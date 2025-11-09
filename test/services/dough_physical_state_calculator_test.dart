import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/dough_physical_state.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/services/dough_physical_state_calculator.dart';

void main() {
  group('DoughPhysicalStateCalculator Tests', () {
    group('글루텐 강도 지수 계산 테스트', () {
      test('표준 빵 레시피의 글루텐 강도 지수가 정확해야 함', () {
        // Given
        const flourProtein = 13.0; // 강력분
        const salt = 2.0;
        const fat = 5.0;
        const sugar = 3.0;

        // When
        final index = DoughPhysicalStateCalculator.calculateGlutenStrengthIndex(
          flourProteinPercentage: flourProtein,
          saltPercentage: salt,
          fatPercentage: fat,
          sugarPercentage: sugar,
        );

        // Then
        // (13.0 × 1.2) + (2.0 × 0.7) - (5.0 × 0.5) - (3.0 × 0.3)
        // = 15.6 + 1.4 - 2.5 - 0.9 = 13.6 → 10.0으로 클램핑
        expect(index, equals(10.0));
      });

      test('저단백 케이크 레시피의 글루텐 강도 지수가 정확해야 함', () {
        // Given
        const flourProtein = 8.5; // 박력분
        const salt = 0.5;
        const fat = 25.0; // 높은 지방
        const sugar = 30.0; // 높은 설탕

        // When
        final index = DoughPhysicalStateCalculator.calculateGlutenStrengthIndex(
          flourProteinPercentage: flourProtein,
          saltPercentage: salt,
          fatPercentage: fat,
          sugarPercentage: sugar,
        );

        // Then
        // (8.5 × 1.2) + (0.5 × 0.7) - (25.0 × 0.5) - (30.0 × 0.3)
        // = 10.2 + 0.35 - 12.5 - 9.0 = -10.95 → 0.0으로 클램핑
        expect(index, equals(0.0));
      });

      test('중간 강도 반죽의 글루텐 강도 지수가 정확해야 함', () {
        // Given
        const flourProtein = 11.0; // 중력분
        const salt = 1.8;
        const fat = 10.0;
        const sugar = 8.0;

        // When
        final index = DoughPhysicalStateCalculator.calculateGlutenStrengthIndex(
          flourProteinPercentage: flourProtein,
          saltPercentage: salt,
          fatPercentage: fat,
          sugarPercentage: sugar,
        );

        // Then
        // (11.0 × 1.2) + (1.8 × 0.7) - (10.0 × 0.5) - (8.0 × 0.3)
        // = 13.2 + 1.26 - 5.0 - 2.4 = 7.06
        expect(index, closeTo(7.06, 0.01));
      });
    });

    group('품질 등급 판정 테스트', () {
      test('우수 등급 판정이 정확해야 함', () {
        // Given
        const index = 9.0;

        // When
        final quality = DoughQuality.fromGlutenStrengthIndex(index);

        // Then
        expect(quality, equals(DoughQuality.excellent));
        expect(quality.displayName, equals('우수'));
      });

      test('양호 등급 판정이 정확해야 함', () {
        // Given
        const index = 7.0;

        // When
        final quality = DoughQuality.fromGlutenStrengthIndex(index);

        // Then
        expect(quality, equals(DoughQuality.good));
        expect(quality.displayName, equals('양호'));
      });

      test('보통 등급 판정이 정확해야 함', () {
        // Given
        const index = 5.0;

        // When
        final quality = DoughQuality.fromGlutenStrengthIndex(index);

        // Then
        expect(quality, equals(DoughQuality.fair));
        expect(quality.displayName, equals('보통'));
      });

      test('개선필요 등급 판정이 정확해야 함', () {
        // Given
        const index = 2.0;

        // When
        final quality = DoughQuality.fromGlutenStrengthIndex(index);

        // Then
        expect(quality, equals(DoughQuality.poor));
        expect(quality.displayName, equals('개선필요'));
      });
    });

    group('레시피 분석 테스트', () {
      test('표준 빵 레시피 분석이 정확해야 함', () {
        // Given
        final recipe = Recipe(
          id: 1,
          title: '기본 식빵',
          category: 'bread',
          ingredients: [
            Ingredient(name: '강력분', amount: 500.0, unit: 'g'),
            Ingredient(name: '물', amount: 320.0, unit: 'g'),
            Ingredient(name: '소금', amount: 10.0, unit: 'g'),
            Ingredient(name: '설탕', amount: 15.0, unit: 'g'),
            Ingredient(name: '버터', amount: 25.0, unit: 'g'),
          ],
          instructions: ['반죽하기', '발효하기', '굽기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(
            state.ingredientRatios.flourProteinPercentage, equals(13.0)); // 강력분
        expect(
            state.ingredientRatios.saltPercentage, equals(2.0)); // 10/500 * 100
        expect(
            state.ingredientRatios.fatPercentage, equals(5.0)); // 25/500 * 100
        expect(state.ingredientRatios.sugarPercentage,
            equals(3.0)); // 15/500 * 100
        expect(state.ingredientRatios.hydrationPercentage,
            equals(64.0)); // 320/500 * 100
        expect(state.quality, equals(DoughQuality.excellent));
        expect(state.suggestions, isNotEmpty);
      });

      test('케이크 레시피 분석이 정확해야 함', () {
        // Given
        final recipe = Recipe(
          id: 2,
          title: '스펀지 케이크',
          category: 'cake',
          ingredients: [
            Ingredient(name: '박력분', amount: 200.0, unit: 'g'),
            Ingredient(name: '설탕', amount: 150.0, unit: 'g'),
            Ingredient(name: '버터', amount: 100.0, unit: 'g'),
            Ingredient(name: '우유', amount: 80.0, unit: 'ml'),
            Ingredient(name: '소금', amount: 2.0, unit: 'g'),
          ],
          instructions: ['재료 섞기', '굽기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(
            state.ingredientRatios.flourProteinPercentage, equals(8.5)); // 박력분
        expect(
            state.ingredientRatios.saltPercentage, equals(1.0)); // 2/200 * 100
        expect(state.ingredientRatios.fatPercentage,
            equals(50.0)); // 100/200 * 100
        expect(state.ingredientRatios.sugarPercentage,
            equals(75.0)); // 150/200 * 100
        expect(state.ingredientRatios.hydrationPercentage,
            equals(40.0)); // 80/200 * 100
        expect(state.quality, equals(DoughQuality.poor));
        expect(state.suggestions, isNotEmpty);
      });

      test('밀가루가 없는 레시피는 모든 비율이 0이어야 함', () {
        // Given
        final recipe = Recipe(
          id: 3,
          title: '과일 샐러드',
          category: 'dessert',
          ingredients: [
            Ingredient(name: '사과', amount: 200.0, unit: 'g'),
            Ingredient(name: '바나나', amount: 150.0, unit: 'g'),
          ],
          instructions: ['과일 썰기', '섞기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(state.ingredientRatios.flourProteinPercentage, equals(0.0));
        expect(state.ingredientRatios.saltPercentage, equals(0.0));
        expect(state.ingredientRatios.fatPercentage, equals(0.0));
        expect(state.ingredientRatios.sugarPercentage, equals(0.0));
        expect(state.ingredientRatios.hydrationPercentage, equals(0.0));
        expect(state.glutenStrengthIndex, equals(0.0));
        expect(state.quality, equals(DoughQuality.poor));
      });
    });

    group('조정 제안 생성 테스트', () {
      test('글루텐 강도가 낮은 경우 적절한 제안이 생성되어야 함', () {
        // Given
        final recipe = Recipe(
          id: 4,
          title: '약한 반죽',
          category: 'bread',
          ingredients: [
            Ingredient(name: '박력분', amount: 500.0, unit: 'g'), // 낮은 단백질
            Ingredient(name: '물', amount: 300.0, unit: 'g'),
            Ingredient(name: '소금', amount: 5.0, unit: 'g'), // 낮은 소금
            Ingredient(name: '버터', amount: 100.0, unit: 'g'), // 높은 지방
            Ingredient(name: '설탕', amount: 150.0, unit: 'g'), // 높은 설탕
          ],
          instructions: ['반죽하기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(state.glutenStrengthIndex, lessThan(4.0));
        expect(state.quality, equals(DoughQuality.poor));

        final suggestionTypes = state.suggestions.map((s) => s.type).toSet();
        expect(suggestionTypes, contains(AdjustmentType.protein));
        expect(suggestionTypes, contains(AdjustmentType.salt));
        expect(suggestionTypes, contains(AdjustmentType.fat));
        expect(suggestionTypes, contains(AdjustmentType.sugar));
      });

      test('수분이 부족한 경우 수분 조정 제안이 생성되어야 함', () {
        // Given
        final recipe = Recipe(
          id: 5,
          title: '건조한 반죽',
          category: 'bread',
          ingredients: [
            Ingredient(name: '강력분', amount: 500.0, unit: 'g'),
            Ingredient(name: '물', amount: 200.0, unit: 'g'), // 낮은 수분 (40%)
            Ingredient(name: '소금', amount: 10.0, unit: 'g'),
          ],
          instructions: ['반죽하기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(state.ingredientRatios.hydrationPercentage, equals(40.0));

        final hydrationSuggestions = state.suggestions
            .where((s) => s.type == AdjustmentType.hydration)
            .toList();
        expect(hydrationSuggestions, isNotEmpty);
        expect(hydrationSuggestions.first.message, contains('수분이 부족'));
      });

      test('수분이 과도한 경우 수분 조정 제안이 생성되어야 함', () {
        // Given
        final recipe = Recipe(
          id: 6,
          title: '젖은 반죽',
          category: 'bread',
          ingredients: [
            Ingredient(name: '강력분', amount: 500.0, unit: 'g'),
            Ingredient(name: '물', amount: 450.0, unit: 'g'), // 높은 수분 (90%)
            Ingredient(name: '소금', amount: 10.0, unit: 'g'),
          ],
          instructions: ['반죽하기'],
        );

        // When
        final state = DoughPhysicalStateCalculator.analyzeRecipe(recipe);

        // Then
        expect(state.ingredientRatios.hydrationPercentage, equals(90.0));

        final hydrationSuggestions = state.suggestions
            .where((s) => s.type == AdjustmentType.hydration)
            .toList();
        expect(hydrationSuggestions, isNotEmpty);
        expect(hydrationSuggestions.first.message, contains('수분이 과도'));
      });
    });

    group('데이터 모델 테스트', () {
      test('DoughPhysicalState JSON 직렬화/역직렬화가 정상 동작해야 함', () {
        // Given
        final originalState = DoughPhysicalState(
          glutenStrengthIndex: 7.5,
          quality: DoughQuality.good,
          suggestions: [
            const DoughAdjustmentSuggestion(
              type: AdjustmentType.salt,
              message: '소금을 조정하세요',
              priority: 1,
              expectedEffect: '글루텐 강화',
            ),
          ],
          ingredientRatios: const DoughIngredientRatios(
            flourProteinPercentage: 12.0,
            saltPercentage: 2.0,
            fatPercentage: 5.0,
            sugarPercentage: 3.0,
            hydrationPercentage: 65.0,
          ),
          calculatedAt: DateTime(2024, 1, 1, 12, 0, 0),
        );

        // When
        final json = originalState.toJson();
        final deserializedState = DoughPhysicalState.fromJson(json);

        // Then
        expect(deserializedState.glutenStrengthIndex,
            equals(originalState.glutenStrengthIndex));
        expect(deserializedState.quality, equals(originalState.quality));
        expect(deserializedState.suggestions.length,
            equals(originalState.suggestions.length));
        expect(deserializedState.ingredientRatios,
            equals(originalState.ingredientRatios));
        expect(
            deserializedState.calculatedAt, equals(originalState.calculatedAt));
      });

      test('DoughIngredientRatios copyWith 메서드가 정상 동작해야 함', () {
        // Given
        const original = DoughIngredientRatios(
          flourProteinPercentage: 12.0,
          saltPercentage: 2.0,
          fatPercentage: 5.0,
          sugarPercentage: 3.0,
          hydrationPercentage: 65.0,
        );

        // When
        final modified = original.copyWith(
          saltPercentage: 2.5,
          hydrationPercentage: 70.0,
        );

        // Then
        expect(modified.flourProteinPercentage, equals(12.0)); // 변경되지 않음
        expect(modified.saltPercentage, equals(2.5)); // 변경됨
        expect(modified.fatPercentage, equals(5.0)); // 변경되지 않음
        expect(modified.sugarPercentage, equals(3.0)); // 변경되지 않음
        expect(modified.hydrationPercentage, equals(70.0)); // 변경됨
      });

      test('DoughAdjustmentSuggestion 동등성 비교가 정상 동작해야 함', () {
        // Given
        const suggestion1 = DoughAdjustmentSuggestion(
          type: AdjustmentType.salt,
          message: '소금을 조정하세요',
          priority: 1,
          expectedEffect: '글루텐 강화',
        );

        const suggestion2 = DoughAdjustmentSuggestion(
          type: AdjustmentType.salt,
          message: '소금을 조정하세요',
          priority: 1,
          expectedEffect: '글루텐 강화',
        );

        const suggestion3 = DoughAdjustmentSuggestion(
          type: AdjustmentType.protein,
          message: '단백질을 조정하세요',
          priority: 1,
          expectedEffect: '글루텐 강화',
        );

        // When & Then
        expect(suggestion1, equals(suggestion2));
        expect(suggestion1, isNot(equals(suggestion3)));
        expect(suggestion1.hashCode, equals(suggestion2.hashCode));
        expect(suggestion1.hashCode, isNot(equals(suggestion3.hashCode)));
      });
    });
  });
}
