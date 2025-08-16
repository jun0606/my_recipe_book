/// 제품 스테이터스 생성 시스템
/// 레시피 분석 결과를 바탕으로 제품의 특성을 자동 생성합니다.

import '../services/baking_science_engine.dart';
import '../services/real_time_recipe_analyzer.dart';
import 'dart:math' as math;

class ProductStatusGenerator {
  /// 레시피 분석 결과로부터 제품 스테이터스 생성
  static ProductStatus generateStatus({
    required RecipeAnalysisResult analysisResult,
    required Map<String, dynamic> bakingContext,
    required Map<String, dynamic> environmentalConditions,
  }) {
    try {
      // 기본 특성 매핑
      final textureProfile = _mapHydrationToTexture(
        analysisResult.hydrationLevel,
        analysisResult.fatWeight,
        analysisResult.sugarWeight,
      );
      
      final flavorProfile = _mapIngredientsToFlavor(
        analysisResult.sugarWeight,
        analysisResult.fatWeight,
        analysisResult.saltPercentage,
        analysisResult.yeastPercentage,
      );
      
      final appearanceProfile = _mapBakingToAppearance(
        bakingContext,
        analysisResult.sugarWeight,
        analysisResult.hydrationLevel,
      );
      
      // 베이킹 사이언스 기반 고급 분석
      final maillardResult = _calculateMaillardReaction(
        bakingContext,
        analysisResult.sugarWeight,
        analysisResult.flourWeight,
        analysisResult.hydrationLevel,
      );
      
      final glutenResult = _calculateGlutenStrength(
        analysisResult.flourWeight,
        analysisResult.hydrationLevel,
        analysisResult.saltPercentage,
      );
      
      // 환경 조건 반영
      final environmentalAdjustments = _applyEnvironmentalFactors(
        environmentalConditions,
        textureProfile,
        flavorProfile,
        appearanceProfile,
      );
      
      return ProductStatus(
        // 기본 특성
        textureProfile: environmentalAdjustments['texture'] ?? textureProfile,
        flavorProfile: environmentalAdjustments['flavor'] ?? flavorProfile,
        appearanceProfile: environmentalAdjustments['appearance'] ?? appearanceProfile,
        
        // 과학적 분석 결과
        maillardIntensity: maillardResult.intensity,
        glutenStrength: glutenResult.strength,
        expectedCrustColor: maillardResult.estimatedColor,
        expectedTexture: glutenResult.expectedTexture,
        
        // 수치 데이터
        hydrationLevel: analysisResult.hydrationLevel,
        yeastActivity: analysisResult.yeastPercentage,
        saltBalance: analysisResult.saltPercentage,
        sugarContent: analysisResult.sugarWeight,
        
        // 베이킹 예측
        estimatedBakingType: analysisResult.estimatedBakingType,
        confidenceScore: analysisResult.confidenceScore,
        
        // 메타데이터
        generatedAt: DateTime.now(),
        analysisVersion: '2.0',
        environmentalFactors: environmentalConditions,
      );
    } catch (e) {
      print('제품 스테이터스 생성 중 오류: $e');
      return ProductStatus.empty();
    }
  }

  /// 수분율 → 식감 매핑
  static TextureProfile _mapHydrationToTexture(
    double hydration,
    double fatWeight,
    double sugarWeight,
  ) {
    // 기본 식감 결정
    String primaryTexture;
    String secondaryTexture;
    double moistureLevel;
    double chewiness;
    double softness;
    
    if (hydration >= 0.75) {
      // 고수분 (75% 이상)
      primaryTexture = "촉촉함";
      moistureLevel = 0.9;
      
      if (fatWeight > 50) {
        secondaryTexture = "부드럽고 폭신함";
        softness = 0.95;
        chewiness = 0.3;
      } else {
        secondaryTexture = "쫄깃함";
        softness = 0.7;
        chewiness = 0.8;
      }
    } else if (hydration >= 0.65) {
      // 표준 수분 (65-75%)
      primaryTexture = "적당한 촉촉함";
      moistureLevel = 0.7;
      
      if (sugarWeight > 30) {
        secondaryTexture = "부드러움";
        softness = 0.8;
        chewiness = 0.5;
      } else {
        secondaryTexture = "탄력있음";
        softness = 0.6;
        chewiness = 0.7;
      }
    } else if (hydration >= 0.55) {
      // 저수분 (55-65%)
      primaryTexture = "단단함";
      moistureLevel = 0.5;
      secondaryTexture = "조밀함";
      softness = 0.4;
      chewiness = 0.6;
    } else {
      // 매우 저수분 (55% 미만)
      primaryTexture = "바삭함";
      moistureLevel = 0.3;
      secondaryTexture = "건조함";
      softness = 0.2;
      chewiness = 0.2;
    }
    
    return TextureProfile(
      primary: primaryTexture,
      secondary: secondaryTexture,
      moistureLevel: moistureLevel,
      chewiness: chewiness,
      softness: softness,
      crispiness: hydration < 0.6 ? 0.8 : 0.2,
    );
  }

  /// 성분 → 풍미 매핑
  static FlavorProfile _mapIngredientsToFlavor(
    double sugarWeight,
    double fatWeight,
    double saltPercentage,
    double yeastPercentage,
  ) {
    List<String> primaryFlavors = [];
    List<String> secondaryFlavors = [];
    double sweetnessLevel = 0.0;
    double richnessLevel = 0.0;
    double saltinessLevel = 0.0;
    double umami = 0.0;
    
    // 단맛 분석
    if (sugarWeight > 50) {
      primaryFlavors.add("달콤함");
      sweetnessLevel = 0.9;
    } else if (sugarWeight > 20) {
      secondaryFlavors.add("은은한 단맛");
      sweetnessLevel = 0.5;
    }
    
    // 고소함/풍부함 분석
    if (fatWeight > 60) {
      primaryFlavors.add("진한 고소함");
      richnessLevel = 0.9;
    } else if (fatWeight > 30) {
      primaryFlavors.add("고소함");
      richnessLevel = 0.7;
    } else if (fatWeight > 10) {
      secondaryFlavors.add("담백함");
      richnessLevel = 0.3;
    }
    
    // 짠맛 분석
    if (saltPercentage > 0.02) {
      primaryFlavors.add("짭짤함");
      saltinessLevel = 0.8;
    } else if (saltPercentage > 0.015) {
      secondaryFlavors.add("적당한 간");
      saltinessLevel = 0.6;
    } else if (saltPercentage > 0.008) {
      secondaryFlavors.add("담백함");
      saltinessLevel = 0.3;
    }
    
    // 발효 풍미 분석
    if (yeastPercentage > 0.015) {
      secondaryFlavors.add("발효향");
      umami = 0.6;
    } else if (yeastPercentage > 0.005) {
      secondaryFlavors.add("은은한 발효향");
      umami = 0.3;
    }
    
    // 기본 풍미가 없는 경우
    if (primaryFlavors.isEmpty && secondaryFlavors.isEmpty) {
      primaryFlavors.add("심플하고 깔끔함");
    }
    
    return FlavorProfile(
      primary: primaryFlavors,
      secondary: secondaryFlavors,
      sweetnessLevel: sweetnessLevel,
      richnessLevel: richnessLevel,
      saltinessLevel: saltinessLevel,
      umami: umami,
      complexity: (primaryFlavors.length + secondaryFlavors.length) / 6.0,
    );
  }

  /// 베이킹 조건 → 외관 매핑
  static AppearanceProfile _mapBakingToAppearance(
    Map<String, dynamic> bakingContext,
    double sugarWeight,
    double hydrationLevel,
  ) {
    // 기본값 설정
    String crustColor = "연한 갈색";
    String crustTexture = "부드러운";
    double crustThickness = 0.3;
    double glossiness = 0.2;
    String overallAppearance = "자연스러운";
    
    // 베이킹 온도 분석
    final suggestedTemp = bakingContext['suggestedTemperature'] as int? ?? 180;
    
    if (suggestedTemp >= 220) {
      crustColor = "진한 갈색";
      crustTexture = "바삭한";
      crustThickness = 0.7;
    } else if (suggestedTemp >= 200) {
      crustColor = "황금색";
      crustTexture = "적당히 바삭한";
      crustThickness = 0.5;
    } else if (suggestedTemp >= 160) {
      crustColor = "연한 갈색";
      crustTexture = "부드러운";
      crustThickness = 0.3;
    } else {
      crustColor = "매우 연한 색";
      crustTexture = "부드러운";
      crustThickness = 0.2;
    }
    
    // 당분 영향
    if (sugarWeight > 50) {
      crustColor = _deepenColor(crustColor);
      glossiness = 0.8;
      overallAppearance = "윤기나는";
    } else if (sugarWeight > 20) {
      glossiness = 0.5;
    }
    
    // 수분율 영향
    if (hydrationLevel > 0.7) {
      crustTexture = "얇고 " + crustTexture;
      crustThickness *= 0.7;
    } else if (hydrationLevel < 0.6) {
      crustTexture = "두꺼운 " + crustTexture;
      crustThickness *= 1.3;
    }
    
    return AppearanceProfile(
      crustColor: crustColor,
      crustTexture: crustTexture,
      crustThickness: crustThickness,
      glossiness: glossiness,
      overallAppearance: overallAppearance,
      expectedHeight: _calculateExpectedHeight(hydrationLevel),
      porosity: _calculatePorosity(hydrationLevel),
    );
  }

  /// Maillard 반응 계산
  static MaillardReactionResult _calculateMaillardReaction(
    Map<String, dynamic> bakingContext,
    double sugarWeight,
    double flourWeight,
    double hydrationLevel,
  ) {
    final temperature = (bakingContext['suggestedTemperature'] as int? ?? 180).toDouble();
    final timeMinutes = (bakingContext['suggestedTimeMinutes'] as int? ?? 30).toDouble();
    final proteinContent = flourWeight * 0.125; // 강력분 기준 12.5% 단백질
    
    return BakingScienceEngine.calculateMaillardReaction(
      temperature: temperature,
      timeMinutes: timeMinutes,
      sugarContent: sugarWeight,
      proteinContent: proteinContent,
      moisture: hydrationLevel,
    );
  }

  /// 글루텐 강도 계산
  static GlutenStrengthResult _calculateGlutenStrength(
    double flourWeight,
    double hydrationLevel,
    double saltPercentage,
  ) {
    return BakingScienceEngine.predictGlutenStrength(
      flourType: "강력분", // 기본값
      hydration: hydrationLevel,
      kneadingTimeMinutes: 10.0, // 기본값
      saltPercentage: saltPercentage,
    );
  }

  /// 환경 요인 적용
  static Map<String, dynamic> _applyEnvironmentalFactors(
    Map<String, dynamic> environmentalConditions,
    TextureProfile textureProfile,
    FlavorProfile flavorProfile,
    AppearanceProfile appearanceProfile,
  ) {
    final adjustments = <String, dynamic>{};
    
    // 온도 영향
    final temperature = environmentalConditions['temperature'] as double? ?? 26.0;
    if (temperature > 30) {
      // 고온 환경: 발효 촉진, 수분 손실 증가
      adjustments['texture'] = textureProfile.copyWith(
        moistureLevel: math.max(textureProfile.moistureLevel - 0.1, 0.0),
      );
    } else if (temperature < 20) {
      // 저온 환경: 발효 지연, 수분 보존
      adjustments['texture'] = textureProfile.copyWith(
        moistureLevel: math.min(textureProfile.moistureLevel + 0.1, 1.0),
      );
    }
    
    // 습도 영향
    final humidity = environmentalConditions['humidity'] as double? ?? 60.0;
    if (humidity < 40) {
      // 저습도: 크러스트 빠른 형성
      adjustments['appearance'] = appearanceProfile.copyWith(
        crustThickness: appearanceProfile.crustThickness * 1.2,
      );
    } else if (humidity > 80) {
      // 고습도: 크러스트 형성 지연
      adjustments['appearance'] = appearanceProfile.copyWith(
        crustThickness: appearanceProfile.crustThickness * 0.8,
      );
    }
    
    // 고도 영향
    final altitude = environmentalConditions['altitude'] as double? ?? 0.0;
    if (altitude > 1000) {
      // 고지대: 수분 증발 증가, 발효 촉진
      adjustments['texture'] = textureProfile.copyWith(
        moistureLevel: math.max(textureProfile.moistureLevel - 0.15, 0.0),
        softness: math.max(textureProfile.softness - 0.1, 0.0),
      );
    }
    
    return adjustments;
  }

  /// 색상 진하게 만들기
  static String _deepenColor(String originalColor) {
    switch (originalColor) {
      case "매우 연한 색":
        return "연한 갈색";
      case "연한 갈색":
        return "황금색";
      case "황금색":
        return "진한 갈색";
      case "진한 갈색":
        return "매우 진한 갈색";
      default:
        return originalColor;
    }
  }

  /// 예상 높이 계산
  static double _calculateExpectedHeight(double hydrationLevel) {
    // 수분율이 높을수록 더 높이 부풀어 오름
    return 0.5 + (hydrationLevel * 0.5);
  }

  /// 기공 계산
  static double _calculatePorosity(double hydrationLevel) {
    // 수분율이 높을수록 더 많은 기공
    return math.min(hydrationLevel * 1.2, 1.0);
  }
}

/// 제품 스테이터스 클래스
class ProductStatus {
  final TextureProfile textureProfile;
  final FlavorProfile flavorProfile;
  final AppearanceProfile appearanceProfile;
  
  // 과학적 분석 결과
  final double maillardIntensity;
  final double glutenStrength;
  final String expectedCrustColor;
  final String expectedTexture;
  
  // 수치 데이터
  final double hydrationLevel;
  final double yeastActivity;
  final double saltBalance;
  final double sugarContent;
  
  // 베이킹 예측
  final String estimatedBakingType;
  final double confidenceScore;
  
  // 메타데이터
  final DateTime generatedAt;
  final String analysisVersion;
  final Map<String, dynamic> environmentalFactors;

  ProductStatus({
    required this.textureProfile,
    required this.flavorProfile,
    required this.appearanceProfile,
    required this.maillardIntensity,
    required this.glutenStrength,
    required this.expectedCrustColor,
    required this.expectedTexture,
    required this.hydrationLevel,
    required this.yeastActivity,
    required this.saltBalance,
    required this.sugarContent,
    required this.estimatedBakingType,
    required this.confidenceScore,
    required this.generatedAt,
    required this.analysisVersion,
    required this.environmentalFactors,
  });

  /// 빈 스테이터스 생성 (오류 시 사용)
  factory ProductStatus.empty() {
    return ProductStatus(
      textureProfile: TextureProfile.empty(),
      flavorProfile: FlavorProfile.empty(),
      appearanceProfile: AppearanceProfile.empty(),
      maillardIntensity: 0.0,
      glutenStrength: 0.0,
      expectedCrustColor: "알 수 없음",
      expectedTexture: "알 수 없음",
      hydrationLevel: 0.0,
      yeastActivity: 0.0,
      saltBalance: 0.0,
      sugarContent: 0.0,
      estimatedBakingType: "알 수 없음",
      confidenceScore: 0.0,
      generatedAt: DateTime.now(),
      analysisVersion: "2.0",
      environmentalFactors: {},
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'textureProfile': textureProfile.toJson(),
      'flavorProfile': flavorProfile.toJson(),
      'appearanceProfile': appearanceProfile.toJson(),
      'maillardIntensity': maillardIntensity,
      'glutenStrength': glutenStrength,
      'expectedCrustColor': expectedCrustColor,
      'expectedTexture': expectedTexture,
      'hydrationLevel': hydrationLevel,
      'yeastActivity': yeastActivity,
      'saltBalance': saltBalance,
      'sugarContent': sugarContent,
      'estimatedBakingType': estimatedBakingType,
      'confidenceScore': confidenceScore,
      'generatedAt': generatedAt.toIso8601String(),
      'analysisVersion': analysisVersion,
      'environmentalFactors': environmentalFactors,
    };
  }

  /// 요약 텍스트 생성
  String get summaryText {
    return "${textureProfile.primary}, ${flavorProfile.primary.join(', ')}, ${appearanceProfile.crustColor} 크러스트";
  }

  /// 상세 설명 생성
  String get detailedDescription {
    final buffer = StringBuffer();
    
    buffer.writeln("🤚 식감: ${textureProfile.primary}");
    if (textureProfile.secondary.isNotEmpty) {
      buffer.writeln("   └ ${textureProfile.secondary}");
    }
    
    buffer.writeln("👅 풍미: ${flavorProfile.primary.join(', ')}");
    if (flavorProfile.secondary.isNotEmpty) {
      buffer.writeln("   └ ${flavorProfile.secondary.join(', ')}");
    }
    
    buffer.writeln("👁️ 외관: ${appearanceProfile.crustTexture} ${appearanceProfile.crustColor} 크러스트");
    
    return buffer.toString();
  }
}

/// 식감 프로필
class TextureProfile {
  final String primary;
  final String secondary;
  final double moistureLevel; // 0-1
  final double chewiness; // 0-1
  final double softness; // 0-1
  final double crispiness; // 0-1

  TextureProfile({
    required this.primary,
    required this.secondary,
    required this.moistureLevel,
    required this.chewiness,
    required this.softness,
    required this.crispiness,
  });

  factory TextureProfile.empty() {
    return TextureProfile(
      primary: "알 수 없음",
      secondary: "",
      moistureLevel: 0.0,
      chewiness: 0.0,
      softness: 0.0,
      crispiness: 0.0,
    );
  }

  TextureProfile copyWith({
    String? primary,
    String? secondary,
    double? moistureLevel,
    double? chewiness,
    double? softness,
    double? crispiness,
  }) {
    return TextureProfile(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      moistureLevel: moistureLevel ?? this.moistureLevel,
      chewiness: chewiness ?? this.chewiness,
      softness: softness ?? this.softness,
      crispiness: crispiness ?? this.crispiness,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'moistureLevel': moistureLevel,
      'chewiness': chewiness,
      'softness': softness,
      'crispiness': crispiness,
    };
  }
}

/// 풍미 프로필
class FlavorProfile {
  final List<String> primary;
  final List<String> secondary;
  final double sweetnessLevel; // 0-1
  final double richnessLevel; // 0-1
  final double saltinessLevel; // 0-1
  final double umami; // 0-1
  final double complexity; // 0-1

  FlavorProfile({
    required this.primary,
    required this.secondary,
    required this.sweetnessLevel,
    required this.richnessLevel,
    required this.saltinessLevel,
    required this.umami,
    required this.complexity,
  });

  factory FlavorProfile.empty() {
    return FlavorProfile(
      primary: ["알 수 없음"],
      secondary: [],
      sweetnessLevel: 0.0,
      richnessLevel: 0.0,
      saltinessLevel: 0.0,
      umami: 0.0,
      complexity: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'sweetnessLevel': sweetnessLevel,
      'richnessLevel': richnessLevel,
      'saltinessLevel': saltinessLevel,
      'umami': umami,
      'complexity': complexity,
    };
  }
}

/// 외관 프로필
class AppearanceProfile {
  final String crustColor;
  final String crustTexture;
  final double crustThickness; // 0-1
  final double glossiness; // 0-1
  final String overallAppearance;
  final double expectedHeight; // 0-1
  final double porosity; // 0-1

  AppearanceProfile({
    required this.crustColor,
    required this.crustTexture,
    required this.crustThickness,
    required this.glossiness,
    required this.overallAppearance,
    required this.expectedHeight,
    required this.porosity,
  });

  factory AppearanceProfile.empty() {
    return AppearanceProfile(
      crustColor: "알 수 없음",
      crustTexture: "알 수 없음",
      crustThickness: 0.0,
      glossiness: 0.0,
      overallAppearance: "알 수 없음",
      expectedHeight: 0.0,
      porosity: 0.0,
    );
  }

  AppearanceProfile copyWith({
    String? crustColor,
    String? crustTexture,
    double? crustThickness,
    double? glossiness,
    String? overallAppearance,
    double? expectedHeight,
    double? porosity,
  }) {
    return AppearanceProfile(
      crustColor: crustColor ?? this.crustColor,
      crustTexture: crustTexture ?? this.crustTexture,
      crustThickness: crustThickness ?? this.crustThickness,
      glossiness: glossiness ?? this.glossiness,
      overallAppearance: overallAppearance ?? this.overallAppearance,
      expectedHeight: expectedHeight ?? this.expectedHeight,
      porosity: porosity ?? this.porosity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crustColor': crustColor,
      'crustTexture': crustTexture,
      'crustThickness': crustThickness,
      'glossiness': glossiness,
      'overallAppearance': overallAppearance,
      'expectedHeight': expectedHeight,
      'porosity': porosity,
    };
  }
}