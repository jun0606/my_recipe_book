# Sous Chef 모드 통합 설계안 (v2.0)

**문서 목적:** Flutter와 온디바이스 DB를 사용하여 구현될 'Sous Chef 모드'의 상세 기능, UI/UX 흐름, 데이터 구조, 보정 알고리즘을 정의합니다. 이 문서는 **Claude Sonnet 3.7**이 일관성 있는 코드를 생성하기 위한 최종 설계 지침서 역할을 합니다.

---

## 1. 시스템 아키텍처 및 핵심 원칙

1.  **온디바이스 중심 (On-Device First):** 모든 데이터 처리, 계산, 저장은 사용자 기기 내에서 이루어집니다. 클라우드 의존성이 없습니다.
2.  **레시피 메타데이터 기반 동적 구성:** 모든 레시피는 `bakingType` (e.g., `bread`, `cake`, `cookie`, `fried`)과 `doughType` (e.g., `sourdough`, `chiffon`) 메타데이터를 가집니다. 시스템은 이 메타데이터를 기반으로 필요한 UI 옵션과 알고리즘 모듈을 동적으로 로드합니다.
3.  **모듈형 알고리즘 (Modular Algorithm):** 각 베이킹 유형과 환경 변수에 따른 보정 로직을 독립된 모듈로 개발하여, 필요한 모듈만 조합하여 사용함으로써 확장성과 유지보수성을 확보합니다.
4.  **상태 관리:** Flutter의 Riverpod 또는 Provider를 사용하여 앱의 상태를 예측 가능하고 일관되게 관리합니다.

---

## 2. UI/UX 상세 흐름

### 2.1. 메인 플로우
1.  **진입점:** 레시피 상세 페이지에서 `bakingMode: true`인 경우에만 **[Sous Chef 설정]** 버튼이 활성화됩니다.
2.  **옵션 설정:** 버튼 클릭 시, BottomSheet 형태의 **'옵션 선택 위젯'**이 나타납니다.
    *   위젯 상단에는 현재 레시피의 `bakingType`에 따라 "빵 설정", "케이크 설정" 등 동적 타이틀이 표시됩니다.
    *   사용자는 현재 레시피 타입에 맞춰 필터링된 옵션들을 선택하고 세부 값을 입력합니다.
3.  **프리셋 관리:** 설정된 옵션은 **[프리셋으로 저장]** 버튼을 통해 이름, 색상, 태그와 함께 저장할 수 있습니다. **[프리셋 불러오기]**로 기존 설정을 재사용합니다.
4.  **적용 전 검토:** **[설정 적용]** 버튼 클릭 시, 시스템은 **'충돌 해결 및 최적화'** 과정을 거칩니다.
    *   그 후, **'비교 카드(Comparison Card)'**가 Modal 형태로 표시됩니다.
    *   사용자는 `기존 값`과 `조정된 값`의 차이와 변경 이유를 명확히 확인합니다.
5.  **최종 적용:** 비교 카드에서 **[최종 적용]** 버튼을 누르면, 보정된 값이 레시피 계산기와 시뮬레이션에 반영됩니다. 레시피 상세 페이지에는 적용된 주요 설정이 **'정보 카드(Info Card)'** 형태로 요약 표시됩니다.

### 2.2. 베이킹 타입별 동적 UI 예시

| 레시피 타입 (`bakingType`) | 활성화되는 주요 옵션 카테고리 | 비활성화/숨김 처리되는 옵션 |
| :--- | :--- | :--- |
| **빵 (bread)** | ✅ **발효:** 1차/2차/저온숙성, 발효기 사용 여부<br>✅ **수분:** 수분율, 수분증발률<br>✅ **오븐:** 오븐스프링, 스팀 사용 | ❌ 휴지, 퍼짐성, 흡유율 |
| **쿠키 (cookie)** | ✅ **반죽:** 휴지 시간, 크림법/블렌딩법<br>✅ **굽기:** 퍼짐성 예측, 식감(바삭/쫀득) | ❌ 발효, 오븐스프링, 흡유율 |
| **케이크 (cake)** | ✅ **반죽:** 머랭/버터크림 안정성, 유화 상태<br>✅ **굽기:** 부피 변화, 수축/붕괴 예측 | ❌ 발효, 휴지, 흡유율 |
| **튀김 (fried)** | ✅ **공정:** 기름 종류, 흡유율 계산<br>✅ **온도:** 튀김 온도, 시간 | ❌ 오븐, 굽기, 휴지 |
| **냉동 디저트 (frozen_dessert)** | ✅ **냉동:** 동결 시간, 오버런(overrun) 계산<br>✅ **안정성:** 결정화 방지, 안정제 종류 | ❌ 발효, 굽기, 튀김 |
| **아이스크림/젤라토 (ice_cream/gelato)** | ✅ **공정:** 오버런, 숙성(aging) 시간<br>✅ **온도:** 동결점, 보관 온도<br>✅ **재료:** 유지방/당도 비율 | ❌ 발효, 굽기, 튀김 |
| **사탕 (candy)** | ✅ **온도:** 끓는점, 결정화 온도(소프트볼, 하드크랙 등)<br>✅ **재료:** 설탕 종류, 산도(pH) | ❌ 발효, 굽기, 튀김, 냉동 |
| **온 디저트 (dessert_hot)** | ✅ **온도:** 서빙 온도, 보온성<br>✅ **재료:** 소스 점도, 재료 궁합 | ❌ 발효, 냉동, 결정화 |
| **냉 디저트 (dessert_cold)** | ✅ **온도:** 냉장 시간, 겔화(gelation)<br>✅ **재료:** 안정제, 굳기 조절 | ❌ 발효, 굽기, 튀김 |

### 2.3. 공정 방식별 상세 UI 옵션

사용자가 '옵션 선택 위젯'에서 특정 공정 방식을 선택하면, 관련된 세부 설정 UI가 동적으로 활성화됩니다.

**오븐 종류 선택 시:**

| 오븐 종류 | 활성화되는 세부 옵션 | 시스템 제안 |
| :--- | :--- | :--- |
| **컨벡션 오븐** | `팬 속도 (저/중/고)`, `스팀 기능 사용 여부` | 기본 설정 온도에서 -15°C 자동 보정 제안 |
| **데크 오븐** | `상단 열`, `하단 열` 온도 개별 설정 | 레시피 타입에 따른 상/하단 열 온도 비율 제안 |
| **스팀 오븐** | `스팀 주입량 (%)`, `스팀 주입 타이밍 (초기/중간/후반)` | 빵 종류에 따른 최적 스팀 프로파일 추천 |

**발효 방식 선택 시:**

| 발효 방식 | 활성화되는 세부 옵션 | 시스템 제안 |
| :--- | :--- | :--- |
| **발효기 사용** | `발효기 온도`, `발효기 습도` | 제품별 최적 온도/습도 값 자동 추천 |
| **저온 숙성 (냉장)** | `냉장 온도`, `숙성 시간 (시간 단위)` | 풍미 극대화를 위한 추천 숙성 시간 제안 |
| **실온 발효** | (별도 옵션 없음) | 현재 작업실 환경(온도/습도)을 기반으로 예상 발효 시간 자동 계산 |

---

## 3. 지능형 보정 알고리즘 상세

### 3.1. 알고리즘 구조
`최종 보정값 = 기본값 + Σ(모듈별 보정치) + 충돌 해결 로직`

### 3.2. 핵심 보정 모듈 (베이킹 타입별)

| 모듈명 | 적용 대상 타입 | 입력 변수 | 출력 (보정 항목) |
| :--- | :--- | :--- | :--- |
| **발효시간_예측_모듈** | `bread`, `fried` | 실내/발효기 온도, 습도, 이스트 종류/양, 반죽 종류 | `발효 시간` |
| **수분증발률_계산_모듈** | `bread`, `cake` | 오븐 온도, 시간, 팬 종류, 반죽 표면적 | `총 반죽량`, `수분율` |
| **반죽부피_변화_모듈** | `cake`, `bread` | 재료(팽창제, 계란), 믹싱 강도, 오븐 온도 | `예상 부피`, `수축/붕괴 위험도` |
| **퍼짐성_예측_모듈** | `cookie` | 유지방 종류/온도, 설탕 종류, 휴지 시간 | `예상 퍼짐 직경`, `두께` |
| **흡유율_계산_모듈** | `fried` | 기름 온도, 튀김 시간, 반죽 수분율 | `최종 칼로리`, `반죽 무게` |
| **결정화_제어_모듈** | `candy`, `ice_cream`, `gelato` | 설탕 종류, 당도(Brix), 산도, 교반 속도 | `결정화 온도`, `결정 크기` |
| **오버런_계산_모듈** | `ice_cream`, `gelato` | 크림/우유 비율, 교반 속도, 숙성 시간 | `예상 부피 증가율`, `식감` |
| **동결점_강하_모듈** | `frozen_dessert`, `ice_cream`, `gelato` | 당분/알코올 함량, 안정제 종류 | `최적 동결 온도`, `보관성` |
| **점도_조절_모듈** | `dessert_hot`, `dessert_cold` | 전분/젤라틴 종류 및 양, 가열/냉각 시간 | `소스/크림 점도`, `안정성` |
| **오븐_특성_보정_모듈** | `bread`, `cake`, `cookie` | 오븐 종류(컨벡션/데크), 팬 속도, 상/하단 열 비율 | `굽는 온도`, `굽는 시간`, `열 전달 효율` |
| **발효_방식_최적화_모듈**| `bread`, `fried` | 발효 방식(발효기/저온/실온), 발효기 온도/습도 | `총 발효 시간`, `반죽 밀도`, `풍미 프로파일` |
| **고도_보정_모듈** | `All` | 해발 고도 | `팽창제 양`, `끓는점`, `굽는 온도` |

### 3.3. 수식화 예시 (수분 보정)
`AdjustedMoisture(%) = BaseMoisture + TempFactor + HumidityFactor + AltitudeFactor + DoughTypeFactor`

*   **TempFactor:** `(실내온도 - 22) * 0.4` (온도가 높을수록 증발량이 많아져 추가 수분 필요)
*   **HumidityFactor:** `(55 - 실내습도) * 0.2` (건조할수록 추가 수분 필요)
*   **AltitudeFactor:** `(고도 / 1000) * 0.5` (고도가 높을수록 증발 용이)
*   **DoughTypeFactor:** `{'sourdough': 1.5, 'chiffon': 2.0, 'shortcrust': -1.0}` (반죽별 기본 수분 요구량 차이)

### 3.4. 충돌 해결 로직
1.  **우선순위:** `사용자 직접 입력` > `환경 변수 보정` > `레시피 기본값`
2.  **병합 처리:** 여러 요인으로 수분 보정값이 중복 발생 시(예: 온도 `+1%`, 습도 `+1.5%`), 시스템은 이를 합산(`+2.5%`)하여 사용자에게 제안합니다. 단, 총 보정치가 ±5%p를 초과할 경우, 사용자에게 경고 메시지를 표시하여 과도한 변경을 인지시킵니다.

---

## 4. 온디바이스 데이터 구조 (JSON Schema)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "SousChefRecipeState",
  "type": "object",
  "properties": {
    "recipeId": { "type": "string" },
    "bakingType": { "enum": ["bread", "cake", "cookie", "fried", "dessert_hot", "dessert_cold", "frozen_dessert", "ice_cream", "gelato", "candy", "etc"] },
    "activePresetId": { "type": ["string", "null"] },
    "presets": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "colorTag": { "type": "string" },
          "tags": { "type": "array", "items": { "type": "string" } },
          "options": { 
            "type": "object",
            "properties": {
              "oven": {
                "type": "object",
                "properties": {
                  "type": { "enum": ["convection", "deck", "steam"] },
                  "fanSpeed": { "enum": ["low", "medium", "high", "null"] },
                  "topHeat": { "type": ["number", "null"] },
                  "bottomHeat": { "type": ["number", "null"] }
                }
              },
              "fermentation": {
                "type": "object",
                "properties": {
                  "method": { "enum": ["proofer", "cold", "room_temp"] },
                  "temperature": { "type": ["number", "null"] },
                  "humidity": { "type": ["number", "null"] },
                  "duration": { "type": "number" }
                }
              }
            }
          },
          "metadata": {
            "type": "object",
            "properties": {
              "createdAt": { "type": "string", "format": "date-time" },
              "usageCount": { "type": "integer" },
              "successRate": { "type": "number", "minimum": 0, "maximum": 1 }
            }
          }
        },
        "required": ["id", "name", "options"]
      }
    },
    "currentAdjustments": {
      "type": "object",
      "description": "현재 레시피에 적용된 최종 보정값",
      "properties": {
        "moisture": { "type": "number" },
        "fermentationTime": { "type": "number" },
        "bakingTemperature": { "type": "number" }
      }
    },
    "adjustmentHistory": {
      "type": "array",
      "description": "사용자의 성공/실패 피드백을 포함한 이력",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": { "type": "string", "format": "date-time" },
          "presetIdUsed": { "type": "string" },
          "finalAdjustments": { "type": "object" },
          "userFeedback": {
            "type": "object",
            "properties": {
              "result": { "enum": ["success", "failure", "partial_success"] },
              "memo": { "type": "string" },
              "imagePath": { "type": ["string", "null"] }
            }
          }
        }
      }
    }
  },
  "required": ["recipeId", "bakingType"]
}
```

---

## 5. 개발자 가이드 (for Claude Sonnet 3.7)

1.  **일관성 준수:** 본 문서에 정의된 데이터 모델(JSON Schema), UI/UX 흐름, 알고리즘 원칙을 엄격히 준수하여 코드를 생성합니다.
2.  **모듈식 개발:** '지능형 보정 알고리즘'의 각 모듈은 독립된 함수 또는 클래스로 개발하여 단위 테스트가 용이하도록 합니다.
3.  **상태 관리:** `Riverpod`를 사용하여 `RecipeState`를 관리하고, UI는 상태 변화에만 반응하도록 선언적으로 구성합니다.
4.  **데이터 영속성:** 온디바이스 DB로 `Hive` 또는 `Drift`를 사용하며, 정의된 JSON 구조에 맞춰 데이터를 저장하고 로드합니다.
5.  **동적 UI 구현:** `bakingType`에 따라 `Option` 위젯의 목록이 동적으로 변경되는 로직을 최우선으로 구현합니다. `Map`과 `enum`을 활용하여 각 타입에 필요한 옵션 목록을 정의하고, 이를 기반으로 UI를 렌더링합니다.