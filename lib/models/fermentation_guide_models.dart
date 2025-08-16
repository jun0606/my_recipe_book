/// 발효 가이드 관련 강타입 모델들
/// 
/// 이 파일은 발효 시스템의 모든 데이터 구조를 정의하여
/// 타입 안전성을 보장하고 런타임 오류를 방지합니다.

/// 발효 단계 정보
class FermentationStep {
  final String title;
  final String description;
  final int? durationMinutes;
  final double? temperature;
  final double? humidity;
  final List<String> checkpoints;
  final List<String> tips;

  const FermentationStep({
    required this.title,
    required this.description,
    this.durationMinutes,
    this.temperature,
    this.humidity,
    this.checkpoints = const [],
    this.tips = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'temperature': temperature,
      'humidity': humidity,
      'checkpoints': checkpoints,
      'tips': tips,
    };
  }
}

/// 발효 팁 정보
class FermentationTip {
  final String category;
  final String title;
  final String content;
  final String? icon;
  final int priority; // 1-5, 높을수록 중요

  const FermentationTip({
    required this.category,
    required this.title,
    required this.content,
    this.icon,
    this.priority = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'content': content,
      'icon': icon,
      'priority': priority,
    };
  }
}

/// 발효 경고 정보
class FermentationWarning {
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final List<String> preventionTips;
  final String? icon;

  const FermentationWarning({
    required this.title,
    required this.description,
    required this.severity,
    this.preventionTips = const [],
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'preventionTips': preventionTips,
      'icon': icon,
    };
  }
}

/// 환경 요인 분석 결과
class EnvironmentalAnalysis {
  final double currentTemperature;
  final double currentHumidity;
  final double optimalTemperature;
  final double optimalHumidity;
  final String temperatureStatus; // 'too_low', 'optimal', 'too_high'
  final String humidityStatus; // 'too_low', 'optimal', 'too_high'
  final List<String> adjustmentTips;
  final String overallAssessment;

  const EnvironmentalAnalysis({
    required this.currentTemperature,
    required this.currentHumidity,
    required this.optimalTemperature,
    required this.optimalHumidity,
    required this.temperatureStatus,
    required this.humidityStatus,
    this.adjustmentTips = const [],
    required this.overallAssessment,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentTemperature': currentTemperature,
      'currentHumidity': currentHumidity,
      'optimalTemperature': optimalTemperature,
      'optimalHumidity': optimalHumidity,
      'temperatureStatus': temperatureStatus,
      'humidityStatus': humidityStatus,
      'adjustmentTips': adjustmentTips,
      'overallAssessment': overallAssessment,
    };
  }
}

/// 레시피 요인 분석 결과
class RecipeAnalysis {
  final double yeastAmount;
  final double sugarAmount;
  final String yeastType;
  final String yeastStatus; // 'insufficient', 'optimal', 'excessive'
  final String sugarStatus; // 'insufficient', 'optimal', 'excessive'
  final List<String> optimizationTips;
  final int estimatedFermentationTimeMinutes;
  final String overallAssessment;

  const RecipeAnalysis({
    required this.yeastAmount,
    required this.sugarAmount,
    required this.yeastType,
    required this.yeastStatus,
    required this.sugarStatus,
    this.optimizationTips = const [],
    required this.estimatedFermentationTimeMinutes,
    required this.overallAssessment,
  });

  Map<String, dynamic> toJson() {
    return {
      'yeastAmount': yeastAmount,
      'sugarAmount': sugarAmount,
      'yeastType': yeastType,
      'yeastStatus': yeastStatus,
      'sugarStatus': sugarStatus,
      'optimizationTips': optimizationTips,
      'estimatedFermentationTimeMinutes': estimatedFermentationTimeMinutes,
      'overallAssessment': overallAssessment,
    };
  }
}

/// 발효 추천사항
class FermentationRecommendation {
  final String category;
  final String title;
  final String description;
  final List<String> actionItems;
  final String priority; // 'low', 'medium', 'high'
  final String? reasoning;

  const FermentationRecommendation({
    required this.category,
    required this.title,
    required this.description,
    this.actionItems = const [],
    this.priority = 'medium',
    this.reasoning,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'actionItems': actionItems,
      'priority': priority,
      'reasoning': reasoning,
    };
  }
}

/// 빠른 시작 가이드
class QuickStartGuide {
  final String title;
  final List<String> steps;
  final int estimatedTimeMinutes;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final List<String> requiredTools;
  final List<String> keyTips;

  const QuickStartGuide({
    required this.title,
    this.steps = const [],
    required this.estimatedTimeMinutes,
    this.difficulty = 'beginner',
    this.requiredTools = const [],
    this.keyTips = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'steps': steps,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'difficulty': difficulty,
      'requiredTools': requiredTools,
      'keyTips': keyTips,
    };
  }
}

/// 통합 발효 가이드 모델
class FermentationGuide {
  final String id;
  final String name;
  final String type; // 'room_temperature', 'cold', 'warm', 'custom'
  final String description;
  
  // 방법 설명
  final String methodExplanation;
  
  // 맞춤 지침
  final List<String> customInstructions;
  
  // 단계별 가이드
  final List<FermentationStep> steps;
  
  // 팁들
  final List<FermentationTip> tips;
  
  // 경고사항
  final List<FermentationWarning> warnings;
  
  // 환경 분석
  final EnvironmentalAnalysis? environmentalAnalysis;
  
  // 레시피 분석
  final RecipeAnalysis? recipeAnalysis;
  
  // 추천사항
  final List<FermentationRecommendation> recommendations;
  
  // 빠른 시작 가이드
  final QuickStartGuide? quickStartGuide;
  
  // 메타데이터
  final String createdAt;
  final String? updatedAt;
  final Map<String, dynamic> metadata;

  const FermentationGuide({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.methodExplanation,
    this.customInstructions = const [],
    this.steps = const [],
    this.tips = const [],
    this.warnings = const [],
    this.environmentalAnalysis,
    this.recipeAnalysis,
    this.recommendations = const [],
    this.quickStartGuide,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'methodExplanation': methodExplanation,
      'customInstructions': customInstructions,
      'steps': steps.map((step) => step.toJson()).toList(),
      'tips': tips.map((tip) => tip.toJson()).toList(),
      'warnings': warnings.map((warning) => warning.toJson()).toList(),
      'environmentalAnalysis': environmentalAnalysis?.toJson(),
      'recipeAnalysis': recipeAnalysis?.toJson(),
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'quickStartGuide': quickStartGuide?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'metadata': metadata,
    };
  }

  /// UI 호환성을 위한 레거시 Map 형태로 변환
  /// 기존 UI 컴포넌트들이 기대하는 형태로 데이터를 제공
  Map<String, dynamic> toLegacyMap() {
    return {
      'methodExplanation': methodExplanation,
      'customInstructions': customInstructions,
      'tips': tips.map((tip) => {
        'category': tip.category,
        'title': tip.title,
        'content': tip.content,
        'priority': tip.priority,
      }).toList(),
      'warnings': warnings.map((warning) => {
        'title': warning.title,
        'description': warning.description,
        'severity': warning.severity,
        'preventionTips': warning.preventionTips,
      }).toList(),
      'environmentalFactors': environmentalAnalysis?.toJson() ?? {},
      'recipeFactors': recipeAnalysis?.toJson() ?? {},
      'recommendations': recommendations.map((rec) => {
        'category': rec.category,
        'title': rec.title,
        'description': rec.description,
        'actionItems': rec.actionItems,
        'priority': rec.priority,
      }).toList(),
      'quickStartTips': quickStartGuide?.keyTips ?? [],
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  /// 복사본 생성 (불변성 유지)
  FermentationGuide copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? methodExplanation,
    List<String>? customInstructions,
    List<FermentationStep>? steps,
    List<FermentationTip>? tips,
    List<FermentationWarning>? warnings,
    EnvironmentalAnalysis? environmentalAnalysis,
    RecipeAnalysis? recipeAnalysis,
    List<FermentationRecommendation>? recommendations,
    QuickStartGuide? quickStartGuide,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FermentationGuide(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      methodExplanation: methodExplanation ?? this.methodExplanation,
      customInstructions: customInstructions ?? this.customInstructions,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      warnings: warnings ?? this.warnings,
      environmentalAnalysis: environmentalAnalysis ?? this.environmentalAnalysis,
      recipeAnalysis: recipeAnalysis ?? this.recipeAnalysis,
      recommendations: recommendations ?? this.recommendations,
      quickStartGuide: quickStartGuide ?? this.quickStartGuide,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}