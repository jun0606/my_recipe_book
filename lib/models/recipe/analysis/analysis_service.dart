import 'dart:async';
import 'analysis_result.dart';
import 'bread_analysis_data.dart';
import '../core/recipe.dart';
import '../metadata/ingredient_metadata.dart';
import '../metadata/quality_metadata.dart';
import '../metadata/process_metadata.dart';
import '../metadata/baking_phase.dart';
import '../environment/environmental_conditions.dart';
import '../environment/oven_characteristics.dart';
import '../environment/oven_type.dart';
import '../environment/season.dart';

// bread_calculator.dart의 기능을 통합하기 위한 import
import '../../../services/bread_calculator.dart';

/// 온도 범위 enum
enum TemperatureRange {
  tooLow, // < 20°C
  low, // 20-22°C
  optimal, // 22-26°C
  high, // 26-30°C
  tooHigh // > 30°C
}

/// 온도 평가 결과 클래스
class TemperatureEvaluation {
  final TemperatureRange range;
  final double timeMultiplier;
  final double glutenFormation;
  final double successBonus;
  final List<String> warnings;

  TemperatureEvaluation({
    required this.range,
    required this.timeMultiplier,
    required this.glutenFormation,
    required this.successBonus,
    required this.warnings,
  });

  String get displayName {
    switch (range) {
      case TemperatureRange.tooLow:
        return '너무 낮음';
      case TemperatureRange.low:
        return '낮음';
      case TemperatureRange.optimal:
        return '적정';
      case TemperatureRange.high:
        return '높음';
      case TemperatureRange.tooHigh:
        return '너무 높음';
    }
  }
}

// bread_calculator.dart의 기능을 통합하기 위한 import
class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  /// 기본 분석 실행
  Future<AnalysisResult> analyzeRecipe({
    required Recipe recipe,
    EnvironmentalConditions? environment,
    String analysisType = 'basic',
  }) async {
    // 분석 데이터 생성
    final analysisData = await _generateAnalysisData(recipe, environment);

    // 분석 결과 생성
    final result = AnalysisResultGenerator.createBasicResult(
      recipe: recipe,
      analysisData: analysisData,
      analysisType: analysisType,
    );

    return result;
  }

  /// 상세 분석 실행
  Future<AnalysisResult> analyzeRecipeDetailed({
    required Recipe recipe,
    EnvironmentalConditions? environment,
    Map<String, dynamic>? additionalParameters,
    String analysisType = 'detailed',
  }) async {
    // 기본 분석 실행
    final basicResult = await analyzeRecipe(
      recipe: recipe,
      environment: environment,
      analysisType: analysisType,
    );

    // 추가 분석 수행
    final additionalAnalysis = await _performAdditionalAnalysis(
      recipe,
      basicResult.analysisData,
      additionalParameters,
    );

    // 상세 결과 생성
    final detailedResult = AnalysisResultGenerator.createDetailedResult(
      recipe: recipe,
      analysisData: basicResult.analysisData,
      additionalAnalysis: additionalAnalysis,
      analysisType: analysisType,
    );

    return detailedResult;
  }

  /// 빠른 분석 실행 (간소화된 버전)
  Future<AnalysisResult> analyzeRecipeQuick({
    required Recipe recipe,
    EnvironmentalConditions? environment,
  }) async {
    // 최소한의 데이터로 빠른 분석
    final analysisData = await _generateQuickAnalysisData(recipe, environment);

    return AnalysisResultGenerator.createBasicResult(
      recipe: recipe,
      analysisData: analysisData,
      analysisType: 'quick',
    );
  }

  /// 배치 분석 실행
  Future<List<AnalysisResult>> analyzeRecipesBatch({
    required List<Recipe> recipes,
    EnvironmentalConditions? environment,
    String analysisType = 'batch',
  }) async {
    final results = <AnalysisResult>[];

    for (final recipe in recipes) {
      try {
        final result = await analyzeRecipe(
          recipe: recipe,
          environment: environment,
          analysisType: analysisType,
        );
        results.add(result);
      } catch (e) {
        // 분석 실패한 레시피는 건너뜀
        print('레시피 분석 실패: ${recipe.title}, 오류: $e');
      }
    }

    return results;
  }

  /// 분석 결과 비교
  Future<AnalysisComparison> compareAnalysisResults({
    required AnalysisResult result1,
    required AnalysisResult result2,
  }) async {
    return AnalysisComparison(
      result1: result1,
      result2: result2,
      differences: _calculateDifferences(result1, result2),
      recommendations: _generateComparisonRecommendations(result1, result2),
    );
  }

  /// RPM 기반 믹싱 분석 (bread_calculator.dart 기능 통합)
  Future<AnalysisResult> analyzeMixingWithRPM({
    required Recipe recipe,
    required Map<String, dynamic> mixingInputs,
    required List<dynamic> mixingData,
    EnvironmentalConditions? environment,
    String analysisType = 'rpm_analysis',
  }) async {
    // bread_calculator.dart의 RPM 기반 분석 활용
    final rpmAnalysis = BreadCalculator.calculateMixingStageAnalysisWithRPM(
      mixingInputs,
      mixingData,
    );

    // 환경 조건
    final env = environment ?? await _createDefaultEnvironment();

    // 분석 데이터 생성 (RPM 분석 결과를 반영)
    final analysisData = await _generateAnalysisDataFromRPMAnalysis(
      recipe,
      env,
      rpmAnalysis,
    );

    // RPM 기반 상세 분석 결과 생성
    final result = AnalysisResultGenerator.createDetailedResult(
      recipe: recipe,
      analysisData: analysisData,
      additionalAnalysis: {
        'rpm_analysis': rpmAnalysis,
        'recommendations': {
          'mixing_optimization': _extractRPMRecommendations(rpmAnalysis),
        },
        'warnings': {
          'mixing_warnings': _extractRPMWarnings(rpmAnalysis),
        },
      },
      analysisType: analysisType,
    );

    return result;
  }

  /// 기존 bread_calculator.dart 호환 메소드
  Map<String, dynamic> calculateMixingStageAnalysis({
    required Map<String, dynamic> inputs,
    required List<dynamic> mixingData,
  }) {
    // 기존 bread_calculator.dart의 메소드를 그대로 위임
    return BreadCalculator.calculateMixingStageAnalysis(inputs, mixingData);
  }

  /// 온도 평가 (bread_calculator.dart 기능 통합)
  TemperatureEvaluation evaluateTemperature(double temperature) {
    // 기존 bread_calculator.dart의 메소드를 그대로 위임
    return BreadCalculator.evaluateTemperature(temperature);
  }

  // 내부 헬퍼 메소드들
  Future<BreadAnalysisData> _generateAnalysisData(
    Recipe recipe,
    EnvironmentalConditions? environment,
  ) async {
    // 환경 조건 생성 또는 사용
    final env = environment ?? await _createDefaultEnvironment();

    // 재료 메타데이터 생성
    final ingredientMetadata =
        IngredientMetadataGenerator.generateMetadataList(recipe.ingredients);

    // 품질 메타데이터 예측
    final qualityMetadata = QualityCalculator.predictFromRecipe(
      hydration: recipe.hydrationPercentage,
      yeastAmount: recipe.yeastAmount,
      saltAmount: recipe.saltAmount,
      flourType: recipe.flourType,
      fermentationMethod: recipe.fermentationMethod,
    );

    // 공정 메타데이터 생성
    final processMetadata = await _generateProcessMetadata(recipe, env);

    return BreadAnalysisData(
      recipe: recipe,
      environment: env,
      ingredientMetadata: ingredientMetadata,
      qualityMetadata: qualityMetadata,
      processMetadata: processMetadata,
      analysisTimestamp: DateTime.now(),
    );
  }

  Future<BreadAnalysisData> _generateQuickAnalysisData(
    Recipe recipe,
    EnvironmentalConditions? environment,
  ) async {
    // 빠른 분석을 위한 간소화된 버전
    final env = environment ?? await _createDefaultEnvironment();

    // 기본 메타데이터 생성
    final ingredientMetadata =
        IngredientMetadataGenerator.generateMetadataList(recipe.ingredients);

    // 기본 품질 예측
    final qualityMetadata = QualityMetadata(
      volumeIndex: 2.0,
      crustColorIndex: 0.7,
      poreStructureScore: 70.0,
      moistureRetention: 0.8,
    );

    // 기본 공정 메타데이터
    final processMetadata = ProcessMetadata(
      mixing: MixingMeta(
        predictedTime: 15.0,
        frictionHeat: 8.0,
        mixerTypeCoefficient: 1.0,
        glutenDevelopmentTarget: 1.1,
        equipmentCalibration: 1.0,
      ),
      fermentation: FermentationMeta(
        predictedTime: 120.0,
        volumeIncrease: 2.0,
        microbialActivityCoefficient: 1.0,
        doughPhysicalChemicalCoefficient: 1.0,
        environmentalClimateCoefficient: 1.0,
        doughTypeCorrection: 1.0,
      ),
      baking: BakingMeta(
        temperatureProfile: BakingProfileGenerator.createStandardBreadProfile(),
        totalBakingTime: 45.0,
        weightCorrection: 1.0,
        hydrationCorrection: 1.0,
        ovenEfficiency: 0.9,
        breadTypeCorrection: 1.0,
      ),
    );

    return BreadAnalysisData(
      recipe: recipe,
      environment: env,
      ingredientMetadata: ingredientMetadata,
      qualityMetadata: qualityMetadata,
      processMetadata: processMetadata,
      analysisTimestamp: DateTime.now(),
    );
  }

  Future<ProcessMetadata> _generateProcessMetadata(
    Recipe recipe,
    EnvironmentalConditions environment,
  ) async {
    // 믹싱 메타데이터 생성
    final mixing = MixingMeta(
      predictedTime: _calculateMixingTime(recipe),
      frictionHeat: _calculateFrictionHeat(recipe, environment),
      mixerTypeCoefficient: 1.05,
      glutenDevelopmentTarget: _calculateGlutenTarget(recipe),
      equipmentCalibration: 0.98,
    );

    // 발효 메타데이터 생성
    final fermentation = FermentationMeta(
      predictedTime: _calculateFermentationTime(recipe, environment),
      volumeIncrease: 2.5,
      microbialActivityCoefficient: 1.1,
      doughPhysicalChemicalCoefficient: 1.05,
      environmentalClimateCoefficient: environment.temperature > 25 ? 1.1 : 0.9,
      doughTypeCorrection: 1.0,
    );

    // 굽기 메타데이터 생성
    final baking = BakingMeta(
      temperatureProfile: BakingProfileGenerator.createStandardBreadProfile(),
      totalBakingTime: _calculateBakingTime(recipe),
      weightCorrection: 1.02,
      hydrationCorrection: recipe.hydrationPercentage > 70 ? 0.95 : 1.0,
      ovenEfficiency: environment.oven.ovenEfficiency,
      breadTypeCorrection: 1.0,
    );

    return ProcessMetadata(
      mixing: mixing,
      fermentation: fermentation,
      baking: baking,
    );
  }

  Future<Map<String, dynamic>> _performAdditionalAnalysis(
    Recipe recipe,
    BreadAnalysisData analysisData,
    Map<String, dynamic>? additionalParameters,
  ) async {
    final recommendations = <String, dynamic>{};
    final warnings = <String, dynamic>{};

    // 온도 분석
    if (additionalParameters?['analyzeTemperature'] == true) {
      recommendations['temperature'] =
          _analyzeTemperatureRequirements(recipe, analysisData);
    }

    // 시간 분석
    if (additionalParameters?['analyzeTiming'] == true) {
      recommendations['timing'] =
          _analyzeTimingOptimization(recipe, analysisData);
    }

    // 재료 상호작용 분석
    if (additionalParameters?['analyzeInteractions'] == true) {
      recommendations['interactions'] = _analyzeIngredientInteractions(recipe);
      warnings['interactions'] = _checkIngredientWarnings(recipe);
    }

    // 고급 품질 예측
    if (additionalParameters?['advancedQuality'] == true) {
      recommendations['quality'] =
          _generateAdvancedQualityRecommendations(recipe, analysisData);
    }

    return {
      'recommendations': recommendations,
      'warnings': warnings,
    };
  }

  Map<String, dynamic> _calculateDifferences(
    AnalysisResult result1,
    AnalysisResult result2,
  ) {
    return {
      'qualityScore': result2.predictedQuality.overallQualityScore -
          result1.predictedQuality.overallQualityScore,
      'volumeIndex': result2.predictedQuality.volumeIndex -
          result1.predictedQuality.volumeIndex,
      'confidenceScore': result2.confidenceScore - result1.confidenceScore,
      'estimatedDuration':
          result2.estimatedDuration - result1.estimatedDuration,
    };
  }

  List<String> _generateComparisonRecommendations(
    AnalysisResult result1,
    AnalysisResult result2,
  ) {
    final recommendations = <String>[];

    if (result2.predictedQuality.overallQualityScore >
        result1.predictedQuality.overallQualityScore) {
      recommendations.add('두 번째 레시피의 품질이 더 높습니다');
    }

    if (result2.confidenceScore > result1.confidenceScore) {
      recommendations.add('두 번째 레시피의 분석 신뢰도가 더 높습니다');
    }

    if (result2.estimatedDuration < result1.estimatedDuration) {
      recommendations.add('두 번째 레시피의 소요 시간이 더 짧습니다');
    }

    return recommendations;
  }

  // 계산 헬퍼 메소드들
  double _calculateMixingTime(Recipe recipe) {
    final flourAmount = recipe.flourAmount;
    if (flourAmount < 300) return 10.0;
    if (flourAmount < 600) return 15.0;
    if (flourAmount < 1000) return 20.0;
    return 25.0;
  }

  double _calculateFrictionHeat(
      Recipe recipe, EnvironmentalConditions environment) {
    final baseHeat = recipe.flourAmount * 0.002;
    final tempAdjustment = (environment.temperature - 20) * 0.1;
    return baseHeat + tempAdjustment;
  }

  double _calculateGlutenTarget(Recipe recipe) {
    final hydration = recipe.hydrationPercentage;
    if (hydration > 75) return 1.3;
    if (hydration > 65) return 1.2;
    return 1.1;
  }

  double _calculateFermentationTime(
      Recipe recipe, EnvironmentalConditions environment) {
    final yeastAmount = recipe.yeastAmount;
    final temp = environment.temperature;

    double baseTime = 120.0;

    if (yeastAmount < 2) baseTime *= 1.5;
    if (yeastAmount > 8) baseTime *= 0.7;

    if (temp > 28) baseTime *= 0.8;
    if (temp < 20) baseTime *= 1.3;

    return baseTime;
  }

  double _calculateBakingTime(Recipe recipe) {
    final weight = recipe.totalDoughWeight;
    if (weight < 500) return 35.0;
    if (weight < 800) return 45.0;
    if (weight < 1200) return 55.0;
    return 65.0;
  }

  Future<EnvironmentalConditions> _createDefaultEnvironment() async {
    // 실제로는 사용자 환경 설정이나 위치 기반으로 생성
    return EnvironmentalConditions(
      temperature: 25.0,
      humidity: 65.0,
      pressure: 1013.25,
      season: Season.spring,
      oven: OvenCharacteristics(
        type: OvenType.home,
        typeCoefficient: 0.95,
        calibrationIndex: 1.0,
        steamCapability: 0.0,
        hasConvection: false,
        maxTemperature: 250,
      ),
      altitude: 100,
    );
  }

  // 추가 분석 헬퍼 메소드들
  String _analyzeTemperatureRequirements(
      Recipe recipe, BreadAnalysisData analysisData) {
    final temp = analysisData.environment.temperature;
    if (temp < 18) return '실내 온도가 낮아 발효 시간이 길어질 수 있습니다. 온도를 높이거나 발효 시간을 연장하세요.';
    if (temp > 30) return '실내 온도가 높아 발효가 빨리 진행될 수 있습니다. 온도를 낮추거나 발효 시간을 단축하세요.';
    return '실내 온도가 적절합니다.';
  }

  String _analyzeTimingOptimization(
      Recipe recipe, BreadAnalysisData analysisData) {
    final totalTime = analysisData.processMetadata.totalEstimatedTime;
    if (totalTime.inHours > 8)
      return '총 소요 시간이 길어집니다. 이스트량을 늘려 발효 시간을 단축하는 것을 고려하세요.';
    if (totalTime.inHours < 3) return '총 소요 시간이 너무 짧습니다. 발효 시간을 늘려 품질을 향상시키세요.';
    return '총 소요 시간이 적절합니다.';
  }

  String _analyzeIngredientInteractions(Recipe recipe) {
    final flourType = recipe.flourType;
    final hydration = recipe.hydrationPercentage;

    if (flourType.contains('강력분') && hydration > 75) {
      return '강력분과 고수분의 조합이 좋습니다. 글루텐 형성이 잘 될 것입니다.';
    }

    if (flourType.contains('박력분') && hydration < 60) {
      return '박력분의 특성을 고려하여 수분량을 적절히 조정하세요.';
    }

    return '재료 조합이 적절합니다.';
  }

  List<String> _checkIngredientWarnings(Recipe recipe) {
    final warnings = <String>[];

    if (recipe.yeastPercentage > 3.0) {
      warnings.add('이스트량이 많아 빵 맛이 저하될 수 있습니다');
    }

    if (recipe.saltPercentage < 1.5) {
      warnings.add('소금량이 적어 빵 맛이 밋밋할 수 있습니다');
    }

    if (recipe.hydrationPercentage > 80) {
      warnings.add('수분량이 높아 반죽 관리가 어려울 수 있습니다');
    }

    return warnings;
  }

  String _generateAdvancedQualityRecommendations(
      Recipe recipe, BreadAnalysisData analysisData) {
    final score = analysisData.qualityMetadata.overallQualityScore;

    if (score < 60) {
      return '품질 점수가 낮습니다. 수분량, 이스트량, 소금량의 균형을 재검토하세요.';
    }

    if (score > 85) {
      return '품질 점수가 매우 높습니다. 현재 레시피를 유지하는 것이 좋습니다.';
    }

    return '품질 점수가 보통입니다. 세부 사항을 미세 조정하여 개선할 수 있습니다.';
  }

  // RPM 분석 통합 헬퍼 메소드들
  Future<BreadAnalysisData> _generateAnalysisDataFromRPMAnalysis(
    Recipe recipe,
    EnvironmentalConditions environment,
    Map<String, dynamic> rpmAnalysis,
  ) async {
    // 재료 메타데이터 생성
    final ingredientMetadata =
        IngredientMetadataGenerator.generateMetadataList(recipe.ingredients);

    // RPM 분석 결과를 반영한 품질 메타데이터
    final qualityMetadata = QualityMetadata(
      volumeIndex: _extractVolumeIndexFromRPM(rpmAnalysis),
      crustColorIndex: 0.8, // RPM 분석에서는 기본값 사용
      poreStructureScore: _extractPoreScoreFromRPM(rpmAnalysis),
      moistureRetention: 0.85,
    );

    // RPM 분석을 반영한 공정 메타데이터
    final processMetadata = ProcessMetadata(
      mixing: MixingMeta(
        predictedTime: _extractMixingTimeFromRPM(rpmAnalysis),
        frictionHeat: _extractFrictionHeatFromRPM(rpmAnalysis),
        mixerTypeCoefficient: 1.05,
        glutenDevelopmentTarget: _extractGlutenTargetFromRPM(rpmAnalysis),
        equipmentCalibration: 0.98,
      ),
      fermentation: FermentationMeta(
        predictedTime: 120.0, // 기본값
        volumeIncrease: 2.5,
        microbialActivityCoefficient: 1.1,
        doughPhysicalChemicalCoefficient: 1.05,
        environmentalClimateCoefficient:
            environment.temperature > 25 ? 1.1 : 0.9,
        doughTypeCorrection: 1.0,
      ),
      baking: BakingMeta(
        temperatureProfile: BakingProfileGenerator.createStandardBreadProfile(),
        totalBakingTime: 45.0,
        weightCorrection: 1.02,
        hydrationCorrection: recipe.hydrationPercentage > 70 ? 0.95 : 1.0,
        ovenEfficiency: environment.oven.ovenEfficiency,
        breadTypeCorrection: 1.0,
      ),
    );

    return BreadAnalysisData(
      recipe: recipe,
      environment: environment,
      ingredientMetadata: ingredientMetadata,
      qualityMetadata: qualityMetadata,
      processMetadata: processMetadata,
      analysisTimestamp: DateTime.now(),
    );
  }

  List<String> _extractRPMRecommendations(Map<String, dynamic> rpmAnalysis) {
    final recommendations = <String>[];

    // RPM 분석 결과를 기반으로 추천사항 추출
    final successProbability = rpmAnalysis['successProbability'] ?? 0.0;
    final riskLevel = rpmAnalysis['riskLevel'] ?? '';

    if (successProbability < 0.7) {
      recommendations.add('믹싱 설정을 최적화하여 성공 확률을 높이세요');
    }

    if (riskLevel.contains('높음')) {
      recommendations.add('믹서 속도와 시간을 재검토하세요');
    }

    final glutenIndex = rpmAnalysis['최종 글루텐 형성 지수'] ?? '0%';
    final glutenValue = double.tryParse(glutenIndex.replaceAll('%', '')) ?? 0.0;
    if (glutenValue < 70) {
      recommendations.add('글루텐 형성을 개선하기 위해 믹싱 시간을 늘리거나 속도를 조정하세요');
    }

    return recommendations;
  }

  List<String> _extractRPMWarnings(Map<String, dynamic> rpmAnalysis) {
    final warnings = <String>[];

    final issues = rpmAnalysis['issues'] as List<dynamic>? ?? [];
    final riskLevel = rpmAnalysis['riskLevel'] ?? '';

    if (issues.isNotEmpty) {
      warnings.addAll(issues.map((issue) => issue.toString()));
    }

    final riskLevelStr = riskLevel.toString();
    if (riskLevelStr.contains('높음') || riskLevelStr.contains('매우 높음')) {
      warnings.add('현재 믹싱 설정으로 실패 위험이 있습니다');
    }

    return warnings;
  }

  double _extractVolumeIndexFromRPM(Map<String, dynamic> rpmAnalysis) {
    final glutenIndex = rpmAnalysis['최종 글루텐 형성 지수'] ?? '70%';
    final glutenValue =
        double.tryParse(glutenIndex.replaceAll('%', '')) ?? 70.0;

    // 글루텐 형성도에 따른 부피 지수 계산
    if (glutenValue >= 90) return 2.8;
    if (glutenValue >= 80) return 2.5;
    if (glutenValue >= 70) return 2.2;
    if (glutenValue >= 60) return 1.8;
    return 1.5;
  }

  double _extractPoreScoreFromRPM(Map<String, dynamic> rpmAnalysis) {
    final glutenIndex = rpmAnalysis['최종 글루텐 형성 지수'] ?? '70%';
    final glutenValue =
        double.tryParse(glutenIndex.replaceAll('%', '')) ?? 70.0;

    // 글루텐 형성도에 따른 기공 구조 점수
    return glutenValue * 0.85; // 글루텐 형성도의 85%로 계산
  }

  double _extractMixingTimeFromRPM(Map<String, dynamic> rpmAnalysis) {
    final totalTime = rpmAnalysis['총 믹싱 시간'] ?? '18분';
    final timeValue = double.tryParse(totalTime.replaceAll('분', '')) ?? 18.0;
    return timeValue;
  }

  double _extractFrictionHeatFromRPM(Map<String, dynamic> rpmAnalysis) {
    final finalTemp = rpmAnalysis['최종 반죽 온도'] ?? '25.0°C';
    final tempValue = double.tryParse(finalTemp.replaceAll('°C', '')) ?? 25.0;
    final startTemp = 22.0; // 가정 시작 온도

    // 마찰열 계산: 최종온도 - 시작온도
    return (tempValue - startTemp).clamp(0.0, 10.0);
  }

  double _extractGlutenTargetFromRPM(Map<String, dynamic> rpmAnalysis) {
    final glutenIndex = rpmAnalysis['최종 글루텐 형성 지수'] ?? '70%';
    final glutenValue =
        double.tryParse(glutenIndex.replaceAll('%', '')) ?? 70.0;

    // 글루텐 형성도에 따른 목표 계수
    if (glutenValue >= 85) return 1.3;
    if (glutenValue >= 75) return 1.2;
    if (glutenValue >= 65) return 1.1;
    return 1.0;
  }
}

/// 분석 결과 비교 클래스
class AnalysisComparison {
  final AnalysisResult result1;
  final AnalysisResult result2;
  final Map<String, dynamic> differences;
  final List<String> recommendations;

  const AnalysisComparison({
    required this.result1,
    required this.result2,
    required this.differences,
    required this.recommendations,
  });

  String get summary {
    final scoreDiff = differences['qualityScore'] as double;
    final timeDiff = (differences['estimatedDuration'] as Duration).inMinutes;

    return '품질 차이: ${scoreDiff.toStringAsFixed(1)}점, '
        '시간 차이: ${timeDiff}분, '
        '추천사항: ${recommendations.length}개';
  }
}
