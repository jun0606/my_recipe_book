import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/services/common_analysis_pipeline.dart';
import 'package:my_recipe_book/models/recipe_analysis_result.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'; // Import all necessary models from here
import 'package:my_recipe_book/models/process_guide.dart';

// Import mocks
import '../mocks/common_analysis_pipeline_mocks.dart';

void main() {
  group('CommonAnalysisPipeline', () {
    late MockBakingScienceFormulaEngine mockFormulaEngine;
    late CommonAnalysisPipeline pipeline;

    setUp(() {
      mockFormulaEngine = MockBakingScienceFormulaEngine();
      pipeline = CommonAnalysisPipeline(mockFormulaEngine);
    });

    group('analyzeRecipe', () {
      test('should extract keywords from title and ingredients', () {
        final recipe = MockRecipe(
          title: 'Delicious Sourdough Bread',
          ingredients: [
            MockIngredient(name: 'All-purpose Flour', amount: 500, unit: 'g', properties: {}),
            MockIngredient(name: 'Water', amount: 350, unit: 'ml', properties: {}),
            MockIngredient(name: 'Salt', amount: 10, unit: 'g', properties: {}),
            MockIngredient(name: 'Sourdough Starter', amount: 100, unit: 'g', properties: {}),
          ],
          category: RecipeCategory.bread,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = pipeline.analyzeRecipe(recipe);

        expect(result.extractedKeywords, containsAll(['delicious', 'sourdough', 'bread', 'all-purpose flour', 'water', 'salt', 'sourdough starter']));
        expect(result.determinedCategory, 'bread');
      });

      test('should determine category as bread', () {
        final recipe = MockRecipe(
          title: 'Whole Wheat Loaf',
          ingredients: [
            MockIngredient(name: 'Whole Wheat Flour', amount: 500, unit: 'g', properties: {}),
            MockIngredient(name: 'Yeast', amount: 5, unit: 'g', properties: {}),
          ],
          category: RecipeCategory.bread,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = pipeline.analyzeRecipe(recipe);
        expect(result.determinedCategory, 'bread');
      });

      test('should determine category as cake', () {
        final recipe = MockRecipe(
          title: 'Chocolate Fudge Cake',
          ingredients: [
            MockIngredient(name: 'Sugar', amount: 200, unit: 'g', properties: {}),
            MockIngredient(name: 'Butter', amount: 100, unit: 'g', properties: {}),
            MockIngredient(name: 'Eggs', amount: 3, unit: 'ea', properties: {}),
          ],
          category: RecipeCategory.cake,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = pipeline.analyzeRecipe(recipe);
        expect(result.determinedCategory, 'cake');
      });

      test('should determine category as cookie', () {
        final recipe = MockRecipe(
          title: 'Oatmeal Raisin Cookies',
          ingredients: [
            MockIngredient(name: 'Brown Sugar', amount: 150, unit: 'g', properties: {}),
            MockIngredient(name: 'Oats', amount: 200, unit: 'g', properties: {}),
            MockIngredient(name: 'Cookie Dough', amount: 1, unit: 'batch', properties: {}),
          ],
          category: RecipeCategory.cookie,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = pipeline.analyzeRecipe(recipe);
        expect(result.determinedCategory, 'cookie');
      });

      test('should determine category as dessert', () {
        final recipe = MockRecipe(
          title: 'Vanilla Bean Ice Cream',
          ingredients: [
            MockIngredient(name: 'Heavy Cream', amount: 500, unit: 'ml', properties: {}),
            MockIngredient(name: 'Vanilla Extract', amount: 5, unit: 'ml', properties: {}),
          ],
          category: RecipeCategory.dessert,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = pipeline.analyzeRecipe(recipe);
        expect(result.determinedCategory, 'dessert');
      });

      test('should use explicit category if provided', () {
        final recipe = MockRecipe(
          title: 'Generic Recipe',
          ingredients: [],
          category: RecipeCategory.bread, // Explicitly set
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = pipeline.analyzeRecipe(recipe);
        expect(result.determinedCategory, 'bread');
      });
    });

    group('selectModule', () {
      test('should return BreadModule for bread keywords', () {
        final module = pipeline.selectModule(['bread'], []);
        expect(module, isA<BreadModule>());
      });

      test('should return CakeModule for cake keywords', () {
        final module = pipeline.selectModule(['cake'], []);
        expect(module, isA<CakeModule>());
      });

      test('should return CookieModule for cookie keywords', () {
        final module = pipeline.selectModule(['cookie'], []);
        expect(module, isA<CookieModule>());
      });

      test('should return DessertModule for dessert keywords', () {
        final module = pipeline.selectModule(['dessert'], []);
        expect(module, isA<DessertModule>());
      });

      test('should throw ArgumentError for unknown module type', () {
        expect(() => pipeline.selectModule(['unknown_type'], []),
            throwsA(isA<ArgumentError>()));
      });
    });

    group('processEnvironment', () {
      test('should delegate to BakingScienceFormulaEngine', () {
        final conditions = MockEnvironmentalConditions(
          temperature: 25,
          humidity: 60,
          pressure: 1013,
          season: Season.summer,
          oven: MockOvenCharacteristics(type: OvenType.convection, maxTemperature: 250, typeCoefficient: 1.0, calibrationIndex: 1.0, steamCapability: 0.0, hasConvection: true),
        );
        final result = pipeline.processEnvironment(conditions);
        expect(result, isA<MockEnvironmentCorrection>());
      });
    });

    group('generateIngredientMetadata', () {
      test('should generate metadata for known ingredients', () {
        final ingredients = [
          MockIngredient(name: 'All-purpose Flour', amount: 100, unit: 'g', properties: {'protein': 10.0}),
          MockIngredient(name: 'Sugar', amount: 50, unit: 'g', properties: {'sweetness': 1.0}),
        ];
        final metadata = pipeline.generateIngredientMetadata(ingredients);

        expect(metadata.length, 2);
        expect(metadata[0].name, 'All-purpose Flour');
        expect(metadata[0].function, 'structure');
        expect(metadata[1].name, 'Sugar');
        expect(metadata[1].function, 'sweetener');
      });

      test('should handle unknown ingredients', () {
        final ingredients = [
          MockIngredient(name: 'Unknown Ingredient', amount: 10, unit: 'g', properties: {}),
        ];
        final metadata = pipeline.generateIngredientMetadata(ingredients);

        expect(metadata.length, 1);
        expect(metadata[0].name, 'Unknown Ingredient');
        expect(metadata[0].function, 'unknown');
      });
    });

    group('generateProcessGuide', () {
      test('should generate bread process guide for BreadModule', () {
        final recipe = MockRecipe(
          title: 'Bread',
          ingredients: [],
          category: RecipeCategory.bread,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final module = MockBreadModule();
        final guide = pipeline.generateProcessGuide(recipe, module);

        expect(guide.mixingGuide, 'Mock Bread Mixing Guide');
        expect(guide.fermentationGuide, 'Mock Bread Fermentation Guide');
        expect(guide.bakingGuide, 'Mock Bread Baking Guide');
        expect(guide.overallProcessSummary, 'Detailed bread making process guide.');
      });

      test('should generate cake process guide for CakeModule', () {
        final recipe = MockRecipe(
          title: 'Cake',
          ingredients: [],
          category: RecipeCategory.cake,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final module = MockCakeModule();
        final guide = pipeline.generateProcessGuide(recipe, module);

        expect(guide.bakingGuide, 'Mock Cake Baking Guide');
        expect(guide.overallProcessSummary, 'Detailed cake making process guide.');
      });

      test('should generate generic process guide for unknown module type', () {
        final recipe = MockRecipe(
          title: 'Unknown',
          ingredients: [],
          category: RecipeCategory.bread,
          processes: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final module = MockBakingModule(); // Generic mock baking module
        final guide = pipeline.generateProcessGuide(recipe, module);

        expect(guide.overallProcessSummary, 'Could not generate specific process guide for this module type.');
      });
    });
  });
}
