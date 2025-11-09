// 믹싱 분석 계산 헬퍼
// 중복코드 제거 및 공통화된 계산 로직 제공

import 'package:flutter/material.dart';
import '../constants/bread_constants.dart';

/// 믹싱 분석 계산 공통 헬퍼 클래스
/// 중복코드를 제거하고 재사용 가능한 계산 로직을 제공
class MixingCalculationHelper {
  /// 통합 효율성 계산 메소드
  /// 기존 _calculateStepEfficiency 계열 메소드들을 통합
  static double calculateUnifiedEfficiency(
    String speed,
    int duration,
    double rpm, {
    String type = 'general',
    int? stepIndex,
  }) {
    double efficiency = 1.0;

    // 기본 RPM 기반 조정
    if (rpm < BreadConstants.lowSpeedRPM || rpm > BreadConstants.highSpeedRPM) {
      efficiency *= 0.8;
    }

    // 최대 믹싱 시간 초과 조정
    if (duration > BreadConstants.maximumMixingTime) {
      efficiency *= 0.9;
    }

    // 고속 + 짧은 시간 조정
    if (speed == '고속' && duration < BreadConstants.minimumMixingTime) {
      efficiency *= 0.7;
    }

    // 타입별 추가 조정
    switch (type) {
      case 'moisture':
        // 수분 흡수율용 특별 조정
        final moistureBase = _calculateBaseMoistureMultiplier(stepIndex ?? 0);
        efficiency *= moistureBase;
        break;
      case 'temperature':
        // 온도 변화용 조정
        efficiency *= _calculateTemperatureEfficiency(speed, duration);
        break;
      case 'viscosity':
        // 점도 변화용 조정
        efficiency *= _calculateViscosityEfficiency(speed, duration);
        break;
      default:
        // 일반 효율성 (기존 로직 유지)
        break;
    }

    return efficiency.clamp(0.1, 1.0); // 안전 범위 제한
  }

  /// 단계별 수분 승수 계산 헬퍼
  static double _calculateBaseMoistureMultiplier(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return 0.8; // 초기 혼합
      case 1:
        return 1.0; // 본격 형성
      case 2:
        return 0.9; // 마무리 안정화
      default:
        return 0.85 + (stepIndex * 0.02);
    }
  }

  /// 온도 효율성 계산
  static double _calculateTemperatureEfficiency(String speed, int duration) {
    final baseEfficiency = 1.0;

    // 마찰열 발생량 기반 조정
    final heatFactor = _calculateHeatFactor(speed);
    return baseEfficiency * heatFactor;
  }

  /// 점도 효율성 계산
  static double _calculateViscosityEfficiency(String speed, int duration) {
    // 기본 점도 변화 패턴
    switch (speed) {
      case '저속':
        return 0.9;
      case '중속':
        return 1.0;
      case '고속':
        return 1.1;
      default:
        return 1.0;
    }
  }

  /// 마찰열 계수 계산
  static double _calculateHeatFactor(String speed) {
    switch (speed) {
      case '저속':
        return 0.7;
      case '중속':
        return 1.0;
      case '고속':
        return 1.5;
      default:
        return 1.0;
    }
  }

  /// 통합 메트릭 색상 계산
  /// 기존 getTemperatureColor, getScoreColor 등 색상 계산 메소드들 통합
  static Color getUnifiedMetricColor(String metricType, double value,
      {double? optimalMin, double? optimalMax, double? currentTemp}) {
    switch (metricType) {
      case 'gluten':
        return _getGlutenColor(value);
      case 'moisture':
        return _getMoistureColor(value);
      case 'viscosity':
        return _getViscosityColor(value);
      case 'temperature':
        return _getTemperatureColor(value, optimalMin, optimalMax);
      case 'score':
        return _getScoreColor(value);
      default:
        return Colors.grey;
    }
  }

  /// 글루텐 형성도 색상 계산
  static Color _getGlutenColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.5) return Colors.lightGreen;
    if (value >= 0.3) return Colors.orange;
    return Colors.red;
  }

  /// 수분 흡수율 색상 계산
  static Color _getMoistureColor(double value) {
    if (value >= 65 && value <= 80) return Colors.green;
    if (value >= 60 && value <= 85) return Colors.orange;
    return Colors.red;
  }

  /// 점도 색상 계산
  static Color _getViscosityColor(double value) {
    if (value >= 1.5 && value <= 2.0) return Colors.green;
    if (value >= 1.0 && value <= 2.5) return Colors.orange;
    return Colors.red;
  }

  /// 온도 색상 계산
  static Color _getTemperatureColor(
      double value, double? optimalMin, double? optimalMax) {
    try {
      final min = optimalMin ?? 20.0;
      final max = optimalMax ?? 26.0;
      final goodMin = min - 3.0;
      final goodMax = max + 3.0;

      if (value >= min && value <= max) return Colors.green;
      if (value >= goodMin && value <= goodMax) return Colors.orange;
      return Colors.red;
    } catch (e) {
      return Colors.grey.shade600;
    }
  }

  /// 점수 색상 계산
  static Color _getScoreColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.lightGreen;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }

  /// 안전 값 보장 헬퍼
  static double ensureSafeValue(double value,
      {double min = 0.0, double max = double.maxFinite}) {
    if (value.isNaN || value.isInfinite) {
      return (min + max) / 2; // 평균값으로 폴백
    }
    return value.clamp(min, max);
  }

  /// 계산 결과 검증 헬퍼
  static bool isValidCalculation(double value) {
    return !value.isNaN && !value.isInfinite && value >= 0;
  }

  /// 빵 제조 과학적 단계 효율 계산
  /// 기존 _calculateStepEfficiencyDirectlyForMoisture 로직 재사용
  static double calculateBakingScienceEfficiency(int stepIndex, int duration) {
    double baseEfficiency = 1.0;

    // 빵 제조 과학적 단계별 효율 패턴
    switch (stepIndex) {
      case 0:
        baseEfficiency = 0.8; // 초기 혼합
        break;
      case 1:
        baseEfficiency = 1.0; // 글루텐 형성
        break;
      case 2:
        baseEfficiency = 0.9; // 마무리
        break;
      default:
        baseEfficiency = duration >= 5 ? 1.0 : 0.85;
    }

    // 시간 기반 추가 조정
    if (duration < 3) {
      baseEfficiency *= 0.95; // 너무 짧음
    } else if (duration > 8) {
      baseEfficiency *= 1.05; // 충분한 시간
    }

    return ensureSafeValue(baseEfficiency, min: 0.5, max: 1.5);
  }
}
