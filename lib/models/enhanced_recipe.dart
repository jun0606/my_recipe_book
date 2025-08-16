import 'recipe.dart';
import 'ingredient.dart';
import 'environmental_conditions.dart';
import 'cost_analysis.dart';
import 'user_configuration.dart';

/// 베이킹 카테고리 열거형
enum BakingCategory {
  bread('bread', '빵'),
  cake('cake', '케이크'),
  cookie('cookie', '쿠키'),
  pastry('pastry', '페이스트리'),
  dessert('dessert', '디저트'),
  general('general', '일반');

  const BakingCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  static BakingCategory fromString(String value) {
    return BakingCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => BakingCategory.general,
    );
  }
}

/// 베이킹 장비 모델
enum OvenType {
  electric('electric', '전기'),
  gas('gas', '가스'),
  convection('convection', '컨벡션'),
  steam('steam', '스팀'),
  deck('deck', '데크'),
  wood('wood', '장작');

  const OvenType(this.value, this.displayName);
  final String value;
  final String displayName;

  static OvenType fromString(String value) {
    return OvenType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OvenType.electric,
    );
  }
}

enum PanMaterial {
  aluminum('aluminum', '알루미늄'),
  stainless('stainless', '스테인리스'),
  silicone('silicone', '실리콘'),
  glass('glass', '유리'),
  ceramic('ceramic', '세라믹'),
  carbon('carbon', '카본');

  const PanMaterial(this.value, this.displayName);
  final String value;
  final String displayName;

  static PanMaterial fromString(String value) {
    return PanMaterial.values.firstWhere(
      (material) => material.value == value,
      orElse: () => PanMaterial.aluminum,
    );
  }
}

enum PanColor {
  light('light', '밝음'),
  dark('dark', '어두움'),
  medium('medium', '중간');

  const PanColor(this.value, this.displayName);
  final String value;
  final String displayName;

  static PanColor fromString(String value) {
    return PanColor.values.firstWhere(
      (color) => color.value == value,
      orElse: () => PanColor.light,
    );
  }
}

class BakingEquipment {
  final OvenType ovenType;
  final PanMaterial panMaterial;
  final PanColor panColor;
  final List<String> availableTools;
  final Map<String, dynamic> specifications;

  const BakingEquipment({
    required this.ovenType,
    required this.panMaterial,
    required this.panColor,
    this.availableTools = const [],
    this.specifications = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'ovenType': ovenType.value,
      'panMaterial': panMaterial.value,
      'panColor': panColor.value,
      'availableTools': availableTools,
      'specifications': specifications,
    };
  }

  factory BakingEquipment.fromJson(Map<String, dynamic> json) {
    return BakingEquipment(
      ovenType: OvenType.fromString(json['ovenType'] ?? 'electric'),
      panMaterial: PanMaterial.fromString(json['panMaterial'] ?? 'aluminum'),
      panColor: PanColor.fromString(json['panColor'] ?? 'light'),
      availableTools: List<String>.from(json['availableTools'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
    );
  }

  BakingEquipment copyWith({
    OvenType? ovenType,
    PanMaterial? panMaterial,
    PanColor? panColor,
    List<String>? availableTools,
    Map<String, dynamic>? specifications,
  }) {
    return BakingEquipment(
      ovenType: ovenType ?? this.ovenType,
      panMaterial: panMaterial ?? this.panMaterial,
      panColor: panColor ?? this.panColor,
      availableTools: availableTools ?? this.availableTools,
      specifications: specifications ?? this.specifications,
    );
  }
}

/// 재료 대체 정보
class IngredientSubstitution {
  final String originalIngredient;
  final String substituteIngredient;
  final double ratio;
  final String function; // 'binding', 'fat', 'sweetening', etc.
  final double confidenceScore; // 0.0 - 1.0
  final List<String> notes;

  const IngredientSubstitution({
    required this.originalIngredient,
    required this.substituteIngredient,
    required this.ratio,
    required this.function,
    this.confidenceScore = 1.0,
    this.notes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'originalIngredient': originalIngredient,
      'substituteIngredient': substituteIngredient,
      'ratio': ratio,
      'function': function,
      'confidenceScore': confidenceScore,
      'notes': notes,
    };
  }

  factory IngredientSubstitution.fromJson(Map<String, dynamic> json) {
    return IngredientSubstitution(
      originalIngredient: json['originalIngredient'] ?? '',
      substituteIngredient: json['substituteIngredient'] ?? '',
      ratio: json['ratio']?.toDouble() ?? 1.0,
      function: json['function'] ?? '',
      confidenceScore: json['confidenceScore']?.toDouble() ?? 1.0,
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

/// 수율 예측 정보
class YieldPrediction {
  final double expectedYield; // 예상 수율 (퍼센트)
  final double expectedWeight; // 예상 최종 무게
  final double moistureLoss; // 수분 손실 (퍼센트)
  final String notes;

  const YieldPrediction({
    required this.expectedYield,
    required this.expectedWeight,
    this.moistureLoss = 0.0,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'expectedYield': expectedYield,
      'expectedWeight': expectedWeight,
      'moistureLoss': moistureLoss,
      'notes': notes,
    };
  }

  factory YieldPrediction.fromJson(Map<String, dynamic> json) {
    return YieldPrediction(
      expectedYield: json['expectedYield']?.toDouble() ?? 0.0,
      expectedWeight: json['expectedWeight']?.toDouble() ?? 0.0,
      moistureLoss: json['moistureLoss']?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
    );
  }
}

/// 확장된 레시피 모델
class EnhancedRecipe extends Recipe {
  final BakingCategory bakingCategory;
  final UserMode optimizedFor;
  final EnvironmentalConditions? environmentalConditions;
  final BakingEquipment? bakingEquipment;
  final Map<String, double>? bakersPercentages;
  final double? hydrationLevel;
  final List<IngredientSubstitution>? availableSubstitutions;
  final CostAnalysis? costAnalysis;
  final YieldPrediction? yieldPrediction;
  final int? bakingTemperature; // 굽기 온도 (섭씨)
  final Duration? bakingTime; // 굽기 시간

  EnhancedRecipe({
    required super.id,
    required super.title,
    required super.category,
    required super.ingredients,
    required super.instructions,
    super.imagePath,
    super.baseServings = 1,
    super.isBaking = false,
    super.targetSplitAmount,
    super.targetSplitCount,
    super.calculatedRemainingWeight,
    super.totalIngredientWeight,
    super.parentId,
    this.bakingCategory = BakingCategory.general,
    this.optimizedFor = UserMode.homeBaker,
    this.environmentalConditions,
    this.bakingEquipment,
    this.bakersPercentages,
    this.hydrationLevel,
    this.availableSubstitutions,
    this.costAnalysis,
    this.yieldPrediction,
    this.bakingTemperature,
    this.bakingTime,
  });

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'bakingCategory': bakingCategory.value,
      'optimizedFor': optimizedFor.value,
      'environmentalConditions': environmentalConditions?.toJson(),
      'bakingEquipment': bakingEquipment?.toJson(),
      'bakersPercentages': bakersPercentages,
      'hydrationLevel': hydrationLevel,
      'availableSubstitutions':
          availableSubstitutions?.map((s) => s.toJson()).toList(),
      'costAnalysis': costAnalysis?.toJson(),
      'yieldPrediction': yieldPrediction?.toJson(),
      'bakingTemperature': bakingTemperature,
      'bakingTime': bakingTime?.inMinutes,
    };
  }

  factory EnhancedRecipe.fromJson(Map<String, dynamic> json) {
    final baseRecipe = Recipe.fromJson(json);

    return EnhancedRecipe(
      id: baseRecipe.id,
      title: baseRecipe.title,
      category: baseRecipe.category,
      ingredients: baseRecipe.ingredients,
      instructions: baseRecipe.instructions,
      imagePath: baseRecipe.imagePath,
      baseServings: baseRecipe.baseServings,
      isBaking: baseRecipe.isBaking,
      targetSplitAmount: baseRecipe.targetSplitAmount,
      targetSplitCount: baseRecipe.targetSplitCount,
      calculatedRemainingWeight: baseRecipe.calculatedRemainingWeight,
      totalIngredientWeight: baseRecipe.totalIngredientWeight,
      parentId: baseRecipe.parentId,
      bakingCategory:
          BakingCategory.fromString(json['bakingCategory'] ?? 'general'),
      optimizedFor: UserMode.fromString(json['optimizedFor'] ?? 'home'),
      environmentalConditions: json['environmentalConditions'] != null
          ? EnvironmentalConditions.fromJson(json['environmentalConditions'])
          : null,
      bakingEquipment: json['bakingEquipment'] != null
          ? BakingEquipment.fromJson(json['bakingEquipment'])
          : null,
      bakersPercentages: json['bakersPercentages'] != null
          ? Map<String, double>.from(json['bakersPercentages']
              .map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0)))
          : null,
      hydrationLevel: json['hydrationLevel']?.toDouble(),
      availableSubstitutions: json['availableSubstitutions'] != null
          ? List<IngredientSubstitution>.from(json['availableSubstitutions']
              .map((s) => IngredientSubstitution.fromJson(s)))
          : null,
      costAnalysis: json['costAnalysis'] != null
          ? CostAnalysis.fromJson(json['costAnalysis'])
          : null,
      yieldPrediction: json['yieldPrediction'] != null
          ? YieldPrediction.fromJson(json['yieldPrediction'])
          : null,
      bakingTemperature: json['bakingTemperature'],
      bakingTime: json['bakingTime'] != null
          ? Duration(minutes: json['bakingTime'])
          : null,
    );
  }

  factory EnhancedRecipe.fromRecipe(Recipe recipe) {
    return EnhancedRecipe(
      id: recipe.id,
      title: recipe.title,
      category: recipe.category,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imagePath: recipe.imagePath,
      baseServings: recipe.baseServings,
      isBaking: recipe.isBaking,
      targetSplitAmount: recipe.targetSplitAmount,
      targetSplitCount: recipe.targetSplitCount,
      calculatedRemainingWeight: recipe.calculatedRemainingWeight,
      totalIngredientWeight: recipe.totalIngredientWeight,
      parentId: recipe.parentId,
    );
  }

  EnhancedRecipe copyWith({
    int? id,
    String? title,
    String? category,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    String? imagePath,
    int? baseServings,
    bool? isBaking,
    double? targetSplitAmount,
    int? targetSplitCount,
    double? calculatedRemainingWeight,
    double? totalIngredientWeight,
    int? parentId,
    BakingCategory? bakingCategory,
    UserMode? optimizedFor,
    EnvironmentalConditions? environmentalConditions,
    BakingEquipment? bakingEquipment,
    Map<String, double>? bakersPercentages,
    double? hydrationLevel,
    List<IngredientSubstitution>? availableSubstitutions,
    CostAnalysis? costAnalysis,
    YieldPrediction? yieldPrediction,
    int? bakingTemperature,
    Duration? bakingTime,
  }) {
    return EnhancedRecipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imagePath: imagePath ?? this.imagePath,
      baseServings: baseServings ?? this.baseServings,
      isBaking: isBaking ?? this.isBaking,
      targetSplitAmount: targetSplitAmount ?? this.targetSplitAmount,
      targetSplitCount: targetSplitCount ?? this.targetSplitCount,
      calculatedRemainingWeight:
          calculatedRemainingWeight ?? this.calculatedRemainingWeight,
      totalIngredientWeight:
          totalIngredientWeight ?? this.totalIngredientWeight,
      parentId: parentId ?? this.parentId,
      bakingCategory: bakingCategory ?? this.bakingCategory,
      optimizedFor: optimizedFor ?? this.optimizedFor,
      environmentalConditions:
          environmentalConditions ?? this.environmentalConditions,
      bakingEquipment: bakingEquipment ?? this.bakingEquipment,
      bakersPercentages: bakersPercentages ?? this.bakersPercentages,
      hydrationLevel: hydrationLevel ?? this.hydrationLevel,
      availableSubstitutions:
          availableSubstitutions ?? this.availableSubstitutions,
      costAnalysis: costAnalysis ?? this.costAnalysis,
      yieldPrediction: yieldPrediction ?? this.yieldPrediction,
      bakingTemperature: bakingTemperature ?? this.bakingTemperature,
      bakingTime: bakingTime ?? this.bakingTime,
    );
  }
}