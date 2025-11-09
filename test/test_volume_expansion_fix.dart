import 'package:flutter_test/flutter_test.dart';
import 'lib/services/fermentation_calculator.dart';

void main() {
  group('팽창율 계산 개선 테스트', () {
    test('2단계부터 급격한 팽창 개선 확인', () {
      // 표준화된 이스트 속성 생성
      final yeastProperties = StandardizedYeastProperties(
        percentage: 2.0,
        typeEfficiency: 0.8,
        activity: 0.016,
        co2Rate: 0.083333,
        isValid: true,
        validationWarnings: [],
      );

      // 1단계 팽창율 계산
      double step1Expansion = YeastCalculationService.calculateVolumeExpansion(
        fermentationProgress: 0.2,
        acidity: 4.5,
        glutenFormation: 0.8,
        stepNumber: 1,
        temperature: 25.0,
        humidity: 75.0,
        durationMinutes: 60,
        yeastProperties: yeastProperties,
      );

      // 2단계 팽창율 계산
      double step2Expansion = YeastCalculationService.calculateVolumeExpansion(
        fermentationProgress: 0.5,
        acidity: 4.8,
        glutenFormation: 0.8,
        stepNumber: 2,
        temperature: 25.0,
        humidity: 75.0,
        durationMinutes: 60,
        yeastProperties: yeastProperties,
      );

      // 3단계 팽창율 계산
      double step3Expansion = YeastCalculationService.calculateVolumeExpansion(
        fermentationProgress: 0.8,
        acidity: 5.0,
        glutenFormation: 0.8,
        stepNumber: 3,
        temperature: 25.0,
        humidity: 75.0,
        durationMinutes: 60,
        yeastProperties: yeastProperties,
      );

      print('📈 [팽창율 개선 테스트 결과]');
      print('   1단계 팽창율: ${step1Expansion.toStringAsFixed(2)}%');
      print('   2단계 팽창율: ${step2Expansion.toStringAsFixed(2)}%');
      print('   3단계 팽창율: ${step3Expansion.toStringAsFixed(2)}%');

      // 2단계와 1단계의 팽창율 차이 계산
      double step2Increase = step2Expansion - step1Expansion;
      double step3Increase = step3Expansion - step2Expansion;

      print('   1→2단계 증가량: ${step2Increase.toStringAsFixed(2)}%');
      print('   2→3단계 증가량: ${step3Increase.toStringAsFixed(2)}%');

      // 개선 확인: 2단계 증가량이 3단계 증가량보다 크지 않아야 함 (급격한 팽창 방지)
      expect(step2Increase, lessThanOrEqualTo(step3Increase * 1.5),
          reason: '2단계 팽창 증가가 과도하게 크지 않아야 함');

      // 각 단계 팽창율이 합리적인 범위 내에 있어야 함
      expect(step1Expansion, greaterThan(0));
      expect(step1Expansion, lessThan(50)); // 1단계는 낮은 팽창율
      expect(step2Expansion, greaterThan(step1Expansion)); // 2단계는 1단계보다 높아야 함
      expect(step3Expansion, greaterThan(step2Expansion)); // 3단계는 2단계보다 높아야 함
    });

    test('효율 요소 상한선 적용 확인', () {
      // 높은 효율 값들로 테스트하여 상한선이 적용되는지 확인
      final yeastProperties = StandardizedYeastProperties(
        percentage: 2.0,
        typeEfficiency: 0.8,
        activity: 0.016,
        co2Rate: 0.083333,
        isValid: true,
        validationWarnings: [],
      );

      // 매우 높은 진행률로 테스트 (상한선 적용 확인)
      double highProgressExpansion =
          YeastCalculationService.calculateVolumeExpansion(
        fermentationProgress: 0.95, // 매우 높은 진행률
        acidity: 4.5,
        glutenFormation: 0.8,
        stepNumber: 2,
        temperature: 35.0, // 높은 온도
        humidity: 95.0, // 높은 습도
        durationMinutes: 120, // 긴 시간
        yeastProperties: yeastProperties,
      );

      print('🔧 [효율 상한선 테스트]');
      print('   높은 조건 팽창율: ${highProgressExpansion.toStringAsFixed(2)}%');

      // 상한선 적용으로 인해 팽창율이 과도하게 높아지지 않아야 함
      expect(highProgressExpansion, lessThan(200.0),
          reason: '효율 상한선 적용으로 팽창율이 과도하게 높아지지 않아야 함');
    });
  });
}
