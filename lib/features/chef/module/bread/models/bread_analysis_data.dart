// lib/modules/bread/models/bread_analysis_data.dart
// 빵 분석 데이터 모델들

/// 빵 믹싱 분석 데이터 (단계별)
class BreadMixingAnalysisData {
  final String stepId;
  final double mixingIntensity;
  final int mixingDuration;
  final String mixingTechnique;
  final double doughConsistency;
  final double? glutenFormationIndex;
  final double? optimizedMixingTime;
  final Map<String, dynamic> speedProfile;
  final List<String>? issues;
  final double? successProbability;
  final double? actualTemperature;
  final double? glutenNetworkStability;

  const BreadMixingAnalysisData({
    required this.stepId,
    required this.mixingIntensity,
    required this.mixingDuration,
    required this.mixingTechnique,
    required this.doughConsistency,
    this.glutenFormationIndex,
    this.optimizedMixingTime,
    this.speedProfile = const {},
    this.issues,
    this.successProbability,
    this.actualTemperature,
    this.glutenNetworkStability,
  });

  factory BreadMixingAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadMixingAnalysisData(
      stepId: json['stepId'] as String? ?? '',
      mixingIntensity: (json['mixingIntensity'] as num?)?.toDouble() ?? 0.5,
      mixingDuration: (json['mixingDuration'] as num?)?.toInt() ?? 0,
      mixingTechnique: json['mixingTechnique'] as String? ?? 'standard',
      doughConsistency: (json['doughConsistency'] as num?)?.toDouble() ?? 0.5,
      glutenFormationIndex: (json['glutenFormationIndex'] as num?)?.toDouble(),
      optimizedMixingTime: (json['optimizedMixingTime'] as num?)?.toDouble(),
      speedProfile: Map<String, dynamic>.from(json['speedProfile'] ?? {}),
      issues: json['issues'] != null ? List<String>.from(json['issues']) : null,
      successProbability: (json['successProbability'] as num?)?.toDouble(),
      actualTemperature: (json['actualTemperature'] as num?)?.toDouble(),
      glutenNetworkStability:
          (json['glutenNetworkStability'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'mixingIntensity': mixingIntensity,
      'mixingDuration': mixingDuration,
      'mixingTechnique': mixingTechnique,
      'doughConsistency': doughConsistency,
      'glutenFormationIndex': glutenFormationIndex,
      'optimizedMixingTime': optimizedMixingTime,
      'speedProfile': speedProfile,
      'issues': issues,
      'successProbability': successProbability,
      'actualTemperature': actualTemperature,
      'glutenNetworkStability': glutenNetworkStability,
    };
  }
}

/// 빵 믹싱 분석 결과
class BreadMixingAnalysis {
  final double successProbability;
  final String analysis;
  final List<String> recommendations;

  const BreadMixingAnalysis({
    required this.successProbability,
    required this.analysis,
    required this.recommendations,
  });

  factory BreadMixingAnalysis.fromJson(Map<String, dynamic> json) {
    return BreadMixingAnalysis(
      successProbability:
          (json['successProbability'] as num?)?.toDouble() ?? 0.5,
      analysis: json['analysis'] as String? ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successProbability': successProbability,
      'analysis': analysis,
      'recommendations': recommendations,
    };
  }
}

/// 믹싱 분석 데이터
class MixingAnalysisData {
  final double mixingIntensity;
  final int mixingDuration;
  final String mixingTechnique;
  final double doughConsistency;
  final double? glutenFormationIndex;
  final double? optimizedMixingTime;
  final Map<String, dynamic> speedProfile;
  final List<String>? issues;
  final double? successProbability;

  const MixingAnalysisData({
    required this.mixingIntensity,
    required this.mixingDuration,
    required this.mixingTechnique,
    required this.doughConsistency,
    this.glutenFormationIndex,
    this.optimizedMixingTime,
    this.speedProfile = const {},
    this.issues,
    this.successProbability,
  });

  factory MixingAnalysisData.fromJson(Map<String, dynamic> json) {
    return MixingAnalysisData(
      mixingIntensity: (json['mixingIntensity'] as num?)?.toDouble() ?? 0.5,
      mixingDuration: (json['mixingDuration'] as num?)?.toInt() ?? 0,
      mixingTechnique: json['mixingTechnique'] as String? ?? 'standard',
      doughConsistency: (json['doughConsistency'] as num?)?.toDouble() ?? 0.5,
      glutenFormationIndex: (json['glutenFormationIndex'] as num?)?.toDouble(),
      optimizedMixingTime: (json['optimizedMixingTime'] as num?)?.toDouble(),
      speedProfile: Map<String, dynamic>.from(json['speedProfile'] ?? {}),
      issues: json['issues'] != null ? List<String>.from(json['issues']) : null,
      successProbability: (json['successProbability'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mixingIntensity': mixingIntensity,
      'mixingDuration': mixingDuration,
      'mixingTechnique': mixingTechnique,
      'doughConsistency': doughConsistency,
      'glutenFormationIndex': glutenFormationIndex,
      'optimizedMixingTime': optimizedMixingTime,
      'speedProfile': speedProfile,
      'issues': issues,
      'successProbability': successProbability,
    };
  }
}

/// 빵 도우 분석 데이터
class BreadDoughAnalysisData {
  final String stepId;
  final double glutenNetworkStrength;
  final double doughElasticity;
  final double fermentationProgress;
  final Map<String, dynamic> characteristics;
  final double? actualTemperature;
  final double? glutenNetworkStability;
  final List<String>? issues;
  final double? successProbability;

  const BreadDoughAnalysisData({
    required this.stepId,
    required this.glutenNetworkStrength,
    required this.doughElasticity,
    required this.fermentationProgress,
    this.characteristics = const {},
    this.actualTemperature,
    this.glutenNetworkStability,
    this.issues,
    this.successProbability,
  });

  factory BreadDoughAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadDoughAnalysisData(
      stepId: json['stepId'] as String? ?? '',
      glutenNetworkStrength:
          (json['glutenNetworkStrength'] as num?)?.toDouble() ?? 0.0,
      doughElasticity: (json['doughElasticity'] as num?)?.toDouble() ?? 0.0,
      fermentationProgress:
          (json['fermentationProgress'] as num?)?.toDouble() ?? 0.0,
      characteristics: Map<String, dynamic>.from(json['characteristics'] ?? {}),
      actualTemperature: (json['actualTemperature'] as num?)?.toDouble(),
      glutenNetworkStability:
          (json['glutenNetworkStability'] as num?)?.toDouble(),
      issues: json['issues'] != null ? List<String>.from(json['issues']) : null,
      successProbability: (json['successProbability'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'glutenNetworkStrength': glutenNetworkStrength,
      'doughElasticity': doughElasticity,
      'fermentationProgress': fermentationProgress,
      'characteristics': characteristics,
      'actualTemperature': actualTemperature,
      'glutenNetworkStability': glutenNetworkStability,
      'issues': issues,
      'successProbability': successProbability,
    };
  }
}

/// 빵 재료 분석 데이터
class BreadIngredientAnalysisData {
  final String ingredientId;
  final String ingredientName;
  final double proportion;
  final double impactOnDough;
  final Map<String, dynamic> properties;

  const BreadIngredientAnalysisData({
    required this.ingredientId,
    required this.ingredientName,
    required this.proportion,
    required this.impactOnDough,
    this.properties = const {},
  });

  factory BreadIngredientAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadIngredientAnalysisData(
      ingredientId: json['ingredientId'] as String? ?? '',
      ingredientName: json['ingredientName'] as String? ?? '',
      proportion: (json['proportion'] as num?)?.toDouble() ?? 0.0,
      impactOnDough: (json['impactOnDough'] as num?)?.toDouble() ?? 0.0,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'proportion': proportion,
      'impactOnDough': impactOnDough,
      'properties': properties,
    };
  }
}

/// 빵 분석 결과 통합 데이터
class BreadAnalysisResult {
  final String analysisId;
  final DateTime timestamp;
  final List<BreadMixingAnalysisData> mixingAnalysis;
  final List<BreadDoughAnalysisData> doughAnalysis;
  final List<BreadIngredientAnalysisData> ingredientAnalysis;
  final Map<String, dynamic> data;
  final bool isSuccessful;
  final String? errorMessage;

  const BreadAnalysisResult({
    required this.analysisId,
    required this.timestamp,
    required this.mixingAnalysis,
    required this.doughAnalysis,
    required this.ingredientAnalysis,
    required this.data,
    required this.isSuccessful,
    this.errorMessage,
  });

  factory BreadAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisResult(
      analysisId: json['analysisId'] as String? ?? '',
      timestamp: DateTime.parse(
          json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      mixingAnalysis: (json['mixingAnalysis'] as List<dynamic>? ?? [])
          .map((e) =>
              BreadMixingAnalysisData.fromJson(e as Map<String, dynamic>))
          .toList(),
      doughAnalysis: (json['doughAnalysis'] as List<dynamic>? ?? [])
          .map(
              (e) => BreadDoughAnalysisData.fromJson(e as Map<String, dynamic>))
          .toList(),
      ingredientAnalysis: (json['ingredientAnalysis'] as List<dynamic>? ?? [])
          .map((e) =>
              BreadIngredientAnalysisData.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      isSuccessful: json['isSuccessful'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'timestamp': timestamp.toIso8601String(),
      'mixingAnalysis': mixingAnalysis.map((e) => e.toJson()).toList(),
      'doughAnalysis': doughAnalysis.map((e) => e.toJson()).toList(),
      'ingredientAnalysis': ingredientAnalysis.map((e) => e.toJson()).toList(),
      'data': data,
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
    };
  }
}
