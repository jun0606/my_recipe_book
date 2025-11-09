// lib/modules/bread/services/bread_environment_analyzer.dart
// 빵 환경 분석 서비스 - 환경 요인들이 빵 굽기에 미치는 영향을 분석

import '../../../core/types/environment_types.dart';

/// 환경 분석 결과 클래스
class EnvironmentAnalysisResult {
  final double environmentalScore;
  final Map<String, double> factorImpacts;
  final List<Map<String, dynamic>> environmentalIssues;
  final List<String> recommendations;
  final Map<String, dynamic> optimalConditions;
  final String environmentalSummary;

  EnvironmentAnalysisResult({
    required this.environmentalScore,
    required this.factorImpacts,
    required this.environmentalIssues,
    required this.recommendations,
    required this.optimalConditions,
    required this.environmentalSummary,
  });
}

/// 빵 환경 분석기 클래스
class BreadEnvironmentAnalyzer {
  /// 환경 분석 수행
  static EnvironmentAnalysisResult analyzeEnvironment(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    // 각 환경 요인 분석
    final temperatureAnalysis =
        _analyzeTemperatureImpact(environment, recipeInputs);
    final humidityAnalysis = _analyzeHumidityImpact(environment, recipeInputs);
    final altitudeAnalysis = _analyzeAltitudeImpact(environment, recipeInputs);
    final seasonalAnalysis = _analyzeSeasonalImpact(environment, recipeInputs);

    // 종합 환경 점수 계산
    final environmentalScore = _calculateEnvironmentalScore(
      temperatureAnalysis['score'],
      humidityAnalysis['score'],
      altitudeAnalysis['score'],
      seasonalAnalysis['score'],
    );

    // 요인별 영향도
    final factorImpacts = <String, double>{
      'temperature': temperatureAnalysis['impact'] as double,
      'humidity': humidityAnalysis['impact'] as double,
      'altitude': altitudeAnalysis['impact'] as double,
      'seasonal': seasonalAnalysis['impact'] as double,
    };

    // 환경 문제점 수집
    final environmentalIssues = <Map<String, dynamic>>[
      ...temperatureAnalysis['issues'] as List<Map<String, dynamic>>,
      ...humidityAnalysis['issues'] as List<Map<String, dynamic>>,
      ...altitudeAnalysis['issues'] as List<Map<String, dynamic>>,
      ...seasonalAnalysis['issues'] as List<Map<String, dynamic>>,
    ];

    // 환경 권장사항 생성
    final recommendations = _generateEnvironmentalRecommendations(
      temperatureAnalysis,
      humidityAnalysis,
      altitudeAnalysis,
      seasonalAnalysis,
    );

    // 최적 조건 계산
    final optimalConditions = _calculateOptimalConditions(
      environment,
      recipeInputs,
    );

    // 환경 분석 요약
    final environmentalSummary = _generateEnvironmentalSummary(
      environmentalScore,
      factorImpacts,
    );

    return EnvironmentAnalysisResult(
      environmentalScore: environmentalScore,
      factorImpacts: factorImpacts,
      environmentalIssues: environmentalIssues,
      recommendations: recommendations,
      optimalConditions: optimalConditions,
      environmentalSummary: environmentalSummary,
    );
  }

  /// 온도 영향 분석
  static Map<String, dynamic> _analyzeTemperatureImpact(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    final currentTemp = environment.temperature;
    final targetTemp = recipeInputs['temperature'] as double? ?? 25.0;

    double score = 1.0;
    double impact = 0.0;
    final issues = <Map<String, dynamic>>[];

    // 빵 굽기 최적 온도 범위: 22-26°C
    if (currentTemp >= 22 && currentTemp <= 26) {
      score = 1.0; // 최적
      impact = 0.05; // 긍정적 영향
    } else if (currentTemp >= 20 && currentTemp <= 28) {
      score = 0.9; // 양호
      impact = 0.02; // 약간 긍정적
    } else if (currentTemp >= 18 && currentTemp <= 30) {
      score = 0.8; // 보통
      impact = -0.01; // 약간 부정적
    } else {
      score = 0.6; // 불량
      impact = -0.05; // 부정적 영향
    }

    // 온도 차이에 따른 추가 분석
    final tempDiff = (currentTemp - targetTemp).abs();
    if (tempDiff > 5) {
      score -= 0.1;
      impact -= 0.02;
      issues.add({
        'factor': 'temperature',
        'description': '작업 온도와 목표 온도의 차이가 큽니다.',
        'severity': tempDiff > 8 ? 'high' : 'medium',
        'recommendation': '온도를 ${targetTemp}°C에 가깝게 조절하세요.',
      });
    }

    // 계절별 온도 보정
    final seasonalAdjustment =
        _calculateSeasonalTemperatureAdjustment(environment.season);
    score += seasonalAdjustment * 0.1;

    return {
      'score': score.clamp(0.0, 1.0),
      'impact': impact,
      'issues': issues,
      'optimalRange': '22-26°C',
      'currentValue': '${currentTemp}°C',
    };
  }

  /// 습도 영향 분석
  static Map<String, dynamic> _analyzeHumidityImpact(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    final currentHumidity = environment.humidity;
    final targetHumidity = recipeInputs['humidity'] as double? ?? 70.0;

    double score = 1.0;
    double impact = 0.0;
    final issues = <Map<String, dynamic>>[];

    // 빵 굽기 최적 습도 범위: 65-75%
    if (currentHumidity >= 65 && currentHumidity <= 75) {
      score = 1.0; // 최적
      impact = 0.04; // 긍정적 영향
    } else if (currentHumidity >= 60 && currentHumidity <= 80) {
      score = 0.9; // 양호
      impact = 0.02; // 약간 긍정적
    } else if (currentHumidity >= 50 && currentHumidity <= 85) {
      score = 0.8; // 보통
      impact = -0.01; // 약간 부정적
    } else {
      score = 0.6; // 불량
      impact = -0.04; // 부정적 영향
    }

    // 습도 차이에 따른 추가 분석
    final humidityDiff = (currentHumidity - targetHumidity).abs();
    if (humidityDiff > 10) {
      score -= 0.1;
      impact -= 0.02;
      issues.add({
        'factor': 'humidity',
        'description': '현재 습도가 목표 습도와 차이가 큽니다.',
        'severity': humidityDiff > 15 ? 'high' : 'medium',
        'recommendation': '습도를 ${targetHumidity}%에 가깝게 조절하세요.',
      });
    }

    // 건조한 환경 특별 처리
    if (currentHumidity < 50) {
      issues.add({
        'factor': 'humidity',
        'description': '매우 건조한 환경으로 수분 증발이 빠를 수 있습니다.',
        'severity': 'medium',
        'recommendation': '가습기를 사용하여 습도를 높이세요.',
      });
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'impact': impact,
      'issues': issues,
      'optimalRange': '65-75%',
      'currentValue': '${currentHumidity}%',
    };
  }

  /// 고도 영향 분석
  static Map<String, dynamic> _analyzeAltitudeImpact(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    final currentAltitude = environment.altitude;

    double score = 1.0;
    double impact = 0.0;
    final issues = <Map<String, dynamic>>[];

    // 빵 굽기 최적 고도 범위: 0-500m
    if (currentAltitude <= 500) {
      score = 1.0; // 최적
      impact = 0.02; // 약간 긍정적
    } else if (currentAltitude <= 1000) {
      score = 0.9; // 양호
      impact = 0.0; // 중립
    } else if (currentAltitude <= 1500) {
      score = 0.8; // 보통
      impact = -0.02; // 약간 부정적
    } else {
      score = 0.7; // 불량
      impact = -0.04; // 부정적 영향
    }

    // 고지대 특별 처리
    if (currentAltitude > 800) {
      issues.add({
        'factor': 'altitude',
        'description': '고지대 기압으로 수분 증발이 빠를 수 있습니다.',
        'severity': currentAltitude > 1200 ? 'high' : 'medium',
        'recommendation': '수분 함량을 5-10% 높이는 것을 고려하세요.',
      });
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'impact': impact,
      'issues': issues,
      'optimalRange': '0-500m',
      'currentValue': '${currentAltitude}m',
    };
  }

  /// 계절적 영향 분석
  static Map<String, dynamic> _analyzeSeasonalImpact(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    final currentSeason = environment.season;

    double score = 1.0;
    double impact = 0.0;
    final issues = <Map<String, dynamic>>[];

    // 계절별 최적성 평가
    switch (currentSeason) {
      case Season.spring:
        score = 1.0; // 봄: 최적 (적절한 온습도)
        impact = 0.03;
        break;
      case Season.autumn:
        score = 0.95; // 가을: 양호 (안정적)
        impact = 0.02;
        break;
      case Season.summer:
        score = 0.85; // 여름: 보통 (고온 다습)
        impact = -0.01;
        issues.add({
          'factor': 'seasonal',
          'description': '여름철 고온 다습한 환경으로 발효 관리가 필요합니다.',
          'severity': 'low',
          'recommendation': '냉장 재료를 사용하고 발효 시간을 단축하세요.',
        });
        break;
      case Season.winter:
        score = 0.8; // 겨울: 보통 (저온 건조)
        impact = -0.02;
        issues.add({
          'factor': 'seasonal',
          'description': '겨울철 저온 건조한 환경으로 수분 보충이 필요합니다.',
          'severity': 'medium',
          'recommendation': '수분 함량을 늘리고 작업 온도를 높이세요.',
        });
        break;
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'impact': impact,
      'issues': issues,
      'currentSeason': currentSeason.displayName,
    };
  }

  /// 종합 환경 점수 계산
  static double _calculateEnvironmentalScore(
    double tempScore,
    double humidityScore,
    double altitudeScore,
    double seasonalScore,
  ) {
    // 가중치 적용 (온도와 습도가 가장 중요)
    const tempWeight = 0.4;
    const humidityWeight = 0.3;
    const altitudeWeight = 0.15;
    const seasonalWeight = 0.15;

    return (tempScore * tempWeight +
            humidityScore * humidityWeight +
            altitudeScore * altitudeWeight +
            seasonalScore * seasonalWeight)
        .clamp(0.0, 1.0);
  }

  /// 계절별 온도 조정 계산
  static double _calculateSeasonalTemperatureAdjustment(Season season) {
    switch (season) {
      case Season.spring:
        return 0.1; // 봄: 최적
      case Season.autumn:
        return 0.05; // 가을: 양호
      case Season.summer:
        return -0.1; // 여름: 불리
      case Season.winter:
        return -0.05; // 겨울: 보통
    }
  }

  /// 환경 권장사항 생성
  static List<String> _generateEnvironmentalRecommendations(
    Map<String, dynamic> temperatureAnalysis,
    Map<String, dynamic> humidityAnalysis,
    Map<String, dynamic> altitudeAnalysis,
    Map<String, dynamic> seasonalAnalysis,
  ) {
    final recommendations = <String>[];

    // 온도 권장사항
    if (temperatureAnalysis['score'] < 0.9) {
      recommendations.add('작업 온도를 22-26°C 범위로 유지하세요.');
    }

    // 습도 권장사항
    if (humidityAnalysis['score'] < 0.9) {
      recommendations.add('작업 환경 습도를 65-75%로 조절하세요.');
    }

    // 고도 권장사항
    if (altitudeAnalysis['score'] < 0.9) {
      recommendations.add('고지대에서는 수분 함량을 5-10% 높이는 것을 고려하세요.');
    }

    // 계절별 권장사항
    final season = seasonalAnalysis['currentSeason'] as String;
    if (season == '여름') {
      recommendations.add('여름철에는 냉장 재료를 사용하고 발효 시간을 단축하세요.');
    } else if (season == '겨울') {
      recommendations.add('겨울철에는 수분 함량을 늘리고 작업 온도를 높이세요.');
    }

    return recommendations;
  }

  /// 최적 조건 계산
  static Map<String, dynamic> _calculateOptimalConditions(
    UserEnvironment environment,
    Map<String, dynamic> recipeInputs,
  ) {
    return {
      'optimalTemperature': 24.0,
      'optimalHumidity': 70.0,
      'optimalAltitude': 0.0,
      'optimalSeason': '봄',
      'currentTemperature': environment.temperature,
      'currentHumidity': environment.humidity,
      'currentAltitude': environment.altitude,
      'currentSeason': environment.season.displayName,
      'temperatureAdjustment': (24.0 - environment.temperature),
      'humidityAdjustment': (70.0 - environment.humidity),
    };
  }

  /// 환경 분석 요약 생성
  static String _generateEnvironmentalSummary(
    double environmentalScore,
    Map<String, double> factorImpacts,
  ) {
    final scorePercent = (environmentalScore * 100).round();

    String summary = '';

    if (environmentalScore >= 0.9) {
      summary = '환경 조건이 매우 우수합니다 ($scorePercent%).';
    } else if (environmentalScore >= 0.8) {
      summary = '환경 조건이 양호합니다 ($scorePercent%).';
    } else if (environmentalScore >= 0.7) {
      summary = '환경 조건이 보통입니다 ($scorePercent%).';
    } else {
      summary = '환경 조건 개선이 필요합니다 ($scorePercent%).';
    }

    // 주요 영향 요인 추가
    final majorFactors = factorImpacts.entries
        .where((entry) => entry.value.abs() > 0.02)
        .map((entry) => entry.key)
        .toList();

    if (majorFactors.isNotEmpty) {
      summary += ' 주요 영향 요인: ${majorFactors.join(', ')}.';
    }

    return summary;
  }

  /// 빠른 환경 평가
  static Map<String, dynamic> quickEnvironmentalAssessment(
    UserEnvironment environment,
  ) {
    final temperatureScore =
        environment.temperature >= 22 && environment.temperature <= 26
            ? 1.0
            : 0.7;
    final humidityScore =
        environment.humidity >= 65 && environment.humidity <= 75 ? 1.0 : 0.7;

    final overallScore = (temperatureScore + humidityScore) / 2.0;

    return {
      'overallScore': overallScore,
      'temperatureScore': temperatureScore,
      'humidityScore': humidityScore,
      'isOptimal': overallScore >= 0.9,
      'quickTips': _generateQuickEnvironmentalTips(environment),
    };
  }

  /// 빠른 환경 팁 생성
  static List<String> _generateQuickEnvironmentalTips(
      UserEnvironment environment) {
    final tips = <String>[];

    if (environment.temperature < 22 || environment.temperature > 26) {
      tips.add('작업 온도를 22-26°C로 조절하세요');
    }

    if (environment.humidity < 65 || environment.humidity > 75) {
      tips.add('습도를 65-75% 범위로 유지하세요');
    }

    if (environment.altitude > 500) {
      tips.add('고지대에서는 수분 함량을 높이세요');
    }

    return tips.take(2).toList();
  }
}
