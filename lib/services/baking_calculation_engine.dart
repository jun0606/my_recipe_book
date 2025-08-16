import 'package:my_recipe_book/models/enhanced_recipe.dart';
import 'package:my_recipe_book/models/baking_calculation_result.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/cost_analysis.dart';
import 'package:my_recipe_book/models/user_configuration.dart';
import 'package:my_recipe_book/services/scaling_engine.dart';
import 'package:my_recipe_book/services/unit_conversion_engine.dart';
import 'package:my_recipe_book/services/environmental_adjustment_engine.dart';

/// 베이킹 계산을 담당하는 메인 파사드 클래스
/// 모든 계산 엔진들을 조율하여 최종 결과를 생성합니다.
class BakingCalculationEngine {
  final ScalingEngine _scalingEngine;
  final UnitConversionEngine _unitConversionEngine;
  final EnvironmentalAdjustmentEngine _environmentalEngine;

  BakingCalculationEngine({
    ScalingEngine? scalingEngine,
    UnitConversionEngine? unitConversionEngine,
    EnvironmentalAdjustmentEngine? environmentalEngine,
  })  : _scalingEngine = scalingEngine ?? ScalingEngine(),
        _unitConversionEngine = unitConversionEngine ?? UnitConversionEngine(),
        _environmentalEngine = environmentalEngine ?? EnvironmentalAdjustmentEngine();

  /// 종합적인 베이킹 계산을 수행합니다.
  /// 
  /// 계산 순서:
  /// 1. 스케일링 (양 조절)
  /// 2. 환경 조건 보정
  /// 3. 단위 변환
  /// 4. 최종 결과 검증 및 제안 생성
  Future<BakingCalculationResult> calculate({
    required EnhancedRecipe recipe,
    double? scaleFactor,
    double? targetWeight,
    String? targetUnit,
    EnvironmentalConditions? environmentalConditions,
    UserConfiguration? userConfig,
  }) async {
    try {
      final calculations = <String, dynamic>{};
      final warnings = <ValidationWarning>[];
      final suggestions = <Suggestion>[];

      // 1. 스케일링 단계
      EnhancedRecipe scaledRecipe = recipe;
      if (scaleFactor != null && scaleFactor != 1.0) {
        final scalingResult = await _scalingEngine.scaleRecipe(
          recipe: recipe,
          scaleFactor: scaleFactor,
        );
        scaledRecipe = scalingResult.scaledRecipe;
        calculations['scaling'] = scalingResult.calculations;
        warnings.addAll(scalingResult.warnings);
      } else if (targetWeight != null) {
        final scalingResult = await _scalingEngine.scaleToWeight(
          recipe: recipe,
          targetWeight: targetWeight,
        );
        scaledRecipe = scalingResult.scaledRecipe;
        calculations['scaling'] = scalingResult.calculations;
        warnings.addAll(scalingResult.warnings);
      }

      // 2. 환경 조건 보정 단계
      EnhancedRecipe adjustedRecipe = scaledRecipe;
      EnvironmentalAdjustment? environmentalAdjustment;
      if (environmentalConditions != null) {
        final adjustmentResult = await _environmentalEngine.adjustForEnvironment(
          recipe: scaledRecipe,
          conditions: environmentalConditions,
        );
        adjustedRecipe = adjustmentResult.adjustedRecipe;
        environmentalAdjustment = adjustmentResult.adjustment;
        calculations['environmental'] = adjustmentResult.calculations;
        warnings.addAll(adjustmentResult.warnings);
        suggestions.addAll(adjustmentResult.suggestions);
      }

      // 3. 단위 변환 단계
      EnhancedRecipe finalRecipe = adjustedRecipe;
      if (targetUnit != null) {
        final conversionResult = await _unitConversionEngine.convertRecipeUnits(
          recipe: adjustedRecipe,
          targetUnit: targetUnit,
          userConfig: userConfig,
        );
        finalRecipe = conversionResult.convertedRecipe;
        calculations['unitConversion'] = conversionResult.calculations;
        warnings.addAll(conversionResult.warnings);
      }

      // 4. 최종 검증 및 제안 생성
      final validationResults = _validateResult(finalRecipe, recipe);
      warnings.addAll(validationResults.warnings);
      suggestions.addAll(validationResults.suggestions);

      // 5. 비용 분석 (선택적)
      CostAnalysis? costAnalysis;
      if (userConfig?.preferences['includeCostAnalysis'] == true) {
        costAnalysis = await _calculateCostAnalysis(finalRecipe, userConfig);
      }

      return BakingCalculationResult(
        originalRecipe: recipe,
        calculatedRecipe: finalRecipe,
        calculationMode: BakingCalculationMode.scaleAdjustment,
        calculations: calculations,
        warnings: warnings,
        suggestions: suggestions,
        environmentalAdjustment: environmentalAdjustment,
        costAnalysis: costAnalysis,
        scale: scaleFactor ?? _calculateActualScaleFactor(recipe, finalRecipe),
      );
    } catch (e) {
      throw BakingCalculationException('계산 중 오류가 발생했습니다: $e');
    }
  }

  /// 간단한 스케일링만 수행하는 메서드
  Future<BakingCalculationResult> scaleOnly({
    required EnhancedRecipe recipe,
    required double scaleFactor,
  }) async {
    return calculate(
      recipe: recipe,
      scaleFactor: scaleFactor,
    );
  }

  /// 무게 기준 스케일링만 수행하는 메서드
  Future<BakingCalculationResult> scaleToWeight({
    required EnhancedRecipe recipe,
    required double targetWeight,
  }) async {
    return calculate(
      recipe: recipe,
      targetWeight: targetWeight,
    );
  }

  /// 단위 변환만 수행하는 메서드
  Future<BakingCalculationResult> convertUnits({
    required EnhancedRecipe recipe,
    required String targetUnit,
    UserConfiguration? userConfig,
  }) async {
    return calculate(
      recipe: recipe,
      targetUnit: targetUnit,
      userConfig: userConfig,
    );
  }

  /// 결과 검증 및 제안 생성
  ValidationResult _validateResult(EnhancedRecipe finalRecipe, EnhancedRecipe originalRecipe) {
    final warnings = <ValidationWarning>[];
    final suggestions = <Suggestion>[];

    // 베이커스 퍼센트 검증
    if (finalRecipe.bakersPercentages != null && originalRecipe.bakersPercentages != null) {
      final originalTotal = originalRecipe.bakersPercentages!.values.fold(0.0, (a, b) => a + b);
      final finalTotal = finalRecipe.bakersPercentages!.values.fold(0.0, (a, b) => a + b);
      
      if ((originalTotal - finalTotal).abs() > 1.0) {
        warnings.add(ValidationWarning(
          level: ValidationLevel.warning,
          message: '베이커스 퍼센트 총합이 변경되었습니다 (${originalTotal.toStringAsFixed(1)}% → ${finalTotal.toStringAsFixed(1)}%)',
          category: 'bakers_percentage',
        ));
      }
    }

    // 수분량 검증
    if (finalRecipe.hydrationLevel != null) {
      if (finalRecipe.hydrationLevel! < 50) {
        warnings.add(ValidationWarning(
          level: ValidationLevel.info,
          message: '수분량이 낮습니다 (${finalRecipe.hydrationLevel!.toStringAsFixed(1)}%). 반죽이 딱딱할 수 있습니다.',
          suggestion: '물이나 우유를 조금 더 추가해보세요.',
          category: 'hydration',
        ));
      } else if (finalRecipe.hydrationLevel! > 85) {
        warnings.add(ValidationWarning(
          level: ValidationLevel.warning,
          message: '수분량이 높습니다 (${finalRecipe.hydrationLevel!.toStringAsFixed(1)}%). 반죽이 끈적할 수 있습니다.',
          suggestion: '밀가루를 조금 더 추가하거나 오토리즈 기법을 사용해보세요.',
          category: 'hydration',
        ));
      }
    }

    // 최적화 제안
    if (finalRecipe.category == 'bread') {
      suggestions.add(Suggestion(
        title: '발효 시간 최적화',
        description: '현재 환경 조건에서 최적의 발효 시간을 확인해보세요.',
        priority: 0.8,
      ));
    }

    return ValidationResult(warnings: warnings, suggestions: suggestions);
  }

  /// 실제 스케일링 팩터 계산
  double _calculateActualScaleFactor(EnhancedRecipe original, EnhancedRecipe finalRecipe) {
    if (original.ingredients.isEmpty || finalRecipe.ingredients.isEmpty) return 1.0;
    
    // 첫 번째 재료의 양을 기준으로 스케일링 팩터 계산
    final originalAmount = original.ingredients.first['amount'] as double? ?? 1.0;
    final finalAmount = finalRecipe.ingredients.first['amount'] as double? ?? 1.0;
    
    return finalAmount / originalAmount;
  }

  // 사용하지 않는 메서드 제거됨

  /// 비용 분석 계산
  Future<CostAnalysis?> _calculateCostAnalysis(EnhancedRecipe recipe, UserConfiguration? userConfig) async {
    // 실제 구현에서는 재료별 가격 데이터베이스를 참조
    // 여기서는 기본적인 구조만 제공
    final ingredientCosts = <String, double>{};
    double totalCost = 0.0;

    for (final ingredient in recipe.ingredients) {
      final name = ingredient['name'] as String;
      final amount = ingredient['amount'] as double? ?? 0.0;
      
      // 기본 가격 (실제로는 데이터베이스에서 조회)
      final unitPrice = _getIngredientPrice(name);
      final cost = amount * unitPrice;
      
      ingredientCosts[name] = cost;
      totalCost += cost;
    }

    return CostAnalysis(
      ingredientCosts: ingredientCosts,
      totalCost: totalCost,
      profitMargin: 0.3, // 기본 30% 마진
      suggestedPrice: totalCost * 1.5, // 기본 50% 마크업
    );
  }

  /// 재료별 기본 가격 조회 (임시 구현)
  double _getIngredientPrice(String ingredientName) {
    final prices = {
      '밀가루': 0.002, // 원/g
      '물': 0.0001,
      '소금': 0.001,
      '설탕': 0.003,
      '이스트': 0.01,
      '버터': 0.008,
      '계란': 0.005,
    };
    
    return prices[ingredientName] ?? 0.002; // 기본값
  }
}

/// 계산 관련 예외 클래스
class BakingCalculationException implements Exception {
  final String message;
  BakingCalculationException(this.message);
  
  @override
  String toString() => 'BakingCalculationException: $message';
}

/// 검증 결과를 담는 클래스
class ValidationResult {
  final List<ValidationWarning> warnings;
  final List<Suggestion> suggestions;

  ValidationResult({
    required this.warnings,
    required this.suggestions,
  });
}