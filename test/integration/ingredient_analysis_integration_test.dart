/// 빵 분석 시스템 통합 인터페이스 단위 테스트
/// IngredientAnalysisHub와 AnalysisCacheManager의 기본 기능 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/types/unified_types.dart';
import '../../lib/core/types/special_dough_types.dart';
import '../../lib/services/syrup_analyzer.dart';
import '../../lib/services/fat_analyzer.dart';
import '../../lib/services/ingredient_analysis_hub.dart';
import '../../lib/services/analysis_cache_manager.dart';

void main() {
  group('IngredientAnalysisHub Tests', () {
    late IngredientAnalysisHub hub;
    late AnalysisCacheManager cacheManager;

    setUp(() {
      hub = IngredientAnalysisHub.instance;
      cacheManager = AnalysisCacheManager.instance;
    });

    test('IngredientAnalysisHub singleton instance', () {
      final hub1 = IngredientAnalysisHub.instance;
      final hub2 = IngredientAnalysisHub.instance;

      expect(hub1, equals(hub2));
    });

    test('AnalysisCacheManager singleton instance', () {
      final cache1 = AnalysisCacheManager.instance;
      final cache2 = AnalysisCacheManager.instance;

      expect(cache1, equals(cache2));
    });

    test('Cache key generation', () {
      final ingredients = [
        UnifiedIngredient(
          id: 'flour',
          name: '밀가루',
          amount: 500,
          unit: 'g',
          properties: {},
        ),
        UnifiedIngredient(
          id: 'water',
          name: '물',
          amount: 350,
          unit: 'ml',
          properties: {},
        ),
      ];

      final cacheKey = AnalysisCacheManager.generateCacheKey(
        ingredients,
        'bread',
        '기본 빵',
      );

      expect(cacheKey, isNotNull);
      expect(cacheKey, isNotEmpty);
      expect(cacheKey, isA<String>());
    });

    test('Cache operations', () {
      // 기본 분석 결과 생성
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {},
        analysisTimestamp: DateTime.now(),
        analysisId: 'test_analysis',
      );

      // 캐시에 저장
      cacheManager.put('test_key', analysisResult);

      // 캐시에서 조회
      final cached = cacheManager.get('test_key');

      expect(cached, isNotNull);
      expect(cached?.analysisId, equals('test_analysis'));

      // 캐시에서 제거
      cacheManager.remove('test_key');
      final removed = cacheManager.get('test_key');

      expect(removed, isNull);
    });

    test('Cache statistics', () {
      final stats = cacheManager.getStatistics();

      expect(stats, isNotNull);
      expect(stats.totalEntries, isA<int>());
      expect(stats.validEntries, isA<int>());
      expect(stats.hitRate, isA<double>());
      expect(stats.hitRate, greaterThanOrEqualTo(0.0));
      expect(stats.hitRate, lessThanOrEqualTo(1.0));
    });

    test('Analysis result effects', () {
      // 기본 분석 결과 생성
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {},
        analysisTimestamp: DateTime.now(),
        analysisId: 'effects_test',
      );

      // 효과 데이터 확인
      expect(analysisResult.mixingEffects, isA<Map<String, dynamic>>());
      expect(analysisResult.doughEffects, isA<Map<String, dynamic>>());
      expect(analysisResult.fermentationEffects, isA<Map<String, dynamic>>());
      expect(analysisResult.bakingEffects, isA<Map<String, dynamic>>());

      // 필수 효과 키들 확인
      expect(analysisResult.mixingEffects.containsKey('glutenFormationImpact'),
          isTrue);
      expect(analysisResult.doughEffects.containsKey('elasticityModifier'),
          isTrue);
      expect(
          analysisResult.fermentationEffects.containsKey('osmoticStressLevel'),
          isTrue);
      expect(analysisResult.bakingEffects.containsKey('temperatureAdjustment'),
          isTrue);
    });

    test('Cache size limit enforcement', () {
      // 캐시 크기 제한 테스트를 위한 여러 항목 추가
      for (int i = 0; i < 150; i++) {
        // 최대 크기(100)보다 많이 추가
        final syrupAnalysis = SyrupAnalysisResult.noSyrup();
        final fatAnalysis = FatAnalysisResult.noFat();
        final specialDoughDetection = SpecialDoughDetectionResult(
          hasSpecialDough: false,
          primaryType: SpecialDoughType.standard,
          detectedTypes: [],
          confidenceScores: {},
          detectionReasons: [],
        );

        final analysisResult = ComprehensiveIngredientAnalysis(
          syrupAnalysis: syrupAnalysis,
          fatAnalysis: fatAnalysis,
          specialDoughDetection: specialDoughDetection,
          integratedEffects: {},
          analysisTimestamp: DateTime.now(),
          analysisId: 'size_test_$i',
        );

        cacheManager.put('size_test_$i', analysisResult);
      }

      // 캐시 크기가 제한을 넘지 않는지 확인
      expect(cacheManager.size, lessThanOrEqualTo(100));
    });

    test('Cache expiration', () async {
      // 짧은 만료 시간으로 캐시 항목 생성
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {},
        analysisTimestamp: DateTime.now(),
        analysisId: 'expiration_test',
      );

      // 1초 후 만료되는 캐시 항목 저장
      cacheManager.put('expiration_test', analysisResult,
          expiration: Duration(seconds: 1));

      // 즉시 조회 (유효해야 함)
      final immediateResult = cacheManager.get('expiration_test');
      expect(immediateResult, isNotNull);

      // 2초 대기 후 조회 (만료되었어야 함)
      await Future.delayed(Duration(seconds: 2));
      final expiredResult = cacheManager.get('expiration_test');
      expect(expiredResult, isNull);
    });

    test('Cache statistics update', () {
      final initialStats = cacheManager.getStatistics();
      final initialRequests = initialStats.totalAccessCount;

      // 캐시 히트 발생
      cacheManager.get('nonexistent_key'); // 미스
      cacheManager.get('nonexistent_key'); // 미스

      final updatedStats = cacheManager.getStatistics();

      // 요청 횟수가 증가했어야 함
      expect(updatedStats.totalAccessCount, greaterThan(initialRequests));
    });
  });

  group('Analysis Result Data Structure Tests', () {
    test('ComprehensiveIngredientAnalysis data structure', () {
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: true,
        primaryType: SpecialDoughType.sourdough,
        detectedTypes: [SpecialDoughType.sourdough],
        confidenceScores: {SpecialDoughType.sourdough: 0.9},
        detectionReasons: ['사워도우 재료 감지'],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {
          'testEffect': 1.5,
          'complexEffect': {'nested': 'value'},
        },
        analysisTimestamp: DateTime.now(),
        analysisId: 'structure_test',
      );

      // 데이터 구조 검증
      expect(analysisResult.syrupAnalysis, equals(syrupAnalysis));
      expect(analysisResult.fatAnalysis, equals(fatAnalysis));
      expect(
          analysisResult.specialDoughDetection, equals(specialDoughDetection));
      expect(analysisResult.analysisId, equals('structure_test'));
      expect(analysisResult.integratedEffects['testEffect'], equals(1.5));
      expect(analysisResult.integratedEffects['complexEffect'],
          isA<Map<String, dynamic>>());
    });

    test('Analysis result toData conversion', () {
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {},
        analysisTimestamp: DateTime.now(),
        analysisId: 'data_test',
      );

      final data = analysisResult.toData();

      expect(data, isA<Map<String, dynamic>>());
      expect(data.containsKey('analysisId'), isTrue);
      expect(data.containsKey('integratedEffects'), isTrue);
      expect(data.containsKey('analysisTimestamp'), isTrue);
      expect(data['analysisId'], equals('data_test'));
    });
  });

  group('Cache Performance Tests', () {
    late AnalysisCacheManager cacheManager;

    setUp(() {
      cacheManager = AnalysisCacheManager.instance;
      cacheManager.clear(); // 테스트 전 캐시 초기화
    });

    test('Cache hit rate calculation', () {
      // 여러 번의 캐시 작업 수행
      for (int i = 0; i < 10; i++) {
        final syrupAnalysis = SyrupAnalysisResult.noSyrup();
        final fatAnalysis = FatAnalysisResult.noFat();
        final specialDoughDetection = SpecialDoughDetectionResult(
          hasSpecialDough: false,
          primaryType: SpecialDoughType.standard,
          detectedTypes: [],
          confidenceScores: {},
          detectionReasons: [],
        );

        final analysisResult = ComprehensiveIngredientAnalysis(
          syrupAnalysis: syrupAnalysis,
          fatAnalysis: fatAnalysis,
          specialDoughDetection: specialDoughDetection,
          integratedEffects: {},
          analysisTimestamp: DateTime.now(),
          analysisId: 'performance_test_$i',
        );

        cacheManager.put('perf_test_$i', analysisResult);
      }

      // 캐시 히트 시도
      for (int i = 0; i < 5; i++) {
        cacheManager.get('perf_test_$i'); // 히트
        cacheManager.get('nonexistent_$i'); // 미스
      }

      final stats = cacheManager.getStatistics();

      // 적중률이 0과 1 사이여야 함
      expect(stats.hitRate, greaterThanOrEqualTo(0.0));
      expect(stats.hitRate, lessThanOrEqualTo(1.0));

      // 총 요청 수 검증 (히트 5 + 미스 5 = 10)
      expect(stats.totalAccessCount, equals(10));
    });

    test('Memory cleanup after dispose', () {
      // 캐시 항목 추가
      final syrupAnalysis = SyrupAnalysisResult.noSyrup();
      final fatAnalysis = FatAnalysisResult.noFat();
      final specialDoughDetection = SpecialDoughDetectionResult(
        hasSpecialDough: false,
        primaryType: SpecialDoughType.standard,
        detectedTypes: [],
        confidenceScores: {},
        detectionReasons: [],
      );

      final analysisResult = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        specialDoughDetection: specialDoughDetection,
        integratedEffects: {},
        analysisTimestamp: DateTime.now(),
        analysisId: 'cleanup_test',
      );

      cacheManager.put('cleanup_test', analysisResult);

      // dispose 전 확인
      expect(cacheManager.size, greaterThan(0));

      // dispose 호출 (실제 dispose는 외부에서 호출되어야 함)
      // 여기서는 캐시 초기화로 대체
      cacheManager.clear();

      // dispose 후 확인
      expect(cacheManager.size, equals(0));
    });
  });
}
