// 믹싱 분석 상수들
// 메트릭 스타일 enum 및 기타 상수들

import '../../../../services/ingredient_analyzer.dart';
import '../../../../services/environment_defaults_calculator.dart';
import '../../../../services/moisture_calculator.dart';
import '../../../../core/types/environment_types.dart';

/// 메트릭 표시 스타일 enum
enum MetricStyle {
  simple, // 간소화된 스타일
  integrated, // 아이콘 포함 스타일
  essential, // 중요 메트릭 스타일
  mini, // 미니 스타일
  detailed, // 상세 스타일
}

/// 믹싱 분석 관련 상수들
class MixingAnalysisConstants {
  // 캐싱된 환경 기본값 (반복 호출 방지)
  static final UserEnvironment _cachedDefaultEnvironment =
      EnvironmentDefaultsCalculator.getDefaultEnvironment();

  // 기본 값들 (동적 계산 적용 - 하드코딩 제거)
  static const double defaultGlutenFormation = 0.5;
  static double get defaultTemperature => _cachedDefaultEnvironment.temperature;
  static const double defaultViscosity = 1.0;
  // 기본 수분 흡수율 (동적 계산 기반)
  static double get defaultMoistureAbsorption =>
      MoistureCalculator.calculateBaseMoistureAbsorption(
        [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'g'},
        ],
        recipeTitle: '기본 빵',
      );

  // RPM 값들
  static const double lowSpeedRPM = 80.0;
  static const double mediumSpeedRPM = 130.0;
  static const double highSpeedRPM = 200.0;

  // 시간 제한
  static const int minMixingTime = 2;
  static const int maxMixingTime = 20;

  // 효율성 범위
  static const double minEfficiency = 0.0;
  static const double maxEfficiency = 1.0;

  // 색상 값들
  static const int greenColor = 0xFF4CAF50;
  static const int lightGreenColor = 0xFF8BC34A;
  static const int orangeColor = 0xFFFF9800;
  static const int redColor = 0xFFF44336;

  // UI 색상 값들 (Material Design 기반)
  static const int primaryGreen = 0xFF2E7D32;
  static const int primaryBlue = 0xFF1565C0;
  static const int secondaryBlue = 0xFF1976D2;
  static const int accentOrange = 0xFFFF6F00;

  // 글루텐 형성 범위
  static const double optimalGlutenMin = 0.6;
  static const double optimalGlutenMax = 0.8;

  // 온도 범위 (동적 계산 - 하드코딩 제거)
  static double get optimalTempMin =>
      _cachedDefaultEnvironment.temperature - 3.0;
  static double get optimalTempMax =>
      _cachedDefaultEnvironment.temperature + 3.0;

  // 점도 범위
  static const double optimalViscosityMin = 1.5;
  static const double optimalViscosityMax = 2.0;

  // 수분 흡수율 범위 (동적 계산 기반)
  static double get optimalMoistureMin =>
      MoistureCalculator.calculateBaseMoistureAbsorption(
        [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'g'},
        ],
        recipeTitle: '기본 빵',
      ) -
      5.0; // 최적 범위 하한
  static double get optimalMoistureMax =>
      MoistureCalculator.calculateBaseMoistureAbsorption(
        [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'g'},
        ],
        recipeTitle: '기본 빵',
      ) +
      15.0; // 최적 범위 상한

  // 메트릭 분석 범위 (허용 범위)
  static const double moistureToleranceRange = 15.0; // 수분 흡수율 허용 범위 (±15%)
  static const double temperatureToleranceRange = 5.0; // 온도 허용 범위 (±5°C)
  static const double viscosityToleranceMin = 1.0; // 점도 허용 범위 최소
  static const double viscosityToleranceMax = 2.5; // 점도 허용 범위 최대

  // 기본값들 (실제 계산에 사용)
  static const double defaultTotalWeight = 1000.0; // 기본 총 무게 (g)
  static const int defaultTotalSteps = 3; // 기본 총 단계 수

  // 색상 투명도 값들
  static const double colorOpacityPrimary = 0.1;
  static const double colorOpacitySecondary = 0.3;
  static const double colorOpacityBackground = 0.08;

  // 점수 임계값들
  static const double excellentScoreThreshold = 0.8; // 우수 (80% 이상)
  static const double goodScoreThreshold = 0.6; // 양호 (60% 이상)
  static const double fairScoreThreshold = 0.4; // 보통 (40% 이상)

  // === 하드코딩 값 중앙화 (Phase 1-3) ===

  // 기본 온도 값들 (하드코딩 제거)
  static const double fallbackTemperature = 25.0; // 폴백 기본 온도
  static const double initialDoughTemperature = 20.0; // 초기 반죽 온도
  static const double defaultUserTemperature = 25.0; // 사용자 기본 온도

  // 기본 글루텐 형성도 값들 (하드코딩 제거)
  static const double defaultGlutenIncrement = 0.1; // 기본 증가량
  static const double fallbackGlutenFormation = 0.3; // 폴백 글루텐 형성도
  static const double minimumGlutenFormation = 0.0; // 최소 글루텐 형성도
  static const double maximumGlutenFormation = 1.0; // 최대 글루텐 형성도

  // 기본 수분 흡수율 값들 (하드코딩 제거)
  static const double fallbackMoistureAbsorption = 65.0; // 일반 빵 적정 수분
  static const double safeDefaultMoistureValue = 0.0; // 안전한 기본값 (NaN 방지)

  // 계절별 온도 보정 값들 (하드코딩 제거)
  static const double springTemperatureCorrection = 2.0; // 봄: +2°C
  static const double summerTemperatureCorrection = -1.0; // 여름: -1°C
  static const double autumnTemperatureCorrection = 1.0; // 가을: +1°C
  static const double winterTemperatureCorrection = -2.0; // 겨울: -2°C

  // 고도별 온도 보정 값들 (하드코딩 제거)
  static const double lowlandTemperatureCorrection = 1.0; // 저지대: +1°C
  static const double highlandTemperatureCorrection = -1.0; // 고지대: -1°C

  // 빵 제조 과학적 범위 제한 값들
  static const double minTemperatureRange = 15.0; // 최소 온도 (°C)
  static const double maxTemperatureRange = 45.0; // 최대 온도 (°C)
  static const double minViscosityRange = 0.5; // 최소 점도
  static const double maxViscosityRange = 3.0; // 최대 점도
  static const double minMoistureRange = 50.0; // 최소 수분 (%)
  static const double maxMoistureRange = 90.0; // 최대 수분 (%)

  // 동적 계산 계수들 (하드코딩 제거)
  static const double temperatureIncrementFactor = 0.2; // 온도 증가 계수
  static const double viscosityIncrementFactor = 0.2; // 점도 증가 계수
  static const double frictionHeatLowSpeed = 0.5; // 저속 마찰열
  static const double frictionHeatMediumSpeed = 1.0; // 중속 마찰열
  static const double frictionHeatHighSpeed = 2.0; // 고속 마찰열
  static const double moistureTemperatureCorrection = -0.5; // 수분 보정 계수

  // 단계별 기본 증가량 (빵 제조 과학적)
  static const double baseIncrementStep0 = 0.12; // 1단계: 초기 형성 (12%)
  static const double baseIncrementStep1 = 0.18; // 2단계: 본격 형성 (18%)
  static const double baseIncrementStep2 = 0.15; // 3단계: 강화 형성 (15%)
  static const double baseIncrementStep3 = 0.10; // 4단계: 마무리 형성 (10%)
  static const double baseIncrementDefault = 0.08; // 추가 단계: 보수적 형성 (8%)

  // 역할별 기본 글루텐 형성도 (빵 제조 과학적)
  static const double roleInitialMix = 0.08; // 초기 혼합: 낮음
  static const double roleGlutenFormation = 0.25; // 글루텐 형성: 높음
  static const double roleFinalMix = 0.15; // 추가 혼합: 중간
  static const double roleResting = 0.12; // 숙성: 중간-낮음
  static const double roleDefault = 0.10; // 기본값

  // RPM 기반 속도 계수
  static const double rpmLowFactor = 0.8; // 저속 이하
  static const double rpmMediumFactor = 1.0; // 중속 범위
  static const double rpmHighFactor = 1.2; // 고속 범위
  static const double rpmHighExtraFactor = 1.1; // 고속 초과

  // 효율성 기반 시간 계수
  static const double efficiencyLowFactor = 0.9; // 효율 낮음
  static const double efficiencyMediumFactor = 1.0; // 효율 보통
  static const double efficiencyHighFactor = 1.1; // 효율 높음

  // 단계 위치 보정 계수
  static const double positionFirstStepFactor = 0.9; // 첫 단계
  static const double positionLastStepFactor = 1.1; // 마지막 단계
  static const double positionMiddleStepBase = 1.0; // 중간 단계 기본
  static const double positionMiddleStepIncrement = 0.1; // 중간 단계 증가량
  static const double positionMiddleStepMin = 0.95; // 중간 단계 최소
  static const double positionMiddleStepMax = 1.05; // 중간 단계 최대

  // 속도 기반 글루텐 보정
  static const double speedLowGlutenCorrection = 0.02; // 저속: 증가
  static const double speedHighGlutenCorrection = -0.02; // 고속: 감소

  // 시간 기반 글루텐 보정
  static const double timeShortGlutenCorrection = -0.01; // 짧은 시간: 감소
  static const double timeLongGlutenCorrection = 0.02; // 긴 시간: 증가

  // 온도 기반 글루텐 보정
  static const double tempLowGlutenCorrection = -0.02; // 낮은 온도: 감소
  static const double tempHighGlutenCorrection = -0.01; // 높은 온도: 약간 감소

  // 속도 기반 점도 보정
  static const double speedLowViscosityCorrection = 0.1; // 저속: 증가
  static const double speedHighViscosityCorrection = -0.1; // 고속: 감소

  // 시간 기반 점도 보정
  static const double timeShortViscosityCorrection = -0.1; // 짧은 시간: 감소
  static const double timeLongViscosityCorrection = 0.2; // 긴 시간: 증가

  // 환경 기반 점도 보정
  static const double envTempLowViscosityCorrection = 0.1; // 낮은 온도: 증가
  static const double envTempHighViscosityCorrection = -0.1; // 높은 온도: 감소
  static const double envHumidityLowViscosityCorrection = 0.05; // 낮은 습도: 증가
  static const double envHumidityHighViscosityCorrection = -0.05; // 높은 습도: 감소

  // 믹서 효율 기본값 및 보정
  static const double mixerEfficiencyBase = 0.85; // 기본 효율
  static const double mixerEfficiencyTempLowCorrection = -0.1; // 낮은 온도
  static const double mixerEfficiencyTempMediumLowCorrection =
      -0.05; // 약간 낮은 온도
  static const double mixerEfficiencyTempHighCorrection = -0.03; // 약간 높은 온도
  static const double mixerEfficiencyTempHighExtraCorrection = -0.08; // 높은 온도
  static const double mixerEfficiencyHumidityLowCorrection = -0.05; // 낮은 습도
  static const double mixerEfficiencyHumidityMediumLowCorrection =
      -0.02; // 약간 낮은 습도
  static const double mixerEfficiencyAltitudeLowCorrection = 0.02; // 저지대
  static const double mixerEfficiencyAltitudeHighCorrection = -0.03; // 높은 고도
  static const double mixerEfficiencyAltitudeHighExtraCorrection =
      -0.05; // 매우 높은 고도

  // 동적 단계 효율 기본값
  static const double stepEfficiencyInitialMix = 0.75; // 1단계: 초기 혼합
  static const double stepEfficiencyGlutenFormation = 0.95; // 2단계: 글루텐 형성
  static const double stepEfficiencyFinalMix = 1.0; // 3단계: 최종 숙성
  static const double stepEfficiencyAdditional = 1.05; // 4단계 이상: 추가 숙성

  // 속도 기반 효율 보정
  static const double efficiencySpeedLowCorrection = 1.05; // 저속: 증가
  static const double efficiencySpeedHighCorrection = 0.95; // 고속: 감소

  // 환경 기반 효율 보정
  static const double efficiencyEnvTempLowCorrection = -0.02; // 낮은 온도
  static const double efficiencyEnvTempHighCorrection = -0.01; // 높은 온도
  static const double efficiencyEnvHumidityLowCorrection = -0.01; // 낮은 습도
  static const double efficiencyEnvHumidityHighCorrection = -0.01; // 높은 습도

  // 기본값들 (컨트롤러용)
  static const double controllerFallbackEfficiency = 1.0; // 폴백 효율
  static const double controllerFallbackViscosity = 1.0; // 폴백 점도
  static const double controllerFallbackMixerEfficiency = 0.9; // 폴백 믹서 효율
  static const double controllerFallbackDuration = 5; // 폴백 시간
  static const String controllerFallbackSpeed = '중속'; // 폴백 속도

  // 빵 타입별 기본 시간 (분)
  static const int breadTypeSandwichDuration = 8; // 식빵
  static const int breadTypeBaguetteDuration = 6; // 바게트
  static const int breadTypeSourdoughDuration = 10; // 사워도우
  static const int breadTypeCroissantDuration = 4; // 크루아상
  static const int breadTypeDefaultDuration = 5; // 일반 빵

  // 빵 타입별 기본 속도
  static const String breadTypeSandwichSpeed = '중속'; // 식빵
  static const String breadTypeBaguetteSpeed = '고속'; // 바게트
  static const String breadTypeSourdoughSpeed = '저속'; // 사워도우
  static const String breadTypeCroissantSpeed = '저속'; // 크루아상
  static const String breadTypeDefaultSpeed = '중속'; // 일반 빵

  // 빵 타입별 기본 점도
  static const double breadTypeSandwichViscosity = 1.2; // 식빵
  static const double breadTypeBaguetteViscosity = 0.9; // 바게트
  static const double breadTypeSourdoughViscosity = 1.4; // 사워도우
  static const double breadTypeCroissantViscosity = 0.8; // 크루아상
  static const double breadTypeDefaultViscosity = 1.0; // 일반 빵

  // 단계별 점도 보정
  static const double viscosityStep0Correction = 0.1; // 1단계: 초기 혼합
  static const double viscosityStep1Correction = 0.3; // 2단계: 글루텐 형성
  static const double viscosityStep2Correction = -0.1; // 3단계: 최종 숙성
  static const double viscosityStepDefaultCorrection = -0.2; // 4단계 이상

  // 재료 기반 보정 (밀가루 양 기준)
  static const double ingredientFlourSmallCorrection = -0.1; // 소량
  static const double ingredientFlourLargeCorrection = 0.1; // 대량
  static const double ingredientFlourExtraLargeCorrection = 0.2; // 초대량

  // 시간 기반 보정 (분 기준)
  static const int timeShortThreshold = 3; // 짧은 시간 임계값
  static const int timeMediumThreshold = 8; // 적정 시간 임계값
  static const int timeLongThreshold = 12; // 긴 시간 임계값

  // 효율성 범위
  static const double efficiencyRangeMin = 0.5; // 최소 효율
  static const double efficiencyRangeMax = 1.5; // 최대 효율

  // 분석 타임아웃 (초)
  static const int analysisTimeoutSeconds = 10;

  // 콜백 지연 시간 (밀리초)
  static const int callbackDelayMilliseconds = 0;

  // 기본 분석 결과 값들
  static const double defaultAnalysisEfficiency = 0.5;
  static const double defaultAnalysisScore = 0.85;
  static const double defaultAnalysisConfidence = 0.85;
}
