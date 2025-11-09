# 🔬 빵모듈 프로세스 상세 설계

## 📋 목차
1. 프로세스 개요
2. 데이터 흐름 설계
3. 각 단계별 상세 구현
4. 에러 처리 및 예외 상황
5. 성능 최적화
6. 테스트 전략

## 1. 프로세스 개요

### 1.1 목표
빵모듈의 7단계 연동 프로세스를 구현하여 실제 제빵 과학에 기반한 정확한 분석 결과를 제공한다.

### 1.2 주요 요구사항
- 단계별 데이터 연동 (이전 단계 결과가 다음 단계에 영향)
- 도우 타입별 특화 분석
- 실시간 피드백 및 진행 상황 표시
- 사용자 환경 조건 반영

## 2. 데이터 흐름 설계

### 2.1 데이터 흐름도
```
사용자 입력 → 도우 타입 감지 → 재료 분석 → 믹싱 분석 → 반죽 분석 → 발효 분석 → 오븐 분석 → 최종 결과
```

### 2.2 데이터 모델 구조
```dart
class BreadAnalysisResult {
  final String doughType;                    // 감지된 도우 타입
  final UserComprehensiveData userData;      // 사용자 종합 데이터
  final IngredientAnalysisData ingredientData; // 재료 분석 데이터
  final MixingAnalysisData mixingData;       // 믹싱 분석 데이터
  final DoughAnalysisData doughData;         // 반죽 분석 데이터
  final FermentationAnalysisData fermentationData; // 발효 분석 데이터
  final OvenAnalysisData ovenData;           // 오븐 분석 데이터
  final DateTime analysisTimestamp;          // 분석 시간
  final AnalysisMetadata metadata;           // 분석 메타데이터
}
```

## 3. 각 단계별 상세 구현

### 3.1 도우 타입 감지 (Step 1)
```dart
class DoughTypeDetector {
  Future<String> detectDoughType(RecipeData recipeData) async {
    // 재료 기반 감지
    final ingredients = _extractIngredients(recipeData);
    final fatContent = _calculateFatContent(ingredients);
    final hasSourdough = _containsSourdoughStarter(ingredients);
    final hasSugar = _containsHighSugar(ingredients);

    // 점수 기반 결정
    final scores = await _calculateDoughTypeScores(ingredients);

    // 가장 높은 점수의 도우 타입 반환
    return _getHighestScoreDoughType(scores);
  }

  Map<String, double> _calculateDoughTypeScores(List<String> ingredients) {
    final scores = <String, double>{};

    // 각 도우 타입별 키워드 매칭
    for (final doughType in _doughTypeKeywords.keys) {
      scores[doughType] = _calculateKeywordMatchScore(
        ingredients,
        _doughTypeKeywords[doughType]!
      );
    }

    return scores;
  }
}
```

### 3.2 사용자 종합 데이터 생성 (Step 2)
```dart
class UserDataGenerator {
  Future<UserComprehensiveData> generateComprehensiveData(
    UserInputData userInput
  ) async {
    // 환경 데이터 검증
    final validatedEnvironment = await _validateEnvironmentData(userInput);

    // 장비 성능 데이터
    final equipmentPerformance = await _calculateEquipmentPerformance(
      userInput.mixerType,
      userInput.ovenType
    );

    // 계절별 보정값 계산
    final seasonalAdjustments = _calculateSeasonalAdjustments(
      userInput.season,
      userInput.altitude
    );

    return UserComprehensiveData(
      environment: validatedEnvironment,
      equipmentPerformance: equipmentPerformance,
      seasonalAdjustments: seasonalAdjustments,
      validationTimestamp: DateTime.now()
    );
  }
}
```

### 3.3 재료 분석 데이터 생성 (Step 3)
```dart
class IngredientAnalyzer {
  Future<IngredientAnalysisData> analyzeIngredients(
    RecipeData recipeData,
    String doughType
  ) async {
    // 재료 구성 분석
    final composition = _analyzeIngredientComposition(recipeData.ingredients);

    // 도우 타입별 특성 분석
    final doughCharacteristics = await _analyzeDoughCharacteristics(
      composition,
      doughType
    );

    // 수분 흡수율 계산
    final moistureAbsorption = _calculateMoistureAbsorptionRate(
      composition,
      doughType
    );

    // 글루텐 함량 분석
    final glutenContent = _analyzeGlutenContent(composition);

    return IngredientAnalysisData(
      composition: composition,
      doughCharacteristics: doughCharacteristics,
      moistureAbsorption: moistureAbsorption,
      glutenContent: glutenContent
    );
  }
}
```

### 3.4 믹싱 단계 분석 (Step 4)
```dart
class MixingAnalyzer {
  Future<MixingAnalysisData> analyzeMixingStage(
    UserComprehensiveData userData,
    IngredientAnalysisData ingredientData,
    String doughType
  ) async {
    // 도우 타입별 최적 믹싱 조건
    final optimalConditions = _getOptimalMixingConditions(doughType);

    // 실제 믹싱 조건 계산
    final actualConditions = await _calculateActualMixingConditions(
      userData,
      ingredientData
    );

    // 글루텐 형성 지수 계산
    final glutenFormationIndex = _calculateGlutenFormationIndex(
      actualConditions,
      optimalConditions
    );

    // 믹서 성능 분석
    final mixerPerformance = await _analyzeMixerPerformance(
      userData.equipmentPerformance,
      doughType
    );

    // 믹싱 시간 최적화
    final optimizedMixingTime = _calculateOptimizedMixingTime(
      actualConditions,
      mixerPerformance
    );

    // 믹싱 속도 프로파일 생성
    final speedProfile = _generateMixingSpeedProfile(
      doughType,
      mixerPerformance
    );

    // 문제점 분석
    final issues = await _analyzeMixingIssues(
      actualConditions,
      optimalConditions,
      glutenFormationIndex
    );

    return MixingAnalysisData(
      doughType: doughType,
      optimalConditions: optimalConditions,
      actualConditions: actualConditions,
      glutenFormationIndex: glutenFormationIndex,
      mixerPerformance: mixerPerformance,
      optimizedMixingTime: optimizedMixingTime,
      speedProfile: speedProfile,
      issues: issues,
      successProbability: _calculateMixingSuccessProbability(
        glutenFormationIndex,
        issues
      )
    );
  }
}
```

### 3.5 반죽 단계 분석 (Step 5)
```dart
class DoughAnalyzer {
  Future<DoughAnalysisData> analyzeDoughStage(
    UserComprehensiveData userData,
    MixingAnalysisData mixingData
  ) async {
    // 믹싱 결과 기반 반죽 특성
    final doughCharacteristics = _calculateDoughCharacteristics(
      mixingData.glutenFormationIndex,
      userData.environment
    );

    // 수분 흡수율 재계산 (믹싱 결과 반영)
    final moistureAbsorptionRate = _recalculateMoistureAbsorption(
      mixingData.glutenFormationIndex,
      userData.environment
    );

    // 반죽 온도 상승 계산
    final temperatureRise = _calculateTemperatureRise(
      userData.equipmentPerformance,
      mixingData.mixerPerformance
    );

    // 실제 반죽 온도
    final actualDoughTemperature = userData.environment.temperature + temperatureRise;

    // 글루텐 네트워크 안정성 분석
    final glutenNetworkStability = _analyzeGlutenNetworkStability(
      mixingData.glutenFormationIndex,
      moistureAbsorptionRate,
      actualDoughTemperature
    );

    // 계절별 수분 보정
    final seasonalMoistureAdjustment = _calculateSeasonalMoistureAdjustment(
      userData.seasonalAdjustments,
      moistureAbsorptionRate
    );

    // 고도별 수분 영향
    final altitudeMoistureImpact = _calculateAltitudeMoistureImpact(
      userData.environment.altitude,
      moistureAbsorptionRate
    );

    // 문제점 분석
    final issues = await _analyzeDoughIssues(
      moistureAbsorptionRate,
      actualDoughTemperature,
      glutenNetworkStability,
      seasonalMoistureAdjustment,
      altitudeMoistureImpact
    );

    return DoughAnalysisData(
      characteristics: doughCharacteristics,
      moistureAbsorptionRate: moistureAbsorptionRate,
      actualTemperature: actualDoughTemperature,
      glutenNetworkStability: glutenNetworkStability,
      seasonalMoistureAdjustment: seasonalMoistureAdjustment,
      altitudeMoistureImpact: altitudeMoistureImpact,
      issues: issues,
      successProbability: _calculateDoughSuccessProbability(
        glutenNetworkStability,
        issues
      )
    );
  }
}
```

### 3.6 발효 단계 분석 (Step 6)
```dart
class FermentationAnalyzer {
  Future<FermentationAnalysisData> analyzeFermentationStage(
    UserComprehensiveData userData,
    DoughAnalysisData doughData
  ) async {
    // 이스트 활성도 계산 (반죽 온도, 글루텐 안정성 영향)
    final yeastActivity = _calculateYeastActivity(
      userData.environment,
      doughData.actualTemperature,
      doughData.glutenNetworkStability
    );

    // 발효 방식별 효율성
    final fermentationMethodEfficiency = _calculateFermentationMethodEfficiency(
      userData.fermentationMethod,
      doughData.glutenNetworkStability
    );

    // 가스 발생 최적화 (이스트 활성도, 환경 조건)
    final gasGenerationOptimization = _calculateGasGenerationOptimization(
      yeastActivity,
      userData.environment,
      fermentationMethodEfficiency
    );

    // 최적 발효 시간 계산
    final optimalFermentationTime = _calculateOptimalFermentationTime(
      yeastActivity,
      userData.environment,
      fermentationMethodEfficiency
    );

    // 발효 온도 범위 분석
    final fermentationTemperatureRange = _calculateFermentationTemperatureRange(
      userData.environment,
      fermentationMethodEfficiency
    );

    // 가스 발생량 예측
    final gasGenerationVolume = _calculateGasGenerationVolume(
      yeastActivity,
      optimalFermentationTime,
      gasGenerationOptimization
    );

    // 발효 속도 지수
    final fermentationSpeedIndex = _calculateFermentationSpeedIndex(
      yeastActivity,
      userData.environment,
      fermentationMethodEfficiency
    );

    // 문제점 분석
    final issues = await _analyzeFermentationIssues(
      yeastActivity,
      userData.environment,
      fermentationMethodEfficiency
    );

    return FermentationAnalysisData(
      yeastActivity: yeastActivity,
      fermentationMethodEfficiency: fermentationMethodEfficiency,
      gasGenerationOptimization: gasGenerationOptimization,
      optimalFermentationTime: optimalFermentationTime,
      fermentationTemperatureRange: fermentationTemperatureRange,
      gasGenerationVolume: gasGenerationVolume,
      fermentationSpeedIndex: fermentationSpeedIndex,
      issues: issues,
      successProbability: _calculateFermentationSuccessProbability(
        yeastActivity,
        issues
      )
    );
  }
}
```

### 3.7 오븐 단계 분석 (Step 7)
```dart
class OvenAnalyzer {
  Future<OvenAnalysisData> analyzeOvenStage(
    UserComprehensiveData userData,
    FermentationAnalysisData fermentationData
  ) async {
    // 마이야르 반응 지수 (온도, 습도, 발효 상태 영향)
    final maillardReactionIndex = _calculateMaillardReactionIndex(
      userData.environment,
      fermentationData.fermentationSpeedIndex
    );

    // 수분 이동 계수 (온도, 습도, 오븐 타입, 발효 상태)
    final moistureTransferCoefficient = _calculateMoistureTransferCoefficient(
      userData.environment,
      userData.ovenType,
      fermentationData.gasGenerationVolume
    );

    // 크러스트 형성 지수 (마이야르 반응, 수분 이동, 오븐 성능)
    final crustFormationIndex = _calculateCrustFormationIndex(
      maillardReactionIndex,
      moistureTransferCoefficient,
      userData.equipmentPerformance
    );

    // 오븐 성능 지수
    final ovenPerformanceIndex = _calculateOvenPerformanceIndex(
      userData.equipmentPerformance,
      userData.environment
    );

    // 열 분포 균일성
    final heatDistribution = _calculateHeatDistribution(
      userData.ovenType,
      userData.environment
    );

    // 최종 베이킹 성공 확률
    final finalSuccessProbability = _calculateFinalBakingSuccess(
      maillardReactionIndex,
      crustFormationIndex,
      ovenPerformanceIndex,
      heatDistribution
    );

    // 문제점 분석
    final issues = await _analyzeOvenIssues(
      userData.environment,
      maillardReactionIndex,
      moistureTransferCoefficient,
      ovenPerformanceIndex
    );

    return OvenAnalysisData(
      maillardReactionIndex: maillardReactionIndex,
      moistureTransferCoefficient: moistureTransferCoefficient,
      crustFormationIndex: crustFormationIndex,
      ovenPerformanceIndex: ovenPerformanceIndex,
      heatDistribution: heatDistribution,
      finalSuccessProbability: finalSuccessProbability,
      issues: issues
    );
  }
}
```

## 4. 에러 처리 및 예외 상황

### 4.1 데이터 검증 에러
```dart
class DataValidationError extends BreadAnalysisError {
  final String field;
  final dynamic invalidValue;
  final String reason;

  DataValidationError({
    required this.field,
    required this.invalidValue,
    required this.reason
  });
}
```

### 4.2 분석 실패 처리
```dart
class AnalysisFailureHandler {
  Future<AnalysisResult> handleAnalysisFailure(
    BreadAnalysisError error,
    BreadAnalysisContext context
  ) async {
    // 에러 타입별 처리
    switch (error.runtimeType) {
      case DataValidationError:
        return await _handleValidationError(error as DataValidationError);
      case InsufficientDataError:
        return await _handleInsufficientDataError(error as InsufficientDataError);
      case CalculationError:
        return await _handleCalculationError(error as CalculationError);
      default:
        return await _handleUnknownError(error);
    }
  }
}
```

## 5. 성능 최적화

### 5.1 캐싱 전략
```dart
class BreadAnalysisCache {
  static final Map<String, CachedAnalysisResult> _cache = {};

  static Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() computation
  ) async {
    if (_cache.containsKey(key) && !_isExpired(_cache[key]!)) {
      return _cache[key]!.result as T;
    }

    final result = await computation();
    _cache[key] = CachedAnalysisResult(
      result: result,
      timestamp: DateTime.now()
    );

    return result;
  }
}
```

### 5.2 병렬 처리
```dart
class ParallelAnalysisProcessor {
  Future<BreadAnalysisResult> processInParallel(
    UserComprehensiveData userData,
    RecipeData recipeData
  ) async {
    // 독립적 분석 작업들을 병렬로 실행
    final results = await Future.wait([
      _analyzeIngredients(recipeData),
      _analyzeEnvironment(userData),
      _analyzeEquipment(userData.equipmentPerformance),
    ]);

    // 종속적 분석 작업들 순차 실행
    final mixingData = await _analyzeMixing(userData, results[0]);
    final doughData = await _analyzeDough(userData, mixingData);
    final fermentationData = await _analyzeFermentation(userData, doughData);
    final ovenData = await _analyzeOven(userData, fermentationData);

    return BreadAnalysisResult(
      ingredientData: results[0],
      environmentData: results[1],
      equipmentData: results[2],
      mixingData: mixingData,
      doughData: doughData,
      fermentationData: fermentationData,
      ovenData: ovenData
    );
  }
}
```

## 6. 테스트 전략

### 6.1 단위 테스트
```dart
void main() {
  group('BreadModuleProcess', () {
    test('should detect dough type correctly', () async {
      final detector = DoughTypeDetector();
      final result = await detector.detectDoughType(testRecipeData);
      expect(result, equals('린 도우'));
    });

    test('should calculate mixing analysis accurately', () async {
      final analyzer = MixingAnalyzer();
      final result = await analyzer.analyzeMixingStage(
        testUserData,
        testIngredientData,
        '린 도우'
      );
      expect(result.glutenFormationIndex, greaterThan(0.7));
    });
  });
}
```

### 6.2 통합 테스트
```dart
void main() {
  group('BreadModuleProcess Integration', () {
    test('should complete full analysis pipeline', () async {
      final processor = BreadModuleProcess();
      final result = await processor.executeFullPipeline(
        testUserData,
        testRecipeData
      );

      expect(result.doughType, isNotNull);
      expect(result.mixingData, isNotNull);
      expect(result.doughData, isNotNull);
      expect(result.fermentationData, isNotNull);
      expect(result.ovenData, isNotNull);
    });
  });
}
```

이 설계는 실제 제빵 과학에 기반한 정확한 분석을 제공하며, 각 단계별 데이터 연동을 통해 신뢰할 수 있는 결과를 생성한다.
