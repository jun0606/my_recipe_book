import 'dart:math';
import '../repositories/local_storage_repository.dart';

/// 반올림 설정을 관리하는 서비스
class RoundingPreferencesService {
  final LocalStorageRepository _repository;

  RoundingPreferencesService(this._repository);

  static const String _keyRoundingEnabled = 'rounding_enabled';
  static const String _keyDecimalPlaces = 'decimal_places';

  /// 반올림 활성화 여부 가져오기
  Future<bool> getRoundingEnabled() async {
    return await _repository.loadPreference<bool>(_keyRoundingEnabled) ?? true;
  }

  /// 반올림 활성화 여부 설정
  Future<void> setRoundingEnabled(bool enabled) async {
    await _repository.savePreference(_keyRoundingEnabled, enabled);
  }

  /// 소수점 자릿수 가져오기
  Future<int> getDecimalPlaces() async {
    return await _repository.loadPreference<int>(_keyDecimalPlaces) ?? 1;
  }

  /// 소수점 자릿수 설정
  Future<void> setDecimalPlaces(int places) async {
    if (places < 0 || places > 3) {
      throw ArgumentError('소수점 자릿수는 0-3 사이여야 합니다.');
    }
    await _repository.savePreference(_keyDecimalPlaces, places);
  }

  /// 값을 반올림 설정에 따라 처리
  ///
  /// [value] 반올림할 값
  /// [decimalPlaces] 소수점 자릿수 (null이면 저장된 설정 사용)
  /// [enabled] 반올림 활성화 여부 (null이면 저장된 설정 사용)
  Future<double> roundValue(double value,
      {int? decimalPlaces, bool? enabled}) async {
    final isEnabled = enabled ?? await getRoundingEnabled();
    if (!isEnabled) return value;

    final places = decimalPlaces ?? await getDecimalPlaces();
    final factor = pow(10, places);
    return (value * factor).round() / factor;
  }

  /// 동기적으로 값을 반올림 (설정값 직접 전달)
  double roundValueSync(double value, int decimalPlaces, bool enabled) {
    if (!enabled) return value;
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  /// 반올림 설정에 따른 문자열 포맷팅
  Future<String> formatValue(double value,
      {String suffix = '', int? decimalPlaces, bool? enabled}) async {
    final roundedValue =
        await roundValue(value, decimalPlaces: decimalPlaces, enabled: enabled);
    final places = decimalPlaces ?? await getDecimalPlaces();
    return '${roundedValue.toStringAsFixed(places)}$suffix';
  }

  /// 동기적으로 문자열 포맷팅
  String formatValueSync(double value, int decimalPlaces, bool enabled,
      {String suffix = ''}) {
    final roundedValue = roundValueSync(value, decimalPlaces, enabled);
    return '${roundedValue.toStringAsFixed(decimalPlaces)}$suffix';
  }
}
