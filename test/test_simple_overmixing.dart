// 간단한 계산 테스트
import 'lib/services/fermentation_calculator.dart';
import 'lib/core/types/calculation_types.dart';
import 'lib/features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;

void main() {
  print('=== 범위 제한 제거 후 계산 테스트 ===');

  // 모의 재료 데이터
  List<Map<String, dynamic>> mockIngredients = [
    {'name': '생이스트', 'amount': 10.0},
    {'name': '밀가루', 'amount': 500.0},
  ];

  print('재료: 생이스트 10g, 밀가루 500g');

  try {
    // 캐시 클리어 후 테스트
    FermentationCalculator.instance.clearCalculationCache();

    // art.FermentationStep 사용
    art.FermentationStep mockStep = art.FermentationStep(
      stepNumber: 1,
      duration: Duration(hours: 2),
      targetTemperature: 26.0,
      targetHumidity: 75.0,
      expectedStage: art.FermentationStage.primary,
      stepNotes: '테스트 단계',
    );

    // 이스트 퍼센트 계산 테스트
    double yeastPercent =
        FermentationCalculator.instance.calculateYeastActivity(
      previousState: FermentationState(
        yeastActivity: 0.0,
        fermentationProgress: 0.0,
        acidity: 5.8,
        volumeIncrease: 0.0,
        fermentationMethod: 'test',
        currentStep: 1,
        temperature: 25.0,
        humidity: 70.0,
      ),
      mixingState: BakingState(
        temperature: 25.0,
        glutenFormation: 0.8,
        viscosity: 1.2,
        moistureAbsorption: 0.6,
        developmentStage: 'optimal',
        currentStep: 1,
      ),
      step: mockStep, // art 타입
      previousResult: null,
      ingredients: mockIngredients,
    );

    print('\n=== 테스트 결과 ===');
    print('계산된 값: ${yeastPercent.toStringAsFixed(6)}');

    if (yeastPercent > 10.0) {
      print('❌ 과도하게 높은 값 발견! 355727% 같은 문제가 여전히 있음');
    } else if (yeastPercent < 0.0) {
      print('❌ 음수 값 발생');
    } else {
      print('✅ 정상적인 범위의 값 (0.0 ~ 10.0)');
    }
  } catch (e) {
    print('❌ 테스트 실패: $e');
  }

  print('\n=== 범위 제한 제거 작업 완료 ===');
  print('과도한 %값 문제가 해결되었는지 확인해보세요.');
}
