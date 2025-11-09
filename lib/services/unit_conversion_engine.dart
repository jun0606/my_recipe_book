import '../models/enhanced_recipe.dart';
import '../models/baking_calculation_result.dart';
import '../models/user_configuration.dart';

/// 단위 변환을 담당하는 엔진
class UnitConversionEngine {
  /// 레시피의 단위를 변환
  Future<UnitConversionResult> convertRecipeUnits({
    required EnhancedRecipe recipe,
    required String targetUnit,
    UserConfiguration? userConfig,
  }) async {
    try {
      final convertedIngredients = <Map<String, dynamic>>[];
      final calculations = <String, dynamic>{};
      final warnings = <ValidationWarning>[];

      // 재료별 단위 변환
      for (final ingredient in recipe.ingredients) {
        final originalAmount = ingredient.amount;
        final originalUnit = ingredient.unit;

        final convertedAmount = _convertUnit(
          amount: originalAmount,
          fromUnit: originalUnit,
          toUnit: targetUnit,
          ingredientName: ingredient.name,
        );

        convertedIngredients.add({
          'name': ingredient.name,
          'amount': convertedAmount,
          'unit': targetUnit,
          'originalAmount': originalAmount,
          'originalUnit': originalUnit,
        });
      }

      // 계산 정보 저장
      calculations['targetUnit'] = targetUnit;
      calculations['conversionsApplied'] = convertedIngredients.length;

      // 정확도 경고
      if (targetUnit == 'cup' || targetUnit == 'tbsp' || targetUnit == 'tsp') {
        warnings.add(ValidationWarning(
          level: ValidationLevel.info,
          message: '부피 단위로 변환했습니다. 재료에 따라 정확도가 다를 수 있습니다.',
          category: 'unit_conversion',
        ));
      }

      final convertedRecipe = recipe.copyWith(
        ingredients: convertedIngredients,
      );

      return UnitConversionResult(
        convertedRecipe: convertedRecipe,
        calculations: calculations,
        warnings: warnings,
      );
    } catch (e) {
      throw UnitConversionException('단위 변환 중 오류가 발생했습니다: $e');
    }
  }

  /// 단위 변환 로직
  double _convertUnit({
    required double amount,
    required String fromUnit,
    required String toUnit,
    required String ingredientName,
  }) {
    if (fromUnit == toUnit) return amount;

    // 무게 단위 변환
    final weightConversions = {
      'g': 1.0,
      'kg': 1000.0,
      'oz': 28.35,
      'lb': 453.59,
    };

    // 부피 단위 변환 (물 기준)
    final volumeConversions = {
      'ml': 1.0,
      'l': 1000.0,
      'cup': 240.0,
      'tbsp': 15.0,
      'tsp': 5.0,
      'fl oz': 29.57,
    };

    // 무게 단위 간 변환
    if (weightConversions.containsKey(fromUnit) &&
        weightConversions.containsKey(toUnit)) {
      final grams = amount * weightConversions[fromUnit]!;
      return grams / weightConversions[toUnit]!;
    }

    // 부피 단위 간 변환
    if (volumeConversions.containsKey(fromUnit) &&
        volumeConversions.containsKey(toUnit)) {
      final ml = amount * volumeConversions[fromUnit]!;
      return ml / volumeConversions[toUnit]!;
    }

    // 무게-부피 간 변환 (재료별 밀도 고려)
    if (weightConversions.containsKey(fromUnit) &&
        volumeConversions.containsKey(toUnit)) {
      final density = _getIngredientDensity(ingredientName);
      final grams = amount * weightConversions[fromUnit]!;
      final ml = grams / density;
      return ml / volumeConversions[toUnit]!;
    }

    if (volumeConversions.containsKey(fromUnit) &&
        weightConversions.containsKey(toUnit)) {
      final density = _getIngredientDensity(ingredientName);
      final ml = amount * volumeConversions[fromUnit]!;
      final grams = ml * density;
      return grams / weightConversions[toUnit]!;
    }

    // 변환할 수 없는 경우 원래 값 반환
    return amount;
  }

  /// 재료별 밀도 반환 (g/ml)
  double _getIngredientDensity(String ingredientName) {
    final densities = {
      '물': 1.0,
      '우유': 1.03,
      '밀가루': 0.6,
      '설탕': 0.85,
      '소금': 1.2,
      '버터': 0.91,
      '식용유': 0.92,
      '꿀': 1.4,
      '계란': 1.03,
    };

    // 재료명에서 키워드 찾기
    for (final key in densities.keys) {
      if (ingredientName.contains(key)) {
        return densities[key]!;
      }
    }

    // 기본값 (물의 밀도)
    return 1.0;
  }
}

/// 단위 변환 결과
class UnitConversionResult {
  final EnhancedRecipe convertedRecipe;
  final Map<String, dynamic> calculations;
  final List<ValidationWarning> warnings;

  const UnitConversionResult({
    required this.convertedRecipe,
    required this.calculations,
    required this.warnings,
  });
}

/// 단위 변환 예외
class UnitConversionException implements Exception {
  final String message;
  const UnitConversionException(this.message);

  @override
  String toString() => 'UnitConversionException: $message';
}
