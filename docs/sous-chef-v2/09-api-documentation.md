# 09. API 문서

## 📋 개요

수쉐프 모드 v2.0의 외부 서비스 연동 API 문서를 제공합니다. 외부 데이터 소스, 클라우드 서비스, 분석 API 등과의 통합 방법을 설명합니다.

## 🔗 외부 서비스 연동

### 1. 레시피 데이터베이스 API

#### Recipe Database Service
```dart
// lib/api/recipe_database_service.dart
class RecipeDatabaseService {
  final HttpClient _httpClient;
  final DataEncryptionManager _encryptionManager;
  final CacheManager _cacheManager;

  RecipeDatabaseService({
    required HttpClient httpClient,
    required DataEncryptionManager encryptionManager,
    required CacheManager cacheManager,
  }) : _httpClient = httpClient,
       _encryptionManager = encryptionManager,
       _cacheManager = cacheManager;

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      // 캐시 확인
      final cacheKey = 'recipes_search_$query';
      final cached = await _cacheManager.get<List<Recipe>>(cacheKey);
      if (cached != null) return cached;

      // API 호출
      final response = await _httpClient.get('/api/recipes/search?q=$query');

      if (response.statusCode == 200) {
        final recipes = _parseRecipesResponse(response.body);

        // 캐시 저장
        await _cacheManager.set(cacheKey, recipes, ttl: Duration(minutes: 30));

        return recipes;
      } else {
        throw ApiException('Failed to search recipes: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Recipe search failed: $e');
      throw e;
    }
  }

  Future<Recipe> getRecipeDetails(String recipeId) async {
    try {
      final cacheKey = 'recipe_details_$recipeId';
      final cached = await _cacheManager.get<Recipe>(cacheKey);
      if (cached != null) return cached;

      final response = await _httpClient.get('/api/recipes/$recipeId');

      if (response.statusCode == 200) {
        final recipe = _parseRecipeResponse(response.body);
        await _cacheManager.set(cacheKey, recipe, ttl: Duration(hours: 1));
        return recipe;
      } else {
        throw ApiException('Failed to get recipe details: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Recipe details fetch failed: $e');
      throw e;
    }
  }

  Future<void> saveUserRecipe(Recipe recipe, String userId) async {
    try {
      // 민감한 데이터 암호화
      final encryptedRecipe = await _encryptionManager.encryptData(
        recipe.toString(),
        await _getUserEncryptionKey(userId)
      );

      final response = await _httpClient.post(
        '/api/user-recipes',
        body: {
          'userId': userId,
          'recipeData': encryptedRecipe,
          'timestamp': DateTime.now().toIso8601String(),
        }
      );

      if (response.statusCode != 201) {
        throw ApiException('Failed to save recipe: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Save user recipe failed: $e');
      throw e;
    }
  }

  List<Recipe> _parseRecipesResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    return (data['recipes'] as List)
      .map((recipeJson) => Recipe.fromJson(recipeJson))
      .toList();
  }

  Recipe _parseRecipeResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    return Recipe.fromJson(data['recipe']);
  }

  Future<String> _getUserEncryptionKey(String userId) async {
    // 사용자의 암호화 키 가져오기 (보안 키 관리 시스템에서)
    return 'user_encryption_key_$userId';
  }
}
```

### 2. 빵 분석 전문 API

#### Bread Analysis API Service
```dart
// lib/api/bread_analysis_service.dart
class BreadAnalysisService {
  final HttpClient _httpClient;
  final PerformanceMonitor _performanceMonitor;

  BreadAnalysisService({
    required HttpClient httpClient,
    required PerformanceMonitor performanceMonitor,
  }) : _httpClient = httpClient,
       _performanceMonitor = performanceMonitor;

  Future<BreadAnalysisResult> analyzeDoughComposition(
    Map<String, dynamic> ingredients,
    Map<String, dynamic> conditions
  ) async {
    final startTime = DateTime.now();

    try {
      final response = await _httpClient.post(
        '/api/bread/analyze-dough',
        body: {
          'ingredients': ingredients,
          'conditions': conditions,
          'timestamp': DateTime.now().toIso8601String(),
        },
        timeout: Duration(seconds: 30)
      );

      if (response.statusCode == 200) {
        final result = BreadAnalysisResult.fromJson(jsonDecode(response.body));

        // 성능 메트릭 기록
        final duration = DateTime.now().difference(startTime);
        await _performanceMonitor.recordApiCall('analyzeDoughComposition', duration);

        return result;
      } else {
        throw ApiException('Dough analysis failed: ${response.statusCode}');
      }

    } catch (e) {
      // 에러 메트릭 기록
      final duration = DateTime.now().difference(startTime);
      await _performanceMonitor.recordApiError('analyzeDoughComposition', e.toString());

      throw e;
    }
  }

  Future<FermentationPrediction> predictFermentation(
    Map<String, dynamic> doughParameters,
    Duration fermentationTime
  ) async {
    try {
      final response = await _httpClient.post(
        '/api/bread/predict-fermentation',
        body: {
          'doughParameters': doughParameters,
          'fermentationTime': fermentationTime.inMinutes,
        }
      );

      if (response.statusCode == 200) {
        return FermentationPrediction.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Fermentation prediction failed: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Fermentation prediction failed: $e');
      throw e;
    }
  }

  Future<List<BakingRecommendation>> getBakingRecommendations(
    Map<String, dynamic> doughState,
    Map<String, dynamic> ovenSettings
  ) async {
    try {
      final response = await _httpClient.post(
        '/api/bread/baking-recommendations',
        body: {
          'doughState': doughState,
          'ovenSettings': ovenSettings,
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['recommendations'] as List)
          .map((rec) => BakingRecommendation.fromJson(rec))
          .toList();
      } else {
        throw ApiException('Baking recommendations failed: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Baking recommendations failed: $e');
      throw e;
    }
  }
}
```

### 3. 영양 정보 API

#### Nutrition API Service
```dart
// lib/api/nutrition_service.dart
class NutritionService {
  final HttpClient _httpClient;
  final DataAnonymizer _dataAnonymizer;

  NutritionService({
    required HttpClient httpClient,
    required DataAnonymizer dataAnonymizer,
  }) : _httpClient = httpClient,
       _dataAnonymizer = dataAnonymizer;

  Future<NutritionInfo> getNutritionInfo(String ingredientName) async {
    try {
      // 개인정보 보호를 위해 재료명 익명화
      final anonymizedName = await _dataAnonymizer.anonymizeIngredientName(ingredientName);

      final response = await _httpClient.get(
        '/api/nutrition/info?name=$anonymizedName'
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NutritionInfo.fromJson(data['nutrition']);
      } else {
        throw ApiException('Nutrition info fetch failed: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Nutrition info fetch failed: $e');
      throw e;
    }
  }

  Future<List<NutritionInfo>> getRecipeNutrition(
    List<Map<String, dynamic>> ingredients
  ) async {
    try {
      // 전체 재료 목록 익명화
      final anonymizedIngredients = await _dataAnonymizer.anonymizeIngredientList(ingredients);

      final response = await _httpClient.post(
        '/api/nutrition/recipe-nutrition',
        body: {
          'ingredients': anonymizedIngredients,
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['nutrition'] as List)
          .map((nut) => NutritionInfo.fromJson(nut))
          .toList();
      } else {
        throw ApiException('Recipe nutrition fetch failed: ${response.statusCode}');
      }

    } catch (e) {
      Logger.error('Recipe nutrition fetch failed: $e');
      throw e;
    }
  }
}
```

## 🔧 API 클라이언트 아키텍처

### 1. HttpClient 추상화

#### Base HttpClient
```dart
// lib/api/http_client.dart
abstract class HttpClient {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
  });
  Future<HttpResponse> put(String url, {
    Map<String, String>? headers,
    dynamic body,
  });
  Future<HttpResponse> delete(String url, {Map<String, String>? headers});
}

class HttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  const HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });
}
```

#### Dio HttpClient 구현
```dart
// lib/api/dio_http_client.dart
class DioHttpClient implements HttpClient {
  final Dio _dio;
  final ApiConfig _config;

  DioHttpClient({
    required Dio dio,
    required ApiConfig config,
  }) : _dio = dio,
       _config = config {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = _config.baseUrl;
    _dio.options.connectTimeout = _config.connectTimeout;
    _dio.options.receiveTimeout = _config.receiveTimeout;

    // 인터셉터 설정
    _dio.interceptors.add(LogInterceptor());
    _dio.interceptors.add(AuthInterceptor(_config.apiKey));
    _dio.interceptors.add(RetryInterceptor());
  }

  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await _dio.get(url, options: Options(headers: headers));
    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data.toString(),
      headers: Map<String, String>.from(response.headers.map),
    );
  }

  @override
  Future<HttpResponse> post(String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
  }) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(headers: headers),
    );

    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data.toString(),
      headers: Map<String, String>.from(response.headers.map),
    );
  }

  @override
  Future<HttpResponse> put(String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final response = await _dio.put(url, data: body, options: Options(headers: headers));
    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data.toString(),
      headers: Map<String, String>.from(response.headers.map),
    );
  }

  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    final response = await _dio.delete(url, options: Options(headers: headers));
    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data?.toString() ?? '',
      headers: Map<String, String>.from(response.headers.map),
    );
  }
}
```

### 2. API 설정 관리

#### API Configuration
```dart
// lib/api/api_config.dart
class ApiConfig {
  final String baseUrl;
  final String apiKey;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxRetries;
  final Map<String, String> defaultHeaders;

  const ApiConfig({
    required this.baseUrl,
    required this.apiKey,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.defaultHeaders = const {},
  });

  static ApiConfig get development => const ApiConfig(
    baseUrl: 'https://api-dev.souschef.com',
    apiKey: 'dev_api_key',
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 45),
  );

  static ApiConfig get production => const ApiConfig(
    baseUrl: 'https://api.souschef.com',
    apiKey: 'prod_api_key',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 30),
    maxRetries: 5,
  );

  static ApiConfig getCurrent() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'development');
    return flavor == 'production' ? production : development;
  }
}
```

## 📊 API 모니터링 및 분석

### 1. API 성능 모니터링

#### ApiPerformanceMonitor
```dart
// lib/api/api_performance_monitor.dart
class ApiPerformanceMonitor {
  final Map<String, ApiMetrics> _metrics = {};

  void recordApiCall(String endpoint, Duration duration) {
    _metrics.putIfAbsent(endpoint, () => ApiMetrics());
    final metric = _metrics[endpoint]!;

    metric.totalCalls++;
    metric.totalResponseTime += duration.inMilliseconds;
    metric.lastCallTime = DateTime.now();

    if (metric.minResponseTime == 0 || duration.inMilliseconds < metric.minResponseTime) {
      metric.minResponseTime = duration.inMilliseconds;
    }

    if (duration.inMilliseconds > metric.maxResponseTime) {
      metric.maxResponseTime = duration.inMilliseconds;
    }
  }

  void recordApiError(String endpoint, String error) {
    _metrics.putIfAbsent(endpoint, () => ApiMetrics());
    final metric = _metrics[endpoint]!;

    metric.errorCount++;
    metric.lastError = error;
    metric.lastErrorTime = DateTime.now();
  }

  ApiMetrics? getMetrics(String endpoint) => _metrics[endpoint];

  Map<String, ApiMetrics> getAllMetrics() => Map.from(_metrics);

  List<String> getSlowEndpoints({int thresholdMs = 5000}) {
    return _metrics.entries
      .where((entry) => entry.value.averageResponseTime > thresholdMs)
      .map((entry) => entry.key)
      .toList();
  }

  List<String> getHighErrorRateEndpoints({double threshold = 0.1}) {
    return _metrics.entries
      .where((entry) {
        final metric = entry.value;
        return metric.totalCalls > 0 &&
               (metric.errorCount / metric.totalCalls) > threshold;
      })
      .map((entry) => entry.key)
      .toList();
  }
}

class ApiMetrics {
  int totalCalls = 0;
  int totalResponseTime = 0;
  int minResponseTime = 0;
  int maxResponseTime = 0;
  int errorCount = 0;
  DateTime? lastCallTime;
  DateTime? lastErrorTime;
  String? lastError;

  double get averageResponseTime =>
    totalCalls > 0 ? totalResponseTime / totalCalls : 0.0;

  double get errorRate =>
    totalCalls > 0 ? errorCount / totalCalls : 0.0;
}
```

### 2. API 사용량 분석

#### ApiUsageAnalyzer
```dart
// lib/api/api_usage_analyzer.dart
class ApiUsageAnalyzer {
  final ApiPerformanceMonitor _monitor;
  final AlertManager _alertManager;

  ApiUsageAnalyzer({
    required ApiPerformanceMonitor monitor,
    required AlertManager alertManager,
  }) : _monitor = monitor,
       _alertManager = alertManager;

  Future<ApiUsageReport> generateUsageReport(DateTime startDate, DateTime endDate) async {
    final allMetrics = _monitor.getAllMetrics();

    final totalCalls = allMetrics.values.fold<int>(
      0,
      (sum, metric) => sum + metric.totalCalls
    );

    final totalErrors = allMetrics.values.fold<int>(
      0,
      (sum, metric) => sum + metric.errorCount
    );

    final endpoints = allMetrics.keys.toList();
    final slowEndpoints = _monitor.getSlowEndpoints();
    final highErrorEndpoints = _monitor.getHighErrorRateEndpoints();

    return ApiUsageReport(
      period: DateTimeRange(start: startDate, end: endDate),
      totalCalls: totalCalls,
      totalErrors: totalErrors,
      endpointsUsed: endpoints.length,
      slowEndpoints: slowEndpoints,
      highErrorRateEndpoints: highErrorEndpoints,
      mostUsedEndpoint: _findMostUsedEndpoint(allMetrics),
      averageResponseTime: _calculateAverageResponseTime(allMetrics),
    );
  }

  String? _findMostUsedEndpoint(Map<String, ApiMetrics> metrics) {
    if (metrics.isEmpty) return null;

    return metrics.entries
      .reduce((a, b) => a.value.totalCalls > b.value.totalCalls ? a : b)
      .key;
  }

  double _calculateAverageResponseTime(Map<String, ApiMetrics> metrics) {
    if (metrics.isEmpty) return 0.0;

    final totalResponseTime = metrics.values.fold<int>(
      0,
      (sum, metric) => sum + metric.totalResponseTime
    );

    final totalCalls = metrics.values.fold<int>(
      0,
      (sum, metric) => sum + metric.totalCalls
    );

    return totalCalls > 0 ? totalResponseTime / totalCalls : 0.0;
  }

  Future<void> checkUsageThresholds() async {
    final slowEndpoints = _monitor.getSlowEndpoints();
    final highErrorEndpoints = _monitor.getHighErrorRateEndpoints();

    // 알림 발송
    if (slowEndpoints.isNotEmpty) {
      await _alertManager.sendAlert(Alert(
        type: AlertType.performance,
        severity: Severity.medium,
        message: 'Slow API endpoints detected: ${slowEndpoints.join(', ')}',
        metric: 'api_response_time',
        value: slowEndpoints.length,
        threshold: 0,
      ));
    }

    if (highErrorEndpoints.isNotEmpty) {
      await _alertManager.sendAlert(Alert(
        type: AlertType.error,
        severity: Severity.high,
        message: 'High error rate endpoints: ${highErrorEndpoints.join(', ')}',
        metric: 'api_error_rate',
        value: highErrorEndpoints.length,
        threshold: 0,
      ));
    }
  }
}

class ApiUsageReport {
  final DateTimeRange period;
  final int totalCalls;
  final int totalErrors;
  final int endpointsUsed;
  final List<String> slowEndpoints;
  final List<String> highErrorRateEndpoints;
  final String? mostUsedEndpoint;
  final double averageResponseTime;

  const ApiUsageReport({
    required this.period,
    required this.totalCalls,
    required this.totalErrors,
    required this.endpointsUsed,
    required this.slowEndpoints,
    required this.highErrorRateEndpoints,
    this.mostUsedEndpoint,
    required this.averageResponseTime,
  });

  double get errorRate => totalCalls > 0 ? totalErrors / totalCalls : 0.0;

  void printSummary() {
    print('API Usage Report (${period.start} - ${period.end})');
    print('- Total Calls: $totalCalls');
    print('- Total Errors: $totalErrors');
    print('- Error Rate: ${(errorRate * 100).toStringAsFixed(1)}%');
    print('- Endpoints Used: $endpointsUsed');
    print('- Most Used Endpoint: $mostUsedEndpoint');
    print('- Average Response Time: ${averageResponseTime.toStringAsFixed(0)}ms');
    print('- Slow Endpoints: ${slowEndpoints.length}');
    print('- High Error Rate Endpoints: ${highErrorRateEndpoints.length}');
  }
}
```

## 🎯 결론

### API 연동의 이점

✅ **데이터 풍부성** - 외부 데이터베이스 및 분석 API 활용
✅ **실시간 분석** - 전문 빵 분석 API 연동
✅ **영양 정보** - 정확한 영양 데이터 제공
✅ **확장성** - 새로운 API 쉽게 추가 가능
✅ **성능 모니터링** - API 호출 성능 실시간 모니터링

### 구현 우선순위

1. **코어 HTTP 클라이언트** (DioHttpClient)
2. **레시피 데이터베이스 API** (RecipeDatabaseService)
3. **빵 분석 전문 API** (BreadAnalysisService)
4. **API 성능 모니터링** (ApiPerformanceMonitor)
5. **사용량 분석** (ApiUsageAnalyzer)

이 API 문서를 통해 수쉐프 모드 v2.0은 외부 서비스와의 완벽한 통합을 달성할 수 있습니다.
