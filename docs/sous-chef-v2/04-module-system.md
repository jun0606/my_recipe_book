# 04. 모듈 시스템

## 📋 개요

수쉐프 모드 v2.0의 모듈 시스템은 빵, 케이크, 쿠키, 디저트 모듈을 독립적으로 개발하고 관리할 수 있는 플러그인 아키텍처를 제공합니다.

## 🎯 설계 목표

### 1. 코드 중복 제거
```dart
// 기존 방식: 각 모듈별 중복 코드
BreadAnalysisTab, CakeAnalysisTab, CookieAnalysisTab, DessertAnalysisTab

// 신규 방식: 단일 범용 컴포넌트
DynamicAnalysisTab(module: currentModule)
```

### 2. 모듈 독립성
```dart
// 각 모듈은 독립적으로 개발/배포/관리
class BreadModule implements SousChefModule
class CakeModule implements SousChefModule
```

### 3. 런타임 모듈 전환
```dart
// 사용자가 모듈을 실시간으로 전환
ModuleManager.switchTo('bread')
ModuleManager.switchTo('cake')
```

## 🏗️ 모듈 아키텍처

### 1. 코어 모듈 인터페이스

#### SousChefModule - 기본 모듈 인터페이스
```dart
// lib/modules/base_module.dart
abstract class SousChefModule {
  // 기본 정보
  String get moduleId;
  String get displayName;
  IconData get icon;
  Color get themeColor;
  String get description;

  // 모듈 능력 정의
  ModuleCapabilities get capabilities;
  List<String> get supportedRecipeTypes;

  // 레시피 처리
  bool canHandleRecipe(UnifiedRecipe recipe);
  Future<bool> validateRecipe(UnifiedRecipe recipe);

  // 분석 기능
  Future<AnalysisResult> analyze(UnifiedRecipe recipe);
  Future<AnalysisResult> quickAnalyze(UnifiedRecipe recipe);

  // 조언 기능
  Future<List<String>> getGeneralAdvice(UnifiedRecipe recipe);
  Future<List<String>> getSpecificAdvice(UnifiedRecipe recipe, String aspect);
  Future<List<String>> getImprovementSuggestions(UnifiedRecipe recipe);

  // UI 컴포넌트
  List<Widget> buildAnalysisUI(AnalysisResult result);
  List<Widget> buildAdviceUI(AnalysisResult result);
  List<Widget> buildImprovementUI(AnalysisResult result);

  // 모듈 설정
  Future<void> initialize();
  Future<void> dispose();
  Future<void> updateSettings(Map<String, dynamic> settings);

  // 이벤트 처리
  void onRecipeUpdated(UnifiedRecipe recipe);
  void onModuleActivated();
  void onModuleDeactivated();
}
```

#### ModuleCapabilities - 모듈 능력 정의
```dart
class ModuleCapabilities {
  final bool supportsRealTimeAnalysis;
  final bool supportsRecipeModification;
  final bool supportsQuickAnalysis;
  final bool supportsAdvancedSettings;

  final List<String> supportedProcessTypes;
  final List<String> supportedIngredientTypes;
  final List<String> supportedEquipmentTypes;

  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> featureFlags;

  const ModuleCapabilities({
    this.supportsRealTimeAnalysis = true,
    this.supportsRecipeModification = true,
    this.supportsQuickAnalysis = true,
    this.supportsAdvancedSettings = false,
    this.supportedProcessTypes = const [],
    this.supportedIngredientTypes = const [],
    this.supportedEquipmentTypes = const [],
    this.performanceMetrics = const {},
    this.featureFlags = const {},
  });
}
```

### 2. 모듈 관리 시스템

#### ModuleManager - 모듈 관리자
```dart
// lib/modules/module_manager.dart
class ModuleManager {
  static final Map<String, SousChefModule> _modules = {};
  static final Map<String, ModuleState> _moduleStates = {};
  static final Map<String, ModuleMetadata> _moduleMetadata = {};

  static String? _currentModuleId;
  static final SousChefEventBus _eventBus = SousChefEventBus();

  // 모듈 등록
  static Future<void> registerModule(
    String id,
    SousChefModule module,
    ModuleMetadata metadata,
  ) async {
    try {
      // 모듈 초기화
      await module.initialize();

      // 모듈 등록
      _modules[id] = module;
      _moduleStates[id] = ModuleState.inactive;
      _moduleMetadata[id] = metadata;

      // 이벤트 발행
      _eventBus.publish(
        SousChefEvent.moduleRegistered.name,
        ModuleRegisteredEvent(id, metadata)
      );

      Logger.info('Module $id registered successfully');

    } catch (e) {
      Logger.error('Failed to register module $id: $e');
      throw ModuleRegistrationError(id, e);
    }
  }

  // 모듈 활성화
  static Future<void> activateModule(String id) async {
    if (!_modules.containsKey(id)) {
      throw ModuleNotFoundError(id);
    }

    if (_currentModuleId != null) {
      await deactivateModule(_currentModuleId!);
    }

    try {
      _moduleStates[id] = ModuleState.active;
      _currentModuleId = id;

      await _modules[id].onModuleActivated();

      _eventBus.publish(
        SousChefEvent.moduleActivated.name,
        ModuleActivatedEvent(id)
      );

    } catch (e) {
      _moduleStates[id] = ModuleState.error;
      throw ModuleActivationError(id, e);
    }
  }

  // 모듈 비활성화
  static Future<void> deactivateModule(String id) async {
    if (!_modules.containsKey(id)) {
      return;
    }

    try {
      await _modules[id].onModuleDeactivated();
      _moduleStates[id] = ModuleState.inactive;

      if (_currentModuleId == id) {
        _currentModuleId = null;
      }

      _eventBus.publish(
        SousChefEvent.moduleDeactivated.name,
        ModuleDeactivatedEvent(id)
      );

    } catch (e) {
      Logger.error('Error deactivating module $id: $e');
    }
  }

  // 모듈 전환
  static Future<void> switchToModule(String id) async {
    if (_currentModuleId == id) {
      return; // 이미 활성화된 모듈
    }

    try {
      // 현재 모듈 비활성화
      if (_currentModuleId != null) {
        await deactivateModule(_currentModuleId!);
      }

      // 새 모듈 활성화
      await activateModule(id);

      _eventBus.publish(
        SousChefEvent.moduleSwitched.name,
        ModuleSwitchEvent(id, ModuleState.active)
      );

    } catch (e) {
      Logger.error('Failed to switch to module $id: $e');
      throw ModuleSwitchError(id, e);
    }
  }

  // 현재 모듈 가져오기
  static SousChefModule? getCurrentModule() {
    return _currentModuleId != null ? _modules[_currentModuleId] : null;
  }

  // 특정 모듈 가져오기
  static SousChefModule? getModule(String id) {
    return _modules[id];
  }

  // 사용 가능한 모듈 목록
  static List<String> getAvailableModules() {
    return _modules.keys.toList();
  }

  // 모듈 상태 확인
  static ModuleState getModuleState(String id) {
    return _moduleStates[id] ?? ModuleState.notFound;
  }

  // 모듈 메타데이터
  static ModuleMetadata? getModuleMetadata(String id) {
    return _moduleMetadata[id];
  }
}
```

#### ModuleState - 모듈 상태
```dart
enum ModuleState {
  notFound,   // 모듈을 찾을 수 없음
  inactive,   // 비활성화 상태
  active,     // 활성화 상태
  suspended,  // 일시 정지 상태
  error,      // 에러 상태
  loading,    // 로딩 중
}
```

#### ModuleMetadata - 모듈 메타데이터
```dart
class ModuleMetadata {
  final String version;
  final String author;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> dependencies;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> permissions;

  const ModuleMetadata({
    required this.version,
    required this.author,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dependencies = const {},
    this.settings = const {},
    this.permissions = const {},
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
```

## 🔧 구체적 모듈 구현

### 1. 빵 모듈 (BreadModule)

#### BreadModule 구현
```dart
// lib/modules/bread/bread_module.dart
class BreadModule implements SousChefModule {
  @override
  String get moduleId => 'bread';

  @override
  String get displayName => '빵 분석';

  @override
  IconData get icon => Icons.bread;

  @override
  Color get themeColor => Colors.brown;

  @override
  String get description => '빵 만들기 전문 분석 모듈';

  @override
  ModuleCapabilities get capabilities => const ModuleCapabilities(
    supportsRealTimeAnalysis: true,
    supportsRecipeModification: true,
    supportedProcessTypes: ['mixing', 'kneading', 'fermentation', 'baking'],
    supportedIngredientTypes: ['flour', 'yeast', 'water', 'salt'],
  );

  @override
  List<String> get supportedRecipeTypes => ['bread', 'dough', 'fermentation'];

  @override
  bool canHandleRecipe(UnifiedRecipe recipe) {
    // 빵 관련 재료나 프로세스가 있는지 확인
    final hasBreadIngredients = recipe.ingredients.any(
      (ing) => ing.properties['type'] == 'flour' ||
               ing.properties['type'] == 'yeast'
    );

    final hasBreadProcesses = recipe.processes.any(
      (proc) => supportedProcessTypes.contains(proc.type)
    );

    return hasBreadIngredients || hasBreadProcesses;
  }

  @override
  Future<AnalysisResult> analyze(UnifiedRecipe recipe) async {
    try {
      // 빵 특화 분석 로직
      final doughAnalysis = await _analyzeDough(recipe);
      final fermentationAnalysis = await _analyzeFermentation(recipe);
      final bakingAnalysis = await _analyzeBaking(recipe);

      return AnalysisResult.success(
        moduleId: moduleId,
        data: {
          'dough': doughAnalysis,
          'fermentation': fermentationAnalysis,
          'baking': bakingAnalysis,
        },
        processAnalysis: doughAnalysis,
        ingredientAnalysis: await _analyzeIngredients(recipe),
      );

    } catch (e) {
      return AnalysisResult.error(
        moduleId: moduleId,
        errorMessage: '빵 분석 중 오류가 발생했습니다: $e',
      );
    }
  }

  @override
  List<Widget> buildAnalysisUI(AnalysisResult result) {
    return [
      BreadDoughCard(doughAnalysis: result.processAnalysis),
      BreadFermentationCard(fermentationAnalysis: result.ingredientAnalysis),
      BreadBakingCard(bakingAnalysis: result.equipmentAnalysis),
    ];
  }

  @override
  List<Widget> buildAdviceUI(AnalysisResult result) {
    return [
      BreadGeneralAdviceCard(result: result),
      BreadSpecificAdviceCard(result: result),
    ];
  }

  @override
  List<Widget> buildImprovementUI(AnalysisResult result) {
    return [
      BreadImprovementSuggestions(result: result),
    ];
  }

  // 기타 구현...
}
```

### 2. 모듈 설정 시스템

#### ModuleConfig - 모듈 설정
```dart
// lib/modules/module_config.dart
class ModuleConfig {
  final String moduleId;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> thresholds;

  const ModuleConfig({
    required this.moduleId,
    this.settings = const {},
    this.preferences = const {},
    this.thresholds = const {},
  });

  factory ModuleConfig.fromMap(String moduleId, Map<String, dynamic> map) {
    return ModuleConfig(
      moduleId: moduleId,
      settings: map['settings'] ?? {},
      preferences: map['preferences'] ?? {},
      thresholds: map['thresholds'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
      'preferences': preferences,
      'thresholds': thresholds,
    };
  }

  // 설정 값 가져오기
  T getSetting<T>(String key, T defaultValue) {
    return settings[key] ?? defaultValue;
  }

  // 임계값 가져오기
  double getThreshold(String key, double defaultValue) {
    return thresholds[key]?.toDouble() ?? defaultValue;
  }

  // 선호도 가져오기
  bool getPreference(String key, bool defaultValue) {
    return preferences[key] ?? defaultValue;
  }
}
```

### 3. 모듈 간 데이터 공유

#### ModuleDataBridge - 모듈 간 데이터 공유
```dart
// lib/modules/module_data_bridge.dart
class ModuleDataBridge {
  static final Map<String, Map<String, dynamic>> _sharedData = {};

  // 데이터 공유
  static void shareData(String moduleId, String key, dynamic value) {
    _sharedData[moduleId] ??= {};
    _sharedData[moduleId]![key] = value;

    // 이벤트 발행
    SousChefEventBus().publish(
      'module:data_shared',
      {
        'moduleId': moduleId,
        'key': key,
        'value': value,
        'timestamp': DateTime.now(),
      }
    );
  }

  // 데이터 가져오기
  static T? getSharedData<T>(String moduleId, String key) {
    return _sharedData[moduleId]?[key] as T?;
  }

  // 모듈 데이터 가져오기
  static Map<String, dynamic> getModuleData(String moduleId) {
    return _sharedData[moduleId] ?? {};
  }

  // 데이터 클리어
  static void clearModuleData(String moduleId) {
    _sharedData.remove(moduleId);
  }

  // 모든 데이터 클리어
  static void clearAllData() {
    _sharedData.clear();
  }
}
```

## 🎨 동적 UI 컴포넌트 시스템

### 1. 범용 UI 컴포넌트

#### DynamicAnalysisTab - 범용 분석 탭
```dart
// lib/ui/dynamic_analysis_tab.dart
class DynamicAnalysisTab extends StatefulWidget {
  final UnifiedRecipe recipe;
  final SousChefModule module;
  final AnalysisResult? analysisResult;

  const DynamicAnalysisTab({
    required this.recipe,
    required this.module,
    this.analysisResult,
  });

  @override
  _DynamicAnalysisTabState createState() => _DynamicAnalysisTabState();
}

class _DynamicAnalysisTabState extends State<DynamicAnalysisTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription _recipeSubscription;
  late StreamSubscription _analysisSubscription;

  AnalysisResult? _currentResult;

  @override
  void initState() {
    super.initState();

    // 탭 컨트롤러 초기화
    _tabController = TabController(
      length: 3, // 분석, 조언, 개선
      vsync: this,
    );

    // 현재 결과 설정
    _currentResult = widget.analysisResult;

    // 이벤트 구독
    _setupEventSubscriptions();

    // 초기 분석 실행
    _runInitialAnalysis();
  }

  void _setupEventSubscriptions() {
    // 레시피 업데이트 구독
    _recipeSubscription = SousChefEventBus().subscribe<RecipeUpdateEvent>(
      SousChefEvent.recipeUpdated.name,
    ).listen(_handleRecipeUpdate);

    // 분석 완료 구독
    _analysisSubscription = SousChefEventBus().subscribe<AnalysisCompleteEvent>(
      SousChefEvent.analysisCompleted.name,
    ).listen(_handleAnalysisComplete);
  }

  void _handleRecipeUpdate(RecipeUpdateEvent event) {
    if (mounted) {
      setState(() {
        // 레시피가 변경되었으므로 재분석 필요
        _currentResult = null;
        _runAnalysis();
      });
    }
  }

  void _handleAnalysisComplete(AnalysisCompleteEvent event) {
    if (event.moduleId == widget.module.moduleId && mounted) {
      setState(() {
        _currentResult = event.result;
      });
    }
  }

  Future<void> _runInitialAnalysis() async {
    if (_currentResult == null) {
      await _runAnalysis();
    }
  }

  Future<void> _runAnalysis() async {
    try {
      final result = await widget.module.analyze(widget.recipe);
      if (mounted) {
        setState(() {
          _currentResult = result;
        });
      }
    } catch (e) {
      Logger.error('Analysis failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.module.displayName),
      backgroundColor: widget.module.themeColor,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '분석'),
          Tab(text: '조언'),
          Tab(text: '개선'),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(widget.module.icon),
          onPressed: _showModuleInfo,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_currentResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAnalysisTab(),
        _buildAdviceTab(),
        _buildImprovementTab(),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    final components = widget.module.buildAnalysisUI(_currentResult!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: components,
    );
  }

  Widget _buildAdviceTab() {
    final components = widget.module.buildAdviceUI(_currentResult!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: components,
    );
  }

  Widget _buildImprovementTab() {
    final components = widget.module.buildImprovementUI(_currentResult!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: components,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _runAnalysis,
      backgroundColor: widget.module.themeColor,
      child: const Icon(Icons.refresh),
    );
  }

  void _showModuleInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.module.displayName),
        content: Text(widget.module.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipeSubscription.cancel();
    _analysisSubscription.cancel();
    super.dispose();
  }
}
```

### 2. 모듈별 설정 파일

#### 모듈 설정 예시
```dart
// lib/modules/bread/bread_module_config.dart
class BreadModuleConfig {
  static const String moduleId = 'bread';

  static const Map<String, dynamic> uiConfig = {
    'theme': {
      'primaryColor': Colors.brown,
      'secondaryColor': Colors.orange,
    },
    'tabs': [
      {
        'id': 'analysis',
        'title': '빵 분석',
        'components': [
          'BreadDoughCard',
          'BreadFermentationCard',
          'BreadBakingCard',
        ],
      },
      {
        'id': 'advice',
        'title': '빵 조언',
        'components': [
          'BreadGeneralAdviceCard',
          'BreadSpecificAdviceCard',
        ],
      },
      {
        'id': 'improvement',
        'title': '빵 개선',
        'components': [
          'BreadImprovementSuggestions',
        ],
      },
    ],
    'analysisCards': {
      'dough': {
        'title': '반죽 분석',
        'metrics': ['glutenStrength', 'elasticity', 'extensibility'],
        'thresholds': {
          'glutenStrength': {'min': 0.7, 'max': 0.9},
          'elasticity': {'min': 0.6, 'max': 0.9},
        },
      },
      'fermentation': {
        'title': '발효 분석',
        'metrics': ['gasProduction', 'flavorDevelopment'],
        'thresholds': {
          'gasProduction': {'min': 0.8},
          'flavorDevelopment': {'min': 0.7},
        },
      },
    },
  };

  static const Map<String, dynamic> analysisConfig = {
    'doughTypes': {
      'lean': {
        'optimalMixingTime': 12.0,
        'optimalGlutenStrength': 0.85,
        'hydrationRange': {'min': 0.65, 'max': 0.75},
      },
      'rich': {
        'optimalMixingTime': 15.0,
        'optimalGlutenStrength': 0.75,
        'hydrationRange': {'min': 0.70, 'max': 0.80},
      },
    },
    'fermentationProfiles': {
      'bulk': {
        'optimalTemperature': 24.0,
        'optimalTime': 180, // minutes
        'optimalHumidity': 75.0,
      },
      'proof': {
        'optimalTemperature': 26.0,
        'optimalTime': 60, // minutes
        'optimalHumidity': 80.0,
      },
    },
  };
}
```

## 📊 모듈 성능 모니터링

### ModulePerformanceMonitor - 모듈 성능 모니터링
```dart
// lib/modules/module_performance_monitor.dart
class ModulePerformanceMonitor {
  static final Map<String, ModulePerformanceMetrics> _metrics = {};

  static void startMeasurement(String moduleId, String operation) {
    _metrics[moduleId] ??= ModulePerformanceMetrics();
    _metrics[moduleId]!.startOperation(operation);
  }

  static void endMeasurement(String moduleId, String operation) {
    if (_metrics.containsKey(moduleId)) {
      _metrics[moduleId]!.endOperation(operation);
    }
  }

  static void recordError(String moduleId, dynamic error) {
    if (_metrics.containsKey(moduleId)) {
      _metrics[moduleId]!.recordError(error);
    }
  }

  static ModulePerformanceMetrics? getMetrics(String moduleId) {
    return _metrics[moduleId];
  }

  static Map<String, ModulePerformanceMetrics> getAllMetrics() {
    return Map.from(_metrics);
  }

  static void resetMetrics(String moduleId) {
    _metrics.remove(moduleId);
  }
}

class ModulePerformanceMetrics {
  final Map<String, OperationMetrics> operations = {};
  final List<ErrorRecord> errors = [];
  final DateTime createdAt = DateTime.now();

  void startOperation(String operation) {
    operations[operation] = OperationMetrics(startTime: DateTime.now());
  }

  void endOperation(String operation) {
    final metrics = operations[operation];
    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.duration = metrics.endTime!.difference(metrics.startTime).inMilliseconds;
    }
  }

  void recordError(dynamic error) {
    errors.add(ErrorRecord(
      error: error.toString(),
      timestamp: DateTime.now(),
    ));
  }

  double get averageResponseTime {
    if (operations.isEmpty) return 0.0;
    final completedOps = operations.values.where((op) => op.endTime != null);
    if (completedOps.isEmpty) return 0.0;

    final totalTime = completedOps.fold<int>(
      0,
      (sum, op) => sum + (op.duration ?? 0),
    );
    return totalTime / completedOps.length;
  }

  int get errorCount => errors.length;

  Map<String, dynamic> toMap() {
    return {
      'operations': operations.map((k, v) => MapEntry(k, v.toMap())),
      'errors': errors.map((e) => e.toMap()).toList(),
      'averageResponseTime': averageResponseTime,
      'errorCount': errorCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

## 🎯 결론

### 모듈 시스템의 강점

✅ **코드 중복 완전 제거** - 범용 컴포넌트 + 설정 파일
✅ **모듈 독립성 보장** - 각 모듈 독립적 개발/관리
✅ **런타임 모듈 전환** - 실시간 모듈 스위칭
✅ **확장성 극대화** - 새로운 모듈 쉽게 추가
✅ **성능 모니터링** - 각 모듈별 성능 추적
✅ **에러 격리** - 모듈별 에러 독립적 처리

### 구현 우선순위

1. **코어 모듈 인터페이스** (SousChefModule)
2. **모듈 관리자** (ModuleManager)
3. **범용 UI 컴포넌트** (DynamicAnalysisTab)
4. **빵 모듈 구현** (첫 번째 모듈)
5. **성능 모니터링 시스템**
6. **모듈별 설정 시스템**

이 모듈 시스템을 통해 다중 모듈을 효율적으로 관리하면서도 코드 중복을 완전히 제거할 수 있습니다. 각 모듈은 독립적으로 개발되고 관리되며, 범용 UI 컴포넌트를 통해 일관된 사용자 경험을 제공합니다.
