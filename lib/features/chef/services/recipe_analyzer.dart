// 레시피 모듈 분석기
// 레시피 데이터를 분석하여 적절한 모듈을 선택하는 서비스

import 'dart:convert';
import '../../../data/module_keywords.dart';

class RecipeAnalyzer {
  /// 레시피 데이터를 분석하여 가장 적합한 모듈을 선택
  static String analyzeRecipeModule(Map<String, dynamic> recipeData) {
    return _analyzeWithKeywords(recipeData);
  }

  /// 키워드 기반 모듈 분석
  static String _analyzeWithKeywords(Map<String, dynamic> recipeData) {
    final title = (recipeData['title'] as String?)?.toLowerCase() ?? '';

    List<dynamic> ingredients = [];
    final ingredientsData = recipeData['ingredients'];
    if (ingredientsData is String) {
      try {
        ingredients = jsonDecode(ingredientsData) as List<dynamic>;
      } catch (e) {
        ingredients = [];
      }
    } else if (ingredientsData is List) {
      ingredients = ingredientsData;
    }

    final instructions = recipeData['instructions'] as String? ?? '';

    final scores = <String, double>{};

    for (final entry in ModuleKeywords.data.entries) {
      final moduleName = entry.key;
      final keywords = entry.value;
      double score = 0.0;

      final titleKeywords = keywords['title_keywords'] ?? [];
      for (final keyword in titleKeywords) {
        if (title.contains(keyword.toLowerCase())) {
          score += 3.0;
        }
      }

      final ingredientKeywords = keywords['ingredient_keywords'] ?? [];
      for (final ingredient in ingredients) {
        final ingredientName = ingredient.toString().toLowerCase();
        for (final keyword in ingredientKeywords) {
          if (ingredientName.contains(keyword.toLowerCase())) {
            score += 2.0;
          }
        }
      }

      final instructionKeywords = keywords['instruction_keywords'] ?? [];
      for (final keyword in instructionKeywords) {
        if (instructions.toLowerCase().contains(keyword.toLowerCase())) {
          score += 1.0;
        }
      }

      scores[moduleName] = score;
    }

    if (scores.isNotEmpty) {
      final bestModule =
          scores.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (bestModule.value > 0) {
        return bestModule.key;
      }
    }

    return 'bread';
  }

  /// 모듈 선택 근거 설명
  static Map<String, dynamic> explainModuleSelection(
    Map<String, dynamic> recipeData,
    String selectedModule,
  ) {
    final title = (recipeData['title'] as String?)?.toLowerCase() ?? '';
    final instructions = recipeData['instructions'] as String? ?? '';

    final reasons = <String>[];
    final keywords = ModuleKeywords.data[selectedModule];

    if (keywords != null) {
      final titleKeywords = keywords['title_keywords'] as List<String>? ?? [];
      final instructionKeywords =
          keywords['instruction_keywords'] as List<String>? ?? [];

      for (final keyword in titleKeywords) {
        if (title.contains(keyword.toLowerCase())) {
          reasons.add('제목에 "$keyword" 키워드가 포함됨');
        }
      }

      for (final keyword in instructionKeywords) {
        if (instructions.toLowerCase().contains(keyword.toLowerCase())) {
          reasons.add('조리법에 "$keyword" 키워드가 포함됨');
        }
      }
    }

    return {
      'selectedModule': selectedModule,
      'reasons': reasons,
      'confidence': reasons.length > 0 ? '높음' : '낮음',
    };
  }

  /// 사용 가능한 모듈 목록 반환
  static List<String> getAvailableModules() {
    return ModuleKeywords.data.keys.toList();
  }

  /// 모듈별 키워드 정보 반환
  static Map<String, dynamic>? getModuleKeywords(String moduleName) {
    return ModuleKeywords.data[moduleName];
  }
}
