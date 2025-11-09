import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/bread_method.dart';
import 'package:my_recipe_book/services/baking_science_formula_engine.dart';
import 'package:my_recipe_book/modules/dough_method_classifier.dart';
import '../core/services/dough_temperature_calculator.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';

abstract class BakingModule {
  // Common interface for all baking modules
}

/// 🥖 Phase 4: 고도화된 도우 프로파일 기반 믹싱 시스템
/// infomation.md의 현실 요소들을 반영한 실전형 도우 분석

/// 🍞 고급 재료 프로파일링 시스템
/// 사용자 지정 재료와 세밀한 재료 분류를 지원
class AdvancedIngredientAnalyzer {
  // 사전 정의된 재료 데이터베이스
  static final Map<String, IngredientProfile> _ingredientDatabase = {
    // 밀가루 계열 - 더 세밀한 분류
    '고단백 강력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'high_protein_bread',
        proteinContent: 14.0,
        density: 0.95,
        mixingResistance: 1.2,
        fermentationBoost: 1.1,
        description: '바게트, 사워도우용 고단백 강력분'),
    '중단백 강력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'medium_protein_bread',
        proteinContent: 12.5,
        density: 0.97,
        mixingResistance: 1.0,
        fermentationBoost: 1.0,
        description: '일반 빵용 표준 강력분'),
    '저단백 강력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'low_protein_bread',
        proteinContent: 11.0,
        density: 0.99,
        mixingResistance: 0.9,
        fermentationBoost: 0.95,
        description: '부드러운 식감용 저단백 강력분'),
    '고단백 중력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'high_protein_all_purpose',
        proteinContent: 12.0,
        density: 0.98,
        mixingResistance: 1.1,
        fermentationBoost: 1.05,
        description: '다용도 고단백 중력분'),
    '일반 중력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'standard_all_purpose',
        proteinContent: 10.5,
        density: 1.0,
        mixingResistance: 1.0,
        fermentationBoost: 1.0,
        description: '표준 다용도 중력분'),
    '박력분': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'cake_flour',
        proteinContent: 8.5,
        density: 1.05,
        mixingResistance: 0.8,
        fermentationBoost: 0.9,
        description: '케이크, 쿠키용 박력분'),

    // 통밀/곡물 계열
    '통밀가루': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'whole_wheat',
        proteinContent: 13.0,
        density: 0.88,
        mixingResistance: 1.4,
        fermentationBoost: 0.9,
        description: '영양가 높지만 믹싱 저항 큰 통밀'),
    '호밀가루': IngredientProfile(
        category: IngredientCategory.flour,
        subType: 'rye',
        proteinContent: 9.5,
        density: 0.92,
        mixingResistance: 1.3,
        fermentationBoost: 0.85,
        description: '특유의 풍미와 높은 섬유질'),

    // 이스트 계열 - 더 세밀한 분류
    '인스턴트 드라이 이스트': IngredientProfile(
        category: IngredientCategory.yeast,
        subType: 'instant_dry',
        proteinContent: 40.0,
        density: 1.3,
        mixingResistance: 0.9,
        fermentationBoost: 1.2,
        description: '빠른 발효, 3-5분 활성화 필요'),
    '액티브 드라이 이스트': IngredientProfile(
        category: IngredientCategory.yeast,
        subType: 'active_dry',
        proteinContent: 38.0,
        density: 1.25,
        mixingResistance: 1.0,
        fermentationBoost: 1.1,
        description: '전통적 드라이 이스트, 10분 활성화 필요'),
    '신선 이스트': IngredientProfile(
        category: IngredientCategory.yeast,
        subType: 'fresh',
        proteinContent: 45.0,
        density: 1.2,
        mixingResistance: 0.95,
        fermentationBoost: 1.3,
        description: '최고 발효력, 냉장 보관 필요'),
    '사워도우 스타터': IngredientProfile(
        category: IngredientCategory.yeast,
        subType: 'sourdough_starter',
        proteinContent: 35.0,
        density: 1.15,
        mixingResistance: 1.1,
        fermentationBoost: 0.8,
        description: '천천히 발효, 복합 미생물'),

    // 지방 계열 - 더 세밀한 분류
    '무염버터': IngredientProfile(
        category: IngredientCategory.fat,
        subType: 'unsalted_butter',
        proteinContent: 1.0,
        density: 0.91,
        mixingResistance: 1.2,
        fermentationBoost: 0.95,
        description: '고품질 무염버터, 풍미 우수'),
    '가염버터': IngredientProfile(
        category: IngredientCategory.fat,
        subType: 'salted_butter',
        proteinContent: 1.0,
        density: 0.92,
        mixingResistance: 1.15,
        fermentationBoost: 0.9,
        description: '일반 가염버터, 염분 영향'),
    '올리브 오일': IngredientProfile(
        category: IngredientCategory.fat,
        subType: 'olive_oil',
        proteinContent: 0.0,
        density: 0.92,
        mixingResistance: 1.1,
        fermentationBoost: 1.0,
        description: '건강한 지방, 글루텐에 덜 영향'),
    '카놀라 오일': IngredientProfile(
        category: IngredientCategory.fat,
        subType: 'canola_oil',
        proteinContent: 0.0,
        density: 0.92,
        mixingResistance: 1.05,
        fermentationBoost: 1.0,
        description: '중성 지방, 다용도 사용'),

    // 설탕 계열
    '백설탕': IngredientProfile(
        category: IngredientCategory.sugar,
        subType: 'white_sugar',
        proteinContent: 0.0,
        density: 0.85,
        mixingResistance: 1.3,
        fermentationBoost: 1.1,
        description: '표준 설탕, 빠른 발효 촉진'),
    '흑설탕': IngredientProfile(
        category: IngredientCategory.sugar,
        subType: 'brown_sugar',
        proteinContent: 0.0,
        density: 0.88,
        mixingResistance: 1.25,
        fermentationBoost: 1.05,
        description: '풍미 있는 흑설탕, 수분 함량 높음'),
    '꿀': IngredientProfile(
        category: IngredientCategory.sugar,
        subType: 'honey',
        proteinContent: 0.0,
        density: 1.42,
        mixingResistance: 1.35,
        fermentationBoost: 1.15,
        description: '천연 감미료, 발효력 강함'),
  };

  /// 사용자 지정 재료 등록
  static void registerCustomIngredient(String name, IngredientProfile profile) {
    _ingredientDatabase[name] = profile;
  }

  /// 재료 프로파일 분석 (향상된 버전)
  static IngredientProfile analyzeIngredient(
      String ingredientName, double amount) {
    final normalizedName = ingredientName.toLowerCase().trim();

    // 1. 정확한 이름 매칭 우선
    if (_ingredientDatabase.containsKey(ingredientName)) {
      return _ingredientDatabase[ingredientName]!;
    }

    // 2. 부분 매칭으로 유사 재료 찾기
    for (final entry in _ingredientDatabase.entries) {
      if (normalizedName.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(normalizedName)) {
        return entry.value;
      }
    }

    // 3. 키워드 기반 분류
    return _classifyByKeywords(normalizedName);
  }

  /// 키워드 기반 재료 분류
  static IngredientProfile _classifyByKeywords(String name) {
    // 밀가루 키워드
    if (name.contains('밀가루') || name.contains('flour')) {
      if (name.contains('강력') || name.contains('bread')) {
        return _ingredientDatabase['중단백 강력분']!;
      }
      if (name.contains('박력') || name.contains('cake')) {
        return _ingredientDatabase['박력분']!;
      }
      if (name.contains('통밀') || name.contains('whole')) {
        return _ingredientDatabase['통밀가루']!;
      }
      return _ingredientDatabase['일반 중력분']!;
    }

    // 이스트 키워드
    if (name.contains('이스트') || name.contains('효모') || name.contains('yeast')) {
      if (name.contains('인스턴트') || name.contains('instant')) {
        return _ingredientDatabase['인스턴트 드라이 이스트']!;
      }
      if (name.contains('드라이') || name.contains('dry')) {
        return _ingredientDatabase['액티브 드라이 이스트']!;
      }
      if (name.contains('신선') || name.contains('fresh')) {
        return _ingredientDatabase['신선 이스트']!;
      }
      return _ingredientDatabase['인스턴트 드라이 이스트']!;
    }

    // 버터/지방 키워드
    if (name.contains('버터') || name.contains('butter')) {
      if (name.contains('무염') || name.contains('unsalted')) {
        return _ingredientDatabase['무염버터']!;
      }
      return _ingredientDatabase['가염버터']!;
    }

    // 오일 키워드
    if (name.contains('오일') || name.contains('oil')) {
      if (name.contains('올리브') || name.contains('olive')) {
        return _ingredientDatabase['올리브 오일']!;
      }
      return _ingredientDatabase['카놀라 오일']!;
    }

    // 설탕 키워드
    if (name.contains('설탕') || name.contains('sugar')) {
      if (name.contains('흑설탕') || name.contains('brown')) {
        return _ingredientDatabase['흑설탕']!;
      }
      if (name.contains('꿀') || name.contains('honey')) {
        return _ingredientDatabase['꿀']!;
      }
      return _ingredientDatabase['백설탕']!;
    }

    // 물/우유 키워드
    if (name.contains('물') || name.contains('water')) {
      return IngredientProfile(
          category: IngredientCategory.liquid,
          subType: 'water',
          proteinContent: 0.0,
          density: 1.0,
          mixingResistance: 1.0,
          fermentationBoost: 1.0,
          description: '물/액체 기본값');
    }

    // 기본값: 알 수 없는 재료는 중성값
    return IngredientProfile(
        category: IngredientCategory.other,
        subType: 'unknown',
        proteinContent: 0.0,
        density: 1.0,
        mixingResistance: 1.0,
        fermentationBoost: 1.0,
        description: '알 수 없는 재료 (중성값 적용)');
  }

  /// 재료 상호작용 분석
  static IngredientInteractions analyzeInteractions(
      List<IngredientProfile> ingredients) {
    final interactions = <String>[];

    // 이스트와 소금의 상호작용
    final hasYeast =
        ingredients.any((i) => i.category == IngredientCategory.yeast);
    final hasSalt =
        ingredients.any((i) => i.category == IngredientCategory.salt);

    if (hasYeast && hasSalt) {
      interactions.add('이스트-소금 상호작용: 발효 속도 10-15% 감소 예상');
    }

    // 지방과 글루텐 형성
    final fatRatio = ingredients
        .where((i) => i.category == IngredientCategory.fat)
        .fold(0.0, (sum, i) => sum + 1); // 단순 개수로 계산

    if (fatRatio > 2) {
      interactions.add('고지방: 글루텐 형성 20-30% 약화 예상');
    }

    // 설탕과 발효
    final sugarRatio = ingredients
        .where((i) => i.category == IngredientCategory.sugar)
        .fold(0.0, (sum, i) => sum + 1);

    if (sugarRatio > 1) {
      interactions.add('고당분: 발효 속도 15-25% 향상 예상');
    }

    return IngredientInteractions(
        interactions: interactions,
        riskLevel: interactions.length > 2
            ? 'high'
            : interactions.isEmpty
                ? 'low'
                : 'medium',
        recommendations: _generateRecommendations(interactions));
  }

  /// 상호작용 기반 추천사항 생성
  static List<String> _generateRecommendations(List<String> interactions) {
    final recommendations = <String>[];

    if (interactions.any((i) => i.contains('이스트-소금'))) {
      recommendations.add('이스트와 소금은 따로 섞지 말고 순차적으로 추가하세요');
    }

    if (interactions.any((i) => i.contains('고지방'))) {
      recommendations.add('지방이 많은 경우 믹싱 시간을 20% 연장하세요');
    }

    if (interactions.any((i) => i.contains('고당분'))) {
      recommendations.add('설탕이 많은 경우 발효 시간을 모니터링하세요');
    }

    return recommendations;
  }

  /// 재료별 상세 리포트 생성
  static String generateDetailedReport(List<IngredientProfile> ingredients) {
    final buffer = StringBuffer();

    buffer.writeln('📊 **재료별 상세 분석 리포트**');
    buffer.writeln('=' * 50);

    // 카테고리별 그룹화
    final categories = <IngredientCategory, List<IngredientProfile>>{};
    for (final ingredient in ingredients) {
      categories.putIfAbsent(ingredient.category, () => []).add(ingredient);
    }

    // 각 카테고리별 분석
    for (final category in categories.keys) {
      buffer.writeln('\n🔍 **${_getCategoryName(category)} 분석**');
      for (final ingredient in categories[category]!) {
        buffer.writeln('  • ${ingredient.description}');
        buffer.writeln(
            '    - 단백질: ${ingredient.proteinContent.toStringAsFixed(1)}%');
        buffer.writeln('    - 밀도: ${ingredient.density.toStringAsFixed(2)}');
        buffer.writeln(
            '    - 믹싱 저항: ${ingredient.mixingResistance.toStringAsFixed(2)}');
        buffer.writeln(
            '    - 발효 촉진: ${ingredient.fermentationBoost.toStringAsFixed(2)}');
      }
    }

    // 상호작용 분석
    final interactions = analyzeInteractions(ingredients);
    if (interactions.interactions.isNotEmpty) {
      buffer.writeln('\n⚗️ **재료 상호작용 분석**');
      buffer.writeln('리스크 수준: ${interactions.riskLevel}');

      for (final interaction in interactions.interactions) {
        buffer.writeln('  • $interaction');
      }

      if (interactions.recommendations.isNotEmpty) {
        buffer.writeln('\n💡 **권장사항**');
        for (final recommendation in interactions.recommendations) {
          buffer.writeln('  • $recommendation');
        }
      }
    }

    return buffer.toString();
  }

  static String _getCategoryName(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.flour:
        return '밀가루';
      case IngredientCategory.yeast:
        return '이스트';
      case IngredientCategory.fat:
        return '지방';
      case IngredientCategory.sugar:
        return '설탕';
      case IngredientCategory.liquid:
        return '액체';
      case IngredientCategory.salt:
        return '소금';
      case IngredientCategory.other:
        return '기타';
    }
  }
}

/// 재료 프로파일
class IngredientProfile {
  final IngredientCategory category;
  final String subType;
  final double proteinContent; // 단백질 함량 (%)
  final double density; // 밀도 (g/ml)
  final double mixingResistance; // 믹싱 저항 계수
  final double fermentationBoost; // 발효 촉진 계수
  final String description; // 재료 설명

  const IngredientProfile({
    required this.category,
    required this.subType,
    required this.proteinContent,
    required this.density,
    required this.mixingResistance,
    required this.fermentationBoost,
    required this.description,
  });
}

/// 재료 카테고리
enum IngredientCategory {
  flour, // 밀가루
  yeast, // 이스트
  fat, // 지방
  sugar, // 설탕
  liquid, // 액체
  salt, // 소금
  other, // 기타
}

/// 재료 상호작용 분석 결과
class IngredientInteractions {
  final List<String> interactions;
  final String riskLevel;
  final List<String> recommendations;

  const IngredientInteractions({
    required this.interactions,
    required this.riskLevel,
    required this.recommendations,
  });
}

/// 도우 강도 분류
enum DoughStrength {
  soft, // 부드러운 도우 (고하이드레이션, 저단백)
  medium, // 중간 도우 (일반 빵)
  strong, // 강한 도우 (저하이드레이션, 고단백)
  veryStrong, // 매우 강한 도우 (바게트 등)
}

/// 밀가루 종류별 특성
enum FlourType {
  breadFlour, // 강력분 (고단백, 12-14%)
  allPurpose, // 중력분 (중단백, 10-12%)
  cakeFlour, // 박력분 (저단백, 8-10%)
  wholeWheat, // 통밀 (중단백, 섬유질 많음)
  rye, // 호밀 (저단백, 특유의 풍미)
  oat, // 귀리 (저단백, 특유의 텍스처)
  spelt, // 스펠트밀 (중단백, 소화가 잘됨)
}

/// 도우 프로파일 - infomation.md 기반 현실적 분석
class DoughProfile {
  final double hydration; // 하이드레이션 (%)
  final double proteinContent; // 단백질 함량 (%)
  final double starterRatio; // 스타터 비율 (%)
  final double doughMassKg; // 반죽 질량 (kg) ⭐ 핵심 현실 요소
  final double fatRatio; // 지방 비율 (%) ⭐ 핵심 현실 요소
  final double sugarRatio; // 설탕 비율 (%) ⭐ 핵심 현실 요소
  final double saltRatio; // 소금 비율 (%) ⭐ 핵심 현실 요소
  final FlourType flourType; // 밀가루 종류 ⭐ 핵심 현실 요소
  final String method; // 도법
  final DoughStrength strength; // 도우 강도

  const DoughProfile({
    required this.hydration,
    required this.proteinContent,
    required this.starterRatio,
    required this.doughMassKg,
    required this.fatRatio,
    required this.sugarRatio,
    required this.saltRatio,
    required this.flourType,
    required this.method,
    required this.strength,
  });

  /// 도우 특성 설명
  String get description {
    final flourName = _getFlourTypeName();
    final strengthName = _getStrengthName();
    return '$flourName 기반 $strengthName 도우 (수분: ${hydration.toStringAsFixed(1)}%, 단백질: ${proteinContent.toStringAsFixed(1)}%, 질량: ${doughMassKg.toStringAsFixed(1)}kg)';
  }

  String _getFlourTypeName() {
    switch (flourType) {
      case FlourType.breadFlour:
        return '강력분';
      case FlourType.allPurpose:
        return '중력분';
      case FlourType.cakeFlour:
        return '박력분';
      case FlourType.wholeWheat:
        return '통밀';
      case FlourType.rye:
        return '호밀';
      case FlourType.oat:
        return '귀리';
      case FlourType.spelt:
        return '스펠트밀';
    }
  }

  String _getStrengthName() {
    switch (strength) {
      case DoughStrength.soft:
        return '부드러운';
      case DoughStrength.medium:
        return '중간';
      case DoughStrength.strong:
        return '강한';
      case DoughStrength.veryStrong:
        return '매우 강한';
    }
  }
}

/// 믹싱 파라미터 - 도우 특성 기반 최적화
class MixingParameters {
  final String speed; // 믹싱 속도 (저속/중속/고속)
  final double duration; // 믹싱 시간 (분)
  final double restInterval; // 휴식 간격 (분)
  final double totalHeatLimit; // 총 열 제한 (°C)
  final double efficiencyMultiplier; // 효율 배수
  final List<String> specialNotes; // 특수 메모
  final Map<String, double> factors; // 세부 보정 계수들

  const MixingParameters({
    required this.speed,
    required this.duration,
    required this.restInterval,
    required this.totalHeatLimit,
    required this.efficiencyMultiplier,
    required this.specialNotes,
    required this.factors,
  });

  /// 믹싱 파라미터 설명
  String get description {
    return '속도: $speed, 시간: ${duration.toStringAsFixed(1)}분, 휴식: ${restInterval.toStringAsFixed(1)}분, 열제한: ${totalHeatLimit.toStringAsFixed(1)}°C';
  }
}

/// 도우 프로파일 분석기 - infomation.md 기반 현실적 분석
class DoughProfileAnalyzer {
  /// 레시피로부터 도우 프로파일 분석
  static DoughProfile analyze(Recipe recipe) {
    // 밀가루 포함 여부 검증
    final hasFlour = recipe.ingredients.any((ingredient) => ingredient.isFlour);
    if (!hasFlour) {
      BakingLogger.log(
        level: LogLevel.ERROR,
        category: 'dough_profile_analysis',
        message: '밀가루가 포함되지 않은 레시피입니다',
        data: {
          'recipe_title': recipe.title,
          'ingredients': recipe.ingredients.map((i) => i.name).toList(),
        },
      );
      throw ArgumentError('밀가루가 포함되지 않은 레시피입니다');
    }

    return DoughProfile(
      hydration: _calculateHydration(recipe),
      proteinContent: _calculateEffectiveProtein(recipe),
      starterRatio: _getStarterRatio(recipe),
      doughMassKg: _calculateTotalMass(recipe), // ⭐ 신규: 반죽 질량
      fatRatio: _calculateFatRatio(recipe), // ⭐ 신규: 지방 비율
      sugarRatio: _calculateSugarRatio(recipe), // ⭐ 신규: 설탕 비율
      saltRatio: _calculateSaltRatio(recipe), // ⭐ 신규: 소금 비율
      flourType: _determineFlourType(recipe), // ⭐ 신규: 밀가루 종류
      method: _determineMethod(recipe),
      strength: _calculateStrength(recipe),
    );
  }

  /// 하이드레이션 계산 (물/밀가루 비율 %)
  static double _calculateHydration(Recipe recipe) {
    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 65.0; // 기본값

    final waterAmount = recipe.ingredients
        .where((i) => i.isWater)
        .fold(0.0, (sum, i) => sum + i.amount);

    return (waterAmount / flourAmount) * 100;
  }

  /// 유효 단백질 함량 계산 (밀가루 종류별 보정)
  static double _calculateEffectiveProtein(Recipe recipe) {
    final flourIngredients = recipe.ingredients.where((i) => i.isFlour);
    if (flourIngredients.isEmpty) return 11.0; // 기본값

    double totalProtein = 0.0;
    double totalFlour = 0.0;

    for (final ingredient in flourIngredients) {
      final protein = ingredient.proteinContent;
      totalProtein += protein * ingredient.amount;
      totalFlour += ingredient.amount;
    }

    return totalFlour > 0 ? totalProtein / totalFlour : 11.0;
  }

  /// 스타터 비율 계산
  static double _getStarterRatio(Recipe recipe) {
    final starterIngredients = recipe.ingredients.where((i) => i.isYeast);
    if (starterIngredients.isEmpty) return 0.0;

    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 0.0;

    final starterAmount =
        starterIngredients.fold(0.0, (sum, i) => sum + i.amount);
    return (starterAmount / flourAmount) * 100;
  }

  /// 총 반죽 질량 계산 (kg) ⭐ 핵심 현실 요소
  static double _calculateTotalMass(Recipe recipe) {
    final totalGrams = recipe.ingredients.fold(0.0, (sum, i) => sum + i.amount);
    return totalGrams / 1000.0; // g → kg 변환
  }

  /// 지방 비율 계산 (% of flour weight) ⭐ 핵심 현실 요소
  static double _calculateFatRatio(Recipe recipe) {
    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 0.0;

    final fatAmount = recipe.ingredients
        .where((i) => i.isFat)
        .fold(0.0, (sum, i) => sum + i.amount);

    return (fatAmount / flourAmount) * 100;
  }

  /// 설탕 비율 계산 (%) ⭐ 핵심 현실 요소
  static double _calculateSugarRatio(Recipe recipe) {
    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 0.0;

    final sugarAmount = recipe.ingredients
        .where((i) => i.isSugar)
        .fold(0.0, (sum, i) => sum + i.amount);

    return (sugarAmount / flourAmount) * 100;
  }

  /// 소금 비율 계산 (%) ⭐ 핵심 현실 요소
  static double _calculateSaltRatio(Recipe recipe) {
    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 0.0;

    final saltAmount = recipe.ingredients
        .where((i) => i.isSalt)
        .fold(0.0, (sum, i) => sum + i.amount);

    return (saltAmount / flourAmount) * 100;
  }

  /// 밀가루 종류 판정 ⭐ 핵심 현실 요소
  static FlourType _determineFlourType(Recipe recipe) {
    final flourIngredients = recipe.ingredients.where((i) => i.isFlour);
    if (flourIngredients.isEmpty) return FlourType.allPurpose;

    // 주요 밀가루 성분 분석
    for (final ingredient in flourIngredients) {
      final name = ingredient.name.toLowerCase();

      if (name.contains('강력분') || name.contains('bread flour')) {
        return FlourType.breadFlour;
      }
      if (name.contains('박력분') || name.contains('cake flour')) {
        return FlourType.cakeFlour;
      }
      if (name.contains('통밀') || name.contains('whole wheat')) {
        return FlourType.wholeWheat;
      }
      if (name.contains('호밀') || name.contains('rye')) {
        return FlourType.rye;
      }
      if (name.contains('귀리') || name.contains('oat')) {
        return FlourType.oat;
      }
      if (name.contains('스펠트') || name.contains('spelt')) {
        return FlourType.spelt;
      }
    }

    return FlourType.allPurpose; // 기본값
  }

  /// 도법 판정
  static String _determineMethod(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    final ingredients =
        recipe.ingredients.map((e) => e.name.toLowerCase()).join(' ');

    if (title.contains('sourdough') ||
        ingredients.contains('sourdough') ||
        title.contains('사워도우')) {
      return 'sourdough';
    }
    if (title.contains('levain') ||
        ingredients.contains('levain') ||
        title.contains('르방')) {
      return 'levain';
    }
    return 'straight';
  }

  /// 도우 강도 계산 (복합 분석)
  static DoughStrength _calculateStrength(Recipe recipe) {
    final protein = _calculateEffectiveProtein(recipe);
    final hydration = _calculateHydration(recipe);
    final fatRatio = _calculateFatRatio(recipe);
    final flourType = _determineFlourType(recipe);

    // 복합 점수 계산
    double strengthScore = 0;

    // 단백질 함량 점수 (0-40점)
    if (protein > 14)
      strengthScore += 40;
    else if (protein > 12)
      strengthScore += 30;
    else if (protein > 10)
      strengthScore += 20;
    else
      strengthScore += 10;

    // 하이드레이션 점수 (0-30점)
    if (hydration < 60)
      strengthScore += 30; // 저수분 = 강한 도우
    else if (hydration < 70)
      strengthScore += 20; // 중수분 = 중간 도우
    else if (hydration < 80) strengthScore += 10; // 고수분 = 부드러운 도우
    // 80% 이상 = 매우 부드러운 도우

    // 지방 함량 점수 (0-20점)
    if (fatRatio > 20)
      strengthScore -= 20; // 고지방 = 도우 약화
    else if (fatRatio > 10) strengthScore -= 10; // 중지방 = 약간 약화

    // 밀가루 종류 점수 (0-10점)
    if (flourType == FlourType.breadFlour)
      strengthScore += 10;
    else if (flourType == FlourType.wholeWheat) strengthScore += 5;

    // 점수에 따른 강도 분류
    if (strengthScore >= 70) return DoughStrength.veryStrong;
    if (strengthScore >= 50) return DoughStrength.strong;
    if (strengthScore >= 30) return DoughStrength.medium;
    return DoughStrength.soft;
  }

  /// 밀가루 양 계산 헬퍼
  static double _getFlourAmount(Recipe recipe) {
    return recipe.ingredients
        .where((i) => i.isFlour)
        .fold(0.0, (sum, i) => sum + i.amount);
  }
}

/// 믹싱 전략 최적화 엔진 - infomation.md 기반 현실적 최적화
class MixingStrategyOptimizer {
  /// 도우 프로파일과 환경 조건을 고려한 최적 믹싱 파라미터 계산
  static MixingParameters optimize(
      DoughProfile profile, EnvironmentalConditions env) {
    // 1. 기본 파라미터 계산
    final baseParams = _calculateBaseParameters(profile);

    // 2. 질량 보정 적용 ⭐ 신규 (infomation.md 핵심)
    final massCorrected = _applyMassCorrection(baseParams, profile.doughMassKg);

    // 3. 첨가물 보정 적용 ⭐ 신규 (infomation.md 핵심)
    final additiveCorrected = _applyAdditiveCorrection(massCorrected, profile);

    // 4. 밀가루 종류 보정 적용 ⭐ 신규 (infomation.md 핵심)
    final flourCorrected =
        _applyFlourTypeCorrection(additiveCorrected, profile.flourType);

    // 5. 환경 보정 적용
    return _applyEnvironmentalCorrection(flourCorrected, env);
  }

  /// 기본 믹싱 파라미터 계산
  static MixingParameters _calculateBaseParameters(DoughProfile profile) {
    final factors = <String, double>{};

    // 도우 강도별 기본 설정
    switch (profile.strength) {
      case DoughStrength.soft:
        return MixingParameters(
          speed: '저속',
          duration: 12.0,
          restInterval: 2.0,
          totalHeatLimit: 18.0,
          efficiencyMultiplier: 0.9,
          specialNotes: ['고하이드레이션 도우: 천천히 믹싱하여 과열 방지'],
          factors: {'base': 1.0, 'strength': 0.8},
        );

      case DoughStrength.medium:
        return MixingParameters(
          speed: '중속',
          duration: 10.0,
          restInterval: 1.5,
          totalHeatLimit: 16.0,
          efficiencyMultiplier: 1.0,
          specialNotes: ['일반 빵 도우: 표준 믹싱 파라미터'],
          factors: {'base': 1.0, 'strength': 1.0},
        );

      case DoughStrength.strong:
        return MixingParameters(
          speed: '고속',
          duration: 8.0,
          restInterval: 1.0,
          totalHeatLimit: 14.0,
          efficiencyMultiplier: 1.1,
          specialNotes: ['저하이드레이션 도우: 빠른 믹싱으로 글루텐 형성 촉진'],
          factors: {'base': 1.0, 'strength': 1.2},
        );

      case DoughStrength.veryStrong:
        return MixingParameters(
          speed: '고속',
          duration: 6.0,
          restInterval: 0.5,
          totalHeatLimit: 12.0,
          efficiencyMultiplier: 1.2,
          specialNotes: ['바게트용 도우: 강력한 믹싱으로 글루텐 네트워크 강화'],
          factors: {'base': 1.0, 'strength': 1.4},
        );
    }
  }

  /// 반죽 질량 보정 ⭐ 핵심 현실 요소 (infomation.md 기반)
  static MixingParameters _applyMassCorrection(
      MixingParameters params, double massKg) {
    final factors = Map<String, double>.from(params.factors);
    final notes = List<String>.from(params.specialNotes);

    // 질량별 보정 (500g vs 5kg의 마찰열 흡수 차이)
    double massMultiplier = 1.0;
    if (massKg < 1.0) {
      massMultiplier = 1.2; // 1kg 미만: 열 흡수 적음, 믹싱 조정 필요
      notes.add('소량 반죽: 과열 주의, 믹싱 시간 단축 권장');
    } else if (massKg > 3.0) {
      massMultiplier = 0.8; // 3kg 이상: 열 흡수 좋음, 강력한 믹싱 가능
      notes.add('대량 반죽: 강력한 믹싱 가능, 열 관리 유리');
    }

    // 질량에 따른 시간 조정
    final adjustedDuration = params.duration * massMultiplier;
    final adjustedHeatLimit = params.totalHeatLimit * massMultiplier;

    factors['mass_correction'] = massMultiplier;

    return MixingParameters(
      speed: params.speed,
      duration: adjustedDuration.clamp(3.0, 25.0), // 3분 ~ 25분 범위
      restInterval: params.restInterval,
      totalHeatLimit: adjustedHeatLimit.clamp(8.0, 25.0), // 8°C ~ 25°C 범위
      efficiencyMultiplier: params.efficiencyMultiplier * massMultiplier,
      specialNotes: notes,
      factors: factors,
    );
  }

  /// 첨가물 보정 적용 ⭐ 핵심 현실 요소 (infomation.md 기반)
  static MixingParameters _applyAdditiveCorrection(
      MixingParameters params, DoughProfile profile) {
    final factors = Map<String, double>.from(params.factors);
    final notes = List<String>.from(params.specialNotes);

    double additiveMultiplier = 1.0;

    // 지방 영향 (지방 → 글루텐 약화, 믹싱 시간 ↑)
    if (profile.fatRatio > 20) {
      additiveMultiplier *= 1.3;
      notes.add('고지방 도우: 믹싱 시간 30% 연장 필요');
    } else if (profile.fatRatio > 10) {
      additiveMultiplier *= 1.1;
      notes.add('중지방 도우: 믹싱 시간 10% 연장 필요');
    }

    // 설탕 영향 (설탕 → 점성 ↑, 믹싱 저항 ↑)
    if (profile.sugarRatio > 15) {
      additiveMultiplier *= 1.25;
      notes.add('고당분 도우: 점성 증가로 믹싱 저항 ↑');
    } else if (profile.sugarRatio > 5) {
      additiveMultiplier *= 1.1;
      notes.add('중당분 도우: 약간의 믹싱 저항 증가');
    }

    // 소금 영향 (소금 → 글루텐 강화, 믹싱 효율 ↑)
    if (profile.saltRatio > 2.5) {
      additiveMultiplier *= 0.9;
      notes.add('고염분 도우: 글루텐 강화로 믹싱 효율 ↑');
    } else if (profile.saltRatio < 1.5) {
      additiveMultiplier *= 1.1;
      notes.add('저염분 도우: 글루텐 약화로 믹싱 시간 연장 필요');
    }

    factors['fat_effect'] = profile.fatRatio > 10 ? 0.9 : 1.0;
    factors['sugar_effect'] = profile.sugarRatio > 5 ? 0.95 : 1.0;
    factors['salt_effect'] = profile.saltRatio > 2.0 ? 1.05 : 1.0;

    return MixingParameters(
      speed: params.speed,
      duration: (params.duration * additiveMultiplier).clamp(3.0, 30.0),
      restInterval: params.restInterval,
      totalHeatLimit: params.totalHeatLimit,
      efficiencyMultiplier: params.efficiencyMultiplier * additiveMultiplier,
      specialNotes: notes,
      factors: factors,
    );
  }

  /// 밀가루 종류 보정 적용 ⭐ 핵심 현실 요소 (infomation.md 기반)
  static MixingParameters _applyFlourTypeCorrection(
      MixingParameters params, FlourType flourType) {
    final factors = Map<String, double>.from(params.factors);
    final notes = List<String>.from(params.specialNotes);

    String speed = params.speed;
    double duration = params.duration;
    double flourMultiplier = 1.0;

    switch (flourType) {
      case FlourType.breadFlour:
        // 강력분: 글루텐 형성 빠름, 강력한 믹싱 가능
        flourMultiplier = 0.9;
        speed = '고속';
        notes.add('강력분: 글루텐 형성 빠름, 강력한 믹싱으로 효율 ↑');
        break;

      case FlourType.allPurpose:
        // 중력분: 표준 믹싱
        flourMultiplier = 1.0;
        notes.add('중력분: 표준 믹싱 파라미터 적용');
        break;

      case FlourType.cakeFlour:
        // 박력분: 글루텐 형성 느림, 약한 믹싱
        flourMultiplier = 1.3;
        speed = '저속';
        notes.add('박력분: 글루텐 형성 느림, 약한 믹싱으로 과개발 방지');
        break;

      case FlourType.wholeWheat:
        // 통밀: 섬유질로 믹싱 저항 ↑
        flourMultiplier = 1.2;
        notes.add('통밀: 섬유질로 믹싱 저항 증가, 시간 연장 필요');
        break;

      case FlourType.rye:
        // 호밀: 특유의 믹싱 특성
        flourMultiplier = 1.1;
        notes.add('호밀: 특유의 점성, 주의 깊은 믹싱 필요');
        break;

      case FlourType.oat:
      case FlourType.spelt:
        // 귀리/스펠트: 특수 곡물
        flourMultiplier = 1.1;
        notes.add('특수 곡물: 독특한 믹싱 특성, 모니터링 필요');
        break;
    }

    factors['flour_type'] = flourMultiplier;

    return MixingParameters(
      speed: speed,
      duration: (duration * flourMultiplier).clamp(3.0, 30.0),
      restInterval: params.restInterval,
      totalHeatLimit: params.totalHeatLimit,
      efficiencyMultiplier: params.efficiencyMultiplier * flourMultiplier,
      specialNotes: notes,
      factors: factors,
    );
  }

  /// 환경 조건 보정 적용
  static MixingParameters _applyEnvironmentalCorrection(
      MixingParameters params, EnvironmentalConditions env) {
    final factors = Map<String, double>.from(params.factors);
    final notes = List<String>.from(params.specialNotes);

    double envMultiplier = 1.0;

    // 더운 환경: 믹싱 시간 단축
    if (env.temperature > 25) {
      envMultiplier *= 0.9;
      notes.add('더운 환경: 마찰열 증가, 믹싱 시간 10% 단축');
    }

    // 습한 환경: 믹싱 저항 증가
    if (env.humidity > 70) {
      envMultiplier *= 1.1;
      notes.add('고습 환경: 믹싱 저항 증가, 시간 10% 연장');
    }

    factors['environmental'] = envMultiplier;

    return MixingParameters(
      speed: params.speed,
      duration: (params.duration * envMultiplier).clamp(3.0, 30.0),
      restInterval: params.restInterval,
      totalHeatLimit: params.totalHeatLimit,
      efficiencyMultiplier: params.efficiencyMultiplier * envMultiplier,
      specialNotes: notes,
      factors: factors,
    );
  }
}

/// Phase 3-4: 상세 로깅 시스템 (개선된 버전)
enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR,
}

class BakingLogger {
  static LogLevel currentLevel = LogLevel.INFO;
  static final List<Map<String, dynamic>> _logBuffer = [];
  static const int maxBufferSize = 1000;

  /// 구조화된 로그 기록
  static void log({
    required LogLevel level,
    required String category,
    required String message,
    Map<String, dynamic>? data,
    String? userId,
    String? sessionId,
  }) {
    if (level.index < currentLevel.index) return;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'category': category,
      'message': message,
      'data': data ?? {},
      'userId': userId ?? 'anonymous',
      'sessionId': sessionId ?? 'unknown',
      'performance': _getPerformanceMetrics(),
    };

    // 메모리 버퍼에 저장
    _logBuffer.add(logEntry);
    if (_logBuffer.length > maxBufferSize) {
      _logBuffer.removeAt(0);
    }

    // 콘솔 출력 (개발용)
    _printLog(logEntry);
  }

  /// 믹싱 프로세스 상세 로깅
  static void logMixingProcess({
    required String step,
    required String speed,
    required double time,
    required double frictionHeat,
    required double currentTemp,
    required Map<String, double> factors,
    String? mixerType,
  }) {
    log(
      level: LogLevel.DEBUG,
      category: 'mixing_process',
      message: '믹싱 단계 실행',
      data: {
        'step': step,
        'speed': speed,
        'time': time,
        'frictionHeat': frictionHeat,
        'currentTemp': currentTemp,
        'mixerType': mixerType ?? 'unknown',
        'factors': factors,
        'stepMetrics': _calculateStepMetrics(step, time, frictionHeat),
      },
    );
  }

  /// 계산 성능 로깅
  static void logCalculationPerformance({
    required String operation,
    required Duration duration,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
    required double accuracy,
  }) {
    log(
      level: LogLevel.INFO,
      category: 'calculation_performance',
      message: '계산 작업 완료',
      data: {
        'operation': operation,
        'durationMs': duration.inMilliseconds,
        'inputs': inputs,
        'outputs': outputs,
        'accuracy': accuracy,
        'performanceScore': _calculatePerformanceScore(duration, accuracy),
      },
    );
  }

  /// 사용자 행동 패턴 로깅
  static void logUserBehavior({
    required String action,
    required String feature,
    required Map<String, dynamic> parameters,
    required Duration sessionDuration,
  }) {
    log(
      level: LogLevel.INFO,
      category: 'user_behavior',
      message: '사용자 행동 기록',
      data: {
        'action': action,
        'feature': feature,
        'parameters': parameters,
        'sessionDuration': sessionDuration.inMinutes,
        'userPreferences': _getUserPreferences(),
      },
    );
  }

  /// 시스템 상태 로깅
  static void logSystemStatus({
    required String component,
    required String status,
    required Map<String, dynamic> metrics,
    List<String>? issues,
  }) {
    log(
      level: status == 'error' ? LogLevel.ERROR : LogLevel.INFO,
      category: 'system_status',
      message: '시스템 상태 업데이트',
      data: {
        'component': component,
        'status': status,
        'metrics': metrics,
        'issues': issues ?? [],
        'systemHealth': _calculateSystemHealth(metrics),
      },
    );
  }

  /// 로그 파일로 저장
  static Future<void> saveLogsToFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonLogs = jsonEncode(_logBuffer);
      await file.writeAsString(jsonLogs);

      log(
        level: LogLevel.INFO,
        category: 'file_operation',
        message: '로그 파일 저장 완료',
        data: {
          'filePath': filePath,
          'logCount': _logBuffer.length,
          'fileSize': jsonLogs.length,
        },
      );
    } catch (e) {
      log(
        level: LogLevel.ERROR,
        category: 'file_operation',
        message: '로그 파일 저장 실패',
        data: {'error': e.toString(), 'filePath': filePath},
      );
    }
  }

  /// 로그 분석 데이터 생성
  static Map<String, dynamic> generateAnalyticsData() {
    final analytics = {
      'totalLogs': _logBuffer.length,
      'logLevelDistribution': _calculateLogLevelDistribution(),
      'categoryUsage': _calculateCategoryUsage(),
      'performanceMetrics': _calculateAveragePerformance(),
      'userBehaviorPatterns': _analyzeUserBehavior(),
      'systemHealthTrends': _analyzeSystemHealth(),
      'generatedAt': DateTime.now().toIso8601String(),
    };

    log(
      level: LogLevel.INFO,
      category: 'analytics',
      message: '분석 데이터 생성 완료',
      data: analytics,
    );

    return analytics;
  }

  /// 로그 레벨 변경
  static void setLogLevel(LogLevel level) {
    currentLevel = level;
    log(
      level: LogLevel.INFO,
      category: 'configuration',
      message: '로그 레벨 변경',
      data: {'newLevel': level.name, 'previousLevel': currentLevel.name},
    );
  }

  // ========== 내부 헬퍼 메서드들 ==========

  static Map<String, dynamic> _getPerformanceMetrics() {
    return {
      'memoryUsage': 'unknown', // 실제 앱에서는 ProcessInfo.currentRss 사용
      'cpuUsage': 'unknown',
      'batteryLevel': 'unknown',
      'networkStatus': 'unknown',
    };
  }

  static Map<String, dynamic> _calculateStepMetrics(
      String step, double time, double frictionHeat) {
    return {
      'step': step,
      'time': time,
      'frictionHeat': frictionHeat,
      'heatPerMinute': time > 0 ? frictionHeat / time : 0,
      'efficiency': _calculateStepEfficiency(step, time, frictionHeat),
    };
  }

  static double _calculateStepEfficiency(
      String step, double time, double frictionHeat) {
    // 단계별 효율성 계산 (간단한 예시)
    switch (step) {
      case '저속':
        return time > 0 ? (frictionHeat / time) * 0.8 : 0;
      case '중속':
        return time > 0 ? (frictionHeat / time) * 1.0 : 0;
      case '고속':
        return time > 0 ? (frictionHeat / time) * 1.2 : 0;
      default:
        return time > 0 ? (frictionHeat / time) : 0;
    }
  }

  static double _calculatePerformanceScore(Duration duration, double accuracy) {
    // 성능 점수 계산 (0-100)
    final timeScore = math.max(0, 100 - (duration.inMilliseconds / 10));
    final accuracyScore = accuracy * 100;
    return (timeScore + accuracyScore) / 2;
  }

  static Map<String, dynamic> _getUserPreferences() {
    // 실제 앱에서는 SharedPreferences 또는 설정에서 가져옴
    return {
      'preferredMixer': '스파이럴 믹서',
      'defaultTemperature': 25.0,
      'language': 'ko',
      'expertMode': false,
    };
  }

  static double _calculateSystemHealth(Map<String, dynamic> metrics) {
    // 시스템 건강도 계산 (0-100)
    // 실제로는 더 복잡한 로직이 필요
    return 85.0; // 예시값
  }

  static Map<String, int> _calculateLogLevelDistribution() {
    final distribution = <String, int>{};
    for (final log in _logBuffer) {
      final level = log['level'] as String;
      distribution[level] = (distribution[level] ?? 0) + 1;
    }
    return distribution;
  }

  static Map<String, int> _calculateCategoryUsage() {
    final usage = <String, int>{};
    for (final log in _logBuffer) {
      final category = log['category'] as String;
      usage[category] = (usage[category] ?? 0) + 1;
    }
    return usage;
  }

  static Map<String, dynamic> _calculateAveragePerformance() {
    final performanceLogs =
        _logBuffer.where((log) => log['category'] == 'calculation_performance');
    if (performanceLogs.isEmpty) return {};

    double totalDuration = 0;
    double totalAccuracy = 0;

    for (final log in performanceLogs) {
      totalDuration += (log['data']['durationMs'] as num).toDouble();
      totalAccuracy += (log['data']['accuracy'] as num).toDouble();
    }

    return {
      'averageDuration': totalDuration / performanceLogs.length,
      'averageAccuracy': totalAccuracy / performanceLogs.length,
      'sampleSize': performanceLogs.length,
    };
  }

  static Map<String, dynamic> _analyzeUserBehavior() {
    final behaviorLogs =
        _logBuffer.where((log) => log['category'] == 'user_behavior');
    if (behaviorLogs.isEmpty) return {};

    final actionCounts = <String, int>{};
    final featureUsage = <String, int>{};

    for (final log in behaviorLogs) {
      final action = log['data']['action'] as String;
      final feature = log['data']['feature'] as String;

      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
    }

    return {
      'mostCommonAction':
          actionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      'mostUsedFeature':
          featureUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      'totalActions': behaviorLogs.length,
    };
  }

  static Map<String, dynamic> _analyzeSystemHealth() {
    final statusLogs =
        _logBuffer.where((log) => log['category'] == 'system_status');
    if (statusLogs.isEmpty) return {};

    int errorCount = 0;
    double totalHealth = 0;

    for (final log in statusLogs) {
      if (log['level'] == 'ERROR') errorCount++;
      totalHealth += (log['data']['systemHealth'] as num).toDouble();
    }

    return {
      'errorCount': errorCount,
      'averageHealth': totalHealth / statusLogs.length,
      'totalStatusUpdates': statusLogs.length,
    };
  }

  static void _printLog(Map<String, dynamic> logEntry) {
    final timestamp = logEntry['timestamp'];
    final level = logEntry['level'];
    final category = logEntry['category'];
    final message = logEntry['message'];

    print('[$timestamp] $level [$category] $message');

    // 데이터가 있으면 추가 출력
    final data = logEntry['data'] as Map<String, dynamic>;
    if (data.isNotEmpty) {
      print('  Data: ${jsonEncode(data)}');
    }
  }
}

class BreadModule extends BakingModule {
  /// 도법 판정 시스템 - 스트레이트, 르방, 사워도우 자동 판정
  BreadMethod determineBakingMethod(Recipe recipe) {
    return DoughMethodClassifier.determineDoughMethod(recipe);
  }

  /// 최종 반죽 온도 계산 (중앙화된 계산기 사용)
  double calculateFinalDoughTemperature(
      Recipe recipe, EnvironmentalConditions conditions) {
    // 밀가루 포함 여부 검증
    final hasFlour = recipe.ingredients.any((ingredient) => ingredient.isFlour);
    if (!hasFlour) {
      BakingLogger.log(
        level: LogLevel.ERROR,
        category: 'dough_temperature_calculation',
        message: '밀가루가 포함되지 않은 레시피입니다',
        data: {
          'recipe_title': recipe.title,
          'ingredients': recipe.ingredients.map((i) => i.name).toList(),
        },
      );
      throw ArgumentError('밀가루가 포함되지 않은 레시피입니다');
    }

    // 중앙화된 반죽 온도 계산기 사용 (레거시 변환)
    final totalMass = _calculateTotalDoughMass(recipe);
    final params = DoughTemperatureParameters(
      baseTemperature: 20.0, // 재료 기본 온도 (실제 앱에서는 센서 데이터 사용)
      mixingSteps: _convertLegacyMixingSteps(recipe), // 레거시 변환
      mixerType: 'home', // 기본값 (실제 앱에서는 사용자 설정 사용)
      environmentTemperature: conditions.temperature,
      environmentHumidity: conditions.humidity,
      totalMass: totalMass,
      frictionHeatAdjustment: 1.0,
    );

    final result =
        DoughTemperatureCalculator().calculateDoughTemperature(params);
    return result.finalTemperature.clamp(15.0, 35.0); // 범위 제한 유지
  }

  /// 레거시 믹싱 단계들을 새로운 MixingStep 객체로 변환
  List<MixingStep> _convertLegacyMixingSteps(Recipe recipe) {
    final mixingSteps = <MixingStep>[];

    if (recipe.mixingSteps != null && recipe.mixingSteps!.isNotEmpty) {
      for (int i = 0; i < recipe.mixingSteps!.length; i++) {
        final step = recipe.mixingSteps![i];
        mixingSteps.add(MixingStep(
          stepOrder: i + 1,
          speed: step['speed'] as String? ?? '중속',
          duration: (step['time'] as num?)?.toDouble() ?? 10.0,
          currentDoughTemp: 25.0, // 기본 온도
        ));
      }
    } else {
      // 기본 믹싱 단계가 없는 경우 생성 (기존 로직 호환을 위해)
      mixingSteps.add(const MixingStep(
        stepOrder: 1,
        speed: '중속',
        duration: 10.0,
        currentDoughTemp: 25.0,
      ));
    }

    return mixingSteps;
  }

  /// 믹싱 가이드 생성 (고도화된 버전)
  String generateMixingGuide(
      Recipe recipe, EnvironmentalConditions conditions) {
    final flourAmount = _getFlourAmount(recipe);
    final hydration = _calculateHydration(recipe);
    final method = determineBakingMethod(recipe);

    StringBuffer guide = StringBuffer();

    guide.writeln("🍞 **빵 믹싱 가이드**");
    guide.writeln("**도법:** ${method.description}");
    guide.writeln("**밀가루 양:** ${flourAmount.toStringAsFixed(0)}g");
    guide.writeln("**하이드레이션:** ${hydration.toStringAsFixed(1)}%");
    guide.writeln();

    // 도법별 믹싱 가이드
    switch (method.name) {
      case 'straight':
        guide.writeln("**스트레이트 제법 믹싱 순서:**");
        guide.writeln("1. 밀가루와 물을 먼저 섞어 슈aggy 덩어리 만들기 (2-3분)");
        guide.writeln("2. 소금과 이스트를 추가하여 균등하게 섞기");
        guide.writeln("3. 중력 반죽: 8-12분 (저단백) / 12-15분 (고단백)");
        guide.writeln("4. 반죽이 매끄럽고 탄력있을 때까지 반죽");
        guide.writeln("5. 창문 테스트: 얇게 펴서 창문 모양이 보일 때까지");
        break;

      case 'levain':
        guide.writeln("**르방 제법 믹싱 순서:**");
        guide.writeln("1. 밀가루와 물을 먼저 섞어 슈aggy 덩어리 만들기");
        guide.writeln("2. 르방 스타터를 추가하여 골고루 섞기");
        guide.writeln("3. 소금 추가 후 15-20분 반죽");
        guide.writeln("4. 중간 휴지 (bench rest) 20-30분");
        guide.writeln("5. 최종 반죽 10-15분");
        break;

      case 'sourdough':
        guide.writeln("**사워도우 제법 믹싱 순서:**");
        guide.writeln("1. 사워도우 스타터 활성도 확인 (2배로 부풀었는지)");
        guide.writeln("2. 밀가루와 물 먼저 섞기");
        guide.writeln("3. 스타터와 소금 순서대로 추가");
        guide.writeln("4. 장시간 저속 믹싱 (15-25분)");
        guide.writeln("5. 반죽이 완전히 발달할 때까지");
        break;
    }

    // 환경 조건 고려 (고도화된 조언)
    _addEnvironmentalAdvice(guide, conditions);

    return guide.toString();
  }

  /// 발효 가이드 생성 (고도화된 버전)
  String generateFermentationGuide(Recipe recipe, BreadMethod method) {
    final ratios =
        BakingScienceFormulaEngine.optimizeMaterialRatio(recipe.ingredients);
    final conditions = EnvironmentalConditions(
      temperature: 25.0,
      humidity: 65.0,
      pressure: 1013.25,
      season: Season.spring,
      oven: OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 0.9,
        calibrationIndex: 1.0,
        steamCapability: 0.5,
        hasConvection: false,
        maxTemperature: 250.0,
      ),
    );

    final environmentCorrection =
        BakingScienceFormulaEngine.calculateEnvironmentCorrection(conditions);

    StringBuffer guide = StringBuffer();

    guide.writeln("🧫 **빵 발효 가이드**");
    guide.writeln("**도법:** ${method.description}");
    guide.writeln("**이스트 비율:** ${ratios.yeastPercentage.toStringAsFixed(2)}%");
    guide.writeln(
        "**환경 보정:** ${environmentCorrection.overallCorrection.toStringAsFixed(2)}x");
    guide.writeln();

    // 도법별 발효 가이드
    switch (method.name) {
      case 'straight':
        _generateStraightFermentationGuide(
            guide, ratios, environmentCorrection);
        break;
      case 'levain':
        _generateLevainFermentationGuide(guide, ratios, environmentCorrection);
        break;
      case 'sourdough':
        _generateSourdoughFermentationGuide(
            guide, ratios, environmentCorrection);
        break;
    }

    // 품질 모니터링 가이드
    guide.writeln();
    guide.writeln("📊 **발효 품질 모니터링:**");
    guide.writeln("• 부피 증가: 1.5-2배 (약 50-100% 증가)");
    guide.writeln("• 표면: 약간 윤기 있고 팽팽함");
    guide.writeln("• 냄새: 상큼하고 과일향");
    guide.writeln("• 터치: 탄력이 있고 손가락 자국 복원");

    return guide.toString();
  }

  /// 굽기 가이드 생성 (고도화된 버전)
  String generateBakingGuide(String breadType, DoughPhysicalState state) {
    StringBuffer guide = StringBuffer();

    guide.writeln("🔥 **빵 굽기 가이드**");
    guide.writeln("**빵 종류:** $breadType");
    guide
        .writeln("**글루텐 강도:** ${state.glutenStrengthIndex.toStringAsFixed(1)}");
    guide.writeln();

    // 오븐 준비
    guide.writeln("**1. 오븐 준비:**");
    guide.writeln("• 예열 온도: 250°C (최대)");
    guide.writeln("• 예열 시간: 45-60분 (피자 스톤 사용 시)");
    guide.writeln("• 스팀 준비: 뜨거운 물 준비");
    guide.writeln();

    // 굽기 단계별 가이드
    guide.writeln("**2. 굽기 단계:**");

    // Phase 1: 고온 스팀
    guide.writeln("**Phase 1 (0-15분): 고온 스팀**");
    guide.writeln("• 온도: 250°C 유지");
    guide.writeln("• 스팀: 15분간 주입");
    guide.writeln("• 목적: 오븐 스프링 유도, 크러스트 형성");
    guide.writeln("• 관찰: 반죽이 1.5배로 팽창");
    guide.writeln();

    // Phase 2: 온도 하강
    guide.writeln("**Phase 2 (15-35분): 온도 하강**");
    guide.writeln("• 온도: 220°C로 하강");
    guide.writeln("• 스팀: 제거");
    guide.writeln("• 목적: 내부 익힘, 크러스트 색상 형성");
    guide.writeln("• 관찰: 황금색 크러스트 형성");
    guide.writeln();

    // Phase 3: 최종 익힘
    if (breadType == 'sourdough' || breadType == 'whole_wheat') {
      guide.writeln("**Phase 3 (35-50분): 최종 익힘**");
      guide.writeln("• 온도: 200°C");
      guide.writeln("• 목적: 수분 균형, 내부 완전 익힘");
      guide.writeln("• 관찰: 속이 95°C 이상");
    }

    guide.writeln();
    guide.writeln("🎯 **완성 기준:**");
    guide.writeln("• 내부 온도: 95-98°C");
    guide.writeln("• 크러스트 색상: 황금색 ~ 적갈색");
    guide.writeln("• 소리: 두드렸을 때 공허한 소리");
    guide.writeln("• 무게: 20-30% 감량");

    // 글루텐 강도에 따른 조정
    if (state.glutenStrengthIndex > 15) {
      guide.writeln();
      guide.writeln("💪 **고글루텐 빵 특수 조정:**");
      guide.writeln("• 스팀 시간 2-3분 연장");
      guide.writeln("• 온도 하강 타이밍 2분 지연");
    } else if (state.glutenStrengthIndex < 10) {
      guide.writeln();
      guide.writeln("⚠️ **저글루텐 빵 특수 조정:**");
      guide.writeln("• 스팀 시간 2분 단축");
      guide.writeln("• 오븐 스프링 방지 위해 온도 낮게 시작");
    }

    return guide.toString();
  }

  /// 발효 시간 예측 (향상된 버전)
  Duration predictFermentationTime(
      Recipe recipe, BreadMethod method, EnvironmentalConditions conditions) {
    final ratios =
        BakingScienceFormulaEngine.optimizeMaterialRatio(recipe.ingredients);
    final environmentCorrection =
        BakingScienceFormulaEngine.calculateEnvironmentCorrection(conditions);

    // 빵 종류별 기본 발효 시간 (분)
    double baseTime;
    switch (method.name) {
      case 'sourdough':
        baseTime = 720; // 12시간
        break;
      case 'levain':
        baseTime = 480; // 8시간
        break;
      default:
        baseTime = 240; // 4시간
    }

    // 이스트 양에 따른 조정
    final yeastFactor = ratios.yeastPercentage > 0
        ? math.pow(2.0, (1.0 - ratios.yeastPercentage / 2.0)).toDouble()
        : 1.0;

    // 환경 보정 적용
    final adjustedTime = baseTime *
        yeastFactor /
        environmentCorrection.fermentationSpeedCorrection;

    return Duration(minutes: adjustedTime.round());
  }

  // ========== 헬퍼 메서드들 ==========

  double _getFlourAmount(Recipe recipe) {
    return recipe.ingredients
        .where((ingredient) => ingredient.isFlour)
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  double _calculateHydration(Recipe recipe) {
    final flourAmount = _getFlourAmount(recipe);
    if (flourAmount == 0) return 0;

    final waterAmount = recipe.ingredients
        .where((ingredient) => ingredient.isWater)
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);

    return (waterAmount / flourAmount) * 100;
  }

  void _generateStraightFermentationGuide(StringBuffer guide,
      MaterialRatioResult ratios, EnvironmentCorrection environmentCorrection) {
    guide.writeln("**스트레이트 제법 발효:**");
    guide.writeln();

    // 벌크 발효
    final bulkTime = 120.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**1차 발효 (벌크 발효):**");
    guide.writeln("• 시간: ${bulkTime.toStringAsFixed(0)}분");
    guide.writeln("• 온도: 24-26°C");
    guide.writeln("• 습도: 70-80%");
    guide.writeln("• 관리: 30분마다 1회 접기 (stretch & fold)");
    guide.writeln("• 목표: 1.5-2배 부피 증가");
    guide.writeln();

    // 최종 발효
    final finalTime = 60.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**2차 발효 (최종 발효):**");
    guide.writeln("• 시간: ${finalTime.toStringAsFixed(0)}분");
    guide.writeln("• 온도: 26-28°C");
    guide.writeln("• 형태: 원하는 형태로 성형");
    guide.writeln("• 관리: 덮개로 습도 유지");
    guide.writeln("• 목표: 1.2-1.5배 부피 증가");
    guide.writeln();

    guide.writeln("**총 발효 시간: ${(bulkTime + finalTime).toStringAsFixed(0)}분**");
  }

  void _generateLevainFermentationGuide(StringBuffer guide,
      MaterialRatioResult ratios, EnvironmentCorrection environmentCorrection) {
    guide.writeln("**르방 제법 발효:**");
    guide.writeln();

    // 스타터 준비
    guide.writeln("**스타터 준비:**");
    guide.writeln("• 스타터 온도: 24°C");
    guide.writeln("• 피드 시간: 4-6시간 전");
    guide.writeln("• 목표: 2배 부피 증가");
    guide.writeln();

    // 본 반죽 발효
    final bulkTime = 180.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**본 반죽 발효:**");
    guide.writeln("• 시간: ${bulkTime.toStringAsFixed(0)}분");
    guide.writeln("• 스타터 사용: 20-30%");
    guide.writeln("• 온도: 24°C");
    guide.writeln("• 관리: 45분마다 접기");
    guide.writeln();

    final finalTime = 90.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**최종 발효:**");
    guide.writeln("• 시간: ${finalTime.toStringAsFixed(0)}분");
    guide.writeln("• 온도: 26°C");
    guide.writeln("• 습도: 80%");
    guide.writeln();

    guide.writeln("**총 발효 시간: ${(bulkTime + finalTime).toStringAsFixed(0)}분**");
  }

  void _generateSourdoughFermentationGuide(StringBuffer guide,
      MaterialRatioResult ratios, EnvironmentCorrection environmentCorrection) {
    guide.writeln("**사워도우 제법 발효:**");
    guide.writeln();

    // 스타터 활성화
    guide.writeln("**스타터 활성화:**");
    guide.writeln("• 스타터 온도: 24°C");
    guide.writeln("• 피드 시간: 6-12시간 전");
    guide.writeln("• 목표: 매우 활발한 거품");
    guide.writeln();

    // 벌크 발효 (장시간)
    final bulkTime = 480.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**벌크 발효 (장시간):**");
    guide.writeln("• 시간: ${bulkTime.toStringAsFixed(0)}분");
    guide.writeln("• 스타터 사용: 15-25%");
    guide.writeln("• 온도: 22-24°C");
    guide.writeln("• 관리: 1-2시간마다 접기");
    guide.writeln();

    final finalTime = 120.0 / environmentCorrection.fermentationSpeedCorrection;
    guide.writeln("**최종 발효:**");
    guide.writeln("• 시간: ${finalTime.toStringAsFixed(0)}분");
    guide.writeln("• 온도: 26°C");
    guide.writeln("• 습도: 85%");
    guide.writeln();

    guide.writeln("**총 발효 시간: ${(bulkTime + finalTime).toStringAsFixed(0)}분**");
    guide.writeln("⚠️ **주의:** 사워도우는 온도와 스타터 상태에 따라 시간 편차가 큽니다.");
  }

  /// Phase 1-2: 반죽 질량 영향 계산
  /// 질량이 많을수록 온도 상승 완화 (열용량 원리)
  double _calculateMassFactor(Recipe recipe) {
    const double standardMass = 1000.0; // 기준 질량 (1kg)
    final actualMass = _calculateTotalDoughMass(recipe);

    if (actualMass <= 0) return 1.0;

    // 질량 비율 계산
    final massRatio = actualMass / standardMass;

    // 질량 보정 계수 (mixing_process.md 기반)
    // 질량이 클수록 온도 상승이 완화됨
    double massFactor;
    if (massRatio <= 1.0) {
      // 1kg 이하: 보정 없음
      massFactor = 1.0;
    } else if (massRatio <= 2.0) {
      // 1-2kg: 약간 완화
      massFactor = 1.0 - ((massRatio - 1.0) * 0.1);
    } else {
      // 2kg 이상: 크게 완화
      massFactor = 0.9 - ((massRatio - 2.0) * 0.05);
    }

    return massFactor.clamp(0.5, 1.0); // 0.5 ~ 1.0 범위 제한
  }

  /// Phase 2-3: 실시간 질량 측정 기능 (개선된 버전)
  /// 재료별 특성을 고려한 더 정확한 질량 계산
  double _calculateTotalDoughMass(Recipe recipe) {
    double totalMass = 0.0;

    for (final ingredient in recipe.ingredients) {
      // Phase 2-3: 재료별 밀도 보정 적용
      final densityFactor = _getIngredientDensityFactor(ingredient.name);
      final actualMass = ingredient.amount * densityFactor;

      totalMass += actualMass;

      // 디버그용 로깅
      print(
          '재료: ${ingredient.name}, 원래 무게: ${ingredient.amount.toStringAsFixed(1)}g');
      print('밀도 보정 계수: ${densityFactor.toStringAsFixed(3)}');
      print('보정된 무게: ${actualMass.toStringAsFixed(1)}g');
    }

    // 총 반죽 질량에 대한 추가 보정
    final finalMass = _applyDoughMassCorrections(totalMass);

    print(
        '총 반죽 질량: ${totalMass.toStringAsFixed(1)}g → 최종: ${finalMass.toStringAsFixed(1)}g');
    return finalMass;
  }

  /// 재료별 밀도 보정 계수 (실제 밀도를 반영)
  double _getIngredientDensityFactor(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    // 밀가루 및 곡물류 (벌크 밀도 적용)
    if (lowerName.contains('밀가루') || lowerName.contains('flour')) {
      return 1.0; // 기준
    } else if (lowerName.contains('강력분') || lowerName.contains('bread flour')) {
      return 0.95; // 약간 더 무겁게 측정
    } else if (lowerName.contains('박력분') || lowerName.contains('cake flour')) {
      return 1.05; // 약간 더 가볍게 측정
    }

    // 액체류 (실제 밀도 적용)
    else if (lowerName.contains('물') || lowerName.contains('water')) {
      return 1.0; // 물의 밀도
    } else if (lowerName.contains('우유') || lowerName.contains('milk')) {
      return 1.03; // 우유의 밀도
    }

    // 유지류 (실제 밀도 적용)
    else if (lowerName.contains('버터') || lowerName.contains('butter')) {
      return 0.91; // 버터의 밀도
    } else if (lowerName.contains('기름') || lowerName.contains('oil')) {
      return 0.92; // 기름의 밀도
    }

    // 설탕류
    else if (lowerName.contains('설탕') || lowerName.contains('sugar')) {
      return 0.85; // 설탕의 벌크 밀도
    }

    // 이스트 및 소금
    else if (lowerName.contains('이스트') || lowerName.contains('yeast')) {
      return 1.2; // 이스트의 밀도 (습도 고려)
    } else if (lowerName.contains('소금') || lowerName.contains('salt')) {
      return 1.1; // 소금의 밀도
    }

    return 1.0; // 알 수 없는 재료는 기준값
  }

  /// 반죽 질량에 대한 추가 보정 적용
  double _applyDoughMassCorrections(double rawMass) {
    double correctedMass = rawMass;

    // 1. 측정 오차 보정 (±5% 오차 범위 내)
    if (rawMass < 500) {
      correctedMass *= 1.02; // 소량은 과소 측정되는 경향
    } else if (rawMass > 2000) {
      correctedMass *= 0.98; // 대량은 과다 측정되는 경향
    }

    // 2. 계량 방식 보정 (실제 제빙 현장 고려)
    // 실제로 계량컵이나 저울의 정밀도 차이 반영
    if (correctedMass < 1000) {
      correctedMass *= 1.01; // 소량은 저울이 더 정확
    } else {
      correctedMass *= 0.995; // 대량은 계량컵 사용시 약간 과다
    }

    return correctedMass.clamp(10.0, 10000.0); // 10g ~ 10kg 범위 제한
  }

  /// 실시간 질량 모니터링 기능
  Map<String, dynamic> getMassMonitoringData(Recipe recipe) {
    final totalMass = _calculateTotalDoughMass(recipe);
    final flourMass = _getFlourAmount(recipe);
    final hydrationRatio = _calculateHydration(recipe);

    // 재료별 질량 분석
    final ingredientAnalysis = <Map<String, dynamic>>[];
    for (final ingredient in recipe.ingredients) {
      final densityFactor = _getIngredientDensityFactor(ingredient.name);
      final actualMass = ingredient.amount * densityFactor;
      final percentage = totalMass > 0 ? (actualMass / totalMass) * 100 : 0.0;

      ingredientAnalysis.add({
        'name': ingredient.name,
        'originalAmount': ingredient.amount,
        'densityFactor': densityFactor,
        'actualMass': actualMass,
        'percentage': percentage,
      });
    }

    return {
      'totalMass': totalMass,
      'flourMass': flourMass,
      'hydrationRatio': hydrationRatio,
      'ingredientAnalysis': ingredientAnalysis,
      'massAccuracy': _estimateMassAccuracy(totalMass),
      'recommendations':
          _getMassBasedRecommendations(totalMass, hydrationRatio),
    };
  }

  /// 질량 측정 정확도 추정
  String _estimateMassAccuracy(double totalMass) {
    if (totalMass < 100) {
      return '높음 (±2g)';
    } else if (totalMass < 500) {
      return '보통 (±5g)';
    } else if (totalMass < 2000) {
      return '보통 (±10g)';
    } else {
      return '낮음 (±20g)';
    }
  }

  /// 질량 기반 추천사항
  List<String> _getMassBasedRecommendations(
      double totalMass, double hydration) {
    final recommendations = <String>[];

    if (totalMass < 500) {
      recommendations.add('소량 반죽: 디지털 저울 사용 권장');
      recommendations.add('믹서 속도 1-2단계로 시작');
    } else if (totalMass > 2000) {
      recommendations.add('대량 반죽: 스파이럴 믹서 사용 권장');
      recommendations.add('분할 믹싱 고려 (2-3회에 걸쳐)');
    }

    if (hydration > 75) {
      recommendations.add('고하이드레이션 반죽: 믹싱 시간 연장 필요');
    } else if (hydration < 60) {
      recommendations.add('저하이드레이션 반죽: 강력분 사용시 믹싱 시간 단축');
    }

    return recommendations;
  }

  /// Phase 2-2: 사용자 믹서 설정 기능 (확장 버전)
  /// mixing_process.md + 가정용/버티컬 믹서 추가
  double _getMixerEfficiencyFactor([String? userSelectedMixer]) {
    // Phase 2-2: 사용자 믹서 설정 기능
    // 실제 앱에서는 사용자 설정에서 선택된 믹서 타입을 받아옴
    final mixerType = userSelectedMixer ?? '스파이럴 믹서'; // 기본값

    // 확장된 믹서별 효율 계수 (mixing_process.md + 추가 타입)
    switch (mixerType) {
      case '스파이럴 믹서':
      case 'spiral':
        return 0.9; // 가장 일반적, 표준 효율

      case '행성 믹서':
      case 'planetary':
        return 1.0; // 기준 효율

      case '리본 믹서':
      case 'ribbon':
        return 1.2; // 높은 효율

      case '패들 믹서':
      case 'paddle':
        return 1.2; // 높은 효율

      case '홈 믹서':
      case 'hand':
        return 0.8; // 수동, 낮은 효율

      // Phase 3-2: 확장된 믹서 타입들
      case '가정용 믹서':
      case 'stand':
      case 'stand_mixer':
        return 0.95; // 가정용 스탠드 믹서 (KitchenAid 등)

      case '버티컬 믹서':
      case 'vertical':
      case 'vertical_mixer':
        return 1.1; // 버티컬 믹서 (Ankarsrum 등)

      case '프로페셔널 믹서':
      case 'professional':
      case 'pro':
        return 1.3; // 전문가용 고효율 믹서

      case '중국식 믹서':
      case 'chinese':
      case 'asian':
        return 0.85; // 아시안 타입 믹서 (중국/일본/한국)

      case '이탈리안 믹서':
      case 'italian':
      case 'european':
        return 0.92; // 유럽 스타일 믹서

      case '듀얼 스테이지':
      case 'dual_stage':
      case 'two_speed':
        return 1.15; // 2단계 속도 조절 믹서

      case '컴팩트 믹서':
      case 'compact':
      case 'mini':
        return 0.82; // 소형 가정용 믹서

      case '헤비 듀티':
      case 'heavy_duty':
      case 'industrial':
        return 1.25; // 초대형 산업용 믹서

      default:
        return 0.9; // 알 수 없는 타입은 기본값
    }
  }

  /// 믹서 타입별 권장 사용법 안내 (Phase 3 확장)
  String getMixerUsageGuide(String mixerType) {
    switch (mixerType) {
      case '스파이럴 믹서':
      case 'spiral':
        return '스파이럴 믹서: 빵 반죽에 최적화된 믹서입니다. 저속부터 고속까지 부드러운 전환이 가능합니다.';

      case '행성 믹서':
      case 'planetary':
        return '행성 믹서: 다용도 믹서로 케이크부터 빵까지 모두 사용 가능합니다.';

      case '리본 믹서':
      case 'ribbon':
        return '리본 믹서: 대량 생산용 믹서로 효율이 높지만 가정용에서는 덜 일반적입니다.';

      case '패들 믹서':
      case 'paddle':
        return '패들 믹서: 무거운 반죽용 믹서로 특히 고단백 반죽에 효과적입니다.';

      case '홈 믹서':
      case 'hand':
        return '홈 믹서: 소량 반죽용으로 적합합니다. 장시간 사용 시 과열에 주의하세요.';

      // Phase 3: 새로 추가된 믹서 타입들
      case '가정용 믹서':
      case 'stand':
      case 'stand_mixer':
        return '가정용 스탠드 믹서: KitchenAid, Bosch 등 가정용 믹서에 최적화되어 있습니다. 3-5kg 반죽에 적합하며, 다양한 부속품 사용이 가능합니다.';

      case '버티컬 믹서':
      case 'vertical':
      case 'vertical_mixer':
        return '버티컬 믹서: Ankarsrum, Electrolux 등 버티컬 타입 믹서에 특화되어 있습니다. 반죽의 산소 혼입이 적어 글루텐 발달이 우수합니다.';

      case '프로페셔널 믹서':
      case 'professional':
      case 'pro':
        return '프로페셔널 믹서: 전문 베이커용 고성능 믹서입니다. 5-15kg 대량 반죽에 최적화되어 있으며, 정밀한 속도 조절이 가능합니다.';

      case '중국식 믹서':
      case 'chinese':
      case 'asian':
        return '중국식 믹서: 아시안 스타일 믹서에 특화되어 있습니다. 찐빵, 만두피 등 아시안 제빙에 최적화된 반죽 특성을 고려합니다.';

      case '이탈리안 믹서':
      case 'italian':
      case 'european':
        return '이탈리안 믹서: 유럽 스타일 믹서에 맞춰져 있습니다. 피자 도우, 파스타 등 유럽식 반죽의 텍스처를 고려합니다.';

      case '듀얼 스테이지':
      case 'dual_stage':
      case 'two_speed':
        return '듀얼 스테이지 믹서: 2단계 속도 조절 믹서입니다. 반죽 단계별 최적 속도 설정이 가능하여 글루텐 발달을 세밀하게 제어합니다.';

      case '컴팩트 믹서':
      case 'compact':
      case 'mini':
        return '컴팩트 믹서: 소형 믹서에 최적화되어 있습니다. 1kg 이하 소량 반죽에 적합하며, 소형 용기에 맞는 저속 중심 믹싱을 권장합니다.';

      case '헤비 듀티':
      case 'heavy_duty':
      case 'industrial':
        return '헤비 듀티 믹서: 산업용 대형 믹서입니다. 20kg 이상 초대량 반죽에 사용되며, 내구성과 효율성이 극대화되어 있습니다.';

      default:
        return '믹서 타입을 선택하면 최적화된 믹싱 가이드를 받을 수 있습니다. 일반적인 믹서 기준으로 계산됩니다.';
    }
  }

  /// 🔥 더운 환경 반죽온도 조절 조언 (고도화된 버전)
  /// EnvironmentalConditions의 새로운 메서드를 활용한 상세 조언
  void _addEnvironmentalAdvice(
      StringBuffer guide, EnvironmentalConditions conditions) {
    // EnvironmentalConditions의 새로운 메서드를 활용
    final safeHeatTips = conditions.safeHeatManagementTips;
    final riskyHeatTips = conditions.riskyHeatManagementTips;
    final safeColdTips = conditions.safeColdManagementTips;
    final riskyColdTips = conditions.riskyColdManagementTips;

    if (conditions.temperature > 30) {
      // 매우 더운 환경 (30°C 이상)
      guide.writeln();
      guide.writeln("🔥 **더운 환경 반죽온도 조절 가이드 (30°C 이상)**");
      guide.writeln();

      // 안전한 조언들 먼저 표시
      if (safeHeatTips.isNotEmpty) {
        guide.writeln("✅ **권장 조치사항:**");
        for (final tip in safeHeatTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      // 리스크가 있는 조언들은 별도로 표시
      if (riskyHeatTips.isNotEmpty) {
        guide.writeln("⚠️ **전문가 상담 필요 사항 (정확한 계산 어려움):**");
        for (final tip in riskyHeatTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      guide.writeln("💡 **추가 권장사항:**");
      guide.writeln("• 믹싱 전 모든 재료를 냉장고에서 30분 이상 차갑게 보관");
      guide.writeln("• 얼음물 50g 추가로 반죽온도 2-3°C 낮추기 가능");
      guide.writeln("• 반죽 작업을 서늘한 시간대(새벽/저녁)로 변경 고려");
      guide.writeln("• 대형 반죽은 2-3회에 나누어 믹싱");
    } else if (conditions.temperature > 25) {
      // 다소 더운 환경 (25-30°C)
      guide.writeln();
      guide.writeln("🌡️ **다소 더운 환경 반죽온도 조절 가이드 (25-30°C)**");
      guide.writeln();

      if (safeHeatTips.isNotEmpty) {
        guide.writeln("✅ **권장 조치사항:**");
        for (final tip in safeHeatTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      if (riskyHeatTips.isNotEmpty) {
        guide.writeln("⚠️ **리스크 관리 (전문가 상담 권장):**");
        for (final tip in riskyHeatTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      guide.writeln("💡 **추가 권장사항:**");
      guide.writeln("• 실온 재료 대신 냉장 재료 사용");
      guide.writeln("• 믹싱 시간 10-15% 단축");
      guide.writeln("• 작업 공간에 선풍기 사용으로 2-3°C 낮추기");
    } else if (conditions.temperature < 15) {
      // 매우 추운 환경 (15°C 미만)
      guide.writeln();
      guide.writeln("❄️ **추운 환경 반죽온도 조절 가이드 (15°C 미만)**");
      guide.writeln();

      if (safeColdTips.isNotEmpty) {
        guide.writeln("✅ **권장 조치사항:**");
        for (final tip in safeColdTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      if (riskyColdTips.isNotEmpty) {
        guide.writeln("⚠️ **전문가 상담 필요 사항 (정확한 계산 어려움):**");
        for (final tip in riskyColdTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      guide.writeln("💡 **추가 권장사항:**");
      guide.writeln("• 발효 전 반죽을 25-28°C까지 따뜻하게 데우기");
      guide.writeln("• 발효기는 26°C로 설정 (온도 모니터링 필수)");
      guide.writeln("• 겨울용 레시피 사용 고려 (이스트량 증가)");
      guide.writeln("• 발효 시간을 50-100% 연장할 준비");
    } else if (conditions.temperature < 20) {
      // 다소 추운 환경 (15-20°C)
      guide.writeln();
      guide.writeln("❄️ **다소 추운 환경 반죽온도 조절 가이드 (15-20°C)**");
      guide.writeln();

      if (safeColdTips.isNotEmpty) {
        guide.writeln("✅ **권장 조치사항:**");
        for (final tip in safeColdTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      if (riskyColdTips.isNotEmpty) {
        guide.writeln("⚠️ **리스크 관리 (전문가 상담 권장):**");
        for (final tip in riskyColdTips) {
          guide.writeln("• $tip");
        }
        guide.writeln();
      }

      guide.writeln("💡 **추가 권장사항:**");
      guide.writeln("• 따뜻한 장소에서 발효 진행");
      guide.writeln("• 믹싱 시간 10-15% 연장");
      guide.writeln("• 발효 중간에 1-2회 접기");
    }

    // 일반적인 환경에서도 기온 표시
    guide.writeln();
    guide.writeln("🌡️ **현재 환경 정보:**");
    guide.writeln("• 기온: ${conditions.temperature.toStringAsFixed(1)}°C");
    guide.writeln("• 습도: ${conditions.humidity.toStringAsFixed(1)}%");
    guide.writeln("• 계절: ${conditions.season.displayName}");

    // 환경이 쾌적한 경우
    if (conditions.temperature >= 20 && conditions.temperature <= 25) {
      guide.writeln("✅ 현재 환경이 빵 만들기에 최적적입니다!");
    }
  }
}

class CakeModule extends BakingModule {
  // 공정 모델 선택 로직 (크리밍법, 공립법 등)
  String determineProcessModel(Recipe recipe) {
    // TODO: Implement logic to determine process model based on recipe ingredients and methods
    // Placeholder for now
    if (recipe.ingredients
        .any((i) => i.name.toLowerCase().contains('butter') && i.amount > 0)) {
      return '크리밍법'; // Creaming method
    }
    return '공립법'; // All-in-one method
  }

  // 내부 촉감 지수 계산 공식
  // 내부 촉감 지수 = (최종 내부 온도) × (하이드레이션) × (글루텐 탄성 지수) - (총 수분 손실%)
  double calculateInternalTextureIndex({
    required double finalInternalTemperature,
    required double hydrationPercentage,
    required double glutenElasticityIndex,
    required double totalMoistureLossPercentage,
  }) {
    return (finalInternalTemperature *
            hydrationPercentage *
            glutenElasticityIndex) -
        totalMoistureLossPercentage;
  }

  // 케이크 텍스처 예측 시스템
  String predictCakeTexture({
    required double internalTextureIndex,
    required String processModel,
  }) {
    // TODO: Implement logic to predict cake texture based on internalTextureIndex and processModel
    // Placeholder for now
    if (internalTextureIndex > 1000 && processModel == '크리밍법') {
      return '촉촉하고 부드러운 텍스처';
    } else if (internalTextureIndex > 800 && processModel == '공립법') {
      return '가볍고 폭신한 텍스처';
    }
    return '일반적인 텍스처';
  }

  String optimizeCakeBaking(Recipe recipe, OvenCharacteristics oven) {
    return "Cake Baking Guide: Preheat oven to 175C. Bake for 30-35 minutes until golden brown and a skewer comes out clean.";
  }
}

class CookieModule extends BakingModule {
  // 스프레드 예측 지수 = (지방% × 0.8) + (당% × 0.5) - (수분% × 0.3) 공식 구현
  double calculateSpreadPredictionIndex({
    required double fatPercentage,
    required double sugarPercentage,
    required double moisturePercentage,
  }) {
    return (fatPercentage * 0.8) +
        (sugarPercentage * 0.5) -
        (moisturePercentage * 0.3);
  }

  // 쿠키 굽기 최적화 로직 구현
  String optimizeCookieBaking(Recipe recipe, OvenCharacteristics oven) {
    // TODO: Implement logic for cookie baking optimization
    return "Cookie Baking Guide: Bake at 180C for 10-12 minutes until edges are golden brown.";
  }

  // 쿠키 텍스처 및 모양 예측 시스템 구현
  String predictCookieTextureAndShape({
    required double spreadPredictionIndex,
    required String bakingOptimizationResult,
  }) {
    // TODO: Implement logic to predict cookie texture and shape
    if (spreadPredictionIndex > 50) {
      return "얇고 바삭한 쿠키";
    } else if (spreadPredictionIndex < 30) {
      return "두껍고 부드러운 쿠키";
    }
    return "일반적인 쿠키";
  }
}

class DessertModule extends BakingModule {
  // 푸딩 응고 온도 곡선 계산 구현
  // 응고 온도 곡선 = 젤라틴/펙틴 농도 × (온도 - 기준 온도) × pH 보정
  double calculatePuddingCoagulationTemperatureCurve({
    required double gelatinPectinConcentration,
    required double temperature,
    required double referenceTemperature,
    required double pHCorrection,
  }) {
    return gelatinPectinConcentration *
        (temperature - referenceTemperature) *
        pHCorrection;
  }

  // 아이스크림 오버런 계산 구현
  // 오버런 계산 = ((완제품 부피 - 원액 부피) ÷ 원액 부피) × 100
  double calculateIceCreamOverrun({
    required double finishedVolume,
    required double initialVolume,
  }) {
    if (initialVolume == 0) return 0;
    return ((finishedVolume - initialVolume) / initialVolume) * 100;
  }

  // 젤리 젤화 곡선 계산 구현 (요구사항 6.3 - 와가시)
  // 젤화 곡선 = (한천 농도 × 0.8) + (온도 - 85) × 0.2
  double calculateJellyGelationCurve({
    required double agarConcentration,
    required double temperature,
  }) {
    return (agarConcentration * 0.8) + (temperature - 85) * 0.2;
  }

  // 사탕 결정화 제어 계산 구현 (요구사항 3.4 기반 대표 공식)
  // 결정화 지수 = (설탕 농도 * 1.5) - (전화당 비율 * 2.0) - (온도 * 0.5)
  double calculateCandyCrystallizationIndex({
    required double sugarConcentration,
    required double invertingSugarPercentage,
    required double temperature,
  }) {
    return (sugarConcentration * 1.5) -
        (invertingSugarPercentage * 2.0) -
        (temperature * 0.5);
  }
}
