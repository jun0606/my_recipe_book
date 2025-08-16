/// 재료 분석 및 감지 유틸리티
/// Sous Chef 모드에서 레시피의 재료를 분석하고 분류하는 기능을 제공합니다.

class IngredientAnalyzer {
  /// 레시피 제목을 기반으로 빵 타입 추정
  static String estimateBreadTypeFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    
    // 한국어 빵 타입
    if (lowerTitle.contains('식빵') || lowerTitle.contains('토스트')) return 'bread';
    if (lowerTitle.contains('바게트') || lowerTitle.contains('프랑스빵')) return 'baguette';
    if (lowerTitle.contains('크루아상') || lowerTitle.contains('크로와상')) return 'croissant';
    if (lowerTitle.contains('브리오슈') || lowerTitle.contains('브리오쉬')) return 'brioche';
    if (lowerTitle.contains('사워도우') || lowerTitle.contains('천연발효')) return 'sourdough';
    if (lowerTitle.contains('피자') || lowerTitle.contains('도우')) return 'pizza';
    if (lowerTitle.contains('쿠키') || lowerTitle.contains('비스킷')) return 'cookie';
    if (lowerTitle.contains('케이크') || lowerTitle.contains('스펀지')) return 'cake';
    if (lowerTitle.contains('머핀') || lowerTitle.contains('컵케이크')) return 'muffin';
    if (lowerTitle.contains('스콘')) return 'scone';
    if (lowerTitle.contains('도넛') || lowerTitle.contains('도우넛')) return 'donut';
    if (lowerTitle.contains('베이글')) return 'bagel';
    if (lowerTitle.contains('프레첼')) return 'pretzel';
    if (lowerTitle.contains('치아바타')) return 'ciabatta';
    if (lowerTitle.contains('포카치아')) return 'focaccia';
    if (lowerTitle.contains('난') || lowerTitle.contains('인도빵')) return 'naan';
    
    // 영어 빵 타입
    if (lowerTitle.contains('bread') || lowerTitle.contains('loaf')) return 'bread';
    if (lowerTitle.contains('baguette') || lowerTitle.contains('french bread')) return 'baguette';
    if (lowerTitle.contains('croissant')) return 'croissant';
    if (lowerTitle.contains('brioche')) return 'brioche';
    if (lowerTitle.contains('sourdough')) return 'sourdough';
    if (lowerTitle.contains('pizza')) return 'pizza';
    if (lowerTitle.contains('cookie') || lowerTitle.contains('biscuit')) return 'cookie';
    if (lowerTitle.contains('cake')) return 'cake';
    if (lowerTitle.contains('muffin') || lowerTitle.contains('cupcake')) return 'muffin';
    if (lowerTitle.contains('scone')) return 'scone';
    if (lowerTitle.contains('donut') || lowerTitle.contains('doughnut')) return 'donut';
    if (lowerTitle.contains('bagel')) return 'bagel';
    if (lowerTitle.contains('pretzel')) return 'pretzel';
    if (lowerTitle.contains('ciabatta')) return 'ciabatta';
    if (lowerTitle.contains('focaccia')) return 'focaccia';
    if (lowerTitle.contains('naan')) return 'naan';
    
    return 'general';
  }

  /// 제목 기반 재료 추정 (인식률 향상을 위해)
  static Map<String, List<String>> getExpectedIngredientsFromTitle(String title) {
    final breadType = estimateBreadTypeFromTitle(title);
    
    switch (breadType) {
      case 'bread':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', '우유', 'water', 'milk'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
          'sugar': ['설탕', 'sugar'],
        };
      case 'baguette':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
        };
      case 'croissant':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['우유', '물', 'milk', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'fat': ['버터', 'butter'],
          'salt': ['소금', 'salt'],
          'sugar': ['설탕', 'sugar'],
        };
      case 'pizza':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
          'fat': ['올리브오일', 'olive oil', '기름', 'oil'],
        };
      case 'cookie':
        return {
          'flour': ['박력분', '밀가루', 'cake flour', 'flour'],
          'fat': ['버터', '마가린', 'butter', 'margarine'],
          'sugar': ['설탕', '흑설탕', 'sugar', 'brown sugar'],
          'eggs': ['계란', '달걀', 'egg', 'eggs'],
        };
      case 'cake':
        return {
          'flour': ['박력분', '밀가루', 'cake flour', 'flour'],
          'sugar': ['설탕', 'sugar'],
          'eggs': ['계란', '달걀', 'egg', 'eggs'],
          'fat': ['버터', '기름', 'butter', 'oil'],
          'liquid': ['우유', '물', 'milk', 'water'],
          'leavening': ['베이킹파우더', 'baking powder'],
        };
      default:
        return {
          'flour': ['밀가루', 'flour'],
          'liquid': ['물', '우유', 'water', 'milk'],
        };
    }
  }

  /// 레시피에서 밀가루 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findFlourIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return _isFlour(name);
    }).toList();

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final flourKeywords = expectedIngredients['flour'] ?? [];
      
      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        if (flourKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
          foundIngredients.add(ingredient);
        }
      }
    }

    return foundIngredients;
  }

  /// 레시피에서 액체 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findLiquidIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return _isLiquid(name);
    }).toList();

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final liquidKeywords = expectedIngredients['liquid'] ?? [];
      
      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        if (liquidKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
          foundIngredients.add(ingredient);
        }
      }
    }

    return foundIngredients;
  }

  /// 레시피에서 이스트 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findYeastIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return _isYeast(name);
    }).toList();

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final yeastKeywords = expectedIngredients['yeast'] ?? [];
      
      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        if (yeastKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
          foundIngredients.add(ingredient);
        }
      }
    }

    return foundIngredients;
  }

  /// 레시피에서 소금 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findSaltIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return _isSalt(name);
    }).toList();

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final saltKeywords = expectedIngredients['salt'] ?? [];
      
      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        if (saltKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
          foundIngredients.add(ingredient);
        }
      }
    }

    return foundIngredients;
  }

  /// 수분율(Hydration) 계산 (제목 기반 개선)
  /// 공식: (액체 재료 총량 / 밀가루 총량) × 100
  static double calculateHydration(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients = findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final liquidIngredients = findLiquidIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty) return 0.0;

    // 밀가루 총량 계산
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 액체 총량 계산
    double totalLiquid = 0.0;
    for (final liquid in liquidIngredients) {
      final amount = liquid['amount'] as double? ?? 0.0;
      final unit = liquid['unit'] as String? ?? 'g';
      totalLiquid += convertToGrams(amount, unit, liquid['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalLiquid / totalFlour) * 100;
  }

  /// 이스트 비율 계산 (밀가루 대비 %) (제목 기반 개선)
  static double calculateYeastPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients = findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final yeastIngredients = findYeastIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty || yeastIngredients.isEmpty) return 0.0;

    // 밀가루 총량
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 이스트 총량
    double totalYeast = 0.0;
    for (final yeast in yeastIngredients) {
      final amount = yeast['amount'] as double? ?? 0.0;
      final unit = yeast['unit'] as String? ?? 'g';
      totalYeast += convertToGrams(amount, unit, yeast['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalYeast / totalFlour) * 100;
  }

  /// 소금 비율 계산 (밀가루 대비 %) (제목 기반 개선)
  static double calculateSaltPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients = findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final saltIngredients = findSaltIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty || saltIngredients.isEmpty) return 0.0;

    // 밀가루 총량
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 소금 총량
    double totalSalt = 0.0;
    for (final salt in saltIngredients) {
      final amount = salt['amount'] as double? ?? 0.0;
      final unit = salt['unit'] as String? ?? 'g';
      totalSalt += convertToGrams(amount, unit, salt['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalSalt / totalFlour) * 100;
  }

  /// 베이커스 퍼센트 계산 (제목 기반 개선)
  /// 밀가루를 100%로 기준으로 다른 재료들의 비율 계산
  static Map<String, double> calculateBakersPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients = findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    if (flourIngredients.isEmpty) return {};

    // 밀가루 총량 계산
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour += convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    if (totalFlour == 0) return {};

    // 각 재료별 베이커스 퍼센트 계산
    final bakersPercentage = <String, double>{};
    
    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String? ?? '';
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      
      final gramsAmount = convertToGrams(amount, unit, name);
      final percentage = (gramsAmount / totalFlour) * 100;
      
      bakersPercentage[name] = percentage;
    }

    return bakersPercentage;
  }

  /// 반죽 최대양 계산 (수정된 정확한 계산식)
  /// 오븐 용량과 빵 종류에 따른 최적 반죽량 계산
  static Map<String, dynamic> calculateMaximumDoughAmount(
    List<Map<String, dynamic>> ingredients,
    {
      double ovenCapacityLiters = 30.0, // 기본 오븐 용량 (리터)
      String breadType = 'general', // 빵 종류
      String? recipeTitle,
    }
  ) {
    try {
      final flourIngredients = findFlourIngredients(ingredients, recipeTitle: recipeTitle);
      if (flourIngredients.isEmpty) {
        return {
          'maxFlourAmount': 0.0,
          'maxDoughWeight': 0.0,
          'scalingFactor': 0.0,
          'recommendation': '밀가루 재료를 찾을 수 없습니다.',
        };
      }

      // 현재 밀가루 총량
      double currentFlourAmount = 0.0;
      for (final flour in flourIngredients) {
        final amount = flour['amount'] as double? ?? 0.0;
        final unit = flour['unit'] as String? ?? 'g';
        currentFlourAmount += convertToGrams(amount, unit, flour['name'] as String? ?? '');
      }

      // 현재 총 반죽 무게 계산
      double currentTotalWeight = 0.0;
      for (final ingredient in ingredients) {
        final amount = ingredient['amount'] as double? ?? 0.0;
        final unit = ingredient['unit'] as String? ?? 'g';
        final name = ingredient['name'] as String? ?? '';
        currentTotalWeight += convertToGrams(amount, unit, name);
      }

      // 빵 종류별 오븐 점유율 (실제 베이킹 경험 기반)
      final ovenOccupancyRatio = _getBreadTypeOccupancyRatio(breadType);
      
      // 오븐 용량 기반 최대 반죽 무게 계산 (더 현실적인 공식)
      // 30L 오븐 기준: 식빵 1개(약 800g 반죽), 바게트 2개(약 600g 반죽)
      final baseCapacityGrams = ovenCapacityLiters * 25; // 1L당 약 25g 반죽 기준
      final maxDoughWeight = baseCapacityGrams * ovenOccupancyRatio;
      
      // 현재 반죽 대비 최대 밀가루량 역산
      final flourRatio = currentFlourAmount / currentTotalWeight;
      final maxFlourAmount = maxDoughWeight * flourRatio;

      // 현재 레시피 대비 스케일링 팩터
      final scalingFactor = currentTotalWeight > 0 ? maxDoughWeight / currentTotalWeight : 0.0;

      // 권장사항 생성 (더 현실적인 기준)
      String recommendation;
      if (scalingFactor > 3.0) {
        recommendation = '현재 레시피를 3배까지 확대 가능합니다 (${maxDoughWeight.toStringAsFixed(0)}g 반죽).';
      } else if (scalingFactor > 1.5) {
        recommendation = '현재 레시피를 ${scalingFactor.toStringAsFixed(1)}배 확대 가능합니다 (${maxDoughWeight.toStringAsFixed(0)}g 반죽).';
      } else if (scalingFactor >= 0.9) {
        recommendation = '현재 레시피가 오븐 용량에 적합합니다 (${currentTotalWeight.toStringAsFixed(0)}g 반죽).';
      } else {
        final reductionFactor = 1 / scalingFactor;
        recommendation = '현재 레시피가 오븐 용량을 초과합니다. ${reductionFactor.toStringAsFixed(1)}배 축소 권장 (${maxDoughWeight.toStringAsFixed(0)}g로).';
      }

      return {
        'maxFlourAmount': maxFlourAmount,
        'maxDoughWeight': maxDoughWeight,
        'scalingFactor': scalingFactor,
        'currentFlourAmount': currentFlourAmount,
        'currentTotalWeight': currentTotalWeight,
        'ovenCapacity': ovenCapacityLiters,
        'breadType': breadType,
        'recommendation': recommendation,
      };
    } catch (e) {
      return {
        'maxFlourAmount': 0.0,
        'maxDoughWeight': 0.0,
        'scalingFactor': 0.0,
        'recommendation': '계산 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 빵 종류별 오븐 점유율 반환 (실제 베이킹 경험 기반)
  static double _getBreadTypeOccupancyRatio(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return 1.0; // 기준 (30L 오븐에 식빵 1개)
      case 'baguette':
      case '바게트':
        return 0.8; // 바게트는 길지만 얇아서 조금 더 들어감
      case 'pizza':
      case '피자':
        return 1.5; // 피자는 얇게 펼쳐서 더 많이 들어감
      case 'croissant':
      case '크루아상':
        return 0.6; // 크루아상은 개별 단위가 작음
      case 'brioche':
      case '브리오슈':
        return 0.9; // 브리오슈는 밀도가 높음
      case 'sourdough':
      case '사워도우':
        return 1.1; // 사워도우는 부피가 큼
      case 'cookie':
      case '쿠키':
        return 2.0; // 쿠키는 평평해서 많이 들어감
      case 'cake':
      case '케이크':
        return 0.7; // 케이크는 높이가 있어서 적게 들어감
      case 'muffin':
      case '머핀':
        return 1.2; // 머핀은 개별 단위로 여러 개
      case 'bagel':
      case '베이글':
        return 1.3; // 베이글은 도넛 모양으로 공간 활용 좋음
      case 'scone':
      case '스콘':
        return 1.4; // 스콘은 작은 단위
      default:
        return 1.0; // 일반적인 빵류 기본값
    }
  }

  /// 재료 타입 분석
  static Map<String, List<Map<String, dynamic>>> analyzeIngredientTypes(List<Map<String, dynamic>> ingredients) {
    return {
      'flour': findFlourIngredients(ingredients),
      'liquid': findLiquidIngredients(ingredients),
      'yeast': findYeastIngredients(ingredients),
      'salt': findSaltIngredients(ingredients),
      'sugar': _findSugarIngredients(ingredients),
      'fat': _findFatIngredients(ingredients),
      'eggs': _findEggIngredients(ingredients),
      'leavening': _findLeaveningIngredients(ingredients),
      'other': _findOtherIngredients(ingredients),
    };
  }

  // === 재료 감지 로직 ===

  /// 밀가루 재료 판별 - 확장된 키워드
  static bool _isFlour(String name) {
    final lowerName = name.toLowerCase();
    final flourKeywords = [
      // 한국어 - 기본
      '밀가루', '강력분', '중력분', '박력분', '통밀가루', '호밀가루', 
      '쌀가루', '옥수수가루', '감자전분', '타피오카전분', '글루텐가루',
      // 한국어 - 확장
      '현미가루', '귀리가루', '보리가루', '메밀가루', '콩가루', '아몬드가루',
      '코코넛가루', '바나나가루', '고구마가루', '카사바가루', '퀴노아가루',
      // 영어 - 기본
      'flour', 'bread flour', 'all-purpose flour', 'cake flour',
      'whole wheat flour', 'rye flour', 'rice flour', 'corn flour',
      'potato starch', 'tapioca starch', 'cornstarch', 'gluten flour',
      // 영어 - 확장
      'brown rice flour', 'oat flour', 'barley flour', 'buckwheat flour',
      'soy flour', 'almond flour', 'coconut flour', 'banana flour',
      'sweet potato flour', 'cassava flour', 'quinoa flour', 'spelt flour',
      'chickpea flour', 'teff flour', 'amaranth flour', 'millet flour',
      // 일반적인 패턴
      '가루', 'powder', 'starch', 'meal'
    ];

    return flourKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 액체 재료 판별 - 확장된 키워드
  static bool _isLiquid(String name) {
    final lowerName = name.toLowerCase();
    final liquidKeywords = [
      // 한국어 - 기본
      '물', '우유', '생크림', '버터밀크', '요구르트', '기름', '올리브오일',
      '식용유', '버터', '마가린', '꿀', '시럽', '메이플시럽', '물엿',
      // 한국어 - 확장
      '두유', '코코넛밀크', '아몬드밀크', '오트밀크', '라이스밀크',
      '사워크림', '크림치즈', '연유', '탈지유', '전지유', '저지방우유',
      '코코넛오일', '아보카도오일', '참기름', '들기름', '포도씨오일',
      '해바라기유', '카놀라유', '아가베시럽', '현미시럽', '쌀시럽',
      // 영어 - 기본
      'water', 'milk', 'cream', 'buttermilk', 'yogurt', 'oil',
      'olive oil', 'vegetable oil', 'butter', 'margarine',
      'honey', 'syrup', 'maple syrup', 'corn syrup',
      // 영어 - 확장
      'soy milk', 'coconut milk', 'almond milk', 'oat milk', 'rice milk',
      'sour cream', 'cream cheese', 'condensed milk', 'skim milk', 'whole milk',
      'low-fat milk', 'coconut oil', 'avocado oil', 'sesame oil',
      'sunflower oil', 'canola oil', 'grapeseed oil', 'agave syrup',
      'brown rice syrup', 'rice syrup', 'molasses', 'golden syrup',
      // 액체 형태
      'liquid', 'juice', 'wine', 'beer', 'stock', 'broth', 'extract',
      'vanilla extract', 'lemon juice', 'orange juice', 'apple juice'
    ];

    return liquidKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 이스트 재료 판별 - 확장된 키워드
  static bool _isYeast(String name) {
    final lowerName = name.toLowerCase();
    final yeastKeywords = [
      // 한국어 - 기본
      '이스트', '드라이이스트', '인스턴트이스트', '액티브드라이이스트',
      '생이스트', '천연효모', '사워도우스타터',
      // 한국어 - 확장
      '효모', '발효종', '르방', '스타터', '천연발효종', '자연효모',
      '빵효모', '제빵효모', '압축효모', '냉동효모',
      // 영어 - 기본
      'yeast', 'dry yeast', 'instant yeast', 'active dry yeast',
      'fresh yeast', 'sourdough starter', 'natural yeast',
      'baker\'s yeast',
      // 영어 - 확장
      'compressed yeast', 'cake yeast', 'bread yeast', 'wild yeast',
      'levain', 'mother', 'starter culture', 'fermentation starter',
      'yeast culture', 'brewing yeast', 'pizza yeast', 'rapid-rise yeast',
      'bread machine yeast', 'nutritional yeast'
    ];

    return yeastKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 소금 재료 판별
  static bool _isSalt(String name) {
    final lowerName = name.toLowerCase();
    final saltKeywords = [
      // 한국어
      '소금', '천일염', '바다소금', '암염', '정제염',
      // 영어
      'salt', 'sea salt', 'kosher salt', 'table salt',
      'rock salt', 'himalayan salt'
    ];

    return saltKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 설탕 재료 찾기
  static List<Map<String, dynamic>> _findSugarIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final sugarKeywords = [
        '설탕', '백설탕', '흑설탕', '황설탕', '코코넛설탕',
        'sugar', 'white sugar', 'brown sugar', 'coconut sugar',
        'cane sugar', 'raw sugar', 'turbinado'
      ];
      return sugarKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 지방 재료 찾기
  static List<Map<String, dynamic>> _findFatIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        '버터', '마가린', '쇼트닝', '라드', '코코넛오일',
        'butter', 'margarine', 'shortening', 'lard', 'coconut oil'
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 계란 재료 찾기
  static List<Map<String, dynamic>> _findEggIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final eggKeywords = [
        '계란', '달걀', '계란흰자', '계란노른자',
        'egg', 'eggs', 'egg white', 'egg yolk', 'whole egg'
      ];
      return eggKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 팽창제 재료 찾기
  static List<Map<String, dynamic>> _findLeaveningIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final leaveningKeywords = [
        '베이킹파우더', '베이킹소다', '중조', '타르타르크림',
        'baking powder', 'baking soda', 'cream of tartar',
        'sodium bicarbonate'
      ];
      return leaveningKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 기타 재료 찾기
  static List<Map<String, dynamic>> _findOtherIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return !_isFlour(name) && 
             !_isLiquid(name) && 
             !_isYeast(name) && 
             !_isSalt(name);
    }).toList();
  }

  /// 단위를 그램으로 변환
  static double convertToGrams(double amount, String unit, String ingredientName) {
    final lowerUnit = unit.toLowerCase();
    
    // 이미 그램인 경우
    if (lowerUnit == 'g' || lowerUnit == 'gram' || lowerUnit == 'grams') {
      return amount;
    }
    
    // 킬로그램
    if (lowerUnit == 'kg' || lowerUnit == 'kilogram' || lowerUnit == 'kilograms') {
      return amount * 1000;
    }
    
    // 부피 단위는 재료별 밀도를 고려하여 변환
    final density = _getIngredientDensity(ingredientName);
    
    switch (lowerUnit) {
      case 'ml':
      case 'milliliter':
        return amount * density;
      case 'l':
      case 'liter':
        return amount * 1000 * density;
      case 'cup':
        return amount * 240 * density; // 1컵 = 240ml
      case 'tbsp':
      case 'tablespoon':
        return amount * 15 * density; // 1큰술 = 15ml
      case 'tsp':
      case 'teaspoon':
        return amount * 5 * density; // 1작은술 = 5ml
      default:
        return amount; // 알 수 없는 단위는 그대로 반환
    }
  }

  /// 재료별 밀도 반환 (g/ml) - 종합 제빵 과학 통합 계산식 기반 개선
  static double _getIngredientDensity(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();
    
    // 밀가루류 (정밀한 밀도 적용)
    if (_isFlour(lowerName)) {
      if (lowerName.contains('강력분') || lowerName.contains('bread flour')) return 0.65;
      if (lowerName.contains('박력분') || lowerName.contains('cake flour')) return 0.55;
      if (lowerName.contains('중력분') || lowerName.contains('all-purpose flour')) return 0.60;
      if (lowerName.contains('통밀가루') || lowerName.contains('whole wheat flour')) return 0.68;
      if (lowerName.contains('호밀가루') || lowerName.contains('rye flour')) return 0.70;
      if (lowerName.contains('쌀가루') || lowerName.contains('rice flour')) return 0.75;
      if (lowerName.contains('옥수수가루') || lowerName.contains('corn flour')) return 0.72;
      if (lowerName.contains('감자전분') || lowerName.contains('potato starch')) return 0.80;
      if (lowerName.contains('타피오카') || lowerName.contains('tapioca')) return 0.85;
      return 0.60; // 일반 밀가루 기본값
    }
    
    // 액체류 (정밀한 밀도 적용)
    if (lowerName.contains('물') || lowerName.contains('water')) return 1.00;
    if (lowerName.contains('우유') || lowerName.contains('milk')) return 1.03;
    if (lowerName.contains('생크림') || lowerName.contains('heavy cream')) return 1.01;
    if (lowerName.contains('버터밀크') || lowerName.contains('buttermilk')) return 1.03;
    if (lowerName.contains('요구르트') || lowerName.contains('yogurt')) return 1.05;
    if (lowerName.contains('식용유') || lowerName.contains('vegetable oil')) return 0.92;
    if (lowerName.contains('올리브오일') || lowerName.contains('olive oil')) return 0.91;
    if (lowerName.contains('코코넛오일') || lowerName.contains('coconut oil')) return 0.92;
    if (lowerName.contains('기름') || lowerName.contains('oil')) return 0.92;
    if (lowerName.contains('꿀') || lowerName.contains('honey')) return 1.42;
    if (lowerName.contains('메이플시럽') || lowerName.contains('maple syrup')) return 1.32;
    if (lowerName.contains('물엿') || lowerName.contains('corn syrup')) return 1.38;
    if (lowerName.contains('시럽') || lowerName.contains('syrup')) return 1.30;
    
    // 고체류 (정밀한 밀도 적용)
    if (lowerName.contains('백설탕') || lowerName.contains('white sugar')) return 0.85;
    if (lowerName.contains('흑설탕') || lowerName.contains('brown sugar')) return 0.90;
    if (lowerName.contains('설탕') || lowerName.contains('sugar')) return 0.85;
    if (lowerName.contains('소금') || lowerName.contains('salt')) return 1.20;
    if (lowerName.contains('버터') || lowerName.contains('butter')) return 0.91;
    if (lowerName.contains('마가린') || lowerName.contains('margarine')) return 0.90;
    
    // 이스트류
    if (lowerName.contains('드라이이스트') || lowerName.contains('dry yeast')) return 0.45;
    if (lowerName.contains('인스턴트이스트') || lowerName.contains('instant yeast')) return 0.45;
    if (lowerName.contains('생이스트') || lowerName.contains('fresh yeast')) return 1.05;
    if (lowerName.contains('이스트') || lowerName.contains('yeast')) return 0.45;
    
    // 계란류
    if (lowerName.contains('계란') || lowerName.contains('달걀') || lowerName.contains('egg')) return 1.03;
    
    // 기본값 (물의 밀도)
    return 1.00;
  }
}