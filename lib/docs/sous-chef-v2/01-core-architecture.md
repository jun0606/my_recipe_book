# 01. 코어 아키텍처 설계

## 📋 개요

수쉐프 모드 v2.0의 코어 아키텍처는 메인 앱과의 완벽한 통합과 확장성을 고려하여 설계되었습니다.

## 🏗️ 아키텍처 개요

### 계층 구조
```
┌─────────────────────────────────────┐
│              UI Layer               │
│  - Dynamic Components               │
│  - Module Adapters                  │
│  - Event Handlers                   │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│        Module Layer                 │
│  - Bread Module                     │
│  - Cake Module                      │
│  - Cookie Module                    │
│  - Dessert Module                   │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│     Communication Layer             │
│  - Event Bus                        │
│  - Data Synchronizers               │
│  - Module Bridges                   │
└─────────────────────────────────────┘
                    │
┌─────────────────────────────────────┐
│        Core Layer                   │
│  - Unified Types                    │
│  - Base Interfaces                  │
│  - Core Services                    │
└─────────────────────────────────────┘
```

## 🎯 설계 원칙

### 1. 단일 책임 원칙 (SRP)
```dart
// 각 계층은 명확한 책임을 가짐
class RecipeProvider // 데이터 관리
class ModuleManager  // 모듈 관리
class EventBus       // 통신 관리
class DynamicUI      // UI 관리
```

### 2. 의존성 역전 원칙 (DIP)
```dart
// 구체적인 구현이 아닌 인터페이스에 의존
abstract class SousChefModule {
  Future<AnalysisResult> analyze(UnifiedRecipe recipe);
}

class BreadModule implements SousChefModule {
  // 구체적인 구현
}
```

### 3. 개방-폐쇄 원칙 (OCP)
```dart
// 확장에는 열려있고, 수정에는 닫혀있음
class ModuleRegistry {
  static final Map<String, SousChefModule> _modules = {};

  static void registerModule(String id, SousChefModule module) {
    _modules[id] = module; // 확장 가능
  }

  // 기존 코드 수정 없이 새로운 모듈 추가 가능
}
```

## 🔧 코어 컴포넌트

### 1. 통합 타입 시스템
```dart
// lib/types/sous_chef_types.dart
class UnifiedRecipe {
  final String id;
  final String title;
  final List<UnifiedIngredient> ingredients;
  final List<UnifiedProcess> processes;
  final EquipmentConfig equipment;
  final ModuleMetadata metadata;

  // 수쉐프 모듈이 참조할 수 있는 확장 데이터
  final BreadRequirements? breadReq;
  final CakeRequirements? cakeReq;
  final CookieRequirements? cookieReq;
  final DessertRequirements? dessertReq;
}

class UnifiedIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final Map<String, dynamic> properties;
}

class UnifiedProcess {
  final String id;
  final String name;
  final String type; // 'mixing', 'kneading', 'fermentation', etc.
  final Duration duration;
  final Map<String, dynamic> parameters;
}
```

### 2. 모듈 인터페이스
```dart
// lib/modules/base_module.dart
abstract class SousChefModule {
  String get moduleId;
  String get displayName;
  IconData get icon;
  Color get themeColor;

  // 모듈 능력 정의
  ModuleCapabilities get capabilities;

  // 레시피 처리 가능 여부
  bool canHandleRecipe(UnifiedRecipe recipe);

  // 분석 실행
  Future<AnalysisResult> analyze(UnifiedRecipe recipe);

  // UI 컴포넌트 생성
  List<Widget> buildAnalysisUI(AnalysisResult result);
  List<Widget> buildAdviceUI(AnalysisResult result);
  List<Widget> buildImprovementUI(AnalysisResult result);
}

class ModuleCapabilities {
  final bool supportsRealTimeAnalysis;
  final bool supportsRecipeModification;
  final List<String> supportedProcessTypes;
  final Map<String, dynamic> moduleConfig;
}
```

### 3. 이벤트 기반 통신 시스템
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
}

// 이벤트 타입 정의
enum SousChefEvent {
  recipeUpdated,
  moduleSwitched,
  analysisCompleted,
  adviceRequested,
  recipeModified,
}
```

### 4. 모듈 관리자
```dart
// lib/modules/module_manager.dart
class ModuleManager {
  static final Map<String, SousChefModule> _modules = {};
  static final Map<String, ModuleState> _moduleStates = {};

  static void registerModule(String id, SousChefModule module) {
    _modules[id] = module;
    _moduleStates[id] = ModuleState.inactive;
  }

  static SousChefModule? getModule(String id) {
    return _modules[id];
  }

  static List<String> getAvailableModules() {
    return _modules.keys.toList();
  }

  static Future<void> activateModule(String id) async {
    if (_modules.containsKey(id)) {
      _moduleStates[id] = ModuleState.active;
      SousChefEventBus.publish(
        SousChefEvent.moduleSwitched,
        ModuleSwitchEvent(id, ModuleState.active)
      );
    }
  }

  static Future<void> deactivateModule(String id) async {
    if (_modules.containsKey(id)) {
      _moduleStates[id] = ModuleState.inactive;
      // 리소스 정리
      await _cleanupModuleResources(id);
    }
  }
}
```

## 🔄 데이터 흐름

### 레시피 → 수쉐프 모드
```
Recipe (Main App)
    ↓
Recipe Adapter
    ↓
UnifiedRecipe
    ↓
Module Selection
    ↓
Selected Module Analysis
    ↓
Analysis Result
    ↓
UI Components
    ↓
User Interaction
```

### 수쉐프 모드 → 메인 앱
```
User Action
    ↓
Module Analysis
    ↓
Recipe Modification
    ↓
UnifiedRecipe Update
    ↓
Recipe Adapter
    ↓
Recipe (Main App)
```

## 📊 성능 고려사항

### 1. 메모리 관리
```dart
class ModuleState {
  static const inactive = 'inactive';
  static const active = 'active';
  static const suspended = 'suspended';
}

// 비활성 모듈은 메모리에서 해제
class ModuleLifecycleManager {
  static void optimizeMemory() {
    ModuleManager.getAvailableModules().forEach((moduleId) {
      if (ModuleManager.getModuleState(moduleId) == ModuleState.inactive) {
        ModuleManager.suspendModule(moduleId);
      }
    });
  }
}
```

### 2. 비동기 처리
```dart
// 모든 분석은 비동기로 처리
class AsyncAnalysisManager {
  static Future<AnalysisResult> analyzeWithTimeout(
    SousChefModule module,
    UnifiedRecipe recipe, {
    Duration timeout = const Duration(seconds: 30)
  }) async {
    return await module.analyze(recipe).timeout(
      timeout,
      onTimeout: () => AnalysisResult.timeout()
    );
  }
}
```

## 🔒 안정성 보장

### 1. 에러 처리
```dart
class ModuleErrorHandler {
  static void handleModuleError(String moduleId, dynamic error) {
    // 에러 로깅
    Logger.error('Module $moduleId error: $error');

    // 폴백 모듈로 전환
    if (error is CriticalError) {
      ModuleManager.switchToFallbackModule();
    }

    // 사용자에게 알림
    SousChefEventBus.publish(
      SousChefEvent.analysisError,
      ErrorEvent(moduleId, error)
    );
  }
}
```

### 2. 상태 복구
```dart
class StateRecoveryManager {
  static Future<void> recoverModuleState(String moduleId) async {
    try {
      // 마지막으로 저장된 상태 복구
      final savedState = await _loadModuleState(moduleId);
      await ModuleManager.restoreModuleState(moduleId, savedState);
    } catch (e) {
      // 복구 실패 시 초기화
      await ModuleManager.resetModule(moduleId);
    }
  }
}
```

## 🔐 보안 및 권한 관리

### 1. 모듈 권한 시스템
```dart
class ModulePermissions {
  final bool canAccessUserData;
  final bool canAccessRecipeData;
  final bool canAccessDeviceSensors;
  final bool canAccessNetwork;
  final bool canAccessStorage;
  final Map<String, dynamic> customPermissions;

  const ModulePermissions({
    this.canAccessUserData = false,
    this.canAccessRecipeData = true,
    this.canAccessDeviceSensors = false,
    this.canAccessNetwork = false,
    this.canAccessStorage = false,
    this.customPermissions = const {},
  });
}

class ModuleSecurityManager {
  static Future<bool> checkModulePermission(
    String moduleId,
    String permission
  ) async {
    final module = ModuleManager.getModule(moduleId);
    if (module == null) return false;

    final permissions = module.capabilities.permissions;
    return permissions[permission] ?? false;
  }

  static Future<void> requestPermission(
    String moduleId,
    String permission
  ) async {
    final hasPermission = await checkModulePermission(moduleId, permission);

    if (!hasPermission) {
      throw PermissionDeniedException(moduleId, permission);
    }
  }
}
```

### 2. 데이터 암호화
```dart
class DataEncryptionManager {
  static Future<String> encryptData(String data, String key) async {
    // AES-256 암호화
    final encrypter = Encrypter(AES(Key.fromUtf8(key)));
    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;
  }

  static Future<String> decryptData(String encryptedData, String key) async {
    // AES-256 복호화
    final encrypter = Encrypter(AES(Key.fromUtf8(key)));
    final decrypted = encrypter.decrypt64(encryptedData);
    return decrypted;
  }

  static String generateSecureKey() {
    return base64Url.encode(secureRandom(32));
  }
}
```

### 3. 사용자 데이터 보호
```dart
class UserDataProtectionManager {
  static Future<void> anonymizeUserData(Map<String, dynamic> data) async {
    // 개인정보 제거
    data.remove('email');
    data.remove('phone');
    data.remove('name');

    // ID 해싱
    if (data.containsKey('userId')) {
      data['userId'] = hashUserId(data['userId']);
    }
  }

  static String hashUserId(String userId) {
    return sha256.convert(utf8.encode(userId)).toString();
  }

  static Future<bool> validateDataAccess(String moduleId, String dataType) async {
    // 데이터 접근 권한 검증
    return await ModuleSecurityManager.checkModulePermission(
      moduleId,
      'access_$dataType'
    );
  }
}
```

## 📊 성능 최적화 전략

### 1. 메모리 관리
```dart
class MemoryOptimizationManager {
  static final Map<String, WeakReference> _objectPool = {};

  static T? getFromPool<T>(String key) {
    final ref = _objectPool[key];
    if (ref != null && ref.target != null) {
      return ref.target as T;
    }
    return null;
  }

  static void addToPool(String key, dynamic object) {
    _objectPool[key] = WeakReference(object);
  }

  static void clearPool() {
    _objectPool.clear();
  }

  static void optimizeMemory() {
    // 사용하지 않는 객체 정리
    _objectPool.removeWhere((key, ref) => ref.target == null);
  }
}
```

### 2. 캐시 전략
```dart
class CacheManager {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration DEFAULT_TTL = Duration(minutes: 30);

  static Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    return null;
  }

  static Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
  }) async {
    _cache[key] = CacheEntry(
      data: data,
      expiryTime: DateTime.now().add(ttl ?? DEFAULT_TTL),
    );
  }

  static void clearExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  static void clearAll() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiryTime;

  const CacheEntry({
    required this.data,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
```

### 3. 성능 모니터링
```dart
class PerformanceMonitor {
  static final Map<String, PerformanceMetrics> _metrics = {};

  static void startMeasurement(String operationId) {
    _metrics[operationId] = PerformanceMetrics.start();
  }

  static void endMeasurement(String operationId) {
    final metrics = _metrics[operationId];
    if (metrics != null) {
      metrics.end();

      // 성능 이벤트 발행
      SousChefEventBus.publish(
        'performance:measurement',
        {
          'operationId': operationId,
          'duration': metrics.duration,
          'memoryUsage': metrics.memoryUsage,
          'cpuUsage': metrics.cpuUsage,
        }
      );
    }
  }

  static PerformanceMetrics? getMetrics(String operationId) {
    return _metrics[operationId];
  }
}
```

## 🚨 오류 처리 전략

### 1. 예측 가능한 오류 시나리오
```dart
// 네트워크 오류
class NetworkErrorHandler {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxAttempts) rethrow;

        if (e is NetworkError) {
          await Future.delayed(delay * attempt);
        } else {
          rethrow;
        }
      }
    }
    throw MaxRetriesExceededError(maxAttempts);
  }
}

// 저장소 부족
class StorageErrorHandler {
  static Future<void> ensureStorageSpace(int requiredBytes) async {
    final availableSpace = await getAvailableStorage();

    if (availableSpace < requiredBytes) {
      throw InsufficientStorageError(requiredBytes, availableSpace);
    }
  }

  static Future<void> cleanupStorage() async {
    // 임시 파일 정리
    await clearTempFiles();

    // 오래된 캐시 정리
    CacheManager.clearExpired();

    // 불필요한 데이터 정리
    await clearUnusedData();
  }
}

// 디바이스 호환성
class DeviceCompatibilityChecker {
  static Future<bool> checkMinimumRequirements() async {
    final deviceInfo = await getDeviceInfo();

    // 최소 RAM 요구사항 (512MB)
    if (deviceInfo.ramSize < 512 * 1024 * 1024) {
      return false;
    }

    // 최소 저장소 요구사항 (100MB)
    if (deviceInfo.storageSize < 100 * 1024 * 1024) {
      return false;
    }

    // 최소 Android API 레벨
    if (deviceInfo.platform == 'android' && deviceInfo.apiLevel < 21) {
      return false;
    }

    return true;
  }
}
```

### 2. 사용자 경험 고려사항
```dart
class UserExperienceManager {
  static Future<void> showLoadingState(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(),
    );
  }

  static Future<void> hideLoadingState(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('재시도'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  static Future<void> showOfflineMode(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오프라인 모드'),
        content: const Text('네트워크에 연결되어 있지 않습니다. 일부 기능이 제한될 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 결론

이 코어 아키텍처는 다음과 같은 목표를 달성합니다:

✅ **메인 앱과의 완벽한 통합** - 통합 타입 시스템
✅ **확장 가능한 모듈 시스템** - 플러그인 기반 아키텍처
✅ **실시간 데이터 동기화** - 이벤트 기반 통신
✅ **코드 중복 제거** - 범용 컴포넌트 시스템
✅ **높은 유지보수성** - 명확한 책임 분리
✅ **안정성 보장** - 에러 처리 및 상태 복구

이 아키텍처를 기반으로 각 모듈을 독립적으로 개발하고, 필요에 따라 쉽게 확장할 수 있습니다.
