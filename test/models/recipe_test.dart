import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';

void main() {
  group('Recipe Model Tests', () {
    test('should serialize and deserialize correctly', () {
      // Arrange
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        category: 'Test Category',
        instructions: [
          'Test instruction 1',
          'Test instruction 2',
        ],
        ingredients: [
          Ingredient(name: 'Test Ingredient 1', amount: 100.0, unit: 'g'),
          Ingredient(name: 'Test Ingredient 2', amount: 2.0, unit: 'cups'),
        ],
        imagePath: '/test/path/image.jpg',
        baseServings: 4,
        isBaking: true,
        targetSplitAmount: 50.0,
        targetSplitCount: 2,
        calculatedRemainingWeight: 25.0,
        totalIngredientWeight: 102.0,
        parentId: 5,
      );

      // Act
      final json = recipe.toJson();
      final deserializedRecipe = Recipe.fromJson(json);

      // Assert
      expect(deserializedRecipe.id, recipe.id);
      expect(deserializedRecipe.title, recipe.title);
      expect(deserializedRecipe.category, recipe.category);
      expect(deserializedRecipe.instructions, recipe.instructions);
      expect(deserializedRecipe.ingredients.length, recipe.ingredients.length);
      for (int i = 0; i < recipe.ingredients.length; i++) {
        expect(
            deserializedRecipe.ingredients[i].name, recipe.ingredients[i].name);
        expect(deserializedRecipe.ingredients[i].amount,
            recipe.ingredients[i].amount);
        expect(
            deserializedRecipe.ingredients[i].unit, recipe.ingredients[i].unit);
      }
      expect(deserializedRecipe.imagePath, recipe.imagePath);
      expect(deserializedRecipe.baseServings, recipe.baseServings);
      expect(deserializedRecipe.isBaking, recipe.isBaking);
      expect(deserializedRecipe.targetSplitAmount, recipe.targetSplitAmount);
      expect(deserializedRecipe.targetSplitCount, recipe.targetSplitCount);
      expect(deserializedRecipe.calculatedRemainingWeight,
          recipe.calculatedRemainingWeight);
      expect(deserializedRecipe.totalIngredientWeight,
          recipe.totalIngredientWeight);
      expect(deserializedRecipe.parentId, recipe.parentId);
    });

    test('should handle null values correctly', () {
      // Arrange
      final recipe = Recipe(
        title: 'Minimal Recipe',
        category: 'Test',
        instructions: [],
        ingredients: [],
      );

      // Act
      final json = recipe.toJson();
      final deserializedRecipe = Recipe.fromJson(json);

      // Assert
      expect(deserializedRecipe.id, isNull);
      expect(deserializedRecipe.imagePath, isNull);
      expect(deserializedRecipe.targetSplitAmount, isNull);
      expect(deserializedRecipe.targetSplitCount, isNull);
      expect(deserializedRecipe.calculatedRemainingWeight, isNull);
      expect(deserializedRecipe.totalIngredientWeight, isNull);
      expect(deserializedRecipe.parentId, isNull);
      expect(deserializedRecipe.baseServings, 1);
      expect(deserializedRecipe.isBaking, false);
    });

    test('should handle backward compatibility for isBaking field', () {
      // Test with integer value (old format)
      final jsonWithInt = {
        'title': 'Test Recipe',
        'category': 'Test',
        'ingredients': '[]',
        'instructions': '[]',
        'isBaking': 1,
      };

      final recipeFromInt = Recipe.fromJson(jsonWithInt);
      expect(recipeFromInt.isBaking, true);

      // Test with boolean value (new format)
      final jsonWithBool = {
        'title': 'Test Recipe',
        'category': 'Test',
        'ingredients': '[]',
        'instructions': '[]',
        'isBaking': true,
      };

      final recipeFromBool = Recipe.fromJson(jsonWithBool);
      expect(recipeFromBool.isBaking, true);
    });

    test('should handle malformed JSON gracefully', () {
      // Arrange
      final malformedJson = {
        'title': 'Test Recipe',
        'category': 'Test',
        'ingredients': 'invalid json',
        'instructions': 'invalid json',
      };

      // Act
      final recipe = Recipe.fromJson(malformedJson);

      // Assert - Recipe should be created with fallback values for invalid fields
      expect(recipe.title, 'Test Recipe');
      expect(recipe.category, 'Test');
      // Invalid JSON strings are handled gracefully with empty lists
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions,
          contains('invalid json')); // Fallback to string list
    });
  });
}
