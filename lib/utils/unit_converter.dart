/// 단위 변환 유틸리티 클래스
class UnitConverter {
  // 무게 단위 변환 (모든 값을 그램으로 변환)
  static const Map<String, double> _weightConversions = {
    'g': 1.0,
    'gram': 1.0,
    'kg': 1000.0,
    'kilogram': 1000.0,
    'lb': 453.592,
    'pound': 453.592,
    'oz': 28.3495,
    'ounce': 28.3495,
  };

  // 부피 단위 변환 (모든 값을 밀리리터로 변환)
  static const Map<String, double> _volumeConversions = {
    'ml': 1.0,
    'milliliter': 1.0,
    'l': 1000.0,
    'liter': 1000.0,
    'cup': 240.0,
    'tbsp': 15.0,
    'tablespoon': 15.0,
    'tsp': 5.0,
    'teaspoon': 5.0,
    'fl oz': 29.5735,
    'fluid ounce': 29.5735,
  };

  // 개수 단위
  static const Set<String> _countUnits = {
    'ea',
    'each',
    'piece',
    'pcs',
  };

  /// 단위 타입 확인
  static UnitType getUnitType(String unit) {
    final normalizedUnit = unit.toLowerCase().trim();
    
    if (_weightConversions.containsKey(normalizedUnit)) {
      return UnitType.weight;
    } else if (_volumeConversions.containsKey(normalizedUnit)) {
      return UnitType.volume;
    } else if (_countUnits.contains(normalizedUnit)) {
      return UnitType.count;
    } else {
      return UnitType.unknown;
    }
  }

  /// 무게 단위를 그램으로 변환
  static double convertToGrams(double amount, String unit) {
    final normalizedUnit = unit.toLowerCase().trim();
    final conversionFactor = _weightConversions[normalizedUnit];
    
    if (conversionFactor != null) {
      return amount * conversionFactor;
    }
    
    // 변환할 수 없는 경우 원래 값 반환
    return amount;
  }

  /// 부피 단위를 밀리리터로 변환
  static double convertToMilliliters(double amount, String unit) {
    final normalizedUnit = unit.toLowerCase().trim();
    final conversionFactor = _volumeConversions[normalizedUnit];
    
    if (conversionFactor != null) {
      return amount * conversionFactor;
    }
    
    // 변환할 수 없는 경우 원래 값 반환
    return amount;
  }

  /// 그램에서 다른 무게 단위로 변환
  static double convertFromGrams(double grams, String targetUnit) {
    final normalizedUnit = targetUnit.toLowerCase().trim();
    final conversionFactor = _weightConversions[normalizedUnit];
    
    if (conversionFactor != null) {
      return grams / conversionFactor;
    }
    
    // 변환할 수 없는 경우 원래 값 반환
    return grams;
  }

  /// 밀리리터에서 다른 부피 단위로 변환
  static double convertFromMilliliters(double ml, String targetUnit) {
    final normalizedUnit = targetUnit.toLowerCase().trim();
    final conversionFactor = _volumeConversions[normalizedUnit];
    
    if (conversionFactor != null) {
      return ml / conversionFactor;
    }
    
    // 변환할 수 없는 경우 원래 값 반환
    return ml;
  }

  /// 재료의 표준 무게 계산 (베이킹 계산용)
  /// 모든 재료를 그램 단위로 통일하여 계산
  static double getStandardWeight(double amount, String unit) {
    final unitType = getUnitType(unit);
    
    switch (unitType) {
      case UnitType.weight:
        return convertToGrams(amount, unit);
      case UnitType.volume:
        // 부피를 무게로 근사 변환 (물 기준: 1ml = 1g)
        // 실제로는 재료별 밀도를 고려해야 하지만, 간단한 근사치 사용
        return convertToMilliliters(amount, unit) * _getIngredientDensity(unit);
      case UnitType.count:
        // 개수 단위는 평균 무게로 근사 (예: 계란 1개 = 50g)
        return amount * _getAverageItemWeight(unit);
      case UnitType.unknown:
        // 알 수 없는 단위는 그대로 반환
        return amount;
    }
  }

  /// 재료별 밀도 근사치 (g/ml)
  static double _getIngredientDensity(String unit) {
    // 대부분의 액체 재료는 물과 비슷한 밀도
    // 실제로는 재료명을 분석해서 더 정확한 밀도를 사용해야 함
    return 1.0;
  }

  /// 개수 단위의 평균 무게 (그램)
  static double _getAverageItemWeight(String unit) {
    final normalizedUnit = unit.toLowerCase().trim();
    
    switch (normalizedUnit) {
      case 'ea':
      case 'each':
      case 'piece':
      case 'pcs':
        return 50.0; // 기본 개수 단위
      default:
        return 50.0; // 기본값
    }
  }

  /// 단위 표시 형식 정규화
  static String normalizeUnitDisplay(String unit) {
    final normalizedUnit = unit.toLowerCase().trim();
    
    // 한국어 단위 우선 표시
    switch (normalizedUnit) {
      case 'g':
      case 'gram':
        return 'g';
      case 'kg':
      case 'kilogram':
        return 'kg';
      case 'ml':
      case 'milliliter':
        return 'ml';
      case 'l':
      case 'liter':
        return 'L';
      case 'cup':
        return 'cup';
      case 'tbsp':
      case 'tablespoon':
        return 'tbsp';
      case 'tsp':
      case 'teaspoon':
        return 'tsp';
      case 'ea':
      case 'each':
      case 'piece':
      case 'pcs':
        return 'ea';
      default:
        return unit; // 원래 단위 그대로 반환
    }
  }

  /// 적절한 단위로 자동 변환 (표시용) - 계산된 값에만 사용
  static Map<String, dynamic> getOptimalDisplayUnit(double amount, String originalUnit) {
    final unitType = getUnitType(originalUnit);
    
    switch (unitType) {
      case UnitType.weight:
        final grams = convertToGrams(amount, originalUnit);
        if (grams >= 1000) {
          return {
            'amount': grams / 1000,
            'unit': 'kg',
          };
        } else {
          return {
            'amount': grams,
            'unit': 'g',
          };
        }
      case UnitType.volume:
        final ml = convertToMilliliters(amount, originalUnit);
        if (ml >= 1000) {
          return {
            'amount': ml / 1000,
            'unit': 'L',
          };
        } else {
          return {
            'amount': ml,
            'unit': 'ml',
          };
        }
      default:
        return {
          'amount': amount,
          'unit': normalizeUnitDisplay(originalUnit),
        };
    }
  }

  /// 원본 단위 유지하면서 표시용 포맷팅 (사용자 입력값 표시용)
  static String formatAmountWithOriginalUnit(double amount, String originalUnit) {
    final displayUnit = normalizeUnitDisplay(originalUnit);
    
    // 소수점 처리
    if (amount >= 10) {
      return '${amount.toStringAsFixed(0)} $displayUnit';
    } else if (amount >= 1) {
      return '${amount.toStringAsFixed(1)} $displayUnit';
    } else {
      return '${amount.toStringAsFixed(2)} $displayUnit';
    }
  }

  /// 기존 코드 호환성을 위한 범용 단위 변환 메서드
  static double convert(double amount, String fromUnit, String toUnit) {
    final fromType = getUnitType(fromUnit);
    final toType = getUnitType(toUnit);
    
    // 같은 단위 타입 간 변환
    if (fromType == toType) {
      switch (fromType) {
        case UnitType.weight:
          final grams = convertToGrams(amount, fromUnit);
          return convertFromGrams(grams, toUnit);
        case UnitType.volume:
          final ml = convertToMilliliters(amount, fromUnit);
          return convertFromMilliliters(ml, toUnit);
        case UnitType.count:
        case UnitType.unknown:
          return amount; // 개수나 알 수 없는 단위는 그대로 반환
      }
    }
    
    // 다른 타입 간 변환 (근사치)
    if (fromType == UnitType.volume && toType == UnitType.weight) {
      // 부피 → 무게 (물 기준 밀도 1.0)
      final ml = convertToMilliliters(amount, fromUnit);
      final grams = ml * 1.0; // 물 기준
      return convertFromGrams(grams, toUnit);
    } else if (fromType == UnitType.weight && toType == UnitType.volume) {
      // 무게 → 부피 (물 기준 밀도 1.0)
      final grams = convertToGrams(amount, fromUnit);
      final ml = grams / 1.0; // 물 기준
      return convertFromMilliliters(ml, toUnit);
    }
    
    // 변환할 수 없는 경우 원래 값 반환
    return amount;
  }

  /// 단위 시스템에 따른 사용 가능한 단위 목록 반환
  static List<String> getUnits(String unitSystem) {
    switch (unitSystem.toLowerCase()) {
      case 'metric':
      case '미터법':
        return [
          // 무게
          'g', 'kg',
          // 부피
          'ml', 'L',
          // 기타
          '개', 'tsp', 'tbsp', 'cup',
        ];
      case 'imperial':
      case '야드파운드법':
        return [
          // 무게
          'oz', 'lb',
          // 부피
          'fl oz', 'cup', 'tbsp', 'tsp',
          // 기타
          'ea',
        ];
      case 'korea':
      case '한국':
      case 'korean':
        return [
          // 무게 (한국에서 주로 사용)
          'g', 'kg',
          // 부피
          'ml', 'L', 'cup',
          // 개수
          'ea',
          // 베이킹용
          'tsp', 'tbsp',
        ];
      case 'mixed':
      case '혼합':
      default:
        return [
          // 무게
          'g', 'kg', 'oz', 'lb',
          // 부피
          'ml', 'L', 'fl oz', 'cup', 'tbsp', 'tsp',
          // 개수
          'ea', 'piece', 'pcs',
        ];
    }
  }

  /// 단위 시스템별 기본 단위 반환
  static String getDefaultUnit(String unitSystem, UnitType unitType) {
    switch (unitSystem.toLowerCase()) {
      case 'metric':
      case '미터법':
        switch (unitType) {
          case UnitType.weight:
            return 'g';
          case UnitType.volume:
            return 'ml';
          case UnitType.count:
            return 'ea';
          case UnitType.unknown:
            return 'g';
        }
      case 'imperial':
      case '야드파운드법':
        switch (unitType) {
          case UnitType.weight:
            return 'oz';
          case UnitType.volume:
            return 'fl oz';
          case UnitType.count:
            return 'ea';
          case UnitType.unknown:
            return 'oz';
        }
      case 'korea':
      case '한국':
      case 'korean':
        switch (unitType) {
          case UnitType.weight:
            return 'g';
          case UnitType.volume:
            return 'ml';
          case UnitType.count:
            return 'ea';
          case UnitType.unknown:
            return 'g';
        }
      default:
        switch (unitType) {
          case UnitType.weight:
            return 'g';
          case UnitType.volume:
            return 'ml';
          case UnitType.count:
            return 'ea';
          case UnitType.unknown:
            return 'g';
        }
    }
  }
}

/// 단위 타입 열거형
enum UnitType {
  weight,   // 무게
  volume,   // 부피
  count,    // 개수
  unknown,  // 알 수 없음
}