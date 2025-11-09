// lib/widgets/recipe_detail/baking_calculator.dart
// 베이킹 계산기 위젯

import 'package:flutter/material.dart';
import '../../../../models/recipe.dart';
import '../../../../models/ingredient.dart';

/// 베이킹 계산기 위젯
class BakingCalculator extends StatelessWidget {
  final double? flourWeight;
  final double? waterWeight;
  final double? saltWeight;
  final double? yeastWeight;
  final Recipe? recipe;
  final TextEditingController? targetWeightController;
  final Function(List<Ingredient>)? onIngredientsCalculated;
  final Function(double)? onMultiplierChanged;

  const BakingCalculator({
    super.key,
    this.flourWeight,
    this.waterWeight,
    this.saltWeight,
    this.yeastWeight,
    this.recipe,
    this.targetWeightController,
    this.onIngredientsCalculated,
    this.onMultiplierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hydration = _calculateHydration();
    final saltPercentage = _calculateSaltPercentage();
    final yeastPercentage = _calculateYeastPercentage();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '베이킹 계산기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 수분 함량
            _buildCalculationRow(
              '수분 함량',
              '${hydration.toStringAsFixed(1)}%',
              hydration > 70
                  ? Colors.green
                  : hydration > 60
                      ? Colors.orange
                      : Colors.red,
            ),

            const SizedBox(height: 8),

            // 소금 비율
            _buildCalculationRow(
              '소금 비율',
              '${saltPercentage.toStringAsFixed(2)}%',
              saltPercentage > 1.5 && saltPercentage < 2.5
                  ? Colors.green
                  : Colors.orange,
            ),

            const SizedBox(height: 8),

            // 효모 비율
            _buildCalculationRow(
              '효모 비율',
              '${yeastPercentage.toStringAsFixed(2)}%',
              yeastPercentage > 0.5 && yeastPercentage < 2.0
                  ? Colors.green
                  : Colors.orange,
            ),

            const SizedBox(height: 16),

            // 팁
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 최적 수분 함량: 65-75%, 소금: 1.8-2.2%, 효모: 1-2%',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateHydration() {
    if (flourWeight == null || flourWeight == 0) return 0.0;
    if (waterWeight == null) return 0.0;
    return (waterWeight! / flourWeight!) * 100;
  }

  double _calculateSaltPercentage() {
    if (flourWeight == null || flourWeight == 0) return 0.0;
    if (saltWeight == null) return 0.0;
    return (saltWeight! / flourWeight!) * 100;
  }

  double _calculateYeastPercentage() {
    if (flourWeight == null || flourWeight == 0) return 0.0;
    if (yeastWeight == null) return 0.0;
    return (yeastWeight! / flourWeight!) * 100;
  }
}
