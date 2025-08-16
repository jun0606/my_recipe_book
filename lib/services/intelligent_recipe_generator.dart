/// 지능적 레시피 생성 엔진
/// 고도화된 알고리즘으로 목표에 맞는 최적 레시피를 생성합니다.

import 'dart:math' as math;
import '../models/recipe_target.dart';
import '../services/product_status_generator.dart';
import '../services/real_time_recipe_analyzer.dart';
import '../services/baking_science_engine.dart';

class IntelligentRecipeGenerator {
  /// 지능적 레시피 생성
  static Future<GeneratedRecipeResult> generateIntelligentRecipe({
    required RecipeTarget target,
    required Map<String, dynamic> environmentalConditions,
    String? baseRecipeType,
  }) async {
    try {
      // 1. 베이킹 타입별 최적 기본 비율 로드
      final baseRatios = _getOptimalBaseRatios(target.targetBakingType);
      
      // 2. 목표 특성 기반 정밀 조정
      final adjustedRatios = _precisionAdjustment(target, baseRatios);
      
      // 3. 환경 조건 반영
      final environmentAdjustedRatios = _applyEnvironmentalFactors(
        adjustedRatios, 
        environmentalConditions
      );
      
      // 4. 재료 상호작용 최적화
      final optimizedRatios = _optimizeIngredientInteractions(
        environmentAdjustedRatios, 
        target
      );
      
      // 5. 최종 재료 리스트 생성
      final ingredients = _generateIngredientList(optimizedRatios, target);
      
      // 6. 다단계 검증 및 보정
      final validatedIngredients = await _multiStageValidation(
        ingredients, 
        target, 
        environmentalConditions
      );
      
      // 7. 품질 예측 및 결과 생성
      final result = await _generateFinalResult(
        validatedIngredients, 
        target, 
        environmentalConditions,
        optimizedRatios
      );
      
      return result;
    } catch (e) {
      throw IntelligentRecipeGenerationException('지능적 레시피 생성 중 오류: $e');
    }
  }

  /// 베이킹 타입별 최적 기본 비율
  static Map<String, double> _getOptimalBaseRatios(String bakingType) {
    final baseRatiosDatabase = {
      '식빵': {
        '강력분': 100.0,
        '물': 65.0,
        '설탕': 6.0,
        '소금': 2.0,
        '드라이이스트': 1.2,
        '버터': 8.0,
      },
      '촉촉한 식빵': {
        '강력분': 100.0,
        '물': 55.0,
        '우유': 25.0,
        '계란': 15.0,
        '설탕': 8.0,
        '소금': 1.8,
        '드라이이스트': 1.0,
        '버터': 12.0,
      },
      '쫄깃한 식빵': {
        '강력분': 100.0,
        '물': 70.0,
        '설탕': 4.0,
        '소금': 2.2,
        '드라이이스트': 1.5,
        '버터': 5.0,
      },
      '바삭한 크러스트 빵': {
        '강력분': 100.0,
        '물': 60.0,
        '설탕': 2.0,
        '소금': 2.5,
        '드라이이스트': 0.8,
        '올리브오일': 3.0,
      },
      '브리오슈': {
        '강력분': 100.0,
        '우유': 30.0,
        '계란': 40.0,
        '설탕': 15.0,
        '소금': 1.5,
        '드라이이스트': 1.0,
        '버터': 25.0,
      },
      '케이크': {
        '박력분': 100.0,
        '설탕': 80.0,
        '계란': 60.0,
        '버터': 50.0,
        '우유': 40.0,
        '베이킹파우더': 3.0,
        '소금': 0.5,
      },
      '쿠키': {
        '박력분': 100.0,
        '설탕': 60.0,
        '버터': 70.0,
        '계란': 20.0,
        '소금': 0.8,
        '베이킹파우더': 1.5,
      },
    };

    return baseRatiosDatabase[bakingType] ?? baseRatiosDatabase['식빵']!;
  }

  /// 목표 특성 기반 정밀 조정
  static Map<String, double> _precisionAdjustment(
    RecipeTarget target, 
    Map<String, double> baseRatios
  ) {
    final adjustedRatios = Map<String, double>.from(baseRatios);
    
    // 수분율 조정 (촉촉함 + 쫄깃함 기반)
    final targetHydration = (target.moistureTarget * 0.6) + (target.chewinessTarget * 0.4);
    final currentHydration = _calculateCurrentHydration(baseRatios);
    final hydrationAdjustment = (targetHydration - currentHydration) * 0.3;
    
    // 액체 재료 조정
    if (adjustedRatios.containsKey('물')) {
      adjustedRatios['물'] = adjustedRatios['물']! * (1.0 + hydrationAdjustment);
    }
    if (adjustedRatios.containsKey('우유')) {
      adjustedRatios['우유'] = adjustedRatios['우유']! * (1.0 + hydrationAdjustment * 0.5);
    }
    
    // 지방 함량 조정 (부드러움 + 고소함 기반)
    final targetFat = (target.softnessTarget * 0.5) + (target.richnessTarget * 0.5);
    final fatAdjustment = (targetFat - 0.5) * 0.4;
    
    if (adjustedRatios.containsKey('버터')) {
      adjustedRatios['버터'] = adjustedRatios['버터']! * (1.0 + fatAdjustment);
    }
    if (adjustedRatios.containsKey('올리브오일')) {
      adjustedRatios['올리브오일'] = adjustedRatios['올리브오일']! * (1.0 + fatAdjustment);
    }
    
    // 당분 조정 (단맛 기반)
    final sugarAdjustment = (target.sweetnessTarget - 0.3) * 0.5;
    if (adjustedRatios.containsKey('설탕')) {
      adjustedRatios['설탕'] = adjustedRatios['설탕']! * (1.0 + sugarAdjustment);
    }
    
    // 소금 조정 (짠맛 기반)
    final saltAdjustment = (target.saltinessTarget - 0.2) * 0.3;
    if (adjustedRatios.containsKey('소금')) {
      adjustedRatios['소금'] = adjustedRatios['소금']! * (1.0 + saltAdjustment);
    }
    
    // 이스트 조정 (높이 + 기공 기반)
    final yeastAdjustment = ((target.heightTarget + target.porosityTarget) / 2.0 - 0.7) * 0.2;
    if (adjustedRatios.containsKey('드라이이스트')) {
      adjustedRatios['드라이이스트'] = adjustedRatios['드라이이스트']! * (1.0 + yeastAdjustment);
    }
    
    // 바삭함을 위한 특별 조정
    if (target.crispinessTarget > 0.7) {
      // 수분 감소, 소금 증가
      if (adjustedRatios.containsKey('물')) {
        adjustedRatios['물'] = adjustedRatios['물']! * 0.9;
      }
      if (adjustedRatios.containsKey('소금')) {
        adjustedRatios['소금'] = adjustedRatios['소금']! * 1.1;
      }
    }
    
    return adjustedRatios;
  }

  /// 환경 요인 반영
  static Map<String, double> _applyEnvironmentalFactors(
    Map<String, double> ratios,
    Map<String, dynamic> environmentalConditions
  ) {
    final adjustedRatios = Map<String, double>.from(ratios);
    
    final temperature = environmentalConditions['temperature'] as double? ?? 26.0;
    final humidity = environmentalConditions['humidity'] as double? ?? 60.0;
    final altitude = environmentalConditions['altitude'] as double? ?? 0.0;
    
    // 온도 보정
    final tempFactor = (temperature - 25.0) / 10.0;
    if (adjustedRatios.containsKey('드라이이스트')) {
      adjustedRatios['드라이이스트'] = adjustedRatios['드라이이스트']! * (1.0 - tempFactor * 0.1);
    }
    
    // 습도 보정
    final humidityFactor = (humidity - 60.0) / 20.0;
    if (adjustedRatios.containsKey('물')) {
      adjustedRatios['물'] = adjustedRatios['물']! * (1.0 - humidityFactor * 0.05);
    }
    
    // 고도 보정
    if (altitude > 500) {
      final altitudeFactor = altitude / 1000.0;
      // 고지대에서는 액체 증가, 이스트 감소
      if (adjustedRatios.containsKey('물')) {
        adjustedRatios['물'] = adjustedRatios['물']! * (1.0 + altitudeFactor * 0.1);
      }
      if (adjustedRatios.containsKey('드라이이스트')) {
        adjustedRatios['드라이이스트'] = adjustedRatios['드라이이스트']! * (1.0 - altitudeFactor * 0.15);
      }
    }
    
    return adjustedRatios;
  }

  /// 재료 상호작용 최적화
  static Map<String, double> _optimizeIngredientInteractions(
    Map<String, double> ratios,
    RecipeTarget target
  ) {
    final optimizedRatios = Map<String, double>.from(ratios);
    
    // 계란과 버터의 상호작용 (부드러움 증진)
    if (target.softnessTarget > 0.8 && 
        optimizedRatios.containsKey('계란') && 
        optimizedRatios.containsKey('버터')) {
      final eggButterSynergy = 1.1;
      optimizedRatios['계란'] = optimizedRatios['계란']! * eggButterSynergy;
      optimizedRatios['버터'] = optimizedRatios['버터']! * eggButterSynergy;
    }
    
    // 우유와 설탕의 상호작용 (Maillard 반응 촉진)
    if (target.crustColorTarget == CrustColorTarget.golden ||
        target.crustColorTarget == CrustColorTarget.darkBrown) {
      if (optimizedRatios.containsKey('우유') && optimizedRatios.containsKey('설탕')) {
        optimizedRatios['우유'] = optimizedRatios['우유']! * 1.05;
        optimizedRatios['설탕'] = optimizedRatios['설탕']! * 1.05;
      }
    }
    
    // 소금과 이스트의 균형 (발효 최적화)
    if (optimizedRatios.containsKey('소금') && optimizedRatios.containsKey('드라이이스트')) {
      final saltYeastRatio = optimizedRatios['소금']! / optimizedRatios['드라이이스트']!;
      if (saltYeastRatio > 2.5) {
        // 소금이 너무 많으면 이스트 활동 억제
        optimizedRatios['드라이이스트'] = optimizedRatios['드라이이스트']! * 1.1;
      } else if (saltYeastRatio < 1.5) {
        // 소금이 너무 적으면 글루텐 강화 부족
        optimizedRatios['소금'] = optimizedRatios['소금']! * 1.1;
      }
    }
    
    return optimizedRatios;
  }

  /// 재료 리스트 생성
  static List<Map<String, dynamic>> _generateIngredientList(
    Map<String, double> ratios,
    RecipeTarget target
  ) {
    final ingredients = <Map<String, dynamic>>[];
    const double baseFlourWeight = 300.0; // 기본 밀가루 300g
    
    for (final entry in ratios.entries) {
      final ingredientName = entry.key;
      final percentage = entry.value;
      final amount = (baseFlourWeight * percentage / 100.0);
      
      // 단위 결정
      String unit = 'g';
      if (ingredientName.contains('물') || 
          ingredientName.contains('우유') || 
          ingredientName.contains('오일')) {
        unit = 'ml';
      }
      
      ingredients.add({
        'name': ingredientName,
        'amount': amount,
        'unit': unit,
        'category': _getIngredientCategory(ingredientName),
        'bakersPercentage': percentage,
        'role': _getIngredientRole(ingredientName),
        'substitutable': _isSubstitutable(ingredientName),
      });
    }
    
    return ingredients;
  }

  /// 다단계 검증 및 보정
  static Future<List<Map<String, dynamic>>> _multiStageValidation(
    List<Map<String, dynamic>> ingredients,
    RecipeTarget target,
    Map<String, dynamic> environmentalConditions
  ) async {
    var validatedIngredients = List<Map<String, dynamic>>.from(ingredients);
    
    // 1단계: 기본 비율 검증
    validatedIngredients = _validateBasicRatios(validatedIngredients);
    
    // 2단계: 베이킹 사이언스 검증
    validatedIngredients = await _validateBakingScience(validatedIngredients, target);
    
    // 3단계: 실용성 검증
    validatedIngredients = _validatePracticality(validatedIngredients);
    
    // 4단계: 최종 미세 조정
    validatedIngredients = _finalFineTuning(validatedIngredients, target);
    
    return validatedIngredients;
  }

  /// 기본 비율 검증
  static List<Map<String, dynamic>> _validateBasicRatios(
    List<Map<String, dynamic>> ingredients
  ) {
    final validated = List<Map<String, dynamic>>.from(ingredients);
    
    // 최소/최대 비율 제한
    final limits = {
      '물': {'min': 40.0, 'max': 90.0},
      '우유': {'min': 0.0, 'max': 50.0},
      '설탕': {'min': 0.0, 'max': 25.0},
      '소금': {'min': 0.8, 'max': 3.0},
      '드라이이스트': {'min': 0.5, 'max': 3.0},
      '버터': {'min': 0.0, 'max': 30.0},
    };
    
    for (final ingredient in validated) {
      final name = ingredient['name'] as String;
      final percentage = ingredient['bakersPercentage'] as double;
      
      if (limits.containsKey(name)) {
        final limit = limits[name]!;
        final min = limit['min']!;
        final max = limit['max']!;
        
        if (percentage < min || percentage > max) {
          final clampedPercentage = percentage.clamp(min, max);
          ingredient['bakersPercentage'] = clampedPercentage;
          ingredient['amount'] = (300.0 * clampedPercentage / 100.0);
        }
      }
    }
    
    return validated;
  }

  /// 베이킹 사이언스 검증
  static Future<List<Map<String, dynamic>>> _validateBakingScience(
    List<Map<String, dynamic>> ingredients,
    RecipeTarget target
  ) async {
    // 글루텐 강도 검증
    final flourWeight = _getIngredientAmount(ingredients, '강력분');
    final hydration = _calculateHydrationFromIngredients(ingredients);
    
    if (flourWeight > 0) {
      final glutenResult = BakingScienceEngine.predictGlutenStrength(
        flourType: '강력분',
        hydration: hydration,
        kneadingTimeMinutes: 10.0,
        saltPercentage: _getIngredientAmount(ingredients, '소금') / flourWeight,
      );
      
      // 글루텐 강도가 목표와 맞지 않으면 조정
      if (target.chewinessTarget > 0.7 && glutenResult.strength < 6.0) {
        _adjustIngredientAmount(ingredients, '소금', 1.1);
      } else if (target.softnessTarget > 0.8 && glutenResult.strength > 8.0) {
        _adjustIngredientAmount(ingredients, '물', 1.05);
      }
    }
    
    return ingredients;
  }

  /// 실용성 검증
  static List<Map<String, dynamic>> _validatePracticality(
    List<Map<String, dynamic>> ingredients
  ) {
    // 재료량이 너무 적거나 측정하기 어려운 경우 조정
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double;
      final unit = ingredient['unit'] as String;
      
      if (unit == 'g' && amount < 1.0) {
        // 1g 미만은 1g으로 조정
        ingredient['amount'] = 1.0;
      } else if (unit == 'ml' && amount < 5.0) {
        // 5ml 미만은 5ml로 조정
        ingredient['amount'] = 5.0;
      }
    }
    
    return ingredients;
  }

  /// 최종 미세 조정
  static List<Map<String, dynamic>> _finalFineTuning(
    List<Map<String, dynamic>> ingredients,
    RecipeTarget target
  ) {
    // 목표 특성에 따른 최종 미세 조정
    if (target.moistureTarget > 0.8) {
      _adjustIngredientAmount(ingredients, '물', 1.02);
    }
    
    if (target.richnessTarget > 0.8) {
      _adjustIngredientAmount(ingredients, '버터', 1.05);
    }
    
    return ingredients;
  }

  /// 최종 결과 생성
  static Future<GeneratedRecipeResult> _generateFinalResult(
    List<Map<String, dynamic>> ingredients,
    RecipeTarget target,
    Map<String, dynamic> environmentalConditions,
    Map<String, double> bakersPercentages
  ) async {
    // 예측 상태 생성
    final analysisResult = RealTimeRecipeAnalyzer.analyzeIngredients(ingredients);
    final predictedStatus = ProductStatusGenerator.generateStatus(
      analysisResult: analysisResult,
      bakingContext: _generateBakingContext(target),
      environmentalConditions: environmentalConditions,
    );
    
    // 목표 달성도 계산
    final achievementScore = target.calculateAchievementScore(predictedStatus);
    
    // 지능적 최적화 노트 생성
    final optimizationNotes = _generateIntelligentNotes(
      target, 
      ingredients, 
      predictedStatus, 
      achievementScore
    );
    
    return GeneratedRecipeResult(
      optimizedIngredients: ingredients,
      originalTarget: target,
      predictedStatus: predictedStatus,
      achievementScore: achievementScore,
      optimizationNotes: optimizationNotes,
      bakersPercentages: bakersPercentages,
      generatedAt: DateTime.now(),
    );
  }

  /// 현재 수분율 계산
  static double _calculateCurrentHydration(Map<String, double> ratios) {
    double liquidTotal = 0.0;
    liquidTotal += ratios['물'] ?? 0.0;
    liquidTotal += ratios['우유'] ?? 0.0;
    liquidTotal += (ratios['계란'] ?? 0.0) * 0.75; // 계란의 75%는 수분
    
    return liquidTotal / 100.0; // 밀가루 100% 기준
  }

  /// 재료에서 수분율 계산
  static double _calculateHydrationFromIngredients(List<Map<String, dynamic>> ingredients) {
    double flourWeight = _getIngredientAmount(ingredients, '강력분');
    if (flourWeight == 0) flourWeight = _getIngredientAmount(ingredients, '박력분');
    
    double liquidWeight = 0.0;
    liquidWeight += _getIngredientAmount(ingredients, '물');
    liquidWeight += _getIngredientAmount(ingredients, '우유');
    liquidWeight += _getIngredientAmount(ingredients, '계란') * 0.75;
    
    return flourWeight > 0 ? liquidWeight / flourWeight : 0.0;
  }

  /// 재료량 가져오기
  static double _getIngredientAmount(List<Map<String, dynamic>> ingredients, String name) {
    for (final ingredient in ingredients) {
      if (ingredient['name'] == name) {
        return ingredient['amount'] as double;
      }
    }
    return 0.0;
  }

  /// 재료량 조정
  static void _adjustIngredientAmount(
    List<Map<String, dynamic>> ingredients, 
    String name, 
    double factor
  ) {
    for (final ingredient in ingredients) {
      if (ingredient['name'] == name) {
        ingredient['amount'] = (ingredient['amount'] as double) * factor;
        break;
      }
    }
  }

  /// 재료 카테고리 결정
  static String _getIngredientCategory(String name) {
    if (name.contains('강력분') || name.contains('박력분')) return 'flour';
    if (name.contains('물') || name.contains('우유')) return 'liquid';
    if (name.contains('이스트') || name.contains('베이킹파우더')) return 'leavening';
    if (name.contains('설탕')) return 'sweetener';
    if (name.contains('소금')) return 'seasoning';
    if (name.contains('버터') || name.contains('오일')) return 'fat';
    if (name.contains('계란')) return 'protein';
    return 'other';
  }

  /// 재료 역할 결정
  static String _getIngredientRole(String name) {
    if (name.contains('강력분')) return '구조 형성';
    if (name.contains('물')) return '수분 공급';
    if (name.contains('이스트')) return '발효';
    if (name.contains('설탕')) return '풍미 및 갈변';
    if (name.contains('소금')) return '글루텐 강화';
    if (name.contains('버터')) return '풍미 및 질감';
    return '보조';
  }

  /// 대체 가능 여부
  static bool _isSubstitutable(String name) {
    final nonSubstitutable = ['강력분', '박력분', '물', '소금'];
    return !nonSubstitutable.contains(name);
  }

  /// 베이킹 컨텍스트 생성
  static Map<String, dynamic> _generateBakingContext(RecipeTarget target) {
    return {
      'suggestedTemperature': _getSuggestedTemperature(target.crustColorTarget),
      'suggestedTimeMinutes': 30,
      'hasFermentation': true,
      'hasKneading': true,
    };
  }

  /// 권장 온도 계산
  static int _getSuggestedTemperature(CrustColorTarget colorTarget) {
    switch (colorTarget) {
      case CrustColorTarget.pale: return 160;
      case CrustColorTarget.lightBrown: return 170;
      case CrustColorTarget.golden: return 180;
      case CrustColorTarget.darkBrown: return 200;
      case CrustColorTarget.veryDark: return 220;
    }
  }

  /// 지능적 최적화 노트 생성
  static List<String> _generateIntelligentNotes(
    RecipeTarget target,
    List<Map<String, dynamic>> ingredients,
    ProductStatus predictedStatus,
    double achievementScore
  ) {
    final notes = <String>[];
    
    // 달성도 기반 평가
    if (achievementScore >= 0.95) {
      notes.add('🎯 목표를 완벽하게 달성한 최적화된 레시피입니다.');
    } else if (achievementScore >= 0.85) {
      notes.add('✅ 목표를 매우 잘 달성한 우수한 레시피입니다.');
    } else if (achievementScore >= 0.75) {
      notes.add('👍 목표를 잘 달성한 양호한 레시피입니다.');
    } else {
      notes.add('⚠️ 목표 달성을 위해 추가 조정을 고려해보세요.');
    }
    
    // 특성별 세부 분석
    if (target.moistureTarget > 0.8) {
      notes.add('💧 고수분 레시피로 촉촉한 식감을 구현했습니다.');
    }
    
    if (target.chewinessTarget > 0.8) {
      notes.add('🤏 글루텐 네트워크 최적화로 쫄깃한 식감을 구현했습니다.');
    }
    
    // 베이킹 사이언스 기반 조언
    final hydration = _calculateHydrationFromIngredients(ingredients);
    if (hydration > 0.75) {
      notes.add('🔬 고수분 반죽이므로 충분한 반죽 시간이 필요합니다.');
    }
    
    // 환경별 팁
    notes.add('🌡️ 실내 온도에 따라 발효 시간을 조절하세요.');
    notes.add('⏰ 첫 번째 시도 후 기호에 맞게 미세 조정하세요.');
    
    return notes;
  }
}

/// 지능적 레시피 생성 예외
class IntelligentRecipeGenerationException implements Exception {
  final String message;
  const IntelligentRecipeGenerationException(this.message);
  
  @override
  String toString() => 'IntelligentRecipeGenerationException: $message';
}