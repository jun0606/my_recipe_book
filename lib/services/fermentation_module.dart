// Sous Chef용 발효 모듈 (시나리오 기반)

import 'dart:math';
import '../models/sous_chef_models.dart';
import '../models/fermentation_scenario.dart';
import 'oven_characteristics_module.dart';
import 'ingredient_analyzer.dart';

class FermentationModule extends AdjustmentModule {
  @override
  String get name => '발효 전문가';

  @override
  List<BakingType> get supportedTypes => [BakingType.bread];

  @override
  Map<String, double> calculate(Map<String, dynamic> inputs) {
    final adjustments = <String, double>{};
    
    // 발효 시나리오 추출
    final scenario = _extractFermentationScenario(inputs);
    if (scenario == null) {
      return adjustments; // 시나리오가 없으면 조정 없음
    }
    
    // 레시피 데이터에서 자동 분석
    final recipeData = inputs['recipeData'] as Map<String, dynamic>? ?? {};
    final ingredients = recipeData['ingredients'] as List<Map<String, dynamic>>? ?? [];
    
    // 재료 자동 분석
    final hydration = _calculateHydrationFromRecipe(ingredients);
    final yeastPercentage = _calculateYeastPercentageFromRecipe(ingredients);
    final saltPercentage = _calculateSaltPercentageFromRecipe(ingredients);
    final doughWeight = _calculateTotalDoughWeight(ingredients);
    
    // 환경 조건
    final roomTemp = inputs['room_temperature'] as double? ?? 22.0;
    final roomHumidity = inputs['room_humidity'] as double? ?? 60.0;
    final altitude = inputs['altitude'] as double? ?? 0.0;
    
    // 1. 환경 조건 기반 조정
    final environmentAdjustments = _calculateEnvironmentAdjustments(
      scenario: scenario,
      roomTemp: roomTemp,
      roomHumidity: roomHumidity,
      altitude: altitude,
    );
    adjustments.addAll(environmentAdjustments);
    
    // 2. 레시피 분석 기반 조정
    final recipeAdjustments = _calculateRecipeBasedAdjustments(
      scenario: scenario,
      currentHydration: hydration,
      currentYeastPercentage: yeastPercentage,
      currentSaltPercentage: saltPercentage,
      doughWeight: doughWeight,
    );
    adjustments.addAll(recipeAdjustments);
    
    // 3. 시나리오 유효성 검증 및 보정
    final warnings = scenario.validateScenario();
    if (warnings.isNotEmpty) {
      // 경고가 있는 경우 보수적으로 조정
      if (scenario.totalEstimatedTime > 720) { // 12시간 초과
        adjustments['yeast_percentage'] = (adjustments['yeast_percentage'] ?? 0.0) - 0.3;
      }
    }
    
    return adjustments;
  }

  @override
  List<String> getExplanations(Map<String, dynamic> inputs) {
    final explanations = <String>[];
    
    // 시나리오 기반 분석
    final scenario = _extractFermentationScenario(inputs);
    if (scenario == null) {
      explanations.add('발효 단계를 선택해주세요');
      return explanations;
    }
    
    final method = _getFermentationMethod(inputs);
    final roomTemp = inputs['room_temperature'] as double? ?? 22.0;
    final roomHumidity = inputs['room_humidity'] as double? ?? 60.0;
    
    // 선택된 발효 시나리오 분석
    explanations.add('🔍 선택된 발효 시나리오: ${_analyzeScenarioType(scenario)}');
    explanations.add('⏱️ 총 예상 시간: ${_formatDuration(scenario.totalEstimatedTime)}');
    
    // 각 단계별 맞춤 조언
    for (final stage in scenario.selectedStages) {
      final config = scenario.stageConfigs[stage];
      if (config != null) {
        explanations.addAll(_getStageSpecificAdvice(stage, config, roomTemp, roomHumidity));
      }
    }
    
    // 시나리오 전체에 대한 조언
    explanations.addAll(_getScenarioAdvice(scenario, method, roomTemp, roomHumidity));
    
    // 환경 조건 기반 조언
    explanations.addAll(_getEnvironmentAdvice(roomTemp, roomHumidity));
    
    return explanations;
  }

  /// 시나리오 타입 분석
  String _analyzeScenarioType(FermentationScenario scenario) {
    final stages = scenario.selectedStages;
    
    if (stages.contains(FermentationStage.bulk) && 
        stages.contains(FermentationStage.finalProof) &&
        stages.length == 2) {
      return '빠른 발효 공정';
    }
    
    if (stages.contains(FermentationStage.bulk) && 
        stages.contains(FermentationStage.secondary) &&
        stages.contains(FermentationStage.divided) &&
        stages.contains(FermentationStage.shaped) &&
        stages.contains(FermentationStage.finalProof)) {
      return '완전한 표준 식빵 공정';
    }
    
    if (stages.contains(FermentationStage.bulk) && 
        stages.contains(FermentationStage.divided) &&
        stages.contains(FermentationStage.shaped) &&
        stages.contains(FermentationStage.finalProof)) {
      return '표준 식빵 공정';
    }
    
    if (stages.contains(FermentationStage.overnight) ||
        stages.contains(FermentationStage.coldRetard)) {
      return '장시간 발효 공정';
    }
    
    if (stages.length == 1) {
      return '단일 단계 발효';
    }
    
    return '사용자 정의 발효 공정';
  }

  /// 단계별 맞춤 조언
  List<String> _getStageSpecificAdvice(FermentationStage stage, FermentationStageConfig config, double roomTemp, double roomHumidity) {
    final advice = <String>[];
    
    switch (stage) {
      case FermentationStage.bulk:
        advice.add('🍞 1차 발효 (${_formatDuration(config.duration)}): 반죽이 1.5-2배 부풀 때까지');
        advice.add('   • 30분마다 폴딩하여 글루텐 강화');
        advice.add('   • 표면이 매끄러워지면 완료');
        break;
        
      case FermentationStage.secondary:
        advice.add('🔄 2차 발효 (${_formatDuration(config.duration)}): 글루텐 구조 안정화');
        advice.add('   • 1차 발효보다 온화한 조건에서 진행');
        advice.add('   • 반죽의 탄력과 풍미가 더욱 발달');
        break;
        
      case FermentationStage.divided:
        advice.add('✂️ 분할 후 휴지 (${_formatDuration(config.duration)}): 반죽의 긴장 완화');
        advice.add('   • 젖은 천으로 덮어 건조 방지');
        advice.add('   • 반죽이 부드러워지면 성형 가능');
        break;
        
      case FermentationStage.shaped:
        advice.add('🎯 성형 후 발효 (${_formatDuration(config.duration)}): 최종 모양 형성');
        advice.add('   • 손가락 테스트로 발효 상태 확인');
        advice.add('   • 1cm 들어가서 천천히 돌아오면 적정');
        break;
        
      case FermentationStage.finalProof:
        advice.add('🏁 최종 발효 (${_formatDuration(config.duration)}): 굽기 직전 마지막 발효');
        advice.add('   • 높은 습도(80%) 유지 필수');
        advice.add('   • 과발효 시 오븐 스프링 감소');
        break;
        
      case FermentationStage.overnight:
        advice.add('🌙 오버나이트 발효 (${_formatDuration(config.duration)}): 풍미 발달');
        advice.add('   • 실온에서 천천히 발효');
        advice.add('   • 아침에 상태 확인 후 다음 단계');
        break;
        
      case FermentationStage.coldRetard:
        advice.add('❄️ 냉장 숙성 (${_formatDuration(config.duration)}): 깊은 풍미 개발');
        advice.add('   • 4°C에서 천천히 숙성');
        advice.add('   • 사용 전 실온에서 30분 복온');
        break;
    }
    
    return advice;
  }

  /// 시나리오 전체 조언
  List<String> _getScenarioAdvice(FermentationScenario scenario, FermentationMethod method, double roomTemp, double roomHumidity) {
    final advice = <String>[];
    
    // 시나리오 검증 결과 기반 조언
    final warnings = scenario.validateScenario();
    if (warnings.isNotEmpty) {
      advice.add('⚠️ 시나리오 주의사항:');
      advice.addAll(warnings.map((w) => '   • $w'));
    }
    
    // 방법별 조언
    switch (method) {
      case FermentationMethod.cold:
        advice.add('❄️ 냉장 발효: 풍미는 좋지만 시간이 오래 걸립니다');
        break;
      case FermentationMethod.proofer:
        advice.add('🌡️ 발효기 사용: 정확한 온습도 제어 가능');
        break;
      case FermentationMethod.warmPlace:
        advice.add('🔥 따뜻한 곳: 온도 변화에 주의하세요');
        break;
      default:
        break;
    }
    
    return advice;
  }

  /// 환경 조건 기반 조언
  List<String> _getEnvironmentAdvice(double roomTemp, double roomHumidity) {
    final advice = <String>[];
    
    // 온도 조언
    if (roomTemp > 28) {
      advice.add('🌡️ 높은 실내온도: 발효 시간 단축, 과발효 주의');
    } else if (roomTemp < 18) {
      advice.add('🌡️ 낮은 실내온도: 발효 시간 연장 필요');
    }
    
    // 습도 조언
    if (roomHumidity < 50) {
      advice.add('💧 건조한 환경: 반죽 표면 건조 방지 필요');
    } else if (roomHumidity > 80) {
      advice.add('💧 습한 환경: 곰팡이 발생 주의');
    }
    
    return advice;
  }

  List<String> getWarnings(Map<String, dynamic> inputs) {
    final warnings = <String>[];
    
    // 시나리오 기반 분석
    final scenario = _extractFermentationScenario(inputs);
    if (scenario == null) {
      warnings.add('⚠️ 발효 단계를 선택해주세요');
      return warnings;
    }
    
    final yeastAmount = inputs['yeast_amount'] as double? ?? 5.0;
    final doughWeight = inputs['dough_weight'] as double? ?? 1000.0;
    final hydration = inputs['hydration'] as double? ?? 65.0;
    final roomTemp = inputs['room_temperature'] as double? ?? 22.0;
    final roomHumidity = inputs['room_humidity'] as double? ?? 60.0;
    final method = _getFermentationMethod(inputs);
    
    // 시나리오 유효성 검증
    final scenarioWarnings = scenario.validateScenario();
    warnings.addAll(scenarioWarnings.map((w) => '⚠️ $w'));
    
    // 환경 조건 경고
    warnings.addAll(_getEnvironmentWarnings(roomTemp, roomHumidity));
    
    // 재료 비율 경고
    warnings.addAll(_getIngredientWarnings(yeastAmount, doughWeight, hydration));
    
    // 시나리오와 환경 조합 경고
    warnings.addAll(_getScenarioEnvironmentWarnings(scenario, roomTemp, roomHumidity, method));
    
    return warnings;
  }

  /// 환경 조건 경고
  List<String> _getEnvironmentWarnings(double roomTemp, double roomHumidity) {
    final warnings = <String>[];
    
    // 온도 관련 경고
    if (roomTemp > 35) {
      warnings.add('⚠️ 실내온도가 너무 높습니다 (35°C 초과). 이스트가 죽을 수 있습니다.');
    } else if (roomTemp > 30) {
      warnings.add('⚠️ 높은 실내온도로 인해 과발효 위험이 있습니다.');
    } else if (roomTemp < 15) {
      warnings.add('⚠️ 실내온도가 너무 낮습니다. 발효가 거의 진행되지 않을 수 있습니다.');
    }
    
    // 습도 관련 경고
    if (roomHumidity > 85) {
      warnings.add('⚠️ 습도가 너무 높습니다. 곰팡이 발생 위험이 있습니다.');
    } else if (roomHumidity < 40) {
      warnings.add('⚠️ 습도가 너무 낮습니다. 반죽 표면이 건조해질 수 있습니다.');
    }
    
    return warnings;
  }

  /// 재료 비율 경고
  List<String> _getIngredientWarnings(double yeastAmount, double doughWeight, double hydration) {
    final warnings = <String>[];
    
    // 이스트량 관련 경고
    final yeastPercentage = (yeastAmount / doughWeight) * 100;
    if (yeastPercentage > 3.0) {
      warnings.add('⚠️ 이스트량이 많습니다 (${yeastPercentage.toStringAsFixed(1)}%). 과발효 위험이 있습니다.');
    } else if (yeastPercentage < 0.3) {
      warnings.add('⚠️ 이스트량이 적습니다 (${yeastPercentage.toStringAsFixed(1)}%). 발효가 충분히 되지 않을 수 있습니다.');
    }
    
    // 수분율 관련 경고
    if (hydration > 85) {
      warnings.add('⚠️ 수분율이 매우 높습니다 (${hydration.toStringAsFixed(1)}%). 다루기 매우 어려울 수 있습니다.');
    } else if (hydration > 75) {
      warnings.add('⚠️ 수분율이 높습니다 (${hydration.toStringAsFixed(1)}%). 숙련된 기술이 필요합니다.');
    } else if (hydration < 50) {
      warnings.add('⚠️ 수분율이 낮습니다 (${hydration.toStringAsFixed(1)}%). 딱딱한 빵이 될 수 있습니다.');
    }
    
    return warnings;
  }

  /// 시나리오와 환경 조합 경고
  List<String> _getScenarioEnvironmentWarnings(FermentationScenario scenario, double roomTemp, double roomHumidity, FermentationMethod method) {
    final warnings = <String>[];
    
    // 장시간 발효 + 높은 온도
    if (scenario.totalEstimatedTime > 720 && roomTemp > 26) { // 12시간 이상 + 26도 이상
      warnings.add('⚠️ 장시간 발효에 높은 온도는 과발효를 유발할 수 있습니다.');
    }
    
    // 냉장 발효가 아닌데 24시간 이상
    if (scenario.totalEstimatedTime > 1440 && method != FermentationMethod.cold) { // 24시간 이상
      warnings.add('⚠️ 실온에서 24시간 이상 발효는 위험합니다. 냉장 발효를 고려하세요.');
    }
    
    // 빠른 발효 + 낮은 온도
    if (scenario.totalEstimatedTime < 180 && roomTemp < 20) { // 3시간 미만 + 20도 미만
      warnings.add('⚠️ 낮은 온도에서 빠른 발효는 어려울 수 있습니다.');
    }
    
    // 오버나이트 발효 + 높은 온도
    if (scenario.selectedStages.contains(FermentationStage.overnight) && roomTemp > 24) {
      warnings.add('⚠️ 오버나이트 발효 시 온도가 높으면 과발효될 수 있습니다.');
    }
    
    // 냉장 숙성 없이 사워도우
    if (scenario.selectedStages.contains(FermentationStage.bulk) && 
        scenario.totalEstimatedTime > 720 && 
        !scenario.selectedStages.contains(FermentationStage.coldRetard)) {
      warnings.add('⚠️ 장시간 발효 시 냉장 숙성을 고려해보세요.');
    }
    
    return warnings;
  }

  // 헬퍼 메서드들
  FermentationStage _getFermentationStage(Map<String, dynamic> inputs) {
    final stageStr = inputs['fermentation_stage'] as String?;
    switch (stageStr) {
      case 'bulk': return FermentationStage.bulk;
      case 'divided': return FermentationStage.divided;
      case 'shaped': return FermentationStage.shaped;
      case 'finalProof': return FermentationStage.finalProof;
      case 'overnight': return FermentationStage.overnight;
      case 'coldRetard': return FermentationStage.coldRetard;
      default: return FermentationStage.bulk;
    }
  }

  FermentationMethod _getFermentationMethod(Map<String, dynamic> inputs) {
    final methodStr = inputs['fermentation_method'] as String?;
    switch (methodStr) {
      case 'proofer': return FermentationMethod.proofer;
      case 'cold': return FermentationMethod.cold;
      case 'roomTemp': return FermentationMethod.roomTemp;
      case 'warmPlace': return FermentationMethod.warmPlace;
      case 'controlled': return FermentationMethod.controlled;
      default: return FermentationMethod.roomTemp;
    }
  }

  double _calculateOptimalFermentationTime({
    required FermentationStage stage,
    required FermentationMethod method,
    required double temperature,
    required double yeastAmount,
    required double doughWeight,
    required double hydration,
    required double saltPercentage,
    required bool usePreferment,
  }) {
    // 기본 시간 (분)
    double baseTime;
    switch (stage) {
      case FermentationStage.bulk:
        baseTime = method == FermentationMethod.cold ? 720.0 : 120.0;
        break;
      case FermentationStage.secondary:
        baseTime = 90.0;
        break;
      case FermentationStage.divided:
        baseTime = 20.0;
        break;
      case FermentationStage.shaped:
        baseTime = 60.0;
        break;
      case FermentationStage.finalProof:
        baseTime = 45.0;
        break;
      case FermentationStage.overnight:
        baseTime = 720.0;
        break;
      case FermentationStage.coldRetard:
        baseTime = 1440.0;
        break;
    }
    
    // 온도 보정 (26°C 기준)
    final tempFactor = pow(2, -(temperature - 26.0) / 10.0);
    baseTime *= tempFactor;
    
    // 이스트 양 보정 (1.5% 기준)
    final yeastPercentage = yeastAmount / doughWeight * 100;
    final yeastFactor = 1.5 / yeastPercentage;
    baseTime *= yeastFactor;
    
    // 수분율 보정
    final hydrationFactor = 1.0 - (hydration - 65.0) * 0.005;
    baseTime *= hydrationFactor;
    
    // 소금 보정
    final saltFactor = 1.0 + (saltPercentage - 2.0) * 0.1;
    baseTime *= saltFactor;
    
    // 프리퍼먼트 보정
    if (usePreferment) {
      baseTime *= 0.7;
    }
    
    return baseTime.clamp(30.0, 1440.0);
  }

  double _calculateYeastAdjustment({
    required double temperature,
    required double targetTime,
    required double currentAmount,
    required double doughWeight,
  }) {
    // 온도가 높으면 이스트 감소, 낮으면 증가
    double adjustment = 0.0;
    
    if (temperature > 28.0) {
      adjustment = -(temperature - 28.0) * 0.1;
    } else if (temperature < 22.0) {
      adjustment = (22.0 - temperature) * 0.1;
    }
    
    // 목표 시간이 길면 이스트 감소
    if (targetTime > 180.0) {
      adjustment -= (targetTime - 180.0) / 180.0 * 0.5;
    }
    
    return adjustment.clamp(-2.0, 2.0); // 최대 ±2g 조정
  }

  double _calculateMoistureAdjustment({
    required double roomHumidity,
    required double fermentationTime,
    required double currentHydration,
  }) {
    double adjustment = 0.0;
    
    // 습도가 낮으면 수분 증가
    if (roomHumidity < 60.0) {
      adjustment = (60.0 - roomHumidity) * 0.1;
    }
    
    // 긴 발효 시간일 때 수분 증가
    if (fermentationTime > 360) { // 6시간 이상
      adjustment += 1.0;
    }
    
    return adjustment.clamp(-5.0, 5.0); // 최대 ±5%
  }

  double _calculateTemperatureAdjustment({
    required FermentationStage stage,
    required double currentTemp,
    required double roomTemp,
  }) {
    double optimalTemp;
    
    switch (stage) {
      case FermentationStage.bulk:
        optimalTemp = 26.0;
        break;
      case FermentationStage.secondary:
        optimalTemp = 25.0;
        break;
      case FermentationStage.divided:
        optimalTemp = 24.0;
        break;
      case FermentationStage.shaped:
        optimalTemp = 28.0;
        break;
      case FermentationStage.finalProof:
        optimalTemp = 32.0;
        break;
      case FermentationStage.overnight:
        optimalTemp = 4.0;
        break;
      case FermentationStage.coldRetard:
        optimalTemp = 2.0;
        break;
    }
    
    return optimalTemp - currentTemp;
  }

  /// 시간을 읽기 쉬운 형태로 포맷
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()}분';
    } else if (minutes < 1440) {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).toInt();
      if (remainingMinutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${remainingMinutes}분';
      }
    } else {
      final days = (minutes / 1440).floor();
      final remainingHours = ((minutes % 1440) / 60).floor();
      if (remainingHours == 0) {
        return '${days}일';
      } else {
        return '${days}일 ${remainingHours}시간';
      }
    }
  }

  /// 발효 시나리오 추출
  FermentationScenario? _extractFermentationScenario(Map<String, dynamic> inputs) {
    // 사용자가 선택한 발효 단계들
    final selectedStagesStr = inputs['selected_fermentation_stages'] as List<String>? ?? [];
    if (selectedStagesStr.isEmpty) return null;
    
    final selectedStages = selectedStagesStr
        .map((stageStr) => FermentationStage.values
            .firstWhere((stage) => stage.name == stageStr))
        .toList();
    
    // 각 단계별 설정 (사용자 입력 또는 기본값)
    final stageConfigs = <FermentationStage, FermentationStageConfig>{};
    
    for (final stage in selectedStages) {
      final stageKey = stage.name;
      stageConfigs[stage] = FermentationStageConfig(
        duration: inputs['${stageKey}_duration'] as double? ?? _getDefaultDuration(stage),
        temperature: inputs['${stageKey}_temperature'] as double? ?? _getDefaultTemperature(stage),
        humidity: inputs['${stageKey}_humidity'] as double? ?? _getDefaultHumidity(stage),
        notes: inputs['${stageKey}_notes'] as String? ?? '',
      );
    }
    
    return FermentationScenario(
      selectedStages: selectedStages,
      stageConfigs: stageConfigs,
    );
  }

  /// 레시피에서 수분율 계산
  double _calculateHydrationFromRecipe(List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return 65.0; // 기본값
    return IngredientAnalyzer.calculateHydration(ingredients);
  }

  /// 레시피에서 이스트 비율 계산
  double _calculateYeastPercentageFromRecipe(List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return 1.0; // 기본값
    return IngredientAnalyzer.calculateYeastPercentage(ingredients);
  }

  /// 레시피에서 소금 비율 계산
  double _calculateSaltPercentageFromRecipe(List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return 2.0; // 기본값
    return IngredientAnalyzer.calculateSaltPercentage(ingredients);
  }

  /// 총 반죽 무게 계산
  double _calculateTotalDoughWeight(List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return 1000.0; // 기본값
    
    double totalWeight = 0.0;
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';
      
      // 단위를 그램으로 변환하여 합산
      totalWeight += _convertToGrams(amount, unit, name);
    }
    
    return totalWeight;
  }

  /// 환경 조건 기반 조정
  Map<String, double> _calculateEnvironmentAdjustments({
    required FermentationScenario scenario,
    required double roomTemp,
    required double roomHumidity,
    required double altitude,
  }) {
    final adjustments = <String, double>{};
    
    // 온도 조정
    if (roomTemp > 26.0) {
      // 높은 온도: 발효 시간 단축을 위해 이스트 감소
      adjustments['yeast_percentage'] = -0.1 * ((roomTemp - 26.0) / 5.0);
    } else if (roomTemp < 20.0) {
      // 낮은 온도: 발효 시간 연장을 위해 이스트 증가
      adjustments['yeast_percentage'] = 0.1 * ((20.0 - roomTemp) / 5.0);
    }
    
    // 습도 조정
    if (roomHumidity < 50.0) {
      // 건조한 환경: 수분 증가
      adjustments['hydration'] = 1.0 * ((50.0 - roomHumidity) / 20.0);
    } else if (roomHumidity > 80.0) {
      // 습한 환경: 수분 감소
      adjustments['hydration'] = -0.5 * ((roomHumidity - 80.0) / 20.0);
    }
    
    // 고도 조정
    if (altitude > 500.0) {
      // 고도가 높을수록 이스트 감소, 수분 증가
      adjustments['yeast_percentage'] = (adjustments['yeast_percentage'] ?? 0.0) - (altitude / 1000.0 * 0.1);
      adjustments['hydration'] = (adjustments['hydration'] ?? 0.0) + (altitude / 1000.0 * 1.0);
    }
    
    return adjustments;
  }

  /// 레시피 분석 기반 조정
  Map<String, double> _calculateRecipeBasedAdjustments({
    required FermentationScenario scenario,
    required double currentHydration,
    required double currentYeastPercentage,
    required double currentSaltPercentage,
    required double doughWeight,
  }) {
    final adjustments = <String, double>{};
    
    // 수분율 기반 조정
    if (currentHydration > 75.0) {
      // 고수분 반죽: 발효 시간이 길어질 수 있으므로 이스트 약간 감소
      adjustments['yeast_percentage'] = -0.1;
    } else if (currentHydration < 55.0) {
      // 저수분 반죽: 발효가 느려질 수 있으므로 이스트 약간 증가
      adjustments['yeast_percentage'] = 0.1;
    }
    
    // 현재 이스트 비율 기반 조정
    if (currentYeastPercentage > 2.0) {
      // 이스트가 많음: 과발효 위험, 시간 단축 권장
      adjustments['fermentation_time_multiplier'] = 0.8;
    } else if (currentYeastPercentage < 0.5) {
      // 이스트가 적음: 발효 시간 연장 필요
      adjustments['fermentation_time_multiplier'] = 1.3;
    }
    
    // 소금 비율 기반 조정
    if (currentSaltPercentage < 1.5) {
      // 소금이 적음: 발효가 빨라질 수 있음
      adjustments['fermentation_time_multiplier'] = (adjustments['fermentation_time_multiplier'] ?? 1.0) * 0.9;
    }
    
    // 반죽 무게 기반 조정
    if (doughWeight > 2000.0) {
      // 대용량 반죽: 발효 시간 연장
      adjustments['fermentation_time_multiplier'] = (adjustments['fermentation_time_multiplier'] ?? 1.0) * 1.1;
    } else if (doughWeight < 500.0) {
      // 소용량 반죽: 발효 시간 단축
      adjustments['fermentation_time_multiplier'] = (adjustments['fermentation_time_multiplier'] ?? 1.0) * 0.9;
    }
    
    return adjustments;
  }

  /// 단위를 그램으로 변환 (간단 버전)
  double _convertToGrams(double amount, String unit, String ingredientName) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return amount * 1000;
      case 'ml':
        return amount; // 대부분의 액체는 1:1 비율로 근사
      case 'cup':
        return amount * 240;
      case 'tbsp':
        return amount * 15;
      case 'tsp':
        return amount * 5;
      default:
        return amount; // 이미 그램이거나 알 수 없는 단위
    }
  }

  /// 발효 단계별 기본 시간 (분)
  double _getDefaultDuration(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return 120.0; // 2시간
      case FermentationStage.secondary:
        return 90.0;  // 1시간 30분
      case FermentationStage.divided:
        return 20.0;  // 20분
      case FermentationStage.shaped:
        return 15.0;  // 15분
      case FermentationStage.finalProof:
        return 60.0;  // 1시간
      case FermentationStage.overnight:
        return 720.0; // 12시간
      case FermentationStage.coldRetard:
        return 1440.0; // 24시간
    }
  }

  /// 발효 단계별 기본 온도 (°C)
  double _getDefaultTemperature(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
      case FermentationStage.secondary:
      case FermentationStage.divided:
      case FermentationStage.shaped:
        return 26.0;
      case FermentationStage.finalProof:
        return 30.0;
      case FermentationStage.overnight:
        return 18.0;
      case FermentationStage.coldRetard:
        return 4.0;
    }
  }

  /// 발효 단계별 기본 습도 (%)
  double _getDefaultHumidity(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
      case FermentationStage.secondary:
      case FermentationStage.divided:
      case FermentationStage.shaped:
        return 75.0;
      case FermentationStage.finalProof:
        return 80.0;
      case FermentationStage.overnight:
        return 70.0;
      case FermentationStage.coldRetard:
        return 85.0;
    }
  }
}