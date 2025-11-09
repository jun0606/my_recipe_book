// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environmental_conditions.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvironmentalConditionsAdapter
    extends TypeAdapter<EnvironmentalConditions> {
  @override
  final int typeId = 6;

  @override
  EnvironmentalConditions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvironmentalConditions(
      temperature: fields[0] as double,
      humidity: fields[1] as double,
      pressure: fields[2] as double,
      season: fields[3] as Season,
      oven: fields[4] as OvenCharacteristics,
      altitude: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, EnvironmentalConditions obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.humidity)
      ..writeByte(2)
      ..write(obj.pressure)
      ..writeByte(3)
      ..write(obj.season)
      ..writeByte(4)
      ..write(obj.oven)
      ..writeByte(5)
      ..write(obj.altitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentalConditionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentalConditions _$EnvironmentalConditionsFromJson(
        Map<String, dynamic> json) =>
    EnvironmentalConditions(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      season: $enumDecode(_$SeasonEnumMap, json['season']),
      oven: OvenCharacteristics.fromJson(json['oven'] as Map<String, dynamic>),
      altitude: (json['altitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EnvironmentalConditionsToJson(
        EnvironmentalConditions instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'season': _$SeasonEnumMap[instance.season]!,
      'oven': instance.oven,
      'altitude': instance.altitude,
    };

const _$SeasonEnumMap = {
  Season.spring: 'spring',
  Season.summer: 'summer',
  Season.autumn: 'autumn',
  Season.winter: 'winter',
};
