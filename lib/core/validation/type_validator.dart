// 런타임 타입 검증 시스템
// Week 2: 타입 안전성 보장

import '../types/comprehensive_types.dart';
import '../controllers/base_analysis_controller.dart';

/// 타입 검증 인터페이스
abstract class TypeValidator<T> {
  /// 값 검증
  ValidationResult validate(T value);

  /// 타입 호환성 확인
  bool isCompatible(dynamic value);

  /// 기본값 제공
  T get defaultValue;

  /// 타입 이름
  String get typeName;
}

/// 재료 분석 결과 검증기
class ComprehensiveIngredientAnalysisValidator
    extends TypeValidator<ComprehensiveIngredientAnalysis> {
  @override
  String get typeName => 'ComprehensiveIngredientAnalysis';

  @override
  ComprehensiveIngredientAnalysis get defaultValue =>
      ComprehensiveIngredientAnalysis.empty();

  @override
  ValidationResult validate(ComprehensiveIngredientAnalysis value) {
    final errors = <String>[];
    final warnings = <String>[];

    // 필수 필드 검증
    if (value.analysisId.isEmpty) {
      errors.add('analysisId가 비어있습니다');
    }

    if (value.timestamp.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      errors.add('timestamp가 미래 시간입니다');
    }

    // 신뢰도 검증
    if (value.overallConfidence < 0 || value.overallConfidence > 1) {
      errors.add('overallConfidence가 유효 범위(0-1)를 벗어났습니다');
    }

    // 하위 객체 검증
    final syrupResult = _validateSyrupAnalysis(value.syrupAnalysis);
    final fatResult = _validateFatAnalysis(value.fatAnalysis);
    final doughResult =
        _validateSpecialDoughDetection(value.specialDoughDetection);

    errors.addAll(syrupResult.errors);
    errors.addAll(fatResult.errors);
    errors.addAll(doughResult.errors);

    warnings.addAll(syrupResult.warnings);
    warnings.addAll(fatResult.warnings);
    warnings.addAll(doughResult.warnings);

    // 신뢰도 경고
    if (value.overallConfidence < 0.5) {
      warnings.add(
          '전체 신뢰도가 낮습니다 (${(value.overallConfidence * 100).toStringAsFixed(1)}%)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  bool isCompatible(dynamic value) {
    return value is ComprehensiveIngredientAnalysis;
  }

  ValidationResult _validateSyrupAnalysis(SyrupAnalysisResult value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.sugarContent < 0 || value.sugarContent > 100) {
      errors.add('시럽 당분 함량이 유효 범위(0-100%)를 벗어났습니다');
    }

    if (value.viscosity <= 0) {
      errors.add('시럽 점도가 0보다 커야 합니다');
    }

    if (value.confidence < 0 || value.confidence > 1) {
      errors.add('시럽 분석 신뢰도가 유효 범위(0-1)를 벗어났습니다');
    }

    if (value.confidence < 0.7) {
      warnings.add('시럽 분석 신뢰도가 낮습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validateFatAnalysis(FatAnalysisResult value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.fatContent < 0 || value.fatContent > 100) {
      errors.add('지방 함량이 유효 범위(0-100%)를 벗어났습니다');
    }

    if (value.fatType.isEmpty) {
      errors.add('지방 타입이 지정되지 않았습니다');
    }

    if (value.confidence < 0 || value.confidence > 1) {
      errors.add('지방 분석 신뢰도가 유효 범위(0-1)를 벗어났습니다');
    }

    if (value.confidence < 0.7) {
      warnings.add('지방 분석 신뢰도가 낮습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validateSpecialDoughDetection(
      SpecialDoughDetectionResult value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.highestConfidence < 0 || value.highestConfidence > 1) {
      errors.add('특수 반죽 감지 신뢰도가 유효 범위(0-1)를 벗어났습니다');
    }

    if (value.highestConfidence < 0.5) {
      warnings.add('특수 반죽 감지 신뢰도가 낮습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 믹싱 분석 결과 검증기
class MixingAnalysisResultValidator
    extends TypeValidator<MixingAnalysisResult> {
  @override
  String get typeName => 'MixingAnalysisResult';

  @override
  MixingAnalysisResult get defaultValue => MixingAnalysisResult.empty();

  @override
  ValidationResult validate(MixingAnalysisResult value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.confidenceScore < 0 || value.confidenceScore > 1) {
      errors.add('믹싱 분석 신뢰도가 유효 범위(0-1)를 벗어났습니다');
    }

    if (value.analysisTime.isNegative) {
      errors.add('분석 시간이 음수일 수 없습니다');
    }

    if (value.analysisTime > const Duration(minutes: 5)) {
      warnings.add('분석 시간이 5분을 초과했습니다');
    }

    if (value.optimizedSteps.isEmpty) {
      warnings.add('최적화된 믹싱 단계가 없습니다');
    }

    if (value.confidenceScore < 0.6) {
      warnings.add('믹싱 분석 신뢰도가 낮습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  bool isCompatible(dynamic value) {
    return value is MixingAnalysisResult;
  }
}

/// 환경 분석 결과 검증기
class EnvironmentAnalysisResultValidator
    extends TypeValidator<EnvironmentAnalysisResult> {
  @override
  String get typeName => 'EnvironmentAnalysisResult';

  @override
  EnvironmentAnalysisResult get defaultValue =>
      EnvironmentAnalysisResult.empty();

  @override
  ValidationResult validate(EnvironmentAnalysisResult value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.overallScore < 0 || value.overallScore > 1) {
      errors.add('환경 분석 점수가 유효 범위(0-1)를 벗어났습니다');
    }

    if (value.scores.isEmpty) {
      warnings.add('환경 분석 점수 데이터가 없습니다');
    }

    if (value.recommendations.isEmpty) {
      warnings.add('환경 개선 권장사항이 없습니다');
    }

    if (value.overallScore < 0.5) {
      warnings.add('환경 조건이 최적이 아닙니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  bool isCompatible(dynamic value) {
    return value is EnvironmentAnalysisResult;
  }
}

/// 분석 요청 검증기
class AnalysisRequestValidator extends TypeValidator<AnalysisRequest> {
  @override
  String get typeName => 'AnalysisRequest';

  @override
  AnalysisRequest get defaultValue => AnalysisRequest(
        ingredients: [],
        breadType: 'unknown',
        settings: const AnalysisSettings(),
        environment: {},
        requestId: '',
      );

  @override
  ValidationResult validate(AnalysisRequest value) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value.ingredients.isEmpty) {
      errors.add('재료 목록이 비어있습니다');
    }

    if (value.breadType.isEmpty) {
      errors.add('빵 타입이 지정되지 않았습니다');
    }

    if (value.requestId.isEmpty) {
      errors.add('요청 ID가 비어있습니다');
    }

    if (value.ingredients.length > 50) {
      warnings.add('재료 목록이 너무 많습니다 (50개 초과)');
    }

    // 재료 데이터 검증
    for (int i = 0; i < value.ingredients.length; i++) {
      final ingredient = value.ingredients[i];
      if (ingredient['name'] == null || ingredient['name'].toString().isEmpty) {
        errors.add('재료 ${i + 1}: 이름이 비어있습니다');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  bool isCompatible(dynamic value) {
    return value is AnalysisRequest;
  }
}

/// 타입 검증기 팩토리
class TypeValidatorFactory {
  static final Map<String, TypeValidator> _validators = {};

  static void registerValidator<T>(TypeValidator<T> validator) {
    _validators[validator.typeName] = validator;
  }

  static TypeValidator<T>? getValidator<T>(String typeName) {
    return _validators[typeName] as TypeValidator<T>?;
  }

  static void initializeDefaults() {
    registerValidator(ComprehensiveIngredientAnalysisValidator());
    registerValidator(MixingAnalysisResultValidator());
    registerValidator(EnvironmentAnalysisResultValidator());
    registerValidator(AnalysisRequestValidator());
  }

  static ValidationResult validate(dynamic value, String typeName) {
    final validator = _validators[typeName];
    if (validator == null) {
      return ValidationResult.invalid(['지원하지 않는 타입입니다: $typeName']);
    }

    if (!validator.isCompatible(value)) {
      return ValidationResult.invalid(['타입이 호환되지 않습니다: ${value.runtimeType}']);
    }

    return validator.validate(value);
  }
}

/// 런타임 타입 검증 서비스
class RuntimeTypeValidator {
  static final Map<String, TypeValidator> _validators = {};

  static void registerValidator(String typeName, TypeValidator validator) {
    _validators[typeName] = validator;
  }

  static ValidationResult validateType(dynamic value, String expectedType) {
    final validator = _validators[expectedType];
    if (validator == null) {
      return ValidationResult.invalid(['타입 검증기가 등록되지 않았습니다: $expectedType']);
    }

    if (!validator.isCompatible(value)) {
      return ValidationResult.invalid(
          ['타입 불일치: 기대=${expectedType}, 실제=${value.runtimeType}']);
    }

    return validator.validate(value);
  }

  static bool isTypeCompatible(dynamic value, String expectedType) {
    final validator = _validators[expectedType];
    return validator?.isCompatible(value) ?? false;
  }

  static T? getDefaultValue<T>(String typeName) {
    final validator = _validators[typeName];
    if (validator != null && validator is TypeValidator<T>) {
      return validator.defaultValue;
    }
    return null;
  }

  /// 분석 파이프라인 검증
  static ValidationResult validateAnalysisPipeline(
    AnalysisRequest request,
    ComprehensiveIngredientAnalysis? ingredientAnalysis,
    MixingAnalysisResult? mixingResult,
    EnvironmentAnalysisResult? environmentResult,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    // 요청 검증
    final requestValidation = validateType(request, 'AnalysisRequest');
    errors.addAll(requestValidation.errors);
    warnings.addAll(requestValidation.warnings);

    // 재료 분석 결과 검증
    if (ingredientAnalysis != null) {
      final ingredientValidation =
          validateType(ingredientAnalysis, 'ComprehensiveIngredientAnalysis');
      errors.addAll(ingredientValidation.errors);
      warnings.addAll(ingredientValidation.warnings);
    }

    // 믹싱 분석 결과 검증
    if (mixingResult != null) {
      final mixingValidation =
          validateType(mixingResult, 'MixingAnalysisResult');
      errors.addAll(mixingValidation.errors);
      warnings.addAll(mixingValidation.warnings);
    }

    // 환경 분석 결과 검증
    if (environmentResult != null) {
      final environmentValidation =
          validateType(environmentResult, 'EnvironmentAnalysisResult');
      errors.addAll(environmentValidation.errors);
      warnings.addAll(environmentValidation.warnings);
    }

    // 파이프라인 일관성 검증
    if (request.ingredients.isNotEmpty && ingredientAnalysis == null) {
      warnings.add('재료가 있지만 재료 분석 결과가 없습니다');
    }

    if (ingredientAnalysis != null && mixingResult == null) {
      warnings.add('재료 분석 결과가 있지만 믹싱 분석 결과가 없습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 타입 변환 검증
  static ValidationResult validateTypeConversion(
    dynamic sourceValue,
    String sourceType,
    String targetType,
  ) {
    final errors = <String>[];

    if (!isTypeCompatible(sourceValue, sourceType)) {
      errors.add('소스 값이 소스 타입과 호환되지 않습니다');
    }

    // 변환 가능성 검증 로직 추가 가능
    // 예: Map -> 객체 변환, JSON 직렬화 등

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 타입 안전성 보장 믹스인
mixin TypeSafeAnalysis {
  /// 타입 검증 실행
  ValidationResult validateTypes() {
    final errors = <String>[];
    final warnings = <String>[];

    // 런타임 타입 검증 로직 구현
    // 각 필드의 타입을 검증하고 결과 반환

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 타입 안전한 값 반환
  T safeCast<T>(dynamic value, T defaultValue) {
    if (value is T) {
      return value;
    }

    // 타입 변환 로깅
    print('타입 변환: ${value.runtimeType} -> $T, 기본값 사용');

    return defaultValue;
  }

  /// 널 안전한 값 반환
  T? safeValue<T>(dynamic value) {
    return value is T ? value : null;
  }
}

/// 검증 결과 로깅 확장
extension ValidationResultLogging on ValidationResult {
  void logValidationResult([String context = '']) {
    final prefix = context.isEmpty ? '' : '[$context] ';

    if (!isValid) {
      print('${prefix}타입 검증 실패:');
      for (final error in errors) {
        print('  ❌ $error');
      }
    }

    if (warnings.isNotEmpty) {
      print('${prefix}타입 검증 경고:');
      for (final warning in warnings) {
        print('  ⚠️ $warning');
      }
    }

    if (isValid && warnings.isEmpty) {
      print('${prefix}타입 검증 성공 ✅');
    }
  }
}

/// 타입 검증 헬퍼 함수들
class TypeValidationHelpers {
  /// 맵 데이터 검증
  static ValidationResult validateMapData(
    Map<String, dynamic> data,
    Map<String, ValidationRule> rules,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    for (final entry in rules.entries) {
      final key = entry.key;
      final rule = entry.value;
      final value = data[key];

      if (rule.required &&
          (value == null || (value is String && value.isEmpty))) {
        errors.add('필수 필드가 누락되었습니다: $key');
        continue;
      }

      if (value != null && !rule.validate(value)) {
        errors.add('필드 검증 실패: $key (값: $value)');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 리스트 데이터 검증
  static ValidationResult validateListData(
    List<dynamic> data,
    ValidationRule itemRule,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (!itemRule.validate(item)) {
        errors.add('리스트 항목 검증 실패: 인덱스 $i (값: $item)');
      }
    }

    if (data.isEmpty) {
      warnings.add('리스트가 비어있습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 숫자 범위 검증
  static ValidationResult validateNumericRange(
    num value,
    num min,
    num max, [
    String fieldName = '값',
  ]) {
    final errors = <String>[];

    if (value < min) {
      errors.add('$fieldName이 최소값($min)보다 작습니다: $value');
    }

    if (value > max) {
      errors.add('$fieldName이 최대값($max)보다 큽니다: $value');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 문자열 검증
  static ValidationResult validateString(
    String? value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    String? pattern,
    String fieldName = '문자열',
  }) {
    final errors = <String>[];

    if (required && (value == null || value.isEmpty)) {
      errors.add('$fieldName은 필수 입력 항목입니다');
      return ValidationResult(isValid: false, errors: errors);
    }

    if (value == null || value.isEmpty) {
      return ValidationResult.valid();
    }

    if (minLength != null && value.length < minLength) {
      errors.add('$fieldName의 길이가 최소 길이($minLength)보다 짧습니다: ${value.length}');
    }

    if (maxLength != null && value.length > maxLength) {
      errors.add('$fieldName의 길이가 최대 길이($maxLength)보다 깁니다: ${value.length}');
    }

    if (pattern != null && !RegExp(pattern).hasMatch(value)) {
      errors.add('$fieldName이 지정된 패턴과 일치하지 않습니다: $pattern');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// 타입 검증기 초기화
void initializeTypeValidators() {
  TypeValidatorFactory.initializeDefaults();

  // 런타임 검증기 등록
  RuntimeTypeValidator.registerValidator(
    'ComprehensiveIngredientAnalysis',
    ComprehensiveIngredientAnalysisValidator(),
  );

  RuntimeTypeValidator.registerValidator(
    'MixingAnalysisResult',
    MixingAnalysisResultValidator(),
  );

  RuntimeTypeValidator.registerValidator(
    'EnvironmentAnalysisResult',
    EnvironmentAnalysisResultValidator(),
  );

  RuntimeTypeValidator.registerValidator(
    'AnalysisRequest',
    AnalysisRequestValidator(),
  );
}
