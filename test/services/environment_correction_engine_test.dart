import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/services/environment_correction_engine.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';

void main() {
  group('환경 보정 엔진 테스트', () {
    test('발효 속도 온도 보정 계산이 정확해야 함', () {
      // 기준 온도 25°C에서는 1.0
      expect(
        EnvironmentCorrectionEngine.calculateFermentationSpeedCorrection(25.0),
        closeTo(1.0, 0.01),
      );

      // 35°C에서는 2.0
      expect(
        EnvironmentCorrectionEngine.calculateFermentationSpeedCorrection(35.0),
        closeTo(2.0, 0.01),
      );

      // 15°C에서는 0.5
      expect(
        EnvironmentCorrectionEngine.calculateFermentationSpeedCorrection(15.0),
        closeTo(0.5, 0.01),
      );
    });

    test('습도 보정 계산이 정확해야 함', () {
      // 기준 습도 65%에서는 1.0
      expect(
        EnvironmentCorrectionEngine.calculateHumidityCorrection(65.0),
        closeTo(1.0, 0.01),
      );

      // 75%에서는 1.05
      expect(
        EnvironmentCorrectionEngine.calculateHumidityCorrection(75.0),
        closeTo(1.05, 0.01),
      );

      // 55%에서는 0.95
      expect(
        EnvironmentCorrectionEngine.calculateHumidityCorrection(55.0),
        closeTo(0.95, 0.01),
      );
    });

    test('고도 보정 계산이 정확해야 함', () {
      // 해수면에서는 1.0
      expect(
        EnvironmentCorrectionEngine.calculateAltitudeCorrection(0.0),
        closeTo(1.0, 0.01),
      );

      // 1000m에서는 1.02
      expect(
        EnvironmentCorrectionEngine.calculateAltitudeCorrection(1000.0),
        closeTo(1.02, 0.01),
      );

      // 2000m에서는 1.04
      expect(
        EnvironmentCorrectionEngine.calculateAltitudeCorrection(2000.0),
        closeTo(1.04, 0.01),
      );
    });

    test('통합 보정 계산이 정확해야 함', () {
      final conditions = EnvironmentalConditions(
        temperature: 30.0,
        humidity: 70.0,
        altitude: 1000.0,
        season: Season.spring,
      );

      final result =
          EnvironmentCorrectionEngine.calculateIntegratedCorrection(conditions);

      expect(result.temperatureCorrection, closeTo(1.414, 0.01));
      expect(result.humidityCorrection, closeTo(1.025, 0.01));
      expect(result.altitudeCorrection, closeTo(1.02, 0.01));
      expect(result.seasonalCorrection, closeTo(1.0, 0.01));
      expect(result.integratedCorrection, closeTo(1.478, 0.01));
    });

    test('발효 시간 보정이 올바르게 적용되어야 함', () {
      final conditions = EnvironmentalConditions(
        temperature: 30.0,
        humidity: 65.0,
        altitude: 0.0,
        season: Season.spring,
      );
      final correction =
          EnvironmentCorrectionEngine.calculateIntegratedCorrection(conditions);

      final correctedTime =
          EnvironmentCorrectionEngine.applyFermentationTimeCorrection(
        120,
        correction,
      );

      // 온도가 높으면 발효 시간이 단축되어야 함
      expect(correctedTime, lessThan(120));
    });

    test('최적 환경 진단이 정확해야 함', () {
      final optimalConditions = EnvironmentalConditions(
        temperature: 22.0,
        humidity: 65.0,
        altitude: 100.0,
        season: Season.spring,
      );

      final diagnosis =
          EnvironmentCorrectionEngine.diagnoseEnvironment(optimalConditions);

      expect(diagnosis.isOptimal, true);
      expect(diagnosis.issues, isEmpty);
      expect(diagnosis.riskLevel, '낮음');
      expect(diagnosis.overallAssessment, contains('최적'));
    });
  });
}
