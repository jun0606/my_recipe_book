import 'dart:async';
import 'dart:math';
import '../models/fermentation_scenario.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';

/// 실시간 발효 분석 엔진
/// 발효 진행 중 실시간으로 상태를 분석하고 예측하는 시스템
class RealTimeFermentationAnalyzer {
  static const double _baseTemperature = 26.0; // 기준 온도 (°C)
  static const double _temperatureCoefficient = 0.1; // 온도 계수
  static const double _humidityCoefficient = 0.05; // 습도 계수
  
  /// 현재 발효 진행률 계산
  /// [elapsedTime]: 경과 시간 (분)
  /// [totalTime]: 총 예상 시간 (분)
  /// [currentTemp]: 현재 온도 (°C)
  /// [currentHumidity]: 현재 습도 (%)
  /// [targetTemp]: 목표 온도 (°C)
  /// [targetHumidity]: 목표 습도 (%)
  static double calculateRealTimeProgress({
    required double elapsedTime,
    required double totalTime,
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
  }) {
    // 기본 시간 진행률
    double baseProgress = elapsedTime / totalTime;
    
    // 온도 영향 계산
    double tempDifference = currentTemp - targetTemp;
    double tempFactor = 1.0 + (tempDifference * _temperatureCoefficient);
    
    // 습도 영향 계산  
    double humidityDifference = currentHumidity - targetHumidity;
    double humidityFactor = 1.0 + (humidityDifference * _humidityCoefficient);
    
    // 실제 발효 진행률 계산
    double realProgress = baseProgress * tempFactor * humidityFactor;
    
    return realProgress.clamp(0.0, 1.0);
  }
  
  /// 환경 조건 변화에 따른 예상 완료 시간 재계산
  static double calculateAdjustedCompletionTime({
    required double originalTime,
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
    required double elapsedTime,
  }) {
    // 온도 영향 계수 계산
    double tempRatio = pow(2, (targetTemp - currentTemp) / 10).toDouble();
    
    // 습도 영향 계수 계산
    double humidityRatio = 1.0 + ((targetHumidity - currentHumidity) * 0.01);
    
    // 조정된 총 시간 계산
    double adjustedTotalTime = originalTime * tempRatio * humidityRatio;
    
    // 남은 시간 계산
    double remainingTime = adjustedTotalTime - elapsedTime;
    
    return max(0.0, remainingTime);
  }
  
  /// 발효 속도 계산
  /// 현재 환경 조건에서의 발효 속도 (1.0 = 정상 속도)
  static double calculateFermentationRate({
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
  }) {
    // 온도 기반 발효 속도 (Q10 법칙 적용)
    double tempRate = pow(2, (currentTemp - _baseTemperature) / 10).toDouble();
    
    // 습도 보정
    double humidityRate = 1.0 + ((currentHumidity - 70.0) * 0.005);
    
    // 최적 조건과의 차이 보정
    double tempOptimalityFactor = 1.0 - (pow((currentTemp - targetTemp) / 10, 2) * 0.1);
    double humidityOptimalityFactor = 1.0 - (pow((currentHumidity - targetHumidity) / 20, 2) * 0.05);
    
    double finalRate = tempRate * humidityRate * tempOptimalityFactor * humidityOptimalityFactor;
    
    return max(0.1, min(3.0, finalRate)); // 0.1배 ~ 3배 범위로 제한
  }
  
  /// 발효 효율성 분석
  static FermentationEfficiencyAnalysis analyzeFermentationEfficiency({
    required double elapsedTime,
    required double expectedTime,
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
  }) {
    double currentRate = calculateFermentationRate(
      currentTemp: currentTemp,
      currentHumidity: currentHumidity,
      targetTemp: targetTemp,
      targetHumidity: targetHumidity,
    );
    
    double efficiency = currentRate;
    String status;
    List<String> recommendations = [];
    
    // 효율성 평가
    if (efficiency > 1.2) {
      status = '매우 빠름';
      recommendations.add('과발효 위험 - 온도를 낮추거나 시간을 단축하세요');
    } else if (efficiency > 1.0) {
      status = '빠름';
      recommendations.add('정상보다 빠른 발효 - 주의 깊게 관찰하세요');
    } else if (efficiency > 0.8) {
      status = '정상';
      recommendations.add('적정한 발효 속도입니다');
    } else if (efficiency > 0.6) {
      status = '느림';
      recommendations.add('발효가 느림 - 온도를 높이거나 시간을 연장하세요');
    } else {
      status = '매우 느림';
      recommendations.add('발효 부족 위험 - 환경 조건을 점검하세요');
    }
    
    // 환경 조건별 구체적 조언
    if ((currentTemp - targetTemp).abs() > 3) {
      recommendations.add('온도 차이가 큽니다 (${(currentTemp - targetTemp).toStringAsFixed(1)}°C)');
    }
    
    if ((currentHumidity - targetHumidity).abs() > 10) {
      recommendations.add('습도 차이가 큽니다 (${(currentHumidity - targetHumidity).toStringAsFixed(1)}%)');
    }
    
    return FermentationEfficiencyAnalysis(
      efficiency: efficiency,
      status: status,
      recommendations: recommendations,
      currentRate: currentRate,
      timeDeviation: elapsedTime - expectedTime,
    );
  }
  
  /// 체크포인트 분석
  static CheckpointAnalysis analyzeCheckpoint({
    required double elapsedTime,
    required double totalTime,
    required double currentTemp,
    required double currentHumidity,
    required double targetTemp,
    required double targetHumidity,
    required FermentationStage stage,
  }) {
    double progress = calculateRealTimeProgress(
      elapsedTime: elapsedTime,
      totalTime: totalTime,
      currentTemp: currentTemp,
      currentHumidity: currentHumidity,
      targetTemp: targetTemp,
      targetHumidity: targetHumidity,
    );
    
    String status;
    List<String> actions = [];
    bool isOnTrack = true;
    
    // 진행률에 따른 체크포인트 분석
    if (progress < 0.3) {
      status = '초기 단계';
      actions.add('반죽 표면 상태 확인');
      actions.add('온도와 습도 모니터링');
    } else if (progress < 0.6) {
      status = '중간 단계';
      actions.add('부피 변화 관찰 (1.3-1.5배)');
      if (stage == FermentationStage.bulk) {
        actions.add('폴딩 실시 고려');
      }
    } else if (progress < 0.9) {
      status = '후반 단계';
      actions.add('부피 변화 관찰 (1.7-2배)');
      actions.add('손가락 테스트 준비');
    } else {
      status = '완료 임박';
      actions.add('손가락 테스트 실시');
      actions.add('다음 단계 준비');
    }
    
    // 환경 조건 체크
    if ((currentTemp - targetTemp).abs() > 2) {
      isOnTrack = false;
      actions.add('온도 조정 필요');
    }
    
    if ((currentHumidity - targetHumidity).abs() > 15) {
      isOnTrack = false;
      actions.add('습도 조정 필요');
    }
    
    return CheckpointAnalysis(
      progress: progress,
      status: status,
      actions: actions,
      isOnTrack: isOnTrack,
      nextCheckTime: _calculateNextCheckTime(elapsedTime, totalTime),
    );
  }
  
  /// 다음 체크 시간 계산
  static double _calculateNextCheckTime(double elapsedTime, double totalTime) {
    double progress = elapsedTime / totalTime;
    
    if (progress < 0.3) {
      return totalTime * 0.3; // 30% 지점
    } else if (progress < 0.6) {
      return totalTime * 0.6; // 60% 지점
    } else if (progress < 0.9) {
      return totalTime * 0.9; // 90% 지점
    } else {
      return totalTime; // 완료 시점
    }
  }
}

/// 발효 효율성 분석 결과
class FermentationEfficiencyAnalysis {
  final double efficiency;
  final String status;
  final List<String> recommendations;
  final double currentRate;
  final double timeDeviation;
  
  const FermentationEfficiencyAnalysis({
    required this.efficiency,
    required this.status,
    required this.recommendations,
    required this.currentRate,
    required this.timeDeviation,
  });
}

/// 체크포인트 분석 결과
class CheckpointAnalysis {
  final double progress;
  final String status;
  final List<String> actions;
  final bool isOnTrack;
  final double nextCheckTime;
  
  const CheckpointAnalysis({
    required this.progress,
    required this.status,
    required this.actions,
    required this.isOnTrack,
    required this.nextCheckTime,
  });
}