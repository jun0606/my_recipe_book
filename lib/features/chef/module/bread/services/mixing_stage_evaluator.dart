// lib/modules/bread/services/mixing_stage_evaluator.dart
// 믹싱 단계별 평가 시스템
// 전단계, 중단계, 후단계 별로 다른 평가 기준 적용

import '../../../core/types/unified_types.dart';
import '../../../models/ingredient.dart';
import '../types/bread_types.dart';
import '../models/integrated_mixing_analysis_types.dart';
import 'dough_type_analyzer.dart';

/// 단계별 평가 결과
class StageEvaluationResult {
  /// 단계 번호 (1부터 시작)
  final int stageNumber;

  /// 단계 유형
  final MixingStageType stageType;

  /// 평가 점수 (0.0 ~ 1.0)
  final double score;

  /// 문제점 목록
  final List<String> issues;

  /// 개선 권장사항
  final List<String> recommendations;

  /// 상세 분석 데이터
  final Map<String, dynamic> analysisData;

  /// 평가 타임스탬프
  final DateTime evaluatedAt;

  const StageEvaluationResult({
    required this.stageNumber,
    required this.stageType,
    required this.score,
    required this.issues,
    required this.recommendations,
    required this.analysisData,
    required this.evaluatedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stageNumber': stageNumber,
      'stageType': stageType.name,
      'score': score,
      'issues': issues,
      'recommendations': recommendations,
      'analysisData': analysisData,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory StageEvaluationResult.fromJson(Map<String, dynamic> json) {
    return StageEvaluationResult(
      stageNumber: json['stageNumber'] as int,
      stageType: MixingStageType.values.firstWhere(
        (type) => type.name == json['stageType'],
        orElse: () => MixingStageType.intermediate,
      ),
      score: (json['score'] as num).toDouble(),
      issues: List<String>.from(json['issues'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      analysisData: Map<String, dynamic>.from(json['analysisData'] as Map),
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'StageEvaluationResult('
        'stage: $stageNumber, '
        'type: ${stageType.description}, '
        'score: ${(score * 100).toStringAsFixed(1)}%)';
  }
}

/// 믹싱 단계 유형 열거형
enum MixingStageType {
  /// 전단계 (초기 믹싱)
  initial,

  /// 중단계 (본격 믹싱)
  intermediate,

  /// 후단계 (마무리 믹싱)
  final_,

  /// 알 수 없음
  unknown;

  /// 단계 설명
  String get description {
    switch (this) {
      case MixingStageType.initial:
        return '전단계 (초기 믹싱)';
      case MixingStageType.intermediate:
        return '중단계 (본격 믹싱)';
      case MixingStageType.final_:
        return '후단계 (마무리 믹싱)';
      case MixingStageType.unknown:
        return '알 수 없음';
    }
  }

  /// 최적 속도 범위
  Map<String, dynamic> get optimalSpeedRange {
    switch (this) {
      case MixingStageType.initial:
        return {'min': 3, 'max': 5, 'recommended': 4};
      case MixingStageType.intermediate:
        return {'min': 4, 'max': 7, 'recommended': 5};
      case MixingStageType.final_:
        return {'min': 2, 'max': 4, 'recommended': 3};
      case MixingStageType.unknown:
        return {'min': 3, 'max': 6, 'recommended': 4};
    }
  }

  /// 최적 시간 범위 (분)
  Map<String, dynamic> get optimalTimeRange {
    switch (this) {
      case MixingStageType.initial:
        return {'min': 2, 'max': 5, 'recommended': 3};
      case MixingStageType.intermediate:
        return {'min': 5, 'max': 12, 'recommended': 8};
      case MixingStageType.final_:
        return {'min': 1, 'max': 4, 'recommended': 2};
      case MixingStageType.unknown:
        return {'min': 3, 'max': 8, 'recommended': 5};
    }
  }
}

/// 단계별 평가 기준
class MixingStageCriteria {
  /// 속도 평가 가중치
  final double speedWeight;

  /// 시간 평가 가중치
  final double timeWeight;

  /// 환경 평가 가중치
  final double environmentWeight;

  /// 온도 민감도
  final double temperatureSensitivity;

  /// 습도 민감도
  final double humiditySensitivity;

  const MixingStageCriteria({
    required this.speedWeight,
    required this.timeWeight,
    required this.environmentWeight,
    required this.temperatureSensitivity,
    required this.humiditySensitivity,
  });

  /// 단계 유형별 기준 팩토리
  factory MixingStageCriteria.forStage(MixingStageType stageType) {
    switch (stageType) {
      case MixingStageType.initial:
        return const MixingStageCriteria(
          speedWeight: 0.4,
          timeWeight: 0.3,
          environmentWeight: 0.3,
          temperatureSensitivity: 0.7,
          humiditySensitivity: 0.5,
        );
      case MixingStageType.intermediate:
        return const MixingStageCriteria(
          speedWeight: 0.5,
          timeWeight: 0.4,
          environmentWeight: 0.1,
          temperatureSensitivity: 0.3,
          humiditySensitivity: 0.3,
        );
      case MixingStageType.final_:
        return const MixingStageCriteria(
          speedWeight: 0.6,
          timeWeight: 0.3,
          environmentWeight: 0.1,
          temperatureSensitivity: 0.2,
          humiditySensitivity: 0.4,
        );
      case MixingStageType.unknown:
        return const MixingStageCriteria(
          speedWeight: 0.4,
          timeWeight: 0.4,
          environmentWeight: 0.2,
          temperatureSensitivity: 0.4,
          humiditySensitivity: 0.4,
        );
    }
  }
}

/// 믹싱 단계 평가기
class MixingStageEvaluator {
  /// 기본 생성자
  const MixingStageEvaluator();

  /// 단일 단계 평가
  Future<StageEvaluationResult> evaluateStage({
    required int stageNumber,
    required UnifiedProcess process,
    required DoughType doughType,
    required BreadUserData userData,
    required Map<String, dynamic> previousStageData,
  }) async {
    // 단계 유형 결정
    final stageType = _determineStageType(stageNumber, process);

    // 평가 기준 가져오기
    final criteria = MixingStageCriteria.forStage(stageType);

    // 각 요소별 평가
    final speedScore = _evaluateSpeed(process, doughType, stageType);
    final timeScore = _evaluateTime(process, doughType, stageType);
    final environmentScore =
        _evaluateEnvironment(userData, criteria, doughType);

    // 종합 점수 계산
    final overallScore = _calculateOverallScore(
      speedScore: speedScore,
      timeScore: timeScore,
      environmentScore: environmentScore,
      criteria: criteria,
    );

    // 문제점 및 권장사항 생성
    final issues = _identifyStageIssues(
      speedScore: speedScore,
      timeScore: timeScore,
      environmentScore: environmentScore,
      criteria: criteria,
    );

    final recommendations = _generateStageRecommendations(
      stageType: stageType,
      doughType: doughType,
      overallScore: overallScore,
      issues: issues,
    );

    // 분석 데이터
    final analysisData = {
      'stageType': stageType.name,
      'speedScore': speedScore,
      'timeScore': timeScore,
      'environmentScore': environmentScore,
      'criteria': {
        'speedWeight': criteria.speedWeight,
        'timeWeight': criteria.timeWeight,
        'environmentWeight': criteria.environmentWeight,
      },
      'processParameters': process.parameters,
      'doughType': doughType.name,
      'previousStageData': previousStageData,
    };

    return StageEvaluationResult(
      stageNumber: stageNumber,
      stageType: stageType,
      score: overallScore,
      issues: issues,
      recommendations: recommendations,
      analysisData: analysisData,
      evaluatedAt: DateTime.now(),
    );
  }

  /// 다중 단계 평가
  Future<List<StageEvaluationResult>> evaluateStages({
    required List<UnifiedProcess> processes,
    required DoughType doughType,
    required BreadUserData userData,
  }) async {
    final results = <StageEvaluationResult>[];
    var previousStageData = <String, dynamic>{};

    for (int i = 0; i < processes.length; i++) {
      if (processes[i].type != 'mixing') continue;

      final result = await evaluateStage(
        stageNumber: i + 1,
        process: processes[i],
        doughType: doughType,
        userData: userData,
        previousStageData: previousStageData,
      );

      results.add(result);

      // 다음 단계의 참고 데이터로 사용
      previousStageData = {
        'stageNumber': i + 1,
        'score': result.score,
        'stageType': result.stageType.name,
        'issues': result.issues,
      };
    }

    return results;
  }

  /// 단계 유형 결정
  MixingStageType _determineStageType(int stageNumber, UnifiedProcess process) {
    final totalStages = _estimateTotalStages(process);
    final relativePosition = stageNumber / totalStages;

    if (relativePosition <= 0.3) {
      return MixingStageType.initial;
    } else if (relativePosition <= 0.8) {
      return MixingStageType.intermediate;
    } else {
      return MixingStageType.final_;
    }
  }

  /// 총 단계 수 추정
  int _estimateTotalStages(UnifiedProcess process) {
    // 프로세스 파라미터에서 단계 정보를 추출하거나 기본값 사용
    final parameters = process.parameters;
    if (parameters != null && parameters.containsKey('totalStages')) {
      return parameters['totalStages'] as int;
    }
    return 3; // 기본적으로 3단계로 가정
  }

  /// 속도 평가
  double _evaluateSpeed(
      UnifiedProcess process, DoughType doughType, MixingStageType stageType) {
    final parameters = process.parameters;
    if (parameters == null || !parameters.containsKey('speed')) {
      return 0.5; // 기본 중간 점수
    }

    final speedValue = _parseSpeedValue(parameters['speed']);
    final optimalRange = stageType.optimalSpeedRange;
    final minSpeed = optimalRange['min'] as int;
    final maxSpeed = optimalRange['max'] as int;
    final recommendedSpeed = optimalRange['recommended'] as int;

    // 최적 속도와의 차이 계산
    final speedDiff = (speedValue - recommendedSpeed).abs();
    const tolerance = 1; // 허용 오차

    if (speedDiff <= tolerance) {
      return 1.0; // 최적
    } else if (speedValue >= minSpeed && speedValue <= maxSpeed) {
      return 0.7; // 양호
    } else {
      return 0.3; // 부적절
    }
  }

  /// 시간 평가
  double _evaluateTime(
      UnifiedProcess process, DoughType doughType, MixingStageType stageType) {
    final duration = process.duration.inMinutes;
    final optimalRange = stageType.optimalTimeRange;
    final minTime = optimalRange['min'] as int;
    final maxTime = optimalRange['max'] as int;
    final recommendedTime = optimalRange['recommended'] as int;

    // 최적 시간과의 차이 계산
    final timeDiff = (duration - recommendedTime).abs();
    const tolerance = 2; // 허용 오차 (분)

    if (timeDiff <= tolerance) {
      return 1.0; // 최적
    } else if (duration >= minTime && duration <= maxTime) {
      return 0.7; // 양호
    } else {
      return 0.3; // 부적절
    }
  }

  /// 환경 평가
  double _evaluateEnvironment(
    BreadUserData userData,
    MixingStageCriteria criteria,
    DoughType doughType,
  ) {
    final environment = userData.environment;
    final temperature = environment.temperature;
    final humidity = environment.humidity;

    // 온도 평가
    final tempScore = _evaluateTemperature(temperature, doughType);
    final humidityScore = _evaluateHumidity(humidity, doughType);

    // 가중치 적용
    return (tempScore * criteria.temperatureSensitivity) +
        (humidityScore * criteria.humiditySensitivity);
  }

  /// 온도 평가
  double _evaluateTemperature(double temperature, DoughType doughType) {
    // 반도 타입별 최적 온도 범위
    Map<String, double> optimalRange;

    switch (doughType) {
      case DoughType.sourdough:
        optimalRange = {'min': 20, 'max': 25, 'ideal': 22};
        break;
      case DoughType.lean:
        optimalRange = {'min': 22, 'max': 28, 'ideal': 25};
        break;
      case DoughType.rich:
        optimalRange = {'min': 20, 'max': 26, 'ideal': 23};
        break;
      case DoughType.highHydration:
        optimalRange = {'min': 18, 'max': 24, 'ideal': 21};
        break;
      default:
        optimalRange = {'min': 20, 'max': 28, 'ideal': 24};
    }

    final min = optimalRange['min']!;
    final max = optimalRange['max']!;
    final ideal = optimalRange['ideal']!;

    if (temperature >= min && temperature <= max) {
      // 이상적인 온도와의 차이 계산
      final tempDiff = (temperature - ideal).abs();
      const tolerance = 2.0;

      if (tempDiff <= tolerance) {
        return 1.0;
      } else {
        return 0.7;
      }
    } else {
      return 0.4;
    }
  }

  /// 습도 평가
  double _evaluateHumidity(double humidity, DoughType doughType) {
    // 반도 타입별 최적 습도 범위
    Map<String, double> optimalRange;

    switch (doughType) {
      case DoughType.sourdough:
        optimalRange = {'min': 60, 'max': 80, 'ideal': 70};
        break;
      case DoughType.highHydration:
        optimalRange = {'min': 55, 'max': 75, 'ideal': 65};
        break;
      case DoughType.lean:
        optimalRange = {'min': 50, 'max': 70, 'ideal': 60};
        break;
      default:
        optimalRange = {'min': 50, 'max': 75, 'ideal': 62};
    }

    final min = optimalRange['min']!;
    final max = optimalRange['max']!;
    final ideal = optimalRange['ideal']!;

    if (humidity >= min && humidity <= max) {
      final humidityDiff = (humidity - ideal).abs();
      const tolerance = 5.0;

      if (humidityDiff <= tolerance) {
        return 1.0;
      } else {
        return 0.7;
      }
    } else {
      return 0.4;
    }
  }

  /// 종합 점수 계산
  double _calculateOverallScore({
    required double speedScore,
    required double timeScore,
    required double environmentScore,
    required MixingStageCriteria criteria,
  }) {
    return (speedScore * criteria.speedWeight) +
        (timeScore * criteria.timeWeight) +
        (environmentScore * criteria.environmentWeight);
  }

  /// 단계별 문제점 식별
  List<String> _identifyStageIssues({
    required double speedScore,
    required double timeScore,
    required double environmentScore,
    required MixingStageCriteria criteria,
  }) {
    final issues = <String>[];

    if (speedScore < 0.5) {
      issues.add('믹싱 속도가 이 단계에 적합하지 않습니다');
    }

    if (timeScore < 0.5) {
      issues.add('믹싱 시간이 이 단계에 적절하지 않습니다');
    }

    if (environmentScore < 0.5) {
      issues.add('환경 조건이 이 단계에 최적 상태가 아닙니다');
    }

    return issues;
  }

  /// 단계별 권장사항 생성
  List<String> _generateStageRecommendations({
    required MixingStageType stageType,
    required DoughType doughType,
    required double overallScore,
    required List<String> issues,
  }) {
    final recommendations = <String>[];

    if (overallScore < 0.7) {
      // 단계별 특화된 조언
      switch (stageType) {
        case MixingStageType.initial:
          recommendations.add('전단계에서는 저속으로 충분한 수분 흡수를 유도하세요');
          recommendations.add('재료가 균일하게 섞이는지 확인하세요');
          break;

        case MixingStageType.intermediate:
          recommendations.add('중단계에서는 글루텐 네트워크 형성을 위해 적절한 속도 유지');
          recommendations.add('반죽의 탄력성을 주기적으로 확인하세요');
          break;

        case MixingStageType.final_:
          recommendations.add('후단계에서는 과도한 믹싱을 피하고 부드러운 마무리를 목표로 하세요');
          recommendations.add('반죽 표면이 매끄러운지 확인하세요');
          break;

        case MixingStageType.unknown:
          recommendations.add('믹싱 과정을 단계별로 구분하여 실행하세요');
          break;
      }

      // 반도 타입별 조언
      switch (doughType) {
        case DoughType.lean:
          recommendations.add('팡 도우의 경우 충분한 발효 시간을 확보하세요');
          break;
        case DoughType.rich:
          recommendations.add('리치 도우의 경우 온도를 낮춰 믹싱하세요');
          break;
        case DoughType.highHydration:
          recommendations.add('고수분 도우의 경우 강력한 믹서 사용을 권장합니다');
          break;
        case DoughType.sourdough:
          recommendations.add('사워도우의 경우 천연 효모 특성을 고려한 믹싱을 하세요');
          break;
        default:
          recommendations.add('${doughType.description}에 맞는 믹싱 전략을 적용하세요');
      }
    }

    return recommendations;
  }

  /// 속도 값 파싱
  int _parseSpeedValue(dynamic speedValue) {
    if (speedValue == null) return 4; // 기본 중속

    if (speedValue is int) return speedValue;
    if (speedValue is double) return speedValue.round();
    if (speedValue is String) {
      final speedStr = speedValue.toString().toLowerCase();

      // 한글 속도 표현 처리
      if (speedStr.contains('저속') || speedStr.contains('low')) return 3;
      if (speedStr.contains('중속') || speedStr.contains('medium')) return 5;
      if (speedStr.contains('고속') || speedStr.contains('high')) return 7;

      // 숫자 추출 시도
      final numberMatch = RegExp(r'(\d+)').firstMatch(speedStr);
      if (numberMatch != null) {
        return int.tryParse(numberMatch.group(1)!) ?? 4;
      }
    }

    return 4; // 기본값
  }
}

/// 단계별 평가기 팩토리
class MixingStageEvaluatorFactory {
  /// 기본 평가기 생성
  static MixingStageEvaluator createDefault() {
    return const MixingStageEvaluator();
  }

  /// 커스텀 평가기 생성
  static MixingStageEvaluator createCustom({
    // 향후 확장성을 위한 파라미터
    Map<String, dynamic>? customCriteria,
  }) {
    return const MixingStageEvaluator();
  }
}

/// 단계별 평가 헬퍼 클래스
class MixingStageEvaluationHelper {
  /// 평가 결과 요약
  static Map<String, dynamic> summarizeEvaluations(
      List<StageEvaluationResult> results) {
    if (results.isEmpty) {
      return {'error': '평가 결과가 없습니다'};
    }

    final totalScore =
        results.fold<double>(0, (sum, result) => sum + result.score);
    final averageScore = totalScore / results.length;

    final stageTypeCounts = <MixingStageType, int>{};
    final issuesByStage = <int, List<String>>{};
    final recommendationsByStage = <int, List<String>>{};

    for (final result in results) {
      stageTypeCounts[result.stageType] =
          (stageTypeCounts[result.stageType] ?? 0) + 1;
      issuesByStage[result.stageNumber] = result.issues;
      recommendationsByStage[result.stageNumber] = result.recommendations;
    }

    // 가장 큰 문제점들 추출
    final criticalIssues = results
        .where((result) => result.score < 0.5)
        .expand((result) => result.issues)
        .toSet()
        .toList();

    // 주요 개선사항 추출
    final keyRecommendations = results
        .where((result) => result.score < 0.7)
        .expand((result) => result.recommendations)
        .toSet()
        .take(5)
        .toList();

    return {
      'totalStages': results.length,
      'averageScore': averageScore,
      'stageTypeDistribution':
          stageTypeCounts.map((k, v) => MapEntry(k.name, v)),
      'criticalIssuesCount': criticalIssues.length,
      'criticalIssues': criticalIssues,
      'keyRecommendationsCount': keyRecommendations.length,
      'keyRecommendations': keyRecommendations,
      'issuesByStage': issuesByStage,
      'recommendationsByStage': recommendationsByStage,
      'evaluationTimestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 평가 결과 검증
  static bool validateEvaluationResult(StageEvaluationResult result) {
    if (result.stageNumber < 1) return false;
    if (result.score < 0.0 || result.score > 1.0) return false;
    if (result.analysisData.isEmpty) return false;
    return true;
  }

  /// 다중 평가 결과 검증
  static List<String> validateEvaluationResults(
      List<StageEvaluationResult> results) {
    final errors = <String>[];

    if (results.isEmpty) {
      errors.add('평가 결과가 비어있습니다');
      return errors;
    }

    // 연속성 검증
    for (int i = 0; i < results.length - 1; i++) {
      final current = results[i];
      final next = results[i + 1];

      if (next.stageNumber != current.stageNumber + 1) {
        errors.add(
            '단계 번호가 연속되지 않습니다: ${current.stageNumber} -> ${next.stageNumber}');
      }
    }

    // 개별 결과 검증
    for (final result in results) {
      if (!validateEvaluationResult(result)) {
        errors.add('단계 ${result.stageNumber}의 평가 결과가 유효하지 않습니다');
      }
    }

    return errors;
  }
}
