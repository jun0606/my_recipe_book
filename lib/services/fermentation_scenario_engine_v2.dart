/// 발효 시나리오 엔진 V2 - 완전 커스텀 중심 시스템
/// 실온 발효는 커스텀만, 발효기는 과학적 가이드 제공

import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';
import 'room_temperature_fermentation_templates.dart';
import 'fermenter_optimization_guide.dart';

class FermentationScenarioEngine {
  
  /// 발효 모드별 시나리오 생성
  static Future<List<FermentationScenarioV2>> generateScenarios({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions environment,
    FermentationMode? preferredMode,
  }) async {
    final scenarios = <FermentationScenarioV2>[];
    
    // 실온 발효 모드 - 커스텀 가이드만 제공
    if (preferredMode == null || preferredMode == FermentationMode.roomTemperature) {
      final customGuide = _createCustomGuideScenario(recipe, environment);
      scenarios.add(customGuide);
    }
    
    // 발효기 모드 - 과학적 최적화 가이드 제공
    if (preferredMode == null || preferredMode == FermentationMode.fermenter) {
      final fermenterScenarios = await _generateFermenterScenarios(recipe, environment);
      scenarios.addAll(fermenterScenarios);
    }
    
    return scenarios;
  }
  
  /// 실온 발효 커스텀 가이드 시나리오
  static FermentationScenarioV2 _createCustomGuideScenario(
    RecipeAnalysis recipe,
    EnvironmentalConditions environment,
  ) {
    final customGuide = RoomTemperatureFermentationTemplates.getCustomGuide(
      recipe: recipe,
      env: environment,
    );
    
    return FermentationScenarioV2(
      id: 'custom_guide_${DateTime.now().millisecondsSinceEpoch}',
      name: '실온 발효 커스텀 가이드',
      description: '환경과 레시피에 맞는 나만의 발효 시나리오를 만들어보세요.\n'
                  '아래 추천사항을 참고하여 커스텀 빌더를 사용하세요.',
      mode: FermentationMode.roomTemperature,
      method: FermentationMethodV2.custom,
      stages: [], // 커스텀 빌더에서 생성
      recipeAnalysis: recipe,
      environmentalConditions: environment,
      createdAt: DateTime.now(),
      totalDuration: Duration.zero, // 사용자가 설정
      metadata: {
        'type': 'custom_guide',
        'environmentalFactors': customGuide['environmentalFactors'],
        'recipeFactors': customGuide['recipeFactors'],
        'recommendations': customGuide['recommendations'],
        'quickStartTips': customGuide['quickStartTips'],
        'customOnly': true,
      },
      confidenceScore: 1.0, // 커스텀이므로 최대 신뢰도
    );
  }
  
  /// 발효기 최적화 시나리오들 생성
  static Future<List<FermentationScenarioV2>> _generateFermenterScenarios(
    RecipeAnalysis recipe,
    EnvironmentalConditions environment,
  ) async {
    final scenarios = <FermentationScenarioV2>[];
    
    // 기본 발효기 시나리오 (1차 + 최종)
    scenarios.add(await _createBasicFermenterScenario(recipe, environment));
    
    // 냉장 저온 발효 시나리오
    scenarios.add(await _createColdRetardationScenario(recipe, environment));
    
    // 냉동 보관 시나리오
    scenarios.add(await _createFreezerScenario(recipe, environment));
    
    return scenarios;
  }
  
  /// 기본 발효기 시나리오
  static Future<FermentationScenarioV2> _createBasicFermenterScenario(
    RecipeAnalysis recipe,
    EnvironmentalConditions environment,
  ) async {
    final stages = <FermentationStageV2>[];
    
    // 1차 발효 단계
    final primarySettings = FermenterOptimizationGuide.calculateOptimalSettings(
      recipe: recipe,
      stageType: FermentationStageType.primary,
    );
    
    stages.add(FermentationStageV2(
      name: '1차 발효',
      type: FermentationStageType.primary,
      duration: primarySettings.duration,
      temperature: TemperatureRange(
        min: primarySettings.temperature - 2,
        max: primarySettings.temperature + 2,
        optimal: primarySettings.temperature,
      ),
      humidity: HumidityRange(
        min: primarySettings.humidity - 5,
        max: primarySettings.humidity + 5,
        optimal: primarySettings.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '발효기를 ${primarySettings.temperature.toStringAsFixed(1)}°C, ${primarySettings.humidity.toStringAsFixed(0)}%로 설정하세요',
          description: primarySettings.explanations['온도'] ?? '최적 발효 조건입니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
          equipmentTarget: '발효기',
        ),
        UserInstruction(
          action: '반죽을 발효기에 넣고 ${primarySettings.duration.inMinutes}분 발효하세요',
          description: '1차 발효는 반죽의 기본 부피를 만드는 중요한 단계입니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': primarySettings.duration.inMinutes},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '1차 발효가 완료되었습니다. 반죽이 1.5-2배 부풀었는지 확인하세요.',
      ),
      description: '발효기를 사용한 최적화된 1차 발효 단계입니다.',
      metadata: {
        'optimized': true,
        'explanations': primarySettings.explanations,
        'warnings': primarySettings.warnings,
        'tips': primarySettings.tips,
      },
    ));
    
    // 분할 후 휴지
    stages.add(FermentationStageV2(
      name: '분할 후 휴지',
      type: FermentationStageType.rest,
      duration: Duration(minutes: 20),
      temperature: TemperatureRange(
        min: environment.temperature - 2,
        max: environment.temperature + 2,
        optimal: environment.temperature,
      ),
      humidity: HumidityRange(
        min: environment.humidity - 5,
        max: environment.humidity + 5,
        optimal: environment.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '반죽을 원하는 크기로 분할하세요',
          description: '날카로운 칼이나 스크래퍼를 사용하여 깔끔하게 분할하세요',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
        UserInstruction(
          action: '둥글게 정리하고 덮개를 덮어 20분 휴지하세요',
          description: '분할로 인한 스트레스를 완화합니다',
          timing: Duration(minutes: 2),
          priority: InstructionPriority.important,
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
        message: '휴지가 완료되었습니다. 성형을 시작하세요.',
      ),
      description: '분할 후 글루텐을 이완시키는 휴지 단계입니다.',
    ));
    
    // 최종 발효 단계
    final finalSettings = FermenterOptimizationGuide.calculateOptimalSettings(
      recipe: recipe,
      stageType: FermentationStageType.finalProofing,
    );
    
    stages.add(FermentationStageV2(
      name: '최종 발효',
      type: FermentationStageType.finalProofing,
      duration: finalSettings.duration,
      temperature: TemperatureRange(
        min: finalSettings.temperature - 2,
        max: finalSettings.temperature + 2,
        optimal: finalSettings.temperature,
      ),
      humidity: HumidityRange(
        min: finalSettings.humidity - 5,
        max: finalSettings.humidity + 5,
        optimal: finalSettings.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '발효기를 ${finalSettings.temperature.toStringAsFixed(1)}°C, ${finalSettings.humidity.toStringAsFixed(0)}%로 재설정하세요',
          description: finalSettings.explanations['온도'] ?? '최종 발효 최적 조건입니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
          equipmentTarget: '발효기',
        ),
        UserInstruction(
          action: '성형된 반죽을 발효기에 넣고 발효하세요',
          description: '과발효되지 않도록 주의깊게 관찰하세요',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
        UserInstruction(
          action: '손가락 테스트로 발효 상태를 확인하세요',
          description: '손가락으로 살짝 눌렀을 때 천천히 돌아오면 완료',
          timing: Duration(minutes: (finalSettings.duration.inMinutes * 0.8).round()),
          priority: InstructionPriority.critical,
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': finalSettings.duration.inMinutes},
          executeAt: Duration.zero,
        ),
        AutomationAction(
          target: AutomationTarget.notification,
          settings: {'message': '오븐을 예열하세요 (180°C)'},
          executeAt: Duration(minutes: (finalSettings.duration.inMinutes * 0.8).round()),
        ),
      ],
      alerts: AlertSettings(
        message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
        beforeCompletion: Duration(minutes: 10),
      ),
      description: '발효기를 사용한 최적화된 최종 발효 단계입니다.',
      metadata: {
        'optimized': true,
        'explanations': finalSettings.explanations,
        'warnings': finalSettings.warnings,
        'tips': finalSettings.tips,
      },
    ));
    
    final totalDuration = stages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );
    
    return FermentationScenarioV2(
      id: 'fermenter_basic_${DateTime.now().millisecondsSinceEpoch}',
      name: '발효기 기본 시나리오',
      description: '발효기를 사용한 과학적으로 최적화된 기본 발효 과정입니다.\n'
                  '레시피 특성에 맞춰 온도, 습도, 시간이 자동 계산됩니다.',
      mode: FermentationMode.fermenter,
      method: FermentationMethodV2.normal,
      stages: stages,
      recipeAnalysis: recipe,
      environmentalConditions: environment,
      createdAt: DateTime.now(),
      totalDuration: totalDuration,
      metadata: {
        'type': 'optimized_fermenter',
        'difficulty': 'beginner',
        'advantages': ['정확한 온도/습도 제어', '예측 가능한 결과', '과학적 근거'],
        'requirements': ['발효기 필요', '정확한 설정'],
      },
      confidenceScore: 0.95,
    );
  }
  
  /// 냉장 저온 발효 시나리오
  static Future<FermentationScenarioV2> _createColdRetardationScenario(
    RecipeAnalysis recipe,
    EnvironmentalConditions environment,
  ) async {
    final stages = <FermentationStageV2>[];
    
    // 짧은 1차 발효
    final primarySettings = FermenterOptimizationGuide.calculateOptimalSettings(
      recipe: recipe,
      stageType: FermentationStageType.primary,
    );
    
    stages.add(FermentationStageV2(
      name: '1차 발효 (단축)',
      type: FermentationStageType.primary,
      duration: Duration(minutes: (primarySettings.duration.inMinutes * 0.7).round()),
      temperature: TemperatureRange(
        min: primarySettings.temperature - 2,
        max: primarySettings.temperature + 2,
        optimal: primarySettings.temperature,
      ),
      humidity: HumidityRange(
        min: primarySettings.humidity - 5,
        max: primarySettings.humidity + 5,
        optimal: primarySettings.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '발효기에서 단축된 1차 발효를 진행하세요',
          description: '냉장 발효를 위한 준비 단계입니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': (primarySettings.duration.inMinutes * 0.7).round()},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '1차 발효가 완료되었습니다. 냉장고로 이동하세요.',
      ),
      description: '냉장 발효를 위한 단축된 1차 발효입니다.',
    ));
    
    // 냉장 저온 발효
    stages.add(FermentationStageV2(
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
          action: '반죽을 밀폐용기에 담아 냉장고(4°C)에 보관하세요',
          description: '12시간 동안 천천히 발효되어 풍미가 발달합니다',
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
        message: '냉장 발효가 완료되었습니다. 실온에서 1시간 적응시키세요.',
        beforeCompletion: Duration(hours: 1),
      ),
      description: '저온에서 천천히 발효하여 깊은 풍미를 만듭니다.',
    ));
    
    // 실온 적응 및 최종 발효
    final finalSettings = FermenterOptimizationGuide.calculateOptimalSettings(
      recipe: recipe,
      stageType: FermentationStageType.finalProofing,
    );
    
    stages.add(FermentationStageV2(
      name: '실온 적응 및 최종 발효',
      type: FermentationStageType.finalProofing,
      duration: Duration(minutes: (finalSettings.duration.inMinutes * 0.8).round()),
      temperature: TemperatureRange(
        min: finalSettings.temperature - 2,
        max: finalSettings.temperature + 2,
        optimal: finalSettings.temperature,
      ),
      humidity: HumidityRange(
        min: finalSettings.humidity - 5,
        max: finalSettings.humidity + 5,
        optimal: finalSettings.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '냉장고에서 꺼내 1시간 실온 적응 후 발효기에서 최종 발효하세요',
          description: '냉장 발효 후이므로 시간이 단축됩니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': (finalSettings.duration.inMinutes * 0.8).round()},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '최종 발효가 완료되었습니다. 오븐에서 구워주세요.',
      ),
      description: '냉장 발효 후 마지막 발효 단계입니다.',
    ));
    
    final totalDuration = stages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );
    
    return FermentationScenarioV2(
      id: 'fermenter_cold_${DateTime.now().millisecondsSinceEpoch}',
      name: '발효기 + 냉장 저온 발효',
      description: '발효기와 냉장고를 함께 사용하여 풍미를 극대화하는 시나리오입니다.\n'
                  '시간은 오래 걸리지만 깊고 복합적인 맛을 얻을 수 있습니다.',
      mode: FermentationMode.fermenter,
      method: FermentationMethodV2.coldRetardation,
      stages: stages,
      recipeAnalysis: recipe,
      environmentalConditions: environment,
      createdAt: DateTime.now(),
      totalDuration: totalDuration,
      metadata: {
        'type': 'cold_retardation',
        'difficulty': 'intermediate',
        'advantages': ['풍미 발달', '스케줄 유연성', '글루텐 강화'],
        'requirements': ['발효기', '냉장고', '시간 여유'],
      },
      confidenceScore: 0.9,
    );
  }
  
  /// 냉동 보관 시나리오
  static Future<FermentationScenarioV2> _createFreezerScenario(
    RecipeAnalysis recipe,
    EnvironmentalConditions environment,
  ) async {
    final freezerSettings = FermenterOptimizationGuide.calculateFreezerSettings(
      recipe: recipe,
    );
    
    final stages = <FermentationStageV2>[];
    
    // 짧은 1차 발효
    final primarySettings = FermenterOptimizationGuide.calculateOptimalSettings(
      recipe: recipe,
      stageType: FermentationStageType.primary,
    );
    
    stages.add(FermentationStageV2(
      name: '1차 발효 (단축)',
      type: FermentationStageType.primary,
      duration: Duration(minutes: (primarySettings.duration.inMinutes * 0.6).round()),
      temperature: TemperatureRange(
        min: primarySettings.temperature - 2,
        max: primarySettings.temperature + 2,
        optimal: primarySettings.temperature,
      ),
      humidity: HumidityRange(
        min: primarySettings.humidity - 5,
        max: primarySettings.humidity + 5,
        optimal: primarySettings.humidity,
      ),
      instructions: [
        UserInstruction(
          action: '발효기에서 단축된 1차 발효를 진행하세요',
          description: '냉동 보관을 위한 준비 단계입니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': (primarySettings.duration.inMinutes * 0.6).round()},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '1차 발효가 완료되었습니다. 냉동 보관하세요.',
      ),
      description: '냉동 보관을 위한 단축된 1차 발효입니다.',
    ));
    
    // 냉동 보관
    stages.add(FermentationStageV2(
      name: '냉동 보관',
      type: FermentationStageType.storage,
      duration: freezerSettings.recommendedDuration,
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
          action: '반죽을 밀폐 포장하여 냉동고(-18°C)에 보관하세요',
          description: '최대 ${freezerSettings.maxStorageDuration.inDays}일까지 보관 가능합니다',
          timing: Duration.zero,
          priority: InstructionPriority.critical,
          equipmentTarget: '냉동고',
        ),
      ],
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': freezerSettings.recommendedDuration.inMinutes},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '냉동 보관이 완료되었습니다. 사용 12시간 전에 해동을 시작하세요.',
        beforeCompletion: Duration(hours: 12),
      ),
      description: '장기간 보관을 위한 냉동 단계입니다.',
      metadata: {
        'packagingInstructions': freezerSettings.packagingInstructions,
        'qualityImpact': freezerSettings.qualityImpact,
        'suitabilityScore': freezerSettings.suitabilityScore,
      },
    ));
    
    // 해동 및 최종 발효는 사용 시점에 별도 가이드 제공
    
    final totalDuration = stages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );
    
    return FermentationScenarioV2(
      id: 'fermenter_freezer_${DateTime.now().millisecondsSinceEpoch}',
      name: '발효기 + 냉동 보관',
      description: '발효기로 기본 발효 후 냉동 보관하는 편리한 시나리오입니다.\n'
                  '계획적인 베이킹에 적합하며 최대 ${freezerSettings.maxStorageDuration.inDays}일 보관 가능합니다.',
      mode: FermentationMode.fermenter,
      method: FermentationMethodV2.freezerOvernight,
      stages: stages,
      recipeAnalysis: recipe,
      environmentalConditions: environment,
      createdAt: DateTime.now(),
      totalDuration: totalDuration,
      metadata: {
        'type': 'freezer_storage',
        'difficulty': 'intermediate',
        'advantages': ['장기 보관', '계획적 베이킹', '편의성'],
        'requirements': ['발효기', '냉동고', '적절한 포장'],
        'suitabilityScore': freezerSettings.suitabilityScore,
        'qualityImpact': freezerSettings.qualityImpact,
      },
      confidenceScore: freezerSettings.suitabilityScore,
    );
  }
  
  /// 시나리오 추천 시스템
  static FermentationScenarioV2? recommendBestScenario(
    List<FermentationScenarioV2> scenarios,
    Map<String, dynamic> userPreferences,
  ) {
    if (scenarios.isEmpty) return null;
    
    // 사용자 선호도에 따른 점수 계산
    double calculateScore(FermentationScenarioV2 scenario) {
      double score = scenario.confidenceScore;
      
      // 시간 선호도
      final timePreference = userPreferences['timePreference'] as String?;
      if (timePreference == 'quick' && scenario.totalDuration.inHours < 6) {
        score += 0.2;
      } else if (timePreference == 'slow' && scenario.totalDuration.inHours > 12) {
        score += 0.2;
      }
      
      // 복잡도 선호도
      final complexityPreference = userPreferences['complexityPreference'] as String?;
      final difficulty = scenario.metadata['difficulty'] as String?;
      if (complexityPreference == 'simple' && difficulty == 'beginner') {
        score += 0.1;
      } else if (complexityPreference == 'advanced' && difficulty == 'intermediate') {
        score += 0.1;
      }
      
      // 장비 가용성
      final hasRefrigerator = userPreferences['hasRefrigerator'] as bool? ?? true;
      final hasFreezer = userPreferences['hasFreezer'] as bool? ?? true;
      final hasFermenter = userPreferences['hasFermenter'] as bool? ?? false;
      
      if (scenario.mode == FermentationMode.fermenter && !hasFermenter) {
        score -= 0.5; // 발효기가 없으면 큰 감점
      }
      
      if (scenario.method == FermentationMethodV2.coldRetardation && !hasRefrigerator) {
        score -= 0.3;
      }
      
      if (scenario.method == FermentationMethodV2.freezerOvernight && !hasFreezer) {
        score -= 0.3;
      }
      
      return score.clamp(0.0, 1.0);
    }
    
    // 점수 기준으로 정렬하여 최고 점수 반환
    scenarios.sort((a, b) => calculateScore(b).compareTo(calculateScore(a)));
    return scenarios.first;
  }
}