# 데이터 모델 문서

## 1. 데이터 모델 개요

### 1.1 주요 모델 클래스
- **Recipe**: 레시피 정보
- **History**: 레시피 변경 이력

### 1.2 모델 관계 다이어그램
```
┌─────────┐     1     ┌─────────┐
│ Recipe  │◄────────┤ Recipe  │
└─────────┘  parentId └─────────┘
     │
     │ 1
     ▼
     * 
┌─────────┐
│ History │
└─────────┘
```

## 2. Recipe 모델

### 2.1 속성
| 필드명 | 타입 | 설명 | 필수 여부 | 기본값 |
|--------|------|------|-----------|--------|
| id | int? | 레시피 고유 ID | 아니오 | null |
| title | String | 레시피 제목 | 예 | - |
| category | String | 레시피 카테고리 | 예 | - |
| ingredients | List<Map<String, dynamic>> | 재료 목록 | 예 | - |
| instructions | List<Map<String, dynamic>> | 조리법 단계 | 예 | - |
| imagePath | String? | 이미지 파일 경로 | 아니오 | null |
| baseServings | int | 기준 인분 수 | 아니오 | 1 |
| isBaking | bool | 베이킹 레시피 여부 | 아니오 | false |
| targetSplitAmount | double? | 목표 분할량 | 아니오 | null |
| targetSplitCount | int? | 목표 분할 개수 | 아니오 | null |
| calculatedRemainingWeight | double? | 계산된 남은 무게 | 아니오 | null |
| totalIngredientWeight | double? | 총 재료 무게 | 아니오 | null |
| parentId | int? | 부모 레시피 ID | 아니오 | null |

### 2.2 ingredients 구조
```json
[
  {
    "name": "밀가루",
    "amount": 100.0,
    "unit": "g"
  },
  {
    "name": "설탕",
    "amount": 50.0,
    "unit": "g"
  }
]
```

### 2.3 instructions 구조
```json
[
  {
    "text": "밀가루와 설탕을 섞습니다.",
    "imagePath": "/path/to/image.jpg"
  },
  {
    "text": "반죽을 만듭니다.",
    "imagePath": null
  }
]
```

### 2.4 메서드
```dart
// 맵으로 변환
Map<String, dynamic> toMap()

// 맵에서 생성
factory Recipe.fromMap(Map<String, dynamic> map)
```

### 2.5 데이터베이스 스키마
```sql
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  title TEXT, 
  category TEXT,
  ingredients TEXT, 
  instructions TEXT, 
  imagePath TEXT,
  baseServings INTEGER DEFAULT 1, 
  isBaking INTEGER DEFAULT 0,
  targetSplitAmount REAL,
  targetSplitCount INTEGER,
  calculatedRemainingWeight REAL,
  totalIngredientWeight REAL,
  parentId INTEGER
)
```

### 2.6 유효성 검사 규칙
- **title**: 비어있지 않아야 함
- **category**: 비어있지 않아야 함
- **ingredients**: 최소 1개 이상의 재료 필요
- **instructions**: 최소 1개 이상의 조리법 단계 필요
- **baseServings**: 1 이상의 정수
- **targetSplitAmount**: 양수 (설정된 경우)
- **targetSplitCount**: 양수 (설정된 경우)

## 3. History 모델

### 3.1 속성
| 필드명 | 타입 | 설명 | 필수 여부 | 기본값 |
|--------|------|------|-----------|--------|
| id | int? | 히스토리 고유 ID | 아니오 | null |
| recipeId | int | 레시피 ID | 예 | - |
| modifiedDate | String | 수정 날짜 (ISO 8601 형식) | 예 | - |
| changes | String | 변경 내용 설명 | 예 | - |
| recipeState | String? | 변경 전 레시피 상태 (JSON) | 아니오 | null |

### 3.2 메서드
```dart
// 맵으로 변환
Map<String, dynamic> toMap()

// 맵에서 생성
factory History.fromMap(Map<String, dynamic> map)
```

### 3.3 데이터베이스 스키마
```sql
CREATE TABLE history (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  recipeId INTEGER,
  modifiedDate TEXT, 
  changes TEXT, 
  recipeState TEXT
)
```

## 4. 데이터 변환 및 직렬화

### 4.1 JSON 직렬화
```dart
// Recipe 객체를 JSON 문자열로 변환
String recipeToJson(Recipe recipe) {
  return jsonEncode(recipe.toMap());
}

// JSON 문자열에서 Recipe 객체 생성
Recipe recipeFromJson(String json) {
  return Recipe.fromMap(jsonDecode(json));
}
```

### 4.2 데이터베이스 직렬화
- **ingredients**: JSON 문자열로 저장
- **instructions**: JSON 문자열로 저장
- **isBaking**: 0(false) 또는 1(true)로 저장

### 4.3 단위 변환
- 저장: 모든 단위는 원본 그대로 저장
- 표시: 선택된 단위 시스템에 따라 변환하여 표시

## 5. 데이터 관계

### 5.1 파생 레시피 관계
- 원본 레시피: `parentId == null`
- 파생 레시피: `parentId != null`
- 파생 관계 조회: `Recipe.parentId`로 부모 레시피 참조

### 5.2 히스토리 관계
- 레시피와 히스토리: 1:N 관계
- 조회 방법: `history` 테이블에서 `recipeId`로 필터링

## 6. 데이터 마이그레이션

### 6.1 마이그레이션 이력
| 버전 | 변경 사항 |
|------|-----------|
| 1 | 초기 스키마 생성 |
| 2 | history 테이블에 recipeState 컬럼 추가 |
| 3 | recipes 테이블에 baseServings 컬럼 추가 |
| 4 | recipes 테이블에 isBaking 컬럼 추가 |
| 5 | recipes 테이블에 분할 관련 컬럼 추가 (targetSplitAmount, targetSplitCount, calculatedRemainingWeight, totalIngredientWeight) |
| 6 | recipes 테이블에 parentId 컬럼 추가 |

### 6.2 마이그레이션 코드
```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE history ADD COLUMN recipeState TEXT');
  }
  if (oldVersion < 3) {
    await db.execute('ALTER TABLE recipes ADD COLUMN baseServings INTEGER DEFAULT 1');
  }
  if (oldVersion < 4) {
    await db.execute('ALTER TABLE recipes ADD COLUMN isBaking INTEGER DEFAULT 0');
  }
  if (oldVersion < 5) {
    await db.execute('ALTER TABLE recipes ADD COLUMN targetSplitAmount REAL');
    await db.execute('ALTER TABLE recipes ADD COLUMN targetSplitCount INTEGER');
    await db.execute('ALTER TABLE recipes ADD COLUMN calculatedRemainingWeight REAL');
    await db.execute('ALTER TABLE recipes ADD COLUMN totalIngredientWeight REAL');
  }
  if (oldVersion < 6) {
    await db.execute('ALTER TABLE recipes ADD COLUMN parentId INTEGER');
  }
}
```

## 7. 데이터 백업 및 복원

### 7.1 백업 형식
```json
{
  "recipes": [
    {
      "id": 1,
      "title": "김치찌개",
      "category": "한식",
      "ingredients": "[{\"name\":\"김치\",\"amount\":300,\"unit\":\"g\"}]",
      "instructions": "[{\"text\":\"끓인다\"}]",
      "imagePath": null,
      "baseServings": 2,
      "isBaking": 0,
      "imageData": "base64_encoded_image_data"
    }
  ],
  "history": [
    {
      "id": 1,
      "recipeId": 1,
      "modifiedDate": "2025-07-20T10:30:00.000Z",
      "changes": "레시피 생성",
      "recipeState": null
    }
  ]
}
```

### 7.2 백업 프로세스
1. 데이터베이스에서 모든 레시피와 히스토리 조회
2. 이미지 파일을 Base64로 인코딩
3. JSON 형식으로 직렬화
4. ZIP 파일로 압축

### 7.3 복원 프로세스
1. ZIP 파일 압축 해제
2. JSON 파싱
3. 기존 데이터베이스 초기화
4. 레시피 및 히스토리 데이터 삽입
5. Base64 이미지 데이터를 파일로 저장

## 8. 데이터 모델 확장 계획

### 8.1 계획된 모델 추가
- **Tag**: 레시피 태그 관리
- **ShoppingList**: 쇼핑 목록 관리
- **Nutrition**: 영양 정보 관리
- **User**: 사용자 계정 관리 (클라우드 동기화용)

### 8.2 계획된 필드 추가
- **Recipe.cookingTime**: 조리 시간
- **Recipe.difficulty**: 난이도
- **Recipe.rating**: 평점
- **Recipe.notes**: 메모
- **Recipe.tags**: 태그 목록

### 8.3 마이그레이션 계획
- 버전 7: 조리 시간, 난이도, 평점 필드 추가
- 버전 8: 태그 관련 테이블 및 관계 추가
- 버전 9: 쇼핑 목록 관련 테이블 추가