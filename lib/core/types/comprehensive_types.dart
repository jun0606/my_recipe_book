// 통합 재료 분석 타입들
// Week 2: 타입 시스템 재설계의 핵심

/// 시럽 분석 결과
class SyrupAnalysisResult {
  final double sugarContent;
  final double viscosity;
  final Map<String, dynamic> effects;
  final double confidence;

  const SyrupAnalysisResult({
    required this.sugarContent,
    required this.viscosity,
    required this.effects,
    this.confidence = 1.0,
  });

  factory SyrupAnalysisResult.empty() {
    return const SyrupAnalysisResult(
      sugarContent: 0.0,
      viscosity: 1.0,
      effects: {},
      confidence: 0.0,
    );
  }

  // 누락된 속성들 추가
  double get totalSyrupPercentage => sugarContent;
  Map<String, dynamic> get syrupEffects => effects;

  Map<String, dynamic> toJson() {
    return {
      'sugarContent': sugarContent,
      'viscosity': viscosity,
      'effects': effects,
      'confidence': confidence,
    };
  }

  factory SyrupAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SyrupAnalysisResult(
      sugarContent: json['sugarContent'] ?? 0.0,
      viscosity: json['viscosity'] ?? 1.0,
      effects: json['effects'] ?? {},
      confidence: json['confidence'] ?? 1.0,
    );
  }
}

/// 지방 분석 결과
class FatAnalysisResult {
  final double fatContent;
  final String fatType;
  final Map<String, dynamic> effects;
  final double confidence;

  const FatAnalysisResult({
    required this.fatContent,
    required this.fatType,
    required this.effects,
    this.confidence = 1.0,
  });

  factory FatAnalysisResult.empty() {
    return const FatAnalysisResult(
      fatContent: 0.0,
      fatType: 'unknown',
      effects: {},
      confidence: 0.0,
    );
  }

  // 누락된 속성들 추가
  double get totalFatPercentage => fatContent;
  Map<String, dynamic> get fatEffects => effects;

  Map<String, dynamic> toJson() {
    return {
      'fatContent': fatContent,
      'fatType': fatType,
      'effects': effects,
      'confidence': confidence,
    };
  }

  factory FatAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FatAnalysisResult(
      fatContent: json['fatContent'] ?? 0.0,
      fatType: json['fatType'] ?? 'unknown',
      effects: json['effects'] ?? {},
      confidence: json['confidence'] ?? 1.0,
    );
  }
}

/// 특수 반죽 감지 결과
class SpecialDoughDetectionResult {
  final List<String> detectedTypes;
  final Map<String, double> confidenceScores;
  final Map<String, dynamic> effects;

  const SpecialDoughDetectionResult({
    required this.detectedTypes,
    required this.confidenceScores,
    required this.effects,
  });

  factory SpecialDoughDetectionResult.empty() {
    return const SpecialDoughDetectionResult(
      detectedTypes: [],
      confidenceScores: {},
      effects: {},
    );
  }

  bool get hasSpecialDough => detectedTypes.isNotEmpty;

  double get highestConfidence => confidenceScores.isEmpty
      ? 0.0
      : confidenceScores.values.reduce((a, b) => a > b ? a : b);

  // 누락된 속성 추가
  String get primaryType =>
      detectedTypes.isNotEmpty ? detectedTypes.first : 'standard';

  Map<String, dynamic> toJson() {
    return {
      'detectedTypes': detectedTypes,
      'confidenceScores': confidenceScores,
      'effects': effects,
    };
  }

  factory SpecialDoughDetectionResult.fromJson(Map<String, dynamic> json) {
    return SpecialDoughDetectionResult(
      detectedTypes: List<String>.from(json['detectedTypes'] ?? []),
      confidenceScores:
          Map<String, double>.from(json['confidenceScores'] ?? {}),
      effects: json['effects'] ?? {},
    );
  }
}

/// 종합 재료 분석 결과
class ComprehensiveIngredientAnalysis {
  final SyrupAnalysisResult syrupAnalysis;
  final FatAnalysisResult fatAnalysis;
  final SpecialDoughDetectionResult specialDoughDetection;
  final Map<String, dynamic> integratedEffects;
  final DateTime timestamp;
  final String analysisId;

  ComprehensiveIngredientAnalysis({
    required this.syrupAnalysis,
    required this.fatAnalysis,
    required this.specialDoughDetection,
    required this.integratedEffects,
    required this.analysisId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 빈 분석 결과 생성
  factory ComprehensiveIngredientAnalysis.empty() {
    return ComprehensiveIngredientAnalysis(
      syrupAnalysis: SyrupAnalysisResult.empty(),
      fatAnalysis: FatAnalysisResult.empty(),
      specialDoughDetection: SpecialDoughDetectionResult.empty(),
      integratedEffects: {},
      analysisId: '',
    );
  }

  /// 믹싱 단계별 효과
  Map<String, dynamic> get mixingEffects {
    return {
      ...syrupAnalysis.effects,
      ...fatAnalysis.effects,
      ...specialDoughDetection.effects,
      ...integratedEffects['mixing'] ?? {},
    };
  }

  /// 반죽 형성 효과
  Map<String, dynamic> get doughEffects {
    return {
      ...syrupAnalysis.effects,
      ...fatAnalysis.effects,
      ...specialDoughDetection.effects,
      ...integratedEffects['dough'] ?? {},
    };
  }

  /// 발효 단계별 효과
  Map<String, dynamic> get fermentationEffects {
    return {
      ...syrupAnalysis.effects,
      ...fatAnalysis.effects,
      ...specialDoughDetection.effects,
      ...integratedEffects['fermentation'] ?? {},
    };
  }

  /// 굽기 단계별 효과
  Map<String, dynamic> get bakingEffects {
    return {
      ...syrupAnalysis.effects,
      ...fatAnalysis.effects,
      ...specialDoughDetection.effects,
      ...integratedEffects['baking'] ?? {},
    };
  }

  /// 종합 신뢰도 계산
  double get overallConfidence {
    final confidences = [
      syrupAnalysis.confidence,
      fatAnalysis.confidence,
      specialDoughDetection.highestConfidence,
    ];

    if (confidences.isEmpty) return 0.0;
    return confidences.reduce((a, b) => a + b) / confidences.length;
  }

  /// 분석 유효성 검증
  bool get isValid {
    return analysisId.isNotEmpty &&
        timestamp.isBefore(DateTime.now().add(const Duration(minutes: 1)));
  }

  Map<String, dynamic> toJson() {
    return {
      'syrupAnalysis': syrupAnalysis.toJson(),
      'fatAnalysis': fatAnalysis.toJson(),
      'specialDoughDetection': specialDoughDetection.toJson(),
      'integratedEffects': integratedEffects,
      'timestamp': timestamp.toIso8601String(),
      'analysisId': analysisId,
    };
  }

  factory ComprehensiveIngredientAnalysis.fromJson(Map<String, dynamic> json) {
    return ComprehensiveIngredientAnalysis(
      syrupAnalysis: SyrupAnalysisResult.fromJson(json['syrupAnalysis'] ?? {}),
      fatAnalysis: FatAnalysisResult.fromJson(json['fatAnalysis'] ?? {}),
      specialDoughDetection: SpecialDoughDetectionResult.fromJson(
        json['specialDoughDetection'] ?? {},
      ),
      integratedEffects: json['integratedEffects'] ?? {},
      analysisId: json['analysisId'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// 믹싱 분석 결과
class MixingAnalysisResult {
  final List<Map<String, dynamic>> optimizedSteps;
  final Map<String, dynamic> recommendations;
  final double confidenceScore;
  final Duration analysisTime;

  const MixingAnalysisResult({
    required this.optimizedSteps,
    required this.recommendations,
    required this.confidenceScore,
    required this.analysisTime,
  });

  factory MixingAnalysisResult.empty() {
    return const MixingAnalysisResult(
      optimizedSteps: [],
      recommendations: {},
      confidenceScore: 0.0,
      analysisTime: Duration.zero,
    );
  }

  bool get hasOptimizations => optimizedSteps.isNotEmpty;
  bool get isHighConfidence => confidenceScore >= 0.8;
}

/// 환경 분석 결과
class EnvironmentAnalysisResult {
  final List<String> recommendations;
  final Map<String, double> scores;
  final bool isOptimal;
  final Map<String, dynamic> details;

  const EnvironmentAnalysisResult({
    required this.recommendations,
    required this.scores,
    required this.isOptimal,
    required this.details,
  });

  factory EnvironmentAnalysisResult.empty() {
    return const EnvironmentAnalysisResult(
      recommendations: [],
      scores: {},
      isOptimal: false,
      details: {},
    );
  }

  double get overallScore {
    if (scores.isEmpty) return 0.0;
    return scores.values.reduce((a, b) => a + b) / scores.length;
  }
}

/// 분석 설정
class AnalysisSettings {
  final bool enableRealTimeFeedback;
  final bool enableRPMMode;
  final bool enableEffectsVisualization;
  final bool enableCaching;
  final int maxAnalysisTimeSeconds;
  final double confidenceThreshold;

  const AnalysisSettings({
    this.enableRealTimeFeedback = true,
    this.enableRPMMode = true,
    this.enableEffectsVisualization = true,
    this.enableCaching = true,
    this.maxAnalysisTimeSeconds = 30,
    this.confidenceThreshold = 0.7,
  });

  AnalysisSettings copyWith({
    bool? enableRealTimeFeedback,
    bool? enableRPMMode,
    bool? enableEffectsVisualization,
    bool? enableCaching,
    int? maxAnalysisTimeSeconds,
    double? confidenceThreshold,
  }) {
    return AnalysisSettings(
      enableRealTimeFeedback:
          enableRealTimeFeedback ?? this.enableRealTimeFeedback,
      enableRPMMode: enableRPMMode ?? this.enableRPMMode,
      enableEffectsVisualization:
          enableEffectsVisualization ?? this.enableEffectsVisualization,
      enableCaching: enableCaching ?? this.enableCaching,
      maxAnalysisTimeSeconds:
          maxAnalysisTimeSeconds ?? this.maxAnalysisTimeSeconds,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }
}

/// 제네릭 분석 결과 래퍼
class AnalysisResult<T> {
  final T? data;
  final bool success;
  final String? error;
  final Duration processingTime;
  final double confidence;

  const AnalysisResult({
    this.data,
    required this.success,
    this.error,
    required this.processingTime,
    required this.confidence,
  });

  factory AnalysisResult.success(T data, Duration processingTime,
      [double confidence = 1.0]) {
    return AnalysisResult(
      data: data,
      success: true,
      processingTime: processingTime,
      confidence: confidence,
    );
  }

  factory AnalysisResult.failure(String error, Duration processingTime) {
    return AnalysisResult(
      success: false,
      error: error,
      processingTime: processingTime,
      confidence: 0.0,
    );
  }

  bool get hasData => data != null;
  bool get isHighConfidence => confidence >= 0.8;
}

/// 분석 요청 DTO
class AnalysisRequest {
  final List<Map<String, dynamic>> ingredients;
  final String breadType;
  final AnalysisSettings settings;
  final Map<String, dynamic> environment;
  final String requestId;

  const AnalysisRequest({
    required this.ingredients,
    required this.breadType,
    required this.settings,
    required this.environment,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients,
      'breadType': breadType,
      'settings': settings,
      'environment': environment,
      'requestId': requestId,
    };
  }
}

/// 분석 응답 DTO
class AnalysisResponse {
  final ComprehensiveIngredientAnalysis? analysis;
  final MixingAnalysisResult? mixingResult;
  final EnvironmentAnalysisResult? environmentResult;
  final bool success;
  final String? error;
  final String requestId;
  final Duration totalProcessingTime;

  const AnalysisResponse({
    this.analysis,
    this.mixingResult,
    this.environmentResult,
    required this.success,
    this.error,
    required this.requestId,
    required this.totalProcessingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis?.toJson(),
      'mixingResult': mixingResult,
      'environmentResult': environmentResult,
      'success': success,
      'error': error,
      'requestId': requestId,
      'totalProcessingTime': totalProcessingTime.inMilliseconds,
    };
  }
}
