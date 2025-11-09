import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/bread_method.dart';

class DoughMethodClassifier {
  /// 레시피를 분석하여 도법(스트레이트, 르방, 사워도우)을 판정합니다.
  static BreadMethod determineDoughMethod(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    final ingredients = recipe.ingredients.map((e) => e.name.toLowerCase()).join(' ');

    if (title.contains('sourdough') || ingredients.contains('sourdough') || title.contains('사워도우')) {
      return BreadMethod(name: 'sourdough', description: '사워도우 스타터를 이용한 제법');
    }
    if (title.contains('levain') || ingredients.contains('levain') || title.contains('르방')) {
      return BreadMethod(name: 'levain', description: '르방 스타터를 이용한 제법');
    }
    return BreadMethod(name: 'straight', description: '스트레이트 제법');
  }

  // TODO: 르방 활성도 지수 계산 공식 구현
  // TODO: 사워도우 숙성 시간 계산 공식 구현
  // TODO: 도법별 특성 데이터베이스 구축
}