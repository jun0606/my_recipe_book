import 'dart:convert';
import 'enhanced_recipe.dart';
import 'environmental_conditions.dart';
import 'cost_analysis.dart';

/// 검증 수준 열거형
enum ValidationLevel {
  error('error', '오류'),
  warning('warning', '경고'),
  info('info', '정보');

  const ValidationLevel(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 검증 경고 정보
class ValidationWarning {
  final ValidationLevel level;
  final String message;
  final String? suggestion;
  final String? category;

  const ValidationWarning({
    required this.level,
    required this.message,
    this.suggestion,
    this.category,
  });

  ValidationWarning.error(this.message, {this.suggestion, this.category})
      : level = ValidationLevel.error;

  ValidationWarning.warning(this.message, {this.suggestion, this.category})
      : level = ValidationLevel.warning;

  ValidationWarning.info(this.message, {this.suggestion, this.category})
      : level = ValidationLevel.info;

  Map<String, dynamic> toJson() {
    return {
      'level': level.value,
      'message': message,
      'suggestion': suggestion,
      'category': category,
    };
  }

  factory ValidationWarning.fromJson(Map<String, dynamic> json) {
    return ValidationWarning(
      level: ValidationLevel.values.firstWhere(
        (level) => level.value == json['level'],
        orElse: () => ValidationLevel.info,
      ),
      message: json['message'] ?? '',
      suggestion: json['suggestion'],
      category: json['category'],
    );
  }
}

/// 제안 정보
class Suggestion {
  final String title;
  final String description;
  final String? actionText;
  final Map<String, dynamic>? actionData;
  final double priority; // 0.0 - 1.0

  const Suggestion({
    required this.title,
    required this.description,
    this.actionText,
    this.actionData,
    this.priority = 0.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'actionText': actionText,
      'actionData': actionData,
      'priority': priority,
    };
  }

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      actionText: json['actionText'],
      actionData: json['actionData'],
      priority: json['priority']?.toDouble() ?? 0.5,
    );
  }
}

// EnvironmentalAdjustment는 environmental_conditions.dart에서 import됨

/// 베이킹 계산 모드 열거형
enum BakingCalculationMode {
  scaleAdjustment('scale', '배율 조정'),
  splitByCount('splitCount', '분할 수량'),
  splitByWeight('splitWeight', '분할 무게'),
  scaleAndSplit('scaleAndSplit', '배율+분할'),
  dynamicComparison('dynamic', '동적 비교'),
  optimalSplit('optimal', '최적 분할'),
  bakersPercentage('percentage', '베이커스 퍼센트'),
  hydrationAdjustment('hydration', '수분 조정');

  const BakingCalculationMode(this.value, this.displayName);
  final String value;
  final String displayName;

  static BakingCalculationMode fromString(String value) {
    return BakingCalculationMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => BakingCalculationMode.scaleAdjustment,
    );
  }
}

/// 베이킹 계산 결과
class BakingCalculationResult {
  final EnhancedRecipe originalRecipe;
  final EnhancedRecipe calculatedRecipe;
  final BakingCalculationMode calculationMode;
  final Map<String, dynamic> calculations;
  final List<ValidationWarning> warnings;
  final List<Suggestion> suggestions;
  final EnvironmentalAdjustment? environmentalAdjustment;
  final CostAnalysis? costAnalysis;
  final DateTime calculatedAt;
  final double? totalWeight;
  final double? splitWeight;
  final int? splitCount;
  final double? remainingWeight;
  final double? scale;
  final bool isOptimized;

  BakingCalculationResult({
    required this.originalRecipe,
    required this.calculatedRecipe,
    required this.calculationMode,
    required this.calculations,
    this.warnings = const [],
    this.suggestions = const [],
    this.environmentalAdjustment,
    this.costAnalysis,
    DateTime? calculatedAt,
    this.totalWeight,
    this.splitWeight,
    this.splitCount,
    this.remainingWeight,
    this.scale,
    this.isOptimized = false,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'originalRecipe': originalRecipe.toJson(),
      'calculatedRecipe': calculatedRecipe.toJson(),
      'calculationMode': calculationMode.value,
      'calculations': calculations,
      'warnings': warnings.map((w) => w.toJson()).toList(),
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'environmentalAdjustment': environmentalAdjustment?.toJson(),
      'costAnalysis': costAnalysis?.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
      'totalWeight': totalWeight,
      'splitWeight': splitWeight,
      'splitCount': splitCount,
      'remainingWeight': remainingWeight,
      'scale': scale,
      'isOptimized': isOptimized,
    };
  }

  factory BakingCalculationResult.fromJson(Map<String, dynamic> json) {
    return BakingCalculationResult(
      originalRecipe: EnhancedRecipe.fromJson(json['originalRecipe']),
      calculatedRecipe: EnhancedRecipe.fromJson(json['calculatedRecipe']),
      calculationMode:
          BakingCalculationMode.fromString(json['calculationMode'] ?? 'scale'),
      calculations: Map<String, dynamic>.from(json['calculations'] ?? {}),
      warnings: List<ValidationWarning>.from(
        json['warnings']?.map((w) => ValidationWarning.fromJson(w)) ?? [],
      ),
      suggestions: List<Suggestion>.from(
        json['suggestions']?.map((s) => Suggestion.fromJson(s)) ?? [],
      ),
      environmentalAdjustment: json['environmentalAdjustment'] != null
          ? EnvironmentalAdjustment.fromJson(json['environmentalAdjustment'])
          : null,
      costAnalysis: json['costAnalysis'] != null
          ? CostAnalysis.fromJson(json['costAnalysis'])
          : null,
      calculatedAt: DateTime.parse(
          json['calculatedAt'] ?? DateTime.now().toIso8601String()),
      totalWeight: json['totalWeight']?.toDouble(),
      splitWeight: json['splitWeight']?.toDouble(),
      splitCount: json['splitCount'],
      remainingWeight: json['remainingWeight']?.toDouble(),
      scale: json['scale']?.toDouble(),
      isOptimized: json['isOptimized'] ?? false,
    );
  }

  BakingCalculationResult copyWith({
    EnhancedRecipe? originalRecipe,
    EnhancedRecipe? calculatedRecipe,
    BakingCalculationMode? calculationMode,
    Map<String, dynamic>? calculations,
    List<ValidationWarning>? warnings,
    List<Suggestion>? suggestions,
    EnvironmentalAdjustment? environmentalAdjustment,
    CostAnalysis? costAnalysis,
    DateTime? calculatedAt,
    double? totalWeight,
    double? splitWeight,
    int? splitCount,
    double? remainingWeight,
    double? scale,
    bool? isOptimized,
  }) {
    return BakingCalculationResult(
      originalRecipe: originalRecipe ?? this.originalRecipe,
      calculatedRecipe: calculatedRecipe ?? this.calculatedRecipe,
      calculationMode: calculationMode ?? this.calculationMode,
      calculations: calculations ?? this.calculations,
      warnings: warnings ?? this.warnings,
      suggestions: suggestions ?? this.suggestions,
      environmentalAdjustment:
          environmentalAdjustment ?? this.environmentalAdjustment,
      costAnalysis: costAnalysis ?? this.costAnalysis,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      totalWeight: totalWeight ?? this.totalWeight,
      splitWeight: splitWeight ?? this.splitWeight,
      splitCount: splitCount ?? this.splitCount,
      remainingWeight: remainingWeight ?? this.remainingWeight,
      scale: scale ?? this.scale,
      isOptimized: isOptimized ?? this.isOptimized,
    );
  }
}

/// 발효 스케줄 정보
class FermentationSchedule {
  final Duration bulkFermentation; // 1차 발효
  final Duration finalProof; // 2차 발효
  final Duration totalTime; // 총 시간
  final double temperature; // 발효 온도
  final List<String> notes; // 발효 노트

  const FermentationSchedule({
    required this.bulkFermentation,
    required this.finalProof,
    required this.totalTime,
    required this.temperature,
    this.notes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'bulkFermentation': bulkFermentation.inMinutes,
      'finalProof': finalProof.inMinutes,
      'totalTime': totalTime.inMinutes,
      'temperature': temperature,
      'notes': notes,
    };
  }

  factory FermentationSchedule.fromJson(Map<String, dynamic> json) {
    return FermentationSchedule(
      bulkFermentation: Duration(minutes: json['bulkFermentation'] ?? 0),
      finalProof: Duration(minutes: json['finalProof'] ?? 0),
      totalTime: Duration(minutes: json['totalTime'] ?? 0),
      temperature: json['temperature']?.toDouble() ?? 25.0,
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

/// 빵 계산 결과 (특화)
class BreadCalculationResult extends BakingCalculationResult {
  final Map<String, double> bakersPercentages;
  final double currentHydration;
  final double targetHydration;
  final FermentationSchedule fermentationSchedule;

  BreadCalculationResult({
    required super.originalRecipe,
    required super.calculatedRecipe,
    required super.calculationMode,
    required super.calculations,
    super.warnings,
    super.suggestions,
    super.environmentalAdjustment,
    super.costAnalysis,
    super.calculatedAt,
    super.totalWeight,
    super.splitWeight,
    super.splitCount,
    super.remainingWeight,
    super.scale,
    super.isOptimized,
    required this.bakersPercentages,
    required this.currentHydration,
    required this.targetHydration,
    required this.fermentationSchedule,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'bakersPercentages': bakersPercentages,
      'currentHydration': currentHydration,
      'targetHydration': targetHydration,
      'fermentationSchedule': fermentationSchedule.toJson(),
    };
  }

  factory BreadCalculationResult.fromJson(Map<String, dynamic> json) {
    final base = BakingCalculationResult.fromJson(json);
    return BreadCalculationResult(
      originalRecipe: base.originalRecipe,
      calculatedRecipe: base.calculatedRecipe,
      calculationMode: base.calculationMode,
      calculations: base.calculations,
      warnings: base.warnings,
      suggestions: base.suggestions,
      environmentalAdjustment: base.environmentalAdjustment,
      costAnalysis: base.costAnalysis,
      calculatedAt: base.calculatedAt,
      totalWeight: base.totalWeight,
      splitWeight: base.splitWeight,
      splitCount: base.splitCount,
      remainingWeight: base.remainingWeight,
      scale: base.scale,
      isOptimized: base.isOptimized,
      bakersPercentages: Map<String, double>.from(
        json['bakersPercentages']
                ?.map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0)) ??
            {},
      ),
      currentHydration: json['currentHydration']?.toDouble() ?? 0.0,
      targetHydration: json['targetHydration']?.toDouble() ?? 0.0,
      fermentationSchedule:
          FermentationSchedule.fromJson(json['fermentationSchedule'] ?? {}),
    );
  }
}

/// 팬 크기 정보
class PanSize {
  final PanShape shape;
  final double diameter; // 원형 팬의 지름
  final double width; // 사각형 팬의 너비
  final double height; // 사각형 팬의 높이
  final double depth; // 팬의 깊이

  const PanSize({
    required this.shape,
    this.diameter = 0.0,
    this.width = 0.0,
    this.height = 0.0,
    this.depth = 0.0,
  });

  double get area {
    switch (shape) {
      case PanShape.round:
        return 3.14159 * (diameter / 2) * (diameter / 2);
      case PanShape.square:
        return width * width;
      case PanShape.rectangular:
        return width * height;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape.value,
      'diameter': diameter,
      'width': width,
      'height': height,
      'depth': depth,
    };
  }

  factory PanSize.fromJson(Map<String, dynamic> json) {
    return PanSize(
      shape: PanShape.fromString(json['shape'] ?? 'round'),
      diameter: json['diameter']?.toDouble() ?? 0.0,
      width: json['width']?.toDouble() ?? 0.0,
      height: json['height']?.toDouble() ?? 0.0,
      depth: json['depth']?.toDouble() ?? 0.0,
    );
  }
}

enum PanShape {
  round('round', '원형'),
  square('square', '정사각형'),
  rectangular('rectangular', '직사각형');

  const PanShape(this.value, this.displayName);
  final String value;
  final String displayName;

  static PanShape fromString(String value) {
    return PanShape.values.firstWhere(
      (shape) => shape.value == value,
      orElse: () => PanShape.round,
    );
  }
}

/// 케이크 계산 결과 (특화)
class CakeCalculationResult extends BakingCalculationResult {
  final PanSize originalPanSize;
  final PanSize targetPanSize;
  final double panScaleFactor;
  final int servings;
  final double decorationAmount; // 데코레이션 재료 양

  CakeCalculationResult({
    required super.originalRecipe,
    required super.calculatedRecipe,
    required super.calculationMode,
    required super.calculations,
    super.warnings,
    super.suggestions,
    super.environmentalAdjustment,
    super.costAnalysis,
    super.calculatedAt,
    super.totalWeight,
    super.splitWeight,
    super.splitCount,
    super.remainingWeight,
    super.scale,
    super.isOptimized,
    required this.originalPanSize,
    required this.targetPanSize,
    required this.panScaleFactor,
    required this.servings,
    this.decorationAmount = 0.0,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'originalPanSize': originalPanSize.toJson(),
      'targetPanSize': targetPanSize.toJson(),
      'panScaleFactor': panScaleFactor,
      'servings': servings,
      'decorationAmount': decorationAmount,
    };
  }

  factory CakeCalculationResult.fromJson(Map<String, dynamic> json) {
    final base = BakingCalculationResult.fromJson(json);
    return CakeCalculationResult(
      originalRecipe: base.originalRecipe,
      calculatedRecipe: base.calculatedRecipe,
      calculationMode: base.calculationMode,
      calculations: base.calculations,
      warnings: base.warnings,
      suggestions: base.suggestions,
      environmentalAdjustment: base.environmentalAdjustment,
      costAnalysis: base.costAnalysis,
      calculatedAt: base.calculatedAt,
      totalWeight: base.totalWeight,
      splitWeight: base.splitWeight,
      splitCount: base.splitCount,
      remainingWeight: base.remainingWeight,
      scale: base.scale,
      isOptimized: base.isOptimized,
      originalPanSize: PanSize.fromJson(json['originalPanSize'] ?? {}),
      targetPanSize: PanSize.fromJson(json['targetPanSize'] ?? {}),
      panScaleFactor: json['panScaleFactor']?.toDouble() ?? 1.0,
      servings: json['servings'] ?? 1,
      decorationAmount: json['decorationAmount']?.toDouble() ?? 0.0,
    );
  }
}
