import 'dart:math' as math;

/// 고정 소수점 정밀도 계산을 위한 클래스
class FixedPoint {
  final int value; // 내부적으로 정수로 저장 (소수점 6자리까지)
  final int decimals;

  const FixedPoint(this.value, {this.decimals = 6});

  /// double에서 FixedPoint로 변환
  factory FixedPoint.fromDouble(double value, {int decimals = 6}) {
    final multiplier = math.pow(10, decimals).toInt();
    return FixedPoint((value * multiplier).round(), decimals: decimals);
  }

  /// int에서 FixedPoint로 변환
  factory FixedPoint.fromInt(int value, {int decimals = 6}) {
    final multiplier = math.pow(10, decimals).toInt();
    return FixedPoint(value * multiplier, decimals: decimals);
  }

  /// FixedPoint에서 double로 변환
  double toDouble() => value / math.pow(10, decimals);

  /// 두 FixedPoint의 합
  FixedPoint add(FixedPoint other) {
    if (decimals == other.decimals) {
      return FixedPoint(value + other.value, decimals: decimals);
    }
    // 다른 소수점 자릿수 처리
    final maxDecimals = math.max(decimals, other.decimals);
    final thisScaled = _scaleTo(maxDecimals);
    final otherScaled = other._scaleTo(maxDecimals);
    return FixedPoint(thisScaled + otherScaled, decimals: maxDecimals);
  }

  /// 두 FixedPoint의 차
  FixedPoint subtract(FixedPoint other) {
    if (decimals == other.decimals) {
      return FixedPoint(value - other.value, decimals: decimals);
    }
    final maxDecimals = math.max(decimals, other.decimals);
    final thisScaled = _scaleTo(maxDecimals);
    final otherScaled = other._scaleTo(maxDecimals);
    return FixedPoint(thisScaled - otherScaled, decimals: maxDecimals);
  }

  /// 두 FixedPoint의 곱
  FixedPoint multiply(FixedPoint other) {
    final result = value * other.value;
    final resultDecimals = decimals + other.decimals;
    return FixedPoint(result, decimals: resultDecimals).roundTo(decimals);
  }

  /// 두 FixedPoint의 나눗셈
  FixedPoint divide(FixedPoint other) {
    if (other.value == 0) throw Exception('Division by zero');
    final result = (value * math.pow(10, decimals).toInt()) ~/ other.value;
    return FixedPoint(result, decimals: decimals);
  }

  /// 지정된 소수점 자리로 반올림
  FixedPoint roundTo(int newDecimals) {
    if (newDecimals >= decimals) return this;

    final factor = math.pow(10, decimals - newDecimals).toInt();
    final rounded = (value + factor ~/ 2) ~/ factor;
    return FixedPoint(rounded, decimals: newDecimals);
  }

  /// 절대값
  FixedPoint abs() {
    return FixedPoint(value.abs(), decimals: decimals);
  }

  /// 소수점 자릿수를 맞추기 위한 스케일링
  int _scaleTo(int targetDecimals) {
    if (targetDecimals == decimals) return value;
    if (targetDecimals > decimals) {
      return value * math.pow(10, targetDecimals - decimals).toInt();
    } else {
      return value ~/ math.pow(10, decimals - targetDecimals).toInt();
    }
  }

  @override
  String toString() => toDouble().toString();

  @override
  bool operator ==(Object other) =>
      other is FixedPoint && value == other.value && decimals == other.decimals;

  @override
  int get hashCode => value.hashCode ^ decimals.hashCode;
}

/// 고정 소수점 기반의 고정밀도 계산기
class PrecisionCalculator {
  static const int DEFAULT_DECIMALS = 6;

  /// 두 수의 합 (고정밀도)
  static FixedPoint add(double a, double b, {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.add(fb);
  }

  /// 두 수의 차 (고정밀도)
  static FixedPoint subtract(double a, double b,
      {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.subtract(fb);
  }

  /// 두 수의 곱 (고정밀도)
  static FixedPoint multiply(double a, double b,
      {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.multiply(fb);
  }

  /// 두 수의 나눗셈 (고정밀도)
  static FixedPoint divide(double a, double b,
      {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.divide(fb);
  }

  /// 퍼센트 계산 (고정밀도)
  static FixedPoint percentage(double value, double percent,
      {int decimals = DEFAULT_DECIMALS}) {
    final fValue = FixedPoint.fromDouble(value, decimals: decimals);
    final fPercent = FixedPoint.fromDouble(percent / 100.0, decimals: decimals);
    return fValue.multiply(fPercent);
  }

  /// 비율 계산 (고정밀도)
  static FixedPoint ratio(double value, double ratio,
      {int decimals = DEFAULT_DECIMALS}) {
    final fValue = FixedPoint.fromDouble(value, decimals: decimals);
    final fRatio = FixedPoint.fromDouble(ratio, decimals: decimals);
    return fValue.multiply(fRatio);
  }

  /// 제곱근 계산 (고정밀도)
  static FixedPoint sqrt(double value, {int decimals = DEFAULT_DECIMALS}) {
    final result = math.sqrt(value);
    return FixedPoint.fromDouble(result, decimals: decimals);
  }

  /// 거듭제곱 계산 (고정밀도)
  static FixedPoint pow(double base, double exponent,
      {int decimals = DEFAULT_DECIMALS}) {
    final result = math.pow(base, exponent);
    return FixedPoint.fromDouble(result.toDouble(), decimals: decimals);
  }

  /// 반올림 (고정밀도)
  static FixedPoint round(double value, int decimals) {
    final f = FixedPoint.fromDouble(value, decimals: DEFAULT_DECIMALS);
    return f.roundTo(decimals);
  }

  /// 절대값 (고정밀도)
  static FixedPoint abs(double value, {int decimals = DEFAULT_DECIMALS}) {
    final f = FixedPoint.fromDouble(value, decimals: decimals);
    return FixedPoint(f.value.abs(), decimals: decimals);
  }

  /// 최대값 (고정밀도)
  static FixedPoint max(double a, double b, {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.value > fb.value ? fa : fb;
  }

  /// 최소값 (고정밀도)
  static FixedPoint min(double a, double b, {int decimals = DEFAULT_DECIMALS}) {
    final fa = FixedPoint.fromDouble(a, decimals: decimals);
    final fb = FixedPoint.fromDouble(b, decimals: decimals);
    return fa.value < fb.value ? fa : fb;
  }
}

/// 베이킹 전용 고정밀도 계산기
class BakingCalculator {
  static const int BAKING_DECIMALS = 3; // 베이킹에서는 3자리 소수점까지 충분

  /// 재료 비율 계산 (예: 밀가루 100g 기준 물의 양)
  static FixedPoint calculateRatio(double baseAmount, double ratio) {
    return PrecisionCalculator.multiply(baseAmount, ratio,
        decimals: BAKING_DECIMALS);
  }

  /// 수분 함량 계산 (hydration)
  static FixedPoint calculateHydration(double flourAmount, double waterAmount) {
    if (flourAmount <= 0) return FixedPoint.fromInt(0);
    final hydration = (waterAmount / flourAmount) * 100.0;
    return PrecisionCalculator.round(hydration, 1); // 소수점 1자리
  }

  /// 총 중량 계산
  static FixedPoint calculateTotalWeight(List<double> amounts) {
    if (amounts.isEmpty) return FixedPoint.fromInt(0);

    var total = FixedPoint.fromInt(0);
    for (final amount in amounts) {
      final fAmount = FixedPoint.fromDouble(amount, decimals: BAKING_DECIMALS);
      total = total.add(fAmount);
    }
    return total;
  }

  /// 재료 스케일링 (원본 레시피의 양을 기준으로 목표 양 계산)
  static FixedPoint scaleIngredient(
      double originalAmount, double originalTotal, double targetTotal) {
    if (originalTotal <= 0) return FixedPoint.fromDouble(originalAmount);

    final ratio = targetTotal / originalTotal;
    return PrecisionCalculator.multiply(originalAmount, ratio,
        decimals: BAKING_DECIMALS);
  }

  /// 온도 변환 (섭씨 ↔ 화씨)
  static FixedPoint celsiusToFahrenheit(double celsius) {
    // °F = °C × 9/5 + 32
    final fahrenheit = celsius * 9.0 / 5.0 + 32.0;
    return PrecisionCalculator.round(fahrenheit, 1);
  }

  static FixedPoint fahrenheitToCelsius(double fahrenheit) {
    // °C = (°F - 32) × 5/9
    final celsius = (fahrenheit - 32.0) * 5.0 / 9.0;
    return PrecisionCalculator.round(celsius, 1);
  }

  /// 시간 변환 (분 ↔ 시간)
  static FixedPoint minutesToHours(double minutes) {
    return PrecisionCalculator.divide(minutes, 60.0, decimals: 2);
  }

  static FixedPoint hoursToMinutes(double hours) {
    return PrecisionCalculator.multiply(hours, 60.0, decimals: 0);
  }

  /// 부피 ↔ 무게 변환 (밀도 고려)
  static FixedPoint volumeToWeight(double volume, double density) {
    return PrecisionCalculator.multiply(volume, density,
        decimals: BAKING_DECIMALS);
  }

  static FixedPoint weightToVolume(double weight, double density) {
    if (density <= 0) throw Exception('Density must be greater than 0');
    return PrecisionCalculator.divide(weight, density,
        decimals: BAKING_DECIMALS);
  }

  /// 효모량 계산 (밀가루량의 퍼센트)
  static FixedPoint calculateYeastAmount(
      double flourAmount, double yeastPercent) {
    return PrecisionCalculator.percentage(flourAmount, yeastPercent,
        decimals: BAKING_DECIMALS);
  }

  /// 소금량 계산 (밀가루량의 퍼센트)
  static FixedPoint calculateSaltAmount(
      double flourAmount, double saltPercent) {
    return PrecisionCalculator.percentage(flourAmount, saltPercent,
        decimals: BAKING_DECIMALS);
  }

  /// 팽창 계수 계산 (발효 전후 부피 차이)
  static FixedPoint calculateExpansionFactor(
      double originalVolume, double finalVolume) {
    if (originalVolume <= 0) return FixedPoint.fromInt(1);
    return PrecisionCalculator.divide(finalVolume, originalVolume, decimals: 2);
  }

  /// 구이 시간 계산 (온도와 두께 고려)
  static FixedPoint calculateBakingTime(
      double thickness, double temperature, double baseTime) {
    // 간단한 경험 공식: 두께에 비례, 온도에 반비례
    const double referenceTemp = 200.0; // 기준 온도 (°C)
    const double referenceThickness = 2.0; // 기준 두께 (cm)

    final tempFactor = referenceTemp / temperature;
    final thicknessFactor = thickness / referenceThickness;
    final adjustedTime = baseTime * tempFactor * thicknessFactor;

    return PrecisionCalculator.round(adjustedTime, 0); // 분 단위로 반올림
  }

  /// 영양성분 계산 (단순 합산)
  static Map<String, FixedPoint> calculateNutrition(
      List<Map<String, double>> ingredientsNutrition, List<double> amounts) {
    if (ingredientsNutrition.length != amounts.length) {
      throw Exception('Ingredients and amounts must have the same length');
    }

    final totalNutrition = <String, FixedPoint>{};

    for (int i = 0; i < ingredientsNutrition.length; i++) {
      final nutrition = ingredientsNutrition[i];
      final amount = amounts[i];

      for (final entry in nutrition.entries) {
        final nutrient = entry.key;
        final valuePer100g = entry.value;

        // 100g당 영양성분을 실제 양에 맞게 조정
        final actualValue = (valuePer100g * amount) / 100.0;
        final fValue = FixedPoint.fromDouble(actualValue, decimals: 1);

        totalNutrition[nutrient] =
            (totalNutrition[nutrient] ?? FixedPoint.fromInt(0)).add(fValue);
      }
    }

    return totalNutrition;
  }

  /// 정확도 검증 (계산 결과가 허용 범위 내인지 확인)
  static bool validatePrecision(
      FixedPoint calculated, double expected, double tolerancePercent) {
    final expectedFixed =
        FixedPoint.fromDouble(expected, decimals: BAKING_DECIMALS);
    final difference = calculated.subtract(expectedFixed).abs();
    final tolerance = PrecisionCalculator.percentage(expected, tolerancePercent,
        decimals: BAKING_DECIMALS);

    return difference.value <= tolerance.value;
  }

  /// 안전한 나눗셈 (0으로 나누기 방지)
  static FixedPoint safeDivide(double numerator, double denominator,
      {double defaultValue = 0.0}) {
    if (denominator == 0) {
      return FixedPoint.fromDouble(defaultValue, decimals: BAKING_DECIMALS);
    }
    return PrecisionCalculator.divide(numerator, denominator,
        decimals: BAKING_DECIMALS);
  }

  /// 범위 제한 (계산 결과를 안전한 범위로 제한)
  static FixedPoint clamp(double value, double min, double max) {
    final fValue = FixedPoint.fromDouble(value, decimals: BAKING_DECIMALS);
    final fMin = FixedPoint.fromDouble(min, decimals: BAKING_DECIMALS);
    final fMax = FixedPoint.fromDouble(max, decimals: BAKING_DECIMALS);

    if (fValue.value < fMin.value) return fMin;
    if (fValue.value > fMax.value) return fMax;
    return fValue;
  }
}

/// 계산 결과 검증 및 로깅을 위한 클래스
class CalculationValidator {
  final List<CalculationStep> _steps = [];

  /// 계산 단계 기록
  void logStep(String operation, List<double> inputs, FixedPoint result,
      {String? notes}) {
    _steps.add(CalculationStep(
      operation: operation,
      inputs: inputs,
      result: result,
      timestamp: DateTime.now(),
      notes: notes,
    ));
  }

  /// 계산 과정 검증
  bool validateSteps({double tolerancePercent = 1.0}) {
    for (final step in _steps) {
      final expected = _calculateExpected(step);
      if (!BakingCalculator.validatePrecision(
          step.result, expected, tolerancePercent)) {
        return false;
      }
    }
    return true;
  }

  /// 예상 결과 계산 (단순 검증용)
  double _calculateExpected(CalculationStep step) {
    switch (step.operation) {
      case 'add':
        return step.inputs.reduce((a, b) => a + b);
      case 'multiply':
        return step.inputs.reduce((a, b) => a * b);
      case 'divide':
        return step.inputs[0] / step.inputs[1];
      case 'percentage':
        return step.inputs[0] * step.inputs[1] / 100.0;
      default:
        return step.result.toDouble();
    }
  }

  /// 계산 과정 리포트 생성
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== 계산 검증 리포트 ===');
    buffer.writeln('총 계산 단계: ${_steps.length}');
    buffer.writeln('');

    for (int i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      buffer.writeln('단계 ${i + 1}: ${step.operation}');
      buffer.writeln('  입력: ${step.inputs}');
      buffer.writeln('  결과: ${step.result.toDouble()}');
      if (step.notes != null) {
        buffer.writeln('  비고: ${step.notes}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// 계산 단계 초기화
  void clear() {
    _steps.clear();
  }

  List<CalculationStep> get steps => List.unmodifiable(_steps);
}

/// 계산 단계 정보
class CalculationStep {
  final String operation;
  final List<double> inputs;
  final FixedPoint result;
  final DateTime timestamp;
  final String? notes;

  const CalculationStep({
    required this.operation,
    required this.inputs,
    required this.result,
    required this.timestamp,
    this.notes,
  });
}
