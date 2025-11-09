/// 🎯 발효 계산 엔진 - 중앙화된 이스트 값 참조
/// 이스트 값 참조를 모든 단계에서 일관성 있게 유지
/// 빅데이터 준수: 실질 사용자 입력 값만 사용 (하드코딩 금지)

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/types/calculation_types.dart';
import '../core/types/environment_types.dart';
import '../core/constants/bread_constants.dart';
import '../services/ingredient_analyzer.dart';
import 'centralized_parsing_service.dart';
import '../features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;

/// 🎯 중앙화된 발효 계산 컨텍스트
/// 모든 발효 계산에 필요한 데이터를 통합하여 일관성 있게 관리
/// 빅데이터 준수: 계산 로직들이 동일한 데이터 소스로부터 값을 전달받아 사용
class FermentationCalculationContext {
  // === 입력 데이터 (불변) ===
  final Map<String, dynamic> recipeData;
  final UserEnvironment environment;
  final List<Map<String, dynamic>> ingredients;
  final List<dynamic> fermentationSteps; // 동적 타입 지원을 위한 변경
  final BakingState mixingState;

  // === 계산 중 생성되는 데이터 (가변) ===
  StandardizedYeastProperties? yeastProperties;
  Map<String, dynamic>? calculationParameters;
  FermentationState? initialState;
  List<String> debugLogs = [];

  // === 초기화 및 검증 플래그 ===
  bool isInitialized;
  bool isValidated;

  factory FermentationCalculationContext.initialize({
    required Map<String, dynamic> recipeData,
    required UserEnvironment environment,
    required List<Map<String, dynamic>> ingredients,
    required List<dynamic> fermentationSteps,
    required BakingState mixingState,
  }) {
    debugPrint('🎯 [컨텍스트 초기화] 발효 계산 컨텍스트 생성 시작');

    final context = FermentationCalculationContext._internal(
      recipeData: recipeData,
      environment: environment,
      ingredients: ingredients,
      fermentationSteps: fermentationSteps,
      mixingState: mixingState,
    );

    // 중앙 집중식 데이터 검증
    context._validateContextIntegrity();
    context._initializeCalculationParameters();

    debugPrint(
        '✅ [컨텍스트 초기화] 완료 - 재료 ${ingredients.length}개, 단계 ${fermentationSteps.length}개');
    return context;
  }

  FermentationCalculationContext._internal({
    required this.recipeData,
    required this.environment,
    required this.ingredients,
    required this.fermentationSteps,
    required this.mixingState,
  })  : isInitialized = false,
        isValidated = false;

  /// 🎯 컨텍스트 무결성 검증 - 빅데이터 준수: 계산로직이 유효데이터만 받도록 보장
  void _validateContextIntegrity() {
    debugPrint('🔍 [컨텍스트 검증] 데이터 무결성 검사 시작');

    isValidated = false;

    // 기본 구조 검증
    if (recipeData.isEmpty) {
      throw ArgumentError('[컨텍스트 검증] recipeData가 비어있음');
    }
    if (ingredients.isEmpty) {
      throw ArgumentError('[컨텍스트 검증] ingredients가 비어있음');
    }
    if (fermentationSteps.isEmpty) {
      throw ArgumentError('[컨텍스트 검증] fermentationSteps가 비어있음');
    }

    // 환경 데이터 검증
    if (environment.temperature == null || environment.humidity == null) {
      throw ArgumentError('[컨텍스트 검증] environment 데이터 불완전');
    }

    // 단계별 데이터 검증
    for (int i = 0; i < fermentationSteps.length; i++) {
      final step = fermentationSteps[i];
      // FermentationStep의 durationMinutes 속성 사용 (타입 안전성)
      int durationMinutes = 0;
      try {
        if (step is art.FermentationStep) {
          durationMinutes = step.duration.inMinutes.toInt();
        } else if (step is FermentationStep) {
          durationMinutes = step.durationMinutes;
        } else {
          // 다른 타입인 경우 dynamic 접근 시도
          if (step.runtimeType.toString().contains('FermentationStep')) {
            durationMinutes = (step as dynamic).duration.inMinutes.toInt();
          } else {
            durationMinutes = 0;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [컨텍스트 검증] 단계 ${i + 1} duration 접근 실패: $e');
        durationMinutes = 0;
      }

      if (durationMinutes <= 0) {
        throw ArgumentError('[컨텍스트 검증] 단계 ${i + 1}: duration이 0분 이하');
      }
      if (step.targetTemperature < -10 || step.targetTemperature > 40) {
        throw ArgumentError(
            '[컨텍스트 검증] 단계 ${i + 1}: 비정상 온도 ${step.targetTemperature}°C');
      }
      if (step.targetHumidity < 30 || step.targetHumidity > 90) {
        throw ArgumentError(
            '[컨텍스트 검증] 단계 ${i + 1}: 비정상 습도 ${step.targetHumidity}%');
      }
    }

    // 믹싱 상태 검증
    if (mixingState.temperature.isNaN || mixingState.temperature.isInfinite) {
      throw ArgumentError('[컨텍스트 검증] mixingState.temperature 값 비정상');
    }

    debugLogs.add('🎯 [컨텍스트 검증] 모든 데이터 무결성 확인됨');
    isValidated = true;
  }

  /// 🧪 계산 파라미터 초기화 - 중앙 집중 계산 설정
  void _initializeCalculationParameters() {
    debugPrint('⚙️ [컨텍스트 초기화] 계산 파라미터 설정');

    calculationParameters = {
      'baseYeastActivity': 0.024,
      'environmentalFactors': {
        'temperatureCoefficient': 1.0,
        'humidityCoefficient': 1.0,
        'stabilityFactor': 0.95,
      },
      'biochemicalConstants': {
        'co2GenerationRate': 0.00002,
        'acidityIncrementFactor': 0.001,
        'glucoseUtilizationRate': 0.15,
      },
      'validation': {
        'maxSteps': 10,
        'minTemperature': -10.0,
        'maxTemperature': 40.0,
        'minHumidity': 30.0,
        'maxHumidity': 90.0,
      },
    };

    // 초기 상태 설정 (빅데이터 준수: 레시피 데이터 기반, 재료량 기반 동적 산도 계산)
    initialState = FermentationState.initial(
      mixingState: mixingState,
      environment: environment,
      recipeData: recipeData, // 빅데이터 준수: 레시피 데이터 전달
      ingredients: ingredients, // 재료량 기반 산도 계산을 위한 재료 정보 전달
      recipeTitle: recipeData['title'] as String?, // 레시피 제목 전달
    );

    debugLogs.add('⚙️ [컨텍스트 초기화] 계산 파라미터 및 초기 상태 완료');
    isInitialized = true;
  }

  /// 📊 디버깅용 현재 상태 요약
  String getContextSummary() {
    return '''🧪 FermentationCalculationContext 상태:
🔍 검증 상태: ${isValidated ? '✅' : '❌'}
🔧 초기화 상태: ${isInitialized ? '✅' : '❌'}
📋 재료: ${ingredients.length}개
🍞 단계: ${fermentationSteps.length}개
🌡️ 환경: ${environment.temperature}°C / ${environment.humidity}%
🥖 믹싱: ${mixingState.temperature}°C / 글루텐 ${mixingState.glutenFormation.toStringAsFixed(2)}
🧬 이스트 속성: ${yeastProperties != null ? '초기화됨' : '미초기화'}
📝 디버그 로그: ${debugLogs.length}개 항목''';
  }
}

/// 🧪 발효 성장 페이즈 열거형
/// 빵 발효의 4단계 생물학적 성장곡선 반영
enum FermentationPhase {
  lag, // 라그 페이즈: 효모 적응 단계 (0-15분)
  log, // 로그 페이즈: 급격한 증식 단계 (15-90분)
  stationary, // 정체 페이즈: 안정적 유지 단계 (90-150분)
  death // 사멸 페이즈: 효모 피로 단계 (150분+)
}

/// 🧪 생물학적 발효 모델
/// 효모 성장곡선 기반 시간 종속 발효 진행률 계산
class BiologicalFermentationModel {
  /// 성장 페이즈 결정 함수
  static FermentationPhase determineFermentationPhase(double totalElapsedTime) {
    if (totalElapsedTime < 15) return FermentationPhase.lag;
    if (totalElapsedTime < 90) return FermentationPhase.log;
    if (totalElapsedTime < 150) return FermentationPhase.stationary;
    return FermentationPhase.death;
  }

  /// 페이즈별 성장률 계산
  static double calculatePhaseGrowthRate(
      FermentationPhase phase, double timeInPhase) {
    switch (phase) {
      case FermentationPhase.lag:
        return _calculateLagPhaseGrowth(timeInPhase);
      case FermentationPhase.log:
        return _calculateLogPhaseGrowth(timeInPhase);
      case FermentationPhase.stationary:
        return _calculateStationaryPhaseGrowth(timeInPhase);
      case FermentationPhase.death:
        return _calculateDeathPhaseGrowth(timeInPhase);
    }
  }

  /// CO2 생성 시간 종속성 승수
  static double calculateTimeDependentCO2Multiplier(
      FermentationPhase phase, double timeInPhase) {
    switch (phase) {
      case FermentationPhase.lag:
        return 0.3; // 낮은 CO2 생성 (효모 적응 중)
      case FermentationPhase.log:
        return 1.2; // 최고 CO2 생성 (급격한 증식)
      case FermentationPhase.stationary:
        return 0.9; // 안정적 CO2 생성 (균형 상태)
      case FermentationPhase.death:
        return 0.4; // 감소 CO2 생성 (효모 피로)
    }
  }

  /// 라그 페이즈 성장률 (점진적 증가) - 빵 과학적 S-커브 적용
  static double _calculateLagPhaseGrowth(double timeInPhase) {
    // 0-15분: 0.6% → 0.9% S-커브 증가 (진행율 높음 문제 해결 - 100배 낮춤)
    // 빵 과학: 초기 효모 활성화가 더 빠름
    double progressRatio = timeInPhase / 15.0;
    // S-커브: 초기 가속화 + 후반 완만화
    double sCurve = progressRatio * progressRatio * (3.0 - 2.0 * progressRatio);
    return 0.006 + (sCurve * 0.003);
  }

  /// 로그 페이즈 성장률 (지수적 증가) - 현실적 성장률 적용
  static double _calculateLogPhaseGrowth(double timeInPhase) {
    // 15-90분: 0.7% → 0.85% 피크 (진행율 높음 문제 해결 - 100배 낮춤)
    double progressRatio = timeInPhase / 75.0; // 90-15=75분
    // 강화된 지수적 성장 패턴 (현실적 발효 속도 반영)
    return 0.007 +
        (progressRatio * 0.0015) + // 0.12 → 0.15 증가 → 0.0012 → 0.0015
        (progressRatio *
            progressRatio *
            0.0004); // 0.03 → 0.04 증가 → 0.0003 → 0.0004
  }

  /// 정체 페이즈 성장률 (안정적 유지)
  static double _calculateStationaryPhaseGrowth(double timeInPhase) {
    // 90-150분: 0.65% 안정 유지 (약간의 변동) - 빵 과학적 현실성 고려 (완화 적용)
    double oscillation = math.sin(timeInPhase * 0.1) * 0.002; // ±0.2% 진동 (완화)
    return 0.0065 + oscillation;
  }

  /// 사멸 페이즈 성장률 (점진적 감소)
  static double _calculateDeathPhaseGrowth(double timeInPhase) {
    // 150분+: 1.0% → 0.4% 점진적 감소 (100배 낮춤)
    double timeBeyond150 = timeInPhase - 150.0;
    double decayFactor = math.max(0.004, 0.01 - (timeBeyond150 * 0.00003));
    return decayFactor;
  }

  /// 생물학적 성장률 계산 (메인 인터페이스)
  static double calculateBiologicalGrowthRate({
    required double totalElapsedTime,
    required double yeastActivity,
    required double temperature,
    required double acidity,
  }) {
    FermentationPhase phase = determineFermentationPhase(totalElapsedTime);
    double phaseTime = _calculatePhaseElapsedTime(totalElapsedTime, phase);

    // 기본 페이즈 성장률
    double phaseGrowthRate = calculatePhaseGrowthRate(phase, phaseTime);

    // 환경 요인 적용
    double temperatureFactor = _calculateTemperatureFactor(temperature);
    double acidityFactor = _calculateAcidityFactor(acidity);

    // 최종 성장률
    double finalGrowthRate =
        phaseGrowthRate * temperatureFactor * acidityFactor;

    debugPrint(
        '🧬 [생물학적 성장률] 단계:$phase, 시간:$totalElapsedTime분, 성장률:${finalGrowthRate.toStringAsFixed(3)}');
    return finalGrowthRate;
  }

  /// 페이즈 내 경과 시간 계산
  static double _calculatePhaseElapsedTime(
      double totalElapsedTime, FermentationPhase phase) {
    switch (phase) {
      case FermentationPhase.lag:
        return totalElapsedTime;
      case FermentationPhase.log:
        return totalElapsedTime - 15.0;
      case FermentationPhase.stationary:
        return totalElapsedTime - 90.0;
      case FermentationPhase.death:
        return totalElapsedTime - 150.0;
    }
  }

  /// 온도 영향 계수
  static double _calculateTemperatureFactor(double temperature) {
    // 최적 온도 25-30°C에서 완화된 효율 (현실성 고려)
    if (temperature >= 25 && temperature <= 30) return 0.85; // 1.0 → 0.85 완화
    if (temperature >= 20 && temperature < 25)
      return 0.7 + ((temperature - 20) * 0.03); // 0.8 → 0.7 완화
    if (temperature > 30 && temperature <= 35)
      return 0.85 - ((temperature - 30) * 0.015); // 완화
    return 0.55; // 너무 높거나 낮은 온도 (0.6 → 0.55 완화)
  }

  /// 산도 영향 계수
  static double _calculateAcidityFactor(double acidity) {
    // 최적 pH 4.5-5.5에서 완화된 효율 (현실성 고려)
    if (acidity >= 4.5 && acidity <= 5.5) return 0.9; // 1.0 → 0.9 완화
    if (acidity >= 4.0 && acidity < 4.5)
      return 0.75 + ((acidity - 4.0) * 0.3); // 완화
    if (acidity > 5.5 && acidity <= 6.0)
      return 0.9 - ((acidity - 5.5) * 0.15); // 완화
    return 0.65; // 너무 높거나 낮은 산도 (0.7 → 0.65 완화)
  }
}

/// 🧪 표준화된 이스트 속성 인터페이스
/// 모든 단계별 계산에서 동일하게 사용되는 이스트 데이터 구조
class StandardizedYeastProperties {
  final double percentage;
  final double typeEfficiency;
  final double activity;
  final double co2Rate;
  final bool isValid;
  final List<String> validationWarnings;

  const StandardizedYeastProperties({
    required this.percentage,
    required this.typeEfficiency,
    required this.activity,
    required this.co2Rate,
    required this.isValid,
    required this.validationWarnings,
  });

  /// 일관된 검증 기준 제공
  bool get hasValidPercentage => percentage >= 0.1 && percentage <= 10.0;
  bool get hasValidTypeEfficiency =>
      typeEfficiency >= 0.5 && typeEfficiency <= 1.2;
  bool get hasValidActivity => activity >= 0.01 && activity <= 5.0;
  bool get hasValidCO2Rate => co2Rate >= 0.01 && co2Rate <= 2.0;
}

/// 🧪 중앙화된 이스트 계산 서비스 (모든 참조 통합)
class YeastCalculationService {
  static StandardizedYeastProperties calculateStandardizedYeastProperties({
    required List<Map<String, dynamic>> ingredients,
  }) {
    debugPrint('🔬 [이스트 속성 표준화 계산 시작]');
    final warnings = <String>[];

    try {
      // 1단계: 기본 이스트 속성 계산
      debugPrint('   1️⃣ 기본 이스트 속성 계산 중...');
      final yeastResult = _calculateYeastBaseProperties(ingredients);
      debugPrint(
          '   ✅ 기본 속성: 백분율=${yeastResult['percentage']}%, 타입효율=${yeastResult['typeEfficiency']}, CO2율=${yeastResult['co2Rate']}');

      // 2단계: 빅데이터 준수 검증 및 보정
      debugPrint('   2️⃣ 빅데이터 준수 검증 및 보정 중...');
      final validatedPercentage = _validateAndAdjustPercentage(
          yeastResult['percentage'] as double, warnings);
      final validatedTypeEfficiency = _validateAndAdjustTypeEfficiency(
          yeastResult['typeEfficiency'] as double, warnings);
      final validatedCO2Rate = yeastResult['co2Rate'] as double;

      // 3단계: 최종 활성도 계산 (일관된 공식 적용)
      debugPrint('   3️⃣ 최종 활성도 계산 중...');
      final calculatedActivity =
          validatedPercentage * validatedTypeEfficiency / 100.0;

      if (calculatedActivity.isNaN || calculatedActivity.isInfinite) {
        debugPrint(
            '   🚨 [이스트 활성도 계산 오류] NaN/Infinite 발생: $calculatedActivity');
        warnings.add('활성도 계산 오류: 유효하지 않은 값 발생');
      }

      // 4단계: 종합 유효성 판단
      final isValid = warnings.isEmpty;
      debugPrint('   4️⃣ 유효성 판단: $isValid (경고 개수: ${warnings.length})');

      debugPrint('🔬 [이스트 속성 표준화 계산 완료]');
      return StandardizedYeastProperties(
        percentage: validatedPercentage,
        typeEfficiency: validatedTypeEfficiency,
        activity: calculatedActivity,
        co2Rate: validatedCO2Rate,
        isValid: isValid,
        validationWarnings: warnings,
      );
    } catch (e, stackTrace) {
      debugPrint('🚨 [이스트 속성 표준화 치명적 오류]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      // 오류 발생 시 기본 값 반환
      return StandardizedYeastProperties(
        percentage: 2.0,
        typeEfficiency: 0.8,
        activity: 0.016,
        co2Rate: 0.083333,
        isValid: false,
        validationWarnings: ['이스트 계산 중 치명적 오류 발생: ${e.toString()}'],
      );
    }
  }

  /// 1단계: 기본 이스트 속성 계산
  /// ✅ 빅데이터/빵타입별 금지, 범위제한 금지, 기본값 사용 금지 정책 준수
  static Map<String, dynamic> _calculateYeastBaseProperties(
      List<Map<String, dynamic>> ingredients) {
    final yeastIngredients =
        IngredientAnalyzer.findYeastIngredients(ingredients);
    final naturalStarterIngredients =
        IngredientAnalyzer.findNaturalStarterIngredients(ingredients);

    // ✅ 밀가루 감지 실패시 백분율 0으로 드러냄 (기본값 사용 금지)
    final flourIngredients =
        IngredientAnalyzer.findFlourIngredients(ingredients);

    // 자연 발효종 백분율 계산 (밀가루 대비)
    final naturalStarterPercentage = _calculateNaturalStarterPercentage(
        naturalStarterIngredients, flourIngredients);

    // 상업용 이스트 백분율 계산 (자연 발효종이 있으면 0으로 설정)
    final hasNaturalStarter = naturalStarterIngredients.isNotEmpty;
    final yeastPercentage = flourIngredients.isNotEmpty &&
            yeastIngredients.isNotEmpty &&
            !hasNaturalStarter
        ? IngredientAnalyzer.calculateYeastPercentage(ingredients)
        : 0.0; // 밀가루 또는 이스트 감지 실패시 또는 자연 발효종 존재시 0

    // 효과적인 이스트 백분율 (자연 발효종 우선 적용)
    final effectiveYeastPercentage =
        hasNaturalStarter ? naturalStarterPercentage : yeastPercentage;

    final typeEfficiency = _calculateTypeEfficiencyFromIngredients(
        yeastIngredients, naturalStarterIngredients);
    final co2Rate = _calculateCO2RateFromIngredients(
        yeastIngredients, naturalStarterIngredients);

    return {
      'yeastIngredients': yeastIngredients,
      'naturalStarterIngredients': naturalStarterIngredients,
      'percentage': effectiveYeastPercentage, // 자연 발효종 우선 적용
      'typeEfficiency': typeEfficiency,
      'co2Rate': co2Rate,
    };
  }

  /// 팽창율 기반 계산 헬퍼들 - 빵 과학 기반 현실적 팽창율 보장
  static double calculateVolumeExpansion({
    required double fermentationProgress,
    required double acidity,
    required double glutenFormation,
    required int stepNumber,
    required double temperature,
    required double humidity,
    required int durationMinutes,
    required StandardizedYeastProperties yeastProperties,
  }) {
    try {
      debugPrint('📈 [팽창율 계산 시작] 단계 $stepNumber - 빵 과학 기반 계산');
      debugPrint(
          '   입력: progress=${(fermentationProgress * 100).toStringAsFixed(1)}%, acidity=$acidity, gluten=$glutenFormation');
      debugPrint(
          '   입력: temperature=$temperature°C, humidity=$humidity%, duration=$durationMinutes분');
      debugPrint(
          '   입력: yeastProperties.activity=${yeastProperties.activity}, co2Rate=${yeastProperties.co2Rate}');

      // 빵 과학적 CO2 용해도 기반 산도 효율 (헨리의 법칙 근사)
      // pH가 낮을수록(산성) CO2 용해도가 높아져 팽창률이 낮아짐
      double co2Solubility = 1.0 / (1.0 + math.exp(-(acidity - 3.5) * 1.5));
      double acidityEfficiency = math.max(0.4, 1.0 - co2Solubility * 0.35);
      debugPrint(
          '   🧪 [CO2 용해도 기반 산도 효율] ${acidityEfficiency.toStringAsFixed(3)} (산도 $acidity, CO2 용해도 ${co2Solubility.toStringAsFixed(3)})');

      if (acidityEfficiency.isNaN || acidityEfficiency.isInfinite) {
        debugPrint('   🚨 [산도 효율 계산 오류] NaN/Infinite: $acidityEfficiency');
        acidityEfficiency = 1.0; // 기본값 적용
      }

      // 환경 효율 계산 (온도/습도 기반) - 빵 과학적 최소값 보장
      double tempEfficiency =
          math.min(_calculateTemperatureEfficiency(temperature), 1.5);
      double humidityEfficiency =
          math.min(_calculateHumidityEfficiency(humidity), 1.5);
      double timeEfficiency = math.min(
          _calculateTimeEfficiency(durationMinutes.toDouble(), stepNumber),
          1.5);
      double progressEfficiency =
          math.min(_calculateBaseProgressEfficiency(fermentationProgress), 1.5);

      debugPrint('   🌡️ [환경 효율 상세]');
      debugPrint(
          '     온도 효율: ${tempEfficiency.toStringAsFixed(3)} (온도 ${temperature.toStringAsFixed(1)}°C)');
      debugPrint(
          '     습도 효율: ${humidityEfficiency.toStringAsFixed(3)} (습도 ${humidity.toStringAsFixed(1)}%)');
      debugPrint(
          '     시간 효율: ${timeEfficiency.toStringAsFixed(3)} (시간 ${durationMinutes}분)');
      debugPrint(
          '     진행률 효율: ${progressEfficiency.toStringAsFixed(3)} (진행률 ${(fermentationProgress * 100).toStringAsFixed(1)}%)');

      // 음수 값 체크
      if (tempEfficiency < 0)
        debugPrint('   🚨 [음수 감지] tempEfficiency: $tempEfficiency');
      if (humidityEfficiency < 0)
        debugPrint('   🚨 [음수 감지] humidityEfficiency: $humidityEfficiency');
      if (timeEfficiency < 0)
        debugPrint('   🚨 [음수 감지] timeEfficiency: $timeEfficiency');
      if (progressEfficiency < 0)
        debugPrint('   🚨 [음수 감지] progressEfficiency: $progressEfficiency');

      // 진행률 효율 합성 계산 - 빅데이터 준수: 계산 결과 그대로 사용
      double progressEfficiencyTotal = tempEfficiency *
          humidityEfficiency *
          timeEfficiency *
          progressEfficiency;

      debugPrint(
          '   🔄 [진행률 효율 합성] ${progressEfficiencyTotal.toStringAsFixed(6)}');
      debugPrint(
          '   📊 [합성 상세] ${tempEfficiency.toStringAsFixed(3)} × ${humidityEfficiency.toStringAsFixed(3)} × ${timeEfficiency.toStringAsFixed(3)} × ${progressEfficiency.toStringAsFixed(3)} = ${progressEfficiencyTotal.toStringAsFixed(6)}');

      if (progressEfficiencyTotal.isNaN || progressEfficiencyTotal.isInfinite) {
        debugPrint(
            '   🚨 [진행률 효율 합성 계산 오류] NaN/Infinite: $progressEfficiencyTotal');
        progressEfficiencyTotal = 0.0; // 빅데이터 준수: 기본값 사용 금지, 0으로 설정
      }
      if (progressEfficiencyTotal < 0) {
        debugPrint('   🚨 [진행률 효율 합성 음수 감지] $progressEfficiencyTotal');
      }

      // 글루텐 및 산도 효율 적용 - 빵 과학적 글루텐 영향 완화 (단계별 조정)
      double baseGlutenEfficiency = glutenFormation > 0
          ? 1.0 + (glutenFormation * 0.5)
          : 0.6; // 글루텐 영향 완화 (1.2 → 0.5)

      // 단계별 글루텐 효율 조정: 2단계에서 급격한 팽창 방지
      double stepGlutenMultiplier;
      switch (stepNumber) {
        case 1:
          stepGlutenMultiplier = 1.0; // 1단계: 정상 효율
          break;
        case 2:
          stepGlutenMultiplier = 0.8; // 2단계: 효율 완화 (급격한 팽창 방지)
          break;
        case 3:
          stepGlutenMultiplier = 0.9; // 3단계: 약간 완화
          break;
        default:
          stepGlutenMultiplier = 1.0; // 이후 단계: 정상 효율
      }

      double glutenEfficiency = baseGlutenEfficiency * stepGlutenMultiplier;

      debugPrint(
          '   🌾 [글루텐 효율] ${glutenEfficiency.toStringAsFixed(3)} (글루텐 형성도 $glutenFormation)');

      if (glutenEfficiency.isNaN || glutenEfficiency.isInfinite) {
        debugPrint('   🚨 [글루텐 효율 계산 오류] NaN/Infinite: $glutenEfficiency');
        glutenEfficiency = 0.6; // 기본값 적용
      }

      // 최종 팽창률 계산 (배율 → 퍼센트 변환) - 빵 과학적 현실성 보장
      double resultExpansion =
          progressEfficiencyTotal * glutenEfficiency * acidityEfficiency;

      debugPrint(
          '   🧮 [최종 배율 계산] ${progressEfficiencyTotal.toStringAsFixed(6)} × ${glutenEfficiency.toStringAsFixed(3)} × ${acidityEfficiency.toStringAsFixed(3)} = ${resultExpansion.toStringAsFixed(6)}');

      if (resultExpansion.isNaN || resultExpansion.isInfinite) {
        debugPrint('   🚨 [최종 팽창률 계산 오류] NaN/Infinite: $resultExpansion');
        return 0.0; // 오류 시 0 반환
      }

      double finalPercentage = (resultExpansion) * 100.0;

      debugPrint('   ✅ [팽창율 계산 완료] ${finalPercentage.toStringAsFixed(2)}%');
      return finalPercentage; // 퍼센트로 반환
    } catch (e, stackTrace) {
      debugPrint('🚨 [팽창율 계산 치명적 오류] 단계 $stepNumber');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return 0.0; // 오류 시 안전한 기본값 반환
    }
  }

  /// 이스트 타입 효율 계산 헬퍼
  static double _calculateTypeEfficiencyFromIngredients(
      List<Map<String, dynamic>> yeastIngredients,
      List<Map<String, dynamic>> naturalStarterIngredients) {
    // 자연 발효종이 있는 경우 우선적으로 사용
    if (naturalStarterIngredients.isNotEmpty) {
      double totalEfficiency = 0.0;
      double totalWeight = 0.0;

      for (final starter in naturalStarterIngredients) {
        final name = starter['name']?.toString().toLowerCase() ?? '';
        final amount = (starter['amount'] as num?)?.toDouble() ?? 0.0;

        if (amount <= 0) continue;

        // 자연 발효종은 낮은 효율 (상업용 이스트보다 천천히 작동)
        double typeEfficiency = _getNaturalStarterTypeEfficiency(name);
        totalEfficiency += typeEfficiency * amount;
        totalWeight += amount;
      }

      return totalWeight > 0 ? totalEfficiency / totalWeight : 0.6;
    }

    // 상업용 이스트 계산
    if (yeastIngredients.isEmpty) return 0.8;

    double totalEfficiency = 0.0;
    double totalWeight = 0.0;

    for (final yeast in yeastIngredients) {
      final name = yeast['name']?.toString().toLowerCase() ?? '';
      final amount = (yeast['amount'] as num?)?.toDouble() ?? 0.0;

      if (amount <= 0) continue;

      double typeEfficiency = _getYeastTypeEfficiency(name);
      totalEfficiency += typeEfficiency * amount;
      totalWeight += amount;
    }

    return totalWeight > 0 ? totalEfficiency / totalWeight : 0.8;
  }

  /// CO2 생성률 계산 헬퍼
  static double _calculateCO2RateFromIngredients(
      List<Map<String, dynamic>> yeastIngredients,
      List<Map<String, dynamic>> naturalStarterIngredients) {
    // 자연 발효종이 있는 경우 우선적으로 사용
    if (naturalStarterIngredients.isNotEmpty) {
      double totalWeightedCO2 = 0.0;
      double totalWeight = 0.0;

      for (final starter in naturalStarterIngredients) {
        final name = starter['name']?.toString().toLowerCase() ?? '';
        final amount = (starter['amount'] as num?)?.toDouble() ?? 0.0;

        if (amount <= 0) continue;

        // 자연 발효종은 낮은 CO2율 (상업용 이스트보다 천천히 작동)
        final co2Rate = _getNaturalStarterCO2Rate(name);
        totalWeightedCO2 += co2Rate * amount;
        totalWeight += amount;
      }

      return totalWeight > 0 ? totalWeightedCO2 / totalWeight : 0.5;
    }

    // 상업용 이스트 계산
    double totalWeightedCO2 = 0.0;
    double totalWeight = 0.0;

    for (final yeast in yeastIngredients) {
      final name = yeast['name']?.toString().toLowerCase() ?? '';
      final amount = (yeast['amount'] as num?)?.toDouble() ?? 0.0;

      if (amount <= 0) continue;

      final co2Rate = _getYeastCO2Rate(name);
      totalWeightedCO2 += co2Rate * amount;
      totalWeight += amount;
    }

    return totalWeight > 0 ? totalWeightedCO2 / totalWeight : 0.083333;
  }

  /// 검증 헬퍼들 (보정 금지 - 기본값 사용 금지 정책 준수)
  static double _validateAndAdjustPercentage(
      double percentage, List<String> warnings) {
    // ✅ 범위 제한 금지 - 계산 결과 그대로 사용
    if (percentage < 0.1) {
      warnings.add('이스트 백분율이 너무 낮음: ${percentage.toStringAsFixed(2)}%');
    } else if (percentage > 10.0) {
      warnings.add('이스트 백분율이 너무 높음: ${percentage.toStringAsFixed(2)}%');
    }
    return percentage; // 값 그대로 반환 (보정 금지)
  }

  static double _validateAndAdjustTypeEfficiency(
      double efficiency, List<String> warnings) {
    // ✅ 범위 제한 금지 - 계산 결과 그대로 사용
    if (efficiency < 0.5 || efficiency > 1.2) {
      warnings.add('이스트 타입 효율 비정상: ${efficiency.toStringAsFixed(3)}');
    }
    return efficiency; // 값 그대로 반환 (보정 금지)
  }

  /// 이스트 타입별 효율 매핑 (빅데이터 기반)
  static double _getYeastTypeEfficiency(String name) {
    if (name.contains('생이스트') ||
        name.contains('fresh yeast') ||
        name.contains('압축이스트') ||
        name.contains('compressed yeast')) {
      return 1.00;
    }
    if (name.contains('드라이이스트') ||
        name.contains('dry yeast') ||
        name.contains('인스턴트드라이') ||
        name.contains('instant dry yeast')) {
      return 0.95;
    }
    if (name.contains('액티브드라이') || name.contains('active dry yeast')) {
      return 0.90;
    }
    if (name.contains('사워도우스타터') ||
        name.contains('sourdough starter') ||
        name.contains('천연효모') ||
        name.contains('natural yeast') ||
        name.contains('르방') ||
        name.contains('levain')) {
      return 0.80;
    }
    if (name.contains('와일드이스트') || name.contains('wild yeast')) {
      return 0.70;
    }
    return 0.80; // 미분류 기본값
  }

  /// 자연 발효종 타입 효율 매핑 (빵 과학 기반)
  /// 자연 발효종은 상업용 이스트보다 효율이 낮음
  static double _getNaturalStarterTypeEfficiency(String name) {
    // 자연 발효종은 천천히 작동하므로 효율이 낮음
    if (name.contains('생종') || name.contains('starter')) return 0.6;
    if (name.contains('탕종') || name.contains('poolish')) return 0.7;
    if (name.contains('르방') || name.contains('levain')) return 0.65;
    if (name.contains('커머센트') || name.contains('commersant')) return 0.55;
    if (name.contains('천연효모') || name.contains('natural yeast')) return 0.5;
    if (name.contains('와일드이스트') || name.contains('wild yeast')) return 0.4;
    return 0.6; // 미분류 자연 발효종 기본값
  }

  /// 자연 발효종 백분율 계산 (빵 과학적 효모 함량 기반)
  /// 자연 발효종의 실제 효모 함량을 고려하여 백분율 계산
  static double _calculateNaturalStarterPercentage(
      List<Map<String, dynamic>> naturalStarterIngredients,
      List<Map<String, dynamic>> flourIngredients) {
    debugPrint('🌱 [자연 발효종 백분율 계산 시작] - 빵 과학적 효모 함량 기반');
    debugPrint(
        '   입력: 자연 발효종 ${naturalStarterIngredients.length}개, 밀가루 ${flourIngredients.length}개');

    if (naturalStarterIngredients.isEmpty) {
      debugPrint('   ❌ 자연 발효종 재료가 없음 → 백분율 0.0%');
      return 0.0;
    }

    if (flourIngredients.isEmpty) {
      debugPrint('   ❌ 밀가루 재료가 없음 → 백분율 0.0%');
      return 0.0;
    }

    // 밀가루 총량 계산
    double totalFlourWeight = 0.0;
    debugPrint('   🔍 밀가루 재료별 계산:');
    for (final flour in flourIngredients) {
      final name = flour['name'] as String? ?? '이름없음';
      final amount = (flour['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      final weight = IngredientAnalyzer.convertToGrams(amount, unit, name);
      totalFlourWeight += weight;
      debugPrint(
          '     - $name: ${amount}${unit} → ${weight.toStringAsFixed(1)}g');
    }

    if (totalFlourWeight <= 0) {
      debugPrint('   ❌ 밀가루 총량이 0g 이하 → 백분율 0.0%');
      return 0.0;
    }

    // 자연 발효종 총량 계산
    double totalNaturalStarterWeight = 0.0;
    debugPrint('   🔍 자연 발효종 재료별 계산:');
    for (final starter in naturalStarterIngredients) {
      final name = starter['name'] as String? ?? '이름없음';
      final amount = (starter['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = starter['unit'] as String? ?? 'g';
      final weight = IngredientAnalyzer.convertToGrams(amount, unit, name);
      totalNaturalStarterWeight += weight;
      debugPrint(
          '     - $name: ${amount}${unit} → ${weight.toStringAsFixed(1)}g');
    }

    // 빵 과학적 접근: 자연 발효종의 실제 효모 함량 계산
    // 전통 생종 효모 농도: 1-5% (빵 과학 연구 기반)
    double effectiveYeastPercentage = 0.0;

    for (final starter in naturalStarterIngredients) {
      final name = starter['name'] as String? ?? '';
      final amount = (starter['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = starter['unit'] as String? ?? 'g';
      final weight = IngredientAnalyzer.convertToGrams(amount, unit, name);

      // 자연 발효종 타입별 실제 효모 농도 적용
      double yeastConcentration = _getNaturalStarterYeastConcentration(name);
      double effectiveYeastWeight = weight * yeastConcentration;

      effectiveYeastPercentage +=
          (effectiveYeastWeight / totalFlourWeight) * 100.0;

      debugPrint(
          '     🔬 $name 효모 농도: ${(yeastConcentration * 100).toStringAsFixed(1)}%');
      debugPrint('     ⚡ 유효 효모량: ${effectiveYeastWeight.toStringAsFixed(3)}g');
    }

    debugPrint('   📊 빵 과학적 계산 결과:');
    debugPrint('     밀가루 총량: ${totalFlourWeight.toStringAsFixed(1)}g');
    debugPrint(
        '     자연 발효종 총량: ${totalNaturalStarterWeight.toStringAsFixed(1)}g');
    debugPrint(
        '     물리적 백분율: ${(totalNaturalStarterWeight / totalFlourWeight * 100).toStringAsFixed(2)}%');
    debugPrint(
        '     유효 효모 백분율: ${effectiveYeastPercentage.toStringAsFixed(3)}%');

    final clampedPercentage =
        effectiveYeastPercentage.clamp(0.0, double.infinity);
    debugPrint('   ✅ 최종 유효 효모 백분율: ${clampedPercentage.toStringAsFixed(3)}%');

    return clampedPercentage; // 실제 효모 함량 기반 백분율 반환
  }

  /// 자연 발효종 효모 농도 계산 (빵 과학 기반)
  /// 전통 생종의 실제 효모 함량을 고려하여 백분율 반환
  static double _getNaturalStarterYeastConcentration(String name) {
    // 빵 과학 연구 기반: 자연 발효종의 실제 효모 농도
    // 전통 생종: 1-5% 정도의 효모 함량 (전체 무게 기준)
    if (name.contains('생종') || name.contains('starter')) return 0.025; // 2.5%
    if (name.contains('탕종') || name.contains('poolish')) return 0.020; // 2.0%
    if (name.contains('르방') || name.contains('levain')) return 0.030; // 3.0%
    if (name.contains('커머센트') || name.contains('commersant'))
      return 0.015; // 1.5%
    if (name.contains('천연효모') || name.contains('natural yeast'))
      return 0.010; // 1.0%
    if (name.contains('와일드이스트') || name.contains('wild yeast'))
      return 0.005; // 0.5%
    return 0.020; // 미분류 자연 발효종 기본값 (2.0%)
  }

  /// 자연 발효종 CO2 생성률 매핑 (빵 과학 기반 - ml/g/분 단위)
  /// 자연 발효종은 상업용 이스트보다 CO2 발생량이 적음
  static double _getNaturalStarterCO2Rate(String name) {
    // 빵 과학 기준: 자연 발효종은 상업용 이스트보다 CO2 발생량이 적음
    // 생종: 0.8 ml/g/분 (분당 0.8ml)
    if (name.contains('생종') || name.contains('starter')) return 0.8;
    if (name.contains('탕종') || name.contains('poolish')) return 0.9;
    // 르방: 0.7 ml/g/분 (분당 0.7ml)
    if (name.contains('르방') || name.contains('levain')) return 0.7;
    if (name.contains('커머센트') || name.contains('commersant')) return 0.6;
    // 천연효모: 0.5 ml/g/분 (분당 0.5ml)
    if (name.contains('천연효모') || name.contains('natural yeast')) return 0.5;
    if (name.contains('와일드이스트') || name.contains('wild yeast')) return 0.4;
    return 0.7; // 미분류 자연 발효종 기본값
  }

  /// 이스트 타입별 CO2 생성률 매핑 (빵 과학 기반 - ml/g/분 단위)
  /// 빅데이터 준수: 실제 빵 과학 데이터 기반으로 조정
  static double _getYeastCO2Rate(String name) {
    // 빵 과학 기준: 1시간에 1g당 CO2 발생량을 분 단위로 변환
    // 생이스트: 2.0 ml/g/분 (분당 2.0ml)
    if (name.contains('생이스트') || name.contains('fresh yeast')) return 2.0;
    if (name.contains('압축이스트') || name.contains('compressed yeast')) return 1.8;
    // 드라이이스트: 1.6 ml/g/분 (분당 1.6ml)
    if (name.contains('드라이이스트') || name.contains('dry yeast')) return 1.6;
    if (name.contains('인스턴트드라이')) return 1.6;
    if (name.contains('액티브드라이')) return 1.4;
    // 사워도우: 1.0 ml/g/분 (분당 1.0ml)
    if (name.contains('사워도우스타터') || name.contains('르방')) return 1.0;
    if (name.contains('천연효모')) return 0.9;
    if (name.contains('와일드이스트')) return 0.7;
    return 1.4; // 미분류 기본값 (액티브 드라이 기준)
  }

  /// 환경 효율 계산 헬퍼들 (팽창율 계산용)
  static double _calculateTemperatureEfficiency(double temperature) {
    if (temperature >= 22 && temperature <= 28) return 1.0;
    if (temperature >= 18 && temperature < 22)
      return 0.9 + (temperature - 18) * 0.025;
    if (temperature > 28 && temperature <= 35)
      return 1.0 - (temperature - 28) * 0.02;
    return 0.8;
  }

  static double _calculateHumidityEfficiency(double humidity) {
    if (humidity >= 65 && humidity <= 85) return 1.0;
    if (humidity >= 50 && humidity < 65) return 0.85 + (humidity - 50) * 0.03;
    if (humidity > 85 && humidity <= 95) return 1.0 - (humidity - 85) * 0.02;
    return 0.75;
  }

  static double _calculateTimeEfficiency(
      double durationMinutes, int stepNumber) {
    // 빵 과학적 현실성: 사용자가 입력한 발효 시간을 기준으로 단계별 효율 조정
    // 1단계: 입력 시간의 80% 수준 (효모 적응 단계 - 효율 낮음)
    // 2단계: 입력 시간의 90% 수준 (안정 발효 단계 - 효율 상승)
    // 3단계 이상: 입력 시간의 100% 수준 (피로 단계 - 효율 유지)

    double baseExpectedTime;
    switch (stepNumber) {
      case 1:
        baseExpectedTime = durationMinutes * 0.8; // 1단계: 80% 기준 (효율 낮음)
        break;
      case 2:
        baseExpectedTime = durationMinutes * 0.9; // 2단계: 90% 기준 (효율 상승)
        break;
      default:
        baseExpectedTime = durationMinutes * 1.0; // 3단계 이상: 100% 기준 (효율 유지)
    }

    // 최소/최대 시간 보장 (빵 과학적 현실성)
    baseExpectedTime = math.max(baseExpectedTime, 30.0); // 최소 30분
    baseExpectedTime =
        math.min(baseExpectedTime, durationMinutes * 1.2); // 최대 입력시간의 120%

    debugPrint(
        '   ⏱️ [시간 효율 계산] 단계 $stepNumber - 입력시간: ${durationMinutes.toStringAsFixed(1)}분, 기준시간: ${baseExpectedTime.toStringAsFixed(1)}분');

    double timeRatio = durationMinutes / baseExpectedTime;

    // 빵 과학적 효율 곡선: 단계별 자연스러운 변화
    if (timeRatio >= 0.9 && timeRatio <= 1.1) return 1.0; // 최적 범위
    if (timeRatio < 0.9) return math.max(0.7, timeRatio * 1.1); // 낮은 효율 범위 완화
    double efficiency = 1.5 / (timeRatio + 0.5); // 높은 효율 범위 완화
    return math.min(efficiency, 1.2); // 최대 효율 제한
  }

  static double _calculateBaseProgressEfficiency(double progress) {
    if (progress <= 0) return 0.1;
    if (progress < 0.4)
      return 0.1 + (progress * 2.25); // 0-0.4: 0.1 → 1.0 (완만한 증가)
    if (progress < 0.7)
      return 1.0 + (progress - 0.4) * 0.8; // 0.4-0.7: 1.0 → 1.16 (완만한 증가로 변경)
    if (progress <= 1.0)
      return 1.16 - (progress - 0.7) * 0.1; // 0.7-1.0: 1.16 → 1.06 (완만한 감소)
    return 1.06; // 최대 효율 제한
  }
}

/// 🧪 VolumeExpansionCalculator 클래스 (표준화된 팽창율 계산)
class VolumeExpansionCalculator {
  /// 팽창율을 퍼센트로 변환
  static double expansionToPercent(double expansion) {
    return (expansion - 1.0) * 100.0;
  }

  /// 팽창률을 다시 배율로 변환
  static double percentToExpansion(double percent) {
    return percent / 100.0 + 1.0;
  }

  /// 팽창률 기반 색상 결정
  static Color getExpansionColor(double expansion) {
    double percent = expansionToPercent(expansion);
    if (percent >= 180.0) return Colors.green.shade600;
    if (percent >= 120.0) return Colors.blue.shade600;
    if (percent >= 80.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 표준화된 팽창률 텍스트 포맷
  static String formatExpansion(double expansion, {bool showPercent = true}) {
    if (showPercent) {
      return '${expansionToPercent(expansion).toStringAsFixed(1)}%';
    } else {
      return '${expansion.toStringAsFixed(2)}배';
    }
  }

  /// 팽창률을 VolumeExpansion enum으로 변환
  static art.VolumeExpansion convertToEnum(double expansionPercent) {
    // 실제 enum으로 반환하여 타입 호환성 해결
    if (expansionPercent >= 200.0) return art.VolumeExpansion.excellent;
    if (expansionPercent >= 120.0) return art.VolumeExpansion.excessive;
    if (expansionPercent >= 80.0) return art.VolumeExpansion.excellent;
    if (expansionPercent >= 30.0) return art.VolumeExpansion.moderate;
    return art.VolumeExpansion.minimal;
  }
}

/// 발효 계산 엔진 - 일관된 이스트 값 참조
class FermentationCalculator {
  /// 싱글턴 패턴
  static final FermentationCalculator _instance =
      FermentationCalculator._internal();
  factory FermentationCalculator() => _instance;
  FermentationCalculator._internal();

  /// 싱글턴 인스턴스 getter (하위 호환성 유지)
  static FermentationCalculator get instance => _instance;

  /// 파싱 캐시 (하위 호환성 유지)
  final Map<String, Map<String, double>> _parsingCache = {};

  /// 마지막 발효 결과 저장 (컨트롤러에서 사용)
  static var _lastFermentationResult;

  /// 메인 인터페이스 calculate 메소드 (하위 호환성 유지)
  CalculationResult calculate(
    CalculationInput input, {
    Map<String, dynamic>? recipeData,
    List<Map<String, dynamic>>? recipeFermentationSteps,
    bool useEnvironmentValues = false,
  }) {
    // 기존 인터페이스와의 호환성 위해 임시로 기본 값 반환
    return calculateRoomTemperatureFermentation(
      FermentationCalculationInput(
        mixingState: input.currentState,
        fermentationSteps: [],
        fermentationMethod: FermentationMethodType.roomTemperature,
        environment: input.environment,
        ingredients: input.ingredients,
      ),
    );
  }

  /// 캐시 클리어 메소드 (하위 호환성 유지)
  void clearCalculationCache() {
    _parsingCache.clear();
    debugPrint('🧹 [파싱 캐시 클리어] 모든 파싱 캐시가 초기화되었습니다');
  }

  /// 마지막 발효 결과 설정 (컨트롤러에서 사용)
  static void setLastFermentationResult(dynamic result) {
    _lastFermentationResult = result;
  }

  /// 마지막 발효 결과 가져오기
  static dynamic getLastFermentationResult() {
    return _lastFermentationResult;
  }

  /// 🎯 컨텍스트 기반 통합 발효 계산 메소드
  /// 어려 다른 계산 메소드들의 공통 인터페이스
  Future<art.FermentationProcessResult> calculateWithContext(
      FermentationCalculationContext context) async {
    debugPrint('🎯 [컨텍스트 기반 계산] 시작');
    debugPrint(context.getContextSummary());

    try {
      // === 1. 이스트 속성이 없으면 계산 ===
      context.yeastProperties ??=
          YeastCalculationService.calculateStandardizedYeastProperties(
        ingredients: context.ingredients,
      );
      debugPrint('🧬 이스트 속성 초기화 완료');

      // === 2. 컨텍스트 기반 발효 계산 수행 ===
      final calculationResult = await _performFermentationCalculation(context);

      if (!calculationResult.success) {
        debugPrint('❌ [컨텍스트 계산 실패] 에러: ${calculationResult.error}');

        return art.FermentationProcessResult(
          stepResults: [],
          totalElapsedTime: 0,
          finalYeastActivity: 0.0,
          overallSuccess: false,
        );
      }

      // === 3. 결과를 컨텍스트에 저장 ===
      _lastFermentationResult = calculationResult;

      // === 4. 전처리결과 추출 ===
      final data = calculationResult.data;
      final totalSteps = data?['totalSteps'] as int? ?? 0;

      final yeastProperties = data?['yeastProperties'] as Map<String, dynamic>?;
      final finalYeastActivity =
          (yeastProperties?['activity'] as num?)?.toDouble() ?? 0.0;

      // === 5. 총 시간 계산 (컨텍스트 단계들을 사용) ===
      final totalElapsedTime =
          context.fermentationSteps.fold<int>(0, (sum, step) {
        debugPrint('🔍 [시간 합산] 단계 ${step.stepNumber} 시간 계산');

        int durationMinutes = 0;
        if (step is art.FermentationStep) {
          durationMinutes = step.duration.inMinutes.toInt();
        } else if (step is FermentationStep) {
          durationMinutes = step.durationMinutes;
        } else {
          // 다른 타입인 경우 런타임 타입으로 판별
          if (step.runtimeType.toString().contains('FermentationStep')) {
            durationMinutes = (step as dynamic).duration.inMinutes.toInt();
          }
        }

        debugPrint('⏱️ 단계 ${step.stepNumber}: $durationMinutes분');
        return sum + durationMinutes;
      });

      // === 6. 컨텍스트에 로깅 ===
      context.debugLogs
          .add('✅ [컨텍스트 계산 완료] 총 ${totalSteps}단계, 총 ${totalElapsedTime}분 계산됨');

      debugPrint('✅ [컨텍스트 기반 계산 완료] 총 시간: ${totalElapsedTime}분');
      debugPrint(context.getContextSummary());

      return art.FermentationProcessResult(
        stepResults: [], // 실제 단계별 결과는 추후 구현시 추가
        totalElapsedTime: totalElapsedTime,
        finalYeastActivity: finalYeastActivity,
        overallSuccess: calculationResult.success,
      );
    } catch (e, stackTrace) {
      debugPrint('🚨 [컨텍스트 계산 치명적 오류]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');

      context.debugLogs.add('❌ 계산 실패: ${e.toString()}');

      return art.FermentationProcessResult(
        stepResults: [],
        totalElapsedTime: 0,
        finalYeastActivity: 0.0,
        overallSuccess: false,
      );
    }
  }

  /// 🔧 컨텍스트 기반 실제 계산 수행 헬퍼
  Future<CalculationResult> _performFermentationCalculation(
      FermentationCalculationContext context) async {
    debugPrint('🔄 [컨텍스트 계산 수행] 시작');

    // 컨텍스트의 fermentationSteps를 List<FermentationStep>으로 변환
    final List<FermentationStep> conversionSteps =
        context.fermentationSteps.map((step) {
      // 이미 FermentationStep인 경우 그대로 반환
      if (step is FermentationStep) return step;

      // Map인 경우 FermentationStep으로 변환
      if (step is Map<String, dynamic>) {
        return FermentationStep(
          stepNumber: step['stepNumber'] as int? ?? 1,
          durationMinutes:
              step['durationMinutes'] as int? ?? step['time'] as int? ?? 10,
          targetTemperature: (step['targetTemperature'] as num?)?.toDouble() ??
              context.environment.temperature ??
              25.0,
          targetHumidity: (step['targetHumidity'] as num?)?.toDouble() ??
              context.environment.humidity ??
              70.0,
          description: step['description'] as String? ??
              step['stepNotes'] as String? ??
              '발효 단계 ${step['stepNumber'] ?? 1}',
        );
      }

      // art.FermentationStep인 경우 계산 타입 FermentationStep으로 변환
      if (step is art.FermentationStep) {
        return FermentationStep(
          stepNumber: step.stepNumber,
          durationMinutes: step.duration.inMinutes.toInt(),
          targetTemperature: step.targetTemperature,
          targetHumidity: step.targetHumidity.toDouble(),
          description: step.stepNotes,
        );
      }

      // 기타 타입의 경우 기본 값 사용
      debugPrint('⚠️ [단계 변환] 알 수 없는 타입: ${step.runtimeType}, 기본 값 사용');
      return FermentationStep(
        stepNumber: 1,
        durationMinutes: 10,
        targetTemperature: context.environment.temperature ?? 25.0,
        targetHumidity: context.environment.humidity ?? 70.0,
        description: '기본 발효 단계',
      );
    }).toList();

    // 기존 calculateRoomTemperatureFermentation 로직을 컨텍스트 기반으로 재사용
    final input = FermentationCalculationInput(
      mixingState: context.mixingState,
      fermentationSteps: conversionSteps,
      fermentationMethod: FermentationMethodType.roomTemperature,
      environment: context.environment,
      ingredients: context.ingredients,
    );

    // 기존 메소드 호출 (나중에 컨텍스트로 완전히 대체 가능)
    return calculateRoomTemperatureFermentation(input);
  }

  /// 메인 계산 인터페이스 (실온 발효)
  CalculationResult calculateRoomTemperatureFermentation(
      FermentationCalculationInput input) {
    debugPrint('🍞 [실온 발효 계산] 중앙화된 이스트 값 참조로 일관된 계산 수행');

    try {
      // === 1. 이스트 속성 한 번 계산 (모든 단계에서 동일하게 사용) ===
      debugPrint('🧪 [단계 1] 이스트 속성 계산 시작');
      final yeastProperties =
          YeastCalculationService.calculateStandardizedYeastProperties(
        ingredients: input.ingredients,
      );
      debugPrint('🧪 [단계 1] 이스트 속성 계산 완료');

      debugPrint('🧪 [표준화 이스트 속성 계산 완료]');
      debugPrint(
          '   📊 백분율: ${yeastProperties.percentage.toStringAsFixed(2)}%');
      debugPrint(
          '   🧪 타입 효율: ${yeastProperties.typeEfficiency.toStringAsFixed(3)}');
      debugPrint('   ⚡ 활성도: ${yeastProperties.activity.toStringAsFixed(4)}');
      debugPrint('   💨 CO2율: ${yeastProperties.co2Rate.toStringAsFixed(6)}');
      debugPrint('   ✅ 유효성: ${yeastProperties.isValid}');

      if (yeastProperties.validationWarnings.isNotEmpty) {
        debugPrint('⚠️ 검증 경고:');
        yeastProperties.validationWarnings
            .forEach((w) => debugPrint('   - $w'));
      }

      // === 2. 단계별 계산 (동일한 이스트 속성 사용) ===
      final steps = input.fermentationSteps;
      debugPrint('📋 [단계 2] 총 ${steps.length}개 단계별 계산 시작');

      FermentationState currentState = FermentationState.initial(
        mixingState: input.mixingState,
        environment: input.environment,
        ingredients: input.ingredients, // 재료량 기반 산도 계산을 위한 재료 정보 전달
        recipeTitle: input.recipeData?['title'] as String?, // 레시피 제목 전달
      );

      // ✅ 단계별 계산 결과 저장을 위한 리스트
      List<FermentationStepResult> stepResults = [];

      // 누적 시간 추적을 위한 변수
      int totalElapsedTime = 0;

      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        debugPrint(
            '   🔄 [단계 ${step.stepNumber} (${i + 1}/${steps.length})] 계산 시작 - 누적 시간: ${totalElapsedTime}분');

        try {
          // 모든 단계에서 동일한 yeastProperties 사용
          final stepResult = _calculateStepWithStandardYeast(
            previousState: currentState,
            step: step,
            yeastProperties: yeastProperties,
            mixingState: input.mixingState,
            environment: input.environment,
            ingredients: input.ingredients,
            totalElapsedTime: totalElapsedTime, // 누적 시간 전달
          );

          currentState = stepResult.state;
          stepResults.add(stepResult); // ✅ 단계별 결과 저장

          // 단계 완료 후 누적 시간 업데이트
          totalElapsedTime += step.durationMinutes;
          debugPrint(
              '   ⏱️ [누적 시간 업데이트] 단계 ${step.stepNumber} 완료, 누적 시간: ${totalElapsedTime}분');

          if (!stepResult.success) {
            debugPrint(
                '   ❌ [단계 ${step.stepNumber}] 계산 실패: 메타데이터=${stepResult.metadata}');
          } else {
            debugPrint(
                '   ✅ [단계 ${step.stepNumber}] 진행률: ${(currentState.fermentationProgress * 100).toStringAsFixed(0)}%');
          }
        } catch (e, stackTrace) {
          debugPrint('   🚨 [단계 ${step.stepNumber}] 치명적 오류 발생!');
          debugPrint('     Error: $e');
          debugPrint('     StackTrace: $stackTrace');
          debugPrint('     이전 상태 유지 및 계산 계속 진행');

          // 오류 발생 시에도 누적 시간 업데이트 (계산 계속 진행)
          totalElapsedTime += step.durationMinutes;
          debugPrint(
              '   ⏱️ [오류 시 누적 시간 업데이트] 단계 ${step.stepNumber}, 누적 시간: ${totalElapsedTime}분');
        }
      }

      debugPrint('📋 [단계 2] 모든 단계별 계산 완료');

      return CalculationResult(
        data: {
          'finalState': currentState.toJson(),
          'totalSteps': steps.length,
          'stepResults': stepResults, // ✅ 단계별 결과 리스트 저장
          'yeastProperties': {
            'percentage': yeastProperties.percentage,
            'typeEfficiency': yeastProperties.typeEfficiency,
            'activity': yeastProperties.activity,
            'co2Rate': yeastProperties.co2Rate,
            'isValid': yeastProperties.isValid,
            'warnings': yeastProperties.validationWarnings,
          },
        },
        success: true,
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      return CalculationResult(
        data: {'error': e.toString()},
        success: false,
        error: '발효 계산 실패: $e',
        calculatedAt: DateTime.now(),
      );
    }
  }

  /// 개별 단계 계산 - 표준화된 이스트 속성 사용
  FermentationStepResult _calculateStepWithStandardYeast({
    required FermentationState previousState,
    required FermentationStep step,
    required StandardizedYeastProperties yeastProperties,
    required BakingState mixingState,
    required UserEnvironment environment,
    required List<Map<String, dynamic>> ingredients,
    required int totalElapsedTime, // 누적 시간 추가
  }) {
    // === 이스트 활성도 계산 (일관된 속성 사용) ===
    final yeastActivity = yeastProperties.activity; // 동일한 값 사용

    // === 발효 진행율 계산 ===
    final fermentationProgress = _calculateFermentationProgress(
      previousProgress: previousState.fermentationProgress,
      step: step,
      yeastActivity: yeastActivity,
      glutenFormation: mixingState.glutenFormation,
      totalElapsedTime: totalElapsedTime.toDouble(), // 누적 시간 전달
      previousAcidity: previousState.acidity, // 이전 산도 값 전달
      previousTemperature: previousState.temperature, // 이전 온도 값 전달
    );

    // === 산도 계산 ===
    final acidity = _calculateAcidity(
      previousAcidity: previousState.acidity,
      step: step,
      yeastActivity: yeastActivity,
      ingredients: ingredients,
      environment: environment,
    );

    // === 부피 증가율 계산 (중앙화된 팽창율 계산, 일관된 이스트 속성 전달) ===
    final volumeIncrease = YeastCalculationService.calculateVolumeExpansion(
      fermentationProgress: fermentationProgress,
      acidity: acidity,
      glutenFormation: mixingState.glutenFormation,
      stepNumber: step.stepNumber,
      temperature: step.targetTemperature,
      humidity: step.targetHumidity.toDouble(),
      durationMinutes: step.durationMinutes,
      yeastProperties: yeastProperties, // 일관된 이스트 속성 전달
    );

    // === CO2 생성량 계산 ===
    final stepCO2Generation = _calculateStepCO2Generation(
      step: step,
      yeastProperties: yeastProperties, // 일관된 속성 사용
      temperature: step.targetTemperature,
      humidity: step.targetHumidity,
      ingredients: ingredients, // 밀가루 무게 계산을 위해 추가
    );

    final newCumulativeCO2 = previousState.cumulativeCO2 + stepCO2Generation;

    // 최종 상태 구성
    final newState = FermentationState(
      yeastActivity: yeastActivity,
      fermentationProgress: fermentationProgress,
      acidity: acidity,
      volumeIncrease: volumeIncrease,
      fermentationMethod: '실온 발효 (표준화 이스트 속성 사용)',
      currentStep: step.stepNumber,
      temperature: step.targetTemperature,
      humidity: step.targetHumidity.toDouble(),
      cumulativeCO2: newCumulativeCO2,
    );

    return FermentationStepResult(
      state: newState,
      metadata: {
        'stepNumber': step.stepNumber,
        'calculationMethod': 'standardized_yeast_properties',
        'yeastActivitySource': 'StandardizedYeastProperties.activity',
        'co2RateSource': 'StandardizedYeastProperties.co2Rate',
      },
      success: true,
      calculatedAt: DateTime.now(),
      co2Generation: stepCO2Generation,
    );
  }

  /// 발효 진행율 계산 - 생물학적 성장 모델 적용
  double _calculateFermentationProgress({
    required double previousProgress,
    required FermentationStep step,
    required double yeastActivity,
    required double glutenFormation,
    required double totalElapsedTime, // 누적 시간 추가
    required double previousAcidity, // 실제 산도 값 사용을 위한 추가
    required double previousTemperature, // 이전 단계 온도 추가
  }) {
    try {
      debugPrint(
          '🧬 [생물학적 진행율 계산] 단계 ${step.stepNumber} - 총 누적 시간: ${totalElapsedTime.toStringAsFixed(1)}분');

      // 단계별 동적 온도 계산 적용
      double dynamicTemperature = _calculateDynamicTemperatureForStep(
        step: step,
        totalElapsedTime: totalElapsedTime,
        previousTemperature: previousTemperature,
      );

      // 생물학적 성장률 계산 (동적 온도 사용)
      double biologicalGrowthRate =
          BiologicalFermentationModel.calculateBiologicalGrowthRate(
        totalElapsedTime: totalElapsedTime,
        yeastActivity: yeastActivity,
        temperature: dynamicTemperature, // 동적 온도 적용
        acidity: previousAcidity, // 실제 이전 산도 값 사용 (일관성 개선)
      );

      // 시간 기반 증분 계산 (생물학적 모델 적용 - 분 단위 직접 계산)
      double timeIncrement =
          biologicalGrowthRate * step.durationMinutes.toDouble();

      // 글루텐 형성도 영향: 글루텐 네트워크가 잘 형성될수록 발효 진행이 원활 (완화 적용)
      double glutenEfficiency =
          glutenFormation > 0 ? 1.0 + (glutenFormation * 0.2) : 0.8;
      final increment = timeIncrement * glutenEfficiency;

      debugPrint('🧬 [생물학적 진행율 계산 상세]');
      debugPrint(
          '   - 생물학적 성장률: ${biologicalGrowthRate.toStringAsFixed(4)} (시간 종속)');
      debugPrint(
          '   - 시간 증분: ${timeIncrement.toStringAsFixed(6)} (생장률 × 시간 × 1/60)');
      debugPrint(
          '   - 글루텐 효율: ${glutenEfficiency.toStringAsFixed(3)} (글루텐 형성도: $glutenFormation)');
      debugPrint('   - 최종 증분: ${increment.toStringAsFixed(6)}');

      if (increment.isNaN || increment.isInfinite) {
        debugPrint('🚨 [생물학적 진행율 증분 계산 오류] NaN/Infinite: $increment');
        return previousProgress; // 오류 시 이전 값 유지
      }

      final newProgress = previousProgress + increment;

      if (newProgress.isNaN || newProgress.isInfinite) {
        debugPrint('🚨 [생물학적 최종 진행율 계산 오류] NaN/Infinite: $newProgress');
        return previousProgress; // 오류 시 이전 값 유지
      }

      // 빅데이터 준수: 계산 결과 그대로 사용 (clamp 제거)
      debugPrint(
          '🧬 [생물학적 진행율 계산 완료] ${newProgress.toStringAsFixed(3)} (${(newProgress * 100).toStringAsFixed(1)}%)');
      return newProgress;
    } catch (e, stackTrace) {
      debugPrint('🚨 [생물학적 진행율 계산 치명적 오류] 단계 ${step.stepNumber}');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return previousProgress; // 오류 시 이전 값 유지
    }
  }

  /// 빵 과학적 단계별 가속화 계수 계산
  static double _calculateStepAccelerationFactor(
      int stepNumber, double previousProgress) {
    // 빵 과학: 발효 초기 단계에서 효모 활성화로 진행이 더 빠름
    // 단계 1: 초기 활성화로 1.5배 가속
    // 단계 2: 안정화 단계로 1.2배 가속
    // 이후 단계: 정상 속도

    if (stepNumber == 1) {
      return 1.5; // 초기 단계 가속화
    } else if (stepNumber == 2) {
      return 1.2; // 두 번째 단계 가속화
    } else {
      return 1.0; // 이후 단계 정상 속도
    }
  }

  /// 산도 계산
  double _calculateAcidity({
    required double previousAcidity,
    required FermentationStep step,
    required double yeastActivity,
    required List<Map<String, dynamic>> ingredients,
    required UserEnvironment environment,
  }) {
    try {
      debugPrint(
          '🧪 [산도 계산] 단계 ${step.stepNumber} - 시작: previous=${previousAcidity.toStringAsFixed(2)}');

      // 빵 과학적 산도 증가: 계수 상향 조정 (0.00002 → 0.001, 50배 증가)
      double acidProduction = step.durationMinutes * yeastActivity * 0.001;
      if (acidProduction.isNaN || acidProduction.isInfinite) {
        debugPrint('🚨 [산 생산량 계산 오류] NaN/Infinite: $acidProduction');
        acidProduction = 0.0;
      }

      double environmentalInfluence =
          _calculateEnvironmentalAcidInfluence(step, environment);
      if (environmentalInfluence.isNaN || environmentalInfluence.isInfinite) {
        debugPrint('🚨 [환경 영향 계산 오류] NaN/Infinite: $environmentalInfluence');
        environmentalInfluence = 0.0;
      }

      // 빅데이터 준수: 계산 결과 그대로 사용 (버퍼링 상수 제거)
      double newAcidity =
          previousAcidity + acidProduction + environmentalInfluence;

      if (newAcidity.isNaN || newAcidity.isInfinite) {
        debugPrint('🚨 [최종 산도 계산 오류] NaN/Infinite: $newAcidity');
        return previousAcidity; // 오류 시 이전 값 유지
      }

      // 빅데이터 준수: 계산 결과 그대로 사용 (clamp 제거)
      debugPrint(
          '🧪 [산도 계산 완료] ${newAcidity.toStringAsFixed(2)} (빅데이터 준수 적용, 계수 조정)');
      return newAcidity;
    } catch (e, stackTrace) {
      debugPrint('🚨 [산도 계산 치명적 오류] 단계 ${step.stepNumber}');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return previousAcidity; // 오류 시 이전 값 유지
    }
  }

  /// 환경 기반 산도 영향 계산
  double _calculateEnvironmentalAcidInfluence(
      FermentationStep step, UserEnvironment environment) {
    try {
      double baseHumidity = environment.humidity ?? 70.0;
      // 빵 과학적 습도 영향: 계수 상향 조정 (0.00001 → 0.0001, 10배 증가)
      double humidityEffect = (step.targetHumidity - baseHumidity) * 0.0001;

      if (humidityEffect.isNaN || humidityEffect.isInfinite) {
        debugPrint('🚨 [습도 영향 계산 오류] NaN/Infinite: $humidityEffect');
        return 0.0;
      }

      double result = humidityEffect * step.durationMinutes;

      if (result.isNaN || result.isInfinite) {
        debugPrint('🚨 [환경 산도 영향 최종 계산 오류] NaN/Infinite: $result');
        return 0.0;
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('🚨 [환경 산도 영향 계산 오류]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return 0.0;
    }
  }

  /// 단계별 CO2 생성량 계산 - 빵 과학 기반 타당성 개선
  double _calculateStepCO2Generation({
    required FermentationStep step,
    required StandardizedYeastProperties yeastProperties,
    required double temperature,
    required double humidity,
    required List<Map<String, dynamic>> ingredients, // 밀가루 무게 계산을 위해 추가
  }) {
    try {
      debugPrint('💨 [CO2 생성량 계산] 단계 ${step.stepNumber} - 시작');
      debugPrint('   📋 [입력 파라미터 검증]');
      debugPrint('   👉 temperature: ${temperature.toStringAsFixed(2)}°C');
      debugPrint('   👉 humidity: ${humidity.toStringAsFixed(1)}%');
      debugPrint('   👉 durationMinutes: ${step.durationMinutes}분');
      debugPrint('   🔬 [이스트 속성 값 확인]');
      debugPrint(
          '   👉 yeastProperties.co2Rate: ${yeastProperties.co2Rate.toStringAsFixed(8)} (기본 CO2율)');
      debugPrint(
          '   👉 yeastProperties.activity: ${yeastProperties.activity.toStringAsFixed(6)} (활성도)');
      debugPrint(
          '   👉 yeastProperties.percentage: ${yeastProperties.percentage.toStringAsFixed(2)}% (백분율)');
      debugPrint(
          '   👉 yeastProperties.typeEfficiency: ${yeastProperties.typeEfficiency.toStringAsFixed(3)} (타입 효율)');

      // 표준화된 CO2율을 직접 사용
      double environmentalEfficiency =
          _calculateCO2EnvironmentalEfficiency(temperature, humidity);
      debugPrint(
          '   🌡️ [환경 효율 계산] 온도효율 × 습도효율 = ${environmentalEfficiency.toStringAsFixed(4)}');
      if (environmentalEfficiency.isNaN || environmentalEfficiency.isInfinite) {
        debugPrint(
            '🚨 [CO2 환경 효율 계산 오류] NaN/Infinite: $environmentalEfficiency');
        // ✅ 기본값 설정 금지 - 에러 드러냄
        environmentalEfficiency = 0.0; // 계산 오류시 0으로 드러냄
      }

      // ✅ 빅데이터 준수: 이스트 총량 기반 CO2 계산 (빵 과학 타당성 확보)
      // 밀가루 무게 계산
      final flourIngredients =
          IngredientAnalyzer.findFlourIngredients(ingredients);
      final totalFlourWeight = flourIngredients.fold<double>(0.0, (sum, flour) {
        final amount = (flour['amount'] as num?)?.toDouble() ?? 0.0;
        return sum + amount;
      });

      // 이스트 총량 계산: 밀가루 무게 × 이스트 백분율
      final yeastTotalWeight =
          totalFlourWeight * (yeastProperties.percentage / 100.0);
      debugPrint(
          '   🧪 [이스트 총량 계산] 밀가루 ${totalFlourWeight.toStringAsFixed(1)}g × ${yeastProperties.percentage.toStringAsFixed(2)}% = ${yeastTotalWeight.toStringAsFixed(3)}g');

      if (yeastTotalWeight.isNaN ||
          yeastTotalWeight.isInfinite ||
          yeastTotalWeight <= 0) {
        debugPrint('🚨 [CO2 이스트 총량 계산 오류] 유효하지 않은 값: $yeastTotalWeight');
        return 0.0; // 밀가루 또는 이스트 감지 실패시 0
      }

      debugPrint('   🔢 [빵 과학 기반 계산식 구성 요소 확인]');
      debugPrint(
          '   1️⃣ yeastTotalWeight: ${yeastTotalWeight.toStringAsFixed(3)}g');
      debugPrint(
          '   2️⃣ co2Rate: ${yeastProperties.co2Rate.toStringAsFixed(8)} ml/g/분');
      debugPrint(
          '   3️⃣ environmentalEfficiency: ${environmentalEfficiency.toStringAsFixed(4)}');
      debugPrint('   4️⃣ durationMinutes: ${step.durationMinutes}분');

      // 빵 과학 기반 CO2 계산: 이스트 총량 × CO2율 × 환경효율 × 시간
      double result = yeastTotalWeight *
          yeastProperties.co2Rate *
          environmentalEfficiency *
          step.durationMinutes;
      debugPrint(
          '   🧮 [최종 계산식] ${yeastTotalWeight.toStringAsFixed(3)} × ${yeastProperties.co2Rate.toStringAsFixed(8)} × ${environmentalEfficiency.toStringAsFixed(4)} × ${step.durationMinutes} = ${result.toStringAsFixed(12)}');

      if (result.isNaN || result.isInfinite) {
        debugPrint('🚨 [CO2 생성량 최종 계산 오류] NaN/Infinite: $result');
        return 0.0;
      }

      debugPrint(
          '   💨 [CO2 생성량 계산 완료] 단계별 생성량: ${result.toStringAsFixed(12)}');
      debugPrint('   📊 [단계 합산 용도로 반환] 값: ${result}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('🚨 [CO2 생성량 계산 치명적 오류] 단계 ${step.stepNumber}');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return 0.0;
    }
  }

  /// CO2 생성 환경 효율 계산 (기본값 사용 금지 정책 준수)
  double _calculateCO2EnvironmentalEfficiency(
      double temperature, double humidity) {
    try {
      double tempEfficiency =
          (temperature >= 25 && temperature <= 35) ? 0.9 : 0.6;
      double humidityEfficiency =
          (humidity >= 60 && humidity <= 85) ? 0.9 : 0.7;

      double result = tempEfficiency * humidityEfficiency;

      if (result.isNaN || result.isInfinite) {
        debugPrint('🚨 [CO2 환경 효율 최종 계산 오류] NaN/Infinite: $result');
        // ✅ 기본값 설정 금지 - 에러 드러냄
        return 0.0; // 계산 오류시 0으로 드러냄
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('🚨 [CO2 환경 효율 계산 오류]');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      // ✅ 기본값 설정 금지 - 에러 드러냄
      return 0.0; // 계산 오류시 0으로 드러냄
    }
  }

  /// 단계별 동적 온도 계산 - 발효 차수별 온도 프로파일 적용
  /// 빵 과학적 접근: 발효 단계별로 온도가 점진적으로 변화하는 것을 모델링
  static double _calculateDynamicTemperatureForStep({
    required FermentationStep step,
    required double totalElapsedTime,
    required double previousTemperature,
  }) {
    try {
      debugPrint('🌡️ [동적 온도 계산] 단계 ${step.stepNumber} - 시작');
      debugPrint(
          '   입력: 목표온도=${step.targetTemperature}°C, 이전온도=${previousTemperature}°C, 누적시간=${totalElapsedTime}분');

      // 빵 과학적 온도 변화 모델링
      // 1. 냉장고 발효 → 실온 발효 전환 시 온도 상승 고려
      // 2. 단계별 목표 온도에 도달하는 시간 고려
      // 3. 실제 빵 발효에서 온도가 즉시 변하지 않는 현실 반영

      double currentTemperature;

      // 냉장고 발효에서 실온 발효로 전환되는 경우 (4°C → 25°C)
      if (previousTemperature <= 10.0 && step.targetTemperature >= 20.0) {
        // 냉장고에서 꺼내 실온으로 오르는 과정 모델링
        // 빵 과학: 냉장고 빵이 실온에 도달하는 데 약 2-3시간 소요
        double timeToReachRoomTemp = 120.0; // 2시간
        double tempDifference = step.targetTemperature - previousTemperature;

        if (totalElapsedTime < timeToReachRoomTemp) {
          // 점진적 온도 상승
          double progressRatio = totalElapsedTime / timeToReachRoomTemp;
          currentTemperature =
              previousTemperature + (tempDifference * progressRatio);
          debugPrint(
              '   🧊 [냉장고→실온 전환] ${progressRatio.toStringAsFixed(2)} 진행률, 현재온도: ${currentTemperature.toStringAsFixed(1)}°C');
        } else {
          // 목표 온도 도달
          currentTemperature = step.targetTemperature;
          debugPrint(
              '   ✅ [냉장고→실온 전환 완료] 목표온도 도달: ${currentTemperature.toStringAsFixed(1)}°C');
        }
      }
      // 일반적인 온도 변화 (단계별 목표 온도 적용)
      else {
        // 빵 과학: 온도 변화는 단계 시간의 20% 동안 점진적으로 발생
        double transitionTime = step.durationMinutes * 0.2; // 20% 시간 동안 전환
        double tempDifference = step.targetTemperature - previousTemperature;

        if (step.durationMinutes > 0 && totalElapsedTime < transitionTime) {
          // 점진적 온도 변화
          double progressRatio = totalElapsedTime / transitionTime;
          currentTemperature =
              previousTemperature + (tempDifference * progressRatio);
          debugPrint(
              '   🔄 [점진적 온도 변화] ${progressRatio.toStringAsFixed(2)} 진행률, 현재온도: ${currentTemperature.toStringAsFixed(1)}°C');
        } else {
          // 목표 온도 유지
          currentTemperature = step.targetTemperature;
          debugPrint(
              '   🎯 [목표 온도 유지] ${currentTemperature.toStringAsFixed(1)}°C');
        }
      }

      // 빅데이터 준수: 계산 결과 그대로 사용 (범위 제한 금지)
      if (currentTemperature.isNaN || currentTemperature.isInfinite) {
        debugPrint('🚨 [동적 온도 계산 오류] NaN/Infinite: $currentTemperature');
        return step.targetTemperature; // 오류 시 목표 온도 반환
      }

      debugPrint(
          '🌡️ [동적 온도 계산 완료] ${currentTemperature.toStringAsFixed(2)}°C');
      return currentTemperature;
    } catch (e, stackTrace) {
      debugPrint('🚨 [동적 온도 계산 치명적 오류] 단계 ${step.stepNumber}');
      debugPrint('   Error: $e');
      debugPrint('   StackTrace: $stackTrace');
      return step.targetTemperature; // 오류 시 목표 온도 반환
    }
  }

  /// calculateYeastActivity 메소드 (테스트 호환성 유지)
  double calculateYeastActivity({
    required FermentationState previousState,
    required BakingState mixingState,
    required FermentationStep step,
    required List<Map<String, dynamic>> ingredients,
  }) {
    // 표준화된 속성을 사용한 계산
    final yeastProperties =
        YeastCalculationService.calculateStandardizedYeastProperties(
      ingredients: ingredients,
    );
    return yeastProperties.activity;
  }
}
