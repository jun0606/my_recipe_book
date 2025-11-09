import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/process_guide.dart'; // Import ProcessGuide
import 'package:my_recipe_book/models/baking_modules.dart';
import 'package:my_recipe_book/services/baking_science_formula_engine.dart';

// Mock Recipe and Ingredient (if not already defined in a common mock file)
class MockRecipe extends Recipe {
  MockRecipe({
    required String title,
    required List<Ingredient> ingredients,
    required RecipeCategory category,
    required List<String> processes,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
  }) : super(
          title: title,
          ingredients: ingredients,
          processes: processes,
          category: category,
          createdAt: createdAt,
          updatedAt: updatedAt,
          description: description,
        );
}

class MockIngredient extends Ingredient {
  MockIngredient({
    required String name,
    required double amount,
    required String unit,
    required Map<String, dynamic> properties,
  }) : super(name: name, amount: amount, unit: unit, properties: properties);
}

// Mock EnvironmentalConditions
class MockEnvironmentalConditions extends EnvironmentalConditions {
  MockEnvironmentalConditions({
    required double temperature,
    required double humidity,
    required double pressure,
    required Season season,
    required OvenCharacteristics oven,
    double? altitude,
  }) : super(
          temperature: temperature,
          humidity: humidity,
          pressure: pressure,
          season: season,
          oven: oven,
          altitude: altitude,
        );
}

// Mock IngredientMetadata
class MockIngredientMetadata extends IngredientMetadata {
  MockIngredientMetadata({
    required String name,
    required Map<String, dynamic> properties,
    required double effectiveValue,
    required String function,
    required double qualityCorrectionFactor,
  }) : super(
          name: name,
          properties: properties,
          effectiveValue: effectiveValue,
          function: function,
          qualityCorrectionFactor: qualityCorrectionFactor,
        );
}

// Mock BakingScienceFormulaEngine
class MockBakingScienceFormulaEngine extends BakingScienceFormulaEngine {
  @override
  EnvironmentCorrection calculateEnvironmentCorrection(EnvironmentalConditions conditions) {
    return MockEnvironmentCorrection();
  }
  // Add other methods if they are called by CommonAnalysisPipeline and need specific mock behavior
}

// Mock EnvironmentCorrection
class MockEnvironmentCorrection extends EnvironmentCorrection {
  // Add properties/methods if needed for testing
  MockEnvironmentCorrection({
    double temperatureCorrection = 1.0,
    double humidityCorrection = 1.0,
    double altitudeCorrection = 1.0,
  }) : super(
          temperatureCorrection: temperatureCorrection,
          humidityCorrection: humidityCorrection,
          altitudeCorrection: altitudeCorrection,
        );
}

// Mock BakingModule and its concrete implementations
class MockBakingModule extends BakingModule {}

class MockBreadModule extends BreadModule {
  @override
  String generateMixingGuide(Recipe recipe, EnvironmentalConditions conditions) {
    return "Mock Bread Mixing Guide";
  }

  @override
  String generateFermentationGuide(Recipe recipe, BreadMethod method) {
    return "Mock Bread Fermentation Guide";
  }

  @override
  String generateBakingGuide(String breadType, DoughPhysicalState state) {
    return "Mock Bread Baking Guide";
  }
}

class MockCakeModule extends CakeModule {
  @override
  String optimizeCakeBaking(Recipe recipe, OvenCharacteristics oven) {
    return "Mock Cake Baking Guide";
  }
}

class MockCookieModule extends CookieModule {}
class MockDessertModule extends DessertModule {}

// Mock DoughPhysicalState
class MockDoughPhysicalState extends DoughPhysicalState {
  MockDoughPhysicalState({
    required double glutenStrengthIndex,
    required double doughElasticityIndex,
  }) : super(
          glutenStrengthIndex: glutenStrengthIndex,
          doughElasticityIndex: doughElasticityIndex,
        );
}

// Mock OvenCharacteristics
class MockOvenCharacteristics extends OvenCharacteristics {
  MockOvenCharacteristics({
    required OvenType type,
    required double typeCoefficient,
    required double calibrationIndex,
    required double steamCapability,
    required bool hasConvection,
    required double maxTemperature,
    bool hasStone = false,
    bool hasSteam = false,
    double temperatureAccuracy = 0.95,
  }) : super(
          type: type,
          typeCoefficient: typeCoefficient,
          calibrationIndex: calibrationIndex,
          steamCapability: steamCapability,
          hasConvection: hasConvection,
          maxTemperature: maxTemperature,
          hasStone: hasStone,
          hasSteam: hasSteam,
          temperatureAccuracy: temperatureAccuracy,
        );
}

// Mock BreadMethod
class MockBreadMethod extends BreadMethod {
  MockBreadMethod({
    required String name,
    double starterRatio = 0.0,
    double fermentationTemperature = 24.0,
    double fermentationTime = 120.0,
    String description = '',
  }) : super(
          name: name,
          starterRatio: starterRatio,
          fermentationTemperature: fermentationTemperature,
          fermentationTime: fermentationTime,
          description: description,
        );
}