import 'dart:async';
import 'package:my_recipe_book/interfaces/analysis_module.dart';

/// 분석 모듈 레지스트리
/// 
/// 분석 모듈들을 등록, 관리하고 동적으로 로딩하는 시스템입니다.
class ModuleRegistry {
  final Map<String, BaseAnalysisModule> _modules = {};
  final Map<String, ModuleMetadata> _metadata = {};
  final List<ModuleRegistryListener> _listeners = [];
  
  // 모듈 상태 관리
  final Map<String, ModuleStatus> _moduleStatus = {};
  final Map<String, DateTime> _lastHealthCheck = {};
  
  /// 모듈 등록
  Future<void> registerModule(BaseAnalysisModule module) async {
    final name = module.name;
    
    // 중복 등록 확인
    if (_modules.containsKey(name)) {
      throw ModuleRegistrationException(
        '모듈 "$name"이 이미 등록되어 있습니다.',
        moduleName: name,
      );
    }
    
    try {
      // 모듈 초기화
      await module.initialize();
      
      // 등록
      _modules[name] = module;
      _metadata[name] = ModuleMetadata(
        name: name,
        version: module.version,
        description: module.description,
        category: module.category,
        priority: module.priority,
        dependencies: List.from(module.dependencies),
        supportedFeatures: module.getSupportedFeatures(),
        requiredPermissions: module.getRequiredPermissions(),
        configurationSchema: module.getConfigurationSchema(),
        registrationTime: DateTime.now(),
      );
      _moduleStatus[name] = ModuleStatus.active;
      _lastHealthCheck[name] = DateTime.now();
      
      _notifyListeners(ModuleRegistryEvent.registered(name, module));
      
    } catch (e) {
      _moduleStatus[name] = ModuleStatus.failed;
      _notifyListeners(ModuleRegistryEvent.registrationFailed(name, e));
      
      throw ModuleRegistrationException(
        '모듈 "$name" 등록 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 여러 모듈 일괄 등록
  Future<void> registerModules(List<BaseAnalysisModule> modules) async {
    final results = <String, dynamic>{};
    
    for (final module in modules) {
      try {
        await registerModule(module);
        results[module.name] = 'success';
      } catch (e) {
        results[module.name] = 'failed: $e';
      }
    }
    
    _notifyListeners(ModuleRegistryEvent.bulkRegistration(results));
  }

  /// 모듈 등록 해제
  Future<void> unregisterModule(String name) async {
    final module = _modules[name];
    if (module == null) {
      throw ModuleRegistrationException(
        '모듈 "$name"을 찾을 수 없습니다.',
        moduleName: name,
      );
    }
    
    try {
      // 의존성 확인
      final dependentModules = _findDependentModules(name);
      if (dependentModules.isNotEmpty) {
        throw ModuleRegistrationException(
          '모듈 "$name"에 의존하는 다른 모듈들이 있습니다: ${dependentModules.join(", ")}',
          moduleName: name,
          details: {'dependent_modules': dependentModules},
        );
      }
      
      // 모듈 정리
      await module.dispose();
      
      // 등록 해제
      _modules.remove(name);
      _metadata.remove(name);
      _moduleStatus.remove(name);
      _lastHealthCheck.remove(name);
      
      _notifyListeners(ModuleRegistryEvent.unregistered(name));
      
    } catch (e) {
      _notifyListeners(ModuleRegistryEvent.unregistrationFailed(name, e));
      rethrow;
    }
  }

  /// 의존하는 모듈들 찾기
  List<String> _findDependentModules(String moduleName) {
    final dependentModules = <String>[];
    
    for (final entry in _metadata.entries) {
      if (entry.value.dependencies.contains(moduleName)) {
        dependentModules.add(entry.key);
      }
    }
    
    return dependentModules;
  }

  /// 모듈 조회
  BaseAnalysisModule? getModule(String name) {
    return _modules[name];
  }

  /// 모든 모듈 조회
  List<BaseAnalysisModule> getAllModules() {
    return _modules.values.toList();
  }

  /// 활성 모듈 조회
  List<BaseAnalysisModule> getActiveModules() {
    return _modules.entries
        .where((entry) => _moduleStatus[entry.key] == ModuleStatus.active)
        .map((entry) => entry.value)
        .toList();
  }

  /// 카테고리별 모듈 조회
  List<BaseAnalysisModule> getModulesByCategory(AnalysisModuleCategory category) {
    return _modules.values
        .where((module) => module.category == category)
        .toList();
  }

  /// 모듈 메타데이터 조회
  ModuleMetadata? getModuleMetadata(String name) {
    return _metadata[name];
  }

  /// 모든 모듈 메타데이터 조회
  List<ModuleMetadata> getAllModuleMetadata() {
    return _metadata.values.toList();
  }

  /// 모듈 상태 조회
  ModuleStatus? getModuleStatus(String name) {
    return _moduleStatus[name];
  }

  /// 모듈 존재 확인
  bool hasModule(String name) {
    return _modules.containsKey(name);
  }

  /// 의존성 검증
  List<String> validateDependencies() {
    final issues = <String>[];
    
    for (final entry in _metadata.entries) {
      final moduleName = entry.key;
      final metadata = entry.value;
      
      for (final dependency in metadata.dependencies) {
        if (!hasModule(dependency)) {
          issues.add('모듈 "$moduleName"의 의존성 "$dependency"를 찾을 수 없습니다.');
        } else if (_moduleStatus[dependency] != ModuleStatus.active) {
          issues.add('모듈 "$moduleName"의 의존성 "$dependency"가 비활성 상태입니다.');
        }
      }
    }
    
    return issues;
  }

  /// 순환 의존성 검사
  List<String> detectCircularDependencies() {
    final cycles = <String>[];
    final visited = <String>{};
    final recursionStack = <String>{};
    
    for (final moduleName in _modules.keys) {
      if (_detectCycleUtil(moduleName, visited, recursionStack, [])) {
        // 순환 의존성 발견 시 경로 추가
        cycles.add('순환 의존성 발견: $moduleName');
      }
    }
    
    return cycles;
  }

  bool _detectCycleUtil(
    String moduleName, 
    Set<String> visited, 
    Set<String> recursionStack,
    List<String> path
  ) {
    if (recursionStack.contains(moduleName)) {
      return true;
    }
    if (visited.contains(moduleName)) {
      return false;
    }
    
    visited.add(moduleName);
    recursionStack.add(moduleName);
    path.add(moduleName);
    
    final metadata = _metadata[moduleName];
    if (metadata != null) {
      for (final dependency in metadata.dependencies) {
        if (_detectCycleUtil(dependency, visited, recursionStack, path)) {
          return true;
        }
      }
    }
    
    recursionStack.remove(moduleName);
    path.removeLast();
    return false;
  }

  /// 모듈 상태 변경
  void setModuleStatus(String name, ModuleStatus status) {
    if (!_modules.containsKey(name)) {
      throw ModuleRegistrationException(
        '모듈 "$name"을 찾을 수 없습니다.',
        moduleName: name,
      );
    }
    
    final oldStatus = _moduleStatus[name];
    _moduleStatus[name] = status;
    
    _notifyListeners(ModuleRegistryEvent.statusChanged(name, oldStatus, status));
  }

  /// 모듈 비활성화
  Future<void> deactivateModule(String name) async {
    final module = _modules[name];
    if (module == null) {
      throw ModuleRegistrationException(
        '모듈 "$name"을 찾을 수 없습니다.',
        moduleName: name,
      );
    }
    
    try {
      setModuleStatus(name, ModuleStatus.inactive);
      _notifyListeners(ModuleRegistryEvent.deactivated(name));
    } catch (e) {
      _notifyListeners(ModuleRegistryEvent.deactivationFailed(name, e));
      rethrow;
    }
  }

  /// 모듈 활성화
  Future<void> activateModule(String name) async {
    final module = _modules[name];
    if (module == null) {
      throw ModuleRegistrationException(
        '모듈 "$name"을 찾을 수 없습니다.',
        moduleName: name,
      );
    }
    
    try {
      // 의존성 확인
      final metadata = _metadata[name];
      if (metadata != null) {
        for (final dependency in metadata.dependencies) {
          if (_moduleStatus[dependency] != ModuleStatus.active) {
            throw ModuleRegistrationException(
              '의존성 모듈 "$dependency"가 활성화되지 않았습니다.',
              moduleName: name,
            );
          }
        }
      }
      
      setModuleStatus(name, ModuleStatus.active);
      _notifyListeners(ModuleRegistryEvent.activated(name));
    } catch (e) {
      _notifyListeners(ModuleRegistryEvent.activationFailed(name, e));
      rethrow;
    }
  }

  /// 모듈 헬스 체크
  Future<Map<String, ModuleHealthStatus>> performHealthCheck() async {
    final results = <String, ModuleHealthStatus>{};
    
    for (final entry in _modules.entries) {
      final name = entry.key;
      final module = entry.value;
      
      try {
        final isHealthy = await _checkModuleHealth(module);
        results[name] = ModuleHealthStatus(
          moduleName: name,
          isHealthy: isHealthy,
          lastCheckTime: DateTime.now(),
          status: _moduleStatus[name] ?? ModuleStatus.unknown,
        );
        
        _lastHealthCheck[name] = DateTime.now();
        
        if (!isHealthy && _moduleStatus[name] == ModuleStatus.active) {
          setModuleStatus(name, ModuleStatus.unhealthy);
        }
        
      } catch (e) {
        results[name] = ModuleHealthStatus(
          moduleName: name,
          isHealthy: false,
          lastCheckTime: DateTime.now(),
          status: ModuleStatus.failed,
          error: e.toString(),
        );
        
        setModuleStatus(name, ModuleStatus.failed);
      }
    }
    
    _notifyListeners(ModuleRegistryEvent.healthCheckCompleted(results));
    
    return results;
  }

  /// 개별 모듈 헬스 체크
  Future<bool> _checkModuleHealth(BaseAnalysisModule module) async {
    try {
      // 기본적인 헬스 체크 (모듈이 응답하는지 확인)
      final testRequest = _createTestRequest();
      final canHandle = await module.canHandle(testRequest);
      
      // canHandle 메서드가 정상적으로 응답하면 건강한 것으로 간주
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 테스트용 요청 생성
  AnalysisRequest _createTestRequest() {
    // 최소한의 테스트 요청 생성
    return AnalysisRequest.builder()
        .withRecipe(Recipe(
          title: 'Test Recipe',
          ingredients: [],
          instructions: [],
        ))
        .build();
  }

  /// 모듈 통계 조회
  ModuleRegistryStatistics getStatistics() {
    final totalModules = _modules.length;
    final activeModules = _moduleStatus.values.where((s) => s == ModuleStatus.active).length;
    final inactiveModules = _moduleStatus.values.where((s) => s == ModuleStatus.inactive).length;
    final failedModules = _moduleStatus.values.where((s) => s == ModuleStatus.failed).length;
    final unhealthyModules = _moduleStatus.values.where((s) => s == ModuleStatus.unhealthy).length;
    
    final categoryCounts = <AnalysisModuleCategory, int>{};
    for (final module in _modules.values) {
      categoryCounts[module.category] = (categoryCounts[module.category] ?? 0) + 1;
    }
    
    return ModuleRegistryStatistics(
      totalModules: totalModules,
      activeModules: activeModules,
      inactiveModules: inactiveModules,
      failedModules: failedModules,
      unhealthyModules: unhealthyModules,
      categoryCounts: categoryCounts,
      lastHealthCheckTime: _lastHealthCheck.values.isNotEmpty 
          ? _lastHealthCheck.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );
  }

  /// 모듈 설정 업데이트
  Future<void> updateModuleConfiguration(String name, Map<String, dynamic> configuration) async {
    final module = _modules[name];
    if (module == null) {
      throw ModuleRegistrationException(
        '모듈 "$name"을 찾을 수 없습니다.',
        moduleName: name,
      );
    }
    
    try {
      await module.updateConfiguration(configuration);
      _notifyListeners(ModuleRegistryEvent.configurationUpdated(name, configuration));
    } catch (e) {
      _notifyListeners(ModuleRegistryEvent.configurationUpdateFailed(name, e));
      rethrow;
    }
  }

  /// 리스너 추가
  void addListener(ModuleRegistryListener listener) {
    _listeners.add(listener);
  }

  /// 리스너 제거
  void removeListener(ModuleRegistryListener listener) {
    _listeners.remove(listener);
  }

  /// 리스너들에게 이벤트 알림
  void _notifyListeners(ModuleRegistryEvent event) {
    for (final listener in _listeners) {
      try {
        listener.onEvent(event);
      } catch (e) {
        print('모듈 레지스트리 리스너 알림 중 오류: $e');
      }
    }
  }

  /// 모든 모듈 정리
  Future<void> dispose() async {
    final moduleNames = _modules.keys.toList();
    
    for (final name in moduleNames) {
      try {
        await unregisterModule(name);
      } catch (e) {
        print('모듈 "$name" 정리 중 오류: $e');
      }
    }
    
    _listeners.clear();
  }

  /// 레지스트리 상태 덤프 (디버깅용)
  Map<String, dynamic> dumpState() {
    return {
      'modules': _modules.keys.toList(),
      'metadata': _metadata.map((k, v) => MapEntry(k, v.toMap())),
      'status': _moduleStatus.map((k, v) => MapEntry(k, v.toString())),
      'last_health_check': _lastHealthCheck.map((k, v) => MapEntry(k, v.toIso8601String())),
      'statistics': getStatistics().toMap(),
    };
  }
}/
// 모듈 메타데이터
class ModuleMetadata {
  final String name;
  final String version;
  final String description;
  final AnalysisModuleCategory category;
  final int priority;
  final List<String> dependencies;
  final List<String> supportedFeatures;
  final List<String> requiredPermissions;
  final Map<String, dynamic> configurationSchema;
  final DateTime registrationTime;

  ModuleMetadata({
    required this.name,
    required this.version,
    required this.description,
    required this.category,
    required this.priority,
    required this.dependencies,
    required this.supportedFeatures,
    required this.requiredPermissions,
    required this.configurationSchema,
    required this.registrationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'category': category.toString(),
      'priority': priority,
      'dependencies': dependencies,
      'supported_features': supportedFeatures,
      'required_permissions': requiredPermissions,
      'configuration_schema': configurationSchema,
      'registration_time': registrationTime.toIso8601String(),
    };
  }
}

/// 모듈 상태
enum ModuleStatus {
  active,      // 활성화됨
  inactive,    // 비활성화됨
  failed,      // 실패 상태
  unhealthy,   // 비정상 상태
  unknown,     // 알 수 없음
}

/// 모듈 헬스 상태
class ModuleHealthStatus {
  final String moduleName;
  final bool isHealthy;
  final DateTime lastCheckTime;
  final ModuleStatus status;
  final String? error;

  ModuleHealthStatus({
    required this.moduleName,
    required this.isHealthy,
    required this.lastCheckTime,
    required this.status,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'module_name': moduleName,
      'is_healthy': isHealthy,
      'last_check_time': lastCheckTime.toIso8601String(),
      'status': status.toString(),
      'error': error,
    };
  }
}

/// 모듈 레지스트리 통계
class ModuleRegistryStatistics {
  final int totalModules;
  final int activeModules;
  final int inactiveModules;
  final int failedModules;
  final int unhealthyModules;
  final Map<AnalysisModuleCategory, int> categoryCounts;
  final DateTime? lastHealthCheckTime;

  ModuleRegistryStatistics({
    required this.totalModules,
    required this.activeModules,
    required this.inactiveModules,
    required this.failedModules,
    required this.unhealthyModules,
    required this.categoryCounts,
    this.lastHealthCheckTime,
  });

  double get healthyPercentage {
    if (totalModules == 0) return 0.0;
    return (activeModules / totalModules) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'total_modules': totalModules,
      'active_modules': activeModules,
      'inactive_modules': inactiveModules,
      'failed_modules': failedModules,
      'unhealthy_modules': unhealthyModules,
      'healthy_percentage': healthyPercentage,
      'category_counts': categoryCounts.map((k, v) => MapEntry(k.toString(), v)),
      'last_health_check_time': lastHealthCheckTime?.toIso8601String(),
    };
  }
}

/// 모듈 레지스트리 이벤트
abstract class ModuleRegistryEvent {
  final DateTime timestamp;

  ModuleRegistryEvent() : timestamp = DateTime.now();

  static ModuleRegistryEvent registered(String name, BaseAnalysisModule module) =>
      ModuleRegisteredEvent(name, module);
  
  static ModuleRegistryEvent registrationFailed(String name, Object error) =>
      ModuleRegistrationFailedEvent(name, error);
  
  static ModuleRegistryEvent unregistered(String name) =>
      ModuleUnregisteredEvent(name);
  
  static ModuleRegistryEvent unregistrationFailed(String name, Object error) =>
      ModuleUnregistrationFailedEvent(name, error);
  
  static ModuleRegistryEvent statusChanged(String name, ModuleStatus? oldStatus, ModuleStatus newStatus) =>
      ModuleStatusChangedEvent(name, oldStatus, newStatus);
  
  static ModuleRegistryEvent activated(String name) =>
      ModuleActivatedEvent(name);
  
  static ModuleRegistryEvent activationFailed(String name, Object error) =>
      ModuleActivationFailedEvent(name, error);
  
  static ModuleRegistryEvent deactivated(String name) =>
      ModuleDeactivatedEvent(name);
  
  static ModuleRegistryEvent deactivationFailed(String name, Object error) =>
      ModuleDeactivationFailedEvent(name, error);
  
  static ModuleRegistryEvent configurationUpdated(String name, Map<String, dynamic> configuration) =>
      ModuleConfigurationUpdatedEvent(name, configuration);
  
  static ModuleRegistryEvent configurationUpdateFailed(String name, Object error) =>
      ModuleConfigurationUpdateFailedEvent(name, error);
  
  static ModuleRegistryEvent healthCheckCompleted(Map<String, ModuleHealthStatus> results) =>
      ModuleHealthCheckCompletedEvent(results);
  
  static ModuleRegistryEvent bulkRegistration(Map<String, dynamic> results) =>
      ModuleBulkRegistrationEvent(results);
}

class ModuleRegisteredEvent extends ModuleRegistryEvent {
  final String name;
  final BaseAnalysisModule module;
  ModuleRegisteredEvent(this.name, this.module);
}

class ModuleRegistrationFailedEvent extends ModuleRegistryEvent {
  final String name;
  final Object error;
  ModuleRegistrationFailedEvent(this.name, this.error);
}

class ModuleUnregisteredEvent extends ModuleRegistryEvent {
  final String name;
  ModuleUnregisteredEvent(this.name);
}

class ModuleUnregistrationFailedEvent extends ModuleRegistryEvent {
  final String name;
  final Object error;
  ModuleUnregistrationFailedEvent(this.name, this.error);
}

class ModuleStatusChangedEvent extends ModuleRegistryEvent {
  final String name;
  final ModuleStatus? oldStatus;
  final ModuleStatus newStatus;
  ModuleStatusChangedEvent(this.name, this.oldStatus, this.newStatus);
}

class ModuleActivatedEvent extends ModuleRegistryEvent {
  final String name;
  ModuleActivatedEvent(this.name);
}

class ModuleActivationFailedEvent extends ModuleRegistryEvent {
  final String name;
  final Object error;
  ModuleActivationFailedEvent(this.name, this.error);
}

class ModuleDeactivatedEvent extends ModuleRegistryEvent {
  final String name;
  ModuleDeactivatedEvent(this.name);
}

class ModuleDeactivationFailedEvent extends ModuleRegistryEvent {
  final String name;
  final Object error;
  ModuleDeactivationFailedEvent(this.name, this.error);
}

class ModuleConfigurationUpdatedEvent extends ModuleRegistryEvent {
  final String name;
  final Map<String, dynamic> configuration;
  ModuleConfigurationUpdatedEvent(this.name, this.configuration);
}

class ModuleConfigurationUpdateFailedEvent extends ModuleRegistryEvent {
  final String name;
  final Object error;
  ModuleConfigurationUpdateFailedEvent(this.name, this.error);
}

class ModuleHealthCheckCompletedEvent extends ModuleRegistryEvent {
  final Map<String, ModuleHealthStatus> results;
  ModuleHealthCheckCompletedEvent(this.results);
}

class ModuleBulkRegistrationEvent extends ModuleRegistryEvent {
  final Map<String, dynamic> results;
  ModuleBulkRegistrationEvent(this.results);
}

/// 모듈 레지스트리 리스너
abstract class ModuleRegistryListener {
  void onEvent(ModuleRegistryEvent event);
}

/// 모듈 등록 예외
class ModuleRegistrationException implements Exception {
  final String message;
  final String? moduleName;
  final Exception? cause;
  final Map<String, dynamic>? details;

  ModuleRegistrationException(
    this.message, {
    this.moduleName,
    this.cause,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ModuleRegistrationException: $message');
    if (moduleName != null) {
      buffer.write(' (module: $moduleName)');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    if (details != null && details!.isNotEmpty) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}