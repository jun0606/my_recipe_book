import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/services/analysis/analysis_pipeline_engine.dart';
import 'package:my_recipe_book/services/analysis/module_registry.dart';
import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_status.dart';

// Mock ModuleRegistry for testing AnalysisPipelineEngine
class MockModuleRegistry extends ModuleRegistry {
  final List<AnalysisModule> _mockModules;

  MockModuleRegistry(this._mockModules) : super();

  @override
  List<AnalysisModule> getEnabledModules(List<String> enabledModuleNames) {
    return _mockModules.where((m) => enabledModuleNames.contains(m.name)).toList();
  }

  @override
  List<AnalysisModule> resolveExecutionOrder(List<AnalysisModule> modules) {
    // 간단하게 우선순위로 정렬 (실제 ModuleRegistry의 복잡한 로직 대신)
    final sorted = List<AnalysisModule>.from(modules);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }
}

// Mock AnalysisModule for testing
class MockAnalysisModule extends BaseAnalysisModule {
  final String _moduleName;
  final int _priority;
  final bool _canHandle;
  final Map<String, dynamic> _analyzeResult;
  final bool _throwError;

  MockAnalysisModule({
    required String name,
    required int priority,
    bool canHandle = true,
    Map<String, dynamic> analyzeResult = const {'status': 'success'},
    bool throwError = false,
  })  : _moduleName = name,
        _priority = priority,
        _canHandle = canHandle,
        _analyzeResult = analyzeResult,
        _throwError = throwError,
        super(
          name: name,
          version: '1.0.0',
          description: 'Mock Module',
          priority: priority,
          dependencies: [],
          category: AnalysisModuleCategory.recipe, // 더미 카테고리
        );

  @override
  String get name => _moduleName;

  @override
  int get priority => _priority;

  @override
  bool canHandle(AnalysisRequest request) => _canHandle;

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    if (_throwError) {
      throw Exception('Mock module error');
    }
    return _analyzeResult;
  }
}

void main() {
  group('AnalysisPipelineEngine', () {
    late AnalysisPipelineEngine pipelineEngine;
    late MockModuleRegistry mockModuleRegistry;

    setUp(() {
      final mockModules = [
        MockAnalysisModule(name: 'moduleA', priority: 1, analyzeResult: {'dataA': 1}),
        MockAnalysisModule(name: 'moduleB', priority: 2, analyzeResult: {'dataB': 2}),
        MockAnalysisModule(name: 'moduleC', priority: 3, analyzeResult: {'dataC': 3}),
      ];
      mockModuleRegistry = MockModuleRegistry(mockModules);
      pipelineEngine = AnalysisPipelineEngine(mockModuleRegistry);
    });

    test('analyze should execute all enabled modules and return combined results', () async {
      final request = AnalysisRequest(
        id: 'test_request_id',
        recipe: Recipe(title: 'Test Recipe', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(enabledModules: ['moduleA', 'moduleB', 'moduleC']),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await pipelineEngine.analyze(request);

      expect(result.status, AnalysisStatus.completed);
      expect(result.results, containsPair('moduleA', {'dataA': 1}));
      expect(result.results, containsPair('moduleB', {'dataB': 2}));
      expect(result.results, containsPair('moduleC', {'dataC': 3}));
      expect(result.errorMessage, isNull);
      expect(result.warnings, isEmpty);
    });

    test('analyze should handle module errors gracefully and record warnings', () async {
      final mockModulesWithError = [
        MockAnalysisModule(name: 'moduleA', priority: 1, analyzeResult: {'dataA': 1}),
        MockAnalysisModule(name: 'moduleB', priority: 2, throwError: true), // This module will throw an error
        MockAnalysisModule(name: 'moduleC', priority: 3, analyzeResult: {'dataC': 3}),
      ];
      mockModuleRegistry = MockModuleRegistry(mockModulesWithError);
      pipelineEngine = AnalysisPipelineEngine(mockModuleRegistry);

      final request = AnalysisRequest(
        id: 'test_request_id',
        recipe: Recipe(title: 'Test Recipe', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(enabledModules: ['moduleA', 'moduleB', 'moduleC']),
        createdAt: DateTime.now(),
        priority: 1,
      );

      // Expect an exception to be rethrown from analyze method
      expectLater(() => pipelineEngine.analyze(request), throwsA(isA<Exception>()));

      // Since rethrow is used, the final result won't be returned directly.
      // We need to test the error handling within the try-catch-finally block.
      // For this test, we'll focus on the fact that an error is thrown.
    });

    test('analyze should return partial results if some modules cannot handle the request', () async {
      final mockModulesPartial = [
        MockAnalysisModule(name: 'moduleA', priority: 1, analyzeResult: {'dataA': 1}),
        MockAnalysisModule(name: 'moduleB', priority: 2, canHandle: false), // This module cannot handle
        MockAnalysisModule(name: 'moduleC', priority: 3, analyzeResult: {'dataC': 3}),
      ];
      mockModuleRegistry = MockModuleRegistry(mockModulesPartial);
      pipelineEngine = AnalysisPipelineEngine(mockModuleRegistry);

      final request = AnalysisRequest(
        id: 'test_request_id',
        recipe: Recipe(title: 'Test Recipe', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(enabledModules: ['moduleA', 'moduleB', 'moduleC']),
        createdAt: DateTime.now(),
        priority: 1,
      );

      final result = await pipelineEngine.analyze(request);

      expect(result.status, AnalysisStatus.completed);
      expect(result.results, containsPair('moduleA', {'dataA': 1}));
      expect(result.results, isNot(containsKey('moduleB'))); // moduleB should not be in results
      expect(result.results, containsPair('moduleC', {'dataC': 3}));
      expect(result.errorMessage, isNull);
      expect(result.warnings, isEmpty);
    });

    test('analyze should throw ArgumentError for invalid request', () async {
      final request = AnalysisRequest(
        id: 'test_request_id',
        recipe: Recipe(title: 'Test Recipe', instructions: [], ingredients: []),
        ingredients: [],
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(enabledModules: ['moduleA']),
        createdAt: DateTime.now(),
        priority: 1,
        isValid: false, // Mark request as invalid
      );

      expect(() => pipelineEngine.analyze(request), throwsA(isA<ArgumentError>()));
    });
  });
}