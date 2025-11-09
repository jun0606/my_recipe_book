// lib/modules/bread/services/bread_comprehensive_analyzer.dart
// 빵 종합 분석 서비스 - 모든 단계의 분석 결과를 통합하여 종합 평가 담당

import '../../../core/types/environment_types.dart';
import '../../../services/bread_calculator.dart';
import '../../../services/environment_defaults_calculator.dart';
import 'bread_oven_analyzer.dart';

// OvenType과 MixerType을 위한 임시 import (실제로는 다른 파일에 정의되어 있어야 함)
import '../../../core/types/environment_types.dart' as env_types
    show OvenType, MixerType;

/// 종합 분석 결과 클래스
class ComprehensiveAnalysisResult {
  final double overallSuccessProbability;
  final Map<String, double> stageProbabilities;
  final List<Map<String, dynamic>> riskFactors;
  final List<String> recommendations;
  final String specialDoughType;
  final double specialDoughBonus;
  final Map<String, dynamic> detailedMetrics;
  final String analysisSummary;

  ComprehensiveAnalysisResult({
    required this.overallSuccessProbability,
    required this.stageProbabilities,
    required this.riskFactors,
    required this.recommendations,
    required this.specialDoughType,
    required this.specialDoughBonus,
    required this.detailedMetrics,
    required this.analysisSummary,
  });
}

/// 임시 분석 결과 클래스들 (기존 BreadCalculator 호환용)
class MixingAnalysisResult {
  final double successProbability;
  final double glutenIndex;
  final List<Map<String, dynamic>> issues;
  final Map<String, dynamic> performanceMetrics;

  MixingAnalysisResult({
    required this.successProbability,
    required this.glutenIndex,
    required this.issues,
    required this.performanceMetrics,
  });
}

class DoughAnalysisResult {
  final double successProbability;
  final double moistureAbsorptionRate;
  final List<Map<String, dynamic>> issues;
  final Map<String, dynamic> performanceMetrics;

  DoughAnalysisResult({
    required this.successProbability,
    required this.moistureAbsorptionRate,
    required this.issues,
    required this.performanceMetrics,
  });
}

class FermentationAnalysisResult {
  final double successProbability;
  final double yeastActivity;
  final List<Map<String, dynamic>> issues;
  final Map<String, dynamic> performanceMetrics;

  FermentationAnalysisResult({
    required this.successProbability,
    required this.yeastActivity,
    required this.issues,
    required this.performanceMetrics,
  });
}

/// 빵 종합 분석기 클래스
class BreadComprehensiveAnalyzer {
  /// 종합 빵 분석 수행
  static ComprehensiveAnalysisResult analyzeComprehensive(
    Map<String, dynamic> inputs,
    UserEnvironment environment,
    List<dynamic> mixingData,
  ) {
    // 각 단계별 분석 수행 (기존 BreadCalculator 함수 활용)
    final mixingResult = _analyzeMixingWithBreadCalculator(inputs, mixingData);
    final doughResult = _analyzeDoughWithBreadCalculator(inputs);
    final fermentationResult = _analyzeFermentationWithBreadCalculator(inputs);
    final ovenResult = BreadOvenAnalyzer.analyzeOvenStage(inputs, environment);

    // 단계별 확률 계산
    final stageProbabilities = {
      'mixing': mixingResult.successProbability,
      'dough': doughResult.successProbability,
      'fermentation': fermentationResult.successProbability,
      'oven': ovenResult.successProbability,
    };

    // 종합 성공 확률 계산 (빵 굽기 과학 기반 가중치)
    final overallSuccessProbability = _calculateOverallSuccessProbability(
      mixingResult.successProbability,
      doughResult.successProbability,
      fermentationResult.successProbability,
      ovenResult.successProbability,
      inputs,
    );

    // 위험 요인 수집 및 우선순위 정렬
    final riskFactors = _collectAndPrioritizeRiskFactors([
      ...mixingResult.issues,
      ...doughResult.issues,
      ...fermentationResult.issues,
      ...ovenResult.issues,
    ]);

    // 권장사항 생성
    final recommendations = _generateComprehensiveRecommendations(
      inputs,
      mixingResult,
      doughResult,
      fermentationResult,
      ovenResult,
      environment,
    );

    // 특수 반죽 분석 정보 활용
    final specialDoughInfo = _analyzeSpecialDoughImpact(inputs);
    final adjustedProbability =
        overallSuccessProbability + specialDoughInfo['bonus'];

    // 상세 메트릭 생성
    final detailedMetrics = _createDetailedMetrics(
      inputs,
      mixingResult,
      doughResult,
      fermentationResult,
      ovenResult,
      environment,
    );

    // 분석 요약 생성
    final analysisSummary = _generateAnalysisSummary(
      adjustedProbability.clamp(0.0, 1.0),
      specialDoughInfo['type'],
      riskFactors.length,
    );

    return ComprehensiveAnalysisResult(
      overallSuccessProbability: adjustedProbability.clamp(0.0, 1.0),
      stageProbabilities: stageProbabilities,
      riskFactors: riskFactors,
      recommendations: recommendations,
      specialDoughType: specialDoughInfo['type'],
      specialDoughBonus: specialDoughInfo['bonus'],
      detailedMetrics: detailedMetrics,
      analysisSummary: analysisSummary,
    );
  }

  /// 종합 성공 확률 계산 (빵 굽기 과학 기반 가중치)
  static double _calculateOverallSuccessProbability(
    double mixingProb,
    double doughProb,
    double fermentationProb,
    double ovenProb,
    Map<String, dynamic> inputs,
  ) {
    // 빵 굽기 단계별 중요도 가중치
    const mixingWeight = 0.35; // 믹싱: 기초 구조 형성 (가장 중요)
    const fermentationWeight = 0.32; // 발효: 부피 및 풍미 형성
    const ovenWeight = 0.23; // 오븐: 최종 품질 결정
    const doughWeight = 0.10; // 반죽: 중간 연결 단계

    double weightedSum = mixingProb * mixingWeight +
        fermentationProb * fermentationWeight +
        ovenProb * ovenWeight +
        doughProb * doughWeight;

    // 환경 요인 보정
    weightedSum += _calculateEnvironmentalCorrection(inputs);

    return weightedSum.clamp(0.0, 1.0);
  }

  /// 환경 요인 보정 계산
  static double _calculateEnvironmentalCorrection(Map<String, dynamic> inputs) {
    double correction = 0.0;

    final temperature = inputs['temperature'] as double? ?? 25.0;
    final humidity = inputs['humidity'] as double? ?? 65.0;
    final altitude = inputs['altitude'] as double? ?? 100.0;

    // 최적 조건 범위 보정
    if (temperature >= 22 && temperature <= 26) {
      correction += 0.03; // 최적 온도
    }
    if (humidity >= 65 && humidity <= 75) {
      correction += 0.02; // 최적 습도
    }
    if (altitude < 300) {
      correction += 0.01; // 저지대 유리
    }

    // 부적합 조건 패널티 - 동적 계산 적용
    final optimalTempRange =
        EnvironmentDefaultsCalculator.getOptimalTemperatureRange();
    final optimalHumidityRange =
        EnvironmentDefaultsCalculator.getOptimalHumidityRange();

    if (temperature < optimalTempRange.min ||
        temperature > optimalTempRange.max) {
      correction -= 0.02;
    }
    if (humidity < optimalHumidityRange.min ||
        humidity > optimalHumidityRange.max) {
      correction -= 0.01;
    }
    if (altitude > 1000) {
      correction -= 0.02;
    }

    return correction;
  }

  /// 위험 요인 수집 및 우선순위 정렬
  static List<Map<String, dynamic>> _collectAndPrioritizeRiskFactors(
    List<Map<String, dynamic>> allIssues,
  ) {
    // 중복 제거
    final uniqueIssues = <Map<String, dynamic>>[];
    final descriptions = <String>{};

    for (final issue in allIssues) {
      final description = issue['description'] as String;
      if (!descriptions.contains(description)) {
        descriptions.add(description);
        uniqueIssues.add(issue);
      }
    }

    // 심각도별 우선순위 정렬
    const severityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};

    uniqueIssues.sort((a, b) {
      final severityA = severityOrder[a['severity'] as String? ?? 'low'] ?? 3;
      final severityB = severityOrder[b['severity'] as String? ?? 'low'] ?? 3;
      return severityA.compareTo(severityB);
    });

    // 최대 10개까지만 반환 (가장 중요한 것들)
    return uniqueIssues.take(10).toList();
  }

  /// 종합 권장사항 생성
  static List<String> _generateComprehensiveRecommendations(
    Map<String, dynamic> inputs,
    MixingAnalysisResult mixingResult,
    DoughAnalysisResult doughResult,
    FermentationAnalysisResult fermentationResult,
    OvenAnalysisResult ovenResult,
    UserEnvironment environment,
  ) {
    final recommendations = <String>[];

    // 환경 관련 권장사항
    if (environment.temperature < 22 || environment.temperature > 26) {
      recommendations.add('작업 온도를 22-26°C 범위로 유지하세요.');
    }
    if (environment.humidity < 65 || environment.humidity > 75) {
      recommendations.add('작업 환경 습도를 65-75%로 조절하세요.');
    }

    // 단계별 최적화 권장사항
    if (mixingResult.successProbability < 0.8) {
      recommendations.add('믹싱 단계에서 글루텐 형성을 개선하기 위해 시간을 늘리거나 속도를 조절하세요.');
    }
    if (fermentationResult.successProbability < 0.8) {
      recommendations.add('발효 단계에서 온도와 습도를 최적화하세요.');
    }
    if (ovenResult.successProbability < 0.8) {
      recommendations.add('굽기 단계에서 온도와 시간을 조정하세요.');
    }

    // 오븐 타입별 권장사항
    if (environment.ovenType == OvenType.home) {
      recommendations.add('컨벡션 오븐이나 전문가용 오븐을 고려해보세요.');
    }

    // 믹서 타입별 권장사항
    if (environment.mixerType == MixerType.home &&
        inputs['doughType'] == 'professional') {
      recommendations.add('전문가용 반죽에는 상업용 믹서를 고려해보세요.');
    }

    return recommendations.take(8).toList(); // 최대 8개 권장사항
  }

  /// 특수 반죽 영향 분석
  static Map<String, dynamic> _analyzeSpecialDoughImpact(
      Map<String, dynamic> inputs) {
    // 특수 반죽 분석 정보 활용 (실제로는 캐시에서 가져와야 함)
    final recipeId = inputs['recipeId'] as String? ?? 'default';

    // 기본값 설정
    String specialDoughType = '표준 반죽';
    double bonus = 0.0;

    // 특수 반죽 감지 로직 (간소화된 버전)
    final doughType = inputs['doughType'] as String? ?? 'standard';

    switch (doughType.toLowerCase()) {
      case 'sourdough':
      case 'sour':
        specialDoughType = '사워도우';
        bonus = 0.05; // 사워도우 보너스
        break;
      case 'brioche':
        specialDoughType = '브리오슈';
        bonus = 0.03; // 버터 반죽 보너스
        break;
      case 'ciabatta':
        specialDoughType = '치아바타';
        bonus = 0.02; // 고수분 반죽 보너스
        break;
      case 'bagel':
        specialDoughType = '베이글';
        bonus = 0.04; // 튀김 후 굽기 보너스
        break;
      case 'focaccia':
        specialDoughType = '포카차';
        bonus = 0.03; // 올리브 오일 반죽 보너스
        break;
    }

    return {
      'type': specialDoughType,
      'bonus': bonus,
    };
  }

  /// 상세 메트릭 생성
  static Map<String, dynamic> _createDetailedMetrics(
    Map<String, dynamic> inputs,
    MixingAnalysisResult mixingResult,
    DoughAnalysisResult doughResult,
    FermentationAnalysisResult fermentationResult,
    OvenAnalysisResult ovenResult,
    UserEnvironment environment,
  ) {
    return {
      'environmentalFactors': {
        'temperature': environment.temperature,
        'humidity': environment.humidity,
        'altitude': environment.altitude,
        'season': environment.season.displayName,
      },
      'equipmentFactors': {
        'mixerType': environment.mixerType.displayName,
        'ovenType': environment.ovenType.displayName,
        'fermentationMethod': environment.fermentationMethod.displayName,
      },
      'performanceMetrics': {
        'mixingEfficiency':
            mixingResult.performanceMetrics['efficiency'] ?? 0.0,
        'doughQuality': doughResult.performanceMetrics['quality'] ?? 0.0,
        'fermentationHealth':
            fermentationResult.performanceMetrics['health'] ?? 0.0,
        'bakingConsistency':
            ovenResult.performanceMetrics['consistency'] ?? 0.0,
      },
      'qualityIndicators': {
        'glutenFormation': mixingResult.glutenIndex,
        'hydrationBalance': doughResult.moistureAbsorptionRate,
        'yeastActivity': fermentationResult.yeastActivity,
        'maillardReaction': ovenResult.maillardIndex,
      },
    };
  }

  /// 분석 요약 생성
  static String _generateAnalysisSummary(
    double successProbability,
    String specialDoughType,
    int riskCount,
  ) {
    final probabilityPercent = (successProbability * 100).round();

    String summary = '';

    // 성공 확률에 따른 요약
    if (successProbability >= 0.85) {
      summary = '탁월한 빵 굽기 조건입니다. ($probabilityPercent% 성공 확률)';
    } else if (successProbability >= 0.75) {
      summary = '좋은 빵 굽기 조건입니다. ($probabilityPercent% 성공 확률)';
    } else if (successProbability >= 0.65) {
      summary = '보통 수준의 빵 굽기 조건입니다. ($probabilityPercent% 성공 확률)';
    } else {
      summary = '빵 굽기 조건 개선이 필요합니다. ($probabilityPercent% 성공 확률)';
    }

    // 특수 반죽 정보 추가
    if (specialDoughType != '표준 반죽') {
      summary += ' $specialDoughType 레시피에 최적화된 분석 결과입니다.';
    }

    // 위험 요인 정보 추가
    if (riskCount > 0) {
      summary += ' $riskCount개의 개선 포인트가 있습니다.';
    }

    return summary;
  }

  /// 빠른 분석 (단순 버전)
  static Map<String, dynamic> quickAnalysis(
    Map<String, dynamic> inputs,
    UserEnvironment environment,
  ) {
    // 간소화된 분석 로직
    final temperature =
        inputs['temperature'] as double? ?? environment.temperature;
    final humidity = inputs['humidity'] as double? ?? environment.humidity;

    // 기본 성공 확률 계산
    double successProbability = 0.7;

    // 온도 최적화
    if (temperature >= 22 && temperature <= 26) {
      successProbability += 0.1;
    } else if (temperature >= 20 && temperature <= 28) {
      successProbability += 0.05;
    }

    // 습도 최적화
    if (humidity >= 65 && humidity <= 75) {
      successProbability += 0.08;
    } else if (humidity >= 60 && humidity <= 80) {
      successProbability += 0.04;
    }

    // 오븐 타입 보너스
    if (environment.ovenType == OvenType.convection) {
      successProbability += 0.03;
    }

    successProbability = successProbability.clamp(0.0, 1.0);

    return {
      'successProbability': successProbability,
      'riskLevel': successProbability > 0.8
          ? '낮음'
          : successProbability > 0.6
              ? '보통'
              : '높음',
      'quickTips': _generateQuickTips(inputs, environment),
    };
  }

  /// 빠른 팁 생성
  static List<String> _generateQuickTips(
    Map<String, dynamic> inputs,
    UserEnvironment environment,
  ) {
    final tips = <String>[];

    final temperature =
        inputs['temperature'] as double? ?? environment.temperature;
    final humidity = inputs['humidity'] as double? ?? environment.humidity;

    if (temperature < 22) {
      tips.add('온도를 높여 글루텐 형성을 개선하세요');
    }
    if (temperature > 26) {
      tips.add('온도를 낮춰 효소 과활성을 방지하세요');
    }
    if (humidity < 65) {
      tips.add('습도를 높여 반죽 수분 균형을 맞추세요');
    }
    if (humidity > 75) {
      tips.add('습도를 낮춰 발효를 안정화하세요');
    }

    return tips.take(3).toList(); // 최대 3개 팁
  }

  /// BreadCalculator를 활용한 믹싱 분석
  static MixingAnalysisResult _analyzeMixingWithBreadCalculator(
    Map<String, dynamic> inputs,
    List<dynamic> mixingData,
  ) {
    try {
      // 기존 BreadCalculator의 믹싱 분석 함수 호출
      final mixingAnalysis = BreadCalculator.calculateMixingStageAnalysis(
        inputs,
        mixingData,
      );

      // 결과를 MixingAnalysisResult 형식으로 변환
      final successProbability = mixingAnalysis['successProbability'] as double;
      final glutenIndexStr = mixingAnalysis['최종 글루텐 형성 지수'] as String;
      final glutenIndex = double.tryParse(glutenIndexStr.split('%')[0]) ?? 70.0;

      return MixingAnalysisResult(
        successProbability: successProbability,
        glutenIndex: glutenIndex / 100.0, // 퍼센트를 소수로 변환
        issues: mixingAnalysis['issues'] as List<Map<String, dynamic>>,
        performanceMetrics: {'efficiency': successProbability},
      );
    } catch (e) {
      // 오류 발생 시 기본값 반환
      return MixingAnalysisResult(
        successProbability: 0.7,
        glutenIndex: 0.7,
        issues: [],
        performanceMetrics: {'efficiency': 0.7},
      );
    }
  }

  /// BreadCalculator를 활용한 반죽 분석
  static DoughAnalysisResult _analyzeDoughWithBreadCalculator(
    Map<String, dynamic> inputs,
  ) {
    try {
      // 기존 BreadCalculator의 반죽 분석 함수 호출
      final doughAnalysis = BreadCalculator.calculateDoughStageAnalysis(inputs);

      // 결과를 DoughAnalysisResult 형식으로 변환
      final successProbability = doughAnalysis['successProbability'] as double;
      final moistureRateStr = doughAnalysis['수분 흡수율'] as String;
      final moistureRate =
          double.tryParse(moistureRateStr.split('배')[0]) ?? 1.0;

      return DoughAnalysisResult(
        successProbability: successProbability,
        moistureAbsorptionRate: moistureRate,
        issues: doughAnalysis['issues'] as List<Map<String, dynamic>>,
        performanceMetrics: {'quality': successProbability},
      );
    } catch (e) {
      // 오류 발생 시 기본값 반환
      return DoughAnalysisResult(
        successProbability: 0.75,
        moistureAbsorptionRate: 1.0,
        issues: [],
        performanceMetrics: {'quality': 0.75},
      );
    }
  }

  /// BreadCalculator를 활용한 발효 분석
  static FermentationAnalysisResult _analyzeFermentationWithBreadCalculator(
    Map<String, dynamic> inputs,
  ) {
    try {
      // 기존 BreadCalculator의 발효 분석 함수 호출
      final fermentationAnalysis =
          BreadCalculator.calculateFermentationStageAnalysis(inputs);

      // 결과를 FermentationAnalysisResult 형식으로 변환
      final successProbability =
          fermentationAnalysis['successProbability'] as double;
      final yeastActivityStr = fermentationAnalysis['이스트 활성도'] as String;
      final yeastActivity =
          double.tryParse(yeastActivityStr.split('%')[0]) ?? 75.0;

      return FermentationAnalysisResult(
        successProbability: successProbability,
        yeastActivity: yeastActivity / 100.0, // 퍼센트를 소수로 변환
        issues: fermentationAnalysis['issues'] as List<Map<String, dynamic>>,
        performanceMetrics: {'health': successProbability},
      );
    } catch (e) {
      // 오류 발생 시 기본값 반환
      return FermentationAnalysisResult(
        successProbability: 0.75,
        yeastActivity: 0.75,
        issues: [],
        performanceMetrics: {'health': 0.75},
      );
    }
  }
}
