import 'dart:math' as math;
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../services/environment_defaults_calculator.dart';

part 'advanced_sous_chef_models.g.dart';

/// 고도화된 수쉐프 시스템의 통합 레시피 데이터
@JsonSerializable()
class AdvancedRecipeData {
  final Recipe recipe;
  final EnvironmentalConditions environment;
  final List<IngredientMetadata> ingredientMeta;
  final ProcessMetadata processMeta;
  final QualityMetadata qualityMeta;
  final DessertMetadata? dessertMeta;
  final InterfaceMetadata interfaceMeta;

  const AdvancedRecipeData({
    required this.recipe,
    required this.environment,
    required this.ingredientMeta,
    required this.processMeta,
    required this.qualityMeta,
    this.dessertMeta,
    required this.interfaceMeta,
  });

  factory AdvancedRecipeData.fromJson(Map<String, dynamic> json) =>
      _$AdvancedRecipeDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedRecipeDataToJson(this);

  AdvancedRecipeData copyWith({
    Recipe? recipe,
    EnvironmentalConditions? environment,
    List<IngredientMetadata>? ingredientMeta,
    ProcessMetadata? processMeta,
    QualityMetadata? qualityMeta,
    DessertMetadata? dessertMeta,
    InterfaceMetadata? interfaceMeta,
  }) {
    return AdvancedRecipeData(
      recipe: recipe ?? this.recipe,
      environment: environment ?? this.environment,
      ingredientMeta: ingredientMeta ?? this.ingredientMeta,
      processMeta: processMeta ?? this.processMeta,
      qualityMeta: qualityMeta ?? this.qualityMeta,
      dessertMeta: dessertMeta ?? this.dessertMeta,
      interfaceMeta: interfaceMeta ?? this.interfaceMeta,
    );
  }
}

/// 기본 레시피 정보
@HiveType(typeId: 3)
@JsonSerializable()
class Recipe {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final List<Ingredient> ingredients;
  @HiveField(2)
  final List<String> processes;
  @HiveField(3)
  final RecipeCategory category;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;
  @HiveField(7)
  final List<Map<String, dynamic>>? mixingSteps;
  @HiveField(8)
  final List<Map<String, dynamic>>? fermentationSteps;
  @HiveField(9)
  final List<Map<String, dynamic>>? ovenSteps;

  const Recipe({
    required this.title,
    required this.ingredients,
    required this.processes,
    required this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.mixingSteps,
    this.fermentationSteps,
    this.ovenSteps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  Recipe copyWith({
    String? title,
    List<Ingredient>? ingredients,
    List<String>? processes,
    RecipeCategory? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? mixingSteps,
    List<Map<String, dynamic>>? fermentationSteps,
    List<Map<String, dynamic>>? ovenSteps,
  }) {
    return Recipe(
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      processes: processes ?? this.processes,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mixingSteps: mixingSteps ?? this.mixingSteps,
      fermentationSteps: fermentationSteps ?? this.fermentationSteps,
      ovenSteps: ovenSteps ?? this.ovenSteps,
    );
  }

  /// 재료 비율 계산을 위한 밀가루 양 반환
  double get flourAmount {
    final flour = ingredients.firstWhere(
      (ingredient) => ingredient.isFlour,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return flour.amount;
  }

  /// 하이드레이션 계산: (물의 양 ÷ 밀가루 양) × 100
  double get hydrationPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final water = ingredients.firstWhere(
      (ingredient) => ingredient.isWater,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (water.amount / flourAmt) * 100;
  }

  /// 소금 비율 계산: (소금 양 ÷ 밀가루 양) × 100
  double get saltPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final salt = ingredients.firstWhere(
      (ingredient) => ingredient.isSalt,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (salt.amount / flourAmt) * 100;
  }

  /// 이스트 비율 계산: (이스트 양 ÷ 밀가루 양) × 100
  double get yeastPercentage {
    final flourAmt = flourAmount;
    if (flourAmt == 0) return 0;

    final yeast = ingredients.firstWhere(
      (ingredient) => ingredient.isYeast,
      orElse: () => const Ingredient(
        name: '',
        amount: 0,
        unit: 'g',
        properties: {},
      ),
    );
    return (yeast.amount / flourAmt) * 100;
  }
}

/// 재료 정보
@HiveType(typeId: 4)
@JsonSerializable()
class Ingredient {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String unit;
  @HiveField(3)
  final Map<String, dynamic> properties;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.properties,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    Map<String, dynamic>? properties,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      properties: properties ?? this.properties,
    );
  }

  /// 밀가루 여부 판별
  bool get isFlour {
    final lowerName = name.toLowerCase();
    return lowerName.contains('flour') ||
        lowerName.contains('밀가루') ||
        lowerName.contains('강력분') ||
        lowerName.contains('중력분') ||
        lowerName.contains('박력분');
  }

  /// 물 여부 판별
  bool get isWater {
    final lowerName = name.toLowerCase();
    return lowerName.contains('water') ||
        lowerName.contains('물') ||
        lowerName.contains('우유') ||
        lowerName.contains('milk');
  }

  /// 소금 여부 판별
  bool get isSalt {
    final lowerName = name.toLowerCase();
    return lowerName.contains('salt') || lowerName.contains('소금');
  }

  /// 이스트 여부 판별
  bool get isYeast {
    final lowerName = name.toLowerCase();
    return lowerName.contains('yeast') ||
        lowerName.contains('이스트') ||
        lowerName.contains('효모');
  }

  /// 설탕 여부 판별
  bool get isSugar {
    final lowerName = name.toLowerCase();
    return lowerName.contains('sugar') ||
        lowerName.contains('설탕') ||
        lowerName.contains('꿀') ||
        lowerName.contains('honey');
  }

  /// 지방 여부 판별
  bool get isFat {
    final lowerName = name.toLowerCase();
    return lowerName.contains('butter') ||
        lowerName.contains('oil') ||
        lowerName.contains('버터') ||
        lowerName.contains('기름') ||
        lowerName.contains('올리브오일');
  }

  /// 단백질 함량 반환
  double get proteinContent {
    return (properties['protein'] as num?)?.toDouble() ?? 0.0;
  }

  /// 수분 함량 반환
  double get moistureContent {
    return (properties['moisture'] as num?)?.toDouble() ?? 0.0;
  }

  /// 지방 함량 반환
  double get fatContent {
    return (properties['fat'] as num?)?.toDouble() ?? 0.0;
  }
}

/// 레시피 카테고리
@HiveType(typeId: 5)
enum RecipeCategory {
  @HiveField(0)
  @JsonValue('bread')
  bread,
  @HiveField(1)
  @JsonValue('cake')
  cake,
  @HiveField(2)
  @JsonValue('cookie')
  cookie,
  @HiveField(3)
  @JsonValue('dessert')
  dessert,
}

extension RecipeCategoryExtension on RecipeCategory {
  String get displayName {
    switch (this) {
      case RecipeCategory.bread:
        return '빵';
      case RecipeCategory.cake:
        return '케이크';
      case RecipeCategory.cookie:
        return '쿠키';
      case RecipeCategory.dessert:
        return '디저트';
    }
  }

  String get englishName {
    switch (this) {
      case RecipeCategory.bread:
        return 'Bread';
      case RecipeCategory.cake:
        return 'Cake';
      case RecipeCategory.cookie:
        return 'Cookie';
      case RecipeCategory.dessert:
        return 'Dessert';
    }
  }
}

/// 환경 조건 정보
@HiveType(typeId: 6)
@JsonSerializable()
class EnvironmentalConditions {
  @HiveField(0)
  final double temperature; // 섭씨
  @HiveField(1)
  final double humidity; // 퍼센트
  @HiveField(2)
  final double pressure; // hPa
  @HiveField(3)
  final Season season;
  @HiveField(4)
  final OvenCharacteristics oven;
  @HiveField(5)
  final double? altitude; // 미터

  const EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.season,
    required this.oven,
    this.altitude,
  });

  factory EnvironmentalConditions.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentalConditionsToJson(this);

  EnvironmentalConditions copyWith({
    double? temperature,
    double? humidity,
    double? pressure,
    Season? season,
    OvenCharacteristics? oven,
    double? altitude,
  }) {
    return EnvironmentalConditions(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      season: season ?? this.season,
      oven: oven ?? this.oven,
      altitude: altitude ?? this.altitude,
    );
  }

  /// 온도 보정 계수: 1 + ((실제 온도 - 25) / 10)
  double get temperatureCorrection {
    return 1 + ((temperature - 25) / 10);
  }

  /// 습도 보정 계수: 1 + ((실제 습도% - 65) × 0.005)
  double get humidityCorrection {
    return 1 + ((humidity - 65) * 0.005);
  }

  /// 고도 보정 계수: 1 + ((현재 고도(m) / 1000) × 0.02)
  double get altitudeCorrection {
    if (altitude == null) return 1.0;
    return 1 + ((altitude! / 1000) * 0.02);
  }

  /// 발효 속도 온도 보정: 2^((실제 온도 - 25) / 10)
  double get fermentationSpeedCorrection {
    return math.pow(2, (temperature - 25) / 10).toDouble();
  }

  /// 🔥 더운 환경 반죽온도 조절 조언
  List<String> get heatManagementRecommendations {
    final recommendations = <String>[];

    if (temperature > 30) {
      // 매우 더운 환경 (30°C 이상)
      recommendations.addAll([
        '🚨 매우 더운 환경 감지: 반죽온도가 급격히 상승할 수 있습니다',
        '재료 온도 조절:',
        '  • 냉장 재료 사용 (냉장 우유, 냉동 버터)',
        '  • 얼음물로 반죽하거나 아이스 큐브 2-3개 추가',
        '  • 밀가루를 냉장고에서 30분 이상 차갑게 보관',
        '믹싱 최적화:',
        '  • 저속 믹싱으로 시작 (1단계)',
        '  • 1-2분 믹싱 후 2-3분 휴식 (과열 방지)',
        '  • 총 믹싱 시간 20-30% 단축',
        '환경 제어:',
        '  • 선풍기나 에어컨으로 작업 공간 22-24°C 유지',
        '  • 차가운 대리석판이나 스테인리스 작업대 사용',
        '  • 반죽을 냉장고에서 15-20분 휴지',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트/소금 양 조정은 발효에 큰 영향 → 전문가 상담 권장',
        '  • 정확한 계산 불가로 인한 리스크: 발효 실패 가능성',
        '  • 초보자는 재료 온도와 믹싱 방법 조절만 권장'
      ]);
    } else if (temperature > 25) {
      // 다소 더운 환경 (25-30°C)
      recommendations.addAll([
        '⚠️ 다소 더운 환경 감지: 반죽온도 상승 주의',
        '재료 온도 조절:',
        '  • 차가운 물 사용 (실온보다 3-5°C 낮은 물)',
        '  • 버터를 냉장 상태로 사용',
        '  • 밀가루 실온 보관 (냉장고에서 꺼내기)',
        '믹싱 최적화:',
        '  • 중속에서 저속으로 변경',
        '  • 믹싱 시간 10-15% 단축',
        '환경 제어:',
        '  • 통풍이 좋은 장소에서 작업',
        '  • 반죽을 서늘한 곳에서 10분 휴지',
        '⚠️ 레시피 조정 주의사항:',
        '  • 정확한 계산이 어려우므로 변경 자제',
        '  • 발효 시간 모니터링 강화 권장'
      ]);
    }

    return recommendations;
  }

  /// 🔥 더운 환경용 안전한 조언만 분리
  List<String> get safeHeatManagementTips {
    final safeTips = <String>[];

    if (temperature > 30) {
      safeTips.addAll([
        '냉장 재료 사용 (냉장 우유, 냉동 버터)',
        '얼음물로 반죽하거나 아이스 큐브 2-3개 추가',
        '저속 믹싱으로 시작 (1단계)',
        '1-2분 믹싱 후 2-3분 휴식 (과열 방지)',
        '선풍기나 에어컨으로 작업 공간 냉각',
        '차가운 대리석판이나 스테인리스 작업대 사용',
        '반죽을 냉장고에서 15-20분 휴지'
      ]);
    } else if (temperature > 25) {
      safeTips.addAll([
        '차가운 물 사용 (실온보다 3-5°C 낮은 물)',
        '버터를 냉장 상태로 사용',
        '중속에서 저속으로 변경',
        '통풍이 좋은 장소에서 작업',
        '반죽을 서늘한 곳에서 10분 휴지'
      ]);
    }

    return safeTips;
  }

  /// ⚠️ 리스크가 있는 조언 분리
  List<String> get riskyHeatManagementTips {
    final riskyTips = <String>[];

    if (temperature > 30) {
      riskyTips.addAll([
        '리스크: 이스트 양 10-20% 감소 가능성 (정확한 계산 불가)',
        '리스크: 소금 양 10-15% 증가 가능성 (발효 속도 영향)',
        '리스크: 발효 시간 20-30% 단축 가능성 (과발효 위험)',
        '⚠️ 주의: 정확한 계산이 어렵기 때문에 초보자는 시도하지 않는 것을 권장'
      ]);
    } else if (temperature > 25) {
      riskyTips.addAll([
        '리스크: 이스트 양 소폭 감소 가능성 (정확도 낮음)',
        '리스크: 발효 시간 단축 가능성 (모니터링 필요)',
        '⚠️ 주의: 정확한 계산이 어려우므로 변경 자제 권장'
      ]);
    }

    return riskyTips;
  }

  /// ❄️ 추운 환경 반죽온도 조절 조언
  List<String> get coldManagementRecommendations {
    final recommendations = <String>[];

    if (temperature < 15) {
      // 매우 추운 환경 (15°C 미만)
      recommendations.addAll([
        '❄️ 매우 추운 환경 감지: 반죽온도가 낮아 발효가 느려질 수 있습니다',
        '재료 온도 조절:',
        '  • 따뜻한 물 사용 (35-40°C)',
        '  • 버터와 계란 실온에 1-2시간 보관',
        '  • 밀가루를 실온에 2-3시간 두기',
        '  • 이스트는 따뜻한 물에 미리 활성화',
        '믹싱 최적화:',
        '  • 고속 믹싱으로 시작 (글루텐 형성 촉진)',
        '  • 믹싱 시간 20-30% 연장',
        '  • 2-3분 믹싱 후 1분 휴식 (과열 방지)',
        '환경 제어:',
        '  • 난방이 되는 따뜻한 장소에서 작업',
        '  • 반죽을 보온 장소(오븐 옆)에 20-30분 휴지',
        '  • 믹싱 볼에 따뜻한 물 담가서 예열',
        '발효 관리:',
        '  • 발효 시간을 50-100% 연장',
        '  • 발효 온도를 26-28°C로 유지',
        '  • 습도 80% 이상 유지 (건조 방지)',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트 양 10-20% 증가 가능성 (발효 촉진)',
        '  • 정확한 계산 불가로 인한 리스크: 과발효 가능성',
        '  • 초보자는 환경 제어와 믹싱 방법 조절만 권장'
      ]);
    } else if (temperature < 20) {
      // 다소 추운 환경 (15-20°C)
      recommendations.addAll([
        '❄️ 다소 추운 환경 감지: 발효 시간이 길어질 수 있습니다',
        '재료 온도 조절:',
        '  • 미지근한 물 사용 (25-30°C)',
        '  • 버터 실온에 30분-1시간 보관',
        '  • 밀가루 실온에 1-2시간 두기',
        '믹싱 최적화:',
        '  • 중속 믹싱으로 시작',
        '  • 믹싱 시간 10-15% 연장',
        '환경 제어:',
        '  • 난방이 되는 장소에서 작업',
        '  • 반죽을 따뜻한 곳에서 10-15분 휴지',
        '발효 관리:',
        '  • 발효 시간을 20-30% 연장',
        '  • 발효 중간에 1-2회 접기',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트 양 소폭 증가 가능성 (정확도 낮음)',
        '  • 발효 모니터링 강화 권장'
      ]);
    }

    return recommendations;
  }

  /// ❄️ 추운 환경용 안전한 조언만 분리
  List<String> get safeColdManagementTips {
    final safeTips = <String>[];

    if (temperature < 15) {
      safeTips.addAll([
        '따뜻한 물 사용 (35-40°C)',
        '버터와 계란 실온에 1-2시간 보관',
        '밀가루를 실온에 2-3시간 두기',
        '이스트는 따뜻한 물에 미리 활성화',
        '고속 믹싱으로 시작 (글루텐 형성 촉진)',
        '믹싱 시간 20-30% 연장',
        '2-3분 믹싱 후 1분 휴식 (과열 방지)',
        '난방이 되는 따뜻한 장소에서 작업',
        '반죽을 보온 장소(오븐 옆)에 20-30분 휴지',
        '믹싱 볼에 따뜻한 물 담가서 예열',
        '발효 시간을 50-100% 연장',
        '발효 온도를 26-28°C로 유지',
        '습도 80% 이상 유지 (건조 방지)'
      ]);
    } else if (temperature < 20) {
      safeTips.addAll([
        '미지근한 물 사용 (25-30°C)',
        '버터 실온에 30분-1시간 보관',
        '밀가루 실온에 1-2시간 두기',
        '중속 믹싱으로 시작',
        '믹싱 시간 10-15% 연장',
        '난방이 되는 장소에서 작업',
        '반죽을 따뜻한 곳에서 10-15분 휴지',
        '발효 시간을 20-30% 연장',
        '발효 중간에 1-2회 접기'
      ]);
    }

    return safeTips;
  }

  /// ❄️ 추운 환경 리스크 조언 분리
  List<String> get riskyColdManagementTips {
    final riskyTips = <String>[];

    if (temperature < 15) {
      riskyTips.addAll([
        '리스크: 이스트 양 10-20% 증가 가능성 (정확한 계산 불가)',
        '리스크: 발효 시간 과다 연장 가능성 (과발효 위험)',
        '⚠️ 주의: 정확한 계산이 어렵기 때문에 초보자는 시도하지 않는 것을 권장'
      ]);
    } else if (temperature < 20) {
      riskyTips.addAll([
        '리스크: 이스트 양 소폭 증가 가능성 (정확도 낮음)',
        '리스크: 발효 시간 과다 연장 가능성 (모니터링 필요)',
        '⚠️ 주의: 정확한 계산이 어려우므로 변경 자제 권장'
      ]);
    }

    return riskyTips;
  }
}

/// 계절 정보
@HiveType(typeId: 7)
enum Season {
  @HiveField(0)
  @JsonValue('spring')
  spring,
  @HiveField(1)
  @JsonValue('summer')
  summer,
  @HiveField(2)
  @JsonValue('autumn')
  autumn,
  @HiveField(3)
  @JsonValue('winter')
  winter,
}

extension SeasonExtension on Season {
  String get displayName {
    switch (this) {
      case Season.spring:
        return '봄';
      case Season.summer:
        return '여름';
      case Season.autumn:
        return '가을';
      case Season.winter:
        return '겨울';
    }
  }
}

/// 오븐 특성 정보
@HiveType(typeId: 8)
@JsonSerializable()
class OvenCharacteristics {
  @HiveField(0)
  final OvenType type;
  @HiveField(1)
  final double typeCoefficient; // 오븐 유형 계수
  @HiveField(2)
  final double calibrationIndex; // 동적 캘리브레이션 지수
  @HiveField(3)
  final double steamCapability; // 스팀 능력
  @HiveField(4)
  final bool hasConvection; // 컨벡션 기능 여부
  @HiveField(5)
  final double maxTemperature; // 최대 온도
  @HiveField(6)
  final bool hasStone; // 피자 스톤 여부
  @HiveField(7)
  final bool hasSteam; // 스팀 기능 여부
  @HiveField(8)
  final double temperatureAccuracy; // 온도 정확도

  const OvenCharacteristics({
    required this.type,
    required this.typeCoefficient,
    required this.calibrationIndex,
    required this.steamCapability,
    required this.hasConvection,
    required this.maxTemperature,
    this.hasStone = false,
    this.hasSteam = false,
    this.temperatureAccuracy = 0.95,
  });

  factory OvenCharacteristics.fromJson(Map<String, dynamic> json) =>
      _$OvenCharacteristicsFromJson(json);

  Map<String, dynamic> toJson() => _$OvenCharacteristicsToJson(this);

  OvenCharacteristics copyWith({
    OvenType? type,
    double? typeCoefficient,
    double? calibrationIndex,
    double? steamCapability,
    bool? hasConvection,
    double? maxTemperature,
    bool? hasStone,
    bool? hasSteam,
    double? temperatureAccuracy,
  }) {
    return OvenCharacteristics(
      type: type ?? this.type,
      typeCoefficient: typeCoefficient ?? this.typeCoefficient,
      calibrationIndex: calibrationIndex ?? this.calibrationIndex,
      steamCapability: steamCapability ?? this.steamCapability,
      hasConvection: hasConvection ?? this.hasConvection,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      hasStone: hasStone ?? this.hasStone,
      hasSteam: hasSteam ?? this.hasSteam,
      temperatureAccuracy: temperatureAccuracy ?? this.temperatureAccuracy,
    );
  }
}

/// 오븐 타입
@HiveType(typeId: 9)
enum OvenType {
  @HiveField(0)
  @JsonValue('home')
  home,
  @HiveField(1)
  @JsonValue('professional_convection')
  professionalConvection,
  @HiveField(2)
  @JsonValue('deck')
  deck,
  @HiveField(3)
  @JsonValue('steam')
  steam,
  @HiveField(4)
  @JsonValue('conventional')
  conventional, // 일반 오븐
  @HiveField(5)
  @JsonValue('convection')
  convection, // 컨벡션 오븐
  @HiveField(6)
  @JsonValue('combi')
  combi, // 콤비 오븐
}

extension OvenTypeExtension on OvenType {
  String get displayName {
    switch (this) {
      case OvenType.home:
        return '가정용 오븐';
      case OvenType.professionalConvection:
        return '전문가용 컨벡션';
      case OvenType.deck:
        return '데크 오븐';
      case OvenType.steam:
        return '스팀 오븐';
      case OvenType.conventional:
        return '일반 오븐';
      case OvenType.convection:
        return '컨벡션 오븐';
      case OvenType.combi:
        return '콤비 오븐';
    }
  }

  /// 기본 유형 계수
  double get defaultTypeCoefficient {
    switch (this) {
      case OvenType.home:
        return 0.9;
      case OvenType.professionalConvection:
        return 1.0;
      case OvenType.deck:
        return 1.1;
      case OvenType.steam:
        return 1.2;
      case OvenType.conventional:
        return 0.95;
      case OvenType.convection:
        return 1.05;
      case OvenType.combi:
        return 1.15;
    }
  }
}

/// 재료 메타데이터
@JsonSerializable()
class IngredientMetadata {
  final String name;
  final Map<String, dynamic> properties; // 글루텐, 수분, 단백질 등
  final double effectiveValue; // 유효값 (보정 적용 후)
  final String function; // 재료의 기능 (구조 형성, 발효 등)
  final double qualityCorrectionFactor; // 품질 보정 계수
  final String? description; // 재료 설명 (선택적)

  const IngredientMetadata({
    required this.name,
    required this.properties,
    required this.effectiveValue,
    required this.function,
    required this.qualityCorrectionFactor,
    this.description,
  });

  factory IngredientMetadata.fromJson(Map<String, dynamic> json) =>
      _$IngredientMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientMetadataToJson(this);

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

/// 공정 메타데이터
@JsonSerializable()
class ProcessMetadata {
  final MixingMeta mixing;
  final FermentationMeta fermentation;
  final BakingMeta baking;

  const ProcessMetadata({
    required this.mixing,
    required this.fermentation,
    required this.baking,
  });

  factory ProcessMetadata.fromJson(Map<String, dynamic> json) =>
      _$ProcessMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessMetadataToJson(this);

  ProcessMetadata copyWith({
    MixingMeta? mixing,
    FermentationMeta? fermentation,
    BakingMeta? baking,
  }) {
    return ProcessMetadata(
      mixing: mixing ?? this.mixing,
      fermentation: fermentation ?? this.fermentation,
      baking: baking ?? this.baking,
    );
  }
}

/// 믹싱 메타데이터
@JsonSerializable()
class MixingMeta {
  final double predictedTime; // 예측 시간 (분)
  final double frictionHeat; // 마찰열 (°C)
  final double mixerTypeCoefficient; // 반죽기 유형 계수
  final double glutenDevelopmentTarget; // 글루텐 발달 목표 계수
  final double equipmentCalibration; // 장비 캘리브레이션 계수

  const MixingMeta({
    required this.predictedTime,
    required this.frictionHeat,
    required this.mixerTypeCoefficient,
    required this.glutenDevelopmentTarget,
    required this.equipmentCalibration,
  });

  factory MixingMeta.fromJson(Map<String, dynamic> json) =>
      _$MixingMetaFromJson(json);

  Map<String, dynamic> toJson() => _$MixingMetaToJson(this);

  MixingMeta copyWith({
    double? predictedTime,
    double? frictionHeat,
    double? mixerTypeCoefficient,
    double? glutenDevelopmentTarget,
    double? equipmentCalibration,
  }) {
    return MixingMeta(
      predictedTime: predictedTime ?? this.predictedTime,
      frictionHeat: frictionHeat ?? this.frictionHeat,
      mixerTypeCoefficient: mixerTypeCoefficient ?? this.mixerTypeCoefficient,
      glutenDevelopmentTarget:
          glutenDevelopmentTarget ?? this.glutenDevelopmentTarget,
      equipmentCalibration: equipmentCalibration ?? this.equipmentCalibration,
    );
  }
}

/// 발효 메타데이터
@JsonSerializable()
class FermentationMeta {
  final double predictedTime; // 예측 시간 (분)
  final double volumeIncrease; // 부피 증가 (배수)
  final double microbialActivityCoefficient; // 미생물 활성 계수
  final double doughPhysicalChemicalCoefficient; // 반죽 물리화학 계수
  final double environmentalClimateCoefficient; // 환경 기후 계수
  final double doughTypeCorrection; // 반죽 유형 보정 계수

  const FermentationMeta({
    required this.predictedTime,
    required this.volumeIncrease,
    required this.microbialActivityCoefficient,
    required this.doughPhysicalChemicalCoefficient,
    required this.environmentalClimateCoefficient,
    required this.doughTypeCorrection,
  });

  factory FermentationMeta.fromJson(Map<String, dynamic> json) =>
      _$FermentationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$FermentationMetaToJson(this);

  FermentationMeta copyWith({
    double? predictedTime,
    double? volumeIncrease,
    double? microbialActivityCoefficient,
    double? doughPhysicalChemicalCoefficient,
    double? environmentalClimateCoefficient,
    double? doughTypeCorrection,
  }) {
    return FermentationMeta(
      predictedTime: predictedTime ?? this.predictedTime,
      volumeIncrease: volumeIncrease ?? this.volumeIncrease,
      microbialActivityCoefficient:
          microbialActivityCoefficient ?? this.microbialActivityCoefficient,
      doughPhysicalChemicalCoefficient: doughPhysicalChemicalCoefficient ??
          this.doughPhysicalChemicalCoefficient,
      environmentalClimateCoefficient: environmentalClimateCoefficient ??
          this.environmentalClimateCoefficient,
      doughTypeCorrection: doughTypeCorrection ?? this.doughTypeCorrection,
    );
  }
}

/// 굽기 메타데이터
@JsonSerializable()
class BakingMeta {
  final List<BakingPhase> temperatureProfile; // 단계별 온도 프로파일
  final double totalBakingTime; // 총 굽기 시간 (분)
  final double weightCorrection; // 무게 보정
  final double hydrationCorrection; // 하이드레이션 보정
  final double ovenEfficiency; // 오븐 효율
  final double breadTypeCorrection; // 빵 종류 보정

  const BakingMeta({
    required this.temperatureProfile,
    required this.totalBakingTime,
    required this.weightCorrection,
    required this.hydrationCorrection,
    required this.ovenEfficiency,
    required this.breadTypeCorrection,
  });

  factory BakingMeta.fromJson(Map<String, dynamic> json) =>
      _$BakingMetaFromJson(json);

  Map<String, dynamic> toJson() => _$BakingMetaToJson(this);

  BakingMeta copyWith({
    List<BakingPhase>? temperatureProfile,
    double? totalBakingTime,
    double? weightCorrection,
    double? hydrationCorrection,
    double? ovenEfficiency,
    double? breadTypeCorrection,
  }) {
    return BakingMeta(
      temperatureProfile: temperatureProfile ?? this.temperatureProfile,
      totalBakingTime: totalBakingTime ?? this.totalBakingTime,
      weightCorrection: weightCorrection ?? this.weightCorrection,
      hydrationCorrection: hydrationCorrection ?? this.hydrationCorrection,
      ovenEfficiency: ovenEfficiency ?? this.ovenEfficiency,
      breadTypeCorrection: breadTypeCorrection ?? this.breadTypeCorrection,
    );
  }
}

/// 굽기 단계
@JsonSerializable()
class BakingPhase {
  final String phase; // 단계명 (Phase 1, Phase 2, etc.)
  final double temperature; // 온도 (°C)
  final double time; // 시간 (분)
  final double? steamTime; // 스팀 시간 (분, 선택적)

  const BakingPhase({
    required this.phase,
    required this.temperature,
    required this.time,
    this.steamTime,
  });

  factory BakingPhase.fromJson(Map<String, dynamic> json) =>
      _$BakingPhaseFromJson(json);

  Map<String, dynamic> toJson() => _$BakingPhaseToJson(this);

  BakingPhase copyWith({
    String? phase,
    double? temperature,
    double? time,
    double? steamTime,
  }) {
    return BakingPhase(
      phase: phase ?? this.phase,
      temperature: temperature ?? this.temperature,
      time: time ?? this.time,
      steamTime: steamTime ?? this.steamTime,
    );
  }
}

/// 품질 메타데이터
@JsonSerializable()
class QualityMetadata {
  final double volumeIndex; // 볼륨 지수 (예측 배수)
  final double crustColorIndex; // 크러스트 색상 지수
  final double poreStructureScore; // 내부 기공 점수
  final double moistureRetention; // 수분 보유율

  const QualityMetadata({
    required this.volumeIndex,
    required this.crustColorIndex,
    required this.poreStructureScore,
    required this.moistureRetention,
  });

  factory QualityMetadata.fromJson(Map<String, dynamic> json) =>
      _$QualityMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$QualityMetadataToJson(this);

  QualityMetadata copyWith({
    double? volumeIndex,
    double? crustColorIndex,
    double? poreStructureScore,
    double? moistureRetention,
  }) {
    return QualityMetadata(
      volumeIndex: volumeIndex ?? this.volumeIndex,
      crustColorIndex: crustColorIndex ?? this.crustColorIndex,
      poreStructureScore: poreStructureScore ?? this.poreStructureScore,
      moistureRetention: moistureRetention ?? this.moistureRetention,
    );
  }
}

/// 디저트 메타데이터 (선택적)
@JsonSerializable()
class DessertMetadata {
  final String dessertType; // 디저트 종류
  final String country; // 원산지 국가
  final Map<String, double> calculatedValues; // 계산된 값들
  final Map<String, double> correctionFactors; // 보정 계수들

  const DessertMetadata({
    required this.dessertType,
    required this.country,
    required this.calculatedValues,
    required this.correctionFactors,
  });

  factory DessertMetadata.fromJson(Map<String, dynamic> json) =>
      _$DessertMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$DessertMetadataToJson(this);

  DessertMetadata copyWith({
    String? dessertType,
    String? country,
    Map<String, double>? calculatedValues,
    Map<String, double>? correctionFactors,
  }) {
    return DessertMetadata(
      dessertType: dessertType ?? this.dessertType,
      country: country ?? this.country,
      calculatedValues: calculatedValues ?? this.calculatedValues,
      correctionFactors: correctionFactors ?? this.correctionFactors,
    );
  }
}

/// 인터페이스 메타데이터 (알람, 대시보드 등)
@JsonSerializable()
class InterfaceMetadata {
  final List<Alert> alerts; // 알람 목록
  final DashboardData dashboard; // 대시보드 데이터

  const InterfaceMetadata({
    required this.alerts,
    required this.dashboard,
  });

  factory InterfaceMetadata.fromJson(Map<String, dynamic> json) =>
      _$InterfaceMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$InterfaceMetadataToJson(this);

  InterfaceMetadata copyWith({
    List<Alert>? alerts,
    DashboardData? dashboard,
  }) {
    return InterfaceMetadata(
      alerts: alerts ?? this.alerts,
      dashboard: dashboard ?? this.dashboard,
    );
  }
}

@JsonSerializable()
class Alert {
  @JsonKey()
  final String id;

  @JsonKey()
  final String title;

  @JsonKey()
  final String message;

  @JsonKey()
  final AlertType type;

  @JsonKey()
  final String action;

  @JsonKey()
  final DateTime timestamp;

  @JsonKey()
  final AlertSeverity severity;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.action,
    required this.timestamp,
    required this.severity,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);

  Map<String, dynamic> toJson() => _$AlertToJson(this);

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    String? action,
    DateTime? timestamp,
    AlertSeverity? severity,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }
}

/// 알람 타입
enum AlertType {
  @JsonValue('fermentation_time_deviation')
  fermentationTimeDeviation,
  @JsonValue('baking_temperature_deviation')
  bakingTemperatureDeviation,
  @JsonValue('environment_variable_deviation')
  environmentVariableDeviation,
  @JsonValue('process_completion')
  processCompletion,
}

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.fermentationTimeDeviation:
        return '발효 시간 이탈';
      case AlertType.bakingTemperatureDeviation:
        return '굽기 온도 이탈';
      case AlertType.environmentVariableDeviation:
        return '환경 변수 이탈';
      case AlertType.processCompletion:
        return '공정 완료';
    }
  }
}

/// 알람 심각도
enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return '낮음';
      case AlertSeverity.medium:
        return '보통';
      case AlertSeverity.high:
        return '높음';
      case AlertSeverity.critical:
        return '긴급';
    }
  }
}

/// 대시보드 데이터
@JsonSerializable()
class DashboardData {
  final VolumeIndexData volumeIndex;
  final CrustColorData crustColor;
  final PoreStructureData poreStructure;
  final EnvironmentData environment;
  final List<Alert> recentAlerts;

  const DashboardData({
    required this.volumeIndex,
    required this.crustColor,
    required this.poreStructure,
    required this.environment,
    required this.recentAlerts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);

  DashboardData copyWith({
    VolumeIndexData? volumeIndex,
    CrustColorData? crustColor,
    PoreStructureData? poreStructure,
    EnvironmentData? environment,
    List<Alert>? recentAlerts,
  }) {
    return DashboardData(
      volumeIndex: volumeIndex ?? this.volumeIndex,
      crustColor: crustColor ?? this.crustColor,
      poreStructure: poreStructure ?? this.poreStructure,
      environment: environment ?? this.environment,
      recentAlerts: recentAlerts ?? this.recentAlerts,
    );
  }
}

/// 볼륨 지수 데이터
@JsonSerializable()
class VolumeIndexData {
  final double current; // 현재 값
  final double target; // 목표 값
  final List<double> history; // 이력 데이터

  const VolumeIndexData({
    required this.current,
    required this.target,
    required this.history,
  });

  factory VolumeIndexData.fromJson(Map<String, dynamic> json) =>
      _$VolumeIndexDataFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeIndexDataToJson(this);

  VolumeIndexData copyWith({
    double? current,
    double? target,
    List<double>? history,
  }) {
    return VolumeIndexData(
      current: current ?? this.current,
      target: target ?? this.target,
      history: history ?? this.history,
    );
  }
}

/// 크러스트 색상 데이터
@JsonSerializable()
class CrustColorData {
  final double current; // 현재 색상 강도
  final double target; // 목표 색상 강도
  final List<double> history; // 이력 데이터

  const CrustColorData({
    required this.current,
    required this.target,
    required this.history,
  });

  factory CrustColorData.fromJson(Map<String, dynamic> json) =>
      _$CrustColorDataFromJson(json);

  Map<String, dynamic> toJson() => _$CrustColorDataToJson(this);

  CrustColorData copyWith({
    double? current,
    double? target,
    List<double>? history,
  }) {
    return CrustColorData(
      current: current ?? this.current,
      target: target ?? this.target,
      history: history ?? this.history,
    );
  }
}

/// 기공 구조 데이터
@JsonSerializable()
class PoreStructureData {
  final double current; // 현재 점수
  final double target; // 목표 점수
  final List<double> sizeDistribution; // 크기 분포

  const PoreStructureData({
    required this.current,
    required this.target,
    required this.sizeDistribution,
  });

  factory PoreStructureData.fromJson(Map<String, dynamic> json) =>
      _$PoreStructureDataFromJson(json);

  Map<String, dynamic> toJson() => _$PoreStructureDataToJson(this);

  PoreStructureData copyWith({
    double? current,
    double? target,
    List<double>? sizeDistribution,
  }) {
    return PoreStructureData(
      current: current ?? this.current,
      target: target ?? this.target,
      sizeDistribution: sizeDistribution ?? this.sizeDistribution,
    );
  }
}

/// 환경 데이터
@JsonSerializable()
class EnvironmentData {
  final double temperature;
  final double humidity;
  final double pressure;
  final bool isWithinRange; // 허용 범위 내 여부

  const EnvironmentData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.isWithinRange,
  });

  factory EnvironmentData.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentDataToJson(this);

  EnvironmentData copyWith({
    double? temperature,
    double? humidity,
    double? pressure,
    bool? isWithinRange,
  }) {
    return EnvironmentData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      isWithinRange: isWithinRange ?? this.isWithinRange,
    );
  }
}

/// 발효 계수 정보
@JsonSerializable()
class FermentationCoefficients {
  final double microbialActivityCoefficient; // 미생물 활성 계수
  final double doughPhysicochemicalCoefficient; // 반죽 물리화학 계수
  final double environmentalClimateCoefficient; // 환경 기후 계수
  final double doughTypeCorrectionCoefficient; // 반죽 유형 보정 계수

  const FermentationCoefficients({
    required this.microbialActivityCoefficient,
    required this.doughPhysicochemicalCoefficient,
    required this.environmentalClimateCoefficient,
    required this.doughTypeCorrectionCoefficient,
  });

  factory FermentationCoefficients.fromJson(Map<String, dynamic> json) =>
      _$FermentationCoefficientsFromJson(json);

  Map<String, dynamic> toJson() => _$FermentationCoefficientsToJson(this);

  FermentationCoefficients copyWith({
    double? microbialActivityCoefficient,
    double? doughPhysicochemicalCoefficient,
    double? environmentalClimateCoefficient,
    double? doughTypeCorrectionCoefficient,
  }) {
    return FermentationCoefficients(
      microbialActivityCoefficient:
          microbialActivityCoefficient ?? this.microbialActivityCoefficient,
      doughPhysicochemicalCoefficient: doughPhysicochemicalCoefficient ??
          this.doughPhysicochemicalCoefficient,
      environmentalClimateCoefficient: environmentalClimateCoefficient ??
          this.environmentalClimateCoefficient,
      doughTypeCorrectionCoefficient:
          doughTypeCorrectionCoefficient ?? this.doughTypeCorrectionCoefficient,
    );
  }
}

/// 환경 조건 유효성 검증 클래스
class EnvironmentalConditionsValidator {
  /// 온도 유효성 검증 (일반적인 제빵 환경: 10°C ~ 40°C)
  static bool isValidTemperature(double temperature) {
    return temperature >= -20.0 && temperature <= 60.0;
  }

  /// 습도 유효성 검증 (일반적인 범위: 20% ~ 95%)
  static bool isValidHumidity(double humidity) {
    return humidity >= 0.0 && humidity <= 100.0;
  }

  /// 기압 유효성 검증 (일반적인 범위: 900hPa ~ 1100hPa)
  static bool isValidPressure(double pressure) {
    return pressure >= 800.0 && pressure <= 1200.0;
  }

  /// 고도 유효성 검증 (일반적인 범위: -500m ~ 5000m)
  static bool isValidAltitude(double? altitude) {
    if (altitude == null) return true;
    return altitude >= -500.0 && altitude <= 5000.0;
  }

  /// 전체 환경 조건 유효성 검증
  static ValidationResult validateEnvironmentalConditions(
      EnvironmentalConditions conditions) {
    final errors = <String>[];
    final warnings = <String>[];

    // 온도 검증
    if (!isValidTemperature(conditions.temperature)) {
      errors
          .add('온도가 유효 범위(-20°C ~ 60°C)를 벗어났습니다: ${conditions.temperature}°C');
    } else if (conditions.temperature < 10.0 || conditions.temperature > 40.0) {
      warnings.add(
          '온도가 일반적인 제빵 환경(10°C ~ 40°C)을 벗어났습니다: ${conditions.temperature}°C');
    }

    // 습도 검증
    if (!isValidHumidity(conditions.humidity)) {
      errors.add('습도가 유효 범위(0% ~ 100%)를 벗어났습니다: ${conditions.humidity}%');
    } else if (conditions.humidity < 30.0 || conditions.humidity > 90.0) {
      warnings
          .add('습도가 일반적인 제빵 환경(30% ~ 90%)을 벗어났습니다: ${conditions.humidity}%');
    }

    // 기압 검증
    if (!isValidPressure(conditions.pressure)) {
      errors.add(
          '기압이 유효 범위(800hPa ~ 1200hPa)를 벗어났습니다: ${conditions.pressure}hPa');
    } else if (conditions.pressure < 950.0 || conditions.pressure > 1050.0) {
      warnings.add(
          '기압이 일반적인 범위(950hPa ~ 1050hPa)를 벗어났습니다: ${conditions.pressure}hPa');
    }

    // 고도 검증
    if (!isValidAltitude(conditions.altitude)) {
      errors.add('고도가 유효 범위(-500m ~ 5000m)를 벗어났습니다: ${conditions.altitude}m');
    } else if (conditions.altitude != null &&
        (conditions.altitude! < 0.0 || conditions.altitude! > 3000.0)) {
      warnings.add('고도가 일반적인 범위(0m ~ 3000m)를 벗어났습니다: ${conditions.altitude}m');
    }

    // 오븐 특성 검증
    final ovenValidation =
        OvenCharacteristicsValidator.validateOvenCharacteristics(
            conditions.oven);
    errors.addAll(ovenValidation.errors);
    warnings.addAll(ovenValidation.warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 환경 조건 권장 범위 확인
  static EnvironmentalRecommendation getRecommendations(
      EnvironmentalConditions conditions) {
    final recommendations = <String>[];

    // 온도 권장사항
    if (conditions.temperature < 20.0) {
      recommendations.add('온도가 낮습니다. 발효 시간이 길어질 수 있습니다.');
    } else if (conditions.temperature > 30.0) {
      recommendations.add('온도가 높습니다. 발효가 빨라질 수 있으니 주의하세요.');
    }

    // 습도 권장사항
    if (conditions.humidity < 50.0) {
      recommendations.add('습도가 낮습니다. 반죽 표면이 마를 수 있으니 덮개를 사용하세요.');
    } else if (conditions.humidity > 80.0) {
      recommendations.add('습도가 높습니다. 곰팡이 발생에 주의하세요.');
    }

    // 계절별 권장사항
    switch (conditions.season) {
      case Season.summer:
        recommendations.add('여름철에는 발효가 빨라지니 시간을 단축하세요.');
        break;
      case Season.winter:
        recommendations.add('겨울철에는 발효가 느려지니 따뜻한 곳에서 발효하세요.');
        break;
      case Season.spring:
      case Season.autumn:
        recommendations.add('적절한 계절입니다. 표준 발효 시간을 사용하세요.');
        break;
    }

    return EnvironmentalRecommendation(
      recommendations: recommendations,
      // 동적 계산 적용 - 하드코딩 제거
      optimalTemperatureRange: TemperatureRange(
        min: EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature -
            5.0,
        max: EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature +
            5.0,
      ),
      optimalHumidityRange: HumidityRange(
        min: EnvironmentDefaultsCalculator.getDefaultEnvironment().humidity -
            10.0,
        max: EnvironmentDefaultsCalculator.getDefaultEnvironment().humidity +
            10.0,
      ),
    );
  }
}

/// 오븐 특성 유효성 검증 클래스
class OvenCharacteristicsValidator {
  /// 오븐 특성 유효성 검증
  static ValidationResult validateOvenCharacteristics(
      OvenCharacteristics oven) {
    final errors = <String>[];
    final warnings = <String>[];

    // 유형 계수 검증
    if (oven.typeCoefficient < 0.5 || oven.typeCoefficient > 2.0) {
      errors.add('오븐 유형 계수가 유효 범위(0.5 ~ 2.0)를 벗어났습니다: ${oven.typeCoefficient}');
    }

    // 캘리브레이션 지수 검증
    if (oven.calibrationIndex < 0.8 || oven.calibrationIndex > 1.5) {
      warnings.add(
          '캘리브레이션 지수가 일반적인 범위(0.8 ~ 1.5)를 벗어났습니다: ${oven.calibrationIndex}');
    }

    // 스팀 능력 검증
    if (oven.steamCapability < 0.0 || oven.steamCapability > 2.0) {
      errors.add('스팀 능력이 유효 범위(0.0 ~ 2.0)를 벗어났습니다: ${oven.steamCapability}');
    }

    // 최대 온도 검증
    if (oven.maxTemperature < 150.0 || oven.maxTemperature > 500.0) {
      errors
          .add('최대 온도가 유효 범위(150°C ~ 500°C)를 벗어났습니다: ${oven.maxTemperature}°C');
    } else if (oven.maxTemperature < 220.0) {
      warnings.add(
          '최대 온도가 낮습니다(${oven.maxTemperature}°C). 일부 빵 종류에 제한이 있을 수 있습니다.');
    }

    // 스팀 오븐인데 스팀 능력이 낮은 경우
    if (oven.type == OvenType.steam && oven.steamCapability < 0.8) {
      warnings.add('스팀 오븐이지만 스팀 능력이 낮습니다: ${oven.steamCapability}');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 유효성 검증 결과
@JsonSerializable()
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultToJson(this);

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// 환경 권장사항
@JsonSerializable()
class EnvironmentalRecommendation {
  final List<String> recommendations;
  final TemperatureRange optimalTemperatureRange;
  final HumidityRange optimalHumidityRange;

  const EnvironmentalRecommendation({
    required this.recommendations,
    required this.optimalTemperatureRange,
    required this.optimalHumidityRange,
  });

  factory EnvironmentalRecommendation.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentalRecommendationToJson(this);
}

/// 온도 범위
@JsonSerializable()
class TemperatureRange {
  final double min;
  final double max;

  const TemperatureRange({
    required this.min,
    required this.max,
  });

  factory TemperatureRange.fromJson(Map<String, dynamic> json) =>
      _$TemperatureRangeFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureRangeToJson(this);

  bool contains(double temperature) => temperature >= min && temperature <= max;
}

/// 습도 범위
@JsonSerializable()
class HumidityRange {
  final double min;
  final double max;

  const HumidityRange({
    required this.min,
    required this.max,
  });

  factory HumidityRange.fromJson(Map<String, dynamic> json) =>
      _$HumidityRangeFromJson(json);

  Map<String, dynamic> toJson() => _$HumidityRangeToJson(this);

  bool contains(double humidity) => humidity >= min && humidity <= max;
}

// 재료 기능 분류
enum IngredientFunction {
  @JsonValue('structure_formation')
  structureFormation, // 구조 형성 (밀가루, 글루텐)

  @JsonValue('fermentation')
  fermentation, // 발효 (이스트, 사워도우 스타터)

  @JsonValue('flavor_enhancement')
  flavorEnhancement, // 풍미 향상 (소금, 설탕, 향신료)

  @JsonValue('texture_modification')
  textureModification, // 텍스처 조절 (지방, 버터, 오일)

  @JsonValue('moisture_control')
  moistureControl, // 수분 조절 (물, 우유, 계란)

  @JsonValue('leavening')
  leavening, // 팽창 (베이킹파우더, 베이킹소다)

  @JsonValue('binding')
  binding, // 결합 (계란, 젤라틴)

  @JsonValue('preservation')
  preservation, // 보존 (소금, 설탕, 방부제)

  @JsonValue('coloring')
  coloring, // 착색 (코코아, 식용색소)

  @JsonValue('decoration')
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
  static Map<String, dynamic> analyzeChemicalProperties(Ingredient ingredient) {
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
  static double calculateQualityCorrectionFactor(Ingredient ingredient) {
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

/// 재료 메타데이터 생성기
class IngredientMetadataGenerator {
  /// 재료로부터 메타데이터 생성
  static IngredientMetadata generateMetadata(Ingredient ingredient) {
    final functions = IngredientAnalyzer.analyzeFunctions(ingredient.name);
    final properties = IngredientAnalyzer.analyzeChemicalProperties(ingredient);
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
      List<Ingredient> ingredients) {
    return ingredients
        .map((ingredient) => generateMetadata(ingredient))
        .toList();
  }

  /// 재료 호환성 검사
  static CompatibilityResult checkIngredientCompatibility(
      List<Ingredient> ingredients) {
    final issues = <String>[];
    final warnings = <String>[];

    // 이스트와 소금의 직접 접촉 검사
    final hasYeast = ingredients.any((i) => i.isYeast);
    final hasSalt = ingredients.any((i) => i.isSalt);

    if (hasYeast && hasSalt) {
      warnings.add('이스트와 소금이 직접 접촉하지 않도록 주의하세요.');
    }

    // 산성 재료와 베이킹소다 호환성
    final hasAcidic = ingredients.any((i) =>
        i.name.toLowerCase().contains('lemon') ||
        i.name.toLowerCase().contains('레몬') ||
        i.name.toLowerCase().contains('vinegar') ||
        i.name.toLowerCase().contains('식초'));

    final hasBakingSoda = ingredients.any((i) =>
        i.name.toLowerCase().contains('baking soda') ||
        i.name.toLowerCase().contains('베이킹소다'));

    if (hasAcidic && hasBakingSoda) {
      warnings.add('산성 재료와 베이킹소다가 함께 사용되어 즉시 반응할 수 있습니다.');
    }

    // 지방 함량 과다 검사
    final totalFat =
        ingredients.where((i) => i.isFat).fold(0.0, (sum, i) => sum + i.amount);

    final flourAmount = ingredients
        .where((i) => i.isFlour)
        .fold(0.0, (sum, i) => sum + i.amount);

    if (flourAmount > 0 && (totalFat / flourAmount) > 0.3) {
      warnings.add('지방 함량이 높습니다. 글루텐 형성에 영향을 줄 수 있습니다.');
    }

    return CompatibilityResult(
      isCompatible: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }
}

/// 재료 호환성 검사 결과
@JsonSerializable()
class CompatibilityResult {
  final bool isCompatible;
  final List<String> issues;
  final List<String> warnings;

  const CompatibilityResult({
    required this.isCompatible,
    required this.issues,
    required this.warnings,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) =>
      _$CompatibilityResultFromJson(json);

  Map<String, dynamic> toJson() => _$CompatibilityResultToJson(this);

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => issues.isNotEmpty;
}

/// 알람 설정 정보
@JsonSerializable()
class AlertPreferences {
  final bool enableFermentationAlerts; // 발효 알람 활성화
  final bool enableBakingAlerts; // 굽기 알람 활성화
  final bool enableEnvironmentAlerts; // 환경 알람 활성화
  final bool enableCompletionAlerts; // 완료 알람 활성화
  final bool enableSound; // 소리 알람 활성화
  final bool enableVibration; // 진동 알람 활성화
  final int alertLeadTime; // 알람 사전 시간 (분)
  final double temperatureThreshold; // 온도 이탈 임계값 (%)
  final double humidityThreshold; // 습도 이탈 임계값 (%)
  final double timeDeviationThreshold; // 시간 이탈 임계값 (%)

  const AlertPreferences({
    this.enableFermentationAlerts = true,
    this.enableBakingAlerts = true,
    this.enableEnvironmentAlerts = false,
    this.enableCompletionAlerts = true,
    this.enableSound = true,
    this.enableVibration = false,
    this.alertLeadTime = 5,
    this.temperatureThreshold = 5.0,
    this.humidityThreshold = 10.0,
    this.timeDeviationThreshold = 10.0,
  });

  factory AlertPreferences.fromJson(Map<String, dynamic> json) =>
      _$AlertPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$AlertPreferencesToJson(this);

  AlertPreferences copyWith({
    bool? enableFermentationAlerts,
    bool? enableBakingAlerts,
    bool? enableEnvironmentAlerts,
    bool? enableCompletionAlerts,
    bool? enableSound,
    bool? enableVibration,
    int? alertLeadTime,
    double? temperatureThreshold,
    double? humidityThreshold,
    double? timeDeviationThreshold,
  }) {
    return AlertPreferences(
      enableFermentationAlerts:
          enableFermentationAlerts ?? this.enableFermentationAlerts,
      enableBakingAlerts: enableBakingAlerts ?? this.enableBakingAlerts,
      enableEnvironmentAlerts:
          enableEnvironmentAlerts ?? this.enableEnvironmentAlerts,
      enableCompletionAlerts:
          enableCompletionAlerts ?? this.enableCompletionAlerts,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      alertLeadTime: alertLeadTime ?? this.alertLeadTime,
      temperatureThreshold: temperatureThreshold ?? this.temperatureThreshold,
      humidityThreshold: humidityThreshold ?? this.humidityThreshold,
      timeDeviationThreshold:
          timeDeviationThreshold ?? this.timeDeviationThreshold,
    );
  }

  @override
  String toString() {
    return 'AlertPreferences(fermentation: $enableFermentationAlerts, baking: $enableBakingAlerts, environment: $enableEnvironmentAlerts, completion: $enableCompletionAlerts)';
  }
}

/// 대시보드 메트릭 정보
class DashboardMetrics {
  final double updateFrequency; // 초당 업데이트 빈도
  final int activeCharts; // 활성 차트 수
  final int dataPoints; // 데이터 포인트 수
  final int alertsCount; // 알림 수
  final DateTime lastUpdate; // 마지막 업데이트 시간
  final double performanceScore; // 성능 점수

  const DashboardMetrics({
    required this.updateFrequency,
    required this.activeCharts,
    required this.dataPoints,
    required this.alertsCount,
    required this.lastUpdate,
    required this.performanceScore,
  });

  Map<String, dynamic> toJson() => {
        'updateFrequency': updateFrequency,
        'activeCharts': activeCharts,
        'dataPoints': dataPoints,
        'alertsCount': alertsCount,
        'lastUpdate': lastUpdate.toIso8601String(),
        'performanceScore': performanceScore,
      };

  DashboardMetrics copyWith({
    double? updateFrequency,
    int? activeCharts,
    int? dataPoints,
    int? alertsCount,
    DateTime? lastUpdate,
    double? performanceScore,
  }) {
    return DashboardMetrics(
      updateFrequency: updateFrequency ?? this.updateFrequency,
      activeCharts: activeCharts ?? this.activeCharts,
      dataPoints: dataPoints ?? this.dataPoints,
      alertsCount: alertsCount ?? this.alertsCount,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      performanceScore: performanceScore ?? this.performanceScore,
    );
  }

  /// 성능 등급 반환
  String get performanceGrade {
    if (performanceScore >= 90) return 'Excellent';
    if (performanceScore >= 80) return 'Good';
    if (performanceScore >= 70) return 'Fair';
    if (performanceScore >= 60) return 'Poor';
    return 'Critical';
  }

  /// 시스템 상태 반환
  String get systemStatus {
    if (performanceScore >= 85) return 'Optimal';
    if (performanceScore >= 75) return 'Stable';
    if (performanceScore >= 65) return 'Warning';
    return 'Critical';
  }

  @override
  String toString() {
    return 'DashboardMetrics(performance: ${performanceScore.toStringAsFixed(1)}, grade: $performanceGrade, status: $systemStatus)';
  }
}

// Note: Traditional dessert functionality has been moved to lib/models/traditional_dessert_db.dart
