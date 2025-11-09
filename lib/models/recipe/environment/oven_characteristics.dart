import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'oven_type.dart';

part 'oven_characteristics.g.dart';

/// 오븐 특성 정보
@HiveType(typeId: 8)
@JsonSerializable()
class OvenCharacteristics {
  @HiveField(0)
  final OvenType type;
  @HiveField(1)
  final double typeCoefficient; // 오븐 유형 계수
  @HiveField(2)
  final double calibrationIndex; // 동적 캘리브레이션 지수
  @HiveField(3)
  final double steamCapability; // 스팀 능력
  @HiveField(4)
  final bool hasConvection; // 컨벡션 기능 여부
  @HiveField(5)
  final double maxTemperature; // 최대 온도
  @HiveField(6)
  final bool hasStone; // 피자 스톤 여부
  @HiveField(7)
  final bool hasSteam; // 스팀 기능 여부
  @HiveField(8)
  final double temperatureAccuracy; // 온도 정확도

  const OvenCharacteristics({
    required this.type,
    required this.typeCoefficient,
    required this.calibrationIndex,
    required this.steamCapability,
    required this.hasConvection,
    required this.maxTemperature,
    this.hasStone = false,
    this.hasSteam = false,
    this.temperatureAccuracy = 0.95,
  });

  factory OvenCharacteristics.fromJson(Map<String, dynamic> json) =>
      _$OvenCharacteristicsFromJson(json);

  Map<String, dynamic> toJson() => _$OvenCharacteristicsToJson(this);

  OvenCharacteristics copyWith({
    OvenType? type,
    double? typeCoefficient,
    double? calibrationIndex,
    double? steamCapability,
    bool? hasConvection,
    double? maxTemperature,
    bool? hasStone,
    bool? hasSteam,
    double? temperatureAccuracy,
  }) {
    return OvenCharacteristics(
      type: type ?? this.type,
      typeCoefficient: typeCoefficient ?? this.typeCoefficient,
      calibrationIndex: calibrationIndex ?? this.calibrationIndex,
      steamCapability: steamCapability ?? this.steamCapability,
      hasConvection: hasConvection ?? this.hasConvection,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      hasStone: hasStone ?? this.hasStone,
      hasSteam: hasSteam ?? this.hasSteam,
      temperatureAccuracy: temperatureAccuracy ?? this.temperatureAccuracy,
    );
  }
}
