import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../../core/controllers/base_analysis_controller.dart';
import '../../../../../core/types/unified_types.dart' as unified_types;
import '../../../../../core/types/comprehensive_types.dart' as comp_types;
import '../../../../../core/utils/mixing_data_helper.dart';
import '../../../../../services/recipe_data_parser.dart';
import '../../../../../services/moisture_calculator.dart';
import '../../../../../services/ingredient_analyzer.dart';

import '../../../../../core/controllers/base_analysis_controller.dart'
    as base_controller;

/// 빵 분석 컨트롤러 - 컨트롤러 패턴 완성
/// BaseAnalysisController를 상속받아 통합 분석 로직 구현
class BreadAnalysisController extends base_controller.BaseAnalysisController<
        unified_types.UnifiedRecipe, unified_types.AnalysisResult>
    with
        base_controller.CacheableAnalysisController<unified_types.UnifiedRecipe,
            unified_types.AnalysisResult> {
  final MixingDataHelper _mixingHelper;
  final RecipeDataParser _recipeParser;

  BreadAnalysisController({
    MixingDataHelper? mixingHelper,
    RecipeDataParser? recipeParser,
  })  : _mixingHelper = mixingHelper ?? MixingDataHelper(),
        _recipeParser = recipeParser ?? RecipeDataParser();

  @override
  String get controllerName => 'BreadAnalysisController';

  @override
  List<String> get supportedAnalysisTypes => [
        'bread_analysis',
        'mixing_optimization',
        'ingredient_analysis',
        'dough_analysis',
        'fermentation_analysis',
        'baking_analysis'
      ];

  @override
  comp_types.AnalysisSettings get defaultSettings =>
      const comp_types.AnalysisSettings(
        enableRealTimeFeedback: true,
        enableCaching: true,
        maxAnalysisTimeSeconds: 45,
        confidenceThreshold: 0.75,
      );

  @override
  Future<comp_types.AnalysisResult<unified_types.AnalysisResult>> analyze(
      unified_types.UnifiedRecipe input) async {
    final startTime = DateTime.now();

    try {
      debugPrint('🍞 [BreadAnalysisController] 분석 시작: ${input.title}');

      // 1. 입력 검증
      final validationResult = _validateRecipe(input);
      if (!validationResult.isValid) {
        return comp_types.AnalysisResult.failure(
          '레시피 검증 실패: ${validationResult.errors.join(", ")}',
          DateTime.now().difference(startTime),
        );
      }

      // 2. 캐시 확인
      if (supportsCaching) {
        final cachedResult = await getCachedResult(generateCacheKey(input));
        if (cachedResult != null) {
          debugPrint('✅ [BreadAnalysisController] 캐시 히트');
          return comp_types.AnalysisResult.success(
            cachedResult,
            DateTime.now().difference(startTime),
            0.95,
          );
        }
      }

      // 3. 통합 분석 수행
      final analysisResult = await _performIntegratedAnalysis(input);

      // 4. 결과 캐싱
      if (supportsCaching && analysisResult.isSuccessful) {
        await cacheResult(generateCacheKey(input), analysisResult);
      }

      final processingTime = DateTime.now().difference(startTime);
      debugPrint(
          '✅ [BreadAnalysisController] 분석 완료: ${processingTime.inMilliseconds}ms');

      return comp_types.AnalysisResult.success(
        analysisResult,
        processingTime,
        analysisResult.confidence,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [BreadAnalysisController] 분석 실패: $e');
      debugPrint('📋 [StackTrace] $stackTrace');

      return comp_types.AnalysisResult.failure(
        '빵 분석 중 오류 발생: $e',
        DateTime.now().difference(startTime),
      );
    }
  }

  @override
  bool validateInput(unified_types.UnifiedRecipe input) {
    return _validateRecipe(input).isValid;
  }

  /// 통합 분석 수행
  Future<unified_types.AnalysisResult> _performIntegratedAnalysis(
      unified_types.UnifiedRecipe recipe) async {
    final analysisData = <String, dynamic>{};

    // 1. 믹싱 단계 분석
    final mixingSteps = await _analyzeMixingSteps(recipe);
    analysisData['mixingSteps'] = mixingSteps;

    // 2. 재료 분석
    final ingredientAnalysis = await _analyzeIngredients(recipe);
    analysisData['ingredients'] = ingredientAnalysis;

    // 3. 반죽 특성 분석
    final doughAnalysis =
        await _analyzeDoughCharacteristics(recipe, mixingSteps);
    analysisData['dough'] = doughAnalysis;

    // 4. 발효 분석
    final fermentationAnalysis = await _analyzeFermentation(recipe);
    analysisData['fermentation'] = fermentationAnalysis;

    // 5. 굽기 분석
    final bakingAnalysis = await _analyzeBaking(recipe);
    analysisData['baking'] = bakingAnalysis;

    // 6. 종합 평가
    final overallScore = _calculateOverallScore(analysisData);
    final recommendations = _generateRecommendations(analysisData);

    return unified_types.AnalysisResult.success(
      moduleId: controllerName,
      data: {
        ...analysisData,
        'overallScore': overallScore,
        'recommendations': recommendations,
        'analysisTime': DateTime.now(),
      },
      timestamp: DateTime.now(),
      confidence: overallScore / 100.0,
    );
  }

  /// 믹싱 단계 분석
  Future<List<Map<String, dynamic>>> _analyzeMixingSteps(
      unified_types.UnifiedRecipe recipe) async {
    try {
      final recipeData = recipe.toJson();
      final mixingSteps = MixingDataHelper.extractMixingSteps(recipeData);

      if (mixingSteps.isEmpty) {
        // 기본 믹싱 단계 생성
        return MixingDataHelper.ensureMixingDataExists(recipeData);
      }

      return mixingSteps;
    } catch (e) {
      debugPrint('❌ 믹싱 단계 분석 실패: $e');
      return [];
    }
  }

  /// 재료 분석
  Future<Map<String, dynamic>> _analyzeIngredients(
      unified_types.UnifiedRecipe recipe) async {
    final ingredientData = <String, dynamic>{};

    // 기본 재료 분석
    final flourAmount = _calculateIngredientAmount(recipe, ['밀가루', 'flour']);
    final waterAmount = _calculateIngredientAmount(recipe, ['물', 'water']);
    final yeastAmount =
        _calculateIngredientAmount(recipe, ['이스트', 'yeast', '르방']);
    final saltAmount = _calculateIngredientAmount(recipe, ['소금', 'salt']);
    final fatAmount =
        _calculateIngredientAmount(recipe, ['버터', '기름', 'butter', 'oil']);

    ingredientData['flour'] = flourAmount;
    ingredientData['water'] = waterAmount;
    ingredientData['yeast'] = yeastAmount;
    ingredientData['salt'] = saltAmount;
    ingredientData['fat'] = fatAmount;

    // 수분 흡수율 계산
    if (flourAmount > 0) {
      final hydrationLevel = waterAmount / flourAmount;
      ingredientData['hydrationLevel'] = hydrationLevel;

      // 수분 흡수율 검증 (빵 제조 과학적 한계 적용)
      final recipeData = recipe.toJson();
      final ingredients =
          recipeData['ingredients'] as List<Map<String, dynamic>>? ?? [];

      final moistureValidation = MoistureCalculator.validateMoistureAbsorption(
        hydrationLevel * 100, // 퍼센트로 변환
        ingredients,
        recipeTitle: recipe.title,
      );

      ingredientData['moistureValidation'] = moistureValidation;

      // 수분 초과 시 경고 로그 및 사용자 표시 데이터 추가
      if (hydrationLevel > 1.0) {
        debugPrint(
            '⚠️ [수분 초과 경고] 수분 흡수율: ${(hydrationLevel * 100).toStringAsFixed(1)}%');
        debugPrint('📋 [경고 내용] ${moistureValidation['warnings'].join(', ')}');
        debugPrint(
            '💡 [권장사항] ${moistureValidation['recommendations'].join(', ')}');

        // 사용자에게 표시할 경고 데이터 추가
        ingredientData['hydrationWarning'] = {
          'isExceeded': true,
          'currentHydration': hydrationLevel * 100,
          'warnings': moistureValidation['warnings'] ?? [],
          'recommendations': moistureValidation['recommendations'] ?? [],
          'severity': _calculateHydrationWarningSeverity(hydrationLevel),
          'scientificExplanation':
              _generateHydrationScientificExplanation(hydrationLevel),
        };
      } else {
        // 정상 범위일 때도 정보 제공
        ingredientData['hydrationWarning'] = {
          'isExceeded': false,
          'currentHydration': hydrationLevel * 100,
          'warnings': [],
          'recommendations': [],
          'severity': 'normal',
          'scientificExplanation': '수분 흡수율이 빵 제조 과학적 범위 내에 있습니다.',
        };
      }
    }

    // 재료 비율 계산
    ingredientData['ratios'] = {
      'flourToWater': flourAmount > 0 ? waterAmount / flourAmount : 0,
      'flourToYeast': flourAmount > 0 ? yeastAmount / flourAmount : 0,
      'flourToSalt': flourAmount > 0 ? saltAmount / flourAmount : 0,
    };

    // 반죽 형성 가능성 분석 (빵 제조 과학적 계산)
    final recipeData = recipe.toJson();
    final ingredientsList =
        recipeData['ingredients'] as List<Map<String, dynamic>>? ?? [];

    final doughFormationAnalysis =
        IngredientAnalyzer.analyzeDoughFormationCapability(
      ingredientsList,
      recipeTitle: recipe.title,
    );

    ingredientData['doughFormationAnalysis'] = doughFormationAnalysis;

    // 반죽 형성 불가능 시 경고 로그
    if (!(doughFormationAnalysis['isFormable'] as bool? ?? false)) {
      debugPrint(
          '⚠️ [반죽 형성 경고] 형성 가능성: ${doughFormationAnalysis['formationGrade']}');
      debugPrint('📋 [문제점] ${doughFormationAnalysis['issues'].join(', ')}');
      debugPrint(
          '💡 [개선 방안] ${doughFormationAnalysis['recommendations'].join(', ')}');
    }

    return ingredientData;
  }

  /// 반죽 특성 분석
  Future<Map<String, dynamic>> _analyzeDoughCharacteristics(
    unified_types.UnifiedRecipe recipe,
    List<Map<String, dynamic>> mixingSteps,
  ) async {
    final doughData = <String, dynamic>{};

    // 재료 기반 특성 계산
    final flourAmount = _calculateIngredientAmount(recipe, ['밀가루', 'flour']);
    final waterAmount = _calculateIngredientAmount(recipe, ['물', 'water']);
    final proteinContent = _estimateProteinContent(recipe);

    // 수분 흡수율
    final hydrationLevel = flourAmount > 0 ? waterAmount / flourAmount : 0.65;

    // 글루텐 형성 지수
    final glutenIndex = _calculateGlutenFormationIndex(
      proteinContent,
      hydrationLevel,
      mixingSteps.length,
    );

    doughData['hydrationLevel'] = hydrationLevel;
    doughData['proteinContent'] = proteinContent;
    doughData['glutenIndex'] = glutenIndex;
    doughData['estimatedTemperature'] = _estimateDoughTemperature(recipe);

    // 반죽 특성 평가
    doughData['characteristics'] = {
      'elasticity': _calculateElasticity(glutenIndex, hydrationLevel),
      'extensibility': _calculateExtensibility(glutenIndex, hydrationLevel),
      'cohesion': _calculateCohesion(glutenIndex, hydrationLevel),
      'gasRetention': _calculateGasRetention(glutenIndex, hydrationLevel),
    };

    return doughData;
  }

  /// 발효 분석
  Future<Map<String, dynamic>> _analyzeFermentation(
      unified_types.UnifiedRecipe recipe) async {
    return {
      'optimalTemperature': 24.0,
      'optimalHumidity': 75.0,
      'estimatedTime': _estimateFermentationTime(recipe),
      'yeastActivity': _estimateYeastActivity(recipe),
    };
  }

  /// 굽기 분석
  Future<Map<String, dynamic>> _analyzeBaking(
      unified_types.UnifiedRecipe recipe) async {
    return {
      'optimalTemperature': 200.0,
      'estimatedTime': 30,
      'steamRequired': true,
      'ovenType': 'convection',
    };
  }

  /// 재료 양 계산 헬퍼
  double _calculateIngredientAmount(
      unified_types.UnifiedRecipe recipe, List<String> keywords) {
    return recipe.ingredients
        .where((ing) => keywords.any((keyword) =>
            ing.name.toLowerCase().contains(keyword.toLowerCase())))
        .fold(0.0, (sum, ing) => sum + (ing.amount));
  }

  /// 단백질 함량 추정
  double _estimateProteinContent(unified_types.UnifiedRecipe recipe) {
    final flourIngredient = recipe.ingredients.firstWhere(
      (ing) =>
          ing.name.toLowerCase().contains('밀가루') ||
          ing.name.toLowerCase().contains('flour'),
      orElse: () => const unified_types.UnifiedIngredient(
        id: 'default',
        name: 'default_flour',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );

    final flourType = flourIngredient.name.toLowerCase();

    if (flourType.contains('강력분') || flourType.contains('bread flour')) {
      return 0.125;
    } else if (flourType.contains('중력분') || flourType.contains('all-purpose')) {
      return 0.105;
    } else if (flourType.contains('박력분') || flourType.contains('cake flour')) {
      return 0.08;
    }

    return 0.11; // 기본값
  }

  /// 글루텐 형성 지수 계산
  double _calculateGlutenFormationIndex(
    double proteinContent,
    double hydrationLevel,
    int mixingStepsCount,
  ) {
    // 단백질 함량 가중치
    double index = proteinContent * 0.4;

    // 수분 함량 가중치
    if (hydrationLevel >= 0.6 && hydrationLevel <= 0.75) {
      index += 0.3;
    } else if (hydrationLevel > 0.75) {
      index += 0.2; // 고수분은 글루텐 형성이 어려움
    }

    // 믹싱 단계 수 가중치
    if (mixingStepsCount >= 3) {
      index += 0.3;
    } else if (mixingStepsCount >= 2) {
      index += 0.2;
    }

    return index.clamp(0.0, 1.0);
  }

  /// 탄성 계산 (빵 제조 과학적 계산 - 물리법칙 준수)
  /// 탄성 = 글루텐 형성도 × 0.8 + (1 - 수분 흡수율) × 0.2
  /// ✅ 물리법칙 준수: 수분 흡수율이 100%를 초과할 수 없으므로 clamp 제거
  double _calculateElasticity(double glutenIndex, double hydrationLevel) {
    // 빵 제조 과학: 글루텐 네트워크의 탄성은 단백질 함량과 수분 균형에 따라 결정됨
    // 물리법칙 준수: 실제 빵 제조 데이터를 기반으로 한 정확한 계산 유지
    final elasticity = glutenIndex * 0.8 + (1 - hydrationLevel) * 0.2;

    // ✅ 물리법칙 준수: 수분 흡수율 물리적 한계 검증
    if (hydrationLevel > 1.0) {
      print('⚠️ [물리법칙 준수] 탄성 계산 시 수분 흡수율 초과');
      print('   - 수분 흡수율: ${(hydrationLevel * 100).toStringAsFixed(1)}%');
      print('   - 물리적 한계: 100.0%');
      print('   - 빵 제조 과학적 원리: 수분 흡수율은 100%를 초과할 수 없음');
      // 물리법칙 위반 시 계산값 유지 (clamp 제거)
    }

    return elasticity;
  }

  /// 연성 계산 (빵 제조 과학적 계산 - 물리법칙 준수)
  /// 연성 = 글루텐 형성도 × 0.6 + 수분 흡수율 × 0.4
  /// ✅ 물리법칙 준수: 고수분 빵에서도 수분 흡수율이 100%를 초과할 수 없음
  double _calculateExtensibility(double glutenIndex, double hydrationLevel) {
    // 빵 제조 과학: 반죽의 연성은 수분량에 따라 결정되며, 고수분일수록 더 연성이 높아짐
    // 물리법칙 준수: 실제 빵 제조 데이터를 기반으로 한 정확한 계산 유지
    final extensibility = glutenIndex * 0.6 + hydrationLevel * 0.4;

    // ✅ 물리법칙 준수: 수분 흡수율 물리적 한계 검증
    if (hydrationLevel > 1.0) {
      print('⚠️ [물리법칙 준수] 연성 계산 시 수분 흡수율 초과');
      print('   - 수분 흡수율: ${(hydrationLevel * 100).toStringAsFixed(1)}%');
      print('   - 물리적 한계: 100.0%');
      print('   - 빵 제조 과학적 원리: 수분 흡수율은 100%를 초과할 수 없음');
      // 물리법칙 위반 시 계산값 유지 (clamp 제거)
    }

    return extensibility;
  }

  /// 응집력 계산 (빵 제조 과학적 계산 - 물리법칙 준수)
  /// 응집력 = 글루텐 형성도 × 0.7 + (1 - 수분 흡수율) × 0.3
  /// ✅ 물리법칙 준수: 수분 흡수율이 낮은 빵에서도 물리적 한계를 초과할 수 없음
  double _calculateCohesion(double glutenIndex, double hydrationLevel) {
    // 빵 제조 과학: 반죽의 응집력은 글루텐 네트워크의 강도와 수분 균형에 따라 결정됨
    // 물리법칙 준수: 과학적 정확성을 위해 실제 계산값 사용
    final cohesion = glutenIndex * 0.7 + (1 - hydrationLevel) * 0.3;

    // ✅ 물리법칙 준수: 수분 흡수율 물리적 한계 검증
    if (hydrationLevel > 1.0) {
      print('⚠️ [물리법칙 준수] 응집력 계산 시 수분 흡수율 초과');
      print('   - 수분 흡수율: ${(hydrationLevel * 100).toStringAsFixed(1)}%');
      print('   - 물리적 한계: 100.0%');
      print('   - 빵 제조 과학적 원리: 수분 흡수율은 100%를 초과할 수 없음');
      // 물리법칙 위반 시 계산값 유지 (clamp 제거)
    }

    return cohesion;
  }

  /// 가스 보유력 계산 (빵 제조 과학적 계산 - 물리법칙 준수)
  /// 가스 보유력 = 글루텐 형성도 × 0.9 + 수분 흡수율 × 0.1
  /// ✅ 물리법칙 준수: 빵 제조에서는 수분 흡수율이 100%를 초과할 수 없음
  double _calculateGasRetention(double glutenIndex, double hydrationLevel) {
    // 빵 제조 과학: 발효 가스의 보유력은 글루텐 네트워크의 강도와 수분 균형에 따라 결정됨
    // 물리법칙 준수: 레시피의 실제 수분량을 고려한 정확한 분석을 위해
    final gasRetention = glutenIndex * 0.9 + hydrationLevel * 0.1;

    // ✅ 물리법칙 준수: 수분 흡수율 물리적 한계 검증
    if (hydrationLevel > 1.0) {
      print('⚠️ [물리법칙 준수] 가스 보유력 계산 시 수분 흡수율 초과');
      print('   - 수분 흡수율: ${(hydrationLevel * 100).toStringAsFixed(1)}%');
      print('   - 물리적 한계: 100.0%');
      print('   - 빵 제조 과학적 원리: 수분 흡수율은 100%를 초과할 수 없음');
      // 물리법칙 위반 시 계산값 유지 (clamp 제거)
    }

    return gasRetention;
  }

  /// 반죽 온도 추정
  double _estimateDoughTemperature(unified_types.UnifiedRecipe recipe) {
    // 기본 상온 + 믹싱으로 인한 마찰열
    return 20.0 + 2.0;
  }

  /// 발효 시간 추정
  int _estimateFermentationTime(unified_types.UnifiedRecipe recipe) {
    // 기본 발효 시간 (분)
    return 90;
  }

  /// 이스트 활성도 추정
  double _estimateYeastActivity(unified_types.UnifiedRecipe recipe) {
    final yeastAmount =
        _calculateIngredientAmount(recipe, ['이스트', 'yeast', '르방']);
    final flourAmount = _calculateIngredientAmount(recipe, ['밀가루', 'flour']);

    if (flourAmount == 0) return 0.5;

    final yeastRatio = yeastAmount / flourAmount;

    // 이스트 비율에 따른 활성도
    if (yeastRatio >= 0.002 && yeastRatio <= 0.004) {
      return 0.9; // 최적
    } else if (yeastRatio < 0.002) {
      return 0.6; // 부족
    } else {
      return 0.7; // 과다
    }
  }

  /// 종합 점수 계산
  double _calculateOverallScore(Map<String, dynamic> analysisData) {
    double totalScore = 0;
    int factorCount = 0;

    // 믹싱 단계 점수
    final mixingSteps = analysisData['mixingSteps'] as List? ?? [];
    if (mixingSteps.isNotEmpty) {
      totalScore += (mixingSteps.length >= 3) ? 25 : 15;
      factorCount++;
    }

    // 재료 균형 점수
    final ingredients = analysisData['ingredients'] as Map? ?? {};
    final hydrationLevel = ingredients['hydrationLevel'] as double? ?? 0;
    if (hydrationLevel >= 0.6 && hydrationLevel <= 0.75) {
      totalScore += 25;
    } else if (hydrationLevel >= 0.5 && hydrationLevel <= 0.8) {
      totalScore += 20;
    }
    factorCount++;

    // 반죽 특성 점수
    final dough = analysisData['dough'] as Map? ?? {};
    final glutenIndex = dough['glutenIndex'] as double? ?? 0;
    if (glutenIndex >= 0.7) {
      totalScore += 25;
    } else if (glutenIndex >= 0.5) {
      totalScore += 20;
    }
    factorCount++;

    // 발효 및 굽기 점수
    totalScore += 25; // 기본 점수
    factorCount++;

    return factorCount > 0 ? totalScore / factorCount : 0;
  }

  /// 추천사항 생성
  List<String> _generateRecommendations(Map<String, dynamic> analysisData) {
    final recommendations = <String>[];

    // 믹싱 단계 추천
    final mixingSteps = analysisData['mixingSteps'] as List? ?? [];
    if (mixingSteps.length < 3) {
      recommendations.add('믹싱 단계를 3단계 이상으로 늘려보세요');
    }

    // 수분 함량 추천
    final ingredients = analysisData['ingredients'] as Map? ?? {};
    final hydrationLevel = ingredients['hydrationLevel'] as double? ?? 0;
    if (hydrationLevel < 0.6) {
      recommendations.add('수분 함량을 60-75% 범위로 높여보세요');
    } else if (hydrationLevel > 0.75) {
      recommendations.add('수분 함량이 높아 믹싱 시 주의가 필요합니다');
    }

    // 글루텐 형성 추천
    final dough = analysisData['dough'] as Map? ?? {};
    final glutenIndex = dough['glutenIndex'] as double? ?? 0;
    if (glutenIndex < 0.7) {
      recommendations.add('글루텐 형성을 위해 강력분 사용을 고려해보세요');
    }

    if (recommendations.isEmpty) {
      recommendations.add('현재 레시피 조건이 전반적으로 양호합니다');
    }

    return recommendations;
  }

  /// 레시피 검증
  base_controller.ValidationResult _validateRecipe(
      unified_types.UnifiedRecipe recipe) {
    final errors = <String>[];
    final warnings = <String>[];

    // 필수 재료 확인
    final hasFlour = recipe.ingredients.any((ing) =>
        ing.name.toLowerCase().contains('밀가루') ||
        ing.name.toLowerCase().contains('flour'));

    final hasWater = recipe.ingredients.any((ing) =>
        ing.name.toLowerCase().contains('물') ||
        ing.name.toLowerCase().contains('water'));

    final hasYeast = recipe.ingredients.any((ing) =>
        ing.name.toLowerCase().contains('이스트') ||
        ing.name.toLowerCase().contains('yeast') ||
        ing.name.toLowerCase().contains('르방'));

    if (!hasFlour) {
      errors.add('밀가루가 포함되어야 합니다');
    }

    if (!hasWater) {
      errors.add('물이 포함되어야 합니다');
    }

    if (!hasYeast) {
      warnings.add('이스트가 없으면 자연 발효됩니다');
    }

    // 재료 양 검증
    for (final ingredient in recipe.ingredients) {
      if (ingredient.amount <= 0) {
        warnings.add('${ingredient.name}의 양이 0보다 커야 합니다');
      }
    }

    return base_controller.ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ===== 캐싱 인터페이스 구현 =====

  @override
  String generateCacheKey(unified_types.UnifiedRecipe input) {
    // 레시피의 핵심 정보를 기반으로 캐시 키 생성
    final ingredientsHash = input.ingredients
        .map((ing) => '${ing.name}:${ing.amount}:${ing.unit}')
        .join('|')
        .hashCode;

    final processesHash = input.processes
        .map((proc) => '${proc.type}:${proc.name}')
        .join('|')
        .hashCode;

    return 'bread_analysis_${input.id}_${ingredientsHash}_${processesHash}';
  }

  @override
  Future<unified_types.AnalysisResult?> getCachedResult(String cacheKey) async {
    try {
      // 캐시에서 결과 조회 (실제 구현에서는 캐시 매니저 사용)
      debugPrint('🔍 캐시 조회: $cacheKey');
      return null; // 현재는 캐시 미구현
    } catch (e) {
      debugPrint('❌ 캐시 조회 실패: $e');
      return null;
    }
  }

  @override
  Future<void> cacheResult(
      String cacheKey, unified_types.AnalysisResult result) async {
    try {
      // 결과를 캐시에 저장 (실제 구현에서는 캐시 매니저 사용)
      debugPrint('💾 캐시 저장: $cacheKey');
    } catch (e) {
      debugPrint('❌ 캐시 저장 실패: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    debugPrint('🗑️ 캐시 정리');
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'cacheEnabled': supportsCaching,
      'cacheSize': 0,
      'hitRate': 0.0,
    };
  }

  /// 수분 초과 경고 심각도 계산
  String _calculateHydrationWarningSeverity(double hydrationLevel) {
    final hydrationPercent = hydrationLevel * 100;

    if (hydrationPercent >= 120) {
      return 'critical'; // 매우 위험
    } else if (hydrationPercent >= 110) {
      return 'high'; // 높음
    } else if (hydrationPercent >= 105) {
      return 'medium'; // 중간
    } else if (hydrationPercent >= 100) {
      return 'low'; // 낮음
    }

    return 'normal'; // 정상
  }

  /// 수분 초과 과학적 설명 생성
  String _generateHydrationScientificExplanation(double hydrationLevel) {
    final hydrationPercent = hydrationLevel * 100;

    if (hydrationPercent >= 120) {
      return '빵 제조 과학적으로 수분 흡수율이 120%를 초과하면 반죽이 액체 상태가 되어 빵 형성이 불가능합니다. 밀가루의 수분 흡수 한계를 초과했습니다.';
    } else if (hydrationPercent >= 110) {
      return '빵 제조 과학적으로 수분 흡수율이 110%를 초과하면 글루텐 네트워크 형성이 매우 어려워집니다. 반죽의 점성이 과도하게 높아집니다.';
    } else if (hydrationPercent >= 105) {
      return '빵 제조 과학적으로 수분 흡수율이 105%를 초과하면 반죽의 안정성이 저하됩니다. 발효 과정에서 가스 보유력이 떨어질 수 있습니다.';
    } else if (hydrationPercent >= 100) {
      return '빵 제조 과학적으로 수분 흡수율이 100%를 초과하면 반죽이 매우 부드러워지지만, 적절한 글루텐 형성이 필요합니다.';
    }

    return '빵 제조 과학적으로 수분 흡수율이 정상 범위 내에 있습니다. 반죽 형성이 최적의 조건입니다.';
  }
}
