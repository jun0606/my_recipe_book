import 'dart:math' as math;
import '../models/environmental_conditions.dart';
import '../models/enhanced_recipe.dart';
import 'ingredient_analyzer.dart';

/// 환경 및 지역 변수 보정 공식 엔진
/// Phase 2 Task 4: 과학적 보정 공식 구현
class EnvironmentCorrectionEngine {
  /// 발효 속도 온도 보정 공식
  /// 공식: 2^((실제 온도 - 25) / 10)
  static double calculateFermentationSpeedCorrection(double actualTemperature) {
    const double baseTemperature = 25.0; // 기준 온도 25°C
    const double temperatureSensitivity = 10.0; // 온도 민감도

    double exponent =
        (actualTemperature - baseTemperature) / temperatureSensitivity;
    return math.pow(2, exponent).toDouble();
  }

  /// 습도 보정 공식
  /// 공식: 1 + ((실제 습도% - 65%) × 0.005)
  static double calculateHumidityCorrection(double actualHumidity) {
    const double baseHumidity = 65.0; // 기준 습도 65%
    const double humiditySensitivity = 0.005; // 습도 민감도

    return 1.0 + ((actualHumidity - baseHumidity) * humiditySensitivity);
  }

  /// 고도 보정 공식
  /// 공식: 1 + ((현재 고도(m) / 1000) × 0.02)
  static double calculateAltitudeCorrection(double altitude) {
    const double altitudeSensitivity = 0.02; // 1000m당 2% 보정

    return 1.0 + ((altitude / 1000.0) * altitudeSensitivity);
  }

  /// 통합 환경 보정 계수 계산
  static EnvironmentCorrectionResult calculateIntegratedCorrection(
    EnvironmentalConditions conditions,
  ) {
    // 개별 보정 계수 계산
    final temperatureCorrection =
        calculateFermentationSpeedCorrection(conditions.temperature);
    final humidityCorrection = calculateHumidityCorrection(conditions.humidity);
    final altitudeCorrection = calculateAltitudeCorrection(conditions.altitude);

    // 통합 보정 계수 (곱셈 적용)
    final integratedCorrection =
        temperatureCorrection * humidityCorrection * altitudeCorrection;

    // 계절별 추가 보정
    final seasonalCorrection = _calculateSeasonalCorrection(conditions.season);
    final finalCorrection = integratedCorrection * seasonalCorrection;

    return EnvironmentCorrectionResult(
      temperatureCorrection: temperatureCorrection,
      humidityCorrection: humidityCorrection,
      altitudeCorrection: altitudeCorrection,
      seasonalCorrection: seasonalCorrection,
      integratedCorrection: finalCorrection,
      conditions: conditions,
    );
  }

  /// 발효 시간 보정 적용
  static int applyFermentationTimeCorrection(
    int baseFermentationTime, // 분 단위
    EnvironmentCorrectionResult correction,
  ) {
    // 발효 시간은 온도 보정의 역수 적용 (온도가 높으면 시간 단축)
    double correctedTime =
        baseFermentationTime / correction.temperatureCorrection;

    // 습도와 고도 보정 적용
    correctedTime *= correction.humidityCorrection;
    correctedTime *= correction.altitudeCorrection;
    correctedTime *= correction.seasonalCorrection;

    return correctedTime.round().clamp(30, 1440); // 최소 30분, 최대 24시간
  }

  /// 굽기 온도 보정 적용
  static int applyBakingTemperatureCorrection(
    int baseTemperature, // 섭씨
    EnvironmentCorrectionResult correction,
  ) {
    double correctedTemp = baseTemperature.toDouble();

    // 고도가 높을수록 온도를 높여야 함
    if (correction.conditions.altitude > 500) {
      correctedTemp +=
          (correction.conditions.altitude / 1000) * 15; // 1000m당 15°C 증가
    }

    // 습도가 높을수록 온도를 약간 높여야 함
    if (correction.conditions.humidity > 70) {
      correctedTemp +=
          (correction.conditions.humidity - 70) * 0.2; // 1%당 0.2°C 증가
    }

    return correctedTemp.round().clamp(150, 300); // 최소 150°C, 최대 300°C
  }

  /// 재료량 보정 적용
  static Map<String, double> applyIngredientCorrection(
    Map<String, double> baseIngredients,
    EnvironmentCorrectionResult correction,
  ) {
    final correctedIngredients = <String, double>{};

    for (final entry in baseIngredients.entries) {
      final ingredientName = entry.key;
      final baseAmount = entry.value;
      double correctedAmount = baseAmount;

      // 재료별 보정 적용
      if (IngredientAnalyzer.isFlour(ingredientName)) {
        // 밀가루: 습도가 높으면 증가, 고도가 높으면 증가
        correctedAmount *= correction.humidityCorrection;
        correctedAmount *= correction.altitudeCorrection;
      } else if (_isLiquid(ingredientName)) {
        // 액체: 습도가 낮으면 증가, 고도가 높으면 증가
        correctedAmount *= (2.0 - correction.humidityCorrection); // 역보정
        correctedAmount *= correction.altitudeCorrection;
      } else if (_isLeavening(ingredientName)) {
        // 팽창제: 고도가 높으면 감소, 온도가 높으면 감소
        correctedAmount /= correction.altitudeCorrection;
        correctedAmount /=
            math.sqrt(correction.temperatureCorrection); // 제곱근 적용으로 완화
      } else if (_isSugar(ingredientName)) {
        // 설탕: 습도 영향 최소화
        correctedAmount *= math.sqrt(correction.humidityCorrection);
      } else if (_isFat(ingredientName)) {
        // 지방: 온도 영향 고려
        correctedAmount *=
            (2.0 - correction.temperatureCorrection); // 온도가 높으면 약간 감소
      }

      correctedIngredients[ingredientName] = correctedAmount;
    }

    return correctedIngredients;
  }

  /// 환경 조건 진단 및 권장사항 생성
  static EnvironmentDiagnosis diagnoseEnvironment(
    EnvironmentalConditions conditions,
  ) {
    final issues = <String>[];
    final recommendations = <String>[];
    final warnings = <String>[];

    // 온도 진단
    if (conditions.temperature < 15) {
      issues.add('온도가 너무 낮습니다 (${conditions.temperature}°C)');
      recommendations.add('실내 온도를 18-25°C로 높이거나 따뜻한 곳에서 작업하세요');
    } else if (conditions.temperature > 30) {
      issues.add('온도가 너무 높습니다 (${conditions.temperature}°C)');
      recommendations.add('에어컨을 사용하거나 시원한 시간대에 작업하세요');
      warnings.add('높은 온도로 인해 발효가 빨라질 수 있습니다');
    }

    // 습도 진단
    if (conditions.humidity < 40) {
      issues.add('습도가 너무 낮습니다 (${conditions.humidity}%)');
      recommendations.add('가습기를 사용하거나 젖은 수건을 근처에 두세요');
    } else if (conditions.humidity > 80) {
      issues.add('습도가 너무 높습니다 (${conditions.humidity}%)');
      recommendations.add('제습기를 사용하거나 환기를 개선하세요');
      warnings.add('높은 습도로 인해 반죽이 끈적해질 수 있습니다');
    }

    // 고도 진단
    if (conditions.altitude > 1500) {
      issues.add('고도가 높습니다 (${conditions.altitude}m)');
      recommendations.add('팽창제를 15-25% 줄이고 액체를 10-15% 늘리세요');
      recommendations.add('오븐 온도를 15-25°C 높이고 굽기 시간을 단축하세요');
      warnings.add('고도로 인해 반죽이 과도하게 부풀 수 있습니다');
    }

    // 계절별 진단
    switch (conditions.season) {
      case Season.summer:
        recommendations.add('여름철: 재료를 차갑게 보관하고 발효 시간을 단축하세요');
        break;
      case Season.winter:
        recommendations.add('겨울철: 재료를 실온에 두고 발효 시간을 연장하세요');
        break;
      case Season.spring:
      case Season.autumn:
        recommendations.add('적절한 계절입니다. 표준 레시피를 따르세요');
        break;
    }

    // 전체적인 환경 평가
    String overallAssessment;
    if (issues.isEmpty) {
      overallAssessment = '최적의 베이킹 환경입니다';
    } else if (issues.length <= 2) {
      overallAssessment = '약간의 조정이 필요한 환경입니다';
    } else {
      overallAssessment = '베이킹에 도전적인 환경입니다. 신중한 조정이 필요합니다';
    }

    return EnvironmentDiagnosis(
      overallAssessment: overallAssessment,
      issues: issues,
      recommendations: recommendations,
      warnings: warnings,
      isOptimal: issues.isEmpty,
      riskLevel: _calculateRiskLevel(conditions),
    );
  }

  /// 향후 센서 연동을 위한 확장 가능한 인터페이스
  static Future<EnvironmentalConditions>
      getEnvironmentalDataFromSensors() async {
    // 현재는 수동 입력 기반, 향후 센서 연동 시 이 메서드 구현
    // 표준화된 센서 프로토콜 지원을 위한 추상 인터페이스
    throw UnimplementedError('센서 연동은 향후 구현 예정입니다');
  }

  // 헬퍼 메서드들
  static double _calculateSeasonalCorrection(Season season) {
    switch (season) {
      case Season.spring:
        return 1.0; // 기준
      case Season.summer:
        return 0.95; // 5% 감소 (더운 날씨)
      case Season.autumn:
        return 1.0; // 기준
      case Season.winter:
        return 1.1; // 10% 증가 (추운 날씨)
    }
  }

  static String _calculateRiskLevel(EnvironmentalConditions conditions) {
    int riskScore = 0;

    // 온도 위험도
    if (conditions.temperature < 10 || conditions.temperature > 35) {
      riskScore += 3;
    } else if (conditions.temperature < 15 || conditions.temperature > 30) {
      riskScore += 2;
    } else if (conditions.temperature < 18 || conditions.temperature > 28) {
      riskScore += 1;
    }

    // 습도 위험도
    if (conditions.humidity < 30 || conditions.humidity > 85) {
      riskScore += 3;
    } else if (conditions.humidity < 40 || conditions.humidity > 80) {
      riskScore += 2;
    } else if (conditions.humidity < 50 || conditions.humidity > 75) {
      riskScore += 1;
    }

    // 고도 위험도
    if (conditions.altitude > 2000) {
      riskScore += 3;
    } else if (conditions.altitude > 1500) {
      riskScore += 2;
    } else if (conditions.altitude > 1000) {
      riskScore += 1;
    }

    if (riskScore >= 6) {
      return '높음';
    } else if (riskScore >= 3) {
      return '중간';
    } else {
      return '낮음';
    }
  }

  static bool _isFlour(String name) {
    final flourKeywords = ['밀가루', 'flour', '강력분', '중력분', '박력분', '통밀가루'];
    return flourKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  static bool _isLiquid(String name) {
    final liquidKeywords = ['물', 'water', '우유', 'milk', '크림', 'cream'];
    return liquidKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  static bool _isLeavening(String name) {
    final leavenKeywords = [
      '이스트',
      'yeast',
      '베이킹파우더',
      'baking powder',
      '베이킹소다',
      'baking soda'
    ];
    return leavenKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  static bool _isSugar(String name) {
    final sugarKeywords = ['설탕', 'sugar', '꿀', 'honey', '시럽', 'syrup'];
    return sugarKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }

  static bool _isFat(String name) {
    final fatKeywords = ['버터', 'butter', '기름', 'oil', '마가린', 'margarine'];
    return fatKeywords
        .any((keyword) => name.toLowerCase().contains(keyword.toLowerCase()));
  }
}

/// 환경 보정 결과
class EnvironmentCorrectionResult {
  final double temperatureCorrection;
  final double humidityCorrection;
  final double altitudeCorrection;
  final double seasonalCorrection;
  final double integratedCorrection;
  final EnvironmentalConditions conditions;

  const EnvironmentCorrectionResult({
    required this.temperatureCorrection,
    required this.humidityCorrection,
    required this.altitudeCorrection,
    required this.seasonalCorrection,
    required this.integratedCorrection,
    required this.conditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperatureCorrection': temperatureCorrection,
      'humidityCorrection': humidityCorrection,
      'altitudeCorrection': altitudeCorrection,
      'seasonalCorrection': seasonalCorrection,
      'integratedCorrection': integratedCorrection,
      'conditions': conditions.toJson(),
    };
  }

  factory EnvironmentCorrectionResult.fromJson(Map<String, dynamic> json) {
    return EnvironmentCorrectionResult(
      temperatureCorrection: json['temperatureCorrection']?.toDouble() ?? 1.0,
      humidityCorrection: json['humidityCorrection']?.toDouble() ?? 1.0,
      altitudeCorrection: json['altitudeCorrection']?.toDouble() ?? 1.0,
      seasonalCorrection: json['seasonalCorrection']?.toDouble() ?? 1.0,
      integratedCorrection: json['integratedCorrection']?.toDouble() ?? 1.0,
      conditions: EnvironmentalConditions.fromJson(json['conditions'] ?? {}),
    );
  }
}

/// 환경 진단 결과
class EnvironmentDiagnosis {
  final String overallAssessment;
  final List<String> issues;
  final List<String> recommendations;
  final List<String> warnings;
  final bool isOptimal;
  final String riskLevel;

  const EnvironmentDiagnosis({
    required this.overallAssessment,
    required this.issues,
    required this.recommendations,
    required this.warnings,
    required this.isOptimal,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'overallAssessment': overallAssessment,
      'issues': issues,
      'recommendations': recommendations,
      'warnings': warnings,
      'isOptimal': isOptimal,
      'riskLevel': riskLevel,
    };
  }

  factory EnvironmentDiagnosis.fromJson(Map<String, dynamic> json) {
    return EnvironmentDiagnosis(
      overallAssessment: json['overallAssessment'] ?? '',
      issues: List<String>.from(json['issues'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      isOptimal: json['isOptimal'] ?? false,
      riskLevel: json['riskLevel'] ?? '낮음',
    );
  }
}
