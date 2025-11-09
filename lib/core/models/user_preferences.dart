// lib/core/models/user_preferences.dart
// 사용자 설정 모델 - 분석 및 UI 개인화 설정

import 'dart:convert';

/// 언어 설정 열거형
enum Language {
  korean, // 한국어
  english, // 영어
  japanese, // 일본어
  chinese, // 중국어
}

/// 난이도 수준 열거형
enum DifficultyLevel {
  beginner, // 초보자
  intermediate, // 중급자
  advanced, // 상급자
  expert, // 전문가
}

/// 알림 빈도 열거형
enum NotificationFrequency {
  never, // 알리지 않음
  minimal, // 최소한으로
  normal, // 보통
  frequent, // 자주
}

/// 단위 시스템 열거형
enum UnitSystem {
  metric, // 미터법 (g, kg, mL, L, °C)
  imperial, // 영국식 단위 (oz, lb, cup, °F)
  mixed, // 혼합 (레시피에 따라 자동)
}

/// 사용자 설정 모델
class UserPreferences {
  final String userId;
  final Language language;
  final DifficultyLevel experienceLevel;
  final NotificationFrequency notificationFrequency;
  final UnitSystem unitSystem;
  final bool enableRealTimeAnalysis;
  final bool enableEnvironmentMonitoring;
  final bool enableAdaptiveRecommendations;
  final bool enableDetailedExplanations;
  final Map<String, dynamic> customSettings;
  final DateTime lastUpdated;

  const UserPreferences({
    required this.userId,
    required this.language,
    required this.experienceLevel,
    required this.notificationFrequency,
    required this.unitSystem,
    required this.enableRealTimeAnalysis,
    required this.enableEnvironmentMonitoring,
    required this.enableAdaptiveRecommendations,
    required this.enableDetailedExplanations,
    this.customSettings = const {},
    required this.lastUpdated,
  });

  /// 초보자용 기본 설정 생성
  factory UserPreferences.beginner({
    required String userId,
    Language language = Language.korean,
  }) {
    return UserPreferences(
      userId: userId,
      language: language,
      experienceLevel: DifficultyLevel.beginner,
      notificationFrequency: NotificationFrequency.frequent,
      unitSystem: UnitSystem.metric,
      enableRealTimeAnalysis: true,
      enableEnvironmentMonitoring: true,
      enableAdaptiveRecommendations: true,
      enableDetailedExplanations: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// 전문가용 설정 생성
  factory UserPreferences.expert({
    required String userId,
    Language language = Language.korean,
  }) {
    return UserPreferences(
      userId: userId,
      language: language,
      experienceLevel: DifficultyLevel.expert,
      notificationFrequency: NotificationFrequency.minimal,
      unitSystem: UnitSystem.metric,
      enableRealTimeAnalysis: true,
      enableEnvironmentMonitoring: true,
      enableAdaptiveRecommendations: false,
      enableDetailedExplanations: false,
      lastUpdated: DateTime.now(),
    );
  }

  /// 난이도에 따른 UI 복잡도 설정
  int get uiComplexityLevel {
    switch (experienceLevel) {
      case DifficultyLevel.beginner:
        return 1; // 간단한 UI
      case DifficultyLevel.intermediate:
        return 2; // 중간 복잡도
      case DifficultyLevel.advanced:
        return 3; // 고급 기능 표시
      case DifficultyLevel.expert:
        return 4; // 모든 기능 표시
    }
  }

  /// 알림 설정에 따른 알림 활성화 여부
  bool get isNotificationEnabled {
    return notificationFrequency != NotificationFrequency.never;
  }

  /// 세부 분석 표시 여부 (난이도 기반)
  bool get showDetailedAnalysis {
    return experienceLevel == DifficultyLevel.advanced ||
        experienceLevel == DifficultyLevel.expert;
  }

  /// 자동화 수준 (난이도 기반)
  int get automationLevel {
    switch (experienceLevel) {
      case DifficultyLevel.beginner:
        return 3; // 높은 자동화
      case DifficultyLevel.intermediate:
        return 2; // 중간 자동화
      case DifficultyLevel.advanced:
        return 1; // 낮은 자동화
      case DifficultyLevel.expert:
        return 0; // 수동 선호
    }
  }

  /// 언어 코드 반환 (로케일용)
  String get languageCode {
    switch (language) {
      case Language.korean:
        return 'ko';
      case Language.english:
        return 'en';
      case Language.japanese:
        return 'ja';
      case Language.chinese:
        return 'zh';
    }
  }

  /// 단위 변환기 설정
  Map<String, String> get unitConversionPreferences {
    switch (unitSystem) {
      case UnitSystem.metric:
        return {
          'weight': 'g',
          'volume': 'mL',
          'temperature': 'celsius',
        };
      case UnitSystem.imperial:
        return {
          'weight': 'oz',
          'volume': 'cup',
          'temperature': 'fahrenheit',
        };
      case UnitSystem.mixed:
        return {
          'weight': 'g',
          'volume': 'cup',
          'temperature': 'celsius',
        };
    }
  }

  /// 분석 시간 제한 (난이도 기반)
  Duration get analysisTimeout {
    switch (experienceLevel) {
      case DifficultyLevel.beginner:
        return const Duration(seconds: 30);
      case DifficultyLevel.intermediate:
        return const Duration(seconds: 20);
      case DifficultyLevel.advanced:
        return const Duration(seconds: 15);
      case DifficultyLevel.expert:
        return const Duration(seconds: 10);
    }
  }

  /// Map에서 생성
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] as String? ?? '',
      language: _parseLanguage(map['language'] as String?),
      experienceLevel: _parseDifficultyLevel(map['experienceLevel'] as String?),
      notificationFrequency:
          _parseNotificationFrequency(map['notificationFrequency'] as String?),
      unitSystem: _parseUnitSystem(map['unitSystem'] as String?),
      enableRealTimeAnalysis: map['enableRealTimeAnalysis'] as bool? ?? true,
      enableEnvironmentMonitoring:
          map['enableEnvironmentMonitoring'] as bool? ?? true,
      enableAdaptiveRecommendations:
          map['enableAdaptiveRecommendations'] as bool? ?? true,
      enableDetailedExplanations:
          map['enableDetailedExplanations'] as bool? ?? true,
      customSettings:
          Map<String, dynamic>.from(map['customSettings'] as Map? ?? {}),
      lastUpdated: DateTime.parse(
          map['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'language': language.name,
      'experienceLevel': experienceLevel.name,
      'notificationFrequency': notificationFrequency.name,
      'unitSystem': unitSystem.name,
      'enableRealTimeAnalysis': enableRealTimeAnalysis,
      'enableEnvironmentMonitoring': enableEnvironmentMonitoring,
      'enableAdaptiveRecommendations': enableAdaptiveRecommendations,
      'enableDetailedExplanations': enableDetailedExplanations,
      'customSettings': customSettings,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// JSON 직렬화
  String toJson() => jsonEncode(toMap());

  /// JSON 역직렬화
  factory UserPreferences.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserPreferences.fromMap(map);
  }

  /// 설정 복사본 생성 (수정)
  UserPreferences copyWith({
    String? userId,
    Language? language,
    DifficultyLevel? experienceLevel,
    NotificationFrequency? notificationFrequency,
    UnitSystem? unitSystem,
    bool? enableRealTimeAnalysis,
    bool? enableEnvironmentMonitoring,
    bool? enableAdaptiveRecommendations,
    bool? enableDetailedExplanations,
    Map<String, dynamic>? customSettings,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      language: language ?? this.language,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      notificationFrequency:
          notificationFrequency ?? this.notificationFrequency,
      unitSystem: unitSystem ?? this.unitSystem,
      enableRealTimeAnalysis:
          enableRealTimeAnalysis ?? this.enableRealTimeAnalysis,
      enableEnvironmentMonitoring:
          enableEnvironmentMonitoring ?? this.enableEnvironmentMonitoring,
      enableAdaptiveRecommendations:
          enableAdaptiveRecommendations ?? this.enableAdaptiveRecommendations,
      enableDetailedExplanations:
          enableDetailedExplanations ?? this.enableDetailedExplanations,
      customSettings:
          customSettings ?? Map<String, dynamic>.from(this.customSettings),
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// 설정 유효성 검증
  bool get isValid {
    return userId.isNotEmpty;
  }

  /// 설정 리셋 (기본값으로)
  UserPreferences resetToDefaults() {
    return UserPreferences.beginner(
      userId: userId,
      language: language,
    );
  }

  static Language _parseLanguage(String? language) {
    if (language == null) return Language.korean;
    return Language.values.firstWhere(
      (e) => e.name == language,
      orElse: () => Language.korean,
    );
  }

  static DifficultyLevel _parseDifficultyLevel(String? level) {
    if (level == null) return DifficultyLevel.beginner;
    return DifficultyLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => DifficultyLevel.beginner,
    );
  }

  static NotificationFrequency _parseNotificationFrequency(String? frequency) {
    if (frequency == null) return NotificationFrequency.normal;
    return NotificationFrequency.values.firstWhere(
      (e) => e.name == frequency,
      orElse: () => NotificationFrequency.normal,
    );
  }

  static UnitSystem _parseUnitSystem(String? system) {
    if (system == null) return UnitSystem.metric;
    return UnitSystem.values.firstWhere(
      (e) => e.name == system,
      orElse: () => UnitSystem.metric,
    );
  }
}

/// 사용자 분석 프로필
class UserAnalysisProfile {
  final String userId;
  final Map<String, dynamic> analysisPreferences;
  final List<String> preferredAnalysisTypes;
  final Map<String, double> analysisWeights; // 분석 요소별 가중치
  final Map<String, dynamic> historicalData;
  final DateTime lastAnalysis;

  const UserAnalysisProfile({
    required this.userId,
    required this.analysisPreferences,
    required this.preferredAnalysisTypes,
    required this.analysisWeights,
    required this.historicalData,
    required this.lastAnalysis,
  });

  /// 분석 선호도 점수 계산
  double getAnalysisPreferenceScore(String analysisType) {
    return analysisWeights[analysisType] ?? 1.0;
  }

  /// 최적 분석 조합 추천
  List<String> getRecommendedAnalysisTypes() {
    // 가중치에 따라 정렬하여 상위 분석 유형 반환
    final sorted = analysisWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Map에서 생성
  factory UserAnalysisProfile.fromMap(Map<String, dynamic> map) {
    return UserAnalysisProfile(
      userId: map['userId'] as String? ?? '',
      analysisPreferences:
          Map<String, dynamic>.from(map['analysisPreferences'] as Map? ?? {}),
      preferredAnalysisTypes:
          List<String>.from(map['preferredAnalysisTypes'] as List? ?? []),
      analysisWeights:
          Map<String, double>.from(map['analysisWeights'] as Map? ?? {}),
      historicalData:
          Map<String, dynamic>.from(map['historicalData'] as Map? ?? {}),
      lastAnalysis: DateTime.parse(
          map['lastAnalysis'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'analysisPreferences': analysisPreferences,
      'preferredAnalysisTypes': preferredAnalysisTypes,
      'analysisWeights': analysisWeights,
      'historicalData': historicalData,
      'lastAnalysis': lastAnalysis.toIso8601String(),
    };
  }
}
