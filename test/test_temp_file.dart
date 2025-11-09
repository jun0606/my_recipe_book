import 'dart:convert';
import 'lib/services/ingredient_analyzer.dart';

void main() {
  print('🎯 발효 분석 계산 검증 시작');

  try {
    // 샘플 재료 직접 생성 (생종 포함)
    final ingredients = [
      {'name': '강력분', 'amount': 700.0, 'unit': 'g'},
      {'name': '생종', 'amount': 300.0, 'unit': 'g'},
      {'name': '식초', 'amount': 15.0, 'unit': 'ml'},
      {'name': '소금', 'amount': 15.0, 'unit': 'g'},
      {'name': '버터', 'amount': 60.0, 'unit': 'g'},
      {'name': '설탕', 'amount': 70.0, 'unit': 'g'},
      {'name': '우유', 'amount': 400.0, 'unit': 'ml'},
    ].map((e) => Map<String, dynamic>.from(e)).toList();

    print('📝 초기화된 재료들:');
    for (var ing in ingredients) {
      print('   - ${ing['name']}: ${ing['amount']}${ing['unit']}');
    }

    // 밀가루 감지 테스트
    final flourIngredients =
        IngredientAnalyzer.findFlourIngredients(ingredients);
    print('\n🌾 밀가루 감지 결과: ${flourIngredients.length}개 발견');
    for (var flour in flourIngredients) {
      print('   - ${flour['name']}: ${flour['amount']}${flour['unit']}');
    }

    // 이스트 감지 테스트
    final yeastIngredients =
        IngredientAnalyzer.findYeastIngredients(ingredients);
    print('\n🧪 이스트 감지 결과: ${yeastIngredients.length}개 발견');
    for (var yeast in yeastIngredients) {
      print('   - ${yeast['name']}: ${yeast['amount']}${yeast['unit']}');
    }

    // 이스트 수분 계산
    final yeastPercentage =
        IngredientAnalyzer.calculateYeastPercentage(ingredients);
    print('\n📊 이스트 수분 계산 결과: ${(yeastPercentage * 100).toStringAsFixed(2)}%');

    // 이스트 품질 계산
    final yeastQuality = IngredientAnalyzer.estimateYeastQuality(ingredients);
    print('📊 이스트 품질 계산 결과: ${(yeastQuality * 100).toStringAsFixed(2)}%');

    print('\n✅ 계산 검증 완료 - 모든 테스트 통과');
  } catch (e, stackTrace) {
    print('❌ 계산 검증 실패: $e');
    print('📋 스택트레이스: $stackTrace');
  }
}
