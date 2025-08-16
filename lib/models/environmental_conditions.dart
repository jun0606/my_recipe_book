/// 환경 조건을 나타내는 모델
import 'fermentation_scenario_v2.dart';

class EnvironmentalConditions {
  final double temperature; // 온도 (°C)
  final double humidity; // 습도 (%)
  final double altitude; // 고도 (m)
  final double airPressure; // 기압 (hPa)
  final Season season; // 계절
  final String location; // 지역
  final String ovenType; // 오븐 타입

  const EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    this.altitude = 0.0,
    this.airPressure = 1013.25,
    this.season = Season.spring,
    this.location = 'default',
    this.ovenType = '가정용 전기오븐',
  });

  /// 표준 환경 조건 (20°C, 60% 습도)
  static const EnvironmentalConditions standard = EnvironmentalConditions(
    temperature: 20.0,
    humidity: 60.0,
  );

  /// 여름 환경 조건
  static const EnvironmentalConditions summer = EnvironmentalConditions(
    temperature: 28.0,
    humidity: 75.0,
    season: Season.summer,
  );

  /// 겨울 환경 조건
  static const EnvironmentalConditions winter = EnvironmentalConditions(
    temperature: 15.0,
    humidity: 45.0,
    season: Season.winter,
  );

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'altitude': altitude,
      'airPressure': airPressure,
      'season': season.name,
      'location': location,
      'ovenType': ovenType,
    };
  }

  /// JSON에서 생성
  factory EnvironmentalConditions.fromJson(Map<String, dynamic> json) {
    return EnvironmentalConditions(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      airPressure: (json['airPressure'] as num?)?.toDouble() ?? 1013.25,
      season: Season.values.firstWhere(
        (e) => e.name == (json['season'] as String? ?? 'spring'),
        orElse: () => Season.spring,
      ),
      location: json['location'] as String? ?? 'default',
      ovenType: json['ovenType'] as String? ?? '가정용 전기오븐',
    );
  }

  /// 복사본 생성
  EnvironmentalConditions copyWith({
    double? temperature,
    double? humidity,
    double? altitude,
    double? airPressure,
    Season? season,
    String? location,
    String? ovenType,
  }) {
    return EnvironmentalConditions(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      altitude: altitude ?? this.altitude,
      airPressure: airPressure ?? this.airPressure,
      season: season ?? this.season,
      location: location ?? this.location,
      ovenType: ovenType ?? this.ovenType,
    );
  }

  @override
  String toString() {
    return 'EnvironmentalConditions(temperature: $temperature°C, humidity: $humidity%, altitude: ${altitude}m, ovenType: $ovenType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnvironmentalConditions &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.altitude == altitude &&
        other.airPressure == airPressure &&
        other.season == season &&
        other.location == location &&
        other.ovenType == ovenType;
  }

  @override
  int get hashCode {
    return Object.hash(temperature, humidity, altitude, airPressure, season, location, ovenType);
  }
}

/// 환경 조정 결과
class EnvironmentalAdjustment {
  final Map<String, double> adjustmentFactors; // 조정 계수들
  final List<String> recommendations; // 권장사항들
  final String reason; // 조정 이유

  const EnvironmentalAdjustment({
    required this.adjustmentFactors,
    required this.recommendations,
    required this.reason,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'adjustmentFactors': adjustmentFactors,
      'recommendations': recommendations,
      'reason': reason,
    };
  }

  /// JSON에서 생성
  factory EnvironmentalAdjustment.fromJson(Map<String, dynamic> json) {
    return EnvironmentalAdjustment(
      adjustmentFactors: Map<String, double>.from(json['adjustmentFactors'] as Map),
      recommendations: List<String>.from(json['recommendations'] as List),
      reason: json['reason'] as String,
    );
  }
}