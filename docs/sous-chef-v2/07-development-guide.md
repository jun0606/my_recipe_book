# 07. 개발 가이드

## 📋 개요

수쉐프 모드 v2.0의 개발 가이드는 새로운 아키텍처에 따라 모듈을 개발하고 시스템에 통합하는 방법을 설명합니다.

## 🎯 개발 원칙

### 1. SOLID 원칙 준수
```dart
// 단일 책임 원칙: 각 모듈은 하나의 책임만 가짐
class BreadModule implements SousChefModule {
  // 오직 빵 분석만 수행
}

// 개방-폐쇄 원칙: 확장에는 열려있고, 수정에는 닫혀있음
class ModuleManager {
  // 새로운 모듈을 쉽게 추가할 수 있음
  static void registerModule(String id, SousChefModule module) {
    // 기존 코드 수정 없이 새로운 모듈 추가 가능
  }
}
```

### 2. Null Safety 엄격 준수
```dart
// 모든 타입은 Null Safety를 준수
class UnifiedIngredient {
  final String id;        // required - 절대 null이 아님
  final String? unit;     // optional - null일 수 있음
  final double? amount;   // optional - null일 수 있음

  // 팩토리 메서드에서 null 처리
  factory UnifiedIngredient.from(Ingredient ingredient) {
    return UnifiedIngredient(
      id: ingredient.id,  // null이면 에러 발생
      name: ingredient.name,
      amount: ingredient.amount,
      unit: ingredient.unit, // null 허용
    );
  }
}
```

### 3. 이벤트 기반 아키텍처
```dart
// 모든 통신은 이벤트 기반으로 수행
class BreadModule implements SousChefModule {
  Future<AnalysisResult> analyze(UnifiedRecipe recipe) async {
    // 분석 시작 이벤트 발행
    SousChefEventBus().publish('analysis:started', {
      'moduleId': moduleId,
      'recipeId': recipe.id,
    });

    try {
      final result = await _performAnalysis(recipe);

      // 분석 완료 이벤트 발행
      SousChefEventBus().publish('analysis:completed', {
        'moduleId': moduleId,
        'result': result,
      });

      return result;
    } catch (e) {
      // 에러 이벤트 발행
      SousChefEventBus().publish('analysis:error', {
        'moduleId': moduleId,
        'error': e.toString(),
      });
      throw e;
    }
  }
}
```

## 🔧 새로운 모듈 개발하기

### 1단계: 모듈 인터페이스 구현

#### 기본 모듈 구조
```dart
// lib/modules/[module_name]/[module_name]_module.dart
class [ModuleName]Module implements SousChefModule {
  @override
  String get moduleId => '[module_name]';

  @override
  String get displayName => '[모듈 표시 이름]';

  @override
  IconData get icon => [Icons.icon_name];

  @override
  Color get themeColor => [Colors.color_name];

  @override
  String get description => '[모듈 설명]';

  @override
  ModuleCapabilities get capabilities => const ModuleCapabilities(
    supportsRealTimeAnalysis: [true/false],
    supportsRecipeModification: [true/false],
    supportedProcessTypes: ['process1', 'process2'],
    supportedIngredientTypes: ['ingredient1', 'ingredient2'],
  );

  @override
  List<String> get supportedRecipeTypes => ['recipe_type1', 'recipe_type2'];

  @override
  bool canHandleRecipe(UnifiedRecipe recipe) {
    // 레시피 처리 가능 여부 판단 로직
    return [처리 가능 여부 로직];
  }

  @override
  Future<bool> validateRecipe(UnifiedRecipe recipe) async {
    // 레시피 유효성 검증 로직
    return [유효성 검증 결과];
  }

  @override
  Future<AnalysisResult> analyze(UnifiedRecipe recipe) async {
    try {
      // 모듈별 특화 분석 로직
      final analysis = await _performModuleAnalysis(recipe);
      return AnalysisResult.success(
        moduleId: moduleId,
        data: analysis,
        // 기타 분석 결과들...
      );
    } catch (e) {
      return AnalysisResult.error(
        moduleId: moduleId,
        errorMessage: '분석 중 오류가 발생했습니다: $e',
      );
    }
  }

  @override
  Future<AnalysisResult> quickAnalyze(UnifiedRecipe recipe) async {
    // 빠른 분석 로직 (간단한 버전)
    return [빠른 분석 결과];
  }

  @override
  Future<List<String>> getGeneralAdvice(UnifiedRecipe recipe) async {
    // 일반 조언 생성 로직
    return [조언 목록];
  }

  @override
  Future<List<String>> getSpecificAdvice(
    UnifiedRecipe recipe,
    String aspect
  ) async {
    // 특정 측면에 대한 조언 생성 로직
    return [특정 조언 목록];
  }

  @override
  Future<List<String>> getImprovementSuggestions(
    UnifiedRecipe recipe
  ) async {
    // 개선 제안 생성 로직
    return [개선 제안 목록];
  }

  @override
  List<Widget> buildAnalysisUI(AnalysisResult result) {
    // 분석 UI 컴포넌트 생성
    return [
      [ModuleName]AnalysisCard(result: result),
      // 기타 분석 UI 컴포넌트들...
    ];
  }

  @override
  List<Widget> buildAdviceUI(AnalysisResult result) {
    // 조언 UI 컴포넌트 생성
    return [
      [ModuleName]AdviceCard(result: result),
      // 기타 조언 UI 컴포넌트들...
    ];
  }

  @override
  List<Widget> buildImprovementUI(AnalysisResult result) {
    // 개선 UI 컴포넌트 생성
    return [
      [ModuleName]ImprovementCard(result: result),
      // 기타 개선 UI 컴포넌트들...
    ];
  }

  @override
  Future<void> initialize() async {
    // 모듈 초기화 로직
    // 리소스 로드, 설정 초기화 등
  }

  @override
  Future<void> dispose() async {
    // 모듈 정리 로직
    // 리소스 해제, 구독 취소 등
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    // 설정 업데이트 로직
  }

  @override
  void onRecipeUpdated(UnifiedRecipe recipe) {
    // 레시피 업데이트 처리
  }

  @override
  void onModuleActivated() {
    // 모듈 활성화 처리
  }

  @override
  void onModuleDeactivated() {
    // 모듈 비활성화 처리
  }
}
```

### 2단계: 모듈별 분석 로직 구현

#### 분석 로직 템플릿
```dart
// lib/modules/[module_name]/analysis/[module_name]_analyzer.dart
class [ModuleName]Analyzer {
  final SousChefEventBus eventBus;

  [ModuleName]Analyzer({required this.eventBus});

  Future<Map<String, dynamic>> analyze(UnifiedRecipe recipe) async {
    // 1. 모듈별 데이터 추출
    final moduleData = await ModuleDataExtractor.extractModuleData(
      recipe,
      '[module_name]'
    );

    // 2. 재료 분석
    final ingredientAnalysis = await _analyzeIngredients(recipe);

    // 3. 공정 분석
    final processAnalysis = await _analyzeProcesses(recipe);

    // 4. 장비 분석
    final equipmentAnalysis = await _analyzeEquipment(recipe);

    // 5. 종합 분석
    final comprehensiveAnalysis = await _comprehensiveAnalysis(
      ingredientAnalysis,
      processAnalysis,
      equipmentAnalysis,
    );

    // 6. 분석 메트릭 계산
    final metrics = _calculateMetrics(comprehensiveAnalysis);

    // 7. 문제점 식별
    final issues = _identifyIssues(comprehensiveAnalysis);

    // 8. 조언 생성
    final advice = await _generateAdvice(comprehensiveAnalysis, issues);

    return {
      'ingredients': ingredientAnalysis,
      'processes': processAnalysis,
      'equipment': equipmentAnalysis,
      'comprehensive': comprehensiveAnalysis,
      'metrics': metrics,
      'issues': issues,
      'advice': advice,
    };
  }

  Future<Map<String, dynamic>> _analyzeIngredients(UnifiedRecipe recipe) async {
    // 모듈별 재료 분석 로직
    return {};
  }

  Future<Map<String, dynamic>> _analyzeProcesses(UnifiedRecipe recipe) async {
    // 모듈별 공정 분석 로직
    return {};
  }

  Future<Map<String, dynamic>> _analyzeEquipment(UnifiedRecipe recipe) async {
    // 모듈별 장비 분석 로직
    return {};
  }

  Future<Map<String, dynamic>> _comprehensiveAnalysis(
    Map<String, dynamic> ingredients,
    Map<String, dynamic> processes,
    Map<String, dynamic> equipment,
  ) async {
    // 종합 분석 로직
    return {};
  }

  Map<String, dynamic> _calculateMetrics(Map<String, dynamic> analysis) {
    // 메트릭 계산 로직
    return {};
  }

  List<String> _identifyIssues(Map<String, dynamic> analysis) {
    // 문제점 식별 로직
    return [];
  }

  Future<List<String>> _generateAdvice(
    Map<String, dynamic> analysis,
    List<String> issues,
  ) async {
    // 조언 생성 로직
    return [];
  }
}
```

### 3단계: UI 컴포넌트 구현

#### 분석 카드 템플릿
```dart
// lib/modules/[module_name]/ui/[module_name]_analysis_card.dart
class [ModuleName]AnalysisCard extends StatelessWidget {
  final AnalysisResult result;

  const [ModuleName]AnalysisCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = ModuleThemeProvider.getTheme('[module_name]');

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            Divider(),
            _buildMetrics(result),
            _buildIssues(result),
            _buildScore(result),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ModuleTheme theme) {
    return Row(
      children: [
        Icon(
          [Icons.icon_name],
          color: theme.primaryColor,
        ),
        SizedBox(width: 8),
        Text(
          '[모듈 이름] 분석 결과',
          style: theme.titleStyle,
        ),
        Spacer(),
        _buildScoreBadge(result.isSuccessful ? 0.85 : 0.0), // 임시 점수
      ],
    );
  }

  Widget _buildMetrics(AnalysisResult result) {
    final data = result.data as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('분석 메트릭', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        // 모듈별 메트릭 표시 로직
        _buildMetricRow('메트릭 1', data['metric1'] ?? 0),
        _buildMetricRow('메트릭 2', data['metric2'] ?? 0),
        // 기타 메트릭들...
      ],
    );
  }

  Widget _buildIssues(AnalysisResult result) {
    if (result.issues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          '✅ 모든 조건이 최적입니다!',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('개선 필요 사항:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...result.issues.map((issue) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text(issue)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildScore(AnalysisResult result) {
    final score = result.isSuccessful ? 85 : 0; // 임시 점수 계산

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '종합 점수: $score점',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toString()),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(double score) {
    final color = score >= 0.8 ? Colors.green :
                  score >= 0.6 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '${(score * 100).round()}%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

### 4단계: 모듈 등록

#### 모듈 등록 예시
```dart
// lib/modules/[module_name]/[module_name]_module_register.dart
class [ModuleName]ModuleRegister {
  static void register() {
    // 모듈 메타데이터 생성
    final metadata = ModuleMetadata(
      version: '1.0.0',
      author: '[개발자 이름]',
      description: '[모듈 설명]',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dependencies: {
        'core': '>=1.0.0',
        // 기타 의존성...
      },
      settings: {
        // 기본 설정...
      },
    );

    // 모듈 인스턴스 생성
    final module = [ModuleName]Module();

    // 모듈 등록
    ModuleManager.registerModule('[module_name]', module, metadata);

    // UI 컴포넌트 등록
    ComponentFactory.registerBuilder(
      '[module_name]_analysis_card',
      (data) => [ModuleName]AnalysisCard(result: data),
    );

    // 이벤트 구독 설정
    _setupEventSubscriptions(module);
  }

  static void _setupEventSubscriptions([ModuleName]Module module) {
    // 레시피 업데이트 구독
    SousChefEventBus().subscribe<RecipeUpdateEvent>(
      SousChefEvent.recipeUpdated.name,
    ).listen((event) {
      module.onRecipeUpdated(event.recipe);
    });

    // 모듈 활성화/비활성화 구독
    SousChefEventBus().subscribe<ModuleSwitchEvent>(
      SousChefEvent.moduleSwitched.name,
    ).listen((event) {
      if (event.moduleId == module.moduleId) {
        if (event.state == ModuleState.active) {
          module.onModuleActivated();
        } else {
          module.onModuleDeactivated();
        }
      }
    });
  }
}
```

### 5단계: 메인 앱에 통합

#### 모듈 초기화
```dart
// lib/main.dart 또는 초기화 파일
void initializeSousChefModules() {
  // 코어 모듈들 등록
  BreadModuleRegister.register();
  // CakeModuleRegister.register();
  // CookieModuleRegister.register();
  // DessertModuleRegister.register();

  // 새로운 모듈 등록
  [ModuleName]ModuleRegister.register();

  // 기본 컴포넌트 등록
  ComponentFactory.registerDefaultComponents();
}
```

## 🧪 테스트 가이드

### 1. 단위 테스트

#### 모듈 테스트 템플릿
```dart
// test/modules/[module_name]/[module_name]_module_test.dart
void main() {
  group('[ModuleName]Module', () {
    late [ModuleName]Module module;
    late UnifiedRecipe testRecipe;

    setUp(() {
      module = [ModuleName]Module();
      testRecipe = _createTestRecipe();
    });

    test('moduleId should be [module_name]', () {
      expect(module.moduleId, '[module_name]');
    });

    test('displayName should be correct', () {
      expect(module.displayName, '[모듈 표시 이름]');
    });

    test('canHandleRecipe should work correctly', () {
      expect(module.canHandleRecipe(testRecipe), true);
    });

    test('analyze should return valid result', () async {
      final result = await module.analyze(testRecipe);

      expect(result, isA<AnalysisResult>());
      expect(result.moduleId, module.moduleId);
      expect(result.isSuccessful, true);
    });

    test('buildAnalysisUI should return widgets', () {
      final result = AnalysisResult.success(
        moduleId: module.moduleId,
        data: {},
      );

      final widgets = module.buildAnalysisUI(result);
      expect(widgets, isNotEmpty);
      expect(widgets.every((w) => w is Widget), true);
    });
  });
}
```

### 2. 통합 테스트

#### 모듈 통합 테스트
```dart
// test/integration/[module_name]_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[ModuleName]Module Integration Tests', () {
    testWidgets('full analysis flow', (tester) async {
      // 1. 모듈 초기화
      final module = [ModuleName]Module();
      await module.initialize();

      // 2. 테스트 레시피 생성
      final recipe = _createIntegrationTestRecipe();

      // 3. 분석 실행
      final result = await module.analyze(recipe);

      // 4. 결과 검증
      expect(result.isSuccessful, true);
      expect(result.issues, isNotEmpty);

      // 5. UI 컴포넌트 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: module.buildAnalysisUI(result),
            ),
          ),
        ),
      );

      // 6. UI 요소 존재 확인
      expect(find.byType([ModuleName]AnalysisCard), findsOneWidget);
    });
  });
}
```

## 📊 성능 모니터링

### 1. 모듈 성능 메트릭

#### 성능 모니터링 사용법
```dart
// lib/modules/[module_name]/[module_name]_performance_monitor.dart
class [ModuleName]PerformanceMonitor {
  static void monitorAnalysis(String operation, Future<void> Function() analysis) async {
    final startTime = DateTime.now();

    try {
      await analysis();

      final duration = DateTime.now().difference(startTime);

      // 성능 메트릭 발행
      SousChefEventBus().publish('performance:analysis', {
        'moduleId': '[module_name]',
        'operation': operation,
        'duration': duration.inMilliseconds,
        'success': true,
      });

    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      // 에러 메트릭 발행
      SousChefEventBus().publish('performance:error', {
        'moduleId': '[module_name]',
        'operation': operation,
        'duration': duration.inMilliseconds,
        'error': e.toString(),
      });
    }
  }
}
```

### 2. 메모리 관리

#### 모듈 메모리 관리
```dart
class [ModuleName]MemoryManager {
  static final Map<String, dynamic> _cache = {};

  static void cacheData(String key, dynamic data) {
    _cache[key] = data;

    // 캐시 크기 제한
    if (_cache.length > 100) {
      _clearOldCache();
    }
  }

  static dynamic getCachedData(String key) {
    return _cache[key];
  }

  static void clearCache() {
    _cache.clear();
  }

  static void _clearOldCache() {
    // 오래된 캐시 항목 정리 로직
    final keysToRemove = _cache.keys.take(20).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
}
```

## 🎯 결론

### 개발 가이드 핵심 포인트

✅ **SOLID 원칙 준수** - 유지보수성과 확장성 보장
✅ **Null Safety 엄격 준수** - 런타임 에러 방지
✅ **이벤트 기반 아키텍처** - 모듈 간 느슨한 결합
✅ **포괄적인 테스트** - 단위 테스트 + 통합 테스트
✅ **성능 모니터링** - 실시간 성능 추적

### 모듈 개발 체크리스트

- [ ] 모듈 인터페이스 구현 (`SousChefModule`)
- [ ] 모듈별 분석 로직 구현
- [ ] UI 컴포넌트 구현 (범용 컴포넌트 활용)
- [ ] 이벤트 구독 및 발행 로직 구현
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] 성능 모니터링 구현
- [ ] 모듈 메타데이터 설정
- [ ] 문서화

이 개발 가이드를 따라 새로운 모듈을 개발하면, 수쉐프 모드 v2.0의 아키텍처를 완벽하게 준수하면서도 안정적이고 확장 가능한 모듈을 만들 수 있습니다.

## 🔐 보안 개발 가이드

### 1. 보안 코딩 표준

#### 입력 검증
```dart
// lib/modules/[module_name]/security/input_validator.dart
class InputValidator {
  static bool validateRecipeInput(UnifiedRecipe recipe) {
    // 1. 필수 필드 검증
    if (recipe.id.isEmpty || recipe.title.isEmpty) {
      throw SecurityException('Invalid recipe input: missing required fields');
    }

    // 2. 데이터 범위 검증
    if (recipe.ingredients.length > 100) {
      throw SecurityException('Too many ingredients');
    }

    // 3. 타입 검증
    for (final ingredient in recipe.ingredients) {
      if (ingredient.amount < 0) {
        throw SecurityException('Invalid ingredient amount');
      }
    }

    // 4. SQL 인젝션 방지
    if (_containsSqlInjection(recipe.title)) {
      throw SecurityException('Potential SQL injection detected');
    }

    return true;
  }

  static bool _containsSqlInjection(String input) {
    final dangerousPatterns = [
      RegExp(r';\s*DROP', caseSensitive: false),
      RegExp(r';\s*DELETE', caseSensitive: false),
      RegExp(r';\s*UPDATE', caseSensitive: false),
      RegExp(r'--'),
      RegExp(r'/\*.*\*/'),
    ];

    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  static String sanitizeInput(String input) {
    // HTML 엔티티 이스케이프
    return input
      .replaceAll('&', '&')
      .replaceAll('<', '<')
      .replaceAll('>', '>')
      .replaceAll('"', '"')
      .replaceAll("'", '&#x27;');
  }
}
```

#### 데이터 암호화
```dart
// lib/modules/[module_name]/security/data_encryptor.dart
class DataEncryptor {
  static const String ALGORITHM = 'AES-256-GCM';

  static Future<String> encryptSensitiveData(
    String data,
    String key
  ) async {
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);

    // PBKDF2로 키 생성
    final derivedKey = await _deriveKey(keyBytes, _getSalt());

    // AES 암호화
    final encrypter = Encrypter(AES(Key(derivedKey)));
    final encrypted = encrypter.encrypt(data);

    return encrypted.base64;
  }

  static Future<String> decryptSensitiveData(
    String encryptedData,
    String key
  ) async {
    final keyBytes = utf8.encode(key);

    // PBKDF2로 키 생성
    final derivedKey = await _deriveKey(keyBytes, _getSalt());

    // AES 복호화
    final encrypter = Encrypter(AES(Key(derivedKey)));
    final decrypted = encrypter.decrypt64(encryptedData);

    return decrypted;
  }

  static Future<List<int>> _deriveKey(List<int> keyBytes, List<int> salt) async {
    return await pbkdf2(
      keyBytes,
      salt: salt,
      iterations: 10000,
      keyLength: 32, // AES-256
    );
  }

  static List<int> _getSalt() {
    return utf8.encode('souschef_module_salt');
  }
}
```

### 2. 권한 관리

#### 모듈 권한 시스템
```dart
// lib/modules/[module_name]/security/module_permissions.dart
class ModulePermissionManager {
  static final Map<String, Set<ModulePermission>> _permissions = {};

  static void definePermissions(String moduleId, Set<ModulePermission> permissions) {
    _permissions[moduleId] = permissions;
  }

  static Future<bool> checkPermission(
    String moduleId,
    ModulePermission permission,
    UserContext context
  ) async {
    // 1. 모듈 권한 확인
    final modulePermissions = _permissions[moduleId];
    if (modulePermissions == null || !modulePermissions.contains(permission)) {
      return false;
    }

    // 2. 사용자 역할 확인
    if (!await _checkUserRole(context, permission)) {
      return false;
    }

    // 3. 추가 보안 검증
    return await _performAdditionalSecurityChecks(context, permission);
  }

  static Future<bool> _checkUserRole(
    UserContext context,
    ModulePermission permission
  ) async {
    switch (permission.level) {
      case PermissionLevel.public:
        return true;
      case PermissionLevel.user:
        return context.userRole != UserRole.guest;
      case PermissionLevel.premium:
        return context.userRole == UserRole.premium || context.userRole == UserRole.admin;
      case PermissionLevel.admin:
        return context.userRole == UserRole.admin;
      default:
        return false;
    }
  }

  static Future<bool> _performAdditionalSecurityChecks(
    UserContext context,
    ModulePermission permission
  ) async {
    // 디바이스 신뢰도 확인
    if (context.deviceTrustScore < 0.8) {
      Logger.warning('Low device trust score: ${context.deviceTrustScore}');
      return false;
    }

    // 세션 유효성 확인
    if (!await _isSessionValid(context.sessionId)) {
      return false;
    }

    return true;
  }

  static Future<bool> _isSessionValid(String sessionId) async {
    // 세션 유효성 검증 로직
    return true; // 실제로는 서버에서 검증
  }
}

enum ModulePermission {
  readRecipe,
  analyzeRecipe,
  modifyRecipe,
  accessUserData,
  exportData,
}

enum PermissionLevel {
  public,
  user,
  premium,
  admin,
}

class UserContext {
  final String userId;
  final UserRole userRole;
  final String sessionId;
  final double deviceTrustScore;
  final Map<String, dynamic> attributes;

  const UserContext({
    required this.userId,
    required this.userRole,
    required this.sessionId,
    required this.deviceTrustScore,
    this.attributes = const {},
  });
}
```

## 📊 고급 성능 모니터링

### 1. 실시간 성능 대시보드

#### PerformanceDashboard - 성능 모니터링 대시보드
```dart
// lib/modules/[module_name]/monitoring/performance_dashboard.dart
class PerformanceDashboard {
  final String moduleId;
  final PerformanceCollector _collector;
  final AlertManager _alertManager;

  PerformanceDashboard({
    required this.moduleId,
    required PerformanceCollector collector,
    required AlertManager alertManager,
  }) : _collector = collector,
       _alertManager = alertManager;

  void startMonitoring() {
    // 실시간 메트릭 수집 시작
    Timer.periodic(const Duration(seconds: 5), (_) {
      _collectAndAnalyzeMetrics();
    });
  }

  void _collectAndAnalyzeMetrics() async {
    // 1. 메트릭 수집
    final metrics = await _collector.collectMetrics();

    // 2. 임계값 검증
    final violations = _checkThresholds(metrics);

    // 3. 알림 발행
    for (final violation in violations) {
      await _alertManager.sendAlert(violation);
    }

    // 4. 대시보드 업데이트
    _updateDashboard(metrics, violations);
  }

  List<ThresholdViolation> _checkThresholds(PerformanceMetrics metrics) {
    final violations = <ThresholdViolation>[];

    // 응답 시간 검증
    if (metrics.averageResponseTime > const Duration(seconds: 5)) {
      violations.add(ThresholdViolation(
        type: 'response_time',
        value: metrics.averageResponseTime.inMilliseconds,
        threshold: 5000,
        severity: Severity.high,
      ));
    }

    // 메모리 사용량 검증
    if (metrics.memoryUsage > 100 * 1024 * 1024) { // 100MB
      violations.add(ThresholdViolation(
        type: 'memory_usage',
        value: metrics.memoryUsage,
        threshold: 100 * 1024 * 1024,
        severity: Severity.critical,
      ));
    }

    // CPU 사용량 검증
    if (metrics.cpuUsage > 80.0) {
      violations.add(ThresholdViolation(
        type: 'cpu_usage',
        value: metrics.cpuUsage,
        threshold: 80.0,
        severity: Severity.medium,
      ));
    }

    return violations;
  }

  void _updateDashboard(PerformanceMetrics metrics, List<ThresholdViolation> violations) {
    // 대시보드 UI 업데이트 이벤트 발행
    SousChefEventBus().publish('dashboard:update', {
      'moduleId': moduleId,
      'metrics': metrics.toMap(),
      'violations': violations.map((v) => v.toMap()).toList(),
      'timestamp': DateTime.now(),
    });
  }
}

class PerformanceMetrics {
  final Duration averageResponseTime;
  final int memoryUsage;
  final double cpuUsage;
  final int errorCount;
  final int requestCount;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.averageResponseTime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.errorCount,
    required this.requestCount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'averageResponseTime': averageResponseTime.inMilliseconds,
      'memoryUsage': memoryUsage,
      'cpuUsage': cpuUsage,
      'errorCount': errorCount,
      'requestCount': requestCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ThresholdViolation {
  final String type;
  final dynamic value;
  final dynamic threshold;
  final Severity severity;

  const ThresholdViolation({
    required this.type,
    required this.value,
    required this.threshold,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'threshold': threshold,
      'severity': severity.name,
    };
  }
}

enum Severity {
  low,
  medium,
  high,
  critical,
}
```

### 2. 성능 최적화 도구

#### PerformanceOptimizer - 성능 최적화 도구
```dart
// lib/modules/[module_name]/optimization/performance_optimizer.dart
class PerformanceOptimizer {
  final String moduleId;
  final PerformanceMetricsCollector _metricsCollector;

  PerformanceOptimizer({
    required this.moduleId,
    required PerformanceMetricsCollector metricsCollector,
  }) : _metricsCollector = metricsCollector;

  Future<OptimizationResult> analyzeAndOptimize() async {
    // 1. 현재 성능 메트릭 수집
    final currentMetrics = await _metricsCollector.collect();

    // 2. 병목 지점 식별
    final bottlenecks = await _identifyBottlenecks(currentMetrics);

    // 3. 최적화 전략 생성
    final strategies = await _generateOptimizationStrategies(bottlenecks);

    // 4. 최적화 적용
    final results = <OptimizationResult>[];
    for (final strategy in strategies) {
      final result = await _applyOptimizationStrategy(strategy);
      results.add(result);
    }

    // 5. 결과 종합
    return _summarizeResults(results);
  }

  Future<List<Bottleneck>> _identifyBottlenecks(PerformanceMetrics metrics) async {
    final bottlenecks = <Bottleneck>[];

    // 메모리 누수 검출
    if (metrics.memoryUsage > 50 * 1024 * 1024) {
      bottlenecks.add(Bottleneck(
        type: BottleneckType.memoryLeak,
        severity: Severity.high,
        description: 'High memory usage detected',
      ));
    }

    // 느린 응답 시간
    if (metrics.averageResponseTime > const Duration(seconds: 2)) {
      bottlenecks.add(Bottleneck(
        type: BottleneckType.slowResponse,
        severity: Severity.medium,
        description: 'Slow response time detected',
      ));
    }

    // 잦은 에러 발생
    if (metrics.errorCount > 10) {
      bottlenecks.add(Bottleneck(
        type: BottleneckType.highErrorRate,
        severity: Severity.high,
        description: 'High error rate detected',
      ));
    }

    return bottlenecks;
  }

  Future<List<OptimizationStrategy>> _generateOptimizationStrategies(
    List<Bottleneck> bottlenecks
  ) async {
    final strategies = <OptimizationStrategy>[];

    for (final bottleneck in bottlenecks) {
      switch (bottleneck.type) {
        case BottleneckType.memoryLeak:
          strategies.add(OptimizationStrategy(
            type: StrategyType.memoryOptimization,
            description: 'Implement memory optimization techniques',
            actions: [
              'Clear unused caches',
              'Implement weak references',
              'Optimize object pooling',
            ],
          ));
          break;

        case BottleneckType.slowResponse:
          strategies.add(OptimizationStrategy(
            type: StrategyType.caching,
            description: 'Implement caching mechanisms',
            actions: [
              'Add result caching',
              'Implement lazy loading',
              'Optimize data structures',
            ],
          ));
          break;

        case BottleneckType.highErrorRate:
          strategies.add(OptimizationStrategy(
            type: StrategyType.errorHandling,
            description: 'Improve error handling',
            actions: [
              'Add retry mechanisms',
              'Implement circuit breaker',
              'Add fallback strategies',
            ],
          ));
          break;
      }
    }

    return strategies;
  }

  Future<OptimizationResult> _applyOptimizationStrategy(
    OptimizationStrategy strategy
  ) async {
    // 최적화 전략 적용
    Logger.info('Applying optimization strategy: ${strategy.description}');

    // 실제 최적화 로직 구현
    return OptimizationResult(
      strategy: strategy,
      success: true,
      improvement: 0.0, // 개선 정도 계산
      appliedAt: DateTime.now(),
    );
  }

  OptimizationResult _summarizeResults(List<OptimizationResult> results) {
    final totalImprovement = results.fold<double>(
      0.0,
      (sum, result) => sum + result.improvement
    );

    return OptimizationResult(
      strategy: OptimizationStrategy(
        type: StrategyType.summary,
        description: 'Optimization summary',
        actions: [],
      ),
      success: results.every((r) => r.success),
      improvement: totalImprovement,
      appliedAt: DateTime.now(),
    );
  }
}

enum BottleneckType {
  memoryLeak,
  slowResponse,
  highErrorRate,
  highCpuUsage,
}

class Bottleneck {
  final BottleneckType type;
  final Severity severity;
  final String description;

  const Bottleneck({
    required this.type,
    required this.severity,
    required this.description,
  });
}

enum StrategyType {
  memoryOptimization,
  caching,
  errorHandling,
  summary,
}

class OptimizationStrategy {
  final StrategyType type;
  final String description;
  final List<String> actions;

  const OptimizationStrategy({
    required this.type,
    required this.description,
    required this.actions,
  });
}

class OptimizationResult {
  final OptimizationStrategy strategy;
  final bool success;
  final double improvement;
  final DateTime appliedAt;

  const OptimizationResult({
    required this.strategy,
    required this.success,
    required this.improvement,
    required this.appliedAt,
  });
}
```

## 🚨 고급 오류 처리 패턴

### 1. 회로 차단기 패턴

#### CircuitBreaker - 회로 차단기 구현
```dart
// lib/modules/[module_name]/error_handling/circuit_breaker.dart
class CircuitBreaker {
  final String serviceName;
  final int failureThreshold;
  final Duration timeout;
  final Duration retryTimeout;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    required this.serviceName,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.retryTimeout = const Duration(minutes: 1),
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitBreakerState.halfOpen;
      } else {
        throw CircuitBreakerOpenException(serviceName);
      }
    }

    try {
      final result = await operation().timeout(timeout);

      // 성공 시 상태 리셋
      _onSuccess();
      return result;

    } catch (e) {
      _onFailure();
      throw e;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;

    final timeSinceLastFailure = DateTime.now().difference(_lastFailureTime!);
    return timeSinceLastFailure >= retryTimeout;
  }

  CircuitBreakerState get state => _state;
  int get currentFailureCount => _failureCount;
}

enum CircuitBreakerState {
  closed,    // 정상 작동
  open,      // 차단됨
  halfOpen,  // 재시도 중
}

class CircuitBreakerOpenException implements Exception {
  final String serviceName;

  const CircuitBreakerOpenException(this.serviceName);

  @override
  String toString() => 'Circuit breaker is open for service: $serviceName';
}
```

### 2. 재시도 정책

#### RetryPolicy - 재시도 정책
```dart
// lib/modules/[module_name]/error_handling/retry_policy.dart
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<Type> retryableExceptions;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 1),
    this.backoffMultiplier = 2.0,
    this.retryableExceptions = const [
      TimeoutException,
      NetworkException,
      TemporaryFailureException,
    ],
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();

      } catch (e) {
        lastException = e as Exception;

        // 재시도 가능 여부 확인
        if (!_isRetryable(e) || attempt == maxAttempts) {
          break;
        }

        // 재시도 전 대기
        if (attempt < maxAttempts) {
          final delay = _calculateDelay(attempt);
          await Future.delayed(delay);
        }
      }
    }

    throw RetryExhaustedException(
      maxAttempts: maxAttempts,
      lastException: lastException,
    );
  }

  bool _isRetryable(dynamic error) {
    return retryableExceptions.any((type) => error.runtimeType == type);
  }

  Duration _calculateDelay(int attempt) {
    final delay = initialDelay * pow(backoffMultiplier, attempt - 1);
    return delay < maxDelay ? delay : maxDelay;
  }
}

class RetryExhaustedException implements Exception {
  final int maxAttempts;
  final Exception? lastException;

  const RetryExhaustedException({
    required this.maxAttempts,
    this.lastException,
  });

  @override
  String toString() {
    return 'Retry exhausted after $maxAttempts attempts. Last error: $lastException';
  }
}

class TemporaryFailureException implements Exception {
  final String message;

  const TemporaryFailureException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => message;
}
```

## 🧪 고급 테스트 전략

### 1. 속성 기반 테스트

#### PropertyBasedTester - 속성 기반 테스터
```dart
// test/modules/[module_name]/property_based_test.dart
class PropertyBasedTester {
  static void testRecipeAnalysisProperties() {
    group('Recipe Analysis Properties', () {
      test('analysis is deterministic for same input', () async {
        // 같은 입력에 대해 항상 같은 결과가 나오는지 검증
        final recipe = _generateRandomRecipe();
        final module = [ModuleName]Module();

        final result1 = await module.analyze(recipe);
        final result2 = await module.analyze(recipe);

        expect(result1.isSuccessful, result2.isSuccessful);
        expect(result1.issues.length, result2.issues.length);
      });

      test('analysis handles edge cases gracefully', () async {
        // 엣지 케이스 처리 검증
        final edgeCases = [
          _createEmptyRecipe(),
          _createRecipeWithMaxIngredients(),
          _createRecipeWithNegativeValues(),
          _createRecipeWithVeryLongNames(),
        ];

        for (final recipe in edgeCases) {
          final module = [ModuleName]Module();

          // 예외가 발생하지 않아야 함
          expect(
            () async => await module.analyze(recipe),
            returnsNormally,
          );
        }
      });

      test('analysis results are consistent across sessions', () async {
        // 세션 간 일관성 검증
        final recipe = _generateRandomRecipe();
        final module1 = [ModuleName]Module();
        final module2 = [ModuleName]Module();

        final result1 = await module1.analyze(recipe);
        final result2 = await module2.analyze(recipe);

        // 결과 구조가 동일해야 함
        expect(result1.isSuccessful, result2.isSuccessful);
        expect(result1.issues.length, result2.issues.length);
      });
    });
  }

  static UnifiedRecipe _generateRandomRecipe() {
    final random = Random();
    final ingredientCount = random.nextInt(20) + 1;

    final ingredients = List.generate(
      ingredientCount,
      (i) => UnifiedIngredient(
        id: 'ing_$i',
        name: 'Ingredient $i',
        amount: random.nextDouble() * 1000,
        unit: 'g',
        properties: {},
      ),
    );

    return UnifiedRecipe(
      id: 'test_recipe_${random.nextInt(1000)}',
      title: 'Test Recipe',
      ingredients: ingredients,
      processes: [],
      equipment: UnifiedEquipment.empty(),
      metadata: RecipeMetadata.empty(),
    );
  }

  static UnifiedRecipe _createEmptyRecipe() {
    return UnifiedRecipe(
      id: 'empty_recipe',
      title: '',
      ingredients: [],
      processes: [],
      equipment: UnifiedEquipment.empty(),
      metadata: RecipeMetadata.empty(),
    );
  }

  static UnifiedRecipe _createRecipeWithMaxIngredients() {
    final ingredients = List.generate(
      1000,
      (i) => UnifiedIngredient(
        id: 'ing_$i',
        name: 'Ingredient $i',
        amount: 100.0,
        unit: 'g',
        properties: {},
      ),
    );

    return UnifiedRecipe(
      id: 'max_ingredients_recipe',
      title: 'Max Ingredients Recipe',
      ingredients: ingredients,
      processes: [],
      equipment: UnifiedEquipment.empty(),
      metadata: RecipeMetadata.empty(),
    );
  }

  static UnifiedRecipe _createRecipeWithNegativeValues() {
    return UnifiedRecipe(
      id: 'negative_recipe',
      title: 'Negative Recipe',
      ingredients: [
        UnifiedIngredient(
          id: 'negative_ing',
          name: 'Negative Ingredient',
          amount: -100.0,
          unit: 'g',
          properties: {},
        ),
      ],
      processes: [],
      equipment: UnifiedEquipment.empty(),
      metadata: RecipeMetadata.empty(),
    );
  }

  static UnifiedRecipe _createRecipeWithVeryLongNames() {
    final longName = 'A' * 10000; // 10,000자 이름

    return UnifiedRecipe(
      id: 'long_name_recipe',
      title: longName,
      ingredients: [
        UnifiedIngredient(
          id: 'long_ing',
          name: longName,
          amount: 100.0,
          unit: 'g',
          properties: {},
        ),
      ],
      processes: [],
      equipment: UnifiedEquipment.empty(),
      metadata: RecipeMetadata.empty(),
    );
  }
}
```

### 2. 부하 테스트

#### LoadTester - 부하 테스터
```dart
// test/modules/[module_name]/load_test.dart
class LoadTester {
  static Future<LoadTestResult> runLoadTest({
    required int concurrentUsers,
    required Duration testDuration,
    required Future<void> Function() operation,
  }) async {
    final results = <TestResult>[];
    final errors = <Exception>[];

    // 동시 사용자 시뮬레이션
    final futures = List.generate(concurrentUsers, (i) async {
      final userResults = <TestResult>[];

      final startTime = DateTime.now();
      final endTime = startTime.add(testDuration);

      while (DateTime.now().isBefore(endTime)) {
        try {
          final operationStart = DateTime.now();
          await operation();
          final operationEnd = DateTime.now();

          userResults.add(TestResult(
            userId: i,
            startTime: operationStart,
            endTime: operationEnd,
            success: true,
          ));
        } catch (e) {
          errors.add(e as Exception);
          userResults.add(TestResult(
            userId: i,
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            success: false,
            error: e,
          ));
        }

        // 작은 지연으로 CPU 부하 방지
        await Future.delayed(const Duration(milliseconds: 10));
      }

      return userResults;
    });

    // 모든 사용자 테스트 완료 대기
    final allResults = await Future.wait(futures);
    results.addAll(allResults.expand((userResults) => userResults));

    // 결과 분석
    return LoadTestResult(
      totalRequests: results.length,
      successfulRequests: results.where((r) => r.success).length,
      failedRequests: results.where((r) => !r.success).length,
      averageResponseTime: _calculateAverageResponseTime(results),
      maxResponseTime: _calculateMaxResponseTime(results),
      minResponseTime: _calculateMinResponseTime(results),
      percentile95ResponseTime: _calculatePercentileResponseTime(results, 0.95),
      errors: errors,
      testDuration: testDuration,
      concurrentUsers: concurrentUsers,
    );
  }

  static Duration _calculateAverageResponseTime(List<TestResult> results) {
    if (results.isEmpty) return Duration.zero;

    final totalTime = results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + (result.endTime.difference(result.startTime)),
    );

    return Duration(milliseconds: totalTime.inMilliseconds ~/ results.length);
  }

  static Duration _calculateMaxResponseTime(List<TestResult> results) {
    if (results.isEmpty) return Duration.zero;

    return results
      .map((r) => r.endTime.difference(r.startTime))
      .reduce((a, b) => a > b ? a : b);
  }

  static Duration _calculateMinResponseTime(List<TestResult> results) {
    if (results.isEmpty) return Duration.zero;

    return results
      .map((r) => r.endTime.difference(r.startTime))
      .reduce((a, b) => a < b ? a : b);
  }

  static Duration _calculatePercentileResponseTime(
    List<TestResult> results,
    double percentile,
  ) {
    if (results.isEmpty) return Duration.zero;

    final sortedTimes = results
      .map((r) => r.endTime.difference(r.startTime).inMilliseconds)
      .toList()
      ..sort();

    final index = (sortedTimes.length * percentile).floor();
    return Duration(milliseconds: sortedTimes[index]);
  }
}

class TestResult {
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final bool success;
  final dynamic error;

  const TestResult({
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.success,
    this.error,
  });
}

class LoadTestResult {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration averageResponseTime;
  final Duration maxResponseTime;
  final Duration minResponseTime;
  final Duration percentile95ResponseTime;
  final List<Exception> errors;
  final Duration testDuration;
  final int concurrentUsers;

  const LoadTestResult({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.maxResponseTime,
    required this.minResponseTime,
    required this.percentile95ResponseTime,
    required this.errors,
    required this.testDuration,
    required this.concurrentUsers,
  });

  double get successRate => totalRequests > 0 ? successfulRequests / totalRequests : 0.0;
  double get errorRate => totalRequests > 0 ? failedRequests / totalRequests : 0.0;

  void printSummary() {
    print('Load Test Summary:');
    print('- Concurrent Users: $concurrentUsers');
    print('- Test Duration: $testDuration');
    print('- Total Requests: $totalRequests');
    print('- Success Rate: ${(successRate * 100).toStringAsFixed(2)}%');
    print('- Average Response Time: $averageResponseTime');
    print('- 95th Percentile Response Time: $percentile95ResponseTime');
    print('- Max Response Time: $maxResponseTime');
    print('- Errors: ${errors.length}');
  }
}
```

이 개발 가이드를 따라 새로운 모듈을 개발하면, 수쉐프 모드 v2.0의 아키텍처를 완벽하게 준수하면서도 안정적이고 확장 가능한 모듈을 만들 수 있습니다. 보안, 성능, 오류 처리, 고급 테스트 전략을 모두 포함한 포괄적인 개발 방법을 제공합니다.
