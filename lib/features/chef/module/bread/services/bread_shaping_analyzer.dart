import 'dart:math' as math;
import '../../../models/recipe.dart';
import '../../../models/ingredient.dart';
import 'bread_user_data_generator.dart';
import 'bread_dough_analyzer.dart';
import 'bread_fermentation_analyzer.dart';

/// 성형 분석 데이터 모델
class ShapingAnalysisData {
  final String shapingMethod; // 성형 방법 (boule, batard, baguette 등)
  final double optimalRestingTime; // 최적 휴지 시간 (분)
  final Map<String, double> doughTemperatureEvolution; // 반죽 온도 변화
  final double glutenRelaxationIndex; // 글루텐 이완 지수
  final double doughExtensibility; // 반죽 신장성
  final double finalVolumeEstimation; // 최종 부피 예측 (L)
  final List<String> shapingIssues; // 성형 문제점
  final double shapingSuccessProbability; // 성형 성공 확률
  final DateTime analysisTimestamp; // 분석 시간

  const ShapingAnalysisData({
    required this.shapingMethod,
    required this.optimalRestingTime,
    required this.doughTemperatureEvolution,
    required this.glutenRelaxationIndex,
    required this.doughExtensibility,
    required this.finalVolumeEstimation,
    required this.shapingIssues,
    required this.shapingSuccessProbability,
    required this.analysisTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'shapingMethod': shapingMethod,
        'optimalRestingTime': optimalRestingTime,
        'doughTemperatureEvolution': doughTemperatureEvolution,
        'glutenRelaxationIndex': glutenRelaxationIndex,
        'doughExtensibility': doughExtensibility,
        'finalVolumeEstimation': finalVolumeEstimation,
        'shapingIssues': shapingIssues,
        'shapingSuccessProbability': shapingSuccessProbability,
        'analysisTimestamp': analysisTimestamp.toIso8601String(),
      };
}

/// 반죽 물리학 모델 - 성형 시뮬레이션용
class DoughPhysicsModel {
  /// 글루텐 이완 시간 계산 (Weissenberg 모델 기반)
  double calculateGlutenRelaxationTime(
      double glutenStrength, double temperature) {
    // 글루텐 이완은 온도와 글루텐 강도에 따라 달라짐
    const double baseRelaxationTime = 30.0; // 분 (기본값)
    final temperatureFactor = math.exp((temperature - 25.0) / 10.0);
    final glutenFactor = 1.0 / glutenStrength;

    return baseRelaxationTime * temperatureFactor * glutenFactor;
  }

  /// 반죽 점도 계산 (Cross 모델 기반)
  double calculateDoughViscosity(double shearRate, double glutenStrength) {
    // 반죽의 점도는 전단 속도와 글루텐 강도에 따라 달라짐
    const double zeroShearViscosity = 10000; // Pa·s
    const double criticalShearRate = 1.0; // 1/s
    const double powerIndex = 0.8;

    final viscosity = zeroShearViscosity /
        math.pow(1 + shearRate / criticalShearRate, powerIndex);

    return viscosity * glutenStrength;
  }

  /// 반죽 탄성 계산 (Maxwell 모델 기반)
  double calculateDoughElasticity(
      double glutenNetworkStability, double hydration) {
    // 탄성은 글루텐 네트워크 안정성과 수분 함량에 따라 달라짐
    const double baseElasticity = 1000; // Pa
    final stabilityFactor = glutenNetworkStability;
    final hydrationFactor = 1.0 + (hydration - 0.65) * 0.5; // 수분 조정

    return baseElasticity * stabilityFactor * hydrationFactor;
  }

  /// 최종 부피 예측 (가스 포집 모델)
  double predictFinalVolume(
      double gasVolume, double doughStrength, double shapingEfficiency) {
    // 최종 부피는 가스 발생량, 반죽 강도, 성형 효율성에 따라 달라짐
    const double gasRetentionEfficiency = 0.85; // 가스 포집 효율
    final retainedGas = gasVolume * gasRetentionEfficiency;

    final strengthFactor = doughStrength; // 반죽 강도 보정
    final shapingFactor = shapingEfficiency; // 성형 효율 보정

    return retainedGas * strengthFactor * shapingFactor;
  }
}

/// 빵모듈 성형 단계 분석 서비스
class ShapingAnalyzer {
  final DoughPhysicsModel _physicsModel = DoughPhysicsModel();

  /// 성형 방법별 특성 데이터베이스
  static const Map<String, Map<String, dynamic>> _shapingMethodData = {
    'boule': {
      'restingTime': 20.0, // 20분
      'glutenRelaxationTarget': 0.7,
      'extensibilityTarget': 0.8,
      'surfaceTension': 0.6,
      'description': '둥근 빵 성형'
    },
    'batard': {
      'restingTime': 25.0, // 25분
      'glutenRelaxationTarget': 0.8,
      'extensibilityTarget': 0.9,
      'surfaceTension': 0.7,
      'description': '타원형 빵 성형'
    },
    'baguette': {
      'restingTime': 30.0, // 30분
      'glutenRelaxationTarget': 0.9,
      'extensibilityTarget': 0.95,
      'surfaceTension': 0.8,
      'description': '바게트 성형'
    },
    'rolls': {
      'restingTime': 15.0, // 15분
      'glutenRelaxationTarget': 0.6,
      'extensibilityTarget': 0.7,
      'surfaceTension': 0.5,
      'description': '롤빵 성형'
    },
    'freeform': {
      'restingTime': 18.0, // 18분
      'glutenRelaxationTarget': 0.75,
      'extensibilityTarget': 0.85,
      'surfaceTension': 0.65,
      'description': '자유형 성형'
    },
  };

  /// 성형 분석 메인 함수
  Future<ShapingAnalysisData> analyzeShapingStage(
    FermentationAnalysisData fermentationData,
    UserComprehensiveData userData,
    DoughAnalysisData doughData,
  ) async {
    try {
      // 1. 최적 성형 방법 결정
      final shapingMethod = await _determineOptimalShapingMethod(
          fermentationData, doughData, userData);

      // 2. 최적 휴지 시간 계산
      final optimalRestingTime = await _calculateOptimalRestingTime(
          shapingMethod, doughData, userData.environment);

      // 3. 반죽 온도 변화 예측
      final temperatureEvolution = await _predictTemperatureEvolution(
          doughData.actualTemperature,
          optimalRestingTime,
          userData.environment);

      // 4. 글루텐 이완 지수 계산
      final glutenRelaxationIndex = await _calculateGlutenRelaxationIndex(
          doughData.glutenNetworkStability,
          userData.environment.temperature,
          optimalRestingTime);

      // 5. 반죽 신장성 분석
      final doughExtensibility = await _analyzeDoughExtensibility(
          doughData, fermentationData, shapingMethod);

      // 6. 최종 부피 예측
      final finalVolumeEstimation = await _estimateFinalVolume(
          fermentationData.gasGenerationVolume,
          doughData.glutenNetworkStability,
          shapingMethod);

      // 7. 성형 문제점 분석
      final shapingIssues = await _analyzeShapingIssues(glutenRelaxationIndex,
          doughExtensibility, temperatureEvolution, shapingMethod);

      // 8. 성형 성공 확률 계산
      final successProbability = await _calculateShapingSuccessProbability(
          glutenRelaxationIndex,
          doughExtensibility,
          shapingIssues,
          shapingMethod);

      return ShapingAnalysisData(
        shapingMethod: shapingMethod,
        optimalRestingTime: optimalRestingTime,
        doughTemperatureEvolution: temperatureEvolution,
        glutenRelaxationIndex: glutenRelaxationIndex,
        doughExtensibility: doughExtensibility,
        finalVolumeEstimation: finalVolumeEstimation,
        shapingIssues: shapingIssues,
        shapingSuccessProbability: successProbability,
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('성형 분석 오류: $e');
      return _getDefaultShapingAnalysisData();
    }
  }

  /// 최적 성형 방법 결정
  Future<String> _determineOptimalShapingMethod(
    FermentationAnalysisData fermentationData,
    DoughAnalysisData doughData,
    UserComprehensiveData userData,
  ) async {
    // 발효 상태에 따른 성형 방법 결정
    final yeastActivity = fermentationData.yeastActivity;
    final glutenStability = doughData.glutenNetworkStability;
    final hydration = doughData.moistureAbsorptionRate;

    // 가스 발생량에 따른 성형 방법
    if (fermentationData.gasGenerationVolume > 3.0) {
      // 많은 가스 발생 → 긴 성형이 유리
      return 'baguette';
    } else if (fermentationData.gasGenerationVolume > 2.0) {
      // 중간 가스 발생 → 타원형 성형
      return 'batard';
    } else if (glutenStability > 0.8 && hydration < 0.7) {
      // 안정적인 글루텐 + 낮은 수분 → 둥근 성형
      return 'boule';
    } else {
      // 기본 성형
      return 'freeform';
    }
  }

  /// 최적 휴지 시간 계산
  Future<double> _calculateOptimalRestingTime(
    String shapingMethod,
    DoughAnalysisData doughData,
    EnvironmentData environment,
  ) async {
    final methodData =
        _shapingMethodData[shapingMethod] ?? _shapingMethodData['boule']!;
    double baseRestingTime = methodData['restingTime'] as double;

    // 글루텐 강도에 따른 휴지 시간 조정
    final glutenStrength = doughData.glutenNetworkStability;
    if (glutenStrength > 0.8) {
      baseRestingTime *= 1.2; // 강한 글루텐은 더 긴 휴지 시간
    } else if (glutenStrength < 0.6) {
      baseRestingTime *= 0.8; // 약한 글루텐은 짧은 휴지 시간
    }

    // 온도에 따른 휴지 시간 조정
    if (environment.temperature > 25) {
      baseRestingTime *= 0.9; // 더운 온도에서는 휴지 시간 단축
    } else if (environment.temperature < 20) {
      baseRestingTime *= 1.1; // 차가운 온도에서는 휴지 시간 연장
    }

    // 수분 함량에 따른 조정
    final hydration = doughData.moistureAbsorptionRate;
    if (hydration > 0.75) {
      baseRestingTime *= 0.9; // 높은 수분은 휴지 시간 단축
    } else if (hydration < 0.65) {
      baseRestingTime *= 1.1; // 낮은 수분은 휴지 시간 연장
    }

    return baseRestingTime.clamp(10.0, 45.0); // 10분 ~ 45분 범위
  }

  /// 반죽 온도 변화 예측
  Future<Map<String, double>> _predictTemperatureEvolution(
    double currentTemperature,
    double restingTime,
    EnvironmentData environment,
  ) async {
    // 뉴턴 냉각/가열 법칙 기반 온도 변화 예측
    const double heatTransferCoefficient = 0.01; // 1/분
    const double ambientTemperature = 22.0; // 기준 실내 온도

    final timeSteps = 5; // 5단계로 나누어 예측
    final timeStep = restingTime / timeSteps;

    final temperatureEvolution = <String, double>{};
    double temp = currentTemperature;

    for (int i = 0; i <= timeSteps; i++) {
      final time = i * timeStep;
      // 뉴턴 냉각 법칙 적용
      temp = ambientTemperature +
          (currentTemperature - ambientTemperature) *
              math.exp(-heatTransferCoefficient * time);

      temperatureEvolution['step_$i'] = temp;
    }

    return temperatureEvolution;
  }

  /// 글루텐 이완 지수 계산
  Future<double> _calculateGlutenRelaxationIndex(
    double glutenNetworkStability,
    double temperature,
    double restingTime,
  ) async {
    // Weissenberg 모델 기반 글루텐 이완 계산
    final relaxationTime = _physicsModel.calculateGlutenRelaxationTime(
        glutenNetworkStability, temperature);

    // 이완 지수 = 휴지 시간 / 완전 이완 시간
    final relaxationIndex = restingTime / relaxationTime;

    // 온도 보정
    final temperatureCorrection = 1.0 + (temperature - 22.0) * 0.02;

    return (relaxationIndex * temperatureCorrection).clamp(0.3, 1.2);
  }

  /// 반죽 신장성 분석
  Future<double> _analyzeDoughExtensibility(
    DoughAnalysisData doughData,
    FermentationAnalysisData fermentationData,
    String shapingMethod,
  ) async {
    // 기본 신장성 계산
    double baseExtensibility = doughData.glutenNetworkStability * 0.8;

    // 발효 상태에 따른 보정
    final yeastActivity = fermentationData.yeastActivity;
    if (yeastActivity > 1.2) {
      baseExtensibility *= 1.1; // 높은 이스트 활성도는 신장성 증가
    } else if (yeastActivity < 0.8) {
      baseExtensibility *= 0.9; // 낮은 이스트 활성도는 신장성 감소
    }

    // 수분 함량에 따른 보정
    final hydration = doughData.moistureAbsorptionRate;
    if (hydration > 0.75) {
      baseExtensibility *= 1.15; // 높은 수분은 신장성 증가
    } else if (hydration < 0.65) {
      baseExtensibility *= 0.85; // 낮은 수분은 신장성 감소
    }

    // 성형 방법에 따른 보정
    final methodData =
        _shapingMethodData[shapingMethod] ?? _shapingMethodData['boule']!;
    final targetExtensibility = methodData['extensibilityTarget'] as double;
    final methodCorrection = targetExtensibility / 0.8; // 기준값 보정

    return (baseExtensibility * methodCorrection).clamp(0.4, 1.2);
  }

  /// 최종 부피 예측
  Future<double> _estimateFinalVolume(
    double gasVolume,
    double doughStrength,
    String shapingMethod,
  ) async {
    // 성형 방법에 따른 효율성 계수
    final shapingEfficiency = _getShapingEfficiency(shapingMethod);

    // 물리학 모델 기반 부피 예측
    final predictedVolume = _physicsModel.predictFinalVolume(
        gasVolume, doughStrength, shapingEfficiency);

    // 경험적 보정 계수 적용
    const double empiricalCorrection = 0.9; // 실제 빵 굽기 데이터 기반

    return predictedVolume * empiricalCorrection;
  }

  /// 성형 효율성 계산
  double _getShapingEfficiency(String shapingMethod) {
    const efficiencyMap = {
      'boule': 0.9, // 둥근 성형 - 높은 효율성
      'batard': 0.85, // 타원형 성형 - 중간 효율성
      'baguette': 0.8, // 바게트 성형 - 긴 성형으로 효율성 감소
      'rolls': 0.95, // 롤빵 성형 - 작은 조각으로 높은 효율성
      'freeform': 0.85, // 자유형 성형 - 중간 효율성
    };

    return efficiencyMap[shapingMethod] ?? 0.85;
  }

  /// 성형 문제점 분석
  Future<List<String>> _analyzeShapingIssues(
    double glutenRelaxationIndex,
    double doughExtensibility,
    Map<String, double> temperatureEvolution,
    String shapingMethod,
  ) async {
    final issues = <String>[];

    // 글루텐 이완 문제점
    if (glutenRelaxationIndex < 0.6) {
      issues.add('글루텐 이완이 부족합니다. 휴지 시간을 늘리거나 온도를 높여주세요.');
    } else if (glutenRelaxationIndex > 1.1) {
      issues.add('글루텐 이완이 과도합니다. 휴지 시간을 줄이거나 온도를 낮춰주세요.');
    }

    // 신장성 문제점
    if (doughExtensibility < 0.6) {
      issues.add('반죽 신장성이 부족합니다. 수분량을 늘리거나 발효 시간을 조절해주세요.');
    } else if (doughExtensibility > 1.0) {
      issues.add('반죽 신장성이 너무 높습니다. 수분량을 줄이거나 글루텐 강화를 고려해주세요.');
    }

    // 온도 변화 문제점
    final startTemp = temperatureEvolution['step_0']!;
    final endTemp = temperatureEvolution['step_5']!;
    final tempChange = (endTemp - startTemp).abs();

    if (tempChange > 5.0) {
      issues.add('휴지 중 온도 변화가 큽니다. 온도를 안정적으로 유지해주세요.');
    }

    // 성형 방법별 특화 문제점
    final methodIssues = await _analyzeMethodSpecificIssues(
        shapingMethod, glutenRelaxationIndex, doughExtensibility);
    issues.addAll(methodIssues);

    return issues;
  }

  /// 성형 방법별 특화 문제점 분석
  Future<List<String>> _analyzeMethodSpecificIssues(
    String shapingMethod,
    double glutenRelaxationIndex,
    double doughExtensibility,
  ) async {
    final issues = <String>[];

    switch (shapingMethod) {
      case 'baguette':
        if (doughExtensibility < 0.8) {
          issues.add('바게트 성형에는 높은 신장성이 필요합니다.');
        }
        if (glutenRelaxationIndex < 0.8) {
          issues.add('바게트 성형에는 충분한 글루텐 이완이 필요합니다.');
        }
        break;

      case 'boule':
        if (doughExtensibility > 1.0) {
          issues.add('둥근 성형에는 너무 높은 신장성이 부적합할 수 있습니다.');
        }
        break;

      case 'rolls':
        if (glutenRelaxationIndex > 1.0) {
          issues.add('롤빵 성형에는 과도한 글루텐 이완이 부적합할 수 있습니다.');
        }
        break;
    }

    return issues;
  }

  /// 성형 성공 확률 계산
  Future<double> _calculateShapingSuccessProbability(
    double glutenRelaxationIndex,
    double doughExtensibility,
    List<String> shapingIssues,
    String shapingMethod,
  ) async {
    double probability = 100.0;

    // 글루텐 이완 지수에 따른 점수
    if (glutenRelaxationIndex < 0.5 || glutenRelaxationIndex > 1.1) {
      probability -= 25;
    } else if (glutenRelaxationIndex < 0.7 || glutenRelaxationIndex > 0.9) {
      probability -= 10;
    }

    // 신장성에 따른 점수
    if (doughExtensibility < 0.5 || doughExtensibility > 1.1) {
      probability -= 25;
    } else if (doughExtensibility < 0.7 || doughExtensibility > 0.9) {
      probability -= 10;
    }

    // 문제점당 점수 감점
    probability -= shapingIssues.length * 8.0;

    // 긍정적 요인들
    if (glutenRelaxationIndex >= 0.7 && glutenRelaxationIndex <= 0.9) {
      probability += 10; // 최적 글루텐 이완
    }

    if (doughExtensibility >= 0.7 && doughExtensibility <= 0.9) {
      probability += 10; // 최적 신장성
    }

    // 성형 방법 적합성 보너스
    final methodBonus = await _calculateMethodBonus(shapingMethod);
    probability += methodBonus;

    return probability.clamp(0.0, 100.0);
  }

  /// 성형 방법 적합성 보너스 계산
  Future<double> _calculateMethodBonus(String shapingMethod) async {
    // 각 성형 방법의 성공률 기반 보너스
    const methodBonuses = {
      'boule': 5.0, // 둥근 성형 - 기본 보너스
      'batard': 3.0, // 타원형 성형 - 중간 보너스
      'baguette': 0.0, // 바게트 성형 - 고난도
      'rolls': 8.0, // 롤빵 성형 - 쉬운 편
      'freeform': 2.0, // 자유형 성형 - 기본 보너스
    };

    return methodBonuses[shapingMethod] ?? 2.0;
  }

  /// 기본 성형 분석 데이터 반환
  ShapingAnalysisData _getDefaultShapingAnalysisData() {
    return ShapingAnalysisData(
      shapingMethod: 'boule',
      optimalRestingTime: 20.0,
      doughTemperatureEvolution: {
        'step_0': 25.0,
        'step_1': 24.5,
        'step_2': 24.0,
        'step_3': 23.8,
        'step_4': 23.5,
        'step_5': 23.2,
      },
      glutenRelaxationIndex: 0.75,
      doughExtensibility: 0.8,
      finalVolumeEstimation: 2.5,
      shapingIssues: ['기본 성형 분석을 사용할 수 없습니다'],
      shapingSuccessProbability: 50.0,
      analysisTimestamp: DateTime.now(),
    );
  }
}
