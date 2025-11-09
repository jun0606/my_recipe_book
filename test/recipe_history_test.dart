/// 레시피 히스토리 시스템 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/recipe_history.dart';
import 'package:my_recipe_book/services/recipe_history_service.dart';

void main() {
  group('RecipeHistory 모델 테스트', () {
    test('RecipeHistory 생성 및 JSON 변환', () {
      final beforeStatus = ProductStatusHistory(
        textureProfile: '촉촉함',
        flavorProfile: ['고소함'],
        appearanceProfile: '연한 갈색',
        textureScore: 0.7,
        flavorScore: 0.6,
        appearanceScore: 0.8,
        confidenceLevel: 0.8,
      );

      final afterStatus = ProductStatusHistory(
        textureProfile: '촉촉하고 부드러움',
        flavorProfile: ['고소하고 달콤함'],
        appearanceProfile: '균일한 갈색',
        textureScore: 0.9,
        flavorScore: 0.8,
        appearanceScore: 0.9,
        confidenceLevel: 0.9,
      );

      final history = RecipeHistory.create(
        recipeTitle: '테스트 식빵',
        recipeCategory: '식빵',
        type: RecipeHistoryType.optimization,
        originalIngredients: {'flour': 300, 'water': 200},
        optimizedIngredients: {'flour': 300, 'water': 210},
        environmentalConditions: {
          'temperature': 26.0,
          'humidity': 60.0,
          'altitude': 0.0
        },
        beforeStatus: beforeStatus,
        afterStatus: afterStatus,
        optimizationNotes: ['수분량 증가로 촉촉함 개선'],
      );

      // JSON 변환 테스트
      final json = history.toJson();
      final restored = RecipeHistory.fromJson(json);

      expect(restored.recipeTitle, equals('테스트 식빵'));
      expect(restored.type, equals(RecipeHistoryType.optimization));
      expect(restored.isSuccessfulOptimization, isTrue);
      expect(restored.mainImprovements, contains('식감'));
    });

    test('개선 점수 계산', () {
      final beforeStatus = ProductStatusHistory(
        textureProfile: '보통',
        flavorProfile: ['기본'],
        appearanceProfile: '연한',
        textureScore: 0.6,
        flavorScore: 0.6,
        appearanceScore: 0.6,
        confidenceLevel: 0.7,
      );

      final afterStatus = ProductStatusHistory(
        textureProfile: '우수',
        flavorProfile: ['풍부'],
        appearanceProfile: '완벽',
        textureScore: 0.9,
        flavorScore: 0.8,
        appearanceScore: 0.9,
        confidenceLevel: 0.9,
      );

      final history = RecipeHistory.create(
        recipeTitle: '개선 테스트',
        recipeCategory: '테스트',
        type: RecipeHistoryType.optimization,
        originalIngredients: {},
        optimizedIngredients: {},
        environmentalConditions: {},
        beforeStatus: beforeStatus,
        afterStatus: afterStatus,
        optimizationNotes: [],
      );

      expect(history.improvementScore, greaterThan(0.1));
      expect(history.isSuccessfulOptimization, isTrue);
    });
  });

  group('RecipeHistoryStats 테스트', () {
    test('통계 생성', () {
      final histories = <RecipeHistory>[];

      // 성공적인 최적화 2개
      for (int i = 0; i < 2; i++) {
        histories.add(RecipeHistory.create(
          recipeTitle: '성공 레시피 $i',
          recipeCategory: '식빵',
          type: RecipeHistoryType.optimization,
          originalIngredients: {},
          optimizedIngredients: {},
          environmentalConditions: {'temperature': 26.0, 'humidity': 60.0},
          beforeStatus: ProductStatusHistory(
            textureProfile: '보통',
            flavorProfile: ['기본'],
            appearanceProfile: '보통',
            textureScore: 0.6,
            flavorScore: 0.6,
            appearanceScore: 0.6,
            confidenceLevel: 0.7,
          ),
          afterStatus: ProductStatusHistory(
            textureProfile: '우수',
            flavorProfile: ['풍부'],
            appearanceProfile: '우수',
            textureScore: 0.9,
            flavorScore: 0.8,
            appearanceScore: 0.8,
            confidenceLevel: 0.9,
          ),
          optimizationNotes: [],
        ));
      }

      // 실패한 최적화 1개
      histories.add(RecipeHistory.create(
        recipeTitle: '실패 레시피',
        recipeCategory: '케이크',
        type: RecipeHistoryType.reverseRecipe,
        originalIngredients: {},
        optimizedIngredients: {},
        environmentalConditions: {'temperature': 24.0, 'humidity': 70.0},
        beforeStatus: ProductStatusHistory(
          textureProfile: '보통',
          flavorProfile: ['기본'],
          appearanceProfile: '보통',
          textureScore: 0.7,
          flavorScore: 0.7,
          appearanceScore: 0.7,
          confidenceLevel: 0.7,
        ),
        afterStatus: ProductStatusHistory(
          textureProfile: '보통',
          flavorProfile: ['기본'],
          appearanceProfile: '보통',
          textureScore: 0.6,
          flavorScore: 0.6,
          appearanceScore: 0.6,
          confidenceLevel: 0.6,
        ),
        optimizationNotes: [],
      ));

      final stats = RecipeHistoryStats.fromHistories(histories);

      expect(stats.totalOptimizations, equals(3));
      expect(stats.successfulOptimizations, equals(2));
      expect(stats.successRate, closeTo(0.67, 0.01));
      expect(stats.categoryDistribution['식빵'], equals(2));
      expect(stats.categoryDistribution['케이크'], equals(1));
    });
  });

  group('RecipeHistoryFilter 테스트', () {
    test('필터링 동작', () {
      final history1 = RecipeHistory.create(
        recipeTitle: '식빵',
        recipeCategory: '식빵',
        type: RecipeHistoryType.optimization,
        originalIngredients: {},
        optimizedIngredients: {},
        environmentalConditions: {},
        beforeStatus: ProductStatusHistory(
          textureProfile: '',
          flavorProfile: [],
          appearanceProfile: '',
          textureScore: 0.6,
          flavorScore: 0.6,
          appearanceScore: 0.6,
          confidenceLevel: 0.7,
        ),
        afterStatus: ProductStatusHistory(
          textureProfile: '',
          flavorProfile: [],
          appearanceProfile: '',
          textureScore: 0.8,
          flavorScore: 0.8,
          appearanceScore: 0.8,
          confidenceLevel: 0.8,
        ),
        optimizationNotes: [],
      );

      final history2 = RecipeHistory.create(
        recipeTitle: '케이크',
        recipeCategory: '케이크',
        type: RecipeHistoryType.reverseRecipe,
        originalIngredients: {},
        optimizedIngredients: {},
        environmentalConditions: {},
        beforeStatus: ProductStatusHistory(
          textureProfile: '',
          flavorProfile: [],
          appearanceProfile: '',
          textureScore: 0.5,
          flavorScore: 0.5,
          appearanceScore: 0.5,
          confidenceLevel: 0.6,
        ),
        afterStatus: ProductStatusHistory(
          textureProfile: '',
          flavorProfile: [],
          appearanceProfile: '',
          textureScore: 0.5,
          flavorScore: 0.5,
          appearanceScore: 0.5,
          confidenceLevel: 0.6,
        ),
        optimizationNotes: [],
      );

      // 카테고리 필터
      final categoryFilter = RecipeHistoryFilter(category: '식빵');
      expect(categoryFilter.matches(history1), isTrue);
      expect(categoryFilter.matches(history2), isFalse);

      // 타입 필터
      final typeFilter =
          RecipeHistoryFilter(type: RecipeHistoryType.optimization);
      expect(typeFilter.matches(history1), isTrue);
      expect(typeFilter.matches(history2), isFalse);

      // 성공만 필터
      final successFilter = RecipeHistoryFilter(successfulOnly: true);
      expect(successFilter.matches(history1), isTrue);
      expect(successFilter.matches(history2), isFalse);
    });
  });
}
