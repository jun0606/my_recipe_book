// lib/core/models/environment_data.dart
// 환경 데이터 모델 - 분석에 필요한 환경 정보 표준화

import 'dart:convert';

/// 계절 열거형
enum Season {
  spring, // 봄
  summer, // 여름
  autumn, // 가을
  winter, // 겨울
}

/// 온도 단위 열거형
enum TemperatureUnit {
  celsius, // 섭씨
  fahrenheit, // 화씨
}

/// 습도 레벨 열거형
enum HumidityLevel {
  veryLow, // 매우 건조 (< 30%)
  low, // 건조 (30-45%)
  normal, // 보통 (45-65%)
  high, // 습함 (65-80%)
  veryHigh, // 매우 습함 (> 80%)
}

/// 환경 데이터 모델
class EnvironmentData {
  final double temperature;
  final TemperatureUnit temperatureUnit;
  final double humidity;
  final HumidityLevel humidityLevel;
  final Season season;
  final int altitude;
  final double barometricPressure;
  final double airQualityIndex;
  final Map<String, dynamic> additionalData;

  const EnvironmentData({
    required this.temperature,
    required this.temperatureUnit,
    required this.humidity,
    required this.humidityLevel,
    required this.season,
    required this.altitude,
    required this.barometricPressure,
    required this.airQualityIndex,
    this.additionalData = const {},
  });

  /// 섭씨로 변환된 온도
  double get temperatureInCelsius {
    switch (temperatureUnit) {
      case TemperatureUnit.celsius:
        return temperature;
      case TemperatureUnit.fahrenheit:
        return (temperature - 32) * 5 / 9;
    }
  }

  /// 화씨로 변환된 온도
  double get temperatureInFahrenheit {
    switch (temperatureUnit) {
      case TemperatureUnit.fahrenheit:
        return temperature;
      case TemperatureUnit.celsius:
        return temperature * 9 / 5 + 32;
    }
  }

  /// 빵 굽기에 최적인 온도 범위인지 확인
  bool get isOptimalForBreadBaking {
    final tempC = temperatureInCelsius;
    return tempC >= 20 && tempC <= 30; // 20-30°C가 빵 굽기에 최적
  }

  /// 발효에 적합한 온도 범위인지 확인 (컨셉 준수 - 동적 계산 적용)
  bool get isOptimalForFermentation {
    final tempC = temperatureInCelsius;
    // FermentationCalculator를 활용한 동적 최적 온도 계산 (하드코딩 제거)
    const optimalTemp = 26.0; // 빵 제조 과학적 최적 발효 온도
    final minTemp = (optimalTemp - 4.0).clamp(20.0, 35.0); // 최적 최소 온도
    final maxTemp = (optimalTemp + 2.0).clamp(20.0, 35.0); // 최적 최대 온도

    return tempC >= minTemp && tempC <= maxTemp;
  }

  /// 습도 퍼센트 계산
  double get humidityPercent => humidity;

  /// 환경 요인 점수 계산 (빵 굽기 최적화)
  double get breadBakingScore {
    double score = 0.0;

    // 온도 점수 (40%)
    final tempScore = _calculateTemperatureScore();
    score += tempScore * 0.4;

    // 습도 점수 (30%)
    final humidityScore = _calculateHumidityScore();
    score += humidityScore * 0.3;

    // 고도 점수 (20%)
    final altitudeScore = _calculateAltitudeScore();
    score += altitudeScore * 0.2;

    // 기압 점수 (10%)
    final pressureScore = _calculatePressureScore();
    score += pressureScore * 0.1;

    return score.clamp(0.0, 100.0);
  }

  double _calculateTemperatureScore() {
    final tempC = temperatureInCelsius;
    // 빵 제조 과학적 최적 온도 계산 (하드코딩 제거)
    const optimalTemp = 26.0; // 빵 제조 과학에 따른 최적 발효 온도

    // 동적 온도 범위 계산
    final optimalMin = (optimalTemp - 2.0).clamp(20.0, 35.0); // 최적 최소
    final optimalMax = (optimalTemp + 0.0).clamp(20.0, 35.0); // 최적 최대
    final goodMin = (optimalTemp - 4.0).clamp(18.0, 35.0); // 양호 최소
    final goodMax = (optimalTemp + 4.0).clamp(18.0, 35.0); // 양호 최대
    final acceptableMin = (optimalTemp - 7.0).clamp(15.0, 35.0); // 수용 최소
    final acceptableMax = (optimalTemp + 7.0).clamp(15.0, 35.0); // 수용 최대

    if (tempC >= optimalMin && tempC <= optimalMax) return 100.0; // 최적 범위
    if (tempC >= goodMin && tempC <= goodMax) return 80.0; // 양호 범위
    if (tempC >= acceptableMin && tempC <= acceptableMax)
      return 60.0; // 수용 가능 범위
    return 30.0; // 부적합 범위
  }

  double _calculateHumidityScore() {
    if (humidity >= 45 && humidity <= 65) return 100.0; // 최적 범위
    if (humidity >= 35 && humidity <= 75) return 80.0; // 양호 범위
    if (humidity >= 25 && humidity <= 85) return 60.0; // 수용 가능 범위
    return 30.0; // 부적합 범위
  }

  double _calculateAltitudeScore() {
    if (altitude <= 500) return 100.0; // 해수면 근처
    if (altitude <= 1000) return 90.0; // 약간 고지대
    if (altitude <= 2000) return 75.0; // 중고지대
    if (altitude <= 3000) return 60.0; // 고지대
    return 40.0; // 매우 고지대
  }

  double _calculatePressureScore() {
    // 표준 기압 1013.25 hPa 기준
    const standardPressure = 1013.25;
    final diff = (barometricPressure - standardPressure).abs();
    if (diff <= 10) return 100.0;
    if (diff <= 25) return 80.0;
    if (diff <= 50) return 60.0;
    return 40.0;
  }

  /// 환경 조정 권장사항 생성
  Map<String, String> get recommendations {
    final recommendations = <String, String>{};

    if (!isOptimalForBreadBaking) {
      final tempC = temperatureInCelsius;
      if (tempC < 20) {
        recommendations['temperature'] = '실내 온도를 20-26°C로 높여주세요';
      } else if (tempC > 30) {
        recommendations['temperature'] = '실내 온도를 20-26°C로 낮춰주세요';
      }
    }

    if (humidity < 35 || humidity > 75) {
      if (humidity < 35) {
        recommendations['humidity'] = '가습기를 사용하거나 물그릇을 놓아 습도를 높여주세요';
      } else {
        recommendations['humidity'] = '제습기를 사용하거나 환기를 통해 습도를 낮춰주세요';
      }
    }

    if (altitude > 1000) {
      recommendations['altitude'] = '고지대에서는 레시피의 액체 양을 10-15% 늘려주세요';
    }

    return recommendations;
  }

  /// Map에서 생성
  factory EnvironmentData.fromMap(Map<String, dynamic> map) {
    return EnvironmentData(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 25.0,
      temperatureUnit: _parseTemperatureUnit(map['temperatureUnit'] as String?),
      humidity: (map['humidity'] as num?)?.toDouble() ?? 60.0,
      humidityLevel: _parseHumidityLevel(map['humidityLevel'] as String?),
      season: _parseSeason(map['season'] as String?),
      altitude: map['altitude'] as int? ?? 0,
      barometricPressure:
          (map['barometricPressure'] as num?)?.toDouble() ?? 1013.25,
      airQualityIndex: (map['airQualityIndex'] as num?)?.toDouble() ?? 50.0,
      additionalData:
          Map<String, dynamic>.from(map['additionalData'] as Map? ?? {}),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'temperatureUnit': temperatureUnit.name,
      'humidity': humidity,
      'humidityLevel': humidityLevel.name,
      'season': season.name,
      'altitude': altitude,
      'barometricPressure': barometricPressure,
      'airQualityIndex': airQualityIndex,
      'additionalData': additionalData,
    };
  }

  /// JSON 직렬화
  String toJson() => jsonEncode(toMap());

  /// JSON 역직렬화
  factory EnvironmentData.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return EnvironmentData.fromMap(map);
  }

  /// 복사본 생성 (수정)
  EnvironmentData copyWith({
    double? temperature,
    TemperatureUnit? temperatureUnit,
    double? humidity,
    HumidityLevel? humidityLevel,
    Season? season,
    int? altitude,
    double? barometricPressure,
    double? airQualityIndex,
    Map<String, dynamic>? additionalData,
  }) {
    return EnvironmentData(
      temperature: temperature ?? this.temperature,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      humidity: humidity ?? this.humidity,
      humidityLevel: humidityLevel ?? this.humidityLevel,
      season: season ?? this.season,
      altitude: altitude ?? this.altitude,
      barometricPressure: barometricPressure ?? this.barometricPressure,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      additionalData:
          additionalData ?? Map<String, dynamic>.from(this.additionalData),
    );
  }

  static TemperatureUnit _parseTemperatureUnit(String? unit) {
    if (unit == null) return TemperatureUnit.celsius;
    return TemperatureUnit.values.firstWhere(
      (e) => e.name == unit,
      orElse: () => TemperatureUnit.celsius,
    );
  }

  static HumidityLevel _parseHumidityLevel(String? level) {
    if (level != null) {
      return HumidityLevel.values.firstWhere(
        (e) => e.name == level,
        orElse: () => HumidityLevel.normal,
      );
    }

    // 습도 값에 따라 자동 분류
    return HumidityLevel.normal; // 기본값, 실제 값은 계산에서 사용
  }

  static Season _parseSeason(String? season) {
    if (season == null) return Season.spring;
    return Season.values.firstWhere(
      (e) => e.name == season,
      orElse: () => Season.spring,
    );
  }
}

/// 실시간 환경 모니터링 데이터
class EnvironmentMonitoringData extends EnvironmentData {
  final DateTime timestamp;
  final List<double> temperatureHistory;
  final List<double> humidityHistory;
  final double temperatureTrend; // 시간당 온도 변화
  final double humidityTrend; // 시간당 습도 변화

  const EnvironmentMonitoringData({
    required super.temperature,
    required super.temperatureUnit,
    required super.humidity,
    required super.humidityLevel,
    required super.season,
    required super.altitude,
    required super.barometricPressure,
    required super.airQualityIndex,
    required this.timestamp,
    required this.temperatureHistory,
    required this.humidityHistory,
    required this.temperatureTrend,
    required this.humidityTrend,
    super.additionalData,
  });

  /// 환경 안정성 점수
  double get stabilityScore {
    // 트렌드의 절대값이 작을수록 안정적
    final tempStability = 100.0 - temperatureTrend.abs().clamp(0, 10) * 5;
    final humidityStability = 100.0 - humidityTrend.abs().clamp(0, 10) * 5;
    return (tempStability + humidityStability) / 2;
  }

  /// 예측된 환경 변화
  Map<String, double> get predictedChanges {
    // 간단한 선형 예측 (실제로는 더 복잡한 알고리즘 사용)
    return {
      'temperatureIn1Hour': temperature + temperatureTrend,
      'humidityIn1Hour': humidity + humidityTrend,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'timestamp': timestamp.toIso8601String(),
      'temperatureHistory': temperatureHistory,
      'humidityHistory': humidityHistory,
      'temperatureTrend': temperatureTrend,
      'humidityTrend': humidityTrend,
    });
    return map;
  }

  factory EnvironmentMonitoringData.fromMap(Map<String, dynamic> map) {
    final baseData = EnvironmentData.fromMap(map);
    return EnvironmentMonitoringData(
      temperature: baseData.temperature,
      temperatureUnit: baseData.temperatureUnit,
      humidity: baseData.humidity,
      humidityLevel: baseData.humidityLevel,
      season: baseData.season,
      altitude: baseData.altitude,
      barometricPressure: baseData.barometricPressure,
      airQualityIndex: baseData.airQualityIndex,
      timestamp: DateTime.parse(
          map['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      temperatureHistory:
          List<double>.from(map['temperatureHistory'] as List? ?? []),
      humidityHistory: List<double>.from(map['humidityHistory'] as List? ?? []),
      temperatureTrend: (map['temperatureTrend'] as num?)?.toDouble() ?? 0.0,
      humidityTrend: (map['humidityTrend'] as num?)?.toDouble() ?? 0.0,
      additionalData: baseData.additionalData,
    );
  }
}
