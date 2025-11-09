import 'package:flutter_test/flutter_test.dart';
import '../lib/services/fermentation_guide_service.dart';
import '../lib/services/fermenter_guide_manager.dart';

void main() {
  group('발효 가이드 한글 텍스트 테스트', () {
    late FermentationGuideService fermentationGuideService;

    setUp(() {
      fermentationGuideService = FermentationGuideService();
    });

    test('실온 발효 가이드 생성 및 한글 텍스트 확인', () async {
      // Given
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'ml'},
          {'name': '인스턴트 이스트', 'amount': 5.0, 'unit': 'g'},
          {'name': '소금', 'amount': 10.0, 'unit': 'g'},
        ],
        'totalWeight': 840.0,
        'bakingTemperature': 220.0,
        'bakingTime': 25.0,
      };

      final environmentalData = {
        'temperature': 25.0,
        'humidity': 65.0,
        'altitude': 0.0,
      };

      // When
      final guide = await fermentationGuideService.generateGuide(
        fermentationType: 'room_temperature',
        recipeData: recipeData,
        environmentalData: environmentalData,
      );

      // Then
      expect(guide.name, equals('실온 발효'));
      expect(guide.description, contains('실온에서 진행하는'));
      expect(guide.methodExplanation, contains('실온(20-30°C)에서'));
      expect(guide.customInstructions, isNotEmpty);
      expect(guide.steps, isNotEmpty);
      expect(guide.tips, isNotEmpty);

      // 한글 텍스트가 올바르게 포함되어 있는지 확인
      expect(
          guide.customInstructions.any((instruction) =>
              instruction.contains('실온 발효는') ||
              instruction.contains('온도') ||
              instruction.contains('발효')),
          isTrue);

      print('✅ 실온 발효 가이드 생성 성공');
      print('가이드 이름: ${guide.name}');
      print('설명: ${guide.description}');
      print('맞춤 지침 수: ${guide.customInstructions.length}');
      print('발효 단계 수: ${guide.steps.length}');
      print('팁 수: ${guide.tips.length}');
    });

    test('FermenterGuideManager.generateCustomGuideV2 한글 텍스트 확인', () async {
      // Given
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'ml'},
          {'name': '인스턴트 이스트', 'amount': 5.0, 'unit': 'g'},
        ],
      };

      final environmentalData = {
        'temperature': 25.0,
        'humidity': 65.0,
      };

      // When
      final result = await FermenterGuideManager.generateCustomGuideV2(
        fermentationType: 'room_temperature',
        recipeData: recipeData,
        environmentalData: environmentalData,
      );

      // Then
      expect(result, isNotNull);
      expect(result, isA<Map<String, dynamic>>());

      // 레거시 호환성 확인
      expect(result.containsKey('methodExplanation'), isTrue);
      expect(result.containsKey('customInstructions'), isTrue);

      // 한글 텍스트 확인
      final methodExplanation = result['methodExplanation'] as String?;
      expect(methodExplanation, isNotNull);
      expect(methodExplanation!, contains('발효'));

      final customInstructions = result['customInstructions'] as List?;
      expect(customInstructions, isNotNull);
      expect(customInstructions!, isNotEmpty);

      print('✅ FermenterGuideManager 통합 테스트 성공');
      print('방법 설명: $methodExplanation');
      print('맞춤 지침 수: ${customInstructions.length}');
    });

    test('냉장 발효 가이드 한글 텍스트 확인', () async {
      // Given
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 325.0, 'unit': 'ml'},
        ],
      };

      final environmentalData = {
        'temperature': 4.0,
        'humidity': 80.0,
      };

      // When
      final guide = await fermentationGuideService.generateGuide(
        fermentationType: 'cold',
        recipeData: recipeData,
        environmentalData: environmentalData,
      );

      // Then
      expect(guide.name, equals('냉장 발효'));
      expect(guide.description, contains('냉장고에서'));
      expect(guide.methodExplanation, contains('냉장고(2-8°C)에서'));

      print('✅ 냉장 발효 가이드 생성 성공');
      print('가이드 이름: ${guide.name}');
      print('설명: ${guide.description}');
    });

    test('온발효 가이드 한글 텍스트 확인', () async {
      // Given
      final recipeData = {
        'ingredients': [
          {'name': '강력분', 'amount': 500.0, 'unit': 'g'},
        ],
      };

      final environmentalData = {
        'temperature': 35.0,
        'humidity': 75.0,
      };

      // When
      final guide = await fermentationGuideService.generateGuide(
        fermentationType: 'warm',
        recipeData: recipeData,
        environmentalData: environmentalData,
      );

      // Then
      expect(guide.name, equals('온발효'));
      expect(guide.description, contains('따뜻한 환경에서'));
      expect(guide.methodExplanation, contains('발효기나 오븐의'));

      print('✅ 온발효 가이드 생성 성공');
      print('가이드 이름: ${guide.name}');
      print('설명: ${guide.description}');
    });

    test('오류 상황에서 기본 가이드 반환 확인', () async {
      // Given - 잘못된 데이터로 오류 유발
      final invalidRecipeData = <String, dynamic>{};
      final invalidEnvironmentalData = <String, dynamic>{};

      // When
      final result = await FermenterGuideManager.generateCustomGuideV2(
        fermentationType: 'invalid_type',
        recipeData: invalidRecipeData,
        environmentalData: invalidEnvironmentalData,
      );

      // Then - 기본 가이드가 반환되어야 함
      expect(result, isNotNull);
      expect(result['methodExplanation'], contains('발효 방식입니다'));

      print('✅ 오류 상황 처리 확인 완료');
      print('기본 가이드 반환: ${result['methodExplanation']}');
    });
  });
}
