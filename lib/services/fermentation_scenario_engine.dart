/// AI 기반 발효 시나리오 엔진
/// 사용자 입력을 받아 완벽한 발효 시나리오를 자동 생성하는 핵심 엔진

import 'dart:math';
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';
import 'ingredient_analyzer.dart';

/// AI 발효 시나리오 엔진
class FermentationScenarioEngine {
  final IngredientAnalyzer _ingredientAnalyzer;

  FermentationScenarioEngine({
    IngredientAnalyzer? ingredientAnalyzer,
  }) : _ingredientAnalyzer = ingredientAnalyzer ?? IngredientAnalyzer();

  /// 메인 시나리오 생성 메서드
  /// 모든 입력 조건을 분석하여 완벽한 발효 시나리오 생성
  Future<FermentationScenarioV2> generateScenario({
    required FermentationMode mode,
    FermentationMethodV2? method,
    required Map<String, double> ingredients,
    required EnvironmentalConditions environmentalConditions,
    EquipmentProfile? equipment,
    String? recipeId,
  }) async {
    // 1. 레시피 특성 분석
    final recipeAnalysis = await _analyzeRecipe(
      recipeId: recipeId ?? _generateRecipeId(),
      ingredients: ingredients,
    );

    // 2. 환경 조건 평가 및 조정
    final adjustedConditions = _evaluateEnvironmentalConditions(
      environmentalConditions,
      recipeAnalysis,
    );

    // 3. 장비 프로파일 검증
    final validatedEquipment = _validateEquipment(equipment, mode);

    // 4. 시나리오 생성
    final scenario = await _createScenario(
      mode: mode,
      method: method,
      recipeAnalysis: recipeAnalysis,
      environmentalConditions: adjustedConditions,
      equipment: validatedEquipment,
    );

    return scenario;
  }

  /// 실시간 시나리오 재계산
  Future<FermentationScenarioV2> adaptScenario(
    FermentationScenarioV2 currentScenario,
    EnvironmentalConditions newConditions,
    Duration elapsed,
  ) async {
    // 1. 환경 변화 분석
    final environmentalChange = _analyzeEnvironmentalChange(
      currentScenario.environmentalConditions,
      newConditions,
    );

    // 2. 영향도 계산
    final impactLevel = _calculateImpactLevel(environmentalChange);

    // 3. 조정이 필요한 경우에만 재계산
    if (impactLevel < 0.3) {
      // 경미한 변화 - 시나리오 유지
      return currentScenario.copyWith(
        environmentalConditions: newConditions,
      );
    }

    // 4. 남은 단계들만 재계산
    final remainingStages = _recalculateRemainingStages(
      currentScenario,
      newConditions,
      elapsed,
      impactLevel,
    );

    // 5. 업데이트된 시나리오 생성
    return currentScenario.copyWith(
      stages: remainingStages,
      environmentalConditions: newConditions,
      metadata: {
        ...currentScenario.metadata,
        'lastAdaptation': DateTime.now().toIso8601String(),
        'adaptationReason': _getAdaptationReason(environmentalChange),
      },
    );
  }

  /// 레시피 특성 분석
  Future<RecipeAnalysis> _analyzeRecipe({
    required String recipeId,
    required Map<String, double> ingredients,
  }) async {
    // 1. 기본 재료 비율 계산
    final totalWeight = ingredients.values.fold(0.0, (sum, weight) => sum + weight);
    
    final flourWeight = _getIngredientWeight(ingredients, ['강력분', '중력분', '박력분', 'flour']);
    final sugarWeight = _getIngredientWeight(ingredients, ['설탕', '백설탕', 'sugar']);
    final yeastWeight = _getIngredientWeight(ingredients, ['이스트', '드라이이스트', 'yeast']);
    final waterWeight = _getIngredientWeight(ingredients, ['물', '우유', 'water', 'milk']);

    // 2. 베이커스 퍼센트 계산
    final flourPercentage = flourWeight > 0 ? (flourWeight / totalWeight) * 100 : 0;
    final sugarPercentage = flourWeight > 0 ? (sugarWeight / flourWeight) * 100 : 0;
    final yeastPercentage = flourWeight > 0 ? (yeastWeight / flourWeight) * 100 : 0;
    final hydrationLevel = flourWeight > 0 ? (waterWeight / flourWeight) * 100 : 0;

    // 3. 베이킹 타입 추정
    final bakingType = _estimateBakingType(ingredients, sugarPercentage, hydrationLevel);

    // 4. 복잡도 계산
    final complexity = _calculateRecipeComplexity(
      ingredients,
      sugarPercentage,
      yeastPercentage,
      hydrationLevel,
    );

    // 5. 특성 분석
    final characteristics = _analyzeRecipeCharacteristics(
      sugarPercentage,
      yeastPercentage,
      hydrationLevel,
      ingredients,
    );

    return RecipeAnalysis(
      recipeId: recipeId,
      ingredients: ingredients,
      flourPercentage: flourPercentage,
      sugarPercentage: sugarPercentage,
      yeastPercentage: yeastPercentage,
      hydrationLevel: hydrationLevel,
      bakingType: bakingType,
      estimatedComplexity: complexity,
      characteristics: characteristics,
    );
  }

  /// 환경 조건 평가 및 조정
  EnvironmentalConditions _evaluateEnvironmentalConditions(
    EnvironmentalConditions conditions,
    RecipeAnalysis recipeAnalysis,
  ) {
    // 1. 온도 조정
    double adjustedTemperature = conditions.temperature;
    
    // 고당분 레시피는 온도를 낮춤
    if (recipeAnalysis.sugarPercentage > 15) {
      adjustedTemperature -= 2;
    }
    
    // 고수분 레시피는 온도를 약간 높임
    if (recipeAnalysis.hydrationLevel > 75) {
      adjustedTemperature += 1;
    }

    // 2. 습도 조정
    double adjustedHumidity = conditions.humidity;
    
    // 저수분 레시피는 습도를 높임
    if (recipeAnalysis.hydrationLevel < 60) {
      adjustedHumidity += 5;
    }

    return EnvironmentalConditions(
      temperature: adjustedTemperature.clamp(15, 35),
      humidity: adjustedHumidity.clamp(40, 90),
      pressure: conditions.pressure,
      season: conditions.season,
      location: conditions.location,
    );
  }

  /// 장비 프로파일 검증
  EquipmentProfile? _validateEquipment(EquipmentProfile? equipment, FermentationMode mode) {
    if (mode == FermentationMode.fermenter && equipment == null) {
      // 발효기 모드인데 장비 정보가 없으면 기본 발효기 프로파일 생성
      return EquipmentProfile(
        id: 'default_fermenter',
        name: '일반 발효기',
        fermenterType: FermenterType.manual,
        capabilities: {
          'temperature_control': true,
          'humidity_control': true,
          'timer': true,
        },
        accuracy: {
          'temperature': 1.0, // ±1°C
          'humidity': 5.0,    // ±5%
        },
      );
    }
    return equipment;
  }

  /// 시나리오 생성
  Future<FermentationScenarioV2> _createScenario({
    required FermentationMode mode,
    FermentationMethodV2? method,
    required RecipeAnalysis recipeAnalysis,
    required EnvironmentalConditions environmentalConditions,
    EquipmentProfile? equipment,
  }) async {
    List<FermentationStageV2> stages;
    String scenarioName;
    String description;

    switch (mode) {
      case FermentationMode.roomTemperature:
        stages = await _createRoomTemperatureStages(
          method ?? FermentationMethodV2.normal,
          recipeAnalysis,
          environmentalConditions,
        );
        scenarioName = _getRoomTemperatureScenarioName(method ?? FermentationMethodV2.normal);
        description = _getRoomTemperatureDescription(method ?? FermentationMethodV2.normal);
        break;

      case FermentationMode.fermenter:
        stages = await _createFermenterStages(
          recipeAnalysis,
          environmentalConditions,
          equipment!,
        );
        scenarioName = '발효기 발효 시나리오';
        description = '발효기를 사용한 정밀 온습도 제어 발효';
        break;
    }

    final totalDuration = stages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );

    return FermentationScenarioV2(
      id: _generateScenarioId(),
      name: scenarioName,
      description: description,
      mode: mode,
      method: method,
      stages: stages,
      recipeAnalysis: recipeAnalysis,
      environmentalConditions: environmentalConditions,
      equipment: equipment,
      createdAt: DateTime.now(),
      totalDuration: totalDuration,
      confidenceScore: _calculateConfidenceScore(recipeAnalysis, environmentalConditions),
    );
  }

  /// 실온 발효 단계 생성
  Future<List<FermentationStageV2>> _createRoomTemperatureStages(
    FermentationMethodV2 method,
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
  ) async {
    switch (method) {
      case FermentationMethodV2.normal:
        return _createNormalRoomTemperatureStages(recipeAnalysis, environmentalConditions);
      
      case FermentationMethodV2.coldRetardation:
        return _createColdRetardationStages(recipeAnalysis, environmentalConditions);
      
      case FermentationMethodV2.freezerOvernight:
        return _createFreezerOvernightStages(recipeAnalysis, environmentalConditions);
    }
  }

  /// 일반 실온 발효 단계
  List<FermentationStageV2> _createNormalRoomTemperatureStages(
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
  ) {
    final baseTemp = environmentalConditions.temperature;
    final baseHumidity = environmentalConditions.humidity;

    // 이스트 양에 따른 발효 시간 조정
    final yeastFactor = _calculateYeastTimeFactor(recipeAnalysis.yeastPercentage);
    final sugarFactor = _calculateSugarTimeFactor(recipeAnalysis.sugarPercentage);
    final tempFactor = _calculateTemperatureFactor(baseTemp);

    final totalFactor = yeastFactor * sugarFactor * tempFactor;

    return [
      // 1차 발효
      FermentationStageV2(
        name: '1차 발효',
        type: FermentationStageType.primary,
        duration: Duration(minutes: (90 * totalFactor).round()),
        temperature: TemperatureRange(
          min: baseTemp - 2,
          max: baseTemp + 2,
          optimal: baseTemp,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '반죽을 볼에 넣고 덮개를 덮으세요',
            description: '반죽이 마르지 않도록 젖은 수건이나 랩으로 덮어주세요',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
          UserInstruction(
            action: '30분마다 폴딩하세요 (총 2-3회)',
            description: '글루텐 형성을 도와 더 좋은 식감을 만들어줍니다',
            timing: Duration(minutes: 30),
            priority: InstructionPriority.important,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': (90 * totalFactor).round()},
            executeAt: Duration.zero,
          ),
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '폴딩 시간입니다'},
            executeAt: Duration(minutes: 30),
          ),
        ],
        alerts: AlertSettings(
          message: '1차 발효가 완료되었습니다. 반죽이 1.5-2배 부풀었는지 확인하세요.',
        ),
        description: '반죽의 기본 발효 단계입니다. 이스트가 활동하여 반죽을 부풀립니다.',
      ),

      // 분할 후 휴지
      FermentationStageV2(
        name: '분할 후 휴지',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 20),
        temperature: TemperatureRange(
          min: baseTemp - 3,
          max: baseTemp + 1,
          optimal: baseTemp - 1,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '반죽을 원하는 크기로 분할하세요',
            description: '날카로운 칼이나 스크래퍼를 사용하여 깔끔하게 분할하세요',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
          UserInstruction(
            action: '분할된 반죽을 둥글게 정리하고 덮개를 덮으세요',
            description: '표면이 마르지 않도록 주의하세요',
            timing: Duration(minutes: 2),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 20},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '분할 후 휴지가 완료되었습니다. 성형을 시작하세요.',
        ),
        description: '분할로 인한 스트레스를 완화하고 성형을 용이하게 합니다.',
      ),

      // 성형 후 휴지
      FermentationStageV2(
        name: '성형 후 휴지',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 15),
        temperature: TemperatureRange(
          min: baseTemp - 3,
          max: baseTemp + 1,
          optimal: baseTemp - 1,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '반죽을 원하는 모양으로 성형하세요',
            description: '너무 세게 누르지 말고 부드럽게 성형하세요',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
          UserInstruction(
            action: '성형된 반죽을 팬에 넣고 덮개를 덮으세요',
            description: '최종 발효를 위한 준비입니다',
            timing: Duration(minutes: 3),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 15},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '성형 후 휴지가 완료되었습니다. 최종 발효를 시작하세요.',
        ),
        description: '성형으로 인한 스트레스를 완화합니다.',
      ),

      // 최종 발효
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(minutes: (60 * totalFactor * 0.8).round()),
        temperature: TemperatureRange(
          min: baseTemp + 1,
          max: baseTemp + 4,
          optimal: baseTemp + 2,
        ),
        humidity: HumidityRange(
          min: baseHumidity + 5,
          max: baseHumidity + 15,
          optimal: baseHumidity + 10,
        ),
        instructions: [
          UserInstruction(
            action: '따뜻하고 습한 곳에 두세요',
            description: '오븐에 뜨거운 물을 넣어 습도를 높이는 것도 좋습니다',
            timing: Duration.zero,
            priority: InstructionPriority.important,
          ),
          UserInstruction(
            action: '손가락 테스트로 발효 상태를 확인하세요',
            description: '손가락으로 살짝 눌렀을 때 천천히 돌아오면 완료',
            timing: Duration(minutes: (45 * totalFactor * 0.8).round()),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': (60 * totalFactor * 0.8).round()},
            executeAt: Duration.zero,
          ),
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '오븐을 예열하세요 (180°C)'},
            executeAt: Duration(minutes: (45 * totalFactor * 0.8).round()),
          ),
        ],
        alerts: AlertSettings(
          message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
          beforeCompletion: Duration(minutes: 15),
        ),
        description: '굽기 전 마지막 발효 단계입니다. 과발효되지 않도록 주의하세요.',
      ),
    ];
  }

  /// 냉장 저온 발효 단계
  List<FermentationStageV2> _createColdRetardationStages(
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
  ) {
    final baseTemp = environmentalConditions.temperature;
    final baseHumidity = environmentalConditions.humidity;

    return [
      // 짧은 1차 발효
      FermentationStageV2(
        name: '1차 발효 (단축)',
        type: FermentationStageType.primary,
        duration: Duration(minutes: 60),
        temperature: TemperatureRange(
          min: baseTemp - 2,
          max: baseTemp + 2,
          optimal: baseTemp,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '반죽을 볼에 넣고 덮개를 덮으세요',
            description: '냉장 발효를 위한 짧은 1차 발효입니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 60},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '1차 발효가 완료되었습니다. 냉장고에 넣어주세요.',
        ),
        description: '냉장 발효 전 기본 발효입니다.',
      ),

      // 냉장 저온 발효
      FermentationStageV2(
        name: '냉장 저온 발효',
        type: FermentationStageType.storage,
        duration: Duration(hours: 12),
        temperature: TemperatureRange(
          min: 2,
          max: 6,
          optimal: 4,
        ),
        humidity: HumidityRange(
          min: 80,
          max: 90,
          optimal: 85,
        ),
        instructions: [
          UserInstruction(
            action: '냉장고를 4°C로 설정하세요',
            description: '너무 차가우면 발효가 멈추고, 너무 따뜻하면 과발효됩니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '냉장고',
          ),
          UserInstruction(
            action: '반죽을 밀폐용기에 넣어 냉장고에 보관하세요',
            description: '12시간 동안 천천히 발효됩니다',
            timing: Duration(minutes: 5),
            priority: InstructionPriority.critical,
            equipmentTarget: '냉장고',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 720}, // 12시간
            executeAt: Duration.zero,
          ),
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '냉장 발효가 완료되었습니다. 실온에서 적응시키세요.'},
            executeAt: Duration(hours: 12),
          ),
        ],
        alerts: AlertSettings(
          message: '냉장 발효가 완료되었습니다. 실온에서 1시간 적응 후 성형하세요.',
          beforeCompletion: Duration(hours: 1),
        ),
        description: '저온에서 천천히 발효하여 풍미를 발달시킵니다.',
      ),

      // 실온 적응
      FermentationStageV2(
        name: '실온 적응',
        type: FermentationStageType.thawing,
        duration: Duration(minutes: 60),
        temperature: TemperatureRange(
          min: baseTemp - 3,
          max: baseTemp + 1,
          optimal: baseTemp - 1,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '냉장고에서 꺼내 실온에 두세요',
            description: '차가운 반죽을 실온에 적응시킵니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
          UserInstruction(
            action: '덮개를 덮어 마르지 않게 하세요',
            description: '1시간 정도 실온에서 적응시킵니다',
            timing: Duration(minutes: 5),
            priority: InstructionPriority.important,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 60},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '실온 적응이 완료되었습니다. 성형을 시작하세요.',
        ),
        description: '냉장 보관된 반죽을 실온에 적응시킵니다.',
      ),

      // 최종 발효
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(minutes: 45),
        temperature: TemperatureRange(
          min: baseTemp + 1,
          max: baseTemp + 4,
          optimal: baseTemp + 2,
        ),
        humidity: HumidityRange(
          min: baseHumidity + 5,
          max: baseHumidity + 15,
          optimal: baseHumidity + 10,
        ),
        instructions: [
          UserInstruction(
            action: '성형 후 따뜻한 곳에 두세요',
            description: '냉장 발효 후이므로 시간이 단축됩니다',
            timing: Duration.zero,
            priority: InstructionPriority.important,
          ),
          UserInstruction(
            action: '손가락 테스트로 발효 상태를 확인하세요',
            description: '냉장 발효로 인해 더 빨리 완료될 수 있습니다',
            timing: Duration(minutes: 30),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 45},
            executeAt: Duration.zero,
          ),
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '오븐을 예열하세요 (180°C)'},
            executeAt: Duration(minutes: 30),
          ),
        ],
        alerts: AlertSettings(
          message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
          beforeCompletion: Duration(minutes: 10),
        ),
        description: '냉장 발효 후 마지막 발효 단계입니다.',
      ),
    ];
  }

  /// 냉동 오버나이트 단계
  List<FermentationStageV2> _createFreezerOvernightStages(
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
  ) {
    final baseTemp = environmentalConditions.temperature;
    final baseHumidity = environmentalConditions.humidity;

    return [
      // 짧은 1차 발효
      FermentationStageV2(
        name: '1차 발효 (단축)',
        type: FermentationStageType.primary,
        duration: Duration(minutes: 45),
        temperature: TemperatureRange(
          min: baseTemp - 2,
          max: baseTemp + 2,
          optimal: baseTemp,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '반죽을 볼에 넣고 덮개를 덮으세요',
            description: '냉동 보관을 위한 짧은 1차 발효입니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 45},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '1차 발효가 완료되었습니다. 냉동고에 넣어주세요.',
        ),
        description: '냉동 보관 전 기본 발효입니다.',
      ),

      // 냉동 보관
      FermentationStageV2(
        name: '냉동 보관',
        type: FermentationStageType.storage,
        duration: Duration(hours: 24), // 기본 24시간, 최대 1주일 가능
        temperature: TemperatureRange(
          min: -20,
          max: -15,
          optimal: -18,
        ),
        humidity: HumidityRange(
          min: 0,
          max: 10,
          optimal: 5,
        ),
        instructions: [
          UserInstruction(
            action: '냉동고를 -18°C로 설정하세요',
            description: '너무 차가우면 반죽이 손상될 수 있습니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '냉동고',
          ),
          UserInstruction(
            action: '반죽을 밀폐용기나 냉동백에 넣어 냉동하세요',
            description: '최대 1주일까지 보관 가능합니다',
            timing: Duration(minutes: 5),
            priority: InstructionPriority.critical,
            equipmentTarget: '냉동고',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 1440}, // 24시간
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '냉동 보관이 완료되었습니다. 사용 12시간 전에 냉장고로 이동하세요.',
          beforeCompletion: Duration(hours: 12),
        ),
        description: '장기간 보관을 위한 냉동 단계입니다.',
        metadata: {
          'maxStorageDays': 7,
          'thawingInstructions': '사용 12시간 전에 냉장고로 이동',
        },
      ),

      // 냉장 해동
      FermentationStageV2(
        name: '냉장 해동',
        type: FermentationStageType.thawing,
        duration: Duration(hours: 12),
        temperature: TemperatureRange(
          min: 2,
          max: 6,
          optimal: 4,
        ),
        humidity: HumidityRange(
          min: 80,
          max: 90,
          optimal: 85,
        ),
        instructions: [
          UserInstruction(
            action: '냉동고에서 냉장고로 이동하세요',
            description: '천천히 해동하여 반죽의 구조를 보호합니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '냉장고',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 720}, // 12시간
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '냉장 해동이 완료되었습니다. 실온에서 적응시키세요.',
        ),
        description: '냉동된 반죽을 천천히 해동합니다.',
      ),

      // 실온 적응
      FermentationStageV2(
        name: '실온 적응',
        type: FermentationStageType.thawing,
        duration: Duration(hours: 2),
        temperature: TemperatureRange(
          min: baseTemp - 3,
          max: baseTemp + 1,
          optimal: baseTemp - 1,
        ),
        humidity: HumidityRange(
          min: baseHumidity - 5,
          max: baseHumidity + 5,
          optimal: baseHumidity,
        ),
        instructions: [
          UserInstruction(
            action: '냉장고에서 꺼내 실온에 두세요',
            description: '냉동 해동된 반죽은 더 오래 적응이 필요합니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 120},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '실온 적응이 완료되었습니다. 성형을 시작하세요.',
        ),
        description: '해동된 반죽을 실온에 적응시킵니다.',
      ),

      // 최종 발효
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(minutes: 90),
        temperature: TemperatureRange(
          min: baseTemp + 1,
          max: baseTemp + 4,
          optimal: baseTemp + 2,
        ),
        humidity: HumidityRange(
          min: baseHumidity + 5,
          max: baseHumidity + 15,
          optimal: baseHumidity + 10,
        ),
        instructions: [
          UserInstruction(
            action: '성형 후 따뜻한 곳에 두세요',
            description: '냉동 해동 후이므로 시간이 더 필요합니다',
            timing: Duration.zero,
            priority: InstructionPriority.important,
          ),
          UserInstruction(
            action: '손가락 테스트로 발효 상태를 확인하세요',
            description: '해동 과정으로 인해 발효가 느릴 수 있습니다',
            timing: Duration(minutes: 60),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 90},
            executeAt: Duration.zero,
          ),
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '오븐을 예열하세요 (180°C)'},
            executeAt: Duration(minutes: 75),
          ),
        ],
        alerts: AlertSettings(
          message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
          beforeCompletion: Duration(minutes: 15),
        ),
        description: '냉동 해동 후 마지막 발효 단계입니다.',
      ),
    ];
  }

  /// 발효기 발효 단계 생성
  Future<List<FermentationStageV2>> _createFermenterStages(
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
    EquipmentProfile equipment,
  ) async {
    // 발효기 최적 설정 계산
    final optimalSettings = _calculateOptimalFermenterSettings(recipeAnalysis);
    
    return [
      // 1차 발효
      FermentationStageV2(
        name: '1차 발효',
        type: FermentationStageType.primary,
        duration: Duration(minutes: optimalSettings['primaryDuration']),
        temperature: TemperatureRange(
          min: optimalSettings['primaryTemp'] - 1,
          max: optimalSettings['primaryTemp'] + 1,
          optimal: optimalSettings['primaryTemp'],
        ),
        humidity: HumidityRange(
          min: optimalSettings['primaryHumidity'] - 5,
          max: optimalSettings['primaryHumidity'] + 5,
          optimal: optimalSettings['primaryHumidity'],
        ),
        instructions: [
          UserInstruction(
            action: '발효기를 ${optimalSettings['primaryTemp'].toStringAsFixed(0)}°C로 설정하세요',
            description: '온도 설정을 정확히 맞춰주세요',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '습도를 ${optimalSettings['primaryHumidity'].toStringAsFixed(0)}%로 설정하세요',
            description: '습도가 너무 낮으면 반죽이 마를 수 있습니다',
            timing: Duration(minutes: 1),
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '반죽을 발효기에 넣고 ${optimalSettings['primaryDuration']}분 타이머를 설정하세요',
            description: '발효기 내부 온습도가 안정될 때까지 기다린 후 넣으세요',
            timing: Duration(minutes: 3),
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': optimalSettings['primaryDuration']},
            executeAt: Duration.zero,
          ),
          if (equipment.fermenterType == FermenterType.smart) ...[
            AutomationAction(
              target: AutomationTarget.temperature,
              settings: {'temperature': optimalSettings['primaryTemp']},
              executeAt: Duration.zero,
            ),
            AutomationAction(
              target: AutomationTarget.humidity,
              settings: {'humidity': optimalSettings['primaryHumidity']},
              executeAt: Duration.zero,
            ),
          ],
        ],
        alerts: AlertSettings(
          message: '1차 발효가 완료되었습니다. 분할을 시작하세요.',
        ),
        description: '발효기를 사용한 정밀한 1차 발효입니다.',
      ),

      // 분할 후 휴지
      FermentationStageV2(
        name: '분할 후 휴지',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 15),
        temperature: TemperatureRange(
          min: optimalSettings['restTemp'] - 1,
          max: optimalSettings['restTemp'] + 1,
          optimal: optimalSettings['restTemp'],
        ),
        humidity: HumidityRange(
          min: optimalSettings['restHumidity'] - 5,
          max: optimalSettings['restHumidity'] + 5,
          optimal: optimalSettings['restHumidity'],
        ),
        instructions: [
          UserInstruction(
            action: '발효기를 ${optimalSettings['restTemp'].toStringAsFixed(0)}°C로 조정하세요',
            description: '휴지 단계는 약간 낮은 온도가 좋습니다',
            timing: Duration.zero,
            priority: InstructionPriority.important,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '습도를 ${optimalSettings['restHumidity'].toStringAsFixed(0)}%로 조정하세요',
            description: '습도를 약간 낮춰 표면이 너무 끈적이지 않게 합니다',
            timing: Duration(minutes: 1),
            priority: InstructionPriority.important,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '분할된 반죽을 발효기에 넣고 15분 타이머를 설정하세요',
            description: '분할 스트레스를 완화하는 단계입니다',
            timing: Duration(minutes: 2),
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 15},
            executeAt: Duration.zero,
          ),
          if (equipment.fermenterType == FermenterType.smart) ...[
            AutomationAction(
              target: AutomationTarget.temperature,
              settings: {'temperature': optimalSettings['restTemp']},
              executeAt: Duration.zero,
            ),
            AutomationAction(
              target: AutomationTarget.humidity,
              settings: {'humidity': optimalSettings['restHumidity']},
              executeAt: Duration.zero,
            ),
          ],
        ],
        alerts: AlertSettings(
          message: '분할 후 휴지가 완료되었습니다. 성형을 시작하세요.',
        ),
        description: '발효기에서 분할 스트레스를 완화합니다.',
      ),

      // 성형 후 휴지
      FermentationStageV2(
        name: '성형 후 휴지',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 25),
        temperature: TemperatureRange(
          min: optimalSettings['restTemp'] - 1,
          max: optimalSettings['restTemp'] + 1,
          optimal: optimalSettings['restTemp'],
        ),
        humidity: HumidityRange(
          min: optimalSettings['restHumidity'] - 5,
          max: optimalSettings['restHumidity'] + 5,
          optimal: optimalSettings['restHumidity'],
        ),
        instructions: [
          UserInstruction(
            action: '성형된 반죽을 발효기에 넣고 25분 타이머를 설정하세요',
            description: '성형 스트레스를 완화하고 최종 발효를 준비합니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': 25},
            executeAt: Duration.zero,
          ),
        ],
        alerts: AlertSettings(
          message: '성형 후 휴지가 완료되었습니다. 최종 발효를 시작하세요.',
        ),
        description: '발효기에서 성형 스트레스를 완화합니다.',
      ),

      // 최종 발효
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(minutes: optimalSettings['finalDuration']),
        temperature: TemperatureRange(
          min: optimalSettings['finalTemp'] - 1,
          max: optimalSettings['finalTemp'] + 1,
          optimal: optimalSettings['finalTemp'],
        ),
        humidity: HumidityRange(
          min: optimalSettings['finalHumidity'] - 5,
          max: optimalSettings['finalHumidity'] + 5,
          optimal: optimalSettings['finalHumidity'],
        ),
        instructions: [
          UserInstruction(
            action: '발효기를 ${optimalSettings['finalTemp'].toStringAsFixed(0)}°C로 조정하세요',
            description: '최종 발효는 약간 높은 온도가 좋습니다',
            timing: Duration.zero,
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '습도를 ${optimalSettings['finalHumidity'].toStringAsFixed(0)}%로 조정하세요',
            description: '높은 습도로 표면이 마르지 않게 합니다',
            timing: Duration(minutes: 1),
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '${optimalSettings['finalDuration']}분 타이머를 설정하세요',
            description: '과발효되지 않도록 시간을 정확히 지켜주세요',
            timing: Duration(minutes: 2),
            priority: InstructionPriority.critical,
            equipmentTarget: '발효기',
          ),
          UserInstruction(
            action: '손가락 테스트로 발효 상태를 확인하세요',
            description: '80-85% 발효가 완료되면 굽기 시작하세요',
            timing: Duration(minutes: optimalSettings['finalDuration'] - 10),
            priority: InstructionPriority.critical,
          ),
        ],
        automations: [
          AutomationAction(
            target: AutomationTarget.timer,
            settings: {'duration': optimalSettings['finalDuration']},
            executeAt: Duration.zero,
          ),
          if (equipment.fermenterType == FermenterType.smart) ...[
            AutomationAction(
              target: AutomationTarget.temperature,
              settings: {'temperature': optimalSettings['finalTemp']},
              executeAt: Duration.zero,
            ),
            AutomationAction(
              target: AutomationTarget.humidity,
              settings: {'humidity': optimalSettings['finalHumidity']},
              executeAt: Duration.zero,
            ),
          ],
          AutomationAction(
            target: AutomationTarget.notification,
            settings: {'message': '오븐을 예열하세요 (180°C)'},
            executeAt: Duration(minutes: optimalSettings['finalDuration'] - 15),
          ),
        ],
        alerts: AlertSettings(
          message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
          beforeCompletion: Duration(minutes: 10),
        ),
        description: '발효기를 사용한 정밀한 최종 발효입니다.',
      ),
    ];
  }

  // 헬퍼 메서드들
  double _getIngredientWeight(Map<String, double> ingredients, List<String> names) {
    for (final name in names) {
      for (final key in ingredients.keys) {
        if (key.toLowerCase().contains(name.toLowerCase())) {
          return ingredients[key] ?? 0.0;
        }
      }
    }
    return 0.0;
  }

  BakingType _estimateBakingType(Map<String, double> ingredients, double sugarPercentage, double hydrationLevel) {
    if (sugarPercentage > 20 || hydrationLevel < 50) {
      return BakingType.cake;
    }
    return BakingType.bread;
  }

  double _calculateRecipeComplexity(
    Map<String, double> ingredients,
    double sugarPercentage,
    double yeastPercentage,
    double hydrationLevel,
  ) {
    double complexity = 5.0; // 기본값

    // 재료 수에 따른 복잡도
    complexity += (ingredients.length - 4) * 0.5;

    // 특수 재료에 따른 복잡도
    if (sugarPercentage > 15) complexity += 1.0;
    if (yeastPercentage < 1) complexity += 1.5;
    if (hydrationLevel > 80) complexity += 1.0;
    if (hydrationLevel < 55) complexity += 0.5;

    return complexity.clamp(1.0, 10.0);
  }

  List<String> _analyzeRecipeCharacteristics(
    double sugarPercentage,
    double yeastPercentage,
    double hydrationLevel,
    Map<String, double> ingredients,
  ) {
    final characteristics = <String>[];

    if (sugarPercentage > 15) characteristics.add('고당분');
    if (sugarPercentage < 5) characteristics.add('저당분');
    if (yeastPercentage > 2) characteristics.add('고이스트');
    if (yeastPercentage < 1) characteristics.add('저이스트');
    if (hydrationLevel > 75) characteristics.add('고수분');
    if (hydrationLevel < 60) characteristics.add('저수분');

    return characteristics;
  }

  double _calculateYeastTimeFactor(double yeastPercentage) {
    // 이스트 양이 많을수록 발효 시간 단축
    if (yeastPercentage > 2.0) return 0.8;
    if (yeastPercentage > 1.5) return 0.9;
    if (yeastPercentage < 0.8) return 1.3;
    if (yeastPercentage < 1.0) return 1.2;
    return 1.0;
  }

  double _calculateSugarTimeFactor(double sugarPercentage) {
    // 설탕이 많을수록 발효 시간 단축 (이스트 활성화)
    if (sugarPercentage > 20) return 0.9;
    if (sugarPercentage > 15) return 0.95;
    return 1.0;
  }

  double _calculateTemperatureFactor(double temperature) {
    // 온도가 높을수록 발효 시간 단축
    if (temperature > 30) return 0.8;
    if (temperature > 25) return 0.9;
    if (temperature < 20) return 1.2;
    if (temperature < 15) return 1.4;
    return 1.0;
  }

  Map<String, double> _calculateOptimalFermenterSettings(RecipeAnalysis recipeAnalysis) {
    // 레시피 특성에 따른 최적 발효기 설정 계산
    final baseTemp = 28.0;
    final baseHumidity = 75.0;
    final baseDuration = 75.0;

    // 설탕 함량에 따른 조정
    double tempAdjustment = 0;
    double humidityAdjustment = 0;
    double timeAdjustment = 1.0;

    if (recipeAnalysis.sugarPercentage > 15) {
      tempAdjustment -= 2; // 고당분은 온도 낮춤
      timeAdjustment *= 0.9; // 시간 단축
    }

    if (recipeAnalysis.hydrationLevel > 75) {
      humidityAdjustment += 5; // 고수분은 습도 높임
    }

    if (recipeAnalysis.yeastPercentage > 2) {
      timeAdjustment *= 0.8; // 고이스트는 시간 단축
    }

    return {
      'primaryTemp': baseTemp + tempAdjustment,
      'primaryHumidity': baseHumidity + humidityAdjustment,
      'primaryDuration': (baseDuration * timeAdjustment).round().toDouble(),
      'restTemp': baseTemp + tempAdjustment - 2,
      'restHumidity': baseHumidity + humidityAdjustment - 5,
      'finalTemp': baseTemp + tempAdjustment + 2,
      'finalHumidity': baseHumidity + humidityAdjustment + 5,
      'finalDuration': (45 * timeAdjustment).round().toDouble(),
    };
  }

  double _analyzeEnvironmentalChange(
    EnvironmentalConditions current,
    EnvironmentalConditions newConditions,
  ) {
    final tempChange = (newConditions.temperature - current.temperature).abs();
    final humidityChange = (newConditions.humidity - current.humidity).abs();
    
    return (tempChange / 10) + (humidityChange / 20);
  }

  double _calculateImpactLevel(double environmentalChange) {
    return environmentalChange.clamp(0.0, 1.0);
  }

  List<FermentationStageV2> _recalculateRemainingStages(
    FermentationScenarioV2 scenario,
    EnvironmentalConditions newConditions,
    Duration elapsed,
    double impactLevel,
  ) {
    // 현재 진행 중인 단계부터 재계산
    final currentStage = scenario.getCurrentStage(elapsed);
    if (currentStage == null) return scenario.stages;

    final currentIndex = scenario.stages.indexOf(currentStage);
    final completedStages = scenario.stages.take(currentIndex).toList();
    final remainingStages = scenario.stages.skip(currentIndex).toList();

    // 환경 변화에 따른 시간 조정
    final timeAdjustment = 1.0 + (impactLevel * 0.2);

    final adjustedRemainingStages = remainingStages.map((stage) {
      final adjustedDuration = Duration(
        minutes: (stage.duration.inMinutes * timeAdjustment).round(),
      );

      return FermentationStageV2(
        name: stage.name,
        type: stage.type,
        duration: adjustedDuration,
        temperature: TemperatureRange(
          min: newConditions.temperature - 2,
          max: newConditions.temperature + 2,
          optimal: newConditions.temperature,
        ),
        humidity: HumidityRange(
          min: newConditions.humidity - 5,
          max: newConditions.humidity + 5,
          optimal: newConditions.humidity,
        ),
        instructions: stage.instructions,
        automations: stage.automations,
        alerts: stage.alerts,
        description: stage.description,
        metadata: {
          ...stage.metadata,
          'adjusted': true,
          'adjustmentFactor': timeAdjustment,
        },
      );
    }).toList();

    return [...completedStages, ...adjustedRemainingStages];
  }

  String _getAdaptationReason(double environmentalChange) {
    if (environmentalChange > 0.7) return '환경 조건이 크게 변화하여 시나리오를 재조정했습니다.';
    if (environmentalChange > 0.5) return '온도 또는 습도 변화로 인해 발효 시간을 조정했습니다.';
    return '환경 변화를 반영하여 시나리오를 미세 조정했습니다.';
  }

  String _getRoomTemperatureScenarioName(FermentationMethodV2 method) {
    switch (method) {
      case FermentationMethodV2.normal:
        return '실온 발효 시나리오';
      case FermentationMethodV2.coldRetardation:
        return '냉장 저온 발효 시나리오';
      case FermentationMethodV2.freezerOvernight:
        return '냉동 오버나이트 시나리오';
    }
  }

  String _getRoomTemperatureDescription(FermentationMethodV2 method) {
    switch (method) {
      case FermentationMethodV2.normal:
        return '실온에서 진행하는 일반적인 발효 방식입니다.';
      case FermentationMethodV2.coldRetardation:
        return '냉장고에서 저온 발효하여 풍미를 발달시키는 방식입니다.';
      case FermentationMethodV2.freezerOvernight:
        return '냉동 보관 후 해동하여 사용하는 편리한 방식입니다.';
    }
  }

  double _calculateConfidenceScore(
    RecipeAnalysis recipeAnalysis,
    EnvironmentalConditions environmentalConditions,
  ) {
    double score = 1.0;

    // 레시피 복잡도에 따른 신뢰도 조정
    if (recipeAnalysis.estimatedComplexity > 8) score -= 0.1;
    if (recipeAnalysis.estimatedComplexity < 3) score -= 0.05;

    // 환경 조건에 따른 신뢰도 조정
    if (environmentalConditions.temperature < 15 || environmentalConditions.temperature > 35) {
      score -= 0.15;
    }
    if (environmentalConditions.humidity < 40 || environmentalConditions.humidity > 90) {
      score -= 0.1;
    }

    return score.clamp(0.5, 1.0);
  }

  String _generateRecipeId() {
    return 'recipe_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateScenarioId() {
    return 'scenario_${DateTime.now().millisecondsSinceEpoch}';
  }
}