// 분석 시스템 통합 테스트 - Week 4: 테스트 및 최적화
// 새로운 타입 시스템과 컨트롤러 패턴의 통합 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/types/comprehensive_types.dart';
import '../../lib/core/controllers/analysis_controller_factory.dart';
import '../../lib/core/validation/type_validator.dart';
import '../../lib/services/ingredient_analysis_hub_v2.dart';
import '../../lib/services/mixing_analysis_controller_v2.dart';

void main() {
  group('Analysis System Integration Tests', () {
    late AnalysisControllerFactory factory;
    late IngredientAnalysisControllerV2 ingredientController;
    late MixingAnalysisControllerV2 mixingController;

    setUp(() async {
      // 타입 검증기 초기화
      initializeTypeValidators();

      // 팩토리 초기화
      factory = AnalysisControllerFactory.instance;

      // 컨트롤러 인스턴스
      ingredientController = IngredientAnalysisControllerV2.instance;
      mixingController = MixingAnalysisControllerV2.instance;

      // 팩토리 초기화 대기
      await factory.initializeAllControllers();
    });

    tearDown(() async {
      // 정리
      await factory.disposeAllControllers();
    });

    test('컨트롤러 팩토리 기본 기능 테스트', () {
      // 컨트롤러 존재 확인
      expect(factory.hasController('ingredient_analysis'), true);
      expect(factory.hasController('mixing_analysis'), true);

      // 컨트롤러 조회
      final ingredient = factory.getController('ingredient_analysis');
      expect(ingredient, isNotNull);
      expect(ingredient!.controllerName, 'IngredientAnalysisControllerV2');

      // 팩토리 통계
      final stats = factory.getFactoryStats();
      expect(stats['totalControllers'], 2);
      expect(stats['activeControllers'], 2);
    });

    test('타입 검증 시스템 테스트', () {
      // 유효한 분석 요청 생성
      final request = AnalysisRequest(
        ingredients: [
          {'name': 'flour', 'amount': 500.0},
          {'name': 'water', 'amount': 300.0},
          {'name': 'sugar', 'amount': 50.0},
          {'name': 'butter', 'amount': 100.0},
        ],
        breadType: 'brioche',
        settings: const AnalysisSettings(),
        environment: {'temperature': 24.0, 'humidity': 65.0},
        requestId: 'test_request_001',
      );

      // 타입 검증
      final validation =
          RuntimeTypeValidator.validateType(request, 'AnalysisRequest');
      expect(validation.isValid, true);
      expect(validation.errors, isEmpty);
    });

    test('재료 분석 컨트롤러 통합 테스트', () async {
      // 테스트 데이터
      final request = AnalysisRequest(
        ingredients: [
          {'name': 'flour', 'amount': 500.0},
          {'name': 'water', 'amount': 300.0},
          {'name': 'sugar', 'amount': 50.0},
          {'name': 'butter', 'amount': 100.0},
        ],
        breadType: 'brioche',
        settings: const AnalysisSettings(),
        environment: {'temperature': 24.0, 'humidity': 65.0},
        requestId: 'test_request_002',
      );

      // 분석 실행
      final result = await ingredientController.analyze(request);

      // 결과 검증
      expect(result.success, true);
      expect(result.data, isNotNull);
      expect(result.data!.analysisId.isNotEmpty, true);
      expect(result.data!.overallConfidence, greaterThanOrEqualTo(0.0));
      expect(result.data!.overallConfidence, lessThanOrEqualTo(1.0));
      expect(result.processingTime, greaterThan(Duration.zero));

      // 세부 분석 결과 검증
      final analysis = result.data!;
      expect(analysis.syrupAnalysis.sugarContent, greaterThan(0.0));
      expect(analysis.fatAnalysis.fatContent, greaterThan(0.0));
      expect(analysis.specialDoughDetection.detectedTypes, isNotEmpty);
    });

    test('믹싱 분석 컨트롤러 통합 테스트', () async {
      // 테스트 데이터
      final input = {
        'mixingData': [
          {'speed': '저속', 'time': 5.0, 'comment': '초기 반죽'},
          {'speed': '중속', 'time': 10.0, 'comment': '본 반죽'},
          {'speed': '고속', 'time': 3.0, 'comment': '마무리'},
        ],
        'temperature': 24.0,
        'mixerType': 'home',
      };

      // 분석 실행
      final result = await mixingController.analyze(input);

      // 결과 검증
      expect(result.success, true);
      expect(result.data, isNotNull);
      expect(result.data!.optimizedSteps, isNotEmpty);
      expect(result.data!.confidenceScore, greaterThanOrEqualTo(0.0));
      expect(result.data!.confidenceScore, lessThanOrEqualTo(1.0));
      expect(result.processingTime, greaterThan(Duration.zero));
    });

    test('컨트롤러 메타데이터 및 설정 테스트', () {
      // 메타데이터 조회
      final ingredientMetadata =
          factory.getControllerMetadata('ingredient_analysis');
      expect(ingredientMetadata, isNotNull);
      expect(ingredientMetadata!.version, '2.0.0');
      expect(ingredientMetadata.tags.contains('ingredient'), true);

      // 믹싱 컨트롤러 메타데이터
      final mixingMetadata = factory.getControllerMetadata('mixing_analysis');
      expect(mixingMetadata, isNotNull);
      expect(mixingMetadata!.tags.contains('rpm'), true);
    });

    test('컨트롤러 활성화/비활성화 테스트', () {
      // 초기 상태 확인
      expect(factory.getActiveControllers().length, 2);

      // 컨트롤러 비활성화
      factory.setControllerActive('ingredient_analysis', false);

      // 활성 컨트롤러 수 확인
      expect(factory.getActiveControllers().length, 1);

      // 다시 활성화
      factory.setControllerActive('ingredient_analysis', true);
      expect(factory.getActiveControllers().length, 2);
    });

    test('분석 타입별 컨트롤러 조회 테스트', () {
      // 시럽 분석 컨트롤러 조회
      final syrupControllers =
          factory.getControllersForAnalysisType('syrup_analysis');
      expect(syrupControllers.contains('ingredient_analysis'), true);

      // 믹싱 최적화 컨트롤러 조회
      final mixingControllers =
          factory.getControllersForAnalysisType('mixing_optimization');
      expect(mixingControllers.contains('mixing_analysis'), true);

      // 존재하지 않는 타입
      final unknownControllers =
          factory.getControllersForAnalysisType('unknown_type');
      expect(unknownControllers, isEmpty);
    });

    test('컨트롤러 검증 테스트', () async {
      final validationResults = await factory.validateControllers();

      expect(validationResults.length, 2);

      // 각 컨트롤러 검증 결과 확인
      for (final entry in validationResults.entries) {
        expect(entry.value['isValid'], true);
        expect(entry.value['status'], 'valid');
        expect(entry.value['supportedTypes'], isNotEmpty);
      }
    });

    test('성능 메트릭스 및 모니터링 테스트', () async {
      // 모니터링 서비스 초기화
      final monitoring = ControllerMonitoringService();

      // 메트릭스 수집
      await monitoring.collectMetrics();

      // 메트릭스 조회
      final ingredientMetrics = monitoring.getMetrics('ingredient_analysis');
      expect(ingredientMetrics, isNotNull);
      expect(ingredientMetrics!.isHealthy, true);

      // 성능 리포트 생성
      final report = monitoring.generatePerformanceReport();
      expect(report['status'] != 'no_data', true);
      expect(report['summary'], isNotNull);
    });

    test('오류 처리 및 폴백 테스트', () async {
      // 잘못된 입력 데이터
      final invalidRequest = AnalysisRequest(
        ingredients: [], // 빈 재료 목록
        breadType: '',
        settings: const AnalysisSettings(),
        environment: {},
        requestId: 'invalid_request',
      );

      // 분석 실행
      final result = await ingredientController.analyze(invalidRequest);

      // 실패 결과 확인
      expect(result.success, false);
      expect(result.error, isNotNull);
      expect(result.data, isNull);
    });

    test('캐시 기능 테스트', () async {
      final request = AnalysisRequest(
        ingredients: [
          {'name': 'flour', 'amount': 500.0},
          {'name': 'water', 'amount': 300.0},
        ],
        breadType: 'standard',
        settings: const AnalysisSettings(),
        environment: {'temperature': 24.0},
        requestId: 'cache_test_request',
      );

      // 첫 번째 분석
      final result1 = await ingredientController.analyze(request);
      expect(result1.success, true);

      // 두 번째 분석 (캐시 사용)
      final result2 = await ingredientController.analyze(request);
      expect(result2.success, true);

      // 두 결과가 동일한지 확인 (캐시된 결과)
      expect(result1.data?.analysisId == result2.data?.analysisId, true);
    });

    test('분석 서비스 매니저 통합 테스트', () async {
      final serviceManager = AnalysisServiceManager();

      // 서비스 초기화
      await serviceManager.initialize();

      // 분석 요청
      final request = AnalysisRequest(
        ingredients: [
          {'name': 'flour', 'amount': 500.0},
          {'name': 'water', 'amount': 300.0},
          {'name': 'yeast', 'amount': 7.0},
          {'name': 'salt', 'amount': 10.0},
        ],
        breadType: 'sourdough',
        settings: const AnalysisSettings(enableRPMMode: false),
        environment: {
          'temperature': 24.0,
          'humidity': 65.0,
          'mixerType': 'spiral',
        },
        requestId: 'integration_test_001',
      );

      // 분석 처리
      final response = await serviceManager.processAnalysisRequest(request);

      // 결과 검증
      expect(response.success, true);
      expect(response.requestId, request.requestId);
      expect(response.analysis, isNotNull);
      expect(response.totalProcessingTime, greaterThan(Duration.zero));

      // 서비스 정리
      await serviceManager.dispose();
    });
  });
}
