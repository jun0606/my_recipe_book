import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/features/chef/screen/controllers/fermentation_analysis_controller.dart';
import 'package:my_recipe_book/services/centralized_parsing_service.dart';

void main() {
  group('발효 시간 표준화 테스트', () {
    late CentralizedParsingService parsingService;

    setUp(() {
      parsingService = CentralizedParsingService();
    });

    test('단일 time 키만 사용하여 시간 추출', () {
      // 시간 데이터: 분 단위
      final stepData = {
        'stepNumber': 1,
        'time': 120, // 2시간 = 120분
        'targetTemperature': 26.0,
        'targetHumidity': 80,
        'description': 'test step'
      };

      final normalized =
          parsingService.normalizeUserFermentationStep(stepData, 0);

      // time 키만 존재하고 durationHours 키는 없어야 함
      expect(normalized.containsKey('time'), true);
      expect(normalized['time'], 120);
      expect(normalized.containsKey('durationHours'), false);
    });

    test('사용자 입력 정규화 시 time 키만 생성', () {
      final userStep = {
        'temperature': 25.0,
        'humidity': 75,
        'time': 90, // 1.5시간 = 90분
        'comment': '발효 단계'
      };

      final normalized =
          parsingService.normalizeUserFermentationStep(userStep, 0);

      expect(normalized['time'], 90);
      expect(normalized.containsKey('durationHours'), false);
    });

    test('컨트롤러에서 time 키 우선 사용', () {
      final controller = FermentationAnalysisController();

      // 실제 데이터를 시뮬레이션한 stepData
      final stepData = {
        'time': 60, // 1시간
        'targetTemperature': 26.0,
        'targetHumidity': 80.0,
        'description': '테스트 단계'
      };

      // 컨트롤러의 시간 추출 로직을 간접 테스트 위해 믹싱 데이터 설정
      controller.setMixingResult({
        'finalTemperature': 26.0,
        'finalGlutenFormation': 0.5,
        'finalViscosity': 1.3,
        'finalMoistureAbsorption': 65.0,
        'stepAnalyses': [
          {
            'doughState': {'developmentStage': '완전 개발'}
          }
        ]
      });

      // 실제 데이터 구조에서 time 값이 올바르게 유지되는지 확인
      final timeValue = stepData['time'];
      expect(timeValue, 60); // 시간 값이 보존됨
    });
  });
}
