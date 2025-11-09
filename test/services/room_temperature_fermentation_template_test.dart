import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/sous_chef_models.dart';
import 'package:my_recipe_book/services/room_temperature_fermentation_template.dart';

void main() {
  group('RoomTemperatureFermentationTemplate', () {
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

    final mockEnvironmentalConditions = EnvironmentalConditions(
      temperature: 22,
      humidity: 60,
      altitude: 100,
    );

    test('normalRoomFermentation returns a valid FermentationScenarioV2', () async {
      final scenario = await RoomTemperatureFermentationTemplate.normalRoomFermentation(
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.normal);
      expect(scenario.totalDuration, const Duration(hours: 4)); // Based on simplified engine logic
    });

    test('coldRetardation returns a valid FermentationScenarioV2', () async {
      final scenario = await RoomTemperatureFermentationTemplate.coldRetardation(
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        targetBakeTime: DateTime.now().add(const Duration(days: 1)),
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.coldRetardation);
      expect(scenario.totalDuration, const Duration(hours: 12)); // Based on simplified engine logic
    });

    test('freezerOvernight returns a valid FermentationScenarioV2', () async {
      final scenario = await RoomTemperatureFermentationTemplate.freezerOvernight(
        recipe: mockRecipeAnalysis,
        env: mockEnvironmentalConditions,
        plannedUseDate: DateTime.now().add(const Duration(days: 2)),
      );

      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.mode, FermentationMode.roomTemperature);
      expect(scenario.method, FermentationMethodV2.freezerOvernight);
      expect(scenario.totalDuration, const Duration(hours: 24)); // Based on simplified engine logic
    });

    // Boundary value tests for template methods
    test('normalRoomFermentation handles extreme low environmental conditions', () async {
      final extremeLowEnv = EnvironmentalConditions(
        temperature: 0,
        humidity: 10,
        altitude: 0,
      );
      final scenario = await RoomTemperatureFermentationTemplate.normalRoomFermentation(
        recipe: mockRecipeAnalysis,
        env: extremeLowEnv,
      );
      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.totalDuration, const Duration(hours: 4)); // Still based on simplified engine logic
    });

    test('coldRetardation handles extreme high environmental conditions', () async {
      final extremeHighEnv = EnvironmentalConditions(
        temperature: 40,
        humidity: 99,
        altitude: 1000,
      );
      final scenario = await RoomTemperatureFermentationTemplate.coldRetardation(
        recipe: mockRecipeAnalysis,
        env: extremeHighEnv,
        targetBakeTime: DateTime.now().add(const Duration(days: 1)),
      );
      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.totalDuration, const Duration(hours: 12)); // Still based on simplified engine logic
    });

    test('freezerOvernight handles recipe with zero flour amount', () async {
      final zeroFlourRecipe = RecipeAnalysis(
        recipeId: 'zero_flour',
        recipeName: '밀가루 0 레시피',
        flourAmount: 0,
        yeastAmount: 0,
        sugarAmount: 0,
        liquidAmount: 0,
        fatAmount: 0,
        yeastType: YeastType.dry,
        breadType: BreadType.white,
        analysisTimestamp: DateTime.now(),
      );
      final scenario = await RoomTemperatureFermentationTemplate.freezerOvernight(
        recipe: zeroFlourRecipe,
        env: mockEnvironmentalConditions,
        plannedUseDate: DateTime.now().add(const Duration(days: 2)),
      );
      expect(scenario, isA<FermentationScenarioV2>());
      expect(scenario.recipeAnalysis.flourAmount, 0);
      expect(scenario.totalDuration, const Duration(hours: 24));
    });
  });
}
