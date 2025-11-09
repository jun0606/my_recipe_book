// lib/modules/bread/services/bread_oven_analyzer.dart
// 빵 오븐 분석 서비스 - 오븐 단계별 계산 및 분석 담당

import '../../../core/types/environment_types.dart';

/// 오븐 분석 결과 클래스
class OvenAnalysisResult {
  final double maillardIndex;
  final double moistureTransferCoefficient;
  final double crustFormationIndex;
  final double successProbability;
  final String riskLevel;
  final List<Map<String, dynamic>> issues;
  final Map<String, dynamic> performanceMetrics;

  OvenAnalysisResult({
    required this.maillardIndex,
    required this.moistureTransferCoefficient,
    required this.crustFormationIndex,
    required this.successProbability,
    required this.riskLevel,
    required this.issues,
    required this.performanceMetrics,
  });
}

/// 빵 오븐 분석기 클래스
class BreadOvenAnalyzer {
  /// 오븐 단계 분석 계산
  static OvenAnalysisResult analyzeOvenStage(
    Map<String, dynamic> inputs,
    UserEnvironment environment,
  ) {
    double successProbability = 0.80;

    // 오븐 타입에 따른 확률 조정
    if (inputs['ovenType'] == 'professional' ||
        inputs['ovenType'] == 'convection') {
      successProbability += 0.10;
    }

    // 오븐 성능 지수 영향
    double ovenPerformance = _calculateOvenPerformanceIndex(inputs);
    successProbability += (ovenPerformance - 0.75) * 0.5;

    // 열 분포 균일성 영향
    double heatDistribution = _calculateHeatDistribution(inputs);
    successProbability += (heatDistribution - 0.8) * 0.4;

    // 마이야르 반응 지수 계산
    double maillardIndex = _calculateMaillardReactionIndex(inputs);

    // 수분 이동 계수 계산
    double moistureTransfer = _calculateMoistureTransferCoefficient(inputs);

    // 크러스트 형성 지수 계산
    double crustFormation = _calculateCrustFormationIndex(inputs);

    // 성공 확률 범위 제한
    successProbability = successProbability.clamp(0.0, 1.0);

    String riskLevel = successProbability > 0.8
        ? '낮음'
        : successProbability > 0.6
            ? '보통'
            : '높음';

    List<Map<String, dynamic>> issues = _analyzeOvenIssues(inputs);

    // 성능 메트릭 생성
    Map<String, dynamic> performanceMetrics = {
      'ovenPerformanceIndex': ovenPerformance,
      'heatDistribution': heatDistribution,
      'temperatureEfficiency': _calculateTemperatureEfficiency(inputs),
      'humidityImpact': _calculateHumidityImpact(inputs),
      'bakingTimeOptimization': _calculateBakingTimeOptimization(inputs),
    };

    return OvenAnalysisResult(
      maillardIndex: maillardIndex,
      moistureTransferCoefficient: moistureTransfer,
      crustFormationIndex: crustFormation,
      successProbability: successProbability,
      riskLevel: riskLevel,
      issues: issues,
      performanceMetrics: performanceMetrics,
    );
  }

  /// 오븐 성능 지수 계산
  static double _calculateOvenPerformanceIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 오븐 타입별 성능
    switch (inputs['ovenType']) {
      case 'professional':
        baseIndex += 0.18; // 전문가용 오븐
        break;
      case 'convection':
        baseIndex += 0.12; // 컨벡션 오븐
        break;
      case 'stone_oven':
        baseIndex += 0.10; // 스톤 오븐
        break;
      case 'deck_oven':
        baseIndex += 0.08; // 데크 오븐
        break;
      case 'convection_home':
        baseIndex += 0.06; // 가정용 컨벡션
        break;
      case 'gas_oven':
        baseIndex += 0.04; // 가스 오븐
        break;
      case 'home':
      default:
        baseIndex += 0.0; // 기본 가정용
        break;
    }

    // 고도 영향 (고지대일수록 오븐 성능 저하)
    final altitude = inputs['altitude'] as double? ?? 100.0;
    if (altitude > 500) baseIndex -= 0.03;
    if (altitude > 1000) baseIndex -= 0.05;

    return baseIndex.clamp(0.5, 0.95);
  }

  /// 열 분포 균일성 계산
  static double _calculateHeatDistribution(Map<String, dynamic> inputs) {
    double baseDistribution = 0.80;

    // 오븐 타입별 열 분포
    switch (inputs['ovenType']) {
      case 'professional':
        baseDistribution += 0.15; // 최고의 균일성
        break;
      case 'convection':
        baseDistribution += 0.12; // 우수한 열 순환
        break;
      case 'convection_home':
        baseDistribution += 0.08; // 가정용 컨벡션
        break;
      case 'deck_oven':
        baseDistribution += 0.06; // 좋은 열 보유
        break;
      case 'stone_oven':
        baseDistribution += 0.04; // 스톤의 열 보유력
        break;
      case 'gas_oven':
        baseDistribution += 0.02; // 가스 오븐의 열 분포
        break;
      case 'home':
      default:
        baseDistribution += 0.0; // 기본 오븐
        break;
    }

    // 습도 영향 (건조할수록 열 분포 불균일)
    final humidity = inputs['humidity'] as double? ?? 65.0;
    if (humidity < 50) {
      baseDistribution -= 0.05; // 매우 건조
    } else if (humidity < 60) {
      baseDistribution -= 0.02; // 다소 건조
    } else if (humidity > 80) {
      baseDistribution -= 0.03; // 매우 습함
    }

    return baseDistribution.clamp(0.6, 0.98);
  }

  /// 마이야르 반응 지수 계산
  static double _calculateMaillardReactionIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 온도 영향 (빵 굽기 연구에 기반한 현실적 범위: 180-220°C가 마이야르 반응 최적)
    final temperature = inputs['temperature'] as double? ?? 200.0;
    if (temperature >= 180 && temperature <= 220) {
      baseIndex += 0.08; // 최적 범위
    } else if (temperature >= 160 && temperature <= 240) {
      baseIndex += 0.03; // 허용 범위
    } else if (temperature < 150) {
      baseIndex -= 0.05; // 저온: 반응 저하
    } else {
      baseIndex -= 0.08; // 고온: 과도한 반응
    }

    // 습도 영향 (마이야르 반응에는 건조한 환경이 유리함)
    final humidity = inputs['humidity'] as double? ?? 65.0;
    if (humidity >= 40 && humidity <= 60) {
      baseIndex += 0.03; // 최적 습도
    } else if (humidity < 30) {
      baseIndex -= 0.02; // 매우 건조: 반응 저하
    } else {
      baseIndex -= 0.05; // 고습: 반응 저하
    }

    // 오븐 타입 영향
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'professional') {
      baseIndex += 0.02; // 정밀 온도 제어
    } else if (ovenType == 'convection') {
      baseIndex += 0.01; // 균일한 열 분포
    } else if (ovenType == 'stone_oven') {
      baseIndex += 0.015; // 스톤 오븐: 열 보유력
    }

    return baseIndex.clamp(0.55, 0.88);
  }

  /// 수분 이동 계수 계산
  static double _calculateMoistureTransferCoefficient(
      Map<String, dynamic> inputs) {
    double baseCoefficient = 1.0;

    // 온도 영향 (고온일수록 수분 이동 증가)
    final temperature = inputs['temperature'] as double? ?? 200.0;
    if (temperature >= 180 && temperature <= 220) {
      baseCoefficient += 0.1; // 최적 범위
    } else if (temperature >= 160 && temperature <= 240) {
      baseCoefficient += 0.05; // 허용 범위
    } else if (temperature > 240) {
      baseCoefficient += 0.15; // 고온: 급격한 수분 이동
    } else {
      baseCoefficient -= 0.1; // 저온: 느린 수분 이동
    }

    // 습도 영향
    final humidity = inputs['humidity'] as double? ?? 65.0;
    if (humidity >= 60 && humidity <= 75) {
      baseCoefficient += 0.05; // 최적 습도
    } else if (humidity < 50) {
      baseCoefficient -= 0.08; // 건조: 수분 손실 증가
    } else if (humidity > 85) {
      baseCoefficient -= 0.03; // 과습: 수분 이동 저하
    }

    // 오븐 타입 영향
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'convection') {
      baseCoefficient += 0.08; // 컨벡션: 효율적인 수분 이동
    } else if (ovenType == 'professional') {
      baseCoefficient += 0.05; // 스팀 기능 등
    }

    return baseCoefficient.clamp(0.7, 1.3);
  }

  /// 크러스트 형성 지수 계산
  static double _calculateCrustFormationIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 마이야르 반응 지수 영향
    double maillardIndex = _calculateMaillardReactionIndex(inputs);
    baseIndex += (maillardIndex - 0.75) * 0.8;

    // 수분 이동 계수 영향
    double moistureTransfer = _calculateMoistureTransferCoefficient(inputs);
    if (moistureTransfer >= 1.0 && moistureTransfer <= 1.2) {
      baseIndex += 0.1; // 최적 수분 이동
    } else if (moistureTransfer > 1.3) {
      baseIndex -= 0.05; // 과도한 수분 이동
    } else if (moistureTransfer < 0.8) {
      baseIndex -= 0.08; // 불충분한 수분 이동
    }

    // 오븐 타입별 크러스트 형성
    final ovenType = inputs['ovenType'] as String?;
    switch (ovenType) {
      case 'stone_oven':
        baseIndex += 0.08; // 스톤 오븐: 우수한 크러스트
        break;
      case 'deck_oven':
        baseIndex += 0.06; // 데크 오븐: 좋은 크러스트
        break;
      case 'professional':
        baseIndex += 0.04; // 전문가용: 정밀 제어
        break;
      case 'convection':
        baseIndex += 0.02; // 컨벡션: 균일한 크러스트
        break;
    }

    return baseIndex.clamp(0.6, 0.95);
  }

  /// 온도 효율성 계산
  static double _calculateTemperatureEfficiency(Map<String, dynamic> inputs) {
    final temperature = inputs['temperature'] as double? ?? 200.0;

    // 최적 굽기 온도 범위: 180-220°C
    if (temperature >= 180 && temperature <= 220) {
      return 1.0; // 최적
    } else if (temperature >= 160 && temperature <= 240) {
      return 0.9; // 양호
    } else if (temperature >= 140 && temperature <= 260) {
      return 0.8; // 보통
    } else {
      return 0.6; // 저효율
    }
  }

  /// 습도 영향 계산
  static double _calculateHumidityImpact(Map<String, dynamic> inputs) {
    final humidity = inputs['humidity'] as double? ?? 65.0;

    if (humidity >= 60 && humidity <= 75) {
      return 1.0; // 최적 습도
    } else if (humidity >= 50 && humidity <= 85) {
      return 0.9; // 허용 범위
    } else if (humidity >= 40 && humidity <= 90) {
      return 0.8; // 확장 범위
    } else {
      return 0.6; // 부적합 범위
    }
  }

  /// 굽기 시간 최적화 계산
  static double _calculateBakingTimeOptimization(Map<String, dynamic> inputs) {
    double baseOptimization = 1.0;

    // 오븐 타입별 시간 최적화
    final ovenType = inputs['ovenType'] as String?;
    switch (ovenType) {
      case 'professional':
        baseOptimization += 0.15; // 최고 효율
        break;
      case 'convection':
        baseOptimization += 0.12; // 고효율
        break;
      case 'stone_oven':
        baseOptimization += 0.08; // 열 보유력
        break;
      case 'deck_oven':
        baseOptimization += 0.06; // 열 보유력
        break;
      case 'convection_home':
        baseOptimization += 0.05; // 가정용 컨벡션
        break;
      case 'gas_oven':
        baseOptimization += 0.03; // 가스 오븐
        break;
      case 'home':
      default:
        baseOptimization += 0.0; // 기본 오븐
        break;
    }

    return baseOptimization.clamp(0.8, 1.2);
  }

  /// 오븐 문제점 분석
  static List<Map<String, dynamic>> _analyzeOvenIssues(
      Map<String, dynamic> inputs) {
    List<Map<String, dynamic>> issues = [];

    // 온도 관련 문제
    final temperature = inputs['temperature'] as double? ?? 200.0;
    if (temperature > 250) {
      issues.add({
        'description': '오븐 온도가 높아 과도한 마이야르 반응이 발생할 수 있습니다.',
        'severity': 'medium',
        'recommendation': '온도를 180-220°C 범위로 낮추세요.',
      });
    } else if (temperature < 150) {
      issues.add({
        'description': '오븐 온도가 낮아 굽기가 충분하지 않을 수 있습니다.',
        'severity': 'high',
        'recommendation': '온도를 180-220°C 범위로 높이세요.',
      });
    }

    // 습도 관련 문제
    final humidity = inputs['humidity'] as double? ?? 65.0;
    if (humidity < 50) {
      issues.add({
        'description': '습도가 낮아 크러스트가 너무 딱딱해질 수 있습니다.',
        'severity': 'medium',
        'recommendation': '가습기를 사용하여 습도를 높이세요.',
      });
    } else if (humidity > 85) {
      issues.add({
        'description': '습도가 높아 크러스트가 약해질 수 있습니다.',
        'severity': 'low',
        'recommendation': '환기를 통해 습도를 낮추세요.',
      });
    }

    // 오븐 타입 관련 문제
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'home' && temperature > 220) {
      issues.add({
        'description': '가정용 오븐에서 고온 작업 시 균일한 굽기가 어려울 수 있습니다.',
        'severity': 'medium',
        'recommendation': '컨벡션 오븐 사용을 고려해보세요.',
      });
    }

    return issues;
  }

  /// 오븐 권장사항 생성
  static List<String> generateOvenRecommendations(
    Map<String, dynamic> inputs,
    OvenAnalysisResult analysis,
  ) {
    List<String> recommendations = [];

    // 온도 권장사항
    final temperature = inputs['temperature'] as double? ?? 200.0;
    if (temperature < 180 || temperature > 220) {
      recommendations.add('굽기 온도를 180-220°C 범위로 조정하세요.');
    }

    // 습도 권장사항
    final humidity = inputs['humidity'] as double? ?? 65.0;
    if (humidity < 60 || humidity > 75) {
      recommendations.add('굽기 환경 습도를 60-75%로 유지하세요.');
    }

    // 오븐 타입 권장사항
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'home') {
      recommendations.add('컨벡션 오븐을 고려해보세요 (더 균일한 굽기).');
    }

    // 마이야르 반응 최적화 권장사항
    if (analysis.maillardIndex < 0.7) {
      recommendations.add('마이야르 반응을 최적화하기 위해 온도와 시간을 조정하세요.');
    }

    return recommendations;
  }
}
