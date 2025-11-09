// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QualityMetadata _$QualityMetadataFromJson(Map<String, dynamic> json) =>
    QualityMetadata(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      volumeIndex: (json['volumeIndex'] as num).toDouble(),
      crustColorScore: json['crustColorScore'] as String,
      poreStructureScore: (json['poreStructureScore'] as num).toDouble(),
      feedback: json['feedback'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QualityMetadataToJson(QualityMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'volumeIndex': instance.volumeIndex,
      'crustColorScore': instance.crustColorScore,
      'poreStructureScore': instance.poreStructureScore,
      'feedback': instance.feedback,
    };
