// 레시피 최적화 히스토리 모델
// 사용자의 수쉐프 모드 사용 기록을 저장하고 관리합니다.

library recipe_history;

class RecipeHistory {
  final String id;
  final String recipeTitle;
  final String recipeCategory;
  final DateTime timestamp;
  final RecipeHistoryType type;
  final Map<String, dynamic> originalIngredients;
  final Map<String, dynamic> optimizedIngredients;
  final Map<String, dynamic> environmentalConditions;
  final ProductStatusHistory beforeStatus;
  final ProductStatusHistory afterStatus;
  final double improvementScore;
  final List<String> optimizationNotes;
  final Map<String, dynamic> metadata;

  const RecipeHistory({
    required this.id,
    required this.recipeTitle,
    required this.recipeCategory,
    required this.timestamp,
    required this.type,
    required this.originalIngredients,
    required this.optimizedIngredients,
    required this.environmentalConditions,
    required this.beforeStatus,
    required this.afterStatus,
    required this.improvementScore,
    required this.optimizationNotes,
    required this.metadata,
  });

  factory RecipeHistory.fromJson(Map<String, dynamic> json) {
    return RecipeHistory(
      id: json['id'] as String,
      recipeTitle: json['recipeTitle'] as String,
      recipeCategory: json['recipeCategory'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: RecipeHistoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RecipeHistoryType.optimization,
      ),
      originalIngredients:
          Map<String, dynamic>.from(json['originalIngredients'] as Map),
      optimizedIngredients:
          Map<String, dynamic>.from(json['optimizedIngredients'] as Map),
      environmentalConditions:
          Map<String, dynamic>.from(json['environmentalConditions'] as Map),
      beforeStatus: ProductStatusHistory.fromJson(
          json['beforeStatus'] as Map<String, dynamic>),
      afterStatus: ProductStatusHistory.fromJson(
          json['afterStatus'] as Map<String, dynamic>),
      improvementScore: (json['improvementScore'] as num).toDouble(),
      optimizationNotes: List<String>.from(json['optimizationNotes'] as List),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeTitle': recipeTitle,
      'recipeCategory': recipeCategory,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'originalIngredients': originalIngredients,
      'optimizedIngredients': optimizedIngredients,
      'environmentalConditions': environmentalConditions,
      'beforeStatus': beforeStatus.toJson(),
      'afterStatus': afterStatus.toJson(),
      'improvementScore': improvementScore,
      'optimizationNotes': optimizationNotes,
      'metadata': metadata,
    };
  }

  /// 히스토리 생성 팩토리
  factory RecipeHistory.create({
    required String recipeTitle,
    required String recipeCategory,
    required RecipeHistoryType type,
    required Map<String, dynamic> originalIngredients,
    required Map<String, dynamic> optimizedIngredients,
    required Map<String, dynamic> environmentalConditions,
    required ProductStatusHistory beforeStatus,
    required ProductStatusHistory afterStatus,
    required List<String> optimizationNotes,
    Map<String, dynamic>? metadata,
  }) {
    final improvementScore =
        _calculateImprovementScore(beforeStatus, afterStatus);

    return RecipeHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipeTitle: recipeTitle,
      recipeCategory: recipeCategory,
      timestamp: DateTime.now(),
      type: type,
      originalIngredients: originalIngredients,
      optimizedIngredients: optimizedIngredients,
      environmentalConditions: environmentalConditions,
      beforeStatus: beforeStatus,
      afterStatus: afterStatus,
      improvementScore: improvementScore,
      optimizationNotes: optimizationNotes,
      metadata: metadata ?? {},
    );
  }

  /// 개선 점수 계산
  static double _calculateImprovementScore(
    ProductStatusHistory before,
    ProductStatusHistory after,
  ) {
    // 각 영역별 개선도 계산
    final textureImprovement = after.textureScore - before.textureScore;
    final flavorImprovement = after.flavorScore - before.flavorScore;
    final appearanceImprovement =
        after.appearanceScore - before.appearanceScore;

    // 가중 평균으로 전체 개선도 계산
    final weightedScore = (textureImprovement * 0.4) +
        (flavorImprovement * 0.3) +
        (appearanceImprovement * 0.3);

    // 0.0 ~ 1.0 범위로 정규화
    return weightedScore.clamp(0.0, 1.0);
  }

  /// 성공적인 최적화인지 확인
  bool get isSuccessfulOptimization => improvementScore > 0.05;

  /// 주요 개선 영역
  List<String> get mainImprovements {
    final improvements = <String>[];

    if (afterStatus.textureScore > beforeStatus.textureScore + 0.05) {
      improvements.add('식감');
    }
    if (afterStatus.flavorScore > beforeStatus.flavorScore + 0.05) {
      improvements.add('풍미');
    }
    if (afterStatus.appearanceScore > beforeStatus.appearanceScore + 0.05) {
      improvements.add('외관');
    }

    return improvements;
  }

  /// 사용된 환경 조건 요약
  String get environmentSummary {
    final temp = environmentalConditions['temperature'] ?? 26;
    final humidity = environmentalConditions['humidity'] ?? 60;
    final altitude = environmentalConditions['altitude'] ?? 0;

    return '${temp}°C, $humidity%, ${altitude}m';
  }
}

class ProductStatusHistory {
  final String textureProfile;
  final List<String> flavorProfile;
  final String appearanceProfile;
  final double textureScore;
  final double flavorScore;
  final double appearanceScore;
  final double confidenceLevel;

  const ProductStatusHistory({
    required this.textureProfile,
    required this.flavorProfile,
    required this.appearanceProfile,
    required this.textureScore,
    required this.flavorScore,
    required this.appearanceScore,
    required this.confidenceLevel,
  });

  factory ProductStatusHistory.fromJson(Map<String, dynamic> json) {
    return ProductStatusHistory(
      textureProfile: json['textureProfile'] as String,
      flavorProfile: List<String>.from(json['flavorProfile'] as List),
      appearanceProfile: json['appearanceProfile'] as String,
      textureScore: (json['textureScore'] as num).toDouble(),
      flavorScore: (json['flavorScore'] as num).toDouble(),
      appearanceScore: (json['appearanceScore'] as num).toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textureProfile': textureProfile,
      'flavorProfile': flavorProfile,
      'appearanceProfile': appearanceProfile,
      'textureScore': textureScore,
      'flavorScore': flavorScore,
      'appearanceScore': appearanceScore,
      'confidenceLevel': confidenceLevel,
    };
  }

  /// ProductStatus에서 변환
  factory ProductStatusHistory.fromProductStatus(dynamic productStatus) {
    return ProductStatusHistory(
      textureProfile: productStatus.textureProfile?.primary ?? '',
      flavorProfile: productStatus.flavorProfile?.primary ?? [],
      appearanceProfile: productStatus.appearanceProfile?.crustColor ?? '',
      textureScore:
          _calculateTextureScore(productStatus.textureProfile?.primary ?? ''),
      flavorScore:
          _calculateFlavorScore(productStatus.flavorProfile?.primary ?? []),
      appearanceScore: _calculateAppearanceScore(
          productStatus.appearanceProfile?.crustColor ?? ''),
      confidenceLevel: productStatus.confidenceLevel ?? 0.8,
    );
  }

  static double _calculateTextureScore(String texture) {
    switch (texture.toLowerCase()) {
      case '촉촉하고 부드러움':
      case '쫄깃하고 탄력있음':
        return 0.9;
      case '촉촉함':
      case '부드러움':
      case '쫄깃함':
        return 0.8;
      case '적당함':
        return 0.7;
      case '건조함':
      case '딱딱함':
        return 0.5;
      default:
        return 0.6;
    }
  }

  static double _calculateFlavorScore(List<String> flavors) {
    if (flavors.isEmpty) return 0.6;

    double score = 0.0;
    for (final flavor in flavors) {
      switch (flavor.toLowerCase()) {
        case '깊은 발효향':
        case '고소하고 달콤함':
          score += 0.9;
          break;
        case '고소함':
        case '달콤함':
        case '담백함':
          score += 0.8;
          break;
        case '적당함':
          score += 0.7;
          break;
        default:
          score += 0.6;
      }
    }

    return score / flavors.length;
  }

  static double _calculateAppearanceScore(String appearance) {
    switch (appearance.toLowerCase()) {
      case '균일한 갈색':
      case '진한 갈색':
        return 0.9;
      case '갈색':
      case '연한 갈색':
        return 0.8;
      case '적당함':
        return 0.7;
      case '너무 밝음':
      case '너무 어두움':
        return 0.5;
      default:
        return 0.6;
    }
  }
}

enum RecipeHistoryType {
  optimization,
  reverseRecipe,
  presetGeneration,
  targetBased;

  String get displayName {
    switch (this) {
      case RecipeHistoryType.optimization:
        return '최적화';
      case RecipeHistoryType.reverseRecipe:
        return '역산 레시피';
      case RecipeHistoryType.presetGeneration:
        return '프리셋 생성';
      case RecipeHistoryType.targetBased:
        return '목표 기반';
    }
  }

  String get description {
    switch (this) {
      case RecipeHistoryType.optimization:
        return '기존 레시피를 환경 조건에 맞게 최적화';
      case RecipeHistoryType.reverseRecipe:
        return '원하는 특성으로부터 레시피 역산 생성';
      case RecipeHistoryType.presetGeneration:
        return '프리셋을 기반으로 레시피 생성';
      case RecipeHistoryType.targetBased:
        return '목표 특성을 설정하여 레시피 생성';
    }
  }
}

/// 히스토리 필터링 옵션
class RecipeHistoryFilter {
  final RecipeHistoryType? type;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minImprovementScore;
  final bool? successfulOnly;

  const RecipeHistoryFilter({
    this.type,
    this.category,
    this.startDate,
    this.endDate,
    this.minImprovementScore,
    this.successfulOnly,
  });

  bool matches(RecipeHistory history) {
    if (type != null && history.type != type) return false;
    if (category != null && history.recipeCategory != category) return false;
    if (startDate != null && history.timestamp.isBefore(startDate!))
      return false;
    if (endDate != null && history.timestamp.isAfter(endDate!)) return false;
    if (minImprovementScore != null &&
        history.improvementScore < minImprovementScore!) return false;
    if (successfulOnly == true && !history.isSuccessfulOptimization)
      return false;

    return true;
  }
}

/// 히스토리 통계
class RecipeHistoryStats {
  final int totalOptimizations;
  final int successfulOptimizations;
  final double averageImprovementScore;
  final Map<String, int> categoryDistribution;
  final Map<RecipeHistoryType, int> typeDistribution;
  final List<String> topImprovements;
  final Map<String, double> environmentalPreferences;

  const RecipeHistoryStats({
    required this.totalOptimizations,
    required this.successfulOptimizations,
    required this.averageImprovementScore,
    required this.categoryDistribution,
    required this.typeDistribution,
    required this.topImprovements,
    required this.environmentalPreferences,
  });

  double get successRate => totalOptimizations > 0
      ? successfulOptimizations / totalOptimizations
      : 0.0;

  factory RecipeHistoryStats.fromHistories(List<RecipeHistory> histories) {
    if (histories.isEmpty) {
      return const RecipeHistoryStats(
        totalOptimizations: 0,
        successfulOptimizations: 0,
        averageImprovementScore: 0.0,
        categoryDistribution: {},
        typeDistribution: {},
        topImprovements: [],
        environmentalPreferences: {},
      );
    }

    final successful =
        histories.where((h) => h.isSuccessfulOptimization).length;
    final avgScore =
        histories.map((h) => h.improvementScore).reduce((a, b) => a + b) /
            histories.length;

    final categoryDist = <String, int>{};
    final typeDist = <RecipeHistoryType, int>{};
    final improvements = <String>[];
    final tempSum = <double>[];
    final humiditySum = <double>[];
    final altitudeSum = <double>[];

    for (final history in histories) {
      // 카테고리 분포
      categoryDist[history.recipeCategory] =
          (categoryDist[history.recipeCategory] ?? 0) + 1;

      // 타입 분포
      typeDist[history.type] = (typeDist[history.type] ?? 0) + 1;

      // 개선 영역
      improvements.addAll(history.mainImprovements);

      // 환경 조건
      tempSum.add(
          history.environmentalConditions['temperature']?.toDouble() ?? 26.0);
      humiditySum
          .add(history.environmentalConditions['humidity']?.toDouble() ?? 60.0);
      altitudeSum
          .add(history.environmentalConditions['altitude']?.toDouble() ?? 0.0);
    }

    // 상위 개선 영역
    final improvementCounts = <String, int>{};
    for (final improvement in improvements) {
      improvementCounts[improvement] =
          (improvementCounts[improvement] ?? 0) + 1;
    }
    final sortedImprovements = improvementCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topImprovements =
        sortedImprovements.take(3).map((e) => e.key).toList();

    // 환경 선호도
    final envPrefs = <String, double>{
      'temperature': tempSum.isNotEmpty
          ? tempSum.reduce((a, b) => a + b) / tempSum.length
          : 26.0,
      'humidity': humiditySum.isNotEmpty
          ? humiditySum.reduce((a, b) => a + b) / humiditySum.length
          : 60.0,
      'altitude': altitudeSum.isNotEmpty
          ? altitudeSum.reduce((a, b) => a + b) / altitudeSum.length
          : 0.0,
    };

    return RecipeHistoryStats(
      totalOptimizations: histories.length,
      successfulOptimizations: successful,
      averageImprovementScore: avgScore,
      categoryDistribution: categoryDist,
      typeDistribution: typeDist,
      topImprovements: topImprovements,
      environmentalPreferences: envPrefs,
    );
  }
}
