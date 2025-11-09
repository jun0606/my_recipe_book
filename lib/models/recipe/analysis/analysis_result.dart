import 'dart:convert';
import 'bread_analysis_data.dart';
import '../core/recipe.dart';
import '../metadata/quality_metadata.dart';
import '../metadata/process_metadata.dart';

/// 빵 분석 결과
class AnalysisResult {
  final String analysisId; // 분석 고유 ID
  final Recipe originalRecipe; // 원본 레시피
  final BreadAnalysisData analysisData; // 분석 데이터
  final QualityMetadata predictedQuality; // 예측 품질
  final ProcessMetadata recommendedProcess; // 추천 공정
  final DateTime analysisDate; // 분석 날짜
  final String analysisType; // 분석 타입 (basic, advanced, expert)
  final Map<String, dynamic> recommendations; // 추천 사항들
  final Map<String, dynamic> warnings; // 경고 사항들
  final double confidenceScore; // 신뢰도 점수 (0.0 ~ 1.0)
  final Duration estimatedDuration; // 예상 소요 시간

  const AnalysisResult({
    required this.analysisId,
    required this.originalRecipe,
    required this.analysisData,
    required this.predictedQuality,
    required this.recommendedProcess,
    required this.analysisDate,
    this.analysisType = 'basic',
    this.recommendations = const {},
    this.warnings = const {},
    this.confidenceScore = 0.8,
  }) : estimatedDuration = const Duration(hours: 4); // 기본 4시간

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      analysisId: json['analysisId'] as String,
      originalRecipe:
          Recipe.fromJson(json['originalRecipe'] as Map<String, dynamic>),
      analysisData: BreadAnalysisData.fromJson(
          json['analysisData'] as Map<String, dynamic>),
      predictedQuality: QualityMetadata.fromJson(
          json['predictedQuality'] as Map<String, dynamic>),
      recommendedProcess: ProcessMetadata.fromJson(
          json['recommendedProcess'] as Map<String, dynamic>),
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      analysisType: json['analysisType'] as String? ?? 'basic',
      recommendations:
          Map<String, dynamic>.from(json['recommendations'] as Map? ?? {}),
      warnings: Map<String, dynamic>.from(json['warnings'] as Map? ?? {}),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'originalRecipe': originalRecipe.toJson(),
      'analysisData': analysisData.toJson(),
      'predictedQuality': predictedQuality.toJson(),
      'recommendedProcess': recommendedProcess.toJson(),
      'analysisDate': analysisDate.toIso8601String(),
      'analysisType': analysisType,
      'recommendations': recommendations,
      'warnings': warnings,
      'confidenceScore': confidenceScore,
    };
  }

  AnalysisResult copyWith({
    String? analysisId,
    Recipe? originalRecipe,
    BreadAnalysisData? analysisData,
    QualityMetadata? predictedQuality,
    ProcessMetadata? recommendedProcess,
    DateTime? analysisDate,
    String? analysisType,
    Map<String, dynamic>? recommendations,
    Map<String, dynamic>? warnings,
    double? confidenceScore,
  }) {
    return AnalysisResult(
      analysisId: analysisId ?? this.analysisId,
      originalRecipe: originalRecipe ?? this.originalRecipe,
      analysisData: analysisData ?? this.analysisData,
      predictedQuality: predictedQuality ?? this.predictedQuality,
      recommendedProcess: recommendedProcess ?? this.recommendedProcess,
      analysisDate: analysisDate ?? this.analysisDate,
      analysisType: analysisType ?? this.analysisType,
      recommendations: recommendations ?? this.recommendations,
      warnings: warnings ?? this.warnings,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }

  /// 분석 결과의 유효성 검증
  bool get isValid {
    return analysisId.isNotEmpty &&
        originalRecipe.ingredients.isNotEmpty &&
        predictedQuality.overallQualityScore > 0 &&
        confidenceScore > 0;
  }

  /// 분석 결과 요약
  String get summary {
    final qualityGrade = predictedQuality.qualityGrade;
    final score = predictedQuality.overallQualityScore.toStringAsFixed(1);
    final confidence = (confidenceScore * 100).toStringAsFixed(1);

    return '분석 결과: $qualityGrade ($score/100), 신뢰도 $confidence%, '
        '예상 시간 ${estimatedDuration.inHours}시간';
  }

  /// 분석 결과 상세 정보
  Map<String, dynamic> get detailedInfo {
    return {
      'analysisId': analysisId,
      'recipeTitle': originalRecipe.title,
      'qualityGrade': predictedQuality.qualityGrade,
      'qualityScore': predictedQuality.overallQualityScore,
      'confidenceScore': confidenceScore,
      'estimatedDuration': estimatedDuration.inMinutes,
      'recommendationsCount': recommendations.length,
      'warningsCount': warnings.length,
      'analysisType': analysisType,
      'analysisDate': analysisDate.toIso8601String(),
    };
  }

  /// 주요 권장 사항 목록
  List<String> get keyRecommendations {
    final List<String> keys = [];

    if (predictedQuality.volumeIndex < 2.0) {
      keys.add('부피 증가를 위해 이스트량을 늘리거나 발효 시간을 연장하세요');
    }

    if (predictedQuality.crustColorIndex < 0.7) {
      keys.add('색상을 개선하기 위해 굽기 온도를 높이거나 시간을 늘리세요');
    }

    if (predictedQuality.poreStructureScore < 70) {
      keys.add('기공 구조 개선을 위해 반죽 휴지 시간을 늘리세요');
    }

    if (originalRecipe.hydrationPercentage < 65) {
      keys.add('수분량을 늘려 빵의 질감을 향상시키세요');
    }

    if (originalRecipe.saltPercentage < 1.5 ||
        originalRecipe.saltPercentage > 2.5) {
      keys.add('소금량을 1.8-2.2%로 조정하세요');
    }

    return keys;
  }

  /// 주요 경고 사항 목록
  List<String> get keyWarnings {
    final List<String> warnings = [];

    if (predictedQuality.overallQualityScore < 60) {
      warnings.add('품질 점수가 낮습니다. 레시피를 재검토하세요');
    }

    if (confidenceScore < 0.7) {
      warnings.add('분석 신뢰도가 낮습니다. 추가 데이터를 입력하세요');
    }

    if (originalRecipe.hydrationPercentage > 80) {
      warnings.add('수분량이 너무 높아 반죽 관리가 어려울 수 있습니다');
    }

    if (originalRecipe.yeastPercentage > 3.0) {
      warnings.add('이스트량이 너무 많아 풍미가 저하될 수 있습니다');
    }

    return warnings;
  }

  /// 분석 결과 평가
  AnalysisGrade get grade {
    final score = predictedQuality.overallQualityScore;
    final confidence = confidenceScore;

    if (score >= 90 && confidence >= 0.9) return AnalysisGrade.excellent;
    if (score >= 80 && confidence >= 0.8) return AnalysisGrade.veryGood;
    if (score >= 70 && confidence >= 0.7) return AnalysisGrade.good;
    if (score >= 60 && confidence >= 0.6) return AnalysisGrade.fair;
    return AnalysisGrade.poor;
  }

  @override
  String toString() => summary;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisResult && other.analysisId == analysisId;
  }

  @override
  int get hashCode => analysisId.hashCode;
}

/// 분석 등급
enum AnalysisGrade {
  excellent,
  veryGood,
  good,
  fair,
  poor,
}

extension AnalysisGradeExtension on AnalysisGrade {
  String get displayName {
    switch (this) {
      case AnalysisGrade.excellent:
        return '탁월';
      case AnalysisGrade.veryGood:
        return '매우 좋음';
      case AnalysisGrade.good:
        return '좋음';
      case AnalysisGrade.fair:
        return '보통';
      case AnalysisGrade.poor:
        return '미흡';
    }
  }

  String get description {
    switch (this) {
      case AnalysisGrade.excellent:
        return '최적의 레시피와 조건으로 최고 품질의 빵을 만들 수 있습니다';
      case AnalysisGrade.veryGood:
        return '약간의 개선으로 훌륭한 결과를 얻을 수 있습니다';
      case AnalysisGrade.good:
        return '표준적인 품질의 빵을 만들 수 있습니다';
      case AnalysisGrade.fair:
        return '개선이 필요한 부분이 있지만 사용 가능한 수준입니다';
      case AnalysisGrade.poor:
        return '큰 개선이 필요합니다';
    }
  }

  String get colorCode {
    switch (this) {
      case AnalysisGrade.excellent:
        return '#4CAF50'; // 녹색
      case AnalysisGrade.veryGood:
        return '#8BC34A'; // 연두색
      case AnalysisGrade.good:
        return '#FFEB3B'; // 노란색
      case AnalysisGrade.fair:
        return '#FF9800'; // 주황색
      case AnalysisGrade.poor:
        return '#F44336'; // 빨강색
    }
  }
}

/// 분석 결과 생성기
class AnalysisResultGenerator {
  /// 기본 분석 결과 생성
  static AnalysisResult createBasicResult({
    required Recipe recipe,
    required BreadAnalysisData analysisData,
    String analysisType = 'basic',
  }) {
    final analysisId = 'analysis_${DateTime.now().millisecondsSinceEpoch}';

    final recommendations = <String, dynamic>{
      'hydration': _getHydrationRecommendation(recipe),
      'yeast': _getYeastRecommendation(recipe),
      'salt': _getSaltRecommendation(recipe),
      'temperature': _getTemperatureRecommendation(analysisData),
    };

    final warnings = <String, dynamic>{
      'critical': _getCriticalWarnings(recipe, analysisData),
      'moderate': _getModerateWarnings(recipe, analysisData),
    };

    final confidenceScore = _calculateConfidenceScore(recipe, analysisData);

    return AnalysisResult(
      analysisId: analysisId,
      originalRecipe: recipe,
      analysisData: analysisData,
      predictedQuality: analysisData.qualityMetadata,
      recommendedProcess: analysisData.processMetadata,
      analysisDate: DateTime.now(),
      analysisType: analysisType,
      recommendations: recommendations,
      warnings: warnings,
      confidenceScore: confidenceScore,
    );
  }

  /// 상세 분석 결과 생성
  static AnalysisResult createDetailedResult({
    required Recipe recipe,
    required BreadAnalysisData analysisData,
    required Map<String, dynamic> additionalAnalysis,
    String analysisType = 'detailed',
  }) {
    final basicResult = createBasicResult(
      recipe: recipe,
      analysisData: analysisData,
      analysisType: analysisType,
    );

    final enhancedRecommendations =
        Map<String, dynamic>.from(basicResult.recommendations);
    enhancedRecommendations.addAll(additionalAnalysis['recommendations'] ?? {});

    final enhancedWarnings = Map<String, dynamic>.from(basicResult.warnings);
    enhancedWarnings.addAll(additionalAnalysis['warnings'] ?? {});

    return basicResult.copyWith(
      recommendations: enhancedRecommendations,
      warnings: enhancedWarnings,
      confidenceScore: basicResult.confidenceScore + 0.1, // 상세 분석으로 신뢰도 향상
    );
  }

  // 내부 헬퍼 메소드들
  static String _getHydrationRecommendation(Recipe recipe) {
    final hydration = recipe.hydrationPercentage;
    if (hydration < 60)
      return '수분량을 늘려 빵의 질감을 향상시키세요 (현재 ${hydration.toStringAsFixed(1)}%)';
    if (hydration > 75)
      return '수분량이 높아 반죽 관리가 어려울 수 있습니다 (현재 ${hydration.toStringAsFixed(1)}%)';
    return '수분량이 적절합니다 (${hydration.toStringAsFixed(1)}%)';
  }

  static String _getYeastRecommendation(Recipe recipe) {
    final yeastPercent = recipe.yeastPercentage;
    if (yeastPercent < 1.5)
      return '이스트량이 적어 발효 시간이 길어질 수 있습니다 (현재 ${yeastPercent.toStringAsFixed(1)}%)';
    if (yeastPercent > 3.0)
      return '이스트량이 많아 풍미가 저하될 수 있습니다 (현재 ${yeastPercent.toStringAsFixed(1)}%)';
    return '이스트량이 적절합니다 (${yeastPercent.toStringAsFixed(1)}%)';
  }

  static String _getSaltRecommendation(Recipe recipe) {
    final saltPercent = recipe.saltPercentage;
    if (saltPercent < 1.8)
      return '소금량을 늘려 빵의 풍미를 향상시키세요 (현재 ${saltPercent.toStringAsFixed(1)}%)';
    if (saltPercent > 2.2)
      return '소금량이 많아 반죽 발달이 느려질 수 있습니다 (현재 ${saltPercent.toStringAsFixed(1)}%)';
    return '소금량이 적절합니다 (${saltPercent.toStringAsFixed(1)}%)';
  }

  static String _getTemperatureRecommendation(BreadAnalysisData analysisData) {
    final temp = analysisData.environment.temperature;
    if (temp < 20)
      return '실내 온도가 낮아 발효 시간이 길어질 수 있습니다 (현재 ${temp.toStringAsFixed(1)}°C)';
    if (temp > 28)
      return '실내 온도가 높아 발효가 빨리 진행될 수 있습니다 (현재 ${temp.toStringAsFixed(1)}°C)';
    return '실내 온도가 적절합니다 (${temp.toStringAsFixed(1)}°C)';
  }

  static List<String> _getCriticalWarnings(
      Recipe recipe, BreadAnalysisData analysisData) {
    final warnings = <String>[];

    if (recipe.hydrationPercentage > 85) {
      warnings.add('수분량이 너무 높아 반죽이 흐물거릴 수 있습니다');
    }

    if (recipe.yeastPercentage > 4.0) {
      warnings.add('이스트량이 너무 많아 빵 맛이 저하될 수 있습니다');
    }

    if (analysisData.qualityMetadata.overallQualityScore < 50) {
      warnings.add('예측 품질 점수가 매우 낮습니다');
    }

    return warnings;
  }

  static List<String> _getModerateWarnings(
      Recipe recipe, BreadAnalysisData analysisData) {
    final warnings = <String>[];

    if (recipe.saltPercentage < 1.0) {
      warnings.add('소금량이 적어 빵 맛이 밋밋할 수 있습니다');
    }

    if (analysisData.environment.humidity < 40) {
      warnings.add('습도가 낮아 반죽 건조가 빨리 진행될 수 있습니다');
    }

    return warnings;
  }

  static double _calculateConfidenceScore(
      Recipe recipe, BreadAnalysisData analysisData) {
    double score = 0.8; // 기본 신뢰도

    // 재료 정보 완전성에 따른 조정
    if (recipe.ingredients.length >= 5) score += 0.05;
    if (recipe.ingredients.any((i) => i.isFlour)) score += 0.05;
    if (recipe.ingredients.any((i) => i.isYeast)) score += 0.05;
    if (recipe.ingredients.any((i) => i.isSalt)) score += 0.05;

    // 환경 정보 완전성에 따른 조정
    if (analysisData.environment.temperature != 25.0) score += 0.02;
    if (analysisData.environment.humidity != 65.0) score += 0.02;

    // 메타데이터 완전성에 따른 조정
    if (analysisData.ingredientMetadata.isNotEmpty) score += 0.03;

    return score.clamp(0.0, 1.0);
  }
}
