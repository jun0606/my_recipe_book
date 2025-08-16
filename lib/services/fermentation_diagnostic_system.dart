import 'dart:math';
import '../models/fermentation_scenario.dart';
import '../models/sous_chef_models.dart';
import 'real_time_fermentation_analyzer.dart';

/// 발효 상태 진단 시스템
/// AI 기반으로 현재 발효 상태를 진단하고 문제점을 조기 감지하는 시스템
class FermentationDiagnosticSystem {
  
  /// 종합적인 발효 상태 진단
  static FermentationDiagnosis diagnoseFermentationState({
    required double elapsedTime,
    required double totalTime,
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
    required FermentationStage stage,
    String? visualObservation,
    double? currentVolume,
    double? initialVolume,
  }) {
    // 1. 시간 기반 분석
    TimeBasedAnalysis timeAnalysis = _analyzeTimeProgress(elapsedTime, totalTime);
    
    // 2. 환경 조건 분석
    EnvironmentalAnalysis envAnalysis = _analyzeEnvironmentalConditions(
      currentTemp, currentHumidity, targetTemp, targetHumidity
    );
    
    // 3. 부피 변화 분석 (제공된 경우)
    VolumeAnalysis? volumeAnalysis;
    if (currentVolume != null && initialVolume != null) {
      volumeAnalysis = _analyzeVolumeChange(
        currentVolume, initialVolume, elapsedTime, totalTime, stage
      );
    }
    
    // 4. 종합 진단
    OverallDiagnosis overallDiagnosis = _generateOverallDiagnosis(
      timeAnalysis, envAnalysis, volumeAnalysis, stage
    );
    
    // 5. 조치 방안 생성
    List<ActionRecommendation> actions = _generateActionRecommendations(
      overallDiagnosis, envAnalysis, timeAnalysis, stage
    );
    
    // 6. 위험도 평가
    RiskAssessment riskAssessment = _assessRisks(
      overallDiagnosis, envAnalysis, timeAnalysis, elapsedTime, totalTime
    );
    
    return FermentationDiagnosis(
      overallState: overallDiagnosis.state,
      confidence: overallDiagnosis.confidence,
      timeAnalysis: timeAnalysis,
      environmentalAnalysis: envAnalysis,
      volumeAnalysis: volumeAnalysis,
      actionRecommendations: actions,
      riskAssessment: riskAssessment,
      diagnosticNotes: overallDiagnosis.notes,
    );
  }
  
  /// 시간 진행 분석
  static TimeBasedAnalysis _analyzeTimeProgress(double elapsedTime, double totalTime) {
    double timeRatio = elapsedTime / totalTime;
    String status;
    double score;
    List<String> observations = [];
    
    if (timeRatio < 0.2) {
      status = '초기 단계';
      score = 0.8;
      observations.add('발효가 막 시작된 단계입니다');
    } else if (timeRatio < 0.5) {
      status = '전반부';
      score = 0.9;
      observations.add('발효가 활발히 진행 중입니다');
    } else if (timeRatio < 0.8) {
      status = '중반부';
      score = 1.0;
      observations.add('발효의 핵심 단계입니다');
    } else if (timeRatio < 1.0) {
      status = '후반부';
      score = 0.9;
      observations.add('발효 완료가 임박했습니다');
    } else if (timeRatio < 1.2) {
      status = '예정 시간 초과';
      score = 0.7;
      observations.add('예정 시간을 초과했습니다');
    } else {
      status = '과발효 위험';
      score = 0.4;
      observations.add('과발효 위험이 높습니다');
    }
    
    return TimeBasedAnalysis(
      timeRatio: timeRatio,
      status: status,
      score: score,
      observations: observations,
    );
  }
  
  /// 환경 조건 분석
  static EnvironmentalAnalysis _analyzeEnvironmentalConditions(
    double currentTemp, double currentHumidity, double targetTemp, double targetHumidity
  ) {
    double tempDiff = (currentTemp - targetTemp).abs();
    double humidityDiff = (currentHumidity - targetHumidity).abs();
    
    // 온도 분석
    String tempStatus;
    double tempScore;
    if (tempDiff < 1) {
      tempStatus = '최적';
      tempScore = 1.0;
    } else if (tempDiff < 3) {
      tempStatus = '양호';
      tempScore = 0.8;
    } else if (tempDiff < 5) {
      tempStatus = '주의';
      tempScore = 0.6;
    } else {
      tempStatus = '위험';
      tempScore = 0.3;
    }
    
    // 습도 분석
    String humidityStatus;
    double humidityScore;
    if (humidityDiff < 5) {
      humidityStatus = '최적';
      humidityScore = 1.0;
    } else if (humidityDiff < 10) {
      humidityStatus = '양호';
      humidityScore = 0.8;
    } else if (humidityDiff < 20) {
      humidityStatus = '주의';
      humidityScore = 0.6;
    } else {
      humidityStatus = '위험';
      humidityScore = 0.3;
    }
    
    List<String> issues = [];
    if (currentTemp > targetTemp + 3) {
      issues.add('온도가 너무 높습니다 (+${tempDiff.toStringAsFixed(1)}°C)');
    } else if (currentTemp < targetTemp - 3) {
      issues.add('온도가 너무 낮습니다 (-${tempDiff.toStringAsFixed(1)}°C)');
    }
    
    if (currentHumidity < targetHumidity - 10) {
      issues.add('습도가 부족합니다 (-${humidityDiff.toStringAsFixed(1)}%)');
    } else if (currentHumidity > targetHumidity + 10) {
      issues.add('습도가 과도합니다 (+${humidityDiff.toStringAsFixed(1)}%)');
    }
    
    return EnvironmentalAnalysis(
      temperatureStatus: tempStatus,
      temperatureScore: tempScore,
      humidityStatus: humidityStatus,
      humidityScore: humidityScore,
      issues: issues,
    );
  }
  
  /// 부피 변화 분석
  static VolumeAnalysis _analyzeVolumeChange(
    double currentVolume, double initialVolume, double elapsedTime, double totalTime, FermentationStage stage
  ) {
    double volumeRatio = currentVolume / initialVolume;
    double timeRatio = elapsedTime / totalTime;
    
    // 단계별 예상 부피 비율
    double expectedVolumeRatio;
    switch (stage) {
      case FermentationStage.bulk:
        expectedVolumeRatio = 1.0 + (timeRatio * 0.8); // 1.0 → 1.8배
        break;
      case FermentationStage.finalProof:
        expectedVolumeRatio = 1.0 + (timeRatio * 0.5); // 1.0 → 1.5배
        break;
      default:
        expectedVolumeRatio = 1.0 + (timeRatio * 0.6); // 기본값
    }
    
    double deviation = (volumeRatio - expectedVolumeRatio).abs();
    String status;
    double score;
    List<String> observations = [];
    
    if (deviation < 0.1) {
      status = '정상';
      score = 1.0;
      observations.add('예상대로 발효가 진행되고 있습니다');
    } else if (deviation < 0.2) {
      status = '양호';
      score = 0.8;
      observations.add('약간의 편차가 있지만 정상 범위입니다');
    } else if (volumeRatio < expectedVolumeRatio - 0.2) {
      status = '발효 부족';
      score = 0.5;
      observations.add('예상보다 발효가 느립니다');
    } else {
      status = '과발효 위험';
      score = 0.4;
      observations.add('예상보다 발효가 빠릅니다');
    }
    
    return VolumeAnalysis(
      currentRatio: volumeRatio,
      expectedRatio: expectedVolumeRatio,
      status: status,
      score: score,
      observations: observations,
    );
  }
  
  /// 종합 진단 생성
  static OverallDiagnosis _generateOverallDiagnosis(
    TimeBasedAnalysis timeAnalysis,
    EnvironmentalAnalysis envAnalysis,
    VolumeAnalysis? volumeAnalysis,
    FermentationStage stage,
  ) {
    // 가중 평균으로 종합 점수 계산
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    // 시간 분석 (가중치: 0.3)
    totalScore += timeAnalysis.score * 0.3;
    totalWeight += 0.3;
    
    // 환경 분석 (가중치: 0.4)
    double envScore = (envAnalysis.temperatureScore + envAnalysis.humidityScore) / 2;
    totalScore += envScore * 0.4;
    totalWeight += 0.4;
    
    // 부피 분석 (가중치: 0.3, 있는 경우만)
    if (volumeAnalysis != null) {
      totalScore += volumeAnalysis.score * 0.3;
      totalWeight += 0.3;
    }
    
    double finalScore = totalScore / totalWeight;
    
    // 상태 결정 (기존 FermentationState enum 사용)
    FermentationState state;
    double confidence;
    List<String> notes = [];
    
    if (finalScore > 0.9) {
      state = FermentationState.optimal;
      confidence = 0.95;
      notes.add('발효가 이상적으로 진행되고 있습니다');
    } else if (finalScore > 0.7) {
      state = FermentationState.readyToBake; // good 대신 readyToBake 사용
      confidence = 0.85;
      notes.add('발효가 양호하게 진행되고 있습니다');
    } else if (finalScore > 0.5) {
      state = FermentationState.optimal; // acceptable 대신 optimal 사용
      confidence = 0.75;
      notes.add('발효 상태에 주의가 필요합니다');
    } else if (finalScore > 0.3) {
      state = FermentationState.underFermented; // problematic 대신 underFermented 사용
      confidence = 0.65;
      notes.add('발효에 문제가 있을 수 있습니다');
    } else {
      state = FermentationState.overFermented; // critical 대신 overFermented 사용
      confidence = 0.55;
      notes.add('발효 상태가 심각합니다');
    }
    
    return OverallDiagnosis(
      state: state,
      confidence: confidence,
      score: finalScore,
      notes: notes,
    );
  }
  
  /// 조치 방안 생성
  static List<ActionRecommendation> _generateActionRecommendations(
    OverallDiagnosis diagnosis,
    EnvironmentalAnalysis envAnalysis,
    TimeBasedAnalysis timeAnalysis,
    FermentationStage stage,
  ) {
    List<ActionRecommendation> actions = [];
    
    // 환경 조건 개선
    if (envAnalysis.temperatureScore < 0.7) {
      actions.add(ActionRecommendation(
        type: ActionType.environmental,
        priority: Priority.high,
        title: '온도 조정',
        description: '발효 온도를 목표 범위로 조정하세요',
        specificSteps: [
          '현재 온도를 확인하세요',
          '발효 환경의 온도를 조절하세요',
          '10분 후 다시 측정하세요',
        ],
      ));
    }
    
    if (envAnalysis.humidityScore < 0.7) {
      actions.add(ActionRecommendation(
        type: ActionType.environmental,
        priority: Priority.medium,
        title: '습도 조정',
        description: '발효 습도를 목표 범위로 조정하세요',
        specificSteps: [
          '습도계로 현재 습도를 확인하세요',
          '젖은 수건이나 가습기를 사용하세요',
          '반죽 표면이 마르지 않도록 덮개를 사용하세요',
        ],
      ));
    }
    
    // 시간 기반 조치
    if (timeAnalysis.timeRatio > 1.1) {
      actions.add(ActionRecommendation(
        type: ActionType.timing,
        priority: Priority.high,
        title: '과발효 방지',
        description: '발효 시간이 초과되었습니다',
        specificSteps: [
          '손가락 테스트로 발효 상태를 확인하세요',
          '과발효되지 않았다면 다음 단계로 진행하세요',
          '과발효된 경우 온도를 낮추고 빠르게 처리하세요',
        ],
      ));
    }
    
    // 단계별 특화 조치
    switch (stage) {
      case FermentationStage.bulk:
        if (timeAnalysis.timeRatio > 0.3 && timeAnalysis.timeRatio < 0.7) {
          actions.add(ActionRecommendation(
            type: ActionType.technique,
            priority: Priority.medium,
            title: '폴딩 실시',
            description: '글루텐 강화를 위해 폴딩을 실시하세요',
            specificSteps: [
              '반죽을 조심스럽게 늘려서 접으세요',
              '4방향으로 폴딩을 실시하세요',
              '30분 후 다시 폴딩하세요',
            ],
          ));
        }
        break;
      case FermentationStage.finalProof:
        actions.add(ActionRecommendation(
          type: ActionType.monitoring,
          priority: Priority.high,
          title: '최종 발효 모니터링',
          description: '최종 발효 상태를 주의 깊게 관찰하세요',
          specificSteps: [
            '15분마다 부피 변화를 확인하세요',
            '손가락 테스트를 준비하세요',
            '오븐을 예열하기 시작하세요',
          ],
        ));
        break;
      default:
        break;
    }
    
    return actions;
  }
  
  /// 위험도 평가
  static RiskAssessment _assessRisks(
    OverallDiagnosis diagnosis,
    EnvironmentalAnalysis envAnalysis,
    TimeBasedAnalysis timeAnalysis,
    double elapsedTime,
    double totalTime,
  ) {
    List<Risk> risks = [];
    RiskLevel overallRisk = RiskLevel.low;
    
    // 과발효 위험
    if (timeAnalysis.timeRatio > 1.2) {
      risks.add(Risk(
        type: RiskType.overFermentation,
        level: RiskLevel.high,
        description: '과발효로 인한 품질 저하 위험',
        probability: 0.8,
        impact: ' 빵의 조직이 거칠어지고 신맛이 날 수 있습니다',
      ));
      overallRisk = RiskLevel.high;
    } else if (timeAnalysis.timeRatio > 1.1) {
      risks.add(Risk(
        type: RiskType.overFermentation,
        level: RiskLevel.medium,
        description: '과발효 주의 필요',
        probability: 0.5,
        impact: '발효 상태를 주의 깊게 관찰해야 합니다',
      ));
      if (overallRisk == RiskLevel.low) overallRisk = RiskLevel.medium;
    }
    
    // 발효 부족 위험
    if (timeAnalysis.timeRatio > 0.8 && diagnosis.score < 0.6) {
      risks.add(Risk(
        type: RiskType.underFermentation,
        level: RiskLevel.medium,
        description: '발효 부족으로 인한 품질 저하 위험',
        probability: 0.6,
        impact: '빵이 딱딱하고 부피가 작을 수 있습니다',
      ));
      if (overallRisk == RiskLevel.low) overallRisk = RiskLevel.medium;
    }
    
    // 환경 조건 위험
    if (envAnalysis.temperatureScore < 0.5 || envAnalysis.humidityScore < 0.5) {
      risks.add(Risk(
        type: RiskType.environmentalFailure,
        level: RiskLevel.medium,
        description: '부적절한 환경 조건',
        probability: 0.7,
        impact: '발효가 제대로 진행되지 않을 수 있습니다',
      ));
      if (overallRisk == RiskLevel.low) overallRisk = RiskLevel.medium;
    }
    
    return RiskAssessment(
      overallRisk: overallRisk,
      risks: risks,
      riskScore: _calculateRiskScore(risks),
    );
  }
  
  /// 위험 점수 계산
  static double _calculateRiskScore(List<Risk> risks) {
    if (risks.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (Risk risk in risks) {
      double levelMultiplier = risk.level == RiskLevel.high ? 1.0 : 
                              risk.level == RiskLevel.medium ? 0.6 : 0.3;
      totalScore += risk.probability * levelMultiplier;
    }
    
    return totalScore / risks.length;
  }
}

// 데이터 모델들
class FermentationDiagnosis {
  final FermentationState overallState;
  final double confidence;
  final TimeBasedAnalysis timeAnalysis;
  final EnvironmentalAnalysis environmentalAnalysis;
  final VolumeAnalysis? volumeAnalysis;
  final List<ActionRecommendation> actionRecommendations;
  final RiskAssessment riskAssessment;
  final List<String> diagnosticNotes;
  
  const FermentationDiagnosis({
    required this.overallState,
    required this.confidence,
    required this.timeAnalysis,
    required this.environmentalAnalysis,
    this.volumeAnalysis,
    required this.actionRecommendations,
    required this.riskAssessment,
    required this.diagnosticNotes,
  });
}

class TimeBasedAnalysis {
  final double timeRatio;
  final String status;
  final double score;
  final List<String> observations;
  
  const TimeBasedAnalysis({
    required this.timeRatio,
    required this.status,
    required this.score,
    required this.observations,
  });
}

class EnvironmentalAnalysis {
  final String temperatureStatus;
  final double temperatureScore;
  final String humidityStatus;
  final double humidityScore;
  final List<String> issues;
  
  const EnvironmentalAnalysis({
    required this.temperatureStatus,
    required this.temperatureScore,
    required this.humidityStatus,
    required this.humidityScore,
    required this.issues,
  });
}

class VolumeAnalysis {
  final double currentRatio;
  final double expectedRatio;
  final String status;
  final double score;
  final List<String> observations;
  
  const VolumeAnalysis({
    required this.currentRatio,
    required this.expectedRatio,
    required this.status,
    required this.score,
    required this.observations,
  });
}

class OverallDiagnosis {
  final FermentationState state;
  final double confidence;
  final double score;
  final List<String> notes;
  
  const OverallDiagnosis({
    required this.state,
    required this.confidence,
    required this.score,
    required this.notes,
  });
}

class ActionRecommendation {
  final ActionType type;
  final Priority priority;
  final String title;
  final String description;
  final List<String> specificSteps;
  
  const ActionRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.specificSteps,
  });
}

class RiskAssessment {
  final RiskLevel overallRisk;
  final List<Risk> risks;
  final double riskScore;
  
  const RiskAssessment({
    required this.overallRisk,
    required this.risks,
    required this.riskScore,
  });
}

class Risk {
  final RiskType type;
  final RiskLevel level;
  final String description;
  final double probability;
  final String impact;
  
  const Risk({
    required this.type,
    required this.level,
    required this.description,
    required this.probability,
    required this.impact,
  });
}

// FermentationState는 sous_chef_models.dart에서 import

enum ActionType {
  environmental,
  timing,
  technique,
  monitoring,
}

enum Priority {
  high,
  medium,
  low,
}

enum RiskLevel {
  high,
  medium,
  low,
}

enum RiskType {
  overFermentation,
  underFermentation,
  environmentalFailure,
}