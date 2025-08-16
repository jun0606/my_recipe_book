import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'dart:math' as math;

/// 영양 분석 모듈
/// 
/// 레시피의 칼로리, 영양소 균형, 건강 지표를 분석합니다.
class NutritionalAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'nutritional_analysis';
  static const String moduleVersion = '1.0.0';
  
  NutritionalAnalysisModule() : super(
    name: moduleName,
    version: moduleVersion,
    description: '영양 성분 및 건강 지표 분석 모듈',
    priority: 4, // 다른 분석 후 실행
    dependencies: ['recipe_analysis', 'ingredient_analysis'], // 레시피와 재료 분석 결과 필요
    category: AnalysisModuleCategory.nutrition,
    initialConfiguration: {
      'enable_calorie_calculation': true,
      'enable_macronutrient_analysis': true,
      'enable_micronutrient_analysis': true,
      'enable_health_score': true,
      'enable_dietary_restrictions': true,
      'enable_allergen_analysis': true,
      'daily_values': {
        'calories': 2000.0,
        'protein': 50.0, // g
        'carbohydrates': 300.0, // g
        'fat': 65.0, // g
        'fiber': 25.0, // g
        'sodium': 2300.0, // mg
        'sugar': 50.0, // g
      },
      'health_thresholds': {
        'high_calorie_per_serving': 400.0,
        'high_fat_percentage': 35.0,
        'high_sugar_percentage': 10.0,
        'high_sodium_per_serving': 600.0, // mg
        'low_fiber_per_serving': 3.0, // g
      },
    },
  );

  @override
  Future<void> onInitialize() async {
    // 영양소 데이터베이스 로드, 식품 성분표 초기화 등
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    // 레시피에 재료 정보가 있는 경우에만 처리
    return request.recipe.ingredients.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final recipe = request.recipe;
    final options = request.options;
    
    final results = <String, dynamic>{};
    
    try {
      // 1. 기본 칼로리 계산
      if (getConfiguration<bool>('enable_calorie_calculation', true)) {
        results['calorie_analysis'] = await _calculateCalories(recipe);
      }
      
      // 2. 다량 영양소 분석 (탄수화물, 단백질, 지방)
      if (getConfiguration<bool>('enable_macronutrient_analysis', true)) {
        results['macronutrient_analysis'] = await _analyzeMacronutrients(recipe);
      }
      
      // 3. 미량 영양소 분석 (비타민, 미네랄)
      if (getConfiguration<bool>('enable_micronutrient_analysis', true)) {
        results['micronutrient_analysis'] = await _analyzeMicronutrients(recipe);
      }
      
      // 4. 건강 점수 계산
      if (getConfiguration<bool>('enable_health_score', true)) {
        results['health_score'] = _calculateHealthScore(results);
      }
      
      // 5. 식이 제한 분석
      if (getConfiguration<bool>('enable_dietary_restrictions', true)) {
        results['dietary_analysis'] = _analyzeDietaryRestrictions(recipe);
      }
      
      // 6. 알레르기 유발 요소 분석
      if (getConfiguration<bool>('enable_allergen_analysis', true)) {
        results['allergen_analysis'] = _analyzeAllergens(recipe);
      }
      
      // 7. 영양 균형 평가
      results['nutritional_balance'] = _evaluateNutritionalBalance(results);
      
      // 8. 개선 제안
      results['improvement_suggestions'] = _generateImprovementSuggestions(results);
      
      // 9. 전체 영양 점수
      results['overall_nutrition_score'] = _calculateOverallNutritionScore(results);
      
      // 10. 추천 사항 생성
      if (options.generateRecommendations) {
        results['recommendations'] = _generateNutritionalRecommendations(results);
      }
      
    } catch (e) {
      throw AnalysisProcessingException(
        '영양 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
    
    return results;
  }

  /// 칼로리 계산
  Future<Map<String, dynamic>> _calculateCalories(recipe) async {
    double totalCalories = 0.0;
    final calorieBreakdown = <String, dynamic>{};
    final ingredientCalories = <Map<String, dynamic>>[];
    
    for (final ingredient in recipe.ingredients) {
      final calories = await _getIngredientCalories(ingredient);
      totalCalories += calories;
      
      ingredientCalories.add({
        'name': ingredient.name,
        'amount': ingredient.amount,
        'unit': ingredient.unit,
        'calories': calories,
        'calories_per_100g': await _getCaloriesPer100g(ingredient.name),
      });
    }
    
    final servings = recipe.servings ?? 1;
    final caloriesPerServing = totalCalories / servings;
    
    // 칼로리 카테고리 분류
    final calorieCategory = _categorizeCalories(caloriesPerServing);
    
    return {
      'total_calories': totalCalories,
      'calories_per_serving': caloriesPerServing,
      'servings': servings,
      'calorie_category': calorieCategory,
      'ingredient_breakdown': ingredientCalories,
      'daily_value_percentage': (caloriesPerServing / getConfiguration<double>('daily_values.calories', 2000.0)) * 100,
      'calorie_density': _calculateCalorieDensity(totalCalories, recipe),
    };
  }

  /// 재료별 칼로리 계산
  Future<double> _getIngredientCalories(ingredient) async {
    // 실제 구현에서는 영양소 데이터베이스에서 조회
    final caloriesPer100g = await _getCaloriesPer100g(ingredient.name);
    final weightInGrams = _convertToGrams(ingredient.amount, ingredient.unit);
    
    return (caloriesPer100g * weightInGrams) / 100.0;
  }

  /// 100g당 칼로리 조회 (간단한 예시 데이터)
  Future<double> _getCaloriesPer100g(String ingredientName) async {
    // 실제로는 외부 영양소 데이터베이스나 API를 사용
    final calorieDatabase = {
      '밀가루': 364.0,
      '설탕': 387.0,
      '버터': 717.0,
      '달걀': 155.0,
      '우유': 42.0,
      '베이킹파우더': 53.0,
      '소금': 0.0,
      '바닐라': 288.0,
      '초콜릿': 546.0,
      '견과류': 607.0,
      '과일': 52.0,
      '야채': 25.0,
      '치즈': 402.0,
      '요거트': 59.0,
      '꿀': 304.0,
      '올리브오일': 884.0,
    };
    
    // 재료명에서 키워드 매칭
    for (final key in calorieDatabase.keys) {
      if (ingredientName.toLowerCase().contains(key.toLowerCase())) {
        return calorieDatabase[key]!;
      }
    }
    
    // 기본값 (알 수 없는 재료)
    return 200.0;
  }

  /// 단위를 그램으로 변환
  double _convertToGrams(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case '그램':
        return amount;
      case 'kg':
      case '킬로그램':
        return amount * 1000;
      case 'ml':
      case '밀리리터':
        return amount; // 물 기준 (1ml = 1g)
      case 'l':
      case '리터':
        return amount * 1000;
      case '컵':
        return amount * 240; // 1컵 = 240ml
      case '큰술':
      case 'tbsp':
        return amount * 15;
      case '작은술':
      case 'tsp':
        return amount * 5;
      case '개':
      case '알':
        return amount * 50; // 평균 달걀 무게
      default:
        return amount * 100; // 기본값
    }
  }

  /// 칼로리 카테고리 분류
  String _categorizeCalories(double caloriesPerServing) {
    final highCalorieThreshold = getConfiguration<double>('health_thresholds.high_calorie_per_serving', 400.0);
    
    if (caloriesPerServing < 100) return 'very_low';
    if (caloriesPerServing < 200) return 'low';
    if (caloriesPerServing < 300) return 'moderate';
    if (caloriesPerServing < highCalorieThreshold) return 'high';
    return 'very_high';
  }

  /// 칼로리 밀도 계산
  double _calculateCalorieDensity(double totalCalories, recipe) {
    // 전체 재료 무게 추정
    double totalWeight = 0.0;
    for (final ingredient in recipe.ingredients) {
      totalWeight += _convertToGrams(ingredient.amount, ingredient.unit);
    }
    
    return totalWeight > 0 ? totalCalories / (totalWeight / 100) : 0.0; // 100g당 칼로리
  }

  /// 다량 영양소 분석
  Future<Map<String, dynamic>> _analyzeMacronutrients(recipe) async {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalFiber = 0.0;
    double totalSugar = 0.0;
    
    final macroBreakdown = <Map<String, dynamic>>[];
    
    for (final ingredient in recipe.ingredients) {
      final macros = await _getIngredientMacronutrients(ingredient);
      
      totalProtein += macros['protein'];
      totalCarbs += macros['carbohydrates'];
      totalFat += macros['fat'];
      totalFiber += macros['fiber'];
      totalSugar += macros['sugar'];
      
      macroBreakdown.add({
        'name': ingredient.name,
        'protein': macros['protein'],
        'carbohydrates': macros['carbohydrates'],
        'fat': macros['fat'],
        'fiber': macros['fiber'],
        'sugar': macros['sugar'],
      });
    }
    
    final servings = recipe.servings ?? 1;
    final totalCalories = await _getTotalCalories(recipe);
    
    return {
      'total_macros': {
        'protein': totalProtein,
        'carbohydrates': totalCarbs,
        'fat': totalFat,
        'fiber': totalFiber,
        'sugar': totalSugar,
      },
      'per_serving': {
        'protein': totalProtein / servings,
        'carbohydrates': totalCarbs / servings,
        'fat': totalFat / servings,
        'fiber': totalFiber / servings,
        'sugar': totalSugar / servings,
      },
      'calorie_percentages': {
        'protein_percentage': (totalProtein * 4 / totalCalories) * 100,
        'carbs_percentage': (totalCarbs * 4 / totalCalories) * 100,
        'fat_percentage': (totalFat * 9 / totalCalories) * 100,
      },
      'daily_value_percentages': _calculateMacroDailyValues(totalProtein / servings, totalCarbs / servings, totalFat / servings, totalFiber / servings),
      'ingredient_breakdown': macroBreakdown,
      'balance_assessment': _assessMacronutrientBalance(totalProtein, totalCarbs, totalFat, totalCalories),
    };
  }

  /// 재료별 다량 영양소 조회
  Future<Map<String, double>> _getIngredientMacronutrients(ingredient) async {
    final weightInGrams = _convertToGrams(ingredient.amount, ingredient.unit);
    final macrosPer100g = await _getMacronutrientsPer100g(ingredient.name);
    
    return {
      'protein': (macrosPer100g['protein']! * weightInGrams) / 100.0,
      'carbohydrates': (macrosPer100g['carbohydrates']! * weightInGrams) / 100.0,
      'fat': (macrosPer100g['fat']! * weightInGrams) / 100.0,
      'fiber': (macrosPer100g['fiber']! * weightInGrams) / 100.0,
      'sugar': (macrosPer100g['sugar']! * weightInGrams) / 100.0,
    };
  }

  /// 100g당 다량 영양소 데이터
  Future<Map<String, double>> _getMacronutrientsPer100g(String ingredientName) async {
    final macroDatabase = {
      '밀가루': {'protein': 10.3, 'carbohydrates': 76.3, 'fat': 1.5, 'fiber': 2.7, 'sugar': 0.3},
      '설탕': {'protein': 0.0, 'carbohydrates': 99.8, 'fat': 0.0, 'fiber': 0.0, 'sugar': 99.8},
      '버터': {'protein': 0.9, 'carbohydrates': 0.1, 'fat': 81.1, 'fiber': 0.0, 'sugar': 0.1},
      '달걀': {'protein': 13.0, 'carbohydrates': 1.1, 'fat': 11.0, 'fiber': 0.0, 'sugar': 1.1},
      '우유': {'protein': 3.4, 'carbohydrates': 5.0, 'fat': 1.0, 'fiber': 0.0, 'sugar': 5.0},
      '치즈': {'protein': 25.0, 'carbohydrates': 1.3, 'fat': 33.0, 'fiber': 0.0, 'sugar': 1.3},
      '견과류': {'protein': 15.0, 'carbohydrates': 16.0, 'fat': 54.0, 'fiber': 8.0, 'sugar': 4.0},
      '과일': {'protein': 0.9, 'carbohydrates': 14.0, 'fat': 0.2, 'fiber': 2.4, 'sugar': 10.0},
      '야채': {'protein': 2.9, 'carbohydrates': 6.0, 'fat': 0.4, 'fiber': 2.6, 'sugar': 4.0},
    };
    
    for (final key in macroDatabase.keys) {
      if (ingredientName.toLowerCase().contains(key.toLowerCase())) {
        return macroDatabase[key]!;
      }
    }
    
    // 기본값
    return {'protein': 5.0, 'carbohydrates': 20.0, 'fat': 5.0, 'fiber': 2.0, 'sugar': 5.0};
  }

  /// 다량 영양소 일일 권장량 대비 비율 계산
  Map<String, double> _calculateMacroDailyValues(double protein, double carbs, double fat, double fiber) {
    final dailyValues = getConfiguration<Map<String, dynamic>>('daily_values', {});
    
    return {
      'protein_dv': (protein / (dailyValues['protein'] ?? 50.0)) * 100,
      'carbohydrates_dv': (carbs / (dailyValues['carbohydrates'] ?? 300.0)) * 100,
      'fat_dv': (fat / (dailyValues['fat'] ?? 65.0)) * 100,
      'fiber_dv': (fiber / (dailyValues['fiber'] ?? 25.0)) * 100,
    };
  }

  /// 다량 영양소 균형 평가
  Map<String, dynamic> _assessMacronutrientBalance(double protein, double carbs, double fat, double totalCalories) {
    final proteinPercentage = (protein * 4 / totalCalories) * 100;
    final carbsPercentage = (carbs * 4 / totalCalories) * 100;
    final fatPercentage = (fat * 9 / totalCalories) * 100;
    
    // 권장 비율: 단백질 10-35%, 탄수화물 45-65%, 지방 20-35%
    final balance = <String, dynamic>{};
    
    balance['protein_status'] = _evaluateNutrientRange(proteinPercentage, 10.0, 35.0);
    balance['carbs_status'] = _evaluateNutrientRange(carbsPercentage, 45.0, 65.0);
    balance['fat_status'] = _evaluateNutrientRange(fatPercentage, 20.0, 35.0);
    
    balance['overall_balance'] = _calculateOverallBalance([
      balance['protein_status']['score'],
      balance['carbs_status']['score'],
      balance['fat_status']['score'],
    ]);
    
    return balance;
  }

  /// 영양소 범위 평가
  Map<String, dynamic> _evaluateNutrientRange(double value, double minRecommended, double maxRecommended) {
    String status;
    double score;
    
    if (value < minRecommended) {
      status = 'low';
      score = (value / minRecommended) * 50; // 0-50점
    } else if (value > maxRecommended) {
      status = 'high';
      score = math.max(0, 100 - ((value - maxRecommended) / maxRecommended) * 50); // 50-100점에서 감소
    } else {
      status = 'optimal';
      score = 100.0; // 만점
    }
    
    return {
      'value': value,
      'status': status,
      'score': score,
      'recommended_range': '$minRecommended-$maxRecommended%',
    };
  }

  /// 전체 균형 점수 계산
  double _calculateOverallBalance(List<double> scores) {
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// 전체 칼로리 조회 (캐시된 값 사용)
  Future<double> _getTotalCalories(recipe) async {
    double totalCalories = 0.0;
    for (final ingredient in recipe.ingredients) {
      totalCalories += await _getIngredientCalories(ingredient);
    }
    return totalCalories;
  }  
/// 미량 영양소 분석
  Future<Map<String, dynamic>> _analyzeMicronutrients(recipe) async {
    final micronutrients = <String, double>{
      'vitamin_c': 0.0,
      'vitamin_d': 0.0,
      'vitamin_b12': 0.0,
      'folate': 0.0,
      'calcium': 0.0,
      'iron': 0.0,
      'potassium': 0.0,
      'sodium': 0.0,
      'magnesium': 0.0,
      'zinc': 0.0,
    };
    
    final microBreakdown = <Map<String, dynamic>>[];
    
    for (final ingredient in recipe.ingredients) {
      final micros = await _getIngredientMicronutrients(ingredient);
      
      for (final key in micronutrients.keys) {
        micronutrients[key] = micronutrients[key]! + micros[key]!;
      }
      
      microBreakdown.add({
        'name': ingredient.name,
        ...micros,
      });
    }
    
    final servings = recipe.servings ?? 1;
    final perServing = <String, double>{};
    for (final key in micronutrients.keys) {
      perServing[key] = micronutrients[key]! / servings;
    }
    
    return {
      'total_micronutrients': micronutrients,
      'per_serving': perServing,
      'daily_value_percentages': _calculateMicroDailyValues(perServing),
      'ingredient_breakdown': microBreakdown,
      'deficiency_risks': _assessDeficiencyRisks(perServing),
      'excess_warnings': _assessExcessWarnings(perServing),
    };
  }

  /// 재료별 미량 영양소 조회
  Future<Map<String, double>> _getIngredientMicronutrients(ingredient) async {
    final weightInGrams = _convertToGrams(ingredient.amount, ingredient.unit);
    final microsPer100g = await _getMicronutrientsPer100g(ingredient.name);
    
    final result = <String, double>{};
    for (final key in microsPer100g.keys) {
      result[key] = (microsPer100g[key]! * weightInGrams) / 100.0;
    }
    
    return result;
  }

  /// 100g당 미량 영양소 데이터
  Future<Map<String, double>> _getMicronutrientsPer100g(String ingredientName) async {
    final microDatabase = {
      '밀가루': {
        'vitamin_c': 0.0, 'vitamin_d': 0.0, 'vitamin_b12': 0.0, 'folate': 44.0,
        'calcium': 15.0, 'iron': 1.2, 'potassium': 107.0, 'sodium': 2.0,
        'magnesium': 22.0, 'zinc': 0.7,
      },
      '달걀': {
        'vitamin_c': 0.0, 'vitamin_d': 2.0, 'vitamin_b12': 0.9, 'folate': 47.0,
        'calcium': 56.0, 'iron': 1.8, 'potassium': 138.0, 'sodium': 142.0,
        'magnesium': 12.0, 'zinc': 1.3,
      },
      '우유': {
        'vitamin_c': 1.5, 'vitamin_d': 1.3, 'vitamin_b12': 0.4, 'folate': 5.0,
        'calcium': 113.0, 'iron': 0.0, 'potassium': 150.0, 'sodium': 43.0,
        'magnesium': 10.0, 'zinc': 0.4,
      },
      '버터': {
        'vitamin_c': 0.0, 'vitamin_d': 1.5, 'vitamin_b12': 0.2, 'folate': 3.0,
        'calcium': 24.0, 'iron': 0.0, 'potassium': 24.0, 'sodium': 11.0,
        'magnesium': 2.0, 'zinc': 0.1,
      },
      '과일': {
        'vitamin_c': 58.8, 'vitamin_d': 0.0, 'vitamin_b12': 0.0, 'folate': 20.0,
        'calcium': 16.0, 'iron': 0.4, 'potassium': 181.0, 'sodium': 1.0,
        'magnesium': 13.0, 'zinc': 0.2,
      },
      '야채': {
        'vitamin_c': 89.2, 'vitamin_d': 0.0, 'vitamin_b12': 0.0, 'folate': 63.0,
        'calcium': 40.0, 'iron': 1.5, 'potassium': 320.0, 'sodium': 30.0,
        'magnesium': 23.0, 'zinc': 0.6,
      },
    };
    
    for (final key in microDatabase.keys) {
      if (ingredientName.toLowerCase().contains(key.toLowerCase())) {
        return microDatabase[key]!;
      }
    }
    
    // 기본값
    return {
      'vitamin_c': 5.0, 'vitamin_d': 0.5, 'vitamin_b12': 0.1, 'folate': 10.0,
      'calcium': 20.0, 'iron': 1.0, 'potassium': 100.0, 'sodium': 50.0,
      'magnesium': 15.0, 'zinc': 0.5,
    };
  }

  /// 미량 영양소 일일 권장량 대비 비율 계산
  Map<String, double> _calculateMicroDailyValues(Map<String, double> micronutrients) {
    final dailyValues = {
      'vitamin_c': 90.0, // mg
      'vitamin_d': 20.0, // μg
      'vitamin_b12': 2.4, // μg
      'folate': 400.0, // μg
      'calcium': 1000.0, // mg
      'iron': 18.0, // mg
      'potassium': 3500.0, // mg
      'sodium': 2300.0, // mg (상한선)
      'magnesium': 400.0, // mg
      'zinc': 11.0, // mg
    };
    
    final result = <String, double>{};
    for (final key in micronutrients.keys) {
      if (dailyValues.containsKey(key)) {
        result['${key}_dv'] = (micronutrients[key]! / dailyValues[key]!) * 100;
      }
    }
    
    return result;
  }

  /// 결핍 위험 평가
  List<Map<String, dynamic>> _assessDeficiencyRisks(Map<String, double> micronutrients) {
    final risks = <Map<String, dynamic>>[];
    final criticalThresholds = {
      'vitamin_c': 10.0, // 10% 미만 시 위험
      'vitamin_d': 15.0,
      'vitamin_b12': 20.0,
      'folate': 15.0,
      'calcium': 20.0,
      'iron': 25.0,
      'potassium': 10.0,
      'magnesium': 20.0,
      'zinc': 25.0,
    };
    
    final dailyValues = _calculateMicroDailyValues(micronutrients);
    
    for (final nutrient in criticalThresholds.keys) {
      final dvKey = '${nutrient}_dv';
      if (dailyValues.containsKey(dvKey)) {
        final percentage = dailyValues[dvKey]!;
        if (percentage < criticalThresholds[nutrient]!) {
          risks.add({
            'nutrient': nutrient,
            'current_percentage': percentage,
            'risk_level': percentage < 5 ? 'high' : 'medium',
            'recommendation': _getDeficiencyRecommendation(nutrient),
          });
        }
      }
    }
    
    return risks;
  }

  /// 과잉 경고 평가
  List<Map<String, dynamic>> _assessExcessWarnings(Map<String, double> micronutrients) {
    final warnings = <Map<String, dynamic>>[];
    final excessThresholds = {
      'sodium': 100.0, // 100% 이상 시 경고
      'vitamin_d': 200.0,
      'iron': 150.0,
      'zinc': 200.0,
    };
    
    final dailyValues = _calculateMicroDailyValues(micronutrients);
    
    for (final nutrient in excessThresholds.keys) {
      final dvKey = '${nutrient}_dv';
      if (dailyValues.containsKey(dvKey)) {
        final percentage = dailyValues[dvKey]!;
        if (percentage > excessThresholds[nutrient]!) {
          warnings.add({
            'nutrient': nutrient,
            'current_percentage': percentage,
            'warning_level': percentage > 200 ? 'high' : 'medium',
            'recommendation': _getExcessRecommendation(nutrient),
          });
        }
      }
    }
    
    return warnings;
  }

  /// 결핍 개선 권장사항
  String _getDeficiencyRecommendation(String nutrient) {
    final recommendations = {
      'vitamin_c': '신선한 과일이나 야채를 추가하세요',
      'vitamin_d': '버섯이나 강화 식품을 고려하세요',
      'vitamin_b12': '유제품이나 강화 식품을 추가하세요',
      'folate': '녹색 잎채소나 콩류를 추가하세요',
      'calcium': '유제품이나 참깨를 추가하세요',
      'iron': '견과류나 씨앗을 추가하세요',
      'potassium': '바나나나 감자를 추가하세요',
      'magnesium': '견과류나 씨앗을 추가하세요',
      'zinc': '견과류나 씨앗을 추가하세요',
    };
    
    return recommendations[nutrient] ?? '균형 잡힌 식단을 고려하세요';
  }

  /// 과잉 개선 권장사항
  String _getExcessRecommendation(String nutrient) {
    final recommendations = {
      'sodium': '소금 사용량을 줄이세요',
      'vitamin_d': '과도한 강화 식품 사용을 피하세요',
      'iron': '철분이 많은 재료 사용량을 조절하세요',
      'zinc': '아연이 많은 재료 사용량을 조절하세요',
    };
    
    return recommendations[nutrient] ?? '해당 영양소가 많은 재료 사용량을 조절하세요';
  }

  /// 건강 점수 계산
  Map<String, dynamic> _calculateHealthScore(Map<String, dynamic> results) {
    double score = 50.0; // 기본 점수
    final factors = <String, double>{};
    
    // 칼로리 점수 (20점)
    if (results.containsKey('calorie_analysis')) {
      final calorieCategory = results['calorie_analysis']['calorie_category'];
      factors['calorie_score'] = _getCalorieScore(calorieCategory);
      score += factors['calorie_score']! * 0.2;
    }
    
    // 다량 영양소 균형 점수 (30점)
    if (results.containsKey('macronutrient_analysis')) {
      final balance = results['macronutrient_analysis']['balance_assessment']['overall_balance'];
      factors['macro_balance_score'] = balance;
      score += (balance - 50) * 0.3; // 50점 기준으로 조정
    }
    
    // 미량 영양소 점수 (25점)
    if (results.containsKey('micronutrient_analysis')) {
      factors['micro_score'] = _calculateMicronutrientScore(results['micronutrient_analysis']);
      score += factors['micro_score']! * 0.25;
    }
    
    // 건강 위험 요소 감점 (25점)
    factors['health_risk_score'] = _calculateHealthRiskScore(results);
    score += factors['health_risk_score']! * 0.25;
    
    return {
      'overall_health_score': score.clamp(0.0, 100.0),
      'score_factors': factors,
      'health_grade': _getHealthGrade(score),
      'improvement_potential': math.max(0, 85 - score), // 85점을 목표로 설정
    };
  }

  /// 칼로리 점수 계산
  double _getCalorieScore(String calorieCategory) {
    switch (calorieCategory) {
      case 'very_low': return 30.0;
      case 'low': return 60.0;
      case 'moderate': return 100.0;
      case 'high': return 70.0;
      case 'very_high': return 40.0;
      default: return 50.0;
    }
  }

  /// 미량 영양소 점수 계산
  double _calculateMicronutrientScore(Map<String, dynamic> microAnalysis) {
    final deficiencyRisks = microAnalysis['deficiency_risks'] as List;
    final excessWarnings = microAnalysis['excess_warnings'] as List;
    
    double score = 100.0;
    
    // 결핍 위험 감점
    for (final risk in deficiencyRisks) {
      final riskLevel = risk['risk_level'];
      score -= riskLevel == 'high' ? 15.0 : 8.0;
    }
    
    // 과잉 경고 감점
    for (final warning in excessWarnings) {
      final warningLevel = warning['warning_level'];
      score -= warningLevel == 'high' ? 10.0 : 5.0;
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// 건강 위험 점수 계산
  double _calculateHealthRiskScore(Map<String, dynamic> results) {
    double score = 100.0;
    
    // 고나트륨 위험
    if (results.containsKey('micronutrient_analysis')) {
      final sodium = results['micronutrient_analysis']['per_serving']['sodium'] ?? 0.0;
      final highSodiumThreshold = getConfiguration<double>('health_thresholds.high_sodium_per_serving', 600.0);
      if (sodium > highSodiumThreshold) {
        score -= 20.0;
      }
    }
    
    // 고당분 위험
    if (results.containsKey('macronutrient_analysis')) {
      final sugar = results['macronutrient_analysis']['per_serving']['sugar'] ?? 0.0;
      if (sugar > 25.0) { // 25g 이상
        score -= 15.0;
      }
    }
    
    // 저섬유질 위험
    if (results.containsKey('macronutrient_analysis')) {
      final fiber = results['macronutrient_analysis']['per_serving']['fiber'] ?? 0.0;
      final lowFiberThreshold = getConfiguration<double>('health_thresholds.low_fiber_per_serving', 3.0);
      if (fiber < lowFiberThreshold) {
        score -= 10.0;
      }
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// 건강 등급 계산
  String _getHealthGrade(double score) {
    if (score >= 85) return 'A';
    if (score >= 75) return 'B';
    if (score >= 65) return 'C';
    if (score >= 55) return 'D';
    return 'F';
  }

  /// 식이 제한 분석
  Map<String, dynamic> _analyzeDietaryRestrictions(recipe) {
    final restrictions = <String, bool>{
      'vegetarian': true,
      'vegan': true,
      'gluten_free': true,
      'dairy_free': true,
      'nut_free': true,
      'low_sodium': true,
      'low_sugar': true,
      'keto_friendly': true,
      'paleo_friendly': true,
    };
    
    final restrictionViolations = <String, List<String>>{};
    
    for (final ingredient in recipe.ingredients) {
      final violations = _checkIngredientRestrictions(ingredient.name);
      
      for (final restriction in violations.keys) {
        if (violations[restriction]!) {
          restrictions[restriction] = false;
          restrictionViolations.putIfAbsent(restriction, () => []).add(ingredient.name);
        }
      }
    }
    
    return {
      'dietary_compatibility': restrictions,
      'restriction_violations': restrictionViolations,
      'suitable_diets': restrictions.entries.where((e) => e.value).map((e) => e.key).toList(),
      'unsuitable_diets': restrictions.entries.where((e) => !e.value).map((e) => e.key).toList(),
      'modification_suggestions': _generateDietaryModifications(restrictionViolations),
    };
  }

  /// 재료별 식이 제한 확인
  Map<String, bool> _checkIngredientRestrictions(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    return {
      'vegetarian': _containsAnimalProducts(name),
      'vegan': _containsAnimalProducts(name) || _containsDairyOrEggs(name),
      'gluten_free': _containsGluten(name),
      'dairy_free': _containsDairy(name),
      'nut_free': _containsNuts(name),
      'low_sodium': false, // 개별 재료로는 판단 어려움
      'low_sugar': _isHighSugar(name),
      'keto_friendly': _isHighCarb(name),
      'paleo_friendly': _isProcessedFood(name),
    };
  }

  /// 동물성 제품 포함 여부
  bool _containsAnimalProducts(String name) {
    final animalProducts = ['고기', '생선', '새우', '게', '조개', '육수', '젤라틴'];
    return animalProducts.any((product) => name.contains(product));
  }

  /// 유제품이나 달걀 포함 여부
  bool _containsDairyOrEggs(String name) {
    final dairyEggs = ['우유', '버터', '치즈', '요거트', '크림', '달걀', '계란'];
    return dairyEggs.any((product) => name.contains(product));
  }

  /// 유제품 포함 여부
  bool _containsDairy(String name) {
    final dairy = ['우유', '버터', '치즈', '요거트', '크림'];
    return dairy.any((product) => name.contains(product));
  }

  /// 글루텐 포함 여부
  bool _containsGluten(String name) {
    final glutenSources = ['밀가루', '밀', '보리', '호밀', '귀리'];
    return glutenSources.any((source) => name.contains(source));
  }

  /// 견과류 포함 여부
  bool _containsNuts(String name) {
    final nuts = ['아몬드', '호두', '땅콩', '피스타치오', '캐슈넛', '견과'];
    return nuts.any((nut) => name.contains(nut));
  }

  /// 고당분 재료 여부
  bool _isHighSugar(String name) {
    final highSugar = ['설탕', '꿀', '시럽', '잼', '초콜릿'];
    return highSugar.any((sugar) => name.contains(sugar));
  }

  /// 고탄수화물 재료 여부
  bool _isHighCarb(String name) {
    final highCarb = ['밀가루', '쌀', '감자', '설탕', '꿀', '과일'];
    return highCarb.any((carb) => name.contains(carb));
  }

  /// 가공식품 여부
  bool _isProcessedFood(String name) {
    final processed = ['베이킹파우더', '바닐라', '인공', '첨가물'];
    return processed.any((proc) => name.contains(proc));
  }

  /// 식이 제한 수정 제안
  Map<String, List<String>> _generateDietaryModifications(Map<String, List<String>> violations) {
    final suggestions = <String, List<String>>{};
    
    for (final restriction in violations.keys) {
      suggestions[restriction] = _getDietaryAlternatives(restriction, violations[restriction]!);
    }
    
    return suggestions;
  }

  /// 식이 제한별 대안 제안
  List<String> _getDietaryAlternatives(String restriction, List<String> violatingIngredients) {
    final alternatives = <String>[];
    
    switch (restriction) {
      case 'vegan':
        if (violatingIngredients.any((i) => i.contains('버터'))) {
          alternatives.add('버터 대신 식물성 오일이나 비건 버터 사용');
        }
        if (violatingIngredients.any((i) => i.contains('달걀'))) {
          alternatives.add('달걀 대신 아쿠아파바나 아마씨겔 사용');
        }
        if (violatingIngredients.any((i) => i.contains('우유'))) {
          alternatives.add('우유 대신 식물성 우유(아몬드, 오트, 두유) 사용');
        }
        break;
      case 'gluten_free':
        if (violatingIngredients.any((i) => i.contains('밀가루'))) {
          alternatives.add('밀가루 대신 글루텐프리 밀가루 믹스 사용');
        }
        break;
      case 'dairy_free':
        alternatives.add('모든 유제품을 식물성 대안으로 교체');
        break;
      case 'nut_free':
        alternatives.add('견과류를 씨앗류(해바라기씨, 호박씨)로 대체');
        break;
      case 'keto_friendly':
        alternatives.add('밀가루를 아몬드가루로, 설탕을 에리스리톨로 대체');
        break;
    }
    
    return alternatives;
  }  ///
 알레르기 유발 요소 분석
  Map<String, dynamic> _analyzeAllergens(recipe) {
    final commonAllergens = {
      'gluten': false,
      'dairy': false,
      'eggs': false,
      'nuts': false,
      'soy': false,
      'shellfish': false,
      'fish': false,
      'sesame': false,
    };
    
    final allergenSources = <String, List<String>>{};
    
    for (final ingredient in recipe.ingredients) {
      final allergens = _identifyAllergens(ingredient.name);
      
      for (final allergen in allergens) {
        commonAllergens[allergen] = true;
        allergenSources.putIfAbsent(allergen, () => []).add(ingredient.name);
      }
    }
    
    return {
      'contains_allergens': commonAllergens,
      'allergen_sources': allergenSources,
      'allergen_warnings': _generateAllergenWarnings(commonAllergens),
      'safe_for_allergies': commonAllergens.entries.where((e) => !e.value).map((e) => e.key).toList(),
      'cross_contamination_risks': _assessCrossContaminationRisks(allergenSources),
    };
  }

  /// 재료별 알레르기 유발 요소 식별
  List<String> _identifyAllergens(String ingredientName) {
    final name = ingredientName.toLowerCase();
    final allergens = <String>[];
    
    if (_containsGluten(name)) allergens.add('gluten');
    if (_containsDairy(name)) allergens.add('dairy');
    if (name.contains('달걀') || name.contains('계란')) allergens.add('eggs');
    if (_containsNuts(name)) allergens.add('nuts');
    if (name.contains('콩') || name.contains('두부')) allergens.add('soy');
    if (name.contains('새우') || name.contains('게') || name.contains('조개')) allergens.add('shellfish');
    if (name.contains('생선')) allergens.add('fish');
    if (name.contains('참깨') || name.contains('깨')) allergens.add('sesame');
    
    return allergens;
  }

  /// 알레르기 경고 생성
  List<String> _generateAllergenWarnings(Map<String, bool> allergens) {
    final warnings = <String>[];
    
    for (final allergen in allergens.keys) {
      if (allergens[allergen]!) {
        warnings.add(_getAllergenWarning(allergen));
      }
    }
    
    return warnings;
  }

  /// 알레르기별 경고 메시지
  String _getAllergenWarning(String allergen) {
    final warnings = {
      'gluten': '글루텐 알레르기나 셀리악병 환자는 섭취를 피하세요',
      'dairy': '유당불내증이나 유제품 알레르기 환자는 주의하세요',
      'eggs': '달걀 알레르기 환자는 섭취를 피하세요',
      'nuts': '견과류 알레르기 환자는 섭취를 피하세요',
      'soy': '콩 알레르기 환자는 주의하세요',
      'shellfish': '갑각류 알레르기 환자는 섭취를 피하세요',
      'fish': '생선 알레르기 환자는 주의하세요',
      'sesame': '참깨 알레르기 환자는 주의하세요',
    };
    
    return warnings[allergen] ?? '$allergen 알레르기 환자는 주의하세요';
  }

  /// 교차 오염 위험 평가
  Map<String, String> _assessCrossContaminationRisks(Map<String, List<String>> allergenSources) {
    final risks = <String, String>{};
    
    if (allergenSources.containsKey('nuts')) {
      risks['nuts'] = '견과류 가공 시설에서 제조된 다른 재료들과의 교차 오염 가능성';
    }
    
    if (allergenSources.containsKey('gluten')) {
      risks['gluten'] = '밀가루 사용으로 인한 작업 환경 내 글루텐 오염 가능성';
    }
    
    if (allergenSources.containsKey('dairy')) {
      risks['dairy'] = '유제품 사용으로 인한 조리 도구 교차 오염 가능성';
    }
    
    return risks;
  }

  /// 영양 균형 평가
  Map<String, dynamic> _evaluateNutritionalBalance(Map<String, dynamic> results) {
    final balance = <String, dynamic>{};
    
    // 다량 영양소 균형
    if (results.containsKey('macronutrient_analysis')) {
      balance['macronutrient_balance'] = results['macronutrient_analysis']['balance_assessment'];
    }
    
    // 미량 영양소 충족도
    if (results.containsKey('micronutrient_analysis')) {
      balance['micronutrient_adequacy'] = _calculateMicronutrientAdequacy(results['micronutrient_analysis']);
    }
    
    // 칼로리 적절성
    if (results.containsKey('calorie_analysis')) {
      balance['calorie_appropriateness'] = _evaluateCalorieAppropriateness(results['calorie_analysis']);
    }
    
    // 전체 균형 점수
    balance['overall_balance_score'] = _calculateNutritionalBalanceScore(balance);
    
    return balance;
  }

  /// 미량 영양소 충족도 계산
  Map<String, dynamic> _calculateMicronutrientAdequacy(Map<String, dynamic> microAnalysis) {
    final dailyValues = microAnalysis['daily_value_percentages'] as Map<String, double>;
    
    int adequate = 0;
    int inadequate = 0;
    int excessive = 0;
    
    for (final percentage in dailyValues.values) {
      if (percentage >= 20 && percentage <= 100) {
        adequate++;
      } else if (percentage < 20) {
        inadequate++;
      } else {
        excessive++;
      }
    }
    
    final total = adequate + inadequate + excessive;
    
    return {
      'adequate_count': adequate,
      'inadequate_count': inadequate,
      'excessive_count': excessive,
      'adequacy_percentage': total > 0 ? (adequate / total) * 100 : 0.0,
      'adequacy_rating': _getAdequacyRating(adequate, total),
    };
  }

  /// 충족도 등급 계산
  String _getAdequacyRating(int adequate, int total) {
    if (total == 0) return 'unknown';
    
    final percentage = (adequate / total) * 100;
    if (percentage >= 80) return 'excellent';
    if (percentage >= 60) return 'good';
    if (percentage >= 40) return 'fair';
    return 'poor';
  }

  /// 칼로리 적절성 평가
  Map<String, dynamic> _evaluateCalorieAppropriateness(Map<String, dynamic> calorieAnalysis) {
    final caloriesPerServing = calorieAnalysis['calories_per_serving'] as double;
    final dailyValuePercentage = calorieAnalysis['daily_value_percentage'] as double;
    
    String appropriateness;
    if (dailyValuePercentage < 5) {
      appropriateness = 'very_low';
    } else if (dailyValuePercentage < 15) {
      appropriateness = 'low';
    } else if (dailyValuePercentage < 25) {
      appropriateness = 'appropriate';
    } else if (dailyValuePercentage < 35) {
      appropriateness = 'high';
    } else {
      appropriateness = 'very_high';
    }
    
    return {
      'appropriateness': appropriateness,
      'daily_value_percentage': dailyValuePercentage,
      'serving_recommendation': _getServingRecommendation(appropriateness),
    };
  }

  /// 섭취량 권장사항
  String _getServingRecommendation(String appropriateness) {
    switch (appropriateness) {
      case 'very_low':
        return '다른 영양소와 함께 섭취하세요';
      case 'low':
        return '적절한 간식이나 디저트로 좋습니다';
      case 'appropriate':
        return '한 끼 식사의 일부로 적절합니다';
      case 'high':
        return '섭취량을 조절하거나 활동량을 늘리세요';
      case 'very_high':
        return '섭취량을 크게 줄이거나 여러 번에 나누어 드세요';
      default:
        return '균형 잡힌 식단의 일부로 섭취하세요';
    }
  }

  /// 영양 균형 점수 계산
  double _calculateNutritionalBalanceScore(Map<String, dynamic> balance) {
    double score = 0.0;
    int factors = 0;
    
    // 다량 영양소 균형 점수 (40%)
    if (balance.containsKey('macronutrient_balance')) {
      final macroScore = balance['macronutrient_balance']['overall_balance'] as double;
      score += macroScore * 0.4;
      factors++;
    }
    
    // 미량 영양소 충족도 점수 (35%)
    if (balance.containsKey('micronutrient_adequacy')) {
      final microScore = balance['micronutrient_adequacy']['adequacy_percentage'] as double;
      score += microScore * 0.35;
      factors++;
    }
    
    // 칼로리 적절성 점수 (25%)
    if (balance.containsKey('calorie_appropriateness')) {
      final calorieScore = _getCalorieAppropriatenessScore(balance['calorie_appropriateness']['appropriateness']);
      score += calorieScore * 0.25;
      factors++;
    }
    
    return factors > 0 ? score : 50.0;
  }

  /// 칼로리 적절성 점수
  double _getCalorieAppropriatenessScore(String appropriateness) {
    switch (appropriateness) {
      case 'very_low': return 40.0;
      case 'low': return 70.0;
      case 'appropriate': return 100.0;
      case 'high': return 60.0;
      case 'very_high': return 30.0;
      default: return 50.0;
    }
  }

  /// 개선 제안 생성
  Map<String, dynamic> _generateImprovementSuggestions(Map<String, dynamic> results) {
    final suggestions = <String, List<String>>{
      'nutritional_improvements': [],
      'ingredient_substitutions': [],
      'portion_adjustments': [],
      'preparation_modifications': [],
    };
    
    // 영양소 개선 제안
    if (results.containsKey('micronutrient_analysis')) {
      final deficiencyRisks = results['micronutrient_analysis']['deficiency_risks'] as List;
      for (final risk in deficiencyRisks) {
        suggestions['nutritional_improvements']!.add(risk['recommendation']);
      }
    }
    
    // 재료 대체 제안
    if (results.containsKey('macronutrient_analysis')) {
      final fatPercentage = results['macronutrient_analysis']['calorie_percentages']['fat_percentage'] as double;
      if (fatPercentage > 35) {
        suggestions['ingredient_substitutions']!.add('버터나 오일 사용량을 줄이고 과일 퓨레로 대체 고려');
      }
      
      final sugarAmount = results['macronutrient_analysis']['per_serving']['sugar'] as double;
      if (sugarAmount > 25) {
        suggestions['ingredient_substitutions']!.add('설탕 대신 천연 감미료나 과일을 사용 고려');
      }
    }
    
    // 분량 조정 제안
    if (results.containsKey('calorie_analysis')) {
      final calorieCategory = results['calorie_analysis']['calorie_category'];
      if (calorieCategory == 'very_high') {
        suggestions['portion_adjustments']!.add('1회 제공량을 줄이거나 여러 번에 나누어 섭취');
      }
    }
    
    // 조리법 수정 제안
    suggestions['preparation_modifications']!.addAll([
      '굽기 대신 찜이나 삶기로 조리법 변경 고려',
      '소금 사용량을 줄이고 허브나 향신료로 맛 보완',
      '전체곡물이나 견과류 추가로 영양가 향상',
    ]);
    
    return {
      'suggestions': suggestions,
      'priority_improvements': _prioritizeImprovements(suggestions),
      'estimated_impact': _estimateImprovementImpact(suggestions),
    };
  }

  /// 개선 사항 우선순위 설정
  List<String> _prioritizeImprovements(Map<String, List<String>> suggestions) {
    final prioritized = <String>[];
    
    // 영양소 개선이 최우선
    prioritized.addAll(suggestions['nutritional_improvements'] ?? []);
    prioritized.addAll(suggestions['ingredient_substitutions'] ?? []);
    prioritized.addAll(suggestions['portion_adjustments'] ?? []);
    prioritized.addAll(suggestions['preparation_modifications'] ?? []);
    
    return prioritized.take(5).toList(); // 상위 5개만 반환
  }

  /// 개선 효과 추정
  Map<String, dynamic> _estimateImprovementImpact(Map<String, List<String>> suggestions) {
    final totalSuggestions = suggestions.values.fold(0, (sum, list) => sum + list.length);
    
    return {
      'potential_score_improvement': math.min(totalSuggestions * 5.0, 30.0), // 최대 30점 향상
      'health_benefit_level': totalSuggestions > 5 ? 'high' : totalSuggestions > 2 ? 'medium' : 'low',
      'implementation_difficulty': _assessImplementationDifficulty(suggestions),
    };
  }

  /// 구현 난이도 평가
  String _assessImplementationDifficulty(Map<String, List<String>> suggestions) {
    final substitutions = suggestions['ingredient_substitutions']?.length ?? 0;
    final modifications = suggestions['preparation_modifications']?.length ?? 0;
    
    final totalChanges = substitutions + modifications;
    
    if (totalChanges > 5) return 'high';
    if (totalChanges > 2) return 'medium';
    return 'low';
  }

  /// 전체 영양 점수 계산
  double _calculateOverallNutritionScore(Map<String, dynamic> results) {
    double score = 0.0;
    int components = 0;
    
    // 건강 점수 (40%)
    if (results.containsKey('health_score')) {
      score += (results['health_score']['overall_health_score'] as double) * 0.4;
      components++;
    }
    
    // 영양 균형 점수 (35%)
    if (results.containsKey('nutritional_balance')) {
      score += (results['nutritional_balance']['overall_balance_score'] as double) * 0.35;
      components++;
    }
    
    // 식이 적합성 점수 (25%)
    if (results.containsKey('dietary_analysis')) {
      final suitableDiets = results['dietary_analysis']['suitable_diets'] as List;
      final dietScore = (suitableDiets.length / 9.0) * 100; // 9개 식이 제한 기준
      score += dietScore * 0.25;
      components++;
    }
    
    return components > 0 ? score : 50.0;
  }

  /// 영양 추천 사항 생성
  List<Map<String, dynamic>> _generateNutritionalRecommendations(Map<String, dynamic> results) {
    final recommendations = <Map<String, dynamic>>[];
    
    final overallScore = results['overall_nutrition_score'] as double? ?? 50.0;
    
    // 전체 영양 점수 기반 추천
    if (overallScore < 60) {
      recommendations.add({
        'type': 'overall_improvement',
        'priority': 'high',
        'title': '전반적인 영양 개선 필요',
        'description': '현재 레시피의 영양 균형을 개선하기 위한 조치가 필요합니다.',
        'actions': results['improvement_suggestions']['priority_improvements'],
      });
    }
    
    // 건강 점수 기반 추천
    if (results.containsKey('health_score')) {
      final healthGrade = results['health_score']['health_grade'];
      if (healthGrade == 'D' || healthGrade == 'F') {
        recommendations.add({
          'type': 'health_improvement',
          'priority': 'high',
          'title': '건강 지표 개선',
          'description': '건강에 해로운 요소들을 줄이고 유익한 영양소를 늘려야 합니다.',
          'current_grade': healthGrade,
        });
      }
    }
    
    // 알레르기 관련 추천
    if (results.containsKey('allergen_analysis')) {
      final allergens = results['allergen_analysis']['contains_allergens'] as Map<String, bool>;
      final hasAllergens = allergens.values.any((hasAllergen) => hasAllergen);
      
      if (hasAllergens) {
        recommendations.add({
          'type': 'allergen_awareness',
          'priority': 'medium',
          'title': '알레르기 주의사항',
          'description': '이 레시피에는 알레르기 유발 요소가 포함되어 있습니다.',
          'allergens': allergens.entries.where((e) => e.value).map((e) => e.key).toList(),
        });
      }
    }
    
    return recommendations;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    int baseTime = 1200; // 1.2초
    
    // 재료 수에 따른 추가 시간
    baseTime += request.recipe.ingredients.length * 100;
    
    // 분석 깊이에 따른 추가 시간
    baseTime += request.options.analysisDepth * 300;
    
    // 미량 영양소 분석 추가 시간
    if (getConfiguration<bool>('enable_micronutrient_analysis', true)) {
      baseTime += 400;
    }
    
    return baseTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    int baseMemory = 10 * 1024 * 1024; // 10MB
    
    // 재료 수에 따른 메모리 사용량
    baseMemory += request.recipe.ingredients.length * 512 * 1024; // 재료당 512KB
    
    // 상세 분석 시 추가 메모리
    if (request.options.generateRecommendations) {
      baseMemory += 3 * 1024 * 1024; // 3MB 추가
    }
    
    return baseMemory;
  }
}