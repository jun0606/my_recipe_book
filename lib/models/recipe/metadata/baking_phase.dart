import 'dart:convert';

/// 굽기 단계
class BakingPhase {
  final String phase; // 단계명 (Phase 1, Phase 2, etc.)
  final double temperature; // 온도 (°C)
  final int time; // 시간 (분)
  final double? steamTime; // 스팀 시간 (분, 선택적)

  const BakingPhase({
    required this.phase,
    required this.temperature,
    required this.time,
    this.steamTime,
  });

  factory BakingPhase.fromJson(Map<String, dynamic> json) {
    return BakingPhase(
      phase: json['phase'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      time: json['time'] as int,
      steamTime: json['steamTime'] != null
          ? (json['steamTime'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'temperature': temperature,
      'time': time,
      'steamTime': steamTime,
    };
  }

  BakingPhase copyWith({
    String? phase,
    double? temperature,
    int? time,
    double? steamTime,
  }) {
    return BakingPhase(
      phase: phase ?? this.phase,
      temperature: temperature ?? this.temperature,
      time: time ?? this.time,
      steamTime: steamTime ?? this.steamTime,
    );
  }

  /// 예상 소요 시간
  Duration get estimatedDuration => Duration(minutes: time);

  /// 스팀 사용 여부
  bool get hasSteam => steamTime != null && steamTime! > 0;

  /// 스팀 비율 계산
  double get steamRatio {
    if (!hasSteam || steamTime == 0) return 0.0;
    return steamTime! / time;
  }

  @override
  String toString() {
    return 'BakingPhase(phase: $phase, temp: ${temperature.toStringAsFixed(1)}°C, '
        'time: ${time}분, steam: ${steamTime?.toStringAsFixed(1)}분)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BakingPhase &&
        other.phase == phase &&
        other.temperature == temperature &&
        other.time == time &&
        other.steamTime == steamTime;
  }

  @override
  int get hashCode {
    return phase.hashCode ^
        temperature.hashCode ^
        time.hashCode ^
        steamTime.hashCode;
  }
}

/// 베이킹 프로파일 생성기
class BakingProfileGenerator {
  /// 기본 빵 굽기 프로파일 생성
  static List<BakingPhase> createStandardBreadProfile() {
    return [
      BakingPhase(
        phase: '예열 및 스팀',
        temperature: 230.0,
        time: 10,
        steamTime: 5.0,
      ),
      BakingPhase(
        phase: '본 굽기',
        temperature: 200.0,
        time: 25,
      ),
      BakingPhase(
        phase: '마무리',
        temperature: 180.0,
        time: 10,
      ),
    ];
  }

  /// 바게트용 프로파일 생성
  static List<BakingPhase> createBaguetteProfile() {
    return [
      BakingPhase(
        phase: '고온 예열',
        temperature: 250.0,
        time: 8,
        steamTime: 6.0,
      ),
      BakingPhase(
        phase: '본 굽기',
        temperature: 220.0,
        time: 20,
      ),
      BakingPhase(
        phase: '색상 마무리',
        temperature: 200.0,
        time: 5,
      ),
    ];
  }

  /// 케이크용 프로파일 생성
  static List<BakingPhase> createCakeProfile() {
    return [
      BakingPhase(
        phase: '예열',
        temperature: 170.0,
        time: 15,
      ),
      BakingPhase(
        phase: '본 굽기',
        temperature: 160.0,
        time: 30,
      ),
      BakingPhase(
        phase: '마무리',
        temperature: 150.0,
        time: 10,
      ),
    ];
  }

  /// 쿠키용 프로파일 생성
  static List<BakingPhase> createCookieProfile() {
    return [
      BakingPhase(
        phase: '예열',
        temperature: 180.0,
        time: 10,
      ),
      BakingPhase(
        phase: '굽기',
        temperature: 170.0,
        time: 12,
      ),
    ];
  }

  /// 환경에 따른 프로파일 조정
  static List<BakingPhase> adjustForEnvironment(
    List<BakingPhase> baseProfile, {
    required double temperature,
    required double humidity,
    required double altitude,
  }) {
    return baseProfile.map((phase) {
      double adjustedTemp = phase.temperature;
      int adjustedTime = phase.time;

      // 고온 환경: 온도와 시간 감소
      if (temperature > 28) {
        adjustedTemp *= 0.95;
        adjustedTime = (adjustedTime * 0.9).round();
      }
      // 저온 환경: 온도와 시간 증가
      else if (temperature < 20) {
        adjustedTemp *= 1.05;
        adjustedTime = (adjustedTime * 1.1).round();
      }

      // 고습도 환경: 스팀 시간 감소
      double? adjustedSteamTime = phase.steamTime;
      if (humidity > 80 && adjustedSteamTime != null) {
        adjustedSteamTime *= 0.8;
      }
      // 저습도 환경: 스팀 시간 증가
      else if (humidity < 50 && adjustedSteamTime != null) {
        adjustedSteamTime *= 1.2;
      }

      // 고도 보정: 온도 증가
      if (altitude > 500) {
        adjustedTemp += (altitude / 1000) * 5;
      }

      return BakingPhase(
        phase: phase.phase,
        temperature: adjustedTemp,
        time: adjustedTime,
        steamTime: adjustedSteamTime,
      );
    }).toList();
  }
}
