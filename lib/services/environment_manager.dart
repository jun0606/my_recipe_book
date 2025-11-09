/// 환경 데이터 실시간 관리 매니저
/// 전역 싱글턴으로 모든 컴포넌트에서 실시간 환경 데이터에 접근 가능
// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/types/environment_types.dart';

/// 환경 데이터 실시간 관리 클래스
class EnvironmentManager extends ChangeNotifier {
  // 싱글턴 인스턴스
  static final EnvironmentManager _instance = EnvironmentManager._internal();
  factory EnvironmentManager() => _instance;

  EnvironmentManager._internal() {
    _initializeDefaultEnvironment();
  }

  // 현재 환경 데이터
  late UserEnvironment _currentEnvironment;

  // getter들
  UserEnvironment get currentEnvironment => _currentEnvironment;
  double get temperature => _currentEnvironment.temperature;
  double get humidity => _currentEnvironment.humidity;
  double? get pressure => _currentEnvironment.pressure;
  double? get altitude => _currentEnvironment.altitude;
  Season get season => _currentEnvironment.season;
  OvenType get ovenType => _currentEnvironment.ovenType;
  FermentationMethod get fermentationMethod =>
      _currentEnvironment.fermentationMethod;
  MixerType get mixerType => _currentEnvironment.mixerType;
  DateTime get lastUpdated => _currentEnvironment.lastUpdated;

  // 디폴트 환경 초기화
  void _initializeDefaultEnvironment() {
    _currentEnvironment = UserEnvironment(
      temperature: 25.0, // 섭씨
      humidity: 60.0, // %
      pressure: 1013.25, // hPa
      altitude: 0.0, // m
      season: Season.spring,
      ovenType: OvenType.convection,
      fermentationMethod: FermentationMethod.roomTemperature,
      mixerType: MixerType.home,
      lastUpdated: DateTime.now(),
    );

    print('🔧 [EnvironmentManager] 기본 환경 초기화:');
    print('   - 온도: ${_currentEnvironment.temperature}°C');
    print('   - 습도: ${_currentEnvironment.humidity}%');
    print('   - 계절: ${_currentEnvironment.season.displayName}');
    print('   - 믹서: ${_currentEnvironment.mixerType.name}');
  }

  /// 환경 데이터 전체 업데이트 (샵 전체 환경 객체)
  void updateEnvironment(UserEnvironment newEnvironment) {
    final oldTemp = _currentEnvironment.temperature;
    final oldHumidity = _currentEnvironment.humidity;

    _currentEnvironment = UserEnvironment(
      temperature: newEnvironment.temperature,
      humidity: newEnvironment.humidity,
      pressure: newEnvironment.pressure ?? _currentEnvironment.pressure,
      altitude: newEnvironment.altitude ?? _currentEnvironment.altitude,
      season: newEnvironment.season,
      ovenType: newEnvironment.ovenType,
      fermentationMethod: newEnvironment.fermentationMethod,
      mixerType: newEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print('🔄 [EnvironmentManager] 환경 업데이트:');
    print('   - 온도: $oldTemp°C → ${_currentEnvironment.temperature}°C');
    print('   - 습도: $oldHumidity% → ${_currentEnvironment.humidity}%');

    // 모든 리스너에게 변경 알림
    notifyListeners();
  }

  /// 개별 속성 업데이트 (온도만, 습도만 등)
  void updateTemperature(double temperature) {
    final oldTemp = _currentEnvironment.temperature;
    _currentEnvironment = UserEnvironment(
      temperature: temperature,
      humidity: _currentEnvironment.humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print('🌡️ [EnvironmentManager] 온도 업데이트: $oldTemp°C → $temperature°C');
    notifyListeners();
  }

  /// 습도 업데이트
  void updateHumidity(double humidity) {
    final oldHumidity = _currentEnvironment.humidity;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print('💧 [EnvironmentManager] 습도 업데이트: $oldHumidity% → $humidity%');
    notifyListeners();
  }

  /// 고도 업데이트
  void updateAltitude(double altitude) {
    final oldAltitude = _currentEnvironment.altitude;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: _currentEnvironment.humidity,
      altitude: altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print('🏔️ [EnvironmentManager] 고도 업데이트: $oldAltitude → $altitude m');
    notifyListeners();
  }

  /// 계절 업데이트
  void updateSeason(Season season) {
    final oldSeason = _currentEnvironment.season;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: _currentEnvironment.humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print(
        '🌸 [EnvironmentManager] 계절 업데이트: ${oldSeason.displayName} → ${season.displayName}');
    notifyListeners();
  }

  /// 오븐 타입 업데이트
  void updateOvenType(OvenType ovenType) {
    final oldOvenType = _currentEnvironment.ovenType;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: _currentEnvironment.humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print(
        '🏠 [EnvironmentManager] 오븐 타입 업데이트: ${oldOvenType.name} → ${ovenType.name}');
    notifyListeners();
  }

  /// 발효 방법 업데이트
  void updateFermentationMethod(FermentationMethod method) {
    final oldMethod = _currentEnvironment.fermentationMethod;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: _currentEnvironment.humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: method,
      mixerType: _currentEnvironment.mixerType,
      lastUpdated: DateTime.now(),
    );

    print(
        '🧑‍🍳 [EnvironmentManager] 발효 방법 업데이트: ${oldMethod.name} → ${method.name}');
    notifyListeners();
  }

  /// 믹서 타입 업데이트
  void updateMixerType(MixerType mixerType) {
    final oldMixerType = _currentEnvironment.mixerType;
    _currentEnvironment = UserEnvironment(
      temperature: _currentEnvironment.temperature,
      humidity: _currentEnvironment.humidity,
      altitude: _currentEnvironment.altitude,
      pressure: _currentEnvironment.pressure,
      season: _currentEnvironment.season,
      ovenType: _currentEnvironment.ovenType,
      fermentationMethod: _currentEnvironment.fermentationMethod,
      mixerType: mixerType,
      lastUpdated: DateTime.now(),
    );

    print(
        '🔄 [EnvironmentManager] 믹서 타입 업데이트: ${oldMixerType.name} → ${mixerType.name}');
    notifyListeners();
  }

  /// Map 데이터로부터 환경 업데이트
  void updateFromMap(Map<String, dynamic> data) {
    try {
      final newEnv = UserEnvironment(
        temperature: (data['temperature'] as num?)?.toDouble() ?? temperature,
        humidity: (data['humidity'] as num?)?.toDouble() ?? humidity,
        pressure: (data['pressure'] as num?)?.toDouble() ?? pressure ?? 1013.25,
        altitude: (data['altitude'] as num?)?.toDouble() ?? altitude ?? 0.0,
        season: _parseSeason(data['season']?.toString()) ?? season,
        ovenType: _parseOvenType(data['ovenType']?.toString()) ?? ovenType,
        fermentationMethod:
            _parseFermentationMethod(data['fermentationMethod']?.toString()) ??
                fermentationMethod,
        mixerType: _parseMixerType(data['mixerType']?.toString()) ?? mixerType,
        lastUpdated: DateTime.now(),
      );

      updateEnvironment(newEnv);
    } catch (e) {
      print('❌ [EnvironmentManager] Map에서 환경 업데이트 실패: $e');
    }
  }

  /// 환경 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'altitude': altitude,
      'season': season.name,
      'ovenType': ovenType.name,
      'fermentationMethod': fermentationMethod.name,
      'mixerType': mixerType.name,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// 환경 검증
  bool isValidEnvironment() {
    return _currentEnvironment.temperature >= -50 &&
        _currentEnvironment.temperature <= 100 &&
        _currentEnvironment.humidity >= 0 &&
        _currentEnvironment.humidity <= 100 &&
        _currentEnvironment.altitude >= -500 &&
        _currentEnvironment.altitude <= 10000;
  }

  // 헬퍼 메소드들
  Season? _parseSeason(String? value) {
    if (value == null) return null;
    return Season.values.firstWhere(
      (season) => season.name == value,
      orElse: () => season,
    );
  }

  OvenType? _parseOvenType(String? value) {
    if (value == null) return null;
    return OvenType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ovenType,
    );
  }

  FermentationMethod? _parseFermentationMethod(String? value) {
    if (value == null) return null;
    return FermentationMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => fermentationMethod,
    );
  }

  MixerType? _parseMixerType(String? value) {
    if (value == null) return null;
    return MixerType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => mixerType,
    );
  }

  /// 디버그 정보 출력
  void printCurrentEnvironment() {
    print('\n🌍 [EnvironmentManager] 현재 환경 상태:');
    print('   - 온도: $temperature°C');
    print('   - 습도: $humidity%');
    print('   - 고도: $altitude m');
    print('   - 계절: ${season.displayName}');
    print('   - 오븐: ${ovenType.name}');
    print('   - 발효 방법: ${fermentationMethod.name}');
    print('   - 믹서: ${mixerType.name}');
    print('   - 마지막 업데이트: $lastUpdated');
  }
}
