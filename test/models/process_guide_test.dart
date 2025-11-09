import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/process_guide.dart';

void main() {
  group('ProcessGuide', () {
    test('ProcessGuide can be instantiated with valid data', () {
      final guide = ProcessGuide(
        mixingGuide: 'Mix well',
        fermentationGuide: 'Ferment for 2 hours',
        bakingGuide: 'Bake at 180C',
        overallProcessSummary: 'Complete baking process',
      );

      expect(guide.mixingGuide, 'Mix well');
      expect(guide.fermentationGuide, 'Ferment for 2 hours');
      expect(guide.bakingGuide, 'Bake at 180C');
      expect(guide.overallProcessSummary, 'Complete baking process');
    });

    test('ProcessGuide can be converted to JSON', () {
      final guide = ProcessGuide(
        mixingGuide: 'Mix well',
        fermentationGuide: 'Ferment for 2 hours',
        bakingGuide: 'Bake at 180C',
        overallProcessSummary: 'Complete baking process',
      );

      final json = guide.toJson();

      expect(json['mixingGuide'], 'Mix well');
      expect(json['fermentationGuide'], 'Ferment for 2 hours');
      expect(json['bakingGuide'], 'Bake at 180C');
      expect(json['overallProcessSummary'], 'Complete baking process');
    });

    test('ProcessGuide can be created from JSON', () {
      final json = {
        'mixingGuide': 'Mix well',
        'fermentationGuide': 'Ferment for 2 hours',
        'bakingGuide': 'Bake at 180C',
        'overallProcessSummary': 'Complete baking process',
      };

      final guide = ProcessGuide.fromJson(json);

      expect(guide.mixingGuide, 'Mix well');
      expect(guide.fermentationGuide, 'Ferment for 2 hours');
      expect(guide.bakingGuide, 'Bake at 180C');
      expect(guide.overallProcessSummary, 'Complete baking process');
    });

    test('ProcessGuide handles empty strings', () {
      final guide = ProcessGuide(
        mixingGuide: '',
        fermentationGuide: '',
        bakingGuide: '',
        overallProcessSummary: '',
      );

      expect(guide.mixingGuide, '');
      expect(guide.fermentationGuide, '');
      expect(guide.bakingGuide, '');
      expect(guide.overallProcessSummary, '');

      final json = guide.toJson();
      expect(ProcessGuide.fromJson(json).mixingGuide, '');
    });
  });
}
