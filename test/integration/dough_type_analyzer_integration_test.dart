import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/features/chef/module/bread/services/dough_type_analyzer_enhanced.dart';
import 'package:my_recipe_book/features/chef/module/bread/types/bread_types.dart';

void main() {
  group('향상된 반도 타입 분석기 통합 테스트', () {
    late EnhancedDoughTypeAnalyzer analyzer;

    setUp(() {
      analyzer = EnhancedDoughTypeAnalyzer();
    });

    test('특수 시럽/지방 타입별 특성 데이터베이스 테스트', () {
      // 시럽 효과 조회 테스트
      final syrupEffect = IngredientEffectsDatabase.getSyrupEffect('물엿');
      expect(syrupEffect, isNotNull);
      expect(syrupEffect!['glutenImpact'], 0.85);
      expect(syrupEffect['fermentationBoost'], 1.15);

      // 지방 효과 조회 테스트
      final fatEffect = IngredientEffectsDatabase.getFatEffect('버터');
      expect(fatEffect, isNotNull);
      expect(fatEffect!['glutenTenderness'], 1.25);
      expect(fatEffect['textureEnhancement'], 1.35);

      // 시럽 타입 감지 테스트
      final detectedSyrup = IngredientEffectsDatabase.detectSyrupType('메이플 시럽');
      expect(detectedSyrup, '메이플시럽');

      // 지방 타입 감지 테스트
      final detectedFat = IngredientEffectsDatabase.detectFatEffect('올리브 오일');
      expect(detectedFat, isNotNull);

      // 존재하지 않는 타입 조회 테스트
      final nonExistentSyrup = IngredientEffectsDatabase.getSyrupEffect('없는시럽');
      expect(nonExistentSyrup, isNull);

      final nonExistentFat = IngredientEffectsDatabase.getFatEffect('없는지방');
      expect(nonExistentFat, isNull);
    });

    test('향상된 반도 타입 분석기 팩토리 테스트', () {
      final defaultAnalyzer = EnhancedDoughTypeAnalyzerFactory.createDefault();
      expect(defaultAnalyzer, isNotNull);

      final customAnalyzer = EnhancedDoughTypeAnalyzerFactory.createCustom();
      expect(customAnalyzer, isNotNull);
    });

    test('기본 반도 타입 분석 테스트', () async {
      // 기본 재료만 있는 레시피로 테스트
      final mockRecipe = _createMockRecipe(
        ingredients: [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 300.0, 'unit': 'g'},
          {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
          {'name': '소금', 'amount': 10.0, 'unit': 'g'},
        ],
      );

      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
        breadType: 'lean',
      );

      expect(result.doughType, isNotNull);
      expect(result.confidence, greaterThan(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.reasoning, isNotEmpty);
      expect(result.recommendations, isNotEmpty);
      expect(result.analyzedAt, isNotNull);
    });

    test('리치 도우 분석 테스트', () async {
      // 설탕과 지방이 많은 리치 도우 레시피
      final mockRecipe = _createMockRecipe(
        ingredients: [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 250.0, 'unit': 'g'},
          {'name': '버터', 'amount': 100.0, 'unit': 'g'},
          {'name': '설탕', 'amount': 50.0, 'unit': 'g'},
          {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
          {'name': '달걀', 'amount': 2.0, 'unit': '개'},
        ],
      );

      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
        breadType: 'rich',
      );

      expect(result.doughType, isNotNull);
      expect(result.reasoning, contains('리치 도우'));
      expect(result.recommendations, contains('믹싱 시간을 늘리고'));
    });

    test('고수분 도우 분석 테스트', () async {
      // 수분 함량이 높은 고수분 도우 레시피
      final mockRecipe = _createMockRecipe(
        ingredients: [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 400.0, 'unit': 'g'}, // 80% 수분
          {'name': '이스트', 'amount': 5.0, 'unit': 'g'},
          {'name': '소금', 'amount': 10.0, 'unit': 'g'},
        ],
      );

      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
        breadType: 'high_hydration',
      );

      expect(result.doughType, isNotNull);
      expect(result.reasoning, contains('고수분'));
      expect(result.recommendations, contains('강력한 믹서'));
    });

    test('시럽 효과 반영 분석 테스트', () async {
      // 시럽이 포함된 레시피
      final mockRecipe = _createMockRecipe(
        ingredients: [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 300.0, 'unit': 'g'},
          {'name': '꿀', 'amount': 50.0, 'unit': 'g'}, // 10% 꿀
          {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
          {'name': '소금', 'amount': 10.0, 'unit': 'g'},
        ],
      );

      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
        breadType: 'with_syrup',
      );

      expect(result.doughType, isNotNull);
      expect(result.analysisData['effectsApplied'], isNotNull);
      expect(result.reasoning, anyElement(contains('시럽')));
    });

    test('환경 요인 고려 분석 테스트', () async {
      final mockRecipe = _createMockRecipe(
        ingredients: [
          {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
          {'name': '물', 'amount': 300.0, 'unit': 'g'},
          {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
        ],
      );

      // 낮은 온도 환경
      final coldEnvironmentUserData = _createMockUserData(temperature: 15.0);

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: coldEnvironmentUserData,
        recipe: mockRecipe,
        breadType: 'cold_environment',
      );

      expect(result.doughType, isNotNull);
      expect(result.recommendations, anyElement(contains('온도')));
    });

    test('분석 데이터 구조 검증', () async {
      final mockRecipe = _createMockRecipe();
      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
      );

      // 분석 데이터 구조 검증
      expect(result.analysisData, isNotNull);
      expect(result.analysisData['ingredientAnalysis'], isNotNull);
      expect(result.analysisData['effectsApplied'], isNotNull);
      expect(result.analysisData['doughTypeFactors'], isNotNull);
      expect(result.analysisData['environmentalFactors'], isNotNull);

      // 신뢰도 범위 검증
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));

      // 타임스탬프 검증
      expect(result.analyzedAt, isNotNull);
      expect(
          result.analyzedAt.isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
      expect(
          result.analyzedAt
              .isAfter(DateTime.now().subtract(Duration(minutes: 1))),
          isTrue);
    });

    test('에러 처리 테스트', () async {
      // 빈 재료 리스트로 테스트
      final mockRecipe = _createMockRecipe(ingredients: []);
      final mockUserData = _createMockUserData();

      final result = await analyzer.analyzeWithIngredientAnalysis(
        userData: mockUserData,
        recipe: mockRecipe,
      );

      // 에러 상황에서도 기본 결과가 반환되어야 함
      expect(result.doughType, isNotNull);
      expect(result.confidence, greaterThan(0.0));
      expect(result.reasoning, isNotEmpty);
    });

    test('다양한 빵 타입 분석 테스트', () async {
      final testCases = [
        {
          'breadType': 'lean',
          'ingredients': [
            {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
            {'name': '물', 'amount': 300.0, 'unit': 'g'},
            {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
          ],
          'expectedType': DoughType.lean,
        },
        {
          'breadType': 'rich',
          'ingredients': [
            {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
            {'name': '물', 'amount': 250.0, 'unit': 'g'},
            {'name': '버터', 'amount': 100.0, 'unit': 'g'},
            {'name': '설탕', 'amount': 50.0, 'unit': 'g'},
          ],
          'expectedType': DoughType.rich,
        },
        {
          'breadType': 'high_hydration',
          'ingredients': [
            {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
            {'name': '물', 'amount': 400.0, 'unit': 'g'},
            {'name': '이스트', 'amount': 5.0, 'unit': 'g'},
          ],
          'expectedType': DoughType.highHydration,
        },
      ];

      for (final testCase in testCases) {
        final mockRecipe = _createMockRecipe(
          ingredients: testCase['ingredients'] as List<Map<String, dynamic>>,
        );
        final mockUserData = _createMockUserData();

        final result = await analyzer.analyzeWithIngredientAnalysis(
          userData: mockUserData,
          recipe: mockRecipe,
          breadType: testCase['breadType'] as String,
        );

        expect(result.doughType, isNotNull,
            reason: '${testCase['breadType']} 분석 실패');
        expect(result.confidence > 0, isTrue,
            reason: '${testCase['breadType']} 신뢰도 0');
      }
    });
  });
}

// 모의 데이터 생성 헬퍼 함수들
UnifiedRecipe _createMockRecipe({
  List<Map<String, dynamic>>? ingredients,
  String title = '테스트 레시피',
}) {
  final defaultIngredients = ingredients ??
      [
        {'name': '밀가루', 'amount': 500.0, 'unit': 'g'},
        {'name': '물', 'amount': 300.0, 'unit': 'g'},
        {'name': '이스트', 'amount': 7.0, 'unit': 'g'},
      ];

  // 실제 테스트에서는 UnifiedRecipe 대신 간단한 모의 객체 사용
  // 여기서는 임시로 기본 생성자 사용
  return UnifiedRecipe(
    id: 'test_recipe_${DateTime.now().millisecondsSinceEpoch}',
    title: title,
    ingredients: defaultIngredients
        .map((ing) => UnifiedIngredient(
              id: 'ing_${ing['name']}',
              name: ing['name'] as String,
              amount: ing['amount'] as double,
              unit: ing['unit'] as String,
              properties: {},
            ))
        .toList(),
    processes: [],
    equipment: EquipmentConfig.defaultConfig(),
    metadata: RecipeMetadata.empty(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

BreadUserData _createMockUserData({
  double temperature = 25.0,
  double humidity = 60.0,
  String difficultyPreference = 'intermediate',
}) {
  return BreadUserData(
    userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
    environment: BreadUserEnvironment(
      temperature: temperature,
      humidity: humidity,
      fermentationMethod: 'roomTemperature',
      ovenType: 'convection',
    ),
    equipment: BreadUserEquipment(
      settings: {'mixerType': 'home', 'ovenType': 'convection'},
    ),
    preferences: BreadUserPreferences(
      preferences: {
        'difficulty': difficultyPreference,
        'timePreference': 'normal',
        'automationLevel': 'medium',
      },
    ),
  );
}
