import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/ingredient.dart';

/// 재료 분석 모듈
/// 
/// 재료의 품질, 대체 재료 제안, 재료 간 상호작용을 분석합니다.
class IngredientAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'ingredient_analysis';
  static const String moduleVersion = '1.0.0';
  
  IngredientAnalysisModule() : super(
    name: moduleName,
    version: moduleVersion,
    description: '재료 품질 및 상호작용 분석 모듈',
    priority: 2, // 레시피 분석 후 실행
    dependencies: ['recipe_analysis'], // 레시피 분석 결과 참조
    category: AnalysisModuleCategory.ingredient,
    initialConfiguration: {
      'enable_quality_assessment': true,
      'enable_substitution_suggestions': true,
      'enable_interaction_analysis': true,
      'enable_nutritional_analysis': true,
      'enable_cost_analysis': false,
      'quality_factors': {
        'freshness_weight': 0.4,
        'origin_weight': 0.3,
        'processing_weight': 0.3,
      },
    },
  );

  @override
  Future<void> onInitialize() async {
    // 재료 데이터베이스 로드, 품질 기준 초기화 등
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    return request.ingredients.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final ingredients = request.ingredients;
    final recipe = request.recipe;
    final options = request.options;
    
    final results = <String, dynamic>{};
    
    try {
      // 1. 기본 재료 정보 분석
      results['basic_info'] = _analyzeBasicInfo(ingredients);
      
      // 2. 재료 품질 평가
      if (getConfiguration<bool>('enable_quality_assessment', true)) {
        results['quality_assessment'] = _analyzeQuality(ingredients);
      }
      
      // 3. 대체 재료 제안
      if (getConfiguration<bool>('enable_substitution_suggestions', true)) {
        results['substitution_suggestions'] = _generateSubstitutions(ingredients, recipe);
      }
      
      // 4. 재료 간 상호작용 분석
      if (getConfiguration<bool>('enable_interaction_analysis', true)) {
        results['interaction_analysis'] = _analyzeInteractions(ingredients);
      }
      
      // 5. 영양 분석 (옵션)
      if (getConfiguration<bool>('enable_nutritional_analysis', true) && 
          options.includeNutritionalAnalysis) {
        results['nutritional_analysis'] = _analyzeNutrition(ingredients);
      }
      
      // 6. 비용 분석 (옵션)
      if (getConfiguration<bool>('enable_cost_analysis', false) && 
          options.includeCostAnalysis) {
        results['cost_analysis'] = _analyzeCost(ingredients);
      }
      
      // 7. 전체 점수 계산
      results['overall_score'] = _calculateOverallScore(results);
      
      // 8. 추천 사항 생성
      if (options.generateRecommendations) {
        results['recommendations'] = _generateRecommendations(ingredients, results);
      }
      
    } catch (e) {
      throw AnalysisProcessingException(
        '재료 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
    
    return results;
  } 
 /// 기본 재료 정보 분석
  Map<String, dynamic> _analyzeBasicInfo(List<Ingredient> ingredients) {
    final categories = <String, List<Ingredient>>{};
    final totalWeight = ingredients.fold<double>(0, (sum, ingredient) => sum + ingredient.amount);
    
    // 재료 카테고리별 분류
    for (final ingredient in ingredients) {
      final category = _categorizeIngredient(ingredient.name);
      categories.putIfAbsent(category, () => []).add(ingredient);
    }
    
    return {
      'total_ingredients': ingredients.length,
      'total_weight': totalWeight,
      'categories': categories.map((key, value) => MapEntry(key, {
        'count': value.length,
        'weight': value.fold<double>(0, (sum, ingredient) => sum + ingredient.amount),
        'percentage': (value.fold<double>(0, (sum, ingredient) => sum + ingredient.amount) / totalWeight * 100),
        'ingredients': value.map((i) => i.name).toList(),
      })),
      'weight_distribution': _calculateWeightDistribution(ingredients),
      'unit_analysis': _analyzeUnits(ingredients),
    };
  }

  /// 재료 카테고리 분류
  String _categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    // 곡물류
    if (name.contains('밀가루') || name.contains('flour') || 
        name.contains('쌀') || name.contains('귀리') || name.contains('보리')) {
      return '곡물류';
    }
    
    // 유제품
    if (name.contains('우유') || name.contains('milk') || name.contains('버터') || 
        name.contains('치즈') || name.contains('크림') || name.contains('요거트')) {
      return '유제품';
    }
    
    // 달걀류
    if (name.contains('달걀') || name.contains('계란') || name.contains('egg')) {
      return '달걀류';
    }
    
    // 당류
    if (name.contains('설탕') || name.contains('sugar') || name.contains('꿀') || 
        name.contains('시럽') || name.contains('메이플')) {
      return '당류';
    }
    
    // 지방류
    if (name.contains('기름') || name.contains('oil') || name.contains('마가린') || 
        name.contains('쇼트닝') || name.contains('라드')) {
      return '지방류';
    }
    
    // 발효제
    if (name.contains('이스트') || name.contains('yeast') || name.contains('베이킹파우더') || 
        name.contains('베이킹소다') || name.contains('효모')) {
      return '발효제';
    }
    
    // 향신료/첨가물
    if (name.contains('소금') || name.contains('salt') || name.contains('바닐라') || 
        name.contains('계피') || name.contains('향료')) {
      return '향신료/첨가물';
    }
    
    // 과일류
    if (name.contains('사과') || name.contains('바나나') || name.contains('딸기') || 
        name.contains('레몬') || name.contains('오렌지')) {
      return '과일류';
    }
    
    // 견과류
    if (name.contains('아몬드') || name.contains('호두') || name.contains('땅콩') || 
        name.contains('피스타치오') || name.contains('잣')) {
      return '견과류';
    }
    
    return '기타';
  }

  /// 중량 분포 계산
  Map<String, dynamic> _calculateWeightDistribution(List<Ingredient> ingredients) {
    final totalWeight = ingredients.fold<double>(0, (sum, ingredient) => sum + ingredient.amount);
    final distribution = <String, double>{};
    
    for (final ingredient in ingredients) {
      final percentage = (ingredient.amount / totalWeight) * 100;
      distribution[ingredient.name] = percentage;
    }
    
    // 상위 5개 재료
    final sortedIngredients = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'distribution': distribution,
      'top_5_ingredients': sortedIngredients.take(5).map((e) => {
        'name': e.key,
        'percentage': e.value,
      }).toList(),
      'dominant_ingredient': sortedIngredients.first.key,
      'dominant_percentage': sortedIngredients.first.value,
    };
  }

  /// 단위 분석
  Map<String, dynamic> _analyzeUnits(List<Ingredient> ingredients) {
    final unitCounts = <String, int>{};
    final unitTypes = <String, List<String>>{};
    
    for (final ingredient in ingredients) {
      final unit = ingredient.unit.toLowerCase();
      unitCounts[unit] = (unitCounts[unit] ?? 0) + 1;
      
      final unitType = _categorizeUnit(unit);
      unitTypes.putIfAbsent(unitType, () => []).add(ingredient.name);
    }
    
    return {
      'unit_counts': unitCounts,
      'unit_types': unitTypes,
      'consistency_score': _calculateUnitConsistency(unitCounts),
      'conversion_needed': _identifyConversionNeeds(ingredients),
    };
  }

  /// 단위 카테고리 분류
  String _categorizeUnit(String unit) {
    if (['g', 'kg', 'gram', 'kilogram'].contains(unit)) return '중량';
    if (['ml', 'l', 'liter', 'milliliter'].contains(unit)) return '부피';
    if (['개', 'ea', 'piece', 'pcs'].contains(unit)) return '개수';
    if (['큰술', 'tbsp', 'tablespoon'].contains(unit)) return '큰술';
    if (['작은술', 'tsp', 'teaspoon'].contains(unit)) return '작은술';
    if (['컵', 'cup'].contains(unit)) return '컵';
    return '기타';
  }

  /// 단위 일관성 점수 계산
  double _calculateUnitConsistency(Map<String, int> unitCounts) {
    if (unitCounts.isEmpty) return 0.0;
    
    final totalIngredients = unitCounts.values.reduce((a, b) => a + b);
    final mostCommonUnit = unitCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    return (mostCommonUnit.value / totalIngredients) * 100;
  }

  /// 단위 변환 필요성 식별
  List<Map<String, dynamic>> _identifyConversionNeeds(List<Ingredient> ingredients) {
    final conversions = <Map<String, dynamic>>[];
    
    for (final ingredient in ingredients) {
      final unit = ingredient.unit.toLowerCase();
      
      // 비표준 단위 식별
      if (!['g', 'ml', 'kg', 'l'].contains(unit)) {
        String suggestedUnit = 'g';
        String reason = '표준 중량 단위 사용 권장';
        
        if (['큰술', 'tbsp', '작은술', 'tsp', '컵', 'cup'].contains(unit)) {
          suggestedUnit = 'ml';
          reason = '정확한 부피 측정을 위해';
        }
        
        conversions.add({
          'ingredient': ingredient.name,
          'current_unit': ingredient.unit,
          'suggested_unit': suggestedUnit,
          'reason': reason,
        });
      }
    }
    
    return conversions;
  }  
/// 재료 품질 평가
  Map<String, dynamic> _analyzeQuality(List<Ingredient> ingredients) {
    final qualityFactors = getConfiguration<Map<String, dynamic>>('quality_factors', {
      'freshness_weight': 0.4,
      'origin_weight': 0.3,
      'processing_weight': 0.3,
    });
    
    final qualityScores = <String, Map<String, dynamic>>{};
    double totalQualityScore = 0.0;
    
    for (final ingredient in ingredients) {
      final quality = _evaluateIngredientQuality(ingredient, qualityFactors);
      qualityScores[ingredient.name] = quality;
      totalQualityScore += quality['overall_score'] as double;
    }
    
    return {
      'individual_scores': qualityScores,
      'average_quality': totalQualityScore / ingredients.length,
      'quality_grade': _getQualityGrade(totalQualityScore / ingredients.length),
      'quality_issues': _identifyQualityIssues(qualityScores),
      'improvement_suggestions': _generateQualityImprovements(qualityScores),
    };
  }

  /// 개별 재료 품질 평가
  Map<String, dynamic> _evaluateIngredientQuality(Ingredient ingredient, Map<String, dynamic> weights) {
    final name = ingredient.name.toLowerCase();
    
    // 신선도 점수 (추정)
    double freshnessScore = _estimateFreshness(name);
    
    // 원산지 점수 (추정)
    double originScore = _estimateOrigin(name);
    
    // 가공도 점수 (추정)
    double processingScore = _estimateProcessing(name);
    
    // 가중 평균 계산
    final overallScore = 
        (freshnessScore * (weights['freshness_weight'] as double)) +
        (originScore * (weights['origin_weight'] as double)) +
        (processingScore * (weights['processing_weight'] as double));
    
    return {
      'freshness_score': freshnessScore,
      'origin_score': originScore,
      'processing_score': processingScore,
      'overall_score': overallScore,
      'grade': _getQualityGrade(overallScore),
      'factors': _getQualityFactors(name),
    };
  }

  /// 신선도 추정
  double _estimateFreshness(String ingredientName) {
    // 실제 구현에서는 유통기한, 보관 조건 등을 고려
    if (ingredientName.contains('유기농') || ingredientName.contains('organic')) return 9.0;
    if (ingredientName.contains('신선') || ingredientName.contains('fresh')) return 8.5;
    if (ingredientName.contains('냉동') || ingredientName.contains('frozen')) return 7.0;
    if (ingredientName.contains('건조') || ingredientName.contains('dried')) return 6.5;
    if (ingredientName.contains('통조림') || ingredientName.contains('canned')) return 6.0;
    
    return 7.5; // 기본값
  }

  /// 원산지 점수 추정
  double _estimateOrigin(String ingredientName) {
    // 실제 구현에서는 원산지 정보를 데이터베이스에서 조회
    if (ingredientName.contains('국산') || ingredientName.contains('local')) return 9.0;
    if (ingredientName.contains('유럽') || ingredientName.contains('european')) return 8.0;
    if (ingredientName.contains('미국') || ingredientName.contains('usa')) return 7.5;
    if (ingredientName.contains('중국') || ingredientName.contains('china')) return 6.0;
    
    return 7.0; // 기본값
  }

  /// 가공도 점수 추정
  double _estimateProcessing(String ingredientName) {
    // 가공도가 낮을수록 높은 점수
    if (ingredientName.contains('무첨가') || ingredientName.contains('natural')) return 9.0;
    if (ingredientName.contains('유기농') || ingredientName.contains('organic')) return 8.5;
    if (ingredientName.contains('정제') || ingredientName.contains('refined')) return 6.0;
    if (ingredientName.contains('인공') || ingredientName.contains('artificial')) return 4.0;
    
    return 7.0; // 기본값
  }

  /// 품질 등급 계산
  String _getQualityGrade(double score) {
    if (score >= 9.0) return 'A+';
    if (score >= 8.0) return 'A';
    if (score >= 7.0) return 'B';
    if (score >= 6.0) return 'C';
    return 'D';
  }

  /// 품질 요인 분석
  List<String> _getQualityFactors(String ingredientName) {
    final factors = <String>[];
    
    if (ingredientName.contains('유기농')) factors.add('유기농 인증');
    if (ingredientName.contains('무첨가')) factors.add('무첨가');
    if (ingredientName.contains('국산')) factors.add('국내산');
    if (ingredientName.contains('프리미엄')) factors.add('프리미엄 등급');
    if (ingredientName.contains('신선')) factors.add('신선도 우수');
    
    return factors;
  }

  /// 품질 문제 식별
  List<Map<String, dynamic>> _identifyQualityIssues(Map<String, Map<String, dynamic>> qualityScores) {
    final issues = <Map<String, dynamic>>[];
    
    for (final entry in qualityScores.entries) {
      final ingredientName = entry.key;
      final scores = entry.value;
      final overallScore = scores['overall_score'] as double;
      
      if (overallScore < 6.0) {
        issues.add({
          'ingredient': ingredientName,
          'issue': '품질 점수 낮음',
          'score': overallScore,
          'severity': 'high',
          'recommendation': '더 높은 품질의 재료로 교체 권장',
        });
      } else if (overallScore < 7.0) {
        issues.add({
          'ingredient': ingredientName,
          'issue': '품질 개선 여지 있음',
          'score': overallScore,
          'severity': 'medium',
          'recommendation': '품질 향상을 위한 대안 검토',
        });
      }
    }
    
    return issues;
  }

  /// 품질 개선 제안
  List<Map<String, dynamic>> _generateQualityImprovements(Map<String, Map<String, dynamic>> qualityScores) {
    final improvements = <Map<String, dynamic>>[];
    
    for (final entry in qualityScores.entries) {
      final ingredientName = entry.key;
      final scores = entry.value;
      final freshnessScore = scores['freshness_score'] as double;
      final originScore = scores['origin_score'] as double;
      final processingScore = scores['processing_score'] as double;
      
      if (freshnessScore < 7.0) {
        improvements.add({
          'ingredient': ingredientName,
          'aspect': '신선도',
          'current_score': freshnessScore,
          'suggestion': '더 신선한 재료 사용 또는 보관 방법 개선',
          'expected_improvement': 1.5,
        });
      }
      
      if (originScore < 7.0) {
        improvements.add({
          'ingredient': ingredientName,
          'aspect': '원산지',
          'current_score': originScore,
          'suggestion': '신뢰할 수 있는 원산지의 재료로 교체',
          'expected_improvement': 1.0,
        });
      }
      
      if (processingScore < 7.0) {
        improvements.add({
          'ingredient': ingredientName,
          'aspect': '가공도',
          'current_score': processingScore,
          'suggestion': '덜 가공된 자연 재료 사용',
          'expected_improvement': 1.2,
        });
      }
    }
    
    return improvements;
  }  
/// 대체 재료 제안
  Map<String, dynamic> _generateSubstitutions(List<Ingredient> ingredients, recipe) {
    final substitutions = <String, List<Map<String, dynamic>>>{};
    final emergencySubstitutions = <String, List<Map<String, dynamic>>>{};
    
    for (final ingredient in ingredients) {
      final subs = _findSubstitutes(ingredient);
      if (subs.isNotEmpty) {
        substitutions[ingredient.name] = subs;
      }
      
      final emergencySubs = _findEmergencySubstitutes(ingredient);
      if (emergencySubs.isNotEmpty) {
        emergencySubstitutions[ingredient.name] = emergencySubs;
      }
    }
    
    return {
      'substitutions': substitutions,
      'emergency_substitutions': emergencySubstitutions,
      'substitution_impact': _analyzeSubstitutionImpact(substitutions),
      'cost_comparison': _compareSubstitutionCosts(substitutions),
    };
  }

  /// 대체 재료 찾기
  List<Map<String, dynamic>> _findSubstitutes(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();
    final substitutes = <Map<String, dynamic>>[];
    
    // 밀가루 대체재
    if (name.contains('밀가루') || name.contains('flour')) {
      substitutes.addAll([
        {
          'name': '아몬드 가루',
          'ratio': 0.25,
          'notes': '글루텐 프리, 단백질 함량 높음',
          'impact': '식감이 더 촉촉해짐',
          'suitability': 'high',
        },
        {
          'name': '쌀가루',
          'ratio': 0.7,
          'notes': '글루텐 프리, 가벼운 식감',
          'impact': '부드러운 식감',
          'suitability': 'medium',
        },
        {
          'name': '귀리가루',
          'ratio': 0.8,
          'notes': '식이섬유 풍부',
          'impact': '고소한 맛 추가',
          'suitability': 'medium',
        },
      ]);
    }
    
    // 설탕 대체재
    if (name.contains('설탕') || name.contains('sugar')) {
      substitutes.addAll([
        {
          'name': '꿀',
          'ratio': 0.75,
          'notes': '수분 함량 높음, 액체량 조절 필요',
          'impact': '더 촉촉하고 진한 맛',
          'suitability': 'high',
        },
        {
          'name': '메이플 시럽',
          'ratio': 0.75,
          'notes': '독특한 풍미, 액체량 조절 필요',
          'impact': '메이플 향 추가',
          'suitability': 'medium',
        },
        {
          'name': '코코넛 설탕',
          'ratio': 1.0,
          'notes': '낮은 혈당 지수',
          'impact': '약간의 코코넛 향',
          'suitability': 'high',
        },
      ]);
    }
    
    // 버터 대체재
    if (name.contains('버터') || name.contains('butter')) {
      substitutes.addAll([
        {
          'name': '식물성 오일',
          'ratio': 0.75,
          'notes': '포화지방 적음',
          'impact': '더 가벼운 식감',
          'suitability': 'medium',
        },
        {
          'name': '아보카도',
          'ratio': 0.5,
          'notes': '건강한 지방, 으깨서 사용',
          'impact': '더 촉촉하고 진한 색',
          'suitability': 'medium',
        },
        {
          'name': '그릭 요거트',
          'ratio': 0.5,
          'notes': '단백질 풍부, 칼로리 낮음',
          'impact': '더 부드럽고 촉촉함',
          'suitability': 'high',
        },
      ]);
    }
    
    // 달걀 대체재
    if (name.contains('달걀') || name.contains('계란') || name.contains('egg')) {
      substitutes.addAll([
        {
          'name': '아쿠아파바',
          'ratio': 3.0, // 3큰술 = 달걀 1개
          'notes': '콩 삶은 물, 비건 옵션',
          'impact': '비슷한 결합력',
          'suitability': 'high',
        },
        {
          'name': '아마씨겔',
          'ratio': 1.0, // 1큰술 아마씨 + 3큰술 물
          'notes': '오메가3 풍부',
          'impact': '약간 견과류 맛',
          'suitability': 'medium',
        },
        {
          'name': '바나나',
          'ratio': 0.25, // 1/4개 = 달걀 1개
          'notes': '으깨서 사용, 단맛 추가',
          'impact': '더 촉촉하고 단맛',
          'suitability': 'medium',
        },
      ]);
    }
    
    return substitutes;
  }

  /// 응급 대체재 찾기 (집에서 쉽게 구할 수 있는 것들)
  List<Map<String, dynamic>> _findEmergencySubstitutes(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();
    final emergencySubstitutes = <Map<String, dynamic>>[];
    
    if (name.contains('베이킹파우더')) {
      emergencySubstitutes.add({
        'name': '베이킹소다 + 식초',
        'ratio': '1:1',
        'recipe': '베이킹소다 1/2작은술 + 식초 1/2작은술',
        'notes': '즉시 사용해야 함',
        'availability': 'high',
      });
    }
    
    if (name.contains('버터밀크')) {
      emergencySubstitutes.add({
        'name': '우유 + 레몬즙',
        'ratio': '1컵 우유 + 1큰술 레몬즙',
        'recipe': '5분간 둔 후 사용',
        'notes': '산성도 비슷함',
        'availability': 'high',
      });
    }
    
    if (name.contains('브라운슈가')) {
      emergencySubstitutes.add({
        'name': '백설탕 + 당밀',
        'ratio': '1컵 백설탕 + 2큰술 당밀',
        'recipe': '잘 섞어서 사용',
        'notes': '당밀 대신 꿀 사용 가능',
        'availability': 'medium',
      });
    }
    
    return emergencySubstitutes;
  }

  /// 대체재 영향 분석
  Map<String, dynamic> _analyzeSubstitutionImpact(Map<String, List<Map<String, dynamic>>> substitutions) {
    final impacts = <String, Map<String, dynamic>>{};
    
    for (final entry in substitutions.entries) {
      final ingredientName = entry.key;
      final subs = entry.value;
      
      final highSuitability = subs.where((s) => s['suitability'] == 'high').length;
      final mediumSuitability = subs.where((s) => s['suitability'] == 'medium').length;
      
      impacts[ingredientName] = {
        'substitution_difficulty': _calculateSubstitutionDifficulty(subs),
        'flavor_impact': _assessFlavorImpact(subs),
        'texture_impact': _assessTextureImpact(subs),
        'nutritional_impact': _assessNutritionalImpact(subs),
        'availability_score': highSuitability * 3 + mediumSuitability * 2,
      };
    }
    
    return {
      'individual_impacts': impacts,
      'overall_substitution_feasibility': _calculateOverallFeasibility(impacts),
    };
  }

  /// 대체 난이도 계산
  String _calculateSubstitutionDifficulty(List<Map<String, dynamic>> substitutes) {
    final highSuitability = substitutes.where((s) => s['suitability'] == 'high').length;
    
    if (highSuitability >= 2) return 'easy';
    if (highSuitability >= 1) return 'medium';
    return 'difficult';
  }

  /// 맛 영향 평가
  String _assessFlavorImpact(List<Map<String, dynamic>> substitutes) {
    final impacts = substitutes.map((s) => s['impact'] as String).toList();
    
    if (impacts.any((i) => i.contains('진한') || i.contains('강한'))) return 'significant';
    if (impacts.any((i) => i.contains('약간') || i.contains('미묘'))) return 'moderate';
    return 'minimal';
  }

  /// 식감 영향 평가
  String _assessTextureImpact(List<Map<String, dynamic>> substitutes) {
    final impacts = substitutes.map((s) => s['impact'] as String).toList();
    
    if (impacts.any((i) => i.contains('촉촉') || i.contains('부드럽'))) return 'positive';
    if (impacts.any((i) => i.contains('거칠') || i.contains('딱딱'))) return 'negative';
    return 'neutral';
  }

  /// 영양 영향 평가
  String _assessNutritionalImpact(List<Map<String, dynamic>> substitutes) {
    final notes = substitutes.map((s) => s['notes'] as String).toList();
    
    if (notes.any((n) => n.contains('단백질') || n.contains('식이섬유') || n.contains('오메가'))) return 'improved';
    if (notes.any((n) => n.contains('칼로리 낮음') || n.contains('지방 적음'))) return 'healthier';
    return 'similar';
  }

  /// 전체 대체 가능성 계산
  double _calculateOverallFeasibility(Map<String, Map<String, dynamic>> impacts) {
    if (impacts.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (final impact in impacts.values) {
      final availabilityScore = impact['availability_score'] as int;
      final difficulty = impact['substitution_difficulty'] as String;
      
      double score = availabilityScore.toDouble();
      if (difficulty == 'easy') score *= 1.2;
      else if (difficulty == 'difficult') score *= 0.8;
      
      totalScore += score;
    }
    
    return (totalScore / impacts.length).clamp(0.0, 10.0);
  }

  /// 대체재 비용 비교
  Map<String, dynamic> _compareSubstitutionCosts(Map<String, List<Map<String, dynamic>>> substitutions) {
    // 실제 구현에서는 실시간 가격 데이터를 사용
    final costComparisons = <String, Map<String, dynamic>>{};
    
    for (final entry in substitutions.entries) {
      final ingredientName = entry.key;
      final subs = entry.value;
      
      final costAnalysis = <String, dynamic>{};
      for (final sub in subs) {
        final subName = sub['name'] as String;
        costAnalysis[subName] = {
          'relative_cost': _estimateRelativeCost(ingredientName, subName),
          'cost_category': _categorizeCost(subName),
        };
      }
      
      costComparisons[ingredientName] = costAnalysis;
    }
    
    return {
      'cost_comparisons': costComparisons,
      'budget_friendly_options': _identifyBudgetOptions(costComparisons),
      'premium_options': _identifyPremiumOptions(costComparisons),
    };
  }

  /// 상대적 비용 추정
  double _estimateRelativeCost(String original, String substitute) {
    // 실제 구현에서는 가격 데이터베이스 조회
    final costMultipliers = {
      '아몬드 가루': 3.0,
      '코코넛 설탕': 2.5,
      '메이플 시럽': 2.0,
      '그릭 요거트': 1.5,
      '꿀': 1.3,
      '쌀가루': 1.1,
      '식물성 오일': 0.9,
      '바나나': 0.8,
    };
    
    return costMultipliers[substitute] ?? 1.0;
  }

  /// 비용 카테고리 분류
  String _categorizeCost(String substitute) {
    final costMultiplier = _estimateRelativeCost('', substitute);
    
    if (costMultiplier >= 2.0) return 'premium';
    if (costMultiplier >= 1.5) return 'expensive';
    if (costMultiplier <= 0.8) return 'budget';
    return 'standard';
  }

  /// 예산 친화적 옵션 식별
  List<Map<String, dynamic>> _identifyBudgetOptions(Map<String, Map<String, dynamic>> costComparisons) {
    final budgetOptions = <Map<String, dynamic>>[];
    
    for (final entry in costComparisons.entries) {
      final ingredientName = entry.key;
      final comparisons = entry.value;
      
      for (final subEntry in comparisons.entries) {
        final subName = subEntry.key;
        final subData = subEntry.value as Map<String, dynamic>;
        
        if (subData['cost_category'] == 'budget') {
          budgetOptions.add({
            'original': ingredientName,
            'substitute': subName,
            'savings': '약 ${((1 - (subData['relative_cost'] as double)) * 100).round()}% 절약',
          });
        }
      }
    }
    
    return budgetOptions;
  }

  /// 프리미엄 옵션 식별
  List<Map<String, dynamic>> _identifyPremiumOptions(Map<String, Map<String, dynamic>> costComparisons) {
    final premiumOptions = <Map<String, dynamic>>[];
    
    for (final entry in costComparisons.entries) {
      final ingredientName = entry.key;
      final comparisons = entry.value;
      
      for (final subEntry in comparisons.entries) {
        final subName = subEntry.key;
        final subData = subEntry.value as Map<String, dynamic>;
        
        if (subData['cost_category'] == 'premium') {
          premiumOptions.add({
            'original': ingredientName,
            'substitute': subName,
            'premium': '약 ${(((subData['relative_cost'] as double) - 1) * 100).round()}% 추가 비용',
          });
        }
      }
    }
    
    return premiumOptions;
  }  /
// 재료 간 상호작용 분석
  Map<String, dynamic> _analyzeInteractions(List<Ingredient> ingredients) {
    final interactions = <Map<String, dynamic>>[];
    final synergies = <Map<String, dynamic>>[];
    final conflicts = <Map<String, dynamic>>[];
    
    // 모든 재료 쌍에 대해 상호작용 분석
    for (int i = 0; i < ingredients.length; i++) {
      for (int j = i + 1; j < ingredients.length; j++) {
        final ingredient1 = ingredients[i];
        final ingredient2 = ingredients[j];
        
        final interaction = _analyzeIngredientPair(ingredient1, ingredient2);
        if (interaction != null) {
          interactions.add(interaction);
          
          if (interaction['type'] == 'synergy') {
            synergies.add(interaction);
          } else if (interaction['type'] == 'conflict') {
            conflicts.add(interaction);
          }
        }
      }
    }
    
    return {
      'total_interactions': interactions.length,
      'synergies': synergies,
      'conflicts': conflicts,
      'interaction_score': _calculateInteractionScore(synergies, conflicts),
      'chemical_reactions': _identifyChemicalReactions(ingredients),
      'flavor_combinations': _analyzeFlavorCombinations(ingredients),
    };
  }

  /// 재료 쌍 상호작용 분석
  Map<String, dynamic>? _analyzeIngredientPair(Ingredient ingredient1, Ingredient ingredient2) {
    final name1 = ingredient1.name.toLowerCase();
    final name2 = ingredient2.name.toLowerCase();
    
    // 시너지 효과
    if (_checkSynergy(name1, name2)) {
      return {
        'ingredient1': ingredient1.name,
        'ingredient2': ingredient2.name,
        'type': 'synergy',
        'effect': _getSynergyEffect(name1, name2),
        'strength': _getSynergyStrength(name1, name2),
        'description': _getSynergyDescription(name1, name2),
      };
    }
    
    // 충돌/갈등
    if (_checkConflict(name1, name2)) {
      return {
        'ingredient1': ingredient1.name,
        'ingredient2': ingredient2.name,
        'type': 'conflict',
        'issue': _getConflictIssue(name1, name2),
        'severity': _getConflictSeverity(name1, name2),
        'solution': _getConflictSolution(name1, name2),
      };
    }
    
    return null;
  }

  /// 시너지 효과 확인
  bool _checkSynergy(String name1, String name2) {
    final synergyPairs = {
      {'초콜릿', '바닐라'}: true,
      {'레몬', '버터'}: true,
      {'계피', '사과'}: true,
      {'꿀', '견과류'}: true,
      {'치즈', '허브'}: true,
      {'토마토', '바질'}: true,
      {'마늘', '올리브오일'}: true,
      {'생강', '꿀'}: true,
    };
    
    return synergyPairs.keys.any((pair) => 
        (name1.contains(pair.first) && name2.contains(pair.last)) ||
        (name1.contains(pair.last) && name2.contains(pair.first)));
  }

  /// 충돌 확인
  bool _checkConflict(String name1, String name2) {
    // 산성 재료와 유제품
    if (_isAcidic(name1) && _isDairy(name2) || _isAcidic(name2) && _isDairy(name1)) {
      return true;
    }
    
    // 강한 향신료 조합
    if (_isStrongSpice(name1) && _isStrongSpice(name2)) {
      return true;
    }
    
    return false;
  }

  /// 산성 재료 확인
  bool _isAcidic(String name) {
    return name.contains('레몬') || name.contains('식초') || name.contains('토마토') || 
           name.contains('요거트') || name.contains('사워크림');
  }

  /// 유제품 확인
  bool _isDairy(String name) {
    return name.contains('우유') || name.contains('크림') || name.contains('치즈') || 
           name.contains('버터');
  }

  /// 강한 향신료 확인
  bool _isStrongSpice(String name) {
    return name.contains('마늘') || name.contains('양파') || name.contains('고추') || 
           name.contains('후추') || name.contains('겨자');
  }

  /// 시너지 효과 설명
  String _getSynergyEffect(String name1, String name2) {
    if ((name1.contains('초콜릿') && name2.contains('바닐라')) ||
        (name1.contains('바닐라') && name2.contains('초콜릿'))) {
      return '풍미 증진';
    }
    if ((name1.contains('레몬') && name2.contains('버터')) ||
        (name1.contains('버터') && name2.contains('레몬'))) {
      return '산미와 고소함의 균형';
    }
    return '맛의 조화';
  }

  /// 시너지 강도
  String _getSynergyStrength(String name1, String name2) {
    // 클래식한 조합일수록 강한 시너지
    final classicPairs = ['초콜릿-바닐라', '레몬-버터', '계피-사과'];
    final pairName = '$name1-$name2';
    
    if (classicPairs.any((pair) => pairName.contains(pair.split('-')[0]) && pairName.contains(pair.split('-')[1]))) {
      return 'strong';
    }
    return 'moderate';
  }

  /// 시너지 설명
  String _getSynergyDescription(String name1, String name2) {
    return '$name1과 $name2의 조합은 서로의 맛을 보완하고 향상시킵니다.';
  }

  /// 충돌 문제
  String _getConflictIssue(String name1, String name2) {
    if (_isAcidic(name1) && _isDairy(name2) || _isAcidic(name2) && _isDairy(name1)) {
      return '산성 성분이 유제품을 응고시킬 수 있음';
    }
    if (_isStrongSpice(name1) && _isStrongSpice(name2)) {
      return '강한 향신료들이 서로 경쟁하여 맛의 균형을 해칠 수 있음';
    }
    return '재료 간 호환성 문제';
  }

  /// 충돌 심각도
  String _getConflictSeverity(String name1, String name2) {
    if (_isAcidic(name1) && _isDairy(name2) || _isAcidic(name2) && _isDairy(name1)) {
      return 'high';
    }
    return 'medium';
  }

  /// 충돌 해결책
  String _getConflictSolution(String name1, String name2) {
    if (_isAcidic(name1) && _isDairy(name2) || _isAcidic(name2) && _isDairy(name1)) {
      return '산성 재료를 나중에 추가하거나, 온도를 낮춰서 천천히 섞기';
    }
    if (_isStrongSpice(name1) && _isStrongSpice(name2)) {
      return '한 가지 향신료의 양을 줄이거나, 중성적인 재료로 균형 맞추기';
    }
    return '재료 비율 조정 또는 추가 순서 변경';
  }

  /// 상호작용 점수 계산
  double _calculateInteractionScore(List<Map<String, dynamic>> synergies, List<Map<String, dynamic>> conflicts) {
    double score = 50.0; // 기본 점수
    
    // 시너지 효과로 점수 증가
    for (final synergy in synergies) {
      final strength = synergy['strength'] as String;
      if (strength == 'strong') {
        score += 10.0;
      } else if (strength == 'moderate') {
        score += 5.0;
      }
    }
    
    // 충돌로 점수 감소
    for (final conflict in conflicts) {
      final severity = conflict['severity'] as String;
      if (severity == 'high') {
        score -= 15.0;
      } else if (severity == 'medium') {
        score -= 8.0;
      }
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// 화학 반응 식별
  List<Map<String, dynamic>> _identifyChemicalReactions(List<Ingredient> ingredients) {
    final reactions = <Map<String, dynamic>>[];
    final ingredientNames = ingredients.map((i) => i.name.toLowerCase()).toList();
    
    // 마이야르 반응
    if (ingredientNames.any((name) => name.contains('단백질') || name.contains('달걀') || name.contains('우유')) &&
        ingredientNames.any((name) => name.contains('설탕') || name.contains('꿀'))) {
      reactions.add({
        'type': '마이야르 반응',
        'description': '단백질과 당류가 가열될 때 발생하는 갈변 반응',
        'effect': '고소한 맛과 갈색 색상 생성',
        'conditions': '140°C 이상의 온도에서 활발',
      });
    }
    
    // 카라멜화
    if (ingredientNames.any((name) => name.contains('설탕') || name.contains('꿀') || name.contains('시럽'))) {
      reactions.add({
        'type': '카라멜화',
        'description': '당류가 고온에서 분해되어 카라멜이 되는 반응',
        'effect': '달콤하고 복합적인 맛, 갈색 색상',
        'conditions': '160°C 이상에서 시작',
      });
    }
    
    // 글루텐 형성
    if (ingredientNames.any((name) => name.contains('밀가루')) &&
        ingredientNames.any((name) => name.contains('물') || name.contains('우유'))) {
      reactions.add({
        'type': '글루텐 형성',
        'description': '밀가루의 단백질이 수분과 만나 글루텐 네트워크 형성',
        'effect': '반죽의 탄성과 구조 제공',
        'conditions': '적절한 수분과 반죽 과정 필요',
      });
    }
    
    return reactions;
  }

  /// 맛 조합 분석
  Map<String, dynamic> _analyzeFlavorCombinations(List<Ingredient> ingredients) {
    final flavorProfiles = <String, List<String>>{};
    
    for (final ingredient in ingredients) {
      final flavors = _getFlavorProfile(ingredient.name);
      flavorProfiles[ingredient.name] = flavors;
    }
    
    return {
      'flavor_profiles': flavorProfiles,
      'dominant_flavors': _identifyDominantFlavors(flavorProfiles),
      'flavor_balance': _assessFlavorBalance(flavorProfiles),
      'missing_elements': _identifyMissingFlavorElements(flavorProfiles),
    };
  }

  /// 재료별 맛 프로필
  List<String> _getFlavorProfile(String ingredientName) {
    final name = ingredientName.toLowerCase();
    final flavors = <String>[];
    
    if (name.contains('설탕') || name.contains('꿀')) flavors.add('단맛');
    if (name.contains('레몬') || name.contains('식초')) flavors.add('신맛');
    if (name.contains('소금')) flavors.add('짠맛');
    if (name.contains('초콜릿') || name.contains('커피')) flavors.add('쓴맛');
    if (name.contains('마늘') || name.contains('양파')) flavors.add('매운맛');
    if (name.contains('바닐라') || name.contains('계피')) flavors.add('향신료');
    if (name.contains('버터') || name.contains('크림')) flavors.add('고소함');
    if (name.contains('과일')) flavors.add('과일향');
    
    return flavors.isEmpty ? ['중성'] : flavors;
  }

  /// 주요 맛 식별
  Map<String, int> _identifyDominantFlavors(Map<String, List<String>> flavorProfiles) {
    final flavorCounts = <String, int>{};
    
    for (final flavors in flavorProfiles.values) {
      for (final flavor in flavors) {
        flavorCounts[flavor] = (flavorCounts[flavor] ?? 0) + 1;
      }
    }
    
    return flavorCounts;
  }

  /// 맛 균형 평가
  String _assessFlavorBalance(Map<String, List<String>> flavorProfiles) {
    final flavorCounts = _identifyDominantFlavors(flavorProfiles);
    
    final hasSweet = flavorCounts.containsKey('단맛');
    final hasSour = flavorCounts.containsKey('신맛');
    final hasSalty = flavorCounts.containsKey('짠맛');
    final hasBitter = flavorCounts.containsKey('쓴맛');
    
    final balanceCount = [hasSweet, hasSour, hasSalty, hasBitter].where((x) => x).length;
    
    if (balanceCount >= 3) return 'well_balanced';
    if (balanceCount == 2) return 'moderately_balanced';
    return 'needs_balance';
  }

  /// 부족한 맛 요소 식별
  List<String> _identifyMissingFlavorElements(Map<String, List<String>> flavorProfiles) {
    final flavorCounts = _identifyDominantFlavors(flavorProfiles);
    final missing = <String>[];
    
    if (!flavorCounts.containsKey('단맛')) missing.add('단맛');
    if (!flavorCounts.containsKey('신맛')) missing.add('신맛');
    if (!flavorCounts.containsKey('짠맛')) missing.add('짠맛');
    if (!flavorCounts.containsKey('향신료')) missing.add('향신료');
    
    return missing;
  }  /// 영양 분
석
  Map<String, dynamic> _analyzeNutrition(List<Ingredient> ingredients) {
    final nutritionData = <String, Map<String, double>>{};
    final totalNutrition = <String, double>{
      'calories': 0.0,
      'protein': 0.0,
      'carbs': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
      'sugar': 0.0,
    };
    
    for (final ingredient in ingredients) {
      final nutrition = _getNutritionData(ingredient);
      nutritionData[ingredient.name] = nutrition;
      
      // 총 영양소 합계
      for (final key in totalNutrition.keys) {
        totalNutrition[key] = totalNutrition[key]! + (nutrition[key] ?? 0.0);
      }
    }
    
    return {
      'individual_nutrition': nutritionData,
      'total_nutrition': totalNutrition,
      'nutrition_density': _calculateNutritionDensity(totalNutrition),
      'health_score': _calculateHealthScore(totalNutrition),
      'dietary_info': _analyzeDietaryInfo(ingredients),
      'allergen_info': _analyzeAllergens(ingredients),
    };
  }

  /// 재료별 영양 데이터 (추정치)
  Map<String, double> _getNutritionData(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();
    final amount = ingredient.amount; // 그램 단위로 가정
    
    // 실제 구현에서는 영양 데이터베이스 조회
    Map<String, double> nutritionPer100g = {};
    
    if (name.contains('밀가루')) {
      nutritionPer100g = {
        'calories': 364.0,
        'protein': 10.3,
        'carbs': 76.3,
        'fat': 0.98,
        'fiber': 2.7,
        'sugar': 0.27,
      };
    } else if (name.contains('설탕')) {
      nutritionPer100g = {
        'calories': 387.0,
        'protein': 0.0,
        'carbs': 99.98,
        'fat': 0.0,
        'fiber': 0.0,
        'sugar': 99.91,
      };
    } else if (name.contains('버터')) {
      nutritionPer100g = {
        'calories': 717.0,
        'protein': 0.85,
        'carbs': 0.06,
        'fat': 81.11,
        'fiber': 0.0,
        'sugar': 0.06,
      };
    } else if (name.contains('달걀')) {
      nutritionPer100g = {
        'calories': 155.0,
        'protein': 13.0,
        'carbs': 1.1,
        'fat': 11.0,
        'fiber': 0.0,
        'sugar': 1.1,
      };
    } else {
      // 기본값
      nutritionPer100g = {
        'calories': 200.0,
        'protein': 5.0,
        'carbs': 30.0,
        'fat': 5.0,
        'fiber': 2.0,
        'sugar': 10.0,
      };
    }
    
    // 실제 사용량에 따른 영양소 계산
    final actualNutrition = <String, double>{};
    for (final entry in nutritionPer100g.entries) {
      actualNutrition[entry.key] = (entry.value * amount) / 100.0;
    }
    
    return actualNutrition;
  }

  /// 영양 밀도 계산
  Map<String, double> _calculateNutritionDensity(Map<String, double> totalNutrition) {
    final calories = totalNutrition['calories'] ?? 1.0;
    
    return {
      'protein_density': (totalNutrition['protein'] ?? 0.0) / calories * 1000,
      'fiber_density': (totalNutrition['fiber'] ?? 0.0) / calories * 1000,
      'nutrient_density_score': _calculateNutrientDensityScore(totalNutrition),
    };
  }

  /// 영양소 밀도 점수
  double _calculateNutrientDensityScore(Map<String, double> nutrition) {
    final calories = nutrition['calories'] ?? 1.0;
    final protein = nutrition['protein'] ?? 0.0;
    final fiber = nutrition['fiber'] ?? 0.0;
    final sugar = nutrition['sugar'] ?? 0.0;
    
    // 단백질과 식이섬유는 좋고, 설탕은 나쁨
    double score = 50.0;
    score += (protein / calories) * 1000 * 0.5; // 단백질 밀도
    score += (fiber / calories) * 1000 * 0.3; // 식이섬유 밀도
    score -= (sugar / calories) * 1000 * 0.2; // 설탕 밀도 (감점)
    
    return score.clamp(0.0, 100.0);
  }

  /// 건강 점수 계산
  double _calculateHealthScore(Map<String, double> nutrition) {
    double score = 50.0; // 기본 점수
    
    final calories = nutrition['calories'] ?? 0.0;
    final protein = nutrition['protein'] ?? 0.0;
    final fiber = nutrition['fiber'] ?? 0.0;
    final sugar = nutrition['sugar'] ?? 0.0;
    final fat = nutrition['fat'] ?? 0.0;
    
    // 긍정적 요소
    if (protein > calories * 0.15 / 4) score += 10; // 단백질 15% 이상
    if (fiber > 25) score += 10; // 식이섬유 25g 이상
    
    // 부정적 요소
    if (sugar > calories * 0.10 / 4) score -= 10; // 설탕 10% 이상
    if (fat > calories * 0.35 / 9) score -= 10; // 지방 35% 이상
    
    return score.clamp(0.0, 100.0);
  }

  /// 식단 정보 분석
  Map<String, dynamic> _analyzeDietaryInfo(List<Ingredient> ingredients) {
    final dietaryFlags = <String, bool>{
      'vegetarian': true,
      'vegan': true,
      'gluten_free': true,
      'dairy_free': true,
      'nut_free': true,
      'low_carb': true,
      'keto_friendly': true,
    };
    
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      
      // 채식주의자 체크
      if (name.contains('달걀') || name.contains('꿀') || name.contains('젤라틴')) {
        dietaryFlags['vegan'] = false;
      }
      
      if (name.contains('고기') || name.contains('생선')) {
        dietaryFlags['vegetarian'] = false;
        dietaryFlags['vegan'] = false;
      }
      
      // 글루텐 프리 체크
      if (name.contains('밀가루') || name.contains('보리') || name.contains('호밀')) {
        dietaryFlags['gluten_free'] = false;
      }
      
      // 유제품 프리 체크
      if (name.contains('우유') || name.contains('버터') || name.contains('치즈') || name.contains('크림')) {
        dietaryFlags['dairy_free'] = false;
      }
      
      // 견과류 프리 체크
      if (name.contains('아몬드') || name.contains('호두') || name.contains('땅콩')) {
        dietaryFlags['nut_free'] = false;
      }
      
      // 저탄수화물 체크
      if (name.contains('설탕') || name.contains('밀가루') || name.contains('쌀')) {
        dietaryFlags['low_carb'] = false;
        dietaryFlags['keto_friendly'] = false;
      }
    }
    
    return {
      'dietary_flags': dietaryFlags,
      'suitable_diets': dietaryFlags.entries.where((e) => e.value).map((e) => e.key).toList(),
      'dietary_restrictions': dietaryFlags.entries.where((e) => !e.value).map((e) => e.key).toList(),
    };
  }

  /// 알레르기 정보 분석
  Map<String, dynamic> _analyzeAllergens(List<Ingredient> ingredients) {
    final allergens = <String>[];
    final allergenDetails = <String, List<String>>{};
    
    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();
      final ingredientAllergens = <String>[];
      
      if (name.contains('밀가루') || name.contains('글루텐')) {
        ingredientAllergens.add('글루텐');
      }
      if (name.contains('우유') || name.contains('버터') || name.contains('치즈')) {
        ingredientAllergens.add('유제품');
      }
      if (name.contains('달걀') || name.contains('계란')) {
        ingredientAllergens.add('달걀');
      }
      if (name.contains('견과') || name.contains('아몬드') || name.contains('호두')) {
        ingredientAllergens.add('견과류');
      }
      if (name.contains('콩') || name.contains('두부')) {
        ingredientAllergens.add('콩');
      }
      if (name.contains('새우') || name.contains('게') || name.contains('조개')) {
        ingredientAllergens.add('갑각류');
      }
      
      if (ingredientAllergens.isNotEmpty) {
        allergenDetails[ingredient.name] = ingredientAllergens;
        allergens.addAll(ingredientAllergens);
      }
    }
    
    return {
      'allergens': allergens.toSet().toList(),
      'allergen_details': allergenDetails,
      'allergen_count': allergens.toSet().length,
      'high_risk_allergens': _identifyHighRiskAllergens(allergens),
    };
  }

  /// 고위험 알레르기 유발 요소 식별
  List<String> _identifyHighRiskAllergens(List<String> allergens) {
    final highRiskAllergens = ['견과류', '갑각류', '달걀', '유제품'];
    return allergens.where((allergen) => highRiskAllergens.contains(allergen)).toList();
  }

  /// 비용 분석
  Map<String, dynamic> _analyzeCost(List<Ingredient> ingredients) {
    final costData = <String, Map<String, dynamic>>{};
    double totalCost = 0.0;
    
    for (final ingredient in ingredients) {
      final cost = _estimateIngredientCost(ingredient);
      costData[ingredient.name] = cost;
      totalCost += cost['total_cost'] as double;
    }
    
    return {
      'individual_costs': costData,
      'total_cost': totalCost,
      'cost_per_serving': totalCost / 4, // 4인분 기준
      'cost_breakdown': _generateCostBreakdown(costData),
      'cost_optimization': _suggestCostOptimization(costData),
    };
  }

  /// 재료별 비용 추정
  Map<String, dynamic> _estimateIngredientCost(Ingredient ingredient) {
    // 실제 구현에서는 실시간 가격 API 사용
    final pricePerUnit = _getEstimatedPrice(ingredient.name);
    final totalCost = pricePerUnit * ingredient.amount;
    
    return {
      'price_per_unit': pricePerUnit,
      'amount': ingredient.amount,
      'unit': ingredient.unit,
      'total_cost': totalCost,
      'cost_category': _categorizeCost(ingredient.name),
    };
  }

  /// 추정 가격 (단위당)
  double _getEstimatedPrice(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    // 원/g 기준 추정 가격
    if (name.contains('밀가루')) return 2.0;
    if (name.contains('설탕')) return 3.0;
    if (name.contains('버터')) return 15.0;
    if (name.contains('달걀')) return 8.0; // 개당
    if (name.contains('바닐라')) return 50.0;
    if (name.contains('초콜릿')) return 20.0;
    
    return 5.0; // 기본값
  }

  /// 비용 분석 요약
  Map<String, dynamic> _generateCostBreakdown(Map<String, Map<String, dynamic>> costData) {
    final categories = <String, double>{};
    
    for (final entry in costData.entries) {
      final cost = entry.value;
      final category = cost['cost_category'] as String;
      final totalCost = cost['total_cost'] as double;
      
      categories[category] = (categories[category] ?? 0.0) + totalCost;
    }
    
    return {
      'by_category': categories,
      'most_expensive_category': categories.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      'cost_distribution': categories,
    };
  }

  /// 비용 최적화 제안
  List<Map<String, dynamic>> _suggestCostOptimization(Map<String, Map<String, dynamic>> costData) {
    final suggestions = <Map<String, dynamic>>[];
    
    // 가장 비싼 재료들 식별
    final sortedByCost = costData.entries.toList()
      ..sort((a, b) => (b.value['total_cost'] as double).compareTo(a.value['total_cost'] as double));
    
    for (final entry in sortedByCost.take(3)) {
      final ingredientName = entry.key;
      final cost = entry.value;
      
      suggestions.add({
        'ingredient': ingredientName,
        'current_cost': cost['total_cost'],
        'suggestion': '더 저렴한 브랜드나 대용량 구매 고려',
        'potential_savings': (cost['total_cost'] as double) * 0.2, // 20% 절약 가능
      });
    }
    
    return suggestions;
  }

  /// 전체 점수 계산
  double _calculateOverallScore(Map<String, dynamic> results) {
    double score = 70.0; // 기본 점수
    
    // 품질 점수 반영
    final qualityScore = results['quality_assessment']?['average_quality'] as double? ?? 7.0;
    score += (qualityScore - 7.0) * 3; // 품질 7.0 기준으로 가감점
    
    // 상호작용 점수 반영
    final interactionScore = results['interaction_analysis']?['interaction_score'] as double? ?? 50.0;
    score += (interactionScore - 50.0) * 0.3; // 상호작용 점수 반영
    
    // 영양 점수 반영
    final healthScore = results['nutritional_analysis']?['health_score'] as double? ?? 50.0;
    score += (healthScore - 50.0) * 0.2; // 건강 점수 반영
    
    return score.clamp(0.0, 100.0);
  }

  /// 추천 사항 생성
  List<Map<String, dynamic>> _generateRecommendations(List<Ingredient> ingredients, Map<String, dynamic> results) {
    final recommendations = <Map<String, dynamic>>[];
    
    // 품질 개선 추천
    final qualityIssues = results['quality_assessment']?['quality_issues'] as List? ?? [];
    if (qualityIssues.isNotEmpty) {
      recommendations.add({
        'type': 'quality_improvement',
        'title': '재료 품질 개선',
        'description': '${qualityIssues.length}개 재료의 품질 개선이 필요합니다.',
        'priority': 'medium',
      });
    }
    
    // 대체재 추천
    final substitutions = results['substitution_suggestions']?['substitutions'] as Map? ?? {};
    if (substitutions.isNotEmpty) {
      recommendations.add({
        'type': 'substitution_available',
        'title': '대체재 활용 가능',
        'description': '${substitutions.length}개 재료에 대한 대체재가 있습니다.',
        'priority': 'low',
      });
    }
    
    // 상호작용 문제 해결
    final conflicts = results['interaction_analysis']?['conflicts'] as List? ?? [];
    if (conflicts.isNotEmpty) {
      recommendations.add({
        'type': 'interaction_conflict',
        'title': '재료 간 충돌 해결',
        'description': '${conflicts.length}개의 재료 충돌을 해결해야 합니다.',
        'priority': 'high',
      });
    }
    
    // 영양 균형 개선
    final flavorBalance = results['interaction_analysis']?['flavor_combinations']?['flavor_balance'] as String? ?? '';
    if (flavorBalance == 'needs_balance') {
      recommendations.add({
        'type': 'flavor_balance',
        'title': '맛 균형 개선',
        'description': '맛의 균형을 위해 추가 재료를 고려해보세요.',
        'priority': 'medium',
      });
    }
    
    return recommendations;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    final baseTime = 800; // 0.8초
    final ingredientTime = request.ingredients.length * 50; // 재료당 50ms
    final complexityTime = request.options.analysisDepth * 200; // 깊이당 200ms
    
    return baseTime + ingredientTime + complexityTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    final baseMemory = 8 * 1024 * 1024; // 8MB
    final ingredientMemory = request.ingredients.length * 2 * 1024; // 재료당 2KB
    
    return baseMemory + ingredientMemory;
  }

  @override
  List<String> getSupportedFeatures() {
    return [
      'quality_assessment',
      'substitution_suggestions',
      'interaction_analysis',
      'nutritional_analysis',
      'cost_analysis',
      'allergen_analysis',
      'dietary_analysis',
    ];
  }

  @override
  Map<String, dynamic> getConfigurationSchema() {
    return {
      'enable_quality_assessment': {
        'type': 'boolean',
        'default': true,
        'description': '재료 품질 평가 활성화',
      },
      'enable_substitution_suggestions': {
        'type': 'boolean',
        'default': true,
        'description': '대체재 제안 활성화',
      },
      'quality_factors': {
        'type': 'object',
        'description': '품질 평가 가중치',
        'properties': {
          'freshness_weight': {'type': 'number', 'default': 0.4},
          'origin_weight': {'type': 'number', 'default': 0.3},
          'processing_weight': {'type': 'number', 'default': 0.3},
        },
      },
    };
  }
}