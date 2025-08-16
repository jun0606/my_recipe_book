// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get recipeBookTitle => '나의 레시피 북';

  @override
  String get noRecipes => '레시피가 없습니다.';

  @override
  String get categoryList => '카테고리 목록';

  @override
  String get noCategories => '카테고리가 없습니다.';

  @override
  String cannotDeleteCategoryWithRecipes(Object category) {
    return '$category 카테고리에 레시피가 있어 삭제할 수 없습니다.';
  }

  @override
  String categoryDeleted(Object category) {
    return '$category 카테고리가 삭제되었습니다.';
  }

  @override
  String categoryDeletionFailed(Object error) {
    return '카테고리 삭제 실패: $error';
  }

  @override
  String get welcomeMessage => '나의 레시피 북에 오신 것을 환영합니다!';

  @override
  String get startCookingJourney => '맛있는 요리 여행을 시작해 보세요!';

  @override
  String get recipeBookSettings => '레시피 북 설정';

  @override
  String get nameLabel => '이름';

  @override
  String get nameRequired => '이름을 입력해주세요';

  @override
  String get titleLabel => '호칭';

  @override
  String get chef => '셰프';

  @override
  String get cook => '요리사';

  @override
  String get baker => '제빵사';

  @override
  String get kitchenMaster => '주방장';

  @override
  String get startCooking => '요리 시작';

  @override
  String get user => '사용자';

  @override
  String addRecipePrompt(Object category) {
    return '$category 레시피를 추가해주세요!';
  }

  @override
  String get addRecipe => '레시피 추가';

  @override
  String get searchRecipe => '레시피 검색';

  @override
  String get settings => '설정';

  @override
  String get addRecipeTitle => '레시피 추가';

  @override
  String get editRecipeTitle => '레시피 편집';

  @override
  String get recipeTitleLabel => '레시피 제목';

  @override
  String get recipeTitleRequired => '레시피 제목을 입력해주세요';

  @override
  String get categoryLabel => '카테고리';

  @override
  String get ingredientNameLabel => '재료명';

  @override
  String get ingredientAmountLabel => '재료양';

  @override
  String get amountGreaterThanZero => '양은 0보다 커야 합니다.';

  @override
  String get invalidAmount => '유효한 재료양을 입력해주세요.';

  @override
  String get unitSystemLabel => '단위 체계';

  @override
  String get unitLabel => '단위';

  @override
  String get addIngredient => '재료 추가';

  @override
  String get instructionsLabel => '만드는 법';

  @override
  String get instructionsRequired => '만드는 법을 입력해주세요';

  @override
  String servings(Object servings) {
    return '$servings차림';
  }

  @override
  String get noPhoto => '사진 없음';

  @override
  String get uploadPhoto => '사진 업로드';

  @override
  String get ingredientUnitInstructionEdit => '재료, 단위, 만드는 법 편집됨';

  @override
  String get saveRecipe => '레시피 저장';

  @override
  String get editRecipe => '레시피 편집';

  @override
  String saveRecipeFailed(Object error) {
    return '레시피 저장 실패: $error';
  }

  @override
  String recipeTitle(Object title) {
    return '레시피: $title';
  }

  @override
  String category(Object category) {
    return '카테고리: $category';
  }

  @override
  String get ingredientsLabel => '재료:';

  @override
  String get editHistory => '편집 기록:';

  @override
  String get noHistory => '기록이 없습니다.';

  @override
  String get updateHistory => '기록 업데이트';

  @override
  String loadHistoryFailed(Object error) {
    return '기록 로드 실패: $error';
  }

  @override
  String get shareExcel => '엑셀로 공유';

  @override
  String exportExcelFailed(Object error) {
    return '엑셀 생성 실패: $error';
  }

  @override
  String get sharePdf => 'PDF로 공유';

  @override
  String exportPdfFailed(Object error) {
    return 'PDF 생성 실패: $error';
  }

  @override
  String get userInfo => '사용자 정보';

  @override
  String get updateUserInfo => '사용자 정보 업데이트';

  @override
  String loadUserInfoFailed(Object error) {
    return '사용자 정보 로드 실패: $error';
  }

  @override
  String get userInfoUpdated => '사용자 정보가 업데이트되었습니다.';

  @override
  String saveUserInfoFailed(Object error) {
    return '사용자 정보 저장 실패: $error';
  }

  @override
  String get defaultUnitSystem => '기본 단위 체계';

  @override
  String get categoryManagement => '카테고리 관리';

  @override
  String get addNewCategory => '새 카테고리 추가';

  @override
  String get categoryAdded => '카테고리가 추가되었습니다!';

  @override
  String addCategoryFailed(Object error) {
    return '카테고리 추가 실패: $error';
  }

  @override
  String get enterValidCategoryName => '유효한 카테고리 이름을 입력해주세요.';

  @override
  String get recipeManagement => '레시피 관리';

  @override
  String get deleteRecipe => '레시피 삭제';

  @override
  String confirmDeleteRecipe(Object title) {
    return '$title 레시피를 삭제하시겠습니까?';
  }

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String recipeDeleted(Object title) {
    return '$title 레시피가 삭제되었습니다.';
  }

  @override
  String deleteRecipeFailed(Object error) {
    return '레시피 삭제 실패: $error';
  }

  @override
  String get save => '저장';

  @override
  String greeting(Object name, Object title) {
    return '안녕하세요, $title $name님!';
  }

  @override
  String get testAddCategoryButton => 'Test Add Category Button';

  @override
  String get languageSelectionLabel => '언어 선택';

  @override
  String get setupScreenTitle => '나만의 레시피북 설정';

  @override
  String get titleSelectionLabel => '호칭 선택';

  @override
  String get pastryChef => '파티쉐';

  @override
  String get gourmet => '미식가';

  @override
  String get foodie => '식도락가';

  @override
  String get culinaryResearcher => '요리연구가';

  @override
  String get honorificNim => '님';

  @override
  String get honorificSsi => '씨';

  @override
  String get resetUserNameAndTitle => '이름 및 호칭 초기화';

  @override
  String get unitSystemSelectionLabel => '단위 시스템 선택';

  @override
  String get saveSettings => '설정 저장';

  @override
  String get newCategoryNameLabel => '새 카테고리 이름';

  @override
  String get add => '추가';

  @override
  String get deleteCategory => '카테고리 삭제';

  @override
  String confirmDeleteCategory(Object category) {
    return '\"$category\" 카테고리를 삭제하시겠습니까? 이 카테고리에 속한 레시피가 없어야 삭제할 수 있습니다.';
  }

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get backupAllRecipes => '모든 레시피 백업';

  @override
  String get restoreRecipes => '레시피 복구';

  @override
  String get deleteAllRecipes => '모든 레시피 삭제';

  @override
  String get deleteAllRecipesTitle => '모든 레시피 삭제';

  @override
  String get confirmDeleteAllRecipes =>
      '정말로 모든 레시피를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get resetUserNameAndTitleTitle => '이름 및 호칭 초기화';

  @override
  String get confirmResetUserNameAndTitle =>
      '정말로 이름과 호칭을 초기화하시겠습니까? 초기화 후 앱을 다시 시작하면 사용자 설정 화면으로 이동합니다.';

  @override
  String get reset => '초기화';

  @override
  String get settingsSaved => '설정이 저장되었습니다.';

  @override
  String recipesBackedUp(Object filePath) {
    return '모든 레시피가 다음 경로에 백업되었습니다: $filePath';
  }

  @override
  String get shareBackupFile => '나의 레시피 북 백업 파일을 공유합니다.';

  @override
  String recipeBackupFailed(Object error) {
    return '레시피 백업 중 오류가 발생했습니다: $error';
  }

  @override
  String get recipesRestored => '레시피가 성공적으로 복구되었습니다.';

  @override
  String get fileSelectionCancelled => '파일 선택이 취소되었습니다.';

  @override
  String recipeRestoreFailed(Object error) {
    return '레시피 복구 중 오류가 발생했습니다: $error';
  }

  @override
  String get allRecipesDeleted => '모든 레시피가 삭제되었습니다.';

  @override
  String get userNameAndTitleReset => '이름과 호칭이 초기화되었습니다. 앱을 다시 시작합니다.';
}
