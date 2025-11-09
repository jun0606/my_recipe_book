/// 점도 계산 중앙화 엔진
/// 믹싱 속도, 시간, 온도, 재료 상태에 따른 점도 변동 예측

import 'dart:math';
import '../core/types/environment_types.dart';
import '../core/types/calculation_types.dart';
import '../core/utils/safe_value_utils.dart';
import '../core/constants/bread_constants.dart';
import 'environment_defaults_calculator.dart';

class ViscosityCalculationResult {
  final double viscosity;
  final double change;
  final String factors;
  final Map<String, dynamic> details;

  const ViscosityCalculationResult({
    required this.viscosity,
    required this.change,
    required this.factors,
    required this.details,
  });
}

class ViscosityCalculator implements BakingCalculator {
  /// 싱글톤 패턴
  static final ViscosityCalculator _instance = ViscosityCalculator._internal();
  factory ViscosityCalculator() => _instance;
  ViscosityCalculator._internal();

  /// 표준화된 BakingCalculator 인터페이스 구현
  @override
  CalculationResult calculate(CalculationInput input) {
    try {
      final startTime = DateTime.now();

      // 기존 계산 메소드 호출
      final viscosity = calculateViscosity(
        stepIndex: input.stepIndex,
        speed: input.mixingStep.speed,
        duration: input.mixingStep.durationMinutes.toInt(),
        currentViscosity: input.currentState.viscosity,
        temperature: input.currentState.temperature,
        moistureAbsorption: input.currentState.moistureAbsorption,
        environment: input.environment,
      );

      // BakingState에 점도 값만 업데이트
      final newState = input.currentState.copyWith(
        viscosity: viscosity,
      );

      // 표준 CalculationResult로 변환
      return CalculationResult(
        data: {
          'viscosity': viscosity,
          'temperature': input.currentState.temperature, // 온도는 변경하지 않음
          'glutenFormation': input.currentState.glutenFormation, // 글루텐은 변경하지 않음
          'moistureAbsorption':
              input.currentState.moistureAbsorption, // 수분은 변경하지 않음
          'calculationMethod': 'centralized_engine',
        },
        success: true,
        calculatedAt: startTime,
      );
    } catch (e) {
      print('❌ [점도 계산 엔진] 표준 인터페이스 계산 실패: $e');
      return CalculationResult(
        data: {
          'viscosity': input.currentState.viscosity, // 기존 값 유지
          'temperature': input.currentState.temperature,
          'glutenFormation': input.currentState.glutenFormation,
          'moistureAbsorption': input.currentState.moistureAbsorption,
          'error': e.toString(),
        },
        success: false,
        error: e.toString(),
        calculatedAt: DateTime.now(),
      );
    }
  }

  /// 점도 계산 메인 함수
  static double calculateViscosity({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentViscosity,
    required double temperature,
    required double moistureAbsorption,
    required UserEnvironment? environment,
  }) {
    final result = ViscosityCalculator()._calculateViscosityChange(
      stepIndex: stepIndex,
      speed: speed,
      duration: duration,
      currentViscosity: currentViscosity,
      temperature: temperature,
      moistureAbsorption: moistureAbsorption,
      environment: environment,
    );

    return result.viscosity;
  }

  /// 점도 변화 계산 (빵 제조 과학 기반)
  ViscosityCalculationResult _calculateViscosityChange({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentViscosity,
    required double temperature,
    required double moistureAbsorption,
    required UserEnvironment? environment,
  }) {
    // 1. 기본 점도 계산 (재료 상태 기반)
    double baseViscosity = _calculateBaseViscosity(
      currentViscosity: currentViscosity,
      moistureAbsorption: moistureAbsorption,
      temperature: temperature,
    );

    // 2. 단계별 점도 변동
    double stepFactor = _calculateStepFactor(stepIndex, speed);

    // 3. 속도별 점도 변동
    double speedFactor = _calculateSpeedFactor(speed, duration);

    // 4. 시간 기여도
    double timeFactor = _calculateTimeFactor(duration);

    // 5. 환경 영향
    double environmentFactor = _calculateEnvironmentFactor(environment);

    // 6. 온도 영향
    double temperatureFactor = _calculateTemperatureFactor(temperature);

    // 7. 점도 포화 효과 (너무 높은 점도는 제한)
    double saturationFactor = _calculateSaturationFactor(currentViscosity);

    // 8. 최종 점도 계산
    double combinedFactor = stepFactor *
        speedFactor *
        timeFactor *
        environmentFactor *
        temperatureFactor *
        saturationFactor;

    // 9. 점도 변화량 산출 (부드러운 전환 유지)
    double viscosityChange =
        (baseViscosity * combinedFactor - currentViscosity) * 0.25;

    // 10. 최종 점도
    double finalViscosity = currentViscosity + viscosityChange;

    return ViscosityCalculationResult(
      viscosity: finalViscosity.clamp(0.5, 5.0), // 현실적 범위 제한
      change: viscosityChange,
      factors: 'step×speed×time×env×temp×saturation',
      details: {
        'stepFactor': stepFactor,
        'speedFactor': speedFactor,
        'timeFactor': timeFactor,
        'environmentFactor': environmentFactor,
        'temperatureFactor': temperatureFactor,
        'saturationFactor': saturationFactor,
        'combinedFactor': combinedFactor,
        'baseViscosity': baseViscosity,
      },
    );
  }

  double _calculateBaseViscosity({
    required double currentViscosity,
    required double moistureAbsorption,
    required double temperature,
  }) {
    // 수분 함량에 따른 기본 점도 결정
    if (moistureAbsorption >= 75) {
      return 1.0; // 높은 수분: 낮은 점도
    } else if (moistureAbsorption >= 65) {
      return 1.5; // 적정 수분: 중간 점도
    } else {
      return 2.0; // 낮은 수분: 높은 점도
    }
  }

  double _calculateStepFactor(int stepIndex, String speed) {
    // ✅ 수정: mixing 시스템에서 호출되므로 stepIndex 기반으로 유지
    // 실제 계산 로직은 유지하되, 경고는 제거 (의도된 사용)

    // 임시: 기존 값 유지하여 호환성 보장 (곧 제거 예정)
    switch (stepIndex) {
      case 0:
        return 1.05; // 1단계: 혼합 시작으로 약간 상승
      case 1:
        return 0.85; // 2단계: 글루텐 형성으로 감소
      case 2:
        return 0.80; // 3단계: 숙성 단계로 더 감소
      case 3:
        return 0.90; // 4단계: 완성 단계
      default:
        return 0.95; // 추가 단계
    }
  }

  double _calculateSpeedFactor(String speed, int duration) {
    switch (speed) {
      case '저속':
        return duration >= 8 ? 1.15 : 0.95; // 저속 장시간: 점도 상승 증가
      case '중속':
        return 1.00; // 기준 속도
      case '고속':
        return duration <= 3 ? 0.70 : 0.85; // 고속: 유동성 증가로 점도 감소
      default:
        return 1.00;
    }
  }

  double _calculateTimeFactor(int duration) {
    if (duration < 3) return 0.8;
    if (duration >= 3 && duration <= 8) return 1.0;
    if (duration <= 12) return 1.1;
    return 0.9;
  }

  double _calculateEnvironmentFactor(UserEnvironment? environment) {
    if (environment == null) return 1.0;

    double factor = 1.0;

    // 습도 영향 (높은 습도일수록 점도 감소)
    final humidity = environment.humidity ?? 60.0;
    if (humidity >= 70) factor *= 0.95;
    if (humidity <= 40) factor *= 1.05;

    // 온도 영향 (높은 온도일수록 점도 감소)
    final temp = environment.temperature ?? 25.0;
    if (temp >= 28) factor *= 0.9;
    if (temp <= 18) factor *= 1.1;

    return factor;
  }

  double _calculateTemperatureFactor(double temperature) {
    if (temperature >= 25 && temperature <= 26) return 1.0;
    if (temperature >= 24 && temperature <= 27) return 0.97;
    if (temperature >= 22 && temperature <= 23) return 1.02;
    if (temperature >= 20 && temperature <= 21) return 1.05;
    if (temperature >= 27 && temperature <= 30) return 0.95;
    return 0.92; // 매우 높거나 낮은 온도
  }

  double _calculateSaturationFactor(double currentViscosity) {
    if (currentViscosity > 3.0) return 0.8; // 높은 점도는 추가 상승 제한
    if (currentViscosity < 0.8) return 1.1; // 낮은 점도는 더 유연하게 상승
    return 1.0;
  }
}
