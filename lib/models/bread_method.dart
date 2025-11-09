import 'package:json_annotation/json_annotation.dart';

part 'bread_method.g.dart'; // Assuming code generation for json_serializable

/// 빵 도법 정보
@JsonSerializable()
class BreadMethod {
  final String name; // e.g., 'straight dough', 'sourdough', 'poolish'
  final double starterRatio; // 스타터 비율 (사워도우, 르방 등)
  final double fermentationTemperature; // 발효 온도 (섭씨)
  final double fermentationTime; // 발효 시간 (분)
  final String description; // 도법 설명

  const BreadMethod({
    required this.name,
    this.starterRatio = 0.0,
    this.fermentationTemperature = 24.0,
    this.fermentationTime = 120.0,
    this.description = '',
  });

  factory BreadMethod.fromJson(Map<String, dynamic> json) =>
      _$BreadMethodFromJson(json);

  Map<String, dynamic> toJson() => _$BreadMethodToJson(this);

  BreadMethod copyWith({
    String? name,
    double? starterRatio,
    double? fermentationTemperature,
    double? fermentationTime,
    String? description,
  }) {
    return BreadMethod(
      name: name ?? this.name,
      starterRatio: starterRatio ?? this.starterRatio,
      fermentationTemperature:
          fermentationTemperature ?? this.fermentationTemperature,
      fermentationTime: fermentationTime ?? this.fermentationTime,
      description: description ?? this.description,
    );
  }
}