// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_characteristics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OvenCharacteristicsAdapter extends TypeAdapter<OvenCharacteristics> {
  @override
  final int typeId = 8;

  @override
  OvenCharacteristics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OvenCharacteristics(
      type: fields[0] as OvenType,
      typeCoefficient: fields[1] as double,
      calibrationIndex: fields[2] as double,
      steamCapability: fields[3] as double,
      hasConvection: fields[4] as bool,
      maxTemperature: fields[5] as double,
      hasStone: fields[6] as bool,
      hasSteam: fields[7] as bool,
      temperatureAccuracy: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OvenCharacteristics obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.typeCoefficient)
      ..writeByte(2)
      ..write(obj.calibrationIndex)
      ..writeByte(3)
      ..write(obj.steamCapability)
      ..writeByte(4)
      ..write(obj.hasConvection)
      ..writeByte(5)
      ..write(obj.maxTemperature)
      ..writeByte(6)
      ..write(obj.hasStone)
      ..writeByte(7)
      ..write(obj.hasSteam)
      ..writeByte(8)
      ..write(obj.temperatureAccuracy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvenCharacteristicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvenCharacteristics _$OvenCharacteristicsFromJson(Map<String, dynamic> json) =>
    OvenCharacteristics(
      type: $enumDecode(_$OvenTypeEnumMap, json['type']),
      typeCoefficient: (json['typeCoefficient'] as num).toDouble(),
      calibrationIndex: (json['calibrationIndex'] as num).toDouble(),
      steamCapability: (json['steamCapability'] as num).toDouble(),
      hasConvection: json['hasConvection'] as bool,
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      hasStone: json['hasStone'] as bool? ?? false,
      hasSteam: json['hasSteam'] as bool? ?? false,
      temperatureAccuracy:
          (json['temperatureAccuracy'] as num?)?.toDouble() ?? 0.95,
    );

Map<String, dynamic> _$OvenCharacteristicsToJson(
        OvenCharacteristics instance) =>
    <String, dynamic>{
      'type': _$OvenTypeEnumMap[instance.type]!,
      'typeCoefficient': instance.typeCoefficient,
      'calibrationIndex': instance.calibrationIndex,
      'steamCapability': instance.steamCapability,
      'hasConvection': instance.hasConvection,
      'maxTemperature': instance.maxTemperature,
      'hasStone': instance.hasStone,
      'hasSteam': instance.hasSteam,
      'temperatureAccuracy': instance.temperatureAccuracy,
    };

const _$OvenTypeEnumMap = {
  OvenType.home: 'home',
  OvenType.professionalConvection: 'professionalConvection',
  OvenType.deck: 'deck',
  OvenType.steam: 'steam',
  OvenType.conventional: 'conventional',
  OvenType.convection: 'convection',
  OvenType.combi: 'combi',
};
