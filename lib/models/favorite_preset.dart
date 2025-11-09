// 즐겨찾기 프리셋 모델
// 사용자가 자주 사용하는 프리셋과 개인 맞춤형 프리셋을 관리합니다.

library favorite_preset;

import 'package:flutter/material.dart';

class FavoritePreset {
  final String id;
  final String name;
  final String description;
  final String category;
  final FavoritePresetType type;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final int usageCount;
  final Map<String, dynamic> presetData;
  final Map<String, dynamic> environmentalConditions;
  final List<String> tags;
  final double successRate;
  final double averageImprovementScore;
  final bool isCustom;
  final String? originalPresetId;
  final Map<String, dynamic> customizations;

  const FavoritePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.createdAt,
    required this.lastUsedAt,
    required this.usageCount,
    required this.presetData,
    required this.environmentalConditions,
    required this.tags,
    required this.successRate,
    required this.averageImprovementScore,
    required this.isCustom,
    this.originalPresetId,
    required this.customizations,
  });

  factory FavoritePreset.fromJson(Map<String, dynamic> json) {
    return FavoritePreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: FavoritePresetType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FavoritePresetType.standard,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      usageCount: json['usageCount'] as int,
      presetData: Map<String, dynamic>.from(json['presetData'] as Map),
      environmentalConditions:
          Map<String, dynamic>.from(json['environmentalConditions'] as Map),
      tags: List<String>.from(json['tags'] as List),
      successRate: (json['successRate'] as num).toDouble(),
      averageImprovementScore:
          (json['averageImprovementScore'] as num).toDouble(),
      isCustom: json['isCustom'] as bool,
      originalPresetId: json['originalPresetId'] as String?,
      customizations:
          Map<String, dynamic>.from(json['customizations'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'usageCount': usageCount,
      'presetData': presetData,
      'environmentalConditions': environmentalConditions,
      'tags': tags,
      'successRate': successRate,
      'averageImprovementScore': averageImprovementScore,
      'isCustom': isCustom,
      'originalPresetId': originalPresetId,
      'customizations': customizations,
    };
  }

  /// 표준 프리셋에서 즐겨찾기 생성
  factory FavoritePreset.fromStandardPreset(
    dynamic standardPreset, {
    Map<String, dynamic>? environmentalConditions,
    Map<String, dynamic>? customizations,
  }) {
    return FavoritePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: standardPreset.name,
      description: standardPreset.description,
      category: standardPreset.category,
      type: FavoritePresetType.standard,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      usageCount: 1,
      presetData: {
        'originalId': standardPreset.id,
        'difficulty': standardPreset.difficulty.toString(),
        'estimatedTime': standardPreset.estimatedTime,
        'keyFeatures': standardPreset.keyFeatures,
        'tags': standardPreset.tags,
      },
      environmentalConditions: environmentalConditions ?? {},
      tags: List<String>.from(standardPreset.tags),
      successRate: 0.0,
      averageImprovementScore: 0.0,
      isCustom: false,
      originalPresetId: standardPreset.id,
      customizations: customizations ?? {},
    );
  }

  /// 커스텀 프리셋 생성
  factory FavoritePreset.createCustom({
    required String name,
    required String description,
    required String category,
    required Map<String, dynamic> presetData,
    required Map<String, dynamic> environmentalConditions,
    List<String>? tags,
    Map<String, dynamic>? customizations,
  }) {
    return FavoritePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      type: FavoritePresetType.custom,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      usageCount: 1,
      presetData: presetData,
      environmentalConditions: environmentalConditions,
      tags: tags ?? [],
      successRate: 0.0,
      averageImprovementScore: 0.0,
      isCustom: true,
      originalPresetId: null,
      customizations: customizations ?? {},
    );
  }

  /// 사용 기록 업데이트
  FavoritePreset updateUsage({
    double? newSuccessRate,
    double? newImprovementScore,
  }) {
    final now = DateTime.now();
    final newUsageCount = usageCount + 1;

    // 성공률과 개선 점수의 이동 평균 계산
    final newAvgSuccessRate = newSuccessRate != null
        ? (successRate * (newUsageCount - 1) + newSuccessRate) / newUsageCount
        : successRate;

    final newAvgImprovementScore = newImprovementScore != null
        ? (averageImprovementScore * (newUsageCount - 1) +
                newImprovementScore) /
            newUsageCount
        : averageImprovementScore;

    return FavoritePreset(
      id: id,
      name: name,
      description: description,
      category: category,
      type: type,
      createdAt: createdAt,
      lastUsedAt: now,
      usageCount: newUsageCount,
      presetData: presetData,
      environmentalConditions: environmentalConditions,
      tags: tags,
      successRate: newAvgSuccessRate,
      averageImprovementScore: newAvgImprovementScore,
      isCustom: isCustom,
      originalPresetId: originalPresetId,
      customizations: customizations,
    );
  }

  /// 프리셋 수정
  FavoritePreset copyWith({
    String? name,
    String? description,
    String? category,
    Map<String, dynamic>? presetData,
    Map<String, dynamic>? environmentalConditions,
    List<String>? tags,
    Map<String, dynamic>? customizations,
  }) {
    return FavoritePreset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
      usageCount: usageCount,
      presetData: presetData ?? this.presetData,
      environmentalConditions:
          environmentalConditions ?? this.environmentalConditions,
      tags: tags ?? this.tags,
      successRate: successRate,
      averageImprovementScore: averageImprovementScore,
      isCustom: isCustom,
      originalPresetId: originalPresetId,
      customizations: customizations ?? this.customizations,
    );
  }

  /// 인기도 점수 계산
  double get popularityScore {
    final usageWeight = usageCount * 0.3;
    final successWeight = successRate * 0.4;
    final improvementWeight = averageImprovementScore * 0.3;

    return usageWeight + successWeight + improvementWeight;
  }

  /// 최근 사용 여부
  bool get isRecentlyUsed {
    final daysSinceLastUse = DateTime.now().difference(lastUsedAt).inDays;
    return daysSinceLastUse <= 7;
  }

  /// 자주 사용하는 프리셋 여부
  bool get isFrequentlyUsed {
    return usageCount >= 3;
  }

  /// 성공적인 프리셋 여부
  bool get isSuccessful {
    return successRate >= 0.7 && usageCount >= 2;
  }

  /// 환경 조건 요약
  String get environmentSummary {
    if (environmentalConditions.isEmpty) return '기본 환경';

    final temp = environmentalConditions['temperature'] ?? 26;
    final humidity = environmentalConditions['humidity'] ?? 60;
    final altitude = environmentalConditions['altitude'] ?? 0;

    return '$temp°C, $humidity%, ${altitude}m';
  }

  /// 프리셋 품질 등급
  PresetQuality get quality {
    if (usageCount < 2) return PresetQuality.untested;
    if (successRate >= 0.8 && averageImprovementScore >= 0.3)
      return PresetQuality.excellent;
    if (successRate >= 0.6 && averageImprovementScore >= 0.2)
      return PresetQuality.good;
    if (successRate >= 0.4) return PresetQuality.fair;
    return PresetQuality.poor;
  }
}

enum FavoritePresetType {
  standard, // 표준 프리셋 기반
  custom, // 완전 커스텀
  hybrid; // 표준 + 커스터마이징

  String get displayName {
    switch (this) {
      case FavoritePresetType.standard:
        return '표준';
      case FavoritePresetType.custom:
        return '커스텀';
      case FavoritePresetType.hybrid:
        return '하이브리드';
    }
  }

  String get description {
    switch (this) {
      case FavoritePresetType.standard:
        return '기본 프리셋을 즐겨찾기에 추가';
      case FavoritePresetType.custom:
        return '완전히 새로운 맞춤형 프리셋';
      case FavoritePresetType.hybrid:
        return '기본 프리셋을 개인화한 프리셋';
    }
  }
}

enum PresetQuality {
  untested,
  poor,
  fair,
  good,
  excellent;

  String get displayName {
    switch (this) {
      case PresetQuality.untested:
        return '미검증';
      case PresetQuality.poor:
        return '개선 필요';
      case PresetQuality.fair:
        return '보통';
      case PresetQuality.good:
        return '좋음';
      case PresetQuality.excellent:
        return '우수';
    }
  }

  String get description {
    switch (this) {
      case PresetQuality.untested:
        return '아직 충분히 사용되지 않음';
      case PresetQuality.poor:
        return '성공률이 낮아 개선이 필요함';
      case PresetQuality.fair:
        return '평균적인 성과를 보임';
      case PresetQuality.good:
        return '좋은 성과를 보임';
      case PresetQuality.excellent:
        return '매우 우수한 성과를 보임';
    }
  }

  Color get color {
    switch (this) {
      case PresetQuality.untested:
        return const Color(0xFF9E9E9E);
      case PresetQuality.poor:
        return const Color(0xFFF44336);
      case PresetQuality.fair:
        return const Color(0xFFFF9800);
      case PresetQuality.good:
        return const Color(0xFF4CAF50);
      case PresetQuality.excellent:
        return const Color(0xFF2196F3);
    }
  }
}

/// 즐겨찾기 프리셋 필터
class FavoritePresetFilter {
  final FavoritePresetType? type;
  final String? category;
  final PresetQuality? quality;
  final bool? recentlyUsed;
  final bool? frequentlyUsed;
  final bool? successful;
  final List<String>? tags;

  const FavoritePresetFilter({
    this.type,
    this.category,
    this.quality,
    this.recentlyUsed,
    this.frequentlyUsed,
    this.successful,
    this.tags,
  });

  bool matches(FavoritePreset preset) {
    if (type != null && preset.type != type) return false;
    if (category != null && preset.category != category) return false;
    if (quality != null && preset.quality != quality) return false;
    if (recentlyUsed == true && !preset.isRecentlyUsed) return false;
    if (frequentlyUsed == true && !preset.isFrequentlyUsed) return false;
    if (successful == true && !preset.isSuccessful) return false;
    if (tags != null && tags!.isNotEmpty) {
      final hasMatchingTag = tags!.any((tag) => preset.tags.contains(tag));
      if (!hasMatchingTag) return false;
    }

    return true;
  }
}

/// 즐겨찾기 프리셋 정렬 옵션
enum FavoritePresetSortOption {
  popularity,
  recentlyUsed,
  successRate,
  improvementScore,
  usageCount,
  name;

  String get displayName {
    switch (this) {
      case FavoritePresetSortOption.popularity:
        return '인기도';
      case FavoritePresetSortOption.recentlyUsed:
        return '최근 사용';
      case FavoritePresetSortOption.successRate:
        return '성공률';
      case FavoritePresetSortOption.improvementScore:
        return '개선도';
      case FavoritePresetSortOption.usageCount:
        return '사용 횟수';
      case FavoritePresetSortOption.name:
        return '이름';
    }
  }
}

/// 즐겨찾기 프리셋 통계
class FavoritePresetStats {
  final int totalPresets;
  final int customPresets;
  final int standardPresets;
  final double averageSuccessRate;
  final double averageImprovementScore;
  final Map<String, int> categoryDistribution;
  final Map<PresetQuality, int> qualityDistribution;
  final List<FavoritePreset> topPerformers;
  final List<FavoritePreset> mostUsed;
  final List<FavoritePreset> recentlyAdded;

  const FavoritePresetStats({
    required this.totalPresets,
    required this.customPresets,
    required this.standardPresets,
    required this.averageSuccessRate,
    required this.averageImprovementScore,
    required this.categoryDistribution,
    required this.qualityDistribution,
    required this.topPerformers,
    required this.mostUsed,
    required this.recentlyAdded,
  });

  factory FavoritePresetStats.fromPresets(List<FavoritePreset> presets) {
    if (presets.isEmpty) {
      return const FavoritePresetStats(
        totalPresets: 0,
        customPresets: 0,
        standardPresets: 0,
        averageSuccessRate: 0.0,
        averageImprovementScore: 0.0,
        categoryDistribution: {},
        qualityDistribution: {},
        topPerformers: [],
        mostUsed: [],
        recentlyAdded: [],
      );
    }

    final customCount = presets.where((p) => p.isCustom).length;
    final standardCount = presets.length - customCount;

    final avgSuccessRate =
        presets.map((p) => p.successRate).reduce((a, b) => a + b) /
            presets.length;
    final avgImprovementScore =
        presets.map((p) => p.averageImprovementScore).reduce((a, b) => a + b) /
            presets.length;

    final categoryDist = <String, int>{};
    final qualityDist = <PresetQuality, int>{};

    for (final preset in presets) {
      categoryDist[preset.category] = (categoryDist[preset.category] ?? 0) + 1;
      qualityDist[preset.quality] = (qualityDist[preset.quality] ?? 0) + 1;
    }

    final sortedByPerformance = List<FavoritePreset>.from(presets)
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

    final sortedByUsage = List<FavoritePreset>.from(presets)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    final sortedByDate = List<FavoritePreset>.from(presets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return FavoritePresetStats(
      totalPresets: presets.length,
      customPresets: customCount,
      standardPresets: standardCount,
      averageSuccessRate: avgSuccessRate,
      averageImprovementScore: avgImprovementScore,
      categoryDistribution: categoryDist,
      qualityDistribution: qualityDist,
      topPerformers: sortedByPerformance.take(5).toList(),
      mostUsed: sortedByUsage.take(5).toList(),
      recentlyAdded: sortedByDate.take(5).toList(),
    );
  }
}
