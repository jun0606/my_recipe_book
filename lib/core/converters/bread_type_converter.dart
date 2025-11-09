// lib/core/converters/bread_type_converter.dart
// 빵 타입 변환기 - BakingCategory와 BreadType 간 변환

import 'package:my_recipe_book/models/enhanced_recipe.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';

/// 빵 타입 변환기 클래스
class BreadTypeConverter {
  /// BakingCategory를 BreadType으로 변환
  static BreadType convertFromBakingCategory(BakingCategory category) {
    switch (category) {
      case BakingCategory.bread:
        return BreadType.white;
      case BakingCategory.pastry:
        return BreadType.enriched;
      case BakingCategory.pizza:
        return BreadType.white; // 피자는 화이트 브레드 기반
      case BakingCategory.cookie:
      case BakingCategory.cake:
        return BreadType.enriched; // 쿠키와 케이크는 리치 도우
      case BakingCategory.other:
        return BreadType.white;
    }
  }

  /// BreadType을 BakingCategory로 변환
  static BakingCategory convertToBakingCategory(BreadType type) {
    switch (type) {
      case BreadType.white:
        return BakingCategory.bread;
      case BreadType.whole_wheat:
        return BakingCategory.bread;
      case BreadType.sourdough:
        return BakingCategory.bread;
      case BreadType.enriched:
        return BakingCategory.pastry;
    }
  }

  /// 문자열로부터 BreadType 변환
  static BreadType fromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'white':
        return BreadType.white;
      case 'whole_wheat':
      case 'wholewheat':
        return BreadType.whole_wheat;
      case 'sourdough':
        return BreadType.sourdough;
      case 'enriched':
        return BreadType.enriched;
      default:
        return BreadType.white;
    }
  }

  /// BreadType을 문자열로 변환
  static String toStringValue(BreadType type) {
    switch (type) {
      case BreadType.white:
        return 'white';
      case BreadType.whole_wheat:
        return 'whole_wheat';
      case BreadType.sourdough:
        return 'sourdough';
      case BreadType.enriched:
        return 'enriched';
    }
  }
}

/// 빵 타입 유틸리티 클래스
class BreadTypeUtils {
  /// 빵 타입별 기본 수분 함량
  static double getDefaultHydration(BreadType type) {
    switch (type) {
      case BreadType.white:
        return 0.65;
      case BreadType.whole_wheat:
        return 0.70;
      case BreadType.sourdough:
        return 0.75;
      case BreadType.enriched:
        return 0.60;
    }
  }

  /// 빵 타입별 권장 발효 시간 (분)
  static int getRecommendedFermentationTime(BreadType type) {
    switch (type) {
      case BreadType.white:
        return 120; // 2시간
      case BreadType.whole_wheat:
        return 180; // 3시간
      case BreadType.sourdough:
        return 240; // 4시간
      case BreadType.enriched:
        return 90; // 1.5시간
    }
  }
}
