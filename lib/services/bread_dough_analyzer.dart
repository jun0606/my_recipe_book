// lib/services/bread_dough_analyzer.dart
// 반죽 단계 분석 기능 모듈

import '../core/services/dough_temperature_calculator.dart';

/// 반죽 분석 결과 클래스
class DoughAnalysisResult {
  final String moistureAbsorptionRate;
  final String moistureOptimizationIndex;
  final String doughTemperature;
  final String doughTemperatureStatus;
  final String glutenStrength;
  final String glutenNetworkStability;
  final String seasonalMoistureAdjustment;
  final String altitudeMoistureImpact;
  final String temperatureOptimizationImpact;
  final double successProbability;
  final String riskLevel;
  final List<Map<String, dynamic>> issues;

  const DoughAnalysisResult({
    required this.moistureAbsorptionRate,
    required this.moistureOptimizationIndex,
    required this.doughTemperature,
    required this.doughTemperatureStatus,
    required this.glutenStrength,
    required this.glutenNetworkStability,
    required this.seasonalMoistureAdjustment,
    required this.altitudeMoistureImpact,
    required this.temperatureOptimizationImpact,
    required this.successProbability,
    required this.riskLevel,
    required this.issues,
  });

  Map<String, dynamic> toMap() {
    return {
      '수분 흡수율': moistureAbsorptionRate,
      '수분 흡수 최적화 지수': moistureOptimizationIndex,
      '반죽 온도': doughTemperature,
      '반죽 온도 상태': doughTemperatureStatus,
      '글루텐 강도': glutenStrength,
      '글루텐 네트워크 안정성': glutenNetworkStability,
      '계절별 수분 보정': seasonalMoistureAdjustment,
      '고도별 수분 영향': altitudeMoistureImpact,
      '온도 최적화 영향': temperatureOptimizationImpact,
      'successProbability': successProbability,
      'riskLevel': riskLevel,
      'issues': issues,
    };
  }
}

/// 빵 반죽 분석기 클래스
class BreadDoughAnalyzer {
  /// 반죽 단계 분석 계산 - 데이터 기반
  static DoughAnalysisResult calculateDoughStageAnalysis(
      Map<String, dynamic> inputs) {
    // 기본 성공 확률
    double successProbability = 0.78;

    // 수분 흡수 분석
    double moistureAbsorptionRate = _calculateMoistureAbsorptionRate(inputs);
    successProbability += (moistureAbsorptionRate - 1.0) * 0.2; // 수분 흡수율 보정

    // 계절별 수분 보정
    double seasonalMoistureAdjustment =
        _calculateSeasonalMoistureAdjustment(inputs['season']);
    successProbability += seasonalMoistureAdjustment;

    // 고도별 수분 증발 영향
    double altitudeMoistureImpact =
        _calculateAltitudeMoistureImpact(inputs['altitude']);
    successProbability += altitudeMoistureImpact;

    // 반죽 온도 최적화
    double doughTemperatureOptimization =
        _calculateDoughTemperatureOptimization(inputs['temperature']);
    successProbability += doughTemperatureOptimization;

    // 글루텐 네트워크 안정화 분석
    double glutenNetworkStability = _calculateGlutenNetworkStability(inputs);
    successProbability += (glutenNetworkStability - 0.5) * 0.3; // 글루텐 안정성 보정

    // 성공 확률 범위 제한 (0.0 ~ 1.0)
    successProbability = successProbability.clamp(0.0, 1.0);

    // 위험도 평가
    String riskLevel = _calculateRiskLevel(successProbability);

    // 문제점 분석
    List<Map<String, dynamic>> issues =
        _analyzeDoughIssues(inputs, successProbability);

    // 반죽 온도 계산 (환경 요인 + 차수별 믹싱 데이터 기반)
    double actualDoughTemperature = _calculateActualDoughTemperature(inputs);

    // 최적 반죽 온도와의 차이
    double optimalDoughTemp = 25.0; // 최적 반죽 온도
    double temperatureDifference =
        (actualDoughTemperature - optimalDoughTemp).abs();
    String temperatureStatus = temperatureDifference <= 2.0 ? '적정' : '조정 필요';

    return DoughAnalysisResult(
      moistureAbsorptionRate: '${moistureAbsorptionRate.toStringAsFixed(2)}배',
      moistureOptimizationIndex:
          '${(moistureAbsorptionRate * 100).toStringAsFixed(1)}%',
      doughTemperature: '${actualDoughTemperature.toStringAsFixed(1)}°C',
      doughTemperatureStatus: temperatureStatus,
      glutenStrength: '${(glutenNetworkStability * 100).toStringAsFixed(1)}%',
      glutenNetworkStability:
          '${(glutenNetworkStability * 100).toStringAsFixed(1)}%',
      seasonalMoistureAdjustment:
          '${(seasonalMoistureAdjustment * 100).toStringAsFixed(1)}%',
      altitudeMoistureImpact:
          '${(altitudeMoistureImpact * 100).toStringAsFixed(1)}%',
      temperatureOptimizationImpact:
          '${(doughTemperatureOptimization * 100).toStringAsFixed(1)}%',
      successProbability: successProbability,
      riskLevel: riskLevel,
      issues: issues,
    );
  }

  /// ⚠️ [중앙화 충돌 제거] 과거 수분 흡수율 계산 제거 - 컨트롤러의 중앙화 계산만 사용
  static double _calculateMoistureAbsorptionRate(Map<String, dynamic> inputs) {
    // 과거: 계절/고도/온도/습도 기반 복합 계산
    // 현재: 컨트롤러의 중앙화 remainingMoisture 기반 계산만 유효
    return 1.0; // 기본값 고정 - 컨트롤러 계산 결과 소비만
  }

  /// 계절별 수분 보정 계산 (환경 데이터 기반으로 개선)
  static double _calculateSeasonalMoistureAdjustment(String? season) {
    // 기본 계절별 보정값
    double baseAdjustment = 0.0;

    switch (season) {
      case 'spring':
        baseAdjustment = 0.04; // 봄: 최적 수분 조건
        break;
      case 'summer':
        baseAdjustment = -0.03; // 여름: 수분 증발
        break;
      case 'autumn':
        baseAdjustment = 0.02; // 가을: 안정적 수분
        break;
      case 'winter':
        baseAdjustment = -0.05; // 겨울: 건조
        break;
      default:
        baseAdjustment = 0.0;
    }

    return baseAdjustment;
  }

  /// 고도별 수분 증발 영향 계산
  static double _calculateAltitudeMoistureImpact(double? altitude) {
    final alt = altitude ?? 100.0;
    if (alt < 300) return 0.02; // 저지대: 수분 유지 우수
    if (alt < 800) return 0.0; // 중간 고도: 보통
    if (alt < 1500) return -0.03; // 고지대: 수분 증발 증가
    return -0.05; // 매우 높은 고도: 심각한 수분 손실
  }

  /// 반죽 온도 최적화 평가
  static double _calculateDoughTemperatureOptimization(double? temperature) {
    final temp = temperature ?? 25.0;
    double optimalTemp = 25.0;
    double difference = (temp - optimalTemp).abs();

    if (difference <= 1.0) return 0.04; // 매우 우수
    if (difference <= 2.0) return 0.02; // 우수
    if (difference <= 4.0) return 0.0; // 보통
    if (difference <= 6.0) return -0.02; // 나쁨
    return -0.04; // 매우 나쁨
  }

  /// 글루텐 네트워크 안정성 계산
  static double _calculateGlutenNetworkStability(Map<String, dynamic> inputs) {
    double baseStability = 0.75;

    // 수분 흡수율 영향
    double moistureRate = _calculateMoistureAbsorptionRate(inputs);
    if (moistureRate >= 1.0) {
      baseStability += (moistureRate - 1.0) * 0.5; // 충분한 수분은 글루텐 형성에 도움
    } else {
      baseStability -= (1.0 - moistureRate) * 0.8; // 수분 부족은 글루텐 형성 저해
    }

    // 온도 영향
    final temperature = inputs['temperature'] as double;
    if (temperature >= 22 && temperature <= 26) {
      baseStability += 0.15; // 최적 온도
    } else if (temperature >= 20 && temperature <= 28) {
      baseStability += 0.05; // 허용 범위
    } else {
      baseStability -= 0.1; // 부적합 범위
    }

    // 습도 영향
    final humidity = inputs['humidity'] as double;
    if (humidity >= 60 && humidity <= 70) {
      baseStability += 0.08; // 최적 습도
    } else if (humidity >= 50 && humidity <= 80) {
      baseStability += 0.03; // 허용 범위
    } else {
      baseStability -= 0.05; // 부적합 범위
    }

    return baseStability.clamp(0.4, 0.95);
  }

  /// 실제 반죽 온도 계산 (중앙화된 계산기 사용)
  static double _calculateActualDoughTemperature(Map<String, dynamic> inputs) {
    // 중앙화된 반죽 온도 계산기 사용 - 모든 마찰열 계산 로직을 제거하고 중앙화 서비스로 통합
    return DoughTemperatureCalculator.calculateActualDoughTemperature(inputs);
  }

  /// ⚠️ [중앙화 전환] 차수별 마찰열 누적 계산제거 - _calculateCumulativeHeat
  /// ⚠️ [중앙화 전환] 단계별 마찰열 계산제거 - _calculateStepHeat
  /// ⚠️ [중앙화 전환] 믹서 타입별 마찰열 배율제거 - _getMixerHeatMultiplier
  /// ⚠️ [중앙화 전환] 속도 값 파싱제거 - _parseSpeedValue
  /// ⚠️ [중앙화 전환] fallback 마찰열 상승값제거 - _getFallbackHeatRise
  /// 모두 DoughTemperatureCalculator로 이전됨

  /// 반죽 문제점 분석
  static List<Map<String, dynamic>> _analyzeDoughIssues(
      Map<String, dynamic> inputs, double successProbability) {
    List<Map<String, dynamic>> issues = [];

    // 수분 흡수율 문제
    double moistureRate = _calculateMoistureAbsorptionRate(inputs);
    if (moistureRate < 0.95) {
      issues.add({
        'description': '수분 흡수율이 낮아 반죽이 건조할 수 있습니다.',
        'severity': 'high',
        'recommendation': '수분 함량을 3-5% 증가시키거나 믹싱 시간을 연장하세요.',
        'expected_impact': '반죽 일관성이 20-25% 향상되어 크랙 발생률이 감소합니다.',
      });
    } else if (moistureRate > 1.15) {
      issues.add({
        'description': '수분 흡수율이 높아 반죽이 너무 축축할 수 있습니다.',
        'severity': 'medium',
        'recommendation': '밀가루 함량을 2-3% 증가시키거나 수분을 2-3% 감소시키세요.',
        'expected_impact': '반죽 점성이 최적화되어 공기 포집률이 15-20% 향상됩니다.',
      });
    }

    // 반죽 온도 문제
    double doughTemp = _calculateActualDoughTemperature(inputs);
    if (doughTemp < 22) {
      issues.add({
        'description': '반죽 온도가 낮아 발효가 느려질 수 있습니다.',
        'severity': 'high',
        'recommendation': '반죽 온도를 24-26°C로 높여보세요.',
        'expected_impact': '발효 속도가 15-20% 향상됩니다.',
      });
    } else if (doughTemp > 28) {
      issues.add({
        'description': '반죽 온도가 높아 과도한 발효가 진행될 수 있습니다.',
        'severity': 'medium',
        'recommendation': '반죽 온도를 24-26°C로 낮추세요.',
        'expected_impact': '발효 안정성이 향상되어 품질이 개선됩니다.',
      });
    }

    // 글루텐 네트워크 안정성 문제
    double glutenStability = _calculateGlutenNetworkStability(inputs);
    if (glutenStability < 0.6) {
      issues.add({
        'description': '글루텐 네트워크 안정성이 낮아 반죽 구조가 약할 수 있습니다.',
        'severity': 'high',
        'recommendation': '믹싱 시간을 연장하거나 수분 함량을 조절하세요.',
        'expected_impact': '반죽 구조 안정성이 15-20% 향상됩니다.',
      });
    }

    // 고도 문제
    final altitude = inputs['altitude'] as double;
    if (altitude > 1000) {
      issues.add({
        'description': '고지대 기압으로 반죽 부피가 과도하게 증가할 수 있습니다.',
        'severity': 'medium',
        'recommendation': '밀가루 함량을 2-3% 증가시키거나 수분을 조절하세요.',
        'expected_impact': '부피 안정성이 향상됩니다.',
      });
    }

    return issues;
  }

  /// 위험도 계산
  static String _calculateRiskLevel(double successProbability) {
    if (successProbability >= 0.85) {
      return '매우 낮음 (A등급)';
    } else if (successProbability >= 0.75) {
      return '낮음 (B등급)';
    } else if (successProbability >= 0.65) {
      return '보통 (C등급)';
    } else if (successProbability >= 0.55) {
      return '높음 (D등급)';
    } else {
      return '매우 높음 (F등급)';
    }
  }
}
