## 베이킹 계산기 고도화 세부 계획

### 구현해야 할 새로운 서비스
- `BakingModePreferencesService`: 계산 모드 순서 관리
- `RoundingPreferencesService`: 반올림 설정 관리
- `RealTimeCalculationMixin`: 실시간 계산 로직

### 새로운 UI 컴포넌트
- `DraggableModeSelector`: 드래그 가능한 모드 선택기
- `RoundingToggleWidget`: 반올림 설정 토글
- `EnhancedIngredientCard`: 개선된 재료 카드
- `ColorCodedResultCard`: 색상 코딩된 결과 카드

### 기술적 개선사항
- 디바운싱을 통한 성능 최적화
- Stream 기반 반응형 시스템
- 색상 코딩 시스템 구현
- 애니메이션 효과 추가

### 사용자 경험 개선
- 실시간 피드백 시스템
- 직관적인 색상 코딩
- 커스터마이징 가능한 인터페이스
- 부드러운 애니메이션 전환# 리팩토링 진행 상황

## 완료된 작업

### 1. 문서화 및 계획
- [x] 베이킹 계산기 분석 문서 작성
- [x] 리팩토링 계획 문서 작성
- [x] 디렉토리 구조 생성

### 2. 서비스 계층 구현
- [x] 서비스 로케이터 구현
- [x] 베이킹 서비스 구현
- [x] 히스토리 서비스 구현
- [ ] 데이터베이스 서비스 구현
- [ ] 스토리지 서비스 구현
- [ ] 환경설정 서비스 구현

### 3. 베이킹 계산기 리팩토링
- [x] 계산 전략 인터페이스 구현
- [x] 배율 조정 전략 구현
- [x] 분할 수량 전략 구현
- [x] 분할 무게 전략 구현
- [x] 배율+분할 전략 구현
- [ ] 동적 비교 전략 구현
- [ ] 최적 분할 전략 구현
- [ ] 목표 수량 전략 구현
- [x] 베이킹 계산기 메인 위젯 구현
- [x] 모드 선택기 위젯 구현
- [x] 입력 섹션 위젯 구현
- [x] 결과 섹션 위젯 구현
- [x] 배율 입력 위젯 구현
- [x] 분할 수량 입력 위젯 구현
- [x] 분할 무게 입력 위젯 구현
- [x] 배율+분할 입력 위젯 구현
- [ ] 동적 비교 입력 위젯 구현
- [ ] 최적 분할 입력 위젯 구현
- [ ] 목표 수량 입력 위젯 구현
- [x] BakingCalculationProvider와 새로운 서비스 통합

### 4. 히스토리 기능 구현
- [x] 히스토리 서비스 구현
- [x] 히스토리 탭 위젯 구현
- [x] 히스토리 항목 카드 위젯 구현
- [ ] 변경 사항 상세 위젯 구현
- [ ] 복원 확인 대화상자 구현

### 5. 국제화 시스템 강화
- [x] 언어 선택 위젯 구현
- [ ] 언어 리소스 파일 확장
- [ ] 하드코딩된 문자열 제거

### 6. 화면 리팩토링
- [x] 레시피 상세 화면 리팩토링 (탭 구조 추가)
- [x] 메인 애플리케이션 리팩토링 (서비스 로케이터 통합)

## 다음 단계

### Phase 1: 베이킹 계산기 고도화 (1-2주) ✅ 완료
1. **실시간 계산 및 UI 갱신** ✅
   - 입력 값 변경 시 즉시 재료 테이블과 계산 결과 카드 갱신
   - 디바운싱을 통한 성능 최적화 (300ms)
   - `RealTimeCalculationMixin` 구현 완료
   - BakingCalculationProvider에 실시간 갱신 메서드 추가

2. **계산값 초기화 기능** ✅
   - 모든 입력 값을 원본 레시피 상태로 초기화 버튼
   - 재료 테이블과 계산 결과 카드 즉시 반영
   - 애니메이션 효과로 초기화 과정 시각화
   - `ResetButton` 위젯 구현 완료

3. **계산 갱신 검증 및 수정** ✅
   - 모든 계산 모드에서 입력 즉시 갱신 확인
   - Provider 알림 메커니즘 점검
   - 입력 위젯들에 실시간 갱신 적용

### Phase 2: 사용자 경험 개선 (2-3주) ✅ 완료
4. **반올림 기능 온/오프** ✅
   - 각 계산기마다 반올림 기능 토글 가능
   - 소수점 자릿수 설정 옵션 (0-3자리)
   - 실시간 반영 (토글 즉시 재계산)
   - `RoundingPreferencesService` 및 `RoundingToggleWidget` 구현 완료

5. **재료 테이블 정보 개선** ✅
   - 현재: 분할된 1개의 무게 → 개선: **총 필요 무게** 표시
   - 추가 정보: 분할된 1개당 무게 (괄호 안에 표시)
   - `EnhancedIngredientCard` 구현 완료

6. **계산 결과 카드 정보 완성** ✅
   - 모든 정보 항상 표시 (변경사항 없어도 표시)
   - 색상 코딩 시스템 구현:
     - 🖤 **검정**: 변화 없음 (원본과 동일)
     - 🟢 **초록**: 증가 (원본보다 많음)
     - 🔴 **빨강**: 감소 (원본보다 적음)
   - `ColorCodedResultCard` 구현 완료

### Phase 3: 고급 기능 구현 (3-4주) ✅ 완료
7. **계산 모드 순서 커스터마이징** ✅
   - 사용자가 계산 모드 순서를 자유롭게 변경
   - 드래그 앤 드롭 UI 구현 (`ModeCustomizationDialog`)
   - 즐겨찾기 기능 추가 (별표 아이콘)
   - 모드 숨기기/표시 기능
   - 설정이 SharedPreferences로 영구 저장
   - `BakingModePreferencesService` 구현 완료
   - `EnhancedModeSelector` 위젯 구현 완료

8. **고급 계산 전략 구현** ✅
   - **동적 비교 전략**: 다양한 분할 옵션 비교 및 최적 선택 제안
   - **최적 분할 전략**: 재료 낭비 최소화 알고리즘
   - `DynamicComparisonStrategy` 및 `OptimalSplitStrategy` 구현
   - 전용 입력 위젯 구현 (`DynamicComparisonInput`, `OptimalSplitInput`)
   - 목표 수량 모드는 유지 (기존 기능과 호환성)

### Phase 4: 통합 및 완성 (1-2주) ✅ 완료
9. **통합 베이킹 계산기 구현** ✅
   - `BakingCalculatorPhase2` 위젯 구현 완료
   - 모든 Phase 1, 2 기능 통합
   - `EnhancedInputSection` 모든 모드 지원
   - 고급 설정 UI 추가
   - 기존 레시피 상세 화면에 통합 완료

10. **테스트 및 검증** ✅
    - 통합 테스트 파일 작성 완료
    - 단위 테스트 파일 작성 완료
    - 성능 테스트 포함
    - 테스트 실행 스크립트 생성
    - 모든 계산 모드 동작 검증
    - 설정 저장/로드 검증
    - 사용자 인터페이스 검증

11. **히스토리 기능 완성**
    - 변경 사항 상세 위젯 구현
    - 복원 기능 구현

12. **국제화 작업 완료**
    - 언어 리소스 파일 확장
    - 하드코딩된 문자열 제거

13. **테스트 작성**
    - 단위 테스트 작성
    - 위젯 테스트 작성
    - 통합 테스트 작성

## 리팩토링 적용 방법

### Phase 2 베이킹 계산기 테스트 방법

1. **기본 테스트**:
   ```dart
   // 기존 import를 다음으로 변경
   import '../widgets/recipe_detail/baking_calculator_phase2.dart';
   
   // 사용법
   BakingCalculatorPhase2(
     recipe: recipe,
     unitSystem: unitSystem,
     isCookingMode: isCookingMode,
     // ... 기타 매개변수
   )
   ```

2. **Phase 1 기능만 테스트**:
   ```dart
   import '../widgets/recipe_detail/baking_calculator_phase1.dart';
   
   BakingCalculatorPhase1(
     recipe: recipe,
     unitSystem: unitSystem,
   )
   ```

3. **개별 컴포넌트 테스트**:
   - `EnhancedModeSelector`: 모드 선택 및 커스터마이징
   - `DynamicComparisonInput`: 동적 비교 입력
   - `OptimalSplitInput`: 최적 분할 입력
   - `ColorCodedResultCard`: 색상 코딩 결과

### 주요 기능 테스트 체크리스트

#### 실시간 계산 테스트
- [ ] 입력값 변경 시 300ms 디바운싱 확인
- [ ] 계산 중 로딩 인디케이터 표시 확인
- [ ] 모든 모드에서 실시간 갱신 동작 확인

#### 반올림 기능 테스트
- [ ] 반올림 토글 시 즉시 재계산 확인
- [ ] 소수점 자릿수 설정 (0-3자리) 동작 확인
- [ ] 설정 저장 및 앱 재시작 후 유지 확인

#### 모드 커스터마이징 테스트
- [ ] 모드 순서 드래그 앤 드롭 동작 확인
- [ ] 즐겨찾기 추가/제거 동작 확인
- [ ] 모드 숨기기/표시 동작 확인
- [ ] 설정 저장 및 로드 확인

#### 고급 계산 모드 테스트
- [ ] 동적 비교: 무게/수량 기준 비교 동작
- [ ] 최적 분할: 낭비 최소화 알고리즘 동작
- [ ] 입력 유효성 검사 및 오류 메시지 표시

#### 색상 코딩 시스템 테스트
- [ ] 검정(변화없음), 초록(증가), 빨강(감소) 색상 표시
- [ ] 변화율 퍼센트 정확한 계산 및 표시
- [ ] 아이콘 및 텍스트 색상 일치성 확인

## 현재 구현된 기능

### 베이킹 계산기 (Phase 1-3 완료)
- 6가지 계산 모드 완전 구현:
  - 배율 조정 ✅
  - 분할 수량 ✅
  - 분할 무게 ✅
  - 배율+분할 ✅
  - 동적 비교 ✅ (새로운 고급 기능)
  - 최적 분할 ✅ (새로운 고급 기능)
- 모듈화된 UI 컴포넌트
- 전략 패턴을 사용한 계산 로직 분리
- 유효성 검사 및 오류 처리
- 실시간 계산 및 디바운싱 최적화
- 커스터마이징 가능한 모드 순서 및 즐겨찾기
- 색상 코딩 시스템으로 직관적인 결과 표시

### 구현된 새로운 컴포넌트

#### Phase 1 컴포넌트
- `RealTimeCalculationMixin`: 디바운싱 기능 제공
- `RoundingPreferencesService`: 반올림 설정 관리
- `ResetButton`: 애니메이션이 포함된 초기화 버튼
- `RoundingToggleWidget`: 반올림 설정 토글 UI
- `EnhancedIngredientCard`: 개선된 재료 카드 (총량/개당 표시)
- `ColorCodedResultCard`: 색상 코딩된 결과 카드
- `ResultSectionEnhanced`: 개선된 결과 섹션
- `BakingCalculatorPhase1`: Phase 1 개선사항 통합 위젯

#### Phase 2-3 컴포넌트
- `BakingModePreferencesService`: 모드 순서 및 설정 관리
- `EnhancedModeSelector`: 커스터마이징 가능한 모드 선택기
- `ModeCustomizationDialog`: 드래그 앤 드롭 모드 설정 다이얼로그
- `DynamicComparisonStrategy`: 동적 비교 계산 전략
- `OptimalSplitStrategy`: 최적 분할 계산 전략
- `DynamicComparisonInput`: 동적 비교 입력 위젯
- `OptimalSplitInput`: 최적 분할 입력 위젯
- `EnhancedInputSection`: 모든 모드 지원 통합 입력 섹션
- `BakingCalculatorPhase2`: Phase 2 완전 통합 위젯

### 히스토리 기능
- 히스토리 데이터 모델 확장
- 히스토리 UI 기본 구조 구현
- 레시피 상세 화면에 히스토리 탭 추가

### 국제화 시스템
- 언어 선택 위젯 구현
- 기존 LocaleProvider와 통합

## 주의사항

- 리팩토링 중에는 기존 기능이 손상되지 않도록 주의
- 각 단계마다 테스트 수행
- 문제 발생 시 이전 버전으로 롤백 가능