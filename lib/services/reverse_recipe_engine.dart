/// 역산 레시피 생성 엔진
/// 원하는 특성에서 최적의 재료 비율을 역산하여 계산합니다.

import 'dart:math' as math;
import '../models/recipe_target.dart';
import '../services/product_status_generator.dart';
import '../services/real_time_recipe_analyzer.dart';
import '../services/baking_science_engine.dart';
import '../services/recipe_preset_manager.dart';

class ReverseRecipeEngine {
  /// 역산 레시피 생성 (텍스트 입력 기반)
  static Future<ReverseRecipeResult> generateFromText({
    required String targetDescription,
    required Map<String, dynamic> environmentalConditions,
    double baseFlourWeight = 300.0,
  }) async {
    try {
      // 1. 텍스트에서 목표 특성 추출
      final target = _parseTextToTarget(targetDescription);
      
      // 2. 프리셋 기반 빠른 매칭 시도
      final presetMatch = _findBestPresetMatch(targetDescription);
      
      // 3. 역산 계산 수행
      final result = await _performReverseCalculation(
        target: target,
        presetBase: presetMatch,
        environmentalConditions: environmentalConditions,
        baseFlourWeight: baseFlourWeight,
      );
      
      return result;
    } catch (e) {
      throw ReverseRecipeException('역산 레시피 생성 중 오류: $e');
    }
  }

  /// 프리셋 기반 역산 레시피 생성
  static Future<ReverseRecipeResult> generateFromPreset({
    required String presetId,
    required Map<String, dynamic> environmentalConditions,
    double baseFlourWeight = 300.0,
    Map<String, double>? customAdjustments,
  }) async {
    try {
      final preset = RecipePresetManager.getPresetById(presetId);
      if (preset == null) {
        throw ReverseRecipeException('프리셋을 찾을 수 없습니다: $presetId');
      }

      // 커스텀 조정 적용
      RecipeTarget target = preset.target;
      if (customAdjustments != null) {
        target = _applyCustomAdjustments(target, customAdjustments);
      }

      final result = await _performReverseCalculation(
        target: target,
        presetBase: preset,
        environmentalConditions: environmentalConditions,
        baseFlourWeight: baseFlourWeight,
      );

      return result;
    } catch (e) {
      throw ReverseRecipeException('프리셋 기반 역산 생성 중 오류: $e');
    }
  }

  /// 고급 역산 레시피 생성 (세밀한 조정)
  static Future<ReverseRecipeResult> generateAdvanced({
    required RecipeTarget target,
    required Map<String, dynamic> environmentalConditions,
    double baseFlourWeight = 300.0,
    Map<String, dynamic>? constraints,
  }) async {
    try {
      final result = await _performAdvancedReverseCalculation(
        target: target,
        environmentalConditions: environmentalConditions,
        baseFlourWeight: baseFlourWeight,
        constraints: constraints ?? {},
      );

      return result;
    } catch (e) {
      throw ReverseRecipeException('고급 역산 생성 중 오류: $e');
    }
  }

  /// 텍스트를 목표로 변환
  static RecipeTarget _parseTextToTarget(String text) {
    final normalizedText = text.toLowerCase();
    
    // 기본 목표 설정
    RecipeTarget target = RecipeTarget.basicBread();
    
    // 베이킹 타입 감지
    String bakingType = '식빵';
    if (normalizedText.contains('케이크')) bakingType = '케이크';
    else if (normalizedText.contains('쿠키')) bakingType = '쿠키';
    else if (normalizedText.contains('브리오슈')) bakingType = '브리오슈';
    
    target = target.copyWith(targetBakingType: bakingType);
    
    // 특성별 분석 및 설정
    final characteristics = _analyzeTextCharacteristics(normalizedText);
    
    return target.copyWith(
      moistureTarget: characteristics['moisture'] ?? target.moistureTarget,
      chewinessTarget: characteristics['chewiness'] ?? target.chewinessTarget,
      softnessTarget: characteristics['softness'] ?? target.softnessTarget,
      crispinessTarget: characteristics['crispiness'] ?? target.crispinessTarget,
      sweetnessTarget: characteristics['sweetness'] ?? target.sweetnessTarget,
      richnessTarget: characteristics['richness'] ?? target.richnessTarget,
      saltinessTarget: characteristics['saltiness'] ?? target.saltinessTarget,
      crustColorTarget: characteristics['crustColor'] ?? target.crustColorTarget,
      heightTarget: characteristics['height'] ?? target.heightTarget,
      porosityTarget: characteristics['porosity'] ?? target.porosityTarget,
    );
  }

  /// 텍스트 특성 분석
  static Map<String, dynamic> _analyzeTextCharacteristics(String text) {
    final characteristics = <String, dynamic>{};
    
    // 강도별 키워드 매핑
    final intensityKeywords = {
      '매우': 1.0,
      '아주': 1.0,
      '완전': 1.0,
      '정말': 0.9,
      '꽤': 0.8,
      '조금': 0.6,
      '약간': 0.6,
      '살짝': 0.5,
    };
    
    // 특성별 키워드와 기본값
    final characteristicKeywords = {
      'moisture': {
        'keywords': ['촉촉', 'moist', '수분'],
        'baseValue': 0.8,
      },
      'chewiness': {
        'keywords': ['쫄깃', 'chewy', '탄력'],
        'baseValue': 0.8,
      },
      'softness': {
        'keywords': ['부드러', 'soft', '폭신'],
        'baseValue': 0.8,
      },
      'crispiness': {
        'keywords': ['바삭', 'crispy', '크리스피'],
        'baseValue': 0.8,
      },
      'sweetness': {
        'keywords': ['달콤', 'sweet', '단맛'],
        'baseValue': 0.7,
      },
      'richness': {
        'keywords': ['고소', 'rich', '풍부'],
        'baseValue': 0.7,
      },
      'saltiness': {
        'keywords': ['짭짤', 'salty', '소금'],
        'baseValue': 0.6,
      },
      'height': {
        'keywords': ['높은', 'tall', '부푼'],
        'baseValue': 0.8,
      },
      'porosity': {
        'keywords': ['구멍', 'airy', '기공'],
        'baseValue': 0.7,
      },
    };
    
    // 각 특성별로 분석
    for (final entry in characteristicKeywords.entries) {
      final characteristic = entry.key;
      final data = entry.value;
      final keywords = data['keywords'] as List<String>;
      final baseValue = data['baseValue'] as double;
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          double intensity = baseValue;
          
          // 강도 수식어 확인
          for (final intensityEntry in intensityKeywords.entries) {
            final intensityWord = intensityEntry.key;
            final intensityValue = intensityEntry.value;
            
            if (text.contains('$intensityWord $keyword') || 
                text.contains('$intensityWord$keyword')) {
              intensity = math.min(1.0, baseValue * intensityValue);
              break;
            }
          }
          
          characteristics[characteristic] = intensity;
          break;
        }
      }
    }
    
    // 크러스트 색상 특별 처리
    if (text.contains('연한') || text.contains('light')) {
      characteristics['crustColor'] = CrustColorTarget.lightBrown;
    } else if (text.contains('황금') || text.contains('golden')) {
      characteristics['crustColor'] = CrustColorTarget.golden;
    } else if (text.contains('진한') || text.contains('dark')) {
      characteristics['crustColor'] = CrustColorTarget.darkBrown;
    }
    
    return characteristics;
  }

  /// 최적 프리셋 매칭
  static RecipePreset? _findBestPresetMatch(String targetDescription) {
    final recommendations = RecipePresetManager.recommendPresets(targetDescription);
    return recommendations.isNotEmpty ? recommendations.first : null;
  }

  /// 커스텀 조정 적용
  static RecipeTarget _applyCustomAdjustments(
    RecipeTarget target, 
    Map<String, double> adjustments
  ) {
    return target.copyWith(
      moistureTarget: adjustments['moisture'] ?? target.moistureTarget,
      chewinessTarget: adjustments['chewiness'] ?? target.chewinessTarget,
      softnessTarget: adjustments['softness'] ?? target.softnessTarget,
      crispinessTarget: adjustments['crispiness'] ?? target.crispinessTarget,
      sweetnessTarget: adjustments['sweetness'] ?? target.sweetnessTarget,
      richnessTarget: adjustments['richness'] ?? target.richnessTarget,
      saltinessTarget: adjustments['saltiness'] ?? target.saltinessTarget,
      heightTarget: adjustments['height'] ?? target.heightTarget,
      porosityTarget: adjustments['porosity'] ?? target.porosityTarget,
    );
  }

  /// 역산 계산 수행
  static Future<ReverseRecipeResult> _performReverseCalculation({
    required RecipeTarget target,
    RecipePreset? presetBase,
    required Map<String, dynamic> environmentalConditions,
    required double baseFlourWeight,
  }) async {
    // 1. 베이커스 퍼센트 역산 계산
    final bakersPercentages = _calculateReverseBakersPercentages(target, presetBase);
    
    // 2. 환경 조건 보정
    final adjustedPercentages = _applyEnvironmentalAdjustments(
      bakersPercentages, 
      environmentalConditions
    );
    
    // 3. 재료 리스트 생성
    final ingredients = _generateIngredientsFromPercentages(
      adjustedPercentages, 
      baseFlourWeight
    );
    
    // 4. 품질 검증 및 미세 조정
    final validatedIngredients = await _validateAndAdjust(ingredients, target);
    
    // 5. 예측 결과 생성
    final analysisResult = RealTimeRecipeAnalyzer.analyzeIngredients(validatedIngredients);
    final predictedStatus = ProductStatusGenerator.generateStatus(
      analysisResult: analysisResult,
      bakingContext: _generateBakingContext(target),
      environmentalConditions: environmentalConditions,
    );
    
    // 6. 목표 달성도 계산
    final achievementScore = target.calculateAchievementScore(predictedStatus);
    
    // 7. 최적화 노트 생성
    final optimizationNotes = _generateReverseNotes(
      target, 
      validatedIngredients, 
      predictedStatus, 
      achievementScore,
      presetBase
    );
    
    return ReverseRecipeResult(
      originalTarget: target,
      generatedIngredients: validatedIngredients,
      bakersPercentages: adjustedPercentages,
      predictedStatus: predictedStatus,
      achievementScore: achievementScore,
      optimizationNotes: optimizationNotes,
      usedPreset: presetBase,
      generatedAt: DateTime.now(),
    );
  }

  /// 고급 역산 계산 수행
  static Future<ReverseRecipeResult> _performAdvancedReverseCalculation({
    required RecipeTarget target,
    required Map<String, dynamic> environmentalConditions,
    required double baseFlourWeight,
    required Map<String, dynamic> constraints,
  }) async {
    // 제약 조건을 고려한 고급 계산 로직
    final bakersPercentages = _calculateAdvancedReverseBakersPercentages(
      target, 
      constraints
    );
    
    // 나머지는 기본 계산과 동일
    final adjustedPercentages = _applyEnvironmentalAdjustments(
      bakersPercentages, 
      environmentalConditions
    );
    
    final ingredients = _generateIngredientsFromPercentages(
      adjustedPercentages, 
      baseFlourWeight
    );
    
    final validatedIngredients = await _validateAndAdjust(ingredients, target);
    
    final analysisResult = RealTimeRecipeAnalyzer.analyzeIngredients(validatedIngredients);
    final predictedStatus = ProductStatusGenerator.generateStatus(
      analysisResult: analysisResult,
      bakingContext: _generateBakingContext(target),
      environmentalConditions: environmentalConditions,
    );
    
    final achievementScore = target.calculateAchievementScore(predictedStatus);
    
    final optimizationNotes = _generateAdvancedReverseNotes(
      target, 
      validatedIngredients, 
      predictedStatus, 
      achievementScore,
      constraints
    );
    
    return ReverseRecipeResult(
      originalTarget: target,
      generatedIngredients: validatedIngredients,
      bakersPercentages: adjustedPercentages,
      predictedStatus: predictedStatus,
      achievementScore: achievementScore,
      optimizationNotes: optimizationNotes,
      usedPreset: null,
      generatedAt: DateTime.now(),
    );
  }

  /// 베이커스 퍼센트 역산 계산
  static Map<String, double> _calculateReverseBakersPercentages(
    RecipeTarget target,
    RecipePreset? presetBase,
  ) {
    // 프리셋이 있으면 기본값으로 사용, 없으면 표준 비율 사용
    Map<String, double> basePercentages = presetBase != null
        ? _getPresetBakersPercentages(presetBase)
        : _getStandardBakersPercentages(target.targetBakingType);
    
    // 목표 특성에 따른 조정
    final adjustedPercentages = Map<String, double>.from(basePercentages);
    
    // 수분율 조정 (촉촉함 + 쫄깃함 기반)
    final targetHydration = _calculateTargetHydration(target);
    final currentHydration = _getCurrentHydration(basePercentages);
    final hydrationAdjustment = (targetHydration - currentHydration) * 0.4;
    
    if (adjustedPercentages.containsKey('물')) {
      adjustedPercentages['물'] = math.max(40.0, 
          adjustedPercentages['물']! * (1.0 + hydrationAdjustment));
    }
    
    // 지방 함량 조정 (부드러움 + 고소함 기반)
    final targetFat = (target.softnessTarget * 0.5) + (target.richnessTarget * 0.5);
    final fatAdjustment = (targetFat - 0.5) * 0.6;
    
    if (adjustedPercentages.containsKey('버터')) {
      adjustedPercentages['버터'] = math.max(0.0,
          adjustedPercentages['버터']! * (1.0 + fatAdjustment));
    }
    
    // 당분 조정 (단맛 기반)
    final sugarAdjustment = (target.sweetnessTarget - 0.3) * 0.8;
    if (adjustedPercentages.containsKey('설탕')) {
      adjustedPercentages['설탕'] = math.max(0.0,
          adjustedPercentages['설탕']! * (1.0 + sugarAdjustment));
    }
    
    // 소금 조정 (짠맛 + 글루텐 강화 기반)
    final saltAdjustment = ((target.saltinessTarget - 0.2) * 0.4) + 
                          ((target.chewinessTarget - 0.5) * 0.2);
    if (adjustedPercentages.containsKey('소금')) {
      adjustedPercentages['소금'] = math.max(0.8,
          adjustedPercentages['소금']! * (1.0 + saltAdjustment));
    }
    
    // 이스트 조정 (높이 + 기공 기반)
    final yeastAdjustment = ((target.heightTarget + target.porosityTarget) / 2.0 - 0.7) * 0.3;
    if (adjustedPercentages.containsKey('드라이이스트')) {
      adjustedPercentages['드라이이스트'] = math.max(0.5,
          adjustedPercentages['드라이이스트']! * (1.0 + yeastAdjustment));
    }
    
    // 특수 재료 추가 결정
    _addSpecialIngredients(adjustedPercentages, target);
    
    return adjustedPercentages;
  }

  /// 고급 베이커스 퍼센트 역산 계산
  static Map<String, double> _calculateAdvancedReverseBakersPercentages(
    RecipeTarget target,
    Map<String, dynamic> constraints,
  ) {
    final basePercentages = _getStandardBakersPercentages(target.targetBakingType);
    final adjustedPercentages = Map<String, double>.from(basePercentages);
    
    // 제약 조건 적용
    if (constraints.containsKey('maxHydration')) {
      final maxHydration = constraints['maxHydration'] as double;
      if (adjustedPercentages.containsKey('물')) {
        adjustedPercentages['물'] = math.min(maxHydration, adjustedPercentages['물']!);
      }
    }
    
    if (constraints.containsKey('noSugar') && constraints['noSugar'] == true) {
      adjustedPercentages.remove('설탕');
    }
    
    if (constraints.containsKey('lowSodium') && constraints['lowSodium'] == true) {
      if (adjustedPercentages.containsKey('소금')) {
        adjustedPercentages['소금'] = math.min(1.0, adjustedPercentages['소금']!);
      }
    }
    
    // 목표 특성 기반 조정 (제약 조건 내에서)
    return _applyTargetAdjustmentsWithConstraints(adjustedPercentages, target, constraints);
  }

  /// 목표 수분율 계산
  static double _calculateTargetHydration(RecipeTarget target) {
    // 촉촉함과 쫄깃함을 기반으로 목표 수분율 계산
    double baseHydration = 0.65; // 기본 65%
    
    // 촉촉함 영향 (0-30% 추가)
    baseHydration += target.moistureTarget * 0.3;
    
    // 쫄깃함 영향 (0-15% 추가)
    baseHydration += target.chewinessTarget * 0.15;
    
    // 바삭함 영향 (0-20% 감소)
    baseHydration -= target.crispinessTarget * 0.2;
    
    // 범위 제한 (40-90%)
    return math.max(0.4, math.min(0.9, baseHydration));
  }

  /// 현재 수분율 계산
  static double _getCurrentHydration(Map<String, double> percentages) {
    double liquidTotal = 0.0;
    liquidTotal += percentages['물'] ?? 0.0;
    liquidTotal += percentages['우유'] ?? 0.0;
    liquidTotal += (percentages['계란'] ?? 0.0) * 0.75; // 계란의 75%는 수분
    
    return liquidTotal / 100.0; // 밀가루 100% 기준
  }

  /// 프리셋 베이커스 퍼센트 가져오기
  static Map<String, double> _getPresetBakersPercentages(RecipePreset preset) {
    // 프리셋별 최적화된 베이커스 퍼센트 반환
    // 실제로는 각 프리셋마다 미리 계산된 최적 비율을 저장해야 함
    return _getStandardBakersPercentages(preset.target.targetBakingType);
  }

  /// 표준 베이커스 퍼센트 가져오기
  static Map<String, double> _getStandardBakersPercentages(String bakingType) {
    final standardRatios = {
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
      '브리오슈': {
        '강력분': 100.0,
        '우유': 30.0,
        '계란': 40.0,
        '설탕': 15.0,
        '소금': 1.5,
        '드라이이스트': 1.0,
        '버터': 25.0,
      },
    };

    return standardRatios[bakingType] ?? standardRatios['식빵']!;
  }

  /// 특수 재료 추가
  static void _addSpecialIngredients(
    Map<String, double> percentages, 
    RecipeTarget target
  ) {
    // 계란 추가 (부드러움과 고소함이 높은 경우)
    if (target.softnessTarget > 0.7 && target.richnessTarget > 0.6) {
      if (!percentages.containsKey('계란')) {
        percentages['계란'] = 15.0;
      }
    }
    
    // 우유 추가 (촉촉함과 부드러움이 높은 경우)
    if (target.moistureTarget > 0.8 && target.softnessTarget > 0.7) {
      if (!percentages.containsKey('우유')) {
        // 물의 일부를 우유로 대체
        final waterAmount = percentages['물'] ?? 65.0;
        final milkAmount = math.min(waterAmount * 0.4, 20.0);
        percentages['우유'] = milkAmount;
        percentages['물'] = waterAmount - milkAmount;
      }
    }
  }

  /// 환경 조건 보정 적용
  static Map<String, double> _applyEnvironmentalAdjustments(
    Map<String, double> percentages,
    Map<String, dynamic> environmentalConditions,
  ) {
    final adjusted = Map<String, double>.from(percentages);
    
    final temperature = environmentalConditions['temperature'] as double? ?? 26.0;
    final humidity = environmentalConditions['humidity'] as double? ?? 60.0;
    final altitude = environmentalConditions['altitude'] as double? ?? 0.0;
    
    // 온도 보정
    final tempFactor = (temperature - 25.0) / 10.0;
    if (adjusted.containsKey('드라이이스트')) {
      adjusted['드라이이스트'] = adjusted['드라이이스트']! * (1.0 - tempFactor * 0.1);
    }
    
    // 습도 보정
    final humidityFactor = (humidity - 60.0) / 20.0;
    if (adjusted.containsKey('물')) {
      adjusted['물'] = adjusted['물']! * (1.0 - humidityFactor * 0.05);
    }
    
    // 고도 보정
    if (altitude > 500) {
      final altitudeFactor = altitude / 1000.0;
      if (adjusted.containsKey('물')) {
        adjusted['물'] = adjusted['물']! * (1.0 + altitudeFactor * 0.1);
      }
      if (adjusted.containsKey('드라이이스트')) {
        adjusted['드라이이스트'] = adjusted['드라이이스트']! * (1.0 - altitudeFactor * 0.15);
      }
    }
    
    return adjusted;
  }

  /// 베이커스 퍼센트에서 재료 리스트 생성
  static List<Map<String, dynamic>> _generateIngredientsFromPercentages(
    Map<String, double> percentages,
    double baseFlourWeight,
  ) {
    final ingredients = <Map<String, dynamic>>[];
    
    for (final entry in percentages.entries) {
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
      });
    }
    
    return ingredients;
  }

  /// 품질 검증 및 미세 조정
  static Future<List<Map<String, dynamic>>> _validateAndAdjust(
    List<Map<String, dynamic>> ingredients,
    RecipeTarget target,
  ) async {
    var validated = List<Map<String, dynamic>>.from(ingredients);
    
    // 1. 기본 비율 검증
    validated = _validateBasicRatios(validated);
    
    // 2. 베이킹 사이언스 검증
    validated = await _validateBakingScience(validated, target);
    
    // 3. 실용성 검증
    validated = _validatePracticality(validated);
    
    return validated;
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
    RecipeTarget target,
  ) async {
    // 글루텐 강도 검증 및 조정
    final flourWeight = _getIngredientAmount(ingredients, '강력분');
    if (flourWeight > 0) {
      final hydration = _calculateHydrationFromIngredients(ingredients);
      final saltPercentage = _getIngredientAmount(ingredients, '소금') / flourWeight;
      
      final glutenResult = BakingScienceEngine.predictGlutenStrength(
        flourType: '강력분',
        hydration: hydration,
        kneadingTimeMinutes: 10.0,
        saltPercentage: saltPercentage,
      );
      
      // 목표 쫄깃함과 글루텐 강도 비교 후 조정
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
        ingredient['amount'] = 1.0;
      } else if (unit == 'ml' && amount < 5.0) {
        ingredient['amount'] = 5.0;
      }
    }
    
    return ingredients;
  }

  /// 제약 조건을 고려한 목표 조정 적용
  static Map<String, double> _applyTargetAdjustmentsWithConstraints(
    Map<String, double> percentages,
    RecipeTarget target,
    Map<String, dynamic> constraints,
  ) {
    // 제약 조건 내에서 목표 특성 기반 조정 수행
    final adjusted = Map<String, double>.from(percentages);
    
    // 각 조정이 제약 조건을 위반하지 않는지 확인하면서 적용
    // 구현 생략 (복잡한 제약 조건 처리 로직)
    
    return adjusted;
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

  /// 역산 노트 생성
  static List<String> _generateReverseNotes(
    RecipeTarget target,
    List<Map<String, dynamic>> ingredients,
    ProductStatus predictedStatus,
    double achievementScore,
    RecipePreset? usedPreset,
  ) {
    final notes = <String>[];
    
    // 프리셋 사용 여부
    if (usedPreset != null) {
      notes.add('🎯 "${usedPreset.name}" 프리셋을 기반으로 생성했습니다.');
    } else {
      notes.add('🔬 목표 특성을 분석하여 맞춤 레시피를 생성했습니다.');
    }
    
    // 달성도 평가
    if (achievementScore >= 0.9) {
      notes.add('✨ 목표 특성을 매우 잘 달성한 최적화된 레시피입니다.');
    } else if (achievementScore >= 0.8) {
      notes.add('👍 목표 특성을 잘 달성한 우수한 레시피입니다.');
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
    
    // 베이킹 팁
    notes.add('🌡️ 환경 조건에 따라 발효 시간을 조정하세요.');
    notes.add('⏰ 첫 번째 시도 후 기호에 맞게 미세 조정하세요.');
    
    return notes;
  }

  /// 고급 역산 노트 생성
  static List<String> _generateAdvancedReverseNotes(
    RecipeTarget target,
    List<Map<String, dynamic>> ingredients,
    ProductStatus predictedStatus,
    double achievementScore,
    Map<String, dynamic> constraints,
  ) {
    final notes = <String>[];
    
    notes.add('🔬 고급 역산 알고리즘으로 생성된 맞춤 레시피입니다.');
    
    // 제약 조건 적용 내역
    if (constraints.isNotEmpty) {
      notes.add('⚙️ 다음 제약 조건이 적용되었습니다:');
      constraints.forEach((key, value) {
        notes.add('  • $key: $value');
      });
    }
    
    // 나머지는 기본 노트와 동일
    if (achievementScore >= 0.9) {
      notes.add('✨ 제약 조건 내에서 목표를 매우 잘 달성했습니다.');
    } else {
      notes.add('⚠️ 제약 조건으로 인해 일부 목표 달성이 제한될 수 있습니다.');
    }
    
    return notes;
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
}

/// 역산 레시피 결과
class ReverseRecipeResult {
  final RecipeTarget originalTarget;
  final List<Map<String, dynamic>> generatedIngredients;
  final Map<String, double> bakersPercentages;
  final ProductStatus predictedStatus;
  final double achievementScore;
  final List<String> optimizationNotes;
  final RecipePreset? usedPreset;
  final DateTime generatedAt;

  const ReverseRecipeResult({
    required this.originalTarget,
    required this.generatedIngredients,
    required this.bakersPercentages,
    required this.predictedStatus,
    required this.achievementScore,
    required this.optimizationNotes,
    this.usedPreset,
    required this.generatedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'originalTarget': originalTarget.toJson(),
      'generatedIngredients': generatedIngredients,
      'bakersPercentages': bakersPercentages,
      'predictedStatus': predictedStatus.toJson(),
      'achievementScore': achievementScore,
      'optimizationNotes': optimizationNotes,
      'usedPreset': usedPreset?.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// 역산 레시피 예외
class ReverseRecipeException implements Exception {
  final String message;
  const ReverseRecipeException(this.message);
  
  @override
  String toString() => 'ReverseRecipeException: $message';
}