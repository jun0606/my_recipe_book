
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_recipe_book/services/sous_chef_engine.dart';
import 'package:my_recipe_book/models/sous_chef_models.dart';
import '../mocks/analysis_mocks.dart'; // Mock classes
import '../mocks/analysis_mocks.mocks.dart';

void main() {
  group('SousChefEngine', () {
    late SousChefEngine sousChefEngine;
    late MockAdjustmentModule mockOvenModule; // Changed type
    late MockAdjustmentModule mockFermentationModule; // Changed type

    setUp(() {
      mockOvenModule = MockAdjustmentModule();
      mockFermentationModule = MockAdjustmentModule();

      // Stub supportedTypes for mocks
      when(mockOvenModule.name).thenReturn('OvenCharacteristicsModule');
      when(mockOvenModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockFermentationModule.name).thenReturn('FermentationModule');
      when(mockFermentationModule.supportedTypes).thenReturn([BakingType.bread]);

      sousChefEngine = SousChefEngine(modules: [mockOvenModule, mockFermentationModule]);
    });

    test('should calculate adjustments for supported baking types', () {
      // Stub supportedTypes for mocks
      when(mockOvenModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockFermentationModule.supportedTypes).thenReturn([BakingType.bread]);

      // Stub calculate and getExplanations for mocks
      when(mockOvenModule.calculate({})).thenReturn({'temperature': 5.0});
      when(mockOvenModule.getExplanations({})).thenReturn(['Oven explanation']);
      when(mockFermentationModule.calculate({})).thenReturn({'fermentationTime': 10.0});
      when(mockFermentationModule.getExplanations({})).thenReturn(['Fermentation explanation']);

      // Create a SousChefEngine with mocked modules
      // This requires modifying SousChefEngine to accept a list of AdjustmentModule
      // For now, let's assume the default modules are used and we're testing their interaction.
      // If SousChefEngine cannot be injected, we'll need to mock the modules globally or use a different testing strategy.

      final result = sousChefEngine.calculateAdjustments(
        bakingType: BakingType.bread,
        userInputs: {},
        environmentData: {},
        recipeData: {},
      );

      expect(result.adjustments, isA<Map<String, double>>());
      expect(result.adjustments, containsPair('temperature', 5.0));
      expect(result.adjustments, containsPair('fermentationTime', 10.0));
      expect(result.explanations, contains('Oven explanation'));
      expect(result.explanations, contains('Fermentation explanation'));
      expect(result.warnings, isEmpty);
      expect(result.confidenceScore, isA<double>());
    });

    test('should handle modules throwing exceptions', () {
      when(mockOvenModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockFermentationModule.supportedTypes).thenReturn([BakingType.bread]);

      // Stub one module to throw an exception
      when(mockOvenModule.calculate({})).thenThrow(Exception('Oven calculation error'));
      when(mockFermentationModule.calculate({})).thenReturn({'fermentationTime': 10.0});

      final result = sousChefEngine.calculateAdjustments(
        bakingType: BakingType.bread,
        userInputs: {},
        environmentData: {},
        recipeData: {},
      );

      expect(result.adjustments, containsPair('fermentationTime', 10.0)); // Other module's adjustments should still be present
      expect(result.warnings, isNotEmpty);
      expect(result.warnings, contains('OvenCharacteristicsModule 모듈 계산 중 오류: Exception: Oven calculation error'));
    });

    test('should resolve conflicts and validate adjustments', () {
      // This test requires direct access to _resolveConflicts and _validateAdjustments
      // or a scenario where they are implicitly tested through calculateAdjustments.
      // For now, we'll rely on calculateAdjustments to trigger them.

      // Stub modules to return conflicting/large adjustments
      when(mockOvenModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockFermentationModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockOvenModule.calculate({})).thenReturn({'moisture': 20.0, 'temperature': 60.0}); // Exceeds limits
      when(mockFermentationModule.calculate({})).thenReturn({'moisture': 10.0});

      final result = sousChefEngine.calculateAdjustments(
        bakingType: BakingType.bread,
        userInputs: {},
        environmentData: {},
        recipeData: {},
      );

      expect(result.adjustments['moisture'], lessThanOrEqualTo(15.0)); // Should be clamped
      expect(result.adjustments['temperature'], lessThanOrEqualTo(50.0)); // Should be clamped
      expect(result.warnings, isNotEmpty);
      expect(result.warnings, contains('moisture 보정값이 큽니다 (15.0%). 결과를 주의깊게 확인하세요.'));
      expect(result.warnings, contains('temperature 보정값이 큽니다 (50.0%). 결과를 주의깊게 확인하세요.'));
    });

    test('should calculate confidence score correctly', () {
      when(mockOvenModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockFermentationModule.supportedTypes).thenReturn([BakingType.bread]);
      when(mockOvenModule.calculate({})).thenReturn({'temperature': 5.0});
      when(mockFermentationModule.calculate({})).thenReturn({'fermentationTime': 10.0});

      final result = sousChefEngine.calculateAdjustments(
        bakingType: BakingType.bread,
        userInputs: {},
        environmentData: {},
        recipeData: {},
      );

      // Total adjustment is 5.0 + 10.0 = 15.0
      // Confidence score should be 1.0 - (15.0 / 100.0) = 0.85
      expect(result.confidenceScore, closeTo(0.85, 0.001));
    });
  });
}
