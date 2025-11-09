/// 새로운 AI 기반 발효 시나리오 시스템 모델
/// 사용자는 발효 방식만 선택하고, AI가 모든 계산을 담당하는 혁신적인 접근법

/// 새로운 AI 기반 발효 시나리오 시스템 모델
/// 사용자는 발효 방식만 선택하고, AI가 모든 계산을 담당하는 혁신적인 접근법

import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/sous_chef_models.dart';

/// 발효 모드 (실온 vs 발효기)
enum FermentationMode {
  roomTemperature, // 실온 발효
  fermenter, // 발효기 발효
}

/// 발효 방법 (실온 모드의 세부 방법)
enum FermentationMethodV2 {
  normal, // 일반 실온 발효
  coldRetardation, // 냉장 저온 발효
  freezerOvernight, // 냉동 오버나이트
  custom, // 커스텀 발효
}

/// 발효기 타입
enum FermenterType {
  smart, // 스마트 발효기 (자동 제어 가능)
  manual, // 일반 발효기 (수동 설정)
}

/// 발효 단계 타입
enum FermentationStageType {
  primary, // 1차 발효
  rest, // 휴지
  secondary, // 2차 발효
  finalProofing, // 최종 발효
  storage, // 보관 (냉장/냉동)
  thawing, // 해동
  proofing, // 휴지 (proofing)
  finalStage, // 최종 (final)
}

/// 사용자 지침 우선순위
enum InstructionPriority {
  critical, // 필수 (놓치면 실패)
  important, // 중요 (품질에 영향)
  optional, // 선택적 (개선 사항)
}

/// 자동화 대상
enum AutomationTarget {
  timer, // 타이머
  notification, // 알림
  temperature, // 온도 제어
  humidity, // 습도 제어
  equipment, // 장비 제어
}

/// 온도 범위
class TemperatureRange {
  final double min;
  final double max;
  final double optimal;

  const TemperatureRange({
    required this.min,
    required this.max,
    required this.optimal,
  });

  bool contains(double temperature) {
    return temperature >= min && temperature <= max;
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'optimal': optimal,
      };

  factory TemperatureRange.fromJson(Map<String, dynamic> json) {
    return TemperatureRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      optimal: (json['optimal'] as num).toDouble(),
    );
  }
}

/// 습도 범위
class HumidityRange {
  final double min;
  final double max;
  final double optimal;

  const HumidityRange({
    required this.min,
    required this.max,
    required this.optimal,
  });

  bool contains(double humidity) {
    return humidity >= min && humidity <= max;
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'optimal': optimal,
      };

  factory HumidityRange.fromJson(Map<String, dynamic> json) {
    return HumidityRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      optimal: (json['optimal'] as num).toDouble(),
    );
  }
}

/// 사용자 행동 지침
class UserInstruction {
  final String action; // 행동 (예: "발효기를 28°C로 설정하세요")
  final String description; // 상세 설명
  final Duration timing; // 실행 타이밍
  final InstructionPriority priority; // 우선순위
  final List<String> visualAids; // 시각적 도움 (이미지 경로 등)
  final String? equipmentTarget; // 대상 장비 (발효기, 냉장고 등)

  const UserInstruction({
    required this.action,
    required this.description,
    required this.timing,
    required this.priority,
    this.visualAids = const [],
    this.equipmentTarget,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'description': description,
        'timing': timing.inMinutes,
        'priority': priority.name,
        'visualAids': visualAids,
        'equipmentTarget': equipmentTarget,
      };

  factory UserInstruction.fromJson(Map<String, dynamic> json) {
    return UserInstruction(
      action: json['action'],
      description: json['description'],
      timing: Duration(minutes: json['timing']),
      priority: InstructionPriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      visualAids: List<String>.from(json['visualAids'] ?? []),
      equipmentTarget: json['equipmentTarget'],
    );
  }
}

/// 자동화 액션
class AutomationAction {
  final AutomationTarget target; // 자동화 대상
  final Map<String, dynamic> settings; // 설정값
  final Duration executeAt; // 실행 시점
  final List<String> conditions; // 실행 조건

  const AutomationAction({
    required this.target,
    required this.settings,
    required this.executeAt,
    this.conditions = const [],
  });

  Map<String, dynamic> toJson() => {
        'target': target.name,
        'settings': settings,
        'executeAt': executeAt.inMinutes,
        'conditions': conditions,
      };

  factory AutomationAction.fromJson(Map<String, dynamic> json) {
    return AutomationAction(
      target: AutomationTarget.values.firstWhere(
        (e) => e.name == json['target'],
      ),
      settings: json['settings'],
      executeAt: Duration(minutes: json['executeAt']),
      conditions: List<String>.from(json['conditions'] ?? []),
    );
  }
}

/// 알림 설정
class AlertSettings {
  final bool enabled;
  final Duration beforeCompletion; // 완료 전 알림 시간
  final List<String> notificationTypes; // 알림 타입 (push, sound, vibration)
  final String message; // 알림 메시지

  const AlertSettings({
    this.enabled = true,
    this.beforeCompletion = const Duration(minutes: 5),
    this.notificationTypes = const ['push', 'sound'],
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'beforeCompletion': beforeCompletion.inMinutes,
        'notificationTypes': notificationTypes,
        'message': message,
      };

  factory AlertSettings.fromJson(Map<String, dynamic> json) {
    return AlertSettings(
      enabled: json['enabled'] ?? true,
      beforeCompletion: Duration(minutes: json['beforeCompletion'] ?? 5),
      notificationTypes:
          List<String>.from(json['notificationTypes'] ?? ['push', 'sound']),
      message: json['message'],
    );
  }
}

/// 발효 단계 (V2)
class FermentationStageV2 {
  final String name; // 단계 이름 (예: "1차 발효")
  final FermentationStageType type; // 단계 타입
  final Duration duration; // 지속 시간
  final TemperatureRange temperature; // 온도 범위
  final HumidityRange humidity; // 습도 범위
  final List<UserInstruction> instructions; // 사용자 지침
  final List<AutomationAction> automations; // 자동화 액션
  final AlertSettings alerts; // 알림 설정
  final String description; // 단계 설명
  final Map<String, dynamic> metadata; // 추가 메타데이터

  const FermentationStageV2({
    required this.name,
    required this.type,
    required this.duration,
    required this.temperature,
    required this.humidity,
    required this.instructions,
    required this.automations,
    required this.alerts,
    required this.description,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'duration': duration.inMinutes,
        'temperature': temperature.toJson(),
        'humidity': humidity.toJson(),
        'instructions': instructions.map((e) => e.toJson()).toList(),
        'automations': automations.map((e) => e.toJson()).toList(),
        'alerts': alerts.toJson(),
        'description': description,
        'metadata': metadata,
      };

  factory FermentationStageV2.fromJson(Map<String, dynamic> json) {
    return FermentationStageV2(
      name: json['name'],
      type: FermentationStageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      duration: Duration(minutes: json['duration']),
      temperature: TemperatureRange.fromJson(json['temperature']),
      humidity: HumidityRange.fromJson(json['humidity']),
      instructions: (json['instructions'] as List)
          .map((e) => UserInstruction.fromJson(e))
          .toList(),
      automations: (json['automations'] as List)
          .map((e) => AutomationAction.fromJson(e))
          .toList(),
      alerts: AlertSettings.fromJson(json['alerts']),
      description: json['description'],
      metadata: json['metadata'] ?? {},
    );
  }
}

/// 레시피 분석 결과
class RecipeAnalysis {
  final String recipeId;
  final String recipeName;
  final double flourAmount;
  final double yeastAmount;
  final double sugarAmount;
  final double liquidAmount;
  final double fatAmount;
  final YeastType yeastType;
  final BreadType breadType;
  final DateTime analysisTimestamp;

  const RecipeAnalysis({
    required this.recipeId,
    required this.recipeName,
    required this.flourAmount,
    required this.yeastAmount,
    required this.sugarAmount,
    required this.liquidAmount,
    required this.fatAmount,
    required this.yeastType,
    required this.breadType,
    required this.analysisTimestamp,
  });

  /// 설탕 비율 (%)
  double get sugarPercentage => (sugarAmount / flourAmount) * 100;

  /// 이스트 비율 (%)
  double get yeastPercentage => (yeastAmount / flourAmount) * 100;

  /// 수분 함량 (%)
  double get hydrationLevel => (liquidAmount / flourAmount) * 100;

  /// 예상 복잡도 (1-10)
  int get estimatedComplexity {
    int complexity = 5; // 기본값

    // 이스트 양에 따른 조정
    if (yeastPercentage > 2.0) complexity += 1;
    if (yeastPercentage < 1.0) complexity += 2;

    // 설탕 함량에 따른 조정
    if (sugarPercentage > 15) complexity += 2;
    if (sugarPercentage > 25) complexity += 1;

    // 수분 함량에 따른 조정
    if (hydrationLevel > 80) complexity += 1;
    if (hydrationLevel < 60) complexity += 1;

    // 빵 타입에 따른 조정
    switch (breadType) {
      case BreadType.sourdough:
        complexity += 3;
        break;
      case BreadType.enriched:
        complexity += 2;
        break;
      case BreadType.whole_wheat:
        complexity += 1;
        break;
      default:
        break;
    }

    return complexity.clamp(1, 10);
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'flourAmount': flourAmount,
      'yeastAmount': yeastAmount,
      'sugarAmount': sugarAmount,
      'liquidAmount': liquidAmount,
      'fatAmount': fatAmount,
      'yeastType': yeastType.name,
      'breadType': breadType.name,
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory RecipeAnalysis.fromJson(Map<String, dynamic> json) {
    return RecipeAnalysis(
      recipeId: json['recipeId'],
      recipeName: json['recipeName'],
      flourAmount: (json['flourAmount'] as num).toDouble(),
      yeastAmount: (json['yeastAmount'] as num).toDouble(),
      sugarAmount: (json['sugarAmount'] as num).toDouble(),
      liquidAmount: (json['liquidAmount'] as num).toDouble(),
      fatAmount: (json['fatAmount'] as num).toDouble(),
      yeastType:
          YeastType.values.firstWhere((e) => e.name == json['yeastType']),
      breadType:
          BreadType.values.firstWhere((e) => e.name == json['breadType']),
      analysisTimestamp: DateTime.parse(json['analysisTimestamp']),
    );
  }
}

/// 이스트 타입
enum YeastType {
  dry, // 건조 이스트
  fresh, // 생이스트
  sourdough, // 사워도우 스타터
}

/// 빵 타입
enum BreadType {
  white, // 화이트 브레드
  whole_wheat, // 통밀 빵
  enriched, // 리치 도우 (버터, 설탕 많음)
  sourdough, // 사워도우
}

/// 장비 프로파일
class EquipmentProfile {
  final String id; // 장비 ID
  final String name; // 장비 이름
  final FermenterType? fermenterType; // 발효기 타입 (발효기인 경우)
  final Map<String, dynamic> capabilities; // 장비 기능
  final Map<String, double> accuracy; // 정확도 (온도, 습도 등)
  final bool isConnected; // 연결 상태
  final Map<String, dynamic> settings; // 현재 설정

  const EquipmentProfile({
    required this.id,
    required this.name,
    this.fermenterType,
    this.capabilities = const {},
    this.accuracy = const {},
    this.isConnected = false,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fermenterType': fermenterType?.name,
        'capabilities': capabilities,
        'accuracy': accuracy,
        'isConnected': isConnected,
        'settings': settings,
      };

  factory EquipmentProfile.fromJson(Map<String, dynamic> json) {
    return EquipmentProfile(
      id: json['id'],
      name: json['name'],
      fermenterType: json['fermenterType'] != null
          ? FermenterType.values.firstWhere(
              (e) => e.name == json['fermenterType'],
            )
          : null,
      capabilities: json['capabilities'] ?? {},
      accuracy: Map<String, double>.from(json['accuracy'] ?? {}),
      isConnected: json['isConnected'] ?? false,
      settings: json['settings'] ?? {},
    );
  }
}

/// AI 생성 발효 시나리오 (V2)
class FermentationScenarioV2 {
  final String id; // 시나리오 ID
  final String name; // 시나리오 이름
  final String description; // 시나리오 설명
  final FermentationMode mode; // 발효 모드
  final FermentationMethodV2? method; // 발효 방법 (실온 모드인 경우)
  final List<FermentationStageV2> stages; // 발효 단계들
  final RecipeAnalysis recipeAnalysis; // 레시피 분석
  final EnvironmentalConditions environmentalConditions; // 환경 조건
  final EquipmentProfile? equipment; // 사용 장비
  final DateTime createdAt; // 생성 시간
  final Duration totalDuration; // 총 소요 시간
  final Map<String, dynamic> metadata; // 추가 메타데이터
  final double confidenceScore; // AI 신뢰도 점수

  const FermentationScenarioV2({
    required this.id,
    required this.name,
    required this.description,
    required this.mode,
    this.method,
    required this.stages,
    required this.recipeAnalysis,
    required this.environmentalConditions,
    this.equipment,
    required this.createdAt,
    required this.totalDuration,
    this.metadata = const {},
    this.confidenceScore = 1.0,
  });

  /// 현재 활성 단계 찾기
  FermentationStageV2? getCurrentStage(Duration elapsed) {
    Duration cumulative = Duration.zero;
    for (final stage in stages) {
      cumulative += stage.duration;
      if (elapsed <= cumulative) {
        return stage;
      }
    }
    return null; // 모든 단계 완료
  }

  /// 다음 단계 찾기
  FermentationStageV2? getNextStage(Duration elapsed) {
    Duration cumulative = Duration.zero;
    for (int i = 0; i < stages.length; i++) {
      cumulative += stages[i].duration;
      if (elapsed <= cumulative && i + 1 < stages.length) {
        return stages[i + 1];
      }
    }
    return null; // 마지막 단계이거나 완료
  }

  /// 진행률 계산 (0.0 - 1.0)
  double getProgress(Duration elapsed) {
    if (totalDuration.inMinutes == 0) return 1.0;
    return (elapsed.inMinutes / totalDuration.inMinutes).clamp(0.0, 1.0);
  }

  /// 남은 시간 계산
  Duration getRemainingTime(Duration elapsed) {
    final remaining = totalDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 시나리오 유효성 검증
  List<String> validate() {
    final warnings = <String>[];

    // 1. 단계 순서 검증
    if (stages.isEmpty) {
      warnings.add('발효 단계가 없습니다.');
      return warnings;
    }

    // 2. 총 시간 검증
    if (totalDuration.inHours > 48) {
      warnings.add('총 발효 시간이 48시간을 초과합니다. 과발효 위험이 있습니다.');
    }

    // 3. 온도 일관성 검증
    for (int i = 0; i < stages.length - 1; i++) {
      final current = stages[i];
      final next = stages[i + 1];

      final tempDiff =
          (current.temperature.optimal - next.temperature.optimal).abs();
      if (tempDiff > 20) {
        warnings.add(
            '${current.name}과 ${next.name} 사이의 온도 차이가 큽니다 (${tempDiff.toStringAsFixed(1)}°C).');
      }
    }

    // 4. 장비 호환성 검증
    if (mode == FermentationMode.fermenter &&
        equipment?.fermenterType == null) {
      warnings.add('발효기 모드이지만 발효기 정보가 없습니다.');
    }

    return warnings;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'mode': mode.name,
        'method': method?.name,
        'stages': stages.map((e) => e.toJson()).toList(),
        'recipeAnalysis': recipeAnalysis.toJson(),
        'environmentalConditions': environmentalConditions.toJson(),
        'equipment': equipment?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'totalDuration': totalDuration.inMinutes,
        'metadata': metadata,
        'confidenceScore': confidenceScore,
      };

  factory FermentationScenarioV2.fromJson(Map<String, dynamic> json) {
    return FermentationScenarioV2(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      mode: FermentationMode.values.firstWhere(
        (e) => e.name == json['mode'],
      ),
      method: json['method'] != null
          ? FermentationMethodV2.values.firstWhere(
              (e) => e.name == json['method'],
            )
          : null,
      stages: (json['stages'] as List)
          .map((e) => FermentationStageV2.fromJson(e))
          .toList(),
      recipeAnalysis: RecipeAnalysis.fromJson(json['recipeAnalysis']),
      environmentalConditions:
          EnvironmentalConditions.fromJson(json['environmentalConditions']),
      equipment: json['equipment'] != null
          ? EquipmentProfile.fromJson(json['equipment'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      totalDuration: Duration(minutes: json['totalDuration']),
      metadata: json['metadata'] ?? {},
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// 시나리오 복사 (수정용)
  FermentationScenarioV2 copyWith({
    String? id,
    String? name,
    String? description,
    FermentationMode? mode,
    FermentationMethodV2? method,
    List<FermentationStageV2>? stages,
    RecipeAnalysis? recipeAnalysis,
    EnvironmentalConditions? environmentalConditions,
    EquipmentProfile? equipment,
    DateTime? createdAt,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
    double? confidenceScore,
  }) {
    return FermentationScenarioV2(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      method: method ?? this.method,
      stages: stages ?? this.stages,
      recipeAnalysis: recipeAnalysis ?? this.recipeAnalysis,
      environmentalConditions:
          environmentalConditions ?? this.environmentalConditions,
      equipment: equipment ?? this.equipment,
      createdAt: createdAt ?? this.createdAt,
      totalDuration: totalDuration ?? this.totalDuration,
      metadata: metadata ?? this.metadata,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }
}
