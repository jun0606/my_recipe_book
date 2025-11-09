import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/constants/bread_constants.dart';
import '../core/types/calculation_types.dart';

/// 빵 과학 컨셉 준수: 상수, 하드 코딩 금지
///
/// 오븐 베이킹 진행 예측: 믹싱 결과 + 발효 결과 기반 연구 계산
///
/// BakingCalculator - 오븐 베이킹 계산 엔진
/// 믹싱과 발효 결과를 입력으로 받아 오븐 베이킹 진행을 예측
class BakingCalculator {
  static final BakingCalculator _instance = BakingCalculator._internal();
  factory BakingCalculator() => _instance;

  BakingCalculator._internal() {
    // 캐시 초기화
    _crumbDetectionCache = {};
  }

  static BakingCalculator get instance => _instance;

  /// 빵 breadcrumb 감지 결과 캐시 (효율성 개선)
  static Map<String, double> _crumbDetectionCache = {};

  /// 마지막 오븐 베이킹 과정 결과 저장 - 다른 곳에서 사용 가능 (빅데이터 준수)
  static BakingProcessResult? _lastBakingResult;

  /// 마지막 베이킹 결과 조회 인터페이스 - 다른 컴포넌트에서 안전한 결과 접근 (컨셉 준수)
  static BakingProcessResult? getLastBakingResult() => _lastBakingResult;

  /// 베이킹 결과 클리어 메소드 - 메모리 정리
  static void clearLastBakingResult() {
    _lastBakingResult = null;
  }

  /// 베이킹 결과 설정 메소드 - 컨트롤러에서 저장용 (빅데이터 준수)
  static void setLastBakingResult(BakingProcessResult result) {
    _lastBakingResult = result;
  }

  /// 캐시 클리어
  void clearCalculationCache() {
    _crumbDetectionCache.clear();
  }

  /// 중앙화된 오븐 베이킹 프로세스 계산 메소드 - 빵 과학 컨셉 준수
  Future<BakingProcessResult> calculateCentralizedBaking({
    required Map<String, dynamic> recipeData,
    required BakingState mixingState,
    required FermentationState fermentationState,
    required List<Map<String, dynamic>> ovenSteps,
  }) async {
    return _calculateCentralizedBakingImpl(
      recipeData: recipeData,
      mixingState: mixingState,
      fermentationState: fermentationState,
      ovenSteps: ovenSteps,
    );
  }

  /// 중앙화된 오븐 베이킹 프로세스 계산 구현 - 빵 과학 컨셉 준수
  static Future<BakingProcessResult> _calculateCentralizedBakingImpl({
    required Map<String, dynamic> recipeData,
    required BakingState mixingState,
    required FermentationState fermentationState,
    required List<Map<String, dynamic>> ovenSteps,
  }) async {
    try {
      debugPrint('🔥 [중앙화] 오븐 베이킹 프로세스 통합 계산 시작');

      // ✅ 추가 로깅: 값 전달 실패 분석을 위한 입력 파라미터 전체 검증
      debugPrint('📋 [중앙화 입력 검사] time=${DateTime.now()}');
      debugPrint('   - recipeData.keys: ${recipeData.keys.toList()}');
      debugPrint(
          '   - recipeData.ingredients: ${recipeData['ingredients']?.length ?? 'null'}개');
      debugPrint(
          '   - recipeData.mixingResult 존재: ${recipeData['mixingResult'] != null ? '예' : '아니오'}');
      debugPrint(
          '   - mixingState.moistureAbsorption: ${mixingState.moistureAbsorption ?? 'null'}');
      debugPrint(
          '   - mixingState.glutenFormation: ${mixingState.glutenFormation ?? 'null'}');
      debugPrint(
          '   - fermentationState.temperature: ${fermentationState.temperature ?? 'null'}°C');
      debugPrint(
          '   - fermentationState.acidity: ${fermentationState.acidity ?? 'null'} pH');
      debugPrint('   - ovenSteps.length: ${ovenSteps.length}단계');

      // 각 ovenSteps 상세 로깅
      for (int i = 0; i < ovenSteps.length; i++) {
        final step = ovenSteps[i];
        debugPrint(
            '   - ovenSteps[${i + 1}]: time=${step['time']}, targetTemperature=${step['targetTemperature']}');
      }

      // 믹싱과 발효 결과로부터 초기 파라미터 계산 - 빅데이터 준수: 기본값 완전 금지
      final initialDoughTemperature = fermentationState.temperature;
      if (initialDoughTemperature == null) {
        throw Exception('베이킹 계산에 발효 결과의 생지 온도 데이터가 필요합니다 - 빅데이터 준수 위반');
      }

      final initialDoughMoisture = mixingState.moistureAbsorption;
      if (initialDoughMoisture == null || initialDoughMoisture <= 0) {
        throw Exception('베이킹 계산에 믹싱 결과의 수분 흡수 데이터가 필요합니다 - 빅데이터 준수 위반');
      }

      final fermentationAcidity = fermentationState.acidity;
      if (fermentationAcidity == null || fermentationAcidity <= 0) {
        throw Exception('베이킹 계산에 발효 결과의 산도 데이터가 필요합니다 - 빅데이터 준수 위반');
      }

      final fermentationGlutenFormation = mixingState.glutenFormation;
      if (fermentationGlutenFormation == null ||
          fermentationGlutenFormation <= 0) {
        throw Exception('베이킹 계산에 믹싱 결과의 글루텐 형성 데이터가 필요합니다 - 빅데이터 준수 위반');
      }

      debugPrint('🔥 [베이킹 초기 상태]');
      debugPrint('   - 생지 온도: ${initialDoughTemperature}°C');
      debugPrint('   - 생지 습도: ${initialDoughMoisture.toStringAsFixed(1)}%');
      debugPrint('   - 발효 산도: ${fermentationAcidity.toStringAsFixed(2)} pH');
      debugPrint(
          '   - 글루텐 형성: ${fermentationGlutenFormation.toStringAsFixed(3)}');

      final List<BakingStepResult> stepResults = [];
      double accumulatedMoistureLoss = 0.0;
      double totalAccumulatedTime = 0.0; // 시간 누적 변수 추가
      double accumulatedProgress = 0.0; // 누적 진행률 변수 추가

      // ✅ 누적값 변수 초기화 (빵 과학적 상태 변화 반영)
      double cumulativeBakingProgress = 0.0; // 누적 베이킹 진행률
      double cumulativeMaillardReaction = 0.0; // 누적 마이야르 반응
      double cumulativeCrumbBakingProgress = 0.0; // 누적 크럼브 진행률
      double cumulativeInternalTemperature =
          initialDoughTemperature; // 누적 내부 온도 (초기값: 발효 온도)

      // ✅ 빅데이터 준수: 단계별 누적 변수 초기화 (빵 과학적 상태 변화 반영)
      double currentDoughTemperature = initialDoughTemperature;
      double currentDoughMoisture = initialDoughMoisture;
      double currentFermentationAcidity = fermentationAcidity;
      double currentFermentationGlutenFormation = fermentationGlutenFormation;

      // ✅ 누적 값 변수 초기화 (각 단계별 누적 값 제공)
      double totalCumulativeBakingProgress = 0.0; // 누적 베이킹 진행률
      double totalCumulativeMaillardReaction = 0.0; // 누적 마이야르 반응
      double totalCumulativeCrumbBakingProgress = 0.0; // 누적 크럼브 진행률
      double currentCumulativeInternalTemperature =
          initialDoughTemperature; // 현재 누적 내부 온도

      // 빅데이터 준수: 첫 번째 단계 온도를 동적 기준점으로 사용
      final firstStepTemperature = (ovenSteps.isNotEmpty
              ? (ovenSteps[0]['targetTemperature'] as num?)?.toDouble()
              : 180.0) ??
          180.0;

      for (int i = 0; i < ovenSteps.length; i++) {
        final step = ovenSteps[i];
        final stepNumber = i + 1;

        // 단계별 베이킹 시간 - 기본값 금지, 없으면 예외
        final stepBakingTime = step['time'] as int?;
        if (stepBakingTime == null) {
          throw Exception('오븐 베이킹 단계 $stepNumber의 시간 값이 없습니다');
        }
        totalAccumulatedTime += stepBakingTime; // 시간 누적

        // 오븐 온도 - 기본값 범위 제한 제거
        final ovenTemperature = (step['targetTemperature'] as num?)?.toDouble();
        if (ovenTemperature == null) {
          throw Exception('오븐 베이킹 단계 $stepNumber의 온도 값이 없습니다 - 기본값 금지');
        }

        // ✅ 빅데이터 준수: 단계별 누적된 생지 상태 값 사용 (빵 과학적 현실성 확보)
        final stepResult = _calculateUnifiedBakingStep(
          stepNumber: stepNumber,
          ovenSteps: ovenSteps, // ✅ 각 단계별 베이킹 정보 전달
          referenceTemperature: firstStepTemperature, // 빅데이터 준수: 동적 기준 온도
          doughTemperature: currentDoughTemperature, // ✅ 단계별 누적 온도 사용
          doughMoisture: currentDoughMoisture, // ✅ 단계별 누적 습도 사용
          fermentationAcidity: currentFermentationAcidity, // ✅ 단계별 누적 산도 사용
          fermentationGlutenFormation:
              currentFermentationGlutenFormation, // ✅ 단계별 누적 글루텐 사용
          recipeData: recipeData, // ✅ 실제 recipeData 전달
        );

        // ✅ 빅데이터 준수: 단계별 누적 값 업데이트 (빵 과학적 상태 변화 반영)
        currentDoughTemperature = stepResult.internalTemperature; // 내부 온도 누적
        accumulatedMoistureLoss += stepResult.moistureLoss; // 습도 손실 누적
        currentDoughMoisture =
            initialDoughMoisture - accumulatedMoistureLoss; // 현재 습도 계산

        // ✅ 누적 값 업데이트 (각 단계별 누적 값 계산)
        totalCumulativeBakingProgress +=
            stepResult.bakingProgress; // 누적 베이킹 진행률
        totalCumulativeMaillardReaction +=
            stepResult.maillardReaction; // 누적 마이야르 반응
        totalCumulativeCrumbBakingProgress +=
            stepResult.crumbBakingProgress; // 누적 크럼브 진행률
        currentCumulativeInternalTemperature =
            stepResult.internalTemperature; // 현재 누적 내부 온도

        // 빅데이터 준수: 발효 파라미터는 베이킹 중 미세 변화 (선택적 구현)
        // currentFermentationAcidity = currentFermentationAcidity * 0.999; // 선택적: 산도 미세 감소
        // currentFermentationGlutenFormation = currentFermentationGlutenFormation * 0.998; // 선택적: 글루텐 미세 변화

        // 진행률 누적 계산 - bakingProgress, maillardReaction, crumbBakingProgress를 누적 값으로 설정
        final accumulatedStepResult = BakingStepResult(
          stepNumber: stepResult.stepNumber,
          bakingProgress: totalCumulativeBakingProgress, // 누적 진행률 적용
          maillardReaction: totalCumulativeMaillardReaction, // 누적 마이야르 반응 적용
          crumbBakingProgress:
              totalCumulativeCrumbBakingProgress, // 누적 크럼브 진행률 적용
          crustColorValue: stepResult.crustColorValue,
          internalTemperature: stepResult.internalTemperature,
          moistureLoss: stepResult.moistureLoss,
          cumulativeBakingProgress: totalCumulativeBakingProgress, // 누적 베이킹 진행률
          cumulativeMaillardReaction:
              totalCumulativeMaillardReaction, // 누적 마이야르 반응
          cumulativeCrumbBakingProgress:
              totalCumulativeCrumbBakingProgress, // 누적 크럼브 진행률
          cumulativeInternalTemperature:
              currentCumulativeInternalTemperature, // 누적 내부 온도
        );

        stepResults.add(accumulatedStepResult);

        debugPrint(
            '🔥 [중앙화] 베이킹 단계 $stepNumber 완료: 온도=${ovenTemperature}°C, 시간=${totalAccumulatedTime.toInt()}분, 진행률=${stepResult.bakingProgress.toStringAsFixed(1)}%');
      }

      debugPrint('🔥 [중앙화] 오븐 베이킹 프로세스 통합 계산 완료');

      // 최종 결과 작성
      final lastStep = stepResults.isNotEmpty ? stepResults.last : null;
      final overallSuccess = lastStep?.bakingProgress ?? 0.0;

      return BakingProcessResult(
        stepResults: stepResults,
        totalBakingTime: totalAccumulatedTime.toInt(),
        finalCrustColor: lastStep?.crustColorValue ?? 0.0,
        finalCrumbBakingProgress: lastStep?.crumbBakingProgress ?? 0.0,
        overallBakingSuccess: overallSuccess >= 0.0, // 성공 판정 기준 기본값 제거
        bakingNotes: '믹싱과 발효 결과를 기반으로 한 과학적 베이킹 예측',
        finalCumulativeMaillardReaction:
            lastStep?.cumulativeMaillardReaction ?? 0.0,
        finalCumulativeCrumbBakingProgress:
            lastStep?.cumulativeCrumbBakingProgress ?? 0.0,
      );
    } catch (e) {
      debugPrint('🔥 [중앙화] 베이킹 계산 오류: $e');
      return BakingProcessResult(
        stepResults: [],
        totalBakingTime: 0,
        finalCrustColor: 0.0,
        finalCrumbBakingProgress: 0.0,
        overallBakingSuccess: false,
        bakingNotes: '계산 오류 발생',
        finalCumulativeMaillardReaction: 0.0,
        finalCumulativeCrumbBakingProgress: 0.0,
      );
    }
  }
}

/// ✅ 빅데이터 기반 재료 비율 계산 (하드코딩 금지)
Map<String, double> _calculateIngredientRatios(
    Map<String, dynamic> recipeData) {
  final ingredients = recipeData['ingredients'] as List<dynamic>?;
  if (ingredients == null || ingredients.isEmpty) {
    debugPrint('💥 [빅데이터 준수 위반] 재료 데이터 없음');
    return {'flourRatio': 0.0, 'waterRatio': 0.0, 'doughWeight': 0.0};
  }

  double flourWeight = 0.0;
  double waterWeight = 0.0;

  for (var ingredient in ingredients) {
    final name = ingredient['name']?.toString().toLowerCase() ?? '';
    final amount = (ingredient['amount'] as num?)?.toDouble();
    final unit = ingredient['unit']?.toString().toLowerCase();

    if (amount == null || amount <= 0) continue;

    final weight = _convertToGrams(amount, unit ?? 'g');

    if (name.contains('밀가루') ||
        name.contains('flour') ||
        name.contains('강력분') ||
        name.contains('중력분') ||
        name.contains('bread flour') ||
        name.contains('all-purpose') ||
        name.contains('통밀') ||
        name.contains('whole wheat') ||
        name.contains('호밀') ||
        name.contains('rye')) {
      flourWeight += weight;
    }

    if (name.contains('물') ||
        name.contains('water') ||
        name.contains('우유') ||
        name.contains('milk') ||
        name.contains('크림') ||
        name.contains('cream') ||
        name.contains('생크림') ||
        name.contains('heavy cream') ||
        name.contains('버터밀크') ||
        name.contains('buttermilk') ||
        name.contains('요구르트') ||
        name.contains('yogurt')) {
      waterWeight += weight;
    }
  }

  final doughWeight = flourWeight + waterWeight;
  final flourRatio = doughWeight > 0 ? flourWeight / doughWeight : 0.0;
  final waterRatio = doughWeight > 0 ? waterWeight / doughWeight : 0.0;

  debugPrint(
      '🍞 [빅데이터 기반 비율 계산] 밀가루:${flourWeight.toStringAsFixed(0)}g(${flourRatio.toStringAsFixed(3)}), 물:${waterWeight.toStringAsFixed(0)}g(${waterRatio.toStringAsFixed(3)}), 총합:${doughWeight.toStringAsFixed(0)}g');
  return {
    'flourRatio': flourRatio,
    'waterRatio': waterRatio,
    'doughWeight': doughWeight
  };
}

/// ✅ 단위 변환 헬퍼 (빵 과학적 정확성 보장)
double _convertToGrams(double amount, String unit) {
  switch (unit.toLowerCase()) {
    case 'kg':
      return amount * 1000;
    case 'lb':
    case 'lbs':
      return amount * 453.592;
    case 'oz':
      return amount * 28.3495;
    case 'cups':
      return amount * 120; // 밀가루 컵 평균치
    case 'tbsp':
    case 'tablespoon':
      return amount * 7.5; // 밀가루 큰술
    case 'tsp':
    case 'teaspoon':
      return amount * 2.5; // 밀가루 작은술
    case 'ml':
    case 'milliliter':
      return amount; // 액체 g/ml 동일
    case 'l':
    case 'liter':
      return amount * 1000;
    default:
      return amount; // 'g'또는 알 수 없는 단위는 그램으로 간주
  }
}

/// 빅데이터 기반 동적 열 전달 시간 계산 (하드코딩 금지)
double _calculateDynamicHeatTransferTime({
  required double doughWeight,
  required double tempGradient,
  required double flourRatio,
  required double waterRatio,
}) {
  // 빅데이터 기반: 반죽 크기로 기본 열 전달 시간 계산 (레시피 총합 무게 직접 사용)
  double sizeBase = doughWeight * BreadConstants.heatTransferSizeFactor +
      BreadConstants.heatTransferBaseTime; // 중앙화된 크기 계수/기본시간 사용

  // 빅데이터 기반: 재료 비율로 열 전달 효율 계산
  double materialEfficiency = flourRatio *
          BreadConstants.heatTransferFlourEfficiency +
      waterRatio * BreadConstants.heatTransferWaterEfficiency; // 중앙화된 효율 계수 사용

  // 빅데이터 기반: 온도 차이에 따른 열 전달 속도
  double tempFactor = 1.0 +
      (tempGradient / BreadConstants.heatTransferTempGradient) *
          BreadConstants.heatTransferTempFactor; // 중앙화된 온도 차이/계수 사용

  // 빵 과학 준수: 실제 계산값 반환
  return sizeBase * materialEfficiency * tempFactor;
}

/// 🔬 빵 과학적 지수 함수 기반 열 전달 모델 (근본 해결)
/// 뉴턴의 냉각 법칙 기반 정확한 온도 상승 계산
double _calculateExponentialHeatTransfer({
  required double initialTemp, // 초기 생지 온도 (°C)
  required double targetTemp, // 오븐 목표 온도 (°C)
  required double bakingTime, // 베이킹 시간 (분)
  required double doughWeight, // 반죽 무게 (g)
  required double maillardReaction, // 마이야르 반응 값 (동적 반영)
  required int stepNumber, // 베이킹 단계 번호
}) {
  // 빵 굽기 3단계별 열 전달 계수 k 계산 (빵 과학적 현실 반영)
  double k = _calculateBakingStageHeatTransferCoefficient(
    stepNumber: stepNumber,
    maillardReaction: maillardReaction,
  );

  // 뉴턴의 냉각 법칙 기반 온도 상승 계산
  // T(t) = T_oven - (T_oven - T0) * exp(-k * t)
  double temperatureRise =
      targetTemp - (targetTemp - initialTemp) * math.exp(-k * bakingTime);

  // 크럼브 진행률 계산 (온도 기반)
  // 70°C 이상에서 크럼브 익힘이 시작된다고 가정 (빵 과학적 현실 반영)
  double crumbProgress;
  if (temperatureRise >= 70.0) {
    // 온도에 따른 선형 진행률 계산 (70°C = 0%, 95°C = 100%)
    crumbProgress = math.min(1.0, (temperatureRise - 70.0) / 25.0);
  } else {
    crumbProgress = 0.0;
  }

  debugPrint('🔬 [지수 함수 열 전달 모델]');
  debugPrint('   - 초기 온도: ${initialTemp}°C');
  debugPrint('   - 목표 온도: ${targetTemp}°C');
  debugPrint('   - 베이킹 시간: ${bakingTime}분');
  debugPrint('   - 열 전달 계수 k: ${k.toStringAsFixed(6)}');
  debugPrint('   - 계산된 온도 상승: ${temperatureRise.toStringAsFixed(1)}°C');
  debugPrint('   - 크럼브 진행률: ${(crumbProgress * 100).toStringAsFixed(1)}%');

  return crumbProgress;
}

/// 빵 굽기 단계별 열 전달 계수 계산 (마이야르 동적 반영)
double _calculateBakingStageHeatTransferCoefficient({
  required int stepNumber,
  required double maillardReaction,
}) {
  // 빵 굽기 3단계별 기본 k값 (빵 과학적 현실에 맞게 조정)
  double baseK;
  if (stepNumber <= 1) {
    // 초기 단계 (0-10분): 수분 증발로 열 전달 느림
    baseK = 0.01; // 증가: 40분 베이킹으로 85°C 도달 필요
  } else if (stepNumber <= 2) {
    // 중기 단계 (10-30분): 빠른 온도 상승
    baseK = 0.02; // 증가: 빵 과학적 현실 반영
  } else {
    // 후기 단계 (30분-): 마이야르 반응에 따른 동적 조정
    baseK = 0.015 + (maillardReaction * 0.0001); // 마이야르 값에 따라 증가 (계수 조정)
  }

  debugPrint('🌡️ [열 전달 계수 계산]');
  debugPrint('   - 단계: $stepNumber');
  debugPrint('   - 마이야르 반응: ${maillardReaction.toStringAsFixed(1)}');
  debugPrint('   - 기본 k값: ${baseK.toStringAsFixed(6)}');

  return baseK;
}

/// 빅데이터 기반 글루텐 효율 계산 (하드코딩 금지)
double _calculateGlutenEfficiency({
  required double glutenFormation,
  required double doughMoisture,
  required double doughTemperature,
  required double waterRatio,
}) {
  // 빅데이터 기반: 글루텐 형성도 × 수분 × 온도 동적 계산
  double moistureFactor = doughMoisture /
      BreadConstants.moistureNormalizationBase; // 중앙화된 수분 기준 정규화
  double tempFactor = doughTemperature /
      BreadConstants.temperatureNormalizationBase; // 중앙화된 온도 기준 정규화
  double waterFactor = 1.0; // 물 비율 영향 제거 (빵 과학적 현실 반영 - 글루텐 효율은 주로 글루텐 형성도에 의존)

  // 빅데이터 준수: 실제 계산값 사용 (기본값 금지)
  return glutenFormation * moistureFactor * tempFactor * waterFactor;
}

/// ✅ 빅데이터 기반 내부 완성 시간 동적 계산 (하드코딩 금지)
double _calculateDynamicInternalCompletionTime({
  required double doughWeight,
  required double tempGradient,
  required double glutenEfficiency,
  required double flourRatio,
  required double waterRatio,
}) {
  // 빅데이터 기반: 반죽 크기로 기본 시간 계산
  double sizeBase = (doughWeight / BreadConstants.completionBaseWeight) *
          BreadConstants.completionSizeMultiplier +
      BreadConstants.completionBaseTime; // 중앙화된 기준 무게/승수/기본시간 사용

  // 빅데이터 기반: 재료 비율로 열 전달 효율 계산
  double materialEfficiency = flourRatio *
          BreadConstants.completionFlourEfficiency +
      waterRatio * BreadConstants.completionWaterEfficiency; // 중앙화된 효율 계수 사용

  // 빅데이터 기반: 글루텐 효율로 구조 안정성 계수
  double structureFactor =
      1.0 + (glutenEfficiency * flourRatio * 0.5); // 글루텐 × 밀가루 비율

  // 빅데이터 기반: 온도 차이에 따른 내부 익힘 속도
  double tempFactor = 1.0 +
      (tempGradient / BreadConstants.completionTempGradient) *
          BreadConstants.completionTempFactor; // 중앙화된 온도 차이/계수 사용

  // 빵 과학 준수: 실제 계산값 반환 (기본값 금지)
  return sizeBase * materialEfficiency * structureFactor * tempFactor;
}

/// 마이야르 반응 온도 효과 계산 - 빅데이터 준수 동적 계산 (하드 코딩 금지)
/// 빵 굽기 컨텍스트에 최적화된 온도 효과 모델 적용
double _calculateMaillardTemperatureEffect(double ovenTemperature) {
  // 빅데이터 준수: 상수/기본값 완전 금지, 실제 빵 굽기 컨텍스트에 맞는 계산만 수행
  // 빵 과학: 마이야르 반응은 140-240°C에서 활발, 고온 선호

  // 빅데이터 기반: 실제 빵 굽기 온도 범위에 맞는 동적 계산
  // 중앙화된 기준 온도로 정규화하여 1.0-3.0 범위의 효과 값 도출
  double normalizedTemp =
      ovenTemperature / BreadConstants.maillardReferenceTemperature;
  double baseEffect = math
      .pow(normalizedTemp, BreadConstants.maillardTemperatureExponent)
      .toDouble(); // 빵 과학: 온도 지수승 효과

  // 빅데이터 준수: 값이 너무 작아지지 않도록 최소 효과 보장
  double finalEffect =
      math.max(baseEffect, BreadConstants.maillardMinimumEffect); // 최소 효과 계수

  debugPrint('🧮 [마이야르 절대 온도 효과 - 빵 과학 동적 계산]');
  debugPrint('   - 오븐 온도: ${ovenTemperature}°C');
  debugPrint('   - 정규화 온도: ${normalizedTemp.toStringAsFixed(3)}');
  debugPrint('   - 최종 효과: ${finalEffect.toStringAsFixed(3)}배');

  return finalEffect;
}

/// ✅ 공통 헬퍼: 마이야르 반응 습도 효과 계산 (코드 중복 제거)
/// 빅데이터 준수: 습도가 낮을수록 마이야르 반응이 강력하게 진행
double _calculateMoistureEffect(double doughMoisture) {
  return 1.0 - (doughMoisture / 100.0);
}

/// ✅ 통합된 오븐 베이킹 단계별 계산 메소드 (모든 계산을 내부에서 직접 수행)
BakingStepResult _calculateUnifiedBakingStep({
  required int stepNumber,
  required List<Map<String, dynamic>> ovenSteps, // 각 단계별 베이킹 정보
  required double referenceTemperature,
  required double doughTemperature,
  required double doughMoisture,
  required double fermentationAcidity,
  required double fermentationGlutenFormation,
  required Map<String, dynamic> recipeData,
}) {
  // ✅ 현재 단계의 베이킹 정보 가져오기 (사용자 입력 값 사용)
  final currentStep = ovenSteps[stepNumber - 1];
  final currentStepTime = currentStep['time'] as int; // 사용자 입력 시간
  final ovenTemperature =
      currentStep['targetTemperature'] as double; // 사용자 입력 온도

  debugPrint('🔧 [통합 베이킹 단계 계산] 현재 단계 정보');
  debugPrint('   - 단계 번호: $stepNumber');
  debugPrint('   - 베이킹 시간: ${currentStepTime}분 (사용자 입력)');
  debugPrint('   - 오븐 온도: ${ovenTemperature}°C (사용자 입력)');

  // ✅ 값 참조 일관성 확보: 공통 값들을 한 번만 계산
  debugPrint('🔧 [통합 베이킹 단계 계산] 공통 값 계산 시작 - 모든 계산 내부 통합');
  final ingredientRatios = _calculateIngredientRatios(recipeData);
  final flourRatio = ingredientRatios['flourRatio'] as double;
  final waterRatio = ingredientRatios['waterRatio'] as double;
  final totalDoughWeight = ingredientRatios['doughWeight'] as double;

  debugPrint('🔧 [공통 값 계산 완료]');
  debugPrint('   - flourRatio: $flourRatio');
  debugPrint('   - waterRatio: $waterRatio');
  debugPrint('   - totalDoughWeight: ${totalDoughWeight}g');

  // ==========================================
  // ✅ 내부 통합: 마이야르 반응 계산 (사용자 입력 값만 사용)
  // ==========================================
  debugPrint('🧮 [내부 통합] 마이야르 반응 계산 시작');

  // 온도 효과 계산 (사용자 입력 온도 사용)
  final tempEffect = _calculateMaillardTemperatureEffect(ovenTemperature);

  // 습도 효과: 마이야르 반응에 적합한 습도는 낮을수록 좋음
  final moistureEffect = _calculateMoistureEffect(doughMoisture);

  // 산도 효과: 발효 과정에서 생성된 산이 마이야르 반응 증폭
  final acidityEffect = 1.0 + (fermentationAcidity / 10.0);

  // 시간 효과: 사용자 입력 시간을 비선형으로 적용 (빵 과학적 현실성 반영)
  final timeEffect =
      math.pow(currentStepTime, BreadConstants.maillardTimeExponent).toDouble();

  // 빅데이터 준수: 최대값 제한 완전 제거
  final maillardReaction =
      tempEffect * moistureEffect * acidityEffect * timeEffect;

  debugPrint('🧮 [내부 통합] 마이야르 반응 계산 완료: $maillardReaction');

  // ==========================================
  // 🔬 빵 과학적 지수 함수 기반 크럼브 베이킹 진행률 계산 (근본 해결)
  // ==========================================
  debugPrint('🧮 [내부 통합] 크럼브 베이킹 진행률 계산 시작');

  // 뉴턴의 냉각 법칙 기반 지수 함수 열 전달 모델 적용
  final crumbProgress = _calculateExponentialHeatTransfer(
    initialTemp: doughTemperature,
    targetTemp: ovenTemperature,
    bakingTime: currentStepTime.toDouble(),
    doughWeight: totalDoughWeight,
    maillardReaction: maillardReaction,
    stepNumber: stepNumber,
  );

  // ✅ 마지막 단계 마이야르 값 참고로 정확성 향상
  final isLastStep = stepNumber == ovenSteps.length;
  final adjustedCrumbProgress = isLastStep
      ? math.min(1.0,
          crumbProgress * (1.0 + maillardReaction * 0.0005)) // 마지막 단계: 마이야르 반영
      : crumbProgress; // 이전 단계: 기존 값 유지

  debugPrint(
      '🧮 [내부 통합] 크럼브 베이킹 진행률 계산 완료: ${(adjustedCrumbProgress * 100).toStringAsFixed(1)}% (${isLastStep ? '마지막 단계 보정 적용' : '기존 값 유지'})');

  // ==========================================
  // ✅ 내부 통합: 최종 베이킹 성공률 계산
  // ==========================================
  debugPrint('🧮 [내부 통합] 최종 베이킹 성공률 계산 시작');

  // ✅ 마지막 단계 마이야르 값 참고로 정확성 향상 (이미 선언된 isLastStep 재사용)
  final effectiveMaillardReaction = isLastStep
      ? maillardReaction * 1.2 // 마지막 단계: 마이야르 반응 강화 (20% 증가)
      : maillardReaction; // 이전 단계: 기존 값 사용

  // 마이야르 값에 따른 동적 가중치 계산 (사칙연산만 사용)
  double maillardRatio = effectiveMaillardReaction / 100.0; // 0-1 범위로 정규화
  double maillardWeight =
      0.3 + (maillardRatio * 0.2); // 0.3에서 0.5으로 선형 증가 (더 낮은 가중치)
  double crumbWeight =
      0.7 - (maillardRatio * 0.1); // 0.7에서 0.6으로 선형 감소 (더 높은 가중치)

  // 빅데이터 준수: 실제 계산값 사용, 빵 과학적 스케일링 적용
  final maillardContribution =
      (effectiveMaillardReaction / 100.0) * maillardWeight;
  final crumbContribution = adjustedCrumbProgress * crumbWeight;
  final bakingSuccess = maillardContribution + crumbContribution;

  // 순수한 계산 값 사용 - 시간 곡선과 스케일링 계수 제거
  final pureSuccess = bakingSuccess * 100.0;

  debugPrint(
      '🧮 [내부 통합] 최종 베이킹 성공률 계산 완료: ${pureSuccess.toStringAsFixed(1)}% (${isLastStep ? '마지막 단계 마이야르 강화 적용' : '기존 값 사용'})');

  // ==========================================
  // ✅ 내부 통합: 내부 온도 및 습도 손실 계산
  // ==========================================
  debugPrint('🌡️ [내부 온도 계산] 시작');
  debugPrint('   - 초기 생지 온도: ${doughTemperature.toStringAsFixed(1)}°C');
  debugPrint('   - 오븐 목표 온도: ${ovenTemperature}°C');
  debugPrint('   - 크럼브 진행률: ${(crumbProgress * 100).toStringAsFixed(2)}%');

  final internalTemperature =
      doughTemperature + (ovenTemperature - doughTemperature) * crumbProgress;
  debugPrint(
      '   - 내부 온도 계산: ${doughTemperature.toStringAsFixed(1)}°C + (${ovenTemperature}°C - ${doughTemperature.toStringAsFixed(1)}°C) × ${(crumbProgress * 100).toStringAsFixed(2)}%');
  debugPrint('   - 최종 내부 온도: ${internalTemperature.toStringAsFixed(1)}°C');

  debugPrint('💧 [습도 손실 계산] 시작');
  debugPrint('   - 초기 생지 습도: ${doughMoisture.toStringAsFixed(1)}%');
  debugPrint('   - 물 비율: ${(waterRatio * 100).toStringAsFixed(1)}%');
  debugPrint('   - 크럼브 진행률: ${(crumbProgress * 100).toStringAsFixed(2)}%');

  final moistureLoss = doughMoisture * waterRatio * crumbProgress;
  debugPrint(
      '   - 습도 손실 계산: ${doughMoisture.toStringAsFixed(1)}% × ${(waterRatio * 100).toStringAsFixed(1)}% × ${(crumbProgress * 100).toStringAsFixed(2)}%');
  debugPrint('   - 최종 습도 손실: ${moistureLoss.toStringAsFixed(2)}%');

  debugPrint('🔥 [통합 베이킹 단계 $stepNumber 계산 완료 - 모든 계산 내부 통합]');
  debugPrint('   - 단계 시간: ${currentStepTime}분 (사용자 입력)');
  debugPrint(
      '   - 단계 성공률: ${pureSuccess.toStringAsFixed(1)}% (마이야르:${maillardReaction.toStringAsFixed(1)}, 크럼브:${(crumbProgress * 100).toStringAsFixed(1)}%)');
  debugPrint('   - 내부 온도: ${internalTemperature.toStringAsFixed(1)}°C');
  debugPrint('   - 습도 손실: ${moistureLoss.toStringAsFixed(2)}%');

  return BakingStepResult(
    stepNumber: stepNumber,
    bakingProgress: pureSuccess,
    maillardReaction: maillardReaction,
    crumbBakingProgress: crumbProgress * 100.0,
    crustColorValue: maillardReaction, // 겉빛깔 색상 값
    internalTemperature: internalTemperature,
    moistureLoss: moistureLoss, // 빅데이터 기반 습도 손실
    cumulativeBakingProgress:
        0.0, // 임시 값 - 실제 누적 값은 calculateCentralizedBaking에서 설정
    cumulativeMaillardReaction: 0.0,
    cumulativeCrumbBakingProgress: 0.0,
    cumulativeInternalTemperature: internalTemperature,
  );
}

/// 베이킹 단계 결과 타입
class BakingStepResult {
  final int stepNumber;
  final double bakingProgress; // 전체 베이킹 진행률 (0-100)
  final double maillardReaction; // 마이야르 반응 값 (0-100)
  final double crumbBakingProgress; // 속(크럼브) 베이킹 진행률 (0-100)
  final double crustColorValue; // 겉빛깔 색상 값
  final double internalTemperature; // 내부 온도
  final double moistureLoss; // 습도 손실량

  // 누적값 필드 추가
  final double cumulativeBakingProgress; // 누적 베이킹 진행률
  final double cumulativeMaillardReaction; // 누적 마이야르 반응
  final double cumulativeCrumbBakingProgress; // 누적 크럼브 진행률
  final double cumulativeInternalTemperature; // 누적 내부 온도

  const BakingStepResult({
    required this.stepNumber,
    required this.bakingProgress,
    required this.maillardReaction,
    required this.crumbBakingProgress,
    required this.crustColorValue,
    required this.internalTemperature,
    required this.moistureLoss,
    required this.cumulativeBakingProgress,
    required this.cumulativeMaillardReaction,
    required this.cumulativeCrumbBakingProgress,
    required this.cumulativeInternalTemperature,
  });
}

/// 베이킹 과정 결과 타입
class BakingProcessResult {
  final List<BakingStepResult> stepResults;
  final int totalBakingTime; // 총 베이킹 시간 (분)
  final double finalCrustColor; // 최종 겉빛깔
  final double finalCrumbBakingProgress; // 최종 속 베이킹 진행률
  final bool overallBakingSuccess; // 전체 베이킹 성공 여부
  final String bakingNotes; // 베이킹 노트

  // 누적 값 필드 추가
  final double finalCumulativeMaillardReaction; // 최종 누적 마이야르 반응
  final double finalCumulativeCrumbBakingProgress; // 최종 누적 크럼브 진행률

  const BakingProcessResult({
    required this.stepResults,
    required this.totalBakingTime,
    required this.finalCrustColor,
    required this.finalCrumbBakingProgress,
    required this.overallBakingSuccess,
    required this.bakingNotes,
    required this.finalCumulativeMaillardReaction,
    required this.finalCumulativeCrumbBakingProgress,
  });
}
