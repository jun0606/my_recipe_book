/// 목표 기반 레시피 최적화 엔진
/// 사용자가 원하는 특성을 바탕으로 최적의 레시피를 생성합니다.

import 'dart:math' as math;
import '../models/recipe_target.dart';
import '../services/product_status_generator.dart';
import '../services/real_time_recipe_analyzer.dart';
import '../services/baking_science_engine.dart';

class TargetBasedRecipeOptimizer {
  /// 목표 기반 레시피 생성
  static Future<GeneratedRecipeResult> generateRecipe({
    required RecipeTarget target,
    required Map<String, dynamic> baseRecipe,
    required Map<String, dynamic> environmentalConditions,
  }) async {
    try {
      // 1. 목표 특성을 베이커스 퍼센트로 변환
      final bakersPercentages = _convertTargetToBakersPercentage(target);
      
      // 2. 기본 재료 구조 생성
      final baseIngredients = _generateBaseIngredients(target, bakersPercentages);
      
      // 3. 반복적 최적화 수행
      final optimizedIngredients = await _iterativeOptimization(
        target,
        baseIngredients,
        environmentalConditions,
      );
      
      // 4. 최종 결과 예측
      final predictedStatus = ProductStatusGenerator.generateStatus(
        analysisResult: RealTimeRecipeAnalyzer.analyzeIngredients(optimizedIngredients),
        bakingContext: _generateBakingContext(target),
        environmentalConditions: environmentalConditions,
      );
      
      // 5. 목표 달성도 계산
      final achievementScore = target.calculateAchievementScore(predictedStatus);
      
      // 6. 최적화 노트 생성
      final optimizationNotes = _generateOptimizationNotes(
        target,
        optimizedIngredients,
        predictedStatus,
        achievementScore,
      );
      
      return GeneratedRecipeResult(
        optimizedIngredients: optimizedIngredients,
        originalTarget: target,
        predictedStatus: predictedStatus,
        achievementScore: achievementScore,
        optimizationNotes: optimizationNotes,
        bakersPercentages: bakersPercentages,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw RecipeOptimizationException('레시피 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 레시피 개선
  static Future<GeneratedRecipeResult> improveExistingRecipe({
    required RecipeTarget target,
    required List<Map<String, dynamic>> currentIngredients,
    required Map<String, dynamic> environmentalConditions,
  }) async {
    try {
      // 현재 레시피 분석
      final currentAnalysis = RealTimeRecipeAnalyzer.analyzeIngredients(currentIngredients);
      final currentStatus = ProductStatusGenerator.generateStatus(
        analysisResult: currentAnalysis,
        bakingContext: {},
        environmentalConditions: environmentalConditions,
      );
      
      // 개선이 필요한 부분 식별
      final improvementAreas = _identifyImprovementAreas(target, currentStatus);
      
      // 점진적 개선 수행
      final improvedIngredients = await _gradualImprovement(
        target,
        currentIngredients,
        improvementAreas,
        environmentalConditions,
      );
      
      // 결과 생성
      final predictedStatus = ProductStatusGenerator.generateStatus(
        analysisResult: RealTimeRecipeAnalyzer.analyzeIngredients(improvedIngredients),
        bakingContext: _generateBakingContext(target),
        environmentalConditions: environmentalConditions,
      );
      
      final achievementScore = target.calculateAchievementScore(predictedStatus);
      final bakersPercentages = _calculateBakersPercentages(improvedIngredients);
      
      final optimizationNotes = _generateImprovementNotes(
        target,
        currentIngredients,
        improvedIngredients,
        improvementAreas,
      );
      
      return GeneratedRecipeResult(
        optimizedIngredients: improvedIngredients,
        originalTarget: target,
        predictedStatus: predictedStatus,
        achievementScore: achievementScore,
        optimizationNotes: optimizationNotes,
        bakersPercentages: bakersPercentages,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw RecipeOptimizationException('레시피 개선 중 오류가 발생했습니다: $e');
    }
  }

  /// 목표 특성을 베이커스 퍼센트로 변환
  static Map<String, double> _convertTargetToBakersPercentage(RecipeTarget target) {
    // 기본 베이커스 퍼센트 (강력분 100% 기준)
    Map<String, double> percentages = {
      '강력분': 100.0,
    };

    // 수분율 계산 (목표 촉촉함과 쫄깃함 기반)
    double hydrationPercentage = 50.0; // 기본 50%
    hydrationPercentage += target.moistureTarget * 30.0; // 촉촉함에 따라 0-30% 추가
    hydrationPercentage += target.chewinessTarget * 15.0; // 쫄깃함에 따라 0-15% 추가
    hydrationPercentage -= target.crispinessTarget * 20.0; // 바삭함에 따라 0-20% 감소
    hydrationPercentage = math.max(40.0, math.min(85.0, hydrationPercentage)); // 40-85% 제한
    
    percentages['물'] = hydrationPercentage;

    // 지방 함량 계산 (목표 부드러움과 고소함 기반)
    double fatPercentage = 2.0; // 기본 2%
    fatPercentage += target.softnessTarget * 8.0; // 부드러움에 따라 0-8% 추가
    fatPercentage += target.richnessTarget * 10.0; // 고소함에 따라 0-10% 추가
    fatPercentage = math.max(0.0, math.min(20.0, fatPercentage)); // 0-20% 제한
    
    if (fatPercentage > 0) {
      percentages['버터'] = fatPercentage;
    }

    // 당분 함량 계산 (목표 단맛 기반)
    double sugarPercentage = 1.0; // 기본 1%
    sugarPercentage += target.sweetnessTarget * 15.0; // 단맛에 따라 0-15% 추가
    sugarPercentage = math.max(0.0, math.min(20.0, sugarPercentage)); // 0-20% 제한
    
    if (sugarPercentage > 0) {
      percentages['설탕'] = sugarPercentage;
    }

    // 소금 함량 계산 (목표 짠맛 기반)
    double saltPercentage = 1.5; // 기본 1.5%
    saltPercentage += target.saltinessTarget * 1.0; // 짠맛에 따라 0-1% 추가
    saltPercentage = math.max(0.8, math.min(3.0, saltPercentage)); // 0.8-3% 제한
    
    percentages['소금'] = saltPercentage;

    // 이스트 함량 계산 (목표 높이와 기공 기반)
    double yeastPercentage = 1.0; // 기본 1%
    yeastPercentage += target.heightTarget * 1.5; // 높이에 따라 0-1.5% 추가
    yeastPercentage += target.porosityTarget * 1.0; // 기공에 따라 0-1% 추가
    yeastPercentage = math.max(0.5, math.min(3.0, yeastPercentage)); // 0.5-3% 제한
    
    percentages['드라이이스트'] = yeastPercentage;

    // 계란 추가 (부드러움과 고소함이 높은 경우)
    if (target.softnessTarget > 0.7 && target.richnessTarget > 0.6) {
      percentages['계란'] = 15.0; // 15%
    }

    // 우유 추가 (촉촉함과 부드러움이 높은 경우)
    if (target.moistureTarget > 0.8 && target.softnessTarget > 0.7) {
      // 물의 일부를 우유로 대체
      final milkPercentage = math.min(percentages['물']! * 0.4, 20.0);
      percentages['우유'] = milkPercentage;
      percentages['물'] = percentages['물']! - milkPercentage;
    }

    return percentages;
  }

  /// 기본 재료 구조 생성
  static List<Map<String, dynamic>> _generateBaseIngredients(
    RecipeTarget target,
    Map<String, double> bakersPercentages,
  ) {
    final ingredients = <Map<String, dynamic>>[];
    const double baseFlourWeight = 300.0; // 기본 밀가루 300g

    for (final entry in bakersPercentages.entries) {
      final ingredientName = entry.key;
      final percentage = entry.value;
      final amount = (baseFlourWeight * percentage / 100.0);

      // 단위 결정
      String unit = 'g';
      if (ingredientName.contains('물') || ingredientName.contains('우유')) {
        unit = 'ml';
      }

      ingredients.add({
        'name': ingredientName,
        'amount': amount,
        'unit': unit,
        'category': _getIngredientCategory(ingredientName),
        'bakersPercentage': percentage,
      });
    }

    return ingredients;
  }

  /// 반복적 최적화 수행
  static Future<List<Map<String, dynamic>>> _iterativeOptimization(
    RecipeTarget target,
    List<Map<String, dynamic>> baseIngredients,
    Map<String, dynamic> environmentalConditions,
  ) async {
    List<Map<String, dynamic>> currentIngredients = List.from(baseIngredients);
    double bestScore = 0.0;
    List<Map<String, dynamic>> bestIngredients = List.from(currentIngredients);

    // 최대 5회 반복 최적화
    for (int iteration = 0; iteration < 5; iteration++) {
      // 현재 상태 분석
      final analysisResult = RealTimeRecipeAnalyzer.analyzeIngredients(currentIngredients);
      final currentStatus = ProductStatusGenerator.generateStatus(
        analysisResult: analysisResult,
        bakingContext: _generateBakingContext(target),
        environmentalConditions: environmentalConditions,
      );

      // 목표 달성도 계산
      final currentScore = target.calculateAchievementScore(currentStatus);

      // 최고 점수 업데이트
      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestIngredients = List.from(currentIngredients);
      }

      // 목표 달성도가 충분히 높으면 종료
      if (currentScore >= 0.9) {
        break;
      }

      // 개선 방향 결정 및 조정
      currentIngredients = _adjustIngredients(target, currentIngredients, currentStatus);
    }

    return bestIngredients;
  }

  /// 재료 조정
  static List<Map<String, dynamic>> _adjustIngredients(
    RecipeTarget target,
    List<Map<String, dynamic>> ingredients,
    ProductStatus currentStatus,
  ) {
    final adjustedIngredients = <Map<String, dynamic>>[];

    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      double amount = ingredient['amount'] as double;
      final adjustmentFactor = _calculateAdjustmentFactor(target, currentStatus, name);
      
      // 조정 적용 (최대 ±20%)
      amount *= (1.0 + adjustmentFactor * 0.2);
      
      adjustedIngredients.add({
        ...ingredient,
        'amount': amount,
      });
    }

    return adjustedIngredients;
  }

  /// 조정 계수 계산
  static double _calculateAdjustmentFactor(
    RecipeTarget target,
    ProductStatus currentStatus,
    String ingredientName,
  ) {
    double adjustmentFactor = 0.0;

    if (ingredientName.contains('물') || ingredientName.contains('우유')) {
      // 수분 관련 재료
      final moistureDiff = target.moistureTarget - currentStatus.textureProfile.moistureLevel;
      adjustmentFactor += moistureDiff * 0.5;
    } else if (ingredientName.contains('버터') || ingredientName.contains('기름')) {
      // 지방 관련 재료
      final richnessDiff = target.richnessTarget - currentStatus.flavorProfile.richnessLevel;
      final softnessDiff = target.softnessTarget - currentStatus.textureProfile.softness;
      adjustmentFactor += (richnessDiff + softnessDiff) * 0.3;
    } else if (ingredientName.contains('설탕')) {
      // 당분 관련 재료
      final sweetnessDiff = target.sweetnessTarget - currentStatus.flavorProfile.sweetnessLevel;
      adjustmentFactor += sweetnessDiff * 0.4;
    } else if (ingredientName.contains('소금')) {
      // 소금 관련 재료
      final saltinessDiff = target.saltinessTarget - currentStatus.flavorProfile.saltinessLevel;
      adjustmentFactor += saltinessDiff * 0.3;
    } else if (ingredientName.contains('이스트')) {
      // 이스트 관련 재료
      final heightDiff = target.heightTarget - currentStatus.appearanceProfile.expectedHeight;
      adjustmentFactor += heightDiff * 0.2;
    }

    // 조정 범위 제한 (-0.5 ~ 0.5)
    return math.max(-0.5, math.min(0.5, adjustmentFactor));
  }

  /// 점진적 개선 수행
  static Future<List<Map<String, dynamic>>> _gradualImprovement(
    RecipeTarget target,
    List<Map<String, dynamic>> currentIngredients,
    Map<String, double> improvementAreas,
    Map<String, dynamic> environmentalConditions,
  ) async {
    List<Map<String, dynamic>> improvedIngredients = List.from(currentIngredients);

    // 개선 영역별로 점진적 조정
    for (final area in improvementAreas.entries) {
      final areaName = area.key;
      final improvementNeeded = area.value;

      if (improvementNeeded.abs() < 0.1) continue; // 작은 차이는 무시

      // 영역별 개선 로직
      switch (areaName) {
        case 'moisture':
          improvedIngredients = _adjustMoisture(improvedIngredients, improvementNeeded);
          break;
        case 'richness':
          improvedIngredients = _adjustRichness(improvedIngredients, improvementNeeded);
          break;
        case 'sweetness':
          improvedIngredients = _adjustSweetness(improvedIngredients, improvementNeeded);
          break;
        case 'saltiness':
          improvedIngredients = _adjustSaltiness(improvedIngredients, improvementNeeded);
          break;
      }
    }

    return improvedIngredients;
  }

  /// 개선이 필요한 영역 식별
  static Map<String, double> _identifyImprovementAreas(
    RecipeTarget target,
    ProductStatus currentStatus,
  ) {
    return {
      'moisture': target.moistureTarget - currentStatus.textureProfile.moistureLevel,
      'chewiness': target.chewinessTarget - currentStatus.textureProfile.chewiness,
      'softness': target.softnessTarget - currentStatus.textureProfile.softness,
      'sweetness': target.sweetnessTarget - currentStatus.flavorProfile.sweetnessLevel,
      'richness': target.richnessTarget - currentStatus.flavorProfile.richnessLevel,
      'saltiness': target.saltinessTarget - currentStatus.flavorProfile.saltinessLevel,
    };
  }

  /// 수분 조정
  static List<Map<String, dynamic>> _adjustMoisture(
    List<Map<String, dynamic>> ingredients,
    double adjustment,
  ) {
    return ingredients.map((ingredient) {
      if (ingredient['name'].toString().contains('물') || 
          ingredient['name'].toString().contains('우유')) {
        final currentAmount = ingredient['amount'] as double;
        final newAmount = currentAmount * (1.0 + adjustment * 0.15);
        return {...ingredient, 'amount': newAmount};
      }
      return ingredient;
    }).toList();
  }

  /// 고소함 조정
  static List<Map<String, dynamic>> _adjustRichness(
    List<Map<String, dynamic>> ingredients,
    double adjustment,
  ) {
    return ingredients.map((ingredient) {
      if (ingredient['name'].toString().contains('버터') || 
          ingredient['name'].toString().contains('기름')) {
        final currentAmount = ingredient['amount'] as double;
        final newAmount = currentAmount * (1.0 + adjustment * 0.2);
        return {...ingredient, 'amount': newAmount};
      }
      return ingredient;
    }).toList();
  }

  /// 단맛 조정
  static List<Map<String, dynamic>> _adjustSweetness(
    List<Map<String, dynamic>> ingredients,
    double adjustment,
  ) {
    return ingredients.map((ingredient) {
      if (ingredient['name'].toString().contains('설탕')) {
        final currentAmount = ingredient['amount'] as double;
        final newAmount = currentAmount * (1.0 + adjustment * 0.3);
        return {...ingredient, 'amount': newAmount};
      }
      return ingredient;
    }).toList();
  }

  /// 짠맛 조정
  static List<Map<String, dynamic>> _adjustSaltiness(
    List<Map<String, dynamic>> ingredients,
    double adjustment,
  ) {
    return ingredients.map((ingredient) {
      if (ingredient['name'].toString().contains('소금')) {
        final currentAmount = ingredient['amount'] as double;
        final newAmount = currentAmount * (1.0 + adjustment * 0.25);
        return {...ingredient, 'amount': newAmount};
      }
      return ingredient;
    }).toList();
  }

  /// 베이킹 컨텍스트 생성
  static Map<String, dynamic> _generateBakingContext(RecipeTarget target) {
    // 크러스트 색상에 따른 온도 설정
    int suggestedTemperature = 180;
    switch (target.crustColorTarget) {
      case CrustColorTarget.pale:
        suggestedTemperature = 160;
        break;
      case CrustColorTarget.lightBrown:
        suggestedTemperature = 170;
        break;
      case CrustColorTarget.golden:
        suggestedTemperature = 180;
        break;
      case CrustColorTarget.darkBrown:
        suggestedTemperature = 200;
        break;
      case CrustColorTarget.veryDark:
        suggestedTemperature = 220;
        break;
    }

    // 높이 목표에 따른 시간 조정
    int suggestedTime = 30;
    if (target.heightTarget > 0.8) {
      suggestedTime = 35; // 높은 빵은 더 오래
    } else if (target.heightTarget < 0.5) {
      suggestedTime = 25; // 낮은 빵은 짧게
    }

    return {
      'suggestedTemperature': suggestedTemperature,
      'suggestedTimeMinutes': suggestedTime,
      'hasFermentation': true,
      'hasKneading': true,
    };
  }

  /// 베이커스 퍼센트 계산
  static Map<String, double> _calculateBakersPercentages(
    List<Map<String, dynamic>> ingredients,
  ) {
    // 밀가루 무게 찾기
    double flourWeight = 0.0;
    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      if (name.contains('강력분') || name.contains('밀가루')) {
        flourWeight = ingredient['amount'] as double;
        break;
      }
    }

    if (flourWeight == 0) return {};

    // 각 재료의 베이커스 퍼센트 계산
    final percentages = <String, double>{};
    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      final amount = ingredient['amount'] as double;
      percentages[name] = (amount / flourWeight) * 100.0;
    }

    return percentages;
  }

  /// 재료 카테고리 결정
  static String _getIngredientCategory(String ingredientName) {
    if (ingredientName.contains('강력분') || ingredientName.contains('밀가루')) {
      return 'flour';
    } else if (ingredientName.contains('물') || ingredientName.contains('우유')) {
      return 'liquid';
    } else if (ingredientName.contains('이스트')) {
      return 'leavening';
    } else if (ingredientName.contains('설탕')) {
      return 'sweetener';
    } else if (ingredientName.contains('소금')) {
      return 'seasoning';
    } else if (ingredientName.contains('버터') || ingredientName.contains('기름')) {
      return 'fat';
    } else if (ingredientName.contains('계란')) {
      return 'protein';
    } else {
      return 'other';
    }
  }

  /// 최적화 노트 생성
  static List<String> _generateOptimizationNotes(
    RecipeTarget target,
    List<Map<String, dynamic>> ingredients,
    ProductStatus predictedStatus,
    double achievementScore,
  ) {
    final notes = <String>[];

    // 달성도에 따른 전체 평가
    if (achievementScore >= 0.9) {
      notes.add('목표 특성을 매우 잘 달성한 레시피입니다.');
    } else if (achievementScore >= 0.7) {
      notes.add('목표 특성을 잘 달성한 레시피입니다.');
    } else {
      notes.add('목표 특성 달성을 위해 추가 조정이 필요할 수 있습니다.');
    }

    // 특성별 세부 노트
    if (target.moistureTarget > 0.7) {
      notes.add('높은 수분율로 촉촉한 식감을 구현했습니다.');
    }
    
    if (target.chewinessTarget > 0.7) {
      notes.add('적절한 글루텐 형성으로 쫄깃한 식감을 구현했습니다.');
    }
    
    if (target.sweetnessTarget > 0.6) {
      notes.add('당분 함량을 조정하여 원하는 단맛을 구현했습니다.');
    }

    // 베이킹 팁
    notes.add('환경 조건에 따라 발효 시간을 조정하세요.');
    notes.add('오븐 예열을 충분히 하여 일정한 온도를 유지하세요.');

    return notes;
  }

  /// 개선 노트 생성
  static List<String> _generateImprovementNotes(
    RecipeTarget target,
    List<Map<String, dynamic>> originalIngredients,
    List<Map<String, dynamic>> improvedIngredients,
    Map<String, double> improvementAreas,
  ) {
    final notes = <String>[];

    notes.add('기존 레시피를 목표에 맞게 개선했습니다.');

    // 주요 변경사항 설명
    for (final area in improvementAreas.entries) {
      final areaName = area.key;
      final change = area.value;
      
      if (change.abs() > 0.1) {
        switch (areaName) {
          case 'moisture':
            notes.add(change > 0 ? '수분을 증가시켜 더 촉촉하게 만들었습니다.' : '수분을 감소시켜 더 단단하게 만들었습니다.');
            break;
          case 'sweetness':
            notes.add(change > 0 ? '당분을 증가시켜 더 달콤하게 만들었습니다.' : '당분을 감소시켜 덜 달게 만들었습니다.');
            break;
          case 'richness':
            notes.add(change > 0 ? '지방을 증가시켜 더 고소하게 만들었습니다.' : '지방을 감소시켜 더 담백하게 만들었습니다.');
            break;
        }
      }
    }

    notes.add('개선된 레시피로 더 나은 결과를 기대할 수 있습니다.');

    return notes;
  }
}

/// 레시피 최적화 예외
class RecipeOptimizationException implements Exception {
  final String message;
  const RecipeOptimizationException(this.message);
  
  @override
  String toString() => 'RecipeOptimizationException: $message';
}