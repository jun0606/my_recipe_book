/// 발효기 설정 가이드 관리자
/// 발효기 사용자에게 최적 설정값과 설정 방법을 체계적으로 안내하는 핵심 시스템
library;

import 'dart:math' as math;
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import 'fermentation_guide_service.dart';


// FermenterType과 InstructionPriority는 fermentation_scenario_v2.dart에서 import됨

/// 발효기 설정 정보
class FermenterSettings {
  final double temperature;      // 설정 온도 (°C)
  final double humidity;         // 설정 습도 (%)
  final Duration duration;       // 설정 시간
  final String stageName;        // 단계 이름
  final FermentationStageType stageType; // 단계 타입
  final Map<String, dynamic> metadata; // 추가 정보

  const FermenterSettings({
    required this.temperature,
    required this.humidity,
    required this.duration,
    required this.stageName,
    required this.stageType,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'duration': duration.inMinutes,
    'stageName': stageName,
    'stageType': stageType.name,
    'metadata': metadata,
  };

  factory FermenterSettings.fromJson(Map<String, dynamic> json) {
    return FermenterSettings(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      duration: Duration(minutes: json['duration']),
      stageName: json['stageName'],
      stageType: FermentationStageType.values.firstWhere(
        (e) => e.name == json['stageType'],
      ),
      metadata: json['metadata'] ?? {},
    );
  }
}

/// 설정 지침
class SettingInstruction {
  final String title;            // 지침 제목
  final String description;      // 상세 설명
  final List<String> steps;      // 단계별 설명
  final InstructionPriority priority; // 우선순위
  final String? equipmentTarget; // 대상 장비
  final List<String> tips;       // 추가 팁
  final List<String> warnings;   // 주의사항

  const SettingInstruction({
    required this.title,
    required this.description,
    required this.steps,
    required this.priority,
    this.equipmentTarget,
    this.tips = const [],
    this.warnings = const [],
  });
}

/// 안전한 보관 설정
class SafeStorageSettings {
  final StorageType type;        // 보관 타입
  final double temperature;      // 보관 온도
  final double humidity;         // 보관 습도
  final Duration maxDuration;    // 최대 보관 시간
  final List<String> instructions; // 보관 지침
  final List<String> safetyTips; // 안전 팁

  const SafeStorageSettings({
    required this.type,
    required this.temperature,
    required this.humidity,
    required this.maxDuration,
    required this.instructions,
    this.safetyTips = const [],
  });
}

/// 보관 타입
enum StorageType {
  refrigerator,  // 냉장 보관
  freezer,       // 냉동 보관
  roomTemp,      // 실온 보관
}

/// 발효기 설정 가이드 관리자
class FermenterGuideManager {
  /// 새로운 통합 서비스를 사용한 가이드 생성 (권장)
  static Future<Map<String, dynamic>> generateCustomGuideV2({
    required String fermentationType,
    required Map<String, dynamic> recipeData,
    required Map<String, dynamic> environmentalData,
    Map<String, dynamic>? customOptions,
  }) async {
    try {
      // FermentationGuideService를 사용하여 실제 가이드 생성
      final fermentationGuideService = FermentationGuideService();
      
      final guide = await fermentationGuideService.generateGuide(
        fermentationType: fermentationType,
        recipeData: recipeData,
        environmentalData: environmentalData,
        customOptions: customOptions,
      );
      
      // 레거시 호환성을 위해 Map 형태로 변환
      return guide.toLegacyMap();
    } catch (e) {
      // 오류 발생 시 기본 가이드 반환
      print('발효 가이드 생성 중 오류 발생: $e');
      return _getDefaultGuide(fermentationType);
    }
  }

  /// 레거시 호환성을 위한 기본 가이드
  static Map<String, dynamic> _getDefaultGuide(String fermentationType) {
    return {
      'methodExplanation': '$fermentationType 발효 방식입니다.',
      'customInstructions': ['기본 발효 지침을 따르세요.'],
      'tips': [],
      'warnings': [],
      'environmentalFactors': {},
      'recipeFactors': {},
      'recommendations': [],
      'quickStartTips': [],
      'steps': [],
    };
  }
  /// 발효기 최적 설정값 계산
  static FermenterSettings calculateOptimalSettings(
    FermentationStageV2 stage,
    RecipeAnalysis recipe,
  ) {
    // 기본 설정값
    double baseTemp = 28.0;
    double baseHumidity = 75.0;

    // 단계별 기본 조정
    switch (stage.type) {
      case FermentationStageType.primary:
        baseTemp = 28.0;
        baseHumidity = 75.0;
        break;
      case FermentationStageType.rest:
        baseTemp = 26.0;
        baseHumidity = 70.0;
        break;
      case FermentationStageType.finalProofing:
        baseTemp = 30.0;
        baseHumidity = 80.0;
        break;
      case FermentationStageType.storage:
        baseTemp = 4.0;  // 냉장 보관
        baseHumidity = 85.0;
        break;
      case FermentationStageType.thawing:
        baseTemp = 26.0;
        baseHumidity = 80.0;
        break;
      default:
        baseTemp = 27.0;
        baseHumidity = 75.0;
    }

    // 레시피 특성에 따른 조정
    double tempAdjustment = 0.0;
    double humidityAdjustment = 0.0;

    // 설탕 함량 조정
    if (recipe.sugarPercentage > 15) {
      tempAdjustment -= 2.0; // 고당분은 온도 낮춤
    } else if (recipe.sugarPercentage < 5) {
      tempAdjustment += 1.0; // 저당분은 온도 높임
    }

    // 이스트 양 조정
    if (recipe.yeastPercentage > 2.0) {
      tempAdjustment -= 1.0; // 고이스트는 온도 낮춤
    } else if (recipe.yeastPercentage < 0.8) {
      tempAdjustment += 2.0; // 저이스트는 온도 높임
    }

    // 수분 함량 조정
    if (recipe.hydrationLevel > 75) {
      humidityAdjustment += 5.0; // 고수분은 습도 높임
    } else if (recipe.hydrationLevel < 60) {
      humidityAdjustment -= 5.0; // 저수분은 습도 낮춤
    }

    // 최종 설정값 계산
    final finalTemp = (baseTemp + tempAdjustment).clamp(18.0, 35.0);
    final finalHumidity = (baseHumidity + humidityAdjustment).clamp(60.0, 90.0);

    return FermenterSettings(
      temperature: finalTemp,
      humidity: finalHumidity,
      duration: stage.duration,
      stageName: stage.name,
      stageType: stage.type,
      metadata: {
        'baseTemp': baseTemp,
        'baseHumidity': baseHumidity,
        'tempAdjustment': tempAdjustment,
        'humidityAdjustment': humidityAdjustment,
        'sugarPercentage': recipe.sugarPercentage,
        'yeastPercentage': recipe.yeastPercentage,
        'hydrationLevel': recipe.hydrationLevel,
      },
    );
  }

  /// 발효기 설정 지침 생성
  static List<SettingInstruction> generateSettingInstructions(
    FermenterSettings settings,
    FermenterType fermenterType,
  ) {
    final instructions = <SettingInstruction>[];

    // 온도 설정 지침
    instructions.add(SettingInstruction(
      title: '온도 설정',
      description: '발효기를 ${settings.temperature.toStringAsFixed(0)}°C로 설정하세요',
      steps: fermenterType == FermenterType.smart
          ? [
              '발효기 전원을 켜세요',
              '디지털 패널에서 온도 설정 메뉴를 선택하세요',
              '온도를 ${settings.temperature.toStringAsFixed(0)}°C로 입력하세요',
              '설정 완료 버튼을 누르세요',
              '온도가 안정될 때까지 5분 기다리세요',
            ]
          : [
              '발효기 전원을 켜세요',
              '온도 다이얼을 천천히 돌려주세요',
              '${settings.temperature.toStringAsFixed(0)}°C 눈금에 맞춰주세요',
              '온도계로 실제 온도를 확인하세요',
              '온도가 안정될 때까지 10분 기다리세요',
            ],
      priority: InstructionPriority.critical,
      equipmentTarget: '발효기',
      tips: [
        '온도가 ±1°C 범위 내에 있으면 정상입니다',
        '온도가 너무 높으면 문을 살짝 열어 조절하세요',
        '온도가 너무 낮으면 설정을 다시 확인하세요',
      ],
      warnings: [
        '35°C를 초과하지 마세요 (이스트 사멸 위험)',
        '18°C 미만에서는 발효가 거의 진행되지 않습니다',
      ],
    ));

    // 습도 설정 지침
    instructions.add(SettingInstruction(
      title: '습도 설정',
      description: '발효기 습도를 ${settings.humidity.toStringAsFixed(0)}%로 설정하세요',
      steps: fermenterType == FermenterType.smart
          ? [
              '디지털 패널에서 습도 설정 메뉴를 선택하세요',
              '습도를 ${settings.humidity.toStringAsFixed(0)}%로 입력하세요',
              '설정 완료 버튼을 누르세요',
              '습도가 안정될 때까지 기다리세요',
            ]
          : [
              '발효기 내부의 물통을 확인하세요',
              '물통에 깨끗한 물을 적절히 넣으세요',
              '습도계로 현재 습도를 확인하세요',
              '목표 습도에 맞춰 물의 양을 조절하세요',
            ],
      priority: InstructionPriority.critical,
      equipmentTarget: '발효기',
      tips: [
        '습도가 ±5% 범위 내에 있으면 정상입니다',
        '습도가 낮으면 물을 더 추가하세요',
        '습도가 높으면 물을 줄이거나 환기하세요',
      ],
      warnings: [
        '90%를 초과하면 곰팡이 위험이 있습니다',
        '60% 미만에서는 반죽이 마를 수 있습니다',
      ],
    ));

    // 타이머 설정 지침
    instructions.add(SettingInstruction(
      title: '타이머 설정',
      description: '발효 시간을 ${settings.duration.inMinutes}분으로 설정하세요',
      steps: fermenterType == FermenterType.smart
          ? [
              '타이머 설정 메뉴를 선택하세요',
              '시간을 ${settings.duration.inMinutes}분으로 입력하세요',
              '알림 설정을 활성화하세요',
              '타이머를 시작하세요',
            ]
          : [
              '별도 타이머를 준비하세요',
              '${settings.duration.inMinutes}분으로 설정하세요',
              '알림음을 확인하세요',
              '타이머를 시작하세요',
            ],
      priority: InstructionPriority.important,
      equipmentTarget: fermenterType == FermenterType.smart ? '발효기' : '타이머',
      tips: [
        '중간에 한 번 정도 상태를 확인하세요',
        '시간이 다 되기 10분 전에 미리 확인하세요',
        '과발효를 방지하기 위해 정확한 시간을 지키세요',
      ],
    ));

    // 반죽 배치 지침
    instructions.add(SettingInstruction(
      title: '반죽 배치',
      description: '반죽을 발효기에 올바르게 배치하세요',
      steps: [
        '발효기 내부 온습도가 안정된 것을 확인하세요',
        '반죽을 적절한 용기에 담으세요',
        '용기를 발효기 중앙에 배치하세요',
        '발효기 문을 완전히 닫으세요',
      ],
      priority: InstructionPriority.important,
      equipmentTarget: '발효기',
      tips: [
        '반죽 표면이 마르지 않도록 덮개를 사용하세요',
        '용기는 발효기 크기의 1/3 정도만 차지하게 하세요',
        '여러 개의 반죽은 간격을 두고 배치하세요',
      ],
      warnings: [
        '발효기 벽면에 직접 닿지 않게 하세요',
        '문을 자주 열면 온습도가 불안정해집니다',
      ],
    ));

    return instructions;
  }

  /// 오버나이트/냉동 안전 보관 설정 계산
  static SafeStorageSettings calculateSafeStorageSettings(
    StorageType type,
    Duration duration,
    RecipeAnalysis recipe,
  ) {
    switch (type) {
      case StorageType.refrigerator:
        return SafeStorageSettings(
          type: type,
          temperature: 4.0,
          humidity: 85.0,
          maxDuration: Duration(days: 3),
          instructions: [
            '냉장고를 4°C로 설정하세요',
            '반죽을 밀폐용기에 넣으세요',
            '용기에 날짜와 시간을 표시하세요',
            '냉장고 중앙 선반에 보관하세요',
            '사용 1시간 전에 실온에 꺼내두세요',
          ],
          safetyTips: [
            '최대 3일까지 보관 가능합니다',
            '냉장고 문 근처는 온도 변화가 크므로 피하세요',
            '다른 음식 냄새가 배지 않도록 밀폐하세요',
            '매일 한 번씩 상태를 확인하세요',
          ],
        );

      case StorageType.freezer:
        return SafeStorageSettings(
          type: type,
          temperature: -18.0,
          humidity: 5.0,
          maxDuration: Duration(days: 7),
          instructions: [
            '냉동고를 -18°C로 설정하세요',
            '반죽을 냉동용 밀폐용기나 냉동백에 넣으세요',
            '공기를 최대한 제거하세요',
            '용기에 날짜와 내용물을 표시하세요',
            '냉동고 깊숙한 곳에 보관하세요',
          ],
          safetyTips: [
            '최대 1주일까지 보관 가능합니다',
            '해동 시 냉장고에서 12시간 천천히 해동하세요',
            '재냉동은 절대 하지 마세요',
            '해동 후 2시간 내에 사용하세요',
          ],
        );

      case StorageType.roomTemp:
        final maxHours = _calculateMaxRoomTempStorage(recipe);
        return SafeStorageSettings(
          type: type,
          temperature: 25.0,
          humidity: 65.0,
          maxDuration: Duration(hours: maxHours),
          instructions: [
            '실온을 20-25°C로 유지하세요',
            '직사광선을 피해 서늘한 곳에 두세요',
            '반죽을 덮개로 덮어 마르지 않게 하세요',
            '주기적으로 상태를 확인하세요',
          ],
          safetyTips: [
            '최대 ${maxHours}시간까지만 보관하세요',
            '온도가 30°C를 넘으면 냉장 보관으로 전환하세요',
            '과발효 징후가 보이면 즉시 다음 단계로 진행하세요',
            '여름철에는 보관 시간을 단축하세요',
          ],
        );
    }
  }

  /// 발효기 문제 해결 가이드
  static Map<String, List<String>> getTroubleshootingGuide() {
    return {
      '온도가 설정값보다 높음': [
        '발효기 문을 살짝 열어 온도를 낮추세요',
        '온도 설정을 2-3°C 낮춰보세요',
        '발효기 주변 환경 온도를 확인하세요',
        '발효기 내부 팬이 정상 작동하는지 확인하세요',
      ],
      '온도가 설정값보다 낮음': [
        '온도 설정을 다시 확인하세요',
        '발효기 문이 완전히 닫혔는지 확인하세요',
        '전원 연결 상태를 점검하세요',
        '히터 기능이 정상 작동하는지 확인하세요',
      ],
      '습도가 너무 높음': [
        '물통의 물을 일부 제거하세요',
        '발효기를 잠시 환기시키세요',
        '습도 설정을 낮춰보세요',
        '물통을 깨끗하게 청소하세요',
      ],
      '습도가 너무 낮음': [
        '물통에 깨끗한 물을 추가하세요',
        '물통이 제대로 설치되었는지 확인하세요',
        '습도 설정을 높여보세요',
        '발효기 문의 밀폐 상태를 확인하세요',
      ],
      '발효가 너무 빠름': [
        '온도를 2-3°C 낮춰보세요',
        '이스트 양이 적절한지 확인하세요',
        '설탕 함량이 높은지 확인하세요',
        '다음 단계로 빨리 진행하세요',
      ],
      '발효가 너무 느림': [
        '온도를 2-3°C 높여보세요',
        '이스트의 활성도를 확인하세요',
        '발효 시간을 연장하세요',
        '반죽의 상태를 자세히 관찰하세요',
      ],
    };
  }

  /// 발효기 유지 관리 팁
  static List<String> getMaintenanceTips() {
    return [
      '사용 후 내부를 깨끗하게 청소하세요',
      '물통은 매주 교체하고 청소하세요',
      '온도 센서 주변을 깨끗하게 유지하세요',
      '정기적으로 온도 정확도를 확인하세요',
      '습도 센서에 물방울이 맺히지 않게 하세요',
      '전원 코드와 연결 부위를 점검하세요',
      '내부 팬의 먼지를 정기적으로 제거하세요',
      '사용하지 않을 때는 문을 열어 환기시키세요',
      '곰팡이 방지를 위해 완전히 건조시키세요',
      '정기적으로 교정(캘리브레이션)을 실시하세요',
    ];
  }

  /// 발효기별 맞춤 설정 가이드
  static Map<String, dynamic> generateCustomGuide(
    FermenterType fermenterType,
    RecipeAnalysis recipe,
    List<FermentationStageV2> stages,
  ) {
    final isSmartFermenter = fermenterType == FermenterType.smart;
    final stageSettings = <Map<String, dynamic>>[];

    // 각 단계별 설정 생성
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final settings = calculateOptimalSettings(stage, recipe);
      final instructions = generateSettingInstructions(settings, fermenterType);

      stageSettings.add({
        'stageIndex': i,
        'stageName': stage.name,
        'settings': settings.toJson(),
        'instructions': instructions.map((inst) => {
          'title': inst.title,
          'description': inst.description,
          'steps': inst.steps,
          'priority': inst.priority.name,
          'tips': inst.tips,
          'warnings': inst.warnings,
        }).toList(),
      });
    }

    return {
      'fermenterType': fermenterType.name,
      'isSmartFermenter': isSmartFermenter,
      'recipeInfo': {
        'sugarPercentage': recipe.sugarPercentage,
        'yeastPercentage': recipe.yeastPercentage,
        'hydrationLevel': recipe.hydrationLevel,
        'complexity': recipe.estimatedComplexity,
      },
      'stageSettings': stageSettings,
      'generalTips': _getGeneralTips(fermenterType),
      'troubleshooting': getTroubleshootingGuide(),
      'maintenance': getMaintenanceTips(),
      'safetyGuidelines': _getSafetyGuidelines(),
    };
  }

  /// 발효기 설정 검증
  static Map<String, dynamic> validateSettings(
    FermenterSettings settings,
    FermenterType fermenterType,
  ) {
    final issues = <String>[];
    final warnings = <String>[];
    final recommendations = <String>[];

    // 온도 검증
    if (settings.temperature < 18.0) {
      issues.add('온도가 너무 낮습니다 (${settings.temperature}°C). 발효가 거의 진행되지 않을 수 있습니다.');
      recommendations.add('온도를 20-25°C로 높이는 것을 권장합니다.');
    } else if (settings.temperature > 35.0) {
      issues.add('온도가 너무 높습니다 (${settings.temperature}°C). 이스트가 사멸할 위험이 있습니다.');
      recommendations.add('온도를 30°C 이하로 낮추세요.');
    } else if (settings.temperature > 32.0) {
      warnings.add('온도가 높습니다 (${settings.temperature}°C). 발효 속도가 매우 빨라질 수 있습니다.');
    }

    // 습도 검증
    if (settings.humidity < 60.0) {
      warnings.add('습도가 낮습니다 (${settings.humidity}%). 반죽 표면이 마를 수 있습니다.');
      recommendations.add('습도를 65-75%로 높이는 것을 권장합니다.');
    } else if (settings.humidity > 90.0) {
      issues.add('습도가 너무 높습니다 (${settings.humidity}%). 곰팡이 위험이 있습니다.');
      recommendations.add('습도를 85% 이하로 낮추세요.');
    }

    // 시간 검증
    if (settings.duration.inMinutes < 30) {
      warnings.add('발효 시간이 짧습니다 (${settings.duration.inMinutes}분). 충분한 발효가 어려울 수 있습니다.');
    } else if (settings.duration.inHours > 12) {
      warnings.add('발효 시간이 깁니다 (${settings.duration.inHours}시간). 과발효 위험을 주의하세요.');
    }

    // 발효기 타입별 검증
    if (fermenterType == FermenterType.manual) {
      recommendations.add('수동 발효기 사용 시 온도계와 습도계를 별도로 준비하세요.');
      recommendations.add('정기적으로 온습도를 확인하고 조절하세요.');
    }

    return {
      'isValid': issues.isEmpty,
      'issues': issues,
      'warnings': warnings,
      'recommendations': recommendations,
      'score': _calculateSettingsScore(settings),
    };
  }

  /// 발효기 설정 점수 계산 (0-100)
  static int _calculateSettingsScore(FermenterSettings settings) {
    int score = 100;

    // 온도 점수 (40점 만점)
    if (settings.temperature >= 25.0 && settings.temperature <= 30.0) {
      // 최적 온도 범위
    } else if (settings.temperature >= 22.0 && settings.temperature <= 32.0) {
      score -= 10; // 양호한 범위
    } else if (settings.temperature >= 20.0 && settings.temperature <= 35.0) {
      score -= 20; // 허용 범위
    } else {
      score -= 40; // 위험 범위
    }

    // 습도 점수 (30점 만점)
    if (settings.humidity >= 70.0 && settings.humidity <= 80.0) {
      // 최적 습도 범위
    } else if (settings.humidity >= 65.0 && settings.humidity <= 85.0) {
      score -= 10; // 양호한 범위
    } else if (settings.humidity >= 60.0 && settings.humidity <= 90.0) {
      score -= 20; // 허용 범위
    } else {
      score -= 30; // 위험 범위
    }

    // 시간 점수 (30점 만점)
    final hours = settings.duration.inHours;
    if (hours >= 1 && hours <= 6) {
      // 최적 시간 범위
    } else if (hours >= 0.5 && hours <= 8) {
      score -= 10; // 양호한 범위
    } else if (hours >= 0.25 && hours <= 12) {
      score -= 20; // 허용 범위
    } else {
      score -= 30; // 위험 범위
    }

    return math.max(0, score);
  }

  /// 환경 조건에 따른 설정 조정
  static FermenterSettings adjustForEnvironment(
    FermenterSettings baseSettings,
    EnvironmentalConditions environment,
  ) {
    double tempAdjustment = 0.0;
    double humidityAdjustment = 0.0;

    // 실내 온도에 따른 조정
    if (environment.temperature > 25.0) {
      tempAdjustment -= 1.0; // 더운 환경에서는 온도 낮춤
    } else if (environment.temperature < 20.0) {
      tempAdjustment += 1.0; // 추운 환경에서는 온도 높임
    }

    // 실내 습도에 따른 조정
    if (environment.humidity > 70.0) {
      humidityAdjustment -= 5.0; // 습한 환경에서는 습도 낮춤
    } else if (environment.humidity < 40.0) {
      humidityAdjustment += 5.0; // 건조한 환경에서는 습도 높임
    }

    // 계절에 따른 조정
    switch (environment.season) {
      case Season.summer:
        tempAdjustment -= 1.0;
        break;
      case Season.winter:
        tempAdjustment += 1.0;
        humidityAdjustment += 5.0;
        break;
      case Season.spring:
      case Season.autumn:
        // 기본값 유지
        break;
    }

    final adjustedTemp = (baseSettings.temperature + tempAdjustment).clamp(18.0, 35.0);
    final adjustedHumidity = (baseSettings.humidity + humidityAdjustment).clamp(60.0, 90.0);

    return FermenterSettings(
      temperature: adjustedTemp,
      humidity: adjustedHumidity,
      duration: baseSettings.duration,
      stageName: baseSettings.stageName,
      stageType: baseSettings.stageType,
      metadata: {
        ...baseSettings.metadata,
        'environmentalAdjustment': {
          'tempAdjustment': tempAdjustment,
          'humidityAdjustment': humidityAdjustment,
          'roomTemp': environment.temperature,
          'roomHumidity': environment.humidity,
          'season': environment.season,
        },
      },
    );
  }

  /// 발효기 설정 비교
  static Map<String, dynamic> compareSettings(
    FermenterSettings settings1,
    FermenterSettings settings2,
    String label1,
    String label2,
  ) {
    return {
      'comparison': {
        'temperature': {
          label1: settings1.temperature,
          label2: settings2.temperature,
          'difference': (settings2.temperature - settings1.temperature).toStringAsFixed(1),
          'recommendation': _getTemperatureRecommendation(settings1.temperature, settings2.temperature),
        },
        'humidity': {
          label1: settings1.humidity,
          label2: settings2.humidity,
          'difference': (settings2.humidity - settings1.humidity).toStringAsFixed(1),
          'recommendation': _getHumidityRecommendation(settings1.humidity, settings2.humidity),
        },
        'duration': {
          label1: settings1.duration.inMinutes,
          label2: settings2.duration.inMinutes,
          'difference': settings2.duration.inMinutes - settings1.duration.inMinutes,
          'recommendation': _getDurationRecommendation(settings1.duration, settings2.duration),
        },
      },
      'scores': {
        label1: _calculateSettingsScore(settings1),
        label2: _calculateSettingsScore(settings2),
      },
      'recommendation': _calculateSettingsScore(settings2) > _calculateSettingsScore(settings1) 
          ? '$label2 설정을 권장합니다' 
          : '$label1 설정을 권장합니다',
    };
  }

  static String _getTemperatureRecommendation(double temp1, double temp2) {
    final diff = (temp2 - temp1).abs();
    if (diff < 1.0) return '온도 차이가 미미합니다';
    if (temp2 > temp1) return '더 높은 온도로 발효 속도가 빨라집니다';
    return '더 낮은 온도로 발효가 천천히 진행됩니다';
  }

  static String _getHumidityRecommendation(double hum1, double hum2) {
    final diff = (hum2 - hum1).abs();
    if (diff < 5.0) return '습도 차이가 미미합니다';
    if (hum2 > hum1) return '더 높은 습도로 반죽이 촉촉하게 유지됩니다';
    return '더 낮은 습도로 표면이 약간 건조해질 수 있습니다';
  }

  static String _getDurationRecommendation(Duration dur1, Duration dur2) {
    final diffMinutes = dur2.inMinutes - dur1.inMinutes;
    if (diffMinutes.abs() < 15) return '시간 차이가 미미합니다';
    if (diffMinutes > 0) return '더 긴 시간으로 충분한 발효가 가능합니다';
    return '더 짧은 시간으로 빠른 발효를 목표로 합니다';
  }

  // Private Helper Methods

  static int _calculateMaxRoomTempStorage(RecipeAnalysis recipe) {
    // 기본 4시간
    int baseHours = 4;

    // 이스트 양에 따른 조정
    if (recipe.yeastPercentage > 2.0) {
      baseHours -= 1; // 고이스트는 시간 단축
    } else if (recipe.yeastPercentage < 1.0) {
      baseHours += 2; // 저이스트는 시간 연장
    }

    // 설탕 함량에 따른 조정
    if (recipe.sugarPercentage > 15) {
      baseHours -= 1; // 고당분은 시간 단축
    }

    return math.max(2, math.min(8, baseHours)); // 2-8시간 범위
  }

  static List<String> _getGeneralTips(FermenterType fermenterType) {
    final commonTips = [
      '발효기 사용 전 항상 청소하세요',
      '온습도가 안정된 후 반죽을 넣으세요',
      '발효 중간에 상태를 한 번 확인하세요',
      '과발효를 방지하기 위해 시간을 정확히 지키세요',
    ];

    if (fermenterType == FermenterType.smart) {
      commonTips.addAll([
        '디지털 설정을 정확히 입력하세요',
        '자동 프로그램을 활용하세요',
        '알림 기능을 적극 활용하세요',
        '데이터 로그를 확인하여 패턴을 파악하세요',
      ]);
    } else {
      commonTips.addAll([
        '온도계와 습도계를 별도로 준비하세요',
        '다이얼 설정을 정확히 맞추세요',
        '별도 타이머를 사용하세요',
        '수동 조절에 익숙해지세요',
      ]);
    }

    return commonTips;
  }

  static List<String> _getSafetyGuidelines() {
    return [
      '전기 안전을 위해 젖은 손으로 만지지 마세요',
      '35°C를 초과하지 않도록 주의하세요',
      '장시간 사용 시 과열 여부를 확인하세요',
      '이상한 냄새나 소음이 나면 즉시 사용을 중단하세요',
      '어린이의 손이 닿지 않는 곳에 두세요',
      '환기가 잘 되는 곳에서 사용하세요',
      '정기적으로 전원 코드를 점검하세요',
      '사용 설명서를 숙지하고 사용하세요',
    ];
  }
}