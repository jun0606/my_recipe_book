import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/analysis_options.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/models/analysis_metadata.dart';
import 'package:my_recipe_book/models/analysis_status.dart';
import 'package:my_recipe_book/interfaces/analysis_module.dart';

// Mock Recipe, Ingredient, EnvironmentalConditions, AnalysisOptions, AnalysisRequest, AnalysisResult, AnalysisMetadata, AnalysisStatus, AnalysisModule
// 실제 모델 정의가 필요할 경우, 해당 파일에서 가져오거나 여기에 직접 정의해야 합니다.
// 현재는 테스트를 위해 최소한의 구조만 정의합니다.

// models/recipe.dart (가정)
class Recipe {
  final String title;
  final List<String> instructions;
  final List<Ingredient> ingredients;
  final int prepTime;
  final int cookTime;
  final String category;
  final int servings;
  final bool isBaking;
  final List<Map<String, dynamic>>? fermentationSteps;
  final List<Map<String, dynamic>>? ovenSteps;

  Recipe({
    required this.title,
    required this.instructions,
    required this.ingredients,
    this.prepTime = 0,
    this.cookTime = 0,
    this.category = 'General',
    this.servings = 1,
    this.isBaking = false,
    this.fermentationSteps,
    this.ovenSteps,
  });
}

// models/ingredient.dart (가정)
class Ingredient {
  final String name;
  final double amount;
  final String unit;

  Ingredient({required this.name, required this.amount, required this.unit});
}

// models/environmental_conditions.dart (가정)
class EnvironmentalConditions {
  final double temperature;
  final double humidity;
  final double altitude;

  EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    required this.altitude,
  });
}

// models/analysis_options.dart (가정)
class AnalysisOptions {
  final List<String> enabledModules;
  final int analysisDepth;
  final bool useCache;
  final bool enableParallelProcessing;
  final int maxProcessingTime;
  final int precisionLevel;
  final bool generateRecommendations;
  final Map<String, dynamic> customParameters;

  AnalysisOptions({
    this.enabledModules = const [],
    this.analysisDepth = 1,
    this.useCache = false,
    this.enableParallelProcessing = false,
    this.maxProcessingTime = 0,
    this.precisionLevel = 1,
    this.generateRecommendations = false,
    this.customParameters = const {},
  });
}

// models/analysis_request.dart (가정)
class AnalysisRequest {
  final String id;
  final Recipe? recipe;
  final List<Ingredient> ingredients;
  final EnvironmentalConditions? environment;
  final AnalysisOptions options;
  final DateTime createdAt;
  final int priority;
  final String? userId;
  final Map<String, dynamic> metadata;
  final bool isValid; // 테스트를 위한 추가 필드

  AnalysisRequest({
    required this.id,
    this.recipe,
    required this.ingredients,
    this.environment,
    required this.options,
    required this.createdAt,
    required this.priority,
    this.userId,
    this.metadata = const {},
    this.isValid = true, // 기본적으로 유효하다고 가정
  });
}

// models/analysis_result.dart (가정)
class AnalysisResult {
  final String requestId;
  final Map<String, dynamic> results;
  final List<dynamic> recommendations; // List<Recommendation> 대신 dynamic 사용
  final AnalysisMetadata metadata;
  final double overallScore;
  final AnalysisStatus status;
  final String? errorMessage;
  final List<String> warnings;
  final DateTime completedAt;
  final bool fromCache;

  AnalysisResult({
    required this.requestId,
    required this.results,
    this.recommendations = const [],
    required this.metadata,
    this.overallScore = 0.0,
    required this.status,
    this.errorMessage,
    this.warnings = const [],
    required this.completedAt,
    this.fromCache = false,
  });

  factory AnalysisResult.partialFailure({
    required String requestId,
    required String failedModuleName,
    required String errorMessage,
    Map<String, dynamic>? partialResults,
    List<String>? warnings,
  }) {
    return AnalysisResult(
      requestId: requestId,
      results: partialResults ?? {},
      status: AnalysisStatus.partial_failure,
      errorMessage: '모듈 $failedModuleName 실행 중 오류 발생: $errorMessage',
      warnings: warnings ?? [],
      metadata: AnalysisMetadata(processingDuration: 0), // 최소한의 메타데이터
      completedAt: DateTime.now(),
    );
  }
}

// models/analysis_metadata.dart (가정)
class AnalysisMetadata {
  final int processingDuration;
  final int memoryUsage;
  final Map<String, dynamic> cacheStats;
  final List<String> logEntries;

  AnalysisMetadata({
    required this.processingDuration,
    this.memoryUsage = 0,
    this.cacheStats = const {},
    this.logEntries = const [],
  });
}



// interfaces/analysis_module.dart (가정)
abstract class AnalysisModule {
  String get name;
  String get version;
  int get priority;
  List<String> get dependencies;
  AnalysisModuleCategory get category;

  Future<Map<String, dynamic>> analyze(AnalysisRequest request);
  bool canHandle(AnalysisRequest request);
  Future<void> onInitialize();
  Future<void> onDispose();
  Map<String, dynamic> getConfigurationSchema();
  List<String> getSupportedFeatures();
  List<String> getRequiredPermissions();
  int estimateProcessingTime(AnalysisRequest request);
  int estimateMemoryUsage(AnalysisRequest request);

  // getConfiguration 헬퍼 메서드 (BaseAnalysisModule에 있을 것으로 가정)
  T? getConfiguration<T>(String key, T? defaultValue) {
    return defaultValue; // Mock에서는 항상 기본값 반환
  }
}

enum AnalysisModuleCategory {
  recipe,
  ingredient,
  environment,
  nutritional,
  cost,
  allergy,
}

abstract class BaseAnalysisModule implements AnalysisModule {
  @override
  final String name;
  @override
  final String version;
  @override
  final String description;
  @override
  final int priority;
  @override
  final List<String> dependencies;
  @override
  final AnalysisModuleCategory category;
  final Map<String, dynamic> initialConfiguration;

  BaseAnalysisModule({
    required this.name,
    required this.version,
    required this.description,
    required this.priority,
    required this.dependencies,
    required this.category,
    this.initialConfiguration = const {},
  });

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> onDispose() async {}

  @override
  Map<String, dynamic> getConfigurationSchema() => {};

  @override
  List<String> getSupportedFeatures() => [];

  @override
  List<String> getRequiredPermissions() => [];

  @override
  int estimateProcessingTime(AnalysisRequest request) => 0;

  @override
  int estimateMemoryUsage(AnalysisRequest request) => 0;

  // 실제 구현에서는 설정 관리 로직이 필요
  T? getConfiguration<T>(String key, T? defaultValue) {
    return initialConfiguration[key] as T? ?? defaultValue;
  }
}

// 예외 처리 클래스 (recipe_analysis_module.dart에서 사용)
class AnalysisProcessingException implements Exception {
  final String message;
  final String moduleName;
  final Exception? cause;

  AnalysisProcessingException(this.message, {required this.moduleName, this.cause});

  @override
  String toString() => 'AnalysisProcessingException: $message (Module: $moduleName)';
}