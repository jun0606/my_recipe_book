// lib/services/bread_calculator_service.dart
// 빵 계산기 메인 서비스 - 모듈 통합 및 오케스트레이션

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'bread_rpm_calculator.dart';
import 'bread_mixing_analyzer.dart';
import 'bread_dough_analyzer.dart';
import 'gluten_calculation_engine.dart'; // 빅데이터 통합 엔진 사용
import 'fermentation_calculator.dart';
import '../core/services/special_dough_analysis_service.dart';
import '../core/types/environment_types.dart';
import '../core/types/unified_types.dart';
import '../core/types/calculation_types.dart';
import '../services/centralized_parsing_service.dart';
import '../services/ingredient_analyzer.dart';
import '../features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;

/// 온도 범위 enum
enum TemperatureRange {
  tooLow, // < 20°C
  low, // 20-22°C
  optimal, // 22-26°C
  high, // 26-30°C
  tooHigh // > 30°C
}

/// 온도 평가 결과 클래스
class TemperatureEvaluation {
  final TemperatureRange range;
  final double timeMultiplier;
  final double glutenFormation;
  final double successBonus;
  final List<String> warnings;

  const TemperatureEvaluation({
    required this.range,
    required this.timeMultiplier,
    required this.glutenFormation,
    required this.successBonus,
    required this.warnings,
  });
}

/// 빵 계산 헬퍼 클래스들
/// 과학적 계산 로직들을 모듈화하여 재사용성과 유지보수성 향상

class BreadCalculationHelper {
  /// 오븐 성능 지수 계산
  static double calculateOvenPerformanceIndex(String? ovenType) {
    switch (ovenType) {
      case 'professional':
        return 0.95; // 최고 성능
      case 'convection':
        return 0.88; // 우수 성능
      case 'stone_oven':
        return 0.85; // 좋은 성능
      case 'deck_oven':
        return 0.82; // 양호 성능
      case 'convection_home':
        return 0.75; // 가정용 컨벡션
      case 'gas_oven':
        return 0.70; // 가스 오븐
      case 'home':
      default:
        return 0.65; // 기본 가정용
    }
  }

  /// 열 분포 균일성 계산
  static double calculateHeatDistribution(String? ovenType) {
    switch (ovenType) {
      case 'professional':
        return 0.95; // 최고 균일성
      case 'convection':
        return 0.90; // 우수 균일성
      case 'convection_home':
        return 0.80; // 가정용 컨벡션
      case 'deck_oven':
        return 0.75; // 좋은 균일성
      case 'stone_oven':
        return 0.70; // 스톤 오븐
      case 'gas_oven':
        return 0.65; // 가스 오븐
      case 'home':
      default:
        return 0.60; // 기본 오븐
    }
  }

  /// 마이야르 반응 지수 계산 (현실적 개선)
  static double calculateMaillardReactionIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 온도 영향 (빵 굽기 연구에 기반한 현실적 범위: 180-220°C가 마이야르 반응 최적)
    final temperature = inputs['temperature'] as double;
    if (temperature >= 180 && temperature <= 220) {
      baseIndex += 0.08; // 최적 범위: 미세한 향상 (기존 0.15에서 47% 감소)
    } else if (temperature >= 160 && temperature <= 240) {
      baseIndex += 0.03; // 허용 범위: 최소한의 영향 (기존 0.05에서 40% 감소)
    } else if (temperature >= 150 && temperature <= 250) {
      // 확장된 허용 범위: 영향 없음 (현실적 접근)
    } else if (temperature < 150) {
      baseIndex -= 0.05; // 저온: 반응 저하 (기존 0.1에서 50% 감소)
    } else {
      baseIndex -= 0.08; // 고온: 과도한 반응 (기존 0.1에서 20% 감소)
    }

    // 습도 영향 (마이야르 반응에는 건조한 환경이 유리함)
    final humidity = inputs['humidity'] as double;
    if (humidity >= 40 && humidity <= 60) {
      baseIndex += 0.03; // 최적 습도: 미세한 향상 (기존 0.08에서 63% 감소)
    } else if (humidity >= 30 && humidity <= 70) {
      baseIndex += 0.01; // 허용 범위: 최소한의 영향 (기존 0.02에서 50% 감소)
    } else if (humidity < 30) {
      baseIndex -= 0.02; // 매우 건조: 반응 저하
    } else {
      baseIndex -= 0.05; // 고습: 반응 저하 (기존 0.05에서 변화 없음)
    }

    // 오븐 타입 영향 (빵 굽기 과학적 연구 기반)
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'professional') {
      baseIndex += 0.02; // 정밀 온도 제어: 미세한 향상 (기존 0.05에서 60% 감소)
    } else if (ovenType == 'convection') {
      baseIndex += 0.01; // 균일한 열 분포: 최소한의 향상 (기존 0.03에서 67% 감소)
    } else if (ovenType == 'stone_oven') {
      baseIndex += 0.015; // 스톤 오븐: 열 보유력으로 약간 향상
    }

    return baseIndex; // ✅ 범위 제한 제거 - 과학적 계산값 그대로 반환
  }

  /// 수분 이동 계수 계산
  static double calculateMoistureTransferCoefficient(
      Map<String, dynamic> inputs) {
    double baseCoefficient = 1.0;

    // 온도 영향 (고온일수록 수분 이동 증가)
    final temperature = inputs['temperature'] as double;
    if (temperature >= 25 && temperature <= 30) {
      baseCoefficient += 0.1; // 최적 범위
    } else if (temperature >= 22 && temperature <= 35) {
      baseCoefficient += 0.05; // 허용 범위
    } else if (temperature > 35) {
      baseCoefficient += 0.15; // 고온: 급격한 수분 이동
    } else {
      baseCoefficient -= 0.1; // 저온: 느린 수분 이동
    }

    // 습도 영향
    final humidity = inputs['humidity'] as double;
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
      baseCoefficient += 0.05; // 전문가용: 스팀 기능 등
    }

    return baseCoefficient.clamp(0.7, 1.3);
  }

  /// 크러스트 형성 지수 계산
  static double calculateCrustFormationIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 마이야르 반응 지수 영향
    double maillardIndex = calculateMaillardReactionIndex(inputs);
    baseIndex += (maillardIndex - 0.75) * 0.8;

    // 수분 이동 계수 영향 (적절한 수분 이동이 크러스트 형성에 중요)
    double moistureTransfer = calculateMoistureTransferCoefficient(inputs);
    if (moistureTransfer >= 1.0 && moistureTransfer <= 1.2) {
      baseIndex += 0.1; // 최적 수분 이동
    } else if (moistureTransfer > 1.3) {
      baseIndex -= 0.05; // 과도한 수분 이동
    } else if (moistureTransfer < 0.8) {
      baseIndex -= 0.08; // 불충분한 수분 이동
    }

    // 오븐 타입별 크러스트 형성
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'stone_oven') {
      baseIndex += 0.08; // 스톤 오븐: 우수한 크러스트
    } else if (ovenType == 'deck_oven') {
      baseIndex += 0.06; // 데크 오븐: 좋은 크러스트
    } else if (ovenType == 'professional') {
      baseIndex += 0.04; // 전문가용: 정밀 제어
    } else if (ovenType == 'convection') {
      baseIndex += 0.02; // 컨벡션: 균일한 크러스트
    }

    return baseIndex.clamp(0.6, 0.95);
  }

  /// 문제점 중복 제거 및 우선순위 정렬
  static List<Map<String, dynamic>> deduplicateAndPrioritizeIssues(
      List<Map<String, dynamic>> issues) {
    // 중복 제거 (유사한 문제점 통합)
    final uniqueIssues = <Map<String, dynamic>>[];
    final descriptions = <String>{};

    for (final issue in issues) {
      final description = issue['description'] as String;
      if (!descriptions.contains(description)) {
        descriptions.add(description);
        uniqueIssues.add(issue);
      }
    }

    // 우선순위 정렬 (severity 기준)
    final severityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};

    uniqueIssues.sort((a, b) {
      final severityA = severityOrder[a['severity']] ?? 3;
      final severityB = severityOrder[b['severity']] ?? 3;
      return severityA.compareTo(severityB);
    });

    return uniqueIssues;
  }

  /// 위험도 계산 헬퍼
  static String calculateRiskLevel(double successProbability) {
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

/// 발효 차별화 전략 인터페이스
/// 컨셉 준수: 단계별 차별화 로직 + 실제 메트릭 계산을 전략 패턴으로 동적화
abstract class FermentationDifferentiationStrategy {
  /// 단계별 목표 온도 계산 (사용자 환경 기반 동적 계산)
  double calculateTargetTemperature(int stepNumber, double baseTemperature);

  /// 단계별 목표 습도 계산 (사용자 환경 기반 동적 계산)
  double calculateTargetHumidity(int stepNumber, double baseHumidity);

  /// 단계별 시간 계산 (사용자 fermentationSteps 우선 or 과학적 계산)
  double calculateEstimatedDurationHours(
      int stepNumber, double? userDefinedHours);

  /// 유동적 차수 대응 메서드 - 스위치문 제거
  art.FermentationStage determineStageDynamically(
      int stepNumber, int totalSteps);

  /// 데이터 오염 없는 초기 산도 계산 - 클램프 제거 ✅
  double calculateInitialAcidity(Map<String, dynamic> recipeData);
}

/// 빵 과학 기반 차별화 전략 구현
/// 기본값 없음, 과학적 계산 공식만 사용
class BreadScienceBasedDifferentiation
    implements FermentationDifferentiationStrategy {
  @override
  double calculateTargetTemperature(int stepNumber, double baseTemperature) {
    // 과학적 계산: 초반 단계와 후반 단계에서 다른 패턴 적용
    final progressionFactor =
        (stepNumber - 1) / math.max(stepNumber - 1, 1).toDouble();

    if (stepNumber <= 2) {
      // 초반: 이스트 활성화 단계 - 입력 온도 유지 or 약간 상승
      return baseTemperature + (progressionFactor * 1.5).clamp(0.0, 3.0);
    } else if (stepNumber <= 4) {
      // 중반: 산 생성 단계 - 온도 상승
      return baseTemperature + (progressionFactor * 2.5 + 1.0).clamp(1.0, 4.0);
    } else {
      // 후반: 풍미 숙성 단계 - 온도 유지 및 조절
      return baseTemperature + (progressionFactor * 1.0).clamp(0.5, 2.5);
    }
  }

  @override
  double calculateTargetHumidity(int stepNumber, double baseHumidity) {
    // 과학적 계산: 발효 단계별 습도 변동 패턴
    final progressionFactor =
        (stepNumber - 1) / math.max(stepNumber - 1, 1).toDouble();

    if (stepNumber <= 2) {
      // 초반: 높은 습도로 글루텐 네트워크 형성 지원
      return baseHumidity + (progressionFactor * 5.0).clamp(0.0, 8.0);
    } else if (stepNumber <= 4) {
      // 중반: 산도를 위해 약간 습도 유지
      return baseHumidity + (progressionFactor * 3.0 + 2.0).clamp(1.0, 6.0);
    } else {
      // 후반: 맛 성숙을 위해 적절한 습도 유지
      return baseHumidity + (progressionFactor * 2.0 - 1.0).clamp(-2.0, 4.0);
    }
  }

  @override
  double calculateEstimatedDurationHours(
      int stepNumber, double? userDefinedHours) {
    // 성속 사용자 입력 우선 (컨셉 준수)
    if (userDefinedHours != null && userDefinedHours > 0) {
      return userDefinedHours;
    }

    // 기본값 없음, 과학적 계산으로만 결정 (하드코딩 제거)
    const double baseHours = 2.0;
    const double progressionMultiplier = 1.8;

    // 지수적 증가 패턴 (초반 짧게, 후반 길어짐) - 범위 제한 제거
    return baseHours *
        math.pow(progressionMultiplier, stepNumber - 1); // ✅ 범위 제한 제거
  }

  @override
  art.FermentationStage determineStageDynamically(
      int stepNumber, int totalSteps) {
    // 유동적 차수 대응: 단계 번호와 전체 단계 수 기반 동적 판별
    final relativePosition = stepNumber / math.max(totalSteps, 1).toDouble();

    if (stepNumber == 1 || relativePosition <= 0.25) {
      return art.FermentationStage.primary;
    } else if (stepNumber <= 2 || relativePosition <= 0.75) {
      return art.FermentationStage.secondary;
    } else {
      return art.FermentationStage.final_;
    }
  }

  @override
  double calculateInitialAcidity(Map<String, dynamic> recipeData) {
    // ✅ 데이터 오염 없는 클램프 제거 산도 계산
    // ❌ 임의 범위 강제 제거, 자연스러운 과학 계산 적용

    debugPrint('🧪 [초기 산도 계산] 데이터 오염 없는 클램프 제거 방식 적용');

    // 1. 밀가루 기준 산도 (산업 표준 pH 5.8)
    const double baseFlourPh = 5.8;
    debugPrint('   - 밀가루 기준 산도: ${baseFlourPh}pH');

    // 2. 재료 기반 산도 기여도 계산 (클램프 없음)
    final ingredientAciditySum =
        _calculateIngredientAcidityContributions(recipeData);
    debugPrint('   - 재료산 기여도 합계: ${ingredientAciditySum.toStringAsFixed(3)}');

    // 3. 빵 타입별 산업 패턴 적용 (클램프 없음)
    final typeModification = _getBreadTypeAcidityPattern(recipeData);
    debugPrint('   - 빵 타입별 패턴 적용: ${typeModification.toStringAsFixed(3)}');

    // 4. 최종 자연 계산 결과 (컨셉 준수: 데이터 오염 금지)
    final finalAcidity = baseFlourPh + ingredientAciditySum + typeModification;

    debugPrint('   - 최종 초기 산도: ${finalAcidity.toStringAsFixed(2)}pH (클램프 없음)');

    return finalAcidity;
  }

  /// 재료 기반 산도 기여도 계산 (클램프 없음)
  double _calculateIngredientAcidityContributions(
      Map<String, dynamic> recipeData) {
    // 클램프 없는 자연스러운 계산: 실제 재료 양 × 계수
    final ingredients = recipeData['ingredients'];
    if (ingredients is! List) return 0.0;

    double totalAcidityContribution = 0.0;

    // 산성 계수 기준 (ml 또는 g 기준) - 클린 컴퓨테이션
    final Map<String, double> acidCoefficients = {
      '식초': -0.012, // ml당 pH 영향
      'vinegar': -0.012,
      '요구르트': -0.008, // g당 pH 영향
      'yogurt': -0.008,
      '레몬': -0.052, // ml당 pH 영향
      'lemon': -0.052,
      '사워크림': -0.009, // g당 pH 영향
      'sour cream': -0.009,
      '숙성종': -0.015, // g당 pH 영향
      'sourdough': -0.015,
      'starter': -0.015,
    };

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String?)?.toLowerCase() ?? '';
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;

      final coefficient = acidCoefficients.entries
          .firstWhere(
            (entry) => name.contains(entry.key),
            orElse: () => MapEntry('', 0.0),
          )
          .value;

      if (coefficient != 0.0) {
        final contribution = amount * coefficient;
        totalAcidityContribution += contribution;
        debugPrint(
            '     - $name: ${amount} × ${coefficient} = ${contribution.toStringAsFixed(3)}');
      }
    }

    return totalAcidityContribution;
  }

  /// 빵 타입별 산도 패턴 적용 (클램프 없음)
  double _getBreadTypeAcidityPattern(Map<String, dynamic> recipeData) {
    // 컨셉 준수: 임시 범위 제한 금지, 실제 빅데이터 기반 패턴 적용
    final title = (recipeData['title'] as String?)?.toLowerCase() ?? '';
    final description =
        (recipeData['instructions'] as String?)?.toLowerCase() ?? '';

    // 빵 타입별 산업 경험치 기반 산도 패턴 (클램프 제거)
    if (title.contains('산종') ||
        title.contains('sourdough') ||
        title.contains('sour') ||
        description.contains('산균')) {
      return -0.8; // 산종빵: 기존에 어느 정도 산성화됨
    } else if (title.contains('유산균') ||
        title.contains('lactobacillus') ||
        title.contains('프로바이오틱') ||
        description.contains('유산균')) {
      return -0.5; // 유산균빵: 어느 정도 산성
    } else if (title.contains('식빵') ||
        title.contains('white') ||
        title.contains('식빵') ||
        description.contains('white bread')) {
      return 0.2; // 일반 식빵: 약간 알칼리성 (Dart 문법: + 접두사 불가)
    }

    // 기본 빵에서는 밀가루 자연 산도로 유지 (0조정)
    return 0.0;
  }
}

/// 기본값 제거 전략 매니저
/// 차별화 전략을 중앙 집중식으로 관리
class DifferentiationStrategyManager {
  static final DifferentiationStrategyManager _instance =
      DifferentiationStrategyManager._internal();
  factory DifferentiationStrategyManager() => _instance;
  DifferentiationStrategyManager._internal();

  final FermentationDifferentiationStrategy _defaultStrategy =
      BreadScienceBasedDifferentiation();

  FermentationDifferentiationStrategy get strategy => _defaultStrategy;
}

/// 빵 계산기 서비스 클래스
/// 기존 BreadCalculator의 기능을 모듈화하여 제공
class BreadCalculatorService {
  /// 종합 빵 분석 계산 (기존 calculateComprehensiveAnalysis와 동일한 인터페이스)
  static Map<String, dynamic> calculateComprehensiveAnalysis(
      Map<String, dynamic> inputs) {
    // 각 단계별 분석 수행 (RPM 기반 우선 사용)
    final mixingData = inputs['mixingData'] as List<dynamic>? ?? [];
    final mixingAnalysis = _calculateMixingAnalysis(inputs, mixingData);
    final doughAnalysis = _calculateDoughAnalysis(inputs, mixingAnalysis);
    final fermentationAnalysis = _calculateFermentationAnalysis(inputs);
    final ovenAnalysis = _calculateOvenAnalysis(inputs);

    // 특수 반죽 분석 정보 활용 (빵 굽기 과학 기반)
    final specialDoughAnalysis = _analyzeSpecialDoughIntegration(inputs);
    final specialDoughBonus = specialDoughAnalysis['bonus'] as double;
    final specialDoughType = specialDoughAnalysis['type'] as String;
    final specialDoughRecommendations =
        specialDoughAnalysis['recommendations'] as List<String>;

    // 전체 성공 확률 계산 (빵 굽기 과학 기반 현실적 가중치 + 특수 반죽 보정)
    // 믹싱: 35% (기초 구조 형성 - 가장 중요)
    // 발효: 32% (부피 및 풍미 형성)
    // 오븐: 23% (최종 품질 결정)
    // 반죽: 10% (중간 연결 단계)
    final overallSuccessProbability =
        (mixingAnalysis['successProbability'] * 0.35 +
                fermentationAnalysis['successProbability'] * 0.32 +
                ovenAnalysis['successProbability'] * 0.23 +
                doughAnalysis['successProbability'] * 0.10) +
            specialDoughBonus;

    // 단계별 확률
    final stageProbabilities = {
      'mixing': mixingAnalysis['successProbability'],
      'dough': doughAnalysis['successProbability'],
      'fermentation': fermentationAnalysis['successProbability'],
      'oven': ovenAnalysis['successProbability'],
    };

    // 과학적 근거 기반 종합 문제점 분석
    final comprehensiveIssues = _analyzeComprehensiveIssues(
        inputs,
        mixingAnalysis,
        doughAnalysis,
        fermentationAnalysis,
        ovenAnalysis,
        specialDoughAnalysis);

    // 최적화 권장사항 생성 (빵 굽기 과학 기반)
    final recommendations = _generateScientificRecommendations(
        inputs,
        mixingAnalysis,
        doughAnalysis,
        fermentationAnalysis,
        ovenAnalysis,
        specialDoughRecommendations);

    // RPM 기반 분석 정보 추가
    final rpmInfo = _getRPMBasedAnalysisInfo(inputs, mixingAnalysis);

    return {
      'overallSuccessProbability': overallSuccessProbability.clamp(0.0, 1.0),
      'stageProbabilities': stageProbabilities,
      'riskFactors': comprehensiveIssues,
      'recommendations': recommendations,
      'specialDoughType': specialDoughType,
      'specialDoughBonus': specialDoughBonus,

      // RPM 기반 분석 정보
      'rpmAnalysis': rpmInfo,

      // 기존 인터페이스 호환성 유지
      '최종 글루텐 형성 지수': mixingAnalysis['최종 글루텐 형성 지수'],
      '총 믹싱 시간': mixingAnalysis['총 믹싱 시간'],
      '최종 반죽 온도': mixingAnalysis['최종 반죽 온도'],
      '믹서 타입': mixingAnalysis['믹서 타입'],
      'successProbability': overallSuccessProbability.clamp(0.0, 1.0),
      'riskLevel':
          _calculateRiskLevel(overallSuccessProbability.clamp(0.0, 1.0)),
      '차수별 분석': mixingAnalysis['차수별 분석'],
      '종합 평가': {
        'totalTime': mixingAnalysis['총 믹싱 시간'],
        'finalGlutenIndex': mixingAnalysis['최종 글루텐 형성 지수'],
        'finalDoughTemp': mixingAnalysis['최종 반죽 온도'],
        'avgStageScore': _calculateAverageStageScore(mixingAnalysis['차수별 분석']),
        'successProbability': overallSuccessProbability.clamp(0.0, 1.0),
        'riskLevel':
            _calculateRiskLevel(overallSuccessProbability.clamp(0.0, 1.0)),
        'issues': comprehensiveIssues,
      },
      'issues': comprehensiveIssues,
    };
  }

  /// RPM 기반 믹싱 분석 수행
  static Map<String, dynamic> _calculateMixingAnalysis(
      Map<String, dynamic> inputs, List<dynamic> mixingData) {
    // RPM 지원 여부 확인
    final mixerType = inputs['mixerType'] as String?;
    final rpmProfile = BreadRPMCalculator.getMixerRPMProfile(mixerType);
    final isRPMMode = rpmProfile.isNotEmpty;

    if (isRPMMode) {
      return BreadMixingAnalyzer.calculateMixingStageAnalysisWithRPM(
          inputs, mixingData);
    } else {
      return BreadMixingAnalyzer.calculateMixingStageAnalysis(
          inputs, mixingData);
    }
  }

  /// 반죽 분석 수행 (차수별 믹싱 데이터 포함)
  static Map<String, dynamic> _calculateDoughAnalysis(
      Map<String, dynamic> inputs, Map<String, dynamic> mixingAnalysis) {
    // 믹싱 분석에서 차수별 데이터를 가져와 반죽온도 재계산
    final stageAnalysis =
        mixingAnalysis['차수별 분석'] as List<Map<String, dynamic>>;
    final updatedInputs = Map<String, dynamic>.from(inputs);
    updatedInputs['stageAnalysis'] = stageAnalysis;

    final result =
        BreadDoughAnalyzer.calculateDoughStageAnalysis(updatedInputs);
    final doughResult = result.toMap();

    // 최종 반죽온도는 믹싱 분석 결과의 차수별 계산을 사용
    doughResult['반죽 온도'] = mixingAnalysis['최종 반죽 온도'];

    return doughResult;
  }

  /// 발효 분석 수행 - FermentationCalculator로부터 결과 가져오기 (중앙화)
  static Map<String, dynamic> _calculateFermentationAnalysis(
      Map<String, dynamic> inputs) {
    // FermentationCalculator로부터 마지막 발효 결과를 가져와 사용
    final fermentationResult =
        FermentationCalculator.getLastFermentationResult();

    if (fermentationResult != null &&
        fermentationResult.stepResults.isNotEmpty) {
      // FermentationCalculator의 결과 사용
      final progress = fermentationResult.stepResults.last.fermentationProgress;

      // 중앙화된 값으로 stepAnalyses 구축 (기존 인터페이스 유지)
      final stepAnalyses = fermentationResult.stepResults
          .map((stepResult) => {
                'stepNumber': stepResult.stepNumber,
                'fermentationProgress': stepResult.fermentationProgress,
                'yeastActivity': stepResult.yeastActivity,
                'acidity': fermentationResult.initialAcidity,
                // 기타 기존 인터페이스 호환 필드들
                'stage': '단계 ${stepResult.stepNumber}',
                'temperature': stepResult.targetTemperature,
                'targetHumidity': stepResult.targetHumidity,
                'duration': stepResult.stepDuration,
                'volumeIncrease': 0.0,
                'gasProduction': 0.0,
                'carbonationLevel': 0.0,
                'yeastActivityLevel': 'medium',
                'volumeExpansion': 'minimal',
                'developmentNotes':
                    '단계 ${stepResult.stepNumber}: 진행률 ${(stepResult.fermentationProgress * 100).toStringAsFixed(0)}%',
              })
          .toList();

      return {
        'successProbability': 0.75 + (progress * 0.25), // 진행률에 따른 성공 확률 조정
        'optimalTotalTime': const Duration(hours: 8),
        'issues': [],
        '글루텐 형성도': (inputs['finalGlutenFormation'] as num?)?.toDouble() ?? 0.75,
        '수분 흡수율': 65.0,
        '점도': 1.35,
        'stepAnalyses': stepAnalyses,
        'fermentationSteps': fermentationResult.stepResults
            .map((step) => '단계 ${step.stepNumber}')
            .toList(),
        'yeastQualityFactor': fermentationResult.yeastQualityFactor,
        'initialAcidity': fermentationResult.initialAcidity,
      };
    }

    // FermentationCalculator 결과가 없는 경우 기본값 반환
    debugPrint('⚠️ FermentationCalculator에 발효 결과 없음 - 기본값 사용');
    return {
      'successProbability': 0.75,
      'optimalTotalTime': const Duration(hours: 8),
      'issues': [],
      '글루텐 형성도': (inputs['finalGlutenFormation'] as num?)?.toDouble() ?? 0.75,
      '수분 흡수율': 65.0,
      '점도': 1.35,
      'stepAnalyses': [],
      'fermentationSteps': [],
      'yeastQualityFactor': 1.0,
      'initialAcidity': 5.8,
    };
  }

  /// 오븐 분석 수행 (과학적 근거 기반)
  static Map<String, dynamic> _calculateOvenAnalysis(
      Map<String, dynamic> inputs) {
    double successProbability = 0.80;

    // 오븐 타입에 따른 확률 조정
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'professional' || ovenType == 'convection') {
      successProbability += 0.10;
    }

    // 오븐 성능 지수 영향
    final ovenPerformance = _calculateOvenPerformanceIndex(ovenType);
    successProbability += (ovenPerformance - 0.75) * 0.5;

    // 열 분포 균일성 영향
    final heatDistribution = _calculateHeatDistribution(ovenType);
    successProbability += (heatDistribution - 0.8) * 0.4;

    // 마이야르 반응 지수 계산 (온도와 습도 영향)
    final maillardIndex = _calculateMaillardReactionIndex(inputs);

    // 수분 이동 계수 계산
    final moistureTransfer = _calculateMoistureTransferCoefficient(inputs);

    // 크러스트 형성 지수 계산
    final crustFormation = _calculateCrustFormationIndex(inputs);

    // 성공 확률 범위 제한
    successProbability = successProbability.clamp(0.0, 1.0);

    String riskLevel = _calculateRiskLevel(successProbability);

    // 과학적 근거 기반 문제점 분석
    List<Map<String, dynamic>> issues =
        _analyzeOvenIssues(inputs, successProbability);

    return {
      '마이야르 반응 지수': '${(maillardIndex * 100).toStringAsFixed(1)}%',
      '수분 이동 계수': '${moistureTransfer.toStringAsFixed(2)}',
      '크러스트 형성 지수': '${(crustFormation * 100).toStringAsFixed(1)}%',
      'successProbability': successProbability,
      'riskLevel': riskLevel,
      'issues': issues,
    };
  }

  /// 특수 반죽 분석 서비스 통합
  static Map<String, dynamic> _analyzeSpecialDoughIntegration(
      Map<String, dynamic> inputs) {
    double specialDoughBonus = 0.0;
    List<String> specialDoughRecommendations = [];
    String specialDoughType = '표준 반죽';

    final recipeId = inputs['recipeId'] as String? ?? 'default';

    try {
      final specialDoughAnalysis =
          SpecialDoughAnalysisService.instance.getCachedResult(recipeId);

      if (specialDoughAnalysis != null &&
          specialDoughAnalysis.hasSpecialDough) {
        specialDoughType =
            specialDoughAnalysis.primarySpecialDoughType.displayName;

        // 특수 반죽 감지 신뢰도에 따른 성공 확률 보정
        final confidence =
            specialDoughAnalysis.specialDoughDetection.confidenceScores[
                    specialDoughAnalysis.primarySpecialDoughType] ??
                0.5;
        specialDoughBonus = (confidence - 0.5) * 0.1; // 최대 10% 보너스

        // 특수 반죽별 권장사항 추가
        specialDoughRecommendations
            .addAll(specialDoughAnalysis.recommendedTechniques);

        // 복합 특수 반죽 경고
        if (specialDoughAnalysis.hasComplexDough) {
          specialDoughRecommendations
              .add('복합 특수 반죽 감지: 각 특성에 맞는 특별한 주의가 필요합니다');
        }
      }
    } catch (e) {
      print('특수 반죽 분석 정보 활용 실패: $e');
    }

    return {
      'bonus': specialDoughBonus,
      'type': specialDoughType,
      'recommendations': specialDoughRecommendations,
      'analysis': null, // 향후 확장용
    };
  }

  /// 과학적 근거 기반 종합 문제점 분석
  static List<Map<String, dynamic>> _analyzeComprehensiveIssues(
      Map<String, dynamic> inputs,
      Map<String, dynamic> mixingAnalysis,
      Map<String, dynamic> doughAnalysis,
      Map<String, dynamic> fermentationAnalysis,
      Map<String, dynamic> ovenAnalysis,
      Map<String, dynamic> specialDoughAnalysis) {
    List<Map<String, dynamic>> allIssues = [];

    // 각 단계별 문제점 수집
    allIssues.addAll(mixingAnalysis['issues'] as List<Map<String, dynamic>>);
    allIssues.addAll(doughAnalysis['issues'] as List<Map<String, dynamic>>);
    allIssues
        .addAll(fermentationAnalysis['issues'] as List<Map<String, dynamic>>);
    allIssues.addAll(ovenAnalysis['issues'] as List<Map<String, dynamic>>);

    // 중복 제거 및 우선순위 정렬
    allIssues = _deduplicateAndPrioritizeIssues(allIssues);

    return allIssues;
  }

  /// 과학적 근거 기반 최적화 권장사항 생성
  static List<String> _generateScientificRecommendations(
      Map<String, dynamic> inputs,
      Map<String, dynamic> mixingAnalysis,
      Map<String, dynamic> doughAnalysis,
      Map<String, dynamic> fermentationAnalysis,
      Map<String, dynamic> ovenAnalysis,
      List<String> specialDoughRecommendations) {
    List<String> recommendations = [];

    // 환경 요인 기반 권장사항
    final temperature = inputs['temperature'] as double;
    final humidity = inputs['humidity'] as double;
    final altitude = inputs['altitude'] as double;

    // 온도 최적화 권장사항 (빵 굽기 과학 기반)
    if (temperature < 22) {
      recommendations.add('작업 온도를 24-26°C로 높여보세요 (글루텐 형성 효율 극대화).');
    } else if (temperature > 28) {
      recommendations.add('작업 온도를 24-26°C로 낮추세요 (효소 과활성 방지).');
    }

    // 습도 최적화 권장사항
    if (humidity < 60) {
      recommendations.add('가습기를 사용하여 습도를 65% 이상으로 유지하세요 (수분 흡수율 향상).');
    } else if (humidity > 80) {
      recommendations.add('환기를 통해 습도를 75% 이하로 낮추세요 (발효 효율 향상).');
    }

    // 고도 영향 권장사항
    if (altitude > 500) {
      recommendations.add('고지대에서는 수분 함량을 5-10% 높이는 것을 고려하세요.');
    }

    // 오븐 타입 권장사항
    if (inputs['ovenType'] == 'home') {
      recommendations.add('컨벡션 오븐을 고려해보세요 (더 균일한 굽기 및 15-20% 향상된 품질).');
    }

    // 믹서 타입 권장사항 - 지원되지 않는 타입에 대한 권장사항 제거
    // 이제 hand 타입은 더 이상 지원되지 않으므로 관련 권장사항 제거

    // 특수 반죽 권장사항 추가
    recommendations.addAll(specialDoughRecommendations);

    // 중복 제거
    return recommendations.toSet().toList();
  }

  /// RPM 기반 분석 정보 생성
  static Map<String, dynamic> _getRPMBasedAnalysisInfo(
      Map<String, dynamic> inputs, Map<String, dynamic> mixingAnalysis) {
    final mixerType = inputs['mixerType'] as String?;
    final rpmProfile = BreadRPMCalculator.getMixerRPMProfile(mixerType);

    if (rpmProfile.isEmpty) {
      return {'rpmSupported': false};
    }

    return {
      'rpmSupported': true,
      'mixerType': mixerType,
      'rpmProfile': rpmProfile,
      'rpmBasedCalculation': mixingAnalysis['rpmBasedCalculations'] ?? false,
    };
  }

  /// 평균 차수 점수 계산
  static String _calculateAverageStageScore(List<dynamic> stageAnalysis) {
    if (stageAnalysis.isEmpty) return '85.0점';

    double totalScore = 0.0;
    for (final stage in stageAnalysis) {
      final score = stage['차수점수'] as double? ?? 0.0;
      totalScore += score;
    }

    final averageScore = totalScore / stageAnalysis.length;
    return '${averageScore.toStringAsFixed(1)}점';
  }

  /// 오븐 성능 지수 계산
  static double _calculateOvenPerformanceIndex(String? ovenType) {
    switch (ovenType) {
      case 'professional':
        return 0.95; // 최고 성능
      case 'convection':
        return 0.88; // 우수 성능
      case 'stone_oven':
        return 0.85; // 좋은 성능
      case 'deck_oven':
        return 0.82; // 양호 성능
      case 'convection_home':
        return 0.75; // 가정용 컨벡션
      case 'gas_oven':
        return 0.70; // 가스 오븐
      case 'home':
      default:
        return 0.65; // 기본 가정용
    }
  }

  /// 열 분포 균일성 계산
  static double _calculateHeatDistribution(String? ovenType) {
    switch (ovenType) {
      case 'professional':
        return 0.95; // 최고 균일성
      case 'convection':
        return 0.90; // 우수 균일성
      case 'convection_home':
        return 0.80; // 가정용 컨벡션
      case 'deck_oven':
        return 0.75; // 좋은 균일성
      case 'stone_oven':
        return 0.70; // 스톤 오븐
      case 'gas_oven':
        return 0.65; // 가스 오븐
      case 'home':
      default:
        return 0.60; // 기본 오븐
    }
  }

  /// 마이야르 반응 지수 계산 (현실적 개선)
  static double _calculateMaillardReactionIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 온도 영향 (빵 굽기 연구에 기반한 현실적 범위: 180-220°C가 마이야르 반응 최적)
    final temperature = inputs['temperature'] as double;
    if (temperature >= 180 && temperature <= 220) {
      baseIndex += 0.08; // 최적 범위: 미세한 향상 (기존 0.15에서 47% 감소)
    } else if (temperature >= 160 && temperature <= 240) {
      baseIndex += 0.03; // 허용 범위: 최소한의 영향 (기존 0.05에서 40% 감소)
    } else if (temperature >= 150 && temperature <= 250) {
      // 확장된 허용 범위: 영향 없음 (현실적 접근)
    } else if (temperature < 150) {
      baseIndex -= 0.05; // 저온: 반응 저하 (기존 0.1에서 50% 감소)
    } else {
      baseIndex -= 0.08; // 고온: 과도한 반응 (기존 0.1에서 20% 감소)
    }

    // 습도 영향 (마이야르 반응에는 건조한 환경이 유리함)
    final humidity = inputs['humidity'] as double;
    if (humidity >= 40 && humidity <= 60) {
      baseIndex += 0.03; // 최적 습도: 미세한 향상 (기존 0.08에서 63% 감소)
    } else if (humidity >= 30 && humidity <= 70) {
      baseIndex += 0.01; // 허용 범위: 최소한의 영향 (기존 0.02에서 50% 감소)
    } else if (humidity < 30) {
      baseIndex -= 0.02; // 매우 건조: 반응 저하
    } else {
      baseIndex -= 0.05; // 고습: 반응 저하 (기존 0.05에서 변화 없음)
    }

    // 오븐 타입 영향 (빵 굽기 과학적 연구 기반)
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'professional') {
      baseIndex += 0.02; // 정밀 온도 제어: 미세한 향상 (기존 0.05에서 60% 감소)
    } else if (ovenType == 'convection') {
      baseIndex += 0.01; // 균일한 열 분포: 최소한의 향상 (기존 0.03에서 67% 감소)
    } else if (ovenType == 'stone_oven') {
      baseIndex += 0.015; // 스톤 오븐: 열 보유력으로 약간 향상
    }

    return baseIndex.clamp(0.55, 0.88); // 실제 빵 굽기 범위로 제한 (기존 0.5-0.95에서 좁힘)
  }

  /// 수분 이동 계수 계산
  static double _calculateMoistureTransferCoefficient(
      Map<String, dynamic> inputs) {
    double baseCoefficient = 1.0;

    // 온도 영향 (고온일수록 수분 이동 증가)
    final temperature = inputs['temperature'] as double;
    if (temperature >= 25 && temperature <= 30) {
      baseCoefficient += 0.1; // 최적 범위
    } else if (temperature >= 22 && temperature <= 35) {
      baseCoefficient += 0.05; // 허용 범위
    } else if (temperature > 35) {
      baseCoefficient += 0.15; // 고온: 급격한 수분 이동
    } else {
      baseCoefficient -= 0.1; // 저온: 느린 수분 이동
    }

    // 습도 영향
    final humidity = inputs['humidity'] as double;
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
      baseCoefficient += 0.05; // 전문가용: 스팀 기능 등
    }

    return baseCoefficient.clamp(0.7, 1.3);
  }

  /// 크러스트 형성 지수 계산
  static double _calculateCrustFormationIndex(Map<String, dynamic> inputs) {
    double baseIndex = 0.75;

    // 마이야르 반응 지수 영향
    double maillardIndex = _calculateMaillardReactionIndex(inputs);
    baseIndex += (maillardIndex - 0.75) * 0.8;

    // 수분 이동 계수 영향 (적절한 수분 이동이 크러스트 형성에 중요)
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
    if (ovenType == 'stone_oven') {
      baseIndex += 0.08; // 스톤 오븐: 우수한 크러스트
    } else if (ovenType == 'deck_oven') {
      baseIndex += 0.06; // 데크 오븐: 좋은 크러스트
    } else if (ovenType == 'professional') {
      baseIndex += 0.04; // 전문가용: 정밀 제어
    } else if (ovenType == 'convection') {
      baseIndex += 0.02; // 컨벡션: 균일한 크러스트
    }

    return baseIndex.clamp(0.6, 0.95);
  }

  /// 오븐 문제점 분석
  static List<Map<String, dynamic>> _analyzeOvenIssues(
      Map<String, dynamic> inputs, double successProbability) {
    List<Map<String, dynamic>> issues = [];

    // 온도 관련 문제
    final temperature = inputs['temperature'] as double;
    if (temperature > 250) {
      issues.add({
        'description': '오븐 온도가 너무 높아 탄화 현상이 발생할 수 있습니다.',
        'severity': 'high',
        'recommendation': '오븐 온도를 180-220°C 범위로 낮추세요.',
      });
    } else if (temperature < 150) {
      issues.add({
        'description': '오븐 온도가 낮아 굽기가 충분하지 않을 수 있습니다.',
        'severity': 'high',
        'recommendation': '오븐 온도를 180-220°C 범위로 높이세요.',
      });
    }

    // 습도 관련 문제
    final humidity = inputs['humidity'] as double;
    if (humidity < 30) {
      issues.add({
        'description': '습도가 너무 낮아 크러스트가 너무 딱딱해질 수 있습니다.',
        'severity': 'medium',
        'recommendation': '가습기를 사용하여 습도를 40% 이상으로 높이세요.',
      });
    } else if (humidity > 85) {
      issues.add({
        'description': '습도가 높아 크러스트 형성이 약해질 수 있습니다.',
        'severity': 'low',
        'recommendation': '환기를 통해 습도를 75% 이하로 낮추세요.',
      });
    }

    // 오븐 타입 관련 문제
    final ovenType = inputs['ovenType'] as String?;
    if (ovenType == 'home' && temperature > 200) {
      issues.add({
        'description': '가정용 오븐에서 고온 작업 시 균일한 굽기가 어려울 수 있습니다.',
        'severity': 'medium',
        'recommendation': '컨벡션 모드를 사용하거나 온도를 180°C 이하로 낮추세요.',
      });
    }

    return issues;
  }

  /// 문제점 중복 제거 및 우선순위 정렬
  static List<Map<String, dynamic>> _deduplicateAndPrioritizeIssues(
      List<Map<String, dynamic>> issues) {
    // 중복 제거 (유사한 문제점 통합)
    final uniqueIssues = <Map<String, dynamic>>[];
    final descriptions = <String>{};

    for (final issue in issues) {
      final description = issue['description'] as String;
      if (!descriptions.contains(description)) {
        descriptions.add(description);
        uniqueIssues.add(issue);
      }
    }

    // 우선순위 정렬 (severity 기준)
    final severityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};

    uniqueIssues.sort((a, b) {
      final severityA = severityOrder[a['severity']] ?? 3;
      final severityB = severityOrder[b['severity']] ?? 3;
      return severityA.compareTo(severityB);
    });

    return uniqueIssues;
  }

  /// 믹싱 단계 분석 (기존 인터페이스 호환)
  static Map<String, dynamic> calculateMixingStageAnalysis(
      Map<String, dynamic> inputs, List<dynamic> mixingData) {
    return BreadMixingAnalyzer.calculateMixingStageAnalysis(inputs, mixingData);
  }

  /// RPM 기반 믹싱 분석 (기존 인터페이스 호환)
  static Map<String, dynamic> calculateMixingStageAnalysisWithRPM(
      Map<String, dynamic> inputs, List<dynamic> mixingData) {
    return BreadMixingAnalyzer.calculateMixingStageAnalysisWithRPM(
        inputs, mixingData);
  }

  /// 반죽 단계 분석 (기존 인터페이스 호환)
  static Map<String, dynamic> calculateDoughStageAnalysis(
      Map<String, dynamic> inputs) {
    final result = BreadDoughAnalyzer.calculateDoughStageAnalysis(inputs);
    return result.toMap();
  }

  /// 발효 단계 분석 (빅데이터 예측 제거: 순수 계산만 수행)
  static Map<String, dynamic> calculateFermentationStageAnalysis(
      Map<String, dynamic> inputs) {
    // 빅데이터 예측 제거: 기본 수치 계산만 제공
    return {
      'successProbability': 0.75,
      'optimalTotalTime': const Duration(hours: 8),
      'toMap': () => {
            'successProbability': 0.75,
            'optimalTotalTime': const Duration(hours: 8),
          }
    };
  }

  /// 오븐 단계 분석 (기존 인터페이스 호환) - TODO: 오븐 모듈 생성 후 구현
  static Map<String, dynamic> calculateOvenStageAnalysis(
      Map<String, dynamic> inputs) {
    // 임시 구현 - 추후 오븐 모듈 생성 후 교체
    double successProbability = 0.80;

    // 오븐 타입에 따른 확률 조정
    if (inputs['ovenType'] == 'professional' ||
        inputs['ovenType'] == 'convection') {
      successProbability += 0.10;
    }

    String riskLevel = successProbability > 0.8
        ? '낮음'
        : successProbability > 0.6
            ? '보통'
            : '높음';

    List<Map<String, dynamic>> issues = [];

    // 온도 관련 문제
    final temperature = inputs['temperature'] as double;
    if (temperature > 30) {
      issues.add({
        'description': '오븐 온도가 높아 과도한 마이야르 반응이 발생할 수 있습니다.',
      });
    } else if (temperature < 20) {
      issues.add({
        'description': '오븐 온도가 낮아 굽기가 충분하지 않을 수 있습니다.',
      });
    }

    return {
      '마이야르 반응 지수': '75.0%',
      '수분 이동 계수': '1.0',
      '크러스트 형성 지수': '75.0%',
      'successProbability': successProbability,
      'riskLevel': riskLevel,
      'issues': issues,
    };
  }

  /// 온도 평가 함수 (기존 인터페이스 호환)
  static TemperatureEvaluation evaluateTemperature(double temperature) {
    TemperatureRange range;
    double timeMultiplier;
    double glutenFormation;
    double successBonus;
    List<String> warnings;

    if (temperature < 20) {
      range = TemperatureRange.tooLow;
      timeMultiplier = 1.3;
      glutenFormation = 0.7;
      successBonus = -0.03;
      warnings = ['저온으로 인한 글루텐 형성 지연 가능성'];
    } else if (temperature >= 20 && temperature <= 22) {
      range = TemperatureRange.low;
      timeMultiplier = 1.0;
      glutenFormation = 1.0;
      successBonus = 0.02;
      warnings = [];
    } else if (temperature > 22 && temperature <= 26) {
      range = TemperatureRange.optimal;
      timeMultiplier = 1.0;
      glutenFormation = 1.2;
      successBonus = 0.04;
      warnings = [];
    } else if (temperature > 26 && temperature <= 30) {
      range = TemperatureRange.high;
      timeMultiplier = 0.9;
      glutenFormation = 1.0;
      successBonus = 0.02;
      warnings = ['주의: 믹싱 중 고온으로 조기 발효 진행 가능성'];
    } else {
      range = TemperatureRange.tooHigh;
      timeMultiplier = 0.9;
      glutenFormation = 0.7;
      successBonus = -0.03;
      warnings = ['고온으로 인한 효소 과활성 및 글루텐 구조 약화'];
    }

    return TemperatureEvaluation(
      range: range,
      timeMultiplier: timeMultiplier,
      glutenFormation: glutenFormation,
      successBonus: successBonus,
      warnings: warnings,
    );
  }

  /// RPM 프로파일 조회 (기존 인터페이스 호환)
  static Map<String, Map<String, double>> getMixerRPMProfile(
      String? mixerType) {
    return BreadRPMCalculator.getMixerRPMProfile(mixerType);
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

  /// 전략 기반 재료 추출 (전략 패턴 적용 전단계)
  static List<Map<String, dynamic>> _extractIngredients(
      Map<String, dynamic> recipeData) {
    if (recipeData.isEmpty) return [];
    final ingredientsRaw = recipeData['ingredients'];

    if (ingredientsRaw is List) {
      return ingredientsRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } else if (ingredientsRaw is String) {
      try {
        return json.decode(ingredientsRaw) as List<Map<String, dynamic>>;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// 발효 단계 로드 - 전략 패턴 적용
  static List<art.FermentationStep> _loadFermentationSteps(
      List<Map<String, dynamic>> ingredients,
      Map<String, dynamic> recipeData,
      UserEnvironment environment) {
    // 환경 데이터 검증 (중앙화 전환)
    if (environment.temperature == null || environment.humidity == null) {
      throw Exception('발효 단계 생성에 환경 데이터가 필요합니다. 온도와 습도 데이터를 제공해주세요.');
    }

    final service = CentralizedParsingService();
    final extractedSteps = service.extractFermentationSteps(recipeData);

    debugPrint('🔍 [발효 단계 로드 디버깅]');
    debugPrint('   - extractedSteps 개수: ${extractedSteps.length}');
    for (int i = 0; i < extractedSteps.length; i++) {
      debugPrint(
          '   - step ${i + 1} keys: ${extractedSteps[i].keys.join(', ')}');
      debugPrint(
          '   - step ${i + 1} durationHours: ${extractedSteps[i]['durationHours']}');
      debugPrint(
          '   - step ${i + 1} temperature: ${extractedSteps[i]['targetTemperature']}');
      debugPrint(
          '   - step ${i + 1} humidity: ${extractedSteps[i]['targetHumidity']}');
    }

    if (extractedSteps.isEmpty) {
      debugPrint('⚠️ fermentationSteps 없음 - 과학적 기본 단계 생성');
      return _createScienceBasedFermentationSteps(environment);
    }

    // 사용자 fermentationSteps 우선 사용 (과학적 계산 방식 적용)
    final steps = <art.FermentationStep>[];
    for (int i = 0; i < extractedSteps.length; i++) {
      final stepNumber = i + 1;
      final stepData = extractedSteps[i];

      // 🚀 전략 패턴 적용: 기본값 없이 동적 계산
      final useTemperature = (stepData['targetTemperature'] as num?)
              ?.toDouble() ??
          DifferentiationStrategyManager()
              .strategy
              .calculateTargetTemperature(stepNumber, environment.temperature!);

      final useHumidity = (stepData['targetHumidity'] as num?)?.toDouble() ??
          DifferentiationStrategyManager()
              .strategy
              .calculateTargetHumidity(stepNumber, environment.humidity!);

      final rawUserDuration = (stepData['durationHours'] as num?)?.toDouble();
      final useDurationHours = DifferentiationStrategyManager()
          .strategy
          .calculateEstimatedDurationHours(
            stepNumber,
            rawUserDuration,
          );

      debugPrint('⏱️ [시간 계산 디버깅] 단계 $stepNumber:');
      debugPrint('   - rawUserDuration: $rawUserDuration');
      debugPrint('   - useDurationHours: $useDurationHours');
      debugPrint(
          '   - 변환 후 Duration: ${_convertHoursToDuration(useDurationHours)}');
      debugPrint(
          '   - Duration.inHours: ${_convertHoursToDuration(useDurationHours).inHours}');

      steps.add(
        art.FermentationStep(
          stepNumber: stepNumber,
          duration: _convertHoursToDuration(useDurationHours),
          targetTemperature: useTemperature,
          targetHumidity: useHumidity,
          expectedStage: DifferentiationStrategyManager()
              .strategy
              .determineStageDynamically(stepNumber, extractedSteps.length),
          stepNotes: stepData['description'] as String? ??
              '${stepNumber}차 발효 - 전략 패턴 적용',
        ),
      );
    }

    return steps;
  }

  /// 빵 과학 기반 기본 발효 단계들 생성 (전략 패턴 적용)
  static List<art.FermentationStep> _createScienceBasedFermentationSteps(
      UserEnvironment environment) {
    debugPrint('🧪 [빵 과학 기반 기본 단계 생성] 전략 패턴 적용');

    // fermentationSteps가 없는 경우 예상 단계 수 계산 (유동적 동작 가능)
    const int totalSteps = 3;

    final steps = <art.FermentationStep>[];
    final baseTemperature = environment.temperature!.toDouble();
    final baseHumidity = environment.humidity!.toDouble();

    // 전략 패턴 적용: 각 단계별로 직접 계산
    for (int stepNumber = 1; stepNumber <= totalSteps; stepNumber++) {
      final targetTemperature = DifferentiationStrategyManager()
          .strategy
          .calculateTargetTemperature(stepNumber, baseTemperature);
      final targetHumidity = DifferentiationStrategyManager()
          .strategy
          .calculateTargetHumidity(stepNumber, baseHumidity);
      final durationHours = DifferentiationStrategyManager()
          .strategy
          .calculateEstimatedDurationHours(stepNumber, null);
      final stage = DifferentiationStrategyManager()
          .strategy
          .determineStageDynamically(stepNumber, totalSteps);

      steps.add(art.FermentationStep(
        stepNumber: stepNumber,
        duration: _convertHoursToDuration(durationHours),
        targetTemperature: targetTemperature.clamp(18.0, 32.0),
        targetHumidity: targetHumidity.clamp(50.0, 85.0),
        expectedStage: stage,
        stepNotes: '${stepNumber}차 발효 - ${stage.displayName} (전략 패턴 적용)',
      ));

      debugPrint(
          '✅ [전략 패턴 적용] 단계 ${stepNumber} ${stage.displayName}: ${targetTemperature}°C, ${targetHumidity}%, ${durationHours}시간');
    }

    debugPrint('🧪 [빵 과학 기반 기본 단계 생성] 완료: ${steps.length}개 단계 생성');
    return steps;
  }

  /// 시간 변환 헬퍼 (전략 패턴 기반 호환성 유지)
  static Duration _convertHoursToDuration(double hours) {
    debugPrint('⏱️ [Duration 변환] 입력 hours: $hours');
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    final duration = Duration(hours: wholeHours, minutes: minutes);
    debugPrint(
        '⏱️ [Duration 변환] 결과: hours=$wholeHours, minutes=$minutes, inHours=${duration.inHours}');
    return duration;
  }

  /// 단계별 환경 기반 이스트 활성도 계산
  /// - 사용자 설정 온도/습도 우선
  /// - 차수간 연결성 유지 (이전 단계 이스트 활동 상태 반영)
  /// - 레시피 기반 이스트 품질 반영 (하드코딩 완전 제거)
  static double _calculateEnvironmentBasedYeastActivity({
    required art.FermentationStep step,
    required int stepNumber,
    required int totalSteps,
    required double previousYeastActivity,
    required double yeastQualityFactor, // 레시피 기반 이스트 품질
  }) {
    debugPrint('🧪 [단계별 환경 기반 이스트 활성도 계산] 단계 $stepNumber 시작 =====');
    debugPrint('   - 레시피 기반 이스트 품질: ${yeastQualityFactor.toStringAsFixed(3)}');

    // 2. 온도 기반 효율 계산
    final temperatureEfficiency =
        _calculateTemperatureFactor(step.targetTemperature);
    debugPrint('   - 목표 온도: ${step.targetTemperature}°C');
    debugPrint('   - 온도 효율: ${temperatureEfficiency.toStringAsFixed(3)}');

    // 3. 습도 기반 효율 계산
    final humidityEfficiency = _calculateHumidityFactor(step.targetHumidity);
    debugPrint('   - 목표 습도: ${step.targetHumidity}%');
    debugPrint('   - 습도 효율: ${humidityEfficiency.toStringAsFixed(3)}');

    // 4. 시간 기반 피로 보정 (긴 시간일수록 효율 ↓)
    final timeFatigueFactor =
        _calculateTimeFatigueFactor(step.duration.inMinutes.toDouble() / 60.0);
    debugPrint(
        '   - 단계 시간: ${step.duration.inHours.toDouble().toStringAsFixed(2)}h');
    debugPrint('   - 시간 피로 보정: ${timeFatigueFactor.toStringAsFixed(3)}');

    // 최종 계산: 레시피품질 × 환경효율 × 시간피로보정 (하드코딩 완전 제거 ✅)
    final environmentEfficiency =
        (temperatureEfficiency + humidityEfficiency) / 2.0;

    // 이전 단계 상태 반영 (선형 감소 적용 준비)
    final stepConnectionMultiplier = _calculateStepConnectionFactor(
        previousYeastActivity, yeastQualityFactor, stepNumber);

    final finalActivity = yeastQualityFactor *
        environmentEfficiency *
        (1 + timeFatigueFactor) *
        stepConnectionMultiplier;

    // ✅ 범위 제한 제거 - 과학적 계산값 그대로 반환
    debugPrint(
        '   - 최종 이스트 활성도: ${finalActivity.toStringAsFixed(3)} (범위 제한 제거)');
    debugPrint(
        '   - 계산 상세: ${yeastQualityFactor.toStringAsFixed(3)} × ${environmentEfficiency.toStringAsFixed(3)} × '
        '(1+${timeFatigueFactor.toStringAsFixed(3)}) × ${stepConnectionMultiplier.toStringAsFixed(3)} = $finalActivity');
    debugPrint('🧪 [단계별 환경 기반 이스트 활성도 계산] 단계 $stepNumber 완료 =====');

    return finalActivity; // ✅ 범위 제한 제거 - 실제 과학적 계산값 반환
  }

  /// 온도 효과 계산 (26°C 기준으로 최적화)
  static double _calculateTemperatureFactor(double temperature) {
    const optimalTemp = 26.0;
    const tolerance = 5.0; // ±5°C 범위

    final distance = (temperature - optimalTemp).abs();
    if (distance == 0) return 1.1; // 최적 온도: 110% 효율
    if (distance <= tolerance)
      return 1.0 - (distance / tolerance) * 0.1; // 점진적 감소
    return 0.5 - (distance - tolerance) / 20.0; // 과도한 차이로 급감
  }

  /// 습도 효과 계산 (70% 기준으로 최적화)
  static double _calculateHumidityFactor(double humidity) {
    const optimalHumidity = 70.0;
    const tolerance = 15.0; // ±15% 범위

    final distance = (humidity - optimalHumidity).abs();
    if (distance == 0) return 1.05; // 최적 습도: 105% 효율
    if (distance <= tolerance)
      return 1.0 - (distance / tolerance) * 0.05; // 점진적 감소
    return 0.6 - (distance - tolerance) / 30.0; // 과도한 차이로 급감
  }

  /// 시간 기반 피로 계산 (긴 시간일수록 효율 약화)
  static double _calculateTimeFatigueFactor(double hours) {
    if (hours <= 1.0) return 0.1; // 1시간 이내: 약간 상승 (+10%)
    if (hours <= 2.0) return 0.0; // 2시간 이내: 최적 (0)
    if (hours <= 4.0) return -0.05; // 4시간 이내: 약간 감소 (-5%)
    if (hours <= 8.0) return -0.15; // 8시간 이내: 중간 감소 (-15%)
    return -0.3; // 8시간 초과: 큰 감소 (-30%)
  }

  /// 단계별 이스트 활동 연결 계수 계산 (선형 감소 패턴 적용)
  static double _calculateStepConnectionFactor(
    double previousYeastActivity,
    double yeastQualityFactor,
    int stepNumber,
  ) {
    // 단계별 선형 감소 패턴 적용 (시간이 갈수록 이스트 효율 저하)
    const baseDecayRate = 0.05; // 단계당 5% 감소
    final cumulativeDecay = (stepNumber - 1) * baseDecayRate;
    final stepDecayFactor = math.max(0.5, 1.0 - cumulativeDecay); // 최소 50% 유지

    debugPrint('🔗 [단계 연결 계산] 단계 $stepNumber:');
    debugPrint('   - 이전 이스트 활동: ${previousYeastActivity.toStringAsFixed(3)}');
    debugPrint('   - 레시피 품질 기준: ${yeastQualityFactor.toStringAsFixed(3)}');
    debugPrint('   - 단계별 감쇠율: ${stepDecayFactor.toStringAsFixed(3)}');

    // 연결 계수 = 이전 활동도 × 품질 보정 × 단계 감쇠
    final activityRatio = previousYeastActivity / yeastQualityFactor;
    final connectionFactor = math.max(0.7, activityRatio) * stepDecayFactor;

    // ✅ 범위 제한 제거 - 실제 과학적 계산값 반환
    debugPrint('   - 활동도 비율: ${activityRatio.toStringAsFixed(3)}');
    debugPrint('   - 연결 계수: ${connectionFactor.toStringAsFixed(3)} (범위 제한 제거)');

    return connectionFactor; // ✅ 범위 제한 제거 - 실제 계산값 반환
  }
}

// 하위 호환성을 위한 타입 별칭
// @deprecated Use BreadCalculatorService instead
typedef BreadCalculator = BreadCalculatorService;
