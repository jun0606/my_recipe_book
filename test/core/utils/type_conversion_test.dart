// test/core/utils/type_conversion_test.dart
// 타입 변환 시스템 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/core/utils/safe_type_converter.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/core/utils/type_converter_factory.dart';

void main() {
  group('SafeTypeConverter Tests', () {
    test('safeToString handles all types correctly', () {
      expect(SafeTypeConverter.safeToString('test'), 'test');
      expect(SafeTypeConverter.safeToString(123), '123');
      expect(SafeTypeConverter.safeToString(45.67), '45.67');
      expect(SafeTypeConverter.safeToString(true), 'true');
      expect(SafeTypeConverter.safeToString(null), '');
      expect(SafeTypeConverter.safeToString(null, defaultValue: 'default'),
          'default');
    });

    test('safeToStringRequired throws on empty string', () {
      expect(() => SafeTypeConverter.safeToStringRequired('', 'field'),
          throwsA(isA<ValidationException>()));
      expect(() => SafeTypeConverter.safeToStringRequired(null, 'field'),
          throwsA(isA<ValidationException>()));
    });

    test('safeToInt handles all types correctly', () {
      expect(SafeTypeConverter.safeToInt(123), 123);
      expect(SafeTypeConverter.safeToInt(45.67), 45);
      expect(SafeTypeConverter.safeToInt('789'), 789);
      expect(SafeTypeConverter.safeToInt('invalid'), null);
      expect(SafeTypeConverter.safeToInt(null), null);
    });

    test('safeToDouble handles all types correctly', () {
      expect(SafeTypeConverter.safeToDouble(45.67), 45.67);
      expect(SafeTypeConverter.safeToDouble(123), 123.0);
      expect(SafeTypeConverter.safeToDouble('45.67'), 45.67);
      expect(SafeTypeConverter.safeToDouble('invalid'), 0.0);
      expect(SafeTypeConverter.safeToDouble(null), 0.0);
      expect(SafeTypeConverter.safeToDouble(null, defaultValue: 99.0), 99.0);
    });

    test('safeToBool handles all types correctly', () {
      expect(SafeTypeConverter.safeToBool(true), true);
      expect(SafeTypeConverter.safeToBool(false), false);
      expect(SafeTypeConverter.safeToBool(1), true);
      expect(SafeTypeConverter.safeToBool(0), false);
      expect(SafeTypeConverter.safeToBool('true'), true);
      expect(SafeTypeConverter.safeToBool('false'), false);
      expect(SafeTypeConverter.safeToBool('1'), true);
      expect(SafeTypeConverter.safeToBool('0'), false);
      expect(SafeTypeConverter.safeToBool(null), false);
    });

    test('safeToDateTime handles all types correctly', () {
      final dateStr = '2023-01-01T10:00:00.000Z';
      final dateTime = DateTime.parse(dateStr);

      expect(SafeTypeConverter.safeToDateTime(dateTime), dateTime);
      expect(SafeTypeConverter.safeToDateTime(dateStr), dateTime);
      expect(SafeTypeConverter.safeToDateTime(1234567890), isA<DateTime>());
      expect(SafeTypeConverter.safeToDateTime('invalid'), null);
      expect(SafeTypeConverter.safeToDateTime(null), null);
    });

    test('safeToList handles all types correctly', () {
      final list = [1, 2, 3];
      expect(SafeTypeConverter.safeToList<int>(list), list);
      expect(SafeTypeConverter.safeToList<String>(['a', 'b']), ['a', 'b']);
      expect(SafeTypeConverter.safeToList<String>(null), []);
      expect(
          SafeTypeConverter.safeToList<String>(null, defaultValue: ['default']),
          ['default']);
    });

    test('safeToMap handles all types correctly', () {
      final map = {'key': 'value'};
      expect(SafeTypeConverter.safeToMap<String, String>(map), map);
      expect(SafeTypeConverter.safeToMap(null), {});
      expect(
          SafeTypeConverter.safeToMap(null, defaultValue: {'default': 'value'}),
          {'default': 'value'});
    });
  });

  group('RecipeConverter Tests', () {
    test('converts valid Map to Recipe successfully', () {
      final json = {
        'title': 'Test Recipe',
        'category': 'Baking',
        'ingredients': [
          {'name': 'Flour', 'amount': 100.0, 'unit': 'g', 'id': 'flour-1'},
          {'name': 'Water', 'amount': 50.0, 'unit': 'ml', 'id': 'water-1'}
        ],
        'instructions': [
          {'title': 'Mix', 'description': 'Mix ingredients'},
          {'title': 'Bake', 'description': 'Bake at 180°C'}
        ],
        'baseServings': 4,
        'isBaking': true,
        'cookingTime': 30,
        'difficulty': 'Easy'
      };

      final recipe = TypeConverterFactory.recipe.fromJson(json);

      expect(recipe.title, 'Test Recipe');
      expect(recipe.category, 'Baking');
      expect(recipe.ingredients.length, 2);
      expect(recipe.instructions.length, 2);
      expect(recipe.baseServings, 4);
      expect(recipe.isBaking, true);
      expect(recipe.cookingTime, 30);
      expect(recipe.difficulty, 'Easy');
    });

    test('throws ValidationException on invalid data', () {
      final invalidJson = {
        'title': '', // Empty title should fail
        'category': 'Baking',
        'ingredients': [],
        'instructions': []
      };

      expect(() => TypeConverterFactory.recipe.fromJson(invalidJson),
          throwsA(isA<ValidationException>()));
    });

    test('handles missing optional fields gracefully', () {
      final minimalJson = {
        'title': 'Minimal Recipe',
        'category': 'Basic',
        'ingredients': [],
        'instructions': []
      };

      final recipe = TypeConverterFactory.recipe.fromJson(minimalJson);

      expect(recipe.title, 'Minimal Recipe');
      expect(recipe.category, 'Basic');
      expect(recipe.baseServings, 1); // Default value
      expect(recipe.isBaking, false); // Default value
      expect(recipe.cookingTime, null); // Optional field
    });

    test('converts Recipe to Map successfully', () {
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        category: 'Baking',
        ingredients: [
          Ingredient(id: 'flour-1', name: 'Flour', amount: 100.0, unit: 'g'),
        ],
        instructions: [
          {'title': 'Mix', 'description': 'Mix well'}
        ],
        baseServings: 4,
        isBaking: true,
        cookingTime: 30,
      );

      final json = TypeConverterFactory.recipe.toJson(recipe);

      expect(json['id'], 1);
      expect(json['title'], 'Test Recipe');
      expect(json['category'], 'Baking');
      expect(json['baseServings'], 4);
      expect(json['isBaking'], 1);
      expect(json['cookingTime'], 30);
    });
  });

  group('IngredientConverter Tests', () {
    test('converts valid Map to Ingredient successfully', () {
      final json = {
        'name': 'Flour',
        'amount': 100.0,
        'unit': 'g',
        'properties': {'type': 'bread'}
      };

      final ingredient = TypeConverterFactory.ingredient.fromJson(json);

      expect(ingredient.name, 'Flour');
      expect(ingredient.amount, 100.0);
      expect(ingredient.unit, 'g');
      expect(ingredient.properties, {'type': 'bread'});
    });

    test('throws ValidationException on invalid data', () {
      final invalidJson = {
        'name': '', // Empty name should fail
        'amount': 100.0,
        'unit': 'g'
      };

      expect(() => TypeConverterFactory.ingredient.fromJson(invalidJson),
          throwsA(isA<ValidationException>()));
    });

    test('handles missing optional fields gracefully', () {
      final minimalJson = {
        'name': 'Sugar',
        'amount': 50.0,
        'unit': 'g'
        // No properties
      };

      final ingredient = TypeConverterFactory.ingredient.fromJson(minimalJson);

      expect(ingredient.name, 'Sugar');
      expect(ingredient.amount, 50.0);
      expect(ingredient.unit, 'g');
      expect(ingredient.properties, null);
    });

    test('converts Ingredient to Map successfully', () {
      final ingredient = Ingredient(
          id: 'butter-1',
          name: 'Butter',
          amount: 50.0,
          unit: 'g',
          properties: {'type': 'dairy'});

      final json = TypeConverterFactory.ingredient.toJson(ingredient);

      expect(json['name'], 'Butter');
      expect(json['amount'], 50.0);
      expect(json['unit'], 'g');
      expect(json['properties'], {'type': 'dairy'});
    });
  });

  group('Integration Tests', () {
    test('full Recipe conversion cycle works correctly', () {
      // Create original recipe
      final originalRecipe = Recipe(
        id: 42,
        title: 'Integration Test Recipe',
        category: 'Baking',
        ingredients: [
          Ingredient(id: 'flour-1', name: 'Flour', amount: 200.0, unit: 'g'),
          Ingredient(id: 'water-1', name: 'Water', amount: 150.0, unit: 'ml'),
        ],
        instructions: [
          {'title': 'Mix', 'description': 'Mix ingredients well'},
          {'title': 'Bake', 'description': 'Bake at 180°C for 30 minutes'}
        ],
        baseServings: 6,
        isBaking: true,
        cookingTime: 30,
        difficulty: 'Medium',
      );

      // Convert to JSON
      final json = TypeConverterFactory.recipe.toJson(originalRecipe);

      // Convert back to Recipe
      final reconstructedRecipe = TypeConverterFactory.recipe.fromJson(json);

      // Verify all fields match
      expect(reconstructedRecipe.id, originalRecipe.id);
      expect(reconstructedRecipe.title, originalRecipe.title);
      expect(reconstructedRecipe.category, originalRecipe.category);
      expect(reconstructedRecipe.ingredients.length,
          originalRecipe.ingredients.length);
      expect(reconstructedRecipe.instructions.length,
          originalRecipe.instructions.length);
      expect(reconstructedRecipe.baseServings, originalRecipe.baseServings);
      expect(reconstructedRecipe.isBaking, originalRecipe.isBaking);
      expect(reconstructedRecipe.cookingTime, originalRecipe.cookingTime);
      expect(reconstructedRecipe.difficulty, originalRecipe.difficulty);
    });

    test('handles complex nested data correctly', () {
      final complexJson = {
        'title': 'Complex Recipe',
        'category': 'Advanced Baking',
        'ingredients': [
          {
            'name': 'Bread Flour',
            'amount': 500.0,
            'unit': 'g',
            'properties': {'type': 'flour', 'protein': '12.5%'}
          },
          {'name': 'Water', 'amount': 350.0, 'unit': 'ml'},
          {'name': 'Salt', 'amount': 10.0, 'unit': 'g'},
        ],
        'instructions': [
          {
            'title': 'Autolyse',
            'description': 'Mix flour and water, rest for 30 minutes'
          },
          {
            'title': 'Mix',
            'description': 'Add salt and mix to medium gluten development'
          },
          {
            'title': 'Bulk Fermentation',
            'description': 'Ferment for 2 hours with folds'
          },
        ],
        'baseServings': 8,
        'isBaking': true,
        'cookingTime': 45,
        'difficulty': 'Advanced',
        'tags': ['sourdough', 'bread', 'advanced'],
        'rating': 4.5,
        'reviewCount': 23,
      };

      final recipe = TypeConverterFactory.recipe.fromJson(complexJson);

      expect(recipe.title, 'Complex Recipe');
      expect(recipe.category, 'Advanced Baking');
      expect(recipe.ingredients.length, 3);
      expect(recipe.instructions.length, 3);
      expect(recipe.tags, ['sourdough', 'bread', 'advanced']);
      expect(recipe.rating, 4.5);
      expect(recipe.reviewCount, 23);
    });
  });
}
