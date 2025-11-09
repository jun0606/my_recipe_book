# 기술적 고려사항 및 라이브러리 선택 가이드

## 🔒 상업적 사용 완전 무료 라이브러리 목록

### ✅ **Flutter 핵심 라이브러리 (모두 BSD-3-Clause)**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 상태 관리 (MIT)
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # 데이터베이스 (MIT)
  sqflite: ^2.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # JSON 처리 (BSD-3-Clause)
  json_annotation: ^4.8.1
  
  # HTTP 통신 (BSD-3-Clause) - AI 기능용
  http: ^1.1.0
  dio: ^5.3.2
  
  # UI 컴포넌트 (MIT)
  flutter_staggered_grid_view: ^0.7.0
  flutter_slidable: ^3.0.0
  
  # 차트 및 시각화 (BSD-3-Clause)
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.7  # Community License (무료)
  
  # 파일 처리 (MIT)
  path_provider: ^2.1.1
  file_picker: ^6.1.1
  
  # 설정 저장 (BSD-3-Clause)
  shared_preferences: ^2.2.2
  
  # 국제화 (BSD-3-Clause)
  intl: ^0.19.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  # 테스트 (BSD-3-Clause)
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  
  # 코드 생성 (BSD-3-Clause)
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
```

### ❌ **피해야 할 라이브러리 (GPL/LGPL)**
```yaml
# 절대 사용 금지
dependencies:
  # GPL 라이선스
  some_gpl_library: ^1.0.0  # ❌
  
  # LGPL 라이선스  
  some_lgpl_library: ^2.0.0  # ❌
  
  # 상업적 사용 제한
  some_commercial_library: ^3.0.0  # ❌
```

### 🔍 **라이선스 자동 검증 도구**
```yaml
dev_dependencies:
  # 라이선스 체크 도구
  license_checker: ^1.0.0  # 커스텀 구현 필요
```

```dart
// 라이선스 검증 스크립트
class LicenseChecker {
  static const allowedLicenses = [
    'MIT',
    'Apache-2.0', 
    'BSD-2-Clause',
    'BSD-3-Clause',
    'ISC',
    'Unlicense'
  ];
  
  static const forbiddenLicenses = [
    'GPL-2.0',
    'GPL-3.0', 
    'LGPL-2.1',
    'LGPL-3.0',
    'AGPL-3.0',
    'CC-BY-SA'  // ShareAlike 조건
  ];
  
  static Future<void> checkAllDependencies() async {
    // pubspec.lock 파일 분석
    // 각 패키지의 라이선스 확인
    // 금지된 라이선스 발견 시 빌드 실패
  }
}
```

## 🧠 AI 로컬 구현 방안

### 📱 **모바일 기기에서 실행 가능한 AI 옵션**

#### 1. **TensorFlow Lite (Apache-2.0)**
```yaml
dependencies:
  tflite_flutter: ^0.10.4  # Apache-2.0
  tflite_flutter_helper: ^0.3.1  # Apache-2.0
```

```dart
class LocalAIEngine {
  late Interpreter _interpreter;
  
  Future<void> loadModel() async {
    // 경량화된 레시피 분석 모델 로드
    _interpreter = await Interpreter.fromAsset('recipe_analyzer.tflite');
  }
  
  Future<RecipeAnalysis> analyzeRecipe(Recipe recipe) async {
    // 로컬에서 AI 추론 실행
    final input = preprocessRecipe(recipe);
    final output = List.filled(10, 0.0).reshape([1, 10]);
    
    _interpreter.run(input, output);
    
    return RecipeAnalysis.fromTensorOutput(output);
  }
}
```

#### 2. **ONNX Runtime (MIT)**
```yaml
dependencies:
  onnxruntime: ^1.16.0  # MIT
```

#### 3. **경량 규칙 기반 AI (자체 구현)**
```dart
class RuleBasedAI {
  // 복잡한 ML 모델 대신 규칙 기반 지능형 시스템
  static RecipeSuggestion suggestAdjustment(
    Recipe recipe, 
    String userRequest
  ) {
    // "설탕을 더 넣고 싶어요" → 안전 범위 계산
    if (userRequest.contains('설탕') && userRequest.contains('더')) {
      final currentSugar = recipe.getSugarAmount();
      final safeMax = currentSugar * 1.3; // 30% 증가까지 안전
      
      return RecipeSuggestion(
        adjustment: safeMax - currentSugar,
        warning: currentSugar * 1.5 < safeMax ? null : "너무 많이 넣으면 실패할 수 있어요",
        explanation: "설탕은 30%까지 늘려도 안전합니다"
      );
    }
    
    return RuleBasedAnalyzer.analyze(recipe, userRequest);
  }
}
```

### 🌐 **선택적 온라인 AI 연동**

#### 1. **OpenAI API (선택사항)**
```dart
class OptionalOnlineAI {
  final bool _isEnabled;
  final String? _apiKey;
  
  OptionalOnlineAI({
    bool enabled = false,
    String? apiKey,
  }) : _isEnabled = enabled && apiKey != null,
       _apiKey = apiKey;
  
  Future<String> getAdvancedSuggestion(String query) async {
    if (!_isEnabled || !await _hasInternetConnection()) {
      // 오프라인 대체 기능 사용
      return RuleBasedAI.getBasicSuggestion(query);
    }
    
    try {
      // 온라인 AI API 호출
      final response = await _callOpenAI(query);
      return response;
    } catch (e) {
      // 실패 시 오프라인 기능으로 대체
      return RuleBasedAI.getBasicSuggestion(query);
    }
  }
}
```

## 🎛️ 유연한 기능 커스터마이징 시스템

### 📋 **기능 모듈 정의**
```dart
enum FeatureModule {
  // 기본 기능 (항상 활성화)
  basicCalculation,
  recipeStorage,
  
  // 선택 가능한 기능들
  advancedCalculation,
  versionControl,
  derivationTracking,
  costCalculation,
  batchCalculation,
  successTracking,
  ingredientSubstitution,
  seasonalOptimization,
  voiceSupport,
  aiFeatures,
  collaborationTools,
}

class FeatureConfiguration {
  final Map<FeatureModule, bool> _enabledFeatures;
  
  FeatureConfiguration({
    Map<FeatureModule, bool>? customConfig,
  }) : _enabledFeatures = {
    // 기본 활성화
    FeatureModule.basicCalculation: true,
    FeatureModule.recipeStorage: true,
    
    // 기본 비활성화 (사용자 선택)
    FeatureModule.advancedCalculation: false,
    FeatureModule.versionControl: false,
    FeatureModule.derivationTracking: false,
    FeatureModule.costCalculation: false,
    FeatureModule.batchCalculation: false,
    FeatureModule.successTracking: false,
    FeatureModule.ingredientSubstitution: false,
    FeatureModule.seasonalOptimization: false,
    FeatureModule.voiceSupport: false,
    FeatureModule.aiFeatures: false,
    FeatureModule.collaborationTools: false,
    
    ...?customConfig,
  };
  
  bool isEnabled(FeatureModule feature) => _enabledFeatures[feature] ?? false;
  
  void enableFeature(FeatureModule feature) {
    _enabledFeatures[feature] = true;
    _saveConfiguration();
  }
  
  void disableFeature(FeatureModule feature) {
    if (_isRequiredFeature(feature)) return; // 필수 기능은 비활성화 불가
    _enabledFeatures[feature] = false;
    _saveConfiguration();
  }
}
```

### 🎯 **프리셋 시스템**
```dart
class FeaturePresets {
  static const Map<String, Map<FeatureModule, bool>> presets = {
    'beginner': {
      FeatureModule.basicCalculation: true,
      FeatureModule.recipeStorage: true,
      FeatureModule.ingredientSubstitution: true,
      // 나머지는 false
    },
    
    'home_baker': {
      FeatureModule.basicCalculation: true,
      FeatureModule.recipeStorage: true,
      FeatureModule.advancedCalculation: true,
      FeatureModule.versionControl: true,
      FeatureModule.successTracking: true,
      FeatureModule.ingredientSubstitution: true,
      // 나머지는 false
    },
    
    'bakery_professional': {
      FeatureModule.basicCalculation: true,
      FeatureModule.recipeStorage: true,
      FeatureModule.advancedCalculation: true,
      FeatureModule.versionControl: true,
      FeatureModule.derivationTracking: true,
      FeatureModule.costCalculation: true,
      FeatureModule.batchCalculation: true,
      FeatureModule.ingredientSubstitution: true,
      FeatureModule.seasonalOptimization: true,
      // AI와 협업 도구는 선택사항
    },
    
    'researcher': {
      // 모든 기능 활성화
      ...Map.fromEntries(
        FeatureModule.values.map((f) => MapEntry(f, true))
      ),
    },
  };
  
  static FeatureConfiguration fromPreset(String presetName) {
    final preset = presets[presetName] ?? presets['beginner']!;
    return FeatureConfiguration(customConfig: preset);
  }
}
```

### 🔍 **체험 모드 시스템**
```dart
class TrialModeManager {
  static const Duration trialDuration = Duration(days: 7);
  final Map<FeatureModule, DateTime> _trialStartDates = {};
  
  bool canStartTrial(FeatureModule feature) {
    return !_trialStartDates.containsKey(feature);
  }
  
  void startTrial(FeatureModule feature) {
    if (canStartTrial(feature)) {
      _trialStartDates[feature] = DateTime.now();
      _saveTrialData();
    }
  }
  
  bool isTrialActive(FeatureModule feature) {
    final startDate = _trialStartDates[feature];
    if (startDate == null) return false;
    
    return DateTime.now().difference(startDate) < trialDuration;
  }
  
  Duration getRemainingTrialTime(FeatureModule feature) {
    final startDate = _trialStartDates[feature];
    if (startDate == null) return Duration.zero;
    
    final elapsed = DateTime.now().difference(startDate);
    return trialDuration - elapsed;
  }
}
```

## 🎵 음성 지원 구현 방안 (장기 계획)

### 🗣️ **Text-to-Speech (Apache-2.0)**
```yaml
dependencies:
  flutter_tts: ^3.8.5  # MIT
```

```dart
class CookingModeVoiceAssistant {
  final FlutterTts _tts = FlutterTts();
  
  Future<void> initialize() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.8);
    await _tts.setVolume(0.8);
  }
  
  Future<void> readIngredient(Ingredient ingredient) async {
    final text = "${ingredient.name} ${ingredient.amount}${ingredient.unit}";
    await _tts.speak(text);
  }
  
  Future<void> readNextStep(String instruction) async {
    await _tts.speak("다음 단계입니다. $instruction");
  }
}
```

### 🎤 **Speech-to-Text (Apache-2.0)**
```yaml
dependencies:
  speech_to_text: ^6.6.0  # BSD-3-Clause
```

```dart
class VoiceCommandHandler {
  final SpeechToText _speech = SpeechToText();
  
  Future<void> startListening() async {
    if (await _speech.initialize()) {
      _speech.listen(
        onResult: (result) {
          _handleVoiceCommand(result.recognizedWords);
        },
        localeId: "ko_KR",
      );
    }
  }
  
  void _handleVoiceCommand(String command) {
    if (command.contains("다음")) {
      _moveToNextStep();
    } else if (command.contains("반복")) {
      _repeatCurrentStep();
    } else if (command.contains("일시정지")) {
      _pauseCookingMode();
    }
  }
}
```

## 📊 성능 최적화 고려사항

### 💾 **메모리 효율적인 데이터 구조**
```dart
class OptimizedRecipe {
  // 자주 사용되는 데이터만 메모리에 유지
  final String id;
  final String name;
  final int originalYield;
  
  // 무거운 데이터는 지연 로딩
  List<Ingredient>? _ingredients;
  List<RecipeVersion>? _versions;
  
  Future<List<Ingredient>> get ingredients async {
    _ingredients ??= await _loadIngredientsFromDB();
    return _ingredients!;
  }
}
```

### ⚡ **계산 결과 캐싱**
```dart
class CalculationCache {
  final Map<String, dynamic> _cache = {};
  static const int maxCacheSize = 100;
  
  T? get<T>(String key) => _cache[key] as T?;
  
  void set<T>(String key, T value) {
    if (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first); // LRU 방식
    }
    _cache[key] = value;
  }
}
```

이렇게 업데이트된 요구사항과 기술적 고려사항으로 더욱 실용적이고 유연한 시스템을 구축할 수 있습니다! 🚀