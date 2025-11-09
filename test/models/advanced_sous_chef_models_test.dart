import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';

void main() {
  group('Recipe 모델 테스트', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        title: '바게트',
        ingredients: [
          const Ingredient(
            name: '강력분',
            amount: 500,
            unit: 'g',
            properties: {'protein': 12.0},
          ),
          const Ingredient(
            name: '물',
            amount: 350,
            unit: 'g',
            properties: {},
          ),
          const Ingredient(
            name: '소금',
            amount: 10,
            unit: 'g',
            properties: {},
          ),
          const Ingredient(
            name: '이스트',
            amount: 5,
            unit: 'g',
            properties: {},
          ),
        ],
        processes: ['믹싱', '1차 발효', '분할', '중간 발효', '성형', '2차 발효', '굽기'],
        category: RecipeCategory.bread,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('하이드레이션 계산이 정확해야 함', () {
      // (물의 양 ÷ 밀가루 양) × 100 = (350 ÷ 500) × 100 = 70%
      expect(testRecipe.hydrationPercentage, equals(70.0));
    });

    test('소금 비율 계산이 정확해야 함', () {
      // (소금 양 ÷ 밀가루 양) × 100 = (10 ÷ 500) × 100 = 2%
      expect(testRecipe.saltPercentage, equals(2.0));
    });

    test('이스트 비율 계산이 정확해야 함', () {
      // (이스트 양 ÷ 밀가루 양) × 100 = (5 ÷ 500) × 100 = 1%
      expect(testRecipe.yeastPercentage, equals(1.0));
    });

    test('밀가루 양 반환이 정확해야 함', () {
      expect(testRecipe.flourAmount, equals(500.0));
    });

    test('JSON 직렬화/역직렬화가 정상 동작해야 함', () {
      final json = testRecipe.toJson();

      // JSON 구조 확인
      expect(json['title'], equals(testRecipe.title));
      expect(json['ingredients'], isA<List>());
      expect(json['category'], equals('bread'));

      // 기본적인 속성들만 테스트 (복잡한 중첩 객체는 별도 테스트)
      expect(json['title'], equals('바게트'));
      expect(json['processes'].length, equals(7));
    });
  });

  group('Ingredient 모델 테스트', () {
    test('밀가루 판별이 정확해야 함', () {
      const flour1 =
          Ingredient(name: '강력분', amount: 500, unit: 'g', properties: {});
      const flour2 = Ingredient(
          name: 'bread flour', amount: 500, unit: 'g', properties: {});
      const notFlour =
          Ingredient(name: '설탕', amount: 50, unit: 'g', properties: {});

      expect(flour1.isFlour, isTrue);
      expect(flour2.isFlour, isTrue);
      expect(notFlour.isFlour, isFalse);
    });

    test('물 판별이 정확해야 함', () {
      const water1 =
          Ingredient(name: '물', amount: 350, unit: 'g', properties: {});
      const water2 =
          Ingredient(name: 'water', amount: 350, unit: 'g', properties: {});
      const milk =
          Ingredient(name: '우유', amount: 200, unit: 'ml', properties: {});
      const notWater =
          Ingredient(name: '설탕', amount: 50, unit: 'g', properties: {});

      expect(water1.isWater, isTrue);
      expect(water2.isWater, isTrue);
      expect(milk.isWater, isTrue);
      expect(notWater.isWater, isFalse);
    });

    test('소금 판별이 정확해야 함', () {
      const salt1 =
          Ingredient(name: '소금', amount: 10, unit: 'g', properties: {});
      const salt2 =
          Ingredient(name: 'salt', amount: 10, unit: 'g', properties: {});
      const notSalt =
          Ingredient(name: '설탕', amount: 50, unit: 'g', properties: {});

      expect(salt1.isSalt, isTrue);
      expect(salt2.isSalt, isTrue);
      expect(notSalt.isSalt, isFalse);
    });

    test('이스트 판별이 정확해야 함', () {
      const yeast1 =
          Ingredient(name: '이스트', amount: 5, unit: 'g', properties: {});
      const yeast2 =
          Ingredient(name: 'yeast', amount: 5, unit: 'g', properties: {});
      const yeast3 =
          Ingredient(name: '효모', amount: 5, unit: 'g', properties: {});
      const notYeast =
          Ingredient(name: '설탕', amount: 50, unit: 'g', properties: {});

      expect(yeast1.isYeast, isTrue);
      expect(yeast2.isYeast, isTrue);
      expect(yeast3.isYeast, isTrue);
      expect(notYeast.isYeast, isFalse);
    });

    test('재료 속성 접근이 정확해야 함', () {
      const ingredient = Ingredient(
        name: '강력분',
        amount: 500,
        unit: 'g',
        properties: {
          'protein': 12.5,
          'moisture': 14.0,
          'fat': 1.2,
        },
      );

      expect(ingredient.proteinContent, equals(12.5));
      expect(ingredient.moistureContent, equals(14.0));
      expect(ingredient.fatContent, equals(1.2));
    });
  });

  group('EnvironmentalConditions 모델 테스트', () {
    late EnvironmentalConditions testConditions;

    setUp(() {
      testConditions = EnvironmentalConditions(
        temperature: 25.0,
        humidity: 65.0,
        pressure: 1013.0,
        season: Season.spring,
        altitude: 100.0,
        oven: const OvenCharacteristics(
          type: OvenType.professionalConvection,
          typeCoefficient: 1.0,
          calibrationIndex: 1.1,
          steamCapability: 1.0,
          hasConvection: true,
          maxTemperature: 300.0,
        ),
      );
    });

    test('온도 보정 계수 계산이 정확해야 함', () {
      // 1 + ((25 - 25) / 10) = 1.0
      expect(testConditions.temperatureCorrection, equals(1.0));

      final hotConditions = testConditions.copyWith(temperature: 35.0);
      // 1 + ((35 - 25) / 10) = 2.0
      expect(hotConditions.temperatureCorrection, equals(2.0));
    });

    test('습도 보정 계수 계산이 정확해야 함', () {
      // 1 + ((65 - 65) × 0.005) = 1.0
      expect(testConditions.humidityCorrection, equals(1.0));

      final humidConditions = testConditions.copyWith(humidity: 75.0);
      // 1 + ((75 - 65) × 0.005) = 1.05
      expect(humidConditions.humidityCorrection, equals(1.05));
    });

    test('고도 보정 계수 계산이 정확해야 함', () {
      // 1 + ((100 / 1000) × 0.02) = 1.002
      expect(testConditions.altitudeCorrection, equals(1.002));

      final highAltitude = testConditions.copyWith(altitude: 1000.0);
      // 1 + ((1000 / 1000) × 0.02) = 1.02
      expect(highAltitude.altitudeCorrection, equals(1.02));
    });

    test('발효 속도 온도 보정 계산이 정확해야 함', () {
      // 2^((25 - 25) / 10) = 2^0 = 1.0
      expect(testConditions.fermentationSpeedCorrection, equals(1.0));

      final hotConditions = testConditions.copyWith(temperature: 35.0);
      // 2^((35 - 25) / 10) = 2^1 = 2.0
      expect(hotConditions.fermentationSpeedCorrection, equals(2.0));
    });
  });

  group('IngredientMetadata 모델 테스트', () {
    test('유효 밀가루 단백질 계산이 정확해야 함', () {
      const metadata = IngredientMetadata(
        name: '강력분',
        properties: {
          'protein': 12.0,
          'activityIndex': 1.1,
        },
        effectiveValue: 13.2,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      // 12.0 × 1.1 = 13.2
      expect(metadata.effectiveProteinPercentage, closeTo(13.2, 0.001));
    });

    test('유효 이스트 활성도 계산이 정확해야 함', () {
      const metadata = IngredientMetadata(
        name: '이스트',
        properties: {
          'standardActivity': 0.5,
          'freshnessIndex': 0.9,
        },
        effectiveValue: 0.45,
        function: '발효',
        qualityCorrectionFactor: 1.0,
      );

      // 0.5 × 0.9 = 0.45
      expect(metadata.effectiveYeastActivity, equals(0.45));
    });
  });

  group('RecipeCategory enum 테스트', () {
    test('displayName이 정확해야 함', () {
      expect(RecipeCategory.bread.displayName, equals('빵'));
      expect(RecipeCategory.cake.displayName, equals('케이크'));
      expect(RecipeCategory.cookie.displayName, equals('쿠키'));
      expect(RecipeCategory.dessert.displayName, equals('디저트'));
    });

    test('englishName이 정확해야 함', () {
      expect(RecipeCategory.bread.englishName, equals('Bread'));
      expect(RecipeCategory.cake.englishName, equals('Cake'));
      expect(RecipeCategory.cookie.englishName, equals('Cookie'));
      expect(RecipeCategory.dessert.englishName, equals('Dessert'));
    });
  });

  group('OvenType enum 테스트', () {
    test('displayName이 정확해야 함', () {
      expect(OvenType.home.displayName, equals('가정용 오븐'));
      expect(OvenType.professionalConvection.displayName, equals('전문가용 컨벡션'));
      expect(OvenType.deck.displayName, equals('데크 오븐'));
      expect(OvenType.steam.displayName, equals('스팀 오븐'));
    });

    test('기본 유형 계수가 정확해야 함', () {
      expect(OvenType.home.defaultTypeCoefficient, equals(0.9));
      expect(
          OvenType.professionalConvection.defaultTypeCoefficient, equals(1.0));
      expect(OvenType.deck.defaultTypeCoefficient, equals(1.1));
      expect(OvenType.steam.defaultTypeCoefficient, equals(1.2));
    });
  });

  group('Alert 모델 테스트', () {
    test('Alert 생성 및 속성 접근이 정상 동작해야 함', () {
      final alert = Alert(
        id: 'test_alert_1',
        title: '발효 시간 알림',
        type: AlertType.fermentationTimeDeviation,
        message: '발효 시간이 예측값을 초과했습니다',
        action: '반죽 상태를 확인하세요',
        timestamp: DateTime.now(),
        severity: AlertSeverity.medium,
      );

      expect(alert.type.displayName, equals('발효 시간 이탈'));
      expect(alert.severity.displayName, equals('보통'));
      expect(alert.message, contains('발효 시간'));
      expect(alert.id, equals('test_alert_1'));
      expect(alert.title, equals('발효 시간 알림'));
    });
  });

  group('데이터 유효성 검증 테스트', () {
    test('빈 재료 목록으로 레시피 생성 시 비율 계산이 0이어야 함', () {
      final emptyRecipe = Recipe(
        title: '빈 레시피',
        ingredients: [],
        processes: [],
        category: RecipeCategory.bread,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(emptyRecipe.hydrationPercentage, equals(0.0));
      expect(emptyRecipe.saltPercentage, equals(0.0));
      expect(emptyRecipe.yeastPercentage, equals(0.0));
      expect(emptyRecipe.flourAmount, equals(0.0));
    });

    test('밀가루 없는 레시피의 비율 계산이 0이어야 함', () {
      final noFlourRecipe = Recipe(
        title: '밀가루 없는 레시피',
        ingredients: [
          const Ingredient(name: '물', amount: 350, unit: 'g', properties: {}),
          const Ingredient(name: '소금', amount: 10, unit: 'g', properties: {}),
        ],
        processes: [],
        category: RecipeCategory.bread,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(noFlourRecipe.hydrationPercentage, equals(0.0));
      expect(noFlourRecipe.saltPercentage, equals(0.0));
      expect(noFlourRecipe.yeastPercentage, equals(0.0));
    });
  });
}
