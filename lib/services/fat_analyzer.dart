/// 버터/유지방 전문 분석기
/// 제빵에서 지방류가 미치는 영향을 과학적으로 분석

import 'dart:math' as math;

class FatAnalyzer {
  /// 지방류 종합 분석
  static FatAnalysisResult analyzeFatEffects({
    required List<Map<String, dynamic>> ingredients,
    required double flourWeight,
    String? recipeTitle,
    String breadType = 'bread',
    double doughTemperature = 25.0,
  }) {
    try {
      // 1. 지방류 재료 분류 및 감지
      final fatIngredients = _findFatIngredients(ingredients);
      if (fatIngredients.isEmpty) {
        return FatAnalysisResult.noFat();
      }

      // 2. 지방 타입별 분류
      final fatClassification = _classifyFatTypes(fatIngredients);

      // 3. 총 지방 함량 계산 (밀가루 대비 %)
      final totalFatWeight = _calculateTotalFatWeight(fatIngredients);
      final fatPercentage = (totalFatWeight / flourWeight) * 100;

      // 4. 지방의 물리적 특성 분석
      final physicalProperties = _analyzePhysicalProperties(
          fatClassification, fatPercentage, doughTemperature);

      // 5. 글루텐 네트워크 영향 분석
      final glutenEffects =
          _analyzeGlutenEffects(fatClassification, fatPercentage);

      return FatAnalysisResult(
        fatClassification: fatClassification,
        totalFatWeight: totalFatWeight,
        fatPercentage: fatPercentage,
        physicalProperties: physicalProperties,
        glutenEffects: glutenEffects,
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('지방 분석 오류: $e');
      return FatAnalysisResult.empty();
    }
  }

  /// 지방류 재료 찾기 (확장된 키워드)
  static List<Map<String, dynamic>> _findFatIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        // 고체 지방 (버터류)
        '버터', '무염버터', '유염버터', '발효버터', '마가린', '쇼트닝',
        'butter', 'unsalted butter', 'salted butter', 'cultured butter',
        'margarine', 'shortening',

        // 액체 지방 (오일류)
        '올리브오일', '식용유', '카놀라유', '해바라기유', '포도씨유', '콩기름',
        '코코넛오일', '아보카도오일', '참기름', '들기름', '옥수수기름',
        'olive oil', 'vegetable oil', 'canola oil', 'sunflower oil',
        'grapeseed oil', 'coconut oil', 'avocado oil', 'sesame oil',
        'soybean oil', 'corn oil',

        // 동물성 지방
        '라드', '우지', '오리기름', 'lard', 'beef tallow', 'duck fat',

        // 유제품 지방 (고지방 유제품)
        '크림', '생크림', '휘핑크림', '사워크림', '헤비크림',
        'cream', 'heavy cream', 'whipping cream', 'sour cream',
        'double cream', 'clotted cream',

        // 저지방 유제품 (소량 지방 함유)
        '우유', '전유', '저지방우유', '요구르트', '그릭요거트',
        'milk', 'whole milk', 'low fat milk', 'yogurt', 'greek yogurt',

        // 견과류 지방
        '아몬드버터', '땅콩버터', '호두오일', 'almond butter', 'peanut butter',
        'walnut oil', 'hazelnut oil',
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 지방 타입별 분류
  static Map<String, dynamic> _classifyFatTypes(
      List<Map<String, dynamic>> fatIngredients) {
    double solidFatWeight = 0.0; // 고체 지방 (버터, 마가린 등)
    double liquidFatWeight = 0.0; // 액체 지방 (오일류)
    double animalFatWeight = 0.0; // 동물성 지방
    double plantFatWeight = 0.0; // 식물성 지방

    String dominantFatType = 'none';
    String fatConsistency = 'mixed';

    for (final fat in fatIngredients) {
      final name = (fat['name'] as String? ?? '').toLowerCase();
      final weight = (fat['amount'] as double? ?? 0.0);

      // 고체 vs 액체 분류
      if (_isSolidFat(name)) {
        solidFatWeight += weight;
      } else {
        liquidFatWeight += weight;
      }

      // 동물성 vs 식물성 분류
      if (_isAnimalFat(name)) {
        animalFatWeight += weight;
      } else {
        plantFatWeight += weight;
      }
    }

    // 주요 지방 타입 결정
    if (solidFatWeight > liquidFatWeight) {
      dominantFatType = 'solid';
      fatConsistency = 'solid_dominant';
    } else if (liquidFatWeight > solidFatWeight) {
      dominantFatType = 'liquid';
      fatConsistency = 'liquid_dominant';
    } else {
      dominantFatType = 'mixed';
      fatConsistency = 'balanced';
    }

    return {
      'solidFatWeight': solidFatWeight,
      'liquidFatWeight': liquidFatWeight,
      'animalFatWeight': animalFatWeight,
      'plantFatWeight': plantFatWeight,
      'dominantFatType': dominantFatType,
      'fatConsistency': fatConsistency,
    };
  }

  /// 고체 지방 여부 판단
  static bool _isSolidFat(String name) {
    final solidFatKeywords = [
      '버터',
      '마가린',
      '쇼트닝',
      '라드',
      '우지',
      '코코넛오일',
      'butter',
      'margarine',
      'shortening',
      'lard',
      'tallow',
      'coconut oil'
    ];
    return solidFatKeywords.any((keyword) => name.contains(keyword));
  }

  /// 동물성 지방 여부 판단
  static bool _isAnimalFat(String name) {
    final animalFatKeywords = [
      '버터',
      '라드',
      '우지',
      '오리기름',
      '크림',
      '생크림',
      '휘핑크림',
      '사워크림',
      '헤비크림',
      '우유',
      '전유',
      '저지방우유',
      '요구르트',
      '그릭요거트',
      'butter',
      'lard',
      'tallow',
      'duck fat',
      'cream',
      'heavy cream',
      'whipping cream',
      'sour cream',
      'double cream',
      'clotted cream',
      'milk',
      'whole milk',
      'low fat milk',
      'yogurt',
      'greek yogurt'
    ];
    return animalFatKeywords.any((keyword) => name.contains(keyword));
  }

  /// 물리적 특성 분석
  static Map<String, dynamic> _analyzePhysicalProperties(
    Map<String, dynamic> classification,
    double fatPercentage,
    double temperature,
  ) {
    final dominantType = classification['dominantFatType'] as String;
    final solidFatWeight = classification['solidFatWeight'] as double;
    final liquidFatWeight = classification['liquidFatWeight'] as double;

    // 융점 특성 분석
    String meltingBehavior = 'normal';
    if (dominantType == 'solid') {
      if (temperature > 25.0) {
        meltingBehavior = 'softening'; // 버터가 부드러워짐
      } else if (temperature < 20.0) {
        meltingBehavior = 'firm'; // 버터가 단단함
      }
    }

    // 크리밍 능력 (공기 포집 능력)
    String creamingAbility = 'none';
    if (solidFatWeight > 0) {
      if (fatPercentage >= 20.0)
        creamingAbility = 'excellent';
      else if (fatPercentage >= 10.0)
        creamingAbility = 'good';
      else
        creamingAbility = 'limited';
    }

    // 층상 구조 형성 능력 (페이스트리)
    String layeringAbility = 'none';
    if (dominantType == 'solid' && fatPercentage >= 25.0) {
      layeringAbility = 'excellent'; // 크루아상, 퍼프페이스트리
    } else if (dominantType == 'solid' && fatPercentage >= 15.0) {
      layeringAbility = 'good'; // 비스킷, 스콘
    }

    return {
      'meltingBehavior': meltingBehavior,
      'creamingAbility': creamingAbility,
      'layeringAbility': layeringAbility,
      'plasticityIndex':
          _calculatePlasticityIndex(dominantType, fatPercentage, temperature),
    };
  }

  /// 가소성 지수 계산
  static double _calculatePlasticityIndex(
      String dominantType, double fatPercentage, double temperature) {
    if (dominantType != 'solid') return 0.0;

    // 온도에 따른 가소성 변화
    double temperatureFactor = 1.0;
    if (temperature > 25.0)
      temperatureFactor = 0.7; // 너무 따뜻하면 가소성 감소
    else if (temperature < 18.0) temperatureFactor = 0.5; // 너무 차가우면 가소성 감소

    // 지방 함량에 따른 가소성
    double fatFactor = math.min(1.0, fatPercentage / 30.0);

    return (fatFactor * temperatureFactor * 10.0).clamp(0.0, 10.0);
  }

  /// 글루텐 네트워크 영향 분석
  static Map<String, dynamic> _analyzeGlutenEffects(
    Map<String, dynamic> classification,
    double fatPercentage,
  ) {
    final dominantType = classification['dominantFatType'] as String;

    // 글루텐 코팅 효과 (shortening effect)
    String shorteningEffect = 'minimal';
    if (fatPercentage >= 20.0)
      shorteningEffect = 'strong';
    else if (fatPercentage >= 10.0)
      shorteningEffect = 'moderate';
    else if (fatPercentage >= 5.0) shorteningEffect = 'mild';

    // 글루텐 발달 억제 정도
    double glutenInhibition = math.min(1.0, fatPercentage / 25.0);

    // 반죽 질감 변화
    String textureEffect = 'normal';
    if (fatPercentage >= 25.0) {
      textureEffect = dominantType == 'solid' ? 'flaky_tender' : 'moist_tender';
    } else if (fatPercentage >= 15.0) {
      textureEffect = 'tender';
    } else if (fatPercentage >= 8.0) {
      textureEffect = 'slightly_tender';
    }

    // 볼륨 영향
    String volumeEffect = 'normal';
    if (fatPercentage >= 20.0)
      volumeEffect = 'reduced';
    else if (fatPercentage >= 30.0) volumeEffect = 'significantly_reduced';

    return {
      'shorteningEffect': shorteningEffect,
      'glutenInhibition': glutenInhibition,
      'textureEffect': textureEffect,
      'volumeEffect': volumeEffect,
    };
  }

  /// 총 지방 무게 계산
  static double _calculateTotalFatWeight(
      List<Map<String, dynamic>> fatIngredients) {
    double totalWeight = 0.0;
    for (final fat in fatIngredients) {
      totalWeight += (fat['amount'] as double? ?? 0.0);
    }
    return totalWeight;
  }
}

/// 지방 분석 결과 클래스
class FatAnalysisResult {
  final Map<String, dynamic> fatClassification;
  final double totalFatWeight;
  final double fatPercentage;
  final Map<String, dynamic> physicalProperties;
  final Map<String, dynamic> glutenEffects;
  final DateTime analysisTimestamp;

  FatAnalysisResult({
    required this.fatClassification,
    required this.totalFatWeight,
    required this.fatPercentage,
    required this.physicalProperties,
    required this.glutenEffects,
    required this.analysisTimestamp,
  });

  /// 지방 없음 결과
  factory FatAnalysisResult.noFat() {
    return FatAnalysisResult(
      fatClassification: {'dominantFatType': 'none'},
      totalFatWeight: 0.0,
      fatPercentage: 0.0,
      physicalProperties: {},
      glutenEffects: {},
      analysisTimestamp: DateTime.now(),
    );
  }

  /// 빈 결과 (오류 시)
  factory FatAnalysisResult.empty() {
    return FatAnalysisResult(
      fatClassification: {},
      totalFatWeight: 0.0,
      fatPercentage: 0.0,
      physicalProperties: {},
      glutenEffects: {},
      analysisTimestamp: DateTime.now(),
    );
  }

  /// 지방 사용 여부
  bool get hasFat => totalFatWeight > 0;

  /// 지방 타입 텍스트
  String get fatTypeText {
    final dominantType =
        fatClassification['dominantFatType'] as String? ?? 'none';
    switch (dominantType) {
      case 'solid':
        return '고체지방 주도형';
      case 'liquid':
        return '액체지방 주도형';
      case 'mixed':
        return '혼합지방형';
      default:
        return '지방 없음';
    }
  }

  /// 지방 함량 텍스트
  String get fatPercentageText {
    if (!hasFat) return '0%';
    return '${fatPercentage.toStringAsFixed(1)}%';
  }

  /// 크리밍 능력 텍스트
  String get creamingAbilityText {
    final ability = physicalProperties['creamingAbility'] as String? ?? 'none';
    switch (ability) {
      case 'excellent':
        return '우수';
      case 'good':
        return '양호';
      case 'limited':
        return '제한적';
      default:
        return '없음';
    }
  }

  /// 쇼트닝 효과 텍스트
  String get shorteningEffectText {
    final effect = glutenEffects['shorteningEffect'] as String? ?? 'minimal';
    switch (effect) {
      case 'strong':
        return '강함';
      case 'moderate':
        return '보통';
      case 'mild':
        return '약함';
      default:
        return '미미';
    }
  }

  /// 질감 효과 텍스트
  String get textureEffectText {
    final effect = glutenEffects['textureEffect'] as String? ?? 'normal';
    switch (effect) {
      case 'flaky_tender':
        return '바삭하고 부드러움';
      case 'moist_tender':
        return '촉촉하고 부드러움';
      case 'tender':
        return '부드러움';
      case 'slightly_tender':
        return '약간 부드러움';
      default:
        return '보통';
    }
  }

  /// 볼륨 영향 텍스트
  String get volumeEffectText {
    final effect = glutenEffects['volumeEffect'] as String? ?? 'normal';
    switch (effect) {
      case 'significantly_reduced':
        return '크게 감소';
      case 'reduced':
        return '감소';
      default:
        return '정상';
    }
  }

  /// 가소성 지수 텍스트
  String get plasticityText {
    final index = physicalProperties['plasticityIndex'] as double? ?? 0.0;
    if (index >= 8.0) return '매우 높음 (${index.toStringAsFixed(1)})';
    if (index >= 6.0) return '높음 (${index.toStringAsFixed(1)})';
    if (index >= 4.0) return '보통 (${index.toStringAsFixed(1)})';
    if (index >= 2.0) return '낮음 (${index.toStringAsFixed(1)})';
    return '없음';
  }
}
