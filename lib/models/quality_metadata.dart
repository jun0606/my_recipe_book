// lib/models/quality_metadata.dart

import 'package:json_annotation/json_annotation.dart';

part 'quality_metadata.g.dart';

@JsonSerializable()
class QualityMetadata {
  final String id;
  final DateTime timestamp;
  final double volumeIndex; // 볼륨 지수
  final String crustColorScore; // 크러스트 색상 지수 (예: "적절", "옅음", "진함")
  final double poreStructureScore; // 기공 구조 점수 (0.0 ~ 1.0)
  final Map<String, dynamic> feedback; // 예측값과 실제값 비교 피드백

  QualityMetadata({
    required this.id,
    required this.timestamp,
    required this.volumeIndex,
    required this.crustColorScore,
    required this.poreStructureScore,
    required this.feedback,
  });

  factory QualityMetadata.fromJson(Map<String, dynamic> json) => _$QualityMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$QualityMetadataToJson(this);
}