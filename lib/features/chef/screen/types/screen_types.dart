// Sous Chef 화면 전용 타입 정의
// 메인 화면의 상태 관리 및 데이터 구조 정의

import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../../../../services/ingredient_analyzer.dart';

/// Sous Chef 메인 화면의 상태 클래스
class SousChefScreenState {
  /// 현재 환경 설정
  final UserEnvironment environment;

  /// 선택된 모듈
  final String selectedModule;

  /// 분석 결과들
  final Map<String, dynamic> analysisResults;

  /// 마지막 업데이트 시간
  final DateTime lastUpdated;

  /// 생성자
  SousChefScreenState({
    required this.environment,
    required this.selectedModule,
    required this.analysisResults,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 기본 상태 생성
  factory SousChefScreenState.initial() {
    return SousChefScreenState(
      environment: UserEnvironment.defaultEnvironment(),
      selectedModule: 'bread',
      analysisResults: {},
    );
  }

  /// 복사본 생성 (특정 필드 변경)
  SousChefScreenState copyWith({
    UserEnvironment? environment,
    String? selectedModule,
    Map<String, dynamic>? analysisResults,
  }) {
    return SousChefScreenState(
      environment: environment ?? this.environment,
      selectedModule: selectedModule ?? this.selectedModule,
      analysisResults: analysisResults ?? this.analysisResults,
    );
  }

  /// 상태 유효성 검증
  bool isValid() {
    return selectedModule.isNotEmpty && environment.isValid;
  }

  /// 디버그용 문자열 표현
  @override
  String toString() {
    return 'SousChefScreenState(module: $selectedModule, '
        'environment: ${environment.temperature}°C, '
        'results: ${analysisResults.length} items)';
  }
}

/// 화면 이벤트 타입들
abstract class ScreenEvent {
  const ScreenEvent();
}

class EnvironmentUpdatedEvent extends ScreenEvent {
  final UserEnvironment newEnvironment;
  const EnvironmentUpdatedEvent(this.newEnvironment);
}

class ModuleSelectedEvent extends ScreenEvent {
  final String moduleId;
  const ModuleSelectedEvent(this.moduleId);
}

class AnalysisRequestedEvent extends ScreenEvent {
  final Map<String, dynamic> inputs;
  const AnalysisRequestedEvent(this.inputs);
}

/// 화면 액션 타입들
abstract class ScreenAction {
  const ScreenAction();
}

class UpdateEnvironmentAction extends ScreenAction {
  final UserEnvironment environment;
  const UpdateEnvironmentAction(this.environment);
}

class SelectModuleAction extends ScreenAction {
  final String moduleId;
  const SelectModuleAction(this.moduleId);
}

class StartAnalysisAction extends ScreenAction {
  final Map<String, dynamic> inputs;
  const StartAnalysisAction(this.inputs);
}

/// 믹싱 분석 결과
class MixingAnalysisResult {
  final int totalTime;
  final double averageGlutenFormation;
  final double finalMoisturePercentage; // 최종 수분 흡수율 추가
  final double? finalDoughTemperature; // 최종 반죽온도 추가 (중앙화된 계산 사용)
  final double efficiency;
  final double overallScore;
  final int stepCount;
  final String finalDoughState;
  final Map<String, dynamic> stepProgressionAnalysis;
  final Map<String, dynamic> speedDistributionAnalysis;
  final Map<String, dynamic> timeOptimizationAnalysis;
  final Map<String, dynamic> integratedPerformanceAnalysis;
  final List<String> processOptimizationSuggestions;
  final List<Map<String, dynamic>> stepProgressionDetails;
  final String analysisVersion;
  final String analysisTimestamp;
  final String dataUtilizationRate;

  const MixingAnalysisResult({
    required this.totalTime,
    required this.averageGlutenFormation,
    required this.finalMoisturePercentage, // 최종 수분 흡수율 추가
    required this.efficiency,
    required this.overallScore,
    required this.stepCount,
    required this.finalDoughState,
    required this.stepProgressionAnalysis,
    required this.speedDistributionAnalysis,
    required this.timeOptimizationAnalysis,
    required this.integratedPerformanceAnalysis,
    required this.processOptimizationSuggestions,
    required this.stepProgressionDetails,
    required this.analysisVersion,
    required this.analysisTimestamp,
    required this.dataUtilizationRate,
    this.finalDoughTemperature, // ✅ nullable로 변경하여 선택적 파라미터로 설정
  });

  /// JSON에서 생성
  factory MixingAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MixingAnalysisResult(
      totalTime: json['totalTime'] as int? ?? 0,
      averageGlutenFormation:
          (json['averageGlutenFormation'] as num?)?.toDouble() ?? 0.0,
      finalMoisturePercentage:
          (json['finalMoisturePercentage'] as num?)?.toDouble() ??
              IngredientAnalyzer.calculateRealisticHydration(
                [],
                recipeTitle: '기본 빵',
              ), // 최종 수분 흡수율 추가
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0.0,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      stepCount: json['stepCount'] as int? ?? 0,
      finalDoughState: json['finalDoughState'] as String? ?? '',
      stepProgressionAnalysis:
          json['stepProgressionAnalysis'] as Map<String, dynamic>? ?? {},
      speedDistributionAnalysis:
          json['speedDistributionAnalysis'] as Map<String, dynamic>? ?? {},
      timeOptimizationAnalysis:
          json['timeOptimizationAnalysis'] as Map<String, dynamic>? ?? {},
      integratedPerformanceAnalysis:
          json['integratedPerformanceAnalysis'] as Map<String, dynamic>? ?? {},
      processOptimizationSuggestions:
          (json['processOptimizationSuggestions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      stepProgressionDetails: (json['stepProgressionDetails'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      analysisVersion: json['analysisVersion'] as String? ?? '1.0',
      analysisTimestamp: json['analysisTimestamp'] as String? ?? '',
      dataUtilizationRate: json['dataUtilizationRate'] as String? ?? '0%',
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'totalTime': totalTime,
      'averageGlutenFormation': averageGlutenFormation,
      'finalMoisturePercentage': finalMoisturePercentage, // 최종 수분 흡수율 추가
      'efficiency': efficiency,
      'overallScore': overallScore,
      'stepCount': stepCount,
      'finalDoughState': finalDoughState,
      'stepProgressionAnalysis': stepProgressionAnalysis,
      'speedDistributionAnalysis': speedDistributionAnalysis,
      'timeOptimizationAnalysis': timeOptimizationAnalysis,
      'integratedPerformanceAnalysis': integratedPerformanceAnalysis,
      'processOptimizationSuggestions': processOptimizationSuggestions,
      'stepProgressionDetails': stepProgressionDetails,
      'analysisVersion': analysisVersion,
      'analysisTimestamp': analysisTimestamp,
      'dataUtilizationRate': dataUtilizationRate,
    };
  }

  /// 성능 등급 반환
  String get performanceGrade {
    if (overallScore >= 0.9) return "탁월";
    if (overallScore >= 0.8) return "우수";
    if (overallScore >= 0.7) return "양호";
    if (overallScore >= 0.6) return "보통";
    return "개선 필요";
  }

  /// 성능 등급에 따른 색상
  Color get performanceColor {
    switch (performanceGrade) {
      case '탁월':
        return const Color(0xFF4CAF50);
      case '우수':
        return const Color(0xFF8BC34A);
      case '양호':
        return const Color(0xFFFFC107);
      case '보통':
        return const Color(0xFFFF9800);
      case '개선 필요':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// 기본 생성자 (하위 호환성 유지)
  factory MixingAnalysisResult.empty() {
    final defaultMoisture = IngredientAnalyzer.calculateRealisticHydration(
      [],
      recipeTitle: '기본 빵',
    );
    return MixingAnalysisResult(
      totalTime: 0,
      averageGlutenFormation: 0.0,
      finalMoisturePercentage: defaultMoisture, // 최종 수분 흡수율 추가
      efficiency: 0.0,
      overallScore: 0.0,
      stepCount: 0,
      finalDoughState: '',
      stepProgressionAnalysis: {},
      speedDistributionAnalysis: {},
      timeOptimizationAnalysis: {},
      integratedPerformanceAnalysis: {},
      processOptimizationSuggestions: [],
      stepProgressionDetails: [],
      analysisVersion: '1.0',
      analysisTimestamp: '',
      dataUtilizationRate: '0%',
    );
  }
}

/// 환경 분석 결과
class EnvironmentAnalysisResult {
  final List<String> recommendations;
  final Map<String, double> scores;
  final bool isOptimal;

  const EnvironmentAnalysisResult({
    required this.recommendations,
    required this.scores,
    required this.isOptimal,
  });

  factory EnvironmentAnalysisResult.empty() {
    return const EnvironmentAnalysisResult(
      recommendations: [],
      scores: {},
      isOptimal: false,
    );
  }
}

/// 성능 모니터링 데이터
class PerformanceMetrics {
  final Duration analysisTime;
  final int cacheHits;
  final int cacheMisses;
  final double memoryUsage;

  const PerformanceMetrics({
    required this.analysisTime,
    required this.cacheHits,
    required this.cacheMisses,
    required this.memoryUsage,
  });

  double get cacheHitRate =>
      cacheHits + cacheMisses > 0 ? cacheHits / (cacheHits + cacheMisses) : 0.0;
}

/// 탭 상태 관리
enum SousChefTab {
  analysis,
  improvement,
  realTimeRecipe;

  String get displayName {
    switch (this) {
      case SousChefTab.analysis:
        return '분석';
      case SousChefTab.improvement:
        return '개선방법';
      case SousChefTab.realTimeRecipe:
        return '실시간 레시피';
    }
  }
}

/// 모듈 상태
class ModuleState {
  final String id;
  final String name;
  final bool isActive;
  final Map<String, dynamic> settings;

  const ModuleState({
    required this.id,
    required this.name,
    required this.isActive,
    required this.settings,
  });

  ModuleState copyWith({
    String? id,
    String? name,
    bool? isActive,
    Map<String, dynamic>? settings,
  }) {
    return ModuleState(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
    );
  }
}

/// 분석 설정
class AnalysisSettings {
  final bool enableRealTimeFeedback;
  final bool enableRPMMode;
  final bool enableEffectsVisualization;
  final int maxAnalysisTimeSeconds;

  const AnalysisSettings({
    this.enableRealTimeFeedback = true,
    this.enableRPMMode = true,
    this.enableEffectsVisualization = true,
    this.maxAnalysisTimeSeconds = 30,
  });

  AnalysisSettings copyWith({
    bool? enableRealTimeFeedback,
    bool? enableRPMMode,
    bool? enableEffectsVisualization,
    int? maxAnalysisTimeSeconds,
  }) {
    return AnalysisSettings(
      enableRealTimeFeedback:
          enableRealTimeFeedback ?? this.enableRealTimeFeedback,
      enableRPMMode: enableRPMMode ?? this.enableRPMMode,
      enableEffectsVisualization:
          enableEffectsVisualization ?? this.enableEffectsVisualization,
      maxAnalysisTimeSeconds:
          maxAnalysisTimeSeconds ?? this.maxAnalysisTimeSeconds,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'enableRealTimeFeedback': enableRealTimeFeedback,
      'enableRPMMode': enableRPMMode,
      'enableEffectsVisualization': enableEffectsVisualization,
      'maxAnalysisTimeSeconds': maxAnalysisTimeSeconds,
    };
  }

  /// JSON에서 생성
  factory AnalysisSettings.fromJson(Map<String, dynamic> json) {
    return AnalysisSettings(
      enableRealTimeFeedback: json['enableRealTimeFeedback'] as bool? ?? true,
      enableRPMMode: json['enableRPMMode'] as bool? ?? true,
      enableEffectsVisualization:
          json['enableEffectsVisualization'] as bool? ?? true,
      maxAnalysisTimeSeconds: json['maxAnalysisTimeSeconds'] as int? ?? 30,
    );
  }
}
