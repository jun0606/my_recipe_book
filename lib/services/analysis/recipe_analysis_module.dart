import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/recipe.dart';

/// 레시피 분석 모듈
///
/// 레시피의 구조, 복잡도, 조리 시간, 단계별 위험도 등을 분석합니다.
class RecipeAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'recipe_analysis';
  static const String moduleVersion = '1.0.0';

  RecipeAnalysisModule()
      : super(
          name: moduleName,
          version: moduleVersion,
          description: '레시피 구조 및 특성 분석 모듈',
          priority: 1, // 높은 우선순위 (다른 모듈들이 이 결과를 참조할 수 있음)
          dependencies: [], // 의존성 없음
          category: AnalysisModuleCategory.recipe,
          initialConfiguration: {
            'enable_complexity_analysis': true,
            'enable_time_optimization': true,
            'enable_risk_assessment': true,
            'enable_technique_analysis': true,
            'complexity_weight_factors': {
              'ingredient_count': 0.3,
              'instruction_count': 0.4,
              'technique_difficulty': 0.3,
            },
          },
        );

  @override
  Future<void> onInitialize() async {
    // 레시피 분석에 필요한 리소스 초기화
    // 예: 기법 데이터베이스 로드, 복잡도 계산 모델 준비 등
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    // 레시피가 있고 유효한 경우에만 처리 가능
    return request.recipe.title.isNotEmpty &&
        request.recipe.instructions.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final recipe = request.recipe;
    final options = request.options;

    final results = <String, dynamic>{};

    try {
      // 1. 기본 레시피 정보 분석
      results['basic_info'] = _analyzeBasicInfo(recipe);

      // 2. 복잡도 분석
      if ((getConfiguration<bool>('enable_complexity_analysis', true) ?? false)) {
        results['complexity'] = _analyzeComplexity(recipe);
      }

      // 3. 조리 시간 최적화 분석
      if ((getConfiguration<bool>('enable_time_optimization', true) ?? false)) {
        results['time_optimization'] = _analyzeTimeOptimization(recipe);
      }

      // 4. 위험도 평가
      if ((getConfiguration<bool>('enable_risk_assessment', true) ?? false)) {
        results['risk_assessment'] = _analyzeRiskFactors(recipe);
      }

      // 5. 기법 분석
      if ((getConfiguration<bool>('enable_technique_analysis', true) ?? false)) {
        results['techniques'] = _analyzeTechniques(recipe);
      }

      // 6. 베이킹 특화 분석 (베이킹 레시피인 경우)
      if (recipe.isBaking) {
        results['baking_specific'] = _analyzeBakingSpecific(recipe);
      }

      // 7. 전체 점수 계산
      results['overall_score'] = _calculateOverallScore(results);

      // 8. 추천 사항 생성
      if (options.generateRecommendations) {
        results['recommendations'] = _generateRecommendations(recipe, results);
      }
    } catch (e) {
      throw AnalysisProcessingException(
        '레시피 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }

    return results;
  }

  /// 기본 레시피 정보 분석
  Map<String, dynamic> _analyzeBasicInfo(Recipe recipe) {
    return {
      'title': recipe.title,
      'category': recipe.category,
      'ingredient_count': recipe.ingredients.length,
      'instruction_count': recipe.instructions.length,
      'estimated_prep_time': recipe.prepTime,
      'estimated_cook_time': recipe.cookTime,
      'servings': recipe.servings,
      'is_baking': recipe.isBaking,
      'has_fermentation': recipe.fermentationSteps?.isNotEmpty ?? false,
      'has_oven_steps': recipe.ovenSteps?.isNotEmpty ?? false,
    };
  }

  /// 레시피 복잡도 분석
  Map<String, dynamic> _analyzeComplexity(Recipe recipe) {
    final weights =
        getConfiguration<Map<String, dynamic>>('complexity_weight_factors', {
      'ingredient_count': 0.3,
      'instruction_count': 0.4,
      'technique_difficulty': 0.3,
    }) as Map<String, dynamic>;

    // 재료 수 기반 복잡도 (1-10 스케일)
    final ingredientComplexity =
        _calculateIngredientComplexity(recipe.ingredients);

    // 지시사항 수 기반 복잡도
    final instructionComplexity =
        _calculateInstructionComplexity(recipe.instructions);

    // 기법 난이도 기반 복잡도
    final techniqueComplexity =
        _calculateTechniqueComplexity(recipe.instructions);

    // 가중 평균으로 전체 복잡도 계산
    final overallComplexity =
        (ingredientComplexity * (weights['ingredient_count'] as double)) +
            (instructionComplexity * (weights['instruction_count'] as double)) +
            (techniqueComplexity * (weights['technique_difficulty'] as double));

    return {
      'ingredient_complexity': ingredientComplexity,
      'instruction_complexity': instructionComplexity,
      'technique_complexity': techniqueComplexity,
      'overall_complexity': overallComplexity.clamp(1.0, 10.0),
      'complexity_level': _getComplexityLevel(overallComplexity),
      'factors': {
        'many_ingredients': recipe.ingredients.length > 15,
        'many_steps': recipe.instructions.length > 20,
        'advanced_techniques': techniqueComplexity > 7,
        'long_cooking_time': recipe.cookTime > 180, // 3시간 이상
      },
    };
  }

  /// 재료 복잡도 계산
  double _calculateIngredientComplexity(List ingredients) {
    final count = ingredients.length;

    // 재료 수에 따른 기본 복잡도
    double complexity = 1.0;
    if (count <= 5)
      complexity = 2.0;
    else if (count <= 10)
      complexity = 4.0;
    else if (count <= 15)
      complexity = 6.0;
    else if (count <= 20)
      complexity = 8.0;
    else
      complexity = 10.0;

    // TODO: 재료의 특수성, 구하기 어려운 정도 등을 고려한 추가 복잡도

    return complexity;
  }

  /// 지시사항 복잡도 계산
  double _calculateInstructionComplexity(List<String> instructions) {
    final count = instructions.length;

    // 지시사항 수에 따른 기본 복잡도
    double complexity = 1.0;
    if (count <= 3)
      complexity = 2.0;
    else if (count <= 6)
      complexity = 4.0;
    else if (count <= 10)
      complexity = 6.0;
    else if (count <= 15)
      complexity = 8.0;
    else
      complexity = 10.0;

    // 지시사항의 길이와 복잡성 고려
    final avgLength =
        instructions.map((i) => i.length).reduce((a, b) => a + b) /
            instructions.length;
    if (avgLength > 100) complexity += 1.0; // 긴 설명이 많으면 복잡도 증가

    return complexity.clamp(1.0, 10.0);
  }

  /// 기법 복잡도 계산
  double _calculateTechniqueComplexity(List<String> instructions) {
    final allText = instructions.join(' ').toLowerCase();
    double complexity = 1.0;

    // 고급 기법들 검출
    final advancedTechniques = {
      '템퍼링': 3.0,
      '컨피': 3.0,
      '수비드': 4.0,
      '발효': 2.5,
      '숙성': 2.0,
      '캐러멜라이제이션': 2.5,
      '마카롱': 4.0,
      '크루아상': 4.5,
      '파이': 3.0,
      '브리오슈': 3.5,
      '라미네이션': 4.0,
      '글루텐': 2.0,
      '유화': 2.5,
    };

    for (final technique in advancedTechniques.entries) {
      if (allText.contains(technique.key)) {
        complexity += technique.value;
      }
    }

    // 시간 관련 복잡성
    if (allText.contains('시간') && allText.contains('정확')) complexity += 1.0;
    if (allText.contains('온도') && allText.contains('조절')) complexity += 1.5;

    return complexity.clamp(1.0, 10.0);
  }

  /// 복잡도 레벨 문자열 반환
  String _getComplexityLevel(double complexity) {
    if (complexity <= 3) return '초급';
    if (complexity <= 6) return '중급';
    if (complexity <= 8) return '고급';
    return '전문가';
  }

  /// 조리 시간 최적화 분석
  Map<String, dynamic> _analyzeTimeOptimization(Recipe recipe) {
    final instructions = recipe.instructions;
    final totalEstimatedTime = recipe.prepTime + recipe.cookTime;

    // 병렬 처리 가능한 단계 식별
    final parallelSteps = _identifyParallelSteps(instructions);

    // 대기 시간 식별
    final waitingTimes = _identifyWaitingTimes(instructions);

    // 최적화 가능한 시간 계산
    final optimizableTime =
        _calculateOptimizableTime(parallelSteps, waitingTimes);

    return {
      'current_total_time': totalEstimatedTime,
      'optimized_time': totalEstimatedTime - optimizableTime,
      'time_savings': optimizableTime,
      'parallel_steps': parallelSteps,
      'waiting_times': waitingTimes,
      'optimization_suggestions':
          _generateTimeOptimizationSuggestions(parallelSteps, waitingTimes),
    };
  }

  /// 병렬 처리 가능한 단계 식별
  List<Map<String, dynamic>> _identifyParallelSteps(List<String> instructions) {
    final parallelSteps = <Map<String, dynamic>>[];

    for (int i = 0; i < instructions.length; i++) {
      final instruction = instructions[i].toLowerCase();

      // 독립적으로 수행 가능한 작업들 식별
      if (instruction.contains('따로') ||
          instruction.contains('별도') ||
          instruction.contains('동시에') ||
          instruction.contains('한편')) {
        parallelSteps.add({
          'step_index': i,
          'instruction': instructions[i],
          'type': 'parallel_execution',
        });
      }

      // 준비 작업들 식별
      if (instruction.contains('준비') ||
          instruction.contains('미리') ||
          instruction.contains('손질')) {
        parallelSteps.add({
          'step_index': i,
          'instruction': instructions[i],
          'type': 'preparation',
        });
      }
    }

    return parallelSteps;
  }

  /// 대기 시간 식별
  List<Map<String, dynamic>> _identifyWaitingTimes(List<String> instructions) {
    final waitingTimes = <Map<String, dynamic>>[];

    for (int i = 0; i < instructions.length; i++) {
      final instruction = instructions[i].toLowerCase();

      // 대기 시간이 있는 단계들 식별
      final timePatterns = [
        RegExp(r'(\d+)분.*기다'),
        RegExp(r'(\d+)시간.*기다'),
        RegExp(r'(\d+)분.*둡니다'),
        RegExp(r'(\d+)시간.*둡니다'),
        RegExp(r'(\d+)분.*휴지'),
        RegExp(r'(\d+)시간.*휴지'),
      ];

      for (final pattern in timePatterns) {
        final match = pattern.firstMatch(instruction);
        if (match != null) {
          final timeValue = int.tryParse(match.group(1) ?? '0') ?? 0;
          waitingTimes.add({
            'step_index': i,
            'instruction': instructions[i],
            'waiting_time_minutes': timeValue,
            'type': 'waiting_time',
          });
        }
      }
    }

    return waitingTimes;
  }

  /// 최적화 가능한 시간 계산
  int _calculateOptimizableTime(List<Map<String, dynamic>> parallelSteps,
      List<Map<String, dynamic>> waitingTimes) {
    int optimizableTime = 0;

    // 병렬 처리로 절약 가능한 시간 (추정)
    optimizableTime += parallelSteps.length * 5; // 단계당 평균 5분 절약

    // 대기 시간 중 활용 가능한 시간
    for (final waitTime in waitingTimes) {
      final minutes = waitTime['waiting_time_minutes'] as int;
      optimizableTime += (minutes * 0.7).round(); // 대기 시간의 70% 활용 가능
    }

    return optimizableTime;
  }

  /// 시간 최적화 제안 생성
  List<String> _generateTimeOptimizationSuggestions(
      List<Map<String, dynamic>> parallelSteps,
      List<Map<String, dynamic>> waitingTimes) {
    final suggestions = <String>[];

    if (parallelSteps.isNotEmpty) {
      suggestions.add('${parallelSteps.length}개의 단계를 병렬로 처리하여 시간을 절약할 수 있습니다.');
    }

    if (waitingTimes.isNotEmpty) {
      final totalWaitTime = waitingTimes.fold<int>(
          0, (sum, item) => sum + (item['waiting_time_minutes'] as int));
      suggestions.add('총 ${totalWaitTime}분의 대기 시간 동안 다른 준비 작업을 할 수 있습니다.');
    }

    suggestions.add('재료를 미리 준비하고 계량해두면 조리 시간을 단축할 수 있습니다.');

    return suggestions;
  }

  /// 위험도 평가
  Map<String, dynamic> _analyzeRiskFactors(Recipe recipe) {
    final instructions = recipe.instructions;
    final allText = instructions.join(' ').toLowerCase();

    final riskFactors = <String, dynamic>{};
    int totalRiskScore = 0;

    // 온도 관련 위험
    if (allText.contains('고온') ||
        allText.contains('뜨거운') ||
        allText.contains('기름')) {
      riskFactors['high_temperature'] = {
        'risk_level': 'high',
        'description': '고온 조리로 인한 화상 위험',
        'safety_tips': ['내열 장갑 착용', '충분한 환기', '어린이 접근 금지'],
      };
      totalRiskScore += 3;
    }

    // 날카로운 도구 사용
    if (allText.contains('칼') ||
        allText.contains('자르') ||
        allText.contains('썰')) {
      riskFactors['sharp_tools'] = {
        'risk_level': 'medium',
        'description': '날카로운 도구 사용으로 인한 상해 위험',
        'safety_tips': ['올바른 칼 사용법 숙지', '안정적인 도마 사용', '집중력 유지'],
      };
      totalRiskScore += 2;
    }

    // 발효/부패 위험
    if (allText.contains('발효') ||
        allText.contains('숙성') ||
        allText.contains('상온')) {
      riskFactors['fermentation_spoilage'] = {
        'risk_level': 'medium',
        'description': '발효 과정에서의 부패 위험',
        'safety_tips': ['적절한 온도 유지', '위생적인 환경', '발효 상태 주기적 확인'],
      };
      totalRiskScore += 2;
    }

    // 알레르기 유발 가능 재료
    final allergenIngredients = recipe.ingredients.where((ingredient) {
      final name = ingredient.name.toLowerCase();
      return name.contains('견과') ||
          name.contains('우유') ||
          name.contains('계란') ||
          name.contains('밀') ||
          name.contains('콩') ||
          name.contains('새우');
    }).toList();

    if (allergenIngredients.isNotEmpty) {
      riskFactors['allergens'] = {
        'risk_level': 'high',
        'description': '알레르기 유발 가능 재료 포함',
        'allergen_ingredients': allergenIngredients.map((i) => i.name).toList(),
        'safety_tips': ['알레르기 확인', '대체 재료 고려', '교차 오염 방지'],
      };
      totalRiskScore += 3;
    }

    return {
      'total_risk_score': totalRiskScore,
      'risk_level': _getRiskLevel(totalRiskScore),
      'risk_factors': riskFactors,
      'overall_safety_rating': _calculateSafetyRating(totalRiskScore),
    };
  }

  /// 위험도 레벨 계산
  String _getRiskLevel(int riskScore) {
    if (riskScore <= 2) return '낮음';
    if (riskScore <= 5) return '보통';
    if (riskScore <= 8) return '높음';
    return '매우 높음';
  }

  /// 안전도 평가 (1-10)
  double _calculateSafetyRating(int riskScore) {
    return (10 - riskScore).clamp(1, 10).toDouble();
  }

  /// 기법 분석
  Map<String, dynamic> _analyzeTechniques(Recipe recipe) {
    final instructions = recipe.instructions;
    final allText = instructions.join(' ').toLowerCase();

    final detectedTechniques = <String>[];
    final techniqueDetails = <String, dynamic>{};

    // 기본 조리 기법들
    final basicTechniques = {
      '볶기': ['볶', '팬에'],
      '끓이기': ['끓', '물에'],
      '굽기': ['굽', '오븐'],
      '튀기기': ['튀', '기름'],
      '찌기': ['찜', '스팀'],
      '삶기': ['삶', '물에'],
    };

    for (final technique in basicTechniques.entries) {
      for (final keyword in technique.value) {
        if (allText.contains(keyword)) {
          detectedTechniques.add(technique.key);
          break;
        }
      }
    }

    // 고급 기법들
    final advancedTechniques = {
      '발효': ['발효', '이스트', '효모'],
      '유화': ['유화', '마요네즈', '버터크림'],
      '캐러멜화': ['캐러멜', '설탕'],
      '글루텐 형성': ['반죽', '글루텐', '치대'],
    };

    for (final technique in advancedTechniques.entries) {
      for (final keyword in technique.value) {
        if (allText.contains(keyword)) {
          detectedTechniques.add(technique.key);
          techniqueDetails[technique.key] = {
            'difficulty': 'advanced',
            'keywords_found':
                technique.value.where((k) => allText.contains(k)).toList(),
          };
          break;
        }
      }
    }

    return {
      'detected_techniques': detectedTechniques,
      'technique_count': detectedTechniques.length,
      'technique_details': techniqueDetails,
      'skill_level_required': _determineSkillLevel(detectedTechniques),
    };
  }

  /// 필요한 기술 수준 결정
  String _determineSkillLevel(List<String> techniques) {
    final advancedTechniques = ['발효', '유화', '캐러멜화', '글루텐 형성'];
    final hasAdvanced = techniques.any((t) => advancedTechniques.contains(t));

    if (hasAdvanced) return '고급';
    if (techniques.length > 3) return '중급';
    return '초급';
  }

  /// 베이킹 특화 분석
  Map<String, dynamic> _analyzeBakingSpecific(Recipe recipe) {
    final results = <String, dynamic>{};

    // 베이킹 타입 분석
    results['baking_type'] = _determineBakingType(recipe);

    // 발효 분석
    if (recipe.fermentationSteps?.isNotEmpty ?? false) {
      results['fermentation_analysis'] =
          _analyzeFermentation(recipe.fermentationSteps!);
    }

    // 오븐 단계 분석
    if (recipe.ovenSteps?.isNotEmpty ?? false) {
      results['oven_analysis'] = _analyzeOvenSteps(recipe.ovenSteps!);
    }

    // 베이킹 난이도
    results['baking_difficulty'] = _calculateBakingDifficulty(recipe);

    return results;
  }

  /// 베이킹 타입 결정
  String _determineBakingType(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    final category = recipe.category.toLowerCase();

    if (title.contains('빵') || category.contains('빵')) return '빵';
    if (title.contains('케이크') || category.contains('케이크')) return '케이크';
    if (title.contains('쿠키') || category.contains('쿠키')) return '쿠키';
    if (title.contains('파이') || category.contains('파이')) return '파이';
    if (title.contains('머핀') || category.contains('머핀')) return '머핀';

    return '기타 베이킹';
  }

  /// 발효 분석
  Map<String, dynamic> _analyzeFermentation(
      List<Map<String, dynamic>> fermentationSteps) {
    return {
      'fermentation_stages': fermentationSteps.length,
      'total_fermentation_time':
          _calculateTotalFermentationTime(fermentationSteps),
      'fermentation_complexity':
          fermentationSteps.length > 2 ? 'complex' : 'simple',
    };
  }

  /// 총 발효 시간 계산
  int _calculateTotalFermentationTime(List<Map<String, dynamic>> steps) {
    int totalTime = 0;
    for (final step in steps) {
      final duration = step['duration'] as int? ?? 0;
      totalTime += duration;
    }
    return totalTime;
  }

  /// 오븐 단계 분석
  Map<String, dynamic> _analyzeOvenSteps(List<Map<String, dynamic>> ovenSteps) {
    return {
      'oven_stages': ovenSteps.length,
      'temperature_changes': _countTemperatureChanges(ovenSteps),
      'total_baking_time': _calculateTotalBakingTime(ovenSteps),
    };
  }

  /// 온도 변경 횟수 계산
  int _countTemperatureChanges(List<Map<String, dynamic>> steps) {
    if (steps.length <= 1) return 0;

    int changes = 0;
    int? previousTemp;

    for (final step in steps) {
      final temp = step['temperature'] as int?;
      if (temp != null && previousTemp != null && temp != previousTemp) {
        changes++;
      }
      previousTemp = temp;
    }

    return changes;
  }

  /// 총 베이킹 시간 계산
  int _calculateTotalBakingTime(List<Map<String, dynamic>> steps) {
    int totalTime = 0;
    for (final step in steps) {
      final duration = step['duration'] as int? ?? 0;
      totalTime += duration;
    }
    return totalTime;
  }

  /// 베이킹 난이도 계산
  Map<String, dynamic> _calculateBakingDifficulty(Recipe recipe) {
    int difficultyScore = 1;
    final factors = <String>[];

    // 발효 단계가 있으면 난이도 증가
    if (recipe.fermentationSteps?.isNotEmpty ?? false) {
      difficultyScore += 2;
      factors.add('발효 과정');
    }

    // 복잡한 오븐 단계
    if ((recipe.ovenSteps?.length ?? 0) > 2) {
      difficultyScore += 1;
      factors.add('복잡한 베이킹 과정');
    }

    // 재료 수
    if (recipe.ingredients.length > 10) {
      difficultyScore += 1;
      factors.add('많은 재료');
    }

    return {
      'difficulty_score': difficultyScore.clamp(1, 10),
      'difficulty_level': _getBakingDifficultyLevel(difficultyScore),
      'difficulty_factors': factors,
    };
  }

  /// 베이킹 난이도 레벨
  String _getBakingDifficultyLevel(int score) {
    if (score <= 2) return '초급';
    if (score <= 4) return '중급';
    if (score <= 6) return '고급';
    return '전문가';
  }

  /// 전체 점수 계산
  double _calculateOverallScore(Map<String, dynamic> results) {
    double score = 70.0; // 기본 점수

    // 복잡도에 따른 점수 조정
    final complexity =
        results['complexity']?['overall_complexity'] as double? ?? 5.0;
    if (complexity <= 3)
      score += 10; // 간단한 레시피는 점수 증가
    else if (complexity >= 8) score -= 5; // 복잡한 레시피는 점수 감소

    // 위험도에 따른 점수 조정
    final riskScore =
        results['risk_assessment']?['total_risk_score'] as int? ?? 0;
    score -= riskScore * 2; // 위험도가 높을수록 점수 감소

    // 시간 최적화 가능성에 따른 점수 증가
    final timeSavings =
        results['time_optimization']?['time_savings'] as int? ?? 0;
    if (timeSavings > 0) score += 5;

    return score.clamp(0.0, 100.0);
  }

  /// 추천 사항 생성
  List<Map<String, dynamic>> _generateRecommendations(
      Recipe recipe, Map<String, dynamic> results) {
    final recommendations = <Map<String, dynamic>>[];

    // 복잡도 기반 추천
    final complexity =
        results['complexity']?['overall_complexity'] as double? ?? 5.0;
    if (complexity > 7) {
      recommendations.add({
        'type': 'complexity_reduction',
        'title': '레시피 단순화 제안',
        'description': '일부 단계를 간소화하거나 재료를 줄여 복잡도를 낮출 수 있습니다.',
        'priority': 'medium',
      });
    }

    // 시간 최적화 추천
    final timeSavings =
        results['time_optimization']?['time_savings'] as int? ?? 0;
    if (timeSavings > 10) {
      recommendations.add({
        'type': 'time_optimization',
        'title': '조리 시간 단축 가능',
        'description': '병렬 처리와 준비 작업 최적화로 약 ${timeSavings}분을 절약할 수 있습니다.',
        'priority': 'high',
      });
    }

    // 안전성 추천
    final riskLevel =
        results['risk_assessment']?['risk_level'] as String? ?? '낮음';
    if (riskLevel == '높음' || riskLevel == '매우 높음') {
      recommendations.add({
        'type': 'safety_improvement',
        'title': '안전성 강화 필요',
        'description': '고위험 단계에서 추가적인 안전 조치가 필요합니다.',
        'priority': 'high',
      });
    }

    return recommendations;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    // 레시피 분석은 상대적으로 빠름
    final baseTime = 500; // 0.5초
    final ingredientTime = request.recipe.ingredients.length * 10; // 재료당 10ms
    final instructionTime =
        request.recipe.instructions.length * 20; // 지시사항당 20ms

    return baseTime + ingredientTime + instructionTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    // 기본 메모리 + 레시피 크기에 따른 추가 메모리
    final baseMemory = 5 * 1024 * 1024; // 5MB
    final recipeMemory = (request.recipe.ingredients.length +
            request.recipe.instructions.length) *
        1024; // 1KB per item

    return baseMemory + recipeMemory;
  }

  @override
  List<String> getSupportedFeatures() {
    return [
      'complexity_analysis',
      'time_optimization',
      'risk_assessment',
      'technique_analysis',
      'baking_specific_analysis',
      'recommendation_generation',
    ];
  }

  @override
  List<String> getRequiredPermissions() {
    return []; // 특별한 권한 불필요
  }

  @override
  Map<String, dynamic> getConfigurationSchema() {
    return {
      'enable_complexity_analysis': {
        'type': 'boolean',
        'default': true,
        'description': '복잡도 분석 활성화',
      },
      'enable_time_optimization': {
        'type': 'boolean',
        'default': true,
        'description': '시간 최적화 분석 활성화',
      },
      'enable_risk_assessment': {
        'type': 'boolean',
        'default': true,
        'description': '위험도 평가 활성화',
      },
      'complexity_weight_factors': {
        'type': 'object',
        'description': '복잡도 계산 가중치',
        'properties': {
          'ingredient_count': {'type': 'number', 'default': 0.3},
          'instruction_count': {'type': 'number', 'default': 0.4},
          'technique_difficulty': {'type': 'number', 'default': 0.3},
        },
      },
    };
  }
}
