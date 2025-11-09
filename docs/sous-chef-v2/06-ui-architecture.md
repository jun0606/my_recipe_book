# 06. UI 아키텍처

## 📋 개요

수쉐프 모드 v2.0의 UI 아키텍처는 모듈별로 다른 UI를 제공하면서도 코드 중복을 최소화하는 동적 컴포넌트 시스템을 설계합니다.

## 🎯 설계 목표

### 1. 코드 중복 제거
```dart
// 기존 방식: 모듈별 중복 UI 컴포넌트
BreadAnalysisTab, CakeAnalysisTab, CookieAnalysisTab, DessertAnalysisTab

// 신규 방식: 단일 범용 컴포넌트
DynamicAnalysisTab(module: currentModule)
```

### 2. 모듈별 UI 유연성
```dart
// 각 모듈은 자신만의 UI를 정의할 수 있음
class BreadModule implements SousChefModule {
  List<Widget> buildAnalysisUI() => [BreadDoughCard(), BreadFermentationCard()];
}
```

### 3. 일관된 사용자 경험
```dart
// 모든 모듈에서 일관된 레이아웃과 상호작용
AppBar, TabBar, FloatingActionButton 등 공통 요소 유지
```

## 🏗️ UI 아키텍처 설계

### 1. 동적 UI 컴포넌트 시스템

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

    // 이벤트 구독 설정
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
        _currentResult = null; // 레시피 변경으로 재분석 필요
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

### 2. 모듈별 UI 컴포넌트

#### BreadAnalysisCard - 빵 분석 카드
```dart
// lib/modules/bread/ui/bread_analysis_card.dart
class BreadAnalysisCard extends StatelessWidget {
  final AnalysisResult result;

  const BreadAnalysisCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final doughAnalysis = result.processAnalysis;
    final ingredientAnalysis = result.ingredientAnalysis;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bread, color: Colors.brown),
                SizedBox(width: 8),
                Text('빵 분석 결과', style: Theme.of(context).textTheme.headline6),
                Spacer(),
                _buildScoreBadge(doughAnalysis?.score.overall ?? 0),
              ],
            ),
            Divider(),
            _buildDoughAnalysis(doughAnalysis),
            _buildIngredientAnalysis(ingredientAnalysis),
            _buildRecommendations(result),
          ],
        ),
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

  Widget _buildDoughAnalysis(ProcessAnalysis? analysis) {
    if (analysis == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('반죽 분석', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildMetric('글루텐 강도', analysis.metrics['glutenStrength'] ?? 0),
        _buildMetric('탄성', analysis.metrics['elasticity'] ?? 0),
        _buildMetric('신장성', analysis.metrics['extensibility'] ?? 0),
      ],
    );
  }

  Widget _buildIngredientAnalysis(IngredientAnalysis? analysis) {
    if (analysis == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('재료 분석', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildMetric('수분 함량', analysis.metrics['hydration'] ?? 0),
        _buildMetric('단백질 함량', analysis.metrics['protein'] ?? 0),
      ],
    );
  }

  Widget _buildMetric(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildRecommendations(AnalysisResult result) {
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
}
```

### 3. UI 설정 시스템

#### ModuleUIConfig - 모듈별 UI 설정
```dart
// lib/modules/ui/module_ui_config.dart
class ModuleUIConfig {
  final String moduleId;
  final ModuleTheme theme;
  final ModuleLayout layout;
  final ModuleComponents components;

  const ModuleUIConfig({
    required this.moduleId,
    required this.theme,
    required this.layout,
    required this.components,
  });

  factory ModuleUIConfig.fromMap(String moduleId, Map<String, dynamic> map) {
    return ModuleUIConfig(
      moduleId: moduleId,
      theme: ModuleTheme.fromMap(map['theme'] ?? {}),
      layout: ModuleLayout.fromMap(map['layout'] ?? {}),
      components: ModuleComponents.fromMap(map['components'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme.toMap(),
      'layout': layout.toMap(),
      'components': components.toMap(),
    };
  }
}

class ModuleTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  const ModuleTheme({
    required this.primaryColor,
    required this.secondaryColor,
    this.backgroundColor = Colors.white,
    this.surfaceColor = Colors.white,
    required this.titleStyle,
    required this.bodyStyle,
  });

  factory ModuleTheme.fromMap(Map<String, dynamic> map) {
    return ModuleTheme(
      primaryColor: Color(map['primaryColor'] ?? 0xFF795548),
      secondaryColor: Color(map['secondaryColor'] ?? 0xFFFF9800),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      surfaceColor: Color(map['surfaceColor'] ?? 0xFFFFFFFF),
      titleStyle: TextStyle(
        fontSize: map['titleSize'] ?? 18,
        fontWeight: FontWeight.bold,
        color: Color(map['titleColor'] ?? 0xFF000000),
      ),
      bodyStyle: TextStyle(
        fontSize: map['bodySize'] ?? 14,
        color: Color(map['bodyColor'] ?? 0xFF666666),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'titleSize': titleStyle.fontSize,
      'titleColor': titleStyle.color?.value,
      'bodySize': bodyStyle.fontSize,
      'bodyColor': bodyStyle.color?.value,
    };
  }
}

class ModuleLayout {
  final EdgeInsets padding;
  final double cardSpacing;
  final double componentSpacing;
  final bool showIcons;
  final bool showBadges;
  final bool enableAnimations;

  const ModuleLayout({
    this.padding = const EdgeInsets.all(16),
    this.cardSpacing = 8,
    this.componentSpacing = 16,
    this.showIcons = true,
    this.showBadges = true,
    this.enableAnimations = true,
  });

  factory ModuleLayout.fromMap(Map<String, dynamic> map) {
    return ModuleLayout(
      padding: EdgeInsets.all(map['padding'] ?? 16),
      cardSpacing: map['cardSpacing'] ?? 8,
      componentSpacing: map['componentSpacing'] ?? 16,
      showIcons: map['showIcons'] ?? true,
      showBadges: map['showBadges'] ?? true,
      enableAnimations: map['enableAnimations'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'padding': padding.horizontal,
      'cardSpacing': cardSpacing,
      'componentSpacing': componentSpacing,
      'showIcons': showIcons,
      'showBadges': showBadges,
      'enableAnimations': enableAnimations,
    };
  }
}

class ModuleComponents {
  final List<String> analysisCards;
  final List<String> adviceCards;
  final List<String> improvementCards;
  final Map<String, dynamic> customComponents;

  const ModuleComponents({
    required this.analysisCards,
    required this.adviceCards,
    required this.improvementCards,
    this.customComponents = const {},
  });

  factory ModuleComponents.fromMap(Map<String, dynamic> map) {
    return ModuleComponents(
      analysisCards: List<String>.from(map['analysisCards'] ?? []),
      adviceCards: List<String>.from(map['adviceCards'] ?? []),
      improvementCards: List<String>.from(map['improvementCards'] ?? []),
      customComponents: map['customComponents'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'analysisCards': analysisCards,
      'adviceCards': adviceCards,
      'improvementCards': improvementCards,
      'customComponents': customComponents,
    };
  }
}
```

### 4. UI 컴포넌트 팩토리

#### ComponentFactory - 동적 컴포넌트 생성
```dart
// lib/ui/component_factory.dart
class ComponentFactory {
  static final Map<String, WidgetBuilder> _componentBuilders = {};

  static void registerBuilder(String componentId, WidgetBuilder builder) {
    _componentBuilders[componentId] = builder;
  }

  static Widget? buildComponent(String componentId, dynamic data) {
    final builder = _componentBuilders[componentId];
    if (builder != null) {
      return builder(data);
    }
    return null;
  }

  static List<Widget> buildComponents(List<String> componentIds, dynamic data) {
    return componentIds.map((id) => buildComponent(id, data)).whereType<Widget>().toList();
  }

  // 기본 컴포넌트 등록
  static void registerDefaultComponents() {
    registerBuilder('score_badge', (data) => ScoreBadge(score: data));
    registerBuilder('metric_display', (data) => MetricDisplay(metric: data));
    registerBuilder('issue_list', (data) => IssueList(issues: data));
    registerBuilder('recommendation_list', (data) => RecommendationList(recommendations: data));
  }
}
```

## 🎨 테마 및 스타일링 시스템

### 1. 모듈별 테마 시스템

#### ModuleThemeProvider - 모듈별 테마 제공
```dart
// lib/ui/theme/module_theme_provider.dart
class ModuleThemeProvider {
  static const Map<String, ModuleTheme> _moduleThemes = {
    'bread': ModuleTheme(
      primaryColor: Colors.brown,
      secondaryColor: Colors.orange,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyStyle: TextStyle(fontSize: 14),
    ),
    'cake': ModuleTheme(
      primaryColor: Colors.pink,
      secondaryColor: Colors.purple,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyStyle: TextStyle(fontSize: 14),
    ),
    'cookie': ModuleTheme(
      primaryColor: Colors.amber,
      secondaryColor: Colors.deepOrange,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyStyle: TextStyle(fontSize: 14),
    ),
    'dessert': ModuleTheme(
      primaryColor: Colors.indigo,
      secondaryColor: Colors.cyan,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyStyle: TextStyle(fontSize: 14),
    ),
  };

  static ModuleTheme getTheme(String moduleId) {
    return _moduleThemes[moduleId] ?? _moduleThemes['bread']!;
  }

  static ThemeData getMaterialTheme(String moduleId) {
    final moduleTheme = getTheme(moduleId);
    return ThemeData(
      primaryColor: moduleTheme.primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: createMaterialColor(moduleTheme.primaryColor),
        accentColor: moduleTheme.secondaryColor,
      ),
      textTheme: TextTheme(
        headline6: moduleTheme.titleStyle,
        bodyText2: moduleTheme.bodyStyle,
      ),
      cardTheme: CardTheme(
        color: moduleTheme.surfaceColor,
        elevation: 4,
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
```

## 📊 UI 성능 모니터링

### 1. UI 성능 메트릭

#### UIMetricsCollector - UI 성능 수집
```dart
// lib/ui/monitoring/ui_metrics_collector.dart
class UIMetricsCollector {
  final Map<String, UIMetrics> _metrics = {};

  void startMeasure(String componentId) {
    _metrics[componentId] = UIMetrics(startTime: DateTime.now());
  }

  void endMeasure(String componentId) {
    final metrics = _metrics[componentId];
    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.buildTime = metrics.endTime!.difference(metrics.startTime).inMilliseconds;

      // 성능 이벤트 발행
      SousChefEventBus().publish('ui:performance', {
        'componentId': componentId,
        'metrics': metrics.toMap(),
        'timestamp': DateTime.now(),
      });
    }
  }

  void recordRenderTime(String componentId, int renderTime) {
    _metrics[componentId] ??= UIMetrics();
    _metrics[componentId]!.renderTime = renderTime;
  }

  void recordInteraction(String componentId, String interaction) {
    _metrics[componentId] ??= UIMetrics();
    _metrics[componentId]!.interactions.add(interaction);
  }

  Map<String, UIMetrics> getAllMetrics() {
    return Map.from(_metrics);
  }
}

class UIMetrics {
  DateTime startTime;
  DateTime? endTime;
  int? buildTime;
  int? renderTime;
  final List<String> interactions = [];
  final List<String> errors = [];

  UIMetrics({required this.startTime});

  void recordError(String error) {
    errors.add(error);
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'buildTime': buildTime,
      'renderTime': renderTime,
      'interactions': interactions,
      'errors': errors,
      'totalTime': endTime?.difference(startTime).inMilliseconds,
    };
  }
}
```

## 🎯 결론

### UI 아키텍처의 강점

✅ **코드 중복 완전 제거** - 범용 컴포넌트 + 설정 파일
✅ **모듈별 UI 유연성** - 각 모듈의 독자적 UI 정의
✅ **일관된 사용자 경험** - 공통 UI 요소 유지
✅ **성능 모니터링** - UI 컴포넌트별 성능 추적
✅ **확장성** - 새로운 모듈 UI 쉽게 추가

### 구현 우선순위

1. **범용 UI 컴포넌트** (DynamicAnalysisTab)
2. **모듈별 UI 설정 시스템** (ModuleUIConfig)
3. **컴포넌트 팩토리** (ComponentFactory)
4. **테마 시스템** (ModuleThemeProvider)
5. **성능 모니터링** (UIMetricsCollector)

이 UI 아키텍처를 통해 각 모듈별로 최적화된 UI를 제공하면서도 코드 중복을 완전히 제거할 수 있습니다. 모든 모듈이 일관된 사용자 경험을 유지하면서도 자신만의 독특한 특성을 표현할 수 있습니다.
