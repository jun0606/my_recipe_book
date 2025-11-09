# 03. 통신 프로토콜

## 📋 개요

수쉐프 모드 v2.0의 통신 프로토콜은 이벤트 기반 아키텍처를 통해 메인 앱, 수쉐프 모드, 각 모듈 간의 실시간 데이터 동기화와 일관된 통신을 보장합니다.

## 🎯 설계 목표

### 1. 실시간 데이터 동기화
```dart
// 레시피 변경 시 모든 모듈에 즉시 반영
Recipe (Main App) → Event Bus → All Modules
```

### 2. 모듈 간 독립성
```dart
// 각 모듈은 독립적으로 통신
Module A → Event Bus → Module B
```

### 3. 에러 복구 및 재시도
```dart
// 통신 실패 시 자동 재시도
tryPublish(event) → onError → retry → fallback
```

## 🏗️ 이벤트 기반 아키텍처

### 1. 코어 이벤트 시스템

#### EventBus - 중앙 이벤트 버스
```dart
// lib/communication/event_bus.dart
class SousChefEventBus {
  static final Map<String, StreamController<dynamic>> _controllers = {};

  static Stream<T> subscribe<T>(String event) {
    _controllers.putIfAbsent(event, () => StreamController<T>.broadcast());
    return _controllers[event].stream as Stream<T>;
  }

  static void publish<T>(String event, T data) {
    if (_controllers.containsKey(event)) {
      _controllers[event].add(data);
    }
  }

  static void unsubscribe(String event) {
    if (_controllers.containsKey(event)) {
      _controllers[event].close();
      _controllers.remove(event);
    }
  }

  // 에러 처리 기능
  static void publishError(String moduleId, dynamic error) {
    publish('module:error', {
      'moduleId': moduleId,
      'error': error,
      'timestamp': DateTime.now(),
    });
  }

  // 메트릭 수집
  static void publishMetric(String metric, dynamic value) {
    publish('system:metric', {
      'metric': metric,
      'value': value,
      'timestamp': DateTime.now(),
    });
  }
}
```

#### Event Types - 표준 이벤트 타입
```dart
// lib/communication/events.dart
enum SousChefEvent {
  // 레시피 관련 이벤트
  recipeUpdated,
  recipeModified,
  ingredientChanged,
  processChanged,
  equipmentChanged,

  // 모듈 관련 이벤트
  moduleActivated,
  moduleDeactivated,
  moduleSwitched,
  moduleError,
  moduleTimeout,

  // 분석 관련 이벤트
  analysisStarted,
  analysisCompleted,
  analysisError,
  analysisTimeout,

  // UI 관련 이벤트
  uiTabChanged,
  uiComponentUpdated,
  uiError,

  // 시스템 이벤트
  systemInitialized,
  systemError,
  systemMetric,
}

// 이벤트 데이터 클래스들
class RecipeUpdateEvent {
  final String recipeId;
  final Map<String, dynamic> changes;
  final DateTime timestamp;

  const RecipeUpdateEvent({
    required this.recipeId,
    required this.changes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ModuleSwitchEvent {
  final String moduleId;
  final ModuleState state;
  final DateTime timestamp;

  const ModuleSwitchEvent({
    required this.moduleId,
    required this.state,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AnalysisCompleteEvent {
  final String moduleId;
  final AnalysisResult result;
  final DateTime timestamp;

  const AnalysisCompleteEvent({
    required this.moduleId,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
```

### 2. 모듈 간 통신 인터페이스

#### ModuleCommunicator - 모듈 통신 인터페이스
```dart
// lib/communication/module_communicator.dart
abstract class ModuleCommunicator {
  final String moduleId;
  final SousChefEventBus eventBus;

  const ModuleCommunicator({
    required this.moduleId,
    required this.eventBus,
  });

  // 이벤트 구독 관리
  StreamSubscription subscribeToRecipeUpdates();
  StreamSubscription subscribeToModuleEvents();
  StreamSubscription subscribeToAnalysisEvents();

  // 이벤트 발행
  void publishRecipeModification(Map<String, dynamic> changes);
  void publishAnalysisResult(AnalysisResult result);
  void publishModuleState(ModuleState state);

  // 에러 처리
  void handleError(dynamic error);
  void requestRetry(String operationId);
}

class DefaultModuleCommunicator implements ModuleCommunicator {
  @override
  final String moduleId;
  @override
  final SousChefEventBus eventBus;

  late final StreamSubscription _recipeSubscription;
  late final StreamSubscription _moduleSubscription;
  late final StreamSubscription _analysisSubscription;

  DefaultModuleCommunicator({
    required this.moduleId,
    required this.eventBus,
  }) {
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    // 레시피 업데이트 구독
    _recipeSubscription = eventBus.subscribe<RecipeUpdateEvent>(
      SousChefEvent.recipeUpdated.name,
    ).listen(_handleRecipeUpdate);

    // 모듈 이벤트 구독
    _moduleSubscription = eventBus.subscribe<ModuleSwitchEvent>(
      SousChefEvent.moduleSwitched.name,
    ).listen(_handleModuleSwitch);

    // 분석 이벤트 구독
    _analysisSubscription = eventBus.subscribe<AnalysisCompleteEvent>(
      SousChefEvent.analysisCompleted.name,
    ).listen(_handleAnalysisComplete);
  }

  void _handleRecipeUpdate(RecipeUpdateEvent event) {
    if (event.recipeId == _currentRecipeId) {
      onRecipeUpdated(event.changes);
    }
  }

  void _handleModuleSwitch(ModuleSwitchEvent event) {
    if (event.moduleId == moduleId) {
      onModuleStateChanged(event.state);
    }
  }

  void _handleAnalysisComplete(AnalysisCompleteEvent event) {
    if (event.moduleId != moduleId) {
      onOtherModuleAnalysis(event.result);
    }
  }

  // Override these methods in concrete implementations
  void onRecipeUpdated(Map<String, dynamic> changes) {}
  void onModuleStateChanged(ModuleState state) {}
  void onOtherModuleAnalysis(AnalysisResult result) {}
  String get _currentRecipeId => ''; // Override in subclasses
}
```

## 🔄 데이터 흐름 프로토콜

### 1. 레시피 → 수쉐프 모드

#### Recipe Synchronization Protocol
```dart
// lib/protocols/recipe_sync.dart
class RecipeSynchronizationProtocol {
  static const String RECIPE_SYNC_CHANNEL = 'recipe:sync';

  static Future<void> synchronizeRecipe({
    required UnifiedRecipe recipe,
    required SousChefEventBus eventBus,
  }) async {
    try {
      // 1. 동기화 시작 이벤트 발행
      eventBus.publish(
        SousChefEvent.systemInitialized.name,
        {'phase': 'recipe_sync_start', 'recipeId': recipe.id}
      );

      // 2. 레시피 데이터 변환
      final syncData = _convertRecipeForSync(recipe);

      // 3. 각 모듈에 데이터 전송
      await _broadcastToModules(syncData, eventBus);

      // 4. 동기화 완료 이벤트 발행
      eventBus.publish(
        SousChefEvent.recipeUpdated.name,
        RecipeUpdateEvent(
          recipeId: recipe.id,
          changes: syncData,
        )
      );

    } catch (e) {
      // 5. 에러 처리
      eventBus.publishError('recipe_sync', e);
    }
  }

  static Map<String, dynamic> _convertRecipeForSync(UnifiedRecipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'ingredients': recipe.ingredients.map((ing) => ing.toMap()).toList(),
      'processes': recipe.processes.map((proc) => proc.toMap()).toList(),
      'equipment': recipe.equipment.toMap(),
      'metadata': recipe.metadata.toMap(),
      'moduleData': _extractModuleSpecificData(recipe),
    };
  }

  static Map<String, dynamic> _extractModuleSpecificData(UnifiedRecipe recipe) {
    return {
      'bread': recipe.breadRequirements?.toMap(),
      'cake': recipe.cakeRequirements?.toMap(),
      'cookie': recipe.cookieRequirements?.toMap(),
      'dessert': recipe.dessertRequirements?.toMap(),
    };
  }

  static Future<void> _broadcastToModules(
    Map<String, dynamic> syncData,
    SousChefEventBus eventBus,
  ) async {
    final modules = ModuleManager.getAvailableModules();

    for (final moduleId in modules) {
      eventBus.publish(
        'module:$moduleId:recipe_sync',
        syncData,
      );
    }
  }
}
```

### 2. 수쉐프 모드 → 메인 앱

#### Analysis Feedback Protocol
```dart
// lib/protocols/analysis_feedback.dart
class AnalysisFeedbackProtocol {
  static const String ANALYSIS_FEEDBACK_CHANNEL = 'analysis:feedback';

  static Future<void> sendAnalysisFeedback({
    required String recipeId,
    required AnalysisResult analysis,
    required SousChefEventBus eventBus,
  }) async {
    try {
      // 1. 피드백 데이터 준비
      final feedbackData = _prepareFeedbackData(analysis);

      // 2. 메인 앱으로 피드백 전송
      eventBus.publish(
        ANALYSIS_FEEDBACK_CHANNEL,
        {
          'recipeId': recipeId,
          'analysis': feedbackData,
          'timestamp': DateTime.now(),
        }
      );

      // 3. 성공 이벤트 발행
      eventBus.publish(
        SousChefEvent.analysisCompleted.name,
        AnalysisCompleteEvent(
          moduleId: analysis.moduleId,
          result: analysis,
        )
      );

    } catch (e) {
      // 4. 에러 처리
      eventBus.publishError(analysis.moduleId, e);
    }
  }

  static Map<String, dynamic> _prepareFeedbackData(AnalysisResult analysis) {
    return {
      'moduleId': analysis.moduleId,
      'isSuccessful': analysis.isSuccessful,
      'errorMessage': analysis.errorMessage,
      'data': analysis.data,
      'processAnalysis': analysis.processAnalysis?.toMap(),
      'ingredientAnalysis': analysis.ingredientAnalysis?.toMap(),
      'equipmentAnalysis': analysis.equipmentAnalysis?.toMap(),
    };
  }
}
```

### 3. 모듈 간 실시간 동기화

#### Module Synchronization Protocol
```dart
// lib/protocols/module_sync.dart
class ModuleSynchronizationProtocol {
  static const Duration SYNC_TIMEOUT = Duration(seconds: 30);

  static Future<void> synchronizeModules({
    required String sourceModuleId,
    required Map<String, dynamic> syncData,
    required SousChefEventBus eventBus,
  }) async {
    try {
      // 1. 타겟 모듈 목록 가져오기
      final targetModules = ModuleManager.getAvailableModules()
        .where((id) => id != sourceModuleId)
        .toList();

      // 2. 각 모듈에 동기화 요청
      final syncFutures = targetModules.map((targetModuleId) {
        return _syncWithModule(
          sourceModuleId: sourceModuleId,
          targetModuleId: targetModuleId,
          syncData: syncData,
          eventBus: eventBus,
        );
      });

      // 3. 모든 동기화 완료 대기
      await Future.wait(syncFutures, timeout: SYNC_TIMEOUT);

      // 4. 동기화 완료 이벤트 발행
      eventBus.publish(
        'modules:sync_completed',
        {
          'sourceModule': sourceModuleId,
          'targetModules': targetModules,
          'timestamp': DateTime.now(),
        }
      );

    } catch (e) {
      // 5. 에러 처리
      eventBus.publishError('module_sync', e);
    }
  }

  static Future<void> _syncWithModule({
    required String sourceModuleId,
    required String targetModuleId,
    required Map<String, dynamic> syncData,
    required SousChefEventBus eventBus,
  }) async {
    final completer = Completer<void>();

    // 타임아웃 타이머
    Timer timeoutTimer = Timer(SYNC_TIMEOUT, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Module sync timeout: $targetModuleId')
        );
      }
    });

    // 응답 대기
    final subscription = eventBus.subscribe<Map<String, dynamic>>(
      'module:$targetModuleId:sync_response',
    ).listen((response) {
      if (response['sourceModule'] == sourceModuleId) {
        timeoutTimer.cancel();
        if (response['success'] == true) {
          completer.complete();
        } else {
          completer.completeError(
            Exception('Module sync failed: ${response['error']}')
          );
        }
      }
    });

    // 동기화 요청 전송
    eventBus.publish(
      'module:$targetModuleId:sync_request',
      {
        'sourceModule': sourceModuleId,
        'syncData': syncData,
        'timestamp': DateTime.now(),
      }
    );

    await completer.future;
    subscription.cancel();
  }
}
```

## 📊 에러 처리 및 복구

### 1. 에러 처리 프로토콜

#### Error Recovery Protocol
```dart
// lib/protocols/error_recovery.dart
class ErrorRecoveryProtocol {
  static const int MAX_RETRY_COUNT = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);

  static Future<void> handleCommunicationError({
    required String operationId,
    required dynamic error,
    required SousChefEventBus eventBus,
    required Future<void> Function() retryOperation,
  }) async {
    try {
      // 1. 에러 로깅
      Logger.error('Communication error in $operationId: $error');

      // 2. 에러 이벤트 발행
      eventBus.publish(
        SousChefEvent.systemError.name,
        {
          'operationId': operationId,
          'error': error.toString(),
          'timestamp': DateTime.now(),
        }
      );

      // 3. 재시도 로직
      await _retryWithBackoff(
        operationId: operationId,
        retryOperation: retryOperation,
        eventBus: eventBus,
      );

    } catch (e) {
      // 4. 최종 실패 처리
      await _handleFinalFailure(operationId, error, eventBus);
    }
  }

  static Future<void> _retryWithBackoff({
    required String operationId,
    required Future<void> Function() retryOperation,
    required SousChefEventBus eventBus,
  }) async {
    for (int attempt = 1; attempt <= MAX_RETRY_COUNT; attempt++) {
      try {
        // 재시도 전 대기
        if (attempt > 1) {
          await Future.delayed(RETRY_DELAY * attempt);
        }

        // 재시도 이벤트 발행
        eventBus.publish(
          'system:retry',
          {
            'operationId': operationId,
            'attempt': attempt,
            'timestamp': DateTime.now(),
          }
        );

        // 재시도 실행
        await retryOperation();

        // 성공 시 이벤트 발행
        eventBus.publish(
          'system:retry_success',
          {
            'operationId': operationId,
            'attempt': attempt,
            'timestamp': DateTime.now(),
          }
        );

        return; // 성공 시 종료

      } catch (e) {
        // 재시도 실패
        eventBus.publish(
          'system:retry_failed',
          {
            'operationId': operationId,
            'attempt': attempt,
            'error': e.toString(),
            'timestamp': DateTime.now(),
          }
        );

        // 마지막 시도에서 실패 시 에러 전파
        if (attempt == MAX_RETRY_COUNT) {
          throw e;
        }
      }
    }
  }

  static Future<void> _handleFinalFailure(
    String operationId,
    dynamic error,
    SousChefEventBus eventBus,
  ) async {
    // 최종 실패 이벤트 발행
    eventBus.publish(
      SousChefEvent.systemError.name,
      {
        'operationId': operationId,
        'error': error.toString(),
        'finalFailure': true,
        'timestamp': DateTime.now(),
      }
    );

    // 폴백 모드로 전환 요청
    eventBus.publish(
      'system:fallback_request',
      {
        'operationId': operationId,
        'reason': 'max_retry_exceeded',
        'timestamp': DateTime.now(),
      }
    );
  }
}
```

## 🎯 결론

### 통신 프로토콜의 이점

✅ **실시간 동기화** - 이벤트 기반 실시간 데이터 교환
✅ **모듈 독립성** - 각 모듈의 독립적 통신 보장
✅ **에러 복구** - 자동 재시도 및 폴백 메커니즘
✅ **확장성** - 새로운 이벤트와 프로토콜 쉽게 추가
✅ **일관성** - 표준화된 통신 방식
✅ **디버깅 용이성** - 이벤트 추적 및 로깅

### 구현 우선순위

1. **코어 이벤트 시스템** (EventBus, Event Types)
2. **기본 통신 인터페이스** (ModuleCommunicator)
3. **레시피 동기화 프로토콜** (RecipeSynchronizationProtocol)
4. **분석 피드백 프로토콜** (AnalysisFeedbackProtocol)
5. **모듈 동기화 프로토콜** (ModuleSynchronizationProtocol)
6. **에러 처리 시스템** (ErrorRecoveryProtocol)

## 🔐 보안 강화 통신 프로토콜

### 1. 암호화된 이벤트 통신

#### SecureEventBus - 암호화된 이벤트 버스
```dart
// lib/communication/secure_event_bus.dart
class SecureEventBus extends SousChefEventBus {
  final DataEncryptionManager _encryptionManager;
  final ModuleSecurityManager _securityManager;

  SecureEventBus({
    required DataEncryptionManager encryptionManager,
    required ModuleSecurityManager securityManager,
  }) : _encryptionManager = encryptionManager,
       _securityManager = securityManager;

  @override
  void publish<T>(String event, T data) async {
    try {
      // 1. 이벤트 데이터 검증
      await _validateEvent(event, data);

      // 2. 민감한 데이터 암호화
      final encryptedData = await _encryptSensitiveData(event, data);

      // 3. 보안 이벤트 발행
      super.publish(event, encryptedData);

      // 4. 감사 로그 기록
      await _logSecurityEvent(event, 'publish');

    } catch (e) {
      // 보안 에러 처리
      await _handleSecurityError(event, e);
    }
  }

  Future<void> _validateEvent(String event, dynamic data) async {
    // 이벤트 권한 검증
    final moduleId = _extractModuleId(event);
    if (moduleId != null) {
      final hasPermission = await _securityManager.checkModulePermission(
        moduleId,
        'publish:$event'
      );

      if (!hasPermission) {
        throw SecurityException('Insufficient permissions for event: $event');
      }
    }
  }

  Future<dynamic> _encryptSensitiveData(String event, dynamic data) async {
    // 민감한 이벤트 데이터 암호화
    final sensitiveEvents = [
      'recipe:personal_data',
      'user:preferences',
      'analysis:sensitive_info'
    ];

    if (sensitiveEvents.contains(event)) {
      final key = await _encryptionManager.generateSecureKey();
      return await _encryptionManager.encryptData(data.toString(), key);
    }

    return data;
  }

  String? _extractModuleId(String event) {
    final moduleMatch = RegExp(r'module:([^:]+)').firstMatch(event);
    return moduleMatch?.group(1);
  }
}
```

### 2. 이벤트 접근 제어

#### EventAccessController - 이벤트 접근 제어기
```dart
// lib/communication/event_access_controller.dart
class EventAccessController {
  static final Map<String, EventPermissions> _eventPermissions = {
    // 공개 이벤트
    'system:heartbeat': EventPermissions.public(),
    'system:status': EventPermissions.public(),

    // 인증 필요 이벤트
    'recipe:update': EventPermissions.authenticated(),
    'analysis:start': EventPermissions.authenticated(),

    // 모듈별 이벤트
    'module:bread:*': EventPermissions.moduleSpecific('bread'),
    'module:cake:*': EventPermissions.moduleSpecific('cake'),

    // 관리자 전용 이벤트
    'admin:*': EventPermissions.adminOnly(),
  };

  static Future<bool> canAccessEvent({
    required String event,
    required String? moduleId,
    required UserRole userRole,
  }) async {
    final permissions = _getEventPermissions(event);

    switch (permissions.level) {
      case PermissionLevel.public:
        return true;

      case PermissionLevel.authenticated:
        return userRole != UserRole.guest;

      case PermissionLevel.moduleSpecific:
        return permissions.allowedModules.contains(moduleId);

      case PermissionLevel.adminOnly:
        return userRole == UserRole.admin;

      default:
        return false;
    }
  }

  static EventPermissions _getEventPermissions(String event) {
    // 정확한 이벤트 매칭
    if (_eventPermissions.containsKey(event)) {
      return _eventPermissions[event]!;
    }

    // 와일드카드 매칭
    for (final pattern in _eventPermissions.keys) {
      if (pattern.contains('*')) {
        final regex = RegExp(pattern.replaceAll('*', '.*'));
        if (regex.hasMatch(event)) {
          return _eventPermissions[pattern]!;
        }
      }
    }

    // 기본값: 인증 필요
    return EventPermissions.authenticated();
  }
}

class EventPermissions {
  final PermissionLevel level;
  final List<String> allowedModules;

  const EventPermissions({
    required this.level,
    this.allowedModules = const [],
  });

  factory EventPermissions.public() => const EventPermissions(level: PermissionLevel.public);
  factory EventPermissions.authenticated() => const EventPermissions(level: PermissionLevel.authenticated);
  factory EventPermissions.moduleSpecific(String module) => EventPermissions(
    level: PermissionLevel.moduleSpecific,
    allowedModules: [module],
  );
  factory EventPermissions.adminOnly() => const EventPermissions(level: PermissionLevel.adminOnly);
}

enum PermissionLevel {
  public,
  authenticated,
  moduleSpecific,
  adminOnly,
}

enum UserRole {
  guest,
  user,
  premium,
  admin,
}
```

## 📊 성능 최적화 통신

### 1. 이벤트 배치 처리

#### EventBatcher - 이벤트 배치 처리기
```dart
// lib/communication/event_batcher.dart
class EventBatcher {
  static const Duration BATCH_INTERVAL = Duration(milliseconds: 100);
  static const int MAX_BATCH_SIZE = 10;

  final SousChefEventBus _eventBus;
  final Map<String, List<QueuedEvent>> _eventQueue = {};
  Timer? _batchTimer;

  EventBatcher({required SousChefEventBus eventBus}) : _eventBus = eventBus {
    _startBatchTimer();
  }

  void queueEvent<T>(String event, T data, {bool highPriority = false}) {
    if (highPriority) {
      // 즉시 처리
      _eventBus.publish(event, data);
      return;
    }

    _eventQueue.putIfAbsent(event, () => []);
    _eventQueue[event]!.add(QueuedEvent(data: data, timestamp: DateTime.now()));

    // 배치 크기 제한 확인
    if (_eventQueue[event]!.length >= MAX_BATCH_SIZE) {
      _flushEvent(event);
    }
  }

  void _startBatchTimer() {
    _batchTimer = Timer.periodic(BATCH_INTERVAL, (_) {
      _flushAllEvents();
    });
  }

  void _flushEvent(String event) {
    final events = _eventQueue[event];
    if (events != null && events.isNotEmpty) {
      // 이벤트들을 하나의 배치로 묶어서 전송
      final batchData = events.map((e) => e.data).toList();
      _eventBus.publish('${event}:batch', batchData);

      _eventQueue[event]!.clear();
    }
  }

  void _flushAllEvents() {
    for (final event in _eventQueue.keys.toList()) {
      _flushEvent(event);
    }
  }

  void dispose() {
    _batchTimer?.cancel();
    _flushAllEvents();
  }
}

class QueuedEvent {
  final dynamic data;
  final DateTime timestamp;

  const QueuedEvent({
    required this.data,
    required this.timestamp,
  });
}
```

### 2. 이벤트 필터링 및 최적화

#### EventOptimizer - 이벤트 최적화기
```dart
// lib/communication/event_optimizer.dart
class EventOptimizer {
  final Map<String, EventStats> _eventStats = {};
  final Map<String, DateTime> _lastEventTime = {};

  // 이벤트 중복 제거
  bool shouldSkipEvent(String event, dynamic data) {
    final lastTime = _lastEventTime[event];
    final now = DateTime.now();

    // 같은 이벤트가 100ms 이내에 발생하면 스킵
    if (lastTime != null && now.difference(lastTime).inMilliseconds < 100) {
      return true;
    }

    _lastEventTime[event] = now;
    return false;
  }

  // 이벤트 압축
  Map<String, dynamic> compressEventData(String event, dynamic data) {
    // 자주 사용하는 이벤트들 압축
    switch (event) {
      case 'recipe:ingredient_changed':
        return _compressIngredientData(data);
      case 'analysis:progress':
        return _compressProgressData(data);
      default:
        return data;
    }
  }

  Map<String, dynamic> _compressIngredientData(dynamic data) {
    // 재료 데이터 압축 로직
    return {
      'id': data['id'],
      'change': data['change'],
      // 불필요한 필드 제거
    };
  }

  Map<String, dynamic> _compressProgressData(dynamic data) {
    // 진행률 데이터 압축 로직
    return {
      'progress': data['progress'],
      'step': data['step'],
      // 타임스탬프 등 불필요한 필드 제거
    };
  }

  // 이벤트 통계 수집
  void recordEventStats(String event, int processingTime) {
    _eventStats.putIfAbsent(event, () => EventStats());
    _eventStats[event]!.recordProcessingTime(processingTime);
  }

  EventStats? getEventStats(String event) => _eventStats[event];
}

class EventStats {
  int totalEvents = 0;
  int totalProcessingTime = 0;
  int maxProcessingTime = 0;
  int minProcessingTime = int.maxFinite;

  void recordProcessingTime(int time) {
    totalEvents++;
    totalProcessingTime += time;
    maxProcessingTime = math.max(maxProcessingTime, time);
    minProcessingTime = math.min(minProcessingTime, time);
  }

  double get averageProcessingTime =>
    totalEvents > 0 ? totalProcessingTime / totalEvents : 0.0;
}
```

## 🚨 고급 오류 처리 및 복구

### 1. 분산 시스템 오류 복구

#### DistributedErrorRecovery - 분산 오류 복구
```dart
// lib/communication/distributed_error_recovery.dart
class DistributedErrorRecovery {
  final Map<String, NodeStatus> _nodeStatus = {};
  final Map<String, List<String>> _nodeDependencies = {};

  void registerNode(String nodeId, List<String> dependencies) {
    _nodeStatus[nodeId] = NodeStatus.healthy;
    _nodeDependencies[nodeId] = dependencies;
  }

  Future<void> handleNodeFailure(String failedNodeId) async {
    try {
      // 1. 종속 노드 식별
      final affectedNodes = _getAffectedNodes(failedNodeId);

      // 2. 상태 업데이트
      _nodeStatus[failedNodeId] = NodeStatus.failed;

      // 3. 종속 노드에 알림
      for (final nodeId in affectedNodes) {
        await _notifyNodeFailure(nodeId, failedNodeId);
      }

      // 4. 복구 전략 실행
      await _executeRecoveryStrategy(failedNodeId, affectedNodes);

    } catch (e) {
      Logger.error('Error recovery failed for node $failedNodeId: $e');
    }
  }

  List<String> _getAffectedNodes(String failedNodeId) {
    return _nodeDependencies.entries
      .where((entry) => entry.value.contains(failedNodeId))
      .map((entry) => entry.key)
      .toList();
  }

  Future<void> _notifyNodeFailure(String nodeId, String failedNodeId) async {
    SousChefEventBus().publish('node:failure_notification', {
      'targetNode': nodeId,
      'failedNode': failedNodeId,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _executeRecoveryStrategy(
    String failedNodeId,
    List<String> affectedNodes
  ) async {
    // 1. 폴백 모드 활성화
    await _activateFallbackMode(failedNodeId);

    // 2. 영향을 받는 노드 재시작
    for (final nodeId in affectedNodes) {
      await _restartNode(nodeId);
    }

    // 3. 시스템 상태 검증
    await _validateSystemState();
  }

  Future<void> _activateFallbackMode(String nodeId) async {
    // 노드별 폴백 전략
    switch (nodeId) {
      case 'bread_module':
        await _activateBreadFallback();
        break;
      case 'recipe_sync':
        await _activateRecipeSyncFallback();
        break;
      default:
        Logger.warning('No fallback strategy for node: $nodeId');
    }
  }

  Future<void> _restartNode(String nodeId) async {
    SousChefEventBus().publish('node:restart_request', {
      'nodeId': nodeId,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _validateSystemState() async {
    // 시스템 상태 검증 로직
    final healthyNodes = _nodeStatus.values.where((status) => status == NodeStatus.healthy).length;
    final totalNodes = _nodeStatus.length;

    if (healthyNodes / totalNodes < 0.8) {
      SousChefEventBus().publish('system:degraded_state', {
        'healthyNodes': healthyNodes,
        'totalNodes': totalNodes,
        'timestamp': DateTime.now(),
      });
    }
  }
}

enum NodeStatus {
  healthy,
  degraded,
  failed,
  recovering,
}
```

### 2. 예측 기반 오류 방지

#### ErrorPredictionEngine - 오류 예측 엔진
```dart
// lib/communication/error_prediction_engine.dart
class ErrorPredictionEngine {
  final Map<String, ErrorPattern> _errorPatterns = {};
  final Map<String, List<DateTime>> _errorHistory = {};

  void recordError(String errorType, String context, DateTime timestamp) {
    _errorHistory.putIfAbsent(errorType, () => []);
    _errorHistory[errorType]!.add(timestamp);

    // 오래된 기록 정리 (7일)
    _cleanupOldRecords(errorType);
  }

  double predictErrorProbability(String errorType, Duration timeWindow) {
    final history = _errorHistory[errorType];
    if (history == null || history.isEmpty) return 0.0;

    final recentErrors = history.where((time) =>
      DateTime.now().difference(time) <= timeWindow
    ).length;

    final hours = timeWindow.inHours;
    return hours > 0 ? recentErrors / hours : 0.0;
  }

  List<String> getHighRiskContexts() {
    return _errorHistory.entries
      .where((entry) => predictErrorProbability(entry.key, Duration(hours: 1)) > 0.1)
      .map((entry) => entry.key)
      .toList();
  }

  void _cleanupOldRecords(String errorType) {
    final history = _errorHistory[errorType];
    if (history != null) {
      final cutoff = DateTime.now().subtract(Duration(days: 7));
      history.removeWhere((time) => time.isBefore(cutoff));
    }
  }
}

class ErrorPattern {
  final String pattern;
  final double frequency;
  final Duration averageInterval;

  const ErrorPattern({
    required this.pattern,
    required this.frequency,
    required this.averageInterval,
  });
}
```

## 📈 모니터링 및 디버깅

### 1. 실시간 통신 모니터링

#### CommunicationMonitor - 통신 모니터링
```dart
// lib/communication/communication_monitor.dart
class CommunicationMonitor {
  final Map<String, CommunicationMetrics> _metrics = {};

  void recordEvent(String event, String sender, String receiver, int dataSize) {
    _metrics.putIfAbsent(event, () => CommunicationMetrics());

    final metric = _metrics[event]!;
    metric.totalEvents++;
    metric.totalDataSize += dataSize;
    metric.lastActivity = DateTime.now();

    if (metric.averageDataSize == 0) {
      metric.averageDataSize = dataSize;
    } else {
      metric.averageDataSize = (metric.averageDataSize + dataSize) ~/ 2;
    }
  }

  void recordLatency(String event, Duration latency) {
    final metric = _metrics[event];
    if (metric != null) {
      metric.lastLatency = latency;
      if (metric.averageLatency == null) {
        metric.averageLatency = latency;
      } else {
        // 이동 평균 계산
        metric.averageLatency = (metric.averageLatency! + latency) ~/ 2;
      }
    }
  }

  void recordError(String event, String error) {
    final metric = _metrics[event];
    if (metric != null) {
      metric.errorCount++;
      metric.lastError = error;
    }
  }

  Map<String, CommunicationMetrics> getAllMetrics() => Map.from(_metrics);

  List<String> getHighLatencyEvents() {
    return _metrics.entries
      .where((entry) => entry.value.averageLatency?.inMilliseconds ?? 0 > 100)
      .map((entry) => entry.key)
      .toList();
  }

  List<String> getHighErrorRateEvents() {
    return _metrics.entries
      .where((entry) {
        final metric = entry.value;
        return metric.totalEvents > 0 &&
               (metric.errorCount / metric.totalEvents) > 0.1;
      })
      .map((entry) => entry.key)
      .toList();
  }
}

class CommunicationMetrics {
  int totalEvents = 0;
  int totalDataSize = 0;
  int averageDataSize = 0;
  Duration? averageLatency;
  Duration? lastLatency;
  DateTime? lastActivity;
  int errorCount = 0;
  String? lastError;
}
```

이 통신 프로토콜을 통해 메인 앱, 수쉐프 모드, 각 모듈 간의 완벽한 통합과 실시간 동기화를 달성할 수 있습니다. 보안 강화, 성능 최적화, 고급 오류 처리 기능을 통해 안정적이고 효율적인 통신 시스템을 구축했습니다.
