/// 파싱된 레시피 데이터 타입들
/// 중앙 집중화된 파싱 시스템을 위한 데이터 모델들

/// 파싱된 개별 재료 정보
class ParsedIngredient {
  final String name;
  final String originalName;
  final double amount;
  final String unit;
  final double weightInGrams;
  final bool isFlour;
  final bool isWater;
  final bool isMilk;

  const ParsedIngredient({
    required this.name,
    required this.originalName,
    required this.amount,
    required this.unit,
    required this.weightInGrams,
    required this.isFlour,
    required this.isWater,
    required this.isMilk,
  });

  @override
  String toString() {
    return 'ParsedIngredient(name: $name, amount: $amount$unit, weight: ${weightInGrams}g)';
  }
}

/// 파싱된 레시피 메타데이터
class RecipeMetadata {
  final String? name;
  final String? description;
  final int totalIngredients;
  final DateTime parsedAt;
  final String parserVersion;

  const RecipeMetadata({
    this.name,
    this.description,
    required this.totalIngredients,
    required this.parsedAt,
    required this.parserVersion,
  });
}

/// 파싱된 레시피 데이터 (중앙 집중화된 데이터 모델)
class ParsedRecipeData {
  final List<ParsedIngredient> ingredients;
  final RecipeMetadata metadata;

  // 계산된 속성들 (캐싱)
  final double _totalWeight;
  final double _totalFlourWeight;
  final double _totalWaterWeight;
  final double _totalMilkWeight;
  final Map<String, double> _flourTypes;

  ParsedRecipeData._({
    required this.ingredients,
    required this.metadata,
    required double totalWeight,
    required double totalFlourWeight,
    required double totalWaterWeight,
    required double totalMilkWeight,
    required Map<String, double> flourTypes,
  })  : _totalWeight = totalWeight,
        _totalFlourWeight = totalFlourWeight,
        _totalWaterWeight = totalWaterWeight,
        _totalMilkWeight = totalMilkWeight,
        _flourTypes = flourTypes;

  /// 팩토리 생성자 - 파싱된 데이터를 기반으로 계산된 속성들을 초기화
  factory ParsedRecipeData.create({
    required List<ParsedIngredient> ingredients,
    required RecipeMetadata metadata,
  }) {
    // 총 무게 계산
    final totalWeight = ingredients.fold<double>(
      0.0,
      (sum, ingredient) => sum + ingredient.weightInGrams,
    );

    // 밀가루 타입별 무게 계산
    final flourTypes = <String, double>{};
    double totalFlourWeight = 0.0;
    double totalWaterWeight = 0.0;
    double totalMilkWeight = 0.0;

    for (final ingredient in ingredients) {
      if (ingredient.isFlour) {
        final flourType = _analyzeFlourType(ingredient.name);
        flourTypes[flourType] =
            (flourTypes[flourType] ?? 0.0) + ingredient.weightInGrams;
        totalFlourWeight += ingredient.weightInGrams;
      } else if (ingredient.isWater) {
        totalWaterWeight += ingredient.weightInGrams;
      } else if (ingredient.isMilk) {
        totalMilkWeight += ingredient.weightInGrams;
      }
    }

    return ParsedRecipeData._(
      ingredients: ingredients,
      metadata: metadata,
      totalWeight: totalWeight,
      totalFlourWeight: totalFlourWeight,
      totalWaterWeight: totalWaterWeight,
      totalMilkWeight: totalMilkWeight,
      flourTypes: flourTypes,
    );
  }

  /// 총 재료 무게
  double get totalWeight => _totalWeight;

  /// 총 밀가루 무게
  double get totalFlourWeight => _totalFlourWeight;

  /// 총 물 무게
  double get totalWaterWeight => _totalWaterWeight;

  /// 총 우유 무게
  double get totalMilkWeight => _totalMilkWeight;

  /// 밀가루 타입별 분포
  Map<String, double> get flourTypes => _flourTypes;

  /// 수분 함량 계산 (hydration level)
  double get hydrationLevel {
    if (_totalFlourWeight <= 0) return 0.0;
    return ((_totalWaterWeight + _totalMilkWeight * 0.87) / _totalFlourWeight) *
        100;
  }

  /// 주 밀가루 타입
  String get primaryFlourType {
    if (_flourTypes.isEmpty) return 'unknown';
    return _flourTypes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 특정 재료 찾기
  ParsedIngredient? findIngredient(String name) {
    return ingredients.firstWhere(
      (ingredient) =>
          ingredient.name.toLowerCase().contains(name.toLowerCase()),
    );
  }

  /// 특정 타입의 재료들 필터링
  List<ParsedIngredient> getIngredientsByType(
      bool Function(ParsedIngredient) predicate) {
    return ingredients.where(predicate).toList();
  }

  @override
  String toString() {
    return 'ParsedRecipeData('
        'ingredients: ${ingredients.length}, '
        'totalWeight: ${totalWeight.toStringAsFixed(1)}g, '
        'flourWeight: ${totalFlourWeight.toStringAsFixed(1)}g, '
        'hydration: ${hydrationLevel.toStringAsFixed(1)}%, '
        'primaryFlour: $primaryFlourType'
        ')';
  }
}

/// 밀가루 타입 분석 헬퍼 함수
String _analyzeFlourType(String ingredientName) {
  final name = ingredientName.toLowerCase();

  if (name.contains('강력분') || name.contains('bread flour')) {
    return '강력분';
  } else if (name.contains('중력분') || name.contains('all-purpose flour')) {
    return '중력분';
  } else if (name.contains('박력분') || name.contains('cake flour')) {
    return '박력분';
  } else if (name.contains('통밀가루') || name.contains('whole wheat flour')) {
    return '통밀가루';
  } else if (name.contains('호밀가루') || name.contains('rye flour')) {
    return '호밀가루';
  } else if (name.contains('밀가루') || name.contains('flour')) {
    return '중력분'; // 일반 밀가루는 중력분으로 가정
  }

  return 'unknown';
}
