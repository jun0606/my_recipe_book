# 빵 모듈 타입 시스템

빵 모듈의 타입 시스템은 빵 제조 과정을 위한 종합적인 데이터 구조를 제공합니다.

## 파일 구조

### 1. analysis_types.dart
빵 분석과 관련된 타입들
- `BreadAnalysisStep`: 분석 단계 열거형
- `BreadAnalysisStatus`: 분석 상태
- `BreadAnalysisMetric`: 분석 메트릭
- `BreadAnalysisContext`: 분석 컨텍스트

### 2. ingredient_types.dart
빵 재료와 관련된 타입들
- `BreadIngredientCategory`: 재료 카테고리
- `BreadIngredientCharacteristics`: 재료 특성
- `BreadIngredientQuality`: 재료 품질
- `BreadIngredientCompatibilityMatrix`: 재료 호환성 매트릭스

### 3. equipment_types.dart
빵 장비와 관련된 타입들
- `BreadEquipmentType`: 장비 타입
- `BreadEquipmentSpecifications`: 장비 사양
- `BreadEquipmentPerformanceMetrics`: 성능 메트릭
- `BreadEquipmentCompatibilityMatrix`: 장비 호환성

### 4. bread_environment_types.dart
환경 요인과 관련된 타입들
- `WeatherCondition`: 날씨 상태
- `EnvironmentalFactor`: 환경 영향 요인
- `SeasonalAdjustment`: 계절별 조정
- `EnvironmentalImpactAnalysis`: 환경 영향 분석

### 5. bread_types.dart
기본 빵 타입들 (기존 파일)

## 사용 방법

```dart
import 'package:my_recipe_book/modules/bread/types/analysis_types.dart';
import 'package:my_recipe_book/modules/bread/types/ingredient_types.dart';
import 'package:my_recipe_book/modules/bread/types/equipment_types.dart';
import 'package:my_recipe_book/modules/bread/types/bread_environment_types.dart';
```

## 특징

- **타입 안전성**: 모든 타입이 컴파일 타임에 검증
- **확장성**: 새로운 타입 쉽게 추가 가능
- **일관성**: 모든 타입이 JSON 직렬화 지원
- **문서화**: 각 타입에 대한 상세한 설명과 예시
- **품질 보증**: 테스트 커버리지 제공

## 예시

```dart
// 재료 분석
final ingredient = BreadIngredientCharacteristics(
  proteinContent: 12.5,
  moistureContent: 14.0,
  ashContent: 0.5,
);

// 환경 분석
final environment = EnvironmentalImpactAnalysis(
  environment: EnvironmentProfile(
    profileId: 'summer_baking',
    profileName: '여름 베이킹',
    season: Season.summer,
    weather: WeatherCondition.humid,
    temperature: 28.0,
    humidity: 75.0,
    altitude: 100.0,
  ),
  factors: [],
  seasonalAdjustment: SeasonalAdjustment(
    season: Season.summer,
    temperatureAdjustments: {'mixing': -2.0, 'fermentation': -1.0},
    timeAdjustments: {'fermentation': 0.8},
    hydrationAdjustments: {'flour': 1.1},
  ),
);
```

## 테스트

```bash
flutter test test/modules/bread/types/
```

## 문서

자세한 내용은 다음 문서를 참고하세요:
- [빵 모듈 설계 문서](../../docs/advanced-sous-chef-system/bread-module-process-design.md)
- [통합 타입 시스템](../../docs/sous-chef-v2/02-unified-type-system.md)
