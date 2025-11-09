/// 안전한 값 처리 유틸리티
/// 파싱 실패 및 NaN 방지를 위한 표준화된 유틸리티 함수들

class SafeValueUtils {
  /// 안전한 double 값 반환 (NaN/무한대 방지)
  static double safeDouble(double? value, {double defaultValue = 0.0}) {
    if (value == null || value.isNaN || value.isInfinite) {
      return defaultValue;
    }
    return value;
  }

  /// 파싱 실패 시 안전한 기본값 반환 (거짓 정보 방지)
  static double safeParseResult(double? result) {
    return safeDouble(result, defaultValue: 0.0);
  }

  /// 수분 흡수율 계산 결과 안전하게 반환
  /// ✅ 컨셉 준수: clamp 제한 완전 제거, 순수 계산 값 유지
  static double safeMoistureResult(double? moisture) {
    final safeValue = safeDouble(moisture, defaultValue: 0.0);

    // ✅ clamp 제한 완전 제거 - 실제 빵 제조 값 유지
    // 실제 빵 제조에서는 100% 초과 값도 의미가 있을 수 있음
    return safeValue;
  }

  /// 글루텐 형성도 계산 결과 안전하게 반환
  /// ✅ 컨셉 준수: clamp 제한 완전 제거, 순수 계산 값 유지
  static double safeGlutenResult(double? gluten) {
    final safeValue = safeDouble(gluten, defaultValue: 0.0);

    // ✅ clamp 제한 완전 제거 - 실제 빵 제조 값 유지
    // 실제 빵 제조에서는 100% 초과 값도 의미가 있을 수 있음
    return safeValue;
  }

  /// 온도 계산 결과 안전하게 반환
  /// ✅ 컨셉 준수: clamp 제한 완전 제거, 순수 계산 값 유지
  static double safeTemperatureResult(double? temperature) {
    final safeValue = safeDouble(temperature, defaultValue: 0.0);

    // ✅ clamp 제한 완전 제거 - 실제 빵 제조 값 유지
    // 실제 빵 제조에서는 다양한 온도 조건이 가능
    return safeValue;
  }

  /// 점도 계산 결과 안전하게 반환
  /// ✅ 컨셉 준수: clamp 제한 완전 제거, 순수 계산 값 유지
  static double safeViscosityResult(double? viscosity) {
    final safeValue = safeDouble(viscosity, defaultValue: 0.0);

    // ✅ clamp 제한 완전 제거 - 실제 빵 제조 값 유지
    // 실제 빵 제조에서는 다양한 점도 조건이 가능
    return safeValue;
  }

  /// 계산 상태 판별
  static CalculationStatus getCalculationStatus(double value) {
    if (value == 0.0) {
      return CalculationStatus.dataMissing;
    }
    return CalculationStatus.success;
  }
}

/// 계산 상태 enum
enum CalculationStatus {
  success, // ✅ 계산 성공
  partialSuccess, // ⚠️ 일부 계산 성공
  dataMissing, // ❌ 데이터 부족
  calculationFailed, // ❌ 계산 실패
}

/// UI 표시용 포맷터
class SafeValueFormatter {
  /// 수분 흡수율 표시 포맷
  static String formatMoisture(double moisture) {
    if (moisture == 0.0) {
      return '데이터 준비 중';
    }
    return '${moisture.toStringAsFixed(1)}%';
  }

  /// 글루텐 형성도 표시 포맷
  static String formatGluten(double gluten) {
    if (gluten == 0.0) {
      return '데이터 준비 중';
    }
    return '${(gluten * 100).toStringAsFixed(0)}%';
  }

  /// 온도 표시 포맷
  static String formatTemperature(double temperature) {
    if (temperature == 0.0) {
      return '데이터 준비 중';
    }
    return '${temperature.toStringAsFixed(1)}°C';
  }

  /// 점도 표시 포맷
  static String formatViscosity(double viscosity) {
    if (viscosity == 0.0) {
      return '데이터 준비 중';
    }
    return viscosity.toStringAsFixed(1);
  }
}
