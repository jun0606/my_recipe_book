// lib/utils/unit_converter.dart
// 단위 변환 유틸리티

/// 단위 변환 클래스
class UnitConverter {
  /// 단위 체계별 변환 상수 (그램을 기준으로)
  static const Map<String, Map<String, double>> _unitConversions = {
    'Korea': {
      'g': 1.0,
      'kg': 1000.0,
      'ml': 1.0,
      'l': 1000.0,
      'cup': 200.0, // 한국 컵 (200ml)
      'tbsp': 15.0, // 큰술
      'tsp': 5.0, // 작은술
    },
    'US': {
      'oz': 28.35, // 액체 온스
      'lb': 453.59, // 파운드
      'cup': 236.59, // 미국 컵 (236.59ml)
      'tbsp': 14.79, // 미국 큰술
      'tsp': 4.93, // 미국 작은술
      'floz': 29.57, // 유체 온스
    },
    'SI': {
      'g': 1.0,
      'kg': 1000.0,
      'ml': 1.0,
      'l': 1000.0,
    },
    'Japan': {
      'g': 1.0,
      'kg': 1000.0,
      '合': 18.0, // 일본 전통 단위 (약 18g)
      '升': 1800.0, // 일본 전통 단위 (약 1800g)
    },
    'Europe': {
      'g': 1.0,
      'kg': 1000.0,
      'ml': 1.0,
      'l': 1000.0,
    },
  };

  /// 단위 변환 (기존 호환성 유지)
  static double convert(double amount, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase();
    final to = toUnit.toLowerCase();

    if (from == to) return amount;

    // 그램으로 먼저 변환
    double grams;
    switch (from) {
      case 'kg':
        grams = amount * 1000;
        break;
      case 'ml':
      case 'l':
        grams = amount * 1.0; // 근사치
        break;
      default:
        grams = amount;
    }

    // 목표 단위로 변환
    switch (to) {
      case 'kg':
        return grams / 1000;
      case 'ml':
      case 'l':
        return grams / 1.0; // 근사치
      default:
        return grams;
    }
  }

  /// 단위 체계별 단위 목록 반환
  static List<String> getUnits(String unitSystem) {
    final conversions =
        _unitConversions[unitSystem] ?? _unitConversions['Korea']!;
    return conversions.keys.toList();
  }

  /// 단위 카테고리 반환
  static String getUnitCategory(String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'kg':
      case 'oz':
      case 'lb':
      case '合':
      case '升':
        return 'weight';
      case 'ml':
      case 'l':
      case 'cup':
      case 'tbsp':
      case 'tsp':
      case 'floz':
        return 'volume';
      default:
        return 'other';
    }
  }

  /// 단위 표시 이름 반환
  static String getUnitDisplayName(String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
        return '그램';
      case 'kg':
        return '킬로그램';
      case 'ml':
        return '밀리리터';
      case 'l':
        return '리터';
      case 'cup':
        return '컵';
      case 'tbsp':
        return '큰술';
      case 'tsp':
        return '작은술';
      case 'oz':
        return '온스';
      case 'lb':
        return '파운드';
      case 'floz':
        return '유체온스';
      case '合':
        return '합';
      case '升':
        return '승';
      default:
        return unit;
    }
  }

  /// 단위 변환 가능 여부 확인
  static bool canConvert(String fromUnit, String toUnit) {
    final fromCategory = getUnitCategory(fromUnit);
    final toCategory = getUnitCategory(toUnit);
    return fromCategory == toCategory && fromCategory != 'other';
  }

  /// 최적 단위 추천
  static String recommendUnit(double amount, String currentUnit) {
    final category = getUnitCategory(currentUnit);

    if (category == 'weight') {
      if (amount >= 1000) return 'kg';
      return 'g';
    } else if (category == 'volume') {
      if (amount >= 1000) return 'l';
      return 'ml';
    }

    return currentUnit;
  }

  /// 표시용: 그램을 사용자의 단위 체계로 변환하여 표시
  static String formatAmount(double grams, String unitSystem) {
    final conversions =
        _unitConversions[unitSystem] ?? _unitConversions['Korea']!;

    switch (unitSystem) {
      case 'Korea':
        if (grams >= 1000) {
          return '${(grams / 1000).toStringAsFixed(2)}kg';
        }
        return '${grams.toStringAsFixed(1)}g';

      case 'US':
        if (grams >= 453.59) {
          // 1lb 이상
          return '${(grams / 453.59).toStringAsFixed(2)}lb';
        }
        return '${(grams / 28.35).toStringAsFixed(2)}oz';

      case 'SI':
        if (grams >= 1000) {
          return '${(grams / 1000).toStringAsFixed(3)}kg';
        }
        return '${grams.toStringAsFixed(1)}g';

      case 'Japan':
        if (grams >= 1800) {
          // 1승 이상
          return '${(grams / 1800).toStringAsFixed(1)}升';
        }
        return '${(grams / 18).toStringAsFixed(1)}合';

      case 'Europe':
        if (grams >= 1000) {
          return '${(grams / 1000).toStringAsFixed(2)}kg';
        }
        return '${grams.toStringAsFixed(1)}g';

      default:
        return '${grams.toStringAsFixed(1)}g';
    }
  }

  /// 저장용: 사용자 입력을 그램으로 변환
  static double convertToGrams(double amount, String unit, String unitSystem) {
    final conversions =
        _unitConversions[unitSystem] ?? _unitConversions['Korea']!;
    final conversionFactor = conversions[unit.toLowerCase()] ?? 1.0;
    return amount * conversionFactor;
  }

  /// 단위 체계 지원 여부 확인
  static bool isUnitSystemSupported(String unitSystem) {
    return _unitConversions.containsKey(unitSystem);
  }

  /// 지원되는 단위 체계 목록 반환
  static List<String> getSupportedUnitSystems() {
    return _unitConversions.keys.toList();
  }
}
