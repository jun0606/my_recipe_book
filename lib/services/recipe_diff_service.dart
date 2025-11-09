/// 레시피 변경사항 비교 서비스
/// 두 레시피 버전을 비교하여 구체적인 변경사항을 추출합니다.

import '../models/recipe.dart';
import '../models/ingredient.dart';

class RecipeDiffService {
  /// 두 레시피를 비교하여 변경사항을 반환
  static Map<String, dynamic> compareRecipes(
      Recipe oldRecipe, Recipe newRecipe) {
    return {
      'ingredients':
          _compareIngredients(oldRecipe.ingredients, newRecipe.ingredients),
      'instructions':
          _compareInstructions(oldRecipe.instructions, newRecipe.instructions),
      'mixingSteps':
          _compareSteps(oldRecipe.mixingSteps, newRecipe.mixingSteps),
      'fermentationSteps': _compareSteps(
          oldRecipe.fermentationSteps, newRecipe.fermentationSteps),
      'ovenSteps': _compareSteps(oldRecipe.ovenSteps, newRecipe.ovenSteps),
      'basicInfo': _compareBasicInfo(oldRecipe, newRecipe),
    };
  }

  /// 재료 변경사항 비교
  static List<String> _compareIngredients(
      List<Ingredient> oldIngredients, List<Ingredient> newIngredients) {
    final changes = <String>[];

    // 재료명으로 맵 생성
    final oldMap = {for (var ing in oldIngredients) ing.name: ing};
    final newMap = {for (var ing in newIngredients) ing.name: ing};

    // 추가된 재료
    for (final name in newMap.keys) {
      if (!oldMap.containsKey(name)) {
        changes
            .add('재료 추가: ${name} ${newMap[name]!.amount}${newMap[name]!.unit}');
      }
    }

    // 삭제된 재료
    for (final name in oldMap.keys) {
      if (!newMap.containsKey(name)) {
        changes.add('재료 삭제: ${name}');
      }
    }

    // 변경된 재료
    for (final name in oldMap.keys) {
      if (newMap.containsKey(name)) {
        final oldIng = oldMap[name]!;
        final newIng = newMap[name]!;

        if (oldIng.amount != newIng.amount || oldIng.unit != newIng.unit) {
          changes.add(
              '재료 변경: ${name} ${oldIng.amount}${oldIng.unit} → ${newIng.amount}${newIng.unit}');
        }
      }
    }

    return changes;
  }

  /// 조리법 변경사항 비교
  static List<String> _compareInstructions(
      List<Map<String, dynamic>> oldInstructions,
      List<Map<String, dynamic>> newInstructions) {
    final changes = <String>[];

    final maxLength = oldInstructions.length > newInstructions.length
        ? oldInstructions.length
        : newInstructions.length;

    for (int i = 0; i < maxLength; i++) {
      final oldStep = i < oldInstructions.length
          ? oldInstructions[i]['description'] as String?
          : null;
      final newStep = i < newInstructions.length
          ? newInstructions[i]['description'] as String?
          : null;

      if (oldStep == null && newStep != null) {
        changes.add('조리법 추가: ${i + 1}단계 "${newStep}"');
      } else if (oldStep != null && newStep == null) {
        changes.add('조리법 삭제: ${i + 1}단계 "${oldStep}"');
      } else if (oldStep != newStep) {
        changes.add('조리법 변경: ${i + 1}단계 "${oldStep}" → "${newStep}"');
      }
    }

    return changes;
  }

  /// 단계별 변경사항 비교 (믹싱, 발효, 오븐)
  static List<String> _compareSteps(List<Map<String, dynamic>>? oldSteps,
      List<Map<String, dynamic>>? newSteps) {
    final changes = <String>[];

    if (oldSteps == null && newSteps == null) return changes;
    if (oldSteps == null && newSteps != null) {
      changes.add('단계 추가: ${newSteps.length}개 단계');
      return changes;
    }
    if (oldSteps != null && newSteps == null) {
      changes.add('단계 삭제: 모든 단계 제거');
      return changes;
    }

    final oldList = oldSteps!;
    final newList = newSteps!;

    if (oldList.length != newList.length) {
      changes.add('단계 수 변경: ${oldList.length}개 → ${newList.length}개');
    }

    final minLength =
        oldList.length < newList.length ? oldList.length : newList.length;

    for (int i = 0; i < minLength; i++) {
      final oldStep = oldList[i];
      final newStep = newList[i];

      // 주요 필드 비교
      final fieldsToCompare = [
        'speed',
        'time',
        'temperature',
        'humidity',
        'comment'
      ];
      for (final field in fieldsToCompare) {
        final oldValue = oldStep[field];
        final newValue = newStep[field];

        if (oldValue != newValue) {
          final fieldName = _getFieldDisplayName(field);
          changes.add(
              '단계 ${i + 1}: ${fieldName} ${oldValue ?? '없음'} → ${newValue ?? '없음'}');
        }
      }
    }

    return changes;
  }

  /// 기본 정보 변경사항 비교
  static List<String> _compareBasicInfo(Recipe oldRecipe, Recipe newRecipe) {
    final changes = <String>[];

    if (oldRecipe.title != newRecipe.title) {
      changes.add('제목 변경: "${oldRecipe.title}" → "${newRecipe.title}"');
    }

    if (oldRecipe.category != newRecipe.category) {
      changes.add('카테고리 변경: ${oldRecipe.category} → ${newRecipe.category}');
    }

    if (oldRecipe.baseServings != newRecipe.baseServings) {
      changes.add(
          '기본 인분 변경: ${oldRecipe.baseServings}인분 → ${newRecipe.baseServings}인분');
    }

    if (oldRecipe.isBaking != newRecipe.isBaking) {
      final oldType = oldRecipe.isBaking ? '베이킹' : '일반';
      final newType = newRecipe.isBaking ? '베이킹' : '일반';
      changes.add('레시피 타입 변경: $oldType → $newType');
    }

    return changes;
  }

  /// 필드명을 표시용 이름으로 변환
  static String _getFieldDisplayName(String field) {
    switch (field) {
      case 'speed':
        return '속도';
      case 'time':
        return '시간';
      case 'temperature':
        return '온도';
      case 'humidity':
        return '습도';
      case 'comment':
        return '코멘트';
      default:
        return field;
    }
  }

  /// 변경사항을 요약된 텍스트로 변환
  static String summarizeChanges(Map<String, dynamic> diffResult) {
    final summary = <String>[];

    final basicChanges = diffResult['basicInfo'] as List<String>;
    final ingredientChanges = diffResult['ingredients'] as List<String>;
    final instructionChanges = diffResult['instructions'] as List<String>;
    final mixingChanges = diffResult['mixingSteps'] as List<String>;
    final fermentationChanges = diffResult['fermentationSteps'] as List<String>;
    final ovenChanges = diffResult['ovenSteps'] as List<String>;

    if (basicChanges.isNotEmpty) {
      summary.add('기본정보: ${basicChanges.length}개 변경');
    }

    if (ingredientChanges.isNotEmpty) {
      summary.add('재료: ${ingredientChanges.length}개 변경');
    }

    if (instructionChanges.isNotEmpty) {
      summary.add('조리법: ${instructionChanges.length}개 변경');
    }

    if (mixingChanges.isNotEmpty) {
      summary.add('믹싱: ${mixingChanges.length}개 변경');
    }

    if (fermentationChanges.isNotEmpty) {
      summary.add('발효: ${fermentationChanges.length}개 변경');
    }

    if (ovenChanges.isNotEmpty) {
      summary.add('오븐: ${ovenChanges.length}개 변경');
    }

    return summary.isEmpty ? '레시피 수정' : summary.join(', ');
  }
}
