// lib/modules/bread/services/dough_type_analyzer.dart
// 반도 타입 분석기 - 과학적 기준으로 반도 타입 파악
// 사용자데이터 + 레시피데이터 기반으로 정확한 분석 수행

import 'dart:developer' as developer;

// ComprehensiveIngredientAnalysis 타입 import 추가
import '../../../../../core/types/comprehensive_types.dart';

import '../../../../../core/types/unified_types.dart';
import '../../../../../core/types/ingredient_analysis_types.dart';
import '../../../../../models/ingredient.dart';
import '../../../../../services/ingredient_analysis_hub_v2.dart';
import '../../../../../services/analysis_cache_manager.dart';
import '../types/bread_types.dart';
import '../models/integrated_mixing_analysis_types.dart';

/// 반도 타입 분석 결과
class DoughTypeAnalysisResult {
  /// 분석된 반도 타입
  final DoughType doughType;

  /// 분석 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 분석 근거
  final List<String> reasoning;

  /// 추천 사항
  final List<String> recommendations;

  /// 상세 분석 데이터
  final Map<String, dynamic> analysisData;

  /// 분석 타임스탬프
  final DateTime analyzedAt;

  const DoughTypeAnalysisResult({
    required this.doughType,
    required this.confidence,
    required this.reasoning,
    required this.recommendations,
    required this.analysisData,
    required this.analyzedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'doughType': doughType.index,
      'confidence': confidence,
      'reasoning': reasoning,
      'recommendations': recommendations,
      'analysisData': analysisData,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory DoughTypeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DoughTypeAnalysisResult(
      doughType: DoughType.values[json['doughType'] as int],
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: List<String>.from(json['reasoning'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      analysisData: Map<String, dynamic>.from(json['analysisData'] as Map),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'DoughTypeAnalysisResult('
        'doughType: ${doughType.description}, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'reasoning: ${reasoning.length}개)';
  }
}

/// 반도 타입 분석기
class DoughTypeAnalyzer {
  /// 기본 생성자
  const DoughTypeAnalyzer();

  /// 반도 타입 분석 실행
  Future<DoughTypeAnalysisResult> analyze({
    required BreadUserData userData,
    required UnifiedRecipe recipe,
  }) async {
    // 1. 재료 비율 분석
    final ingredientAnalysis = _analyzeIngredients(recipe);

    // 2. 프로세스 분석
    final processAnalysis = _analyzeProcesses(recipe);

    // 3. 사용자 환경 분석
    final environmentAnalysis = _analyzeUserEnvironment(userData);

    // 4. 종합 분석
    final comprehensiveResult = _comprehensiveAnalysis(
      ingredientAnalysis: ingredientAnalysis,
      processAnalysis: processAnalysis,
      environmentAnalysis: environmentAnalysis,
    );

    // 5. 최종 결정
    final finalResult = _determineDoughType(comprehensiveResult);

    return DoughTypeAnalysisResult(
      doughType: finalResult['type'] as DoughType,
      confidence: finalResult['confidence'] as double,
      reasoning: finalResult['reasoning'] as List<String>,
      recommendations: finalResult['recommendations'] as List<String>,
      analysisData: {
        'ingredientAnalysis': ingredientAnalysis,
        'processAnalysis': processAnalysis,
        'environmentAnalysis': environmentAnalysis,
        'comprehensiveResult': comprehensiveResult,
      },
      analyzedAt: DateTime.now(),
    );
  }

  /// 재료 분석
  Map<String, dynamic> _analyzeIngredients(UnifiedRecipe recipe) {
    final ingredients = recipe.ingredients
        .map((ing) => Ingredient(
              id: 'temp_${ing.name.hashCode}',
              name: ing.name,
              amount: ing.amount,
              unit: ing.unit,
              properties: ing.properties,
            ))
        .toList();
    final totalWeight = _calculateTotalWeight(ingredients);

    // 재료별 중량 계산
    double flourWeight = 0.0;
    double waterWeight = 0.0;
    double sugarWeight = 0.0;
    double fatWeight = 0.0;
    double yeastWeight = 0.0;
    double saltWeight = 0.0;

    for (final ingredient in ingredients) {
      final weight = _parseWeight(ingredient);
      final type = _classifyIngredientType(ingredient.name);

      switch (type) {
        case 'flour':
          flourWeight += weight;
          break;
        case 'water':
          waterWeight += weight;
          break;
        case 'sugar':
          sugarWeight += weight;
          break;
        case 'fat':
          fatWeight += weight;
          break;
        case 'yeast':
          yeastWeight += weight;
          break;
        case 'salt':
          saltWeight += weight;
          break;
      }
    }

    // 비율 계산
    final hydrationRatio = flourWeight > 0 ? waterWeight / flourWeight : 0.0;
    final sugarRatio = flourWeight > 0 ? sugarWeight / flourWeight : 0.0;
    final fatRatio = flourWeight > 0 ? fatWeight / flourWeight : 0.0;
    final yeastRatio = flourWeight > 0 ? yeastWeight / flourWeight : 0.0;
    final saltRatio = flourWeight > 0 ? saltWeight / flourWeight : 0.0;

    return {
      'totalWeight': totalWeight,
      'flourWeight': flourWeight,
      'waterWeight': waterWeight,
      'hydrationRatio': hydrationRatio,
      'sugarRatio': sugarRatio,
      'fatRatio': fatRatio,
      'yeastRatio': yeastRatio,
      'saltRatio': saltRatio,
      'hasYeast': yeastWeight > 0,
      'isHighHydration': hydrationRatio > 0.75,
      'isLowHydration': hydrationRatio < 0.6,
      'isRich': sugarRatio > 0.1 || fatRatio > 0.1,
      'isLean': sugarRatio < 0.05 && fatRatio < 0.05,
    };
  }

  /// 프로세스 분석
  Map<String, dynamic> _analyzeProcesses(UnifiedRecipe recipe) {
    final processes = recipe.processes;
    bool hasMixing = false;
    bool hasFermentation = false;
    bool hasBaking = false;
    bool hasLongFermentation = false;
    int fermentationSteps = 0;
    int mixingSteps = 0;

    for (final process in processes) {
      switch (process.type) {
        case 'mixing':
          hasMixing = true;
          mixingSteps++;
          break;
        case 'fermentation':
          hasFermentation = true;
          fermentationSteps++;

          // 발효 시간 확인
          final duration = _parseDuration(process.parameters?['duration']);
          if (duration != null && duration.inHours > 2) {
            hasLongFermentation = true;
          }
          break;
        case 'baking':
          hasBaking = true;
          break;
      }
    }

    return {
      'hasMixing': hasMixing,
      'hasFermentation': hasFermentation,
      'hasBaking': hasBaking,
      'hasLongFermentation': hasLongFermentation,
      'fermentationSteps': fermentationSteps,
      'mixingSteps': mixingSteps,
      'totalSteps': processes.length,
      'isComplexProcess': processes.length > 6,
    };
  }

  /// 사용자 환경 분석
  Map<String, dynamic> _analyzeUserEnvironment(BreadUserData userData) {
    final environment = userData.environment;
    final equipment = userData.equipment;
    final preferences = userData.preferences;

    // 온도 영향
    final temperature = environment.temperature;
    final humidity = environment.humidity;

    // 장비 영향
    final mixerType = equipment.settings['mixerType'] as String? ?? 'unknown';
    final ovenType = equipment.settings['ovenType'] as String? ?? 'unknown';

    // 선호도 영향
    final difficultyPreference =
        preferences.preferences['difficulty'] as String? ?? 'intermediate';
    final timePreference =
        preferences.preferences['timePreference'] as String? ?? 'normal';
    final automationLevel =
        preferences.preferences['automationLevel'] as String? ?? 'medium';

    return {
      'temperature': temperature,
      'humidity': humidity,
      'isHighTemperature': temperature > 28,
      'isLowTemperature': temperature < 20,
      'isHighHumidity': humidity > 75,
      'isLowHumidity': humidity < 50,
      'mixerType': mixerType,
      'ovenType': ovenType,
      'difficultyPreference': difficultyPreference,
      'timePreference': timePreference,
      'automationLevel': automationLevel,
      'prefersQuick': timePreference == 'quick',
      'prefersSimple': difficultyPreference == 'beginner',
      'prefersAdvanced': difficultyPreference == 'advanced',
    };
  }

  /// 종합 분석
  Map<String, dynamic> _comprehensiveAnalysis({
    required Map<String, dynamic> ingredientAnalysis,
    required Map<String, dynamic> processAnalysis,
    required Map<String, dynamic> environmentAnalysis,
  }) {
    final scores = <DoughType, double>{};

    // 각 반도 타입에 대한 점수 계산
    for (final doughType in DoughType.values) {
      if (doughType == DoughType.unknown) continue;

      double score = 0.0;
      final factors = <String>[];

      // 재료 기반 점수
      score +=
          _calculateIngredientScore(doughType, ingredientAnalysis, factors);

      // 프로세스 기반 점수
      score += _calculateProcessScore(doughType, processAnalysis, factors);

      // 환경 기반 점수
      score +=
          _calculateEnvironmentScore(doughType, environmentAnalysis, factors);

      scores[doughType] = score;
    }

    // 최고 점수 타입 찾기
    final bestType = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final totalScore = scores.values.reduce((a, b) => a + b);
    final confidence = totalScore > 0 ? bestType.value / totalScore : 0.0;

    return {
      'scores': scores.map((k, v) => MapEntry(k.index, v)),
      'bestType': bestType.key,
      'confidence': confidence,
      'totalScore': totalScore,
    };
  }

  /// 최종 반도 타입 결정
  Map<String, dynamic> _determineDoughType(
      Map<String, dynamic> comprehensiveResult) {
    final scores = comprehensiveResult['scores'] as Map<int, double>;
    final bestTypeIndex = comprehensiveResult['bestType'] as DoughType;
    final confidence = comprehensiveResult['confidence'] as double;

    final reasoning = <String>[];
    final recommendations = <String>[];

    // 신뢰도에 따른 조정
    final adjustedConfidence = confidence.clamp(0.0, 1.0);

    if (adjustedConfidence < 0.5) {
      reasoning.add('분석 신뢰도가 낮아 기본 타입으로 설정');
      recommendations.add('추가 정보를 제공하여 더 정확한 분석을 받으세요');
      return {
        'type': DoughType.lean,
        'confidence': adjustedConfidence,
        'reasoning': reasoning,
        'recommendations': recommendations,
      };
    }

    // 타입별 특화된 조언
    switch (bestTypeIndex) {
      case DoughType.lean:
        reasoning.add('기본 재료 비율로 팡 도우로 분석됨');
        recommendations.add('표준 믹싱 시간을 준수하세요');
        break;
      case DoughType.rich:
        reasoning.add('설탕과 지방 함량이 높아 리치 도우로 분석됨');
        recommendations.add('믹싱 시간을 늘리고 온도를 낮춰 믹싱하세요');
        break;
      case DoughType.highHydration:
        reasoning.add('수분 함량이 높아 고수분 도우로 분석됨');
        recommendations.add('강력한 믹서 사용을 권장합니다');
        break;
      case DoughType.sourdough:
        reasoning.add('천연 효모를 사용하는 사워도우로 분석됨');
        recommendations.add('긴 발효 시간을 확보하세요');
        break;
      default:
        reasoning.add('표준 반도 타입으로 분석됨');
        break;
    }

    return {
      'type': bestTypeIndex,
      'confidence': adjustedConfidence,
      'reasoning': reasoning,
      'recommendations': recommendations,
    };
  }

  /// 재료 기반 점수 계산
  double _calculateIngredientScore(DoughType doughType,
      Map<String, dynamic> ingredientAnalysis, List<String> factors) {
    double score = 0.0;

    final hydrationRatio = ingredientAnalysis['hydrationRatio'] as double;
    final sugarRatio = ingredientAnalysis['sugarRatio'] as double;
    final fatRatio = ingredientAnalysis['fatRatio'] as double;
    final hasYeast = ingredientAnalysis['hasYeast'] as bool;

    switch (doughType) {
      case DoughType.lean:
        if (sugarRatio < 0.05 && fatRatio < 0.05) score += 30;
        if (hydrationRatio >= 0.6 && hydrationRatio <= 0.75) score += 20;
        factors.add('기본 재료 비율');
        break;

      case DoughType.rich:
        if (sugarRatio > 0.1 || fatRatio > 0.1) score += 30;
        factors.add('풍부한 재료 함량');
        break;

      case DoughType.highHydration:
        if (hydrationRatio > 0.75) score += 40;
        factors.add('고수분 함량');
        break;

      case DoughType.lowHydration:
        if (hydrationRatio < 0.6) score += 40;
        factors.add('저수분 함량');
        break;

      case DoughType.sourdough:
        if (!hasYeast) score += 25;
        if (hydrationRatio >= 0.65 && hydrationRatio <= 0.80) score += 15;
        factors.add('천연 효모 특성');
        break;

      default:
        score += 10; // 기본 점수
    }

    return score;
  }

  /// 프로세스 기반 점수 계산
  double _calculateProcessScore(DoughType doughType,
      Map<String, dynamic> processAnalysis, List<String> factors) {
    double score = 0.0;

    final hasLongFermentation = processAnalysis['hasLongFermentation'] as bool;
    final fermentationSteps = processAnalysis['fermentationSteps'] as int;
    final mixingSteps = processAnalysis['mixingSteps'] as int;

    switch (doughType) {
      case DoughType.lean:
        if (mixingSteps >= 2 && fermentationSteps >= 1) score += 20;
        factors.add('표준 프로세스');
        break;

      case DoughType.sourdough:
        if (hasLongFermentation) score += 30;
        if (fermentationSteps >= 2) score += 20;
        factors.add('긴 발효 프로세스');
        break;

      case DoughType.rich:
        if (mixingSteps >= 3) score += 25;
        factors.add('복합 믹싱 프로세스');
        break;

      default:
        score += 15;
    }

    return score;
  }

  /// 환경 기반 점수 계산
  double _calculateEnvironmentScore(DoughType doughType,
      Map<String, dynamic> environmentAnalysis, List<String> factors) {
    double score = 0.0;

    final temperature = environmentAnalysis['temperature'] as double;
    final humidity = environmentAnalysis['humidity'] as double;
    final difficultyPreference =
        environmentAnalysis['difficultyPreference'] as String;

    switch (doughType) {
      case DoughType.sourdough:
        if (temperature >= 20 && temperature <= 25) score += 15;
        if (humidity >= 60 && humidity <= 80) score += 15;
        if (difficultyPreference == 'advanced') score += 10;
        factors.add('사워도우에 적합한 환경');
        break;

      case DoughType.lean:
        if (difficultyPreference == 'beginner' ||
            difficultyPreference == 'intermediate') score += 20;
        factors.add('초보자에게 적합한 난이도');
        break;

      case DoughType.rich:
        if (difficultyPreference == 'intermediate' ||
            difficultyPreference == 'advanced') score += 15;
        factors.add('중급 이상 난이도');
        break;

      default:
        score += 10;
    }

    return score;
  }

  /// 중량 파싱
  double _parseWeight(Ingredient ingredient) {
    // 실제 구현에서는 단위를 고려한 정확한 파싱 필요
    // 여기서는 간단히 수량을 중량으로 가정
    return ingredient.amount.toDouble();
  }

  /// 총 중량 계산
  double _calculateTotalWeight(List<Ingredient> ingredients) {
    return ingredients.fold(
        0.0, (sum, ingredient) => sum + _parseWeight(ingredient));
  }

  /// 재료 타입 분류
  String _classifyIngredientType(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('flour') ||
        lowerName.contains('밀가루') ||
        lowerName.contains('강력분')) {
      return 'flour';
    } else if (lowerName.contains('water') || lowerName.contains('물')) {
      return 'water';
    } else if (lowerName.contains('sugar') || lowerName.contains('설탕')) {
      return 'sugar';
    } else if (lowerName.contains('butter') ||
        lowerName.contains('버터') ||
        lowerName.contains('oil') ||
        lowerName.contains('기름')) {
      return 'fat';
    } else if (lowerName.contains('yeast') || lowerName.contains('효모')) {
      return 'yeast';
    } else if (lowerName.contains('salt') || lowerName.contains('소금')) {
      return 'salt';
    } else {
      return 'other';
    }
  }

  /// 기간 파싱
  Duration? _parseDuration(dynamic durationData) {
    if (durationData == null) return null;

    if (durationData is String) {
      // "2h 30m" 형태 파싱
      final hours = RegExp(r'(\d+)h').firstMatch(durationData);
      final minutes = RegExp(r'(\d+)m').firstMatch(durationData);

      int totalMinutes = 0;
      if (hours != null) {
        totalMinutes += int.parse(hours.group(1)!) * 60;
      }
      if (minutes != null) {
        totalMinutes += int.parse(minutes.group(1)!);
      }

      return Duration(minutes: totalMinutes);
    }

    return null;
  }
}

/// 재료 효과를 고려한 반도 타입 분석 결과
class DoughTypeAnalysisWithEffectsResult extends DoughTypeAnalysisResult {
  /// 적용된 재료 효과 데이터
  final Map<String, dynamic> appliedIngredientEffects;

  /// 효과 기반 조정 사항
  final Map<String, dynamic> effectAdjustments;

  const DoughTypeAnalysisWithEffectsResult({
    required super.doughType,
    required super.confidence,
    required super.reasoning,
    required super.recommendations,
    required super.analysisData,
    required super.analyzedAt,
    required this.appliedIngredientEffects,
    required this.effectAdjustments,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'appliedIngredientEffects': appliedIngredientEffects,
      'effectAdjustments': effectAdjustments,
    });
    return json;
  }

  factory DoughTypeAnalysisWithEffectsResult.fromJson(
      Map<String, dynamic> json) {
    return DoughTypeAnalysisWithEffectsResult(
      doughType: DoughType.values[json['doughType'] as int],
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: List<String>.from(json['reasoning'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      analysisData: Map<String, dynamic>.from(json['analysisData'] as Map),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      appliedIngredientEffects:
          Map<String, dynamic>.from(json['appliedIngredientEffects'] as Map),
      effectAdjustments:
          Map<String, dynamic>.from(json['effectAdjustments'] as Map),
    );
  }
}

/// 반도 타입 분석기 팩토리
class DoughTypeAnalyzerFactory {
  /// 기본 분석기 생성
  static DoughTypeAnalyzer createDefault() {
    return const DoughTypeAnalyzer();
  }

  /// 커스텀 분석기 생성
  static DoughTypeAnalyzer createCustom({
    // 향후 확장성을 위한 파라미터
    Map<String, dynamic>? customRules,
  }) {
    return const DoughTypeAnalyzer();
  }
}

extension DoughTypeAnalyzerWithEffects on DoughTypeAnalyzer {
  /// 재료 효과를 고려한 반도 타입 분석 (Phase 3 확장 기능)
  Future<DoughTypeAnalysisWithEffectsResult> analyzeWithIngredientEffects({
    required BreadUserData userData,
    required UnifiedRecipe recipe,
    ComprehensiveIngredientAnalysis? ingredientAnalysis,
    String? breadType,
    String? recipeTitle,
    Duration? cacheExpiration,
  }) async {
    try {
      // 1. 재료 분석 수행 (제공되지 않은 경우)
      final analysis = ingredientAnalysis ??
          await _performIngredientAnalysis(
            recipe: recipe,
            breadType: breadType,
            recipeTitle: recipeTitle,
            cacheExpiration: cacheExpiration,
          );

      // 2. 재료 비율 분석 (효과 고려)
      final ingredientAnalysisData = _analyzeIngredientsWithEffects(
        recipe,
        analysis.mixingEffects,
        analysis.doughEffects,
      );

      // 3. 프로세스 분석
      final processAnalysis = _analyzeProcesses(recipe);

      // 4. 사용자 환경 분석
      final environmentAnalysis = _analyzeUserEnvironment(userData);

      // 5. 효과 기반 종합 분석
      final comprehensiveResult = _comprehensiveAnalysisWithEffects(
        ingredientAnalysis: ingredientAnalysisData,
        processAnalysis: processAnalysis,
        environmentAnalysis: environmentAnalysis,
        ingredientEffects: analysis.mixingEffects,
      );

      // 6. 최종 결정 (효과 고려)
      final finalResult = _determineDoughTypeWithEffects(
        comprehensiveResult,
        analysis.mixingEffects,
        analysis.doughEffects,
      );

      // 7. 효과 조정사항 계산
      final effectAdjustments = _calculateEffectAdjustments(
        analysis.mixingEffects,
        analysis.doughEffects,
        finalResult['type'] as DoughType,
      );

      return DoughTypeAnalysisWithEffectsResult(
        doughType: finalResult['type'] as DoughType,
        confidence: finalResult['confidence'] as double,
        reasoning: finalResult['reasoning'] as List<String>,
        recommendations: finalResult['recommendations'] as List<String>,
        analysisData: {
          'ingredientAnalysis': ingredientAnalysisData,
          'processAnalysis': processAnalysis,
          'environmentAnalysis': environmentAnalysis,
          'comprehensiveResult': comprehensiveResult,
          'ingredientEffects': analysis.mixingEffects,
          'doughEffects': analysis.doughEffects,
        },
        analyzedAt: DateTime.now(),
        appliedIngredientEffects: {
          'mixingEffects': analysis.mixingEffects,
          'doughEffects': analysis.doughEffects,
        },
        effectAdjustments: effectAdjustments,
      );
    } catch (e) {
      developer.log('❌ [DOUGH TYPE ANALYZER] 재료 효과 분석 실패: $e');
      // 폴백: 기본 분석
      final basicResult = await analyze(userData: userData, recipe: recipe);

      return DoughTypeAnalysisWithEffectsResult(
        doughType: basicResult.doughType,
        confidence: basicResult.confidence * 0.8, // 신뢰도 감소
        reasoning: [...basicResult.reasoning, '재료 효과 분석 실패로 기본 분석 사용'],
        recommendations: [
          ...basicResult.recommendations,
          '재료 효과를 고려한 상세 분석을 권장합니다'
        ],
        analysisData: basicResult.analysisData,
        analyzedAt: basicResult.analyzedAt,
        appliedIngredientEffects: {},
        effectAdjustments: {'fallback': true},
      );
    }
  }

  /// 재료 분석 수행 헬퍼
  Future<ComprehensiveIngredientAnalysis> _performIngredientAnalysis({
    required UnifiedRecipe recipe,
    String? breadType,
    String? recipeTitle,
    Duration? cacheExpiration,
  }) async {
    try {
      // IngredientAnalysisHub를 통한 통합 분석
      final analysis = await AnalysisCacheManager.instance.getOrAnalyze(
        recipeId: recipe.id,
        recipeTitle: recipeTitle ?? recipe.title,
        ingredients: recipe.ingredients,
        breadType: breadType ?? 'bread',
      );

      return analysis;
    } catch (e) {
      developer.log('❌ [INGREDIENT ANALYSIS] 분석 실패: $e');
      throw Exception('재료 분석 수행 중 오류 발생: $e');
    }
  }

  /// 재료 효과를 고려한 재료 분석
  Map<String, dynamic> _analyzeIngredientsWithEffects(
    UnifiedRecipe recipe,
    Map<String, dynamic> mixingEffects,
    Map<String, dynamic> doughEffects,
  ) {
    final ingredients = recipe.ingredients
        .map((ing) => Ingredient(
              id: 'temp_${ing.name.hashCode}',
              name: ing.name,
              amount: ing.amount,
              unit: ing.unit,
              properties: ing.properties,
            ))
        .toList();

    final baseAnalysis = _analyzeIngredients(recipe);
    final adjustedAnalysis = Map<String, dynamic>.from(baseAnalysis);

    // 재료 효과 적용
    final glutenImpact =
        mixingEffects['glutenFormationImpact'] as double? ?? 1.0;
    final hydrationAdjustment =
        mixingEffects['hydrationAdjustment'] as double? ?? 1.0;
    final sugarEffect = doughEffects['sugarEffect'] as double? ?? 1.0;
    final fatEffect = doughEffects['fatEffect'] as double? ?? 1.0;

    // 글루텐 형성 영향 적용
    if (glutenImpact < 0.9) {
      // 글루텐 형성이 어려움: 수분 비율 조정
      adjustedAnalysis['hydrationRatio'] =
          (baseAnalysis['hydrationRatio'] as double) * 0.95;
      adjustedAnalysis['isHighHydration'] =
          (adjustedAnalysis['hydrationRatio'] as double) > 0.75;
    } else if (glutenImpact > 1.1) {
      // 글루텐 형성이 쉬움: 수분 비율 조정
      adjustedAnalysis['hydrationRatio'] =
          (baseAnalysis['hydrationRatio'] as double) * 1.05;
      adjustedAnalysis['isHighHydration'] =
          (adjustedAnalysis['hydrationRatio'] as double) > 0.75;
    }

    // 수분 조정 적용
    final baseHydration = adjustedAnalysis['hydrationRatio'] as double;
    adjustedAnalysis['hydrationRatio'] = baseHydration * hydrationAdjustment;

    // 당분 효과 적용
    final baseSugarRatio = baseAnalysis['sugarRatio'] as double;
    adjustedAnalysis['sugarRatio'] = baseSugarRatio * sugarEffect;

    // 지방 효과 적용
    final baseFatRatio = baseAnalysis['fatRatio'] as double;
    adjustedAnalysis['fatRatio'] = baseFatRatio * fatEffect;

    // 리치/린 도우 재판단
    final adjustedSugarRatio = adjustedAnalysis['sugarRatio'] as double;
    final adjustedFatRatio = adjustedAnalysis['fatRatio'] as double;
    adjustedAnalysis['isRich'] =
        adjustedSugarRatio > 0.12 || adjustedFatRatio > 0.12;
    adjustedAnalysis['isLean'] =
        adjustedSugarRatio < 0.04 && adjustedFatRatio < 0.04;

    // 효과 적용 정보 추가
    adjustedAnalysis['appliedEffects'] = {
      'glutenImpact': glutenImpact,
      'hydrationAdjustment': hydrationAdjustment,
      'sugarEffect': sugarEffect,
      'fatEffect': fatEffect,
    };

    return adjustedAnalysis;
  }

  /// 효과 기반 종합 분석
  Map<String, dynamic> _comprehensiveAnalysisWithEffects({
    required Map<String, dynamic> ingredientAnalysis,
    required Map<String, dynamic> processAnalysis,
    required Map<String, dynamic> environmentAnalysis,
    required Map<String, dynamic> ingredientEffects,
  }) {
    final scores = <DoughType, double>{};
    final effectInfluences = <DoughType, Map<String, dynamic>>{};

    // 각 반도 타입에 대한 점수 계산 (효과 고려)
    for (final doughType in DoughType.values) {
      if (doughType == DoughType.unknown) continue;

      double score = 0.0;
      final factors = <String>[];
      final influences = <String, dynamic>{};

      // 재료 기반 점수 (효과 고려)
      final ingredientScore = _calculateIngredientScoreWithEffects(
        doughType,
        ingredientAnalysis,
        ingredientEffects,
        factors,
        influences,
      );
      score += ingredientScore;

      // 프로세스 기반 점수
      score += _calculateProcessScore(doughType, processAnalysis, factors);

      // 환경 기반 점수
      score +=
          _calculateEnvironmentScore(doughType, environmentAnalysis, factors);

      scores[doughType] = score;
      effectInfluences[doughType] = influences;
    }

    // 최고 점수 타입 찾기
    final bestType = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final totalScore = scores.values.reduce((a, b) => a + b);
    final confidence = totalScore > 0 ? bestType.value / totalScore : 0.0;

    return {
      'scores': scores.map((k, v) => MapEntry(k.index, v)),
      'bestType': bestType.key,
      'confidence': confidence,
      'totalScore': totalScore,
      'effectInfluences': effectInfluences.map((k, v) => MapEntry(k.index, v)),
    };
  }

  /// 효과를 고려한 재료 기반 점수 계산
  double _calculateIngredientScoreWithEffects(
    DoughType doughType,
    Map<String, dynamic> ingredientAnalysis,
    Map<String, dynamic> ingredientEffects,
    List<String> factors,
    Map<String, dynamic> influences,
  ) {
    double score = 0.0;

    final hydrationRatio = ingredientAnalysis['hydrationRatio'] as double;
    final sugarRatio = ingredientAnalysis['sugarRatio'] as double;
    final fatRatio = ingredientAnalysis['fatRatio'] as double;
    final hasYeast = ingredientAnalysis['hasYeast'] as bool;

    // 효과 데이터
    final glutenImpact =
        ingredientEffects['glutenFormationImpact'] as double? ?? 1.0;
    final hydrationAdjustment =
        ingredientEffects['hydrationAdjustment'] as double? ?? 1.0;

    switch (doughType) {
      case DoughType.lean:
        if (sugarRatio < 0.05 && fatRatio < 0.05) score += 30;
        if (hydrationRatio >= 0.6 && hydrationRatio <= 0.75) score += 20;

        // 효과 기반 조정
        if (glutenImpact > 1.0) score += 10; // 글루텐 형성이 좋음
        if (hydrationAdjustment >= 0.95 && hydrationAdjustment <= 1.05)
          score += 5;

        factors.add('기본 재료 비율 (효과 고려)');
        influences['glutenImpact'] = glutenImpact;
        influences['hydrationAdjustment'] = hydrationAdjustment;
        break;

      case DoughType.rich:
        if (sugarRatio > 0.12 || fatRatio > 0.12) score += 30;

        // 효과 기반 조정
        if (glutenImpact < 1.0) score += 15; // 글루텐 형성이 어려움: 리치 도우에 유리
        if (hydrationAdjustment < 0.9) score += 10; // 저수분: 리치 도우에 유리

        factors.add('풍부한 재료 함량 (효과 고려)');
        influences['sugarEffect'] = sugarRatio > 0.1;
        influences['fatEffect'] = fatRatio > 0.1;
        break;

      case DoughType.highHydration:
        if (hydrationRatio > 0.75) score += 40;

        // 효과 기반 조정
        if (hydrationAdjustment > 1.1) score += 20; // 고수분 조정 시 강점
        if (glutenImpact > 1.0) score += 10; // 글루텐 형성이 좋음

        factors.add('고수분 함량 (효과 고려)');
        influences['highHydrationAdjustment'] = hydrationAdjustment > 1.1;
        break;

      case DoughType.lowHydration:
        if (hydrationRatio < 0.6) score += 40;

        // 효과 기반 조정
        if (hydrationAdjustment < 0.9) score += 20; // 저수분 조정 시 강점
        if (glutenImpact < 1.0) score += 15; // 글루텐 형성이 어려움: 저수분에 유리

        factors.add('저수분 함량 (효과 고려)');
        influences['lowHydrationAdjustment'] = hydrationAdjustment < 0.9;
        break;

      case DoughType.sourdough:
        if (!hasYeast) score += 25;
        if (hydrationRatio >= 0.65 && hydrationRatio <= 0.80) score += 15;

        // 효과 기반 조정
        if (glutenImpact > 1.0) score += 10; // 글루텐 형성이 좋음
        if (hydrationAdjustment >= 0.9 && hydrationAdjustment <= 1.1)
          score += 5;

        factors.add('천연 효모 특성 (효과 고려)');
        influences['noYeast'] = !hasYeast;
        break;

      default:
        score += 10; // 기본 점수
    }

    return score;
  }

  /// 효과를 고려한 최종 반도 타입 결정
  Map<String, dynamic> _determineDoughTypeWithEffects(
    Map<String, dynamic> comprehensiveResult,
    Map<String, dynamic> mixingEffects,
    Map<String, dynamic> doughEffects,
  ) {
    final scores = comprehensiveResult['scores'] as Map<int, double>;
    final bestTypeIndex = comprehensiveResult['bestType'] as DoughType;
    final confidence = comprehensiveResult['confidence'] as double;

    final reasoning = <String>[];
    final recommendations = <String>[];

    // 신뢰도에 따른 조정 (효과 고려 시 더 높은 신뢰도)
    final adjustedConfidence = (confidence * 1.2).clamp(0.0, 1.0);

    if (adjustedConfidence < 0.5) {
      reasoning.add('분석 신뢰도가 낮아 기본 타입으로 설정 (재료 효과 고려)');
      recommendations.add('추가 정보를 제공하여 더 정확한 분석을 받으세요');
      return {
        'type': DoughType.lean,
        'confidence': adjustedConfidence,
        'reasoning': reasoning,
        'recommendations': recommendations,
      };
    }

    // 타입별 특화된 조언 (효과 고려)
    switch (bestTypeIndex) {
      case DoughType.lean:
        reasoning.add('기본 재료 비율로 팡 도우로 분석됨 (재료 효과 고려)');
        recommendations.add('표준 믹싱 시간을 준수하세요');

        if ((mixingEffects['glutenFormationImpact'] as double? ?? 1.0) > 1.1) {
          recommendations.add('글루텐 형성이 우수하므로 믹싱 시간을 약간 단축 가능');
        }
        break;

      case DoughType.rich:
        reasoning.add('설탕과 지방 함량이 높아 리치 도우로 분석됨 (재료 효과 고려)');
        recommendations.add('믹싱 시간을 늘리고 온도를 낮춰 믹싱하세요');

        if ((mixingEffects['hydrationAdjustment'] as double? ?? 1.0) < 0.9) {
          recommendations.add('저수분 특성을 고려하여 수분을 추가하세요');
        }
        break;

      case DoughType.highHydration:
        reasoning.add('수분 함량이 높아 고수분 도우로 분석됨 (재료 효과 고려)');
        recommendations.add('강력한 믹서 사용을 권장합니다');

        if ((mixingEffects['glutenFormationImpact'] as double? ?? 1.0) > 1.0) {
          recommendations.add('글루텐 형성이 좋으므로 고수분에도 안정적입니다');
        }
        break;

      case DoughType.sourdough:
        reasoning.add('천연 효모를 사용하는 사워도우로 분석됨 (재료 효과 고려)');
        recommendations.add('긴 발효 시간을 확보하세요');

        if ((mixingEffects['hydrationAdjustment'] as double? ?? 1.0) > 1.0) {
          recommendations.add('고수분 사워도우의 장점을 활용하세요');
        }
        break;

      default:
        reasoning.add('표준 반도 타입으로 분석됨 (재료 효과 고려)');
        break;
    }

    // 효과 기반 추가 추천사항
    final glutenImpact =
        mixingEffects['glutenFormationImpact'] as double? ?? 1.0;
    final hydrationAdjustment =
        mixingEffects['hydrationAdjustment'] as double? ?? 1.0;

    if (glutenImpact < 0.9) {
      recommendations.add('글루텐 형성이 어려우므로 믹싱 시간을 늘리세요');
    }

    if (hydrationAdjustment < 0.8) {
      recommendations.add('저수분 특성으로 인해 반죽 관리를 세심하게 하세요');
    } else if (hydrationAdjustment > 1.2) {
      recommendations.add('고수분 특성으로 인해 반죽 처리를 신중하게 하세요');
    }

    return {
      'type': bestTypeIndex,
      'confidence': adjustedConfidence,
      'reasoning': reasoning,
      'recommendations': recommendations,
    };
  }

  /// 효과 조정사항 계산
  Map<String, dynamic> _calculateEffectAdjustments(
    Map<String, dynamic> mixingEffects,
    Map<String, dynamic> doughEffects,
    DoughType finalType,
  ) {
    final adjustments = <String, dynamic>{};

    // 믹싱 효과 조정사항
    final glutenImpact =
        mixingEffects['glutenFormationImpact'] as double? ?? 1.0;
    final hydrationAdjustment =
        mixingEffects['hydrationAdjustment'] as double? ?? 1.0;
    final mixingTimeAdjustment =
        mixingEffects['mixingTimeAdjustment'] as double? ?? 1.0;
    final speedProfileAdjustment =
        mixingEffects['speedProfileAdjustment'] as double? ?? 1.0;

    adjustments['mixing'] = {
      'glutenImpact': {
        'original': 1.0,
        'adjusted': glutenImpact,
        'change': glutenImpact - 1.0,
        'impact': glutenImpact < 0.9
            ? 'negative'
            : glutenImpact > 1.1
                ? 'positive'
                : 'neutral',
      },
      'hydrationAdjustment': {
        'original': 1.0,
        'adjusted': hydrationAdjustment,
        'change': hydrationAdjustment - 1.0,
        'impact': hydrationAdjustment < 0.9
            ? 'low_hydration'
            : hydrationAdjustment > 1.1
                ? 'high_hydration'
                : 'normal',
      },
      'mixingTimeAdjustment': {
        'original': 1.0,
        'adjusted': mixingTimeAdjustment,
        'change': mixingTimeAdjustment - 1.0,
        'recommendation': mixingTimeAdjustment < 0.9
            ? 'increase_time'
            : mixingTimeAdjustment > 1.1
                ? 'decrease_time'
                : 'maintain',
      },
      'speedProfileAdjustment': {
        'original': 1.0,
        'adjusted': speedProfileAdjustment,
        'change': speedProfileAdjustment - 1.0,
        'recommendation': speedProfileAdjustment < 0.9
            ? 'lower_speed'
            : speedProfileAdjustment > 1.1
                ? 'higher_speed'
                : 'maintain',
      },
    };

    // 반죽 효과 조정사항
    final elasticityModifier =
        doughEffects['elasticityModifier'] as double? ?? 1.0;
    final extensibilityModifier =
        doughEffects['extensibilityModifier'] as double? ?? 1.0;
    final gasRetentionModifier =
        doughEffects['gasRetentionModifier'] as double? ?? 1.0;

    adjustments['dough'] = {
      'elasticityModifier': {
        'original': 1.0,
        'adjusted': elasticityModifier,
        'change': elasticityModifier - 1.0,
        'impact': elasticityModifier > 1.0
            ? 'more_elastic'
            : elasticityModifier < 1.0
                ? 'less_elastic'
                : 'normal',
      },
      'extensibilityModifier': {
        'original': 1.0,
        'adjusted': extensibilityModifier,
        'change': extensibilityModifier - 1.0,
        'impact': extensibilityModifier > 1.0
            ? 'more_extensible'
            : extensibilityModifier < 1.0
                ? 'less_extensible'
                : 'normal',
      },
      'gasRetentionModifier': {
        'original': 1.0,
        'adjusted': gasRetentionModifier,
        'change': gasRetentionModifier - 1.0,
        'impact': gasRetentionModifier > 1.0
            ? 'better_gas_retention'
            : gasRetentionModifier < 1.0
                ? 'poorer_gas_retention'
                : 'normal',
      },
    };

    // 타입별 최적화 제안
    adjustments['optimization'] =
        _generateTypeOptimization(finalType, adjustments);

    return adjustments;
  }

  /// 타입별 최적화 제안 생성
  Map<String, dynamic> _generateTypeOptimization(
    DoughType doughType,
    Map<String, dynamic> adjustments,
  ) {
    final mixingAdj = adjustments['mixing'] as Map<String, dynamic>;
    final doughAdj = adjustments['dough'] as Map<String, dynamic>;

    final optimization = <String, dynamic>{
      'doughType': doughType.name,
      'mixingOptimization': <String>[],
      'doughOptimization': <String>[],
      'overallRecommendation': '',
    };

    // 믹싱 최적화 제안
    if ((mixingAdj['glutenImpact']['change'] as double) < -0.1) {
      optimization['mixingOptimization'].add('글루텐 형성 개선을 위해 믹싱 시간을 15-20% 증가');
    }

    if ((mixingAdj['hydrationAdjustment']['change'] as double) < -0.1) {
      optimization['mixingOptimization'].add('저수분 특성 보완을 위해 수분 5-10% 추가 고려');
    }

    // 반죽 최적화 제안
    if ((doughAdj['elasticityModifier']['change'] as double) > 0.1) {
      optimization['doughOptimization'].add('높은 탄성 활용하여 발효 시간 최적화');
    }

    if ((doughAdj['gasRetentionModifier']['change'] as double) > 0.1) {
      optimization['doughOptimization'].add('우수한 가스 유지력 활용하여 굽기 온도 조정');
    }

    // 종합 추천
    switch (doughType) {
      case DoughType.lean:
        optimization['overallRecommendation'] = '기본 빵에 최적화된 파라미터 유지';
        break;
      case DoughType.rich:
        optimization['overallRecommendation'] = '풍부한 풍미를 위해 온도와 시간 조정';
        break;
      case DoughType.highHydration:
        optimization['overallRecommendation'] = '고수분 특성 극대화를 위한 장비와 기술 활용';
        break;
      case DoughType.sourdough:
        optimization['overallRecommendation'] = '천연 발효 특성을 고려한 긴 시간 계획';
        break;
      default:
        optimization['overallRecommendation'] = '표준 파라미터 적용';
    }

    return optimization;
  }
}
