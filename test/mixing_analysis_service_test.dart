import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/services/mixing_analysis_service.dart';
import '../lib/core/types/environment_types.dart';
import '../lib/features/chef/screen/widgets/mixing_analysis_types.dart' as mat;

/// 기본 환경 객체 생성 헬퍼
UserEnvironment _createTestEnvironment() {
  return UserEnvironment(
    temperature: 25.0,
    humidity: 60.0,
    altitude: 0.0,
    season: Season.spring,
    ovenType: OvenType.home,
    fermentationMethod: FermentationMethod.roomTemperature,
    mixerType: MixerType.home,
  );
}

// Generate mocks
@GenerateMocks([
  MixingAnalysisService,
])
void main() {
  late MixingAnalysisService service;

  setUp(() {
    service = MixingAnalysisService();
  });

  group('MixingAnalysisService Phase 2 Tests', () {
    test('calculateGlutenFormationIncrement - Phase 2 입력 검증 강화', () {
      final environment = _createTestEnvironment();

      // Phase 2: 잘못된 단계 인덱스 검증
      expect(
        () => service.calculateGlutenFormationIncrement(
          stepIndex: -1,
          speed: '중속',
          duration: 5,
          currentGluten: 0.0,
          temperature: 25.0,
          environment: environment,
        ),
        returnsNormally, // Phase 2: 안전하게 처리
      );

      // Phase 2: 잘못된 시간 검증
      expect(
        () => service.calculateGlutenFormationIncrement(
          stepIndex: 0,
          speed: '중속',
          duration: 0,
          currentGluten: 0.0,
          temperature: 25.0,
          environment: environment,
        ),
        returnsNormally, // Phase 2: 안전하게 처리
      );

      // Phase 2: NaN 값 검증
      expect(
        () => service.calculateGlutenFormationIncrement(
          stepIndex: 0,
          speed: '중속',
          duration: 5,
          currentGluten: double.nan,
          temperature: 25.0,
          environment: environment,
        ),
        returnsNormally, // Phase 2: 안전하게 처리
      );
    });

    test('calculateGlutenFormationIncrement - Phase 2 동적 최대 증가량 적용', () {
      final environment = _createTestEnvironment();

      // Phase 2: 정상적인 계산 검증
      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 25.0,
        environment: environment,
      );

      // Phase 2: 결과가 0.05-0.40 범위 내인지 검증
      expect(result, greaterThanOrEqualTo(0.05));
      expect(result, lessThanOrEqualTo(0.40));

      // Phase 2: NaN/무한대가 아닌지 검증
      expect(result.isNaN, false);
      expect(result.isInfinite, false);
    });

    test('calculateGlutenFormationIncrement - Phase 2 최소 안전 증가량 보장', () {
      final environment = _createTestEnvironment();

      // Phase 2: 매우 낮은 값이 나올 수 있는 조건에서 최소값 보장 검증
      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 3, // 마지막 단계
        speed: '저속',
        duration: 2, // 짧은 시간
        currentGluten: 0.9, // 높은 현재 값
        temperature: 15.0, // 낮은 온도
        environment: environment,
      );

      // Phase 2: 최소 안전 증가량 보장 (0.01 이상)
      expect(result, greaterThanOrEqualTo(0.01));
    });

    test('calculateGlutenFormationIncrement - Phase 2 빵 제조 과학적 실제 값 범위', () {
      final environment = _createTestEnvironment();

      // Phase 2: 다양한 조건에서 실제 값 범위 검증
      final testCases = [
        {
          'stepIndex': 0,
          'speed': '고속',
          'duration': 8,
          'currentGluten': 0.0,
          'temperature': 30.0
        },
        {
          'stepIndex': 1,
          'speed': '중속',
          'duration': 5,
          'currentGluten': 0.2,
          'temperature': 25.0
        },
        {
          'stepIndex': 2,
          'speed': '저속',
          'duration': 3,
          'currentGluten': 0.5,
          'temperature': 20.0
        },
      ];

      for (final testCase in testCases) {
        final result = service.calculateGlutenFormationIncrement(
          stepIndex: testCase['stepIndex'] as int,
          speed: testCase['speed'] as String,
          duration: testCase['duration'] as int,
          currentGluten: testCase['currentGluten'] as double,
          temperature: testCase['temperature'] as double,
          environment: environment,
        );

        // Phase 2: 모든 경우에서 실제 빵 제조 값 범위 내인지 검증
        expect(result, greaterThanOrEqualTo(0.01));
        expect(result, lessThanOrEqualTo(0.40));
        expect(result.isNaN, false);
        expect(result.isInfinite, false);
      }
    });

    test('calculateGlutenFormationIncrement - Phase 2 재료 데이터 고려', () {
      final environment = _createTestEnvironment();

      // Phase 2: 재료 데이터가 있는 경우와 없는 경우 비교
      final ingredients = [
        {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
        {'name': '물', 'amount': 300.0, 'unit': 'g'},
      ];

      final resultWithIngredients = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 25.0,
        ingredients: ingredients,
        environment: environment,
      );

      final resultWithoutIngredients =
          service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 25.0,
        environment: environment,
      );

      // Phase 2: 재료 데이터가 있으면 더 정확한 계산이 되어야 함
      expect(resultWithIngredients, isNotNull);
      expect(resultWithoutIngredients, isNotNull);
      expect(resultWithIngredients.isNaN, false);
      expect(resultWithoutIngredients.isNaN, false);
    });

    test('performComprehensiveAnalysis - Phase 2 종합 분석 검증', () async {
      final stepAnalyses = [
        {
          'stepNumber': 1,
          'speed': '중속',
          'durationMinutes': 5,
          'rpm': 150,
          'doughState': {
            'glutenFormation': 0.15,
            'temperature': 26.0,
            'viscosity': 1.2,
            'moistureAbsorption': 68.5,
            'developmentStage': '초기 개발',
          },
          'efficiency': 0.85,
        },
        {
          'stepNumber': 2,
          'speed': '고속',
          'durationMinutes': 3,
          'rpm': 250,
          'doughState': {
            'glutenFormation': 0.35,
            'temperature': 28.0,
            'viscosity': 1.1,
            'moistureAbsorption': 72.0,
            'developmentStage': '중기 개발',
          },
          'efficiency': 0.78,
        },
      ];

      final recipeData = {
        'title': '기본 빵',
        'ingredients': [
          {'name': '밀가루', 'amount': 500, 'unit': 'g'},
          {'name': '물', 'amount': 300, 'unit': 'g'},
        ],
      };

      final result = await service.performComprehensiveAnalysis(
        stepAnalyses,
        recipeData,
        roomTemp: 25.0,
        humidity: 65.0,
      );

      // Phase 2: 종합 분석 결과 검증
      expect(result, isNotNull);
      expect(result['totalTime'], equals(8)); // 5 + 3
      expect(result['averageGlutenFormation'], greaterThan(0.0));
      expect(result['efficiency'], greaterThan(0.0));
      expect(result['overallScore'], greaterThanOrEqualTo(0.0));
      expect(result['overallScore'], lessThanOrEqualTo(1.0));
      expect(result['stepCount'], equals(2));
    });

    test('createStepAnalysisWithAccumulation - Phase 2 누적 계산 검증', () {
      final step = {
        'speed': '중속',
        'durationMinutes': 5,
        'temperature': 25.0,
      };

      final previousDoughState = {
        'temperature': 24.0,
        'glutenFormation': 0.1,
        'viscosity': 1.3,
        'moistureAbsorption': 65.0,
      };

      final result = service.createStepAnalysisWithAccumulation(
        step,
        0,
        previousDoughState,
      );

      // Phase 2: 누적 계산 결과 검증
      expect(result, isNotNull);
      expect(result['stepNumber'], equals(1));
      expect(result['speed'], equals('중속'));
      expect(result['durationMinutes'], equals(5));

      final doughState = result['doughState'] as Map<String, dynamic>;
      expect(doughState['glutenFormation'], greaterThanOrEqualTo(0.0));
      expect(doughState['temperature'], greaterThanOrEqualTo(15.0));
      expect(doughState['temperature'], lessThanOrEqualTo(45.0));
      expect(doughState['moistureAbsorption'], greaterThanOrEqualTo(50.0));
      expect(doughState['moistureAbsorption'], lessThanOrEqualTo(90.0));
    });

    test('generateSimpleAnalysisResult - Phase 2 간단 분석 결과 검증', () {
      final mixingSteps = [
        {'speed': '중속', 'durationMinutes': 5},
        {'speed': '고속', 'durationMinutes': 3},
      ];

      final environment = UserEnvironment(
        temperature: 25.0,
        humidity: 65.0,
        altitude: 0.0,
        season: Season.spring,
        ovenType: OvenType.home,
        fermentationMethod: FermentationMethod.roomTemperature,
        mixerType: MixerType.home,
      );

      final result = service.generateSimpleAnalysisResult(
        mixingSteps,
        environment,
      );

      // Phase 2: 간단 분석 결과 검증
      expect(result, isNotNull);
      expect(result['totalTime'], equals(8));
      expect(result['averageGlutenFormation'], greaterThanOrEqualTo(0.0));
      expect(result['efficiency'], greaterThanOrEqualTo(0.0));
      expect(result['overallScore'], greaterThanOrEqualTo(0.0));
      expect(result['performanceGrade'], isNotNull);
      expect(result['processOptimizationSuggestions'], isNotNull);
    });

    test('generateCurrentStatusWithWarnings - Phase 2 상태 및 경고 생성 검증', () {
      final mixingSteps = [
        {'speed': '고속', 'durationMinutes': 8}, // 잠재적 문제 조건
        {'speed': '중속', 'durationMinutes': 5},
      ];

      final environment = UserEnvironment(
        temperature: 35.0, // 높은 온도
        humidity: 30.0, // 낮은 습도
        altitude: 0.0,
        season: Season.spring,
        ovenType: OvenType.home,
        fermentationMethod: FermentationMethod.roomTemperature,
        mixerType: MixerType.home,
      );

      final result = service.generateCurrentStatusWithWarnings(
        mixingSteps,
        environment,
      );

      // Phase 2: 상태 및 경고 생성 검증
      expect(result, isNotNull);
      expect(result.length, greaterThanOrEqualTo(1)); // 최소 1개 이상의 상태 보고
      expect(result.length, lessThanOrEqualTo(4)); // 최대 4개까지만
    });
  });

  group('MixingAnalysisService Edge Cases - Phase 2', () {
    test('빈 재료 리스트 처리', () {
      final environment = _createTestEnvironment();

      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 25.0,
        ingredients: [], // 빈 리스트
        environment: environment,
      );

      expect(result, isNotNull);
      expect(result.isNaN, false);
      expect(result.isInfinite, false);
    });

    test('null 재료 데이터 처리', () {
      final environment = _createTestEnvironment();

      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 25.0,
        ingredients: null, // null 값
        environment: environment,
      );

      expect(result, isNotNull);
      expect(result.isNaN, false);
      expect(result.isInfinite, false);
    });

    test('극단적인 환경 조건 처리', () {
      final environment = _createTestEnvironment();

      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 0.0,
        temperature: 50.0, // 매우 높은 온도
        environment: environment,
      );

      expect(result, isNotNull);
      expect(result.isNaN, false);
      expect(result.isInfinite, false);
      expect(result, greaterThanOrEqualTo(0.01));
      expect(result, lessThanOrEqualTo(0.40));
    });

    test('비정상적인 글루텐 값 처리', () {
      final environment = _createTestEnvironment();

      final result = service.calculateGlutenFormationIncrement(
        stepIndex: 0,
        speed: '중속',
        duration: 5,
        currentGluten: 2.0, // 100% 초과
        temperature: 25.0,
        environment: environment,
      );

      expect(result, isNotNull);
      expect(result.isNaN, false);
      expect(result.isInfinite, false);
      // Phase 2: 높은 현재 글루텐 값에서도 적절한 증가량 계산
      expect(result, greaterThanOrEqualTo(0.01));
    });
  });

  group('MixingAnalysisService Performance - Phase 2', () {
    test('계산 성능 검증', () {
      final environment = _createTestEnvironment();
      final stopwatch = Stopwatch()..start();

      // Phase 2: 100회 반복 계산으로 성능 검증
      for (int i = 0; i < 100; i++) {
        final result = service.calculateGlutenFormationIncrement(
          stepIndex: i % 4,
          speed: '중속',
          duration: 5,
          currentGluten: 0.0,
          temperature: 25.0,
          environment: environment,
        );

        expect(result, isNotNull);
        expect(result.isNaN, false);
      }

      stopwatch.stop();

      // Phase 2: 100회 계산이 1초 이내 완료되어야 함
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('Phase 2 성능 테스트: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
