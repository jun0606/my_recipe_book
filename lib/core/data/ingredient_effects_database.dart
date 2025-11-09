// lib/core/data/ingredient_effects_database.dart
// 재료 효과 데이터베이스 - 시럽/지방 타입별 특성 데이터 관리
// 빵 과학 기반의 정확한 효과 계수 제공

import '../../../core/types/ingredient_analysis_types.dart';

/// 시럽 효과 데이터
class SyrupEffectData {
  /// 시럽 타입 식별자
  final String syrupType;

  /// 시럽 이름 (한글)
  final String name;

  /// 글루텐 형성 영향 계수 (1.0 = 중립, <1.0 = 약화, >1.0 = 강화)
  final double glutenFormationImpact;

  /// 수분 조정 계수 (1.0 = 중립, <1.0 = 저수분화, >1.0 = 고수분화)
  final double hydrationAdjustment;

  /// 당분 효과 계수 (1.0 = 중립, >1.0 = 강화된 당분 효과)
  final double sugarEffect;

  /// 발효 속도 영향 (1.0 = 중립, <1.0 = 느림, >1.0 = 빠름)
  final double fermentationSpeedImpact;

  /// 굽기 특성 (갈변 정도, 1.0 = 표준)
  final double browningEffect;

  /// 점성 계수 (반죽 점성 영향, 1.0 = 표준)
  final double viscosityEffect;

  /// 최적 사용 비율 (%)
  final double optimalRatio;

  /// 사용 권장사항
  final List<String> recommendations;

  /// 과학적 근거
  final List<String> scientificBasis;

  const SyrupEffectData({
    required this.syrupType,
    required this.name,
    required this.glutenFormationImpact,
    required this.hydrationAdjustment,
    required this.sugarEffect,
    required this.fermentationSpeedImpact,
    required this.browningEffect,
    required this.viscosityEffect,
    required this.optimalRatio,
    required this.recommendations,
    required this.scientificBasis,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'syrupType': syrupType,
      'name': name,
      'glutenFormationImpact': glutenFormationImpact,
      'hydrationAdjustment': hydrationAdjustment,
      'sugarEffect': sugarEffect,
      'fermentationSpeedImpact': fermentationSpeedImpact,
      'browningEffect': browningEffect,
      'viscosityEffect': viscosityEffect,
      'optimalRatio': optimalRatio,
      'recommendations': recommendations,
      'scientificBasis': scientificBasis,
    };
  }

  /// JSON에서 생성
  factory SyrupEffectData.fromJson(Map<String, dynamic> json) {
    return SyrupEffectData(
      syrupType: json['syrupType'] as String,
      name: json['name'] as String,
      glutenFormationImpact: (json['glutenFormationImpact'] as num).toDouble(),
      hydrationAdjustment: (json['hydrationAdjustment'] as num).toDouble(),
      sugarEffect: (json['sugarEffect'] as num).toDouble(),
      fermentationSpeedImpact:
          (json['fermentationSpeedImpact'] as num).toDouble(),
      browningEffect: (json['browningEffect'] as num).toDouble(),
      viscosityEffect: (json['viscosityEffect'] as num).toDouble(),
      optimalRatio: (json['optimalRatio'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations'] as List),
      scientificBasis: List<String>.from(json['scientificBasis'] as List),
    );
  }

  @override
  String toString() {
    return 'SyrupEffectData($name: 글루텐=${glutenFormationImpact.toStringAsFixed(2)}, '
        '수분=${hydrationAdjustment.toStringAsFixed(2)}, '
        '당분=${sugarEffect.toStringAsFixed(2)})';
  }
}

/// 지방 효과 데이터
class FatEffectData {
  /// 지방 타입 식별자
  final String fatType;

  /// 지방 이름 (한글)
  final String name;

  /// 글루텐 형성 영향 계수 (1.0 = 중립, <1.0 = 약화, >1.0 = 강화)
  final double glutenFormationImpact;

  /// 수분 조정 계수 (1.0 = 중립, <1.0 = 저수분화, >1.0 = 고수분화)
  final double hydrationAdjustment;

  /// 지방 효과 계수 (1.0 = 중립, >1.0 = 강화된 지방 효과)
  final double fatEffect;

  /// 가소성 향상 계수 (1.0 = 표준)
  final double plasticityEnhancement;

  /// 연장성 영향 계수 (1.0 = 표준)
  final double extensibilityEffect;

  /// 가스 유지력 영향 (1.0 = 표준)
  final double gasRetentionEffect;

  /// 굽기 특성 (겉바속촉 정도, 1.0 = 표준)
  final double bakingEffect;

  /// 텍스처 영향 (부드러움 정도, 1.0 = 표준)
  final double textureEffect;

  /// 최적 사용 비율 (%)
  final double optimalRatio;

  /// 사용 권장사항
  final List<String> recommendations;

  /// 과학적 근거
  final List<String> scientificBasis;

  const FatEffectData({
    required this.fatType,
    required this.name,
    required this.glutenFormationImpact,
    required this.hydrationAdjustment,
    required this.fatEffect,
    required this.plasticityEnhancement,
    required this.extensibilityEffect,
    required this.gasRetentionEffect,
    required this.bakingEffect,
    required this.textureEffect,
    required this.optimalRatio,
    required this.recommendations,
    required this.scientificBasis,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'fatType': fatType,
      'name': name,
      'glutenFormationImpact': glutenFormationImpact,
      'hydrationAdjustment': hydrationAdjustment,
      'fatEffect': fatEffect,
      'plasticityEnhancement': plasticityEnhancement,
      'extensibilityEffect': extensibilityEffect,
      'gasRetentionEffect': gasRetentionEffect,
      'bakingEffect': bakingEffect,
      'textureEffect': textureEffect,
      'optimalRatio': optimalRatio,
      'recommendations': recommendations,
      'scientificBasis': scientificBasis,
    };
  }

  /// JSON에서 생성
  factory FatEffectData.fromJson(Map<String, dynamic> json) {
    return FatEffectData(
      fatType: json['fatType'] as String,
      name: json['name'] as String,
      glutenFormationImpact: (json['glutenFormationImpact'] as num).toDouble(),
      hydrationAdjustment: (json['hydrationAdjustment'] as num).toDouble(),
      fatEffect: (json['fatEffect'] as num).toDouble(),
      plasticityEnhancement: (json['plasticityEnhancement'] as num).toDouble(),
      extensibilityEffect: (json['extensibilityEffect'] as num).toDouble(),
      gasRetentionEffect: (json['gasRetentionEffect'] as num).toDouble(),
      bakingEffect: (json['bakingEffect'] as num).toDouble(),
      textureEffect: (json['textureEffect'] as num).toDouble(),
      optimalRatio: (json['optimalRatio'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations'] as List),
      scientificBasis: List<String>.from(json['scientificBasis'] as List),
    );
  }

  @override
  String toString() {
    return 'FatEffectData($name: 글루텐=${glutenFormationImpact.toStringAsFixed(2)}, '
        '수분=${hydrationAdjustment.toStringAsFixed(2)}, '
        '지방=${fatEffect.toStringAsFixed(2)})';
  }
}

/// 상호작용 효과 데이터
class InteractionEffectData {
  /// 상호작용 타입 식별자
  final String interactionType;

  /// 설명
  final String description;

  /// 관련 재료 타입들
  final List<String> relatedIngredients;

  /// 효과 강도 계수 (1.0 = 표준)
  final double effectStrength;

  /// 영향 받는 속성들
  final Map<String, double> affectedProperties;

  /// 권장사항
  final List<String> recommendations;

  /// 과학적 근거
  final List<String> scientificBasis;

  const InteractionEffectData({
    required this.interactionType,
    required this.description,
    required this.relatedIngredients,
    required this.effectStrength,
    required this.affectedProperties,
    required this.recommendations,
    required this.scientificBasis,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'interactionType': interactionType,
      'description': description,
      'relatedIngredients': relatedIngredients,
      'effectStrength': effectStrength,
      'affectedProperties': affectedProperties,
      'recommendations': recommendations,
      'scientificBasis': scientificBasis,
    };
  }

  /// JSON에서 생성
  factory InteractionEffectData.fromJson(Map<String, dynamic> json) {
    return InteractionEffectData(
      interactionType: json['interactionType'] as String,
      description: json['description'] as String,
      relatedIngredients: List<String>.from(json['relatedIngredients'] as List),
      effectStrength: (json['effectStrength'] as num).toDouble(),
      affectedProperties:
          Map<String, double>.from(json['affectedProperties'] as Map),
      recommendations: List<String>.from(json['recommendations'] as List),
      scientificBasis: List<String>.from(json['scientificBasis'] as List),
    );
  }
}

/// 재료 효과 데이터베이스
class IngredientEffectsDatabase {
  /// 싱글톤 인스턴스
  static IngredientEffectsDatabase? _instance;

  /// 시럽 효과 데이터 맵
  final Map<String, SyrupEffectData> _syrupEffects = {};

  /// 지방 효과 데이터 맵
  final Map<String, FatEffectData> _fatEffects = {};

  /// 상호작용 효과 데이터 맵
  final Map<String, InteractionEffectData> _interactionEffects = {};

  /// 데이터베이스 버전
  final String version = '1.0.0';

  /// 마지막 업데이트 날짜
  final DateTime lastUpdated = DateTime.now();

  /// 프라이빗 생성자
  IngredientEffectsDatabase._() {
    _initializeData();
  }

  /// 싱글톤 인스턴스 getter
  static IngredientEffectsDatabase get instance {
    _instance ??= IngredientEffectsDatabase._();
    return _instance!;
  }

  /// 데이터베이스 초기화
  void _initializeData() {
    _initializeSyrupEffects();
    _initializeFatEffects();
    _initializeInteractionEffects();
  }

  /// 시럽 효과 데이터 초기화
  void _initializeSyrupEffects() {
    // 물엿 (Corn Syrup)
    _syrupEffects['corn_syrup'] = const SyrupEffectData(
      syrupType: 'corn_syrup',
      name: '물엿',
      glutenFormationImpact: 0.85, // 글루텐 형성 약화
      hydrationAdjustment: 1.15, // 수분 증가
      sugarEffect: 1.2, // 당분 효과 강화
      fermentationSpeedImpact: 0.9, // 발효 속도 감소
      browningEffect: 1.1, // 갈변 증가
      viscosityEffect: 1.3, // 점성 증가
      optimalRatio: 8.0,
      recommendations: [
        '글루텐 형성이 약해지므로 믹싱 시간을 늘리세요',
        '수분 조절을 신경써서 반죽 상태를 확인하세요',
        '과도한 사용은 발효를 느리게 할 수 있습니다'
      ],
      scientificBasis: [
        '포도당과 과당의 높은 비율로 글루텐 네트워크 형성 방해',
        '높은 수분 함유로 반죽 수분 조정 필요',
        '삼투압 효과로 효모 활동 저하'
      ],
    );

    // 올리고당 (Oligo Syrup)
    _syrupEffects['oligo_syrup'] = const SyrupEffectData(
      syrupType: 'oligo_syrup',
      name: '올리고당',
      glutenFormationImpact: 0.9,
      hydrationAdjustment: 1.1,
      sugarEffect: 0.8,
      fermentationSpeedImpact: 0.7, // 발효 속도 크게 감소
      browningEffect: 0.9,
      viscosityEffect: 1.1,
      optimalRatio: 5.0,
      recommendations: [
        '장시간 발효에 적합한 재료입니다',
        '프리바이오틱스 효과로 건강빵에 유용',
        '단맛이 적어 설탕과 함께 사용하는 것을 고려하세요'
      ],
      scientificBasis: [
        '저분자 탄수화물로 효모 이용률 낮음',
        '프리바이오틱스 성분으로 장 건강에 도움',
        '천천히 발효되어 복합 풍미 형성'
      ],
    );

    // 메이플 시럽 (Maple Syrup)
    _syrupEffects['maple_syrup'] = const SyrupEffectData(
      syrupType: 'maple_syrup',
      name: '메이플 시럽',
      glutenFormationImpact: 0.95,
      hydrationAdjustment: 1.05,
      sugarEffect: 1.1,
      fermentationSpeedImpact: 1.0,
      browningEffect: 1.2, // 강한 갈변 효과
      viscosityEffect: 1.0,
      optimalRatio: 10.0,
      recommendations: [
        '메이플의 독특한 풍미를 살릴 수 있는 레시피에 적합',
        '갈변이 강하므로 굽기 시간을 조절하세요',
        '고급 빵이나 디저트 빵에 사용하세요'
      ],
      scientificBasis: [
        '자연 감미료로 글루텐 형성에 미미한 영향',
        '카르멜화 성분으로 갈변 효과 우수',
        '항산화 물질 함유로 영양학적 가치 높음'
      ],
    );

    // 꿀 (Honey)
    _syrupEffects['honey'] = const SyrupEffectData(
      syrupType: 'honey',
      name: '꿀',
      glutenFormationImpact: 0.88,
      hydrationAdjustment: 0.95, // 수분 흡수 효과
      sugarEffect: 1.3,
      fermentationSpeedImpact: 1.2, // 발효 속도 증가
      browningEffect: 1.15,
      viscosityEffect: 0.9,
      optimalRatio: 8.0,
      recommendations: [
        '항균 효과로 발효 안정성 향상',
        '수분 흡수로 반죽이 건조해질 수 있음',
        '꿀의 풍미를 살리는 레시피에 사용하세요'
      ],
      scientificBasis: [
        '과당 함량 높아 글루텐 형성 방해',
        '항균 성분으로 잡균 번식 억제',
        '효모 영양분으로 발효 촉진'
      ],
    );

    // 아가베 시럽 (Agave Syrup)
    _syrupEffects['agave_syrup'] = const SyrupEffectData(
      syrupType: 'agave_syrup',
      name: '아가베 시럽',
      glutenFormationImpact: 0.92,
      hydrationAdjustment: 1.08,
      sugarEffect: 1.1,
      fermentationSpeedImpact: 1.1,
      browningEffect: 0.95,
      viscosityEffect: 1.0,
      optimalRatio: 7.0,
      recommendations: [
        '저혈당 지수로 건강빵에 적합',
        '점성이 낮아 반죽 혼합이 용이',
        '메스칼 풍미로 독특한 빵 만들기 가능'
      ],
      scientificBasis: [
        '프룩토스 함량 높아 글루텐 형성 영향 적음',
        '저혈당 지수로 혈당 관리에 도움',
        '메스칼 식물에서 추출된 천연 감미료'
      ],
    );
  }

  /// 지방 효과 데이터 초기화
  void _initializeFatEffects() {
    // 버터 (Butter)
    _fatEffects['butter'] = const FatEffectData(
      fatType: 'butter',
      name: '버터',
      glutenFormationImpact: 0.9, // 글루텐 형성 약화
      hydrationAdjustment: 0.95, // 수분 감소 효과
      fatEffect: 1.4,
      plasticityEnhancement: 1.3,
      extensibilityEffect: 1.2,
      gasRetentionEffect: 1.1,
      bakingEffect: 1.2,
      textureEffect: 1.4, // 부드러운 텍스처
      optimalRatio: 15.0,
      recommendations: [
        '겉바속촉 효과로 케이크나 쿠키에 적합',
        '글루텐 형성이 약해지므로 믹싱 시간을 늘리세요',
        '냉장 보관 시 더 좋은 효과 발휘'
      ],
      scientificBasis: [
        '유단백질로 글루텐 네트워크 형성 방해',
        '단단한 지방으로 가소성 향상',
        '수분 감소로 반죽 안정성 증가'
      ],
    );

    // 올리브 오일 (Olive Oil)
    _fatEffects['olive_oil'] = const FatEffectData(
      fatType: 'olive_oil',
      name: '올리브 오일',
      glutenFormationImpact: 0.85,
      hydrationAdjustment: 0.9,
      fatEffect: 1.2,
      plasticityEnhancement: 1.1,
      extensibilityEffect: 1.3,
      gasRetentionEffect: 0.95,
      bakingEffect: 1.0,
      textureEffect: 1.1,
      optimalRatio: 8.0,
      recommendations: [
        '지중해 스타일 빵에 적합',
        '건강한 지방으로 영양학적 가치 높음',
        '연성 향상으로 반죽 다루기 쉬워짐'
      ],
      scientificBasis: [
        '불포화 지방산으로 글루텐 형성 방해',
        '항산화 성분으로 빵 보관성 향상',
        '유연성 증가로 반죽 가공성 개선'
      ],
    );

    // 코코넛 오일 (Coconut Oil)
    _fatEffects['coconut_oil'] = const FatEffectData(
      fatType: 'coconut_oil',
      name: '코코넛 오일',
      glutenFormationImpact: 0.88,
      hydrationAdjustment: 0.92,
      fatEffect: 1.3,
      plasticityEnhancement: 1.2,
      extensibilityEffect: 1.1,
      gasRetentionEffect: 1.0,
      bakingEffect: 1.1,
      textureEffect: 1.2,
      optimalRatio: 10.0,
      recommendations: [
        '열대 풍미의 빵 만들기에 적합',
        '고체상태에서 액체상태로 변하는 특성 활용',
        '글루텐 프리 빵에 좋은 대안'
      ],
      scientificBasis: [
        '중쇄 지방산으로 소화 흡수가 용이',
        '항균 성분으로 빵 보관성 향상',
        '특이한 풍미로 독특한 빵 개발 가능'
      ],
    );

    // 라드 (Lard)
    _fatEffects['lard'] = const FatEffectData(
      fatType: 'lard',
      name: '라드',
      glutenFormationImpact: 0.87,
      hydrationAdjustment: 0.93,
      fatEffect: 1.5,
      plasticityEnhancement: 1.4,
      extensibilityEffect: 1.1,
      gasRetentionEffect: 1.2,
      bakingEffect: 1.3,
      textureEffect: 1.5,
      optimalRatio: 12.0,
      recommendations: [
        '전통적인 빵 굽기에 적합',
        '높은 가스 유지력으로 부풀음 효과 우수',
        '겉바속촉 텍스처에 탁월'
      ],
      scientificBasis: [
        '포화 지방산으로 안정성 높음',
        '높은 melting point로 굽기 특성 우수',
        '전통 제빙 방식에서 사용되던 재료'
      ],
    );

    // 마가린 (Margarine)
    _fatEffects['margarine'] = const FatEffectData(
      fatType: 'margarine',
      name: '마가린',
      glutenFormationImpact: 0.92,
      hydrationAdjustment: 0.97,
      fatEffect: 1.1,
      plasticityEnhancement: 1.0,
      extensibilityEffect: 1.1,
      gasRetentionEffect: 1.0,
      bakingEffect: 1.0,
      textureEffect: 1.0,
      optimalRatio: 20.0,
      recommendations: [
        '저비용으로 버터 대체 가능',
        '글루텐 형성 영향이 적어 다양한 빵에 사용',
        '균일한 품질로 산업용에 적합'
      ],
      scientificBasis: [
        '식물성 오일 기반으로 글루텐 영향 적음',
        '유화제 첨가로 안정성 높음',
        '비용 효율성으로 대량 생산에 유리'
      ],
    );
  }

  /// 상호작용 효과 데이터 초기화
  void _initializeInteractionEffects() {
    // 버터 + 밀가루 상호작용
    _interactionEffects['butter_flour'] = const InteractionEffectData(
      interactionType: 'butter_flour',
      description: '버터와 밀가루의 상호작용',
      relatedIngredients: ['butter', 'flour'],
      effectStrength: 1.2,
      affectedProperties: {
        'glutenFormationImpact': 0.9,
        'plasticityEnhancement': 1.3,
        'textureEffect': 1.2,
      },
      recommendations: [
        '버터의 지방이 글루텐 형성을 방해하므로 믹싱 시간을 늘리세요',
        '버터의 가소성 향상 효과를 활용하여 반죽 다루기를 쉽게 하세요',
        '냉장 상태에서 믹싱하면 더 좋은 효과를 얻을 수 있습니다'
      ],
      scientificBasis: [
        '지방의 코팅 효과로 글루텐 단백질 결합 방해',
        '지방의 연화 효과로 반죽 가공성 향상',
        '유단백질의 수분 조절로 반죽 안정성 증가'
      ],
    );

    // 꿀 + 효모 상호작용
    _interactionEffects['honey_yeast'] = const InteractionEffectData(
      interactionType: 'honey_yeast',
      description: '꿀과 효모의 상호작용',
      relatedIngredients: ['honey', 'yeast'],
      effectStrength: 1.3,
      affectedProperties: {
        'fermentationSpeedImpact': 1.2,
        'glutenFormationImpact': 0.88,
        'sugarEffect': 1.3,
      },
      recommendations: [
        '꿀의 항균 효과로 발효 안정성이 향상됩니다',
        '효모 영양분 공급으로 발효 속도가 빨라집니다',
        '글루텐 형성이 약해지므로 믹싱 시간을 조정하세요'
      ],
      scientificBasis: [
        '꿀의 천연 항생물질로 잡균 억제',
        '단순당 공급으로 효모 증식 촉진',
        '과당 과다로 글루텐 형성 방해'
      ],
    );

    // 올리브 오일 + 물 상호작용
    _interactionEffects['olive_oil_water'] = const InteractionEffectData(
      interactionType: 'olive_oil_water',
      description: '올리브 오일과 물의 상호작용',
      relatedIngredients: ['olive_oil', 'water'],
      effectStrength: 1.1,
      affectedProperties: {
        'hydrationAdjustment': 1.05,
        'extensibilityEffect': 1.2,
        'textureEffect': 1.1,
      },
      recommendations: [
        '올리브 오일의 유화 효과로 반죽이 부드러워집니다',
        '수분 흡수가 용이하여 반죽 상태 조절이 쉽습니다',
        '지중해 스타일 빵에 특히 효과적입니다'
      ],
      scientificBasis: [
        '불포화 지방산의 유화제로 수분 결합 향상',
        '지방의 윤활 효과로 연성 증가',
        '페놀 화합물로 산화 안정성 향상'
      ],
    );

    // 물엿 + 소금 상호작용
    _interactionEffects['corn_syrup_salt'] = const InteractionEffectData(
      interactionType: 'corn_syrup_salt',
      description: '물엿과 소금의 상호작용',
      relatedIngredients: ['corn_syrup', 'salt'],
      effectStrength: 0.9,
      affectedProperties: {
        'fermentationSpeedImpact': 0.8,
        'glutenFormationImpact': 0.85,
        'viscosityEffect': 1.2,
      },
      recommendations: [
        '물엿의 삼투압 효과로 발효가 느려질 수 있습니다',
        '소금과 함께 사용할 때는 발효 시간을 늘리세요',
        '점성이 높아져 반죽 다루기가 어려울 수 있습니다'
      ],
      scientificBasis: [
        '고농도 용액으로 효모 활동 저하',
        '점성 증가로 글루텐 네트워크 형성 방해',
        '삼투압 균형으로 반죽 안정성 변화'
      ],
    );
  }

  /// 시럽 효과 데이터 조회
  SyrupEffectData? getSyrupEffect(String syrupType) {
    return _syrupEffects[syrupType];
  }

  /// 지방 효과 데이터 조회
  FatEffectData? getFatEffect(String fatType) {
    return _fatEffects[fatType];
  }

  /// 상호작용 효과 데이터 조회
  InteractionEffectData? getInteractionEffect(String interactionType) {
    return _interactionEffects[interactionType];
  }

  /// 모든 시럽 효과 데이터 조회
  Map<String, SyrupEffectData> getAllSyrupEffects() {
    return Map.unmodifiable(_syrupEffects);
  }

  /// 모든 지방 효과 데이터 조회
  Map<String, FatEffectData> getAllFatEffects() {
    return Map.unmodifiable(_fatEffects);
  }

  /// 모든 상호작용 효과 데이터 조회
  Map<String, InteractionEffectData> getAllInteractionEffects() {
    return Map.unmodifiable(_interactionEffects);
  }

  /// 시럽 타입 존재 여부 확인
  bool hasSyrupEffect(String syrupType) {
    return _syrupEffects.containsKey(syrupType);
  }

  /// 지방 타입 존재 여부 확인
  bool hasFatEffect(String fatType) {
    return _fatEffects.containsKey(fatType);
  }

  /// 상호작용 타입 존재 여부 확인
  bool hasInteractionEffect(String interactionType) {
    return _interactionEffects.containsKey(interactionType);
  }

  /// 시럽 효과 데이터 추가 (런타임 확장용)
  void addSyrupEffect(SyrupEffectData effectData) {
    _syrupEffects[effectData.syrupType] = effectData;
  }

  /// 지방 효과 데이터 추가 (런타임 확장용)
  void addFatEffect(FatEffectData effectData) {
    _fatEffects[effectData.fatType] = effectData;
  }

  /// 상호작용 효과 데이터 추가 (런타임 확장용)
  void addInteractionEffect(InteractionEffectData effectData) {
    _interactionEffects[effectData.interactionType] = effectData;
  }

  /// 데이터베이스 통계 정보
  Map<String, dynamic> getStatistics() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'syrupEffectsCount': _syrupEffects.length,
      'fatEffectsCount': _fatEffects.length,
      'interactionEffectsCount': _interactionEffects.length,
      'totalEffectsCount': _syrupEffects.length +
          _fatEffects.length +
          _interactionEffects.length,
    };
  }

  /// 데이터베이스 검증
  bool validate() {
    // 필수 시럽 타입 확인
    final requiredSyrups = ['corn_syrup', 'honey', 'maple_syrup'];
    for (final syrup in requiredSyrups) {
      if (!hasSyrupEffect(syrup)) {
        return false;
      }
    }

    // 필수 지방 타입 확인
    final requiredFats = ['butter', 'olive_oil'];
    for (final fat in requiredFats) {
      if (!hasFatEffect(fat)) {
        return false;
      }
    }

    return true;
  }

  /// JSON으로 전체 데이터베이스 내보내기
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'syrupEffects': _syrupEffects.map((k, v) => MapEntry(k, v.toJson())),
      'fatEffects': _fatEffects.map((k, v) => MapEntry(k, v.toJson())),
      'interactionEffects':
          _interactionEffects.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  @override
  String toString() {
    return 'IngredientEffectsDatabase(v$version, '
        '시럽:${_syrupEffects.length}개, '
        '지방:${_fatEffects.length}개, '
        '상호작용:${_interactionEffects.length}개)';
  }
}

/// 재료 효과 데이터베이스 헬퍼 클래스
class IngredientEffectsHelper {
  /// 시럽 타입별 추천 비율 범위 계산
  static Map<String, double> getRecommendedSyrupRatio(String syrupType) {
    final database = IngredientEffectsDatabase.instance;
    final effectData = database.getSyrupEffect(syrupType);

    if (effectData == null) {
      return {'min': 0.0, 'max': 10.0, 'optimal': 5.0};
    }

    final optimal = effectData.optimalRatio;
    final min = optimal * 0.5; // 최적의 50%
    final max = optimal * 1.5; // 최적의 150%

    return {
      'min': min.clamp(0.0, 20.0),
      'max': max.clamp(0.0, 20.0),
      'optimal': optimal,
    };
  }

  /// 지방 타입별 추천 비율 범위 계산
  static Map<String, double> getRecommendedFatRatio(String fatType) {
    final database = IngredientEffectsDatabase.instance;
    final effectData = database.getFatEffect(fatType);

    if (effectData == null) {
      return {'min': 0.0, 'max': 15.0, 'optimal': 7.5};
    }

    final optimal = effectData.optimalRatio;
    final min = optimal * 0.5; // 최적의 50%
    final max = optimal * 1.5; // 최적의 150%

    return {
      'min': min.clamp(0.0, 30.0),
      'max': max.clamp(0.0, 30.0),
      'optimal': optimal,
    };
  }

  /// 재료 조합 호환성 점수 계산
  static double calculateCompatibilityScore(List<String> ingredients) {
    final database = IngredientEffectsDatabase.instance;
    double totalScore = 0.0;
    int interactionCount = 0;

    // 모든 재료 쌍에 대한 상호작용 확인
    for (int i = 0; i < ingredients.length; i++) {
      for (int j = i + 1; j < ingredients.length; j++) {
        final ingredient1 = ingredients[i];
        final ingredient2 = ingredients[j];

        // 상호작용 타입 생성 (알파벳 순서로 정렬)
        final sortedIngredients = [ingredient1, ingredient2]..sort();
        final interactionType =
            '${sortedIngredients[0]}_${sortedIngredients[1]}';

        final interactionEffect =
            database.getInteractionEffect(interactionType);
        if (interactionEffect != null) {
          totalScore += interactionEffect.effectStrength;
          interactionCount++;
        }
      }
    }

    // 상호작용이 없는 경우 기본 호환성 점수 반환
    if (interactionCount == 0) {
      return 1.0;
    }

    // 평균 호환성 점수 계산
    return totalScore / interactionCount;
  }

  /// 최적 재료 조합 추천
  static List<String> suggestOptimalCombinations(String primaryIngredient) {
    final database = IngredientEffectsDatabase.instance;
    final recommendations = <String>[];

    // 시럽과의 상호작용 확인
    if (database.hasSyrupEffect(primaryIngredient)) {
      recommendations.addAll(['yeast', 'flour', 'salt']); // 일반적인 빵 재료
    }

    // 지방과의 상호작용 확인
    if (database.hasFatEffect(primaryIngredient)) {
      recommendations.addAll(['flour', 'sugar', 'eggs']); // 베이킹 재료
    }

    return recommendations;
  }
}
