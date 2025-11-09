import 'package:crypto/crypto.dart';
import 'dart:convert'; // utf8 인코딩을 위해 필요

import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/ingredient.dart'; // Ingredient 모델의 id와 amount 접근을 위해 필요

/// 캐시 키 생성기
///
/// AnalysisRequest 객체로부터 고유한 캐시 키를 생성합니다.
class CacheKeyGenerator {
  /// AnalysisRequest 객체로부터 고유한 캐시 키를 생성합니다.
  ///
  /// 레시피 ID, 재료 목록, 환경 조건, 활성화된 모듈 목록을 기반으로
  /// SHA256 해시를 사용하여 키를 생성합니다.
  String generateCacheKey(AnalysisRequest request) {
    final components = <String>[];

    // 1. 레시피 ID (필수)
    components.add(request.recipe?.id?.toString() ?? 'no_recipe_id');

    // 2. 재료 목록 (정규화 및 정렬)
    final sortedIngredients = List<Ingredient>.from(request.ingredients)
      ..sort((a, b) => a.name.compareTo(b.name)); // 이름으로 정렬하여 일관성 유지
    components.add(sortedIngredients.map((i) => '${i.name}:${i.amount}:${i.unit}').join(','));

    // 3. 환경 조건 (hashCode 사용)
    components.add(request.environment?.hashCode.toString() ?? 'no_environment');

    // 4. 활성화된 모듈 목록 (정렬)
    final sortedEnabledModules = List<String>.from(request.options.enabledModules)..sort();
    components.add(sortedEnabledModules.join(','));

    // 5. 기타 사용자 정의 매개변수 (정규화)
    final customParams = request.options.customParameters;
    if (customParams.isNotEmpty) {
      final sortedCustomParams = customParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      components.add(sortedCustomParams.map((e) => '${e.key}:${e.value}').join('&'));
    }

    // 모든 컴포넌트를 결합하여 단일 문자열 생성 후 SHA256 해시
    final combinedString = components.join('|');
    final bytes = utf8.encode(combinedString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}