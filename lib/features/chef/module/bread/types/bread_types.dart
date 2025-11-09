// lib/modules/bread/types/bread_types.dart
// 빵 모듈 전용 타입 시스템

import 'dart:convert';
import '../../../../../core/types/unified_types.dart';

/// 빵 재료 타입
enum BreadIngredientType {
  flour,
  water,
  yeast,
  salt,
  sugar,
  fat,
  egg,
  milk,
  other,
}

/// 빵 재료
class BreadIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final BreadIngredientType type;

  const BreadIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.type,
  });

  factory BreadIngredient.fromJson(Map<String, dynamic> json) {
    return BreadIngredient(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      type: BreadIngredientType.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'type': type.index,
    };
  }

  @override
  String toString() => '$name: ${amount.toStringAsFixed(1)}$unit';
}

/// 빵 지침
class BreadInstruction {
  final String id;
  final String title;
  final String description;
  final int order;

  const BreadInstruction({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  factory BreadInstruction.fromJson(Map<String, dynamic> json) {
    return BreadInstruction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
    };
  }
}

/// 빵 레시피 메타데이터
class BreadRecipeMetadata {
  final Map<String, dynamic> data;

  const BreadRecipeMetadata({
    required this.data,
  });

  factory BreadRecipeMetadata.empty() {
    return const BreadRecipeMetadata(data: {});
  }

  factory BreadRecipeMetadata.fromJson(Map<String, dynamic> json) {
    return BreadRecipeMetadata(
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}

/// 빵 레시피 데이터
class BreadRecipeData {
  final String id;
  final String title;
  final List<BreadIngredient> ingredients;
  final List<BreadInstruction> instructions;
  final BreadRecipeMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BreadRecipeData({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BreadRecipeData.fromJson(Map<String, dynamic> json) {
    return BreadRecipeData(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List)
          .map((ing) => BreadIngredient.fromJson(ing))
          .toList(),
      instructions: (json['instructions'] as List)
          .map((inst) => BreadInstruction.fromJson(inst))
          .toList(),
      metadata: BreadRecipeMetadata.fromJson(json['metadata']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
      'instructions': instructions.map((inst) => inst.toJson()).toList(),
      'metadata': metadata.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 빵 재료 분석 데이터
class BreadIngredientAnalysisData {
  final String ingredientId;
  final double amount;
  final String unit;
  final BreadIngredientType type;
  final Map<String, dynamic> analysis;

  const BreadIngredientAnalysisData({
    required this.ingredientId,
    required this.amount,
    required this.unit,
    required this.type,
    required this.analysis,
  });

  factory BreadIngredientAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadIngredientAnalysisData(
      ingredientId: json['ingredientId'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      type: BreadIngredientType.values[json['type'] as int],
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'amount': amount,
      'unit': unit,
      'type': type.index,
      'analysis': analysis,
    };
  }
}

/// 빵 믹싱 분석 데이터
class BreadMixingAnalysisData {
  final String stepId;
  final String mixingType;
  final double speed;
  final Duration duration;
  final Map<String, dynamic> analysis;

  // 추가된 프로퍼티들
  final double successProbability;
  final List<String> issues;

  const BreadMixingAnalysisData({
    required this.stepId,
    required this.mixingType,
    required this.speed,
    required this.duration,
    required this.analysis,
    this.successProbability = 0.8,
    this.issues = const [],
  });

  factory BreadMixingAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadMixingAnalysisData(
      stepId: json['stepId'] as String,
      mixingType: json['mixingType'] as String,
      speed: (json['speed'] as num).toDouble(),
      duration: Duration(minutes: json['duration_minutes'] as int),
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'mixingType': mixingType,
      'speed': speed,
      'duration_minutes': duration.inMinutes,
      'analysis': analysis,
    };
  }
}

/// 빵 도우 분석 데이터
class BreadDoughAnalysisData {
  final String doughId;
  final double hydration;
  final double temperature;
  final String consistency;
  final Map<String, dynamic> analysis;

  // 추가된 프로퍼티들
  final double successProbability;
  final List<String> issues;

  const BreadDoughAnalysisData({
    required this.doughId,
    required this.hydration,
    required this.temperature,
    required this.consistency,
    required this.analysis,
    this.successProbability = 0.8,
    this.issues = const [],
  });

  factory BreadDoughAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadDoughAnalysisData(
      doughId: json['doughId'] as String,
      hydration: (json['hydration'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      consistency: json['consistency'] as String,
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doughId': doughId,
      'hydration': hydration,
      'temperature': temperature,
      'consistency': consistency,
      'analysis': analysis,
    };
  }
}

/// 빵 발효 분석 데이터
class BreadFermentationAnalysisData {
  final String fermentationId;
  final Duration duration;
  final double temperature;
  final double humidity;
  final Map<String, dynamic> analysis;

  // 추가된 프로퍼티들
  final double successProbability;
  final List<String> issues;

  const BreadFermentationAnalysisData({
    required this.fermentationId,
    required this.duration,
    required this.temperature,
    required this.humidity,
    required this.analysis,
    this.successProbability = 0.8,
    this.issues = const [],
  });

  factory BreadFermentationAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadFermentationAnalysisData(
      fermentationId: json['fermentationId'] as String,
      duration: Duration(minutes: json['duration_minutes'] as int),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fermentationId': fermentationId,
      'duration_minutes': duration.inMinutes,
      'temperature': temperature,
      'humidity': humidity,
      'analysis': analysis,
    };
  }
}

/// 빵 오븐 분석 데이터
class BreadOvenAnalysisData {
  final String ovenId;
  final double temperature;
  final Duration duration;
  final String bakingMode;
  final Map<String, dynamic> analysis;

  // 추가된 프로퍼티들
  final double finalSuccessProbability;
  final List<String> issues;

  const BreadOvenAnalysisData({
    required this.ovenId,
    required this.temperature,
    required this.duration,
    required this.bakingMode,
    required this.analysis,
    this.finalSuccessProbability = 0.8,
    this.issues = const [],
  });

  factory BreadOvenAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadOvenAnalysisData(
      ovenId: json['ovenId'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      duration: Duration(minutes: json['duration_minutes'] as int),
      bakingMode: json['bakingMode'] as String,
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ovenId': ovenId,
      'temperature': temperature,
      'duration_minutes': duration.inMinutes,
      'bakingMode': bakingMode,
      'analysis': analysis,
    };
  }
}

/// 빵 최종 결과
class BreadFinalResult {
  final String resultId;
  final String recipeId;
  final Map<String, dynamic> scores;
  final List<String> recommendations;
  final List<String> warnings;
  final Map<String, dynamic> analysis;

  // 추가된 프로퍼티들
  final double overallSuccessProbability;
  final String successLevel;
  final List<String> keyInsights;

  const BreadFinalResult({
    required this.resultId,
    required this.recipeId,
    required this.scores,
    required this.recommendations,
    required this.warnings,
    required this.analysis,
    this.overallSuccessProbability = 0.8,
    this.successLevel = 'Good',
    this.keyInsights = const [],
  });

  factory BreadFinalResult.fromJson(Map<String, dynamic> json) {
    return BreadFinalResult(
      resultId: json['resultId'] as String,
      recipeId: json['recipeId'] as String,
      scores: Map<String, dynamic>.from(json['scores'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'recipeId': recipeId,
      'scores': scores,
      'recommendations': recommendations,
      'warnings': warnings,
      'analysis': analysis,
    };
  }
}

/// 빵 분석 결과
class BreadAnalysisResult {
  final String analysisId;
  final String doughType;
  final DateTime timestamp;
  final bool isSuccessful;
  final String? errorMessage;
  final Map<String, dynamic> data;

  // 단계별 분석 결과
  final BreadMixingAnalysisData mixingAnalysis;
  final BreadDoughAnalysisData doughAnalysis;
  final BreadFermentationAnalysisData fermentationAnalysis;
  final BreadOvenAnalysisData ovenAnalysis;
  final BreadFinalResult finalResult;

  const BreadAnalysisResult({
    required this.analysisId,
    required this.doughType,
    required this.timestamp,
    required this.isSuccessful,
    this.errorMessage,
    required this.data,
    required this.mixingAnalysis,
    required this.doughAnalysis,
    required this.fermentationAnalysis,
    required this.ovenAnalysis,
    required this.finalResult,
  });

  factory BreadAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisResult(
      analysisId: json['analysisId'] as String,
      doughType: json['doughType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSuccessful: json['isSuccessful'] as bool,
      errorMessage: json['errorMessage'] as String?,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      mixingAnalysis: BreadMixingAnalysisData.fromJson(json['mixingAnalysis']),
      doughAnalysis: BreadDoughAnalysisData.fromJson(json['doughAnalysis']),
      fermentationAnalysis:
          BreadFermentationAnalysisData.fromJson(json['fermentationAnalysis']),
      ovenAnalysis: BreadOvenAnalysisData.fromJson(json['ovenAnalysis']),
      finalResult: BreadFinalResult.fromJson(json['finalResult']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'doughType': doughType,
      'timestamp': timestamp.toIso8601String(),
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
      'data': data,
      'mixingAnalysis': mixingAnalysis.toJson(),
      'doughAnalysis': doughAnalysis.toJson(),
      'fermentationAnalysis': fermentationAnalysis.toJson(),
      'ovenAnalysis': ovenAnalysis.toJson(),
      'finalResult': finalResult.toJson(),
    };
  }
}

/// 통합 빵 분석 결과 - EnvironmentManager 통합
class UnifiedBreadAnalysisResult extends AnalysisResult {
  final BreadRecipeData? recipeData;
  // 환경 데이터 제거 - EnvironmentManager에서 가져옴
  final Map<String, dynamic>? equipmentSettings;
  // 사용자 선호사항 대신 환경 설정 사용
  final List<BreadIngredientAnalysisData> ingredientAnalysis;
  final List<BreadMixingAnalysisData> mixingAnalysis;
  final List<BreadDoughAnalysisData> doughAnalysis;
  final List<BreadFermentationAnalysisData> fermentationAnalysis;
  final List<BreadOvenAnalysisData> ovenAnalysis;
  final BreadFinalResult? finalResult;

  const UnifiedBreadAnalysisResult({
    required super.moduleId,
    required super.data,
    required super.timestamp,
    required super.confidence,
    this.recipeData,
    this.equipmentSettings,
    this.ingredientAnalysis = const [],
    this.mixingAnalysis = const [],
    this.doughAnalysis = const [],
    this.fermentationAnalysis = const [],
    this.ovenAnalysis = const [],
    this.finalResult,
  });

  factory UnifiedBreadAnalysisResult.success({
    required String moduleId,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required double confidence,
    BreadRecipeData? recipeData,
    Map<String, dynamic>? equipmentSettings,
    List<BreadIngredientAnalysisData> ingredientAnalysis = const [],
    List<BreadMixingAnalysisData> mixingAnalysis = const [],
    List<BreadDoughAnalysisData> doughAnalysis = const [],
    List<BreadFermentationAnalysisData> fermentationAnalysis = const [],
    List<BreadOvenAnalysisData> ovenAnalysis = const [],
    BreadFinalResult? finalResult,
  }) {
    return UnifiedBreadAnalysisResult(
      moduleId: moduleId,
      data: data,
      timestamp: timestamp,
      confidence: confidence,
      recipeData: recipeData,
      equipmentSettings: equipmentSettings,
      ingredientAnalysis: ingredientAnalysis,
      mixingAnalysis: mixingAnalysis,
      doughAnalysis: doughAnalysis,
      fermentationAnalysis: fermentationAnalysis,
      ovenAnalysis: ovenAnalysis,
      finalResult: finalResult,
    );
  }

  factory UnifiedBreadAnalysisResult.error({
    required String moduleId,
    required String errorMessage,
    required DateTime timestamp,
  }) {
    return UnifiedBreadAnalysisResult(
      moduleId: moduleId,
      data: {'error': errorMessage},
      timestamp: timestamp,
      confidence: 0.0,
    );
  }

  factory UnifiedBreadAnalysisResult.fromJson(Map<String, dynamic> json) {
    return UnifiedBreadAnalysisResult(
      moduleId: json['moduleId'] as String,
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      recipeData: json['recipeData'] != null
          ? BreadRecipeData.fromJson(json['recipeData'])
          : null,
      equipmentSettings: json['equipmentSettings'] != null
          ? Map<String, dynamic>.from(json['equipmentSettings'])
          : null,
      ingredientAnalysis: json['ingredientAnalysis'] != null
          ? (json['ingredientAnalysis'] as List)
              .map((item) => BreadIngredientAnalysisData.fromJson(item))
              .toList()
          : [],
      mixingAnalysis: json['mixingAnalysis'] != null
          ? (json['mixingAnalysis'] as List)
              .map((item) => BreadMixingAnalysisData.fromJson(item))
              .toList()
          : [],
      doughAnalysis: json['doughAnalysis'] != null
          ? (json['doughAnalysis'] as List)
              .map((item) => BreadDoughAnalysisData.fromJson(item))
              .toList()
          : [],
      fermentationAnalysis: json['fermentationAnalysis'] != null
          ? (json['fermentationAnalysis'] as List)
              .map((item) => BreadFermentationAnalysisData.fromJson(item))
              .toList()
          : [],
      ovenAnalysis: json['ovenAnalysis'] != null
          ? (json['ovenAnalysis'] as List)
              .map((item) => BreadOvenAnalysisData.fromJson(item))
              .toList()
          : [],
      finalResult: json['finalResult'] != null
          ? BreadFinalResult.fromJson(json['finalResult'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
      'recipeData': recipeData?.toJson(),
      'equipmentSettings': equipmentSettings,
      'ingredientAnalysis':
          ingredientAnalysis.map((item) => item.toJson()).toList(),
      'mixingAnalysis': mixingAnalysis.map((item) => item.toJson()).toList(),
      'doughAnalysis': doughAnalysis.map((item) => item.toJson()).toList(),
      'fermentationAnalysis':
          fermentationAnalysis.map((item) => item.toJson()).toList(),
      'ovenAnalysis': ovenAnalysis.map((item) => item.toJson()).toList(),
      'finalResult': finalResult?.toJson(),
    };
  }
}

/// 빵 사용자 환경
class BreadUserEnvironment {
  final double temperature;
  final double humidity;
  final String fermentationMethod;
  final String ovenType;

  const BreadUserEnvironment({
    required this.temperature,
    required this.humidity,
    required this.fermentationMethod,
    required this.ovenType,
  });

  factory BreadUserEnvironment.defaultEnvironment() {
    return const BreadUserEnvironment(
      temperature: 25.0,
      humidity: 60.0,
      fermentationMethod: 'roomTemperature',
      ovenType: 'convection',
    );
  }

  factory BreadUserEnvironment.fromJson(Map<String, dynamic> json) {
    return BreadUserEnvironment(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble() ?? 60.0,
      fermentationMethod:
          json['fermentationMethod'] as String? ?? 'roomTemperature',
      ovenType: json['ovenType'] as String? ?? 'convection',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'fermentationMethod': fermentationMethod,
      'ovenType': ovenType,
    };
  }
}

/// 빵 사용자 장비
class BreadUserEquipment {
  final Map<String, dynamic> settings;

  const BreadUserEquipment({
    required this.settings,
  });

  factory BreadUserEquipment.defaultEquipment() {
    return const BreadUserEquipment(settings: {
      'mixerType': 'stand_mixer',
      'ovenType': 'convection',
      'mixerPower': 300,
      'ovenPower': 2000,
    });
  }

  factory BreadUserEquipment.fromJson(Map<String, dynamic> json) {
    return BreadUserEquipment(
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings,
    };
  }
}

/// 빵 사용자 선호사항
class BreadUserPreferences {
  final Map<String, dynamic> preferences;

  const BreadUserPreferences({
    required this.preferences,
  });

  factory BreadUserPreferences.defaultPreferences() {
    return const BreadUserPreferences(preferences: {
      'difficulty': 'intermediate',
      'automationLevel': 'medium',
      'preferredOven': 'convection',
    });
  }

  factory BreadUserPreferences.fromJson(Map<String, dynamic> json) {
    return BreadUserPreferences(
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferences': preferences,
    };
  }
}

/// 빵 사용자 데이터 (통합 환경/장비/선호사항)
class BreadUserData {
  final String userId;
  final BreadUserEnvironment environment;
  final BreadUserEquipment equipment;
  final BreadUserPreferences preferences;

  const BreadUserData({
    required this.userId,
    required this.environment,
    required this.equipment,
    required this.preferences,
  });

  factory BreadUserData.fromJson(Map<String, dynamic> json) {
    return BreadUserData(
      userId: json['userId'] as String,
      environment: BreadUserEnvironment.fromJson(json['environment']),
      equipment: BreadUserEquipment.fromJson(json['equipment']),
      preferences: BreadUserPreferences.fromJson(json['preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'environment': environment.toJson(),
      'equipment': equipment.toJson(),
      'preferences': preferences.toJson(),
    };
  }
}
