# 드래그 앤 드롭 기능 커스터마이징 설계

## 🎯 개념

복잡한 체험 모드 대신, **드래그 앤 드롭으로 기능을 자유롭게 활성화/비활성화**하는 직관적인 시스템입니다. 사용자가 원하는 기능만 메인 화면으로 끌어와서 개인 맞춤형 인터페이스를 구성할 수 있습니다.

## 🎨 UI/UX 설계

### 📱 **메인 화면 구조**

```
┌─────────────────────────────────────────┐
│  🍞 내 레시피 계산기                      │
├─────────────────────────────────────────┤
│                                         │
│  [활성화된 기능들이 여기에 표시]          │
│                                         │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 기본 분할   │  │ 재료 조정   │      │
│  │ 계산        │  │             │      │
│  └─────────────┘  └─────────────┘      │
│                                         │
│  ┌─────────────┐                       │
│  │ 원가 계산   │                       │
│  │             │                       │
│  └─────────────┘                       │
│                                         │
├─────────────────────────────────────────┤
│  ⚙️ 기능 추가하기                        │
└─────────────────────────────────────────┘
```

### 🛠️ **기능 추가 화면**

```
┌─────────────────────────────────────────┐
│  ← 뒤로가기    기능 선택                  │
├─────────────────────────────────────────┤
│                                         │
│  📊 사용 가능한 기능들                   │
│                                         │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 📈 배치     │  │ 📋 버전     │      │
│  │ 계산        │  │ 관리        │      │
│  │ [드래그]    │  │ [드래그]    │      │
│  └─────────────┘  └─────────────┘      │
│                                         │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 🌳 레시피   │  │ 📊 성공률   │      │
│  │ 파생 관리   │  │ 추적        │      │
│  │ [드래그]    │  │ [드래그]    │      │
│  └─────────────┘  └─────────────┘      │
│                                         │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 🤖 AI      │  │ 🎵 음성     │      │
│  │ 도우미      │  │ 지원        │      │
│  │ [드래그]    │  │ [드래그]    │      │
│  └─────────────┘  └─────────────┘      │
│                                         │
├─────────────────────────────────────────┤
│  💡 위 기능들을 메인 화면으로 끌어오세요  │
└─────────────────────────────────────────┘
```

## 🔧 기술적 구현

### 📦 **기능 모듈 정의**

```dart
class FeatureModule {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCore; // 핵심 기능은 비활성화 불가
  final List<String> dependencies; // 의존성 기능들
  final Widget Function() widgetBuilder;
  
  const FeatureModule({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isCore = false,
    this.dependencies = const [],
    required this.widgetBuilder,
  });
}

// 사용 가능한 모든 기능들
class AvailableFeatures {
  static const List<FeatureModule> all = [
    // 핵심 기능 (항상 활성화)
    FeatureModule(
      id: 'basic_calculation',
      name: '기본 분할 계산',
      description: '5개 → 6개 같은 간단한 계산',
      icon: Icons.calculate,
      color: Colors.blue,
      isCore: true,
      widgetBuilder: BasicCalculationWidget.new,
    ),
    
    FeatureModule(
      id: 'recipe_storage',
      name: '레시피 저장',
      description: '내 레시피 저장하고 관리',
      icon: Icons.bookmark,
      color: Colors.green,
      isCore: true,
      widgetBuilder: RecipeStorageWidget.new,
    ),
    
    // 선택 가능한 기능들
    FeatureModule(
      id: 'ingredient_adjustment',
      name: '재료 조정',
      description: '설탕 더 넣어도 될까? 같은 질문',
      icon: Icons.tune,
      color: Colors.orange,
      widgetBuilder: IngredientAdjustmentWidget.new,
    ),
    
    FeatureModule(
      id: 'batch_calculation',
      name: '배치 계산',
      description: '여러 제품 동시 생산 계산',
      icon: Icons.view_module,
      color: Colors.purple,
      widgetBuilder: BatchCalculationWidget.new,
    ),
    
    FeatureModule(
      id: 'cost_calculation',
      name: '원가 계산',
      description: '재료비, 인건비 포함 원가 분석',
      icon: Icons.attach_money,
      color: Colors.teal,
      widgetBuilder: CostCalculationWidget.new,
    ),
    
    FeatureModule(
      id: 'version_control',
      name: '버전 관리',
      description: '레시피 수정 이력 추적',
      icon: Icons.history,
      color: Colors.indigo,
      widgetBuilder: VersionControlWidget.new,
    ),
    
    FeatureModule(
      id: 'recipe_derivation',
      name: '레시피 파생 관리',
      description: '퓨전 레시피 계보 추적',
      icon: Icons.account_tree,
      color: Colors.brown,
      dependencies: ['version_control'], // 버전 관리 필요
      widgetBuilder: RecipeDerivationWidget.new,
    ),
    
    FeatureModule(
      id: 'success_tracking',
      name: '성공률 추적',
      description: '베이킹 결과 기록 및 분석',
      icon: Icons.trending_up,
      color: Colors.pink,
      widgetBuilder: SuccessTrackingWidget.new,
    ),
    
    FeatureModule(
      id: 'ai_assistant',
      name: 'AI 도우미',
      description: '스마트한 레시피 분석과 제안',
      icon: Icons.psychology,
      color: Colors.deepPurple,
      widgetBuilder: AIAssistantWidget.new,
    ),
    
    FeatureModule(
      id: 'voice_support',
      name: '음성 지원',
      description: '조리 중 음성으로 레시피 안내',
      icon: Icons.record_voice_over,
      color: Colors.red,
      widgetBuilder: VoiceSupportWidget.new,
    ),
  ];
}
```

### 🎯 **드래그 앤 드롭 구현**

```dart
class FeatureCustomizationScreen extends StatefulWidget {
  @override
  _FeatureCustomizationScreenState createState() => _FeatureCustomizationScreenState();
}

class _FeatureCustomizationScreenState extends State<FeatureCustomizationScreen> {
  List<String> activeFeatures = ['basic_calculation', 'recipe_storage']; // 기본 활성화
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기능 선택'),
        actions: [
          TextButton(
            onPressed: _saveConfiguration,
            child: Text('완료'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 현재 활성화된 기능들 (드롭 존)
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: DragTarget<FeatureModule>(
                onAccept: (feature) {
                  setState(() {
                    if (!activeFeatures.contains(feature.id)) {
                      activeFeatures.add(feature.id);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '활성화된 기능들',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: activeFeatures.length,
                          itemBuilder: (context, index) {
                            final featureId = activeFeatures[index];
                            final feature = AvailableFeatures.all
                                .firstWhere((f) => f.id == featureId);
                            
                            return _buildActiveFeatureCard(feature);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          // 사용 가능한 기능들 (드래그 소스)
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '사용 가능한 기능들',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: AvailableFeatures.all.length,
                      itemBuilder: (context, index) {
                        final feature = AvailableFeatures.all[index];
                        final isActive = activeFeatures.contains(feature.id);
                        
                        if (isActive) {
                          return _buildPlaceholderCard(feature);
                        }
                        
                        return _buildDraggableFeatureCard(feature);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDraggableFeatureCard(FeatureModule feature) {
    return Draggable<FeatureModule>(
      data: feature,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature.icon, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                feature.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: _buildPlaceholderCard(feature),
      child: Card(
        elevation: 4,
        color: feature.color,
        child: InkWell(
          onTap: () => _showFeatureDetails(feature),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature.icon, size: 32, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  feature.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveFeatureCard(FeatureModule feature) {
    return Card(
      elevation: 2,
      color: feature.color,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature.icon, size: 32, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  feature.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (!feature.isCore) // 핵심 기능이 아닌 경우만 제거 버튼 표시
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    activeFeatures.remove(feature.id);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderCard(FeatureModule feature) {
    return Card(
      elevation: 1,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          '${feature.name}\n(활성화됨)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  void _showFeatureDetails(FeatureModule feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(feature.icon, color: feature.color),
            SizedBox(width: 8),
            Text(feature.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feature.description),
            if (feature.dependencies.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                '필요한 기능:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...feature.dependencies.map((dep) {
                final depFeature = AvailableFeatures.all
                    .firstWhere((f) => f.id == dep);
                return Text('• ${depFeature.name}');
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // 의존성 기능들도 함께 활성화
                for (final dep in feature.dependencies) {
                  if (!activeFeatures.contains(dep)) {
                    activeFeatures.add(dep);
                  }
                }
                if (!activeFeatures.contains(feature.id)) {
                  activeFeatures.add(feature.id);
                }
              });
            },
            child: Text('활성화'),
          ),
        ],
      ),
    );
  }
  
  void _saveConfiguration() {
    // SharedPreferences에 설정 저장
    FeatureConfigurationManager.saveActiveFeatures(activeFeatures);
    Navigator.pop(context);
  }
}
```

### 💾 **설정 저장 및 관리**

```dart
class FeatureConfigurationManager {
  static const String _key = 'active_features';
  
  static Future<void> saveActiveFeatures(List<String> features) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, features);
  }
  
  static Future<List<String>> loadActiveFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? ['basic_calculation', 'recipe_storage'];
  }
  
  static Future<void> resetToDefault() async {
    await saveActiveFeatures(['basic_calculation', 'recipe_storage']);
  }
}
```

### 🏠 **메인 화면 동적 구성**

```dart
class DynamicMainScreen extends StatefulWidget {
  @override
  _DynamicMainScreenState createState() => _DynamicMainScreenState();
}

class _DynamicMainScreenState extends State<DynamicMainScreen> {
  List<String> activeFeatures = [];
  
  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }
  
  Future<void> _loadConfiguration() async {
    final features = await FeatureConfigurationManager.loadActiveFeatures();
    setState(() {
      activeFeatures = features;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 레시피 계산기'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeatureCustomizationScreen(),
                ),
              );
              _loadConfiguration(); // 설정 변경 후 다시 로드
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: activeFeatures.length + 1, // +1 for "기능 추가" 카드
        itemBuilder: (context, index) {
          if (index == activeFeatures.length) {
            return _buildAddFeatureCard();
          }
          
          final featureId = activeFeatures[index];
          final feature = AvailableFeatures.all
              .firstWhere((f) => f.id == featureId);
          
          return Card(
            elevation: 4,
            color: feature.color,
            child: InkWell(
              onTap: () => _openFeature(feature),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature.icon, size: 40, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      feature.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAddFeatureCard() {
    return Card(
      elevation: 2,
      color: Colors.grey[200],
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeatureCustomizationScreen(),
            ),
          );
          _loadConfiguration();
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: Colors.grey[600]),
            SizedBox(height: 12),
            Text(
              '기능 추가하기',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _openFeature(FeatureModule feature) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => feature.widgetBuilder(),
      ),
    );
  }
}
```

## 🎯 장점

### ✅ **사용자 경험**
- **직관적**: 드래그 앤 드롭으로 누구나 쉽게 이해
- **자유로움**: 원하는 기능만 골라서 사용
- **즉시 적용**: 설정 변경이 바로 메인 화면에 반영
- **부담 없음**: 복잡한 체험 모드나 가입 절차 없음

### ✅ **개발 효율성**
- **모듈화**: 각 기능이 독립적인 위젯으로 구현
- **확장성**: 새로운 기능 추가가 매우 쉬움
- **유지보수**: 기능별로 분리되어 관리 용이
- **테스트**: 각 기능을 독립적으로 테스트 가능

### ✅ **비즈니스 가치**
- **사용자 만족도**: 개인 맞춤형 경험 제공
- **기능 발견**: 사용자가 새로운 기능을 자연스럽게 발견
- **데이터 수집**: 어떤 기능이 인기 있는지 파악 가능
- **점진적 학습**: 사용자가 필요에 따라 점진적으로 고급 기능 사용

이 방식이 훨씬 더 실용적이고 사용자 친화적이네요! 🎉