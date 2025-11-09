// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientMetadata _$IngredientMetadataFromJson(Map<String, dynamic> json) =>
    IngredientMetadata(
      name: json['name'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      effectiveValue: (json['effectiveValue'] as num).toDouble(),
      function: json['function'] as String,
      qualityCorrectionFactor:
          (json['qualityCorrectionFactor'] as num).toDouble(),
    );

Map<String, dynamic> _$IngredientMetadataToJson(IngredientMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'properties': instance.properties,
      'effectiveValue': instance.effectiveValue,
      'function': instance.function,
      'qualityCorrectionFactor': instance.qualityCorrectionFactor,
    };
