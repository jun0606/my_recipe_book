/// 단계별 수분 흡수율 계산 서비스
/// 사용자 레시피의 고체 재료 총합과 수분 재료 총합을 기반으로 실제 수분 흡수량을 계산합니다.
///
//// ✅ 새로운 계산 방식:
/// - 고체 재료 총합 (수분 흡수 기질): 밀가루, 호밀가루 등
/// - 수분 재료 총합 (수분 공급원): 물, 우유, 크림 등
/// - 단계별 실제 흡수량 계산: 믹싱 단계, 속도, 시간을 고려
/// - 물리적 한계 준수: 수분 흡수량은 수분 재료 총량을 초과할 수 없음
///
/// ✅ 정리된 메소드들:
/// - calculateBaseMoistureAbsorption: 기존 호환성 유지
/// - calculateDynamicAbsorption: 동적 단계별 계산
/// - calculateSolidIngredientsTotal: 고체 재료 총합 계산
/// - calculateMoistureIngredientsTotal: 수분 재료 총합 계산
/// - calculateStepActualMoistureAbsorption: 단계별 실제 흡수량 계산
/// - calculateRecipeMoistureLimit: 물리적 한계 계산
/// - formatMoisturePercentage: UI 표시용 포맷팅
/// - getActualMoistureValue: 실제 값 반환

import 'ingredient_analyzer.dart';
import '../core/types/environment_types.dart';

class MoistureCalculator {
  /// 중앙화된 동적 수분 흡수율 계산 (빵 제조 과학 준수)
  /// 컨트롤러에서 직접 계산하던 로직을 중앙화
  static double calculateDynamicMoistureAbsorption({
    required double currentRemainingMoisture,
    required double totalFlourWeight,
  }) {
    try {
      print('💧 [중앙화된 수분 계산] 동적 수분 흡수율 계산 진행');

      // ✅ 물리법칙 준수의 수분 흡수율 계산
      final moistureAbsorptionPercentage = totalFlourWeight > 0
          ? (currentRemainingMoisture / totalFlourWeight) * 100
          : 65.0;

      print(
          '   📐 계산식: ${(currentRemainingMoisture).toStringAsFixed(1)}g ÷ ${totalFlourWeight.toStringAsFixed(1)}g × 100');
      print('   ✨ 계산 결과: ${moistureAbsorptionPercentage.toStringAsFixed(3)}%');

      // ✅ 빵 제조 과학적 범위 제한 (30%-90%)
      final clampedResult = moistureAbsorptionPercentage.clamp(30.0, 90.0);

      if (clampedResult != moistureAbsorptionPercentage) {
        print('   ⚖️ 빵 제조 과학적 범위 제한 적용: ${clampedResult.toStringAsFixed(1)}%');
      }

      return clampedResult;
    } catch (e) {
      print('❌ [중앙화된 수분 계산 실패]: $e');
      return 65.0; // 빵 제조 안전 범위 기본값
    }
  }

  /// 기존 방식과의 호환성을 위한 메소드 (새로운 방식으로 리다이렉트)
  static double calculateBaseMoistureAbsorption(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    try {
      print('🔄 [기존 방식 호환] calculateBaseMoistureAbsorption 호출됨');
      print('   - 새로운 방식으로 리다이렉트합니다');

      // 새로운 방식으로 계산
      final solidTotal = calculateSolidIngredientsTotal(ingredients);
      final moistureTotal = calculateMoistureIngredientsTotal(ingredients);

      if (solidTotal <= 0) {
        print('⚠️ [기존 방식 호환] 고체 재료가 없음');
        return 0.0;
      }

      if (moistureTotal <= 0) {
        print('⚠️ [기존 방식 호환] 수분 재료가 없음');
        return 0.0;
      }

      // 기본 수분 흡수율 계산: (수분 총량 / 고체 총량) × 100
      final baseMoisture = (moistureTotal / solidTotal) * 100;

      print('✅ [기존 방식 호환] 계산 완료: ${baseMoisture.toStringAsFixed(1)}%');
      return baseMoisture;
    } catch (e) {
      print('❌ [기존 방식 호환] 오류: $e');
      // 오류 시 기존 방식으로 폴백
      return IngredientAnalyzer.calculateRealisticHydration(ingredients,
          recipeTitle: recipeTitle);
    }
  }

  /// 마찰열 기반 수분 증발 계산 메소드
  /// 빵 제조 과학적으로 마찰열은 수분 흡수율을 크게 저해하는 요소
  static double calculateFrictionHeatImpactOnMoisture({
    required String speed,
    required int duration,
    required double currentMoistureAbsorption,
    required double environmentTemperature,
    required double environmentHumidity,
    required int mixerTypeIndex,
  }) {
    try {
      // 1. 마찰열 계산
      final frictionHeat = calculateFrictionHeatFromSpeedAndTime(
        speed: speed,
        duration: duration,
        environmentTemperature: environmentTemperature,
        mixerTypeIndex: mixerTypeIndex,
      );

      // 2. 증발률 계산 (마찰열 + 환경 영향)
      final evaporationRate = calculateEvaporationRate(
        frictionHeat: frictionHeat,
        environmentHumidity: environmentHumidity,
        speed: speed,
      );

      // 3. 수분 흡수율 보정 적용
      final correctedMoistureAbsorption =
          currentMoistureAbsorption * (1.0 - evaporationRate);

      print('🔥 [마찰열 수분 영향 계산]');
      print('   - 속도: $speed, 시간: ${duration}분');
      print('   - 마찰열: ${frictionHeat.toStringAsFixed(1)}°C');
      print('   - 증발률: ${(evaporationRate * 100).toStringAsFixed(1)}%');
      print('   - 원본 수분: ${currentMoistureAbsorption.toStringAsFixed(1)}%');
      print('   - 보정 수분: ${correctedMoistureAbsorption.toStringAsFixed(1)}%');

      return correctedMoistureAbsorption;
    } catch (e) {
      print('❌ [마찰열 수분 영향 계산 실패]: $e');
      return currentMoistureAbsorption;
    }
  }

  /// 속도와 시간 기반 마찰열 계산
  /// 빵 제조 과학적 실제 값 적용
  static double calculateFrictionHeatFromSpeedAndTime({
    required String speed,
    required int duration,
    required double environmentTemperature,
    required int mixerTypeIndex,
  }) {
    // 기본 마찰열 계수 (빵 제조 과학적 데이터 기반)
    double baseHeatPerMinute;
    switch (speed) {
      case '저속':
        baseHeatPerMinute = 0.5; // 저속: 적은 마찰열
        break;
      case '중속':
        baseHeatPerMinute = 1.0; // 중속: 표준 마찰열
        break;
      case '고속':
        baseHeatPerMinute = 1.7; // 고속: 높은 마찰열
        break;
      default:
        baseHeatPerMinute = 1.0; // 기본값
    }

    // 믹서 타입별 조정 (가정용, 상업용, 전문가용)
    switch (mixerTypeIndex) {
      case 0: // 가정용
        baseHeatPerMinute *= 0.8;
        break;
      case 1: // 상업용
        baseHeatPerMinute *= 1.2;
        break;
      case 2: // 전문가용
        baseHeatPerMinute *= 1.5;
        break;
    }

    // 시간 적용
    final totalHeat = baseHeatPerMinute * duration;

    // 환경 온도 보정 (뜨거운 환경에서는 추가 마찰열 증가)
    final temperatureCorrection = (environmentTemperature - 20.0) * 0.1;
    final correctedHeat = totalHeat + temperatureCorrection;

    return correctedHeat.clamp(0.0, 25.0); // 현실적 범위 제한
  }

  /// 증발률 계산 (마찰열 + 환경 습도 영향)
  /// 수분 흡수율 감소의 핵심 메커니즘
  static double calculateEvaporationRate({
    required double frictionHeat,
    required double environmentHumidity,
    required String speed,
  }) {
    // 기본 증발 계수 (마찰열 1°C당 수분 흡수율 감소율)
    const baseEvaporationConstant = 0.015; // 1.5%

    // 마찰열 기반 증발률
    double evaporationFromHeat = frictionHeat * baseEvaporationConstant;

    // 환경 습도 보정 (높은 습도에서는 증발률 감소)
    double humidityCorrection =
        (50.0 - environmentHumidity) * 0.001; // 습도 1%당 0.1% 조정
    evaporationFromHeat += humidityCorrection;

    // 속도별 추가 보정 (고속에서는 증발 증가)
    double speedCorrection = 0.0;
    switch (speed) {
      case '저속':
        speedCorrection = -0.02; // 저속: 증발률 2% 감소
        break;
      case '중속':
        speedCorrection = 0.0; // 중속: 기준
        break;
      case '고속':
        speedCorrection = 0.03; // 고속: 증발률 3% 증가
        break;
    }

    final evaporationRate =
        (evaporationFromHeat + speedCorrection).clamp(0.0, 0.50);

    return evaporationRate;
  }

  /// 100% 초과 시 마찰열 기반 수분 손실 모델링
  /// 빵 제조 과학적으로 초과 믹싱 시 수분 손실 증가
  static double modelMoistureLossAfterSaturation({
    required double currentMoistureAbsorption,
    required double maxMoistureLimit,
    required double frictionHeat,
    required int duration,
  }) {
    if (currentMoistureAbsorption <= maxMoistureLimit) {
      return 0.0; // 포화 상태 이전: 손실 없음
    }

    // 초과량 계산
    final excessMoisture = currentMoistureAbsorption - maxMoistureLimit;

    // 마찰열 기반 손실 계수 (초과 믹싱 시간 고려)
    const heatLossFactor = 0.02; // 마찰열 1°C당 초과 수분 2% 손실
    const timeLossFactor = 0.005; // 초과 시간 1분당 0.5% 추가 손실

    // 손실 계산
    final heatBasedLoss =
        frictionHeat * heatLossFactor * (excessMoisture / 10.0);
    final timeBasedLoss = duration * timeLossFactor;

    final totalLoss = heatBasedLoss + timeBasedLoss;

    print('💧 [초과 수분 손실 모델링]');
    print('   - 현재 수분: ${currentMoistureAbsorption.toStringAsFixed(1)}%');
    print('   - 최대 한계: ${maxMoistureLimit.toStringAsFixed(1)}%');
    print('   - 초과량: ${excessMoisture.toStringAsFixed(1)}%');
    print('   - 마찰열: ${frictionHeat.toStringAsFixed(1)}°C');
    print('   - 손실량: ${totalLoss.toStringAsFixed(1)}%');

    return totalLoss.clamp(0.0, excessMoisture); // 초과량 이상 손실 방지
  }

  /// 고체 재료 총합 계산 (수분 흡수 기질)
  /// 밀가루, 호밀가루 등 수분을 흡수하는 고체 재료들의 총량 계산
  /// ✅ 디버깅 강화: 입력 데이터와 처리 과정 상세 로깅
  static double calculateSolidIngredientsTotal(
      List<Map<String, dynamic>> ingredients) {
    print('🔍 [고체 재료 총합 계산] 시작 - 입력 재료 수: ${ingredients.length}');

    double totalSolidWeight = 0.0;
    int solidIngredientCount = 0;

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'];
      final unit = ingredient['unit'] as String? ?? 'g';

      print('🔍 [고체 재료 분석] 원본 데이터:');
      print('   - name: ${ingredient['name']} (${name})');
      print('   - amount: $amount (타입: ${amount.runtimeType})');
      print('   - unit: $unit');

      // 고체 재료 판별
      final isSolid = _isSolidIngredient(name);
      print('   - 고체 재료 판별 결과: $isSolid');

      if (isSolid) {
        // 타입 안전한 변환
        double numericAmount;
        try {
          if (amount is String) {
            numericAmount = double.tryParse(amount) ?? 0.0;
          } else if (amount is num) {
            numericAmount = amount.toDouble();
          } else {
            numericAmount = 0.0;
          }
          print('   - 변환된 amount: $numericAmount');

          final weightInGrams =
              IngredientAnalyzer.convertToGrams(numericAmount, unit, name);
          print('   - 그램 변환 결과: ${weightInGrams}g');

          totalSolidWeight += weightInGrams;
          solidIngredientCount++;

          print(
              '✅ [고체 재료 추가] ${name}: ${weightInGrams}g (누적: ${totalSolidWeight.toStringAsFixed(1)}g)');
        } catch (e) {
          print('❌ [고체 재료 변환 실패] ${name}: $e');
        }
      } else {
        print('❌ [고체 재료 아님] ${name}');
      }
    }

    print('📊 [고체 재료 총합 계산] 결과:');
    print('   - 총 고체 재료 수: $solidIngredientCount');
    print('   - 총 고체 무게: ${totalSolidWeight.toStringAsFixed(1)}g');
    print('   - 입력 재료 총 수: ${ingredients.length}');

    return totalSolidWeight;
  }

  /// 수분 재료 총합 계산 (수분 공급원)
  /// 물, 우유, 크림 등 수분을 제공하는 재료들의 총량 계산
  static double calculateMoistureIngredientsTotal(
      List<Map<String, dynamic>> ingredients) {
    double totalMoistureWeight = 0.0;

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';

      // 수분 재료 판별 및 총량 계산
      if (_isMoistureIngredient(name)) {
        final weightInGrams =
            IngredientAnalyzer.convertToGrams(amount, unit, name);
        totalMoistureWeight += weightInGrams;
        print('🔍 [수분 재료] ${name}: ${weightInGrams}g');
      }
    }

    print('✅ [수분 재료 총합] ${totalMoistureWeight.toStringAsFixed(1)}g');
    return totalMoistureWeight;
  }

  /// 고체 재료 판별 (수분 흡수 기질)
  /// ✅ 수정: 한국어 밀가루 타입들 추가 (강력분, 박력분, 중력분 등)
  static bool _isSolidIngredient(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('밀가루') ||
        lowerName.contains('flour') ||
        lowerName.contains('호밀가루') ||
        lowerName.contains('rye flour') ||
        lowerName.contains('통밀가루') ||
        lowerName.contains('whole wheat') ||
        lowerName.contains('곡물가루') ||
        lowerName.contains('빵가루') ||
        lowerName.contains('breadcrumbs') ||
        // ✅ 한국어 밀가루 타입들 추가
        lowerName.contains('강력분') ||
        lowerName.contains('박력분') ||
        lowerName.contains('중력분') ||
        lowerName.contains('통밀분') ||
        lowerName.contains('호밀분') ||
        lowerName.contains('전립분') ||
        lowerName.contains('빵가루') ||
        lowerName.contains('부침가루') ||
        lowerName.contains('튀김가루');
  }

  /// 수분 재료 판별 (수분 공급원)
  static bool _isMoistureIngredient(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('물') ||
        lowerName.contains('water') ||
        lowerName.contains('우유') ||
        lowerName.contains('milk') ||
        lowerName.contains('크림') ||
        lowerName.contains('cream') ||
        lowerName.contains('요거트') ||
        lowerName.contains('yogurt') ||
        lowerName.contains('주스') ||
        lowerName.contains('juice');
  }
}
