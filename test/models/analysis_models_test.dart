import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'package:my_recipe_book/models/analysis_metadata.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
// Mock classes for dependencies
class MockRecipe extends Recipe {
  MockRecipe({
    int? id,
    required String title,
    String category = 'Test Category',
    List<String> instructions = const ['Step 1'],
    List<Ingredient> ingredients = const [],
  }) : super(
          id: id,
          title: title,
          category: category,
          instructions: instructions,
          ingredients: ingredients,
        );
}

class MockIngredient extends Ingredient {
  MockIngredient({String name = 'Flour', double amount = 100.0, String unit = 'g'})
      : super(name: name, amount: amount, unit: unit);
}

class MockEnvironmentalConditions extends EnvironmentalConditions {
  MockEnvironmentalConditions({double temperature = 25.0, double humidity = 60.0})
      : super(temperature: temperature, humidity: humidity);
}

void main() {
  group('AnalysisRequest', () {
    late MockRecipe mockRecipe;
    late List<MockIngredient> mockIngredients;
    late MockEnvironmentalConditions mockEnvironment;
    late AnalysisOptions defaultOptions;

    setUp(() {
      mockRecipe = MockRecipe(title: 'Test Cake');
      mockIngredients = [
        MockIngredient(name: 'Flour', amount: 200, unit: 'g'),
        MockIngredient(name: 'Sugar', amount: 100, unit: 'g'),
      ];
      mockEnvironment = MockEnvironmentalConditions(temperature: 22, humidity: 50);
      defaultOptions = AnalysisOptions.defaultOptions();
    });

    test('AnalysisRequest.create should create a valid request', () {
      final request = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );

      expect(request, isNotNull);
      expect(request.id, startsWith('analysis_'));
      expect(request.recipe.title, 'Test Cake');
      expect(request.ingredients.length, 2);
      expect(request.environment.temperature, 22);
      expect(request.options, defaultOptions);
      expect(request.createdAt, isA<DateTime>());
      expect(request.priority, 2);
      expect(request.isValid(), isTrue);
    });

    test('AnalysisRequest.copyWith should create a new instance with updated values', () {
      final originalRequest = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );

      final newRecipe = MockRecipe(title: 'New Test Bread');
      final updatedRequest = originalRequest.copyWith(
        recipe: newRecipe,
        priority: 1,
      );

      expect(updatedRequest.recipe.title, 'New Test Bread');
      expect(updatedRequest.priority, 1);
      expect(updatedRequest.id, originalRequest.id); // ID should remain the same
      expect(updatedRequest.ingredients, originalRequest.ingredients);
    });

    test('AnalysisRequest toJson/fromJson should work correctly', () {
      final request = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
        userId: 'testUser',
        metadata: {'source': 'manual'},
      );

      final json = request.toJson();
      final decodedRequest = AnalysisRequest.fromJson(json);

      expect(decodedRequest.id, request.id);
      expect(decodedRequest.recipe.title, request.recipe.title);
      expect(decodedRequest.ingredients.length, request.ingredients.length);
      expect(decodedRequest.environment.temperature, request.environment.temperature);
      expect(decodedRequest.options.analysisDepth, request.options.analysisDepth);
      expect(decodedRequest.createdAt.toIso8601String(), request.createdAt.toIso8601String());
      expect(decodedRequest.priority, request.priority);
      expect(decodedRequest.userId, request.userId);
      expect(decodedRequest.metadata['source'], 'manual');
      expect(decodedRequest.isValid(), isTrue);
    });

    test('AnalysisRequest.isValid should return false for invalid data', () {
      final invalidRecipe = MockRecipe(title: ''); // Invalid recipe title
      final request1 = AnalysisRequest.create(
        recipe: invalidRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );
      expect(request1.isValid(), isFalse);

      final invalidIngredients = [MockIngredient(name: '', amount: 0)]; // Invalid ingredient
      final request2 = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: invalidIngredients,
        environment: mockEnvironment,
      );
      expect(request2.isValid(), isFalse);

      final invalidPriority = AnalysisRequest(
        id: 'test',
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
        options: defaultOptions,
        createdAt: DateTime.now(),
        priority: 0, // Invalid priority
      );
      expect(invalidPriority.isValid(), isFalse);
    });

    test('AnalysisRequest.generateCacheKey should produce consistent keys', () {
      final request1 = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );
      final request2 = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );

      expect(request1.generateCacheKey(), request2.generateCacheKey());

      final differentRecipe = MockRecipe(title: 'Different Cake');
      final request3 = AnalysisRequest.create(
        recipe: differentRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );
      expect(request1.generateCacheKey(), isNot(request3.generateCacheKey()));
    });

    test('AnalysisRequest.estimateProcessingTime and estimateMemoryUsage should return positive values', () {
      final request = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );
      expect(request.estimateProcessingTime(), greaterThan(0));
      expect(request.estimateMemoryUsage(), greaterThan(0));
    });

    test('AnalysisRequest.getSummary should return a non-empty string', () {
      final request = AnalysisRequest.create(
        recipe: mockRecipe,
        ingredients: mockIngredients,
        environment: mockEnvironment,
      );
      expect(request.getSummary(), isNotEmpty);
    });

    test('AnalysisRequestBuilder should build a valid request', () {
      final builder = AnalysisRequestBuilder()
        .recipe(mockRecipe)
        .ingredients(mockIngredients)
        .environment(mockEnvironment)
        .priority(1)
        .userId('builderUser');

      final request = builder.build();

      expect(request, isNotNull);
      expect(request.recipe.title, 'Test Cake');
      expect(request.priority, 1);
      expect(request.userId, 'builderUser');
      expect(request.isValid(), isTrue);
    });

    test('AnalysisRequestBuilder.canBuild should reflect buildability', () {
      final builder = AnalysisRequestBuilder();
      expect(builder.canBuild(), isFalse);

      builder.recipe(mockRecipe).ingredients(mockIngredients).environment(mockEnvironment);
      expect(builder.canBuild(), isTrue);
    });

    test('AnalysisRequestBuilder.reset should clear the builder state', () {
      final builder = AnalysisRequestBuilder()
        .recipe(mockRecipe)
        .ingredients(mockIngredients)
        .environment(mockEnvironment);
      
      expect(builder.canBuild(), isTrue);
      builder.reset();
      expect(builder.canBuild(), isFalse);
    });
  });

  group('AnalysisOptions', () {
    test('AnalysisOptions.defaultOptions should return valid default options', () {
      final options = AnalysisOptions.defaultOptions();
      expect(options.enabledModules, isNotEmpty);
      expect(options.analysisDepth, 2);
      expect(options.useCache, isTrue);
      expect(options.isValid(), isTrue);
    });

    test('AnalysisOptions.quickAnalysis should return valid quick options', () {
      final options = AnalysisOptions.quickAnalysis();
      expect(options.analysisDepth, 1);
      expect(options.maxProcessingTime, 10);
      expect(options.isValid(), isTrue);
    });

    test('AnalysisOptions.detailedAnalysis should return valid detailed options', () {
      final options = AnalysisOptions.detailedAnalysis();
      expect(options.analysisDepth, 3);
      expect(options.maxProcessingTime, 60);
      expect(options.isValid(), isTrue);
    });

    test('AnalysisOptions.expertAnalysis should return valid expert options', () {
      final options = AnalysisOptions.expertAnalysis();
      expect(options.analysisDepth, 3);
      expect(options.maxProcessingTime, 120);
      expect(options.debugMode, isTrue);
      expect(options.isValid(), isTrue);
    });

    test('AnalysisOptions.bakingFocused should return valid baking options', () {
      final options = AnalysisOptions.bakingFocused();
      expect(options.analysisDepth, 3);
      expect(options.maxProcessingTime, 90);
      expect(options.isValid(), isTrue);
    });

    test('AnalysisOptions.copyWith should create a new instance with updated values', () {
      final originalOptions = AnalysisOptions.defaultOptions();
      final updatedOptions = originalOptions.copyWith(
        analysisDepth: 3,
        useCache: false,
      );

      expect(updatedOptions.analysisDepth, 3);
      expect(updatedOptions.useCache, isFalse);
      expect(updatedOptions.enabledModules, originalOptions.enabledModules);
    });

    test('AnalysisOptions toJson/fromJson should work correctly', () {
      final options = AnalysisOptions.detailedAnalysis().copyWith(
        customParameters: {'key': 'value'},
        language: 'en',
      );
      final json = options.toJson();
      final decodedOptions = AnalysisOptions.fromJson(json);

      expect(decodedOptions.analysisDepth, options.analysisDepth);
      expect(decodedOptions.language, 'en');
      expect(decodedOptions.customParameters['key'], 'value');
      expect(decodedOptions.isValid(), isTrue);
    });

    test('AnalysisOptions.isValid should return false for invalid options', () {
      final invalidDepth = AnalysisOptions.defaultOptions().copyWith(analysisDepth: 0);
      expect(invalidDepth.isValid(), isFalse);

      final invalidPrecision = AnalysisOptions.defaultOptions().copyWith(precisionLevel: 0);
      expect(invalidPrecision.isValid(), isFalse);

      final invalidMaxTime = AnalysisOptions.defaultOptions().copyWith(maxProcessingTime: 0);
      expect(invalidMaxTime.isValid(), isFalse);

      final invalidFormat = AnalysisOptions.defaultOptions().copyWith(outputFormat: 'xyz');
      expect(invalidFormat.isValid(), isFalse);

      final invalidLanguage = AnalysisOptions.defaultOptions().copyWith(language: 'fr');
      expect(invalidLanguage.isValid(), isFalse);

      final emptyModules = AnalysisOptions.defaultOptions().copyWith(enabledModules: []);
      expect(emptyModules.isValid(), isFalse);
    });

    test('AnalysisOptions module management methods should work', () {
      var options = AnalysisOptions.defaultOptions();
      expect(options.isModuleEnabled('new_module'), isFalse);

      options = options.enableModule('new_module');
      expect(options.isModuleEnabled('new_module'), isTrue);

      options = options.disableModule('new_module');
      expect(options.isModuleEnabled('new_module'), isFalse);

      options = options.enableModules(['mod1', 'mod2']);
      expect(options.isModuleEnabled('mod1'), isTrue);
      expect(options.isModuleEnabled('mod2'), isTrue);

      options = options.disableModules(['mod1']);
      expect(options.isModuleEnabled('mod1'), isFalse);
      expect(options.isModuleEnabled('mod2'), isTrue);
    });

    test('AnalysisOptions custom parameters methods should work', () {
      var options = AnalysisOptions.defaultOptions();
      expect(options.getCustomParameter<String>('test_key'), isNull);

      options = options.addCustomParameter('test_key', 'test_value');
      expect(options.getCustomParameter<String>('test_key'), 'test_value');

      options = options.removeCustomParameter('test_key');
      expect(options.getCustomParameter<String>('test_key'), isNull);
    });

    test('AnalysisOptions estimateProcessingTime, estimateMemoryUsage, calculateComplexityScore should return positive values', () {
      final options = AnalysisOptions.defaultOptions();
      expect(options.estimateProcessingTime(), greaterThan(0));
      expect(options.estimateMemoryUsage(), greaterThan(0));
      expect(options.calculateComplexityScore(), greaterThan(0));
    });

    test('AnalysisOptions getPerformanceGrade and getSummary should return non-empty strings', () {
      final options = AnalysisOptions.defaultOptions();
      expect(options.getPerformanceGrade(), isNotEmpty);
      expect(options.getSummary(), isNotEmpty);
    });

    test('AnalysisOptionsPresets should provide correct presets', () {
      expect(AnalysisOptionsPresets.getPresetNames(), isNotEmpty);
      expect(AnalysisOptionsPresets.hasPreset('quick'), isTrue);
      expect(AnalysisOptionsPresets.getPreset('quick'), isNotNull);
      expect(AnalysisOptionsPresets.getPreset('quick')!.analysisDepth, 1);
      expect(AnalysisOptionsPresets.getPresetDescription('quick'), isNotEmpty);
      expect(AnalysisOptionsPresets.getAllPresets(), isNotEmpty);
    });
  });

  group('AnalysisResult', () {
    late AnalysisMetadata mockMetadata;
    late List<Recommendation> mockRecommendations;

    setUp(() {
      mockMetadata = AnalysisMetadata.empty('test_req_id');
      mockRecommendations = [
        Recommendation.simple(title: 'Rec 1', description: 'Desc 1', category: 'Cat 1', priority: RecommendationPriority.high),
        Recommendation.simple(title: 'Rec 2', description: 'Desc 2', category: 'Cat 2', priority: RecommendationPriority.medium),
      ];
    });

    test('AnalysisResult.success should create a completed result', () {
      final result = AnalysisResult.success(
        requestId: 'req1',
        results: {'moduleA': 'dataA'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 90.0,
        successfulModules: ['moduleA'],
      );

      expect(result.status, AnalysisStatus.completed);
      expect(result.overallScore, 90.0);
      expect(result.isSuccess, isTrue);
      expect(result.successfulModules, ['moduleA']);
      expect(result.failedModules, isEmpty);
    });

    test('AnalysisResult.failure should create a failed result', () {
      final result = AnalysisResult.failure(
        requestId: 'req2',
        errorMessage: 'Something went wrong',
        metadata: mockMetadata,
        failedModules: ['moduleB'],
      );

      expect(result.status, AnalysisStatus.failed);
      expect(result.overallScore, 0.0);
      expect(result.isFailure, isTrue);
      expect(result.errorMessage, 'Something went wrong');
      expect(result.failedModules, ['moduleB']);
      expect(result.successfulModules, isEmpty);
    });

    test('AnalysisResult.partialSuccess should create a partially completed result', () {
      final result = AnalysisResult.partialSuccess(
        requestId: 'req3',
        results: {'moduleC': 'dataC'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 70.0,
        warnings: ['Some warning'],
        successfulModules: ['moduleC'],
        failedModules: ['moduleD'],
      );

      expect(result.status, AnalysisStatus.partiallyCompleted);
      expect(result.overallScore, 70.0);
      expect(result.isPartialSuccess, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.successfulModules, ['moduleC']);
      expect(result.failedModules, ['moduleD']);
    });

    test('AnalysisResult.partialFailure should create a partially completed result with error', () {
      final result = AnalysisResult.partialFailure(
        requestId: 'req4',
        failedModule: 'moduleE',
        error: 'Module E failed',
      );

      expect(result.status, AnalysisStatus.partiallyCompleted);
      expect(result.errorMessage, contains('Module E failed'));
      expect(result.failedModules, ['moduleE']);
      expect(result.warnings, isNotEmpty);
    });

    test('AnalysisResult toJson/fromJson should work correctly', () {
      final result = AnalysisResult.success(
        requestId: 'req5',
        results: {'modX': 'dataX'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 85.0,
        fromCache: true,
        successfulModules: ['modX'],
      );

      final json = result.toJson();
      final decodedResult = AnalysisResult.fromJson(json);

      expect(decodedResult.requestId, result.requestId);
      expect(decodedResult.status, result.status);
      expect(decodedResult.overallScore, result.overallScore);
      expect(decodedResult.fromCache, isTrue);
      expect(decodedResult.successfulModules, ['modX']);
      expect(decodedResult.recommendations.length, 2);
    });

    test('AnalysisResult utility getters should work', () {
      final result = AnalysisResult.success(
        requestId: 'req6',
        results: {'modA': 'dataA', 'modB': 'dataB'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 95.0,
        warnings: ['Warning 1'],
        successfulModules: ['modA', 'modB'],
      );

      expect(result.getModuleResult<String>('modA'), 'dataA');
      expect(result.hasModuleResult('modB'), isTrue);
      expect(result.isCompleteSuccess, isFalse); // Has warning
      expect(result.successRate, 1.0);
      expect(result.getHighPriorityRecommendations().length, 1);
      expect(result.getRecommendationsByCategory('Cat 2').length, 1);
      expect(result.getRecommendationsByConfidence(0.7).length, 2);
      expect(result.getEasyRecommendations().length, 2); // Default difficulty is 3
    });

    test('AnalysisResultSummary should be correctly generated', () {
      final result = AnalysisResult.success(
        requestId: 'req7',
        results: {'modA': 'dataA'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 88.0,
        successfulModules: ['modA'],
      );
      final summary = result.getSummary();

      expect(summary.requestId, 'req7');
      expect(summary.overallScore, 88.0);
      expect(summary.moduleCount, 1);
      expect(summary.performanceGrade, isNotEmpty);
      expect(summary.qualityGrade, isNotEmpty);
    });

    test('AnalysisResult generateDetailedReport should return a non-empty string', () {
      final result = AnalysisResult.success(
        requestId: 'req8',
        results: {'modA': 'dataA'},
        recommendations: mockRecommendations,
        metadata: mockMetadata,
        overallScore: 90.0,
        successfulModules: ['modA'],
      );
      expect(result.generateDetailedReport(), isNotEmpty);
    });
  });

  group('AnalysisMetadata', () {
    late Map<String, int> mockModuleExecutionTimes;
    late List<LogEntry> mockLogs;
    late CacheStatistics mockCacheStats;
    late MemoryUsageInfo mockMemoryUsage;
    late SystemInfo mockSystemInfo;

    setUp(() {
      mockModuleExecutionTimes = {
        'moduleA': 100,
        'moduleB': 200,
        'moduleC': 50,
      };
      mockLogs = [
        LogEntry.info('Info log'),
        LogEntry.warning('Warning log'),
        LogEntry.error('Error log'),
      ];
      mockCacheStats = CacheStatistics(hits: 10, misses: 2, bytesFromCache: 1000, bytesToCache: 500, cacheOperationTime: 10);
      mockMemoryUsage = MemoryUsageInfo(initialUsage: 1000, peakUsage: 2000, finalUsage: 1500, memoryDelta: 500);
      mockSystemInfo = SystemInfo.current();
    });

    test('AnalysisMetadata.empty should create an empty metadata instance', () {
      final metadata = AnalysisMetadata.empty('empty_req');
      expect(metadata.requestId, 'empty_req');
      expect(metadata.processingTime, 0);
      expect(metadata.moduleExecutionTimes, isEmpty);
      expect(metadata.logs, isEmpty);
      expect(metadata.performance.overallScore, 0.0);
    });

    test('AnalysisMetadata.start should create a starting metadata instance', () {
      final metadata = AnalysisMetadata.start('start_req');
      expect(metadata.requestId, 'start_req');
      expect(metadata.processingTime, 0);
      expect(metadata.startTime, isA<DateTime>());
      expect(metadata.endTime, metadata.startTime); // Initial endTime is startTime
    });

    test('AnalysisMetadata.complete should update metadata correctly', () async {
      final startMetadata = AnalysisMetadata.start('complete_req');
      await Future.delayed(const Duration(milliseconds: 10)); // Ensure processingTime > 0
      final completedMetadata = startMetadata.complete(
        moduleExecutionTimes: mockModuleExecutionTimes,
        logs: mockLogs,
        cacheStats: mockCacheStats,
        debugInfo: {'key': 'value'},
      );

      expect(completedMetadata.processingTime, greaterThan(0));
      expect(completedMetadata.endTime, isA<DateTime>());
      expect(completedMetadata.moduleExecutionTimes, mockModuleExecutionTimes);
      expect(completedMetadata.logs, mockLogs);
      expect(completedMetadata.cacheStats, mockCacheStats);
      expect(completedMetadata.debugInfo['key'], 'value');
      expect(completedMetadata.performance.overallScore, greaterThan(0));
    });

    test('AnalysisMetadata toJson/fromJson should work correctly', () {
      final metadata = AnalysisMetadata(
        requestId: 'json_req',
        startTime: DateTime.now().subtract(const Duration(seconds: 10)),
        endTime: DateTime.now(),
        processingTime: 10000,
        moduleExecutionTimes: mockModuleExecutionTimes,
        memoryUsage: mockMemoryUsage,
        cacheStats: mockCacheStats,
        logs: mockLogs,
        performance: PerformanceMetrics.calculate(
          processingTime: 10000,
          moduleExecutionTimes: mockModuleExecutionTimes,
          memoryUsage: mockMemoryUsage,
        ),
        systemInfo: mockSystemInfo,
      );

      final json = metadata.toJson();
      final decodedMetadata = AnalysisMetadata.fromJson(json);

      expect(decodedMetadata.requestId, metadata.requestId);
      expect(decodedMetadata.processingTime, metadata.processingTime);
      expect(decodedMetadata.moduleExecutionTimes.length, metadata.moduleExecutionTimes.length);
      expect(decodedMetadata.memoryUsage.peakUsage, metadata.memoryUsage.peakUsage);
      expect(decodedMetadata.cacheStats.hits, metadata.cacheStats.hits);
      expect(decodedMetadata.logs.length, metadata.logs.length);
      expect(decodedMetadata.performance.overallScore, closeTo(metadata.performance.overallScore, 0.01));
      expect(decodedMetadata.systemInfo.operatingSystem, metadata.systemInfo.operatingSystem);
    });

    test('AnalysisMetadata getters should return correct values', () {
      final metadata = AnalysisMetadata(
        requestId: 'getters_req',
        startTime: DateTime.now().subtract(const Duration(seconds: 10)),
        endTime: DateTime.now(),
        processingTime: 10000,
        moduleExecutionTimes: mockModuleExecutionTimes,
        memoryUsage: mockMemoryUsage,
        cacheStats: mockCacheStats,
        logs: mockLogs,
        performance: PerformanceMetrics.calculate(
          processingTime: 10000,
          moduleExecutionTimes: mockModuleExecutionTimes,
          memoryUsage: mockMemoryUsage,
        ),
        systemInfo: mockSystemInfo,
      );

      expect(metadata.slowestModule, 'moduleB');
      expect(metadata.fastestModule, 'moduleC');
      expect(metadata.averageModuleExecutionTime, closeTo(116.67, 0.01));
      expect(metadata.errorCount, 1);
      expect(metadata.warningCount, 1);
      expect(metadata.performanceGrade, isNotEmpty);
      expect(metadata.memoryEfficiencyGrade, isNotEmpty);
    });

    test('MemoryUsageInfo toJson/fromJson should work correctly', () {
      final info = MemoryUsageInfo.current();
      final json = info.toJson();
      final decodedInfo = MemoryUsageInfo.fromJson(json);
      expect(decodedInfo.peakUsage, info.peakUsage);
    });

    test('CacheStatistics toJson/fromJson should work correctly', () {
      final stats = CacheStatistics.empty();
      final json = stats.toJson();
      final decodedStats = CacheStatistics.fromJson(json);
      expect(decodedStats.hits, stats.hits);
    });

    test('LogEntry toJson/fromJson should work correctly', () {
      final entry = LogEntry.error('Test error', moduleName: 'TestMod');
      final json = entry.toJson();
      final decodedEntry = LogEntry.fromJson(json);
      expect(decodedEntry.message, entry.message);
      expect(decodedEntry.level, entry.level);
      expect(decodedEntry.moduleName, entry.moduleName);
    });

    test('PerformanceMetrics toJson/fromJson should work correctly', () {
      final metrics = PerformanceMetrics.empty();
      final json = metrics.toJson();
      final decodedMetrics = PerformanceMetrics.fromJson(json);
      expect(decodedMetrics.overallScore, metrics.overallScore);
    });

    test('SystemInfo toJson/fromJson should work correctly', () {
      final info = SystemInfo.current();
      final json = info.toJson();
      final decodedInfo = SystemInfo.fromJson(json);
      expect(decodedInfo.operatingSystem, info.operatingSystem);
    });
  });
}
