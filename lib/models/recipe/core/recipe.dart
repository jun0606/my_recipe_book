import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'ingredient.dart';

part 'recipe.g.dart';

/// 레시피 카테고리
@HiveType(typeId: 5)
enum RecipeCategory {
  @HiveField(0)
  @JsonValue('bread')
  bread,
  @HiveField(1)
  @JsonValue('cake')
  cake,
  @HiveField(2)
  @JsonValue('cookie')
  cookie,
  @HiveField(3)
  @JsonValue('dessert')
  dessert,
}

extension RecipeCategoryExtension on RecipeCategory {
  String get displayName {
    switch (this) {
      case RecipeCategory.bread:
        return '빵';
      case RecipeCategory.cake:
        return '케이크';
      case RecipeCategory.cookie:
        return '쿠키';
      case RecipeCategory.dessert:
        return '디저트';
    }
  }

  String get englishName {
    switch (this) {
      case RecipeCategory.bread:
        return 'Bread';
      case RecipeCategory.cake:
        return 'Cake';
      case RecipeCategory.cookie:
        return 'Cookie';
      case RecipeCategory.dessert:
        return 'Dessert';
    }
  }
}

/// 기본 레시피 정보
@HiveType(typeId: 3)
@JsonSerializable()
class Recipe {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final List<Ingredient> ingredients;
  @HiveField(2)
  final List<String> processes;
  @HiveField(3)
  final RecipeCategory category;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;
  @HiveField(7)
  final List<Map<String, dynamic>>? mixingSteps;
  @HiveField(8)
  final List<Map<String, dynamic>>? fermentationSteps;
  @HiveField(9)
  final List<Map<String, dynamic>>? ovenSteps;

  const Recipe({
    required this.title,
    required this.ingredients,
    required this.processes,
    required this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.mixingSteps,
    this.fermentationSteps,
    this.ovenSteps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  Recipe copyWith({
    String? title,
    List<Ingredient>? ingredients,
    List<String>? processes,
    RecipeCategory? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? mixingSteps,
    List<Map<String, dynamic>>? fermentationSteps,
    List<Map<String, dynamic>>? ovenSteps,
  }) {
    return Recipe(
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      processes: processes ?? this.processes,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mixingSteps: mixingSteps ?? this.mixingSteps,
      fermentationSteps: fermentationSteps ?? this.fermentationSteps,
      ovenSteps: ovenSteps ?? this.ovenSteps,
    );
  }

  /// 재료 비율 계산을 위한 밀가루 양 반환
  double get flourAmount {
    final flour = ingredients.firstWhere(
      (ingredient) => ingredient.isFlour,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return flour.amount;
  }

  /// 하이드레이션 계산: (물의 양 ÷ 밀가루 양) × 100
  double get hydrationPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final water = ingredients.firstWhere(
      (ingredient) => ingredient.isWater,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (water.amount / flourAmt) * 100;
  }

  /// 소금 비율 계산: (소금 양 ÷ 밀가루 양) × 100
  double get saltPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final salt = ingredients.firstWhere(
      (ingredient) => ingredient.isSalt,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (salt.amount / flourAmt) * 100;
  }

  /// 이스트 비율 계산: (이스트 양 ÷ 밀가루 양) × 100
  double get yeastPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final yeast = ingredients.firstWhere(
      (ingredient) => ingredient.isYeast,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (yeast.amount / flourAmt) * 100;
  }
}
