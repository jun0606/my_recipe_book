import 'dart:math' as math;
import '../../../models/recipe.dart';
import '../../../models/ingredient.dart';
import 'bread_user_data_generator.dart';
import 'bread_dough_analyzer.dart';
import 'bread_fermentation_analyzer.dart';
import 'bread_shaping_analyzer.dart';

class BakingAnalysisData {
  final double crustThickness; // 크러스트 두께 (mm)
  final double crumbColor; // 크럼 색상 (RGB 값)
  final double crustColor; // 크러스트 색상 (RGB 값)
  final double internalTemperature; // 내부 온도 (°C)
  final double moistureLoss; // 수분 손실 (%)
  final double volumeExpansion; // 부피 팽창 (%)
  final Map<String, double> flavorCompounds; // 풍미 화합물 농도
  final List<String> bakingIssues; // 굽기 문제점
  final double bakingSuccessProbability; // 굽기 성공 확률
  final DateTime analysisTimestamp; // 분석 시간

  const BakingAnalysisData({
    required this.crustThickness,
    required this.crumbColor,
    required this.crustColor,
    required this.internalTemperature,
    required this.moistureLoss,
    required this.volumeExpansion,
    required this.flavorCompounds,
    required this.bakingIssues,
    required this.bakingSuccessProbability,
    required this.analysisTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'crustThickness': crustThickness,
        'crumbColor': crumbColor,
        'crustColor': crustColor,
        'internalTemperature': internalTemperature,
        'moistureLoss': moistureLoss,
        'volumeExpansion': volumeExpansion,
        'flavorCompounds': flavorCompounds,
        'bakingIssues': bakingIssues,
        'bakingSuccessProbability': bakingSuccessProbability,
        'analysisTimestamp': analysisTimestamp.toIso8601String(),
      };
}

/// 오븐 열전달 및 화학 반응 시뮬레이터
class OvenBakingSimulator {
  /// Fourier의 법칙 기반 열전달 계산
  double calculateHeatTransfer(double ovenTemp, double surfaceTemp,
      double thermalConductivity, double thickness) {
    // 열전달 계수 (W/m²K)
    const double heatTransferCoeff = 15.0;

    // Fourier의 법칙: q = -k * dT/dx
    final heatFlux = heatTransferCoeff * (ovenTemp - surfaceTemp);

    // 열확산 방정식 적용
    final timeStep = 60.0; // 1분
    final temperatureIncrease =
        (heatFlux * timeStep) / (thermalConductivity * thickness);

    return temperatureIncrease;
  }

  /// Maillard 반응 속도 계산
  double calculateMaillardReaction(
      double temperature, double ph, double waterActivity) {
    // Maillard 반응 속도 상수
    const double kMaillard = 0.001;

    // Arrhenius 방정식 적용 (활성화 에너지 고려)
    const double activationEnergy = 50000; // J/mol
    const double gasConstant = 8.314; // J/mol·K
    const double referenceTemp = 373.15; // 100°C (켈빈)

    final temperatureKelvin = temperature + 273.15;
    final arrheniusFactor = math.exp(-activationEnergy /
        gasConstant *
        (1 / temperatureKelvin - 1 / referenceTemp));

    // pH 및 수분 활성도 보정
    final phCorrection = math.max(0.1, math.exp(-math.pow(ph - 7.0, 2)));
    final waterCorrection = math.max(0.1, waterActivity);

    return kMaillard * arrheniusFactor * phCorrection * waterCorrection;
  }

  /// 캐러멜화 반응 계산
  double calculateCaramelization(double temperature, double sugarContent) {
    // 캐러멜화 반응은 160°C 이상에서 발생
    if (temperature < 160.0) return 0.0;

    // 반응 속도 상수
    const double kCaramel = 0.0005;

    // 온도 의존성
    final tempFactor = math.pow((temperature - 160.0) / 20.0, 2);

    // 설탕 함량 의존성
    final sugarFactor = math.min(1.0, sugarContent / 10.0); // 10% 기준

    return kCaramel * tempFactor * sugarFactor;
  }

  /// 증기 효과 시뮬레이션
  Map<String, double> simulateSteamEffect(
      double steamTime, double steamTemperature, double doughMoisture) {
    // 증기 효과 계산
    final steamPenetration = math.min(1.0, steamTime / 5.0); // 5분 기준 최대 침투
    final moistureRetention = 0.95 + (steamPenetration * 0.05); // 수분 유지율
    final surfaceHardening = steamTemperature > 100 ? 1.2 : 0.8; // 표면 경화도

    return {
      'steam_penetration': steamPenetration,
      'moisture_retention': moistureRetention,
      'surface_hardening': surfaceHardening,
      'crust_formation': steamPenetration * surfaceHardening,
    };
  }

  /// 빵 내부 온도 분포 예측
  Map<String, double> predictTemperatureDistribution(
      double ovenTemp, double bakingTime, double breadDiameter) {
    // 빵 중심부와 표면의 온도 차이 계산
    const double thermalDiffusivity = 1.4e-7; // 빵의 열확산율 (m²/s)

    final radius = breadDiameter / 2.0;
    final timeInSeconds = bakingTime * 60.0;

    // Fourier 수 계산 (무차원 시간)
    final fourierNumber =
        thermalDiffusivity * timeInSeconds / (radius * radius);

    // 중심부 온도 상승 예측 (근사식)
    final centerTempRise = ovenTemp * (1 - math.exp(-2.5 * fourierNumber));

    // 표면 온도 (오븐 온도에 가까움)
    final surfaceTemp = ovenTemp * 0.95;

    // 평균 온도
    final averageTemp = (centerTempRise + surfaceTemp) / 2.0;

    return {
      'center_temperature': centerTempRise,
      'surface_temperature': surfaceTemp,
      'average_temperature': averageTemp,
      'temperature_gradient': surfaceTemp - centerTempRise,
    };
  }

  /// 색상 변화 예측 (RGB 값)
  Map<String, int> predictColorChange(
      double maillardProgress, double caramelProgress, double initialColor) {
    // 초기 색상 (RGB)
    final initialR = 255;
    final initialG = 255;
    final initialB = 255;

    // Maillard 반응에 의한 갈변
    final maillardBrown = (maillardProgress * 100).clamp(0, 100);
    final rMaillard = (initialR - maillardBrown * 0.6).clamp(0, 255);
    final gMaillard = (initialG - maillardBrown * 0.4).clamp(0, 255);
    final bMaillard = (initialB - maillardBrown * 0.8).clamp(0, 255);

    // 캐러멜화에 의한 색상 변화
    final caramelFactor = (caramelProgress * 50).clamp(0, 50);
    final rCaramel = (rMaillard - caramelFactor).clamp(0, 255);
    final gCaramel = (gMaillard - caramelFactor * 0.7).clamp(0, 255);
    final bCaramel = (bMaillard - caramelFactor * 0.9).clamp(0, 255);

    return {
      'red': rCaramel.toInt(),
      'green': gCaramel.toInt(),
      'blue': bCaramel.toInt(),
    };
  }

  /// 풍미 화합물 생성 예측
  Map<String, double> predictFlavorCompounds(
      double maillardProgress, double caramelProgress, double bakingTime) {
    // 주요 풍미 화합물 농도 계산
    final furfural = maillardProgress * 0.8; // 퓨르푸랄 (카라멜 향)
    final pyrazines = maillardProgress * 0.6; // 피라진 (너티 향)
    final aldehydes = caramelProgress * 0.7; // 알데히드 (달콤한 향)
    final ketones = maillardProgress * 0.5; // 케톤 (버터 향)
    final acids = bakingTime * 0.1; // 유기산 (신맛)

    return {
      'furfural': furfural.clamp(0, 1.0),
      'pyrazines': pyrazines.clamp(0, 1.0),
      'aldehydes': aldehydes.clamp(0, 1.0),
      'ketones': ketones.clamp(0, 1.0),
      'organic_acids': acids.clamp(0, 1.0),
    };
  }
}

/// 빵모듈 굽기 단계 분석 서비스
class BakingAnalyzer {
  final OvenBakingSimulator _ovenSimulator = OvenBakingSimulator();

  /// 오븐 설정별 특성 데이터베이스
  static const Map<String, Map<String, dynamic>> _ovenSettingsData = {
    'conventional': {
      'heat_distribution': 0.8,
      'steam_support': false,
      'max_temperature': 250.0,
      'description': '일반 오븐'
    },
    'convection': {
      'heat_distribution': 0.95,
      'steam_support': true,
      'max_temperature': 230.0,
      'description': '대류식 오븐'
    },
    'steam': {
      'heat_distribution': 0.9,
      'steam_support': true,
      'max_temperature': 220.0,
      'description': '증기 오븐'
    },
    'stone': {
      'heat_distribution': 0.85,
      'steam_support': false,
      'max_temperature': 300.0,
      'description': '스톤 데크 오븐'
    },
    'dutch_oven': {
      'heat_distribution': 0.75,
      'steam_support': true,
      'max_temperature': 260.0,
      'description': '더치 오븐'
    },
  };

  /// 굽기 분석 메인 함수
  Future<BakingAnalysisData> analyzeBakingStage(
    ShapingAnalysisData shapingData,
    UserComprehensiveData userData,
    FermentationAnalysisData fermentationData,
    DoughAnalysisData doughData,
  ) async {
    try {
      // 1. 오븐 설정 분석
      final ovenSettings =
          await _analyzeOvenSettings(userData.equipmentPerformance);

      // 2. 최적 굽기 온도 및 시간 계산
      final optimalBakingParams = await _calculateOptimalBakingParameters(
          shapingData, ovenSettings, userData.environment);

      // 3. 열전달 시뮬레이션
      final heatTransferResults =
          await _simulateHeatTransfer(optimalBakingParams, shapingData);

      // 4. 화학 반응 시뮬레이션 (Maillard, 캐러멜화)
      final chemicalReactions = await _simulateChemicalReactions(
          heatTransferResults, fermentationData, doughData);

      // 5. 크러스트 형성 분석
      final crustFormation = await _analyzeCrustFormation(
          chemicalReactions, heatTransferResults, ovenSettings);

      // 6. 수분 이동 및 손실 계산
      final moistureMigration = await _calculateMoistureMigration(
          heatTransferResults, shapingData, ovenSettings);

      // 7. 부피 팽창 예측
      final volumeExpansion = await _predictVolumeExpansion(
          fermentationData, heatTransferResults, shapingData);

      // 8. 색상 변화 예측
      final colorChanges =
          await _predictColorChanges(chemicalReactions, crustFormation);

      // 9. 풍미 화합물 생성 예측
      final flavorCompounds = await _predictFlavorDevelopment(
          chemicalReactions, optimalBakingParams['bakingTime'] as double);

      // 10. 문제점 분석
      final bakingIssues = await _analyzeBakingIssues(heatTransferResults,
          chemicalReactions, moistureMigration, ovenSettings);

      // 11. 성공 확률 계산
      final successProbability = await _calculateBakingSuccessProbability(
          crustFormation, moistureMigration, volumeExpansion, bakingIssues);

      return BakingAnalysisData(
        crustThickness: crustFormation['thickness'] as double,
        crumbColor: colorChanges['crumb'] as double,
        crustColor: colorChanges['crust'] as double,
        internalTemperature:
            heatTransferResults['center_temperature'] as double,
        moistureLoss: moistureMigration['total_loss'] as double,
        volumeExpansion: volumeExpansion,
        flavorCompounds: flavorCompounds,
        bakingIssues: bakingIssues,
        bakingSuccessProbability: successProbability,
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('굽기 분석 오류: $e');
      return _getDefaultBakingAnalysisData();
    }
  }

  /// 오븐 설정 분석
  Future<Map<String, dynamic>> _analyzeOvenSettings(
      EquipmentPerformanceData equipmentPerformance) async {
    final ovenType = equipmentPerformance.ovenType;
    final baseSettings =
        _ovenSettingsData[ovenType] ?? _ovenSettingsData['conventional']!;

    return {
      'oven_type': ovenType,
      'heat_distribution': baseSettings['heat_distribution'],
      'steam_support': baseSettings['steam_support'],
      'max_temperature': baseSettings['max_temperature'],
      'accuracy': equipmentPerformance.ovenAccuracy,
      'description': baseSettings['description'],
    };
  }

  /// 최적 굽기 파라미터 계산
  Future<Map<String, dynamic>> _calculateOptimalBakingParameters(
    ShapingAnalysisData shapingData,
    Map<String, dynamic> ovenSettings,
    EnvironmentData environment,
  ) async {
    // 기본 굽기 온도 (화씨를 섭씨로 변환)
    final baseTemp = 220.0; // 220°C
    final ovenType = ovenSettings['oven_type'] as String;

    // 오븐 타입별 온도 조정
    double adjustedTemp = baseTemp;
    switch (ovenType) {
      case 'convection':
        adjustedTemp = 200.0; // 대류식은 낮은 온도
        break;
      case 'steam':
        adjustedTemp = 210.0; // 증기 오븐은 중간 온도
        break;
      case 'stone':
        adjustedTemp = 240.0; // 스톤 오븐은 높은 온도
        break;
      case 'dutch_oven':
        adjustedTemp = 230.0; // 더치 오븐은 높은 온도
        break;
    }

    // 빵 크기별 시간 조정 (작은 빵은 짧은 시간)
    final finalVolume = shapingData.finalVolumeEstimation;
    double bakingTime = 25.0; // 기본 25분
    if (finalVolume < 1.5) {
      bakingTime = 20.0; // 작은 빵
    } else if (finalVolume > 3.0) {
      bakingTime = 35.0; // 큰 빵
    }

    // 환경 온도 보정
    if (environment.temperature > 25) {
      adjustedTemp -= 10; // 더운 날은 낮은 온도
      bakingTime -= 3;
    } else if (environment.temperature < 15) {
      adjustedTemp += 10; // 추운 날은 높은 온도
      bakingTime += 3;
    }

    return {
      'baking_temperature': adjustedTemp,
      'baking_time': bakingTime,
      'preheat_time': 20.0, // 예열 시간
    };
  }

  /// 열전달 시뮬레이션
  Future<Map<String, double>> _simulateHeatTransfer(
    Map<String, dynamic> bakingParams,
    ShapingAnalysisData shapingData,
  ) async {
    final ovenTemp = bakingParams['baking_temperature'] as double;
    final bakingTime = bakingParams['baking_time'] as double;

    // 빵 크기 계산 (부피에서 직경 추정)
    final volume = shapingData.finalVolumeEstimation;
    final diameter = math.pow(volume * 0.75, 1 / 3) * 2; // 근사치 계산

    // 열전달 시뮬레이션 실행
    final tempDistribution = _ovenSimulator.predictTemperatureDistribution(
        ovenTemp, bakingTime, diameter);

    return {
      'center_temperature': tempDistribution['center_temperature']!,
      'surface_temperature': tempDistribution['surface_temperature']!,
      'average_temperature': tempDistribution['average_temperature']!,
      'temperature_gradient': tempDistribution['temperature_gradient']!,
      'heat_penetration_rate':
          tempDistribution['temperature_gradient']! / diameter,
    };
  }

  /// 화학 반응 시뮬레이션
  Future<Map<String, double>> _simulateChemicalReactions(
    Map<String, double> heatTransferResults,
    FermentationAnalysisData fermentationData,
    DoughAnalysisData doughData,
  ) async {
    final surfaceTemp = heatTransferResults['surface_temperature']!;
    final centerTemp = heatTransferResults['center_temperature']!;

    // Maillard 반응 (표면에서 주로 발생)
    final maillardReaction = _ovenSimulator.calculateMaillardReaction(
        surfaceTemp, 6.0, 0.85); // pH 6.0, 수분 활성도 0.85

    // 캐러멜화 반응 (고온에서 발생)
    final caramelReaction =
        _ovenSimulator.calculateCaramelization(surfaceTemp, 2.0); // 2% 설탕 함량 가정

    // 발효 생성물에 의한 추가 반응
    final yeastContribution = fermentationData.yeastActivity * 0.1;
    final glutenEffect = doughData.glutenNetworkStability * 0.05;

    return {
      'maillard_progress': maillardReaction,
      'caramel_progress': caramelReaction,
      'total_browning': maillardReaction + caramelReaction,
      'yeast_contribution': yeastContribution,
      'gluten_effect': glutenEffect,
    };
  }

  /// 크러스트 형성 분석
  Future<Map<String, dynamic>> _analyzeCrustFormation(
    Map<String, double> chemicalReactions,
    Map<String, double> heatTransferResults,
    Map<String, dynamic> ovenSettings,
  ) async {
    final surfaceTemp = heatTransferResults['surface_temperature']!;
    final maillardProgress = chemicalReactions['maillard_progress']!;
    final caramelProgress = chemicalReactions['caramel_progress']!;

    // 크러스트 두께 계산 (수분 이동과 열에 의한 형성)
    double crustThickness = 2.0; // 기본 2mm
    if (surfaceTemp > 180) {
      crustThickness += (surfaceTemp - 180) * 0.02; // 고온에서 두꺼워짐
    }

    // Maillard 반응에 의한 강화
    crustThickness *= (1 + maillardProgress * 0.3);

    // 오븐 타입별 보정
    final ovenType = ovenSettings['oven_type'] as String;
    switch (ovenType) {
      case 'steam':
        crustThickness *= 0.9; // 증기는 크러스트 얇게
        break;
      case 'stone':
        crustThickness *= 1.2; // 스톤은 크러스트 두껍게
        break;
    }

    // 크러스트 강도 계산
    final crustStrength = maillardProgress * 0.8 + caramelProgress * 0.2;

    return {
      'thickness': crustThickness.clamp(1.0, 8.0),
      'strength': crustStrength.clamp(0.1, 1.0),
      'uniformity': ovenSettings['heat_distribution'] as double,
      'crispiness': maillardProgress * 0.9 + caramelProgress * 0.1,
    };
  }

  /// 수분 이동 및 손실 계산
  Future<Map<String, double>> _calculateMoistureMigration(
    Map<String, double> heatTransferResults,
    ShapingAnalysisData shapingData,
    Map<String, dynamic> ovenSettings,
  ) async {
    final surfaceTemp = heatTransferResults['surface_temperature']!;
    final centerTemp = heatTransferResults['center_temperature']!;
    final bakingTime = heatTransferResults['baking_time'] as double? ?? 25.0;

    // 표면 증발
    double surfaceEvaporation = 0.0;
    if (surfaceTemp > 100) {
      surfaceEvaporation = (surfaceTemp - 100) * bakingTime * 0.01;
    }

    // 내부 수분 이동
    final moistureGradient = centerTemp - surfaceTemp;
    final internalMigration = moistureGradient * 0.005;

    // 오븐 타입별 보정
    final ovenType = ovenSettings['oven_type'] as String;
    double ovenCorrection = 1.0;

    switch (ovenType) {
      case 'steam':
        ovenCorrection = 0.7; // 증기는 수분 손실 적음
        break;
      case 'convection':
        ovenCorrection = 1.2; // 대류는 수분 손실 많음
        break;
    }

    final totalLoss = (surfaceEvaporation + internalMigration) * ovenCorrection;
    final finalMoisture = math.max(0.0, 65.0 - totalLoss); // 초기 수분 65% 가정

    return {
      'surface_evaporation': surfaceEvaporation,
      'internal_migration': internalMigration,
      'total_loss': totalLoss,
      'final_moisture': finalMoisture,
      'moisture_retention': finalMoisture / 65.0,
    };
  }

  /// 부피 팽창 예측
  Future<double> _predictVolumeExpansion(
    FermentationAnalysisData fermentationData,
    Map<String, double> heatTransferResults,
    ShapingAnalysisData shapingData,
  ) async {
    // 가스 팽창 (이스트 가스)
    final gasExpansion = fermentationData.gasGenerationVolume * 0.8;

    // 수증기 팽창
    final steamExpansion =
        heatTransferResults['moisture_loss'] as double? ?? 0.0 * 0.3;

    // 글루텐 네트워크 팽창
    final glutenExpansion = shapingData.glutenRelaxationIndex * 0.2;

    // 온도에 의한 팽창
    final tempExpansion =
        (heatTransferResults['center_temperature']! - 25.0) * 0.002;

    final totalExpansion =
        gasExpansion + steamExpansion + glutenExpansion + tempExpansion;

    return totalExpansion.clamp(0.0, 50.0); // 최대 50% 팽창
  }

  /// 색상 변화 예측
  Future<Map<String, double>> _predictColorChanges(
    Map<String, double> chemicalReactions,
    Map<String, dynamic> crustFormation,
  ) async {
    final maillardProgress = chemicalReactions['maillard_progress']!;
    final caramelProgress = chemicalReactions['caramel_progress']!;

    // 크럼 색상 (내부)
    final crumbColor = 255.0 - (maillardProgress * 50); // 약한 갈변

    // 크러스트 색상 (표면)
    final crustColor =
        255.0 - (maillardProgress * 150 + caramelProgress * 100); // 강한 갈변

    return {
      'crumb': crumbColor.clamp(0, 255),
      'crust': crustColor.clamp(0, 255),
      'contrast': crustColor - crumbColor,
    };
  }

  /// 풍미 화합물 생성 예측
  Future<Map<String, double>> _predictFlavorDevelopment(
    Map<String, double> chemicalReactions,
    double bakingTime,
  ) async {
    return _ovenSimulator.predictFlavorCompounds(
      chemicalReactions['maillard_progress']!,
      chemicalReactions['caramel_progress']!,
      bakingTime,
    );
  }

  /// 문제점 분석
  Future<List<String>> _analyzeBakingIssues(
    Map<String, double> heatTransferResults,
    Map<String, double> chemicalReactions,
    Map<String, double> moistureMigration,
    Map<String, dynamic> ovenSettings,
  ) async {
    final issues = <String>[];

    // 온도 문제점
    final centerTemp = heatTransferResults['center_temperature']!;
    final surfaceTemp = heatTransferResults['surface_temperature']!;

    if (centerTemp < 90) {
      issues.add('내부 온도가 충분히 높지 않습니다. 굽기 시간을 늘려주세요.');
    } else if (centerTemp > 100) {
      issues.add('내부 온도가 너무 높습니다. 빵이 건조해질 수 있습니다.');
    }

    if (surfaceTemp > 220) {
      issues.add('표면 온도가 너무 높습니다. 크러스트가 타거나 너무 두꺼워질 수 있습니다.');
    }

    // 수분 문제점
    final moistureLoss = moistureMigration['total_loss']!;
    if (moistureLoss > 25) {
      issues.add('수분 손실이 너무 많습니다. 빵이 건조해질 수 있습니다.');
    } else if (moistureLoss < 10) {
      issues.add('수분 손실이 적습니다. 빵이 충분히 익지 않았을 수 있습니다.');
    }

    // 화학 반응 문제점
    final maillardProgress = chemicalReactions['maillard_progress']!;
    if (maillardProgress < 0.3) {
      issues.add('Maillard 반응이 부족합니다. 색상과 풍미가 부족할 수 있습니다.');
    } else if (maillardProgress > 0.8) {
      issues.add('Maillard 반응이 과도합니다. 크러스트가 너무 어두워질 수 있습니다.');
    }

    // 오븐 문제점
    final heatDistribution = ovenSettings['heat_distribution'] as double;
    if (heatDistribution < 0.8) {
      issues.add('오븐의 열 분배가 고르지 않습니다. 빵이 균일하게 익지 않을 수 있습니다.');
    }

    final steamSupport = ovenSettings['steam_support'] as bool;
    if (!steamSupport && moistureLoss > 20) {
      issues.add('증기 기능이 없어 수분 손실이 많을 수 있습니다.');
    }

    return issues;
  }

  /// 성공 확률 계산
  Future<double> _calculateBakingSuccessProbability(
    Map<String, dynamic> crustFormation,
    Map<String, double> moistureMigration,
    double volumeExpansion,
    List<String> bakingIssues,
  ) async {
    double probability = 100.0;

    // 크러스트 형성 평가
    final crustStrength = crustFormation['strength'] as double;
    if (crustStrength < 0.3) {
      probability -= 30;
    } else if (crustStrength < 0.6) {
      probability -= 15;
    }

    // 수분 균형 평가
    final moistureRetention = moistureMigration['moisture_retention']!;
    if (moistureRetention < 0.6) {
      probability -= 25;
    } else if (moistureRetention < 0.8) {
      probability -= 10;
    }

    // 부피 팽창 평가
    if (volumeExpansion < 10) {
      probability -= 20;
    } else if (volumeExpansion < 20) {
      probability -= 10;
    } else if (volumeExpansion > 40) {
      probability -= 15;
    }

    // 문제점당 감점
    probability -= bakingIssues.length * 5.0;

    // 긍정적 요인들
    if (crustFormation['uniformity'] as double > 0.9) {
      probability += 10; // 균일한 크러스트
    }

    if (volumeExpansion >= 20 && volumeExpansion <= 35) {
      probability += 15; // 적절한 팽창
    }

    return probability.clamp(0.0, 100.0);
  }

  /// 기본 굽기 분석 데이터 반환
  BakingAnalysisData _getDefaultBakingAnalysisData() {
    return BakingAnalysisData(
      crustThickness: 3.0,
      crumbColor: 240.0,
      crustColor: 180.0,
      internalTemperature: 95.0,
      moistureLoss: 20.0,
      volumeExpansion: 25.0,
      flavorCompounds: {
        'furfural': 0.3,
        'pyrazines': 0.2,
        'aldehydes': 0.4,
        'ketones': 0.1,
        'organic_acids': 0.15,
      },
      bakingIssues: ['기본 굽기 분석을 사용할 수 없습니다'],
      bakingSuccessProbability: 50.0,
      analysisTimestamp: DateTime.now(),
    );
  }
}
