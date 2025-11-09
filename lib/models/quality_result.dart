// lib/models/quality_result.dart

class QualityResult {
  final double volumeIndex;
  final String crustColorIndex;
  final double crumbStructureScore;
  final String feedback;

  QualityResult({
    required this.volumeIndex,
    required this.crustColorIndex,
    required this.crumbStructureScore,
    required this.feedback,
  });

  factory QualityResult.fromJson(Map<String, dynamic> json) {
    return QualityResult(
      volumeIndex: json['volumeIndex'] as double,
      crustColorIndex: json['crustColorIndex'] as String,
      crumbStructureScore: json['crumbStructureScore'] as double,
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volumeIndex': volumeIndex,
      'crustColorIndex': crustColorIndex,
      'crumbStructureScore': crumbStructureScore,
      'feedback': feedback,
    };
  }
}
