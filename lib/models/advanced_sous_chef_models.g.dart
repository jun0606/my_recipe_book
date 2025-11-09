// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_sous_chef_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 3;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      title: fields[0] as String,
      ingredients: (fields[1] as List).cast<Ingredient>(),
      processes: (fields[2] as List).cast<String>(),
      category: fields[3] as RecipeCategory,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      mixingSteps: (fields[7] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      fermentationSteps: (fields[8] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      ovenSteps: (fields[9] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.ingredients)
      ..writeByte(2)
      ..write(obj.processes)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.mixingSteps)
      ..writeByte(8)
      ..write(obj.fermentationSteps)
      ..writeByte(9)
      ..write(obj.ovenSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 4;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredient(
      name: fields[0] as String,
      amount: fields[1] as double,
      unit: fields[2] as String,
      properties: (fields[3] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.properties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnvironmentalConditionsAdapter
    extends TypeAdapter<EnvironmentalConditions> {
  @override
  final int typeId = 6;

  @override
  EnvironmentalConditions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvironmentalConditions(
      temperature: fields[0] as double,
      humidity: fields[1] as double,
      pressure: fields[2] as double,
      season: fields[3] as Season,
      oven: fields[4] as OvenCharacteristics,
      altitude: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, EnvironmentalConditions obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.humidity)
      ..writeByte(2)
      ..write(obj.pressure)
      ..writeByte(3)
      ..write(obj.season)
      ..writeByte(4)
      ..write(obj.oven)
      ..writeByte(5)
      ..write(obj.altitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentalConditionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OvenCharacteristicsAdapter extends TypeAdapter<OvenCharacteristics> {
  @override
  final int typeId = 8;

  @override
  OvenCharacteristics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OvenCharacteristics(
      type: fields[0] as OvenType,
      typeCoefficient: fields[1] as double,
      calibrationIndex: fields[2] as double,
      steamCapability: fields[3] as double,
      hasConvection: fields[4] as bool,
      maxTemperature: fields[5] as double,
      hasStone: fields[6] as bool,
      hasSteam: fields[7] as bool,
      temperatureAccuracy: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OvenCharacteristics obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.typeCoefficient)
      ..writeByte(2)
      ..write(obj.calibrationIndex)
      ..writeByte(3)
      ..write(obj.steamCapability)
      ..writeByte(4)
      ..write(obj.hasConvection)
      ..writeByte(5)
      ..write(obj.maxTemperature)
      ..writeByte(6)
      ..write(obj.hasStone)
      ..writeByte(7)
      ..write(obj.hasSteam)
      ..writeByte(8)
      ..write(obj.temperatureAccuracy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvenCharacteristicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeCategoryAdapter extends TypeAdapter<RecipeCategory> {
  @override
  final int typeId = 5;

  @override
  RecipeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecipeCategory.bread;
      case 1:
        return RecipeCategory.cake;
      case 2:
        return RecipeCategory.cookie;
      case 3:
        return RecipeCategory.dessert;
      default:
        return RecipeCategory.bread;
    }
  }

  @override
  void write(BinaryWriter writer, RecipeCategory obj) {
    switch (obj) {
      case RecipeCategory.bread:
        writer.writeByte(0);
        break;
      case RecipeCategory.cake:
        writer.writeByte(1);
        break;
      case RecipeCategory.cookie:
        writer.writeByte(2);
        break;
      case RecipeCategory.dessert:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 7;

  @override
  Season read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Season.spring;
      case 1:
        return Season.summer;
      case 2:
        return Season.autumn;
      case 3:
        return Season.winter;
      default:
        return Season.spring;
    }
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    switch (obj) {
      case Season.spring:
        writer.writeByte(0);
        break;
      case Season.summer:
        writer.writeByte(1);
        break;
      case Season.autumn:
        writer.writeByte(2);
        break;
      case Season.winter:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OvenTypeAdapter extends TypeAdapter<OvenType> {
  @override
  final int typeId = 9;

  @override
  OvenType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OvenType.home;
      case 1:
        return OvenType.professionalConvection;
      case 2:
        return OvenType.deck;
      case 3:
        return OvenType.steam;
      case 4:
        return OvenType.conventional;
      case 5:
        return OvenType.convection;
      case 6:
        return OvenType.combi;
      default:
        return OvenType.home;
    }
  }

  @override
  void write(BinaryWriter writer, OvenType obj) {
    switch (obj) {
      case OvenType.home:
        writer.writeByte(0);
        break;
      case OvenType.professionalConvection:
        writer.writeByte(1);
        break;
      case OvenType.deck:
        writer.writeByte(2);
        break;
      case OvenType.steam:
        writer.writeByte(3);
        break;
      case OvenType.conventional:
        writer.writeByte(4);
        break;
      case OvenType.convection:
        writer.writeByte(5);
        break;
      case OvenType.combi:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvenTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      mixingSteps: (json['mixingSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      fermentationSteps: (json['fermentationSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      ovenSteps: (json['ovenSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'title': instance.title,
      'ingredients': instance.ingredients,
      'processes': instance.processes,
      'category': _$RecipeCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'mixingSteps': instance.mixingSteps,
      'fermentationSteps': instance.fermentationSteps,
      'ovenSteps': instance.ovenSteps,
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
      description: json['description'] as String?,
    );

Map<String, dynamic> _$IngredientMetadataToJson(IngredientMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'properties': instance.properties,
      'effectiveValue': instance.effectiveValue,
      'function': instance.function,
      'qualityCorrectionFactor': instance.qualityCorrectionFactor,
      'description': instance.description,
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
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$AlertTypeEnumMap[instance.type]!,
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

FermentationCoefficients _$FermentationCoefficientsFromJson(
        Map<String, dynamic> json) =>
    FermentationCoefficients(
      microbialActivityCoefficient:
          (json['microbialActivityCoefficient'] as num).toDouble(),
      doughPhysicochemicalCoefficient:
          (json['doughPhysicochemicalCoefficient'] as num).toDouble(),
      environmentalClimateCoefficient:
          (json['environmentalClimateCoefficient'] as num).toDouble(),
      doughTypeCorrectionCoefficient:
          (json['doughTypeCorrectionCoefficient'] as num).toDouble(),
    );

Map<String, dynamic> _$FermentationCoefficientsToJson(
        FermentationCoefficients instance) =>
    <String, dynamic>{
      'microbialActivityCoefficient': instance.microbialActivityCoefficient,
      'doughPhysicochemicalCoefficient':
          instance.doughPhysicochemicalCoefficient,
      'environmentalClimateCoefficient':
          instance.environmentalClimateCoefficient,
      'doughTypeCorrectionCoefficient': instance.doughTypeCorrectionCoefficient,
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

AlertPreferences _$AlertPreferencesFromJson(Map<String, dynamic> json) =>
    AlertPreferences(
      enableFermentationAlerts:
          json['enableFermentationAlerts'] as bool? ?? true,
      enableBakingAlerts: json['enableBakingAlerts'] as bool? ?? true,
      enableEnvironmentAlerts:
          json['enableEnvironmentAlerts'] as bool? ?? false,
      enableCompletionAlerts: json['enableCompletionAlerts'] as bool? ?? true,
      enableSound: json['enableSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? false,
      alertLeadTime: (json['alertLeadTime'] as num?)?.toInt() ?? 5,
      temperatureThreshold:
          (json['temperatureThreshold'] as num?)?.toDouble() ?? 5.0,
      humidityThreshold:
          (json['humidityThreshold'] as num?)?.toDouble() ?? 10.0,
      timeDeviationThreshold:
          (json['timeDeviationThreshold'] as num?)?.toDouble() ?? 10.0,
    );

Map<String, dynamic> _$AlertPreferencesToJson(AlertPreferences instance) =>
    <String, dynamic>{
      'enableFermentationAlerts': instance.enableFermentationAlerts,
      'enableBakingAlerts': instance.enableBakingAlerts,
      'enableEnvironmentAlerts': instance.enableEnvironmentAlerts,
      'enableCompletionAlerts': instance.enableCompletionAlerts,
      'enableSound': instance.enableSound,
      'enableVibration': instance.enableVibration,
      'alertLeadTime': instance.alertLeadTime,
      'temperatureThreshold': instance.temperatureThreshold,
      'humidityThreshold': instance.humidityThreshold,
      'timeDeviationThreshold': instance.timeDeviationThreshold,
    };
