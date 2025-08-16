// Sous Chef 모드 데이터 모델들

import 'package:hive/hive.dart';

part 'sous_chef_models.g.dart';

@HiveType(typeId: 0)
enum BakingType {
  @HiveField(0)
  bread,
  @HiveField(1)
  cake,
  @HiveField(2)
  cookie,
  @HiveField(3)
  fried,
  @HiveField(4)
  dessertHot,
  @HiveField(5)
  dessertCold,
  @HiveField(6)
  frozenDessert,
  @HiveField(7)
  iceCream,
  @HiveField(8)
  gelato,
  @HiveField(9)
  candy,
  @HiveField(10)
  etc,
}

enum OptionCategory {
  fermentation,
  moisture,
  oven,
  dough,
  baking,
  frying,
  freezing,
  crystallization,
}

enum FermentationStage {
  bulk,           // 1차 발효 (Bulk Fermentation)
  secondary,      // 2차 발효 (Secondary Fermentation)
  divided,        // 분할 후 휴지 (Post-Division Rest)
  shaped,         // 성형 후 발효 (Post-Shaping Rest)
  finalProof,     // 최종 발효 (Final Proof)
  overnight,      // 오버나이트 발효 (Overnight Fermentation)
  coldRetard,     // 냉장 숙성 (Cold Retardation)
}

enum OvenType {
  convection,      // 컨벡션 오븐
  deck,           // 데크 오븐
  steam,          // 스팀 오븐
  gas,            // 가스 오븐
  electricHome,   // 가정용 전기 오븐
  combi,          // 콤비 오븐
}

enum FermentationMethod {
  proofer,        // 발효기
  cold,           // 냉장 발효
  roomTemp,       // 실온 발효
  warmPlace,      // 따뜻한 곳
  controlled,     // 온습도 조절
}

enum FermentationState {
  underFermented,    // 발효 부족
  optimal,           // 적정 발효
  overFermented,     // 과발효
  readyToBake,       // 굽기 준비 완료
}

@HiveType(typeId: 1)
class SousChefPreset extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String colorTag;
  
  @HiveField(3)
  final List<String> tags;
  
  @HiveField(4)
  final Map<String, dynamic> options;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final int usageCount;
  
  @HiveField(7)
  final double successRate;

  SousChefPreset({
    required this.id,
    required this.name,
    required this.colorTag,
    required this.tags,
    required this.options,
    required this.createdAt,
    this.usageCount = 0,
    this.successRate = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorTag': colorTag,
    'tags': tags,
    'options': options,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
    'successRate': successRate,
  };

  factory SousChefPreset.fromJson(Map<String, dynamic> json) => SousChefPreset(
    id: json['id'],
    name: json['name'],
    colorTag: json['colorTag'],
    tags: List<String>.from(json['tags']),
    options: json['options'],
    createdAt: DateTime.parse(json['createdAt']),
    usageCount: json['usageCount'] ?? 0,
    successRate: json['successRate'] ?? 0.0,
  );
}

@HiveType(typeId: 2)
class SousChefRecipeState extends HiveObject {
  @HiveField(0)
  final String recipeId;
  
  @HiveField(1)
  final BakingType bakingType;
  
  @HiveField(2)
  final String? activePresetId;
  
  @HiveField(3)
  final List<SousChefPreset> presets;
  
  @HiveField(4)
  final Map<String, double> currentAdjustments;
  
  @HiveField(5)
  final List<AdjustmentHistoryEntry> adjustmentHistory;

  SousChefRecipeState({
    required this.recipeId,
    required this.bakingType,
    this.activePresetId,
    this.presets = const [],
    this.currentAdjustments = const {},
    this.adjustmentHistory = const [],
  });

  SousChefRecipeState copyWith({
    String? recipeId,
    BakingType? bakingType,
    String? activePresetId,
    List<SousChefPreset>? presets,
    Map<String, double>? currentAdjustments,
    List<AdjustmentHistoryEntry>? adjustmentHistory,
  }) {
    return SousChefRecipeState(
      recipeId: recipeId ?? this.recipeId,
      bakingType: bakingType ?? this.bakingType,
      activePresetId: activePresetId ?? this.activePresetId,
      presets: presets ?? this.presets,
      currentAdjustments: currentAdjustments ?? this.currentAdjustments,
      adjustmentHistory: adjustmentHistory ?? this.adjustmentHistory,
    );
  }
}

@HiveType(typeId: 3)
class AdjustmentHistoryEntry extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;
  
  @HiveField(1)
  final String presetIdUsed;
  
  @HiveField(2)
  final Map<String, double> finalAdjustments;
  
  @HiveField(3)
  final UserFeedback? userFeedback;

  AdjustmentHistoryEntry({
    required this.timestamp,
    required this.presetIdUsed,
    required this.finalAdjustments,
    this.userFeedback,
  });
}

@HiveType(typeId: 4)
class UserFeedback extends HiveObject {
  @HiveField(0)
  final FeedbackResult result;
  
  @HiveField(1)
  final String memo;
  
  @HiveField(2)
  final String? imagePath;

  UserFeedback({
    required this.result,
    required this.memo,
    this.imagePath,
  });
}

@HiveType(typeId: 5)
enum FeedbackResult {
  @HiveField(0)
  success,
  @HiveField(1)
  failure,
  @HiveField(2)
  partialSuccess,
}

class AdjustmentResult {
  final Map<String, double> adjustments;
  final List<String> warnings;
  final List<String> explanations;
  final double confidenceScore;

  AdjustmentResult({
    required this.adjustments,
    this.warnings = const [],
    this.explanations = const [],
    this.confidenceScore = 1.0,
  });
}