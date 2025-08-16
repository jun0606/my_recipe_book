/// 실시간 적응 엔진 V2
/// 환경 변화를 감지하고 시나리오를 실시간으로 조정하는 핵심 엔진

import 'dart:async';
import 'dart:math' as math;
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';

/// 환경 변화 타입
enum EnvironmentalChangeType {
  temperature,    // 온도 변화
  humidity,       // 습도 변화
  pressure,       // 기압 변화
  combined,       // 복합 변화
}

/// 환경 변화 정보
class EnvironmentalChange {
  final EnvironmentalChangeType type;
  final EnvironmentalConditions oldConditions;
  final EnvironmentalConditions newConditions;
  final double magnitude;         // 변화 크기 (0.0 ~ 1.0)
  final DateTime detectedAt;

  EnvironmentalChange({
    required this.type,
    required this.oldConditions,
    required this.newConditions,
    required this.magnitude,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  /// 온도 변화량
  double get temperatureChange => (newConditions.temperature - oldConditions.temperature).abs();
  
  /// 습도 변화량
  double get humidityChange => (newConditions.humidity - oldConditions.humidity).abs();
  
  /// 기압 변화량
  double get pressureChange => (newConditions.pressure - oldConditions.pressure).abs();
}

/// 발효 상태 예측 결과
class FermentationStatePrediction {
  final FermentationState predictedState;
  final double confidence;        // 예측 신뢰도 (0.0 ~ 1.0)
  final Duration adjustedDuration; // 조정된 소요 시간
  final List<String> factors;    // 예측에 영향을 준 요인들
  final Map<String, double> metrics; // 상세 메트릭

  const FermentationStatePrediction({
    required this.predictedState,
    required this.confidence,
    required this.adjustedDuration,
    required this.factors,
    required this.metrics,
  });
}

/// 시나리오 조정 제안
class ScenarioAdjustment {
  final String reason;            // 조정 이유
  final double impactLevel;       // 영향도 (0.0 ~ 1.0)
  final List<StageAdjustment> stageAdjustments; // 단계별 조정
  final Map<String, dynamic> metadata; // 추가 정보

  const ScenarioAdjustment({
    required this.reason,
    required this.impactLevel,
    required this.stageAdjustments,
    this.metadata = const {},
  });
}

/// 단계별 조정 정보
class StageAdjustment {
  final int stageIndex;
  final String stageName;
  final Duration originalDuration;
  final Duration adjustedDuration;
  final TemperatureRange? adjustedTemperature;
  final HumidityRange? adjustedHumidity;
  final String adjustmentReason;

  const StageAdjustment({
    required this.stageIndex,
    required this.stageName,
    required this.originalDuration,
    required this.adjustedDuration,
    this.adjustedTemperature,
    this.adjustedHumidity,
    required this.adjustmentReason,
  });

  /// 시간 조정 비율
  double get timeAdjustmentRatio => adjustedDuration.inMinutes / originalDuration.inMinutes;
  
  /// 시간 변화량 (분)
  int get timeChange => adjustedDuration.inMinutes - originalDuration.inMinutes;
}

/// 실시간 적응 엔진
class RealTimeAdaptationEngine {
  static const double _temperatureThreshold = 3.0; // 온도 변화 임계값 (°C)
  static const double _humidityThreshold = 15.0;   // 습도 변화 임계값 (%)
  static const double _pressureThreshold = 10.0;   // 기압 변화 임계값 (hPa)

  /// 환경 변화 감지 및 분석
  static EnvironmentalChange? detectEnvironmentalChange(
    EnvironmentalConditions oldConditions,
    EnvironmentalConditions newConditions,
  ) {
    final tempChange = (newConditions.temperature - oldConditions.temperature).abs();
    final humidityChange = (newConditions.humidity - oldConditions.humidity).abs();
    final pressureChange = (newConditions.pressure - oldConditions.pressure).abs();

    // 변화 크기 계산
    final tempMagnitude = tempChange / _temperatureThreshold;
    final humidityMagnitude = humidityChange / _humidityThreshold;
    final pressureMagnitude = pressureChange / _pressureThreshold;

    // 가장 큰 변화 타입 결정
    EnvironmentalChangeType? changeType;
    double maxMagnitude = 0.0;

    if (tempMagnitude > 0.3) {
      changeType = EnvironmentalChangeType.temperature;
      maxMagnitude = tempMagnitude;
    }

    if (humidityMagnitude > 0.3 && humidityMagnitude > maxMagnitude) {
      changeType = EnvironmentalChangeType.humidity;
      maxMagnitude = humidityMagnitude;
    }

    if (pressureMagnitude > 0.3 && pressureMagnitude > maxMagnitude) {
      changeType = EnvironmentalChangeType.pressure;
      maxMagnitude = pressureMagnitude;
    }

    // 복합 변화 체크
    final significantChanges = [tempMagnitude, humidityMagnitude, pressureMagnitude]
        .where((m) => m > 0.3)
        .length;

    if (significantChanges > 1) {
      changeType = EnvironmentalChangeType.combined;
      maxMagnitude = math.sqrt(tempMagnitude * tempMagnitude + 
                              humidityMagnitude * humidityMagnitude + 
                              pressureMagnitude * pressureMagnitude) / math.sqrt(3);
    }

    // 유의미한 변화가 없으면 null 반환
    if (changeType == null || maxMagnitude < 0.3) {
      return null;
    }

    return EnvironmentalChange(
      type: changeType,
      oldConditions: oldConditions,
      newConditions: newConditions,
      magnitude: maxMagnitude.clamp(0.0, 1.0),
    );
  }

  /// 발효 상태 예측
  static FermentationStatePrediction predictFermentationState(
    FermentationScenarioV2 scenario,
    Duration elapsed,
    EnvironmentalConditions currentConditions,
  ) {
    final currentStage = scenario.getCurrentStage(elapsed);
    if (currentStage == null) {
      return FermentationStatePrediction(
        predictedState: FermentationState.readyToBake,
        confidence: 1.0,
        adjustedDuration: Duration.zero,
        factors: ['시나리오 완료'],
        metrics: {},
      );
    }

    // 환경 조건 분석
    final tempOptimality = _calculateTemperatureOptimality(
      currentConditions.temperature,
      currentStage.temperature.optimal,
    );
    final humidityOptimality = _calculateHumidityOptimality(
      currentConditions.humidity,
      currentStage.humidity.optimal,
    );

    // 발효 속도 계산
    final fermentationRate = _calculateFermentationRate(
      currentConditions.temperature,
      currentConditions.humidity,
      currentStage.temperature.optimal,
      currentStage.humidity.optimal,
    );

    // 진행률 계산
    final progress = scenario.getProgress(elapsed);
    final adjustedProgress = progress * fermentationRate;

    // 상태 예측
    FermentationState predictedState;
    double confidence;
    List<String> factors = [];

    if (adjustedProgress < 0.3) {
      predictedState = FermentationState.underFermented;
      confidence = 0.8;
      factors.add('발효 초기 단계');
    } else if (adjustedProgress < 0.8) {
      predictedState = FermentationState.optimal;
      confidence = tempOptimality * humidityOptimality;
      factors.add('정상 발효 진행');
    } else if (adjustedProgress < 1.1) {
      predictedState = FermentationState.readyToBake;
      confidence = 0.9;
      factors.add('발효 완료 임박');
    } else {
      predictedState = FermentationState.overFermented;
      confidence = 0.7;
      factors.add('과발효 위험');
    }

    // 환경 요인 추가
    if (tempOptimality < 0.7) {
      factors.add('온도 조건 부적절');
      confidence *= 0.8;
    }
    if (humidityOptimality < 0.7) {
      factors.add('습도 조건 부적절');
      confidence *= 0.9;
    }

    // 조정된 소요 시간 계산
    final remainingTime = scenario.getRemainingTime(elapsed);
    final adjustedDuration = Duration(
      minutes: (remainingTime.inMinutes / fermentationRate).round(),
    );

    return FermentationStatePrediction(
      predictedState: predictedState,
      confidence: confidence.clamp(0.0, 1.0),
      adjustedDuration: adjustedDuration,
      factors: factors,
      metrics: {
        'fermentationRate': fermentationRate,
        'temperatureOptimality': tempOptimality,
        'humidityOptimality': humidityOptimality,
        'progress': progress,
        'adjustedProgress': adjustedProgress,
      },
    );
  }

  /// 시나리오 조정 계산
  static ScenarioAdjustment calculateAdjustment(
    FermentationScenarioV2 scenario,
    EnvironmentalChange environmentalChange,
    Duration elapsed,
  ) {
    final impactLevel = _calculateImpactLevel(environmentalChange);
    final stageAdjustments = <StageAdjustment>[];

    // 현재 단계부터 조정
    final currentStageIndex = scenario.stages.indexWhere(
      (stage) => scenario.getCurrentStage(elapsed) == stage,
    );

    if (currentStageIndex == -1) {
      return ScenarioAdjustment(
        reason: '시나리오가 이미 완료됨',
        impactLevel: 0.0,
        stageAdjustments: [],
      );
    }

    // 남은 단계들에 대해 조정 계산
    for (int i = currentStageIndex; i < scenario.stages.length; i++) {
      final stage = scenario.stages[i];
      final adjustment = _calculateStageAdjustment(
        stage,
        environmentalChange,
        impactLevel,
      );
      
      if (adjustment != null) {
        stageAdjustments.add(adjustment);
      }
    }

    String reason = _generateAdjustmentReason(environmentalChange, impactLevel);

    return ScenarioAdjustment(
      reason: reason,
      impactLevel: impactLevel,
      stageAdjustments: stageAdjustments,
      metadata: {
        'changeType': environmentalChange.type.name,
        'changeMagnitude': environmentalChange.magnitude,
        'temperatureChange': environmentalChange.temperatureChange,
        'humidityChange': environmentalChange.humidityChange,
        'adjustedStages': stageAdjustments.length,
      },
    );
  }

  /// 조정된 시나리오 생성
  static FermentationScenarioV2 applyAdjustment(
    FermentationScenarioV2 originalScenario,
    ScenarioAdjustment adjustment,
  ) {
    final adjustedStages = List<FermentationStageV2>.from(originalScenario.stages);

    // 단계별 조정 적용
    for (final stageAdjustment in adjustment.stageAdjustments) {
      final stageIndex = stageAdjustment.stageIndex;
      if (stageIndex < adjustedStages.length) {
        final originalStage = adjustedStages[stageIndex];
        
        adjustedStages[stageIndex] = FermentationStageV2(
          name: originalStage.name,
          type: originalStage.type,
          duration: stageAdjustment.adjustedDuration,
          temperature: stageAdjustment.adjustedTemperature ?? originalStage.temperature,
          humidity: stageAdjustment.adjustedHumidity ?? originalStage.humidity,
          instructions: originalStage.instructions,
          automations: originalStage.automations,
          alerts: originalStage.alerts,
          description: originalStage.description,
          metadata: {
            ...originalStage.metadata,
            'adjusted': true,
            'adjustmentReason': stageAdjustment.adjustmentReason,
            'originalDuration': originalStage.duration.inMinutes,
            'adjustedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    }

    // 총 소요 시간 재계산
    final newTotalDuration = adjustedStages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );

    return originalScenario.copyWith(
      stages: adjustedStages,
      totalDuration: newTotalDuration,
      metadata: {
        ...originalScenario.metadata,
        'adapted': true,
        'adaptationReason': adjustment.reason,
        'adaptationImpact': adjustment.impactLevel,
        'adaptedAt': DateTime.now().toIso8601String(),
        'originalTotalDuration': originalScenario.totalDuration.inMinutes,
      },
    );
  }

  // Private Helper Methods

  static double _calculateImpactLevel(EnvironmentalChange change) {
    switch (change.type) {
      case EnvironmentalChangeType.temperature:
        return (change.temperatureChange / _temperatureThreshold).clamp(0.0, 1.0);
      
      case EnvironmentalChangeType.humidity:
        return (change.humidityChange / _humidityThreshold).clamp(0.0, 1.0);
      
      case EnvironmentalChangeType.pressure:
        return (change.pressureChange / _pressureThreshold).clamp(0.0, 1.0);
      
      case EnvironmentalChangeType.combined:
        return change.magnitude;
    }
  }

  static StageAdjustment? _calculateStageAdjustment(
    FermentationStageV2 stage,
    EnvironmentalChange change,
    double impactLevel,
  ) {
    // 단계 타입별 민감도
    double sensitivity;
    switch (stage.type) {
      case FermentationStageType.primary:
        sensitivity = 1.0; // 1차 발효는 환경에 가장 민감
        break;
      case FermentationStageType.final:
        sensitivity = 0.8; // 최종 발효도 민감
        break;
      case FermentationStageType.rest:
        sensitivity = 0.3; // 휴지는 덜 민감
        break;
      case FermentationStageType.storage:
        sensitivity = 0.1; // 보관은 거의 영향 없음
        break;
      case FermentationStageType.thawing:
        sensitivity = 0.5; // 해동은 중간 정도
        break;
      default:
        sensitivity = 0.6;
    }

    final adjustmentFactor = impactLevel * sensitivity;
    
    // 조정이 미미한 경우 null 반환
    if (adjustmentFactor < 0.1) {
      return null;
    }

    // 시간 조정 계산
    Duration adjustedDuration;
    String adjustmentReason;

    switch (change.type) {
      case EnvironmentalChangeType.temperature:
        final tempDiff = change.newConditions.temperature - change.oldConditions.temperature;
        if (tempDiff > 0) {
          // 온도 상승 → 발효 빨라짐 → 시간 단축
          final reduction = adjustmentFactor * 0.3; // 최대 30% 단축
          adjustedDuration = Duration(
            minutes: (stage.duration.inMinutes * (1 - reduction)).round(),
          );
          adjustmentReason = '온도 상승으로 인한 시간 단축 (${tempDiff.toStringAsFixed(1)}°C 증가)';
        } else {
          // 온도 하강 → 발효 느려짐 → 시간 연장
          final extension = adjustmentFactor * 0.4; // 최대 40% 연장
          adjustedDuration = Duration(
            minutes: (stage.duration.inMinutes * (1 + extension)).round(),
          );
          adjustmentReason = '온도 하강으로 인한 시간 연장 (${tempDiff.abs().toStringAsFixed(1)}°C 감소)';
        }
        break;

      case EnvironmentalChangeType.humidity:
        final humidityDiff = change.newConditions.humidity - change.oldConditions.humidity;
        if (humidityDiff.abs() > _humidityThreshold) {
          final adjustment = adjustmentFactor * 0.15; // 최대 15% 조정
          if (humidityDiff < 0) {
            // 습도 감소 → 약간 느려짐
            adjustedDuration = Duration(
              minutes: (stage.duration.inMinutes * (1 + adjustment)).round(),
            );
            adjustmentReason = '습도 감소로 인한 시간 연장 (${humidityDiff.abs().toStringAsFixed(0)}% 감소)';
          } else {
            // 습도 증가 → 약간 빨라짐
            adjustedDuration = Duration(
              minutes: (stage.duration.inMinutes * (1 - adjustment * 0.5)).round(),
            );
            adjustmentReason = '습도 증가로 인한 미세 조정 (${humidityDiff.toStringAsFixed(0)}% 증가)';
          }
        } else {
          return null;
        }
        break;

      case EnvironmentalChangeType.pressure:
        // 기압 변화는 미미한 영향
        final adjustment = adjustmentFactor * 0.05; // 최대 5% 조정
        adjustedDuration = Duration(
          minutes: (stage.duration.inMinutes * (1 + adjustment)).round(),
        );
        adjustmentReason = '기압 변화로 인한 미세 조정';
        break;

      case EnvironmentalChangeType.combined:
        // 복합 변화는 보수적으로 조정
        final adjustment = adjustmentFactor * 0.2; // 최대 20% 조정
        adjustedDuration = Duration(
          minutes: (stage.duration.inMinutes * (1 + adjustment)).round(),
        );
        adjustmentReason = '복합 환경 변화로 인한 조정';
        break;
    }

    // 최소/최대 시간 제한
    adjustedDuration = Duration(
      minutes: adjustedDuration.inMinutes.clamp(
        (stage.duration.inMinutes * 0.5).round(), // 최소 50%
        (stage.duration.inMinutes * 2.0).round(), // 최대 200%
      ),
    );

    return StageAdjustment(
      stageIndex: 0, // 실제 사용 시 올바른 인덱스로 설정됨
      stageName: stage.name,
      originalDuration: stage.duration,
      adjustedDuration: adjustedDuration,
      adjustmentReason: adjustmentReason,
    );
  }

  static double _calculateTemperatureOptimality(double current, double optimal) {
    final diff = (current - optimal).abs();
    if (diff <= 1.0) return 1.0;
    if (diff <= 3.0) return 1.0 - (diff - 1.0) * 0.2;
    if (diff <= 5.0) return 0.6 - (diff - 3.0) * 0.15;
    return math.max(0.3, 0.9 - diff * 0.1);
  }

  static double _calculateHumidityOptimality(double current, double optimal) {
    final diff = (current - optimal).abs();
    if (diff <= 5.0) return 1.0;
    if (diff <= 15.0) return 1.0 - (diff - 5.0) * 0.05;
    if (diff <= 25.0) return 0.5 - (diff - 15.0) * 0.03;
    return math.max(0.2, 0.8 - diff * 0.02);
  }

  static double _calculateFermentationRate(
    double currentTemp,
    double currentHumidity,
    double optimalTemp,
    double optimalHumidity,
  ) {
    // Q10 법칙 기반 온도 영향 (10°C 상승 시 2배 빨라짐)
    final tempRate = math.pow(2, (currentTemp - 26.0) / 10.0).toDouble();
    
    // 습도 영향 (최적 습도에서 멀어질수록 느려짐)
    final humidityDiff = (currentHumidity - optimalHumidity).abs();
    final humidityRate = math.max(0.7, 1.0 - humidityDiff * 0.01);
    
    // 최적 조건과의 차이 보정
    final tempOptimality = _calculateTemperatureOptimality(currentTemp, optimalTemp);
    final humidityOptimality = _calculateHumidityOptimality(currentHumidity, optimalHumidity);
    
    final finalRate = tempRate * humidityRate * tempOptimality * humidityOptimality;
    
    return finalRate.clamp(0.3, 2.5); // 0.3배 ~ 2.5배 범위로 제한
  }

  static String _generateAdjustmentReason(
    EnvironmentalChange change,
    double impactLevel,
  ) {
    final severity = impactLevel > 0.7 ? '큰' : impactLevel > 0.4 ? '중간' : '작은';
    
    switch (change.type) {
      case EnvironmentalChangeType.temperature:
        final direction = change.newConditions.temperature > change.oldConditions.temperature 
            ? '상승' : '하강';
        return '온도 ${direction}으로 인한 ${severity} 영향 (${change.temperatureChange.toStringAsFixed(1)}°C 변화)';
      
      case EnvironmentalChangeType.humidity:
        final direction = change.newConditions.humidity > change.oldConditions.humidity 
            ? '증가' : '감소';
        return '습도 ${direction}로 인한 ${severity} 영향 (${change.humidityChange.toStringAsFixed(0)}% 변화)';
      
      case EnvironmentalChangeType.pressure:
        return '기압 변화로 인한 ${severity} 영향';
      
      case EnvironmentalChangeType.combined:
        return '복합 환경 변화로 인한 ${severity} 영향';
    }
  }
}