/// 빵 분석 워크플로우를 위한 표준화된 데이터 구조
/// 수직적 데이터 전달과 체인 자동화를 지원

import 'package:flutter/material.dart';
import '../../../../../core/types/environment_types.dart';
import '../../../screen/types/screen_types.dart';

/// 워크플로우 상태 enum
enum WorkflowStatus {
  idle, // 대기 중
  mixing, // 믹싱 분석 진행 중
  mixingComplete, // 믹싱 분석 완료
  fermentation, // 발효 분석 진행 중
  fermentationComplete, // 발효 분석 완료
  oven, // 오븐 분석 진행 중
  ovenComplete, // 오븐 분석 완료
  completed, // 전체 워크플로우 완료
  error, // 오류 발생
}

/// 표준화된 워크플로우 데이터 클래스
class WorkflowData {
  final Map<String, dynamic> recipeData;
  final UserEnvironment environment;
  final AnalysisSettings settings;
  final Map<String, dynamic>? mixingResult;
  final Map<String, dynamic>? fermentationResult;
  final Map<String, dynamic>? ovenResult;
  final WorkflowStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> logs;

  WorkflowData({
    required this.recipeData,
    required this.environment,
    required this.settings,
    this.mixingResult,
    this.fermentationResult,
    this.ovenResult,
    this.status = WorkflowStatus.idle,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.logs = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 워크플로우 데이터 복사 (불변성 유지)
  WorkflowData copyWith({
    Map<String, dynamic>? recipeData,
    UserEnvironment? environment,
    AnalysisSettings? settings,
    Map<String, dynamic>? mixingResult,
    Map<String, dynamic>? fermentationResult,
    Map<String, dynamic>? ovenResult,
    WorkflowStatus? status,
    List<String>? logs,
  }) {
    return WorkflowData(
      recipeData: recipeData ?? this.recipeData,
      environment: environment ?? this.environment,
      settings: settings ?? this.settings,
      mixingResult: mixingResult ?? this.mixingResult,
      fermentationResult: fermentationResult ?? this.fermentationResult,
      ovenResult: ovenResult ?? this.ovenResult,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      logs: logs ?? this.logs,
    );
  }

  /// 다음 단계로 진행
  WorkflowData nextStep() {
    WorkflowStatus nextStatus;
    switch (status) {
      case WorkflowStatus.idle:
        nextStatus = WorkflowStatus.mixing;
        break;
      case WorkflowStatus.mixing:
        nextStatus = WorkflowStatus.mixingComplete;
        break;
      case WorkflowStatus.mixingComplete:
        nextStatus = WorkflowStatus.fermentation;
        break;
      case WorkflowStatus.fermentation:
        nextStatus = WorkflowStatus.fermentationComplete;
        break;
      case WorkflowStatus.fermentationComplete:
        nextStatus = WorkflowStatus.oven;
        break;
      case WorkflowStatus.oven:
        nextStatus = WorkflowStatus.ovenComplete;
        break;
      case WorkflowStatus.ovenComplete:
        nextStatus = WorkflowStatus.completed;
        break;
      default:
        nextStatus = status;
    }

    return copyWith(
      status: nextStatus,
      logs: [
        ...logs,
        '${DateTime.now()}: 상태 변경 ${status.name} → ${nextStatus.name}'
      ],
    );
  }

  /// 오류 상태로 변경
  WorkflowData error(String errorMessage) {
    return copyWith(
      status: WorkflowStatus.error,
      logs: [...logs, '${DateTime.now()}: 오류 발생 - $errorMessage'],
    );
  }

  /// 현재 단계가 완료되었는지 확인
  bool isStepCompleted(WorkflowStatus step) {
    switch (step) {
      case WorkflowStatus.mixing:
        return status == WorkflowStatus.mixingComplete ||
            status == WorkflowStatus.fermentation ||
            status == WorkflowStatus.fermentationComplete ||
            status == WorkflowStatus.oven ||
            status == WorkflowStatus.ovenComplete ||
            status == WorkflowStatus.completed;
      case WorkflowStatus.fermentation:
        return status == WorkflowStatus.fermentationComplete ||
            status == WorkflowStatus.oven ||
            status == WorkflowStatus.ovenComplete ||
            status == WorkflowStatus.completed;
      case WorkflowStatus.oven:
        return status == WorkflowStatus.ovenComplete ||
            status == WorkflowStatus.completed;
      default:
        return false;
    }
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
        'recipeData': recipeData,
        'environment': environment.toJson(),
        'settings': settings.toJson(),
        'mixingResult': mixingResult,
        'fermentationResult': fermentationResult,
        'ovenResult': ovenResult,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'logs': logs,
      };

  /// JSON 역직렬화
  factory WorkflowData.fromJson(Map<String, dynamic> json) {
    return WorkflowData(
      recipeData: json['recipeData'] as Map<String, dynamic>,
      environment: UserEnvironment.fromJson(json['environment']),
      settings: AnalysisSettings.fromJson(json['settings']),
      mixingResult: json['mixingResult'],
      fermentationResult: json['fermentationResult'],
      ovenResult: json['ovenResult'],
      status: WorkflowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkflowStatus.idle,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      logs: List<String>.from(json['logs'] ?? []),
    );
  }

  @override
  String toString() {
    return 'WorkflowData(status: ${status.name}, mixing: ${mixingResult != null}, fermentation: ${fermentationResult != null}, oven: ${ovenResult != null})';
  }
}

// AnalysisSettings는 screen_types.dart에서 import하여 사용

/// 워크플로우 이벤트 클래스
abstract class WorkflowEvent {
  final DateTime timestamp;
  final String description;

  const WorkflowEvent({
    required this.timestamp,
    required this.description,
  });
}

/// 믹싱 분석 시작 이벤트
class MixingAnalysisStarted extends WorkflowEvent {
  MixingAnalysisStarted()
      : super(
          timestamp: DateTime.now(),
          description: '믹싱 분석 시작',
        );
}

/// 믹싱 분석 완료 이벤트
class MixingAnalysisCompleted extends WorkflowEvent {
  final Map<String, dynamic> result;

  MixingAnalysisCompleted(this.result)
      : super(
          timestamp: DateTime.now(),
          description: '믹싱 분석 완료',
        );
}

/// 발효 분석 시작 이벤트
class FermentationAnalysisStarted extends WorkflowEvent {
  FermentationAnalysisStarted()
      : super(
          timestamp: DateTime.now(),
          description: '발효 분석 시작',
        );
}

/// 발효 분석 완료 이벤트
class FermentationAnalysisCompleted extends WorkflowEvent {
  final Map<String, dynamic> result;

  FermentationAnalysisCompleted(this.result)
      : super(
          timestamp: DateTime.now(),
          description: '발효 분석 완료',
        );
}

/// 워크플로우 오류 이벤트
class WorkflowError extends WorkflowEvent {
  final String errorMessage;

  WorkflowError(this.errorMessage)
      : super(
          timestamp: DateTime.now(),
          description: '워크플로우 오류: $errorMessage',
        );
}

/// 워크플로우 콜백 typedef
typedef WorkflowCallback = void Function(WorkflowEvent event);
typedef MixingCompleteCallback = void Function(Map<String, dynamic> result);
typedef FermentationCompleteCallback = void Function(
    Map<String, dynamic> result);
typedef OvenCompleteCallback = void Function(Map<String, dynamic> result);
typedef WorkflowErrorCallback = void Function(String error);
