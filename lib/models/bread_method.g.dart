// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bread_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreadMethod _$BreadMethodFromJson(Map<String, dynamic> json) => BreadMethod(
      name: json['name'] as String,
      starterRatio: (json['starterRatio'] as num?)?.toDouble() ?? 0.0,
      fermentationTemperature:
          (json['fermentationTemperature'] as num?)?.toDouble() ?? 24.0,
      fermentationTime: (json['fermentationTime'] as num?)?.toDouble() ?? 120.0,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$BreadMethodToJson(BreadMethod instance) =>
    <String, dynamic>{
      'name': instance.name,
      'starterRatio': instance.starterRatio,
      'fermentationTemperature': instance.fermentationTemperature,
      'fermentationTime': instance.fermentationTime,
      'description': instance.description,
    };
