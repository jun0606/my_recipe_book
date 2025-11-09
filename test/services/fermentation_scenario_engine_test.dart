import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'
    as advanced_models;
import 'package:my_recipe_book/models/sous_chef_models.dart';
import 'package:my_recipe_book/services/fermentation_scenario_engine.dart';

void main() {
  group('FermentationScenarioEngine', () {
    late FermentationScenarioEngine engine;

    setUp(() {
      engine = FermentationScenarioEngine();
    });

    // Mock data for testing
    final mockRecipeAnalysis = RecipeAnalysis(
      recipeId: 'test_recipe_id',
      recipeName: '테스트 레시피',
      flourAmount: 500,
      yeastAmount: 5,
      sugarAmount: 20,
      liquidAmount: 300,
      fatAmount: 0,
      yeastType: YeastType.dry,
      breadType: BreadType.white,
      analysisTimestamp: DateTime.now(),
    );

    final mockEnvironmentalConditions = advanced_models.EnvironmentalConditions(
      temperature: 22.0,
      humidity: 60.0,
      pressure: 1013.25,
      season: advanced_models.Season.spring,
      altitude: 100,
      oven: advanced_models.OvenCharacteristics(
        type: advanced_models.OvenType.home,
        typeCoefficient: 0.9,
        calibrationIndex: 0.95,
        steamCapability: 0.5,
        hasConvection: false,
        maxTemperature: 250.0,
      ),
    );

    final mockEquipmentProfile = EquipmentProfile(
      id: 'test_equipment',
      name: '테스트 발효기',
      fermenterType: FermenterType.manual,
      capabilities: const {},
      accuracy: const {},
      isConnected: false,
      settings: const {},
    );

    test(
        'generateScenario returns a valid FermentationScenarioV2 for normal room temperature fermentation',
        () async {
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.normal);
      expect(scenario.totalDuration, const Duration(hours: 4));
      expect(scenario.stages.length, 1);
      expect(scenario.stages.first.name, '주 발효 단계');
    });

    test(
        'generateScenario returns a valid FermentationScenarioV2 for cold retardation',
        () async {
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.coldRetardation,
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.coldRetardation);
      expect(scenario.totalDuration, const Duration(hours: 12));
      expect(scenario.stages.length, 1);
    });

    test(
        'generateScenario returns a valid FermentationScenarioV2 for freezer overnight',
        () async {
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.freezerOvernight,
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.freezerOvernight);
      expect(scenario.totalDuration, const Duration(hours: 24));
      expect(scenario.stages.length, 1);
    });

    test(
        'generateScenario returns a valid FermentationScenarioV2 for other methods/modes',
        () async {
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.custom,
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(
          scenario.totalDuration, const Duration(hours: 8)); // Default duration
    });

    test('adaptScenario returns a copied scenario with updated name', () async {
      final initialScenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );

      final mockEnvironmentalChange = EnvironmentalChange(
        newConditions: advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
          season: advanced_models.Season.spring,
          altitude: 100,
          oven: advanced_models.OvenCharacteristics(
            type: advanced_models.OvenType.home,
            typeCoefficient: 0.9,
            calibrationIndex: 0.95,
            steamCapability: 0.5,
            hasConvection: false,
            maxTemperature: 250.0,
          ),
        ),
      );

      final adaptedScenario = await engine.adaptScenario(
        initialScenario,
        mockEnvironmentalChange,
      );

      expect(adaptedScenario, isA<FermentationScenarioV2>());
      expect(adaptedScenario.id, initialScenario.id);
      expect(adaptedScenario.name, '${initialScenario.name} (조정됨)');
    });

    // Boundary value tests
    test('generateScenario handles extreme environmental conditions (low temp)',
        () async {
      final extremeLowEnv = advanced_models.EnvironmentalConditions(
        temperature: 0.0, // Extreme low
        humidity: 10.0,
        pressure: 1013.25,
        season: advanced_models.Season.spring,
        altitude: 0,
        oven: advanced_models.OvenCharacteristics(
          type: advanced_models.OvenType.home,
          typeCoefficient: 0.9,
          calibrationIndex: 0.95,
          steamCapability: 0.5,
          hasConvection: false,
          maxTemperature: 250.0,
        ),
      );
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: mockRecipeAnalysis,
        env: extremeLowEnv,
        equipment: mockEquipmentProfile,
      );
      expect(scenario, isA<FermentationScenarioV2>());
      // Expect totalDuration to be default as simplified logic doesn't adjust for env
      expect(scenario.totalDuration, const Duration(hours: 4));
    });

    test(
        'generateScenario handles extreme environmental conditions (high temp)',
        () async {
      final extremeHighEnv = advanced_models.EnvironmentalConditions(
        temperature: 40.0, // Extreme high
        humidity: 99.0,
        pressure: 1013.25,
        season: advanced_models.Season.spring,
        altitude: 1000,
        oven: advanced_models.OvenCharacteristics(
          type: advanced_models.OvenType.home,
          typeCoefficient: 0.9,
          calibrationIndex: 0.95,
          steamCapability: 0.5,
          hasConvection: false,
          maxTemperature: 250.0,
        ),
      );
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: mockRecipeAnalysis,
        env: extremeHighEnv,
        equipment: mockEquipmentProfile,
      );
      expect(scenario, isA<FermentationScenarioV2>());
      // Expect totalDuration to be default as simplified logic doesn't adjust for env
      expect(scenario.totalDuration, const Duration(hours: 4));
    });

    test('generateScenario handles zero flour amount in recipe', () async {
      final zeroFlourRecipe = RecipeAnalysis(
        recipeId: 'zero_flour',
        recipeName: '밀가루 0 레시피',
        flourAmount: 0, // Boundary value
        yeastAmount: 0,
        sugarAmount: 0,
        liquidAmount: 0,
        fatAmount: 0,
        yeastType: YeastType.dry,
        breadType: BreadType.white,
        analysisTimestamp: DateTime.now(),
      );
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: zeroFlourRecipe,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );
      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.recipeAnalysis.flourAmount, 0);
      // Logic should still produce a scenario, even if not meaningful
      expect(scenario.totalDuration, const Duration(hours: 4));
    });

    test('generateScenario handles very high flour amount in recipe', () async {
      final highFlourRecipe = RecipeAnalysis(
        recipeId: 'high_flour',
        recipeName: '밀가루 대량 레시피',
        flourAmount: 100000, // Boundary value
        yeastAmount: 1000,
        sugarAmount: 5000,
        liquidAmount: 60000,
        fatAmount: 0,
        yeastType: YeastType.dry,
        breadType: BreadType.white,
        analysisTimestamp: DateTime.now(),
      );
      final scenario = await engine.generateScenario(
        mode: FermentationMode.roomTemperature,
        method: FermentationMethodV2.normal,
        recipe: highFlourRecipe,
        env: mockEnvironmentalConditions,
        equipment: mockEquipmentProfile,
      );
      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.recipeAnalysis.flourAmount, 100000);
      expect(scenario.totalDuration, const Duration(hours: 4));
    });
  });
}
