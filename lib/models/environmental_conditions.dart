import 'package:json_annotation/json_annotation.dart';

part 'environmental_conditions.g.dart'; // Assuming code generation for json_serializable

/// 계절 열거형
enum Season {
  spring,
  summer,
  autumn,
  winter,
}

/// Season 확장 - 계절별 속성 추가
extension SeasonExtension on Season {
  /// 계절별 추천 베이킹 스타일
  List<String> get recommendedBakingStyles {
    switch (this) {
      case Season.spring:
        return ['가벼운 빵', '샐러드 빵', '과일 빵'];
      case Season.summer:
        return ['냉장 발효 빵', '상큼한 빵', '가벼운 디저트'];
      case Season.autumn:
        return ['풍부한 빵', '호박 빵', '통곡물 빵'];
      case Season.winter:
        return ['무거운 빵', '뜨거운 빵', '풍부한 맛 빵'];
    }
  }

  /// 계절별 온도 보정
  double get temperatureCorrection {
    switch (this) {
      case Season.spring:
        return 0.0; // 기준 온도
      case Season.summer:
        return -2.0; // 더운 여름은 온도를 낮춤
      case Season.autumn:
        return 1.0; // 시원한 가을은 온도를 높임
      case Season.winter:
        return 2.0; // 추운 겨울은 온도를 높임
    }
  }

  /// 계절별 발효 시간 보정 (분)
  int get fermentationTimeCorrection {
    switch (this) {
      case Season.spring:
        return 0; // 기준 시간
      case Season.summer:
        return -30; // 더운 여름은 발효 시간을 단축
      case Season.autumn:
        return 15; // 시원한 가을은 발효 시간을 약간 연장
      case Season.winter:
        return 45; // 추운 겨울은 발효 시간을 연장
    }
  }
}

/// 오븐 특성 클래스
class OvenCharacteristics {
  final OvenType type;
  final double temperatureAccuracy;
  final bool hasStone;
  final bool hasSteam;

  const OvenCharacteristics({
    required this.type,
    required this.temperatureAccuracy,
    required this.hasStone,
    required this.hasSteam,
  });
}

/// 오븐 타입 열거형
enum OvenType {
  gas,
  electric,
  convection,
  woodFired,
}

/// 환경 조건 정보
@JsonSerializable()
class EnvironmentalConditions {
  final double temperature; // 섭씨
  final double humidity; // 퍼센트
  final double pressure; // hPa
  final Season season;
  final OvenCharacteristics oven;
  final double? altitude; // 미터

  const EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.season,
    required this.oven,
    this.altitude,
  });

  factory EnvironmentalConditions.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentalConditionsToJson(this);

  EnvironmentalConditions copyWith({
    double? temperature,
    double? humidity,
    double? pressure,
    Season? season,
    OvenCharacteristics? oven,
    double? altitude,
  }) {
    return EnvironmentalConditions(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      season: season ?? this.season,
      oven: oven ?? this.oven,
      altitude: altitude ?? this.altitude,
    );
  }

  /// 온도 보정 계수: 1 + ((실제 온도 - 25) / 10)
  double get temperatureCorrection {
    return 1 + ((temperature - 25) / 10);
  }

  /// 습도 보정 계수: 1 + ((실제 습도% - 65) × 0.005)
  double get humidityCorrection {
    return 1 + ((humidity - 65) * 0.005);
  }

  /// 고도 보정 계수: 1 + ((현재 고도(m) / 1000) × 0.02)
  double get altitudeCorrection {
    if (altitude == null) return 1.0;
    return 1 + ((altitude! / 1000) * 0.02);
  }

  /// 발효 속도 온도 보정: 2^((실제 온도 - 25) / 10)
  double get fermentationSpeedCorrection {
    // Assuming math.pow is available, or import dart:math
    return (2).toDouble() * ((temperature - 25) / 10);
  }
}
