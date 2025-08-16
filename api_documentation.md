# API 문서

## 내부 API

### 1. RecipeProvider API

#### 1.1 레시피 관리 메서드
```dart
/// 모든 레시피 로드
Future<void> loadRecipes()

/// ID로 레시피 조회
/// [id] 조회할 레시피 ID
/// 반환값: 찾은 레시피 또는 null
Future<Recipe?> getRecipeById(int id)

/// 레시피 추가
/// [recipe] 추가할 레시피 객체
Future<void> addRecipe(Recipe recipe)

/// 레시피 업데이트
/// [recipe] 업데이트할 레시피 객체
/// [changes] 변경 내용 설명
Future<void> updateRecipe(Recipe recipe, String changes)

/// 레시피 삭제
/// [recipeId] 삭제할 레시피 ID
Future<void> deleteRecipe(int recipeId)
```

#### 1.2 파생 레시피 관련 메서드
```dart
/// 파생 레시피 개수 조회
/// [parentId] 부모 레시피 ID
/// 반환값: 파생된 레시피 개수
Future<int> getDerivedCount(int parentId)

/// 파생 레시피 목록 조회
/// [parentId] 부모 레시피 ID
/// 반환값: 파생된 레시피 목록
Future<List<Recipe>> getDerivedRecipes(int parentId)

/// 부모 레시피 조회
/// [recipeId] 레시피 ID
/// 반환값: 부모 레시피 또는 null
Future<Recipe?> getParentRecipe(int recipeId)
```

#### 1.3 히스토리 관련 메서드
```dart
/// 레시피 히스토리 로드
/// [recipeId] 레시피 ID
Future<void> loadHistory(int recipeId)
```

#### 1.4 데이터 관리 메서드
```dart
/// Excel로 레시피 내보내기
/// [recipe] 내보낼 레시피
/// 반환값: 저장된 파일 경로
Future<String> exportToExcel(Recipe recipe)

/// 모든 레시피 내보내기
/// 반환값: 백업 파일 경로
Future<String> exportAllRecipes()

/// 레시피 데이터 가져오기
/// [filePath] 백업 파일 경로
Future<void> importAllRecipes(String filePath)

/// 모든 레시피 삭제
Future<void> deleteAllRecipes()
```

#### 1.5 카테고리 관리 메서드
```dart
/// 카테고리 로드
Future<void> loadCategories()

/// 카테고리 추가
/// [category] 추가할 카테고리 이름
Future<void> addCategory(String category)

/// 카테고리 삭제
/// [category] 삭제할 카테고리 이름
Future<void> removeCategory(String category)
```

### 2. RecipeDerivationService API

#### 2.1 레시피 복사 및 파생
```dart
/// 레시피 복사본 생성
/// [original] 원본 레시피
/// [withNewTitle] 제목에 "(복사본)" 추가 여부
/// 반환값: 복사된 새 레시피 (아직 저장되지 않음)
Future<Recipe> createCopy(Recipe original, {bool withNewTitle = true})

/// 파생 레시피 생성
/// [original] 원본 레시피
/// [customTitle] 사용자 지정 제목 (없으면 "(파생)" 추가)
/// 반환값: 파생된 새 레시피 (아직 저장되지 않음)
Future<Recipe> createDerived(Recipe original, {String? customTitle})
```

#### 2.2 레시피 계보 관리
```dart
/// 레시피 계보 구성
/// [initialRecipe] 시작 레시피
/// 반환값: 레시피와 깊이 정보를 포함한 트리 구조
Future<List<Map<String, dynamic>>> buildRecipeTree(Recipe initialRecipe)

/// 레시피의 파생 개수 가져오기
/// [recipe] 레시피
/// 반환값: 파생 레시피 개수
Future<int> getDerivedCount(Recipe recipe)

/// 레시피의 파생 레시피 목록 가져오기
/// [recipe] 레시피
/// 반환값: 파생 레시피 목록
Future<List<Recipe>> getDerivedRecipes(Recipe recipe)

/// 레시피의 부모 레시피 가져오기
/// [recipe] 레시피
/// 반환값: 부모 레시피 또는 null
Future<Recipe?> getParentRecipe(Recipe recipe)
```

### 3. UnitConverter API

#### 3.1 단위 변환
```dart
/// 단위 변환
/// [amount] 변환할 양
/// [fromUnit] 원본 단위
/// [toUnit] 대상 단위
/// 반환값: 변환된 양
static double convert(double amount, String fromUnit, String toUnit)

/// 단위 시스템에 따른 단위 목록 가져오기
/// [system] 단위 시스템 (Korea, SI, US, Japan, Europe)
/// 반환값: 단위 목록
static List<String> getUnits(String system)
```

### 4. ImageUtils API

#### 4.1 이미지 처리
```dart
/// 이미지 압축
/// [file] 압축할 이미지 파일
/// 반환값: 압축된 이미지 파일
static Future<File?> compressImage(File file)

/// 이미지 파일 복사
/// [originalPath] 원본 이미지 경로
/// 반환값: 복사된 이미지 경로
static Future<String?> copyImageFile(String originalPath)

/// 이미지 파일 삭제
/// [path] 삭제할 이미지 경로
/// 반환값: 삭제 성공 여부
static Future<bool> deleteImageFile(String? path)
```

### 5. ErrorHandler API

#### 5.1 오류 처리
```dart
/// 오류 로깅
/// [tag] 오류 태그
/// [message] 오류 메시지
/// [error] 오류 객체 (선택)
/// [stackTrace] 스택 트레이스 (선택)
static void logError(String tag, String message, [dynamic error, StackTrace? stackTrace])

/// 오류 스낵바 표시
/// [context] 빌드 컨텍스트
/// [message] 오류 메시지
static void showErrorSnackBar(BuildContext context, String message)

/// 성공 스낵바 표시
/// [context] 빌드 컨텍스트
/// [message] 성공 메시지
static void showSuccessSnackBar(BuildContext context, String message)

/// 확인 대화상자 표시
/// [context] 빌드 컨텍스트
/// [title] 대화상자 제목
/// [content] 대화상자 내용
/// [confirmText] 확인 버튼 텍스트 (기본값: '확인')
/// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
/// 반환값: 사용자 선택 (true: 확인, false: 취소)
static Future<bool> showConfirmationDialog(
  BuildContext context, 
  String title, 
  String content, 
  {String confirmText = '확인', String cancelText = '취소'}
)
```

## 외부 API 및 라이브러리

### 1. sqflite

#### 1.1 데이터베이스 연결
```dart
/// 데이터베이스 열기
Future<Database> openDatabase(
  String path, 
  {int? version, 
  OnDatabaseCreateFn? onCreate, 
  OnDatabaseVersionChangeFn? onUpgrade}
)
```

#### 1.2 데이터 조작
```dart
/// 데이터 조회
Future<List<Map<String, dynamic>>> query(
  String table, 
  {List<String>? columns, 
  String? where, 
  List<dynamic>? whereArgs}
)

/// 데이터 삽입
Future<int> insert(String table, Map<String, dynamic> values)

/// 데이터 업데이트
Future<int> update(
  String table, 
  Map<String, dynamic> values, 
  {String? where, 
  List<dynamic>? whereArgs}
)

/// 데이터 삭제
Future<int> delete(
  String table, 
  {String? where, 
  List<dynamic>? whereArgs}
)
```

### 2. shared_preferences

#### 2.1 데이터 저장 및 조회
```dart
/// 문자열 저장
Future<bool> setString(String key, String value)

/// 문자열 조회
String? getString(String key)

/// 불리언 저장
Future<bool> setBool(String key, bool value)

/// 불리언 조회
bool? getBool(String key)
```

### 3. image_picker

#### 3.1 이미지 선택
```dart
/// 갤러리에서 이미지 선택
Future<XFile?> pickImage(
  {required ImageSource source, 
  double? maxWidth, 
  double? maxHeight, 
  int? imageQuality}
)
```

### 4. flutter_image_compress

#### 4.1 이미지 압축
```dart
/// 이미지 압축 및 저장
Future<File?> compressAndGetFile(
  String sourcePath, 
  String targetPath, 
  {int quality = 80, 
  int minWidth = 1024, 
  int minHeight = 1024}
)
```

### 5. path_provider

#### 5.1 경로 가져오기
```dart
/// 앱 문서 디렉토리 경로 가져오기
Future<Directory> getApplicationDocumentsDirectory()

/// 임시 디렉토리 경로 가져오기
Future<Directory> getTemporaryDirectory()
```

### 6. excel

#### 6.1 Excel 파일 생성
```dart
/// Excel 객체 생성
Excel.createExcel()

/// 시트에 행 추가
Sheet.appendRow(List<CellValue> cells)

/// Excel 파일 인코딩
List<int>? Excel.encode()
```

### 7. share_plus

#### 7.1 콘텐츠 공유
```dart
/// 파일 공유
Future<ShareResult> shareFiles(
  List<String> paths, 
  {String? text, 
  String? subject}
)
```

## API 사용 예시

### 레시피 추가 예시
```dart
final recipe = Recipe(
  title: '김치찌개',
  category: '한식',
  ingredients: [
    {'name': '김치', 'amount': 300.0, 'unit': 'g'},
    {'name': '돼지고기', 'amount': 200.0, 'unit': 'g'},
    {'name': '두부', 'amount': 150.0, 'unit': 'g'},
  ],
  instructions: [
    {'text': '김치를 적당한 크기로 자릅니다.'},
    {'text': '돼지고기를 볶다가 김치를 넣고 같이 볶습니다.'},
    {'text': '물을 붓고 끓인 후 두부를 넣습니다.'},
  ],
  baseServings: 2,
);

await recipeProvider.addRecipe(recipe);
```

### 파생 레시피 생성 예시
```dart
final originalRecipe = await recipeProvider.getRecipeById(1);
if (originalRecipe != null) {
  final derivedRecipe = await derivationService.createDerived(originalRecipe);
  await recipeProvider.addRecipe(derivedRecipe);
}
```

### 단위 변환 예시
```dart
// 200g을 cup_us로 변환
final cups = UnitConverter.convert(200.0, 'g', 'cup_us');
print('200g = ${cups.toStringAsFixed(2)} cups');
```