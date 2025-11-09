import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../../core/types/unified_types.dart';
import '../../../core/types/ingredient_analysis_types.dart';
import '../../../services/ingredient_analysis_hub.dart';
import '../../../services/analysis_cache_manager.dart';
import '../types/bread_types.dart';
import '../models/integrated_mixing_analysis_types.dart';

/// 특수 시럽/지방 타입별 특성 데이터베이스
class IngredientEffectsDatabase {
  static const Map<String, Map<String, dynamic>> _syrupEffects = {
    '물엿': {
      'glutenImpact': 0.85,
      'fermentationBoost': 1.15,
      'moistureRetention': 1.25,
      'browningEnhancement': 1.30,
      'viscosityIncrease': 1.20,
    },
    '올리고당': {
      'glutenImpact': 0.90,
      'fermentationBoost': 1.10,
      'moistureRetention': 1.15,
      'browningEnhancement': 1.20,
      'viscosityIncrease': 1.10,
    },
    '메이플시럽': {
      'glutenImpact': 0.95,
      'fermentationBoost': 1.05,
      'moistureRetention': 1.20,
      'browningEnhancement': 1.25,
      'viscosityIncrease': 1.05,
    },
    '꿀': {
      'glutenImpact': 0.88,
      'fermentationBoost': 1.20,
      'moistureRetention': 1.35,
      'browningEnhancement': 1.40,
      'viscosityIncrease': 1.30,
    },
    '아가베시럽': {
      'glutenImpact': 0.92,
      'fermentationBoost': 1.08,
      'moistureRetention': 1.18,
      'browningEnhancement': 1.22,
      'viscosityIncrease': 1.08,
    },
  };

  static const Map<String, Map<String, dynamic>> _fatEffects = {
    '버터': {
      'glutenTenderness': 1.25,
      'fermentationInhibition': 0.85,
      'textureEnhancement': 1.35,
      'flavorContribution': 1.40,
      'meltingPoint': 32.0,
    },
    '마가린': {
      'glutenTenderness': 1.15,
      'fermentationInhibition': 0.90,
      'textureEnhancement': 1.20,
      'flavorContribution': 0.80,
      'meltingPoint': 30.0,
    },
    '올리브오일': {
      'glutenTenderness': 1.10,
      'fermentationInhibition': 0.95,
      'textureEnhancement': 1.15,
      'flavorContribution': 1.25,
      'meltingPoint': -6.0,
    },
    '코코넛오일': {
      'glutenTenderness': 1.20,
      'fermentationInhibition': 0.88,
      'textureEnhancement': 1.30,
      'flavorContribution': 1.35,
      'meltingPoint': 25.0,
    },
    '라드': {
      'glutenTenderness': 1.30,
      'fermentationInhibition': 0.80,
      'textureEnhancement': 1.40,
      'flavorContribution': 1.20,
      'meltingPoint': 40.0,
    },
  };

  static const Map<String, Map<String, dynamic>> _interactionEffects = {
    'syrup_butter': {
      'glutenImpact': 0.82,
      'textureEnhancement': 1.45,
      'fermentationBoost': 1.25,
      'stabilityIncrease': 1.35,
    },
    'syrup_olive_oil': {
      'glutenImpact': 0.88,
      'textureEnhancement': 1.30,
      'fermentationBoost': 1.15,
      'stabilityIncrease': 1.20,
    },
    'honey_butter': {
      'glutenImpact': 0.78,
      'textureEnhancement': 1.55,
      'fermentationBoost': 1.35,
      'stabilityIncrease': 1.40,
    },
  };

  /// 시럽 효과 조회
  static Map<String, dynamic>? getSyrupEffect(String syrupType) {
    return _syrupEffects[syrupType];
  }

  /// 지방 효과 조회
  static Map<String, dynamic>? getFatEffect(String fatType) {
    return _fatEffects[fatType];
  }

  /// 상호작용 효과 조회
  static Map<String, dynamic>? getInteractionEffect(String combination) {
    return _interactionEffects[combination];
  }

  /// 시럽 타입 감지
  static String? detectSyrupType(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    for (final syrupType in _syrupEffects.keys) {
      if (lowerName.contains(syrupType.toLowerCase())) {
        return syrupType;
      }
    }

    // 일반적인 시럽 키워드
    if (lowerName.contains('syrup') ||
        lowerName.contains('시럽') ||
        lowerName.contains('물엿')) {
      return '물엿'; // 기본값
    }

    return null;
  }

  /// 지방 타입 감지
  static String? detectFatType(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    for (final fatType in _fatEffects.keys) {
      if (lowerName.contains(fatType.toLowerCase())) {
        return fatType;
      }
    }

    // 일반적인 지방 키워드
    if (lowerName.contains('butter') || lowerName.contains('버터')) {
      return '버터';
    } else if (lowerName.contains('oil') || lowerName.contains('기름')) {
      return '올리브오일';
    } else if (lowerName.contains('fat') || lowerName.contains('지방')) {
      return '마가린';
    }

    return null;
  }
}

/// 향상된 반도 타입 분석기 (Phase 3)
class EnhancedDoughTypeAnalyzer {
  final IngredientAnalysisHub _analysisHub;
  final AnalysisCacheManager _cacheManager;

  EnhancedDoughTypeAnalyzer({
    IngredientAnalysisHub? analysisHub,
    AnalysisCacheManager? cacheManager,
  })  : _analysisHub = analysisHub ?? IngredientAnalysisHub.instance,
        _cacheManager = cacheManager ?? AnalysisCacheManager();

  /// 종합 재료 분석을 통한 반도 타입 분석
  Future<DoughTypeAnalysisResult> analyzeWithIngredientAnalysis({
    required BreadUserData userData,
    required UnifiedRecipe recipe,
    String? breadType,
  }) async {
    try {
      // 1. 캐시된 분석 결과 확인
      final cacheKey = '${recipe.id}_${breadType ?? 'default'}';
      final cachedResult = await _cacheManager.getOrAnalyze(
        recipeId: recipe.id,
        recipeTitle: recipe.title,
        ingredients: recipe.ingredients,
        breadType: breadType ?? recipe.title,
      );

      // 2. 종합 재료 분석 수행
      final ingredientAnalysis = await _analysisHub.analyzeAll(
        recipe.ingredients,
        breadType ?? recipe.title,
      );

      // 3. 재료 효과 기반 반도 타입 분석
      final doughType = await _determineDoughTypeFromEffects(
        recipe: recipe,
        ingredientAnalysis: ingredientAnalysis,
        userData: userData,
      );

      // 4. 신뢰도 계산 (재료 효과 고려)
      final confidence = _calculateConfidenceWithEffects(
        ingredientAnalysis,
        doughType,
        userData,
      );

      // 5. 분석 근거 및 추천사항 생성
      final reasoning = _generateReasoningWithEffects(
        ingredientAnalysis,
        doughType,
        userData,
      );

      final recommendations = _generateRecommendationsWithEffects(
        ingredientAnalysis,
        doughType,
        userData,
      );

      // 6. 분석 데이터 구성
      final analysisData = {
        'ingredientAnalysis': ingredientAnalysis.toJson(),
        'effectsApplied': {
          'syrupEffects': ingredientAnalysis.syrupAnalysis.syrupEffects,
          'fatEffects': ingredientAnalysis.fatAnalysis.fatEffects,
          'integratedEffects': ingredientAnalysis.integratedEffects,
        },
        'doughTypeFactors': _extractDoughTypeFactors(
          ingredientAnalysis,
          doughType,
        ),
        'environmentalFactors': _analyzeEnvironmentalFactors(userData),
      };

      return DoughTypeAnalysisResult(
        doughType: doughType,
        confidence: confidence,
        reasoning: reasoning,
        recommendations: recommendations,
        analysisData: analysisData,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      // 폴백: 기본 분석
      return DoughTypeAnalysisResult(
        doughType: DoughType.lean,
        confidence: 0.5,
        reasoning: ['분석 중 오류가 발생하여 기본 타입으로 설정되었습니다'],
        recommendations: ['재료 정보를 확인하고 다시 분석해보세요'],
        analysisData: {'error': e.toString()},
        analyzedAt: DateTime.now(),
      );
    }
  }

  /// 재료 효과 기반 반도 타입 결정
  Future<DoughType> _determineDoughTypeFromEffects({
    required UnifiedRecipe recipe,
    required ComprehensiveIngredientAnalysis ingredientAnalysis,
    required BreadUserData userData,
  }) async {
    final syrupPercentage =
        ingredientAnalysis.syrupAnalysis.totalSyrupPercentage;
    final fatPercentage = ingredientAnalysis.fatAnalysis.totalFatPercentage;
    final hydrationRatio = _calculateHydrationRatio(recipe);

    // 재료 효과 점수 계산
    final scores = <DoughType, double>{};

    for (final doughType in DoughType.values) {
      if (doughType == DoughType.unknown) continue;

      double score = 0.0;

      // 기본 재료 비율 점수
      score += _calculateBaseIngredientScore(
          doughType, hydrationRatio, syrupPercentage, fatPercentage);

      // 재료 효과 점수
      score += _calculateIngredientEffectScore(doughType, ingredientAnalysis);

      // 환경 요인 점수
      score += _calculateEnvironmentalScore(doughType, userData);

      scores[doughType] = score;
    }

    // 최고 점수 타입 반환
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 수분 비율 계산
  double _calculateHydrationRatio(UnifiedRecipe recipe) {
    double flourWeight = 0.0;
    double waterWeight = 0.0;

    for (final ingredient in recipe.ingredients) {
      final name = ingredient.name.toLowerCase();
      final amount = ingredient.amount;

      if (name.contains('flour') || name.contains('밀가루')) {
        flourWeight += amount;
      } else if (name.contains('water') || name.contains('물')) {
        waterWeight += amount;
      }
    }

    return flourWeight > 0 ? waterWeight / flourWeight : 0.0;
  }

  /// 기본 재료 비율 점수 계산
  double _calculateBaseIngredientScore(
    DoughType doughType,
    double hydrationRatio,
    double syrupPercentage,
    double fatPercentage,
  ) {
    double score = 0.0;

    switch (doughType) {
      case DoughType.lean:
        if (syrupPercentage < 5 && fatPercentage < 5) score += 30;
        if (hydrationRatio >= 0.6 && hydrationRatio <= 0.75) score += 20;
        break;

      case DoughType.rich:
        if (syrupPercentage > 8 || fatPercentage > 8) score += 30;
        if (hydrationRatio >= 0.55 && hydrationRatio <= 0.7) score += 15;
        break;

      case DoughType.highHydration:
        if (hydrationRatio > 0.75) score += 40;
        break;

      case DoughType.lowHydration:
        if (hydrationRatio < 0.6) score += 40;
        break;

      case DoughType.sourdough:
        // 사워도우는 효모 유무로 판단
        break;

      default:
        score += 10;
    }

    return score;
  }

  /// 재료 효과 점수 계산
  double _calculateIngredientEffectScore(
    DoughType doughType,
    ComprehensiveIngredientAnalysis analysis,
  ) {
    double score = 0.0;

    final syrupEffects = analysis.syrupAnalysis.syrupEffects;
    final fatEffects = analysis.fatAnalysis.fatEffects;
    final mixingEffects = analysis.mixingEffects;

    switch (doughType) {
      case DoughType.lean:
        // 글루텐 형성이 중요
        if ((mixingEffects['gluten_development_rate'] ?? 1.0) > 1.0)
          score += 15;
        break;

      case DoughType.rich:
        // 지방과 당분 효과가 중요
        if ((fatEffects['gluten_tenderness'] ?? 0.0) > 0.0) score += 20;
        if ((syrupEffects['moisture_retention'] ?? 0.0) > 0.0) score += 15;
        break;

      case DoughType.highHydration:
        // 수분 조절 능력이 중요
        if ((mixingEffects['hydration_adjustment'] ?? 1.0) > 1.0) score += 25;
        break;

      case DoughType.lowHydration:
        // 낮은 수분 적응력이 중요
        if ((mixingEffects['hydration_adjustment'] ?? 1.0) < 1.0) score += 25;
        break;

      case DoughType.sourdough:
        // 발효 효과가 중요
        if ((analysis.fermentationEffects['yeast_activity_modifier'] ?? 1.0) <
            1.0) score += 20;
        break;

      default:
        score += 5;
    }

    return score;
  }

  /// 환경 요인 점수 계산
  double _calculateEnvironmentalScore(
      DoughType doughType, BreadUserData userData) {
    double score = 0.0;

    final temperature = userData.environment.temperature;
    final difficultyPreference =
        userData.preferences.preferences['difficulty'] as String? ??
            'intermediate';

    switch (doughType) {
      case DoughType.sourdough:
        if (temperature >= 20 && temperature <= 25) score += 15;
        if (difficultyPreference == 'advanced') score += 10;
        break;

      case DoughType.lean:
        if (difficultyPreference == 'beginner' ||
            difficultyPreference == 'intermediate') score += 20;
        break;

      case DoughType.rich:
        if (difficultyPreference == 'intermediate' ||
            difficultyPreference == 'advanced') score += 15;
        break;

      case DoughType.highHydration:
        if (difficultyPreference == 'advanced') score += 20;
        break;

      default:
        score += 10;
    }

    return score;
  }

  /// 재료 효과 고려 신뢰도 계산
  double _calculateConfidenceWithEffects(
    ComprehensiveIngredientAnalysis analysis,
    DoughType doughType,
    BreadUserData userData,
  ) {
    double baseConfidence = 0.6;

    // 재료 효과 명확성에 따른 신뢰도 조정
    final syrupClarity =
        analysis.syrupAnalysis.totalSyrupPercentage > 0 ? 0.1 : 0.0;
    final fatClarity = analysis.fatAnalysis.totalFatPercentage > 0 ? 0.1 : 0.0;
    final effectClarity = (analysis.integratedEffects.isNotEmpty) ? 0.1 : 0.0;

    // 환경 요인 일치도
    final envMatch = _calculateEnvironmentalMatch(doughType, userData);

    return (baseConfidence +
            syrupClarity +
            fatClarity +
            effectClarity +
            envMatch)
        .clamp(0.0, 1.0);
  }

  /// 환경 요인 일치도 계산
  double _calculateEnvironmentalMatch(
      DoughType doughType, BreadUserData userData) {
    final temperature = userData.environment.temperature;
    final difficultyPreference =
        userData.preferences.preferences['difficulty'] as String? ??
            'intermediate';

    double match = 0.0;

    switch (doughType) {
      case DoughType.sourdough:
        if (temperature >= 18 && temperature <= 28) match += 0.1;
        if (difficultyPreference == 'advanced') match += 0.1;
        break;

      case DoughType.highHydration:
        if (difficultyPreference == 'advanced') match += 0.15;
        break;

      case DoughType.lean:
        if (difficultyPreference == 'beginner') match += 0.1;
        break;

      default:
        match += 0.05;
    }

    return match;
  }

  /// 재료 효과 고려 분석 근거 생성
  List<String> _generateReasoningWithEffects(
    ComprehensiveIngredientAnalysis analysis,
    DoughType doughType,
    BreadUserData userData,
  ) {
    final reasoning = <String>[];

    // 기본 타입 설명
    switch (doughType) {
      case DoughType.lean:
        reasoning.add('기본 재료 비율로 팡 도우로 분석됨 (재료 효과 고려)');
        break;
      case DoughType.rich:
        reasoning.add('설탕과 지방 함량이 높아 리치 도우로 분석됨 (재료 효과 고려)');
        break;
      case DoughType.highHydration:
        reasoning.add('수분 함량이 높아 고수분 도우로 분석됨 (재료 효과 고려)');
        break;
      case DoughType.sourdough:
        reasoning.add('천연 효모 특성으로 사워도우로 분석됨 (재료 효과 고려)');
        break;
      default:
        reasoning.add('표준 반도 타입으로 분석됨');
    }

    // 재료 효과 설명
    if (analysis.syrupAnalysis.totalSyrupPercentage > 0) {
      reasoning.add(
          '시럽 함량 ${analysis.syrupAnalysis.totalSyrupPercentage.toStringAsFixed(1)}%가 분석에 반영됨');
    }

    if (analysis.fatAnalysis.totalFatPercentage > 0) {
      reasoning.add(
          '지방 함량 ${analysis.fatAnalysis.totalFatPercentage.toStringAsFixed(1)}%가 분석에 반영됨');
    }

    // 환경 요인 설명
    final temperature = userData.environment.temperature;
    if (temperature < 20) {
      reasoning.add('낮은 온도(${temperature}°C)가 반도 타입 선택에 고려됨');
    } else if (temperature > 28) {
      reasoning.add('높은 온도(${temperature}°C)가 반도 타입 선택에 고려됨');
    }

    return reasoning;
  }

  /// 재료 효과 고려 추천사항 생성
  List<String> _generateRecommendationsWithEffects(
    ComprehensiveIngredientAnalysis analysis,
    DoughType doughType,
    BreadUserData userData,
  ) {
    final recommendations = <String>[];

    // 타입별 기본 추천
    switch (doughType) {
      case DoughType.lean:
        recommendations.add('표준 믹싱 시간을 준수하세요');
        break;
      case DoughType.rich:
        recommendations.add('믹싱 시간을 늘리고 온도를 낮춰 믹싱하세요');
        break;
      case DoughType.highHydration:
        recommendations.add('강력한 믹서 사용을 권장합니다');
        break;
      case DoughType.sourdough:
        recommendations.add('긴 발효 시간을 확보하세요');
        break;
      default:
        recommendations.add('표준 베이킹 파라미터를 따르세요');
    }

    // 재료 효과 기반 추천
    if (analysis.syrupAnalysis.totalSyrupPercentage > 10) {
      recommendations.add('시럽 함량이 높아 수분 조절에 유의하세요');
    }

    if (analysis.fatAnalysis.totalFatPercentage > 15) {
      recommendations.add('지방 함량이 높아 믹싱 속도를 낮춰보세요');
    }

    // 환경 기반 추천
    final temperature = userData.environment.temperature;
    if (temperature < 18) {
      recommendations.add('낮은 온도로 인해 발효 시간을 늘려보세요');
    } else if (temperature > 30) {
      recommendations.add('높은 온도로 인해 믹싱 시간을 단축해보세요');
    }

    // 신뢰도 기반 추천
    final confidence =
        _calculateConfidenceWithEffects(analysis, doughType, userData);
    if (confidence < 0.7) {
      recommendations.add('분석 신뢰도가 낮아 전문가 상담을 권장합니다');
    }

    return recommendations;
  }

  /// 반도 타입 결정 요인 추출
  Map<String, dynamic> _extractDoughTypeFactors(
    ComprehensiveIngredientAnalysis analysis,
    DoughType doughType,
  ) {
    return {
      'hydrationRatio': _calculateHydrationRatioFromAnalysis(analysis),
      'syrupImpact': analysis.syrupAnalysis.totalSyrupPercentage > 5,
      'fatImpact': analysis.fatAnalysis.totalFatPercentage > 5,
      'glutenFormation':
          analysis.mixingEffects['gluten_development_rate'] ?? 1.0,
      'fermentationModifier':
          analysis.fermentationEffects['yeast_activity_modifier'] ?? 1.0,
      'primaryDeterminingFactor': _identifyPrimaryFactor(analysis, doughType),
    };
  }

  /// 분석 결과로부터 수분 비율 계산
  double _calculateHydrationRatioFromAnalysis(
      ComprehensiveIngredientAnalysis analysis) {
    // 실제로는 더 복잡한 계산이 필요하지만 간단히 추정
    final moistureEffect =
        analysis.syrupAnalysis.syrupEffects['moisture_retention'] ?? 1.0;
    return 0.65 * moistureEffect; // 기본 수분 비율에 효과 적용
  }

  /// 주요 결정 요인 식별
  String _identifyPrimaryFactor(
      ComprehensiveIngredientAnalysis analysis, DoughType doughType) {
    final syrupPercentage = analysis.syrupAnalysis.totalSyrupPercentage;
    final fatPercentage = analysis.fatAnalysis.totalFatPercentage;

    if (syrupPercentage > 10) return 'high_syrup_content';
    if (fatPercentage > 10) return 'high_fat_content';
    if (analysis.specialDoughDetection.isSpecialDough)
      return 'special_dough_type';

    return 'base_ingredient_ratio';
  }

  /// 환경 요인 분석
  Map<String, dynamic> _analyzeEnvironmentalFactors(BreadUserData userData) {
    final environment = userData.environment;
    final equipment = userData.equipment;
    final preferences = userData.preferences;

    return {
      'temperature': environment.temperature,
      'humidity': environment.humidity,
      'mixerType': equipment.settings['mixerType'] ?? 'unknown',
      'ovenType': equipment.settings['ovenType'] ?? 'unknown',
      'difficultyPreference':
          preferences.preferences['difficulty'] ?? 'intermediate',
      'timePreference': preferences.preferences['timePreference'] ?? 'normal',
      'automationLevel': preferences.preferences['automationLevel'] ?? 'medium',
    };
  }
}

/// 향상된 반도 타입 분석기 팩토리
class EnhancedDoughTypeAnalyzerFactory {
  static EnhancedDoughTypeAnalyzer createDefault() {
    return EnhancedDoughTypeAnalyzer();
  }

  static EnhancedDoughTypeAnalyzer createCustom({
    IngredientAnalysisHub? analysisHub,
    AnalysisCacheManager? cacheManager,
  }) {
    return EnhancedDoughTypeAnalyzer(
      analysisHub: analysisHub,
      cacheManager: cacheManager,
    );
  }
}
