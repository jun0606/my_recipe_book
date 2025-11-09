
import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/recipe_analysis_result.dart';

void main() {
  group('RecipeAnalysisResult', () {
    test('RecipeAnalysisResult can be instantiated with valid data', () {
      final result = RecipeAnalysisResult(
        extractedKeywords: ['flour', 'sugar', 'bread'],
        determinedCategory: 'bread',
      );

      expect(result.extractedKeywords, ['flour', 'sugar', 'bread']);
      expect(result.determinedCategory, 'bread');
    });

    test('RecipeAnalysisResult can be converted to JSON', () {
      final result = RecipeAnalysisResult(
        extractedKeywords: ['flour', 'sugar', 'bread'],
        determinedCategory: 'bread',
      );

      final json = result.toJson();

      expect(json['extractedKeywords'], ['flour', 'sugar', 'bread']);
      expect(json['determinedCategory'], 'bread');
    });

    test('RecipeAnalysisResult can be created from JSON', () {
      final json = {
        'extractedKeywords': ['flour', 'sugar', 'bread'],
        'determinedCategory': 'bread',
      };

      final result = RecipeAnalysisResult.fromJson(json);

      expect(result.extractedKeywords, ['flour', 'sugar', 'bread']);
      expect(result.determinedCategory, 'bread');
    });

    test('RecipeAnalysisResult handles empty keywords list', () {
      final result = RecipeAnalysisResult(
        extractedKeywords: [],
        determinedCategory: 'dessert',
      );

      expect(result.extractedKeywords, []);
      expect(result.determinedCategory, 'dessert');

      final json = result.toJson();
      expect(RecipeAnalysisResult.fromJson(json).extractedKeywords, []);
    });
  });
}
