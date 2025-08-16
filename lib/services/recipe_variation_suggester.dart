/// 레시피 변형 제안 시스템
/// 기존 레시피를 기반으로 다양한 변형을 제안합니다.

import 'dart:math' as math;
import '../models/recipe_target.dart';
import '../services/intelligent_recipe_generator.dart';

class RecipeVariationSuggester {
  /// 레시피 변형 제안 생성
  static Future<List<RecipeVariation>> generateVariations({
    required GeneratedRecipeResult baseRecipe,
    required Map<String, dynamic> environmentalConditions,
    int maxVariations = 5,
  }) async {
    try {
      final variations = <RecipeVariation>[];
      
      // 1. 식감 변형 제안
      final textureVariations = await _generateTextureVariations(
        baseRecipe, 
        environmentalConditions
      );
      variations.addAll(textureVariations);
      
      // 2. 풍미 변형 제안
      final flavorVariations = await _generateFlavorVariations(
        baseRecipe, 
        environmentalConditions
      );
      variations.addAll(flavorVariations);
      
      // 3. 재료 대체 변형 제안
      final substitutionVariations = await _generateSubstitutionVariations(
        baseRecipe, 
        environmentalConditions
      );
      variations.addAll(substitutionVariations);
      
      // 4. 스타일 변형 제안
      final styleVariations = await _generateStyleVariations(
        baseRecipe, 
        environmentalConditions
      );
      variations.addAll(styleVariations);
      
      // 5. 난이도 변형 제안
      final difficultyVariations = await _generateDifficultyVariations(
        baseRecipe, 
        environmentalConditions
      );
      variations.addAll(difficultyVariations);
      
      // 점수 기반 정렬 및 제한
      variations.sort((a, b) => b.interestScore.compareTo(a.interestScore));
      
      return variations.take(maxVariations).toList();
    } catch (e) {
      throw RecipeVariationException('변형 제안 생성 중 오류: $e');
    }
  }

  /// 식감 변형 제안
  static Future<List<RecipeVariation>> _generateTextureVariations(
    GeneratedRecipeResult baseRecipe,
    Map<String, dynamic> environmentalConditions
  ) async {
    final variations = <RecipeVariation>[];
    final baseTarget = baseRecipe.originalTarget;
    
    // 더 촉촉한 버전
    if (baseTarget.moistureTarget < 0.9) {
      final moistVariation = await _createVariation(
        baseTarget.copyWith(
          moistureTarget: math.min(1.0, baseTarget.moistureTarget + 0.2),
          targetBakingType: '${baseTarget.targetBakingType} (더 촉촉한 버전)',
        ),
        environmentalConditions,
        '더 촉촉한 식감',
        '수분을 증가시켜 더욱 촉촉한 식감을 구현했습니다.',
        VariationType.texture,
        0.8,
      );
      variations.add(moistVariation);
    }
    
    // 더 쫄깃한 버전
    if (baseTarget.chewinessTarget < 0.9) {
      final chewyVariation = await _createVariation(
        baseTarget.copyWith(
          chewinessTarget: math.min(1.0, baseTarget.chewinessTarget + 0.2),
          targetBakingType: '${baseTarget.targetBakingType} (더 쫄깃한 버전)',
        ),
        environmentalConditions,
        '더 쫄깃한 식감',
        '글루텐 강도를 높여 더욱 쫄깃한 식감을 구현했습니다.',
        VariationType.texture,
        0.8,
      );
      variations.add(chewyVariation);
    }
    
    // 더 부드러운 버전
    if (baseTarget.softnessTarget < 0.9) {
      final softVariation = await _createVariation(
        baseTarget.copyWith(
          softnessTarget: math.min(1.0, baseTarget.softnessTarget + 0.2),
          richnessTarget: math.min(1.0, baseTarget.richnessTarget + 0.1),
          targetBakingType: '${baseTarget.targetBakingType} (더 부드러운 버전)',
        ),
        environmentalConditions,
        '더 부드러운 식감',
        '지방 함량을 증가시켜 더욱 부드러운 식감을 구현했습니다.',
        VariationType.texture,
        0.7,
      );
      variations.add(softVariation);
    }
    
    return variations;
  }

  /// 풍미 변형 제안
  static Future<List<RecipeVariation>> _generateFlavorVariations(
    GeneratedRecipeResult baseRecipe,
    Map<String, dynamic> environmentalConditions
  ) async {
    final variations = <RecipeVariation>[];
    final baseTarget = baseRecipe.originalTarget;
    
    // 더 달콤한 버전
    if (baseTarget.sweetnessTarget < 0.8) {
      final sweetVariation = await _createVariation(
        baseTarget.copyWith(
          sweetnessTarget: math.min(1.0, baseTarget.sweetnessTarget + 0.3),
          targetBakingType: '${baseTarget.targetBakingType} (달콤한 버전)',
        ),
        environmentalConditions,
        '달콤한 풍미',
        '당분을 증가시켜 달콤한 풍미를 강화했습니다.',
        VariationType.flavor,
        0.7,
      );
      variations.add(sweetVariation);
    }
    
    // 더 고소한 버전
    if (baseTarget.richnessTarget < 0.8) {
      final richVariation = await _createVariation(
        baseTarget.copyWith(
          richnessTarget: math.min(1.0, baseTarget.richnessTarget + 0.2),
          targetBakingType: '${baseTarget.targetBakingType} (고소한 버전)',
        ),
        environmentalConditions,
        '고소한 풍미',
        '버터와 견과류 향을 강화하여 고소한 풍미를 구현했습니다.',
        VariationType.flavor,
        0.7,
      );
      variations.add(richVariation);
    }
    
    // 짭짤한 버전
    if (baseTarget.saltinessTarget < 0.6) {
      final saltyVariation = await _createVariation(
        baseTarget.copyWith(
          saltinessTarget: math.min(0.8, baseTarget.saltinessTarget + 0.3),
          targetBakingType: '${baseTarget.targetBakingType} (짭짤한 버전)',
        ),
        environmentalConditions,
        '짭짤한 풍미',
        '소금 함량을 조정하여 짭짤한 풍미를 강화했습니다.',
        VariationType.flavor,
        0.6,
      );
      variations.add(saltyVariation);
    }
    
    return variations;
  }

  /// 재료 대체 변형 제안
  static Future<List<RecipeVariation>> _generateSubstitutionVariations(
    GeneratedRecipeResult baseRecipe,
    Map<String, dynamic> environmentalConditions
  ) async {
    final variations = <RecipeVariation>[];
    final baseTarget = baseRecipe.originalTarget;
    
    // 우유 → 물 대체 (더 심플한 버전)
    if (_hasIngredient(baseRecipe.optimizedIngredients, '우유')) {
      final waterVariation = await _createVariation(
        baseTarget.copyWith(
          targetBakingType: '${baseTarget.targetBakingType} (심플 버전)',
        ),
        environmentalConditions,
        '심플한 재료',
        '우유를 물로 대체하여 더 심플하고 경제적인 레시피입니다.',
        VariationType.substitution,
        0.6,
        substitutions: {'우유': '물'},
      );
      variations.add(waterVariation);
    }
    
    // 버터 → 올리브오일 대체 (건강한 버전)
    if (_hasIngredient(baseRecipe.optimizedIngredients, '버터')) {
      final oilVariation = await _createVariation(
        baseTarget.copyWith(
          targetBakingType: '${baseTarget.targetBakingType} (건강한 버전)',
        ),
        environmentalConditions,
        '건강한 지방',
        '버터를 올리브오일로 대체하여 더 건강한 레시피입니다.',
        VariationType.substitution,
        0.7,
        substitutions: {'버터': '올리브오일'},
      );
      variations.add(oilVariation);
    }
    
    // 설탕 → 꿀 대체 (천연 감미료 버전)
    if (_hasIngredient(baseRecipe.optimizedIngredients, '설탕')) {
      final honeyVariation = await _createVariation(
        baseTarget.copyWith(
          targetBakingType: '${baseTarget.targetBakingType} (천연 감미료 버전)',
        ),
        environmentalConditions,
        '천연 감미료',
        '설탕을 꿀로 대체하여 천연 감미료를 사용한 레시피입니다.',
        VariationType.substitution,
        0.6,
        substitutions: {'설탕': '꿀'},
      );
      variations.add(honeyVariation);
    }
    
    return variations;
  }

  /// 스타일 변형 제안
  static Future<List<RecipeVariation>> _generateStyleVariations(
    GeneratedRecipeResult baseRecipe,
    Map<String, dynamic> environmentalConditions
  ) async {
    final variations = <RecipeVariation>[];
    final baseTarget = baseRecipe.originalTarget;
    
    // 통밀 버전
    if (baseTarget.targetBakingType.contains('식빵')) {
      final wholeWheatVariation = await _createVariation(
        baseTarget.copyWith(
          targetBakingType: '통밀 ${baseTarget.targetBakingType}',
          richnessTarget: math.min(1.0, baseTarget.richnessTarget + 0.1),
        ),
        environmentalConditions,
        '통밀 스타일',
        '통밀가루를 사용하여 더 건강하고 고소한 풍미를 구현했습니다.',
        VariationType.style,
        0.8,
        additions: ['통밀가루'],
      );
      variations.add(wholeWheatVariation);
    }
    
    // 견과류 추가 버전
    final nutVariation = await _createVariation(
      baseTarget.copyWith(
        targetBakingType: '견과류 ${baseTarget.targetBakingType}',
        richnessTarget: math.min(1.0, baseTarget.richnessTarget + 0.2),
      ),
      environmentalConditions,
      '견과류 풍미',
      '호두나 아몬드를 추가하여 고소한 풍미와 식감을 강화했습니다.',
      VariationType.style,
      0.7,
      additions: ['호두', '아몬드'],
    );
    variations.add(nutVariation);
    
    // 허브 버전 (바삭한 빵에 적합)
    if (baseTarget.crispinessTarget > 0.6) {
      final herbVariation = await _createVariation(
        baseTarget.copyWith(
          targetBakingType: '허브 ${baseTarget.targetBakingType}',
          saltinessTarget: math.min(0.8, baseTarget.saltinessTarget + 0.1),
        ),
        environmentalConditions,
        '허브 풍미',
        '로즈마리나 타임을 추가하여 향긋한 허브 풍미를 구현했습니다.',
        VariationType.style,
        0.6,
        additions: ['로즈마리', '타임'],
      );
      variations.add(herbVariation);
    }
    
    return variations;
  }

  /// 난이도 변형 제안
  static Future<List<RecipeVariation>> _generateDifficultyVariations(
    GeneratedRecipeResult baseRecipe,
    Map<String, dynamic> environmentalConditions
  ) async {
    final variations = <RecipeVariation>[];
    final baseTarget = baseRecipe.originalTarget;
    
    // 초보자용 간단 버전
    final beginnerVariation = await _createVariation(
      baseTarget.copyWith(
        targetBakingType: '${baseTarget.targetBakingType} (초보자용)',
      ),
      environmentalConditions,
      '초보자 친화적',
      '재료를 단순화하고 과정을 간소화한 초보자용 레시피입니다.',
      VariationType.difficulty,
      0.8,
      difficultyLevel: DifficultyLevel.beginner,
    );
    variations.add(beginnerVariation);
    
    // 고급자용 복합 버전
    final advancedVariation = await _createVariation(
      baseTarget.copyWith(
        targetBakingType: '${baseTarget.targetBakingType} (고급 버전)',
      ),
      environmentalConditions,
      '고급 기법',
      '복잡한 기법과 특수 재료를 사용한 고급자용 레시피입니다.',
      VariationType.difficulty,
      0.6,
      difficultyLevel: DifficultyLevel.advanced,
      additions: ['탕종', '중종', '천연발효종'],
    );
    variations.add(advancedVariation);
    
    return variations;
  }

  /// 변형 생성 헬퍼
  static Future<RecipeVariation> _createVariation(
    RecipeTarget target,
    Map<String, dynamic> environmentalConditions,
    String variationName,
    String description,
    VariationType type,
    double interestScore, {
    Map<String, String>? substitutions,
    List<String>? additions,
    DifficultyLevel? difficultyLevel,
  }) async {
    // 변형된 레시피 생성
    final generatedResult = await IntelligentRecipeGenerator.generateIntelligentRecipe(
      target: target,
      environmentalConditions: environmentalConditions,
    );
    
    // 대체 재료 적용
    var modifiedIngredients = List<Map<String, dynamic>>.from(generatedResult.optimizedIngredients);
    if (substitutions != null) {
      modifiedIngredients = _applySubstitutions(modifiedIngredients, substitutions);
    }
    
    // 추가 재료 적용
    if (additions != null) {
      modifiedIngredients = _applyAdditions(modifiedIngredients, additions);
    }
    
    return RecipeVariation(
      name: variationName,
      description: description,
      type: type,
      modifiedTarget: target,
      modifiedIngredients: modifiedIngredients,
      originalResult: generatedResult,
      interestScore: interestScore,
      difficultyLevel: difficultyLevel ?? DifficultyLevel.intermediate,
      substitutions: substitutions ?? {},
      additions: additions ?? [],
    );
  }

  /// 재료 대체 적용
  static List<Map<String, dynamic>> _applySubstitutions(
    List<Map<String, dynamic>> ingredients,
    Map<String, String> substitutions
  ) {
    final modified = <Map<String, dynamic>>[];
    
    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      if (substitutions.containsKey(name)) {
        final newName = substitutions[name]!;
        final modifiedIngredient = Map<String, dynamic>.from(ingredient);
        modifiedIngredient['name'] = newName;
        
        // 대체 재료에 따른 양 조정
        if (name == '버터' && newName == '올리브오일') {
          modifiedIngredient['amount'] = (modifiedIngredient['amount'] as double) * 0.8;
        } else if (name == '설탕' && newName == '꿀') {
          modifiedIngredient['amount'] = (modifiedIngredient['amount'] as double) * 0.7;
          modifiedIngredient['unit'] = 'ml';
        }
        
        modified.add(modifiedIngredient);
      } else {
        modified.add(ingredient);
      }
    }
    
    return modified;
  }

  /// 추가 재료 적용
  static List<Map<String, dynamic>> _applyAdditions(
    List<Map<String, dynamic>> ingredients,
    List<String> additions
  ) {
    final modified = List<Map<String, dynamic>>.from(ingredients);
    
    for (final addition in additions) {
      final amount = _getAdditionAmount(addition);
      final unit = _getAdditionUnit(addition);
      
      modified.add({
        'name': addition,
        'amount': amount,
        'unit': unit,
        'category': 'addition',
        'bakersPercentage': (amount / 300.0) * 100.0, // 300g 밀가루 기준
        'role': '풍미 강화',
        'substitutable': true,
      });
    }
    
    return modified;
  }

  /// 재료 존재 확인
  static bool _hasIngredient(List<Map<String, dynamic>> ingredients, String name) {
    return ingredients.any((ingredient) => ingredient['name'] == name);
  }

  /// 추가 재료 양 결정
  static double _getAdditionAmount(String ingredient) {
    switch (ingredient) {
      case '호두':
      case '아몬드':
        return 50.0;
      case '로즈마리':
      case '타임':
        return 2.0;
      case '통밀가루':
        return 50.0; // 일부 대체
      case '탕종':
        return 30.0;
      default:
        return 10.0;
    }
  }

  /// 추가 재료 단위 결정
  static String _getAdditionUnit(String ingredient) {
    switch (ingredient) {
      case '로즈마리':
      case '타임':
        return 'tsp';
      default:
        return 'g';
    }
  }
}

/// 레시피 변형 클래스
class RecipeVariation {
  final String name;
  final String description;
  final VariationType type;
  final RecipeTarget modifiedTarget;
  final List<Map<String, dynamic>> modifiedIngredients;
  final GeneratedRecipeResult originalResult;
  final double interestScore;
  final DifficultyLevel difficultyLevel;
  final Map<String, String> substitutions;
  final List<String> additions;

  const RecipeVariation({
    required this.name,
    required this.description,
    required this.type,
    required this.modifiedTarget,
    required this.modifiedIngredients,
    required this.originalResult,
    required this.interestScore,
    required this.difficultyLevel,
    required this.substitutions,
    required this.additions,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'modifiedTarget': modifiedTarget.toJson(),
      'modifiedIngredients': modifiedIngredients,
      'interestScore': interestScore,
      'difficultyLevel': difficultyLevel.name,
      'substitutions': substitutions,
      'additions': additions,
    };
  }

  /// 변형 요약 텍스트
  String get summaryText {
    final changes = <String>[];
    
    if (substitutions.isNotEmpty) {
      changes.add('${substitutions.length}개 재료 대체');
    }
    
    if (additions.isNotEmpty) {
      changes.add('${additions.length}개 재료 추가');
    }
    
    if (changes.isEmpty) {
      changes.add('특성 조정');
    }
    
    return '${changes.join(', ')} • ${difficultyLevel.displayName}';
  }
}

/// 변형 타입
enum VariationType {
  texture('식감'),
  flavor('풍미'),
  substitution('재료 대체'),
  style('스타일'),
  difficulty('난이도');

  const VariationType(this.displayName);
  final String displayName;
}

/// 난이도 레벨
enum DifficultyLevel {
  beginner('초보자'),
  intermediate('중급자'),
  advanced('고급자');

  const DifficultyLevel(this.displayName);
  final String displayName;
}

/// 레시피 변형 예외
class RecipeVariationException implements Exception {
  final String message;
  const RecipeVariationException(this.message);
  
  @override
  String toString() => 'RecipeVariationException: $message';
}