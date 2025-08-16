import 'package:flutter/material.dart';

/// 사용자 모드 enum
enum UserMode {
  homeBaker('home', '홈베이커', '가정용 베이킹에 최적화된 모드'),
  professional('professional', '전문가', '전문 베이커를 위한 고급 기능'),
  research('research', '연구용', '실험과 연구를 위한 모든 기능');

  const UserMode(this.value, this.displayName, this.description);
  
  final String value;
  final String displayName;
  final String description;

  /// 문자열에서 UserMode 생성
  static UserMode fromString(String value) {
    return UserMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => UserMode.homeBaker,
    );
  }
}

/// 레시피 설정 클래스
class RecipeSettings {
  final bool showNutrition;
  final bool showCost;
  final bool showTiming;
  final bool enableAutoScale;
  final double defaultServings;
  final String preferredUnit;
  final bool showBakingCalculator;
  final bool showNutritionInfo;
  final bool showVideoGuides;
  final bool enableScaling;
  final bool enableSubstitutions;
  final List<String> enabledFeatures;

  const RecipeSettings({
    this.showNutrition = true,
    this.showCost = false,
    this.showTiming = true,
    this.enableAutoScale = true,
    this.defaultServings = 4.0,
    this.preferredUnit = 'g',
    this.showBakingCalculator = true,
    this.showNutritionInfo = true,
    this.showVideoGuides = false,
    this.enableScaling = true,
    this.enableSubstitutions = true,
    this.enabledFeatures = const [],
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'showNutrition': showNutrition,
      'showCost': showCost,
      'showTiming': showTiming,
      'enableAutoScale': enableAutoScale,
      'defaultServings': defaultServings,
      'preferredUnit': preferredUnit,
      'showBakingCalculator': showBakingCalculator,
      'showNutritionInfo': showNutritionInfo,
      'showVideoGuides': showVideoGuides,
      'enableScaling': enableScaling,
      'enableSubstitutions': enableSubstitutions,
      'enabledFeatures': enabledFeatures,
    };
  }

  /// JSON에서 생성
  factory RecipeSettings.fromJson(Map<String, dynamic> json) {
    return RecipeSettings(
      showNutrition: json['showNutrition'] ?? true,
      showCost: json['showCost'] ?? false,
      showTiming: json['showTiming'] ?? true,
      enableAutoScale: json['enableAutoScale'] ?? true,
      defaultServings: (json['defaultServings'] ?? 4.0).toDouble(),
      preferredUnit: json['preferredUnit'] ?? 'g',
      showBakingCalculator: json['showBakingCalculator'] ?? true,
      showNutritionInfo: json['showNutritionInfo'] ?? true,
      showVideoGuides: json['showVideoGuides'] ?? false,
      enableScaling: json['enableScaling'] ?? true,
      enableSubstitutions: json['enableSubstitutions'] ?? true,
      enabledFeatures: List<String>.from(json['enabledFeatures'] ?? []),
    );
  }

  /// 복사본 생성
  RecipeSettings copyWith({
    bool? showNutrition,
    bool? showCost,
    bool? showTiming,
    bool? enableAutoScale,
    double? defaultServings,
    String? preferredUnit,
    bool? showBakingCalculator,
    bool? showNutritionInfo,
    bool? showVideoGuides,
    bool? enableScaling,
    bool? enableSubstitutions,
    List<String>? enabledFeatures,
  }) {
    return RecipeSettings(
      showNutrition: showNutrition ?? this.showNutrition,
      showCost: showCost ?? this.showCost,
      showTiming: showTiming ?? this.showTiming,
      enableAutoScale: enableAutoScale ?? this.enableAutoScale,
      defaultServings: defaultServings ?? this.defaultServings,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      showBakingCalculator: showBakingCalculator ?? this.showBakingCalculator,
      showNutritionInfo: showNutritionInfo ?? this.showNutritionInfo,
      showVideoGuides: showVideoGuides ?? this.showVideoGuides,
      enableScaling: enableScaling ?? this.enableScaling,
      enableSubstitutions: enableSubstitutions ?? this.enableSubstitutions,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
    );
  }
}

/// 사용자 설정 모델
class UserConfiguration {
  final String userId;
  final UserMode preferredMode;
  final List<String> activeModules;
  final Map<String, Offset> moduleLayout;
  final Map<String, dynamic> preferences;
  final DateTime lastUpdated;

  UserConfiguration({
    required this.userId,
    required this.preferredMode,
    this.activeModules = const [],
    this.moduleLayout = const {},
    this.preferences = const {},
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 기본 설정 생성
  factory UserConfiguration.defaultConfig(String userId) {
    return UserConfiguration(
      userId: userId,
      preferredMode: UserMode.homeBaker,
      activeModules: const ['basic_calculator', 'scaling'],
      moduleLayout: const {
        'basic_calculator': Offset(20, 20),
        'scaling': Offset(420, 20),
      },
      preferences: const {
        'gridSize': 20.0,
        'snapToGrid': true,
        'showGrid': true,
        'autoSave': true,
        'textScaleFactor': 1.0,
        'useSystemTextScale': true,
      },
    );
  }

  /// 베이킹 전용 설정 생성
  factory UserConfiguration.bakingConfig(String userId) {
    return UserConfiguration(
      userId: userId,
      preferredMode: UserMode.professional,
      activeModules: const [
        'scaling',
        'unit_conversion',
        'bakers_percentage',
        'basic_calculator',
      ],
      moduleLayout: const {
        'scaling': Offset(20, 20),
        'unit_conversion': Offset(340, 20),
        'bakers_percentage': Offset(20, 240),
        'basic_calculator': Offset(340, 240),
      },
      preferences: const {
        'gridSize': 20.0,
        'snapToGrid': true,
        'showGrid': true,
        'autoSave': true,
        'bakingMode': true,
        'precisionMode': true,
        'textScaleFactor': 1.0,
        'useSystemTextScale': true,
      },
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'preferredMode': preferredMode.value,
      'activeModules': activeModules,
      'moduleLayout': moduleLayout.map(
        (key, value) => MapEntry(key, {'x': value.dx, 'y': value.dy}),
      ),
      'preferences': preferences,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory UserConfiguration.fromJson(Map<String, dynamic> json) {
    return UserConfiguration(
      userId: json['userId'] ?? '',
      preferredMode: UserMode.fromString(json['preferredMode'] ?? 'home'),
      activeModules: List<String>.from(json['activeModules'] ?? []),
      moduleLayout: (json['moduleLayout'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          Offset(
            value['x']?.toDouble() ?? 0.0,
            value['y']?.toDouble() ?? 0.0,
          ),
        ),
      ) ?? {},
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  /// 복사본 생성
  UserConfiguration copyWith({
    String? userId,
    UserMode? preferredMode,
    List<String>? activeModules,
    Map<String, Offset>? moduleLayout,
    Map<String, dynamic>? preferences,
    DateTime? lastUpdated,
  }) {
    return UserConfiguration(
      userId: userId ?? this.userId,
      preferredMode: preferredMode ?? this.preferredMode,
      activeModules: activeModules ?? this.activeModules,
      moduleLayout: moduleLayout ?? this.moduleLayout,
      preferences: preferences ?? this.preferences,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// 모듈 레이아웃 업데이트
  UserConfiguration updateModuleLayout(Map<String, Offset> newLayout) {
    return copyWith(
      moduleLayout: {...moduleLayout, ...newLayout},
      lastUpdated: DateTime.now(),
    );
  }

  /// 활성 모듈 업데이트
  UserConfiguration updateActiveModules(List<String> modules) {
    return copyWith(
      activeModules: modules,
      lastUpdated: DateTime.now(),
    );
  }

  /// 환경설정 업데이트
  UserConfiguration updatePreferences(Map<String, dynamic> newPreferences) {
    return copyWith(
      preferences: {...preferences, ...newPreferences},
      lastUpdated: DateTime.now(),
    );
  }

  /// 사용자 모드 변경
  UserConfiguration changeMode(UserMode newMode) {
    // 모드에 따른 기본 모듈 설정
    List<String> defaultModules;
    switch (newMode) {
      case UserMode.homeBaker:
        defaultModules = ['basic_calculator', 'scaling', 'unit_conversion'];
        break;
      case UserMode.professional:
        defaultModules = [
          'basic_calculator',
          'scaling',
          'unit_conversion',
          'bakers_percentage',
          'environmental_adjustment',
          'cost_analysis',
        ];
        break;
      case UserMode.research:
        defaultModules = [
          'basic_calculator',
          'scaling',
          'unit_conversion',
          'bakers_percentage',
          'environmental_adjustment',
          'cost_analysis',
          'substitution',
          'fermentation_timing',
          'yield_prediction',
        ];
        break;
    }

    return copyWith(
      preferredMode: newMode,
      activeModules: defaultModules,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserConfiguration &&
        other.userId == userId &&
        other.preferredMode == preferredMode;
  }

  @override
  int get hashCode => userId.hashCode ^ preferredMode.hashCode;

  @override
  String toString() {
    return 'UserConfiguration(userId: $userId, mode: ${preferredMode.displayName}, modules: ${activeModules.length})';
  }
}