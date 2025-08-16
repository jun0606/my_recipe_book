import 'package:my_recipe_book/utils/unit_converter.dart';

class RecipeCalculator {
  static List<Map<String, dynamic>> calculateIngredients(
    List<Map<String, dynamic>> ingredients, 
    double multiplier
  ) {
    return ingredients.map((ingredient) {
      final double originalAmount = double.tryParse(ingredient['amount'].toString()) ?? 0.0;
      return {
        'name': ingredient['name'],
        'amount': originalAmount * multiplier,
        'unit': ingredient['unit'],
        'originalAmount': originalAmount,  // 원본 값 보존
      };
    }).toList();
  }

  static double calculateTotalIngredientWeight(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    for (var ingredient in ingredients) {
      final amount = double.tryParse(ingredient['amount'].toString()) ?? 0.0;
      final unit = ingredient['unit'] ?? 'g';
      if (amount > 0) {
        totalWeight += UnitConverter.convert(amount, unit, 'g');
      }
    }
    return totalWeight;
  }

  static Map<String, dynamic> calculateSplitByAmount(
    double totalWeight, 
    double splitAmount, 
    String splitAmountUnit
  ) {
    final convertedSplitAmount = UnitConverter.convert(splitAmount, splitAmountUnit, 'g');
    if (convertedSplitAmount <= 0 || convertedSplitAmount > totalWeight) {
      return {'success': false};
    }
    
    final numSplits = (totalWeight / convertedSplitAmount).floor();
    final remainingWeight = totalWeight - (numSplits * convertedSplitAmount);
    
    return {
      'success': true,
      'splitCount': numSplits,
      'remainingWeight': remainingWeight,
    };
  }

  static Map<String, dynamic> calculateSplitByCount(
    double totalWeight, 
    int splitCount
  ) {
    if (splitCount <= 0) {
      return {'success': false};
    }
    
    final weightPerSplit = totalWeight / splitCount;
    final remainingWeight = totalWeight % splitCount;
    
    return {
      'success': true,
      'splitAmount': weightPerSplit,
      'remainingWeight': remainingWeight,
    };
  }
  
  static Map<String, dynamic> calculateNewSplitCount(
    double totalWeight,
    double originalSplitAmount,
    int originalSplitCount,
    int newSplitCount,
    bool keepOriginalSplitWeight
  ) {
    if (newSplitCount <= 0 || originalSplitCount <= 0 || originalSplitAmount <= 0) {
      return {'success': false};
    }
    
    double finalSplitAmount;
    double finalRemainingWeight;
    double ratio;

    if (keepOriginalSplitWeight) {
      finalSplitAmount = originalSplitAmount;
      finalRemainingWeight = totalWeight - (newSplitCount * finalSplitAmount);
      ratio = (newSplitCount * finalSplitAmount) / totalWeight;
    } else {
      finalSplitAmount = totalWeight / newSplitCount;
      finalRemainingWeight = totalWeight % newSplitCount;
      ratio = newSplitCount / originalSplitCount;
    }
    
    return {
      'success': true,
      'splitAmount': finalSplitAmount,
      'splitCount': newSplitCount,
      'remainingWeight': finalRemainingWeight,
      'ratio': ratio,
    };
  }
}