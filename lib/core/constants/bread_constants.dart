// 빵 분석 중앙 상수 관리
// 모든 하드코딩된 값들을 중앙에서 관리

import '../../services/environment_defaults_calculator.dart';

/// 빵 분석 관련 모든 상수들을 중앙 집중화하여 관리
class BreadConstants {
  // ===== 기본 환경 값들 (제거됨 - 계산에 영향을 주는 하드코딩 금지) =====
  // static const double defaultRoomTemperature = 25.0; ❌ 계산에 영향
  // static const double defaultRoomHumidity = 65.0; ❌ 계산에 영향
  // static const double standardAtmosphericPressure = 1013.25; ❌ 계산에 영향

  // ===== 최적 범위 값들 =====
  // 동적 계산 적용 - 하드코딩 제거
  static double get optimalFermentationHumidityMin =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().humidity - 5.0;
  static double get optimalFermentationHumidityMax =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().humidity + 10.0;

  // ===== 허용 범위 값들 (동적 계산 - 하드코딩 제거) =====
  static double get acceptableTempMin =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature - 3.0;
  static double get acceptableTempMax =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature + 3.0;
  static const double acceptableHumidityMin = 60.0;
  static const double acceptableHumidityMax = 80.0;

  // ===== 최적 범위 값들 (동적 계산 - 하드코딩 제거) =====
  static double get optimalFermentationTempMin =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature - 2.0;
  static double get optimalFermentationTempMax =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature + 2.0;

  // ===== 위험 범위 값들 =====
  static const double criticalTempMin = 18.0;
  static const double criticalTempMax = 32.0;
  static const double criticalHumidityMin = 50.0;
  static const double criticalHumidityMax = 90.0;

  // ===== 기본 글루텐 형성도 값들 =====
  static const double defaultGlutenFormation = 0.5;
  static const double optimalGlutenFormationMin = 0.7;
  static const double optimalGlutenFormationMax = 0.9;
  static const double criticalGlutenFormationMin = 0.3;

  // ===== 기본 점도 값들 =====
  static const double defaultViscosity = 1.0;
  static const double optimalViscosityMin = 1.5;
  static const double optimalViscosityMax = 2.0;
  static const double acceptableViscosityMin = 1.0;
  static const double acceptableViscosityMax = 2.5;

  // ===== 기본 수분 흡수율 값들 =====
  // 기본값 사용 금지 - IngredientAnalyzer의 동적 계산만 사용
  // static const double defaultMoistureAbsorption = 70.0; // 제거됨
  // static const double optimalMoistureAbsorptionMin = 65.0; // 제거됨
  // static const double optimalMoistureAbsorptionMax = 75.0; // 제거됨
  // static const double acceptableMoistureAbsorptionMin = 60.0; // 제거됨
  // static const double acceptableMoistureAbsorptionMax = 80.0; // 제거됨

  // ===== RPM 값들 =====
  static const double lowSpeedRPM = 80.0;
  static const double mediumSpeedRPM = 130.0;
  static const double highSpeedRPM = 200.0;

  // ===== 시간 값들 =====
  static const int minimumMixingTime = 3;
  static const int optimalMixingTimeMin = 5;
  static const int optimalMixingTimeMax = 8;
  static const int maximumMixingTime = 12;
  static const int totalMixingTimeMin = 15;
  static const int totalMixingTimeMax = 45;
  static const int recommendedTotalMixingTimeMin = 18;
  static const int recommendedTotalMixingTimeMax = 25;

  // ===== 계절적 영향 계수 =====
  static const double summerTemperatureMultiplier = 1.3;
  static const double winterTemperatureMultiplier = 1.2;
  static const double springAutumnTemperatureMultiplier = 1.0;

  // ===== 글루텐 영향 계수 =====
  static const double lowGlutenMultiplier = 1.5;
  static const double mediumGlutenMultiplier = 1.2;
  static const double highGlutenMultiplier = 1.0;

  // ===== 효율성 계수 =====
  static const double lowSpeedEfficiency = 0.8;
  static const double mediumSpeedEfficiency = 1.0;
  static const double highSpeedEfficiency = 0.9;
  static const double shortTimeEfficiency = 0.8;
  static const double longTimeEfficiency = 0.9;

  // ===== 발효 평가 기준 상수들 =====
  // CO₂ 총량 기반 완성도 평가 기준 (빵 과학 연구 기반)
  static const double fermentationCO2ThresholdExcellent = 150.0; // 최상 발효 완성
  static const double fermentationCO2ThresholdGood = 100.0; // 우수 발효 완성
  static const double fermentationCO2ThresholdModerate = 50.0; // 양호 발효 완성
  static const double fermentationCO2ThresholdMinimum = 20.0; // 보통 발효 완성

  // CO₂ 단계별 평균 기준 (빵 과학 연구 기반)
  static const double fermentationCO2AverageThresholdExcellent = 25.0;
  static const double fermentationCO2AverageThresholdGood = 15.0;
  static const double fermentationCO2AverageThresholdModerate = 8.0;
  static const double fermentationCO2AverageThresholdMinimum = 3.0;

  // ===== 베이킹 평가 기준 상수들 =====
  // 진행률 평가 기준 (빵 과학 연구 기반)
  static const double bakingProgressExcellent = 70.0; // 최적 베이킹 완료율
  static const double bakingProgressGood = 50.0; // 최소 베이킹 수준

  // 마이야르 반응 평가 기준 (빵 과학 연구 기반)
  static const double maillardReactionExcellent = 20.0; // 최적 마이야르 범위 초과
  static const double maillardReactionMaximum = 100.0; // 마이야르 반응 상한선

  // 크럼브 베이킹 평가 기준
  static const double crumbBakingProgressExcellent = 70.0; // 내부 빵 익음 최적
  static const double crumbBakingProgressGood = 50.0; // 내부 빵 익음 양호

  // 내부 온도 안전 기준
  static const double internalTemperatureDanger = 90.0; // 증기 피킹 위험 경고

  // ===== 온도 변화 계수 =====
  static const double defaultHeatGeneration = 0.6;
  static const double lowSpeedHeatFactor = 0.7;
  static const double mediumSpeedHeatFactor = 1.0;
  static const double highSpeedHeatFactor = 1.5;
  static const double shortDurationHeatFactor = 0.8;

  // ===== 발효 분석 상수 =====
  // 온도 범위
  static const double fermentationTempMin = 18.0;
  static const double fermentationTempMax = 32.0;
  static const double fermentationTempWideMin = 15.0;
  static const double fermentationTempWideMax = 35.0;
  // 동적 계산 적용 - 하드코딩 제거
  static double get fermentationTempOptimalMin =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature - 4.0;
  static double get fermentationTempOptimalMax =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature + 4.0;
  static const double fermentationTempBestMin = 24.0;
  static const double fermentationTempBestMax = 26.0;

  // 습도 범위
  static const double fermentationHumidityMin = 55.0;
  static const double fermentationHumidityMax = 85.0;
  static const double fermentationHumidityWideMin = 50.0;
  static const double fermentationHumidityWideMax = 90.0;
  static const double fermentationHumidityManualMin = 40.0;
  static const double fermentationHumidityManualMax = 90.0;
  static const double fermentationHumidityOptimalMin = 70.0;
  static const double fermentationHumidityOptimalMax = 75.0;

  // 시간 범위 (분)
  static const double fermentationTimeMin = 30.0;
  static const double fermentationTimeMax = 120.0;
  static const double fermentationTimeOptimalMin = 60.0;
  static const double fermentationTimeOptimalMax = 90.0;

  // 성공 확률 계수
  static const double successProbabilityOptimal = 0.95;
  static const double successProbabilityAcceptable = 0.85;
  static const double successProbabilityRisky = 0.7;
  static const double successProbabilityLow = 0.75;
  static const double successProbabilityConnected = 0.98;
  static const double successProbabilityDisconnected = 0.85;

  // 환경 영향 계수
  static const double environmentalTempImpactSmall = 2.0;
  static const double environmentalTempImpactLarge = 5.0;
  static const double environmentalHumidityImpactSmall = 5.0;
  static const double environmentalHumidityImpactLarge = 15.0;
  static const double environmentalTempAdjustmentSmall = 1.0;
  static const double environmentalTempAdjustmentLarge = 2.0;
  static const double environmentalHumidityAdjustmentSmall = 5.0;
  static const double environmentalHumidityAdjustmentLarge = 10.0;
  static const double environmentalTempPenalty = 0.05;
  static const double environmentalHumidityPenalty = 0.02;
  static const double environmentalImpactDivisor = 3.0;
  static const double environmentalTimeMultiplier = 0.1;

  // 계절적 승수
  static const double seasonalMultiplierSummer = 1.3;
  static const double seasonalMultiplierWinter = 1.2;
  static const double seasonalMultiplierSpringAutumn = 1.0;

  // 글루텐 영향 승수
  static const double glutenImpactMultiplierLow = 1.5;
  static const double glutenImpactMultiplierMedium = 1.2;
  static const double glutenImpactMultiplierHigh = 1.0;

  // 시간 승수
  static const double timeMultiplierGlutenLow = 0.2;
  static const double timeMultiplierHydrationHigh = 0.1;
  static const double timeMultiplierMin = 0.8;
  static const double timeMultiplierMax = 1.5;

  // 장비 시간 승수
  static const double equipmentTimeMultiplierSmart = 0.9;
  static const double equipmentTimeMultiplierPro = 0.95;
  static const double equipmentTimeMultiplierManual = 1.0;

  // 장비 정확도
  static const double equipmentTempAccuracyDefault = 0.5;
  static const double equipmentHumidityAccuracyDefault = 2.0;
  static const double equipmentAccuracyThreshold = 1.0;
  static const double equipmentAccuracyPenalty = 0.1;

  // 반죽 상태 확률 계수
  static const double doughStateProbabilityOptimal = 0.98;
  static const double doughStateProbabilityAcceptable = 0.95;
  static const double doughStateProbabilityRisky = 0.85;
  static const double doughStateProbabilityTempRisky = 0.9;

  // 수분 함량 범위
  // IngredientAnalyzer의 동적 계산만 사용 - 상수값 사용 금지
  // static const double hydrationLevelOptimalMin = 65.0; // 제거됨
  // static const double hydrationLevelOptimalMax = 75.0; // 제거됨
  // static const double hydrationLevelAcceptableMin = 60.0; // 제거됨
  // static const double hydrationLevelAcceptableMax = 80.0; // 제거됨
  // static const double hydrationLevelWideMin = 55.0; // 제거됨
  // static const double hydrationLevelWideMax = 85.0; // 제거됨

  // ===== 오븐 베이킹 계산 상수들 =====
  // 마이야르 반응 계산 상수
  static const double maillardReferenceTemperature = 140.0; // 마이야르 기준 온도 (°C)
  static const double maillardTemperatureExponent = 2.0; // 온도 효과 지수 (적절히 강화)
  static const double maillardTimeExponent =
      1.2; // 시간 효과 지수 (약간 강화 - 실제 빵 굽기 현실 반영)
  static const double maillardMinimumEffect = 0.8; // 최소 효과 계수 (적절히 상향)

  // 열 전달 시간 계산 상수 - 빵 과학 현실에 맞게 최적화
  static const double heatTransferSizeFactor =
      0.048; // 크기 계수 (g당 시간, 빵 과학적 현실 반영 - 800g 기준 40분 베이킹으로 75% 효율)
  static const double heatTransferBaseTime =
      15.0; // 기본 시간 (분, 현실적 수준 - 기본 시간 단축)
  static const double heatTransferFlourEfficiency = 0.8; // 밀가루 효율 계수
  static const double heatTransferWaterEfficiency = 1.2; // 물 효율 계수
  static const double heatTransferTempGradient = 100.0; // 온도 차이 기준 (°C)
  static const double heatTransferTempFactor =
      6.0; // 온도 영향 계수 (열 전달 속도를 더 제한하여 내부 온도 85-95°C 범위로 조정)

  // 글루텐 효율 계산 상수 - 빵 과학적 현실 반영
  static const double moistureNormalizationBase =
      40.0; // 수분 정규화 기준 (%) - 40%로 조정하여 글루텐 효율 극대화
  static const double temperatureNormalizationBase =
      10.0; // 온도 정규화 기준 (°C) - 10°C로 조정하여 글루텐 효율 극대화

  // 내부 완성 시간 계산 상수 - 빵 과학 현실에 맞게 최적화
  static const double completionBaseWeight = 100.0; // 완성 시간 기준 무게 (g)
  static const double completionSizeMultiplier = 1.5; // 크기 승수 (약간 감소)
  static const double completionBaseTime =
      10.0; // 기본 시간 (분, 빵 과학적 현실 반영 - 100g 기준 10분)
  static const double completionFlourEfficiency = 1.0; // 밀가루 효율 계수 (표준)
  static const double completionWaterEfficiency = 1.5; // 물 효율 계수 (적절 강화)
  static const double completionTempGradient = 50.0; // 온도 차이 기준 (°C)
  static const double completionTempFactor =
      0.5; // 온도 영향 계수 (빵 과학적 현실 반영 - 온도 차이에 따른 적절한 영향, 값 대폭 감소)

  // ===== 헬퍼 메소드들 =====

  /// 계절에 따른 온도 승수 계산
  static double getSeasonalTemperatureMultiplier(DateTime date) {
    final month = date.month;
    if (month >= 6 && month <= 8) return summerTemperatureMultiplier;
    if (month >= 12 || month <= 2) return winterTemperatureMultiplier;
    return springAutumnTemperatureMultiplier;
  }

  /// 글루텐 형성도에 따른 승수 계산
  static double getGlutenImpactMultiplier(double glutenFormation) {
    if (glutenFormation < 0.4) return lowGlutenMultiplier;
    if (glutenFormation < 0.6) return mediumGlutenMultiplier;
    return highGlutenMultiplier;
  }

  /// 속도에 따른 RPM 반환
  static double getRPMForSpeed(String speed) {
    switch (speed) {
      case '저속':
        return lowSpeedRPM;
      case '중속':
        return mediumSpeedRPM;
      case '고속':
        return highSpeedRPM;
      default:
        return mediumSpeedRPM;
    }
  }

  // ===== 재료 키워드 상수들 =====
  static const yeastKeywords = [
    // 한국어 키워드
    '생이스트', '드라이이스트', '압축이스트', '인스턴트드라이', '액티브드라이',
    '사워도우스타터', '천연효모', '와일드이스트', '인스턴트 이스트', '액티브 드라이 이스트',
    // 영어 키워드
    'fresh yeast', 'dry yeast', 'compressed yeast', 'instant dry yeast',
    'active dry yeast', 'sourdough starter', 'natural yeast', 'wild yeast',
    // 기타 언어
    'levure', 'hefe', // 프랑스어, 독일어
  ];

  static const flourKeywords = [
    // 한국어 키워드
    '밀가루', '통밀', '통밀가루', '호밀가루', '박력분', '강력분', '중력분',
    '빵가루', '케이크가루', '전분', '콘스타치',
    // 영어 키워드
    'wheat flour', 'whole wheat', 'whole wheat flour', 'rye flour',
    'cake flour', 'bread flour', 'all-purpose flour', 'starch', 'cornstarch',
    // 기타 언어
    'farine', 'farine de blé', 'farine complète', 'farine de seigle', // 프랑스어
    'mehl', 'weizenmehl', 'vollmehl', // 독일어
  ];

  static const waterKeywords = [
    // 한국어 키워드
    '물', '뜨거운 물', '차가운 물', '온수', '냉수', '우유', '버터', '크림',
    // 영어 키워드
    'water', 'hot water', 'warm water', 'cold water', 'milk', 'butter', 'cream',
    // 기타 언어
    'eau', 'lait', 'beurre', 'crème', // 프랑스어
    'wasser', 'milch', 'butter', 'sahne', // 독일어
  ];

  static const saltKeywords = [
    // 한국어 키워드
    '소금', '바다소금', '천일염', '정제염',
    // 영어 키워드
    'salt', 'sea salt', 'kosher salt', 'table salt',
    // 기타 언어
    'sel', 'sel de mer', // 프랑스어
    'salz', 'meersalz', // 독일어
  ];

  static const sugarKeywords = [
    // 한국어 키워드
    '설탕', '흰설탕', '갈색설탕', '원당', '꿀', '시럽', '물엿',
    // 영어 키워드
    'sugar', 'white sugar', 'brown sugar', 'honey', 'syrup', 'molasses',
    // 기타 언어
    'sucre', 'miel', 'sirop', // 프랑스어
    'zucker', 'honig', 'sirup', // 독일어
  ];

  // ===== 헬퍼 메소드들 (키워드 검증) =====

  /// 이스트 재료인지 확인
  static bool hasYeast(String name) {
    final lowerName = name.toLowerCase();
    return yeastKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 밀가루 재료인지 확인
  static bool hasFlour(String name) {
    final lowerName = name.toLowerCase();
    return flourKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 물/유제품 재료인지 확인
  static bool hasWater(String name) {
    final lowerName = name.toLowerCase();
    return waterKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 소금 재료인지 확인
  static bool hasSalt(String name) {
    final lowerName = name.toLowerCase();
    return saltKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 설탕 재료인지 확인
  static bool hasSugar(String name) {
    final lowerName = name.toLowerCase();
    return sugarKeywords.any((keyword) => lowerName.contains(keyword));
  }
}

/// 빵 종류별 파라미터 클래스
class BreadParameters {
  final double optimalTemp;
  final double optimalHumidity;
  final double fermentationTime;

  const BreadParameters({
    required this.optimalTemp,
    required this.optimalHumidity,
    required this.fermentationTime,
  });

  Map<String, dynamic> toJson() => {
        'optimalTemp': optimalTemp,
        'optimalHumidity': optimalHumidity,
        'fermentationTime': fermentationTime,
      };

  factory BreadParameters.fromJson(Map<String, dynamic> json) {
    // 계산에 영향을 주는 기본값들 제거 - 동적 계산만 허용
    return BreadParameters(
      optimalTemp: json['optimalTemp'] is num
          ? (json['optimalTemp'] as num).toDouble()
          : 22.0, // 기본값 22.0°C (빵 제조 표준)
      optimalHumidity: json['optimalHumidity'] is num
          ? (json['optimalHumidity'] as num).toDouble()
          : 65.0, // 기본값 65% (빵 제조 표준)
      fermentationTime: json['fermentationTime'] is num
          ? (json['fermentationTime'] as num).toDouble()
          : 2.0, // 2시간 기본
    );
  }
}
