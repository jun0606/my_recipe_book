import '../models/enhanced_recipe.dart';
import '../models/baking_calculation_result.dart';

/// 레시피 스케일링을 담당하는 엔진
class ScalingEngine {
  /// 스케일링 팩터를 사용하여 레시피 크기 조정
  Future<ScalingResult> scaleRecipe({
    required EnhancedRecipe recipe,
    required double scaleFactor,
  }) async {
    try {
      final scaledIngredients = <Map<String, dynamic>>[];
      final calculations = <String, dynamic>{};
      final warnings = <ValidationWarning>[];

      // 재료별 스케일링
      for (final ingredient in recipe.ingredients) {
        final originalAmount = ingredient['amount'] as double? ?? 0.0;
        final scaledAmount = originalAmount * scaleFactor;

        scaledIngredients.add({
          ...ingredient,
          'amount': scaledAmount,
          'originalAmount': originalAmount,
        });
      }

      // 계산 정보 저장
      calculations['scaleFactor'] = scaleFactor;
      calculations['originalTotalWeight'] =
          _calculateTotalWeight(recipe.ingredients);
      calculations['scaledTotalWeight'] =
          _calculateTotalWeight(scaledIngredients);

      // 경고 생성
      if (scaleFactor > 5.0) {
        warnings.add(ValidationWarning(
          level: ValidationLevel.warning,
          message:
              '스케일링 비율이 매우 큽니다 (${scaleFactor.toStringAsFixed(1)}배). 결과를 확인해주세요.',
          category: 'scaling',
        ));
      } else if (scaleFactor < 0.2) {
        warnings.add(ValidationWarning(
          level: ValidationLevel.warning,
          message:
              '스케일링 비율이 매우 작습니다 (${scaleFactor.toStringAsFixed(1)}배). 정확도가 떨어질 수 있습니다.',
          category: 'scaling',
        ));
      }

      final scaledRecipe = recipe.copyWith(
        ingredients: scaledIngredients,
        servings: (recipe.servings * scaleFactor).round(),
      );

      return ScalingResult(
        scaledRecipe: scaledRecipe,
        calculations: calculations,
        warnings: warnings,
      );
    } catch (e) {
      throw ScalingException('스케일링 중 오류가 발생했습니다: $e');
    }
  }

  /// 목표 무게에 맞춰 레시피 크기 조정
  Future<ScalingResult> scaleToWeight({
    required EnhancedRecipe recipe,
    required double targetWeight,
  }) async {
    final currentWeight = _calculateTotalWeight(recipe.ingredients);
    if (currentWeight == 0) {
      throw ScalingException('현재 레시피의 총 무게를 계산할 수 없습니다.');
    }

    final scaleFactor = targetWeight / currentWeight;
    return scaleRecipe(recipe: recipe, scaleFactor: scaleFactor);
  }

  /// 총 무게 계산
  double _calculateTotalWeight(List<Map<String, dynamic>> ingredients) {
    return ingredients.fold(0.0, (sum, ingredient) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      return sum + amount;
    });
  }
}

/// 스케일링 결과
class ScalingResult {
  final EnhancedRecipe scaledRecipe;
  final Map<String, dynamic> calculations;
  final List<ValidationWarning> warnings;

  const ScalingResult({
    required this.scaledRecipe,
    required this.calculations,
    required this.warnings,
  });
}

/// 스케일링 예외
class ScalingException implements Exception {
  final String message;
  const ScalingException(this.message);

  @override
  String toString() => 'ScalingException: $message';
}
