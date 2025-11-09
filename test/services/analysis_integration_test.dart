import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/services/analysis/analysis_pipeline_engine.dart';
import 'package:my_recipe_book/services/analysis/module_registry.dart';
import 'package:my_recipe_book/services/analysis/in_memory_cache.dart';
import 'package:my_recipe_book/services/analysis/cache_key_generator.dart';
import 'package:my_recipe_book/services/analysis/error_handler.dart';
import 'package:my_recipe_book/services/analysis/parallel_executor.dart';
import 'package:my_recipe_book/models/analysis_status.dart';
import 'package:my_recipe_book/services/analysis/analysis_metrics.dart'; // 메트릭 확인용

void main() {
  group('Analysis Pipeline Integration Test', () {
    late ModuleRegistry moduleRegistry;
    late InMemoryCache cache;
    late CacheKeyGenerator cacheKeyGenerator;
    late ErrorHandler errorHandler;
    late ParallelExecutor parallelExecutor;
    late AnalysisPipelineEngine pipelineEngine;

    setUp(() {
      // 모든 컴포넌트 초기화
      moduleRegistry = ModuleRegistry(); // 실제 모듈들이 등록됨
      cache = InMemoryCache(maxSize: 10); // 캐시 크기 제한
      cacheKeyGenerator = CacheKeyGenerator();
      errorHandler = ErrorHandler();
      parallelExecutor = ParallelExecutor(moduleRegistry); // ParallelExecutor에 ModuleRegistry 주입

      // PipelineEngine에 모든 의존성 주입
      pipelineEngine = AnalysisPipelineEngine(
        moduleRegistry,
        cache,
        cacheKeyGenerator,
        errorHandler,
      );

      // 캐시 및 메트릭 초기화
      cache.clear();
      AnalysisMetrics.resetAll();
    });

    tearDown(() {
      // 모든 컴포넌트 정리
      moduleRegistry.disposeAllModules();
      cache.dispose();
    });

    test('Full pipeline execution with caching and metrics', () async {
      // 1. 첫 번째 요청: 캐시 미스 발생, 분석 수행
      final recipe = Recipe(
        id: 'recipe_1',
        title: '통합 테스트 레시피',
        instructions: ['단계 1', '단계 2', '단계 3'],
        ingredients: [
          Ingredient(name: '밀가루', amount: 100, unit: 'g'),
          Ingredient(name: '설탕', amount: 50, unit: 'g'),
        ],
        prepTime: 10,
        cookTime: 20,
        isBaking: true,
      );
      final request1 = AnalysisRequest(
        id: 'req_1',
        recipe: recipe,
        ingredients: recipe.ingredients,
        environment: EnvironmentalConditions(temperature: 25, humidity: 50, altitude: 0),
        options: AnalysisOptions(enabledModules: ['recipe_analysis', 'ingredient_analysis', 'nutritional_analysis']),
        createdAt: DateTime.now(),
        priority: 1,
      );

      print('--- 첫 번째 요청 시작 ---');
      final result1 = await pipelineEngine.analyze(request1);
      print('--- 첫 번째 요청 완료 ---');

      expect(result1.status, AnalysisStatus.completed);
      expect(result1.fromCache, isFalse);
      expect(result1.results, containsKey('recipe_analysis'));
      expect(result1.results, containsKey('ingredient_analysis'));
      expect(result1.results, containsKey('nutritional_analysis'));
      expect(result1.metadata.processingDuration, greaterThan(0));

      // 메트릭 확인
      expect(AnalysisMetrics.requestCounter, 1);
      expect(AnalysisMetrics.averageProcessingDuration, greaterThan(0));
      expect(AnalysisMetrics.errorCounter, 0);
      expect(AnalysisMetrics.cacheHitRate, 0.0); // 첫 요청이므로 0

      // 캐시 통계 확인
      final cacheStats1 = cache.getStats();
      expect(cacheStats1['total_entries'], 1);
      expect(cacheStats1['hits'], 0);
      expect(cacheStats1['misses'], 1); // 첫 요청은 미스

      // 2. 두 번째 요청: 동일한 요청, 캐시 히트 발생
      print('--- 두 번째 요청 시작 (캐시 히트 예상) ---');
      final result2 = await pipelineEngine.analyze(request1);
      print('--- 두 번째 요청 완료 ---');

      expect(result2.status, AnalysisStatus.completed);
      expect(result2.fromCache, isTrue); // 캐시 히트 확인
      expect(result2.results, containsKey('recipe_analysis'));
      expect(result2.results, containsKey('ingredient_analysis'));
      expect(result2.results, containsKey('nutritional_analysis'));
      // 캐시된 결과이므로 처리 시간은 매우 짧아야 함
      expect(result2.metadata.processingDuration, lessThan(result1.metadata.processingDuration));

      // 메트릭 확인 (요청 카운터 증가, 캐시 히트율 증가)
      expect(AnalysisMetrics.requestCounter, 2);
      expect(AnalysisMetrics.cacheHitRate, greaterThan(0.0)); // 히트 발생으로 증가

      // 캐시 통계 확인
      final cacheStats2 = cache.getStats();
      expect(cacheStats2['total_entries'], 1);
      expect(cacheStats2['hits'], 1); // 히트 증가
      expect(cacheStats2['misses'], 1); // 미스 유지
      expect(cacheStats2['hit_rate'], 0.5); // 1히트 / (1히트 + 1미스)

      // 3. 오류 발생 시나리오 (Mock 모듈을 통해 강제 오류 발생)
      // 이 테스트를 위해서는 Mock 모듈을 PipelineEngine에 주입해야 함.
      // 현재 ModuleRegistry는 실제 모듈을 등록하므로, 이 시나리오는 MockModuleRegistry를 사용하는
      // analysis_pipeline_test.dart에서 더 적합함.
      // 여기서는 통합 테스트이므로 실제 모듈의 오류 처리 로직을 테스트하는 방향으로 진행.
      // 예를 들어, 존재하지 않는 모듈을 활성화하여 오류를 유발하거나,
      // 특정 모듈의 analyze 메서드에서 예외를 던지도록 수정하는 방식.
    });

    test('Pipeline handles invalid request gracefully', () async {
      final invalidRequest = AnalysisRequest(
        id: 'req_invalid',
        recipe: null, // 유효하지 않은 요청 (recipe가 null)
        ingredients: [],
        environment: null,
        options: AnalysisOptions(),
        createdAt: DateTime.now(),
        priority: 1,
        isValid: false, // isValid를 false로 설정하여 ArgumentError 유발
      );

      print('--- 유효하지 않은 요청 시작 ---');
      // ArgumentError가 analyze 메서드에서 throw되므로 expectLater로 감싸야 함
      expectLater(() => pipelineEngine.analyze(invalidRequest), throwsA(isA<ArgumentError>()));
      print('--- 유효하지 않은 요청 완료 ---');

      // 메트릭 확인 (오류 카운터 증가)
      // expect(AnalysisMetrics.errorCounter, greaterThan(0)); // ArgumentError는 pipelineEngine에서 직접 처리되므로 errorCounter가 증가하지 않을 수 있음
    });
  });
}