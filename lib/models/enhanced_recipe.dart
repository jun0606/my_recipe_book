// lib/models/enhanced_recipe.dart
// Enhanced Recipe Model for Advanced Baking Calculations

import 'dart:convert';
import 'recipe.dart';
import 'ingredient.dart';
import 'fermentation_scenario_v2.dart';

/// 베이킹 카테고리 열거형
enum BakingCategory {
  bread('bread', '빵'),
  pastry('pastry', '페이스트리'),
  cake('cake', '케이크'),
  cookie('cookie', '쿠키'),
  pizza('pizza', '피자'),
  other('other', '기타');

  const BakingCategory(this.value, this.displayName);

  final String value;
  final String displayName;

  static BakingCategory fromString(String value) {
    return BakingCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => BakingCategory.other,
    );
  }

  @override
  String toString() => displayName;
}

/// BakingCategory를 BreadType으로 변환하는 확장 함수
extension BakingCategoryToBreadType on BakingCategory {
  BreadType toBreadType() {
    switch (this) {
      case BakingCategory.bread:
        return BreadType.white;
      case BakingCategory.pastry:
        return BreadType.enriched;
      case BakingCategory.pizza:
        return BreadType.white; // 피자는 화이트 브레드 기반
      case BakingCategory.cookie:
      case BakingCategory.cake:
        return BreadType.enriched; // 쿠키와 케이크는 리치 도우
      default:
        return BreadType.white;
    }
  }
}

/// 확장된 레시피 모델 - 고급 베이킹 계산용
class EnhancedRecipe {
  final int id;
  final String title;
  final String category;
  final BakingCategory bakingCategory;
  final List<Ingredient> ingredients;
  final List<Map<String, dynamic>> instructions;
  final String? imagePath;
  final int baseServings;
  final bool isBaking;

  // 베이킹 특화 필드들
  final double? targetSplitAmount;
  final int? targetSplitCount;
  final double? calculatedRemainingWeight;
  final double? totalIngredientWeight;
  final int? parentId;
  final List<Map<String, dynamic>>? mixingSteps;
  final List<Map<String, dynamic>>? fermentationSteps;
  final List<Map<String, dynamic>>? ovenSteps;

  // 추가 메타데이터
  final int? cookingTime;
  final int? servingSize;
  final String? difficulty;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final bool? isPublic;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;

  const EnhancedRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.bakingCategory,
    required this.ingredients,
    required this.instructions,
    this.imagePath,
    this.baseServings = 1,
    this.isBaking = false,
    this.targetSplitAmount,
    this.targetSplitCount,
    this.calculatedRemainingWeight,
    this.totalIngredientWeight,
    this.parentId,
    this.mixingSteps,
    this.fermentationSteps,
    this.ovenSteps,
    this.cookingTime,
    this.servingSize,
    this.difficulty,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.isPublic,
    this.tags,
    this.rating,
    this.reviewCount,
  });

  /// 기존 Recipe에서 EnhancedRecipe로 변환
  factory EnhancedRecipe.fromRecipe(Recipe recipe) {
    return EnhancedRecipe(
      id: recipe.id ?? DateTime.now().millisecondsSinceEpoch,
      title: recipe.title,
      category: recipe.category,
      bakingCategory: BakingCategory.fromString(recipe.category),
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imagePath: recipe.imagePath,
      baseServings: recipe.baseServings,
      isBaking: recipe.isBaking,
      targetSplitAmount: recipe.targetSplitAmount,
      targetSplitCount: recipe.targetSplitCount,
      calculatedRemainingWeight: recipe.calculatedRemainingWeight,
      totalIngredientWeight: recipe.totalIngredientWeight,
      parentId: recipe.parentId,
      mixingSteps: recipe.mixingSteps,
      fermentationSteps: recipe.fermentationSteps,
      ovenSteps: recipe.ovenSteps,
      cookingTime: recipe.cookingTime,
      servingSize: recipe.servingSize,
      difficulty: recipe.difficulty,
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      userId: recipe.userId,
      isPublic: recipe.isPublic,
      tags: recipe.tags,
      rating: recipe.rating,
      reviewCount: recipe.reviewCount,
    );
  }

  /// JSON에서 EnhancedRecipe 생성
  factory EnhancedRecipe.fromJson(Map<String, dynamic> json) {
    return EnhancedRecipe(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      title: json['title'] as String? ?? '제목 없음',
      category: json['category'] as String? ?? 'general',
      bakingCategory: BakingCategory.fromString(
          json['bakingCategory'] as String? ?? 'other'),
      ingredients: _parseIngredients(json['ingredients']),
      instructions: _parseInstructions(json['instructions']),
      imagePath: json['imagePath'] as String?,
      baseServings: json['baseServings'] as int? ?? 1,
      isBaking: json['isBaking'] as bool? ?? false,
      targetSplitAmount: json['targetSplitAmount'] as double?,
      targetSplitCount: json['targetSplitCount'] as int?,
      calculatedRemainingWeight: json['calculatedRemainingWeight'] as double?,
      totalIngredientWeight: json['totalIngredientWeight'] as double?,
      parentId: json['parentId'] as int?,
      mixingSteps: _parseSteps(json['mixingSteps']),
      fermentationSteps: _parseSteps(json['fermentationSteps']),
      ovenSteps: _parseSteps(json['ovenSteps']),
      cookingTime: json['cookingTime'] as int?,
      servingSize: json['servingSize'] as int?,
      difficulty: json['difficulty'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      userId: json['userId'] as String?,
      isPublic: json['isPublic'] as bool?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
    );
  }

  /// Ingredient 리스트 파싱 헬퍼
  static List<Ingredient> _parseIngredients(dynamic data) {
    if (data == null) return [];

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return decoded
              .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('EnhancedRecipe: Failed to parse ingredients string: $e');
      }
    } else if (data is List) {
      return data
          .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Instructions 리스트 파싱 헬퍼
  static List<Map<String, dynamic>> _parseInstructions(dynamic data) {
    if (data == null) return [];

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      } catch (e) {
        print('EnhancedRecipe: Failed to parse instructions string: $e');
      }
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  /// Steps 리스트 파싱 헬퍼
  static List<Map<String, dynamic>>? _parseSteps(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      } catch (e) {
        print('EnhancedRecipe: Failed to parse steps string: $e');
      }
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return null;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'bakingCategory': bakingCategory.value,
      'ingredients': jsonEncode(ingredients.map((i) => i.toJson()).toList()),
      'instructions': jsonEncode(instructions),
      'imagePath': imagePath,
      'baseServings': baseServings,
      'isBaking': isBaking,
      'targetSplitAmount': targetSplitAmount,
      'targetSplitCount': targetSplitCount,
      'calculatedRemainingWeight': calculatedRemainingWeight,
      'totalIngredientWeight': totalIngredientWeight,
      'parentId': parentId,
      'mixingSteps': mixingSteps != null ? jsonEncode(mixingSteps) : null,
      'fermentationSteps':
          fermentationSteps != null ? jsonEncode(fermentationSteps) : null,
      'ovenSteps': ovenSteps != null ? jsonEncode(ovenSteps) : null,
      'cookingTime': cookingTime,
      'servingSize': servingSize,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'isPublic': isPublic,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  /// Recipe로 변환 (하위 호환성)
  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      category: category,
      ingredients: ingredients,
      instructions: instructions,
      imagePath: imagePath,
      baseServings: baseServings,
      isBaking: isBaking,
      targetSplitAmount: targetSplitAmount,
      targetSplitCount: targetSplitCount,
      calculatedRemainingWeight: calculatedRemainingWeight,
      totalIngredientWeight: totalIngredientWeight,
      parentId: parentId,
      mixingSteps: mixingSteps,
      fermentationSteps: fermentationSteps,
      ovenSteps: ovenSteps,
      cookingTime: cookingTime,
      servingSize: servingSize,
      difficulty: difficulty,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      isPublic: isPublic,
      tags: tags,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  /// 복사본 생성 (필드 수정용)
  EnhancedRecipe copyWith({
    int? id,
    String? title,
    String? category,
    BakingCategory? bakingCategory,
    List<Ingredient>? ingredients,
    List<Map<String, dynamic>>? instructions,
    String? imagePath,
    int? baseServings,
    bool? isBaking,
    double? targetSplitAmount,
    int? targetSplitCount,
    double? calculatedRemainingWeight,
    double? totalIngredientWeight,
    int? parentId,
    List<Map<String, dynamic>>? mixingSteps,
    List<Map<String, dynamic>>? fermentationSteps,
    List<Map<String, dynamic>>? ovenSteps,
    int? cookingTime,
    int? servingSize,
    String? difficulty,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isPublic,
    List<String>? tags,
    double? rating,
    int? reviewCount,
  }) {
    return EnhancedRecipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      bakingCategory: bakingCategory ?? this.bakingCategory,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imagePath: imagePath ?? this.imagePath,
      baseServings: baseServings ?? this.baseServings,
      isBaking: isBaking ?? this.isBaking,
      targetSplitAmount: targetSplitAmount ?? this.targetSplitAmount,
      targetSplitCount: targetSplitCount ?? this.targetSplitCount,
      calculatedRemainingWeight:
          calculatedRemainingWeight ?? this.calculatedRemainingWeight,
      totalIngredientWeight:
          totalIngredientWeight ?? this.totalIngredientWeight,
      parentId: parentId ?? this.parentId,
      mixingSteps: mixingSteps ?? this.mixingSteps,
      fermentationSteps: fermentationSteps ?? this.fermentationSteps,
      ovenSteps: ovenSteps ?? this.ovenSteps,
      cookingTime: cookingTime ?? this.cookingTime,
      servingSize: servingSize ?? this.servingSize,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() {
    return 'EnhancedRecipe(id: $id, title: $title, category: $category, bakingCategory: $bakingCategory, ingredients: ${ingredients.length}, isBaking: $isBaking)';
  }

  /// 베이커스 퍼센트 계산 (빵 베이킹용)
  Map<String, double>? get bakersPercentages {
    if (!isBaking || ingredients.isEmpty) return null;

    // 밀가루 양을 기준으로 각 재료의 백분율 계산
    final flourIngredient = ingredients.firstWhere(
      (ing) =>
          ing.name.toLowerCase().contains('밀가루') ||
          ing.name.toLowerCase().contains('flour'),
      orElse: () => ingredients.first, // 기본적으로 첫 번째 재료를 기준으로
    );

    final flourAmount = flourIngredient.amount;
    if (flourAmount == 0) return null;

    final percentages = <String, double>{};
    for (final ingredient in ingredients) {
      final percentage = (ingredient.amount / flourAmount) * 100;
      percentages[ingredient.name] = percentage;
    }

    return percentages;
  }

  /// 수분량 레벨 계산 (%)
  double? get hydrationLevel {
    if (!isBaking || ingredients.isEmpty) return null;

    // 물/액체 재료들의 총량 계산
    double totalLiquid = 0;
    double totalFlour = 0;

    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      final unit = ingredient.unit.toLowerCase();

      // 밀가루 계열 재료들
      if (name.contains('밀가루') ||
          name.contains('flour') ||
          name.contains('통밀') ||
          name.contains('whole wheat') ||
          name.contains('호밀') ||
          name.contains('rye')) {
        // 밀가루의 경우 단위 변환 (g/kg)
        if (unit == 'kg') {
          totalFlour += ingredient.amount * 1000;
        } else {
          totalFlour += ingredient.amount;
        }
      }

      // 액체 재료들
      if (name.contains('물') ||
          name.contains('water') ||
          name.contains('우유') ||
          name.contains('milk') ||
          name.contains('크림') ||
          name.contains('cream') ||
          name.contains('요거트') ||
          name.contains('yogurt')) {
        // 액체의 경우 단위 변환 (ml/l)
        if (unit == 'l' || unit == 'liter') {
          totalLiquid += ingredient.amount * 1000;
        } else {
          totalLiquid += ingredient.amount;
        }
      }
    }

    if (totalFlour == 0) return null;
    return (totalLiquid / totalFlour) * 100;
  }

  /// 베이킹 계산을 위한 헬퍼 메소드들
  double get totalFlourWeight {
    double total = 0;
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      if (name.contains('밀가루') ||
          name.contains('flour') ||
          name.contains('통밀') ||
          name.contains('whole wheat') ||
          name.contains('호밀') ||
          name.contains('rye')) {
        total += ingredient.amount;
      }
    }
    return total;
  }

  double get totalLiquidWeight {
    double total = 0;
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      if (name.contains('물') ||
          name.contains('water') ||
          name.contains('우유') ||
          name.contains('milk') ||
          name.contains('크림') ||
          name.contains('cream') ||
          name.contains('요거트') ||
          name.contains('yogurt')) {
        total += ingredient.amount;
      }
    }
    return total;
  }

  double get totalSaltWeight {
    double total = 0;
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      if (name.contains('소금') || name.contains('salt')) {
        total += ingredient.amount;
      }
    }
    return total;
  }

  double get totalYeastWeight {
    double total = 0;
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      if (name.contains('효모') ||
          name.contains('yeast') ||
          name.contains('이스트') ||
          name.contains('starter')) {
        total += ingredient.amount;
      }
    }
    return total;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EnhancedRecipe &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.bakingCategory == bakingCategory &&
        other.ingredients.length == ingredients.length &&
        other.isBaking == isBaking;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        category.hashCode ^
        bakingCategory.hashCode ^
        ingredients.length.hashCode ^
        isBaking.hashCode;
  }
}
