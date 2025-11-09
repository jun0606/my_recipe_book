import 'package:flutter_test/flutter_test.dart';
import 'lib/services/fermentation_calculator.dart';

void main() {
  group('생물학적 발효 모델 테스트', () {
    test('시간 종속 성장률 계산', () {
      // 15분 (로그 페이즈 시작)
      double growthRate15 =
          BiologicalFermentationModel.calculateBiologicalGrowthRate(
        totalElapsedTime: 15.0,
        yeastActivity: 0.016,
        temperature: 25.0,
        acidity: 4.5,
      );

      // 45분 (로그 페이즈 중간)
      double growthRate45 =
          BiologicalFermentationModel.calculateBiologicalGrowthRate(
        totalElapsedTime: 45.0,
        yeastActivity: 0.016,
        temperature: 25.0,
        acidity: 4.5,
      );

      // 90분 (정체 페이즈 시작)
      double growthRate90 =
          BiologicalFermentationModel.calculateBiologicalGrowthRate(
        totalElapsedTime: 90.0,
        yeastActivity: 0.016,
        temperature: 25.0,
        acidity: 4.5,
      );

      print('🧬 [생물학적 모델 테스트]');
      print('   15분 성장률: ${growthRate15.toStringAsFixed(4)}');
      print('   45분 성장률: ${growthRate45.toStringAsFixed(4)}');
      print('   90분 성장률: ${growthRate90.toStringAsFixed(4)}');

      // 로그 페이즈에서 성장률이 높아야 함
      expect(growthRate45, greaterThan(growthRate15));
      // 정체 페이즈에서는 성장률이 낮아야 함
      expect(growthRate90, lessThan(growthRate45));
    });

    test('페이즈 결정 함수', () {
      expect(BiologicalFermentationModel.determineFermentationPhase(10.0),
          FermentationPhase.lag);
      expect(BiologicalFermentationModel.determineFermentationPhase(30.0),
          FermentationPhase.log);
      expect(BiologicalFermentationModel.determineFermentationPhase(120.0),
          FermentationPhase.stationary);
      expect(BiologicalFermentationModel.determineFermentationPhase(180.0),
          FermentationPhase.death);
    });

    test('CO2 시간 종속 승수', () {
      double lagCO2 =
          BiologicalFermentationModel.calculateTimeDependentCO2Multiplier(
              FermentationPhase.lag, 5.0);
      double logCO2 =
          BiologicalFermentationModel.calculateTimeDependentCO2Multiplier(
              FermentationPhase.log, 30.0);
      double stationaryCO2 =
          BiologicalFermentationModel.calculateTimeDependentCO2Multiplier(
              FermentationPhase.stationary, 100.0);

      print('💨 [CO2 승수 테스트]');
      print('   라그 페이즈 CO2 승수: $lagCO2');
      print('   로그 페이즈 CO2 승수: $logCO2');
      print('   정체 페이즈 CO2 승수: $stationaryCO2');

      // 로그 페이즈에서 CO2 생성이 가장 높아야 함
      expect(logCO2, greaterThan(lagCO2));
      expect(logCO2, greaterThan(stationaryCO2));
    });
  });
}
