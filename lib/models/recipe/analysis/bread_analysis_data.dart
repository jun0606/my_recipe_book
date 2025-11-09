import 'dart:convert';
import '../core/recipe.dart';
import '../core/ingredient.dart';
import '../environment/environmental_conditions.dart';
import '../environment/oven_characteristics.dart';
import '../environment/oven_type.dart';
import '../environment/season.dart';
import '../metadata/ingredient_metadata.dart';
import '../metadata/quality_metadata.dart';
import '../metadata/process_metadata.dart';
import '../metadata/baking_phase.dart';

// OvenCharacteristics extension에서 사용할 수 있도록 import
import '../environment/oven_type.dart' show OvenType;

/// 빵 분석 데이터
class BreadAnalysisData {
  final Recipe recipe; // 레시피 정보
  final EnvironmentalConditions environment; // 환경 조건
  final List<IngredientMetadata> ingredientMetadata; // 재료 메타데이터
  final QualityMetadata qualityMetadata; // 품질 메타데이터
  final ProcessMetadata processMetadata; // 공정 메타데이터
  final DateTime analysisTimestamp; // 분석 시각
  final String analysisVersion; // 분석 버전
  final Map<String, dynamic> additionalData; // 추가 데이터

  const BreadAnalysisData({
    required this.recipe,
    required this.environment,
    required this.ingredientMetadata,
    required this.qualityMetadata,
    required this.processMetadata,
    required this.analysisTimestamp,
    this.analysisVersion = '1.0.0',
    this.additionalData = const {},
  });

  factory BreadAnalysisData.fromJson(Map<String, dynamic> json) {
    return BreadAnalysisData(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      environment: EnvironmentalConditions.fromJson(
          json['environment'] as Map<String, dynamic>),
      ingredientMetadata: (json['ingredientMetadata'] as List<dynamic>?)
              ?.map((item) =>
                  IngredientMetadata.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      qualityMetadata: QualityMetadata.fromJson(
          json['qualityMetadata'] as Map<String, dynamic>),
      processMetadata: ProcessMetadata.fromJson(
          json['processMetadata'] as Map<String, dynamic>),
      analysisTimestamp: DateTime.parse(json['analysisTimestamp'] as String),
      analysisVersion: json['analysisVersion'] as String? ?? '1.0.0',
      additionalData:
          Map<String, dynamic>.from(json['additionalData'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe': recipe.toJson(),
      'environment': environment.toJson(),
      'ingredientMetadata':
          ingredientMetadata.map((meta) => meta.toJson()).toList(),
      'qualityMetadata': qualityMetadata.toJson(),
      'processMetadata': processMetadata.toJson(),
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
      'analysisVersion': analysisVersion,
      'additionalData': additionalData,
    };
  }

  BreadAnalysisData copyWith({
    Recipe? recipe,
    EnvironmentalConditions? environment,
    List<IngredientMetadata>? ingredientMetadata,
    QualityMetadata? qualityMetadata,
    ProcessMetadata? processMetadata,
    DateTime? analysisTimestamp,
    String? analysisVersion,
    Map<String, dynamic>? additionalData,
  }) {
    return BreadAnalysisData(
      recipe: recipe ?? this.recipe,
      environment: environment ?? this.environment,
      ingredientMetadata: ingredientMetadata ?? this.ingredientMetadata,
      qualityMetadata: qualityMetadata ?? this.qualityMetadata,
      processMetadata: processMetadata ?? this.processMetadata,
      analysisTimestamp: analysisTimestamp ?? this.analysisTimestamp,
      analysisVersion: analysisVersion ?? this.analysisVersion,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// 분석 데이터의 유효성 검증
  bool get isValid {
    return recipe.ingredients.isNotEmpty &&
        ingredientMetadata.isNotEmpty &&
        qualityMetadata.overallQualityScore > 0;
  }

  /// 분석 데이터의 완전성 점수 (0.0 ~ 1.0)
  double get completenessScore {
    int score = 0;
    int total = 6;

    if (recipe.ingredients.isNotEmpty) score++;
    if (environment.temperature > 0) score++;
    if (ingredientMetadata.isNotEmpty) score++;
    if (qualityMetadata.volumeIndex > 0) score++;
    if (processMetadata.mixing.predictedTime > 0) score++;
    if (additionalData.isNotEmpty) score++;

    return score / total;
  }

  /// 분석 데이터 요약
  String get summary {
    return '빵 분석 데이터 (v$analysisVersion): '
        '${recipe.title}, 품질 ${qualityMetadata.qualityGrade}, '
        '완전성 ${(completenessScore * 100).toStringAsFixed(1)}%';
  }

  @override
  String toString() => summary;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreadAnalysisData &&
        other.recipe == recipe &&
        other.environment == environment &&
        other.analysisTimestamp == analysisTimestamp;
  }

  @override
  int get hashCode {
    return recipe.hashCode ^ environment.hashCode ^ analysisTimestamp.hashCode;
  }
}

/// 빵 분석 데이터 생성기
class BreadAnalysisDataGenerator {
  /// 기본 분석 데이터 생성
  static BreadAnalysisData createDefault() {
    final defaultRecipe = Recipe(
      title: '기본 빵',
      ingredients: [
        Ingredient(name: '강력분', amount: 500, unit: 'g', properties: {}),
        Ingredient(name: '물', amount: 350, unit: 'ml', properties: {}),
        Ingredient(name: '이스트', amount: 5, unit: 'g', properties: {}),
        Ingredient(name: '소금', amount: 10, unit: 'g', properties: {}),
      ],
      processes: ['반죽', '발효', '굽기'],
      category: RecipeCategory.bread,
      description: '기본 빵 레시피',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final defaultEnvironment = EnvironmentalConditions(
      temperature: 25.0,
      humidity: 65.0,
      pressure: 1013.25,
      season: Season.spring,
      oven: OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 0.95,
        calibrationIndex: 1.0,
        steamCapability: 0.0,
        hasConvection: false,
        maxTemperature: 250,
      ),
      altitude: 100,
    );

    final ingredientMetadata = IngredientMetadataGenerator.generateMetadataList(
        defaultRecipe.ingredients);

    final qualityMetadata = QualityMetadata(
      volumeIndex: 2.5,
      crustColorIndex: 0.8,
      poreStructureScore: 75.0,
      moistureRetention: 0.85,
    );

    final processMetadata = ProcessMetadata(
      mixing: MixingMeta(
        predictedTime: 15.0,
        frictionHeat: 8.5,
        mixerTypeCoefficient: 1.05,
        glutenDevelopmentTarget: 1.2,
        equipmentCalibration: 0.98,
      ),
      fermentation: FermentationMeta(
        predictedTime: 120.0,
        volumeIncrease: 2.5,
        microbialActivityCoefficient: 1.1,
        doughPhysicalChemicalCoefficient: 1.05,
        environmentalClimateCoefficient: 0.95,
        doughTypeCorrection: 1.0,
      ),
      baking: BakingMeta(
        temperatureProfile: BakingProfileGenerator.createStandardBreadProfile(),
        totalBakingTime: 45.0,
        weightCorrection: 1.02,
        hydrationCorrection: 0.98,
        ovenEfficiency: 0.95,
        breadTypeCorrection: 1.0,
      ),
    );

    return BreadAnalysisData(
      recipe: defaultRecipe,
      environment: defaultEnvironment,
      ingredientMetadata: ingredientMetadata,
      qualityMetadata: qualityMetadata,
      processMetadata: processMetadata,
      analysisTimestamp: DateTime.now(),
      analysisVersion: '1.0.0',
    );
  }

  /// 레시피 기반 분석 데이터 생성
  static BreadAnalysisData fromRecipe(
    Recipe recipe, {
    EnvironmentalConditions? environment,
    String analysisVersion = '1.0.0',
  }) {
    final env = environment ??
        EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
          season: Season.fromDate(DateTime.now()),
          oven: OvenCharacteristics(
            type: OvenType.home,
            typeCoefficient: 0.95,
            calibrationIndex: 1.0,
            steamCapability: 0.0,
            hasConvection: false,
            maxTemperature: 250,
          ),
          altitude: 100,
        );

    final ingredientMetadata =
        IngredientMetadataGenerator.generateMetadataList(recipe.ingredients);

    final qualityMetadata = QualityCalculator.predictFromRecipe(
      hydration: recipe.hydrationPercentage,
      yeastAmount: recipe.yeastAmount,
      saltAmount: recipe.saltAmount,
      flourType: recipe.flourType,
      fermentationMethod: recipe.fermentationMethod,
    );

    final processMetadata = _generateProcessMetadata(recipe, env);

    return BreadAnalysisData(
      recipe: recipe,
      environment: env,
      ingredientMetadata: ingredientMetadata,
      qualityMetadata: qualityMetadata,
      processMetadata: processMetadata,
      analysisTimestamp: DateTime.now(),
      analysisVersion: analysisVersion,
    );
  }

  /// 공정 메타데이터 생성 (내부 헬퍼)
  static ProcessMetadata _generateProcessMetadata(
      Recipe recipe, EnvironmentalConditions environment) {
    // 믹싱 메타데이터 생성
    final mixing = MixingMeta(
      predictedTime: _calculateMixingTime(recipe),
      frictionHeat: _calculateFrictionHeat(recipe, environment),
      mixerTypeCoefficient: 1.05,
      glutenDevelopmentTarget: _calculateGlutenTarget(recipe),
      equipmentCalibration: 0.98,
    );

    // 발효 메타데이터 생성
    final fermentation = FermentationMeta(
      predictedTime: _calculateFermentationTime(recipe, environment),
      volumeIncrease: 2.5,
      microbialActivityCoefficient: 1.1,
      doughPhysicalChemicalCoefficient: 1.05,
      environmentalClimateCoefficient: environment.temperature > 25 ? 1.1 : 0.9,
      doughTypeCorrection: 1.0,
    );

    // 굽기 메타데이터 생성
    final baking = BakingMeta(
      temperatureProfile: BakingProfileGenerator.createStandardBreadProfile(),
      totalBakingTime: _calculateBakingTime(recipe),
      weightCorrection: 1.02,
      hydrationCorrection: recipe.hydrationPercentage > 70 ? 0.95 : 1.0,
      ovenEfficiency: environment.oven.ovenEfficiency,
      breadTypeCorrection: 1.0,
    );

    return ProcessMetadata(
      mixing: mixing,
      fermentation: fermentation,
      baking: baking,
    );
  }

  // 계산 헬퍼 메소드들
  static double _calculateMixingTime(Recipe recipe) {
    final flourAmount = recipe.flourAmount;
    if (flourAmount < 300) return 10.0;
    if (flourAmount < 600) return 15.0;
    if (flourAmount < 1000) return 20.0;
    return 25.0;
  }

  static double _calculateFrictionHeat(
      Recipe recipe, EnvironmentalConditions environment) {
    final baseHeat = recipe.flourAmount * 0.002;
    final tempAdjustment = (environment.temperature - 20) * 0.1;
    return baseHeat + tempAdjustment;
  }

  static double _calculateGlutenTarget(Recipe recipe) {
    final hydration = recipe.hydrationPercentage;
    if (hydration > 75) return 1.3; // 고수분 빵
    if (hydration > 65) return 1.2; // 일반 빵
    return 1.1; // 저수분 빵
  }

  static double _calculateFermentationTime(
      Recipe recipe, EnvironmentalConditions environment) {
    final yeastAmount = recipe.yeastAmount;
    final temp = environment.temperature;

    double baseTime = 120.0; // 기본 2시간

    // 이스트량에 따른 조정
    if (yeastAmount < 2) baseTime *= 1.5;
    if (yeastAmount > 8) baseTime *= 0.7;

    // 온도에 따른 조정
    if (temp > 28) baseTime *= 0.8;
    if (temp < 20) baseTime *= 1.3;

    return baseTime;
  }

  static double _calculateBakingTime(Recipe recipe) {
    final weight = recipe.totalDoughWeight;
    if (weight < 500) return 35.0;
    if (weight < 800) return 45.0;
    if (weight < 1200) return 55.0;
    return 65.0;
  }
}

// Recipe extension 메소드들
extension RecipeAnalysisExtensions on Recipe {
  double get hydrationPercentage {
    final flour = ingredients
        .where((i) => i.isFlour)
        .fold(0.0, (sum, i) => sum + i.amount);
    final water = ingredients
        .where((i) => i.isLiquid)
        .fold(0.0, (sum, i) => sum + i.amount);
    return flour > 0 ? (water / flour) * 100 : 0.0;
  }

  double get yeastAmount {
    return ingredients
        .where((i) => i.isYeast)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  double get saltAmount {
    return ingredients
        .where((i) => i.isSalt)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  double get flourAmount {
    return ingredients
        .where((i) => i.isFlour)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  double get totalDoughWeight {
    return ingredients.fold(0.0, (sum, i) => sum + i.amount);
  }

  String get flourType {
    final flour = ingredients.where((i) => i.isFlour).firstOrNull;
    return flour?.name ?? '강력분';
  }

  String get fermentationMethod => 'bulk'; // 기본 발효 방식
}

extension IngredientAnalysisExtensions on Ingredient {
  bool get isFlour => name.contains('분');
  bool get isYeast =>
      name.contains('이스트') || name.contains('효모') || name.contains('스타터');
  bool get isSalt => name.contains('소금');
  bool get isLiquid =>
      name.contains('물') || name.contains('우유') || name.contains('크림');
}

// OvenCharacteristics extension
extension OvenCharacteristicsExtensions on OvenCharacteristics {
  double get ovenEfficiency {
    switch (type) {
      case OvenType.home:
        return 0.92;
      case OvenType.professionalConvection:
        return 0.98;
      case OvenType.deck:
        return 0.96;
      case OvenType.steam:
        return 0.95;
      case OvenType.conventional:
        return 0.90;
      case OvenType.convection:
        return 0.95;
      case OvenType.combi:
        return 1.0;
    }
  }
}
