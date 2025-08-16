class ValidationUtils {
  static bool isValidNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }
  
  static bool isValidPositiveNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    final number = double.tryParse(value);
    return number != null && number > 0;
  }
  
  static bool isValidInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    return int.tryParse(value) != null;
  }
  
  static bool isValidPositiveInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    final number = int.tryParse(value);
    return number != null && number > 0;
  }
  
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    return isNotEmpty(value) ? null : '$fieldName을(를) 입력하세요';
  }
  
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (!isNotEmpty(value)) return '$fieldName을(를) 입력하세요';
    if (!isValidNumber(value)) return '유효한 숫자를 입력하세요';
    if (!isValidPositiveNumber(value)) return '0보다 큰 값을 입력하세요';
    return null;
  }
  
  static String? validatePositiveInteger(String? value, String fieldName) {
    if (!isNotEmpty(value)) return '$fieldName을(를) 입력하세요';
    if (!isValidInteger(value)) return '유효한 정수를 입력하세요';
    if (!isValidPositiveInteger(value)) return '0보다 큰 정수를 입력하세요';
    return null;
  }
}