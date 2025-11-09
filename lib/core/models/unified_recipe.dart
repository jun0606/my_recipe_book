// lib/core/models/unified_recipe.dart
// 통합 레시피 모델 - 타입 안전성 확보 및 데이터 일관성 보장

import 'dart:convert';

/// 재료 카테고리 열거형
enum IngredientCategory {
  flour, // 밀가루
  liquid, // 액체 (물, 우유 등)
  yeast, // 효모
  salt, // 소금
  sugar, // 설탕
  fat, // 지방 (버터, 기름 등)
  egg, // 계란
  other, // 기타
}

/// 통합 재료 모델
class UnifiedIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final IngredientCategory category;
  final Map<String, dynamic> properties;

  const UnifiedIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    this.properties = const {},
  });

  /// Map에서 생성 (기존 코드 호환)
  factory UnifiedIngredient.fromMap(Map<String, dynamic> map) {
    return UnifiedIngredient(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'g',
      category: _parseCategory(map['category'] as String?),
      properties: Map<String, dynamic>.from(map['properties'] as Map? ?? {}),
    );
  }

  /// Map으로 변환 (기존 코드 호환)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'category': category.name,
      'properties': properties,
    };
  }

  /// 그램 단위로 변환된 양
  double get amountInGrams {
    // 단위 변환 로직 (간단 버전)
    switch (unit.toLowerCase()) {
      case 'kg':
        return amount * 1000;
      case 'ml':
        // 밀도 고려 (간단하게 1g/ml 가정)
        return amount;
      case 'cup':
        return amount * 240; // 1컵 = 240ml ≈ 240g
      case 'tbsp':
        return amount * 15; // 1큰술 = 15ml ≈ 15g
      case 'tsp':
        return amount * 5; // 1작은술 = 5ml ≈ 5g
      default:
        return amount; // g는 그대로
    }
  }

  static IngredientCategory _parseCategory(String? category) {
    if (category == null) return IngredientCategory.other;

    switch (category.toLowerCase()) {
      case 'flour':
        return IngredientCategory.flour;
      case 'liquid':
        return IngredientCategory.liquid;
      case 'yeast':
        return IngredientCategory.yeast;
      case 'salt':
        return IngredientCategory.salt;
      case 'sugar':
        return IngredientCategory.sugar;
      case 'fat':
        return IngredientCategory.fat;
      case 'egg':
        return IngredientCategory.egg;
      default:
        return IngredientCategory.other;
    }
  }
}

/// 공정 타입 열거형
enum ProcessType {
  mixing, // 믹싱
  fermentation, // 발효
  baking, // 굽기
  shaping, // 성형
  other, // 기타
}

/// 통합 공정 모델
class UnifiedProcess {
  final String id;
  final ProcessType type;
  final String name;
  final Duration duration;
  final Map<String, dynamic> parameters;
  final int order;

  const UnifiedProcess({
    required this.id,
    required this.type,
    required this.name,
    required this.duration,
    required this.parameters,
    required this.order,
  });

  /// Map에서 생성 (기존 코드 호환)
  factory UnifiedProcess.fromMap(Map<String, dynamic> map) {
    return UnifiedProcess(
      id: map['id'] as String? ?? '',
      type: _parseProcessType(map['type'] as String?),
      name: map['name'] as String? ?? '',
      duration: _parseDuration(map['duration']),
      parameters: Map<String, dynamic>.from(map['parameters'] as Map? ?? {}),
      order: map['order'] as int? ?? 0,
    );
  }

  /// Map으로 변환 (기존 코드 호환)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'duration': duration.inMinutes,
      'parameters': parameters,
      'order': order,
    };
  }

  static ProcessType _parseProcessType(String? type) {
    if (type == null) return ProcessType.other;

    switch (type.toLowerCase()) {
      case 'mixing':
        return ProcessType.mixing;
      case 'fermentation':
        return ProcessType.fermentation;
      case 'baking':
        return ProcessType.baking;
      case 'shaping':
        return ProcessType.shaping;
      default:
        return ProcessType.other;
    }
  }

  static Duration _parseDuration(dynamic duration) {
    if (duration is int) {
      return Duration(minutes: duration);
    } else if (duration is String) {
      final minutes = int.tryParse(duration.replaceAll('분', ''));
      return Duration(minutes: minutes ?? 0);
    }
    return Duration.zero;
  }
}

/// 레시피 메타데이터
class RecipeMetadata {
  final String source;
  final String version;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> additionalInfo;

  const RecipeMetadata({
    required this.source,
    required this.version,
    required this.createdAt,
    this.updatedAt,
    this.additionalInfo = const {},
  });

  factory RecipeMetadata.fromMap(Map<String, dynamic> map) {
    return RecipeMetadata(
      source: map['source'] as String? ?? 'unknown',
      version: map['version'] as String? ?? '1.0',
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      additionalInfo:
          Map<String, dynamic>.from(map['additionalInfo'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }
}

/// 통합 레시피 모델 - 메인 모델
class UnifiedRecipe {
  final String id;
  final String title;
  final List<UnifiedIngredient> ingredients;
  final List<UnifiedProcess> processes;
  final RecipeMetadata metadata;

  const UnifiedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.processes,
    required this.metadata,
  });

  /// Map에서 생성 (기존 코드 호환)
  factory UnifiedRecipe.fromMap(Map<String, dynamic> map) {
    return UnifiedRecipe(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => UnifiedIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      processes: (map['processes'] as List<dynamic>? ?? [])
          .map((e) => UnifiedProcess.fromMap(e as Map<String, dynamic>))
          .toList(),
      metadata: RecipeMetadata.fromMap(
          map['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Map으로 변환 (기존 코드 호환)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'processes': processes.map((e) => e.toMap()).toList(),
      'metadata': metadata.toMap(),
    };
  }

  /// 재료별 카테고리 그룹핑
  Map<IngredientCategory, List<UnifiedIngredient>> get ingredientsByCategory {
    final grouped = <IngredientCategory, List<UnifiedIngredient>>{};
    for (final ingredient in ingredients) {
      grouped.putIfAbsent(ingredient.category, () => []).add(ingredient);
    }
    return grouped;
  }

  /// 공정별 그룹핑
  Map<ProcessType, List<UnifiedProcess>> get processesByType {
    final grouped = <ProcessType, List<UnifiedProcess>>{};
    for (final process in processes) {
      grouped.putIfAbsent(process.type, () => []).add(process);
    }
    return grouped;
  }

  /// 총 재료 무게 계산
  double get totalIngredientWeightGrams {
    return ingredients.fold(0.0, (sum, ing) => sum + ing.amountInGrams);
  }

  /// 총 공정 시간 계산
  Duration get totalProcessTime {
    return processes.fold(Duration.zero, (sum, proc) => sum + proc.duration);
  }

  /// 유효성 검증
  bool get isValid {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        ingredients.isNotEmpty &&
        processes.isNotEmpty;
  }

  /// JSON 직렬화 지원
  String toJson() => jsonEncode(toMap());

  /// JSON 역직렬화 지원
  factory UnifiedRecipe.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UnifiedRecipe.fromMap(map);
  }
}
