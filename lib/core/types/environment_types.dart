// 환경 타입 정의들
// Flutter Run 오류 해결을 위한 긴급 타입 정의

/// 계절 열거형
enum Season {
  spring,
  summer,
  autumn,
  winter;

  /// 표시용 이름
  String get displayName => name;

  /// 날짜로부터 계절 결정
  static Season fromDate(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }
}

/// 오븐 타입 열거형
enum OvenType {
  convection,
  professionalConvection,
  home,
  conventional,
  deck,
  steam,
  radiation,
  stone,
  professional;

  /// 표시용 이름
  String get displayName => switch (this) {
        OvenType.convection => '대류 오븐',
        OvenType.professionalConvection => '전문 대류 오븐',
        OvenType.home => '가정용 오븐',
        OvenType.conventional => '일반 오븐',
        OvenType.deck => '데크 오븐',
        OvenType.steam => '스팀 오븐',
        OvenType.radiation => '복사 오븐',
        OvenType.stone => '스톤 오븐',
        OvenType.professional => '전문 오븐',
      };
}

/// 발효 방식 열거형
enum FermentationMethod {
  roomTemperature,
  fermenter;

  /// 표시용 이름
  String get displayName => switch (this) {
        FermentationMethod.roomTemperature => '실온 발효',
        FermentationMethod.fermenter => '발효기 발효',
      };

  // fromString 메서드 추가
  static FermentationMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'roomtemperature':
      case 'room_temperature':
      case 'overnight': // overnight는 roomTemperature로 매핑
      case 'natural': // natural은 roomTemperature로 매핑
        return FermentationMethod.roomTemperature;
      case 'fermenter':
        return FermentationMethod.fermenter;
      default:
        return FermentationMethod.roomTemperature; // 기본값
    }
  }
}

/// 믹서 타입 열거형 (마찰계수 계산용 확장)
enum MixerType {
  home,
  professional,
  commercial; // ❌ 4가지 타입 제거: stand, planetary, spiral, hand

  /// 표시용 이름
  String get displayName => switch (this) {
        MixerType.home => '가정용 믹서',
        MixerType.professional => '전문용 믹서',
        MixerType.commercial => '상업용 믹서',
        // ❌ 제거된 타입들 제거: stand, planetary, spiral, hand
      };

  /// 마찰계수 (빵 제조 과학적 값)
  double get frictionCoefficient => switch (this) {
        MixerType.home => 1.0, // 기준값
        MixerType.professional => 1.1, // 약간 높은 마찰열
        MixerType.commercial => 1.2, // 높은 마찰열
        // ❌ 제거된 타입들 제거: stand, planetary, spiral, hand
      };
}

/// 사용자 환경 설정 클래스
class UserEnvironment {
  final double temperature;
  final double humidity;
  final double altitude;
  final double pressure;
  final Season season;
  final OvenType ovenType;
  final FermentationMethod fermentationMethod;
  final MixerType mixerType;
  final DateTime lastUpdated;

  /// 환경 값 유효성 검증
  bool get hasValidTemperature =>
      temperature != null && temperature > -50 && temperature < 100;
  bool get hasValidHumidity =>
      humidity != null && humidity >= 0 && humidity <= 100;

  /// 환경 값의 유효성 검증
  bool get hasValidEnvironment =>
      hasValidTemperature &&
      hasValidHumidity &&
      altitude >= -500 &&
      altitude <= 10000 &&
      pressure >= 800 &&
      pressure <= 1200;

  UserEnvironment({
    required this.temperature,
    required this.humidity,
    required this.altitude,
    required this.season,
    required this.ovenType,
    required this.fermentationMethod,
    required this.mixerType,
    this.pressure = 1013.25,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 빈 환경 설정 생성
  factory UserEnvironment.empty() {
    return UserEnvironment(
      temperature: 25.0,
      humidity: 60.0,
      altitude: 0.0,
      season: Season.spring,
      ovenType: OvenType.home,
      fermentationMethod: FermentationMethod.roomTemperature,
      mixerType: MixerType.home,
    );
  }

  /// 기본 환경 설정 생성
  factory UserEnvironment.defaultEnvironment() {
    return UserEnvironment(
      temperature: 25.0,
      humidity: 60.0,
      altitude: 100.0,
      season: Season.spring,
      ovenType: OvenType.convection,
      fermentationMethod: FermentationMethod.roomTemperature,
      mixerType: MixerType.home,
    );
  }

  /// 유효성 검증
  bool get isValid {
    return temperature >= -50 &&
        temperature <= 100 &&
        humidity >= 0 &&
        humidity <= 100 &&
        altitude >= -500 &&
        altitude <= 10000 &&
        pressure >= 800 &&
        pressure <= 1200;
  }

  /// 환경 설정 복사 (일부 속성 변경)
  UserEnvironment copyWith({
    double? temperature,
    double? humidity,
    double? altitude,
    Season? season,
    OvenType? ovenType,
    FermentationMethod? fermentationMethod,
    MixerType? mixerType,
  }) {
    return UserEnvironment(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      altitude: altitude ?? this.altitude,
      season: season ?? this.season,
      ovenType: ovenType ?? this.ovenType,
      fermentationMethod: fermentationMethod ?? this.fermentationMethod,
      mixerType: mixerType ?? this.mixerType,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'altitude': altitude,
      'season': season.name,
      'ovenType': ovenType.name,
      'fermentationMethod': fermentationMethod.name,
      'mixerType': mixerType.name,
    };
  }

  /// JSON에서 생성
  factory UserEnvironment.fromJson(Map<String, dynamic> json) {
    return UserEnvironment(
      temperature: json['temperature'] ?? 25.0,
      humidity: json['humidity'] ?? 60.0,
      altitude: json['altitude'] ?? 0.0,
      season: Season.values.firstWhere(
        (s) => s.name == json['season'],
        orElse: () => Season.spring,
      ),
      ovenType: OvenType.values.firstWhere(
        (o) => o.name == json['ovenType'],
        orElse: () => OvenType.home,
      ),
      fermentationMethod: FermentationMethod.values.firstWhere(
        (f) => f.name == json['fermentationMethod'],
        orElse: () => FermentationMethod.roomTemperature,
      ),
      mixerType: MixerType.values.firstWhere(
        (m) => m.name == json['mixerType'],
        orElse: () => MixerType.home,
      ),
    );
  }

  @override
  String toString() {
    return 'UserEnvironment(temperature: $temperature°C, humidity: $humidity%, '
        'altitude: ${altitude}m, season: ${season.displayName}, '
        'oven: ${ovenType.displayName}, fermentation: ${fermentationMethod.displayName}, '
        'mixer: ${mixerType.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEnvironment &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.altitude == altitude &&
        other.season == season &&
        other.ovenType == ovenType &&
        other.fermentationMethod == fermentationMethod &&
        other.mixerType == mixerType;
  }

  @override
  int get hashCode {
    return Object.hash(
      temperature,
      humidity,
      altitude,
      season,
      ovenType,
      fermentationMethod,
      mixerType,
    );
  }
}

/// 환경 분석 결과
class EnvironmentAnalysisResult {
  final List<String> recommendations;
  final Map<String, double> scores;
  final bool isOptimal;
  final Map<String, dynamic> details;

  const EnvironmentAnalysisResult({
    required this.recommendations,
    required this.scores,
    required this.isOptimal,
    required this.details,
  });

  /// 빈 분석 결과 생성
  factory EnvironmentAnalysisResult.empty() {
    return const EnvironmentAnalysisResult(
      recommendations: [],
      scores: {},
      isOptimal: false,
      details: {},
    );
  }

  /// 종합 점수 계산
  double get overallScore {
    if (scores.isEmpty) return 0.0;
    return scores.values.reduce((a, b) => a + b) / scores.length;
  }
}

/// 환경 설정 관리자
class EnvironmentSettingsManager {
  static final EnvironmentSettingsManager _instance =
      EnvironmentSettingsManager._internal();

  factory EnvironmentSettingsManager() => _instance;

  EnvironmentSettingsManager._internal();

  /// 환경 설정 저장
  Future<void> saveEnvironmentSettings(UserEnvironment environment) async {
    // 실제 구현에서는 SharedPreferences 또는 데이터베이스에 저장
    print('환경 설정 저장: $environment');
  }

  /// 환경 설정 로드
  Future<UserEnvironment> loadEnvironmentSettings() async {
    // 실제 구현에서는 SharedPreferences 또는 데이터베이스에서 로드
    return UserEnvironment.defaultEnvironment();
  }

  /// 환경 설정 로드 (기본값과 함께)
  Future<UserEnvironment> loadEnvironmentSettingsWithDefault() async {
    try {
      return await loadEnvironmentSettings();
    } catch (e) {
      print('환경 설정 로드 실패, 기본값 사용: $e');
      return UserEnvironment.defaultEnvironment();
    }
  }
}

/// 온도 범위 클래스
class TemperatureRange {
  final double min;
  final double max;

  const TemperatureRange({
    required this.min,
    required this.max,
  });

  /// 범위 내에 있는지 확인
  bool contains(double temperature) {
    return temperature >= min && temperature <= max;
  }

  /// 범위의 중간값 반환
  double get midpoint => (min + max) / 2;

  /// 범위의 너비 반환
  double get width => max - min;

  @override
  String toString() {
    return '${min}°C - ${max}°C';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemperatureRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

/// 습도 범위 클래스
class HumidityRange {
  final double min;
  final double max;

  const HumidityRange({
    required this.min,
    required this.max,
  });

  /// 범위 내에 있는지 확인
  bool contains(double humidity) {
    return humidity >= min && humidity <= max;
  }

  /// 범위의 중간값 반환
  double get midpoint => (min + max) / 2;

  /// 범위의 너비 반환
  double get width => max - min;

  @override
  String toString() {
    return '${min}% - ${max}%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HumidityRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}
