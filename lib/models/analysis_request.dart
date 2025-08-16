import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 분석 요청을 나타내는 모델 클래스
/// 
/// 레시피, 재료, 환경 조건 등의 정보를 포함하여
/// 분석 파이프라인에 전달되는 요청 데이터를 정의합니다.
class AnalysisRequest {
  /// 요청의 고유 식별자
  final String id;
  
  /// 분석할 레시피
  final Recipe recipe;
  
  /// 사용할 재료 목록
  final List<Ingredient> ingredients;
  
  /// 환경 조건 (온도, 습도 등)
  final EnvironmentalConditions environment;
  
  /// 분석 옵션 및 설정
  final AnalysisOptions options;
  
  /// 요청 생성 시간
  final DateTime createdAt;
  
  /// 요청 우선순위 (1: 높음, 2: 보통, 3: 낮음)
  final int priority;
  
  /// 요청자 정보 (선택적)
  final String? userId;
  
  /// 추가 메타데이터
  final Map<String, dynamic> metadata;
  
  /// 재시도 횟수 (내부 사용)
  final int retryCount;

  const AnalysisRequest({
    required this.id,
    required this.recipe,
    required this.ingredients,
    required this.environment,
    required this.options,
    required this.createdAt,
    this.priority = 2,
    this.userId,
    this.metadata = const {},
    this.retryCount = 0,
  });

  /// 팩토리 생성자: 기본값으로 요청 생성
  factory AnalysisRequest.create({
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required EnvironmentalConditions environment,
    AnalysisOptions? options,
    int priority = 2,
    String? userId,
    Map<String, dynamic> metadata = const {},
  }) {
    return AnalysisRequest(
      id: _generateId(),
      recipe: recipe,
      ingredients: ingredients,
      environment: environment,
      options: options ?? AnalysisOptions.defaultOptions(),
      createdAt: DateTime.now(),
      priority: priority,
      userId: userId,
      metadata: metadata,
    );
  }

  /// 고유 ID 생성
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'analysis_${timestamp}_$random';
  }

  /// 요청 복사본 생성 (일부 필드 변경 가능)
  AnalysisRequest copyWith({
    String? id,
    Recipe? recipe,
    List<Ingredient>? ingredients,
    EnvironmentalConditions? environment,
    AnalysisOptions? options,
    DateTime? createdAt,
    int? priority,
    String? userId,
    Map<String, dynamic>? metadata,
    int? retryCount,
    Map<String, dynamic>? results,
  }) {
    return AnalysisRequest(
      id: id ?? this.id,
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      environment: environment ?? this.environment,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe.toJson(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'environment': environment.toJson(),
      'options': options.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'priority': priority,
      'userId': userId,
      'metadata': metadata,
      'retryCount': retryCount,
    };
  }

  /// JSON에서 역직렬화
  factory AnalysisRequest.fromJson(Map<String, dynamic> json) {
    return AnalysisRequest(
      id: json['id'] as String,
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      environment: EnvironmentalConditions.fromJson(
          json['environment'] as Map<String, dynamic>),
      options: AnalysisOptions.fromJson(
          json['options'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: json['priority'] as int? ?? 2,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// 요청 유효성 검증
  bool isValid() {
    // 기본 필드 검증
    if (id.isEmpty || recipe.title.isEmpty || ingredients.isEmpty) {
      return false;
    }
    
    // 우선순위 범위 검증
    if (priority < 1 || priority > 3) {
      return false;
    }
    
    // 재료 유효성 검증
    for (final ingredient in ingredients) {
      if (ingredient.name.isEmpty || ingredient.amount <= 0) {
        return false;
      }
    }
    
    // 환경 조건 검증
    if (environment.temperature < -50 || environment.temperature > 100) {
      return false;
    }
    
    if (environment.humidity < 0 || environment.humidity > 100) {
      return false;
    }
    
    // 분석 옵션 검증
    if (!options.isValid()) {
      return false;
    }
    
    return true;
  }

  /// 요청 크기 계산 (메모리 사용량 추정, 바이트 단위)
  int estimateSize() {
    int size = 0;
    
    // 기본 필드 크기
    size += id.length * 2; // UTF-16
    size += recipe.title.length * 2;
    size += recipe.instructions.join().length * 2;
    size += ingredients.length * 100; // 재료당 평균 100바이트
    size += 200; // 환경 조건 및 기타 필드
    size += options.estimateMemoryUsage() * 1024 * 1024; // MB를 바이트로 변환
    
    return size;
  }

  /// 캐시 키 생성
  String generateCacheKey() {
    final components = [
      recipe.id?.toString() ?? recipe.title,
      ingredients.map((i) => '${i.name}:${i.amount}:${i.unit}').join(','),
      environment.hashCode.toString(),
      options.enabledModules.join(','),
      options.analysisDepth.toString(),
      options.precisionLevel.toString(),
    ];
    
    final input = components.join('|');
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// 요청 요약 정보 생성
  String getSummary() {
    return 'Analysis Request: ${recipe.title} '
           '(${ingredients.length} ingredients, '
           'priority: $priority, '
           'modules: ${options.enabledModules.length}, '
           'created: ${createdAt.toLocal()})';
  }

  /// 요청 처리 예상 시간 계산 (초)
  int estimateProcessingTime() {
    return options.estimateProcessingTime();
  }

  /// 요청 처리 예상 메모리 사용량 계산 (MB)
  int estimateMemoryUsage() {
    int baseMemory = options.estimateMemoryUsage();
    
    // 재료 수에 따른 추가 메모리
    baseMemory += (ingredients.length / 10).ceil() * 2;
    
    // 레시피 복잡도에 따른 추가 메모리
    baseMemory += (recipe.instructions.length / 5).ceil() * 1;
    
    return baseMemory;
  }

  /// 요청 우선순위 문자열 반환
  String get priorityString {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  /// 요청 생성 후 경과 시간 (초)
  int get ageInSeconds {
    return DateTime.now().difference(createdAt).inSeconds;
  }

  /// 요청이 만료되었는지 확인 (기본 30분)
  bool isExpired({int maxAgeMinutes = 30}) {
    final maxAge = Duration(minutes: maxAgeMinutes);
    return DateTime.now().difference(createdAt) > maxAge;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AnalysisRequest &&
           other.id == id &&
           other.recipe == recipe &&
           other.ingredients.length == ingredients.length &&
           other.environment == environment &&
           other.options == options;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      recipe.hashCode,
      ingredients.length,
      environment.hashCode,
      options.hashCode,
    );
  }

  @override
  String toString() {
    return 'AnalysisRequest('
           'id: $id, '
           'recipe: ${recipe.title}, '
           'ingredients: ${ingredients.length}, '
           'priority: $priorityString, '
           'modules: ${options.enabledModules.length}, '
           'createdAt: $createdAt'
           ')';
  }
}

/// 분석 요청 빌더 클래스
/// 
/// 복잡한 분석 요청을 단계별로 구성할 수 있도록 도와주는 빌더 패턴 구현
class AnalysisRequestBuilder {
  String? _id;
  Recipe? _recipe;
  List<Ingredient>? _ingredients;
  EnvironmentalConditions? _environment;
  AnalysisOptions? _options;
  DateTime? _createdAt;
  int _priority = 2;
  String? _userId;
  Map<String, dynamic> _metadata = {};

  AnalysisRequestBuilder();

  /// ID 설정
  AnalysisRequestBuilder id(String id) {
    _id = id;
    return this;
  }

  /// 레시피 설정
  AnalysisRequestBuilder recipe(Recipe recipe) {
    _recipe = recipe;
    return this;
  }

  /// 재료 목록 설정
  AnalysisRequestBuilder ingredients(List<Ingredient> ingredients) {
    _ingredients = ingredients;
    return this;
  }

  /// 환경 조건 설정
  AnalysisRequestBuilder environment(EnvironmentalConditions environment) {
    _environment = environment;
    return this;
  }

  /// 분석 옵션 설정
  AnalysisRequestBuilder options(AnalysisOptions options) {
    _options = options;
    return this;
  }

  /// 생성 시간 설정
  AnalysisRequestBuilder createdAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// 우선순위 설정
  AnalysisRequestBuilder priority(int priority) {
    if (priority >= 1 && priority <= 3) {
      _priority = priority;
    }
    return this;
  }

  /// 사용자 ID 설정
  AnalysisRequestBuilder userId(String userId) {
    _userId = userId;
    return this;
  }

  /// 메타데이터 설정
  AnalysisRequestBuilder metadata(Map<String, dynamic> metadata) {
    _metadata = Map.from(metadata);
    return this;
  }

  /// 메타데이터 항목 추가
  AnalysisRequestBuilder addMetadata(String key, dynamic value) {
    _metadata[key] = value;
    return this;
  }

  /// 빠른 분석 설정
  AnalysisRequestBuilder quickAnalysis() {
    _options = AnalysisOptions.quickAnalysis();
    _priority = 1;
    return this;
  }

  /// 상세 분석 설정
  AnalysisRequestBuilder detailedAnalysis() {
    _options = AnalysisOptions.detailedAnalysis();
    _priority = 2;
    return this;
  }

  /// 전문가 분석 설정
  AnalysisRequestBuilder expertAnalysis() {
    _options = AnalysisOptions.expertAnalysis();
    _priority = 1;
    return this;
  }

  /// 빌더로 요청 생성
  AnalysisRequest build() {
    if (_recipe == null || _ingredients == null || _environment == null) {
      throw ArgumentError('Recipe, ingredients, and environment are required');
    }

    return AnalysisRequest(
      id: _id ?? AnalysisRequest._generateId(),
      recipe: _recipe!,
      ingredients: _ingredients!,
      environment: _environment!,
      options: _options ?? AnalysisOptions.defaultOptions(),
      createdAt: _createdAt ?? DateTime.now(),
      priority: _priority,
      userId: _userId,
      metadata: _metadata,
    );
  }

  /// 빌더 상태 검증
  bool canBuild() {
    return _recipe != null && _ingredients != null && _environment != null;
  }

  /// 빌더 상태 리셋
  AnalysisRequestBuilder reset() {
    _id = null;
    _recipe = null;
    _ingredients = null;
    _environment = null;
    _options = null;
    _createdAt = null;
    _priority = 2;
    _userId = null;
    _metadata = {};
    return this;
  }
}

/// 분석 요청 유효성 검증 결과
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 성공적인 검증 결과
  static const ValidationResult success = ValidationResult(isValid: true);

  /// 실패한 검증 결과 생성
  factory ValidationResult.failure(List<String> errors, [List<String>? warnings]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings ?? [],
    );
  }

  /// 경고가 있는 성공 결과 생성
  factory ValidationResult.successWithWarnings(List<String> warnings) {
    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return warnings.isEmpty 
          ? 'Validation: SUCCESS'
          : 'Validation: SUCCESS with ${warnings.length} warnings';
    } else {
      return 'Validation: FAILED with ${errors.length} errors';
    }
  }
}