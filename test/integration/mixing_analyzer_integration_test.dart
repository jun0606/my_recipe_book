import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/core/types/unified_types.dart';
import 'package:my_recipe_book/features/chef/module/bread/types/bread_types.dart';
import 'package:my_recipe_book/features/chef/module/bread/models/integrated_mixing_analysis_types.dart';
import 'package:my_recipe_book/features/chef/module/bread/services/integrated_mixing_analyzer.dart';

void main() {
  group('통합 믹싱 분석 엔진 테스트', () {
    late BreadMixingAnalyzer analyzer;

    setUp(() {
      analyzer = BreadMixingAnalyzer();
    });

    test('분석 엔진 버전 확인', () {
      expect(analyzer.version, '1.0.0');
    });

    test('지원되는 반죽 타입 확인', () {
      final supportedTypes = analyzer.supportedDoughTypes;
      expect(supportedTypes, isNotEmpty);
      expect(supportedTypes.contains(DoughType.lean), isTrue);
    });

    test('입력 검증 테스트', () async {
      // 유효한 입력
      final validInput = {
        'recipe': {
          'id': 'test_recipe',
          'title': '테스트 레시피',
        },
        'userData': {
          'userId': 'test_user',
        },
      };

      final isValid = await analyzer.validateInput(validInput);
      expect(isValid, isTrue);

      // 유효하지 않은 입력
      final invalidInput = <String, dynamic>{};

      final isInvalid = await analyzer.validateInput(invalidInput);
      expect(isInvalid, isFalse);
    });

    test('빠른 분석 테스트', () async {
      final input = {
        'recipe': {
          'id': 'quick_test',
          'title': '빠른 테스트 레시피',
        },
        'userData': {
          'userId': 'quick_user',
        },
      };

      final result = await analyzer.quickAnalyze(input);

      expect(result['analysisId'], startsWith('quick_'));
      expect(result['success'], isTrue);
      expect(result['result'], '빠른 믹싱 분석 완료');
    });

    test('믹싱 프로세스 분석 테스트', () async {
      final input = {
        'recipe': {
          'id': 'mixing_test',
          'title': '믹싱 테스트 레시피',
          'ingredients': [
            {
              'id': 'flour',
              'name': '밀가루',
              'amount': 500.0,
              'unit': 'g',
            },
            {
              'id': 'water',
              'name': '물',
              'amount': 300.0,
              'unit': 'g',
            },
            {
              'id': 'yeast',
              'name': '이스트',
              'amount': 7.0,
              'unit': 'g',
            },
          ],
          'processes': [
            {
              'id': 'mixing_1',
              'name': '초기 믹싱',
              'type': 'mixing',
              'duration': 5,
              'parameters': {'speed': '저속'},
            },
            {
              'id': 'mixing_2',
              'name': '본 믹싱',
              'type': 'mixing',
              'duration': 10,
              'parameters': {'speed': '중속'},
            },
          ],
        },
        'userData': {
          'userId': 'mixing_user',
          'environment': {
            'temperature': 25.0,
            'humidity': 60.0,
          },
        },
      };

      final result = await analyzer.analyze(input);

      expect(result['analysisId'], startsWith('simple_'));
      expect(result['success'], isTrue);
      expect(result['result'], '기본 믹싱 분석 완료');
    });
  });

  group('통합 믹싱 분석 엔진 팩토리 테스트', () {
    test('기본 엔진 생성', () {
      final analyzer = IntegratedMixingAnalyzerFactory.createDefault();
      expect(analyzer, isNotNull);
      expect(analyzer.version, '1.0.0');
    });

    test('커스텀 엔진 생성', () {
      final analyzer = IntegratedMixingAnalyzerFactory.createCustom();
      expect(analyzer, isNotNull);
      expect(analyzer.version, '1.0.0');
    });
  });
}
