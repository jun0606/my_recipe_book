# ADR 001: 아키텍처 재설계 - DDD + Clean Architecture 적용

## Status
Proposed

## Context

현재 프로젝트는 다음과 같은 심각한 아키텍처 문제를 가지고 있습니다:

### 현재 문제점들

1. **타입 시스템 충돌**
   - `core/types/`와 `modules/bread/types/`에 동일한 이름의 타입 존재
   - 컴파일 시 ambiguous import 오류 발생
   - 총 6,076개 오류 중 45%가 타입 충돌 관련

2. **모듈 간 결합도 높음**
   - 순환 의존성 발생
   - 단일 책임 원칙 위반
   - 테스트하기 어려운 구조

3. **비즈니스 로직과 인프라스트럭처 혼재**
   - 도메인 로직이 UI와 데이터베이스 코드에 혼재
   - 재사용성 및 유지보수성 저하

4. **확장성 부족**
   - 새로운 모듈 추가 시 기존 코드 수정 필요
   - 스케일링 시 아키텍처 병목 현상

## Decision

**DDD(Domain-Driven Design) + Clean Architecture**를 적용하여 아키텍처를 재설계합니다.

### 새로운 아키텍처 구조

```
lib/
├── domain/                    # 도메인 레이어
│   ├── core/                  # 공통 도메인
│   │   ├── entities/          # 비즈니스 엔티티
│   │   ├── value_objects/     # 값 객체
│   │   ├── repositories/      # 리포지토리 인터페이스
│   │   └── events/           # 도메인 이벤트
│   └── modules/
│       └── bread/            # 빵 모듈 도메인
│           ├── entities/     # 빵 특화 엔티티
│           ├── use_cases/    # 유스케이스
│           └── services/     # 도메인 서비스
│
├── infrastructure/           # 인프라스트럭처 레이어
│   ├── types/               # 실제 타입 구현
│   ├── services/            # 외부 서비스 구현
│   ├── repositories/        # 리포지토리 구현
│   └── adapters/           # 어댑터 패턴 구현
│
├── presentation/            # 프레젠테이션 레이어
│   ├── widgets/            # UI 컴포넌트
│   ├── screens/            # 화면
│   ├── blocs/              # 상태 관리
│   └── view_models/        # 뷰 모델
│
└── application/             # 애플리케이션 레이어
    ├── use_cases/          # 애플리케이션 서비스
    ├── dto/                # 데이터 전송 객체
    └── events/            # 애플리케이션 이벤트
```

### 아키텍처 원칙

1. **의존성 역전 원칙 (DIP)**
   - 상위 모듈은 하위 모듈에 의존하지 않음
   - 둘 다 추상화에 의존

2. **단일 책임 원칙 (SRP)**
   - 각 클래스는 하나의 책임만 가짐
   - 변경 사유는 하나만 존재

3. **개방-폐쇄 원칙 (OCP)**
   - 확장에는 개방, 수정에는 폐쇄
   - 인터페이스 기반 설계

### 타입 시스템 재설계

#### 1. 도메인 타입 (Domain Layer)
```dart
// lib/domain/core/entities/
abstract class Recipe {
  String get id;
  String get title;
  List<Ingredient> get ingredients;
  List<Process> get processes;
}

// lib/domain/modules/bread/entities/
class BreadRecipe extends Recipe {
  DoughType get doughType;
  FermentationMethod get fermentationMethod;
  BakingMethod get bakingMethod;
}
```

#### 2. 인프라스트럭처 타입 (Infrastructure Layer)
```dart
// lib/infrastructure/types/
class RecipeModel implements Recipe {
  final String id;
  final String title;
  final List<IngredientModel> ingredients;
  final List<ProcessModel> processes;

  RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.processes,
  });
}
```

#### 3. 프레젠테이션 타입 (Presentation Layer)
```dart
// lib/presentation/view_models/
class RecipeViewModel {
  final String displayTitle;
  final String imageUrl;
  final double progress;
  final RecipeStatus status;

  RecipeViewModel({
    required this.displayTitle,
    required this.imageUrl,
    required this.progress,
    required this.status,
  });
}
```

## Consequences

### 장점 (Pros)

1. **유지보수성 향상**
   - 관심사 분리로 각 레이어 독립적 변경 가능
   - 테스트 용이성 증가

2. **확장성 향상**
   - 새로운 모듈 추가 시 기존 코드 영향 최소화
   - 플러그인 형태로 모듈 확장 가능

3. **테스트 용이성**
   - 각 레이어 독립적 테스트 가능
   - Mock 객체 사용으로 단위 테스트 강화

4. **코드 품질 향상**
   - 명확한 역할 분담으로 코드 가독성 증가
   - 재사용성 향상

### 단점 (Cons)

1. **초기 구축 비용 증가**
   - 현재 구조에서 새로운 구조로 마이그레이션 필요
   - 학습 곡선 존재

2. **복잡도 증가**
   - 레이어 간 통신을 위한 인터페이스 추가 필요
   - Boilerplate 코드 증가

3. **성능 오버헤드**
   - 추가적인 추상화 레이어로 인한 성능 저하 가능성
   - 최적화 필요

### 리스크 및 대응책

1. **마이그레이션 복잡도**
   - **대응**: 점진적 마이그레이션 전략 적용
   - **방법**: Parallel implementation + Gradual migration

2. **팀 학습 부담**
   - **대응**: 교육 프로그램 및 문서화
   - **방법**: ADR 작성, 코드 리뷰, 페어 프로그래밍

3. **성능 저하**
   - **대응**: 성능 모니터링 및 최적화
   - **방법**: 프로파일링 도구 사용, 병목 지점 식별

## Implementation Plan

### Phase 1: Foundation (Week 1)
1. 현재 아키텍처 분석 및 문제점 도출
2. 새로운 아키텍처 설계 문서 작성
3. 코어 도메인 엔티티 설계

### Phase 2: Core Implementation (Week 2)
1. 도메인 레이어 구축
2. 인프라스트럭처 레이어 구현
3. 기본 테스트 작성

### Phase 3: Integration (Week 3)
1. 레이어 간 통합
2. UI 레이어 재설계
3. 통합 테스트 수행

### Phase 4: Optimization (Week 4)
1. 성능 최적화
2. 코드 품질 개선
3. 문서화 및 배포

## Validation

### 성공 기준
- 컴파일 오류 95% 이상 감소
- 코드 커버리지 80% 달성
- 유지보수성 지표 개선
- 개발 생산성 향상

### 측정 지표
- 빌드 시간
- 테스트 실행 시간
- 코드 복잡도
- 버그 발생률

## References

- [Domain-Driven Design](https://domainlanguage.com/ddd/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://pub.dev/packages/flutter_clean_architecture)

## Notes

이 아키텍처 재설계는 현재 프로젝트의 근본적인 문제를 해결하고, 장기적인 유지보수성과 확장성을 확보하기 위한 중요한 결정입니다. 점진적 접근을 통해 리스크를 최소화하면서 안정적으로 진행할 것입니다.
