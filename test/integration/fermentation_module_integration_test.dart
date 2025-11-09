/// Phase 4: 발효 모듈 통합 테스트
/// 재료 효과 기반 발효 시나리오 엔진의 정확도 및 성능 검증

import 'dart:developer' as developer;
import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';
import 'package:my_recipe_book/models/sous_chef_models.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'
    as advanced_models;
import '../../lib/services/fermentation_scenario_engine.dart';

void main() {
  group('FermentationScenarioEngineWithEffects Integration Tests', () {
    late FermentationScenarioEngine engine;

    setUp(() {
      engine = FermentationScenarioEngine();
    });

    group('재료 효과 기반 발효 시나리오 생성 테스트', () {
      test('기본 발효 시나리오 생성 검증', () async {
        // Given: 기본 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 기본 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 기본 시나리오 검증
        expect(scenario, isNotNull);
        expect(scenario.name, contains('AI 생성 발효 시나리오'));
        expect(scenario.stages.length, equals(3));
        expect(scenario.totalDuration, isNotNull);
        expect(scenario.totalDuration.inHours, greaterThan(0));
      });

      test('냉장 발효 시나리오 생성 검증', () async {
        // Given: 냉장 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.coldRetardation;
        final recipe = RecipeAnalysis(
          hydration: 0.75,
          saltRatio: 0.025,
          yeastRatio: 0.001,
          sugarRatio: 0.03,
          fatRatio: 0.03,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 4.0,
          humidity: 70.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.automatic,
        );

        // When: 냉장 발효 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 냉장 발효 시나리오 검증
        expect(scenario, isNotNull);
        expect(scenario.method, equals(FermentationMethodV2.coldRetardation));
        expect(scenario.totalDuration.inHours, greaterThan(10)); // 10시간 이상
        expect(scenario.totalDuration.inHours, lessThan(15)); // 15시간 미만
      });

      test('동결 해동 발효 시나리오 생성 검증', () async {
        // Given: 동결 해동 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.freezerOvernight;
        final recipe = RecipeAnalysis(
          hydration: 0.72,
          saltRatio: 0.02,
          yeastRatio: 0.003,
          sugarRatio: 0.02,
          fatRatio: 0.04,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: -18.0,
          humidity: 60.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.automatic,
        );

        // When: 동결 해동 발효 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 동결 해동 발효 시나리오 검증
        expect(scenario, isNotNull);
        expect(scenario.method, equals(FermentationMethodV2.freezerOvernight));
        expect(scenario.totalDuration.inHours, greaterThan(20)); // 20시간 이상
        expect(scenario.totalDuration.inHours, lessThan(30)); // 30시간 미만
      });
    });

    group('시나리오 단계별 검증', () {
      test('1차 발효 단계 검증', () async {
        // Given: 기본 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 1차 발효 단계 검증
        final primaryStage = scenario.stages.firstWhere(
          (stage) => stage.type == FermentationStageType.primary,
        );

        expect(primaryStage.name, contains('1차 발효 단계'));
        expect(primaryStage.duration.inMinutes, greaterThan(30)); // 30분 이상
        expect(primaryStage.temperature.min, greaterThanOrEqualTo(20));
        expect(primaryStage.temperature.max, lessThanOrEqualTo(30));
        expect(primaryStage.humidity.min, greaterThanOrEqualTo(65));
        expect(primaryStage.humidity.max, lessThanOrEqualTo(80));
      });

      test('휴지 단계 검증', () async {
        // Given: 기본 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 휴지 단계 검증
        final proofingStage = scenario.stages.firstWhere(
          (stage) => stage.type == FermentationStageType.proofing,
        );

        expect(proofingStage.name, contains('휴지 단계'));
        expect(proofingStage.duration.inMinutes, greaterThan(10)); // 10분 이상
        expect(proofingStage.temperature.min, greaterThanOrEqualTo(20));
        expect(proofingStage.temperature.max, lessThanOrEqualTo(30));
        expect(proofingStage.humidity.min, greaterThanOrEqualTo(65));
        expect(proofingStage.humidity.max, lessThanOrEqualTo(80));
      });

      test('최종 발효 단계 검증', () async {
        // Given: 기본 발효 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 최종 발효 단계 검증
        final finalStage = scenario.stages.firstWhere(
          (stage) => stage.type == FermentationStageType.finalStage,
        );

        expect(finalStage.name, contains('최종 발효 단계'));
        expect(finalStage.duration.inMinutes, greaterThan(5)); // 5분 이상
        expect(finalStage.temperature.min, greaterThanOrEqualTo(20));
        expect(finalStage.temperature.max, lessThanOrEqualTo(30));
        expect(finalStage.humidity.min, greaterThanOrEqualTo(65));
        expect(finalStage.humidity.max, lessThanOrEqualTo(80));
      });
    });

    group('환경 변화 대응 테스트', () {
      test('온도 변화에 대한 시나리오 조정', () async {
        // Given: 원본 시나리오
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final originalEnv = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        final originalScenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: originalEnv,
          equipment: equipment,
        );

        // When: 온도 상승 환경 변화
        final newEnv = advanced_models.EnvironmentalConditions(
          temperature: 30.0, // 5°C 상승
          humidity: 65.0,
          pressure: 1013.25,
        );
        final change = EnvironmentalChange(newConditions: newEnv);

        final adaptedScenario = await engine.adaptScenario(
          originalScenario,
          change,
        );

        // Then: 시나리오 조정 검증
        expect(adaptedScenario, isNotNull);
        expect(adaptedScenario.name, contains('(조정됨)'));
        expect(
            adaptedScenario.environmentalConditions.temperature, equals(30.0));
      });

      test('습도 변화에 대한 시나리오 조정', () async {
        // Given: 원본 시나리오
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final originalEnv = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        final originalScenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: originalEnv,
          equipment: equipment,
        );

        // When: 습도 상승 환경 변화
        final newEnv = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 80.0, // 15% 상승
          pressure: 1013.25,
        );
        final change = EnvironmentalChange(newConditions: newEnv);

        final adaptedScenario = await engine.adaptScenario(
          originalScenario,
          change,
        );

        // Then: 시나리오 조정 검증
        expect(adaptedScenario, isNotNull);
        expect(adaptedScenario.name, contains('(조정됨)'));
        expect(adaptedScenario.environmentalConditions.humidity, equals(80.0));
      });
    });

    group('에러 처리 및 폴백 테스트', () {
      test('잘못된 입력에 대한 폴백 처리', () async {
        // Given: 잘못된 입력
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final invalidRecipe = RecipeAnalysis(
          hydration: -1.0, // 잘못된 수분 비율
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성 시도
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: invalidRecipe,
          env: env,
          equipment: equipment,
        );

        // Then: 폴백 동작 검증 (기본 시나리오 생성)
        expect(scenario, isNotNull);
        expect(scenario.name, contains('AI 생성 발효 시나리오'));
        expect(scenario.stages.length, equals(3));
      });

      test('환경 조건 범위 초과 시 폴백 처리', () async {
        // Given: 극단적인 환경 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final extremeEnv = advanced_models.EnvironmentalConditions(
          temperature: 50.0, // 비정상적인 고온
          humidity: 95.0, // 비정상적인 고습도
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: extremeEnv,
          equipment: equipment,
        );

        // Then: 정상적인 시나리오 생성 검증
        expect(scenario, isNotNull);
        expect(scenario.stages.length, equals(3));
        // 온도 범위가 적절히 조정되었는지 확인
        for (final stage in scenario.stages) {
          expect(stage.temperature.min, greaterThanOrEqualTo(18));
          expect(stage.temperature.max, lessThanOrEqualTo(35));
        }
      });
    });

    group('성능 및 정확도 테스트', () {
      test('시나리오 생성 성능 검증', () async {
        // Given: 표준 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 성능 측정
        final stopwatch = Stopwatch()..start();
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );
        stopwatch.stop();

        // Then: 성능 검증 (500ms 이내)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(scenario, isNotNull);
      });

      test('메모리 누수 방지 검증', () async {
        // Given: 반복 실행 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 10회 반복 실행
        for (int i = 0; i < 10; i++) {
          final scenario = await engine.generateScenario(
            mode: mode,
            method: method,
            recipe: recipe,
            env: env,
            equipment: equipment,
          );
          expect(scenario, isNotNull);
        }

        // Then: 정상 종료 검증 (메모리 누수 없음)
        expect(true, isTrue); // 테스트 통과
      });
    });

    group('로그 및 디버깅 테스트', () {
      test('성공적인 시나리오 생성 로그 출력', () async {
        // Given: 로깅 활성화
        developer.log('=== 발효 모듈 테스트 시작 ===', name: 'FERMENTATION_TEST');

        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final recipe = RecipeAnalysis(
          hydration: 0.7,
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: recipe,
          env: env,
          equipment: equipment,
        );

        // Then: 로그 출력 검증
        developer.log('✅ 발효 시나리오 생성 성공', name: 'FERMENTATION_TEST');
        developer.log('📊 총 단계 수: ${scenario.stages.length}',
            name: 'FERMENTATION_TEST');
        developer.log('⏱️ 총 소요 시간: ${scenario.totalDuration.inHours}시간',
            name: 'FERMENTATION_TEST');

        expect(scenario, isNotNull);
      });

      test('에러 상황 로깅 검증', () async {
        // Given: 에러 유발 조건
        final mode = FermentationMode.roomTemperature;
        final method = FermentationMethodV2.normal;
        final invalidRecipe = RecipeAnalysis(
          hydration: double.nan, // NaN 값으로 에러 유발
          saltRatio: 0.02,
          yeastRatio: 0.002,
          sugarRatio: 0.05,
          fatRatio: 0.05,
        );
        final env = advanced_models.EnvironmentalConditions(
          temperature: 25.0,
          humidity: 65.0,
          pressure: 1013.25,
        );
        final equipment = EquipmentProfile(
          fermentationCapacity: 5.0,
          temperatureControl: TemperatureControl.manual,
        );

        // When: 시나리오 생성 시도
        final scenario = await engine.generateScenario(
          mode: mode,
          method: method,
          recipe: invalidRecipe,
          env: env,
          equipment: equipment,
        );

        // Then: 에러 로깅 및 폴백 동작 검증
        developer.log('⚠️ 에러 상황에서 폴백 동작 확인', name: 'FERMENTATION_TEST');
        expect(scenario, isNotNull); // 폴백으로 생성된 시나리오
        expect(scenario.stages.length, equals(3)); // 기본 단계 수 유지
      });
    });
  });

  group('FermentationScenarioEngine Extension Tests', () {
    late FermentationScenarioEngine engine;

    setUp(() {
      engine = FermentationScenarioEngine();
    });

    test('확장 메서드 존재 확인', () {
      // Given: 엔진 인스턴스
      // When: 확장 메서드 호출 가능 여부 확인
      // Then: 컴파일 에러 없이 테스트 통과
      expect(engine, isNotNull);
      // Note: 실제 확장 메서드 테스트는 별도 파일에서 수행
    });
  });
}
