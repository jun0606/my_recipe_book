import 'package:flutter_test/flutter_test.dart';

// 레시피 조정 로직 테스트
class RecipeAdjustment {
  final double timeFactor;
  final String reason;

  RecipeAdjustment({
    required this.timeFactor,
    required this.reason,
  });
}

RecipeAdjustment calculateRecipeBasedAdjustment(
  List<Map<String, dynamic>>? ingredients,
  String? recipeTitle,
) {
  print('🔍 레시피 조정 계산 시작:');
  print('   - 재료: ${ingredients?.length ?? 0}개');
  print('   - 레시피 제목: ${recipeTitle ?? "없음"}');

  if (ingredients == null || ingredients.isEmpty) {
    print('   - 결과: 기본 레시피 (재료 없음)');
    return RecipeAdjustment(
      timeFactor: 1.0,
      reason: '기본 레시피',
    );
  }

  double timeFactor = 1.0;
  List<String> reasons = [];

  // 밀가루 종류별 조정
  Map<String, dynamic>? flour;
  try {
    flour = ingredients.firstWhere(
      (ingredient) =>
          ingredient['name']?.toString().contains('밀가루') == true ||
          ingredient['name']?.toString().contains('flour') == true,
    );
  } catch (e) {
    flour = null;
  }

  if (flour != null) {
    final flourName = flour['name']?.toString().toLowerCase() ?? '';
    if (flourName.contains('강력분') || flourName.contains('bread')) {
      timeFactor *= 1.2; // 강력분은 발효 시간 20% 증가
      reasons.add('강력분 사용');
    } else if (flourName.contains('통밀') || flourName.contains('whole')) {
      timeFactor *= 1.3; // 통밀가루는 발효 시간 30% 증가
      reasons.add('통밀가루 사용');
    }
  }

  // 이스트 양에 따른 조정
  Map<String, dynamic>? yeast;
  try {
    yeast = ingredients.firstWhere(
      (ingredient) =>
          ingredient['name']?.toString().contains('이스트') == true ||
          ingredient['name']?.toString().contains('yeast') == true,
    );
  } catch (e) {
    yeast = null;
  }

  if (yeast != null) {
    final yeastAmount =
        double.tryParse(yeast['amount']?.toString() ?? '0') ?? 0;
    if (yeastAmount > 10) {
      // 10g 이상
      timeFactor *= 0.8; // 이스트 많으면 발효 시간 20% 단축
      reasons.add('이스트 다량 사용');
    } else if (yeastAmount < 5) {
      // 5g 미만
      timeFactor *= 1.3; // 이스트 적으면 발효 시간 30% 증가
      reasons.add('이스트 소량 사용');
    }
  }

  // 설탕/꿀 등 당분에 따른 조정
  Map<String, dynamic>? sugar;
  try {
    sugar = ingredients.firstWhere(
      (ingredient) =>
          ingredient['name']?.toString().contains('설탕') == true ||
          ingredient['name']?.toString().contains('꿀') == true ||
          ingredient['name']?.toString().contains('sugar') == true ||
          ingredient['name']?.toString().contains('honey') == true,
    );
  } catch (e) {
    sugar = null;
  }

  if (sugar != null) {
    timeFactor *= 0.9; // 당분이 있으면 발효 시간 10% 단축
    reasons.add('당분 첨가');
  }

  // 레시피 제목 기반 조정
  if (recipeTitle != null) {
    final title = recipeTitle.toLowerCase();
    if (title.contains('바게트') || title.contains('baguette')) {
      timeFactor *= 1.4; // 바게트는 긴 발효 필요
      reasons.add('바게트 레시피');
    } else if (title.contains('식빵') || title.contains('토스트')) {
      timeFactor *= 1.1; // 식빵은 약간 긴 발효
      reasons.add('식빵 레시피');
    } else if (title.contains('피자') || title.contains('pizza')) {
      timeFactor *= 0.8; // 피자는 짧은 발효
      reasons.add('피자 레시피');
    }
  }

  // 최종 조정 (0.5 ~ 2.0 범위로 제한)
  timeFactor = timeFactor.clamp(0.5, 2.0);

  final result = RecipeAdjustment(
    timeFactor: timeFactor,
    reason: reasons.isEmpty ? '기본 레시피' : reasons.join(', '),
  );

  print('   - 최종 시간 계수: ${result.timeFactor}');
  print('   - 조정 이유: ${result.reason}');

  return result;
}

void main() {
  group('발효 시나리오 레시피 반영 테스트', () {
    test('기본 레시피 (재료 없음)', () {
      final result = calculateRecipeBasedAdjustment(null, null);
      expect(result.timeFactor, equals(1.0));
      expect(result.reason, equals('기본 레시피'));

      // 90분 기본 시간 확인
      final adjustedTime = (90 * result.timeFactor).round();
      print('📊 기본 레시피: 90분 → ${adjustedTime}분');
    });

    test('바게트 + 강력분', () {
      final ingredients = [
        {'name': '강력분', 'amount': '500'},
        {'name': '물', 'amount': '350'},
        {'name': '소금', 'amount': '10'},
        {'name': '이스트', 'amount': '3'},
      ];

      final result = calculateRecipeBasedAdjustment(ingredients, '바게트');
      expect(result.timeFactor, greaterThan(1.0));
      expect(result.reason, contains('바게트'));

      final adjustedTime = (90 * result.timeFactor).round();
      print('📊 바게트 + 강력분: 90분 → ${adjustedTime}분 (${result.reason})');
    });

    test('피자 도우 + 설탕', () {
      final ingredients = [
        {'name': '밀가루', 'amount': '300'},
        {'name': '설탕', 'amount': '15'},
        {'name': '이스트', 'amount': '7'},
      ];

      final result = calculateRecipeBasedAdjustment(ingredients, '피자');
      expect(result.timeFactor, lessThan(1.0));
      expect(result.reason, contains('피자'));

      final adjustedTime = (90 * result.timeFactor).round();
      print('📊 피자 도우: 90분 → ${adjustedTime}분 (${result.reason})');
    });

    test('통밀빵 + 이스트 소량', () {
      final ingredients = [
        {'name': '통밀가루', 'amount': '400'},
        {'name': '이스트', 'amount': '3'},
        {'name': '꿀', 'amount': '20'},
      ];

      final result = calculateRecipeBasedAdjustment(ingredients, '통밀빵');
      expect(result.timeFactor, greaterThan(1.0));

      final adjustedTime = (90 * result.timeFactor).round();
      print('📊 통밀빵: 90분 → ${adjustedTime}분 (${result.reason})');
    });
  });
}
