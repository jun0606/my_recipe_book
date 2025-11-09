// lib/widgets/recipe_detail/ingredient_card_simple.dart
// 간단한 재료 카드 위젯

import 'package:flutter/material.dart';

/// 재료 정보를 담는 간단한 카드 위젯
class IngredientCardSimple extends StatelessWidget {
  final String name;
  final double amount;
  final String unit;
  final String? category;
  final bool isCompleted;

  const IngredientCardSimple({
    super.key,
    required this.name,
    required this.amount,
    required this.unit,
    this.category,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: ListTile(
        leading: Icon(
          _getIngredientIcon(),
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: category != null ? Text(category!) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${amount.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        onTap: () {
          // 재료 완료 상태 토글 (실제 구현에서는 콜백 사용)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name 선택됨')),
          );
        },
      ),
    );
  }

  IconData _getIngredientIcon() {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('밀가루') || lowerName.contains('flour')) {
      return Icons.grain;
    } else if (lowerName.contains('물') || lowerName.contains('water')) {
      return Icons.water_drop;
    } else if (lowerName.contains('소금') || lowerName.contains('salt')) {
      return Icons.shower;
    } else if (lowerName.contains('설탕') || lowerName.contains('sugar')) {
      return Icons.cookie;
    } else if (lowerName.contains('버터') || lowerName.contains('butter')) {
      return Icons.restaurant;
    } else if (lowerName.contains('계란') || lowerName.contains('egg')) {
      return Icons.egg;
    } else if (lowerName.contains('우유') || lowerName.contains('milk')) {
      return Icons.local_drink;
    } else {
      return Icons.kitchen;
    }
  }
}
