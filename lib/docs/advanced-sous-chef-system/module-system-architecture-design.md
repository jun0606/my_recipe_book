# 🏗️ 모듈 시스템 아키텍처 상세 설계

## 📋 목차
1. 모듈 시스템 개요
2. 모듈 인터페이스 설계
3. 모듈 관리자 아키텍처
4. 모듈 간 통신 및 데이터 공유
5. 모듈 확장성 및 플러그인 시스템
6. 모듈 테스트 및 검증
7. 모듈 배포 및 업데이트

## 1. 모듈 시스템 개요

### 1.1 시스템 목표
수쉐프 모드의 모든 베이킹 모듈(빵, 케이크, 쿠키, 디저트)을 통합 관리하고, 각 모듈이 독립적으로 개발/배포/업데이트될 수 있도록 하는 모듈화된 아키텍처 구축

### 1.2 주요 요구사항
- 모듈 간 독립성 보장
- 런타임 모듈 로딩/언로딩
- 모듈 간 안전한 데이터 공유
- 확장 가능한 플러그인 시스템
- 모듈 버전 관리 및 호환성

## 2. 모듈 인터페이스 설계

### 2.1 기본 모듈 인터페이스
```dart
abstract class BakingModule {
  // 모듈 식별 정보
  String get moduleId;
  String get moduleName;
  String get moduleDescription;
  String get moduleVersion;
  ModuleType get moduleType;
  int get supportedApiVersion;

  // 모듈 수명주기
  Future<void> initialize(ModuleContext context);
  Future<void> dispose();

  // 모듈 기능
  bool canHandleRecipe(RecipeData recipe);
  Future<ModuleAnalysisResult> analyzeRecipe(RecipeData recipe, UserData userData);

  // UI 제공
  Widget buildAnalysisTab(RecipeData recipe, UserData userData);
  Widget buildImprovementTab(RecipeData recipe, UserData userData);
  Widget buildRealTimeRecipeTab(RecipeData recipe, UserData userData);

  // 모듈 메타데이터
  ModuleMetadata get metadata;
  List<ModuleDependency> get dependencies;
  ModulePermissions get permissions;
}
```

### 2.2 모듈 타입 정의
```dart
enum ModuleType {
  bread,      // 빵 모듈
  cake,       // 케이크 모듈
  cookie,     // 쿠키 모듈
  dessert,    // 디저트 모듈
  utility,    // 유틸리티 모듈
  custom      // 사용자 정의 모듈
}
```

### 2.3 모듈 메타데이터 구조
```dart
class ModuleMetadata {
  final String id;
  final String name;
  final String description;
  final String version;
  final String author;
  final String website;
  final DateTime createdDate;
  final DateTime lastModified;
  final Map<String, dynamic> properties;

  const ModuleMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    this.website = '',
    required this.createdDate,
    required this.lastModified,
    this.properties = const {},
  });
}
```

### 2.4 모듈 권한 및 보안
```dart
class ModulePermissions {
  final bool canAccessUserData;
  final bool canAccessRecipeData;
  final bool canAccessNetwork;
  final bool canAccessFileSystem;
  final bool canExecuteSystemCommands;
  final List<String> allowedDomains;
  final List<String> allowedFilePaths;

  const ModulePermissions({
    this.canAccessUserData = false,
    this.canAccessRecipeData = true,
    this.canAccessNetwork = false,
    this.canAccessFileSystem = false,
    this.canExecuteSystemCommands = false,
    this.allowedDomains = const [],
    this.allowedFilePaths = const [],
  });
}
```

## 3. 모듈 관리자 아키텍처

### 3.1 모듈 관리자 클래스
```dart
class ModuleManager {
  final Map<String, BakingModule> _loadedModules = {};
  final Map<String, ModuleInfo> _moduleRegistry = {};
  final ModuleSecurityManager _securityManager;
  final ModuleDependencyResolver _dependencyResolver;
  final ModuleUpdateManager _updateManager;

  // 모듈 로딩
  Future<BakingModule?> loadModule(String moduleId) async {
    try {
      // 보안 검증
      await _securityManager.validateModule(moduleId);

      // 의존성 확인
      await _dependencyResolver.resolveDependencies(moduleId);

      // 모듈 인스턴스화
      final module = await _instantiateModule(moduleId);

      // 모듈 초기화
      final context = ModuleContext(
        moduleId: moduleId,
        sharedServices: _getSharedServices(),
        configuration: _getModuleConfiguration(moduleId)
      );

      await module.initialize(context);

      // 모듈 등록
      _loadedModules[moduleId] = module;

      return module;
    } catch (e) {
      await _handleModuleLoadError(moduleId, e);
      return null;
    }
  }

  // 모듈 언로딩
  Future<void> unloadModule(String moduleId) async {
    final module = _loadedModules[moduleId];
    if (module != null) {
      await module.dispose();
      _loadedModules.remove(moduleId);
    }
  }

  // 레시피에 적합한 모듈 찾기
  Future<BakingModule?> findSuitableModule(RecipeData recipe) async {
    for (final module in _loadedModules.values) {
      if (await module.canHandleRecipe(recipe)) {
        return module;
      }
    }
    return null;
  }

  // 모든 활성화된 모듈 가져오기
  List<BakingModule> getActiveModules() {
    return _loadedModules.values.toList();
  }
}
```

### 3.2 모듈 보안 관리자
```dart
class ModuleSecurityManager {
  Future<void> validateModule(String moduleId) async {
    final moduleInfo = await _getModuleInfo(moduleId);

    // 코드 서명 검증
    await _verifyCodeSignature(moduleInfo);

    // 권한 검증
    await _verifyPermissions(moduleInfo.permissions);

    // 신뢰할 수 있는 출처 검증
    await _verifyTrustedSource(moduleInfo.author, moduleInfo.website);

    // 보안 취약점 스캔
    await _scanSecurityVulnerabilities(moduleInfo);
  }

  Future<void> enforceSandbox(String moduleId, BakingModule module) async {
    // 샌드박스 환경 생성
    final sandbox = await _createSandbox(moduleId);

    // 리소스 제한 설정
    await _setResourceLimits(sandbox, module.permissions);

    // 네트워크 액세스 제어
    await _configureNetworkAccess(sandbox, module.permissions.allowedDomains);

    // 파일 시스템 액세스 제어
    await _configureFileAccess(sandbox, module.permissions.allowedFilePaths);
  }
}
```

### 3.3 모듈 의존성 해결사
```dart
class ModuleDependencyResolver {
  Future<void> resolveDependencies(String moduleId) async {
    final moduleInfo = await _getModuleInfo(moduleId);
    final dependencies = moduleInfo.dependencies;

    for (final dependency in dependencies) {
      // 의존 모듈이 로드되어 있는지 확인
      if (!_isModuleLoaded(dependency.id)) {
        // 의존 모듈 로드
        await _loadDependencyModule(dependency);

        // 순환 의존성 검증
        await _checkCircularDependency(moduleId, dependency.id);
      }

      // 버전 호환성 검증
      await _verifyVersionCompatibility(dependency);
    }
  }

  Future<void> _loadDependencyModule(ModuleDependency dependency) async {
    if (dependency.isOptional && !_isModuleAvailable(dependency.id)) {
      // 선택적 의존성이고 모듈을 사용할 수 없는 경우
      _logWarning('Optional dependency ${dependency.id} not available');
      return;
    }

    await _moduleManager.loadModule(dependency.id);
  }

  Future<void> _checkCircularDependency(String moduleId, String dependencyId) async {
    if (await _hasCircularDependency(moduleId, dependencyId)) {
      throw ModuleDependencyException(
        'Circular dependency detected: $moduleId -> $dependencyId'
      );
    }
  }
}
```

## 4. 모듈 간 통신 및 데이터 공유

### 4.1 공유 데이터 버스
```dart
class SharedDataBus {
  final Map<String, dynamic> _sharedData = {};
  final Map<String, List<DataSubscription>> _subscriptions = {};

  // 데이터 발행
  void publish(String channel, dynamic data) {
    _sharedData[channel] = data;

    // 구독자들에게 알림
    final subscriptions = _subscriptions[channel];
    if (subscriptions != null) {
      for (final subscription in subscriptions) {
        subscription.callback(data);
      }
    }
  }

  // 데이터 구독
  DataSubscription subscribe(String channel, DataCallback callback) {
    final subscription = DataSubscription(channel, callback);

    if (_subscriptions[channel] == null) {
      _subscriptions[channel] = [];
    }

    _subscriptions[channel]!.add(subscription);

    // 현재 데이터가 있다면 즉시 전달
    if (_sharedData.containsKey(channel)) {
      callback(_sharedData[channel]);
    }

    return subscription;
  }

  // 데이터 요청
  dynamic request(String channel) {
    return _sharedData[channel];
  }

  // 구독 취소
  void unsubscribe(DataSubscription subscription) {
    final subscriptions = _subscriptions[subscription.channel];
    if (subscriptions != null) {
      subscriptions.remove(subscription);
    }
  }
}
```

### 4.2 모듈 간 메시징 시스템
```dart
class ModuleMessagingSystem {
  final Map<String, ModuleMessageQueue> _messageQueues = {};

  // 모듈 간 메시지 전송
  Future<void> sendMessage(String fromModuleId, String toModuleId, ModuleMessage message) async {
    final queue = _getOrCreateQueue(toModuleId);

    // 메시지 권한 검증
    await _verifyMessagePermission(fromModuleId, toModuleId, message);

    // 메시지 큐에 추가
    await queue.enqueue(message);

    // 즉시 전달 모드인 경우
    if (message.deliveryMode == DeliveryMode.immediate) {
      await _deliverMessage(toModuleId, message);
    }
  }

  // 메시지 수신
  Future<ModuleMessage?> receiveMessage(String moduleId, {Duration? timeout}) async {
    final queue = _getOrCreateQueue(moduleId);

    if (timeout != null) {
      return await queue.dequeueWithTimeout(timeout);
    } else {
      return await queue.dequeue();
    }
  }

  // 브로드캐스트 메시지
  Future<void> broadcastMessage(String fromModuleId, ModuleMessage message) async {
    final activeModules = _moduleManager.getActiveModules();

    for (final module in activeModules) {
      if (module.moduleId != fromModuleId) {
        await sendMessage(fromModuleId, module.moduleId, message);
      }
    }
  }
}
```

### 4.3 데이터 공유 인터페이스
```dart
abstract class SharedDataProvider {
  // 공유 데이터 제공
  Future<Map<String, dynamic>> provideSharedData(String dataType);

  // 공유 데이터 요청
  Future<Map<String, dynamic>> requestSharedData(
    String providerModuleId,
    String dataType
  );

  // 데이터 변경 알림
  Stream<DataChangeNotification> get dataChangeStream;
}

class DataChangeNotification {
  final String providerModuleId;
  final String dataType;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;

  const DataChangeNotification({
    required this.providerModuleId,
    required this.dataType,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });
}
```

## 5. 모듈 확장성 및 플러그인 시스템

### 5.1 플러그인 인터페이스
```dart
abstract class ModulePlugin {
  String get pluginId;
  String get pluginName;
  String get pluginDescription;
  String get supportedModuleType;
  int get supportedApiVersion;

  // 플러그인 초기화
  Future<void> initialize(PluginContext context);

  // 플러그인 기능
  Future<PluginResult> execute(PluginInput input);

  // 플러그인 정리
  Future<void> dispose();
}

class PluginContext {
  final String moduleId;
  final ModuleConfiguration config;
  final SharedDataBus sharedDataBus;
  final ModuleMessagingSystem messagingSystem;

  const PluginContext({
    required this.moduleId,
    required this.config,
    required this.sharedDataBus,
    required this.messagingSystem,
  });
}
```

### 5.2 플러그인 관리자
```dart
class PluginManager {
  final Map<String, ModulePlugin> _loadedPlugins = {};
  final Map<String, List<String>> _modulePlugins = {};

  // 플러그인 로딩
  Future<void> loadPlugin(String pluginId, String moduleId) async {
    try {
      // 플러그인 호환성 검증
      await _verifyPluginCompatibility(pluginId, moduleId);

      // 플러그인 인스턴스화
      final plugin = await _instantiatePlugin(pluginId);

      // 플러그인 초기화
      final context = PluginContext(
        moduleId: moduleId,
        config: await _getPluginConfiguration(pluginId),
        sharedDataBus: _sharedDataBus,
        messagingSystem: _messagingSystem
      );

      await plugin.initialize(context);

      // 플러그인 등록
      _loadedPlugins[pluginId] = plugin;

      if (_modulePlugins[moduleId] == null) {
        _modulePlugins[moduleId] = [];
      }

      _modulePlugins[moduleId]!.add(pluginId);

    } catch (e) {
      await _handlePluginLoadError(pluginId, e);
    }
  }

  // 플러그인 실행
  Future<PluginResult> executePlugin(
    String pluginId,
    PluginInput input
  ) async {
    final plugin = _loadedPlugins[pluginId];

    if (plugin == null) {
      throw PluginNotFoundException(pluginId);
    }

    try {
      return await plugin.execute(input);
    } catch (e) {
      await _handlePluginExecutionError(pluginId, e);
      rethrow;
    }
  }

  // 모듈의 모든 플러그인 가져오기
  List<ModulePlugin> getModulePlugins(String moduleId) {
    final pluginIds = _modulePlugins[moduleId] ?? [];
    return pluginIds.map((id) => _loadedPlugins[id]).whereType<ModulePlugin>().toList();
  }
}
```

### 5.3 동적 모듈 로딩
```dart
class DynamicModuleLoader {
  // 파일 시스템에서 모듈 로딩
  Future<BakingModule?> loadModuleFromFile(String filePath) async {
    try {
      // 파일 보안 검증
      await _verifyModuleFile(filePath);

      // 모듈 코드 로딩
      final moduleCode = await _loadModuleCode(filePath);

      // 런타임 컴파일 (가능한 경우)
      final compiledModule = await _compileModule(moduleCode);

      // 모듈 인스턴스화
      final module = await _instantiateCompiledModule(compiledModule);

      // 모듈 검증 및 등록
      await _validateAndRegisterModule(module);

      return module;
    } catch (e) {
      await _handleModuleLoadError(filePath, e);
      return null;
    }
  }

  // 네트워크에서 모듈 다운로드 및 로딩
  Future<BakingModule?> downloadAndLoadModule(String moduleUrl) async {
    try {
      // URL 보안 검증
      await _verifyModuleUrl(moduleUrl);

      // 모듈 다운로드
      final moduleFile = await _downloadModule(moduleUrl);

      // 다운로드된 파일에서 모듈 로딩
      return await loadModuleFromFile(moduleFile.path);
    } catch (e) {
      await _handleModuleDownloadError(moduleUrl, e);
      return null;
    }
  }
}
```

## 6. 모듈 테스트 및 검증

### 6.1 모듈 테스트 프레임워크
```dart
class ModuleTestFramework {
  // 모듈 단위 테스트
  Future<ModuleTestResult> runUnitTests(String moduleId) async {
    final module = _moduleManager.getModule(moduleId);

    if (module == null) {
      throw ModuleNotFoundException(moduleId);
    }

    final testResults = <TestCaseResult>[];

    // 테스트 케이스 실행
    for (final testCase in _getModuleTestCases(moduleId)) {
      try {
        final result = await _executeTestCase(module, testCase);
        testResults.add(result);
      } catch (e) {
        testResults.add(TestCaseResult(
          testCase: testCase,
          status: TestStatus.failed,
          error: e.toString()
        ));
      }
    }

    return ModuleTestResult(
      moduleId: moduleId,
      testResults: testResults,
      overallStatus: _calculateOverallStatus(testResults)
    );
  }

  // 모듈 통합 테스트
  Future<IntegrationTestResult> runIntegrationTests(String moduleId) async {
    final module = _moduleManager.getModule(moduleId);

    // 의존 모듈들과의 통합 테스트
    final dependencyTests = await _runDependencyTests(module);

    // 공유 데이터 버스 통합 테스트
    final dataBusTests = await _runDataBusIntegrationTests(module);

    // 메시징 시스템 통합 테스트
    final messagingTests = await _runMessagingIntegrationTests(module);

    return IntegrationTestResult(
      moduleId: moduleId,
      dependencyTests: dependencyTests,
      dataBusTests: dataBusTests,
      messagingTests: messagingTests
    );
  }

  // 모듈 성능 테스트
  Future<PerformanceTestResult> runPerformanceTests(String moduleId) async {
    final module = _moduleManager.getModule(moduleId);

    // 로딩 시간 테스트
    final loadTime = await _measureModuleLoadTime(module);

    // 분석 성능 테스트
    final analysisPerformance = await _measureAnalysisPerformance(module);

    // 메모리 사용량 테스트
    final memoryUsage = await _measureMemoryUsage(module);

    return PerformanceTestResult(
      moduleId: moduleId,
      loadTime: loadTime,
      analysisPerformance: analysisPerformance,
      memoryUsage: memoryUsage
    );
  }
}
```

### 6.2 모듈 검증 시스템
```dart
class ModuleVerificationSystem {
  // 모듈 보안 검증
  Future<SecurityVerificationResult> verifyModuleSecurity(String moduleId) async {
    final module = _moduleManager.getModule(moduleId);

    // 코드 서명 검증
    final signatureVerification = await _verifyCodeSignature(module);

    // 권한 검증
    final permissionVerification = await _verifyPermissions(module);

    // 취약점 스캔
    final vulnerabilityScan = await _scanVulnerabilities(module);

    // 샌드박스 테스트
    final sandboxTest = await _testSandboxEnvironment(module);

    return SecurityVerificationResult(
      moduleId: moduleId,
      signatureVerification: signatureVerification,
      permissionVerification: permissionVerification,
      vulnerabilityScan: vulnerabilityScan,
      sandboxTest: sandboxTest,
      overallSecurity: _calculateOverallSecurity([
        signatureVerification,
        permissionVerification,
        vulnerabilityScan,
        sandboxTest
      ])
    );
  }

  // 모듈 호환성 검증
  Future<CompatibilityVerificationResult> verifyModuleCompatibility(
    String moduleId
  ) async {
    final module = _moduleManager.getModule(moduleId);

    // API 버전 호환성
    final apiCompatibility = await _verifyApiCompatibility(module);

    // 의존성 호환성
    final dependencyCompatibility = await _verifyDependencyCompatibility(module);

    // 플랫폼 호환성
    final platformCompatibility = await _verifyPlatformCompatibility(module);

    return CompatibilityVerificationResult(
      moduleId: moduleId,
      apiCompatibility: apiCompatibility,
      dependencyCompatibility: dependencyCompatibility,
      platformCompatibility: platformCompatibility
    );
  }
}
```

## 7. 모듈 배포 및 업데이트

### 7.1 모듈 저장소
```dart
class ModuleRepository {
  // 모듈 검색
  Future<List<ModuleInfo>> searchModules(ModuleSearchCriteria criteria) async {
    // 로컬 캐시 확인
    final cachedResults = await _searchLocalCache(criteria);
    if (cachedResults.isNotEmpty) {
      return cachedResults;
    }

    // 원격 저장소 검색
    final remoteResults = await _searchRemoteRepository(criteria);

    // 결과 캐싱
    await _cacheSearchResults(criteria, remoteResults);

    return remoteResults;
  }

  // 모듈 다운로드
  Future<ModuleDownloadResult> downloadModule(String moduleId, String version) async {
    try {
      // 다운로드 URL 생성
      final downloadUrl = await _getModuleDownloadUrl(moduleId, version);

      // 모듈 다운로드
      final downloadedFile = await _downloadModuleFile(downloadUrl);

      // 무결성 검증
      await _verifyModuleIntegrity(downloadedFile, moduleId, version);

      // 로컬 저장소에 저장
      await _saveModuleToLocalRepository(downloadedFile, moduleId, version);

      return ModuleDownloadResult.success(downloadedFile);
    } catch (e) {
      return ModuleDownloadResult.failure(e.toString());
    }
  }
}
```

### 7.2 모듈 업데이트 관리자
```dart
class ModuleUpdateManager {
  // 업데이트 확인
  Future<List<ModuleUpdateInfo>> checkForUpdates() async {
    final activeModules = _moduleManager.getActiveModules();
    final updates = <ModuleUpdateInfo>[];

    for (final module in activeModules) {
      final latestVersion = await _getLatestModuleVersion(module.moduleId);

      if (_isNewerVersion(module.moduleVersion, latestVersion)) {
        updates.add(ModuleUpdateInfo(
          moduleId: module.moduleId,
          currentVersion: module.moduleVersion,
          latestVersion: latestVersion,
          releaseNotes: await _getReleaseNotes(module.moduleId, latestVersion),
          isCompatible: await _checkUpdateCompatibility(module, latestVersion)
        ));
      }
    }

    return updates;
  }

  // 모듈 업데이트
  Future<ModuleUpdateResult> updateModule(
    String moduleId,
    String targetVersion
  ) async {
    try {
      // 현재 모듈 백업
      await _backupCurrentModule(moduleId);

      // 새 버전 다운로드
      final downloadResult = await _moduleRepository.downloadModule(
        moduleId,
        targetVersion
      );

      if (downloadResult.isFailure) {
        throw ModuleUpdateException(downloadResult.error!);
      }

      // 업데이트 설치
      await _installModuleUpdate(downloadResult.file, moduleId, targetVersion);

      // 모듈 재시작
      await _restartModule(moduleId);

      // 업데이트 검증
      await _verifyModuleUpdate(moduleId, targetVersion);

      return ModuleUpdateResult.success(targetVersion);
    } catch (e) {
      // 롤백 실행
      await _rollbackModuleUpdate(moduleId);
      return ModuleUpdateResult.failure(e.toString());
    }
  }

  // 자동 업데이트 설정
  Future<void> configureAutoUpdates(String moduleId, AutoUpdatePolicy policy) async {
    await _saveAutoUpdateConfiguration(moduleId, policy);

    if (policy.isEnabled) {
      // 백그라운드 업데이트 스케줄러 시작
      await _startBackgroundUpdateScheduler(moduleId, policy);
    }
  }
}
```

이 아키텍처는 수쉐프 모드의 모든 베이킹 모듈을 효율적으로 관리하고, 각 모듈의 독립성과 확장성을 보장한다.
