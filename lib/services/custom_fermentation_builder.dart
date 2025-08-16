/// 커스텀 발효 시나리오 빌더
/// 사용자가 완전히 커스터마이징할 수 있는 발효 시나리오 생성 시스템

import 'dart:math' as math;
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';
import 'fermenter_guide_manager.dart';

/// 커스텀 발효 단계 빌더
class CustomFermentationStageBuilder {
  String name = '';
  FermentationStageType type = FermentationStageType.primary;
  Duration duration = Duration(minutes: 60);
  double? temperature;
  double? humidity;
  List<String> userInstructions = [];
  List<String> tips = [];
  List<String> warnings = [];
  String description = '';
  
  /// 단계 생성
  FermentationStageV2 build() {
    return FermentationStageV2(
      name: name.isEmpty ? _getDefaultName(type) : name,
      type: type,
      duration: duration,
      temperature: temperature != null ? TemperatureRange(
        min: temperature! - 2,
        max: temperature! + 2,
        optimal: temperature!,
      ) : null,
      humidity: humidity != null ? HumidityRange(
        min: humidity! - 5,
        max: humidity! + 5,
        optimal: humidity!,
      ) : null,
      instructions: userInstructions.map((instruction) => UserInstruction(
        action: instruction,
        description: instruction,
        timing: Duration.zero,
        priority: InstructionPriority.important,
      )).toList(),
      automations: [
        AutomationAction(
          target: AutomationTarget.timer,
          settings: {'duration': duration.inMinutes},
          executeAt: Duration.zero,
        ),
      ],
      alerts: AlertSettings(
        message: '${name.isEmpty ? _getDefaultName(type) : name}이(가) 완료되었습니다.',
      ),
      description: description.isEmpty ? _getDefaultDescription(type) : description,
      metadata: {
        'custom': true,
        'userCreated': true,
        'tips': tips,
        'warnings': warnings,
      },
    );
  }

  String _getDefaultName(FermentationStageType type) {
    switch (type) {
      case FermentationStageType.primary:
        return '1차 발효';
      case FermentationStageType.secondary:
        return '2차 발효';
      case FermentationStageType.rest:
        return '휴지';
      case FermentationStageType.final:
        return '최종 발효';
      case FermentationStageType.storage:
        return '보관';
      case FermentationStageType.thawing:
        return '해동';
    }
  }

  String _getDefaultDescription(FermentationStageType type) {
    switch (type) {
      case FermentationStageType.primary:
        return '반죽의 기본 발효 단계입니다.';
      case FermentationStageType.secondary:
        return '추가 발효로 풍미를 발달시킵니다.';
      case FermentationStageType.rest:
        return '반죽을 휴지시켜 글루텐을 이완시킵니다.';
      case FermentationStageType.final:
        return '굽기 전 마지막 발효 단계입니다.';
      case FermentationStageType.storage:
        return '반죽을 보관하는 단계입니다.';
      case FermentationStageType.thawing:
        return '냉동된 반죽을 해동하는 단계입니다.';
    }
  }
}

/// 커스텀 발효 시나리오 빌더
class CustomFermentationBuilder {
  String scenarioName = '';
  String description = '';
  FermentationMode mode = FermentationMode.roomTemperature;
  List<CustomFermentationStageBuilder> stageBuilders = [];
  EnvironmentalConditions? environmentalConditions;
  RecipeAnalysis? recipeAnalysis;
  
  /// 단계 추가
  void addStage(CustomFermentationStageBuilder stageBuilder) {
    stageBuilders.add(stageBuilder);
  }
  
  /// 단계 제거
  void removeStage(int index) {
    if (index >= 0 && index < stageBuilders.length) {
      stageBuilders.removeAt(index);
    }
  }
  
  /// 단계 순서 변경
  void moveStage(int fromIndex, int toIndex) {
    if (fromIndex >= 0 && fromIndex < stageBuilders.length &&
        toIndex >= 0 && toIndex < stageBuilders.length) {
      final stage = stageBuilders.removeAt(fromIndex);
      stageBuilders.insert(toIndex, stage);
    }
  }
  
  /// 시나리오 생성
  FermentationScenarioV2 build() {
    final stages = stageBuilders.map((builder) => builder.build()).toList();
    final totalDuration = stages.fold<Duration>(
      Duration.zero,
      (total, stage) => total + stage.duration,
    );
    
    return FermentationScenarioV2(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: scenarioName.isEmpty ? '커스텀 발효 시나리오' : scenarioName,
      description: description.isEmpty ? '사용자가 직접 만든 발효 시나리오입니다.' : description,
      mode: mode,
      method: FermentationMethodV2.custom,
      stages: stages,
      recipeAnalysis: recipeAnalysis,
      environmentalConditions: environmentalConditions,
      createdAt: DateTime.now(),
      totalDuration: totalDuration,
      metadata: {
        'custom': true,
        'userCreated': true,
        'stageCount': stages.length,
        'totalMinutes': totalDuration.inMinutes,
      },
      confidenceScore: 1.0, // 사용자 커스텀이므로 최대 신뢰도
    );
  }
  
  /// 빠른 시나리오 템플릿 생성
  static CustomFermentationBuilder quickTemplate({
    required String name,
    required FermentationMode mode,
    EnvironmentalConditions? environment,
    RecipeAnalysis? recipe,
  }) {
    final builder = CustomFermentationBuilder()
      ..scenarioName = name
      ..mode = mode
      ..environmentalConditions = environment
      ..recipeAnalysis = recipe;
    
    // 기본 단계들 추가
    switch (mode) {
      case FermentationMode.roomTemperature:
        builder._addRoomTemperatureStages(environment, recipe);
        break;
      case FermentationMode.fermenter:
        builder._addFermenterStages(environment, recipe);
        break;
    }
    
    return builder;
  }
  
  void _addRoomTemperatureStages(EnvironmentalConditions? env, RecipeAnalysis? recipe) {
    final baseTemp = env?.temperature ?? 25.0;
    final baseHumidity = env?.humidity ?? 65.0;
    
    // 1차 발효
    final primary = CustomFermentationStageBuilder()
      ..name = '1차 발효'
      ..type = FermentationStageType.primary
      ..duration = Duration(minutes: 90)
      ..temperature = baseTemp
      ..humidity = baseHumidity
      ..userInstructions = [
        '반죽을 볼에 넣고 덮개를 덮으세요',
        '30분마다 폴딩하세요 (총 2-3회)',
      ]
      ..tips = [
        '반죽이 1.5-2배 부풀 때까지 기다리세요',
        '온도가 높으면 시간을 단축하세요',
      ]
      ..description = '반죽의 기본 발효 단계입니다.';
    
    // 휴지
    final rest = CustomFermentationStageBuilder()
      ..name = '분할 후 휴지'
      ..type = FermentationStageType.rest
      ..duration = Duration(minutes: 20)
      ..temperature = baseTemp - 1
      ..humidity = baseHumidity
      ..userInstructions = [
        '반죽을 원하는 크기로 분할하세요',
        '둥글게 정리하고 덮개를 덮으세요',
      ]
      ..description = '분할로 인한 스트레스를 완화합니다.';
    
    // 최종 발효
    final final_ = CustomFermentationStageBuilder()
      ..name = '최종 발효'
      ..type = FermentationStageType.final
      ..duration = Duration(minutes: 60)
      ..temperature = baseTemp + 2
      ..humidity = baseHumidity + 10
      ..userInstructions = [
        '성형 후 따뜻하고 습한 곳에 두세요',
        '손가락 테스트로 발효 상태를 확인하세요',
      ]
      ..tips = [
        '과발효되지 않도록 주의하세요',
        '오븐을 미리 예열하세요',
      ]
      ..description = '굽기 전 마지막 발효 단계입니다.';
    
    stageBuilders.addAll([primary, rest, final_]);
  }
  
  void _addFermenterStages(EnvironmentalConditions? env, RecipeAnalysis? recipe) {
    // 발효기 모드는 사용자가 직접 설정하도록 빈 템플릿만 제공
    final stage = CustomFermentationStageBuilder()
      ..name = '발효기 발효'
      ..type = FermentationStageType.primary
      ..duration = Duration(minutes: 90)
      ..userInstructions = [
        '발효기 설정을 확인하세요',
        '반죽을 발효기에 넣으세요',
      ]
      ..description = '발효기를 사용한 발효 단계입니다.';
    
    stageBuilders.add(stage);
  }
}

/// 발효기 설정 가이드 시스템
class FermenterSettingsGuide {
  /// 최적 설정값 계산 및 가이드 제공
  static Map<String, dynamic> calculateOptimalSettings({
    required RecipeAnalysis recipe,
    required FermentationStageType stageType,
    EnvironmentalConditions? environment,
  }) {
    // FermenterGuideManager를 활용한 기본 계산
    final dummyStage = FermentationStageV2(
      name: 'temp',
      type: stageType,
      duration: Duration(minutes: 90),
      temperature: TemperatureRange(min: 25, max: 30, optimal: 28),
      humidity: HumidityRange(min: 70, max: 80, optimal: 75),
      instructions: [],
      automations: [],
      alerts: AlertSettings(message: ''),
      description: '',
    );
    
    final settings = FermenterGuideManager.calculateOptimalSettings(dummyStage, recipe);
    
    return {
      'temperature': {
        'optimal': settings.temperature,
        'range': {
          'min': settings.temperature - 2,
          'max': settings.temperature + 2,
        },
        'explanation': _getTemperatureExplanation(settings.temperature, recipe),
        'adjustmentReason': _getTemperatureAdjustmentReason(recipe),
      },
      'humidity': {
        'optimal': settings.humidity,
        'range': {
          'min': settings.humidity - 5,
          'max': settings.humidity + 5,
        },
        'explanation': _getHumidityExplanation(settings.humidity, recipe),
        'adjustmentReason': _getHumidityAdjustmentReason(recipe),
      },
      'duration': {
        'optimal': settings.duration.inMinutes,
        'range': {
          'min': (settings.duration.inMinutes * 0.8).round(),
          'max': (settings.duration.inMinutes * 1.2).round(),
        },
        'explanation': _getDurationExplanation(settings.duration, recipe),
      },
      'tips': _getSettingsTips(stageType, recipe),
      'warnings': _getSettingsWarnings(stageType, recipe),
      'troubleshooting': FermenterGuideManager.getTroubleshootingGuide(),
    };
  }
  
  /// 냉동 보관 설정 가이드
  static Map<String, dynamic> getFreezerSettings({
    required RecipeAnalysis recipe,
    Duration? plannedStorage,
  }) {
    final maxStorage = Duration(days: 7);
    final recommendedStorage = plannedStorage ?? Duration(hours: 24);
    
    return {
      'temperature': {
        'optimal': -18.0,
        'range': {'min': -20.0, 'max': -15.0},
        'explanation': '-18°C는 반죽의 구조를 보호하면서 장기 보관이 가능한 최적 온도입니다.',
      },
      'humidity': {
        'optimal': 5.0,
        'range': {'min': 0.0, 'max': 10.0},
        'explanation': '냉동고는 자연적으로 습도가 낮으므로 밀폐 보관이 중요합니다.',
      },
      'maxStorageDuration': maxStorage.inDays,
      'recommendedStorage': recommendedStorage.inHours,
      'packaging': [
        '밀폐용기나 냉동백 사용',
        '공기를 최대한 제거',
        '날짜와 내용물 표시',
      ],
      'thawingInstructions': [
        '사용 12시간 전에 냉장고로 이동',
        '냉장고에서 천천히 해동 (4°C)',
        '해동 후 2시간 실온 적응',
      ],
      'qualityNotes': [
        '냉동으로 인한 약간의 질감 변화 가능',
        '해동 후 발효 시간이 약간 길어질 수 있음',
        '재냉동은 절대 금지',
      ],
    };
  }
  
  /// 해동 설정 가이드
  static Map<String, dynamic> getThawingSettings({
    required RecipeAnalysis recipe,
    required Duration frozenDuration,
  }) {
    // 냉동 기간에 따른 해동 시간 조정
    final baseThawingTime = Duration(hours: 12);
    final adjustedTime = frozenDuration.inDays > 3 
        ? Duration(hours: 14)
        : baseThawingTime;
    
    return {
      'refrigeratorThawing': {
        'temperature': 4.0,
        'duration': adjustedTime.inHours,
        'humidity': 85.0,
        'instructions': [
          '냉동고에서 냉장고로 이동',
          '밀폐 상태 유지',
          '${adjustedTime.inHours}시간 대기',
        ],
      },
      'roomTemperatureAdaptation': {
        'temperature': 22.0,
        'duration': 2,
        'humidity': 65.0,
        'instructions': [
          '냉장고에서 실온으로 이동',
          '덮개를 덮어 마르지 않게 보호',
          '2시간 실온 적응',
        ],
      },
      'finalFermentation': {
        'temperatureAdjustment': '+2°C',
        'durationAdjustment': '+30분',
        'explanation': '냉동 해동 과정으로 인해 발효가 느려질 수 있습니다.',
      },
      'qualityChecks': [
        '해동 후 반죽의 탄력성 확인',
        '이상한 냄새나 색깔 변화 확인',
        '표면 건조 상태 확인',
      ],
    };
  }
  
  /// 단계별 최적화 가이드
  static Map<String, dynamic> getStageOptimizationGuide(FermentationStageType stageType) {
    switch (stageType) {
      case FermentationStageType.primary:
        return {
          'focus': '기본 발효력 확보',
          'keyFactors': ['온도 안정성', '적절한 습도', '충분한 시간'],
          'optimization': {
            'temperature': '28°C ± 2°C 유지',
            'humidity': '75% ± 5% 유지',
            'monitoring': '30분마다 상태 확인',
          },
          'successIndicators': [
            '반죽이 1.5-2배 부풀음',
            '표면에 기포가 보임',
            '손가락으로 눌렀을 때 천천히 돌아옴',
          ],
        };
        
      case FermentationStageType.final:
        return {
          'focus': '최종 부피 확보 및 과발효 방지',
          'keyFactors': ['정확한 타이밍', '온도 관리', '습도 유지'],
          'optimization': {
            'temperature': '30°C ± 2°C (1차보다 약간 높게)',
            'humidity': '80% ± 5% (높은 습도 유지)',
            'monitoring': '15분마다 상태 확인',
          },
          'successIndicators': [
            '반죽이 팬의 80% 정도 채움',
            '손가락 테스트에서 적절한 반응',
            '표면이 매끄럽고 윤기가 남',
          ],
        };
        
      case FermentationStageType.storage:
        return {
          'focus': '장기 보관 및 풍미 발달',
          'keyFactors': ['저온 유지', '습도 관리', '밀폐 보관'],
          'optimization': {
            'temperature': '4°C ± 1°C (냉장) 또는 -18°C ± 2°C (냉동)',
            'humidity': '85% (냉장) 또는 5% (냉동)',
            'packaging': '밀폐용기 또는 랩 포장',
          },
          'maxDuration': {
            'refrigerator': '3일',
            'freezer': '7일',
          },
        };
        
      default:
        return {
          'focus': '단계별 최적화',
          'keyFactors': ['온도', '습도', '시간'],
          'optimization': {
            'temperature': '레시피에 따라 조정',
            'humidity': '환경에 따라 조정',
            'monitoring': '정기적인 상태 확인',
          },
        };
    }
  }
  
  // Private helper methods
  static String _getTemperatureExplanation(double temp, RecipeAnalysis recipe) {
    if (temp < 25) {
      return '저온 발효로 천천히 진행되어 풍미가 발달합니다.';
    } else if (temp > 30) {
      return '고온 발효로 빠르게 진행되지만 과발효 주의가 필요합니다.';
    } else {
      return '적정 온도로 안정적인 발효가 가능합니다.';
    }
  }
  
  static String _getTemperatureAdjustmentReason(RecipeAnalysis recipe) {
    final reasons = <String>[];
    
    if (recipe.sugarPercentage > 15) {
      reasons.add('고당분으로 인해 온도를 낮춤 (-2°C)');
    }
    if (recipe.yeastPercentage > 2.0) {
      reasons.add('고이스트로 인해 온도를 낮춤 (-1°C)');
    } else if (recipe.yeastPercentage < 0.8) {
      reasons.add('저이스트로 인해 온도를 높임 (+2°C)');
    }
    
    return reasons.isEmpty ? '기본 설정 적용' : reasons.join(', ');
  }
  
  static String _getHumidityExplanation(double humidity, RecipeAnalysis recipe) {
    if (humidity < 70) {
      return '낮은 습도로 표면이 마를 수 있으니 덮개 사용을 권장합니다.';
    } else if (humidity > 85) {
      return '높은 습도로 곰팡이 위험이 있으니 환기에 주의하세요.';
    } else {
      return '적정 습도로 반죽 표면이 적절히 유지됩니다.';
    }
  }
  
  static String _getHumidityAdjustmentReason(RecipeAnalysis recipe) {
    final reasons = <String>[];
    
    if (recipe.hydrationLevel > 75) {
      reasons.add('고수분으로 인해 습도를 높임 (+5%)');
    } else if (recipe.hydrationLevel < 60) {
      reasons.add('저수분으로 인해 습도를 낮춤 (-5%)');
    }
    
    return reasons.isEmpty ? '기본 설정 적용' : reasons.join(', ');
  }
  
  static String _getDurationExplanation(Duration duration, RecipeAnalysis recipe) {
    if (duration.inMinutes < 60) {
      return '짧은 발효 시간으로 빠른 진행이 가능합니다.';
    } else if (duration.inMinutes > 120) {
      return '긴 발효 시간으로 충분한 발효와 풍미 발달이 가능합니다.';
    } else {
      return '적정 발효 시간으로 안정적인 결과를 얻을 수 있습니다.';
    }
  }
  
  static List<String> _getSettingsTips(FermentationStageType stageType, RecipeAnalysis recipe) {
    final tips = <String>[];
    
    switch (stageType) {
      case FermentationStageType.primary:
        tips.addAll([
          '30분마다 폴딩하면 글루텐 형성에 도움됩니다',
          '반죽이 1.5-2배 부풀 때까지 기다리세요',
          '온도가 높으면 시간을 단축하세요',
        ]);
        break;
      case FermentationStageType.final:
        tips.addAll([
          '과발효되지 않도록 주의깊게 관찰하세요',
          '손가락 테스트로 발효 상태를 확인하세요',
          '오븐을 미리 예열해두세요',
        ]);
        break;
      default:
        tips.add('정기적으로 상태를 확인하세요');
    }
    
    return tips;
  }
  
  static List<String> _getSettingsWarnings(FermentationStageType stageType, RecipeAnalysis recipe) {
    final warnings = <String>[];
    
    if (recipe.sugarPercentage > 20) {
      warnings.add('고당분 레시피는 과발효 위험이 높습니다');
    }
    if (recipe.yeastPercentage > 2.5) {
      warnings.add('고이스트 레시피는 발효가 매우 빠를 수 있습니다');
    }
    
    switch (stageType) {
      case FermentationStageType.final:
        warnings.add('최종 발효는 과발효되면 되돌릴 수 없습니다');
        break;
      case FermentationStageType.storage:
        warnings.add('보관 중에는 온도 변화를 최소화하세요');
        break;
      default:
        break;
    }
    
    return warnings;
  }
}