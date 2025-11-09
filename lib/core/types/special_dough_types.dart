// lib/core/types/special_dough_types.dart
// 특수 반죽 타입 시스템 - 타입 안전한 특수 반죽 분석 정보 공유

import 'dart:convert';

/// 특수 반죽 타입 - 타입 안전한 열거형
enum SpecialDoughType {
  // 기본 반죽
  standard('표준 반죽'),

  // 사워종 계열
  sourdough('사워종'),
  levain('르방'),

  // 탕종 계열
  tangzhong('탕종'),

  // 프랑스 빵 계열
  frenchBaguette('프랑스 바게트'),
  frenchCroissant('크루아상'),

  // 파이 계열
  puffPastry('퍼프 페이스트리'),
  shortcrustPastry('쇼트크러스트'),
  flakyPastry('플레이크 페이스트리'),

  // 이탈리아 빵 계열
  poolish('풀리쉬'),
  biga('비가'),

  // 기타 특수 반죽
  brioche('브리오슈'),
  challah('할라'),
  ciabatta('치아바타');

  const SpecialDoughType(this.displayName);
  final String displayName;

  /// JSON 직렬화 지원
  String toJson() => name;

  /// JSON 역직렬화 지원
  static SpecialDoughType fromJson(String json) {
    return SpecialDoughType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => SpecialDoughType.standard,
    );
  }

  /// 특수 반죽 여부 확인
  bool get isSpecial => this != SpecialDoughType.standard;

  /// 추천 믹싱 속도
  String get recommendedMixingSpeed {
    switch (this) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return '중속';
      case SpecialDoughType.tangzhong:
        return '저속';
      case SpecialDoughType.frenchBaguette:
        return '중속';
      case SpecialDoughType.frenchCroissant:
        return '저속';
      case SpecialDoughType.puffPastry:
      case SpecialDoughType.shortcrustPastry:
      case SpecialDoughType.flakyPastry:
        return '저속';
      case SpecialDoughType.poolish:
      case SpecialDoughType.biga:
        return '중속';
      case SpecialDoughType.brioche:
        return '중속';
      case SpecialDoughType.challah:
        return '중속';
      case SpecialDoughType.ciabatta:
        return '저속';
      default:
        return '중속';
    }
  }

  /// 추천 믹싱 시간 (분)
  int get recommendedMixingTime {
    switch (this) {
      case SpecialDoughType.sourdough:
      case SpecialDoughType.levain:
        return 12;
      case SpecialDoughType.tangzhong:
        return 8;
      case SpecialDoughType.frenchBaguette:
        return 15;
      case SpecialDoughType.frenchCroissant:
        return 8;
      case SpecialDoughType.puffPastry:
        return 6;
      case SpecialDoughType.shortcrustPastry:
        return 5;
      case SpecialDoughType.flakyPastry:
        return 4;
      case SpecialDoughType.poolish:
        return 12;
      case SpecialDoughType.biga:
        return 10;
      case SpecialDoughType.brioche:
        return 10;
      case SpecialDoughType.challah:
        return 12;
      case SpecialDoughType.ciabatta:
        return 8;
      default:
        return 10;
    }
  }
}

/// 특수 반죽 감지 결과 - 타입 안전한 데이터 구조
class SpecialDoughDetectionResult {
  final bool hasSpecialDough;
  final SpecialDoughType primaryType;
  final List<SpecialDoughType> detectedTypes;
  final Map<SpecialDoughType, double> confidenceScores;
  final List<String> detectionReasons;

  const SpecialDoughDetectionResult({
    required this.hasSpecialDough,
    required this.primaryType,
    required this.detectedTypes,
    required this.confidenceScores,
    required this.detectionReasons,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
        'hasSpecialDough': hasSpecialDough,
        'primaryType': primaryType.toJson(),
        'detectedTypes': detectedTypes.map((type) => type.toJson()).toList(),
        'confidenceScores':
            confidenceScores.map((key, value) => MapEntry(key.toJson(), value)),
        'detectionReasons': detectionReasons,
      };

  /// JSON 역직렬화
  factory SpecialDoughDetectionResult.fromJson(Map<String, dynamic> json) {
    return SpecialDoughDetectionResult(
      hasSpecialDough: json['hasSpecialDough'] as bool,
      primaryType: SpecialDoughType.fromJson(json['primaryType'] as String),
      detectedTypes: (json['detectedTypes'] as List<String>)
          .map((type) => SpecialDoughType.fromJson(type))
          .toList(),
      confidenceScores: (json['confidenceScores'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              SpecialDoughType.fromJson(key), (value as num).toDouble())),
      detectionReasons: List<String>.from(json['detectionReasons'] as List),
    );
  }

  /// 복합 특수 반죽 판정 헬퍼 메소드
  bool get hasComplexDough => detectedTypes.length > 1;

  /// 특정 타입 포함 여부 확인
  bool hasType(SpecialDoughType type) => detectedTypes.contains(type);

  /// 최고 신뢰도 타입 반환
  SpecialDoughType get highestConfidenceType {
    if (confidenceScores.isEmpty) return primaryType;

    return confidenceScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 평균 신뢰도 계산
  double get averageConfidence {
    if (confidenceScores.isEmpty) return 0.0;
    final total = confidenceScores.values.reduce((a, b) => a + b);
    return total / confidenceScores.length;
  }

  /// 신뢰도 레벨 반환
  String get confidenceLevel {
    final avg = averageConfidence;
    if (avg >= 0.8) return '높음';
    if (avg >= 0.6) return '중간';
    if (avg >= 0.4) return '낮음';
    return '매우 낮음';
  }
}

/// 특수 반죽 물리화학적 특성 - 타입 안전한 데이터 구조
class SpecialDoughCharacteristics {
  final double viscosityMultiplier;
  final double elasticityMultiplier;
  final double extensibilityMultiplier;
  final double absorptionRateMultiplier;
  final double glutenStrengthMultiplier;
  final double fermentationToleranceMultiplier;

  const SpecialDoughCharacteristics({
    required this.viscosityMultiplier,
    required this.elasticityMultiplier,
    required this.extensibilityMultiplier,
    required this.absorptionRateMultiplier,
    required this.glutenStrengthMultiplier,
    required this.fermentationToleranceMultiplier,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
        'viscosityMultiplier': viscosityMultiplier,
        'elasticityMultiplier': elasticityMultiplier,
        'extensibilityMultiplier': extensibilityMultiplier,
        'absorptionRateMultiplier': absorptionRateMultiplier,
        'glutenStrengthMultiplier': glutenStrengthMultiplier,
        'fermentationToleranceMultiplier': fermentationToleranceMultiplier,
      };

  /// JSON 역직렬화
  factory SpecialDoughCharacteristics.fromJson(Map<String, dynamic> json) {
    return SpecialDoughCharacteristics(
      viscosityMultiplier: (json['viscosityMultiplier'] as num).toDouble(),
      elasticityMultiplier: (json['elasticityMultiplier'] as num).toDouble(),
      extensibilityMultiplier:
          (json['extensibilityMultiplier'] as num).toDouble(),
      absorptionRateMultiplier:
          (json['absorptionRateMultiplier'] as num).toDouble(),
      glutenStrengthMultiplier:
          (json['glutenStrengthMultiplier'] as num).toDouble(),
      fermentationToleranceMultiplier:
          (json['fermentationToleranceMultiplier'] as num).toDouble(),
    );
  }

  /// 기본 특성으로 초기화
  factory SpecialDoughCharacteristics.standard() {
    return const SpecialDoughCharacteristics(
      viscosityMultiplier: 1.0,
      elasticityMultiplier: 1.0,
      extensibilityMultiplier: 1.0,
      absorptionRateMultiplier: 1.0,
      glutenStrengthMultiplier: 1.0,
      fermentationToleranceMultiplier: 1.0,
    );
  }

  /// 특수 반죽별 특성 팩토리 메소드
  factory SpecialDoughCharacteristics.fromType(SpecialDoughType doughType) {
    switch (doughType) {
      case SpecialDoughType.sourdough:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 1.3,
          elasticityMultiplier: 1.4,
          extensibilityMultiplier: 0.9,
          absorptionRateMultiplier: 1.1,
          glutenStrengthMultiplier: 1.5,
          fermentationToleranceMultiplier: 1.6,
        );

      case SpecialDoughType.levain:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 1.2,
          elasticityMultiplier: 1.3,
          extensibilityMultiplier: 1.0,
          absorptionRateMultiplier: 1.05,
          glutenStrengthMultiplier: 1.3,
          fermentationToleranceMultiplier: 1.4,
        );

      case SpecialDoughType.tangzhong:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 0.9,
          elasticityMultiplier: 1.2,
          extensibilityMultiplier: 1.2,
          absorptionRateMultiplier: 1.15,
          glutenStrengthMultiplier: 1.1,
          fermentationToleranceMultiplier: 1.1,
        );

      case SpecialDoughType.frenchBaguette:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 1.1,
          elasticityMultiplier: 1.3,
          extensibilityMultiplier: 1.3,
          absorptionRateMultiplier: 1.1,
          glutenStrengthMultiplier: 1.2,
          fermentationToleranceMultiplier: 1.2,
        );

      case SpecialDoughType.frenchCroissant:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 0.8,
          elasticityMultiplier: 1.1,
          extensibilityMultiplier: 0.8,
          absorptionRateMultiplier: 0.9,
          glutenStrengthMultiplier: 0.9,
          fermentationToleranceMultiplier: 0.8,
        );

      case SpecialDoughType.puffPastry:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 0.8,
          elasticityMultiplier: 0.9,
          extensibilityMultiplier: 0.7,
          absorptionRateMultiplier: 0.85,
          glutenStrengthMultiplier: 0.8,
          fermentationToleranceMultiplier: 0.7,
        );

      case SpecialDoughType.shortcrustPastry:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 0.9,
          elasticityMultiplier: 0.8,
          extensibilityMultiplier: 0.6,
          absorptionRateMultiplier: 0.8,
          glutenStrengthMultiplier: 0.7,
          fermentationToleranceMultiplier: 0.6,
        );

      case SpecialDoughType.flakyPastry:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 0.85,
          elasticityMultiplier: 0.85,
          extensibilityMultiplier: 0.65,
          absorptionRateMultiplier: 0.82,
          glutenStrengthMultiplier: 0.75,
          fermentationToleranceMultiplier: 0.65,
        );

      case SpecialDoughType.poolish:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 1.1,
          elasticityMultiplier: 1.2,
          extensibilityMultiplier: 1.1,
          absorptionRateMultiplier: 1.05,
          glutenStrengthMultiplier: 1.1,
          fermentationToleranceMultiplier: 1.3,
        );

      case SpecialDoughType.biga:
        return const SpecialDoughCharacteristics(
          viscosityMultiplier: 1.05,
          elasticityMultiplier: 1.15,
          extensibilityMultiplier: 1.05,
          absorptionRateMultiplier: 1.02,
          glutenStrengthMultiplier: 1.05,
          fermentationToleranceMultiplier: 1.2,
        );

      default:
        return SpecialDoughCharacteristics.standard();
    }
  }

  /// 특성 설명 텍스트
  String get characteristicsDescription {
    final descriptions = <String>[];

    if (viscosityMultiplier > 1.2) {
      descriptions.add('높은 점성');
    } else if (viscosityMultiplier < 0.9) {
      descriptions.add('낮은 점성');
    }

    if (elasticityMultiplier > 1.2) {
      descriptions.add('높은 탄성');
    } else if (elasticityMultiplier < 0.9) {
      descriptions.add('낮은 탄성');
    }

    if (extensibilityMultiplier > 1.2) {
      descriptions.add('높은 신장성');
    } else if (extensibilityMultiplier < 0.9) {
      descriptions.add('낮은 신장성');
    }

    if (absorptionRateMultiplier > 1.1) {
      descriptions.add('높은 수분 흡수율');
    } else if (absorptionRateMultiplier < 0.9) {
      descriptions.add('낮은 수분 흡수율');
    }

    if (glutenStrengthMultiplier > 1.2) {
      descriptions.add('강한 글루텐');
    } else if (glutenStrengthMultiplier < 0.9) {
      descriptions.add('약한 글루텐');
    }

    return descriptions.isEmpty ? '표준 특성' : descriptions.join(', ');
  }
}

/// 특수 반죽 분석 결과를 포함한 확장된 빵 분석 결과
class SpecialDoughBreadAnalysisResult {
  final String analysisId;
  final String doughType;
  final DateTime timestamp;
  final bool isSuccessful;
  final String? errorMessage;
  final Map<String, dynamic> data;

  // 단계별 분석 결과
  final Map<String, dynamic> mixingAnalysis;
  final Map<String, dynamic> doughAnalysis;
  final Map<String, dynamic> fermentationAnalysis;
  final Map<String, dynamic> ovenAnalysis;
  final Map<String, dynamic> finalResult;

  // 특수 반죽 분석 정보
  final SpecialDoughDetectionResult specialDoughDetection;
  final SpecialDoughCharacteristics doughCharacteristics;
  final List<String> recommendedTechniques;
  final Map<String, dynamic> specialDoughMetadata;

  const SpecialDoughBreadAnalysisResult({
    required this.analysisId,
    required this.doughType,
    required this.timestamp,
    required this.isSuccessful,
    this.errorMessage,
    required this.data,
    required this.mixingAnalysis,
    required this.doughAnalysis,
    required this.fermentationAnalysis,
    required this.ovenAnalysis,
    required this.finalResult,
    required this.specialDoughDetection,
    required this.doughCharacteristics,
    required this.recommendedTechniques,
    required this.specialDoughMetadata,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'doughType': doughType,
      'timestamp': timestamp.toIso8601String(),
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
      'data': data,
      'mixingAnalysis': mixingAnalysis,
      'doughAnalysis': doughAnalysis,
      'fermentationAnalysis': fermentationAnalysis,
      'ovenAnalysis': ovenAnalysis,
      'finalResult': finalResult,
      'specialDoughDetection': specialDoughDetection.toJson(),
      'doughCharacteristics': doughCharacteristics.toJson(),
      'recommendedTechniques': recommendedTechniques,
      'specialDoughMetadata': specialDoughMetadata,
    };
  }

  /// JSON 역직렬화
  factory SpecialDoughBreadAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SpecialDoughBreadAnalysisResult(
      analysisId: json['analysisId'] as String,
      doughType: json['doughType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSuccessful: json['isSuccessful'] as bool,
      errorMessage: json['errorMessage'] as String?,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      mixingAnalysis: Map<String, dynamic>.from(json['mixingAnalysis'] ?? {}),
      doughAnalysis: Map<String, dynamic>.from(json['doughAnalysis'] ?? {}),
      fermentationAnalysis:
          Map<String, dynamic>.from(json['fermentationAnalysis'] ?? {}),
      ovenAnalysis: Map<String, dynamic>.from(json['ovenAnalysis'] ?? {}),
      finalResult: Map<String, dynamic>.from(json['finalResult'] ?? {}),
      specialDoughDetection:
          SpecialDoughDetectionResult.fromJson(json['specialDoughDetection']),
      doughCharacteristics:
          SpecialDoughCharacteristics.fromJson(json['doughCharacteristics']),
      recommendedTechniques:
          List<String>.from(json['recommendedTechniques'] ?? []),
      specialDoughMetadata:
          Map<String, dynamic>.from(json['specialDoughMetadata'] ?? {}),
    );
  }

  /// 헬퍼 메소드들
  bool get hasSpecialDough => specialDoughDetection.hasSpecialDough;
  SpecialDoughType get primarySpecialDoughType =>
      specialDoughDetection.primaryType;
  bool get hasComplexDough => specialDoughDetection.hasComplexDough;

  /// 특수 반죽 요약 정보
  String get specialDoughSummary {
    if (!hasSpecialDough) return '표준 반죽';

    final typeName = primarySpecialDoughType.displayName;
    final confidence = specialDoughDetection.averageConfidence;
    final level = specialDoughDetection.confidenceLevel;

    return '$typeName (신뢰도: $level, ${(confidence * 100).toInt()}%)';
  }

  /// 분석 상태 텍스트
  String get analysisStatusText {
    if (!isSuccessful) return '분석 실패: ${errorMessage ?? "알 수 없는 오류"}';
    if (hasSpecialDough) return '특수 반죽 분석 완료: $specialDoughSummary';
    return '표준 반죽 분석 완료';
  }
}

/// 특수 반죽 분석 이벤트 데이터
abstract class SpecialDoughEventData {
  final String recipeId;
  final SpecialDoughDetectionResult detectionResult;
  final DateTime timestamp;

  SpecialDoughEventData({
    required this.recipeId,
    required this.detectionResult,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 특수 반죽 감지 완료 이벤트
class SpecialDoughDetectedEvent extends SpecialDoughEventData {
  final SpecialDoughCharacteristics characteristics;
  final List<String> recommendedTechniques;

  SpecialDoughDetectedEvent({
    required super.recipeId,
    required super.detectionResult,
    required this.characteristics,
    required this.recommendedTechniques,
    super.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'eventType': 'specialDoughDetected',
        'recipeId': recipeId,
        'detectionResult': detectionResult.toJson(),
        'characteristics': characteristics.toJson(),
        'recommendedTechniques': recommendedTechniques,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 특수 반죽 분석 실패 이벤트
class SpecialDoughAnalysisFailedEvent extends SpecialDoughEventData {
  final String errorMessage;
  final String? errorCode;

  SpecialDoughAnalysisFailedEvent({
    required super.recipeId,
    required super.detectionResult,
    required this.errorMessage,
    this.errorCode,
    super.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'eventType': 'specialDoughAnalysisFailed',
        'recipeId': recipeId,
        'detectionResult': detectionResult.toJson(),
        'errorMessage': errorMessage,
        'errorCode': errorCode,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 특수 반죽 캐시 업데이트 이벤트
class SpecialDoughCacheUpdatedEvent {
  final String recipeId;
  final bool isCached;
  final DateTime? cacheTimestamp;
  final DateTime timestamp;

  SpecialDoughCacheUpdatedEvent({
    required this.recipeId,
    required this.isCached,
    this.cacheTimestamp,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'eventType': 'specialDoughCacheUpdated',
        'recipeId': recipeId,
        'isCached': isCached,
        'cacheTimestamp': cacheTimestamp?.toIso8601String(),
        'timestamp': timestamp.toIso8601String(),
      };
}
