# Sous Chef 발효 전문가 통합 설계안 (v3.0)

**문서 목적:** 기존 Sous Chef 모드에 전문적인 발효 관리 시스템을 통합하여, 실제 베이킹 현장에서 사용할 수 있는 수준의 발효 조언과 타이머 기능을 제공합니다.

---

## 1. 발효 시스템 통합 개요

### 1.1. 통합 원칙
- **전문성 우선**: 실제 베이커리에서 사용하는 발효 단계와 방법을 정확히 반영
- **상황별 맞춤**: 레시피 타입, 환경 조건, 사용자 설정에 따른 개인화된 조언
- **실시간 지원**: 발효 진행 중 실시간 모니터링과 조언 제공
- **학습 기능**: 사용자의 성공/실패 경험을 학습하여 조언 정확도 향상

### 1.2. 발효 단계 세분화
기존 설계안의 단순한 발효 옵션을 다음과 같이 전문화:

```
기존: 발효 방법 (발효기/저온/실온)
↓
신규: 발효 단계별 전문 관리
├── 1차 발효 (Bulk Fermentation)
├── 분할 후 발효 (Post-Division Rest)  
├── 성형 후 발효 (Final Proof)
├── 오버나이트 발효 (Overnight Fermentation)
├── 냉장 숙성 (Cold Retardation)
└── 특수 발효 (Sourdough, Poolish 등)
```

---

## 2. 발효 전문가 UI/UX 설계

### 2.1. 진입점 통합
**기존 Sous Chef 버튼 옆에 발효 전문가 버튼 추가**
- 위치: 베이킹 계산기 헤더 우측
- 표시 조건: `bakingType == bread` 일 때만 활성화
- 아이콘: `Icons.science` (과학적 접근을 상징)
- 색상: 녹색 그라데이션 (성장/발효를 상징)

### 2.2. 발효 조언 시트 구조
**3개 탭으로 구성된 BottomSheet**

#### 탭 1: 발효 설정 (Settings)
```
┌─ 발효 단계 선택 ─┐
│ ○ 1차 발효      │
│ ○ 분할 후       │  
│ ○ 성형 후       │
│ ○ 최종 발효     │
│ ○ 오버나이트    │
│ ○ 냉장 숙성     │
└─────────────────┘

┌─ 발효 방법 ─┐
│ ○ 실온 발효  │
│ ○ 발효기     │
│ ○ 냉장 발효  │
│ ○ 따뜻한 곳  │
│ ○ 온습도 조절│
└─────────────┘

┌─ 환경 설정 ─┐
│ 온도: [26°C] │ ←── 슬라이더
│ 습도: [75%]  │ ←── 슬라이더  
│ 목표시간: [2시간] │ ←── 슬라이더
└─────────────┘

┌─ 반죽 정보 ─┐
│ 반죽무게: [1000g] │
│ 수분율: [65%]     │
│ 소금비율: [2%]    │
└─────────────────┘

┌─ 이스트 설정 ─┐
│ 이스트양: [5g]    │
│ 종류: [인스턴트▼] │
│ ☑ 프리퍼먼트 사용 │
└─────────────────┘
```

#### 탭 2: AI 조언 (Advice)
```
┌─ 발효 조언 요약 ─┐
│ 권장 시간: 2시간 15분 │
│ 권장 온도: 26°C      │
│ 권장 습도: 75%       │
│ 예상 상태: 적정 발효  │
│ 신뢰도: 92%         │
└────────────────────┘

┌─ 재료 조정 제안 ─┐
│ ⊕ 이스트: +0.5g    │
│ ⊖ 소금: -0.2g      │
└──────────────────┘

┌─ 발효 팁 ─┐
│ ✓ 30분마다 폴딩 권장 │
│ ✓ 표면 건조 방지 필수 │
│ ✓ 손가락 테스트로 확인│
└─────────────────────┘

┌─ 주의사항 ─┐
│ ⚠ 온도가 높아 과발효 위험 │
│ ⚠ 습도 부족시 표면 건조  │
└──────────────────────┘

┌─ 체크 포인트 ─┐
│ ① 30분 후: 폴딩 실시    │
│ ② 1시간 후: 부피 1.3배  │
│ ③ 1시간 45분: 부피 1.7배│
│ ④ 2시간 15분: 최종 확인 │
└─────────────────────┘
```

#### 탭 3: 발효 타이머 (Timer)
```
┌─ 활성 타이머 목록 ─┐
│ ┌─ 1차 발효 ─────┐ │
│ │ ████████░░ 80% │ │
│ │ 남은시간: 24분   │ │
│ │ [중지] [연장]   │ │
│ └───────────────┘ │
│                   │
│ ┌─ 성형 후 발효 ──┐ │
│ │ ██████████ 완료!│ │
│ │ 발효 완료       │ │
│ │ [중지] [다음단계]│ │
│ └───────────────┘ │
└─────────────────┘

[현재 단계 타이머 시작] ←── 버튼
```

---

## 3. 발효 전문 알고리즘 설계

### 3.1. 발효 시간 계산 공식
```
최적_발효시간 = 기본시간 × 온도계수 × 이스트계수 × 수분계수 × 소금계수 × 프리퍼먼트계수

온도계수 = 2^((26-현재온도)/10)  // 10도 차이마다 2배 변화
이스트계수 = 1.5% / 실제이스트비율
수분계수 = 1 - (수분율-65) × 0.005
소금계수 = 1 + (소금비율-2) × 0.1
프리퍼먼트계수 = 프리퍼먼트사용 ? 0.7 : 1.0
```

### 3.2. 발효 상태 진단 알고리즘
```python
def diagnose_fermentation_state(current_time, target_time, temperature, visual_description):
    time_ratio = current_time / target_time
    
    # 시간 기준 1차 판단
    if time_ratio < 0.7:
        base_state = "under_fermented"
    elif time_ratio > 1.3:
        base_state = "over_fermented"  
    else:
        base_state = "optimal"
    
    # 온도 보정
    if temperature < 20:
        return "under_fermented" if time_ratio < 0.9 else "optimal"
    elif temperature > 30:
        return "over_fermented" if time_ratio > 1.1 else "optimal"
    
    return base_state
```

### 3.3. 재료 조정 제안 로직
```python
def suggest_ingredient_adjustments(settings):
    adjustments = {}
    
    # 온도 기반 이스트 조정
    if settings.temperature > 28:
        adjustments['yeast'] = -((settings.temperature - 28) * 0.1)
    elif settings.temperature < 22:
        adjustments['yeast'] = +((22 - settings.temperature) * 0.05)
    
    # 발효 시간 기반 소금 조정
    if settings.target_time > 480:  # 8시간 이상
        adjustments['salt'] = +0.2
    
    # 수분율 기반 밀가루 조정
    if settings.hydration > 80:
        adjustments['flour'] = +(settings.hydration - 80) * 0.5
    
    return adjustments
```

---

## 4. 데이터 모델 확장

### 4.1. 발효 설정 모델
```dart
class FermentationSettings {
  final FermentationStage stage;      // 발효 단계
  final FermentationMethod method;    // 발효 방법
  final double temperature;           // 온도 (°C)
  final double humidity;              // 습도 (%)
  final double targetTime;            // 목표 시간 (분)
  final double yeastAmount;           // 이스트 양 (g)
  final String yeastType;             // 이스트 종류
  final double doughWeight;           // 반죽 무게 (g)
  final double hydration;             // 수분율 (%)
  final bool usePreferment;           // 프리퍼먼트 사용
  final double saltPercentage;        // 소금 비율 (%)
}
```

### 4.2. 발효 조언 모델
```dart
class FermentationAdvice {
  final double recommendedTime;       // 권장 시간
  final double recommendedTemp;       // 권장 온도
  final double recommendedHumidity;   // 권장 습도
  final Map<String, double> ingredientAdjustments; // 재료 조정
  final List<String> tips;            // 팁
  final List<String> warnings;        // 경고
  final FermentationState expectedState; // 예상 상태
  final double confidenceScore;       // 신뢰도
  final List<String> checkPoints;     // 체크포인트
}
```

### 4.3. 발효 타이머 모델
```dart
class FermentationTimer {
  final String id;
  final FermentationStage stage;
  final DateTime startTime;
  final double duration;              // 시간 (분)
  final List<double> checkTimes;      // 체크 시간들
  final bool isActive;
  final String notes;
  
  // 계산 속성
  DateTime get endTime;
  double get remainingMinutes;
  bool get isCompleted;
  double get progressPercentage;
}
```

---

## 5. Sous Chef 통합 워크플로우

### 5.1. 통합된 사용자 여정
```
1. 레시피 상세 페이지 진입
   ↓
2. 베이킹 계산기에서 [Sous Chef] 또는 [발효 전문가] 선택
   ↓
3-A. Sous Chef 선택시:
     - 전반적인 베이킹 조건 설정
     - 오븐, 환경, 재료 보정
     ↓
3-B. 발효 전문가 선택시:
     - 발효 단계별 세부 설정
     - 발효 조건 최적화
     - 실시간 타이머 관리
     ↓
4. 두 시스템의 조언을 종합하여 최종 레시피 조정
   ↓
5. 실제 베이킹 진행 중 발효 타이머로 단계별 관리
```

### 5.2. 시스템 간 데이터 연동
```dart
// Sous Chef에서 발효 전문가로 데이터 전달
class IntegratedBakingState {
  SousChefRecipeState? sousChefState;
  FermentationSettings? fermentationSettings;
  
  // 통합 조정값 계산
  Map<String, dynamic> calculateCombinedAdjustments() {
    final sousChefAdjustments = sousChefState?.currentAdjustments ?? {};
    final fermentationAdjustments = _calculateFermentationAdjustments();
    
    // 두 시스템의 조언을 가중평균으로 결합
    return _mergeAdjustments(sousChefAdjustments, fermentationAdjustments);
  }
}
```

---

## 6. 실제 베이킹 시나리오 예시

### 시나리오 1: 식빵 만들기
```
사용자 입력:
- 레시피: 기본 식빵 (1000g 반죽)
- 환경: 실내 온도 24°C, 습도 60%
- 목표: 오늘 저녁에 완성

발효 전문가 조언:
1차 발효: 실온에서 1시간 30분
- 30분마다 폴딩 권장
- 1.5배 부풀 때까지 대기

분할 후 발효: 15분 휴지
- 반죽 표면 건조 방지

성형 후 발효: 45분
- 손가락 테스트로 확인
- 80% 발효 상태에서 굽기 시작

타이머 설정:
- 1차 발효 타이머: 90분 (30분, 60분 체크포인트)
- 휴지 타이머: 15분
- 최종 발효 타이머: 45분 (35분 체크포인트)
```

### 시나리오 2: 사워도우 빵
```
사용자 입력:
- 레시피: 사워도우 빵 (800g 반죽)
- 스타터: 100g (활성 상태)
- 목표: 내일 아침 굽기

발효 전문가 조언:
1차 발효: 실온 4시간 + 냉장 12시간
- 첫 2시간은 30분마다 폴딩
- 이후 냉장고에서 오버나이트

최종 발효: 실온에서 2-3시간
- 냉장고에서 꺼낸 후 1시간 실온 적응
- 손가락 테스트로 85% 발효 확인

특별 조언:
- 스타터 활성도에 따라 시간 조정
- 산도 조절을 위한 온도 관리
- 글루텐 형성을 위한 폴딩 기법
```

---

## 7. 개발 우선순위

### Phase 1: 핵심 발효 기능
- [ ] 발효 모델 및 엔진 구현
- [ ] 기본 발효 조언 알고리즘
- [ ] 발효 설정 UI (탭 1)

### Phase 2: AI 조언 시스템  
- [ ] 발효 조언 생성 로직
- [ ] 재료 조정 제안 기능
- [ ] 조언 UI (탭 2)

### Phase 3: 타이머 시스템
- [ ] 발효 타이머 구현
- [ ] 실시간 진행률 표시
- [ ] 타이머 UI (탭 3)

### Phase 4: Sous Chef 통합
- [ ] 두 시스템 간 데이터 연동
- [ ] 통합 조언 생성
- [ ] 사용자 경험 최적화

### Phase 5: 고도화
- [ ] 학습 기능 (성공/실패 피드백)
- [ ] 프리셋 관리
- [ ] 고급 발효 기법 지원

---

이 설계안을 통해 단순한 발효 옵션이 아닌, 실제 베이커리 수준의 전문적인 발효 관리 시스템을 구현할 수 있습니다. 사용자는 각 발효 단계별로 정확한 조언을 받고, 실시간으로 진행 상황을 모니터링하며, 성공적인 베이킹 결과를 얻을 수 있게 됩니다.