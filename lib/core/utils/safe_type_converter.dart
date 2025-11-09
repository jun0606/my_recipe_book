// lib/core/utils/safe_type_converter.dart
// 타입 안전성 강화를 위한 유틸리티 클래스

/// 안전한 타입 변환을 위한 유틸리티 클래스
/// 모든 타입 변환에서 런타임 에러를 방지하고 기본값을 제공
class SafeTypeConverter {
  /// 안전한 타입 캐스팅
  static T? safeCast<T>(dynamic value) {
    try {
      return value is T ? value : null;
    } catch (e) {
      return null;
    }
  }

  /// 필수 타입 캐스팅 (실패 시 예외 발생)
  static T safeCastRequired<T>(dynamic value, String fieldName) {
    try {
      if (value is T) return value;
      throw ValidationException(
          '$fieldName is required and must be of type $T');
    } catch (e) {
      throw ValidationException('$fieldName validation failed: $e');
    }
  }

  /// 안전한 double 변환
  static double safeToDouble(dynamic value, {double defaultValue = 0.0}) {
    try {
      if (value == null) return defaultValue;

      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      if (value is num) return value.toDouble();

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 안전한 int 변환
  static int? safeToInt(dynamic value) {
    try {
      if (value == null) return null;

      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 필수 int 변환 (실패 시 예외 발생)
  static int safeToIntRequired(dynamic value, String fieldName) {
    final result = safeToInt(value);
    if (result == null) {
      throw ValidationException(
          '$fieldName is required and must be a valid integer');
    }
    return result;
  }

  /// 안전한 String 변환
  static String safeToString(dynamic value, {String defaultValue = ''}) {
    try {
      if (value == null) return defaultValue;

      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      if (value is bool) return value.toString();

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 필수 String 변환 (실패 시 예외 발생)
  static String safeToStringRequired(dynamic value, String fieldName) {
    final result = safeToString(value);
    if (result.isEmpty) {
      throw ValidationException('$fieldName is required and cannot be empty');
    }
    return result;
  }

  /// 안전한 bool 변환
  static bool safeToBool(dynamic value, {bool defaultValue = false}) {
    try {
      if (value == null) return defaultValue;

      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
        return defaultValue;
      }

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 안전한 DateTime 변환
  static DateTime? safeToDateTime(dynamic value) {
    try {
      if (value == null) return null;

      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 안전한 List 변환
  static List<T> safeToList<T>(dynamic value,
      {List<T> defaultValue = const []}) {
    try {
      if (value == null) return defaultValue;

      if (value is List<T>) return value;
      if (value is List) return value.cast<T>();

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 안전한 Map 변환
  static Map<K, V> safeToMap<K, V>(dynamic value,
      {Map<K, V> defaultValue = const {}}) {
    try {
      if (value == null) return defaultValue;

      if (value is Map<K, V>) return value;
      if (value is Map) return value.cast<K, V>();

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}

/// 검증 예외 클래스
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
