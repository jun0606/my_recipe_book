import 'package:flutter/material.dart';
import '../../utils/unit_converter.dart';

class IngredientCard extends StatelessWidget {
  final Map<String, dynamic> ingredient;
  final Map<String, dynamic>? originalIngredient;
  final bool isHighlighted;
  final Key? itemKey;

  const IngredientCard({
    Key? key,
    required this.ingredient,
    this.originalIngredient,
    this.isHighlighted = false,
    this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = ingredient['name'] as String;
    final double calculatedAmount = ingredient['amount'] as double;
    final String unit = ingredient['unit'] as String;

    final bool isComparison = originalIngredient != null && originalIngredient!['amount'] != null;

    // 증감률 계산 (비교 정보가 있을 때만)
    double percentageChange = 0.0;
    Color changeColor = Colors.grey[700]!;
    IconData? changeIcon;

    if (isComparison) {
      final double originalValue = originalIngredient!['amount'] as double;
      final difference = calculatedAmount - originalValue;
      percentageChange = originalValue != 0 ? (difference / originalValue) * 100 : 0.0;

      if (percentageChange > 0) {
        changeColor = Colors.green[700]!;
        changeIcon = Icons.arrow_upward;
      } else if (percentageChange < 0) {
        changeColor = Colors.red[700]!;
        changeIcon = Icons.arrow_downward;
      } else {
        changeColor = Colors.grey[700]!;
        changeIcon = Icons.horizontal_rule;
      }
    }

    Widget card = Card(
      key: itemKey,
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.brown[700]),
                ),
                if (isComparison)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: changeColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(changeIcon, size: 14, color: changeColor),
                        SizedBox(width: 2),
                        Text(
                          '${percentageChange.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: changeColor),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 원본 값
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              '원본',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Text(
                          _formatAmount(originalIngredient != null ? originalIngredient!['amount'] : calculatedAmount, unit),
                          style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // 계산된 값
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink[50]!,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.pink[300]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate, size: 16, color: Colors.pink[700]),
                            SizedBox(width: 4),
                            Text(
                              '계산',
                              style: TextStyle(fontSize: 12, color: Colors.pink[600]),
                            ),
                          ],
                        ),
                        Text(
                          _formatAmount(calculatedAmount, unit),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink[800]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isHighlighted) {
      return Transform.scale(
        scale: 1.05,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.pink, width: 3),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)],
          ),
          child: card,
        ),
      );
    }

    return card;
  }

  String _formatAmount(double amount, String unit) {
    // 원본 단위 그대로 사용 (자동 변환하지 않음)
    return UnitConverter.formatAmountWithOriginalUnit(amount, unit);
  }
}