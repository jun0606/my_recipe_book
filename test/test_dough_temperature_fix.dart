import 'package:flutter_test/flutter_test.dart';
import '../lib/services/bread_dough_analyzer.dart';

void main() {
  group('DoughTemperature 음수 값 방지 테스트', () {
    test('기본 믹서 타입이 음수 값 방지 보장', () {
      // 매우 낮은 환경 온도 테스트
      final testInputs = {
        'temperature': -10.0, // 매우 낮은 온도
        'mixerType': 'home',
        'mixerType': 'home',
        'altitude': 100.0,
        'season': 'winter',
        'humidity': 60.0,
      };

      final result = BreadDoughAnalyzer.calculateDoughStageAnalysis(testInputs);
      final doughTemp =
          double.tryParse(result.doughTemperature.replaceAll('°C', '')) ?? 0;

      print('환경 온도: -10°C, 계산된 반죽 온도: ${doughTemp}°C');

      // 최소 상승치 보장 확인
      expect(doughTemp, greaterThanOrEqualTo(5.0),
          reason: '반죽온도는 절대 음수가 되어선 안됨');

      // 합리적 범위 확인
      expect(doughTemp, lessThanOrEqualTo(45.0),
          reason: '반죽온도는 현실적 범위를 초과해서도 안됨');
    });

    test('모든 믹서 타입에서 음수 값 발생하지 않음', () {
      final mixerTypes = ['home', 'commercial', 'professional'];

      for (final mixerType in mixerTypes) {
        final testInputs = {
          'temperature': -5.0, // 낮은 온도
          'mixerType': mixerType,
          'altitude': 100.0,
          'season': 'winter',
          'humidity': 60.0,
        };

        final result =
            BreadDoughAnalyzer.calculateDoughStageAnalysis(testInputs);
        final doughTemp =
            double.tryParse(result.doughTemperature.replaceAll('°C', '')) ?? 0;

        print('${mixerType} 타입, 환경온도 -5°C: 계산된 반죽온도 ${doughTemp}°C');

        // 음수 값 방지 확인
        expect(doughTemp, greaterThanOrEqualTo(5.0),
            reason: '${mixerType} 타입에서 반죽온도가 음수가 되어선 안됨');
      }
    });

    test('높은 온도에서도 속도 제한 적용', () {
      final testInputs = {
        'temperature': 35.0, // 높은 온도
        'mixerType': 'professional',
        'altitude': 100.0,
        'season': 'summer',
        'humidity': 70.0,
      };

      final result = BreadDoughAnalyzer.calculateDoughStageAnalysis(testInputs);
      final doughTemp =
          double.tryParse(result.doughTemperature.replaceAll('°C', '')) ?? 0;

      print('환경온도 35°C + 전문가 믹서: 계산된 반죽온도 ${doughTemp}°C');

      // 합리적 상한선 확인
      expect(doughTemp, lessThanOrEqualTo(45.0),
          reason: '반죽온도는 최대 45°C를 초과해서도 안됨');
    });
  });
}
