import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'package:my_recipe_book/services/analysis/recipe_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/ingredient_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/environment_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/nutritional_analysis_module.dart';

import 'analysis_modules_test.mocks.dart';

@GenerateMocks([AnalysisRequest, Recipe, Ingredient, EnvironmentalConditions, AnalysisOptions])
void main() {
  group('RecipeAnalysisModule', () {
    late RecipeAnalysisModule module;

    setUp(() {
      module = RecipeAnalysisModule();
      module.onInitialize(); // 모듈 초기화
    });

    tearDown(() {
      module.onDispose(); // 모듈 정리
    });

    test('canHandle should return true for valid recipe request', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(
          title: 'Test Recipe',
          instructions: ['Step 1', 'Step 2'],
          ingredients: [],
        ),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isTrue);
    });

    test('canHandle should return false for invalid recipe request', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(
          title: '', // Invalid title
          instructions: [], // Invalid instructions
          ingredients: [],
        ),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isFalse);
    });

    test('analyze should return complexity, time optimization, and risk assessment', () async {
      final recipe = Recipe(
        title: 'Simple Cake',
        instructions: ['Mix ingredients', 'Bake for 30 mins'],
        ingredients: [
          Ingredient(name: 'Flour', amount: 200, unit: 'g'),
          Ingredient(name: 'Sugar', amount: 100, unit: 'g'),
          Ingredient(name: 'Eggs', amount: 2, unit: 'ea'),
        ],
        prepTime: 15,
        cookTime: 30,
      );
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: recipe,
        ingredients: recipe.ingredients,
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await module.analyze(request);

      expect(result, containsPair('basic_info', isA<Map>()));
      expect(result, containsPair('complexity', isA<Map>()));
      expect(result, containsPair('time_optimization', isA<Map>()));
      expect(result, containsPair('risk_assessment', isA<Map>()));
      expect(result, containsPair('techniques', isA<Map>()));
      expect(result, containsPair('overall_score', isA<double>()));

      // Add more specific assertions based on expected logic
      // These values are illustrative and should be adjusted based on actual module implementation
      expect(result['complexity']['score'], greaterThanOrEqualTo(3.0));
      expect(result['complexity']['score'], lessThanOrEqualTo(7.0));
      expect(result['time_optimization']['score'], greaterThanOrEqualTo(50.0));
      expect(result['time_optimization']['score'], lessThanOrEqualTo(90.0));
      expect(result['overall_score'], greaterThanOrEqualTo(60.0));
      expect(result['overall_score'], lessThanOrEqualTo(90.0));
    });
  });

  group('IngredientAnalysisModule', () {
    late IngredientAnalysisModule module;

    setUp(() {
      module = IngredientAnalysisModule();
      module.onInitialize();
    });

    tearDown(() {
      module.onDispose();
    });

    test('canHandle should return true if ingredients are not empty', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [Ingredient(name: 'Flour', amount: 100, unit: 'g')],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isTrue);
    });

    test('canHandle should return false if ingredients are empty', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isFalse);
    });

    test('analyze should return ingredient quality, substitution suggestions, and interactions', () async {
      final ingredients = [
        Ingredient(name: 'Flour', amount: 200, unit: 'g'),
        Ingredient(name: 'Butter', amount: 100, unit: 'g'),
        Ingredient(name: 'Baking Soda', amount: 5, unit: 'g'),
        Ingredient(name: 'Lemon Juice', amount: 10, unit: 'ml'),
      ];
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: ingredients,
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await module.analyze(request);

      expect(result, containsPair('ingredient_quality', isA<Map>()));
      expect(result, containsPair('substitution_suggestions', isA<List>()));
      expect(result, containsPair('ingredient_interactions', isA<List>()));

      // Add more specific assertions based on expected logic
      expect(result['ingredient_quality']['Flour'], greaterThan(0.8)); // Assuming quality score
      expect(result['substitution_suggestions'], contains('Butter -> Applesauce')); // Example substitution
      expect(result['ingredient_interactions'], contains('Baking Soda + Lemon Juice: CO2 production')); // Example interaction

      // Test edge cases for ingredients
      final emptyIngredientsRequest = AnalysisRequest(id: 'test_id', recipe: Recipe(title: 'Test', instructions: [], ingredients: []), ingredients: [], environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0), options: AnalysisOptions(), createdAt: DateTime.now(), priority: 1);
      final emptyResult = await module.analyze(emptyIngredientsRequest);
      expect(emptyResult['ingredient_interactions'], isEmpty);
    });
  });

  group('EnvironmentAnalysisModule', () {
    late EnvironmentAnalysisModule module;

    setUp(() {
      module = EnvironmentAnalysisModule();
      module.onInitialize();
    });

    tearDown(() {
      module.onDispose();
    });

    test('canHandle should return true if environment is not null', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isTrue);
    });

    test('canHandle should return false if environment is null', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: null, // Null environment
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isFalse);
    });

    test('analyze should return temperature/humidity, altitude, and seasonal factor analysis', () async {
      final environment = EnvironmentalConditions(temperature: 20, humidity: 45, altitude: 500);
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: environment,
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await module.analyze(request);

      expect(result, containsPair('temperature_humidity_correction', isA<Map>()));
      expect(result, containsPair('altitude_analysis', isA<Map>()));
      expect(result, containsPair('seasonal_factor_analysis', isA<Map>()));

      // Add more specific assertions based on expected logic
      expect(result['temperature_humidity_correction']['temperature_adjustment'], closeTo(-1.0, 0.1)); // Example adjustment
      expect(result['temperature_humidity_correction']['humidity_adjustment'], closeTo(-5.0, 0.1)); // Example adjustment
      expect(result['altitude_analysis']['pressure_factor'], greaterThan(1.0)); // Example factor

      // Test with different environmental conditions
      final summerEnvironment = EnvironmentalConditions(temperature: 30, humidity: 80, altitude: 0, season: Season.summer);
      final summerRequest = AnalysisRequest(
        id: 'test_id_summer',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: summerEnvironment,
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      final summerResult = await module.analyze(summerRequest);
      expect(summerResult['temperature_humidity_correction']['temperature_adjustment'], lessThan(0.0)); // Expect negative adjustment for high temp
      expect(summerResult['seasonal_factor_analysis']['season'], 'summer');

      final winterEnvironment = EnvironmentalConditions(temperature: 10, humidity: 30, altitude: 0, season: Season.winter);
      final winterRequest = AnalysisRequest(
        id: 'test_id_winter',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [],
        environment: winterEnvironment,
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      final winterResult = await module.analyze(winterRequest);
      expect(winterResult['temperature_humidity_correction']['temperature_adjustment'], greaterThan(0.0)); // Expect positive adjustment for low temp
      expect(winterResult['seasonal_factor_analysis']['season'], 'winter');
    });
  });

  group('NutritionalAnalysisModule', () {
    late NutritionalAnalysisModule module;

    setUp(() {
      module = NutritionalAnalysisModule();
      module.onInitialize();
    });

    tearDown(() {
      module.onDispose();
    });

    test('canHandle should return true if recipe and ingredients are not empty', () {
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [Ingredient(name: 'Flour', amount: 100, unit: 'g')],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request), isTrue);
    });

    test('canHandle should return false if recipe or ingredients are empty', () {
      final request1 = AnalysisRequest(
        id: 'test_id',
        recipe: null, // Null recipe
        ingredients: [Ingredient(name: 'Flour', amount: 100, unit: 'g')],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      final request2 = AnalysisRequest(
        id: 'test_id',
        recipe: Recipe(title: 'Test', instructions: [], ingredients: []),
        ingredients: [], // Empty ingredients
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      expect(module.canHandle(request1), isFalse);
      expect(module.canHandle(request2), isFalse);
    });

    test('analyze should return calories, nutrient balance, health metrics, and dietary restrictions', () async {
      final recipe = Recipe(title: 'Test Cake', instructions: [], ingredients: []);
      final ingredients = [
        Ingredient(name: 'Flour', amount: 200, unit: 'g'),
        Ingredient(name: 'Sugar', amount: 100, unit: 'g'),
        Ingredient(name: 'Butter', amount: 50, unit: 'g'),
      ];
      final request = AnalysisRequest(
        id: 'test_id',
        recipe: recipe,
        ingredients: ingredients,
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await module.analyze(request);

      expect(result, containsPair('calories', isA<Map>()));
      expect(result, containsPair('nutrient_balance', isA<Map>()));
      expect(result, containsPair('health_metrics', isA<Map>()));
      expect(result, containsPair('dietary_restrictions', isA<List>()));

      // Add more specific assertions based on expected logic
      expect(result['calories']['total'], greaterThan(500.0)); // Example calorie count
      expect(result['nutrient_balance']['protein'], greaterThan(10.0)); // Example protein
      expect(result['dietary_restrictions'], contains('Gluten')); // Example restriction
    });

    // Test with ingredients that trigger specific dietary restrictions
    test('should handle gluten-free ingredients', () async {
      final glutenFreeRecipe = Recipe(title: 'Gluten-Free Bread', instructions: [], ingredients: []);
      final glutenFreeIngredients = [
        Ingredient(name: 'Almond Flour', amount: 200, unit: 'g'),
        Ingredient(name: 'Xanthan Gum', amount: 5, unit: 'g'),
      ];
      final glutenFreeRequest = AnalysisRequest(
        id: 'test_id_gluten_free',
        recipe: glutenFreeRecipe,
        ingredients: glutenFreeIngredients,
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
      );
      final glutenFreeResult = await module.analyze(glutenFreeRequest);
      expect(glutenFreeResult['dietary_restrictions'], contains('Gluten-Free'));
      expect(glutenFreeResult['calories']['total'], greaterThan(800.0));
    });
  });
}