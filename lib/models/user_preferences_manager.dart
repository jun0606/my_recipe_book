///// 📱 모바일 최적화 사용자 설정 관리자
class UserPreferencesManager {
  static const String _prefsKey = 'bread_module_preferences';

  // 사용자 설정 (자동으로 저장됨)
  static Map<String, dynamic> _cachedSettings = {
    'mixerType': '스파이럴 믹서',
    'expertMode': false,
    'infoDisplayLevel': 'standard', // minimal, standard, detailed, expert
    'locationBasedEnv': true,
    'showDetailedInfo': false,
    'firstTimeUser': true,
    'preferredLanguage': 'ko',
    'lastUsedRecipe': null,
    'measurementSystem': 'metric', // metric, imperial
  };

  // 설정 변경 리스너
  static final List<Function(Map<String, dynamic>)> _listeners = [];

  /// 설정 변경 리스너 추가
  static void addListener(Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  /// 설정 변경 리스너 제거
  static void removeListener(Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }

  /// 설정 변경 알림
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener(Map<String, dynamic>.from(_cachedSettings));
    }
  }

  /// 설정값 가져오기
  static T getSetting<T>(String key, T defaultValue) {
    return _cachedSettings[key] as T ?? defaultValue;
  }

  /// 설정값 저장하기
  static Future<void> setSetting(String key, dynamic value) async {
    _cachedSettings[key] = value;

    // SharedPreferences에 저장 (실제 앱에서 사용)
    try {
      // 실제 앱에서는 SharedPreferences 사용
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString(_prefsKey, jsonEncode(_cachedSettings));
      print('설정 저장됨: $key = $value');
    } catch (e) {
      print('설정 저장 실패: $e');
    }

    _notifyListeners();
  }

  /// 모든 설정 로드 (앱 시작시 호출)
  static Future<void> loadSettings() async {
    try {
      // 실제 앱에서는 SharedPreferences에서 로드
      // final prefs = await SharedPreferences.getInstance();
      // final savedSettings = prefs.getString(_prefsKey);
      // if (savedSettings != null) {
      //   _cachedSettings = Map<String, dynamic>.from(jsonDecode(savedSettings));
      // }

      print('사용자 설정 로드 완료');
      _notifyListeners();
    } catch (e) {
      print('설정 로드 실패: $e');
    }
  }

  /// 설정 초기화 (첫 실행용)
  static Future<void> initializeDefaults() async {
    final isFirstTime = getSetting('firstTimeUser', true);
    if (isFirstTime) {
      // 첫 실행 시 간단한 설정만 물어보고 자동 저장
      await setSetting('firstTimeUser', false);
      await setSetting('expertMode', false);
      await setSetting('infoDisplayLevel', 'standard');
      await setSetting('locationBasedEnv', true);

      print('초기 설정 완료');
    }
  }

  /// 믹서 타입 설정
  static String get mixerType => getSetting('mixerType', '스파이럴 믹서');
  static Future<void> setMixerType(String type) =>
      setSetting('mixerType', type);

  /// 전문가 모드 설정
  static bool get expertMode => getSetting('expertMode', false);
  static Future<void> setExpertMode(bool enabled) =>
      setSetting('expertMode', enabled);

  /// 정보 표시 레벨
  static String get infoDisplayLevel =>
      getSetting('infoDisplayLevel', 'standard');
  static Future<void> setInfoDisplayLevel(String level) =>
      setSetting('infoDisplayLevel', level);

  /// 위치 기반 환경 감지
  static bool get locationBasedEnv => getSetting('locationBasedEnv', true);
  static Future<void> setLocationBasedEnv(bool enabled) =>
      setSetting('locationBasedEnv', enabled);

  /// 상세 정보 표시
  static bool get showDetailedInfo => getSetting('showDetailedInfo', false);
  static Future<void> setShowDetailedInfo(bool show) =>
      setSetting('showDetailedInfo', show);

  /// 측정 시스템
  static String get measurementSystem =>
      getSetting('measurementSystem', 'metric');
  static Future<void> setMeasurementSystem(String system) =>
      setSetting('measurementSystem', system);

  /// 설정 요약 정보
  static Map<String, dynamic> getSettingsSummary() {
    return {
      '믹서 타입': mixerType,
      '전문가 모드': expertMode ? '켜짐' : '꺼짐',
      '정보 표시': _getDisplayLevelName(infoDisplayLevel),
      '환경 감지': locationBasedEnv ? '자동' : '수동',
      '측정 단위': measurementSystem == 'metric' ? '미터법' : '야드파운드법',
    };
  }

  static String _getDisplayLevelName(String level) {
    switch (level) {
      case 'minimal':
        return '최소';
      case 'standard':
        return '표준';
      case 'detailed':
        return '상세';
      case 'expert':
        return '전문가';
      default:
        return '표준';
    }
  }
}
