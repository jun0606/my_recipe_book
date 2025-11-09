// lib/modules/bread/types/analysis_types.dart
// 빵 모듈 분석 타입 시스템

import 'dart:convert';
import '../../../core/types/unified_types.dart';

/// 빵 분석 단계 열거형
enum BreadAnalysisStep {
  ingredientAnalysis,
  mixingAnalysis,
  doughAnalysis,
  fermentationAnalysis,
  ovenAnalysis,
  finalResult,
}

/// 빵 분석 결과 상태
enum BreadAnalysisStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// 빵 분석 우선순위
enum BreadAnalysisPriority {
  low,
  normal,
  high,
  critical,
}

/// 빵 분석 메트릭
class BreadAnalysisMetric {
  final String name;
  final double value;
  final String unit;
  final double? optimalValue;
  final double? minValue;
  final double? maxValue;
  final String? description;

  const BreadAnalysisMetric({
    required this.name,
    required this.value,
    required this.unit,
    this.optimalValue,
    this.minValue,
    this.maxValue,
    this.description,
  });

  factory BreadAnalysisMetric.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisMetric(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      optimalValue: json['optimalValue'] != null
          ? (json['optimalValue'] as num).toDouble()
          : null,
      minValue: json['minValue'] != null
          ? (json['minValue'] as num).toDouble()
          : null,
      maxValue: json['maxValue'] != null
          ? (json['maxValue'] as num).toDouble()
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'optimalValue': optimalValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'description': description,
    };
  }

  bool get isOptimal {
    if (optimalValue == null) return true;
    final tolerance = (maxValue != null && minValue != null)
        ? (maxValue! - minValue!) * 0.1
        : 0.0;
    return (value - optimalValue!).abs() <= tolerance;
  }

  bool get isInRange {
    if (minValue != null && value < minValue!) return false;
    if (maxValue != null && value > maxValue!) return false;
    return true;
  }
}

/// 빵 분석 설정
class BreadAnalysisConfig {
  final BreadAnalysisPriority priority;
  final Duration timeout;
  final bool enableRealTimeUpdates;
  final bool enableDetailedLogging;
  final Map<String, dynamic> customParameters;

  const BreadAnalysisConfig({
    this.priority = BreadAnalysisPriority.normal,
    this.timeout = const Duration(minutes: 5),
    this.enableRealTimeUpdates = false,
    this.enableDetailedLogging = false,
    this.customParameters = const {},
  });

  factory BreadAnalysisConfig.defaultConfig() {
    return const BreadAnalysisConfig(
      priority: BreadAnalysisPriority.normal,
      timeout: Duration(minutes: 5),
      enableRealTimeUpdates: false,
      enableDetailedLogging: false,
      customParameters: {},
    );
  }

  factory BreadAnalysisConfig.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisConfig(
      priority: BreadAnalysisPriority.values[json['priority'] as int? ?? 1],
      timeout: Duration(minutes: json['timeout_minutes'] as int? ?? 5),
      enableRealTimeUpdates: json['enableRealTimeUpdates'] as bool? ?? false,
      enableDetailedLogging: json['enableDetailedLogging'] as bool? ?? false,
      customParameters:
          Map<String, dynamic>.from(json['customParameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority': priority.index,
      'timeout_minutes': timeout.inMinutes,
      'enableRealTimeUpdates': enableRealTimeUpdates,
      'enableDetailedLogging': enableDetailedLogging,
      'customParameters': customParameters,
    };
  }
}

/// 빵 분석 진행 상황
class BreadAnalysisProgress {
  final BreadAnalysisStep currentStep;
  final double overallProgress; // 0.0 ~ 1.0
  final Map<BreadAnalysisStep, double> stepProgress;
  final Duration elapsedTime;
  final Duration estimatedTimeRemaining;
  final String? currentTaskDescription;

  const BreadAnalysisProgress({
    required this.currentStep,
    required this.overallProgress,
    required this.stepProgress,
    required this.elapsedTime,
    required this.estimatedTimeRemaining,
    this.currentTaskDescription,
  });

  factory BreadAnalysisProgress.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisProgress(
      currentStep: BreadAnalysisStep.values[json['currentStep'] as int],
      overallProgress: (json['overallProgress'] as num).toDouble(),
      stepProgress: Map<BreadAnalysisStep, double>.from(
        (json['stepProgress'] as Map).map(
          (key, value) => MapEntry(
            BreadAnalysisStep.values[int.parse(key)],
            (value as num).toDouble(),
          ),
        ),
      ),
      elapsedTime: Duration(milliseconds: json['elapsedTime_ms'] as int),
      estimatedTimeRemaining:
          Duration(milliseconds: json['estimatedTimeRemaining_ms'] as int),
      currentTaskDescription: json['currentTaskDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep.index,
      'overallProgress': overallProgress,
      'stepProgress': stepProgress.map(
        (key, value) => MapEntry(key.index.toString(), value),
      ),
      'elapsedTime_ms': elapsedTime.inMilliseconds,
      'estimatedTimeRemaining_ms': estimatedTimeRemaining.inMilliseconds,
      'currentTaskDescription': currentTaskDescription,
    };
  }

  bool get isComplete => overallProgress >= 1.0;
  bool get isInProgress => overallProgress > 0.0 && overallProgress < 1.0;
}

/// 빵 분석 오류
class BreadAnalysisError {
  final String code;
  final String message;
  final BreadAnalysisStep? step;
  final Map<String, dynamic> details;
  final bool isRecoverable;

  const BreadAnalysisError({
    required this.code,
    required this.message,
    this.step,
    this.details = const {},
    this.isRecoverable = false,
  });

  factory BreadAnalysisError.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisError(
      code: json['code'] as String,
      message: json['message'] as String,
      step: json['step'] != null
          ? BreadAnalysisStep.values[json['step'] as int]
          : null,
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      isRecoverable: json['isRecoverable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'step': step?.index,
      'details': details,
      'isRecoverable': isRecoverable,
    };
  }
}

/// 빵 분석 결과 요약
class BreadAnalysisSummary {
  final String analysisId;
  final BreadAnalysisStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final BreadAnalysisProgress? progress;
  final BreadAnalysisError? error;
  final List<BreadAnalysisMetric> metrics;
  final Map<String, dynamic> insights;

  const BreadAnalysisSummary({
    required this.analysisId,
    required this.status,
    required this.startTime,
    this.endTime,
    this.progress,
    this.error,
    this.metrics = const [],
    this.insights = const {},
  });

  factory BreadAnalysisSummary.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisSummary(
      analysisId: json['analysisId'] as String,
      status: BreadAnalysisStatus.values[json['status'] as int],
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      progress: json['progress'] != null
          ? BreadAnalysisProgress.fromJson(json['progress'])
          : null,
      error: json['error'] != null
          ? BreadAnalysisError.fromJson(json['error'])
          : null,
      metrics: json['metrics'] != null
          ? (json['metrics'] as List)
              .map((metric) => BreadAnalysisMetric.fromJson(metric))
              .toList()
          : [],
      insights: Map<String, dynamic>.from(json['insights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'status': status.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'progress': progress?.toJson(),
      'error': error?.toJson(),
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'insights': insights,
    };
  }

  bool get isSuccessful => status == BreadAnalysisStatus.completed;
  bool get hasError => error != null;
  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;
}

/// 빵 분석 컨텍스트
class BreadAnalysisContext {
  final String recipeId;
  final String userId;
  final BreadAnalysisConfig config;
  final Map<String, dynamic> environment;
  final Map<String, dynamic> equipment;
  final Map<String, dynamic> userPreferences;

  const BreadAnalysisContext({
    required this.recipeId,
    required this.userId,
    required this.config,
    this.environment = const {},
    this.equipment = const {},
    this.userPreferences = const {},
  });

  factory BreadAnalysisContext.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisContext(
      recipeId: json['recipeId'] as String,
      userId: json['userId'] as String,
      config: BreadAnalysisConfig.fromJson(json['config']),
      environment: Map<String, dynamic>.from(json['environment'] ?? {}),
      equipment: Map<String, dynamic>.from(json['equipment'] ?? {}),
      userPreferences: Map<String, dynamic>.from(json['userPreferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'config': config.toJson(),
      'environment': environment,
      'equipment': equipment,
      'userPreferences': userPreferences,
    };
  }
}
