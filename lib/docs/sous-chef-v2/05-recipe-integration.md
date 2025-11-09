# 05. 레시피 연동 방식

## 📋 개요

수쉐프 모드 v2.0의 레시피 연동 방식은 메인 앱의 레시피 시스템과 수쉐프 모듈 간의 완벽한 통합을 위한 데이터 흐름과 변환 메커니즘을 정의합니다.

## 🎯 설계 목표

### 1. 완벽한 데이터 호환성
```dart
// 메인 앱 ↔ 수쉐프 모드 간 완벽한 데이터 변환
Recipe (Main) ↔ UnifiedRecipe (SousChef)
```

### 2. 실시간 동기화
```dart
// 레시피 변경 시 즉시 반영
User edits recipe → All modules update automatically
```

### 3. 양방향 데이터 흐름
```dart
// 양방향 피드백 가능
Recipe → Analysis → Recipe Modifications
```

## 🏗️ 레시피 연동 아키텍처

### 1. 레시피 변환 시스템

#### RecipeConverter - 양방향 변환기
```dart
// lib/utils/recipe_converter.dart
class RecipeConverter {
  // 메인 앱 Recipe → 수쉐프 UnifiedRecipe 변환
  static Future<UnifiedRecipe> toUnifiedRecipe(dynamic recipe) async {
    if (recipe is Recipe) {
      return await _convertFromRecipe(recipe);
    } else if (recipe is Map<String, dynamic>) {
      return await _convertFromMap(recipe);
    } else {
      throw RecipeConversionError('Unsupported recipe type: ${recipe.runtimeType}');
    }
  }

  // 수쉐프 UnifiedRecipe → 메인 앱 Recipe 변환
  static Future<Recipe> toRecipe(UnifiedRecipe unifiedRecipe) async {
    return await _convertToRecipe(unifiedRecipe);
  }

  // 분석 결과로 레시피 수정
  static Future<UnifiedRecipe> applyAnalysisResult(
    UnifiedRecipe recipe,
    AnalysisResult analysis
  ) async {
    final modifier = RecipeModifier();
    return await modifier.applyAnalysis(recipe, analysis);
  }

  // 모듈별 요구사항 적용
  static Future<UnifiedRecipe> applyModuleRequirements(
    UnifiedRecipe recipe,
    String moduleId,
    Map<String, dynamic> requirements
  ) async {
    final modifier = RecipeModifier();
    return await modifier.applyModuleRequirements(recipe, moduleId, requirements);
  }
}
```

#### RecipeAdapter - 레시피 어댑터
```dart
// lib/adapters/recipe_adapter.dart
class RecipeAdapter {
  final RecipeConverter converter;
  final SousChefEventBus eventBus;

  RecipeAdapter({
    required this.converter,
    required this.eventBus,
  }) {
    _setupEventSubscriptions();
  }

  void _setupEventSubscriptions() {
    // 메인 앱 레시피 변경 감지
    eventBus.subscribe('main_app:recipe_updated').listen(_handleMainAppRecipeUpdate);

    // 수쉐프 모드 레시피 변경 감지
    eventBus.subscribe('sous_chef:recipe_modified').listen(_handleSousChefRecipeUpdate);

    // 모듈 분석 결과 감지
    eventBus.subscribe('module:analysis_complete').listen(_handleAnalysisResult);
  }

  Future<void> _handleMainAppRecipeUpdate(dynamic event) async {
    try {
      final recipe = event['recipe'];
      final unifiedRecipe = await converter.toUnifiedRecipe(recipe);

      // 수쉐프 모드에 업데이트 알림
      eventBus.publish('sous_chef:recipe_sync', {
        'unifiedRecipe': unifiedRecipe,
        'source': 'main_app',
        'timestamp': DateTime.now(),
      });

      // 현재 활성 모듈에 직접 알림
      final currentModule = ModuleManager.getCurrentModule();
      if (currentModule != null) {
        currentModule.onRecipeUpdated(unifiedRecipe);
      }

    } catch (e) {
      eventBus.publish('recipe_sync:error', {
        'error': e.toString(),
        'source': 'main_app',
      });
    }
  }

  Future<void> _handleSousChefRecipeUpdate(dynamic event) async {
    try {
      final unifiedRecipe = event['unifiedRecipe'];
      final recipe = await converter.toRecipe(unifiedRecipe);

      // 메인 앱에 업데이트 알림
      eventBus.publish('main_app:recipe_sync', {
        'recipe': recipe,
        'source': 'sous_chef',
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      eventBus.publish('recipe_sync:error', {
        'error': e.toString(),
        'source': 'sous_chef',
      });
    }
  }

  Future<void> _handleAnalysisResult(dynamic event) async {
    try {
      final moduleId = event['moduleId'];
      final analysis = event['analysis'];
      final originalRecipe = event['recipe'];

      // 분석 결과를 레시피에 적용
      final modifiedRecipe = await converter.applyAnalysisResult(
        originalRecipe,
        analysis
      );

      // 수정된 레시피를 메인 앱에 전송
      final recipe = await converter.toRecipe(modifiedRecipe);
      eventBus.publish('main_app:recipe_analysis_result', {
        'recipe': recipe,
        'moduleId': moduleId,
        'analysis': analysis,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      eventBus.publish('recipe_analysis:error', {
        'error': e.toString(),
        'moduleId': event['moduleId'],
      });
    }
  }
}
```

### 2. 모듈별 데이터 추출

#### ModuleDataExtractor - 모듈별 데이터 추출기
```dart
// lib/extractors/module_data_extractor.dart
class ModuleDataExtractor {
  static const Map<String, ModuleDataConfig> _extractionConfigs = {
    'bread': ModuleDataConfig(
      ingredientTypes: ['flour', 'yeast', 'water', 'salt', 'sugar', 'butter'],
      processTypes: ['mixing', 'kneading', 'fermentation', 'baking'],
      equipmentTypes: ['stand_mixer', 'oven', 'proofer'],
      hydrationRange: {'min': 0.5, 'max': 0.9},
      temperatureRange: {'min': 15, 'max': 30},
    ),
    'cake': ModuleDataConfig(
      ingredientTypes: ['flour', 'sugar', 'eggs', 'butter', 'baking_powder'],
      processTypes: ['creaming', 'mixing', 'baking'],
      equipmentTypes: ['stand_mixer', 'oven', 'whisk'],
      hydrationRange: {'min': 0.7, 'max': 1.2},
      temperatureRange: {'min': 160, 'max': 200},
    ),
    'cookie': ModuleDataConfig(
      ingredientTypes: ['flour', 'butter', 'sugar', 'eggs', 'baking_soda'],
      processTypes: ['creaming', 'mixing', 'chilling', 'baking'],
      equipmentTypes: ['stand_mixer', 'oven', 'refrigerator'],
      hydrationRange: {'min': 0.4, 'max': 0.6},
      temperatureRange: {'min': 160, 'max': 190},
    ),
    'dessert': ModuleDataConfig(
      ingredientTypes: ['cream', 'sugar', 'chocolate', 'fruit', 'gelatin'],
      processTypes: ['whipping', 'chilling', 'freezing', 'melting'],
      equipmentTypes: ['whisk', 'refrigerator', 'freezer', 'saucepan'],
      hydrationRange: {'min': 0.3, 'max': 1.5},
      temperatureRange: {'min': -20, 'max': 100},
    ),
  };

  static Future<Map<String, dynamic>> extractModuleData(
    UnifiedRecipe recipe,
    String moduleId
  ) async {
    final config = _extractionConfigs[moduleId];
    if (config == null) {
      throw ModuleNotSupportedError(moduleId);
    }

    return {
      'ingredients': await _extractRelevantIngredients(recipe, config),
      'processes': await _extractRelevantProcesses(recipe, config),
      'equipment': await _extractRelevantEquipment(recipe, config),
      'requirements': await _calculateModuleRequirements(recipe, config),
      'analysisHints': await _generateAnalysisHints(recipe, config),
    };
  }

  static Future<List<UnifiedIngredient>> _extractRelevantIngredients(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    return recipe.ingredients.where((ingredient) {
      return config.ingredientTypes.any((type) =>
        ingredient.properties['type'] == type ||
        ingredient.name.toLowerCase().contains(type)
      );
    }).toList();
  }

  static Future<List<UnifiedProcess>> _extractRelevantProcesses(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    return recipe.processes.where((process) {
      return config.processTypes.contains(process.type);
    }).toList();
  }

  static Future<Map<String, dynamic>> _extractRelevantEquipment(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    final equipment = recipe.equipment.toMap();
    return {
      'primary': equipment['primary'] != null &&
                 config.equipmentTypes.contains(equipment['primary']['type'])
        ? equipment['primary'] : null,
      'secondary': equipment['secondary']?.where((eq) =>
        config.equipmentTypes.contains(eq['type'])
      ).toList() ?? [],
    };
  }

  static Future<Map<String, dynamic>> _calculateModuleRequirements(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    final hydration = await _calculateHydration(recipe);
    final temperature = await _calculateTemperature(recipe);

    return {
      'optimalHydration': _clampHydration(hydration, config),
      'optimalTemperature': _clampTemperature(temperature, config),
      'equipmentRecommendations': await _getEquipmentRecommendations(recipe, config),
      'processAdjustments': await _getProcessAdjustments(recipe, config),
    };
  }

  static Future<double> _calculateHydration(UnifiedRecipe recipe) async {
    // 수분 함량 계산 로직
    final liquidWeight = recipe.ingredients
      .where((ing) => ing.properties['type'] == 'water' ||
                      ing.properties['type'] == 'milk')
      .fold(0.0, (sum, ing) => sum + ing.amount);

    final flourWeight = recipe.ingredients
      .where((ing) => ing.properties['type'] == 'flour')
      .fold(0.0, (sum, ing) => sum + ing.amount);

    return flourWeight > 0 ? liquidWeight / flourWeight : 0.0;
  }

  static Future<double> _calculateTemperature(UnifiedRecipe recipe) async {
    // 최적 온도 계산 로직
    final bakingProcesses = recipe.processes
      .where((proc) => proc.type == 'baking');

    if (bakingProcesses.isEmpty) return 180.0; // 기본값

    final avgTemp = bakingProcesses
      .map((proc) => proc.parameters['temperature'] as double? ?? 180.0)
      .reduce((a, b) => a + b) / bakingProcesses.length;

    return avgTemp;
  }

  static double _clampHydration(double hydration, ModuleDataConfig config) {
    final range = config.hydrationRange;
    return hydration.clamp(range['min']!, range['max']!);
  }

  static double _clampTemperature(double temperature, ModuleDataConfig config) {
    final range = config.temperatureRange;
    return temperature.clamp(range['min']!, range['max']!);
  }

  static Future<List<String>> _getEquipmentRecommendations(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    final recommendations = <String>[];

    if (recipe.processes.any((proc) => proc.type == 'mixing' && proc.duration > 10)) {
      recommendations.add('stand_mixer');
    }

    if (recipe.processes.any((proc) => proc.type == 'fermentation')) {
      recommendations.add('proofer');
    }

    return recommendations.where((rec) =>
      config.equipmentTypes.contains(rec)
    ).toList();
  }

  static Future<Map<String, dynamic>> _getProcessAdjustments(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    return {
      'mixing': {
        'recommendedSpeed': 'medium',
        'temperatureControl': true,
        'restingTime': 15, // minutes
      },
      'fermentation': {
        'optimalHumidity': 75.0,
        'temperatureRange': {'min': 24.0, 'max': 26.0},
        'timeMultiplier': 1.0,
      },
      'baking': {
        'preheatTime': 20, // minutes
        'steamInjection': true,
        'coolingTime': 30, // minutes
      },
    };
  }

  static Future<List<String>> _generateAnalysisHints(
    UnifiedRecipe recipe,
    ModuleDataConfig config
  ) async {
    final hints = <String>[];

    final hydration = await _calculateHydration(recipe);
    if (hydration < config.hydrationRange['min']!) {
      hints.add('수분량이 낮을 수 있습니다. 조정 필요');
    } else if (hydration > config.hydrationRange['max']!) {
      hints.add('수분량이 높을 수 있습니다. 조정 필요');
    }

    final temperature = await _calculateTemperature(recipe);
    if (temperature < config.temperatureRange['min']!) {
      hints.add('온도가 낮을 수 있습니다. 조정 필요');
    } else if (temperature > config.temperatureRange['max']!) {
      hints.add('온도가 높을 수 있습니다. 조정 필요');
    }

    if (recipe.processes.any((proc) => proc.duration > 60)) {
      hints.add('긴 공정 시간이 감지되었습니다. 모니터링 필요');
    }

    return hints;
  }
}
```

### 3. 실시간 동기화 프로토콜

#### RecipeSyncProtocol - 레시피 동기화 프로토콜
```dart
// lib/protocols/recipe_sync_protocol.dart
class RecipeSyncProtocol {
  final RecipeAdapter adapter;
  final ModuleDataExtractor extractor;
  final SousChefEventBus eventBus;

  RecipeSyncProtocol({
    required this.adapter,
    required this.extractor,
    required this.eventBus,
  });

  // 메인 앱에서 수쉐프로 레시피 동기화
  Future<void> syncFromMainApp(dynamic recipe) async {
    try {
      // 1. 레시피 변환
      final unifiedRecipe = await adapter.converter.toUnifiedRecipe(recipe);

      // 2. 각 모듈에 필요한 데이터 추출
      final moduleData = await _extractAllModuleData(unifiedRecipe);

      // 3. 동기화 이벤트 발행
      eventBus.publish('recipe:sync_started', {
        'recipeId': unifiedRecipe.id,
        'timestamp': DateTime.now(),
      });

      // 4. 각 모듈에 데이터 전송
      await _broadcastToActiveModules(unifiedRecipe, moduleData);

      // 5. 동기화 완료 이벤트
      eventBus.publish('recipe:sync_completed', {
        'recipeId': unifiedRecipe.id,
        'moduleCount': moduleData.length,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      // 6. 에러 처리
      eventBus.publish('recipe:sync_error', {
        'error': e.toString(),
        'timestamp': DateTime.now(),
      });
    }
  }

  // 수쉐프에서 메인 앱으로 변경사항 동기화
  Future<void> syncToMainApp(UnifiedRecipe recipe, String sourceModule) async {
    try {
      // 1. 메인 앱 포맷으로 변환
      final mainRecipe = await adapter.converter.toRecipe(recipe);

      // 2. 변경사항 분석
      final changes = await _analyzeRecipeChanges(recipe, sourceModule);

      // 3. 메인 앱에 전송
      eventBus.publish('main_app:recipe_update', {
        'recipe': mainRecipe,
        'changes': changes,
        'sourceModule': sourceModule,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      eventBus.publish('recipe:sync_to_main_error', {
        'error': e.toString(),
        'sourceModule': sourceModule,
      });
    }
  }

  Future<Map<String, Map<String, dynamic>>> _extractAllModuleData(
    UnifiedRecipe recipe
  ) async {
    final moduleData = <String, Map<String, dynamic>>{};

    for (final moduleId in ModuleManager.getAvailableModules()) {
      try {
        moduleData[moduleId] = await extractor.extractModuleData(recipe, moduleId);
      } catch (e) {
        // 모듈별 추출 실패는 다른 모듈에 영향 주지 않음
        Logger.warning('Failed to extract data for module $moduleId: $e');
      }
    }

    return moduleData;
  }

  Future<void> _broadcastToActiveModules(
    UnifiedRecipe recipe,
    Map<String, Map<String, dynamic>> moduleData
  ) async {
    final activeModules = ModuleManager.getAvailableModules()
      .where((id) => ModuleManager.getModuleState(id) == ModuleState.active)
      .toList();

    for (final moduleId in activeModules) {
      final data = moduleData[moduleId];
      if (data != null) {
        eventBus.publish('module:$moduleId:recipe_data', {
          'recipe': recipe,
          'moduleData': data,
          'timestamp': DateTime.now(),
        });
      }
    }
  }

  Future<Map<String, dynamic>> _analyzeRecipeChanges(
    UnifiedRecipe recipe,
    String sourceModule
  ) async {
    return {
      'modifiedBy': sourceModule,
      'ingredients': await _getIngredientChanges(recipe),
      'processes': await _getProcessChanges(recipe),
      'equipment': await _getEquipmentChanges(recipe),
      'metadata': await _getMetadataChanges(recipe),
    };
  }

  Future<List<Map<String, dynamic>>> _getIngredientChanges(UnifiedRecipe recipe) async {
    // 재료 변경사항 분석 로직
    return [];
  }

  Future<List<Map<String, dynamic>>> _getProcessChanges(UnifiedRecipe recipe) async {
    // 공정 변경사항 분석 로직
    return [];
  }

  Future<Map<String, dynamic>> _getEquipmentChanges(UnifiedRecipe recipe) async {
    // 장비 변경사항 분석 로직
    return {};
  }

  Future<Map<String, dynamic>> _getMetadataChanges(UnifiedRecipe recipe) async {
    // 메타데이터 변경사항 분석 로직
    return {};
  }
}
```

## 🔄 데이터 변환 파이프라인

### 1. 양방향 변환 파이프라인
```dart
// lib/pipelines/recipe_conversion_pipeline.dart
class RecipeConversionPipeline {
  final List<RecipeConverter> converters;
  final List<RecipeValidator> validators;
  final List<RecipeTransformer> transformers;

  Future<UnifiedRecipe> convertToUnified(dynamic input) async {
    var current = input;

    // 1. 변환 단계
    for (final converter in converters) {
      if (await converter.canConvert(current)) {
        current = await converter.convert(current);
        break;
      }
    }

    // 2. 검증 단계
    for (final validator in validators) {
      if (!await validator.validate(current)) {
        throw ValidationError(validator.getErrorMessage());
      }
    }

    // 3. 변환 단계
    for (final transformer in transformers) {
      current = await transformer.transform(current);
    }

    return current as UnifiedRecipe;
  }

  Future<Recipe> convertToRecipe(UnifiedRecipe input) async {
    var current = input;

    // 역변환 파이프라인
    for (final transformer in transformers.reversed) {
      current = await transformer.reverse(current);
    }

    for (final converter in converters.reversed) {
      if (await converter.canReverse(current)) {
        current = await converter.reverse(current);
        break;
      }
    }

    return current as Recipe;
  }
}
```

### 2. 실시간 변환 모니터링
```dart
// lib/monitoring/recipe_conversion_monitor.dart
class RecipeConversionMonitor {
  final SousChefEventBus eventBus;
  final Map<String, ConversionMetrics> _metrics = {};

  RecipeConversionMonitor({required this.eventBus}) {
    _setupMonitoring();
  }

  void _setupMonitoring() {
    eventBus.subscribe('recipe:conversion_started').listen(_handleConversionStart);
    eventBus.subscribe('recipe:conversion_completed').listen(_handleConversionComplete);
    eventBus.subscribe('recipe:conversion_error').listen(_handleConversionError);
  }

  void _handleConversionStart(dynamic event) {
    final conversionId = event['conversionId'];
    _metrics[conversionId] = ConversionMetrics(
      startTime: DateTime.now(),
      inputType: event['inputType'],
      outputType: event['outputType'],
    );
  }

  void _handleConversionComplete(dynamic event) {
    final conversionId = event['conversionId'];
    final metrics = _metrics[conversionId];

    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.success = true;
      metrics.output = event['output'];

      eventBus.publish('recipe:conversion_metrics', {
        'conversionId': conversionId,
        'metrics': metrics.toMap(),
      });
    }
  }

  void _handleConversionError(dynamic event) {
    final conversionId = event['conversionId'];
    final metrics = _metrics[conversionId];

    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.success = false;
      metrics.error = event['error'];

      eventBus.publish('recipe:conversion_error_metrics', {
        'conversionId': conversionId,
        'metrics': metrics.toMap(),
      });
    }
  }
}
```

## 📊 결론

### 레시피 연동 방식의 강점

✅ **완벽한 메인 앱 통합** - 양방향 데이터 변환
✅ **실시간 동기화** - 변경사항 즉시 반영
✅ **모듈별 최적화** - 각 모듈에 맞는 데이터 추출
✅ **에러 복구** - 견고한 에러 처리 메커니즘
✅ **성능 모니터링** - 변환 프로세스 모니터링

### 구현 우선순위

1. **코어 변환 시스템** (RecipeConverter, RecipeAdapter)
2. **모듈 데이터 추출기** (ModuleDataExtractor)
3. **동기화 프로토콜** (RecipeSyncProtocol)
4. **변환 파이프라인** (RecipeConversionPipeline)
5. **모니터링 시스템** (RecipeConversionMonitor)

이 레시피 연동 방식을 통해 메인 앱과 수쉐프 모드 간의 완벽한 통합을 달성할 수 있습니다. 각 모듈은 필요한 데이터만을 추출하여 효율적으로 분석할 수 있으며, 모든 변경사항은 실시간으로 동기화됩니다.

## 🔐 데이터 보안 및 개인정보 보호

### 1. 데이터 익명화 및 해싱

#### DataAnonymizer - 데이터 익명화 관리자
```dart
// lib/utils/data_anonymizer.dart
class DataAnonymizer {
  static Future<Map<String, dynamic>> anonymizeRecipeData(
    Map<String, dynamic> recipeData
  ) async {
    final anonymized = Map<String, dynamic>.from(recipeData);

    // 개인정보 필드 제거 또는 해싱
    if (anonymized.containsKey('author')) {
      anonymized['author'] = await _hashUserIdentifier(anonymized['author']);
    }

    if (anonymized.containsKey('createdBy')) {
      anonymized['createdBy'] = await _hashUserIdentifier(anonymized['createdBy']);
    }

    // 민감한 메타데이터 제거
    anonymized.remove('userPreferences');
    anonymized.remove('personalNotes');

    return anonymized;
  }

  static Future<String> _hashUserIdentifier(String identifier) async {
    // SHA-256 해싱으로 사용자 식별자 보호
    final bytes = utf8.encode(identifier + _getSalt());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String _getSalt() {
    // 환경별 솔트 값 (보안 키에서 가져와야 함)
    return const String.fromEnvironment('HASH_SALT', defaultValue: 'souschef_salt');
  }

  static Future<Map<String, dynamic>> anonymizeAnalysisResult(
    Map<String, dynamic> analysisData
  ) async {
    final anonymized = Map<String, dynamic>.from(analysisData);

    // 분석 결과에서 개인정보 제거
    anonymized.remove('userId');
    anonymized.remove('sessionId');
    anonymized.remove('deviceId');

    // 타임스탬프 일반화 (시간 정밀도 낮추기)
    if (anonymized.containsKey('timestamp')) {
      anonymized['timestamp'] = _generalizeTimestamp(anonymized['timestamp']);
    }

    return anonymized;
  }

  static String _generalizeTimestamp(dynamic timestamp) {
    // 분 단위로 타임스탬프 일반화하여 개인 식별 방지
    final dateTime = timestamp is DateTime ? timestamp : DateTime.parse(timestamp.toString());
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    ).toIso8601String();
  }
}
```

### 2. 데이터 검증 및 무결성

#### DataIntegrityValidator - 데이터 무결성 검증기
```dart
// lib/validators/data_integrity_validator.dart
class DataIntegrityValidator {
  static Future<bool> validateRecipeData(Map<String, dynamic> recipeData) async {
    try {
      // 1. 필수 필드 검증
      final requiredFields = ['id', 'title', 'ingredients'];
      for (final field in requiredFields) {
        if (!recipeData.containsKey(field) || recipeData[field] == null) {
          throw ValidationException('Missing required field: $field');
        }
      }

      // 2. 데이터 타입 검증
      if (recipeData['ingredients'] is! List) {
        throw ValidationException('Ingredients must be a list');
      }

      // 3. 데이터 범위 검증
      await _validateIngredientData(recipeData['ingredients']);
      await _validateProcessData(recipeData['processes']);

      // 4. 비즈니스 규칙 검증
      await _validateBusinessRules(recipeData);

      return true;

    } catch (e) {
      Logger.error('Data validation failed: $e');
      return false;
    }
  }

  static Future<void> _validateIngredientData(List ingredients) async {
    for (final ingredient in ingredients) {
      if (ingredient is Map) {
        if (!ingredient.containsKey('name') || ingredient['name'].toString().isEmpty) {
          throw ValidationException('Invalid ingredient name');
        }

        if (ingredient.containsKey('amount')) {
          final amount = ingredient['amount'];
          if (amount is num && amount <= 0) {
            throw ValidationException('Ingredient amount must be positive');
          }
        }
      }
    }
  }

  static Future<void> _validateProcessData(List? processes) async {
    if (processes == null) return;

    for (final process in processes) {
      if (process is Map) {
        if (!process.containsKey('type') || process['type'].toString().isEmpty) {
          throw ValidationException('Invalid process type');
        }

        if (process.containsKey('duration')) {
          final duration = process['duration'];
          if (duration is num && duration <= 0) {
            throw ValidationException('Process duration must be positive');
          }
        }
      }
    }
  }

  static Future<void> _validateBusinessRules(Map<String, dynamic> recipeData) async {
    // 레시피별 비즈니스 규칙 검증
    final ingredients = recipeData['ingredients'] as List?;
    final processes = recipeData['processes'] as List?;

    // 최소 재료 수 검증
    if (ingredients != null && ingredients.length < 2) {
      throw ValidationException('Recipe must have at least 2 ingredients');
    }

    // 재료와 공정의 일관성 검증
    if (ingredients != null && processes != null) {
      await _validateIngredientProcessConsistency(ingredients, processes);
    }
  }

  static Future<void> _validateIngredientProcessConsistency(
    List ingredients,
    List processes
  ) async {
    // 예시: 빵 굽기 레시피는 밀가루가 있어야 함
    final hasFlour = ingredients.any((ing) =>
      ing['name'].toString().toLowerCase().contains('flour') ||
      ing['name'].toString().toLowerCase().contains('밀가루')
    );

    final hasBaking = processes.any((proc) =>
      proc['type'].toString().toLowerCase().contains('baking') ||
      proc['type'].toString().toLowerCase().contains('굽기')
    );

    if (hasBaking && !hasFlour) {
      throw ValidationException('Baking recipe should contain flour');
    }
  }
}
```

## 📊 성능 최적화된 데이터 변환

### 1. 지연 로딩 및 캐싱

#### LazyLoadingRecipeConverter - 지연 로딩 변환기
```dart
// lib/converters/lazy_loading_converter.dart
class LazyLoadingRecipeConverter {
  static final Map<String, Future<UnifiedRecipe>> _cache = {};
  static const Duration CACHE_DURATION = Duration(minutes: 10);

  static Future<UnifiedRecipe> convertWithCache(dynamic recipe) async {
    final key = _generateCacheKey(recipe);

    // 캐시된 결과 확인
    if (_cache.containsKey(key)) {
      final cached = _cache[key]!;
      if (await _isCacheValid(key)) {
        return cached;
      } else {
        _cache.remove(key);
      }
    }

    // 새로운 변환 작업 시작
    final future = _convertAndCache(recipe, key);
    _cache[key] = future;

    return future;
  }

  static String _generateCacheKey(dynamic recipe) {
    if (recipe is Map) {
      return 'recipe_${recipe['id']}_${recipe.hashCode}';
    } else if (recipe is Recipe) {
      return 'recipe_${recipe.id}_${recipe.hashCode}';
    }
    return 'recipe_${recipe.hashCode}';
  }

  static Future<bool> _isCacheValid(String key) async {
    // 캐시 타임스탬프 확인 (실제로는 Redis나 메모리 캐시에서 확인)
    return true; // 간단한 구현
  }

  static Future<UnifiedRecipe> _convertAndCache(dynamic recipe, String key) async {
    try {
      // 1. 기본 변환
      final unifiedRecipe = await RecipeConverter.toUnifiedRecipe(recipe);

      // 2. 모듈별 데이터 지연 로딩 설정
      unifiedRecipe.setLazyLoader(() async {
        // 필요할 때만 모듈별 데이터 로드
        return await ModuleDataExtractor.extractAllModuleData(unifiedRecipe);
      });

      // 3. 캐시 만료 타이머 설정
      Timer(CACHE_DURATION, () {
        _cache.remove(key);
      });

      return unifiedRecipe;

    } catch (e) {
      _cache.remove(key);
      throw e;
    }
  }

  static void clearCache() {
    _cache.clear();
  }

  static void preloadCommonRecipes(List<dynamic> recipes) {
    for (final recipe in recipes) {
      convertWithCache(recipe); // 백그라운드에서 캐시
    }
  }
}
```

### 2. 점진적 데이터 동기화

#### IncrementalSyncManager - 점진적 동기화 관리자
```dart
// lib/sync/incremental_sync_manager.dart
class IncrementalSyncManager {
  final Map<String, RecipeVersion> _recipeVersions = {};
  final Map<String, List<String>> _pendingChanges = {};

  static const int BATCH_SIZE = 10;

  Future<void> syncRecipeChanges(String recipeId, Map<String, dynamic> changes) async {
    // 1. 버전 확인
    final currentVersion = await _getCurrentVersion(recipeId);
    final incomingVersion = changes['version'] ?? 0;

    if (incomingVersion <= currentVersion) {
      Logger.info('Recipe $recipeId is already up to date');
      return;
    }

    // 2. 변경사항 큐에 추가
    _pendingChanges.putIfAbsent(recipeId, () => []);
    _pendingChanges[recipeId]!.addAll(_extractChangeKeys(changes));

    // 3. 배치 처리
    if (_pendingChanges[recipeId]!.length >= BATCH_SIZE) {
      await _processBatch(recipeId);
    } else {
      // 작은 변경사항은 지연 처리
      Timer(const Duration(milliseconds: 500), () {
        _processBatch(recipeId);
      });
    }
  }

  Future<void> _processBatch(String recipeId) async {
    final changes = _pendingChanges[recipeId];
    if (changes == null || changes.isEmpty) return;

    try {
      // 1. 변경사항 통합
      final consolidatedChanges = await _consolidateChanges(recipeId, changes);

      // 2. 충돌 감지 및 해결
      final resolvedChanges = await _resolveConflicts(recipeId, consolidatedChanges);

      // 3. 데이터베이스 업데이트
      await _updateRecipeData(recipeId, resolvedChanges);

      // 4. 버전 업데이트
      await _updateVersion(recipeId);

      // 5. 이벤트 발행
      SousChefEventBus().publish('recipe:sync_completed', {
        'recipeId': recipeId,
        'changes': changes.length,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      Logger.error('Batch processing failed for recipe $recipeId: $e');

      // 실패 시 재시도 큐에 추가
      _scheduleRetry(recipeId, changes);
    }

    // 처리 완료된 변경사항 제거
    _pendingChanges[recipeId]!.clear();
  }

  Future<Map<String, dynamic>> _consolidateChanges(
    String recipeId,
    List<String> changes
  ) async {
    // 변경사항을 통합하여 최종 상태 계산
    final consolidated = <String, dynamic>{};

    for (final change in changes) {
      final value = await _getLatestValue(recipeId, change);
      consolidated[change] = value;
    }

    return consolidated;
  }

  Future<Map<String, dynamic>> _resolveConflicts(
    String recipeId,
    Map<String, dynamic> changes
  ) async {
    // 충돌 감지 및 해결 로직
    // 예: 타임스탬프 기반 최신 값 우선
    return changes; // 간단한 구현
  }

  Future<void> _updateRecipeData(
    String recipeId,
    Map<String, dynamic> changes
  ) async {
    // 실제 데이터베이스 업데이트 로직
    Logger.info('Updating recipe $recipeId with ${changes.length} changes');
  }

  Future<void> _updateVersion(String recipeId) async {
    final currentVersion = await _getCurrentVersion(recipeId);
    _recipeVersions[recipeId] = RecipeVersion(
      version: currentVersion + 1,
      timestamp: DateTime.now(),
    );
  }

  Future<int> _getCurrentVersion(String recipeId) async {
    return _recipeVersions[recipeId]?.version ?? 0;
  }

  List<String> _extractChangeKeys(Map<String, dynamic> changes) {
    return changes.keys.where((key) => key != 'version').toList();
  }

  void _scheduleRetry(String recipeId, List<String> changes) {
    Timer(const Duration(seconds: 30), () {
      if (_pendingChanges.containsKey(recipeId)) {
        _processBatch(recipeId);
      }
    });
  }
}

class RecipeVersion {
  final int version;
  final DateTime timestamp;

  const RecipeVersion({
    required this.version,
    required this.timestamp,
  });
}
```

## 🚨 고급 오류 처리 및 복구

### 1. 데이터 동기화 오류 복구

#### SyncErrorRecoveryManager - 동기화 오류 복구 관리자
```dart
// lib/recovery/sync_error_recovery_manager.dart
class SyncErrorRecoveryManager {
  final Map<String, SyncErrorContext> _errorContexts = {};
  final Map<String, RecoveryStrategy> _recoveryStrategies = {};

  void registerRecoveryStrategy(String errorType, RecoveryStrategy strategy) {
    _recoveryStrategies[errorType] = strategy;
  }

  Future<void> handleSyncError({
    required String recipeId,
    required String errorType,
    required dynamic error,
    required Map<String, dynamic> context,
  }) async {
    final errorContext = SyncErrorContext(
      recipeId: recipeId,
      errorType: errorType,
      error: error,
      context: context,
      timestamp: DateTime.now(),
    );

    _errorContexts[recipeId] = errorContext;

    // 1. 즉시 로깅
    await _logSyncError(errorContext);

    // 2. 복구 전략 선택
    final strategy = _recoveryStrategies[errorType] ?? _getDefaultStrategy(errorType);

    // 3. 복구 실행
    await _executeRecovery(errorContext, strategy);

    // 4. 모니터링 이벤트 발행
    SousChefEventBus().publish('sync:recovery_attempted', {
      'recipeId': recipeId,
      'errorType': errorType,
      'strategy': strategy.name,
      'timestamp': DateTime.now(),
    });
  }

  RecoveryStrategy _getDefaultStrategy(String errorType) {
    switch (errorType) {
      case 'network_timeout':
        return RecoveryStrategy.retryWithBackoff;
      case 'data_corruption':
        return RecoveryStrategy.requestFreshData;
      case 'permission_denied':
        return RecoveryStrategy.requestPermission;
      case 'storage_full':
        return RecoveryStrategy.cleanupStorage;
      default:
        return RecoveryStrategy.retryImmediately;
    }
  }

  Future<void> _executeRecovery(
    SyncErrorContext context,
    RecoveryStrategy strategy
  ) async {
    try {
      switch (strategy) {
        case RecoveryStrategy.retryImmediately:
          await _retryImmediately(context);
          break;
        case RecoveryStrategy.retryWithBackoff:
          await _retryWithBackoff(context);
          break;
        case RecoveryStrategy.requestFreshData:
          await _requestFreshData(context);
          break;
        case RecoveryStrategy.requestPermission:
          await _requestPermission(context);
          break;
        case RecoveryStrategy.cleanupStorage:
          await _cleanupStorage(context);
          break;
      }

      // 복구 성공 시 컨텍스트 제거
      _errorContexts.remove(context.recipeId);

    } catch (e) {
      // 복구 실패 시 최종 실패 처리
      await _handleFinalFailure(context, e);
    }
  }

  Future<void> _retryImmediately(SyncErrorContext context) async {
    // 즉시 재시도 로직
    await RecipeSynchronizationProtocol.synchronizeRecipe(
      recipe: await _getRecipeById(context.recipeId),
      eventBus: SousChefEventBus(),
    );
  }

  Future<void> _retryWithBackoff(SyncErrorContext context) async {
    // 점진적 백오프 재시도
    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(Duration(seconds: attempt * 2));

      try {
        await _retryImmediately(context);
        return; // 성공 시 종료
      } catch (e) {
        if (attempt == 3) throw e;
      }
    }
  }

  Future<void> _requestFreshData(SyncErrorContext context) async {
    // 메인 앱에 신선한 데이터 요청
    SousChefEventBus().publish('main_app:request_fresh_data', {
      'recipeId': context.recipeId,
      'reason': 'data_corruption',
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _requestPermission(SyncErrorContext context) async {
    // 권한 재요청
    SousChefEventBus().publish('system:request_permission', {
      'recipeId': context.recipeId,
      'permission': context.context['requiredPermission'],
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _cleanupStorage(SyncErrorContext context) async {
    // 저장소 정리 후 재시도
    await StorageManager.cleanupTempFiles();
    await _retryImmediately(context);
  }

  Future<void> _handleFinalFailure(SyncErrorContext context, dynamic error) async {
    // 최종 실패 처리
    SousChefEventBus().publish('sync:recovery_failed', {
      'recipeId': context.recipeId,
      'errorType': context.errorType,
      'finalError': error.toString(),
      'timestamp': DateTime.now(),
    });

    // 사용자에게 알림
    SousChefEventBus().publish('ui:show_error', {
      'title': '동기화 실패',
      'message': '레시피 동기화에 실패했습니다. 나중에 다시 시도해주세요.',
      'recipeId': context.recipeId,
    });
  }

  Future<void> _logSyncError(SyncErrorContext context) async {
    Logger.error('Sync error for recipe ${context.recipeId}: ${context.error}');
  }

  Future<dynamic> _getRecipeById(String recipeId) async {
    // 레시피 조회 로직 (실제로는 데이터베이스에서 가져와야 함)
    return {'id': recipeId, 'title': 'Unknown Recipe'};
  }
}

class SyncErrorContext {
  final String recipeId;
  final String errorType;
  final dynamic error;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const SyncErrorContext({
    required this.recipeId,
    required this.errorType,
    required this.error,
    required this.context,
    required this.timestamp,
  });
}

enum RecoveryStrategy {
  retryImmediately,
  retryWithBackoff,
  requestFreshData,
  requestPermission,
  cleanupStorage,
}

extension RecoveryStrategyExtension on RecoveryStrategy {
  String get name {
    switch (this) {
      case RecoveryStrategy.retryImmediately:
        return 'retry_immediately';
      case RecoveryStrategy.retryWithBackoff:
        return 'retry_with_backoff';
      case RecoveryStrategy.requestFreshData:
        return 'request_fresh_data';
      case RecoveryStrategy.requestPermission:
        return 'request_permission';
      case RecoveryStrategy.cleanupStorage:
        return 'cleanup_storage';
    }
  }
}
```

### 2. 데이터 일관성 보장

#### DataConsistencyManager - 데이터 일관성 관리자
```dart
// lib/consistency/data_consistency_manager.dart
class DataConsistencyManager {
  final Map<String, DataConsistencyCheck> _checks = {};

  void registerConsistencyCheck(String dataType, DataConsistencyCheck check) {
    _checks[dataType] = check;
  }

  Future<bool> validateConsistency(
    String dataType,
    Map<String, dynamic> data
  ) async {
    final check = _checks[dataType];
    if (check == null) return true;

    try {
      return await check.validate(data);
    } catch (e) {
      Logger.error('Consistency check failed for $dataType: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> repairConsistency(
    String dataType,
    Map<String, dynamic> data
  ) async {
    final check = _checks[dataType];
    if (check == null) return data;

    try {
      return await check.repair(data);
    } catch (e) {
      Logger.error('Consistency repair failed for $dataType: $e');
      return data;
    }
  }

  Future<void> runConsistencyCheck() async {
    // 주기적 일관성 검증
    Timer.periodic(const Duration(minutes: 30), (_) async {
      await _validateAllDataConsistency();
    });
  }

  Future<void> _validateAllDataConsistency() async {
    for (final entry in _checks.entries) {
      // 각 데이터 타입별 일관성 검증 실행
      Logger.info('Running consistency check for ${entry.key}');
    }
  }
}

abstract class DataConsistencyCheck {
  Future<bool> validate(Map<String, dynamic> data);
  Future<Map<String, dynamic>> repair(Map<String, dynamic> data);
}

class RecipeConsistencyCheck implements DataConsistencyCheck {
  @override
  Future<bool> validate(Map<String, dynamic> data) async {
    // 레시피 데이터 일관성 검증
    if (!data.containsKey('ingredients') || !data.containsKey('processes')) {
      return false;
    }

    final ingredients = data['ingredients'] as List?;
    final processes = data['processes'] as List?;

    if (ingredients == null || ingredients.isEmpty) {
      return false;
    }

    // 재료와 공정 간의 일관성 검증
    return await _validateIngredientProcessConsistency(ingredients, processes);
  }

  @override
  Future<Map<String, dynamic>> repair(Map<String, dynamic> data) async {
    final repaired = Map<String, dynamic>.from(data);

    // 누락된 필드 추가
    if (!repaired.containsKey('ingredients')) {
      repaired['ingredients'] = [];
    }

    if (!repaired.containsKey('processes')) {
      repaired['processes'] = [];
    }

    // 잘못된 데이터 수정
    if (repaired['ingredients'] is! List) {
      repaired['ingredients'] = [];
    }

    return repaired;
  }

  Future<bool> _validateIngredientProcessConsistency(
    List ingredients,
    List? processes
  ) async {
    // 재료와 공정 간의 일관성 검증 로직
    return true; // 간단한 구현
  }
}
```

## 👤 사용자 경험 최적화

### 1. 로딩 상태 및 피드백

#### SyncLoadingManager - 동기화 로딩 관리자
```dart
// lib/ui/sync_loading_manager.dart
class SyncLoadingManager {
  static final Map<String, LoadingContext> _activeLoadings = {};

  static void showLoading(String recipeId, String operation) {
    final context = LoadingContext(
      recipeId: recipeId,
      operation: operation,
      startTime: DateTime.now(),
    );

    _activeLoadings[recipeId] = context;

    // UI에 로딩 표시 요청
    SousChefEventBus().publish('ui:show_loading', {
      'recipeId': recipeId,
      'operation': operation,
      'message': _getLoadingMessage(operation),
    });

    // 타임아웃 설정
    Timer(const Duration(seconds: 30), () {
      if (_activeLoadings.containsKey(recipeId)) {
        hideLoading(recipeId, timeout: true);
      }
    });
  }

  static void hideLoading(String recipeId, {bool timeout = false}) {
    final context = _activeLoadings.remove(recipeId);
    if (context == null) return;

    final duration = DateTime.now().difference(context.startTime);

    // UI에 로딩 숨김 요청
    SousChefEventBus().publish('ui:hide_loading', {
      'recipeId': recipeId,
      'duration': duration.inMilliseconds,
      'timeout': timeout,
    });

    // 성능 메트릭 기록
    SousChefEventBus().publish('performance:loading_duration', {
      'operation': context.operation,
      'duration': duration.inMilliseconds,
      'timeout': timeout,
    });
  }

  static String _getLoadingMessage(String operation) {
    switch (operation) {
      case 'sync':
        return '레시피 동기화 중...';
      case 'analysis':
        return '레시피 분석 중...';
      case 'save':
        return '변경사항 저장 중...';
      default:
        return '처리 중...';
    }
  }

  static bool isLoading(String recipeId) {
    return _activeLoadings.containsKey(recipeId);
  }

  static LoadingContext? getLoadingContext(String recipeId) {
    return _activeLoadings[recipeId];
  }
}

class LoadingContext {
  final String recipeId;
  final String operation;
  final DateTime startTime;

  const LoadingContext({
    required this.recipeId,
    required this.operation,
    required this.startTime,
  });
}
```

### 2. 오프라인 모드 지원

#### OfflineSyncManager - 오프라인 동기화 관리자
```dart
// lib/sync/offline_sync_manager.dart
class OfflineSyncManager {
  static final List<PendingSync> _pendingSyncs = [];
  static bool _isOnline = true;

  static void setOnlineStatus(bool isOnline) {
    final wasOffline = !_isOnline;
    _isOnline = isOnline;

    if (wasOffline && isOnline) {
      // 오프라인에서 온라인으로 복귀 시 대기 중인 동기화 처리
      _processPendingSyncs();
    }

    SousChefEventBus().publish('network:status_changed', {
      'isOnline': isOnline,
      'timestamp': DateTime.now(),
    });
  }

  static Future<void> queueSync({
    required String recipeId,
    required Map<String, dynamic> data,
    required String operation,
  }) async {
    final pendingSync = PendingSync(
      recipeId: recipeId,
      data: data,
      operation: operation,
      timestamp: DateTime.now(),
    );

    _pendingSyncs.add(pendingSync);

    if (_isOnline) {
      // 온라인 상태면 즉시 처리
      await _processPendingSyncs();
    } else {
      // 오프라인 상태면 로컬에 저장
      await _savePendingSync(pendingSync);

      // 사용자에게 알림
      SousChefEventBus().publish('ui:show_offline_notification', {
        'recipeId': recipeId,
        'operation': operation,
      });
    }
  }

  static Future<void> _processPendingSyncs() async {
    if (_pendingSyncs.isEmpty) return;

    final syncsToProcess = List<PendingSync>.from(_pendingSyncs);
    _pendingSyncs.clear();

    for (final sync in syncsToProcess) {
      try {
        await _executeSync(sync);

        // 성공 시 로컬 저장소에서 제거
        await _removePendingSync(sync);

      } catch (e) {
        // 실패 시 다시 큐에 추가
        Logger.error('Sync failed for recipe ${sync.recipeId}: $e');
        _pendingSyncs.add(sync);
      }
    }
  }

  static Future<void> _executeSync(PendingSync sync) async {
    // 실제 동기화 로직 실행
    switch (sync.operation) {
      case 'update':
        await RecipeSynchronizationProtocol.synchronizeRecipe(
          recipe: sync.data,
          eventBus: SousChefEventBus(),
        );
        break;
      case 'delete':
        // 삭제 동기화 로직
        break;
      default:
        Logger.warning('Unknown sync operation: ${sync.operation}');
    }
  }

  static Future<void> _savePendingSync(PendingSync sync) async {
    // 로컬 저장소에 대기 중인 동기화 저장
    // SharedPreferences 또는 SQLite에 저장
  }

  static Future<void> _removePendingSync(PendingSync sync) async {
    // 처리 완료된 동기화 제거
  }

  static Future<void> loadPendingSyncs() async {
    // 앱 시작 시 저장된 동기화 로드
    final savedSyncs = await _loadSavedSyncs();
    _pendingSyncs.addAll(savedSyncs);
  }

  static Future<List<PendingSync>> _loadSavedSyncs() async {
    // 저장된 동기화 데이터 로드
    return [];
  }
}

class PendingSync {
  final String recipeId;
  final Map<String, dynamic> data;
  final String operation;
  final DateTime timestamp;

  const PendingSync({
    required this.recipeId,
    required this.data,
    required this.operation,
    required this.timestamp,
  });
}
```

이 레시피 연동 방식을 통해 메인 앱과 수쉐프 모드 간의 완벽한 통합을 달성할 수 있습니다. 각 모듈은 필요한 데이터만을 추출하여 효율적으로 분석할 수 있으며, 모든 변경사항은 실시간으로 동기화됩니다. 보안 강화, 성능 최적화, 고급 오류 처리 기능을 통해 안정적이고 효율적인 데이터 연동 시스템을 구축했습니다.
