# 🥖 도우 타입별 분석 체계 상세 설계

## 📋 목차
1. 도우 타입 분류 체계
2. 각 도우 타입별 특성 분석
3. 도우 타입 감지 알고리즘
4. 도우 타입별 최적 조건 데이터베이스
5. 동적 분석 파라미터 조정
6. 사용자 맞춤 분석 결과 생성

## 1. 도우 타입 분류 체계

### 1.1 주요 분류 기준
- **재료 구성**: 밀가루 타입, 지방 함량, 설탕 함량, 이스트 타입
- **제조 방법**: 믹싱 방식, 발효 방식, 굽기 방식
- **최종 제품 특성**: 식감, 향, 보관 기간, 수분 함량

### 1.2 도우 타입 계층 구조
```
도우 타입 (Dough Type)
├── 기본 도우 (Base Doughs)
│   ├── 린 도우 (Lean Dough) - 기본 빵
│   ├── 리치 도우 (Rich Dough) - 버터/계란/설탕 함유
│   └── 전통 도우 (Traditional Doughs)
│       ├── 사워도우 (Sourdough) - 사워스타터 사용
│       └── 통밀 도우 (Whole Wheat) - 통밀가루 사용
├── 특수 도우 (Special Doughs)
│   ├── 적층 도우 (Laminated Dough) - 크루아상, 퍼프 페이스트리
│   ├── 당화 도우 (Enriched Dough) - 브리오슈, 시나몬 롤
│   └── 발효 도우 (Fermented Dough) - 피자, 포카치아
└── 세계 도우 (Global Doughs)
    ├── 이탈리안 (Italian) - 피자, 포카치아, 치아바타
    ├── 프랑스 (French) - 바게트, 크루아상
    ├── 아시안 (Asian) - 난, 피타
    └── 아메리칸 (American) - 베이글, 프레첼
```

## 2. 각 도우 타입별 특성 분석

### 2.1 린 도우 (Lean Dough) - 기본 빵
```dart
class LeanDoughCharacteristics {
  // 재료 특성
  final double hydrationRange = 0.65;        // 수분 함량 범위
  final double fatContent = 0.02;           // 지방 함량 (2%)
  final double sugarContent = 0.02;         // 설탕 함량 (2%)
  final String flourType = 'bread_flour';   // 강력분 사용

  // 믹싱 특성
  final double optimalMixingTime = 12.0;     // 최적 믹싱 시간 (분)
  final String mixingSpeed = '저속';         // 저속 믹싱
  final double glutenDevelopment = 0.85;     // 글루텐 발달 지수

  // 발효 특성
  final double optimalFermentationTemp = 25.0; // 최적 발효 온도
  final int fermentationTime = 120;          // 발효 시간 (분)
  final double yeastActivity = 0.75;         // 이스트 활성도

  // 오븐 특성
  final double bakingTemp = 220.0;          // 굽기 온도
  final double crustColorIndex = 0.8;       // 크러스트 색상 지수
  final double crumbStructure = 0.7;        // 빵심 구조 지수

  // 분석 메소드
  Map<String, dynamic> analyzeLeanDough(
    UserData userData,
    RecipeData recipeData
  ) {
    return {
      'mixing': _analyzeLeanMixing(userData, recipeData),
      'dough': _analyzeLeanDough(userData, recipeData),
      'fermentation': _analyzeLeanFermentation(userData, recipeData),
      'oven': _analyzeLeanOven(userData, recipeData)
    };
  }

  Map<String, dynamic> _analyzeLeanMixing(UserData userData, RecipeData recipeData) {
    // 린 도우의 글루텐 형성 최적화
    final glutenFormation = _calculateGlutenFormation(
      userData.mixerType,
      recipeData.flourType,
      userData.environment
    );

    // 수분 흡수율 계산
    final moistureAbsorption = _calculateMoistureAbsorption(
      recipeData.hydration,
      userData.season
    );

    return {
      'glutenFormationIndex': glutenFormation,
      'moistureAbsorptionRate': moistureAbsorption,
      'mixingTime': _optimizeMixingTime(userData.mixerType, glutenFormation),
      'speedProfile': _generateLeanDoughSpeedProfile(userData.mixerType)
    };
  }
}
```

### 2.2 리치 도우 (Rich Dough) - 고지방 함유
```dart
class RichDoughCharacteristics {
  // 재료 특성
  final double hydrationRange = 0.60;        // 수분 함량 범위
  final double fatContent = 0.15;           // 지방 함량 (15%)
  final double sugarContent = 0.10;         // 설탕 함량 (10%)
  final String flourType = 'bread_flour';   // 강력분 사용

  // 믹싱 특성
  final double optimalMixingTime = 8.0;      // 최적 믹싱 시간 (분)
  final String mixingSpeed = '중속';         // 중속 믹싱
  final double glutenDevelopment = 0.6;      // 글루텐 발달 지수 (지방 저해)

  // 발효 특성
  final double optimalFermentationTemp = 4.0;  // 냉장 발효
  final int fermentationTime = 1440;         // 발효 시간 (24시간)
  final double yeastActivity = 0.4;          // 이스트 활성도 (저온 영향)

  // 오븐 특성
  final double bakingTemp = 180.0;          // 굽기 온도
  final double crustColorIndex = 0.9;       // 크러스트 색상 지수
  final double crumbStructure = 0.9;        // 빵심 구조 지수

  Map<String, dynamic> _analyzeRichDoughMixing(UserData userData, RecipeData recipeData) {
    // 지방 함량의 글루텐 형성 저해 효과 계산
    final fatInhibition = _calculateFatInhibition(recipeData.fatContent);

    // 지방 안정화 효과 계산
    final fatStabilization = _calculateFatStabilization(recipeData.fatContent);

    return {
      'glutenFormationIndex': 0.6 - fatInhibition,
      'fatStabilizationIndex': fatStabilization,
      'mixingTime': _optimizeRichMixingTime(userData.mixerType, fatInhibition),
      'speedProfile': _generateRichDoughSpeedProfile(userData.mixerType, fatInhibition)
    };
  }

  Map<String, dynamic> _analyzeRichDoughFermentation(UserData userData, RecipeData recipeData) {
    // 지방 함량의 발효 저해 효과
    final fatFermentationInhibition = _calculateFatFermentationInhibition(recipeData.fatContent);

    // 설탕의 발효 촉진 효과
    final sugarFermentationBoost = _calculateSugarFermentationBoost(recipeData.sugarContent);

    return {
      'yeastActivity': 0.75 - fatFermentationInhibition + sugarFermentationBoost,
      'optimalTemperature': _determineRichFermentationTemp(recipeData.fatContent),
      'fermentationTime': _calculateRichFermentationTime(recipeData.fatContent),
      'gasProduction': _calculateRichGasProduction(yeastActivity, sugarFermentationBoost)
    };
  }
}
```

### 2.3 사워도우 (Sourdough) - 산성 발효
```dart
class SourdoughCharacteristics {
  // 재료 특성
  final double hydrationRange = 0.70;        // 수분 함량 범위
  final double starterPercentage = 0.25;     // 스타터 비율 (25%)
  final double acidityLevel = 4.2;          // 산성도 (pH)
  final String flourType = 'bread_flour';   // 강력분 사용

  // 믹싱 특성
  final double optimalMixingTime = 15.0;     // 최적 믹싱 시간 (분)
  final String mixingSpeed = '저속';         // 저속 믹싱
  final double glutenDevelopment = 0.7;      // 글루텐 발달 지수 (산성 영향)

  // 발효 특성
  final double optimalFermentationTemp = 22.0; // 최적 발효 온도
  final int fermentationTime = 480;          // 발효 시간 (8시간)
  final double yeastActivity = 0.65;         // 이스트 활성도 (스타터)

  // 오븐 특성
  final double bakingTemp = 250.0;          // 굽기 온도
  final double crustColorIndex = 0.95;      // 크러스트 색상 지수
  final double crumbStructure = 0.8;        // 빵심 구조 지수

  Map<String, dynamic> _analyzeSourdoughFermentation(UserData userData, RecipeData recipeData) {
    // 스타터 숙성도 분석
    final starterMaturity = _analyzeStarterMaturity(recipeData.starterAge);

    // 산성도 레벨 계산
    final acidityLevel = _calculateAcidityLevel(recipeData.starterType, starterMaturity);

    // 산성 발효 패턴 분석
    final fermentationPattern = _analyzeAcidicFermentationPattern(
      acidityLevel,
      userData.environment
    );

    return {
      'starterMaturity': starterMaturity,
      'acidityLevel': acidityLevel,
      'fermentationPattern': fermentationPattern,
      'yeastActivity': _calculateSourdoughYeastActivity(starterMaturity, acidityLevel),
      'gasProduction': _calculateSourdoughGasProduction(fermentationPattern)
    };
  }

  Map<String, dynamic> _analyzeSourdoughOven(UserData userData, RecipeData recipeData) {
    // 산성도의 마이야르 반응 영향
    final acidityMaillardEffect = _calculateAcidityMaillardEffect(recipeData.acidityLevel);

    // 스타터의 풍미 향상 효과
    final starterFlavorEnhancement = _calculateStarterFlavorEnhancement(recipeData.starterType);

    return {
      'maillardReactionIndex': 0.85 + acidityMaillardEffect,
      'crustColorIndex': 0.9 + acidityMaillardEffect,
      'flavorProfile': _generateSourdoughFlavorProfile(starterFlavorEnhancement),
      'ovenSpringPrediction': _predictSourdoughOvenSpring(fermentationPattern)
    };
  }
}
```

### 2.4 크루아상 도우 (Croissant Dough) - 적층 구조
```dart
class CroissantDoughCharacteristics {
  // 재료 특성
  final double hydrationRange = 0.55;        // 수분 함량 범위
  final double fatContent = 0.40;           // 지방 함량 (40%)
  final int layerCount = 81;                // 81겹 구조
  final String flourType = 'high_protein';  // 고단백 밀가루

  // 믹싱 특성
  final double optimalMixingTime = 6.0;      // 최적 믹싱 시간 (분)
  final String mixingSpeed = '고속';         // 고속 믹싱 (초기)
  final double glutenDevelopment = 0.9;      // 글루텐 발달 지수

  // 발효 특성
  final double optimalFermentationTemp = 4.0;  // 냉장 발효
  final int fermentationTime = 2880;         // 발효 시간 (48시간)
  final double yeastActivity = 0.3;          // 이스트 활성도 (저온)

  // 오븐 특성
  final double bakingTemp = 200.0;          // 굽기 온도
  final double crustColorIndex = 0.85;      // 크러스트 색상 지수
  final double crumbStructure = 0.95;       // 빵심 구조 지수

  Map<String, dynamic> _analyzeCroissantLamination(UserData userData, RecipeData recipeData) {
    // 적층 레이어 구조 분석
    final layerStructure = _analyzeLayerStructure(recipeData.fatContent, userData.mixerType);

    // 지방층 두께 분석
    final fatLayerThickness = _calculateFatLayerThickness(recipeData.fatContent, layerStructure);

    // 페이스트리 구조 안정성
    final pastryStructureStability = _analyzePastryStructureStability(
      layerStructure,
      fatLayerThickness,
      userData.equipmentPerformance
    );

    return {
      'layerStructure': layerStructure,
      'fatLayerThickness': fatLayerThickness,
      'pastryStructureStability': pastryStructureStability,
      'laminationSuccessProbability': _calculateLaminationSuccess(pastryStructureStability)
    };
  }
}
```

## 3. 도우 타입 감지 알고리즘

### 3.1 재료 기반 감지
```dart
class DoughTypeDetectionEngine {
  Future<String> detectDoughType(RecipeData recipeData) async {
    // 재료 분석
    final ingredients = _extractIngredients(recipeData);
    final ingredientScores = await _analyzeIngredients(ingredients);

    // 제조법 분석
    final instructions = recipeData.instructions;
    final instructionScores = await _analyzeInstructions(instructions);

    // 최종 점수 계산
    final totalScores = _combineScores(ingredientScores, instructionScores);

    // 가장 높은 점수의 도우 타입 반환
    return _getHighestScoreDoughType(totalScores);
  }

  Map<String, double> _analyzeIngredients(List<String> ingredients) {
    final scores = <String, double>{};

    // 각 도우 타입별 재료 키워드 매칭
    for (final doughType in _doughTypeKeywords.keys) {
      double score = 0.0;

      for (final keyword in _doughTypeKeywords[doughType]!.ingredientKeywords) {
        if (ingredients.any((ing) => ing.toLowerCase().contains(keyword))) {
          score += _doughTypeKeywords[doughType]!.ingredientWeight;
        }
      }

      scores[doughType] = score;
    }

    return scores;
  }

  Map<String, double> _analyzeInstructions(String instructions) {
    final scores = <String, double>{};
    final lowerInstructions = instructions.toLowerCase();

    // 각 도우 타입별 제조법 키워드 매칭
    for (final doughType in _doughTypeKeywords.keys) {
      double score = 0.0;

      for (final keyword in _doughTypeKeywords[doughType]!.instructionKeywords) {
        final matches = keyword.allMatches(lowerInstructions).length;
        score += matches * _doughTypeKeywords[doughType]!.instructionWeight;
      }

      scores[doughType] = score;
    }

    return scores;
  }
}
```

### 3.2 감지 정확도 향상
```dart
class DoughTypeDetectionAccuracy {
  // 신뢰도 기반 감지
  Future<DoughTypeDetectionResult> detectWithConfidence(
    RecipeData recipeData
  ) async {
    final scores = await _calculateDetectionScores(recipeData);
    final highestScore = scores.values.reduce(max);
    final confidence = highestScore / scores.values.reduce((a, b) => a + b);

    if (confidence > 0.7) {
      return DoughTypeDetectionResult(
        doughType: _getHighestScoreDoughType(scores),
        confidence: confidence,
        reasoning: _generateDetectionReasoning(scores)
      );
    } else {
      // 저신뢰도 시 추가 분석
      return await _performAdvancedDetection(recipeData, scores);
    }
  }

  Future<DoughTypeDetectionResult> _performAdvancedDetection(
    RecipeData recipeData,
    Map<String, double> initialScores
  ) async {
    // 추가 재료 분석
    final advancedIngredientAnalysis = await _analyzeAdvancedIngredients(recipeData);

    // 조리 시간 패턴 분석
    final timePatternAnalysis = await _analyzeTimePatterns(recipeData);

    // 최종 결정
    final finalScores = _combineAdvancedScores(initialScores, advancedIngredientAnalysis, timePatternAnalysis);

    return DoughTypeDetectionResult(
      doughType: _getHighestScoreDoughType(finalScores),
      confidence: _calculateAdvancedConfidence(finalScores),
      reasoning: _generateAdvancedReasoning(finalScores)
    );
  }
}
```

## 4. 도우 타입별 최적 조건 데이터베이스

### 4.1 최적 조건 정의
```dart
class OptimalDoughConditions {
  static final Map<String, DoughOptimalConditions> conditions = {
    '린 도우': DoughOptimalConditions(
      mixing: MixingConditions(
        time: 12.0,
        speed: '저속',
        temperature: 22.0,
        hydration: 0.65
      ),
      fermentation: FermentationConditions(
        temperature: 25.0,
        time: 120,
        humidity: 75.0,
        method: 'room_temperature'
      ),
      oven: OvenConditions(
        temperature: 220.0,
        time: 35,
        steamTime: 10,
        type: 'convection'
      )
    ),

    '리치 도우': DoughOptimalConditions(
      mixing: MixingConditions(
        time: 8.0,
        speed: '중속',
        temperature: 20.0,
        hydration: 0.60
      ),
      fermentation: FermentationConditions(
        temperature: 4.0,
        time: 1440,
        humidity: 70.0,
        method: 'refrigerator'
      ),
      oven: OvenConditions(
        temperature: 180.0,
        time: 40,
        steamTime: 0,
        type: 'home'
      )
    ),

    '사워도우': DoughOptimalConditions(
      mixing: MixingConditions(
        time: 15.0,
        speed: '저속',
        temperature: 20.0,
        hydration: 0.70
      ),
      fermentation: FermentationConditions(
        temperature: 22.0,
        time: 480,
        humidity: 80.0,
        method: 'room_temperature'
      ),
      oven: OvenConditions(
        temperature: 250.0,
        time: 45,
        steamTime: 15,
        type: 'stone_oven'
      )
    )
  };
}
```

### 4.2 동적 조건 조정
```dart
class DynamicConditionAdjuster {
  Future<DoughOptimalConditions> adjustForUserConditions(
    String doughType,
    UserData userData
  ) async {
    final baseConditions = OptimalDoughConditions.conditions[doughType]!;

    // 고도 보정
    final altitudeAdjusted = _adjustForAltitude(baseConditions, userData.altitude);

    // 계절 보정
    final seasonAdjusted = _adjustForSeason(altitudeAdjusted, userData.season);

    // 장비 성능 보정
    final equipmentAdjusted = _adjustForEquipment(seasonAdjusted, userData.equipmentPerformance);

    return equipmentAdjusted;
  }

  DoughOptimalConditions _adjustForAltitude(
    DoughOptimalConditions conditions,
    double altitude
  ) {
    if (altitude > 1000) {
      return conditions.copyWith(
        mixing: conditions.mixing.copyWith(
          hydration: conditions.mixing.hydration - 0.02, // 고지대 수분 감소
          time: conditions.mixing.time + 2             // 믹싱 시간 증가
        ),
        fermentation: conditions.fermentation.copyWith(
          time: conditions.fermentation.time - 30      // 발효 시간 단축
        )
      );
    }
    return conditions;
  }

  DoughOptimalConditions _adjustForSeason(
    DoughOptimalConditions conditions,
    String season
  ) {
    switch (season) {
      case 'winter':
        return conditions.copyWith(
          mixing: conditions.mixing.copyWith(
            temperature: conditions.mixing.temperature + 2
          ),
          fermentation: conditions.fermentation.copyWith(
            temperature: conditions.fermentation.temperature + 1
          )
        );
      case 'summer':
        return conditions.copyWith(
          mixing: conditions.mixing.copyWith(
            temperature: conditions.mixing.temperature - 2,
            hydration: conditions.mixing.hydration - 0.01
          ),
          fermentation: conditions.fermentation.copyWith(
            temperature: conditions.fermentation.temperature - 2
          )
        );
      default:
        return conditions;
    }
  }
}
```

## 5. 동적 분석 파라미터 조정

### 5.1 실시간 파라미터 조정
```dart
class DynamicParameterAdjuster {
  Future<Map<String, dynamic>> adjustAnalysisParameters(
    String doughType,
    UserData userData,
    Map<String, dynamic> baseParameters
  ) async {
    // 환경 조건 기반 조정
    final environmentalAdjustment = await _calculateEnvironmentalAdjustment(
      doughType,
      userData.environment
    );

    // 장비 성능 기반 조정
    final equipmentAdjustment = await _calculateEquipmentAdjustment(
      doughType,
      userData.equipmentPerformance
    );

    // 사용자 숙련도 기반 조정
    final skillAdjustment = await _calculateSkillAdjustment(
      doughType,
      userData.skillLevel
    );

    // 최종 파라미터 계산
    return _applyAdjustments(baseParameters, [
      environmentalAdjustment,
      equipmentAdjustment,
      skillAdjustment
    ]);
  }

  Future<Map<String, dynamic>> _calculateEnvironmentalAdjustment(
    String doughType,
    EnvironmentalData environment
  ) async {
    final adjustments = <String, dynamic>{};

    // 온도 기반 조정
    if (environment.temperature < 20) {
      adjustments['mixingTime'] = 1.2;  // 믹싱 시간 20% 증가
      adjustments['fermentationTime'] = 1.3;  // 발효 시간 30% 증가
    } else if (environment.temperature > 28) {
      adjustments['mixingTime'] = 0.9;  // 믹싱 시간 10% 감소
      adjustments['fermentationTime'] = 0.8;  // 발효 시간 20% 감소
    }

    // 습도 기반 조정
    if (environment.humidity < 50) {
      adjustments['hydration'] = 1.05;  // 수분 함량 5% 증가
      adjustments['mixingTime'] = 1.1;  // 믹싱 시간 10% 증가
    } else if (environment.humidity > 80) {
      adjustments['hydration'] = 0.95;  // 수분 함량 5% 감소
      adjustments['fermentationTime'] = 0.9;  // 발효 시간 10% 감소
    }

    return adjustments;
  }
}
```

## 6. 사용자 맞춤 분석 결과 생성

### 6.1 개인화된 분석 결과
```dart
class PersonalizedAnalysisGenerator {
  Future<PersonalizedAnalysisResult> generatePersonalizedResult(
    String doughType,
    UserData userData,
    AnalysisData analysisData
  ) async {
    // 사용자 선호도 분석
    final preferences = await _analyzeUserPreferences(userData.userId);

    // 사용자 과거 성공/실패 패턴 분석
    final historicalPatterns = await _analyzeHistoricalPatterns(userData.userId, doughType);

    // 개인화된 조정값 계산
    final personalizedAdjustments = _calculatePersonalizedAdjustments(
      preferences,
      historicalPatterns,
      analysisData
    );

    // 최종 결과 생성
    return PersonalizedAnalysisResult(
      doughType: doughType,
      baseAnalysis: analysisData,
      personalizedAdjustments: personalizedAdjustments,
      userPreferences: preferences,
      historicalInsights: historicalPatterns,
      confidenceLevel: _calculatePersonalizationConfidence(preferences, historicalPatterns)
    );
  }

  Map<String, dynamic> _calculatePersonalizedAdjustments(
    UserPreferences preferences,
    HistoricalPatterns patterns,
    AnalysisData analysisData
  ) {
    final adjustments = <String, dynamic>{};

    // 사용자의 온도 선호도 반영
    if (preferences.preferredTemperature != null) {
      adjustments['mixingTemperature'] = _adjustTemperatureForPreference(
        analysisData.mixing.temperature,
        preferences.preferredTemperature!
      );
    }

    // 사용자의 시간 선호도 반영
    if (preferences.preferredPreparationTime != null) {
      adjustments['totalTime'] = _adjustTimeForPreference(
        analysisData.totalTime,
        preferences.preferredPreparationTime!
      );
    }

    // 과거 성공 패턴 반영
    if (patterns.successfulTemperatureRange != null) {
      adjustments['temperatureRange'] = patterns.successfulTemperatureRange;
    }

    return adjustments;
  }
}
```

이 설계는 40여가지 도우 타입의 특성을 정확히 반영하여 각 도우 타입에 최적화된 분석을 제공한다.
