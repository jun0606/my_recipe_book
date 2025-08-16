/// 레시피 개발 목표 특성 모델
/// 사용자가 원하는 제품 특성을 정의합니다.

import '../services/product_status_generator.dart';

class RecipeTarget {
  // 식감 목표 (0.0 ~ 1.0)
  final double moistureTarget; // 촉촉함
  final double chewinessTarget; // 쫄깃함
  final double softnessTarget; // 부드러움
  final double crispinessTarget; // 바삭함
  
  // 풍미 목표 (0.0 ~ 1.0)
  final double sweetnessTarget; // 단맛
  final double richnessTarget; // 고소함/풍부함
  final double saltinessTarget; // 짠맛
  final double umamiTarget; // 감칠맛
  
  // 외관 목표
  final CrustColorTarget crustColorTarget; // 크러스트 색상
  final double heightTarget; // 높이 (0.0 ~ 1.0)
  final double porosityTarget; // 기공 (0.0 ~ 1.0)
  
  // 베이킹 타입 목표
  final String targetBakingType; // 목표 베이킹 타입
  
  // 제약 조건
  final List<String> allergenRestrictions; // 알레르기 제한
  final List<String> availableIngredients; // 사용 가능한 재료
  final Map<String, double> ingredientLimits; // 재료별 최대/최소 제한
  
  // 우선순위 (어떤 특성이 가장 중요한지)
  final Map<String, double> priorityWeights;

  const RecipeTarget({
    this.moistureTarget = 0.5,
    this.chewinessTarget = 0.5,
    this.softnessTarget = 0.5,
    this.crispinessTarget = 0.0,
    this.sweetnessTarget = 0.3,
    this.richnessTarget = 0.4,
    this.saltinessTarget = 0.2,
    this.umamiTarget = 0.1,
    this.crustColorTarget = CrustColorTarget.golden,
    this.heightTarget = 0.7,
    this.porosityTarget = 0.6,
    this.targetBakingType = '식빵',
    this.allergenRestrictions = const [],
    this.availableIngredients = const [],
    this.ingredientLimits = const {},
    this.priorityWeights = const {
      'texture': 1.0,
      'flavor': 0.8,
      'appearance': 0.6,
    },
  });

  /// 기본 식빵 목표
  factory RecipeTarget.basicBread() {
    return const RecipeTarget(
      moistureTarget: 0.7,
      chewinessTarget: 0.6,
      softnessTarget: 0.8,
      crispinessTarget: 0.2,
      sweetnessTarget: 0.2,
      richnessTarget: 0.5,
      saltinessTarget: 0.3,
      targetBakingType: '기본 식빵',
    );
  }

  /// 촉촉한 식빵 목표
  factory RecipeTarget.moistBread() {
    return const RecipeTarget(
      moistureTarget: 0.9,
      chewinessTarget: 0.4,
      softnessTarget: 0.9,
      crispinessTarget: 0.1,
      sweetnessTarget: 0.3,
      richnessTarget: 0.7,
      saltinessTarget: 0.2,
      targetBakingType: '촉촉한 식빵',
    );
  }

  /// 쫄깃한 식빵 목표
  factory RecipeTarget.chewyBread() {
    return const RecipeTarget(
      moistureTarget: 0.6,
      chewinessTarget: 0.9,
      softnessTarget: 0.5,
      crispinessTarget: 0.2,
      sweetnessTarget: 0.2,
      richnessTarget: 0.4,
      saltinessTarget: 0.4,
      targetBakingType: '쫄깃한 식빵',
    );
  }

  /// 바삭한 크러스트 빵 목표
  factory RecipeTarget.crispyBread() {
    return const RecipeTarget(
      moistureTarget: 0.4,
      chewinessTarget: 0.7,
      softnessTarget: 0.3,
      crispinessTarget: 0.9,
      sweetnessTarget: 0.1,
      richnessTarget: 0.3,
      saltinessTarget: 0.5,
      crustColorTarget: CrustColorTarget.darkBrown,
      targetBakingType: '바삭한 크러스트 빵',
    );
  }

  /// 단빵/브리오슈 목표
  factory RecipeTarget.sweetBread() {
    return const RecipeTarget(
      moistureTarget: 0.8,
      chewinessTarget: 0.3,
      softnessTarget: 0.9,
      crispinessTarget: 0.1,
      sweetnessTarget: 0.8,
      richnessTarget: 0.9,
      saltinessTarget: 0.1,
      crustColorTarget: CrustColorTarget.golden,
      targetBakingType: '단빵/브리오슈',
    );
  }

  /// 복사본 생성
  RecipeTarget copyWith({
    double? moistureTarget,
    double? chewinessTarget,
    double? softnessTarget,
    double? crispinessTarget,
    double? sweetnessTarget,
    double? richnessTarget,
    double? saltinessTarget,
    double? umamiTarget,
    CrustColorTarget? crustColorTarget,
    double? heightTarget,
    double? porosityTarget,
    String? targetBakingType,
    List<String>? allergenRestrictions,
    List<String>? availableIngredients,
    Map<String, double>? ingredientLimits,
    Map<String, double>? priorityWeights,
  }) {
    return RecipeTarget(
      moistureTarget: moistureTarget ?? this.moistureTarget,
      chewinessTarget: chewinessTarget ?? this.chewinessTarget,
      softnessTarget: softnessTarget ?? this.softnessTarget,
      crispinessTarget: crispinessTarget ?? this.crispinessTarget,
      sweetnessTarget: sweetnessTarget ?? this.sweetnessTarget,
      richnessTarget: richnessTarget ?? this.richnessTarget,
      saltinessTarget: saltinessTarget ?? this.saltinessTarget,
      umamiTarget: umamiTarget ?? this.umamiTarget,
      crustColorTarget: crustColorTarget ?? this.crustColorTarget,
      heightTarget: heightTarget ?? this.heightTarget,
      porosityTarget: porosityTarget ?? this.porosityTarget,
      targetBakingType: targetBakingType ?? this.targetBakingType,
      allergenRestrictions: allergenRestrictions ?? this.allergenRestrictions,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      ingredientLimits: ingredientLimits ?? this.ingredientLimits,
      priorityWeights: priorityWeights ?? this.priorityWeights,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'moistureTarget': moistureTarget,
      'chewinessTarget': chewinessTarget,
      'softnessTarget': softnessTarget,
      'crispinessTarget': crispinessTarget,
      'sweetnessTarget': sweetnessTarget,
      'richnessTarget': richnessTarget,
      'saltinessTarget': saltinessTarget,
      'umamiTarget': umamiTarget,
      'crustColorTarget': crustColorTarget.name,
      'heightTarget': heightTarget,
      'porosityTarget': porosityTarget,
      'targetBakingType': targetBakingType,
      'allergenRestrictions': allergenRestrictions,
      'availableIngredients': availableIngredients,
      'ingredientLimits': ingredientLimits,
      'priorityWeights': priorityWeights,
    };
  }

  /// JSON에서 생성
  factory RecipeTarget.fromJson(Map<String, dynamic> json) {
    return RecipeTarget(
      moistureTarget: json['moistureTarget']?.toDouble() ?? 0.5,
      chewinessTarget: json['chewinessTarget']?.toDouble() ?? 0.5,
      softnessTarget: json['softnessTarget']?.toDouble() ?? 0.5,
      crispinessTarget: json['crispinessTarget']?.toDouble() ?? 0.0,
      sweetnessTarget: json['sweetnessTarget']?.toDouble() ?? 0.3,
      richnessTarget: json['richnessTarget']?.toDouble() ?? 0.4,
      saltinessTarget: json['saltinessTarget']?.toDouble() ?? 0.2,
      umamiTarget: json['umamiTarget']?.toDouble() ?? 0.1,
      crustColorTarget: CrustColorTarget.values.firstWhere(
        (e) => e.name == json['crustColorTarget'],
        orElse: () => CrustColorTarget.golden,
      ),
      heightTarget: json['heightTarget']?.toDouble() ?? 0.7,
      porosityTarget: json['porosityTarget']?.toDouble() ?? 0.6,
      targetBakingType: json['targetBakingType'] ?? '식빵',
      allergenRestrictions: List<String>.from(json['allergenRestrictions'] ?? []),
      availableIngredients: List<String>.from(json['availableIngredients'] ?? []),
      ingredientLimits: Map<String, double>.from(json['ingredientLimits'] ?? {}),
      priorityWeights: Map<String, double>.from(json['priorityWeights'] ?? {
        'texture': 1.0,
        'flavor': 0.8,
        'appearance': 0.6,
      }),
    );
  }

  /// 목표 요약 텍스트
  String get summaryText {
    List<String> characteristics = [];
    
    if (moistureTarget > 0.7) characteristics.add('촉촉한');
    if (chewinessTarget > 0.7) characteristics.add('쫄깃한');
    if (softnessTarget > 0.7) characteristics.add('부드러운');
    if (crispinessTarget > 0.7) characteristics.add('바삭한');
    if (sweetnessTarget > 0.6) characteristics.add('달콤한');
    if (richnessTarget > 0.7) characteristics.add('고소한');
    
    if (characteristics.isEmpty) {
      characteristics.add('기본적인');
    }
    
    return '${characteristics.join(', ')} $targetBakingType';
  }

  /// 목표 달성도 계산 (현재 상태와 비교)
  double calculateAchievementScore(ProductStatus currentStatus) {
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    // 식감 점수 계산
    final textureWeight = priorityWeights['texture'] ?? 1.0;
    double textureScore = 0.0;
    
    textureScore += (1.0 - (moistureTarget - currentStatus.textureProfile.moistureLevel).abs()) * 0.25;
    textureScore += (1.0 - (chewinessTarget - currentStatus.textureProfile.chewiness).abs()) * 0.25;
    textureScore += (1.0 - (softnessTarget - currentStatus.textureProfile.softness).abs()) * 0.25;
    textureScore += (1.0 - (crispinessTarget - currentStatus.textureProfile.crispiness).abs()) * 0.25;
    
    totalScore += textureScore * textureWeight;
    totalWeight += textureWeight;
    
    // 풍미 점수 계산
    final flavorWeight = priorityWeights['flavor'] ?? 0.8;
    double flavorScore = 0.0;
    
    flavorScore += (1.0 - (sweetnessTarget - currentStatus.flavorProfile.sweetnessLevel).abs()) * 0.25;
    flavorScore += (1.0 - (richnessTarget - currentStatus.flavorProfile.richnessLevel).abs()) * 0.25;
    flavorScore += (1.0 - (saltinessTarget - currentStatus.flavorProfile.saltinessLevel).abs()) * 0.25;
    flavorScore += (1.0 - (umamiTarget - currentStatus.flavorProfile.umami).abs()) * 0.25;
    
    totalScore += flavorScore * flavorWeight;
    totalWeight += flavorWeight;
    
    // 외관 점수 계산
    final appearanceWeight = priorityWeights['appearance'] ?? 0.6;
    double appearanceScore = 0.0;
    
    appearanceScore += (1.0 - (heightTarget - currentStatus.appearanceProfile.expectedHeight).abs()) * 0.5;
    appearanceScore += (1.0 - (porosityTarget - currentStatus.appearanceProfile.porosity).abs()) * 0.5;
    
    totalScore += appearanceScore * appearanceWeight;
    totalWeight += appearanceWeight;
    
    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }
}

/// 크러스트 색상 목표
enum CrustColorTarget {
  pale('연한 색'),
  lightBrown('연한 갈색'),
  golden('황금색'),
  darkBrown('진한 갈색'),
  veryDark('매우 진한 색');

  const CrustColorTarget(this.displayName);
  final String displayName;
}

/// 생성된 레시피 결과
class GeneratedRecipeResult {
  final List<Map<String, dynamic>> optimizedIngredients; // 최적화된 재료
  final RecipeTarget originalTarget; // 원래 목표
  final ProductStatus predictedStatus; // 예측된 결과
  final double achievementScore; // 목표 달성도 (0-1)
  final List<String> optimizationNotes; // 최적화 노트
  final Map<String, dynamic> bakersPercentages; // 베이커스 퍼센트
  final DateTime generatedAt; // 생성 시간

  const GeneratedRecipeResult({
    required this.optimizedIngredients,
    required this.originalTarget,
    required this.predictedStatus,
    required this.achievementScore,
    required this.optimizationNotes,
    required this.bakersPercentages,
    required this.generatedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'optimizedIngredients': optimizedIngredients,
      'originalTarget': originalTarget.toJson(),
      'predictedStatus': predictedStatus.toJson(),
      'achievementScore': achievementScore,
      'optimizationNotes': optimizationNotes,
      'bakersPercentages': bakersPercentages,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// 달성도 텍스트
  String get achievementText {
    if (achievementScore >= 0.9) return '매우 우수';
    if (achievementScore >= 0.8) return '우수';
    if (achievementScore >= 0.7) return '양호';
    if (achievementScore >= 0.6) return '보통';
    if (achievementScore >= 0.5) return '개선 필요';
    return '크게 개선 필요';
  }

  /// 달성도 색상
  String get achievementColor {
    if (achievementScore >= 0.8) return 'green';
    if (achievementScore >= 0.6) return 'orange';
    return 'red';
  }
}