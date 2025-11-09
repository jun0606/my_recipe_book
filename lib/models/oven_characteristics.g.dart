// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oven_characteristics.dart';

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
  OvenType.professionalConvection: 'professional_convection',
  OvenType.deck: 'deck',
  OvenType.steam: 'steam',
  OvenType.conventional: 'conventional',
  OvenType.convection: 'convection',
  OvenType.combi: 'combi',
};
