import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

/// 재료 정보
@HiveType(typeId: 4)
@JsonSerializable()
class Ingredient {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String unit;
  @HiveField(3)
  final Map<String, dynamic> properties;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.properties,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    Map<String, dynamic>? properties,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      properties: properties ?? this.properties,
    );
  }

  /// 밀가루 여부 판별
  bool get isFlour {
    final lowerName = name.toLowerCase();
    return lowerName.contains('flour') ||
        lowerName.contains('밀가루') ||
        lowerName.contains('강력분') ||
        lowerName.contains('중력분') ||
        lowerName.contains('박력분');
  }

  /// 물 여부 판별
  bool get isWater {
    final lowerName = name.toLowerCase();
    return lowerName.contains('water') ||
        lowerName.contains('물') ||
        lowerName.contains('우유') ||
        lowerName.contains('milk');
  }

  /// 소금 여부 판별
  bool get isSalt {
    final lowerName = name.toLowerCase();
    return lowerName.contains('salt') || lowerName.contains('소금');
  }

  /// 이스트 여부 판별
  bool get isYeast {
    final lowerName = name.toLowerCase();
    return lowerName.contains('yeast') ||
        lowerName.contains('이스트') ||
        lowerName.contains('효모');
  }

  /// 설탕 여부 판별
  bool get isSugar {
    final lowerName = name.toLowerCase();
    return lowerName.contains('sugar') ||
        lowerName.contains('설탕') ||
        lowerName.contains('꿀') ||
        lowerName.contains('honey');
  }

  /// 지방 여부 판별
  bool get isFat {
    final lowerName = name.toLowerCase();
    return lowerName.contains('butter') ||
        lowerName.contains('oil') ||
        lowerName.contains('버터') ||
        lowerName.contains('기름') ||
        lowerName.contains('올리브오일');
  }

  /// 단백질 함량 반환
  double get proteinContent {
    return (properties['protein'] as num?)?.toDouble() ?? 0.0;
  }

  /// 수분 함량 반환
  double get moistureContent {
    return (properties['moisture'] as num?)?.toDouble() ?? 0.0;
  }

  /// 지방 함량 반환
  double get fatContent {
    return (properties['fat'] as num?)?.toDouble() ?? 0.0;
  }
}
