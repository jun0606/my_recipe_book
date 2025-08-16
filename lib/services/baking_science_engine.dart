/// 베이킹 사이언스 엔진
/// 과학적 원리에 기반한 베이킹 특성 계산 및 예측을 제공합니다.

import 'dart:math' as math;

class BakingScienceEngine {
  /// Maillard 반응 계산
  /// 온도, 시간, 당분, 아미노산 존재 여부를 고려하여 갈변 정도를 예측
  static MaillardReactionResult calculateMaillardReaction({
    required double temperature, // 섭씨 온도
    required double timeMinutes, // 굽기 시간 (분)
    required double sugarContent, // 당분 함량 (g)
    required double proteinContent, // 단백질 함량 (g)
    required double moisture, // 수분 함량 (0.0 ~ 1.0)
  }) {
    // Maillard 반응 시작 온도: 140°C
    const double maillardThreshold = 140.0;
    
    if (temperature < maillardThreshold) {
      return MaillardReactionResult(
        intensity: 0.0,
        colorLevel: MaillardColorLevel.none,
        flavorCompounds: [],
        estimatedColor: 'pale',
      );
    }

    // 온도 효과 계산 (지수적 증가)
    double temperatureEffect = math.pow((temperature - maillardThreshold) / 60.0, 1.5).toDouble();
    temperatureEffect = math.min(temperatureEffect, 3.0); // 최대값 제한

    // 시간 효과 계산 (로그적 증가)
    double timeEffect = math.log(timeMinutes + 1) / math.log(60); // 60분 기준 정규화
    timeEffect = math.min(timeEffect, 2.0);

    // 당분 효과 (당분이 많을수록 반응 촉진)
    double sugarEffect = math.min(sugarContent / 50.0, 2.0); // 50g 기준

    // 단백질 효과 (아미노산 공급원)
    double proteinEffect = math.min(proteinContent / 30.0, 1.5); // 30g 기준

    // 수분 효과 (수분이 너무 높으면 반응 억제)
    double moistureEffect = moisture < 0.3 ? 1.0 : (1.0 - (moisture - 0.3) * 0.5);
    moistureEffect = math.max(moistureEffect, 0.3);

    // 전체 반응 강도 계산
    double intensity = temperatureEffect * timeEffect * sugarEffect * proteinEffect * moistureEffect;
    intensity = math.min(intensity, 10.0); // 0-10 스케일

    // 색상 레벨 결정
    MaillardColorLevel colorLevel;
    String estimatedColor;
    
    if (intensity < 1.0) {
      colorLevel = MaillardColorLevel.light;
      estimatedColor = 'light golden';
    } else if (intensity < 3.0) {
      colorLevel = MaillardColorLevel.medium;
      estimatedColor = 'golden brown';
    } else if (intensity < 6.0) {
      colorLevel = MaillardColorLevel.dark;
      estimatedColor = 'deep brown';
    } else {
      colorLevel = MaillardColorLevel.veryDark;
      estimatedColor = 'dark brown';
    }

    // 풍미 화합물 예측
    List<String> flavorCompounds = _predictFlavorCompounds(intensity, sugarContent, proteinContent);

    return MaillardReactionResult(
      intensity: intensity,
      colorLevel: colorLevel,
      flavorCompounds: flavorCompounds,
      estimatedColor: estimatedColor,
    );
  }

  /// 글루텐 강도 예측
  /// 밀가루 종류, 수분율, 반죽 시간을 고려하여 글루텐 네트워크 강도를 계산
  static GlutenStrengthResult predictGlutenStrength({
    required String flourType, // 밀가루 종류
    required double hydration, // 수분율 (0.0 ~ 1.0)
    required double kneadingTimeMinutes, // 반죽 시간 (분)
    required double saltPercentage, // 소금 비율 (0.0 ~ 1.0)
  }) {
    // 밀가루별 기본 글루텐 강도
    double baseStrength = _getFlourGlutenStrength(flourType);
    
    // 수분율 효과 (적정 수분율에서 최대 강도)
    double hydrationEffect;
    if (hydration < 0.5) {
      hydrationEffect = hydration / 0.5; // 수분 부족 시 선형 감소
    } else if (hydration <= 0.7) {
      hydrationEffect = 1.0; // 적정 범위
    } else {
      hydrationEffect = 1.0 - (hydration - 0.7) * 0.5; // 과수분 시 감소
    }
    hydrationEffect = math.max(hydrationEffect, 0.2);

    // 반죽 시간 효과 (적정 시간에서 최대, 과반죽 시 감소)
    double kneadingEffect;
    if (kneadingTimeMinutes <= 10) {
      kneadingEffect = kneadingTimeMinutes / 10.0; // 10분까지 선형 증가
    } else if (kneadingTimeMinutes <= 15) {
      kneadingEffect = 1.0; // 적정 범위
    } else {
      kneadingEffect = 1.0 - (kneadingTimeMinutes - 15) * 0.05; // 과반죽 시 감소
    }
    kneadingEffect = math.max(kneadingEffect, 0.3);

    // 소금 효과 (글루텐 강화)
    double saltEffect = 1.0 + saltPercentage * 0.5; // 소금이 글루텐 강화
    saltEffect = math.min(saltEffect, 1.3);

    // 전체 글루텐 강도 계산
    double totalStrength = baseStrength * hydrationEffect * kneadingEffect * saltEffect;
    totalStrength = math.min(totalStrength, 10.0);

    // 글루텐 강도 레벨 결정
    GlutenStrengthLevel strengthLevel;
    if (totalStrength < 3.0) {
      strengthLevel = GlutenStrengthLevel.weak;
    } else if (totalStrength < 6.0) {
      strengthLevel = GlutenStrengthLevel.medium;
    } else if (totalStrength < 8.0) {
      strengthLevel = GlutenStrengthLevel.strong;
    } else {
      strengthLevel = GlutenStrengthLevel.veryStrong;
    }

    return GlutenStrengthResult(
      strength: totalStrength,
      level: strengthLevel,
      expectedTexture: _predictTextureFromGluten(strengthLevel, hydration),
      windowPaneTestResult: totalStrength > 6.0,
    );
  }

  /// 발효 시간 최적화
  /// 온도, 이스트량, 당분을 고려하여 최적 발효 시간을 계산
  static FermentationOptimizationResult optimizeFermentationTime({
    required double temperature, // 발효 온도 (섭씨)
    required double yeastPercentage, // 이스트 비율 (0.0 ~ 1.0)
    required double sugarContent, // 당분 함량 (g)
    required double saltPercentage, // 소금 비율 (이스트 억제 효과)
    required double doughWeight, // 반죽 무게 (g)
  }) {
    // 기준 발효 시간 (25°C, 1% 이스트 기준)
    const double baseFermentationMinutes = 90.0;

    // 온도 효과 (Q10 법칙 적용 - 10도 상승 시 2배 빨라짐)
    double temperatureEffect = math.pow(2, (temperature - 25) / 10).toDouble();
    temperatureEffect = math.max(temperatureEffect, 0.2); // 최소값 제한
    temperatureEffect = math.min(temperatureEffect, 5.0); // 최대값 제한

    // 이스트 효과 (이스트량에 비례)
    double yeastEffect = yeastPercentage / 0.01; // 1% 기준 정규화
    yeastEffect = math.max(yeastEffect, 0.1);
    yeastEffect = math.min(yeastEffect, 3.0);

    // 당분 효과 (이스트 영양분)
    double sugarEffect = 1.0 + (sugarContent / 100.0) * 0.3; // 100g당 30% 촉진
    sugarEffect = math.min(sugarEffect, 1.5);

    // 소금 효과 (이스트 억제)
    double saltEffect = 1.0 + saltPercentage * 2.0; // 소금이 발효 지연
    saltEffect = math.min(saltEffect, 2.0);

    // 반죽 크기 효과 (큰 반죽일수록 발효 시간 증가)
    double sizeEffect = 1.0 + (doughWeight / 1000.0) * 0.1; // 1kg당 10% 증가
    sizeEffect = math.min(sizeEffect, 1.3);

    // 최적 발효 시간 계산
    double optimalTime = baseFermentationMinutes / (temperatureEffect * yeastEffect * sugarEffect) * saltEffect * sizeEffect;
    optimalTime = math.max(optimalTime, 30.0); // 최소 30분
    optimalTime = math.min(optimalTime, 480.0); // 최대 8시간

    // 발효 단계별 시간 분배
    double bulkFermentation = optimalTime * 0.6; // 1차 발효 60%
    double finalProof = optimalTime * 0.4; // 최종 발효 40%

    return FermentationOptimizationResult(
      totalTimeMinutes: optimalTime,
      bulkFermentationMinutes: bulkFermentation,
      finalProofMinutes: finalProof,
      optimalTemperature: _calculateOptimalFermentationTemperature(yeastPercentage),
      expectedVolumeIncrease: _calculateExpectedVolumeIncrease(yeastPercentage, sugarContent),
    );
  }

  /// 오븐 스프링 예측
  /// 반죽 상태, 발효 정도, 오븐 온도를 고려하여 오븐 스프링을 예측
  static OvenSpringResult predictOvenSpring({
    required double glutenStrength, // 글루텐 강도 (0-10)
    required double fermentationLevel, // 발효 정도 (0-1, 0.8이 적정)
    required double ovenTemperature, // 오븐 온도
    required double steamPresence, // 스팀 존재 여부 (0-1)
    required double doughTension, // 반죽 장력 (0-1)
  }) {
    // 글루텐 강도 효과 (강할수록 좋은 오븐 스프링)
    double glutenEffect = glutenStrength / 10.0;
    
    // 발효 정도 효과 (적정 발효에서 최대)
    double fermentationEffect;
    if (fermentationLevel < 0.7) {
      fermentationEffect = fermentationLevel / 0.7; // 발효 부족
    } else if (fermentationLevel <= 0.9) {
      fermentationEffect = 1.0; // 적정 발효
    } else {
      fermentationEffect = 1.0 - (fermentationLevel - 0.9) * 5.0; // 과발효
    }
    fermentationEffect = math.max(fermentationEffect, 0.1);

    // 오븐 온도 효과 (고온에서 급속 팽창)
    double temperatureEffect = math.min(ovenTemperature / 220.0, 1.2);
    temperatureEffect = math.max(temperatureEffect, 0.5);

    // 스팀 효과 (초기 스팀이 크러스트 형성 지연)
    double steamEffect = 1.0 + steamPresence * 0.3;

    // 반죽 장력 효과 (적절한 장력이 필요)
    double tensionEffect = doughTension;

    // 전체 오븐 스프링 계산
    double ovenSpringFactor = glutenEffect * fermentationEffect * temperatureEffect * steamEffect * tensionEffect;
    ovenSpringFactor = math.min(ovenSpringFactor, 2.0); // 최대 2배 팽창

    // 예상 부피 증가율
    double volumeIncrease = (ovenSpringFactor - 1.0) * 100; // 백분율

    return OvenSpringResult(
      springFactor: ovenSpringFactor,
      expectedVolumeIncreasePercent: volumeIncrease,
      crustFormationTime: _calculateCrustFormationTime(ovenTemperature, steamPresence),
      optimalBakingStrategy: _recommendBakingStrategy(ovenSpringFactor, steamPresence),
    );
  }

  /// 밀가루별 글루텐 강도 반환
  static double _getFlourGlutenStrength(String flourType) {
    final lowerType = flourType.toLowerCase();
    
    if (lowerType.contains('강력분') || lowerType.contains('bread flour')) {
      return 8.0; // 높은 글루텐 강도
    } else if (lowerType.contains('중력분') || lowerType.contains('all-purpose')) {
      return 6.0; // 중간 글루텐 강도
    } else if (lowerType.contains('박력분') || lowerType.contains('cake flour')) {
      return 3.0; // 낮은 글루텐 강도
    } else if (lowerType.contains('듀럼') || lowerType.contains('durum')) {
      return 9.0; // 매우 높은 글루텐 강도
    } else {
      return 6.0; // 기본값
    }
  }

  /// 풍미 화합물 예측
  static List<String> _predictFlavorCompounds(double intensity, double sugarContent, double proteinContent) {
    List<String> compounds = [];
    
    if (intensity > 1.0) {
      compounds.add('furans'); // 캐러멜 향
    }
    if (intensity > 2.0) {
      compounds.add('pyrazines'); // 견과류 향
    }
    if (intensity > 3.0 && sugarContent > 20) {
      compounds.add('aldehydes'); // 달콤한 향
    }
    if (intensity > 4.0 && proteinContent > 30) {
      compounds.add('thiazoles'); // 고기 같은 향
    }
    if (intensity > 5.0) {
      compounds.add('pyrroles'); // 구운 향
    }
    
    return compounds;
  }

  /// 글루텐 강도에 따른 식감 예측
  static String _predictTextureFromGluten(GlutenStrengthLevel level, double hydration) {
    switch (level) {
      case GlutenStrengthLevel.weak:
        return hydration > 0.7 ? '부드럽고 촉촉함' : '부서지기 쉬움';
      case GlutenStrengthLevel.medium:
        return hydration > 0.7 ? '적당히 쫄깃함' : '부드러움';
      case GlutenStrengthLevel.strong:
        return hydration > 0.7 ? '쫄깃하고 탄력있음' : '단단함';
      case GlutenStrengthLevel.veryStrong:
        return '매우 쫄깃하고 탄력있음';
    }
  }

  /// 최적 발효 온도 계산
  static double _calculateOptimalFermentationTemperature(double yeastPercentage) {
    // 이스트량이 적을수록 높은 온도 필요
    if (yeastPercentage < 0.005) {
      return 30.0; // 30°C
    } else if (yeastPercentage < 0.015) {
      return 27.0; // 27°C
    } else {
      return 25.0; // 25°C
    }
  }

  /// 예상 부피 증가율 계산
  static double _calculateExpectedVolumeIncrease(double yeastPercentage, double sugarContent) {
    double baseIncrease = 80.0; // 기본 80% 증가
    double yeastBonus = yeastPercentage * 1000; // 이스트 보너스
    double sugarBonus = sugarContent / 10.0; // 당분 보너스
    
    return math.min(baseIncrease + yeastBonus + sugarBonus, 150.0); // 최대 150%
  }

  /// 크러스트 형성 시간 계산
  static double _calculateCrustFormationTime(double ovenTemperature, double steamPresence) {
    double baseTime = 15.0; // 기본 15분
    double temperatureEffect = 220.0 / ovenTemperature; // 온도가 높을수록 빠름
    double steamDelay = steamPresence * 5.0; // 스팀이 있으면 지연
    
    return baseTime * temperatureEffect + steamDelay;
  }

  /// 베이킹 전략 추천
  static String _recommendBakingStrategy(double ovenSpringFactor, double steamPresence) {
    if (ovenSpringFactor > 1.5) {
      return steamPresence > 0.5 ? '고온 스팀 베이킹' : '고온 직화 베이킹';
    } else if (ovenSpringFactor > 1.2) {
      return '표준 베이킹';
    } else {
      return '저온 장시간 베이킹';
    }
  }
}

/// Maillard 반응 결과
class MaillardReactionResult {
  final double intensity; // 반응 강도 (0-10)
  final MaillardColorLevel colorLevel; // 색상 레벨
  final List<String> flavorCompounds; // 생성되는 풍미 화합물
  final String estimatedColor; // 예상 색상

  MaillardReactionResult({
    required this.intensity,
    required this.colorLevel,
    required this.flavorCompounds,
    required this.estimatedColor,
  });
}

/// Maillard 반응 색상 레벨
enum MaillardColorLevel {
  none,
  light,
  medium,
  dark,
  veryDark,
}

/// 글루텐 강도 결과
class GlutenStrengthResult {
  final double strength; // 글루텐 강도 (0-10)
  final GlutenStrengthLevel level; // 강도 레벨
  final String expectedTexture; // 예상 식감
  final bool windowPaneTestResult; // 윈도우 페인 테스트 통과 여부

  GlutenStrengthResult({
    required this.strength,
    required this.level,
    required this.expectedTexture,
    required this.windowPaneTestResult,
  });
}

/// 글루텐 강도 레벨
enum GlutenStrengthLevel {
  weak,
  medium,
  strong,
  veryStrong,
}

/// 발효 최적화 결과
class FermentationOptimizationResult {
  final double totalTimeMinutes; // 총 발효 시간
  final double bulkFermentationMinutes; // 1차 발효 시간
  final double finalProofMinutes; // 최종 발효 시간
  final double optimalTemperature; // 최적 발효 온도
  final double expectedVolumeIncrease; // 예상 부피 증가율

  FermentationOptimizationResult({
    required this.totalTimeMinutes,
    required this.bulkFermentationMinutes,
    required this.finalProofMinutes,
    required this.optimalTemperature,
    required this.expectedVolumeIncrease,
  });
}

/// 오븐 스프링 결과
class OvenSpringResult {
  final double springFactor; // 오븐 스프링 계수
  final double expectedVolumeIncreasePercent; // 예상 부피 증가율 (%)
  final double crustFormationTime; // 크러스트 형성 시간 (분)
  final String optimalBakingStrategy; // 최적 베이킹 전략

  OvenSpringResult({
    required this.springFactor,
    required this.expectedVolumeIncreasePercent,
    required this.crustFormationTime,
    required this.optimalBakingStrategy,
  });
}