import 'package:json_annotation/json_annotation.dart';

part 'ingredient_metadata.g.dart'; // Assuming code generation for json_serializable

/// 재료 메타데이터
@JsonSerializable()
class IngredientMetadata {
  final String name;
  final Map<String, dynamic> properties; // 글루텐, 수분, 단백질 등
  final double effectiveValue; // 유효값 (보정 적용 후)
  final String function; // 재료의 기능 (구조 형성, 발효 등)
  final double qualityCorrectionFactor; // 품질 보정 계수

  const IngredientMetadata({
    required this.name,
    required this.properties,
    required this.effectiveValue,
    required this.function,
    required this.qualityCorrectionFactor,
  });

  factory IngredientMetadata.fromJson(Map<String, dynamic> json) =>
      _$IngredientMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientMetadataToJson(this);

  IngredientMetadata copyWith({
    String? name,
    Map<String, dynamic>? properties,
    double? effectiveValue,
    String? function,
    double? qualityCorrectionFactor,
  }) {
    return IngredientMetadata(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      effectiveValue: effectiveValue ?? this.effectiveValue,
      function: function ?? this.function,
      qualityCorrectionFactor:
          qualityCorrectionFactor ?? this.qualityCorrectionFactor,
    );
  }
}