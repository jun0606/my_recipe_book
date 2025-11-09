/// 통합 사용자 가이드 시스템
/// 발효기 설정, 알림, 단계별 가이드를 통합 관리하는 핵심 시스템

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import 'fermenter_guide_manager.dart';
import 'fermentation_notification_service.dart';

/// 가이드 타입
enum GuideType {
  setup, // 초기 설정 가이드
  fermentation, // 발효 진행 가이드
  troubleshooting, // 문제 해결 가이드
  maintenance, // 유지 관리 가이드
  safety, // 안전 수칙 가이드
}

/// 가이드 우선순위
enum GuidePriority {
  critical, // 필수 (놓치면 실패)
  important, // 중요 (품질에 영향)
  helpful, // 도움됨 (편의성)
  optional, // 선택적 (추가 정보)
}

/// 가이드 단계
class GuideStep {
  final String id; // 단계 ID
  final String title; // 단계 제목
  final String description; // 상세 설명
  final List<String> instructions; // 실행 지침
  final List<String> tips; // 추가 팁
  final List<String> warnings; // 주의사항
  final GuidePriority priority; // 우선순위
  final Duration? estimatedTime; // 예상 소요 시간
  final List<String> requiredTools; // 필요한 도구
  final Map<String, dynamic> metadata; // 추가 정보
  final bool isCompleted; // 완료 여부
  final DateTime? completedAt; // 완료 시간

  const GuideStep({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    this.tips = const [],
    this.warnings = const [],
    required this.priority,
    this.estimatedTime,
    this.requiredTools = const [],
    this.metadata = const {},
    this.isCompleted = false,
    this.completedAt,
  });

  GuideStep copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? instructions,
    List<String>? tips,
    List<String>? warnings,
    GuidePriority? priority,
    Duration? estimatedTime,
    List<String>? requiredTools,
    Map<String, dynamic>? metadata,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GuideStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      warnings: warnings ?? this.warnings,
      priority: priority ?? this.priority,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      requiredTools: requiredTools ?? this.requiredTools,
      metadata: metadata ?? this.metadata,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'instructions': instructions,
        'tips': tips,
        'warnings': warnings,
        'priority': priority.name,
        'estimatedTime': estimatedTime?.inMinutes,
        'requiredTools': requiredTools,
        'metadata': metadata,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory GuideStep.fromJson(Map<String, dynamic> json) {
    return GuideStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructions: List<String>.from(json['instructions']),
      tips: List<String>.from(json['tips'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      priority: GuidePriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      estimatedTime: json['estimatedTime'] != null
          ? Duration(minutes: json['estimatedTime'])
          : null,
      requiredTools: List<String>.from(json['requiredTools'] ?? []),
      metadata: json['metadata'] ?? {},
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

/// 사용자 가이드
class UserGuide {
  final String id; // 가이드 ID
  final String title; // 가이드 제목
  final String description; // 가이드 설명
  final GuideType type; // 가이드 타입
  final List<GuideStep> steps; // 가이드 단계들
  final Map<String, dynamic> context; // 컨텍스트 정보
  final DateTime createdAt; // 생성 시간
  final DateTime? updatedAt; // 업데이트 시간

  const UserGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.steps,
    this.context = const {},
    required this.createdAt,
    this.updatedAt,
  });

  UserGuide copyWith({
    String? id,
    String? title,
    String? description,
    GuideType? type,
    List<GuideStep>? steps,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      steps: steps ?? this.steps,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 완료된 단계 수
  int get completedStepsCount => steps.where((step) => step.isCompleted).length;

  /// 전체 진행률 (0.0 ~ 1.0)
  double get progress =>
      steps.isEmpty ? 0.0 : completedStepsCount / steps.length;

  /// 다음 단계
  GuideStep? get nextStep => steps.firstWhere(
        (step) => !step.isCompleted,
        orElse: () => steps.last,
      );

  /// 예상 남은 시간
  Duration get estimatedRemainingTime {
    final remainingSteps = steps.where((step) => !step.isCompleted);
    return remainingSteps.fold(
      Duration.zero,
      (total, step) => total + (step.estimatedTime ?? Duration(minutes: 5)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'steps': steps.map((step) => step.toJson()).toList(),
        'context': context,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory UserGuide.fromJson(Map<String, dynamic> json) {
    return UserGuide(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GuideType.values.firstWhere((e) => e.name == json['type']),
      steps: (json['steps'] as List)
          .map((stepJson) => GuideStep.fromJson(stepJson))
          .toList(),
      context: json['context'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

/// 통합 사용자 가이드 시스템
class UserGuideSystem {
  static final UserGuideSystem _instance = UserGuideSystem._internal();
  factory UserGuideSystem() => _instance;
  UserGuideSystem._internal();

  // 서비스 인스턴스들
  final FermentationNotificationService _notificationService =
      FermentationNotificationService();

  // 현재 활성 가이드들
  final Map<String, UserGuide> _activeGuides = {};

  // 가이드 히스토리
  final List<UserGuide> _guideHistory = [];

  // 설정 키들
  static const String _activeGuidesKey = 'user_guide_active_guides';
  static const String _guideHistoryKey = 'user_guide_history';
  static const String _guideSettingsKey = 'user_guide_settings';

  // 설정값들
  bool _autoProgressEnabled = true;
  bool _smartNotificationsEnabled = true;
  bool _contextualTipsEnabled = true;
  bool _voiceGuidanceEnabled = false;

  // 초기화 상태
  bool _initialized = false;

  /// 시스템 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 알림 서비스 초기화
      await _notificationService.initialize();

      // 설정 및 데이터 로드
      await _loadSettings();
      await _loadActiveGuides();
      await _loadGuideHistory();

      _initialized = true;
      print('✅ UserGuideSystem 초기화 완료');
    } catch (e) {
      print('❌ UserGuideSystem 초기화 오류: $e');
    }
  }

  /// 발효기 설정 가이드 생성
  Future<UserGuide> createFermenterSetupGuide({
    required FermenterType fermenterType,
    required RecipeAnalysis recipe,
    required List<FermentationStageV2> stages,
  }) async {
    await _ensureInitialized();

    final guideId = 'fermenter_setup_${DateTime.now().millisecondsSinceEpoch}';
    final customGuide = FermenterGuideManager.generateCustomGuide(
      fermenterType,
      recipe,
      stages,
    );

    final steps = <GuideStep>[];

    // 1. 발효기 준비 단계
    steps.add(GuideStep(
      id: 'prepare_fermenter',
      title: '발효기 준비',
      description: '발효기를 청소하고 사용 준비를 합니다',
      instructions: [
        '발효기 내부를 깨끗하게 청소하세요',
        '물통에 깨끗한 물을 넣으세요',
        '전원을 연결하고 정상 작동을 확인하세요',
        '온도계와 습도계가 정확한지 확인하세요',
      ],
      tips: [
        '청소할 때는 중성 세제를 사용하세요',
        '물통은 증류수나 정수된 물을 사용하는 것이 좋습니다',
      ],
      warnings: [
        '젖은 손으로 전원 부분을 만지지 마세요',
        '청소 후 완전히 건조시켜 주세요',
      ],
      priority: GuidePriority.critical,
      estimatedTime: Duration(minutes: 10),
      requiredTools: ['중성 세제', '마른 수건', '깨끗한 물'],
    ));

    // 2. 각 발효 단계별 설정 가이드
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final settings =
          FermenterGuideManager.calculateOptimalSettings(stage, recipe);
      final instructions = FermenterGuideManager.generateSettingInstructions(
        settings,
        fermenterType,
      );

      steps.add(GuideStep(
        id: 'stage_${i}_setup',
        title: '${stage.name} 설정',
        description: '${stage.name} 단계의 최적 설정을 적용합니다',
        instructions: instructions
            .expand((inst) => [
                  inst.description,
                  ...inst.steps,
                ])
            .toList(),
        tips: instructions.expand((inst) => inst.tips).toList(),
        warnings: instructions.expand((inst) => inst.warnings).toList(),
        priority: GuidePriority.critical,
        estimatedTime: Duration(minutes: 5),
        metadata: {
          'stageIndex': i,
          'stageName': stage.name,
          'settings': settings.toJson(),
        },
      ));
    }

    // 3. 안전 수칙 확인
    steps.add(GuideStep(
      id: 'safety_check',
      title: '안전 수칙 확인',
      description: '발효 과정에서 지켜야 할 안전 수칙을 확인합니다',
      instructions: customGuide['safetyGuidelines'].cast<String>(),
      priority: GuidePriority.important,
      estimatedTime: Duration(minutes: 3),
    ));

    // 4. 최종 점검
    steps.add(GuideStep(
      id: 'final_check',
      title: '최종 점검',
      description: '모든 설정이 올바른지 최종 확인합니다',
      instructions: [
        '온도 설정이 올바른지 확인하세요',
        '습도 설정이 올바른지 확인하세요',
        '타이머가 정확히 설정되었는지 확인하세요',
        '반죽이 올바른 위치에 배치되었는지 확인하세요',
        '발효기 문이 완전히 닫혔는지 확인하세요',
      ],
      tips: [
        '설정값을 메모해두면 다음에 참고할 수 있습니다',
        '첫 30분 동안은 자주 확인해보세요',
      ],
      priority: GuidePriority.critical,
      estimatedTime: Duration(minutes: 5),
    ));

    final guide = UserGuide(
      id: guideId,
      title: '${fermenterType.name == 'smart' ? '스마트' : '일반'} 발효기 설정 가이드',
      description: '${recipe.recipeId} 레시피를 위한 맞춤형 발효기 설정 가이드',
      type: GuideType.setup,
      steps: steps,
      context: {
        'fermenterType': fermenterType.name,
        'recipeId': recipe.recipeId,
        'stageCount': stages.length,
        'customGuide': customGuide,
      },
      createdAt: DateTime.now(),
    );

    await _addActiveGuide(guide);
    return guide;
  }

  /// 발효 진행 가이드 생성
  Future<UserGuide> createFermentationProgressGuide({
    required List<FermentationStageV2> stages,
    required RecipeAnalysis recipe,
  }) async {
    await _ensureInitialized();

    final guideId =
        'fermentation_progress_${DateTime.now().millisecondsSinceEpoch}';
    final steps = <GuideStep>[];

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];

      // 단계 시작
      steps.add(GuideStep(
        id: 'stage_${i}_start',
        title: '${stage.name} 시작',
        description: '${stage.name} 단계를 시작합니다',
        instructions: [
          '발효기 설정이 올바른지 확인하세요',
          '반죽 상태를 확인하고 기록하세요',
          '타이머를 시작하세요',
          '알림 설정을 확인하세요',
        ],
        tips: [
          '시작 시간을 정확히 기록해두세요',
          '반죽의 초기 상태를 사진으로 남겨두면 도움됩니다',
        ],
        priority: GuidePriority.critical,
        estimatedTime: Duration(minutes: 3),
        metadata: {
          'stageIndex': i,
          'stageName': stage.name,
          'duration': stage.duration.inMinutes,
        },
      ));

      // 중간 체크포인트 (긴 단계의 경우)
      if (stage.duration.inMinutes > 60) {
        final checkpointTime = Duration(minutes: stage.duration.inMinutes ~/ 2);
        steps.add(GuideStep(
          id: 'stage_${i}_checkpoint',
          title: '${stage.name} 중간 확인',
          description: '${stage.name} 진행 상황을 중간에 확인합니다',
          instructions: [
            '반죽의 크기 변화를 확인하세요',
            '발효기 온습도가 안정적인지 확인하세요',
            '이상한 냄새나 색깔 변화가 없는지 확인하세요',
            '필요시 설정을 미세 조정하세요',
          ],
          tips: [
            '정상적인 발효라면 반죽이 1.5-2배 정도 부풀어야 합니다',
            '약간의 신맛이 나는 것은 정상입니다',
          ],
          warnings: [
            '곰팡이나 이상한 색깔이 보이면 즉시 중단하세요',
            '너무 빠른 발효는 과발효 위험이 있습니다',
          ],
          priority: GuidePriority.important,
          estimatedTime: Duration(minutes: 2),
          metadata: {
            'stageIndex': i,
            'checkpointTime': checkpointTime.inMinutes,
          },
        ));
      }

      // 단계 완료
      steps.add(GuideStep(
        id: 'stage_${i}_complete',
        title: '${stage.name} 완료',
        description: '${stage.name} 단계를 완료하고 다음 단계를 준비합니다',
        instructions: [
          '반죽의 최종 상태를 확인하세요',
          '발효 결과를 기록하세요',
          '다음 단계 준비를 시작하세요',
          '필요시 반죽을 이동하세요',
        ],
        tips: [
          '완료 시점의 반죽 상태를 사진으로 기록하세요',
          '다음 단계까지 시간이 있다면 적절히 보관하세요',
        ],
        priority: GuidePriority.critical,
        estimatedTime: Duration(minutes: 5),
        metadata: {
          'stageIndex': i,
          'isLastStage': i == stages.length - 1,
        },
      ));
    }

    final guide = UserGuide(
      id: guideId,
      title: '발효 진행 가이드',
      description: '${recipe.recipeId} 레시피의 발효 과정을 단계별로 안내합니다',
      type: GuideType.fermentation,
      steps: steps,
      context: {
        'recipeId': recipe.recipeId,
        'stageCount': stages.length,
        'totalDuration': stages
            .fold(
              Duration.zero,
              (total, stage) => total + stage.duration,
            )
            .inMinutes,
      },
      createdAt: DateTime.now(),
    );

    await _addActiveGuide(guide);
    return guide;
  }

  /// 문제 해결 가이드 생성
  Future<UserGuide> createTroubleshootingGuide({
    required String problem,
    required FermenterType fermenterType,
  }) async {
    await _ensureInitialized();

    final guideId = 'troubleshooting_${DateTime.now().millisecondsSinceEpoch}';
    final troubleshootingGuide =
        FermenterGuideManager.getTroubleshootingGuide();

    final solutions = troubleshootingGuide[problem] ??
        [
          '문제를 정확히 파악하세요',
          '발효기 설명서를 확인하세요',
          '전문가에게 문의하세요',
        ];

    final steps = solutions.asMap().entries.map((entry) {
      final index = entry.key;
      final solution = entry.value;

      return GuideStep(
        id: 'solution_$index',
        title: '해결 방법 ${index + 1}',
        description: solution,
        instructions: [solution],
        priority: index == 0 ? GuidePriority.critical : GuidePriority.important,
        estimatedTime: Duration(minutes: 3),
      );
    }).toList();

    final guide = UserGuide(
      id: guideId,
      title: '문제 해결: $problem',
      description: '$problem 문제를 해결하기 위한 단계별 가이드',
      type: GuideType.troubleshooting,
      steps: steps,
      context: {
        'problem': problem,
        'fermenterType': fermenterType.name,
      },
      createdAt: DateTime.now(),
    );

    await _addActiveGuide(guide);
    return guide;
  }

  /// 유지 관리 가이드 생성
  Future<UserGuide> createMaintenanceGuide({
    required FermenterType fermenterType,
  }) async {
    await _ensureInitialized();

    final guideId = 'maintenance_${DateTime.now().millisecondsSinceEpoch}';
    final maintenanceTips = FermenterGuideManager.getMaintenanceTips();

    final steps = maintenanceTips.asMap().entries.map((entry) {
      final index = entry.key;
      final tip = entry.value;

      return GuideStep(
        id: 'maintenance_$index',
        title: '유지 관리 ${index + 1}',
        description: tip,
        instructions: [tip],
        priority: index < 3 ? GuidePriority.important : GuidePriority.helpful,
        estimatedTime: Duration(minutes: 5),
      );
    }).toList();

    final guide = UserGuide(
      id: guideId,
      title: '발효기 유지 관리 가이드',
      description: '발효기를 최적 상태로 유지하기 위한 관리 방법',
      type: GuideType.maintenance,
      steps: steps,
      context: {
        'fermenterType': fermenterType.name,
      },
      createdAt: DateTime.now(),
    );

    await _addActiveGuide(guide);
    return guide;
  }

  /// 단계 완료 처리
  Future<void> completeStep(String guideId, String stepId) async {
    await _ensureInitialized();

    final guide = _activeGuides[guideId];
    if (guide == null) return;

    final stepIndex = guide.steps.indexWhere((step) => step.id == stepId);
    if (stepIndex == -1) return;

    final updatedStep = guide.steps[stepIndex].copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    final updatedSteps = List<GuideStep>.from(guide.steps);
    updatedSteps[stepIndex] = updatedStep;

    final updatedGuide = guide.copyWith(
      steps: updatedSteps,
      updatedAt: DateTime.now(),
    );

    _activeGuides[guideId] = updatedGuide;
    await _saveActiveGuides();

    // 알림 발송
    if (_smartNotificationsEnabled) {
      await _notificationService.notifyCheckpoint(
        message: '${updatedStep.title} 완료!',
      );
    }

    // 자동 진행 처리
    if (_autoProgressEnabled) {
      await _handleAutoProgress(updatedGuide, stepIndex);
    }
  }

  /// 가이드 완료 처리
  Future<void> completeGuide(String guideId) async {
    await _ensureInitialized();

    final guide = _activeGuides[guideId];
    if (guide == null) return;

    // 히스토리에 추가
    _guideHistory.add(guide);
    await _saveGuideHistory();

    // 활성 가이드에서 제거
    _activeGuides.remove(guideId);
    await _saveActiveGuides();

    // 완료 알림
    await _notificationService.notifyFermentationComplete();
  }

  /// 자동 진행 처리
  Future<void> _handleAutoProgress(
      UserGuide guide, int completedStepIndex) async {
    // 다음 단계가 있는지 확인
    if (completedStepIndex + 1 < guide.steps.length) {
      final nextStep = guide.steps[completedStepIndex + 1];

      // 컨텍스트에 따른 자동 알림
      if (guide.type == GuideType.fermentation) {
        final metadata = nextStep.metadata;
        if (metadata.containsKey('duration')) {
          // 다음 발효 단계 시작 알림
          await _notificationService.notifyStageStart(
            stageName: metadata['stageName'] ?? '다음 단계',
            duration: Duration(minutes: metadata['duration'] ?? 60),
          );
        }
      }
    } else {
      // 모든 단계 완료
      await completeGuide(guide.id);
    }
  }

  /// 활성 가이드 목록
  List<UserGuide> get activeGuides => _activeGuides.values.toList();

  /// 가이드 히스토리
  List<UserGuide> get guideHistory => List.unmodifiable(_guideHistory);

  /// 특정 가이드 조회
  UserGuide? getGuide(String guideId) => _activeGuides[guideId];

  /// 가이드 삭제
  Future<void> removeGuide(String guideId) async {
    _activeGuides.remove(guideId);
    await _saveActiveGuides();
  }

  // 설정 관련 메서드들

  bool get autoProgressEnabled => _autoProgressEnabled;
  bool get smartNotificationsEnabled => _smartNotificationsEnabled;
  bool get contextualTipsEnabled => _contextualTipsEnabled;
  bool get voiceGuidanceEnabled => _voiceGuidanceEnabled;

  Future<void> setAutoProgressEnabled(bool enabled) async {
    _autoProgressEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setSmartNotificationsEnabled(bool enabled) async {
    _smartNotificationsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setContextualTipsEnabled(bool enabled) async {
    _contextualTipsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setVoiceGuidanceEnabled(bool enabled) async {
    _voiceGuidanceEnabled = enabled;
    await _saveSettings();
  }

  // Private 메서드들

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  Future<void> _addActiveGuide(UserGuide guide) async {
    _activeGuides[guide.id] = guide;
    await _saveActiveGuides();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_guideSettingsKey);

    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson);
      _autoProgressEnabled = settings['autoProgressEnabled'] ?? true;
      _smartNotificationsEnabled =
          settings['smartNotificationsEnabled'] ?? true;
      _contextualTipsEnabled = settings['contextualTipsEnabled'] ?? true;
      _voiceGuidanceEnabled = settings['voiceGuidanceEnabled'] ?? false;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'autoProgressEnabled': _autoProgressEnabled,
      'smartNotificationsEnabled': _smartNotificationsEnabled,
      'contextualTipsEnabled': _contextualTipsEnabled,
      'voiceGuidanceEnabled': _voiceGuidanceEnabled,
    };
    await prefs.setString(_guideSettingsKey, jsonEncode(settings));
  }

  Future<void> _loadActiveGuides() async {
    final prefs = await SharedPreferences.getInstance();
    final guidesJson = prefs.getString(_activeGuidesKey);

    if (guidesJson != null) {
      final guidesList = jsonDecode(guidesJson) as List;
      for (final guideJson in guidesList) {
        final guide = UserGuide.fromJson(guideJson);
        _activeGuides[guide.id] = guide;
      }
    }
  }

  Future<void> _saveActiveGuides() async {
    final prefs = await SharedPreferences.getInstance();
    final guidesList =
        _activeGuides.values.map((guide) => guide.toJson()).toList();
    await prefs.setString(_activeGuidesKey, jsonEncode(guidesList));
  }

  Future<void> _loadGuideHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_guideHistoryKey);

    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List;
      _guideHistory.clear();
      _guideHistory.addAll(
        historyList.map((guideJson) => UserGuide.fromJson(guideJson)),
      );
    }
  }

  Future<void> _saveGuideHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = _guideHistory.map((guide) => guide.toJson()).toList();
    await prefs.setString(_guideHistoryKey, jsonEncode(historyList));
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await _notificationService.dispose();
    print('UserGuideSystem 정리 완료');
  }
}
