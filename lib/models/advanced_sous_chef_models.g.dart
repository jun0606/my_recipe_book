// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_sous_chef_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedRecipeData _$AdvancedRecipeDataFromJson(Map<String, dynamic> json) =>
    AdvancedRecipeData(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      environment: EnvironmentalConditions.fromJson(
          json['environment'] as Map<String, dynamic>),
      ingredientMeta: (json['ingredientMeta'] as List<dynamic>)
          .map((e) => IngredientMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      processMeta:
          ProcessMetadata.fromJson(json['processMeta'] as Map<String, dynamic>),
      qualityMeta:
          QualityMetadata.fromJson(json['qualityMeta'] as Map<String, dynamic>),
      dessertMeta: json['dessertMeta'] == null
          ? null
          : DessertMetadata.fromJson(
              json['dessertMeta'] as Map<String, dynamic>),
      interfaceMeta: InterfaceMetadata.fromJson(
          json['interfaceMeta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdvancedRecipeDataToJson(AdvancedRecipeData instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'environment': instance.environment,
      'ingredientMeta': instance.ingredientMeta,
      'processMeta': instance.processMeta,
      'qualityMeta': instance.qualityMeta,
      'dessertMeta': instance.dessertMeta,
      'interfaceMeta': instance.interfaceMeta,
    };

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      processes:
          (json['processes'] as List<dynamic>).map((e) => e as String).toList(),
      category: $enumDecode(_$RecipeCategoryEnumMap, json['category']),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'title': instance.title,
      'ingredients': instance.ingredients,
      'processes': instance.processes,
      'category': _$RecipeCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RecipeCategoryEnumMap = {
  RecipeCategory.bread: 'bread',
  RecipeCategory.cake: 'cake',
  RecipeCategory.cookie: 'cookie',
  RecipeCategory.dessert: 'dessert',
};

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'unit': instance.unit,
      'properties': instance.properties,
    };

EnvironmentalConditions _$EnvironmentalConditionsFromJson(
        Map<String, dynamic> json) =>
    EnvironmentalConditions(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      season: $enumDecode(_$SeasonEnumMap, json['season']),
      oven: OvenCharacteristics.fromJson(json['oven'] as Map<String, dynamic>),
      altitude: (json['altitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EnvironmentalConditionsToJson(
        EnvironmentalConditions instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'season': _$SeasonEnumMap[instance.season]!,
      'oven': instance.oven,
      'altitude': instance.altitude,
    };

const _$SeasonEnumMap = {
  Season.spring: 'spring',
  Season.summer: 'summer',
  Season.autumn: 'autumn',
  Season.winter: 'winter',
};

OvenCharacteristics _$OvenCharacteristicsFromJson(Map<String, dynamic> json) =>
    OvenCharacteristics(
      type: $enumDecode(_$OvenTypeEnumMap, json['type']),
      typeCoefficient: (json['typeCoefficient'] as num).toDouble(),
      calibrationIndex: (json['calibrationIndex'] as num).toDouble(),
      steamCapability: (json['steamCapability'] as num).toDouble(),
      hasConvection: json['hasConvection'] as bool,
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      hasStone: json['hasStone'] as bool? ?? false,
      hasSteam: json['hasSteam'] as bool? ?? false,
      temperatureAccuracy:
          (json['temperatureAccuracy'] as num?)?.toDouble() ?? 0.95,
    );

Map<String, dynamic> _$OvenCharacteristicsToJson(
        OvenCharacteristics instance) =>
    <String, dynamic>{
      'type': _$OvenTypeEnumMap[instance.type]!,
      'typeCoefficient': instance.typeCoefficient,
      'calibrationIndex': instance.calibrationIndex,
      'steamCapability': instance.steamCapability,
      'hasConvection': instance.hasConvection,
      'maxTemperature': instance.maxTemperature,
      'hasStone': instance.hasStone,
      'hasSteam': instance.hasSteam,
      'temperatureAccuracy': instance.temperatureAccuracy,
    };

const _$OvenTypeEnumMap = {
  OvenType.home: 'home',
  OvenType.professionalConvection: 'professional_convection',
  OvenType.deck: 'deck',
  OvenType.steam: 'steam',
  OvenType.conventional: 'conventional',
  OvenType.convection: 'convection',
  OvenType.combi: 'combi',
};

IngredientMetadata _$IngredientMetadataFromJson(Map<String, dynamic> json) =>
    IngredientMetadata(
      name: json['name'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      effectiveValue: (json['effectiveValue'] as num).toDouble(),
      function: json['function'] as String,
      qualityCorrectionFactor:
          (json['qualityCorrectionFactor'] as num).toDouble(),
    );

Map<String, dynamic> _$IngredientMetadataToJson(IngredientMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'properties': instance.properties,
      'effectiveValue': instance.effectiveValue,
      'function': instance.function,
      'qualityCorrectionFactor': instance.qualityCorrectionFactor,
    };

ProcessMetadata _$ProcessMetadataFromJson(Map<String, dynamic> json) =>
    ProcessMetadata(
      mixing: MixingMeta.fromJson(json['mixing'] as Map<String, dynamic>),
      fermentation: FermentationMeta.fromJson(
          json['fermentation'] as Map<String, dynamic>),
      baking: BakingMeta.fromJson(json['baking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProcessMetadataToJson(ProcessMetadata instance) =>
    <String, dynamic>{
      'mixing': instance.mixing,
      'fermentation': instance.fermentation,
      'baking': instance.baking,
    };

MixingMeta _$MixingMetaFromJson(Map<String, dynamic> json) => MixingMeta(
      predictedTime: (json['predictedTime'] as num).toDouble(),
      frictionHeat: (json['frictionHeat'] as num).toDouble(),
      mixerTypeCoefficient: (json['mixerTypeCoefficient'] as num).toDouble(),
      glutenDevelopmentTarget:
          (json['glutenDevelopmentTarget'] as num).toDouble(),
      equipmentCalibration: (json['equipmentCalibration'] as num).toDouble(),
    );

Map<String, dynamic> _$MixingMetaToJson(MixingMeta instance) =>
    <String, dynamic>{
      'predictedTime': instance.predictedTime,
      'frictionHeat': instance.frictionHeat,
      'mixerTypeCoefficient': instance.mixerTypeCoefficient,
      'glutenDevelopmentTarget': instance.glutenDevelopmentTarget,
      'equipmentCalibration': instance.equipmentCalibration,
    };

FermentationMeta _$FermentationMetaFromJson(Map<String, dynamic> json) =>
    FermentationMeta(
      predictedTime: (json['predictedTime'] as num).toDouble(),
      volumeIncrease: (json['volumeIncrease'] as num).toDouble(),
      microbialActivityCoefficient:
          (json['microbialActivityCoefficient'] as num).toDouble(),
      doughPhysicalChemicalCoefficient:
          (json['doughPhysicalChemicalCoefficient'] as num).toDouble(),
      environmentalClimateCoefficient:
          (json['environmentalClimateCoefficient'] as num).toDouble(),
      doughTypeCorrection: (json['doughTypeCorrection'] as num).toDouble(),
    );

Map<String, dynamic> _$FermentationMetaToJson(FermentationMeta instance) =>
    <String, dynamic>{
      'predictedTime': instance.predictedTime,
      'volumeIncrease': instance.volumeIncrease,
      'microbialActivityCoefficient': instance.microbialActivityCoefficient,
      'doughPhysicalChemicalCoefficient':
          instance.doughPhysicalChemicalCoefficient,
      'environmentalClimateCoefficient':
          instance.environmentalClimateCoefficient,
      'doughTypeCorrection': instance.doughTypeCorrection,
    };

BakingMeta _$BakingMetaFromJson(Map<String, dynamic> json) => BakingMeta(
      temperatureProfile: (json['temperatureProfile'] as List<dynamic>)
          .map((e) => BakingPhase.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBakingTime: (json['totalBakingTime'] as num).toDouble(),
      weightCorrection: (json['weightCorrection'] as num).toDouble(),
      hydrationCorrection: (json['hydrationCorrection'] as num).toDouble(),
      ovenEfficiency: (json['ovenEfficiency'] as num).toDouble(),
      breadTypeCorrection: (json['breadTypeCorrection'] as num).toDouble(),
    );

Map<String, dynamic> _$BakingMetaToJson(BakingMeta instance) =>
    <String, dynamic>{
      'temperatureProfile': instance.temperatureProfile,
      'totalBakingTime': instance.totalBakingTime,
      'weightCorrection': instance.weightCorrection,
      'hydrationCorrection': instance.hydrationCorrection,
      'ovenEfficiency': instance.ovenEfficiency,
      'breadTypeCorrection': instance.breadTypeCorrection,
    };

BakingPhase _$BakingPhaseFromJson(Map<String, dynamic> json) => BakingPhase(
      phase: json['phase'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
      steamTime: (json['steamTime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BakingPhaseToJson(BakingPhase instance) =>
    <String, dynamic>{
      'phase': instance.phase,
      'temperature': instance.temperature,
      'time': instance.time,
      'steamTime': instance.steamTime,
    };

QualityMetadata _$QualityMetadataFromJson(Map<String, dynamic> json) =>
    QualityMetadata(
      volumeIndex: (json['volumeIndex'] as num).toDouble(),
      crustColorIndex: (json['crustColorIndex'] as num).toDouble(),
      poreStructureScore: (json['poreStructureScore'] as num).toDouble(),
      moistureRetention: (json['moistureRetention'] as num).toDouble(),
    );

Map<String, dynamic> _$QualityMetadataToJson(QualityMetadata instance) =>
    <String, dynamic>{
      'volumeIndex': instance.volumeIndex,
      'crustColorIndex': instance.crustColorIndex,
      'poreStructureScore': instance.poreStructureScore,
      'moistureRetention': instance.moistureRetention,
    };

DessertMetadata _$DessertMetadataFromJson(Map<String, dynamic> json) =>
    DessertMetadata(
      dessertType: json['dessertType'] as String,
      country: json['country'] as String,
      calculatedValues: (json['calculatedValues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      correctionFactors:
          (json['correctionFactors'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$DessertMetadataToJson(DessertMetadata instance) =>
    <String, dynamic>{
      'dessertType': instance.dessertType,
      'country': instance.country,
      'calculatedValues': instance.calculatedValues,
      'correctionFactors': instance.correctionFactors,
    };

InterfaceMetadata _$InterfaceMetadataFromJson(Map<String, dynamic> json) =>
    InterfaceMetadata(
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      dashboard:
          DashboardData.fromJson(json['dashboard'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InterfaceMetadataToJson(InterfaceMetadata instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
      'dashboard': instance.dashboard,
    };

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      message: json['message'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'type': _$AlertTypeEnumMap[instance.type]!,
      'message': instance.message,
      'action': instance.action,
      'timestamp': instance.timestamp.toIso8601String(),
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
    };

const _$AlertTypeEnumMap = {
  AlertType.fermentationTimeDeviation: 'fermentation_time_deviation',
  AlertType.bakingTemperatureDeviation: 'baking_temperature_deviation',
  AlertType.environmentVariableDeviation: 'environment_variable_deviation',
  AlertType.processCompletion: 'process_completion',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      volumeIndex:
          VolumeIndexData.fromJson(json['volumeIndex'] as Map<String, dynamic>),
      crustColor:
          CrustColorData.fromJson(json['crustColor'] as Map<String, dynamic>),
      poreStructure: PoreStructureData.fromJson(
          json['poreStructure'] as Map<String, dynamic>),
      environment:
          EnvironmentData.fromJson(json['environment'] as Map<String, dynamic>),
      recentAlerts: (json['recentAlerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'volumeIndex': instance.volumeIndex,
      'crustColor': instance.crustColor,
      'poreStructure': instance.poreStructure,
      'environment': instance.environment,
      'recentAlerts': instance.recentAlerts,
    };

VolumeIndexData _$VolumeIndexDataFromJson(Map<String, dynamic> json) =>
    VolumeIndexData(
      current: (json['current'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      history: (json['history'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$VolumeIndexDataToJson(VolumeIndexData instance) =>
    <String, dynamic>{
      'current': instance.current,
      'target': instance.target,
      'history': instance.history,
    };

CrustColorData _$CrustColorDataFromJson(Map<String, dynamic> json) =>
    CrustColorData(
      current: (json['current'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      history: (json['history'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$CrustColorDataToJson(CrustColorData instance) =>
    <String, dynamic>{
      'current': instance.current,
      'target': instance.target,
      'history': instance.history,
    };

PoreStructureData _$PoreStructureDataFromJson(Map<String, dynamic> json) =>
    PoreStructureData(
      current: (json['current'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      sizeDistribution: (json['sizeDistribution'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$PoreStructureDataToJson(PoreStructureData instance) =>
    <String, dynamic>{
      'current': instance.current,
      'target': instance.target,
      'sizeDistribution': instance.sizeDistribution,
    };

EnvironmentData _$EnvironmentDataFromJson(Map<String, dynamic> json) =>
    EnvironmentData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      isWithinRange: json['isWithinRange'] as bool,
    );

Map<String, dynamic> _$EnvironmentDataToJson(EnvironmentData instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'isWithinRange': instance.isWithinRange,
    };

ValidationResult _$ValidationResultFromJson(Map<String, dynamic> json) =>
    ValidationResult(
      isValid: json['isValid'] as bool,
      errors:
          (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ValidationResultToJson(ValidationResult instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errors': instance.errors,
      'warnings': instance.warnings,
    };

EnvironmentalRecommendation _$EnvironmentalRecommendationFromJson(
        Map<String, dynamic> json) =>
    EnvironmentalRecommendation(
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      optimalTemperatureRange: TemperatureRange.fromJson(
          json['optimalTemperatureRange'] as Map<String, dynamic>),
      optimalHumidityRange: HumidityRange.fromJson(
          json['optimalHumidityRange'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnvironmentalRecommendationToJson(
        EnvironmentalRecommendation instance) =>
    <String, dynamic>{
      'recommendations': instance.recommendations,
      'optimalTemperatureRange': instance.optimalTemperatureRange,
      'optimalHumidityRange': instance.optimalHumidityRange,
    };

TemperatureRange _$TemperatureRangeFromJson(Map<String, dynamic> json) =>
    TemperatureRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$TemperatureRangeToJson(TemperatureRange instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

HumidityRange _$HumidityRangeFromJson(Map<String, dynamic> json) =>
    HumidityRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$HumidityRangeToJson(HumidityRange instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

CompatibilityResult _$CompatibilityResultFromJson(Map<String, dynamic> json) =>
    CompatibilityResult(
      isCompatible: json['isCompatible'] as bool,
      issues:
          (json['issues'] as List<dynamic>).map((e) => e as String).toList(),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CompatibilityResultToJson(
        CompatibilityResult instance) =>
    <String, dynamic>{
      'isCompatible': instance.isCompatible,
      'issues': instance.issues,
      'warnings': instance.warnings,
    };
