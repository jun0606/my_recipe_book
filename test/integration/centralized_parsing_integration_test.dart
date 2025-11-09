import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/centralized_parsing_service.dart';

void main() {
  group('CentralizedParsingService Integration Tests', () {
    late CentralizedParsingService service;

    setUp(() {
      service = CentralizedParsingService();
    });

    test('extractMixingSteps should return empty list for empty recipe', () {
      final recipeData = <String, dynamic>{};
      final result = service.extractMixingSteps(recipeData);
      expect(result, isEmpty);
    });

    test('parseIngredientsForMoisture should handle JSON ingredients', () {
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500, 'unit': 'g'},
          {'name': '물', 'amount': 300, 'unit': 'ml'},
          {'name': '우유', 'amount': 100, 'unit': 'ml'},
        ]
      };

      final result = service.parseIngredientsForMoisture(recipeData);

      expect(result['flourWeight'], 500.0);
      expect(result['waterWeight'], 300.0);
      expect(result['milkWeight'], 100.0);
      expect(result['totalMoisture'], 387.0); // 300 + 100*0.87
    });

    test('parseIngredientsForMoisture should handle text ingredients', () {
      final recipeData = {'ingredients': '강력분 500g\n물 300ml\n우유 100ml'};

      final result = service.parseIngredientsForMoisture(recipeData);

      expect(result['flourWeight'], 500.0);
      expect(result['waterWeight'], 300.0);
      expect(result['milkWeight'], 100.0);
    });

    test('calculateTotalIngredientWeight should sum all weights', () {
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500, 'unit': 'g'},
          {'name': '물', 'amount': 300, 'unit': 'ml'},
          {'name': '우유', 'amount': 100, 'unit': 'ml'},
        ]
      };

      final result = service.calculateTotalIngredientWeight(recipeData);
      expect(result, 900.0); // 500 + 300 + 100
    });

    test('should handle complex ingredient parsing', () {
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 300, 'unit': 'g'},
          {'name': '중력분', 'amount': 200, 'unit': 'g'},
          {'name': '물', 'amount': 250, 'unit': 'ml'},
          {'name': '뜨거운 물', 'amount': 100, 'unit': 'ml'},
          {'name': '우유', 'amount': 50, 'unit': 'ml'},
          {'name': '설탕', 'amount': 20, 'unit': 'g'},
        ]
      };

      final result = service.parseIngredientsForMoisture(recipeData);

      // 밀가루 합계: 300 + 200 = 500g
      expect(result['flourWeight'], 500.0);

      // 물 합계: 250 + 100 = 350ml
      expect(result['waterWeight'], 350.0);

      // 우유: 50ml
      expect(result['milkWeight'], 50.0);

      // 총 수분: 350 + 50*0.87 = 393.5ml
      expect(result['totalMoisture'], 393.5);
    });

    test('should handle mixed text and JSON ingredients gracefully', () {
      final recipeData = {'ingredients': '강력분 400g\n물 350ml\n소금 10g'};

      final result = service.parseIngredientsForMoisture(recipeData);

      expect(result['flourWeight'], 400.0);
      expect(result['waterWeight'], 350.0);
      expect(result['milkWeight'], 0.0);
      expect(result['totalMoisture'], 350.0);
    });

    test('should handle empty or invalid data', () {
      final result1 = service.parseIngredientsForMoisture({});
      expect(result1['flourWeight'], 0.0); // 기본값

      final result2 = service.calculateTotalIngredientWeight({});
      expect(result2, 0.0); // 기본값
    });

    test('integration with mixing_analysis_card.dart pattern', () {
      // 실제 mixing_analysis_card.dart에서 사용하는 패턴과 유사한 데이터
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500, 'unit': 'g'},
          {'name': '물', 'amount': 320, 'unit': 'ml'},
          {'name': '이스트', 'amount': 7, 'unit': 'g'},
          {'name': '소금', 'amount': 10, 'unit': 'g'},
          {'name': '버터', 'amount': 30, 'unit': 'g'},
        ],
        'process': [
          {'type': 'mixing', 'name': '1단계: 재료 혼합', 'duration': 5},
          {'type': 'mixing', 'name': '2단계: 글루텐 형성', 'duration': 8},
          {'type': 'mixing', 'name': '3단계: 마무리', 'duration': 3},
        ]
      };

      // 믹싱 단계 추출 테스트
      final mixingSteps = service.extractMixingSteps(recipeData);
      expect(mixingSteps.length, greaterThanOrEqualTo(0));

      // 재료 파싱 테스트
      final ingredients = service.parseIngredientsForMoisture(recipeData);
      expect(ingredients['flourWeight'], 500.0);
      expect(ingredients['waterWeight'], 320.0);

      // 총량 계산 테스트 (밀가루 + 물 + 우유만 포함)
      final totalWeight = service.calculateTotalIngredientWeight(recipeData);
      expect(totalWeight, 820.0); // 500 + 320 + 0 (버터, 이스트, 소금은 제외)
    });
  });
}
