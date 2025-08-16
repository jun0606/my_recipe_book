/// Sous Chef 모드와 Recipe Detail Screen 간 데이터 연동을 담당하는 브릿지
/// 레시피 데이터를 수쉐프 엔진이 이해할 수 있는 형태로 변환하고 관리합니다.

import '../models/recipe.dart';
import '../models/enhanced_recipe.dart';
import 'ingredient_analyzer.dart';

class SousChefDataBridge {
  /// RecipeDetailScreen에서 실시간 재료 데이터를 수신하여 수쉐프 모드용 데이터로 변환
  static Map<String, dynamic> extractRecipeData(
    Recipe recipe, 
    List<Map<String, dynamic>> calculatedIngredients
  ) {
    // 기본 레시피 정보
    final recipeInfo = {
      'id': recipe.id,
      'title': recipe.title,
      'category': recipe.category,
      'isBaking': recipe.isBaking,
      'baseServings': recipe.baseServings,
    };

    // 재료 분석
    final ingredientAnalysis = _analyzeIngredients(calculatedIngredients);
    
    // 베이킹 컨텍스트 추출
    final bakingContext = _extractBakingContext(recipe);
    
    return {
      'recipeInfo': recipeInfo,
      'originalRecipe': recipe,
      'currentIngredients': calculatedIngredients,
      'ingredientAnalysis': ingredientAnalysis,
      'bakingContext': bakingContext,
      'extractedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 재료 데이터를 수쉐프 엔진이 이해할 수 있는 형태로 변환
  static Map<String, dynamic> prepareForSousChef(Map<String, dynamic> recipeData) {
    final ingredients = recipeData['currentIngredients'] as List<Map<String, dynamic>>;
    final analysis = recipeData['ingredientAnalysis'] as Map<String, dynamic>;
    
    return {
      // 원본 데이터
      'ingredients': ingredients,
      'recipeInfo': recipeData['recipeInfo'],
      
      // 분석된 재료 분류
      'flourTypes': analysis['flourIngredients'],
      'liquids': analysis['liquidIngredients'],
      'yeasts': analysis['yeastIngredients'],
      'salts': analysis['saltIngredients'],
      'sugars': analysis['sugarIngredients'],
      'fats': analysis['fatIngredients'],
      'eggs': analysis['eggIngredients'],
      
      // 계산된 비율들
      'hydration': analysis['hydrationLevel'],
      'yeastPercentage': analysis['yeastPercentage'],
      'saltPercentage': analysis['saltPercentage'],
      'bakersPercentages': analysis['bakersPercentages'],
      
      // 무게 정보
      'totalWeight': analysis['totalWeight'],
      'flourWeight': analysis['flourWeight'],
      'liquidWeight': analysis['liquidWeight'],
      
      // 베이킹 컨텍스트
      'bakingContext': recipeData['bakingContext'],
      
      // 메타데이터
      'preparedAt': DateTime.now().toIso8601String(),
      'dataVersion': '1.0',
    };
  }

  /// 총 무게 계산 (정확한 그램 단위)
  static double calculateTotalWeight(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';
      
      // 단위를 그램으로 변환하여 합산
      totalWeight += _convertToGrams(amount, unit, name);
    }
    
    return totalWeight;
  }

  /// 재료별 무게 계산 (그램 단위)
  static double calculateIngredientWeight(Map<String, dynamic> ingredient) {
    final amount = ingredient['amount'] as double? ?? 0.0;
    final unit = ingredient['unit'] as String? ?? 'g';
    final name = ingredient['name'] as String? ?? '';
    
    return _convertToGrams(amount, unit, name);
  }

  /// 레시피 데이터 유효성 검증
  static bool validateRecipeData(Map<String, dynamic> recipeData) {
    try {
      // 필수 필드 확인
      if (!recipeData.containsKey('currentIngredients') ||
          !recipeData.containsKey('recipeInfo')) {
        return false;
      }

      final ingredients = recipeData['currentIngredients'] as List<Map<String, dynamic>>;
      
      // 재료가 비어있지 않은지 확인
      if (ingredients.isEmpty) {
        return false;
      }

      // 각 재료가 필수 필드를 가지고 있는지 확인
      for (final ingredient in ingredients) {
        if (!ingredient.containsKey('name') ||
            !ingredient.containsKey('amount') ||
            !ingredient.containsKey('unit')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('레시피 데이터 검증 중 오류: $e');
      return false;
    }
  }

  /// 재료 분석 수행
  static Map<String, dynamic> _analyzeIngredients(List<Map<String, dynamic>> ingredients) {
    // IngredientAnalyzer를 사용한 상세 분석
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients);
    final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(ingredients);
    final yeastIngredients = IngredientAnalyzer.findYeastIngredients(ingredients);
    final saltIngredients = IngredientAnalyzer.findSaltIngredients(ingredients);
    
    // 추가 재료 분류
    final sugarIngredients = _findSugarIngredients(ingredients);
    final fatIngredients = _findFatIngredients(ingredients);
    final eggIngredients = _findEggIngredients(ingredients);
    
    // 비율 계산
    final hydrationLevel = IngredientAnalyzer.calculateHydration(ingredients);
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients);
    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients);
    final bakersPercentages = IngredientAnalyzer.calculateBakersPercentage(ingredients);
    
    // 무게 계산
    final totalWeight = calculateTotalWeight(ingredients);
    final flourWeight = _calculateCategoryWeight(flourIngredients);
    final liquidWeight = _calculateCategoryWeight(liquidIngredients);
    
    return {
      // 재료 분류
      'flourIngredients': flourIngredients,
      'liquidIngredients': liquidIngredients,
      'yeastIngredients': yeastIngredients,
      'saltIngredients': saltIngredients,
      'sugarIngredients': sugarIngredients,
      'fatIngredients': fatIngredients,
      'eggIngredients': eggIngredients,
      
      // 비율 정보
      'hydrationLevel': hydrationLevel,
      'yeastPercentage': yeastPercentage,
      'saltPercentage': saltPercentage,
      'bakersPercentages': bakersPercentages,
      
      // 무게 정보
      'totalWeight': totalWeight,
      'flourWeight': flourWeight,
      'liquidWeight': liquidWeight,
      
      // 분석 메타데이터
      'analyzedAt': DateTime.now().toIso8601String(),
      'ingredientCount': ingredients.length,
    };
  }

  /// 베이킹 컨텍스트 추출
  static Map<String, dynamic> _extractBakingContext(Recipe recipe) {
    final context = <String, dynamic>{
      'isBaking': recipe.isBaking,
      'category': recipe.category,
    };

    // 베이킹 레시피인 경우 추가 정보 추출
    if (recipe.isBaking) {
      // 조리법에서 온도와 시간 정보 추출 시도
      final bakingInfo = _extractBakingInfoFromInstructions(recipe.instructions);
      context.addAll(bakingInfo);
      
      // 분할 정보가 있는 경우
      if (recipe.targetSplitAmount != null) {
        context['targetSplitAmount'] = recipe.targetSplitAmount;
      }
      if (recipe.targetSplitCount != null) {
        context['targetSplitCount'] = recipe.targetSplitCount;
      }
    }

    return context;
  }

  /// 조리법에서 베이킹 정보 추출
  static Map<String, dynamic> _extractBakingInfoFromInstructions(List<Map<String, dynamic>> instructions) {
    final bakingInfo = <String, dynamic>{};
    
    for (final instruction in instructions) {
      final text = instruction['instruction']?.toString().toLowerCase() ?? '';
      
      // 온도 정보 추출 (예: "180도", "180°C", "180℃")
      final tempRegex = RegExp(r'(\d+)\s*[도°℃]');
      final tempMatch = tempRegex.firstMatch(text);
      if (tempMatch != null) {
        bakingInfo['suggestedTemperature'] = int.tryParse(tempMatch.group(1)!) ?? 0;
      }
      
      // 시간 정보 추출 (예: "30분", "1시간")
      final timeRegex = RegExp(r'(\d+)\s*분|(\d+)\s*시간');
      final timeMatch = timeRegex.firstMatch(text);
      if (timeMatch != null) {
        if (timeMatch.group(1) != null) {
          // 분 단위
          bakingInfo['suggestedTimeMinutes'] = int.tryParse(timeMatch.group(1)!) ?? 0;
        } else if (timeMatch.group(2) != null) {
          // 시간 단위를 분으로 변환
          final hours = int.tryParse(timeMatch.group(2)!) ?? 0;
          bakingInfo['suggestedTimeMinutes'] = hours * 60;
        }
      }
      
      // 발효 관련 키워드 감지
      if (text.contains('발효') || text.contains('부풀') || text.contains('휴지')) {
        bakingInfo['hasFermentation'] = true;
      }
      
      // 반죽 관련 키워드 감지
      if (text.contains('반죽') || text.contains('치대') || text.contains('글루텐')) {
        bakingInfo['hasKneading'] = true;
      }
    }
    
    return bakingInfo;
  }

  /// 설탕 재료 찾기
  static List<Map<String, dynamic>> _findSugarIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final sugarKeywords = [
        '설탕', '백설탕', '흑설탕', '황설탕', '코코넛설탕', '올리고당',
        'sugar', 'white sugar', 'brown sugar', 'coconut sugar',
        'cane sugar', 'raw sugar', 'turbinado', '꿀', 'honey', '메이플', 'maple'
      ];
      return sugarKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 지방 재료 찾기
  static List<Map<String, dynamic>> _findFatIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        '버터', '마가린', '쇼트닝', '라드', '코코넛오일', '올리브오일', '식용유',
        'butter', 'margarine', 'shortening', 'lard', 'coconut oil', 'olive oil', 'oil'
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 계란 재료 찾기
  static List<Map<String, dynamic>> _findEggIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final eggKeywords = [
        '계란', '달걀', '계란흰자', '계란노른자', '전란',
        'egg', 'eggs', 'egg white', 'egg yolk', 'whole egg'
      ];
      return eggKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 특정 카테고리 재료들의 총 무게 계산
  static double _calculateCategoryWeight(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    for (final ingredient in ingredients) {
      totalWeight += calculateIngredientWeight(ingredient);
    }
    return totalWeight;
  }

  /// 단위를 그램으로 변환 (IngredientAnalyzer와 동일한 로직)
  static double _convertToGrams(double amount, String unit, String ingredientName) {
    final lowerUnit = unit.toLowerCase();
    
    // 이미 그램인 경우
    if (lowerUnit == 'g' || lowerUnit == 'gram' || lowerUnit == 'grams') {
      return amount;
    }
    
    // 킬로그램
    if (lowerUnit == 'kg' || lowerUnit == 'kilogram' || lowerUnit == 'kilograms') {
      return amount * 1000;
    }
    
    // 부피 단위는 재료별 밀도를 고려하여 변환
    final density = _getIngredientDensity(ingredientName);
    
    switch (lowerUnit) {
      case 'ml':
      case 'milliliter':
        return amount * density;
      case 'l':
      case 'liter':
        return amount * 1000 * density;
      case 'cup':
        return amount * 240 * density; // 1컵 = 240ml
      case 'tbsp':
      case 'tablespoon':
        return amount * 15 * density; // 1큰술 = 15ml
      case 'tsp':
      case 'teaspoon':
        return amount * 5 * density; // 1작은술 = 5ml
      default:
        return amount; // 알 수 없는 단위는 그대로 반환
    }
  }

  /// 재료별 밀도 반환 (g/ml)
  static double _getIngredientDensity(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();
    
    // 밀가루류
    if (lowerName.contains('강력분') || lowerName.contains('bread flour')) return 0.65;
    if (lowerName.contains('박력분') || lowerName.contains('cake flour')) return 0.55;
    if (lowerName.contains('중력분') || lowerName.contains('all-purpose flour')) return 0.6;
    if (lowerName.contains('밀가루') || lowerName.contains('flour')) return 0.6;
    
    // 액체류
    if (lowerName.contains('물') || lowerName.contains('water')) return 1.0;
    if (lowerName.contains('우유') || lowerName.contains('milk')) return 1.03;
    if (lowerName.contains('기름') || lowerName.contains('oil')) return 0.92;
    if (lowerName.contains('꿀') || lowerName.contains('honey')) return 1.4;
    if (lowerName.contains('시럽') || lowerName.contains('syrup')) return 1.3;
    
    // 고체류
    if (lowerName.contains('설탕') || lowerName.contains('sugar')) return 0.85;
    if (lowerName.contains('소금') || lowerName.contains('salt')) return 1.2;
    if (lowerName.contains('버터') || lowerName.contains('butter')) return 0.91;
    
    // 기본값 (물의 밀도)
    return 1.0;
  }
}