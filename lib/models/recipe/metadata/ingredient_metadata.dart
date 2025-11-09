import 'dart:convert';

/// 재료 메타데이터
class IngredientMetadata {
  final String name;
  final Map<String, dynamic> properties; // 글루텐, 수분, 단백질 등
  final double effectiveValue; // 유효값 (보정 적용 후)
  final String function; // 재료의 기능 (구조 형성, 발효 등)
  final double qualityCorrectionFactor; // 품질 보정 계수

  const IngredientMetadata({
    required this.name,
    required this.properties,
    required this.effectiveValue,
    required this.function,
    required this.qualityCorrectionFactor,
  });

  factory IngredientMetadata.fromJson(Map<String, dynamic> json) {
    return IngredientMetadata(
      name: json['name'] as String,
      properties: Map<String, dynamic>.from(json['properties'] as Map),
      effectiveValue: (json['effectiveValue'] as num).toDouble(),
      function: json['function'] as String,
      qualityCorrectionFactor:
          (json['qualityCorrectionFactor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'properties': properties,
      'effectiveValue': effectiveValue,
      'function': function,
      'qualityCorrectionFactor': qualityCorrectionFactor,
    };
  }

  IngredientMetadata copyWith({
    String? name,
    Map<String, dynamic>? properties,
    double? effectiveValue,
    String? function,
    double? qualityCorrectionFactor,
  }) {
    return IngredientMetadata(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      effectiveValue: effectiveValue ?? this.effectiveValue,
      function: function ?? this.function,
      qualityCorrectionFactor:
          qualityCorrectionFactor ?? this.qualityCorrectionFactor,
    );
  }

  /// 유효 밀가루 단백질% = 실제 단백질% × 밀가루 활성 지수 (0.8~1.2)
  double get effectiveProteinPercentage {
    final protein = (properties['protein'] as num?)?.toDouble() ?? 0.0;
    final activityIndex =
        (properties['activityIndex'] as num?)?.toDouble() ?? 1.0;
    return protein * activityIndex;
  }

  /// 유효 이스트 활성도% = 표준 이스트 활성도% × 이스트 신선도 지수 (0.5~1.0)
  double get effectiveYeastActivity {
    final standardActivity =
        (properties['standardActivity'] as num?)?.toDouble() ?? 0.0;
    final freshnessIndex =
        (properties['freshnessIndex'] as num?)?.toDouble() ?? 1.0;
    return standardActivity * freshnessIndex;
  }

  @override
  String toString() {
    return 'IngredientMetadata(name: $name, function: $function, effectiveValue: $effectiveValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngredientMetadata &&
        other.name == name &&
        other.function == function &&
        other.effectiveValue == effectiveValue &&
        other.qualityCorrectionFactor == qualityCorrectionFactor;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        function.hashCode ^
        effectiveValue.hashCode ^
        qualityCorrectionFactor.hashCode;
  }
}

/// 재료 기능 분류
enum IngredientFunction {
  structureFormation, // 구조 형성 (밀가루, 글루텐)
  fermentation, // 발효 (이스트, 사워도우 스타터)
  flavorEnhancement, // 풍미 향상 (소금, 설탕, 향신료)
  textureModification, // 텍스처 조절 (지방, 버터, 오일)
  moistureControl, // 수분 조절 (물, 우유, 계란)
  leavening, // 팽창 (베이킹파우더, 베이킹소다)
  binding, // 결합 (계란, 젤라틴)
  preservation, // 보존 (소금, 설탕, 방부제)
  coloring, // 착색 (코코아, 식용색소)
  decoration, // 장식 (견과류, 과일, 초콜릿)
}

extension IngredientFunctionExtension on IngredientFunction {
  String get displayName {
    switch (this) {
      case IngredientFunction.structureFormation:
        return '구조 형성';
      case IngredientFunction.fermentation:
        return '발효';
      case IngredientFunction.flavorEnhancement:
        return '풍미 향상';
      case IngredientFunction.textureModification:
        return '텍스처 조절';
      case IngredientFunction.moistureControl:
        return '수분 조절';
      case IngredientFunction.leavening:
        return '팽창';
      case IngredientFunction.binding:
        return '결합';
      case IngredientFunction.preservation:
        return '보존';
      case IngredientFunction.coloring:
        return '착색';
      case IngredientFunction.decoration:
        return '장식';
    }
  }

  String get description {
    switch (this) {
      case IngredientFunction.structureFormation:
        return '빵의 기본 구조를 형성하는 역할';
      case IngredientFunction.fermentation:
        return '반죽을 발효시켜 부피를 증가시키는 역할';
      case IngredientFunction.flavorEnhancement:
        return '맛과 향을 향상시키는 역할';
      case IngredientFunction.textureModification:
        return '식감과 질감을 조절하는 역할';
      case IngredientFunction.moistureControl:
        return '수분 함량을 조절하는 역할';
      case IngredientFunction.leavening:
        return '화학적 팽창을 일으키는 역할';
      case IngredientFunction.binding:
        return '재료들을 결합시키는 역할';
      case IngredientFunction.preservation:
        return '보존성을 높이는 역할';
      case IngredientFunction.coloring:
        return '색상을 부여하는 역할';
      case IngredientFunction.decoration:
        return '장식과 외관을 개선하는 역할';
    }
  }
}

/// 재료 메타데이터 생성기
class IngredientMetadataGenerator {
  /// 재료로부터 메타데이터 생성
  static IngredientMetadata generateMetadata(
      dynamic ingredient, Map<String, dynamic> properties) {
    final functions = IngredientAnalyzer.analyzeFunctions(ingredient.name);
    final qualityFactor =
        IngredientAnalyzer.calculateQualityCorrectionFactor(ingredient);

    // 유효값 계산 (재료별로 다른 계산 방식)
    double effectiveValue = ingredient.amount;

    if (ingredient.isFlour) {
      // 유효 밀가루 단백질% = 실제 단백질% × 밀가루 활성 지수
      final protein = properties['protein'] as double? ?? 0.0;
      final activityIndex = properties['activityIndex'] as double? ?? 1.0;
      effectiveValue = protein * activityIndex;
    } else if (ingredient.isYeast) {
      // 유효 이스트 활성도% = 표준 이스트 활성도% × 이스트 신선도 지수
      final standardActivity = properties['standardActivity'] as double? ?? 0.0;
      final freshnessIndex = properties['freshnessIndex'] as double? ?? 1.0;
      effectiveValue = standardActivity * freshnessIndex;
    }

    return IngredientMetadata(
      name: ingredient.name,
      properties: properties,
      effectiveValue: effectiveValue,
      function: functions.first.displayName,
      qualityCorrectionFactor: qualityFactor,
    );
  }

  /// 재료 목록으로부터 메타데이터 목록 생성
  static List<IngredientMetadata> generateMetadataList(
      List<dynamic> ingredients) {
    return ingredients
        .map(
            (ingredient) => generateMetadata(ingredient, ingredient.properties))
        .toList();
  }
}

/// 재료 분석기 - 재료의 기능과 특성을 자동으로 분석
class IngredientAnalyzer {
  /// 재료 이름을 기반으로 기능 분류
  static List<IngredientFunction> analyzeFunctions(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();
    final functions = <IngredientFunction>[];

    // 구조 형성 재료
    if (lowerName.contains('flour') ||
        lowerName.contains('밀가루') ||
        lowerName.contains('강력분') ||
        lowerName.contains('중력분') ||
        lowerName.contains('박력분')) {
      functions.add(IngredientFunction.structureFormation);
    }

    // 발효 재료
    if (lowerName.contains('yeast') ||
        lowerName.contains('이스트') ||
        lowerName.contains('효모') ||
        lowerName.contains('starter') ||
        lowerName.contains('스타터') ||
        lowerName.contains('사워도우')) {
      functions.add(IngredientFunction.fermentation);
    }

    // 풍미 향상 재료
    if (lowerName.contains('salt') ||
        lowerName.contains('소금') ||
        lowerName.contains('sugar') ||
        lowerName.contains('설탕') ||
        lowerName.contains('honey') ||
        lowerName.contains('꿀') ||
        lowerName.contains('vanilla') ||
        lowerName.contains('바닐라')) {
      functions.add(IngredientFunction.flavorEnhancement);
    }

    // 텍스처 조절 재료
    if (lowerName.contains('butter') ||
        lowerName.contains('버터') ||
        lowerName.contains('oil') ||
        lowerName.contains('기름') ||
        lowerName.contains('올리브오일') ||
        lowerName.contains('지방')) {
      functions.add(IngredientFunction.textureModification);
    }

    // 수분 조절 재료
    if (lowerName.contains('water') ||
        lowerName.contains('물') ||
        lowerName.contains('milk') ||
        lowerName.contains('우유') ||
        lowerName.contains('cream') ||
        lowerName.contains('크림')) {
      functions.add(IngredientFunction.moistureControl);
    }

    // 팽창 재료
    if (lowerName.contains('baking powder') ||
        lowerName.contains('베이킹파우더') ||
        lowerName.contains('baking soda') ||
        lowerName.contains('베이킹소다') ||
        lowerName.contains('탄산수소나트륨')) {
      functions.add(IngredientFunction.leavening);
    }

    // 결합 재료
    if (lowerName.contains('egg') ||
        lowerName.contains('계란') ||
        lowerName.contains('달걀') ||
        lowerName.contains('gelatin') ||
        lowerName.contains('젤라틴')) {
      functions.add(IngredientFunction.binding);
    }

    // 착색 재료
    if (lowerName.contains('cocoa') ||
        lowerName.contains('코코아') ||
        lowerName.contains('chocolate') ||
        lowerName.contains('초콜릿') ||
        lowerName.contains('food coloring') ||
        lowerName.contains('식용색소')) {
      functions.add(IngredientFunction.coloring);
    }

    // 장식 재료
    if (lowerName.contains('nuts') ||
        lowerName.contains('견과류') ||
        lowerName.contains('fruit') ||
        lowerName.contains('과일') ||
        lowerName.contains('raisin') ||
        lowerName.contains('건포도')) {
      functions.add(IngredientFunction.decoration);
    }

    // 기본값: 풍미 향상
    if (functions.isEmpty) {
      functions.add(IngredientFunction.flavorEnhancement);
    }

    return functions;
  }

  /// 재료의 화학적 특성 분석
  static Map<String, dynamic> analyzeChemicalProperties(dynamic ingredient) {
    final properties = <String, dynamic>{};
    final lowerName = ingredient.name.toLowerCase();

    // 밀가루 특성
    if (ingredient.isFlour) {
      properties['protein'] = _estimateFlourProtein(lowerName);
      properties['gluten'] = _estimateGlutenContent(lowerName);
      properties['moisture'] = 14.0; // 일반적인 밀가루 수분 함량
      properties['ash'] = _estimateAshContent(lowerName);
    }

    // 이스트 특성
    if (ingredient.isYeast) {
      properties['standardActivity'] = 0.5; // 표준 활성도
      properties['freshnessIndex'] = 1.0; // 신선도 지수 (기본값)
      properties['type'] = _determineYeastType(lowerName);
    }

    // 지방 특성
    if (ingredient.isFat) {
      properties['fatContent'] = _estimateFatContent(lowerName);
      properties['meltingPoint'] = _estimateMeltingPoint(lowerName);
      properties['waterContent'] = _estimateWaterInFat(lowerName);
    }

    // 설탕 특성
    if (ingredient.isSugar) {
      properties['sweetness'] = _estimateSweetness(lowerName);
      properties['moisture'] = _estimateSugarMoisture(lowerName);
      properties['crystalSize'] = _estimateCrystalSize(lowerName);
    }

    // 기존 속성과 병합
    properties.addAll(ingredient.properties);

    return properties;
  }

  /// 재료 품질 보정 계수 계산
  static double calculateQualityCorrectionFactor(dynamic ingredient) {
    final lowerName = ingredient.name.toLowerCase();
    double factor = 1.0;

    // 밀가루 품질 보정
    if (ingredient.isFlour) {
      final protein = ingredient.proteinContent;
      if (protein > 13.0) {
        factor *= 1.1; // 고단백질 밀가루
      } else if (protein < 10.0) {
        factor *= 0.9; // 저단백질 밀가루
      }
    }

    // 이스트 품질 보정
    if (ingredient.isYeast) {
      if (lowerName.contains('instant') || lowerName.contains('인스턴트')) {
        factor *= 1.2; // 인스턴트 이스트
      } else if (lowerName.contains('active dry') ||
          lowerName.contains('드라이')) {
        factor *= 1.0; // 드라이 이스트
      } else if (lowerName.contains('fresh') || lowerName.contains('생')) {
        factor *= 0.8; // 생이스트
      }
    }

    // 지방 품질 보정
    if (ingredient.isFat) {
      if (lowerName.contains('butter') || lowerName.contains('버터')) {
        factor *= 1.1; // 버터는 풍미가 좋음
      } else if (lowerName.contains('margarine') || lowerName.contains('마가린')) {
        factor *= 0.9; // 마가린은 풍미가 떨어짐
      }
    }

    return factor;
  }

  // 내부 헬퍼 메서드들
  static double _estimateFlourProtein(String flourName) {
    if (flourName.contains('강력분') || flourName.contains('bread flour')) {
      return 12.5;
    } else if (flourName.contains('중력분') || flourName.contains('all purpose')) {
      return 10.5;
    } else if (flourName.contains('박력분') || flourName.contains('cake flour')) {
      return 8.5;
    }
    return 11.0; // 기본값
  }

  static double _estimateGlutenContent(String flourName) {
    if (flourName.contains('강력분') || flourName.contains('bread flour')) {
      return 12.0;
    } else if (flourName.contains('중력분') || flourName.contains('all purpose')) {
      return 10.0;
    } else if (flourName.contains('박력분') || flourName.contains('cake flour')) {
      return 8.0;
    }
    return 10.0; // 기본값
  }

  static double _estimateAshContent(String flourName) {
    if (flourName.contains('whole wheat') || flourName.contains('통밀')) {
      return 1.5;
    } else if (flourName.contains('bread flour') || flourName.contains('강력분')) {
      return 0.55;
    }
    return 0.5; // 기본값
  }

  static String _determineYeastType(String yeastName) {
    if (yeastName.contains('instant') || yeastName.contains('인스턴트')) {
      return 'instant';
    } else if (yeastName.contains('active dry') || yeastName.contains('드라이')) {
      return 'active_dry';
    } else if (yeastName.contains('fresh') || yeastName.contains('생')) {
      return 'fresh';
    }
    return 'unknown';
  }

  static double _estimateFatContent(String fatName) {
    if (fatName.contains('butter') || fatName.contains('버터')) {
      return 82.0;
    } else if (fatName.contains('oil') || fatName.contains('기름')) {
      return 100.0;
    } else if (fatName.contains('margarine') || fatName.contains('마가린')) {
      return 80.0;
    }
    return 85.0; // 기본값
  }

  static double _estimateMeltingPoint(String fatName) {
    if (fatName.contains('butter') || fatName.contains('버터')) {
      return 32.0; // 버터 융점
    } else if (fatName.contains('coconut oil') || fatName.contains('코코넛오일')) {
      return 24.0;
    }
    return 25.0; // 기본값
  }

  static double _estimateWaterInFat(String fatName) {
    if (fatName.contains('butter') || fatName.contains('버터')) {
      return 16.0; // 버터의 수분 함량
    } else if (fatName.contains('oil') || fatName.contains('기름')) {
      return 0.0; // 순수 오일
    }
    return 10.0; // 기본값
  }

  static double _estimateSweetness(String sugarName) {
    if (sugarName.contains('honey') || sugarName.contains('꿀')) {
      return 1.3; // 설탕 대비 단맛
    } else if (sugarName.contains('brown sugar') || sugarName.contains('흑설탕')) {
      return 0.9;
    }
    return 1.0; // 기본 설탕
  }

  static double _estimateSugarMoisture(String sugarName) {
    if (sugarName.contains('honey') || sugarName.contains('꿀')) {
      return 17.0;
    } else if (sugarName.contains('brown sugar') || sugarName.contains('흑설탕')) {
      return 3.5;
    }
    return 0.5; // 백설탕
  }

  static String _estimateCrystalSize(String sugarName) {
    if (sugarName.contains('powdered') || sugarName.contains('가루설탕')) {
      return 'fine';
    } else if (sugarName.contains('coarse') || sugarName.contains('굵은설탕')) {
      return 'coarse';
    }
    return 'medium';
  }
}
