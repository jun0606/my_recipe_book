// lib/core/services/special_dough_analysis_service.dart
// 특수 반죽 분석 서비스 - 타입 안전한 특수 반죽 분석 정보 공유

import 'dart:convert';
import '../types/special_dough_types.dart';
import '../types/unified_types.dart';
import '../../../features/chef/module/bread/types/bread_types.dart';
import '../../../services/environment_defaults_calculator.dart';
import '../../../services/ingredient_analyzer.dart';
import '../../../services/environment_manager.dart';
import '../../../core/types/environment_types.dart'; // UserEnvironment 추가

/// 특수 반죽 분석 서비스 - 타입 안전한 싱글톤
class SpecialDoughAnalysisService {
  static SpecialDoughAnalysisService? _instance;

  static SpecialDoughAnalysisService get instance {
    _instance ??= SpecialDoughAnalysisService._internal();
    return _instance!;
  }

  SpecialDoughAnalysisService._internal();

  /// 분석 결과 캐시 - 타입 안전한 Map
  final Map<String, SpecialDoughBreadAnalysisResult> _analysisCache = {};

  /// 특수 반죽 분석 수행 - 타입 안전한 메소드
  SpecialDoughBreadAnalysisResult analyzeSpecialDough({
    required List<UnifiedIngredient> ingredients,
    required String title,
    required String recipeId,
    required UserEnvironment environment,
  }) {
    // 캐시 확인
    if (_analysisCache.containsKey(recipeId)) {
      return _analysisCache[recipeId]!;
    }

    // 새로운 분석 수행
    final result = _performSpecialDoughAnalysis(
      ingredients: ingredients,
      title: title,
      recipeId: recipeId,
      environment: environment,
    );

    // 캐시에 저장
    _analysisCache[recipeId] = result;

    return result;
  }

  SpecialDoughBreadAnalysisResult _performSpecialDoughAnalysis({
    required List<UnifiedIngredient> ingredients,
    required String title,
    required String recipeId,
    required UserEnvironment environment,
  }) {
    // 특수 반죽 감지
    final detectionResult = _detectSpecialDoughTypes(ingredients, title);

    // 특수 반죽 특성 계산
    final characteristics =
        _calculateDoughCharacteristics(detectionResult, ingredients);

    // 추천 기법 생성
    final recommendedTechniques =
        _generateRecommendedTechniques(detectionResult);

    // 각 단계별 분석 수행
    final mixingAnalysis =
        _performMixingAnalysis(detectionResult, characteristics, ingredients);
    final fermentationAnalysis = _performFermentationAnalysis(
        detectionResult, characteristics, environment);
    final ovenAnalysis = _performOvenAnalysis(detectionResult, characteristics);

    // 메타데이터 생성
    final metadata =
        _generateSpecialDoughMetadata(detectionResult, characteristics);

    return SpecialDoughBreadAnalysisResult(
      analysisId:
          'special_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      doughType: detectionResult.primaryType.displayName,
      timestamp: DateTime.now(),
      isSuccessful: true,
      data: {
        'detectionResult': detectionResult.toJson(),
        'characteristics': characteristics.toJson(),
        'metadata': metadata,
      },
      mixingAnalysis: mixingAnalysis,
      doughAnalysis: _createDoughAnalysis(detectionResult, characteristics),
      fermentationAnalysis: fermentationAnalysis,
      ovenAnalysis: ovenAnalysis,
      finalResult: _createFinalResult(detectionResult, characteristics),
      specialDoughDetection: detectionResult,
      doughCharacteristics: characteristics,
      recommendedTechniques: recommendedTechniques,
      specialDoughMetadata: metadata,
    );
  }

  /// 특수 반죽 타입 감지 - 타입 안전한 메소드
  SpecialDoughDetectionResult _detectSpecialDoughTypes(
      List<UnifiedIngredient> ingredients, String title) {
    final detector = AdvancedSpecialDoughDetector();
    return detector.detectSpecialDough(ingredients, title);
  }

  /// 특수 반죽 특성 계산 - 타입 안전한 메소드
  SpecialDoughCharacteristics _calculateDoughCharacteristics(
      SpecialDoughDetectionResult detectionResult,
      List<UnifiedIngredient> ingredients) {
    final calculator = SpecialDoughCharacteristicsCalculator();
    return calculator.calculateCharacteristics(detectionResult, ingredients);
  }

  /// 추천 기법 생성 - 타입 안전한 메소드
  List<String> _generateRecommendedTechniques(
      SpecialDoughDetectionResult detectionResult) {
    final generator = SpecialDoughTechniqueGenerator();
    return generator.generateTechniques(detectionResult);
  }

  /// 각 단계별 분석 메소드들 (타입 안전하게 구현)
  Map<String, dynamic> _performMixingAnalysis(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics,
      List<UnifiedIngredient> ingredients) {
    final analyzer = SpecialDoughMixingAnalyzer();
    return analyzer.analyzeMixing(
        detectionResult, characteristics, ingredients);
  }

  Map<String, dynamic> _performFermentationAnalysis(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics,
      UserEnvironment environment) {
    final analyzer = SpecialDoughFermentationAnalyzer();
    return analyzer.analyzeFermentation(
        detectionResult, characteristics, environment);
  }

  Map<String, dynamic> _performOvenAnalysis(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    final analyzer = SpecialDoughOvenAnalyzer();
    return analyzer.analyzeOven(detectionResult, characteristics);
  }

  /// 캐시 관리 메소드들
  void invalidateCache(String recipeId) {
    _analysisCache.remove(recipeId);
  }

  void clearCache() {
    _analysisCache.clear();
  }

  bool hasCachedResult(String recipeId) {
    return _analysisCache.containsKey(recipeId);
  }

  SpecialDoughBreadAnalysisResult? getCachedResult(String recipeId) {
    return _analysisCache[recipeId];
  }

  /// 메타데이터 생성 헬퍼
  Map<String, dynamic> _generateSpecialDoughMetadata(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    return {
      'detectionTimestamp': DateTime.now().toIso8601String(),
      'primaryType': detectionResult.primaryType.name,
      'confidenceScore':
          detectionResult.confidenceScores[detectionResult.primaryType] ?? 0.0,
      'hasComplexDough': detectionResult.hasComplexDough,
      'viscosityMultiplier': characteristics.viscosityMultiplier,
      'glutenStrengthMultiplier': characteristics.glutenStrengthMultiplier,
    };
  }

  /// 도우 분석 생성 헬퍼
  Map<String, dynamic> _createDoughAnalysis(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    return {
      'doughId': 'dough_${DateTime.now().millisecondsSinceEpoch}',
      'hydration': 0.65, // 기본값, 실제로는 계산 필요
      'temperature': 25.0,
      'consistency': detectionResult.primaryType.displayName,
      'analysis': {
        'specialDoughType': detectionResult.primaryType.name,
        'viscosityMultiplier': characteristics.viscosityMultiplier,
        'glutenStrengthMultiplier': characteristics.glutenStrengthMultiplier,
      },
    };
  }

  /// 최종 결과 생성 헬퍼
  Map<String, dynamic> _createFinalResult(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    return {
      'resultId': 'final_${DateTime.now().millisecondsSinceEpoch}',
      'recipeId': '', // 실제로는 레시피 ID 필요
      'scores': {
        'specialDoughScore':
            detectionResult.confidenceScores[detectionResult.primaryType] ??
                0.0,
        'techniqueScore': 0.85,
      },
      'recommendations': detectionResult.detectionReasons,
      'warnings': _generateWarnings(detectionResult),
      'analysis': {
        'specialDoughType': detectionResult.primaryType.name,
        'characteristics': characteristics.toJson(),
      },
    };
  }

  /// 경고 생성 헬퍼
  List<String> _generateWarnings(SpecialDoughDetectionResult detectionResult) {
    final warnings = <String>[];

    if (detectionResult.hasComplexDough) {
      warnings.add('복합 특수 반죽 감지: 각 특성에 맞는 특별한 주의가 필요합니다');
    }

    if (detectionResult.confidenceScores[detectionResult.primaryType]! < 0.7) {
      warnings.add('특수 반죽 감지 신뢰도가 낮습니다. 재료 구성을 확인해주세요');
    }

    return warnings;
  }
}

/// 고급 특수 반죽 감지기 - 타입 안전한 구현
class AdvancedSpecialDoughDetector {
  final Map<String, SpecialDoughType> _keywordMap = {
    // 사워종 관련
    'sourdough': SpecialDoughType.sourdough,
    '사워도우': SpecialDoughType.sourdough,
    '산종': SpecialDoughType.sourdough,
    '자연효모': SpecialDoughType.sourdough,
    'starter': SpecialDoughType.sourdough,

    // 르방 관련
    'levain': SpecialDoughType.levain,
    '르방': SpecialDoughType.levain,

    // 탕종 관련
    'tangzhong': SpecialDoughType.tangzhong,
    '탕종': SpecialDoughType.tangzhong,
    'hot water': SpecialDoughType.tangzhong,
    '뜨거운 물': SpecialDoughType.tangzhong,
    'boiling water': SpecialDoughType.tangzhong,

    // 프랑스 빵 관련
    'baguette': SpecialDoughType.frenchBaguette,
    '바게트': SpecialDoughType.frenchBaguette,
    'croissant': SpecialDoughType.frenchCroissant,
    '크루아상': SpecialDoughType.frenchCroissant,
    '프랑스': SpecialDoughType.frenchBaguette,

    // 파이 관련
    'puff': SpecialDoughType.puffPastry,
    '퍼프': SpecialDoughType.puffPastry,
    'shortcrust': SpecialDoughType.shortcrustPastry,
    '쇼트': SpecialDoughType.shortcrustPastry,
    'flaky': SpecialDoughType.flakyPastry,
    '플레이크': SpecialDoughType.flakyPastry,

    // 이탈리아 빵 관련
    'poolish': SpecialDoughType.poolish,
    '풀리쉬': SpecialDoughType.poolish,
    'biga': SpecialDoughType.biga,
    '비가': SpecialDoughType.biga,

    // 기타 특수 반죽
    'brioche': SpecialDoughType.brioche,
    '브리오슈': SpecialDoughType.brioche,
    'challah': SpecialDoughType.challah,
    '할라': SpecialDoughType.challah,
    'ciabatta': SpecialDoughType.ciabatta,
    '치아바타': SpecialDoughType.ciabatta,
  };

  SpecialDoughDetectionResult detectSpecialDough(
      List<UnifiedIngredient> ingredients, String title) {
    final detectedTypes = <SpecialDoughType>{};
    final confidenceScores = <SpecialDoughType, double>{};
    final detectionReasons = <String>[];

    // 제목 기반 감지
    final titleResult = _detectByTitle(title);
    if (titleResult.hasSpecialDough) {
      detectedTypes.add(titleResult.primaryType);
      confidenceScores[titleResult.primaryType] = 0.9;
      detectionReasons.add('제목에서 ${titleResult.primaryType.displayName} 감지');
    }

    // 재료 기반 감지
    final ingredientResult = _detectByIngredients(ingredients);
    for (final type in ingredientResult.detectedTypes) {
      detectedTypes.add(type);
      confidenceScores[type] = ingredientResult.confidenceScores[type] ?? 0.7;
      detectionReasons.add('재료에서 ${type.displayName} 감지');
    }

    // 패턴 기반 감지
    final patternResult = _detectByPattern(ingredients, title);
    for (final type in patternResult.detectedTypes) {
      detectedTypes.add(type);
      confidenceScores[type] = patternResult.confidenceScores[type] ?? 0.6;
      detectionReasons.add('패턴 분석으로 ${type.displayName} 감지');
    }

    if (detectedTypes.isEmpty) {
      return SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: ['특수 반죽 감지되지 않음'],
      );
    }

    // 최고 신뢰도 타입 선택
    final primaryType = _selectPrimaryType(confidenceScores);

    return SpecialDoughDetectionResult(
      hasSpecialDough: true,
      primaryType: primaryType,
      detectedTypes: detectedTypes.toList(),
      confidenceScores: confidenceScores,
      detectionReasons: detectionReasons,
    );
  }

  SpecialDoughDetectionResult _detectByTitle(String title) {
    final titleLower = title.toLowerCase();

    for (final entry in _keywordMap.entries) {
      if (titleLower.contains(entry.key.toLowerCase())) {
        return SpecialDoughDetectionResult(
          hasSpecialDough: true,
          primaryType: entry.value,
          detectedTypes: [entry.value],
          confidenceScores: {entry.value: 0.9},
          detectionReasons: ['제목 키워드 매칭: ${entry.key}'],
        );
      }
    }

    return SpecialDoughDetectionResult(
      hasSpecialDough: false,
      primaryType: SpecialDoughType.standard,
      detectedTypes: [],
      confidenceScores: {},
      detectionReasons: [],
    );
  }

  SpecialDoughDetectionResult _detectByIngredients(
      List<UnifiedIngredient> ingredients) {
    final detectedTypes = <SpecialDoughType>{};
    final confidenceScores = <SpecialDoughType, double>{};
    final detectionReasons = <String>[];

    // 재료명 기반 감지
    for (final ingredient in ingredients) {
      final nameLower = ingredient.name.toLowerCase();

      for (final entry in _keywordMap.entries) {
        if (nameLower.contains(entry.key.toLowerCase())) {
          detectedTypes.add(entry.value);
          confidenceScores[entry.value] = 0.8;
          detectionReasons.add('재료명: ${ingredient.name}');
        }
      }
    }

    return SpecialDoughDetectionResult(
      hasSpecialDough: detectedTypes.isNotEmpty,
      primaryType: detectedTypes.isNotEmpty
          ? detectedTypes.first
          : SpecialDoughType.standard,
      detectedTypes: detectedTypes.toList(),
      confidenceScores: confidenceScores,
      detectionReasons: detectionReasons,
    );
  }

  SpecialDoughDetectionResult _detectByPattern(
      List<UnifiedIngredient> ingredients, String title) {
    // 재료 비율 기반 패턴 감지
    final totalWeight = _calculateTotalWeight(ingredients);
    if (totalWeight == 0) {
      return SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );
    }

    final flourWeight = _calculateFlourWeight(ingredients);
    final fatWeight = _calculateFatWeight(ingredients);
    final liquidWeight = _calculateLiquidWeight(ingredients);

    final flourRatio = flourWeight / totalWeight;
    final fatRatio = fatWeight / totalWeight;
    final hydrationRatio = liquidWeight / flourWeight;

    final detectedTypes = <SpecialDoughType>[];
    final confidenceScores = <SpecialDoughType, double>{};
    final detectionReasons = <String>[];

    // 바게트 패턴: 높은 수분율, 낮은 지방
    if (hydrationRatio > 0.7 && fatRatio < 0.05) {
      detectedTypes.add(SpecialDoughType.frenchBaguette);
      confidenceScores[SpecialDoughType.frenchBaguette] = 0.7;
      detectionReasons.add('높은 수분율 패턴 감지');
    }

    // 크루아상 패턴: 높은 지방, 낮은 수분율
    if (fatRatio > 0.3 && hydrationRatio < 0.6) {
      detectedTypes.add(SpecialDoughType.frenchCroissant);
      confidenceScores[SpecialDoughType.frenchCroissant] = 0.7;
      detectionReasons.add('높은 지방 패턴 감지');
    }

    // 퍼프 페이스트리 패턴: 매우 높은 지방
    if (fatRatio > 0.4) {
      detectedTypes.add(SpecialDoughType.puffPastry);
      confidenceScores[SpecialDoughType.puffPastry] = 0.8;
      detectionReasons.add('매우 높은 지방 비율 감지');
    }

    return SpecialDoughDetectionResult(
      hasSpecialDough: detectedTypes.isNotEmpty,
      primaryType: detectedTypes.isNotEmpty
          ? detectedTypes.first
          : SpecialDoughType.standard,
      detectedTypes: detectedTypes,
      confidenceScores: confidenceScores,
      detectionReasons: detectionReasons,
    );
  }

  SpecialDoughType _selectPrimaryType(
      Map<SpecialDoughType, double> confidenceScores) {
    if (confidenceScores.isEmpty) return SpecialDoughType.standard;

    return confidenceScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _calculateTotalWeight(List<UnifiedIngredient> ingredients) {
    return ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  double _calculateFlourWeight(List<UnifiedIngredient> ingredients) {
    return ingredients
        .where((ingredient) => IngredientAnalyzer.isFlour(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  double _calculateFatWeight(List<UnifiedIngredient> ingredients) {
    return ingredients
        .where((ingredient) => _isFat(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  double _calculateLiquidWeight(List<UnifiedIngredient> ingredients) {
    return ingredients
        .where((ingredient) => _isLiquid(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  bool _isFlour(String name) {
    final flourKeywords = ['밀가루', 'flour', '강력분', '박력분', '통밀'];
    return flourKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  bool _isFat(String name) {
    final fatKeywords = ['버터', 'butter', '기름', 'oil', '마가린', 'margarine'];
    return fatKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  bool _isLiquid(String name) {
    final liquidKeywords = ['물', 'water', '우유', 'milk', '물엿', 'malt'];
    return liquidKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }
}

/// 특수 반죽 특성 계산기 - 타입 안전한 구현
class SpecialDoughCharacteristicsCalculator {
  SpecialDoughCharacteristics calculateCharacteristics(
      SpecialDoughDetectionResult detectionResult,
      List<UnifiedIngredient> ingredients) {
    if (!detectionResult.hasSpecialDough) {
      return SpecialDoughCharacteristics.standard();
    }

    return SpecialDoughCharacteristics.fromType(detectionResult.primaryType);
  }
}

/// 특수 반죽 기법 생성기 - 타입 안전한 구현
class SpecialDoughTechniqueGenerator {
  final Map<SpecialDoughType, List<String>> recommendedTechniques = {
    SpecialDoughType.sourdough: [
      'autolyse',
      'stretch_and_fold',
      'bulk_fermentation_with_folds',
      'cold_retard',
    ],
    SpecialDoughType.levain: [
      'levain_feeding_schedule',
      'stretch_and_fold',
      'extended_bulk_fermentation',
    ],
    SpecialDoughType.tangzhong: [
      'tangzhong_cooling',
      'gentle_mixing',
      'steam_baking',
    ],
    SpecialDoughType.frenchBaguette: [
      'french_fold',
      'extended_autolyse',
      'steam_injection',
      'cooling_rack_immediate',
    ],
    SpecialDoughType.frenchCroissant: [
      'lamination_technique',
      'butter_block_preparation',
      'cold_processing',
      'egg_wash',
    ],
    SpecialDoughType.puffPastry: [
      'cold_butter_incorporation',
      'minimal_handling',
      'rest_periods',
      'blind_baking',
    ],
    SpecialDoughType.shortcrustPastry: [
      'cold_butter_incorporation',
      'minimal_handling',
      'rest_periods',
    ],
    SpecialDoughType.flakyPastry: [
      'cold_butter_incorporation',
      'minimal_handling',
      'rest_periods',
      'flake_technique',
    ],
    SpecialDoughType.poolish: [
      'poolish_maturation',
      'gentle_mixing',
      'extended_fermentation',
    ],
    SpecialDoughType.biga: [
      'biga_maturation',
      'gentle_mixing',
      'extended_fermentation',
    ],
    SpecialDoughType.brioche: [
      'enriched_dough_technique',
      'cold_fermentation',
      'egg_wash',
    ],
    SpecialDoughType.challah: [
      'braiding_technique',
      'egg_wash',
      'steam_baking',
    ],
    SpecialDoughType.ciabatta: [
      'high_hydration_technique',
      'stretch_and_fold',
      'steam_baking',
    ],
  };

  List<String> generateTechniques(SpecialDoughDetectionResult detectionResult) {
    final techniques = <String>[];

    // 주요 타입의 기법 추가
    if (recommendedTechniques.containsKey(detectionResult.primaryType)) {
      techniques.addAll(recommendedTechniques[detectionResult.primaryType]!);
    }

    // 복합 특수 반죽인 경우 추가 기법
    if (detectionResult.hasComplexDough) {
      techniques.add('complex_dough_handling');
      techniques.add('temperature_monitoring');
    }

    // 중복 제거 및 정렬
    return techniques.toSet().toList()..sort();
  }
}

/// 특수 반죽 믹싱 분석기 - 타입 안전한 구현
class SpecialDoughMixingAnalyzer {
  Map<String, dynamic> analyzeMixing(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics,
      List<UnifiedIngredient> ingredients) {
    final primaryType = detectionResult.primaryType;

    return {
      'recommendedSpeed': primaryType.recommendedMixingSpeed,
      'recommendedTime': primaryType.recommendedMixingTime,
      'viscosityMultiplier': characteristics.viscosityMultiplier,
      'glutenStrengthMultiplier': characteristics.glutenStrengthMultiplier,
      'specialInstructions': _getMixingInstructions(primaryType),
      'successProbability':
          _calculateMixingSuccessProbability(detectionResult, characteristics),
    };
  }

  List<String> _getMixingInstructions(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return ['저속으로 시작하여 점진적으로 속도 높이기', '글루텐 네트워크 형성에 충분한 시간 할당'];
      case SpecialDoughType.tangzhong:
        return ['탕종을 실온으로 식힌 후 투입', '부드럽게 섞어 호화 전분 파괴 방지'];
      case SpecialDoughType.frenchBaguette:
        return ['프렌치 폴드 기법 사용', '글루텐 스트랭스 강화에 초점'];
      case SpecialDoughType.frenchCroissant:
        return ['차가운 상태에서 믹싱', '버터가 녹지 않도록 주의'];
      case SpecialDoughType.puffPastry:
        return ['버터가 녹지 않도록 매우 차가운 상태 유지', '최소한의 믹싱으로 층 형성'];
      default:
        return ['표준 믹싱 기법 적용'];
    }
  }

  double _calculateMixingSuccessProbability(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    double baseProbability = 0.85;

    // 특수 반죽 타입별 보정
    switch (detectionResult.primaryType) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        baseProbability *= 0.9; // 사워종 계열은 다루기 어려움
        break;
      case SpecialDoughType.tangzhong:
        baseProbability *= 1.1; // 탕종은 상대적으로 쉬움
        break;
      case SpecialDoughType.frenchBaguette:
        baseProbability *= 0.95; // 바게트는 숙련 필요
        break;
      case SpecialDoughType.frenchCroissant:
        baseProbability *= 0.8; // 크루아상은 고난도
        break;
      default:
        break;
    }

    // 신뢰도 기반 보정
    final confidence =
        detectionResult.confidenceScores[detectionResult.primaryType] ?? 0.5;
    baseProbability *= (0.5 + confidence * 0.5);

    return baseProbability.clamp(0.0, 1.0);
  }
}

/// 특수 반죽 발효 분석기 - 타입 안전한 구현
class SpecialDoughFermentationAnalyzer {
  Map<String, dynamic> analyzeFermentation(
      SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics,
      UserEnvironment environment) {
    final primaryType = detectionResult.primaryType;

    return {
      'optimalTemperature': _getOptimalFermentationTemperature(primaryType),
      'optimalHumidity': _getOptimalHumidity(primaryType),
      'recommendedDuration': _getRecommendedFermentationDuration(primaryType),
      'fermentationToleranceMultiplier':
          characteristics.fermentationToleranceMultiplier,
      'specialInstructions': _getFermentationInstructions(primaryType),
    };
  }

  double _getOptimalFermentationTemperature(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return 27.0; // 사워종 계열은 약간 높은 온도
      case SpecialDoughType.tangzhong:
        // 동적 계산 적용 - 하드코딩 제거
        return EnvironmentDefaultsCalculator.getDefaultEnvironment()
                .temperature +
            3.0; // 탕종은 효모 활성에 유리
      case SpecialDoughType.frenchBaguette:
        return 26.0; // 바게트는 풍미 발달에 적합
      case SpecialDoughType.frenchCroissant:
        return 24.0; // 크루아상은 느린 발효 선호
      case SpecialDoughType.puffPastry:
        return 25.0; // 퍼프는 보통 온도
      default:
        return 25.0;
    }
  }

  double _getOptimalHumidity(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.frenchBaguette:
        return 75.0; // 바게트는 높은 습도
      case SpecialDoughType.ciabatta:
        return 80.0; // 치아바타는 매우 높은 습도
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return 70.0; // 사워종 계열은 보통 습도
      default:
        return 65.0;
    }
  }

  int _getRecommendedFermentationDuration(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.sourdough:
        return 180; // 3시간
      case SpecialDoughType.levain:
        return 240; // 4시간
      case SpecialDoughType.tangzhong:
        return 90; // 1.5시간
      case SpecialDoughType.poolish:
        return 120; // 2시간
      case SpecialDoughType.biga:
        return 120; // 2시간
      case SpecialDoughType.frenchCroissant:
        return 120; // 2시간 (느린 발효)
      default:
        return 120; // 2시간 (기본)
    }
  }

  List<String> _getFermentationInstructions(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return ['주기적으로 반죽 접기', '산미 변화 모니터링', '부피 증가율 확인'];
      case SpecialDoughType.tangzhong:
        return ['효모 활성 모니터링', '습도 유지', '과발효 방지'];
      case SpecialDoughType.frenchBaguette:
        return ['풍미 발달 모니터링', '부피 증가율 확인', '껍질 형성 준비'];
      case SpecialDoughType.frenchCroissant:
        return ['버터 층 유지', '느린 발효 진행', '냉장 발효 고려'];
      default:
        return ['표준 발효 조건 유지'];
    }
  }
}

/// 특수 반죽 굽기 분석기 - 타입 안전한 구현
class SpecialDoughOvenAnalyzer {
  Map<String, dynamic> analyzeOven(SpecialDoughDetectionResult detectionResult,
      SpecialDoughCharacteristics characteristics) {
    final primaryType = detectionResult.primaryType;

    return {
      'optimalTemperature': _getOptimalBakingTemperature(primaryType),
      'recommendedDuration': _getRecommendedBakingDuration(primaryType),
      'steamRequirement': _getSteamRequirement(primaryType),
      'specialInstructions': _getBakingInstructions(primaryType),
    };
  }

  int _getOptimalBakingTemperature(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.frenchBaguette:
        return 240; // 바게트는 고온
      case SpecialDoughType.frenchCroissant:
        return 200; // 크루아상은 중간 온도
      case SpecialDoughType.puffPastry:
        return 200; // 퍼프는 중간 온도
      case SpecialDoughType.ciabatta:
        return 230; // 치아바타는 고온
      case SpecialDoughType.brioche:
        return 180; // 브리오슈는 낮은 온도
      default:
        return 200; // 기본 온도
    }
  }

  int _getRecommendedBakingDuration(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.frenchBaguette:
        return 25; // 바게트는 빠른 굽기
      case SpecialDoughType.frenchCroissant:
        return 18; // 크루아상은 중간 시간
      case SpecialDoughType.puffPastry:
        return 20; // 퍼프는 적당한 시간
      case SpecialDoughType.ciabatta:
        return 20; // 치아바타는 중간 시간
      case SpecialDoughType.brioche:
        return 30; // 브리오슈는 긴 시간
      default:
        return 25; // 기본 시간
    }
  }

  bool _getSteamRequirement(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.frenchBaguette:
      case SpecialDoughType.ciabatta:
        return true; // 스팀 필수
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return true; // 스팀 권장
      default:
        return false; // 스팀 불필요
    }
  }

  List<String> _getBakingInstructions(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.frenchBaguette:
        return ['초반 15분 스팀 공급', '중간 온도 드롭', '바로 꺼내서 냉각'];
      case SpecialDoughType.frenchCroissant:
        return ['계란칠 후 굽기', '중간 온도 유지', '황금색으로 굽기'];
      case SpecialDoughType.puffPastry:
        return ['고온 시작 후 온도 낮추기', '겉면이 황금색 될 때까지 굽기'];
      case SpecialDoughType.ciabatta:
        return ['스팀으로 습도 유지', '바삭한 겉면 형성'];
      default:
        return ['표준 굽기 조건 적용'];
    }
  }
}
