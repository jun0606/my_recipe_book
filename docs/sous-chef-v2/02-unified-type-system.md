# 02. 통합 타입 시스템

## 📋 개요

수쉐프 모드 v2.0의 통합 타입 시스템은 메인 앱과의 완벽한 호환성과 모듈 간 일관성을 보장합니다.

## 🎯 설계 목표

### 1. 완벽한 메인 앱 호환성
```dart
// 기존 Recipe 타입과의 완벽한 호환
class Recipe {
  String id;
  String title;
  List<Ingredient> ingredients;
  // ...
}

class UnifiedRecipe extends Recipe {
  // 수쉐프 모듈이 추가로 참조할 수 있는 데이터
  BreadRequirements? breadReq;
  CakeRequirements? cakeReq;
  // ...
}
```

### 2. 모듈 간 타입 일관성
```dart
// 모든 모듈이 같은 타입을 사용
interface ModuleDataProvider {
  UnifiedRecipe getRecipe();
  AnalysisResult getAnalysis();
  ModuleConfig getConfig();
}
```

### 3. Null Safety 보장
```dart
// 모든 타입은 Null Safety를 준수
class UnifiedIngredient {
  final String id;        // required
  final String name;      // required
  final double? amount;   // optional
  final String? unit;     // optional
  final Map<String, dynamic> properties; // required but can be empty
}
```

## 🏗️ 코어 타입 정의

### 1. 기본 통합 타입

#### UnifiedRecipe - 통합 레시피 타입
```dart
// lib/types/recipe_types.dart
class UnifiedRecipe {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 재료 정보
  final List<UnifiedIngredient> ingredients;

  // 공정 정보
  final List<UnifiedProcess> processes;

  // 장비 정보
  final EquipmentConfig equipment;

  // 메타데이터
  final RecipeMetadata metadata;

  // 모듈별 확장 데이터
  final BreadRequirements? breadRequirements;
  final CakeRequirements? cakeRequirements;
  final CookieRequirements? cookieRequirements;
  final DessertRequirements? dessertRequirements;

  const UnifiedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.processes,
    required this.equipment,
    required this.metadata,
    this.description = '',
    this.author = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.breadRequirements,
    this.cakeRequirements,
    this.cookieRequirements,
    this.dessertRequirements,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // 팩토리 메서드: 기존 Recipe에서 변환
  factory UnifiedRecipe.fromRecipe(Recipe recipe) {
    return UnifiedRecipe(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description ?? '',
      author: recipe.author ?? '',
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      ingredients: recipe.ingredients.map(UnifiedIngredient.from).toList(),
      processes: recipe.instructions.map(UnifiedProcess.from).toList(),
      equipment: EquipmentConfig.fromRecipe(recipe.equipment),
      metadata: RecipeMetadata.fromRecipe(recipe),
    );
  }

  // 변환 메서드: 다시 Recipe로 변환
  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      description: description.isNotEmpty ? description : null,
      author: author.isNotEmpty ? author : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      ingredients: ingredients.map((ing) => ing.toIngredient()).toList(),
      instructions: processes.map((proc) => proc.toInstruction()).toList(),
      equipment: equipment.toRecipeEquipment(),
    );
  }
}
```

#### UnifiedIngredient - 통합 재료 타입
```dart
class UnifiedIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final Map<String, dynamic> properties;

  // 영양 정보
  final NutritionInfo? nutrition;

  // 빵 관련 특성
  final FlourProperties? flourProperties;

  // 유통기한
  final DateTime? expiryDate;

  const UnifiedIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.properties = const {},
    this.nutrition,
    this.flourProperties,
    this.expiryDate,
  });

  factory UnifiedIngredient.from(Ingredient ingredient) {
    return UnifiedIngredient(
      id: ingredient.id,
      name: ingredient.name,
      amount: ingredient.amount,
      unit: ingredient.unit,
      properties: ingredient.properties ?? {},
      nutrition: ingredient.nutrition != null
        ? NutritionInfo.from(ingredient.nutrition!)
        : null,
    );
  }

  Ingredient toIngredient() {
    return Ingredient(
      id: id,
      name: name,
      amount: amount,
      unit: unit,
      properties: properties.isNotEmpty ? properties : null,
      nutrition: nutrition?.toNutrition(),
    );
  }
}
```

#### UnifiedProcess - 통합 공정 타입
```dart
class UnifiedProcess {
  final String id;
  final String name;
  final String type; // 'mixing', 'kneading', 'fermentation', 'baking', etc.
  final Duration duration;
  final Map<String, dynamic> parameters;
  final ProcessMetadata metadata;

  const UnifiedProcess({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    this.parameters = const {},
    this.metadata = const ProcessMetadata(),
  });

  factory UnifiedProcess.from(Instruction instruction) {
    return UnifiedProcess(
      id: instruction.id,
      name: instruction.title,
      type: _mapInstructionToProcessType(instruction),
      duration: instruction.duration ?? Duration(minutes: 10),
      parameters: instruction.parameters ?? {},
      metadata: ProcessMetadata.fromInstruction(instruction),
    );
  }

  Instruction toInstruction() {
    return Instruction(
      id: id,
      title: name,
      description: metadata.description,
      duration: duration,
      parameters: parameters.isNotEmpty ? parameters : null,
      // 기타 필드들...
    );
  }

  static String _mapInstructionToProcessType(Instruction instruction) {
    final title = instruction.title.toLowerCase();
    if (title.contains('mix') || title.contains('반죽')) return 'mixing';
    if (title.contains('knead') || title.contains('반죽')) return 'kneading';
    if (title.contains('ferment') || title.contains('발효')) return 'fermentation';
    if (title.contains('bake') || title.contains('굽')) return 'baking';
    return 'general';
  }
}
```

### 2. 모듈별 요구사항 타입

#### BreadRequirements - 빵 모듈 요구사항
```dart
class BreadRequirements {
  final DoughType doughType;
  final HydrationLevel hydration;
  final FermentationMethod fermentation;
  final OvenSettings ovenSettings;

  final Map<String, dynamic> additionalParams;

  const BreadRequirements({
    required this.doughType,
    required this.hydration,
    required this.fermentation,
    required this.ovenSettings,
    this.additionalParams = const {},
  });

  factory BreadRequirements.fromMap(Map<String, dynamic> map) {
    return BreadRequirements(
      doughType: DoughType.values[map['doughType'] ?? 0],
      hydration: HydrationLevel.fromMap(map['hydration'] ?? {}),
      fermentation: FermentationMethod.fromMap(map['fermentation'] ?? {}),
      ovenSettings: OvenSettings.fromMap(map['ovenSettings'] ?? {}),
      additionalParams: map['additionalParams'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doughType': doughType.index,
      'hydration': hydration.toMap(),
      'fermentation': fermentation.toMap(),
      'ovenSettings': ovenSettings.toMap(),
      'additionalParams': additionalParams,
    };
  }
}

enum DoughType {
  lean,      // 일반 빵
  rich,      // 풍미 빵
  sour,      // 사워도우
  croissant, // 크루아상
}
```

#### CakeRequirements - 케이크 모듈 요구사항
```dart
class CakeRequirements {
  final CakeType cakeType;
  final BatterConsistency batter;
  final BakingMethod bakingMethod;
  final DecorationRequirements decoration;

  const CakeRequirements({
    required this.cakeType,
    required this.batter,
    required this.bakingMethod,
    required this.decoration,
  });
}

enum CakeType {
  sponge,    // 스펀지 케이크
  butter,    // 버터 케이크
  chiffon,   // 쉬폰 케이크
  angel,     // 엔젤 케이크
}
```

### 3. 분석 결과 타입

#### AnalysisResult - 범용 분석 결과
```dart
class AnalysisResult {
  final String moduleId;
  final DateTime timestamp;
  final AnalysisStatus status;
  final Map<String, dynamic> data;

  // 성공/실패 여부
  final bool isSuccessful;
  final String? errorMessage;

  // 세부 분석 결과
  final ProcessAnalysis? processAnalysis;
  final IngredientAnalysis? ingredientAnalysis;
  final EquipmentAnalysis? equipmentAnalysis;

  const AnalysisResult({
    required this.moduleId,
    required this.status,
    required this.data,
    required this.isSuccessful,
    this.errorMessage,
    this.processAnalysis,
    this.ingredientAnalysis,
    this.equipmentAnalysis,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AnalysisResult.success({
    required String moduleId,
    required Map<String, dynamic> data,
    ProcessAnalysis? processAnalysis,
    IngredientAnalysis? ingredientAnalysis,
    EquipmentAnalysis? equipmentAnalysis,
  }) {
    return AnalysisResult(
      moduleId: moduleId,
      status: AnalysisStatus.completed,
      data: data,
      isSuccessful: true,
      processAnalysis: processAnalysis,
      ingredientAnalysis: ingredientAnalysis,
      equipmentAnalysis: equipmentAnalysis,
    );
  }

  factory AnalysisResult.error({
    required String moduleId,
    required String errorMessage,
  }) {
    return AnalysisResult(
      moduleId: moduleId,
      status: AnalysisStatus.error,
      data: {},
      isSuccessful: false,
      errorMessage: errorMessage,
    );
  }

  factory AnalysisResult.timeout() {
    return AnalysisResult(
      moduleId: 'system',
      status: AnalysisStatus.timeout,
      data: {},
      isSuccessful: false,
      errorMessage: 'Analysis timeout',
    );
  }
}

enum AnalysisStatus {
  pending,    // 분석 대기 중
  processing, // 분석 중
  completed,  // 분석 완료
  error,      // 분석 오류
  timeout,    // 분석 시간 초과
}
```

#### ProcessAnalysis - 공정별 분석 결과
```dart
class ProcessAnalysis {
  final String processId;
  final ProcessType processType;
  final AnalysisScore score;
  final List<String> issues;
  final List<String> recommendations;
  final Map<String, dynamic> metrics;

  const ProcessAnalysis({
    required this.processId,
    required this.processType,
    required this.score,
    required this.issues,
    required this.recommendations,
    required this.metrics,
  });
}

class AnalysisScore {
  final double overall;      // 종합 점수 (0.0 - 1.0)
  final double technique;    // 기법 점수
  final double timing;       // 시간 점수
  final double parameters;   // 파라미터 점수

  const AnalysisScore({
    required this.overall,
    required this.technique,
    required this.timing,
    required this.parameters,
  });

  String get grade {
    if (overall >= 0.9) return 'A+';
    if (overall >= 0.8) return 'A';
    if (overall >= 0.7) return 'B';
    if (overall >= 0.6) return 'C';
    if (overall >= 0.5) return 'D';
    return 'F';
  }
}
```

## 🔄 타입 변환 시스템

### 1. 레시피 변환기
```dart
// lib/utils/recipe_converter.dart
class RecipeConverter {
  static UnifiedRecipe toUnifiedRecipe(dynamic recipe) {
    if (recipe is Recipe) {
      return UnifiedRecipe.fromRecipe(recipe);
    } else if (recipe is UnifiedRecipe) {
      return recipe;
    } else if (recipe is Map<String, dynamic>) {
      return UnifiedRecipe.fromMap(recipe);
    } else {
      throw ArgumentError('Unsupported recipe type: ${recipe.runtimeType}');
    }
  }

  static Recipe toRecipe(UnifiedRecipe unifiedRecipe) {
    return unifiedRecipe.toRecipe();
  }

  static Map<String, dynamic> toMap(UnifiedRecipe unifiedRecipe) {
    return unifiedRecipe.toMap();
  }
}
```

### 2. 모듈 데이터 변환기
```dart
// lib/utils/module_data_converter.dart
class ModuleDataConverter {
  static Map<String, dynamic> extractModuleData(
    UnifiedRecipe recipe,
    String moduleId
  ) {
    switch (moduleId) {
      case 'bread':
        return _extractBreadData(recipe);
      case 'cake':
        return _extractCakeData(recipe);
      case 'cookie':
        return _extractCookieData(recipe);
      case 'dessert':
        return _extractDessertData(recipe);
      default:
        return {};
    }
  }

  static Map<String, dynamic> _extractBreadData(UnifiedRecipe recipe) {
    return {
      'ingredients': recipe.ingredients.map((ing) => ing.toMap()).toList(),
      'processes': recipe.processes
        .where((proc) => _isBreadProcess(proc))
        .map((proc) => proc.toMap())
        .toList(),
      'breadRequirements': recipe.breadRequirements?.toMap(),
      'equipment': recipe.equipment.toMap(),
    };
  }

  static bool _isBreadProcess(UnifiedProcess process) {
    return ['mixing', 'kneading', 'fermentation', 'baking'].contains(process.type);
  }
}
```

## 📊 타입 검증 시스템

### 1. 런타임 타입 검증
```dart
// lib/utils/type_validator.dart
class TypeValidator {
  static bool isValidUnifiedRecipe(dynamic object) {
    return object is UnifiedRecipe &&
           object.id.isNotEmpty &&
           object.ingredients.isNotEmpty;
  }

  static bool isValidAnalysisResult(dynamic object) {
    return object is AnalysisResult &&
           object.moduleId.isNotEmpty &&
           object.timestamp != null;
  }

  static void validateRecipe(UnifiedRecipe recipe) {
    if (recipe.id.isEmpty) {
      throw ValidationError('Recipe ID cannot be empty');
    }

    if (recipe.ingredients.isEmpty) {
      throw ValidationError('Recipe must have at least one ingredient');
    }

    for (final ingredient in recipe.ingredients) {
      validateIngredient(ingredient);
    }
  }

  static void validateIngredient(UnifiedIngredient ingredient) {
    if (ingredient.id.isEmpty) {
      throw ValidationError('Ingredient ID cannot be empty');
    }

    if (ingredient.name.isEmpty) {
      throw ValidationError('Ingredient name cannot be empty');
    }

    if (ingredient.amount <= 0) {
      throw ValidationError('Ingredient amount must be positive');
    }
  }
}
```

### 2. 컴파일 타임 안전성
```dart
// 타입 안전성을 위한 추상 클래스들
abstract class RecipeValidator {
  bool isValid(dynamic recipe);
  List<String> getValidationErrors(dynamic recipe);
}

abstract class ModuleDataProvider {
  UnifiedRecipe getRecipe();
  AnalysisResult getAnalysis();
  ModuleConfig getConfig();
}

// 제네릭을 활용한 타입 안전성
class TypedModule<T extends ModuleConfig> {
  final String moduleId;
  final T config;

  const TypedModule({
    required this.moduleId,
    required this.config,
  });
}
```

## 🎯 결론

### 통합 타입 시스템의 이점

✅ **메인 앱 완벽 호환** - 기존 Recipe 타입과의 완벽한 변환
✅ **모듈 간 일관성** - 모든 모듈이 같은 타입 사용
✅ **Null Safety 보장** - 모든 필드의 Null safety 준수
✅ **확장성** - 새로운 모듈 타입 쉽게 추가 가능
✅ **타입 안전성** - 컴파일 타임 및 런타임 검증
✅ **유지보수성** - 중앙화된 타입 관리로 유지보수 용이

### 구현 우선순위

1. **핵심 타입 정의** (UnifiedRecipe, UnifiedIngredient 등)
2. **변환 시스템** (RecipeConverter, ModuleDataConverter)
3. **검증 시스템** (TypeValidator, 런타임 검증)
4. **모듈별 요구사항 타입** (BreadRequirements 등)
5. **분석 결과 타입** (AnalysisResult 등)

이 통합 타입 시스템을 기반으로 메인 앱과의 완벽한 연동과 모듈 간 일관성을 보장할 수 있습니다.
