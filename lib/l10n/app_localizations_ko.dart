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
  String get noCategories => '카테고리가 없습니다';

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
  String get editRecipeTitle => '레시피 수정';

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
  String get recipeDeleted => '레시피가 삭제되었습니다';

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

  @override
  String get textScaleSettings => '텍스트 크기 설정';

  @override
  String get useSystemTextScale => '시스템 텍스트 크기 설정 사용';

  @override
  String get followDeviceAccessibility => '기기의 접근성 설정을 따릅니다';

  @override
  String get textScaleAdjustment => '텍스트 크기 조절';

  @override
  String currentSize(Object size) {
    return '현재 크기: $size%';
  }

  @override
  String get preview => '미리보기';

  @override
  String get previewBodyText => '이것은 본문 텍스트의 예시입니다. 레시피 내용이나 설명이 이런 크기로 표시됩니다.';

  @override
  String get previewSmallText => '작은 텍스트 예시입니다.';

  @override
  String get sizeSmall => '작게';

  @override
  String get sizeNormal => '보통';

  @override
  String get sizeLarge => '크게';

  @override
  String get sizeVeryLarge => '매우 크게';

  @override
  String get helpTitle => '도움말';

  @override
  String get textScaleHelp =>
      '• 시스템 설정을 사용하면 기기의 접근성 설정이 적용됩니다.\n• 커스텀 설정을 사용하면 앱 내에서만 텍스트 크기가 조절됩니다.\n• 두 설정을 함께 사용할 수도 있습니다.';

  @override
  String permissionRequired(Object feature) {
    return '$feature 권한 필요';
  }

  @override
  String permissionRequiredMessage(Object feature) {
    return '$feature 권한이 필요합니다. 권한을 허용하시겠습니까?';
  }

  @override
  String permissionPermanentlyDenied(Object feature) {
    return '$feature 권한이 필요합니다. 설정 > 개인정보 보호 > $feature 에서 권한을 허용해주세요.';
  }

  @override
  String get requestPermission => '권한 요청';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get cameraFeature => '카메라';

  @override
  String get galleryAccessFeature => '갤러리 접근';

  @override
  String get photosFeature => '사진 라이브러리';

  @override
  String get derivedRecipeSave => '파생 레시피 저장';

  @override
  String get recipeCopy => '레시피 복사';

  @override
  String get recipeModify => '레시피 수정';

  @override
  String get recipeImageUpload => '사진 업로드';

  @override
  String get recipeImageCamera => '카메라로 촬영';

  @override
  String get selectFromGallery => '갤러리에서 선택';

  @override
  String get takeWithCamera => '카메라로 촬영';

  @override
  String get bakingModeActivate => '베이킹 모드 활성화';

  @override
  String get servingsInput => '인분';

  @override
  String get servingsRequired => '인분을 입력하세요';

  @override
  String get validServingsRequired => '유효한 인분 수를 입력하세요';

  @override
  String get splitWeight => '분할 무게';

  @override
  String get splitCount => '분할개수';

  @override
  String get splitWeightOrCountRequired => '분할량 또는 분할 개수를 입력하세요';

  @override
  String get validSplitWeightRequired => '유효한 분할량을 입력하세요';

  @override
  String get validSplitCountRequired => '유효한 분할 개수를 입력하세요';

  @override
  String splitWeightExceedsTotal(Object total) {
    return '분할량은 총 재료 무게를 초과할 수 없습니다. (총: ${total}g)';
  }

  @override
  String eachWeight(Object unit, Object weight) {
    return '각 $weight$unit 씩';
  }

  @override
  String totalSplits(Object count, Object remaining, Object unit) {
    return '총 $count개로 분할 가능 (남는 양: $remaining$unit)';
  }

  @override
  String get resetInput => '입력값 초기화';

  @override
  String get ingredients => '재료';

  @override
  String get ingredientName => '재료명';

  @override
  String get ingredientEdit => '재료 수정';

  @override
  String get ingredientAmount => '양';

  @override
  String get validIngredientRequired => '유효한 재료 이름과 양을 입력하세요.';

  @override
  String get validAmountRequired => '유효한 재료 양을 입력하세요.';

  @override
  String get ingredientNameAndAmountRequired => '재료 이름과 양을 모두 입력하세요.';

  @override
  String get copyLabel => ' (복사본)';

  @override
  String get derivedLabel => ' (파생)';

  @override
  String get recipeGenealogy => '레시피 계보';

  @override
  String get retryAction => '다시 시도';

  @override
  String get goBackAction => '돌아가기';

  @override
  String get favoritePresets => '즐겨찾기 프리셋';

  @override
  String get addCustomPreset => '커스텀 프리셋 추가';

  @override
  String get exportAction => '내보내기';

  @override
  String get importAction => '가져오기';

  @override
  String get cleanupAction => '정리';

  @override
  String get useAction => '사용하기';

  @override
  String get editAction => '수정';

  @override
  String get duplicateAction => '복제';

  @override
  String get noPresetsAvailable => '저장된 프리셋이 없습니다.';

  @override
  String get addFirstPreset => '첫 번째 프리셋을 추가해보세요!';

  @override
  String get languageSelection => '언어 선택';

  @override
  String get titleSelection => '호칭 선택';

  @override
  String get unitSelection => '단위';

  @override
  String get editIngredientTitle => '재료 수정';

  @override
  String get recipeTitleInput => '레시피 제목';

  @override
  String get categoryInput => '카테고리';

  @override
  String get servingsLabel => '인분';

  @override
  String get splitWeightLabel => '분할 무게';

  @override
  String get splitCountLabel => '분할 개수';

  @override
  String get temperatureLabel => '온도 (°C)';

  @override
  String get timeMinutesLabel => '시간 (분)';

  @override
  String get humidityLabel => '습도 (%)';

  @override
  String get speedLabel => '속도';

  @override
  String stepNumberLabel(Object number) {
    return '단계 $number';
  }

  @override
  String get enterValidIngredientAmount => '유효한 재료 양을 입력하세요.';

  @override
  String get enterIngredientNameAndAmount => '재료 이름과 양을 모두 입력하세요.';

  @override
  String get writeAllInstructionSteps => '모든 조리법 단계를 작성하세요.';

  @override
  String get addAtLeastOneIngredient => '최소 하나의 재료를 추가하세요.';

  @override
  String get recipeModified => '레시피가 수정되었습니다.';

  @override
  String recipeModifyError(Object error) {
    return '레시피 수정 중 오류가 발생했습니다: $error';
  }

  @override
  String recipeSaveError(Object error) {
    return '레시피 저장 중 오류가 발생했습니다: $error';
  }

  @override
  String get backupFileShare => '백업 파일 공유';

  @override
  String get backupCancelled => '백업이 취소되었습니다';

  @override
  String get favoritesTab => '즐겨찾기';

  @override
  String get statisticsTab => '통계';

  @override
  String get recommendationsTab => '추천';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get deleteFavorite => '즐겨찾기 삭제';

  @override
  String get confirmText => '확인';

  @override
  String get errorTitle => '오류';

  @override
  String get infoTitle => '정보';

  @override
  String successCases(Object count) {
    return '성공 사례: $count회';
  }

  @override
  String averageImprovement(Object percent) {
    return '평균 개선도: $percent%';
  }

  @override
  String get addToFavorites => '즐겨찾기 추가';

  @override
  String get noPerformanceData => '아직 성과 데이터가 없습니다.';

  @override
  String successRate(Object percent) {
    return '성공률: $percent%';
  }

  @override
  String get noUsageData => '아직 사용 데이터가 없습니다.';

  @override
  String get recipeHistory => '레시피 히스토리';

  @override
  String get deleteAllAction => '전체 삭제';

  @override
  String get improvementLabel => '개선도: ';

  @override
  String get improvementPrefix => '개선: ';

  @override
  String get notEnoughImprovementData => '아직 개선 데이터가 충분하지 않습니다.';

  @override
  String get closeAction => '닫기';

  @override
  String get deleteAllTitle => '전체 삭제';

  @override
  String get confirmDeleteAllHistory => '모든 히스토리를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get userGuide => '사용자 가이드';

  @override
  String get initializingGuideSystem => '가이드 시스템을 초기화하는 중...';

  @override
  String get shareAction => '공유';

  @override
  String get completeAction => '완료 처리';

  @override
  String get guideCompleted => '가이드가 완료되었습니다!';

  @override
  String get fermenterSettingGuide => '발효기 설정 가이드';

  @override
  String get fermenterSettingGuideDesc => '새로운 발효기 설정을 위한 단계별 가이드';

  @override
  String get troubleshootingGuide => '문제 해결 가이드';

  @override
  String get guideShareFeatureComingSoon => '가이드 공유 기능은 준비 중입니다';

  @override
  String get guideExportFeatureComingSoon => '가이드 내보내기 기능은 준비 중입니다';

  @override
  String get fermenterGuideComingSoon => '발효기 설정 가이드 생성 기능은 준비 중입니다';

  @override
  String get troubleshootingGuideComingSoon => '문제 해결 가이드 생성 기능은 준비 중입니다';

  @override
  String get overallStatistics => '전체 통계';

  @override
  String get topPerformers => '최고 성과 프리셋';

  @override
  String get mostUsedPresets => '자주 사용하는 프리셋';

  @override
  String get categoryDistribution => '카테고리별 분포';

  @override
  String get totalFavorites => '총 즐겨찾기';

  @override
  String get customPresets => '커스텀';

  @override
  String get averageSuccessRate => '평균 성공률';

  @override
  String get averageImprovementScore => '평균 개선도';

  @override
  String get recommendedEnvironment => '추천 환경 조건';

  @override
  String get temperatureShort => '온도';

  @override
  String get humidityShort => '습도';

  @override
  String get altitudeShort => '고도';

  @override
  String get recentlyUsed => '최근 사용';

  @override
  String get noFavoritesYet => '아직 즐겨찾기가 없습니다';

  @override
  String get addPresetInSousChef => '수쉐프 모드에서 프리셋을 즐겨찾기에 추가해보세요';

  @override
  String get noRecommendationsYet => '아직 추천할 프리셋이 없습니다';

  @override
  String get useMoreForRecommendations => '수쉐프 모드를 더 사용하면 맞춤 추천을 받을 수 있습니다';

  @override
  String confidenceLabel(Object percent) {
    return '신뢰도 $percent%';
  }

  @override
  String get yes => '네';

  @override
  String get no => '아니오';

  @override
  String get close => '닫기';

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get complete => '완료';

  @override
  String get addStep => '단계 추가';

  @override
  String get simpleCopy => '단순 복제';

  @override
  String get derivedRecipe => '파생 레시피';

  @override
  String get recipeEdit => '레시피 수정';

  @override
  String get sousChefMode => '수쉐프 모드';

  @override
  String get historyTooltip => '히스토리';

  @override
  String get korean => '한국어';

  @override
  String get autoSave => '자동 저장';

  @override
  String get textSizeSettingsTooltip => '텍스트 크기 설정';

  @override
  String get enterTitle => '제목을 입력하세요';

  @override
  String get hintOvenCondition => '예: 윗면이 갈색이 될 때까지';

  @override
  String get hintFermentCondition => '예: 반죽이 2배로 부풀 때까지';

  @override
  String get hintMixCondition => '예: 반죽이 매끈해질 때까지';

  @override
  String get sortTooltip => '정렬';

  @override
  String get filterTooltip => '필터';

  @override
  String get refreshTooltip => '새로고침';

  @override
  String get quickGuideTooltip => '빠른 가이드 생성';

  @override
  String get cannotLoadComparisonData => '비교할 레시피 데이터를 불러올 수 없습니다';

  @override
  String get copyRecipeTitle => '레시피 복사';

  @override
  String get saveDerivedRecipeTitle => '파생 레시피 저장';

  @override
  String get ingredientsSectionTitle => '재료';

  @override
  String get instructionsSectionTitle => '조리법';

  @override
  String get enterInstruction => '조리법을 입력하세요';

  @override
  String stepLabel(Object number) {
    return '단계 $number';
  }

  @override
  String stepCommentLabel(Object number) {
    return '$number단계 코멘트 (선택사항)';
  }

  @override
  String get addOvenStepMessage => '오븐 단계를 추가해주세요';

  @override
  String get addFermentationStepMessage => '발효 단계를 추가해주세요';

  @override
  String get addMixingStepMessage => '믹싱 단계를 추가해주세요';

  @override
  String get addOvenStepExample => '예: 180°C 40분 → 200°C 20분';

  @override
  String get addFermentationStepExample => '예: 1차 발효 80% 240분 → 2차 발효 85% 120분';

  @override
  String get addMixingStepExample => '예: 중속 15분 → 저속 10분';

  @override
  String sousChefModeError(Object error) {
    return '수쉐프 모드를 실행할 수 없습니다: $error';
  }

  @override
  String get copyRecipeMethodTitle => '레시피 복제 방식 선택';

  @override
  String get copyRecipeMethodContent => '어떤 방식으로 복제하시겠습니까?';

  @override
  String get deleteRecipeTitle => '레시피 삭제';

  @override
  String deleteRecipeContent(Object title) {
    return '$title 레시피를 삭제하시겠습니까?';
  }

  @override
  String deleteFailed(Object error) {
    return '삭제 실패: $error';
  }

  @override
  String get recipeSaveNotReady => '레시피 저장 기능은 준비 중입니다';

  @override
  String get baseServings => '기본 인분: ';

  @override
  String get multiplier => '배수: ';

  @override
  String get edit => '수정';

  @override
  String get copy => '복사';

  @override
  String get derivedGraph => '파생도';

  @override
  String get saveHistory => '히스토리 저장';

  @override
  String get guideDeactivated => '재료 가이드가 비활성화되었습니다';

  @override
  String get view => '보기';

  @override
  String get allIngredientsAdded => '🎉 모든 재료 투입이 완료되었습니다!';

  @override
  String get guideOn => '가이드 켜기';

  @override
  String get guideOff => '가이드 끄기';

  @override
  String get mixingStep => '믹싱';

  @override
  String get fermentationStep => '발효';

  @override
  String get ovenStep => '오븐';

  @override
  String stepInfoNotEntered(Object stepType) {
    return '$stepType 정보가 입력되지 않았습니다';
  }

  @override
  String canAddStepInEdit(Object stepType) {
    return '레시피 수정에서 $stepType 단계를 추가할 수 있습니다';
  }

  @override
  String get noInstructions => '조리법이 등록되지 않았습니다.';

  @override
  String get originalAmount => '원래';

  @override
  String get calculatedAmount => '계산됨';

  @override
  String get changeAmount => '변화';

  @override
  String get mixingStepTitle => '믹싱 단계';

  @override
  String fermentationStepTitle(Object number) {
    return '발효 단계 $number';
  }

  @override
  String get ovenStepTitle => '오븐 단계';

  @override
  String get recipeCalculator => '레시피 계산기';

  @override
  String get calculationControl => '계산 컨트롤';

  @override
  String get calculationMode => '계산 모드:';

  @override
  String get baseIngredient => '기준 재료:';

  @override
  String get runCalculation => '계산 실행';

  @override
  String get originalRecipe => '오리지널 레시피';

  @override
  String get calculationResult => '계산 결과';

  @override
  String get totalWeight => '총량';

  @override
  String get remainingWeight => '남은재료 무게';

  @override
  String get bakersPercentageComparison => '베이커스 퍼센트 비교';

  @override
  String get multiplierLabel => '배율:';

  @override
  String get calcModePercentage => '퍼센트계산';

  @override
  String get calcModeTargetSplit => '목표분할개수';

  @override
  String get timesLabel => '배';

  @override
  String get targetCountLabel => '목표 개수:';

  @override
  String get countUnit => '개';

  @override
  String get targetCountError => '목표 개수는 1개 이상이어야 합니다';

  @override
  String get noDescription => '설명 없음';

  @override
  String get mixingSpeedLow => '저속';

  @override
  String get mixingSpeedMedium => '중속';

  @override
  String get mixingSpeedHigh => '고속';

  @override
  String get mixingSpeedMax => '최고속';

  @override
  String get mixingSpeedPulse => '펄스';

  @override
  String get mixingSpeedEgg => '계란/거품';

  @override
  String get sousChefModeTitle => '수쉐프 모드';

  @override
  String get analysisTab => '분석';

  @override
  String get selectAnalysisModule => '분석 모듈 선택';

  @override
  String get breadModule => '빵 모듈';

  @override
  String get unknownModule => '알 수 없는 모듈';

  @override
  String get bakingEnvironmentConditions => '베이킹 환경 조건';

  @override
  String get altitudeLabel => '고도 (m)';

  @override
  String get seasonLabel => '계절';

  @override
  String get ovenTypeLabel => '오븐 타입';

  @override
  String get fermentationMethodLabel => '발효 방식';

  @override
  String get mixerTypeLabel => '믹서 타입';

  @override
  String get applySettings => '환경 설정 적용';

  @override
  String get applyingSettings => '적용 중...';

  @override
  String get seasonSpring => '봄';

  @override
  String get seasonSummer => '여름';

  @override
  String get seasonAutumn => '가을';

  @override
  String get seasonWinter => '겨울';

  @override
  String get ovenConvection => '대류 오븐';

  @override
  String get ovenProfessionalConvection => '전문 대류 오븐';

  @override
  String get ovenHome => '가정용 오븐';

  @override
  String get ovenConventional => '일반 오븐';

  @override
  String get ovenDeck => '데크 오븐';

  @override
  String get ovenSteam => '스팀 오븐';

  @override
  String get ovenRadiation => '복사 오븐';

  @override
  String get ovenStone => '스톤 오븐';

  @override
  String get ovenProfessional => '전문 오븐';

  @override
  String get fermentationRoomTemp => '실온 발효';

  @override
  String get fermentationFermenter => '발효기 발효';

  @override
  String get mixerHome => '가정용 믹서';

  @override
  String get mixerProfessional => '전문용 믹서';

  @override
  String get mixerCommercial => '상업용 믹서';

  @override
  String get additionalAnalysisResults => '추가 분석 결과';

  @override
  String get expectedSuccessRate => '예상 성공률';

  @override
  String get glutenOptimization => '글루텐 형성 최적화';

  @override
  String get moistureBalance => '수분 균형';

  @override
  String get temperatureStability => '온도 안정성';

  @override
  String get statusOptimal => '적정';

  @override
  String get statusGood => '양호';

  @override
  String get statusStable => '안정';

  @override
  String get fermentationStrategyRecommendation => '발효 전략 추천';

  @override
  String get mixingStepOptimization => '믹싱 단계 최적화';

  @override
  String get memoryUsage => '메모리 사용량';

  @override
  String get cacheMemory => '캐시 메모리';

  @override
  String get initializingModuleWait => '분석 모듈을 초기화하는 중입니다. 잠시 후 다시 시도해주세요.';

  @override
  String get analysisComplete => '분석이 완료되었습니다.';

  @override
  String get analysisError => '분석 중 오류가 발생했습니다.';

  @override
  String get validationError => '입력값 검증 오류';

  @override
  String get confirm => '확인';

  @override
  String get performanceSuggestions => '성능 개선 제안';

  @override
  String get optimizationHighTemp => ' (고온 최적화)';

  @override
  String get optimizationLowTemp => ' (저온 최적화)';

  @override
  String get optimizationHomeMixer => ' (가정용 믹서용 조정)';

  @override
  String get analyzing => '분석 중...';

  @override
  String get startAnalysis => '분석 시작';

  @override
  String get improvementMethodsAndRecommendations => '개선 방법 및 권장사항';

  @override
  String get runAnalysis => '분석 실행';

  @override
  String get environmentalRecommendations => '환경 조건 기반 추천';

  @override
  String stepCountLabel(Object count) {
    return '$count개 단계';
  }

  @override
  String get settingsApplied => '환경 설정이 적용되었습니다.';

  @override
  String get settingsApplyError => '환경 설정 적용 중 오류가 발생했습니다.';

  @override
  String get realTimeRecipeTitle => '실시간 레시피';

  @override
  String get refresh => '새로고침';

  @override
  String get realTimeRecipeComingSoon => '실시간 레시피가 준비 중입니다';

  @override
  String get realTimeRecipeComingSoonDesc => '곧 다양한 실시간 레시피를 만나보실 수 있습니다';

  @override
  String get loadingRealTimeRecipes => '실시간 레시피를 불러오는 중...';

  @override
  String get realTimeRecommendation => '실시간 추천';

  @override
  String get noTitle => '제목 없음';

  @override
  String get start => '시작하기';

  @override
  String get realTimeFeedback => '실시간 피드백';

  @override
  String get realTimeFeedbackComingSoon =>
      '실시간 피드백 시스템이 준비 중입니다.\n레시피 진행 중 유용한 팁과 조언을 제공해드립니다.';

  @override
  String get recommendedRecipes => '추천 레시피';

  @override
  String recipeStarted(Object title) {
    return '$title 레시피를 시작합니다!';
  }

  @override
  String recipeSaved(Object title) {
    return '$title 레시피가 저장되었습니다!';
  }

  @override
  String get initializingAnalysisEngine => '분석 엔진 초기화 중...';

  @override
  String get performingScientificCalculations => '빵 제조 과학적 단계별 계산 수행 중...';

  @override
  String get preparingMixingData => '믹싱 단계 데이터가 준비되는 중입니다...';

  @override
  String get mixingAnalysis => '믹싱 분석';

  @override
  String keyMetricsTotalMixing(Object minutes) {
    return '주요 메트릭: 총 혼합 $minutes분';
  }

  @override
  String get mixingAnalysisComplete => '믹싱 분석 완료';

  @override
  String overallScore(Object grade, Object score) {
    return '종합 점수: $score% ($grade)';
  }

  @override
  String get totalTime => '총 시간';

  @override
  String get glutenDevelopment => '글루텐 발달';

  @override
  String get moisture => '수분';

  @override
  String get doughTemperature => '반죽온도';

  @override
  String get currentStatus => '현재 상태';

  @override
  String get warning => '경고';

  @override
  String get temperatureWarning => '온도 경고';

  @override
  String stepTemperatureWarning(Object number, Object temp) {
    return '단계 $number: 반죽온도 $temp (권장: 20-30°C)';
  }

  @override
  String get mixingStepAnalysis => '믹싱 단계별 분석';

  @override
  String get analyzingMixing => '믹싱 분석 진행 중...';

  @override
  String get performingStepCalculations => '단계별 계산을 수행하고 있습니다';

  @override
  String get scientificCalculationsInProgress => '과학적 계산 진행 중...';

  @override
  String get processingAnalysisData => '분석 데이터를 처리하여 메트릭 값을 계산하고 있습니다.';

  @override
  String get fermentationAnalysis => '발효 분석';

  @override
  String get totalFermentationTime => '발효 총시간';

  @override
  String get totalCO2Generation => '총 CO₂ 생성량';

  @override
  String get totalFermentationProgress => '총 발효 진행률';

  @override
  String get fermentationStepCount => '발효 단계수';

  @override
  String get noData => '데이터 없음';

  @override
  String get fermentationPerfect => '완벽 발효';

  @override
  String get fermentationExcellent => '우수 완료';

  @override
  String get fermentationGood => '양호 완료';

  @override
  String get fermentationAverage => '보통 완료';

  @override
  String get fermentationPoor => '미흡 완료';

  @override
  String get analysisIncomplete => '분석 미완료';

  @override
  String get actualDataUnavailable => '실제 데이터를 사용할 수 없음';

  @override
  String completedStep(Object number) {
    return '완료 단계 $number';
  }

  @override
  String stepNumber(Object number) {
    return '단계 $number';
  }

  @override
  String timeMinutes(Object minutes) {
    return '시간: $minutes분';
  }

  @override
  String get progress => '진행률';

  @override
  String get maillardReaction => '마이야르';

  @override
  String get crumb => '크럼브';

  @override
  String get internalTemperature => '내부온도';

  @override
  String get bakingComplete => '베이킹 완료!';

  @override
  String get bakingAnalysis => '오븐 베이킹 분석';

  @override
  String get waitingForFermentationAnalysis => '발효 분석 완료 후 베이킹 분석을 진행합니다...';

  @override
  String get totalBakingTime => '총 베이킹 시간';

  @override
  String get totalMaillardReaction => '총 마이야르 반응';

  @override
  String get averageInternalTemperature => '평균 내부 온도';

  @override
  String get bakingStepCount => '베이킹 단계수';

  @override
  String get crustColor => '크러스트 색상';

  @override
  String get crumbBakingProgress => '크럼브 진행률';

  @override
  String get crustColorDarkBrown => '진한 갈색';

  @override
  String get crustColorBrown => '갈색';

  @override
  String get crustColorLightBrown => '연한 갈색';

  @override
  String get crustColorGolden => '금빛';

  @override
  String get crustColorLightIvory => '연한 아이보리색';

  @override
  String get preparingBakingStepData => '오븐 베이킹 단계별 분석 데이터 준비 중...';

  @override
  String get bakingStepAnalysis => '오븐 베이킹 단계별 분석';

  @override
  String stepProgress(Object completed, Object total) {
    return '$completed/$total단계';
  }

  @override
  String get scientificBakingCalculationsInProgress => '빵 제조 과학적 계산 진행 중...';

  @override
  String get performingScientificBakingCalculations =>
      '빵 제조 과학적 베이킹 계산 수행 중...';

  @override
  String get performanceMonitoring => '성능 모니터링';

  @override
  String get analysisDuration => '분석 소요 시간';

  @override
  String get cachePerformance => '캐시 성능';

  @override
  String get totalEntries => '총 항목';

  @override
  String get expiredEntries => '만료 항목';

  @override
  String get hitRate => '적중률';

  @override
  String get successRateStatistics => '성공률 통계';

  @override
  String get lowTempWarning => '온도가 낮아 발효 시간이 길어질 수 있습니다. 따뜻한 곳으로 이동하세요.';

  @override
  String get highTempWarning => '온도가 높아 과발효 위험이 있습니다. 서늘한 곳으로 이동하세요.';

  @override
  String get lowHumidityWarning => '습도가 낮아 빵이 건조해질 수 있습니다. 물을 가까이 두세요.';

  @override
  String get highHumidityWarning => '습도가 높아 빵이 무거워질 수 있습니다. 통풍이 잘 되는 곳을 확인하세요.';

  @override
  String get winterRecommendation => '겨울에는 발효 시간을 20-30% 늘리는 것이 좋습니다.';

  @override
  String get summerRecommendation => '여름에는 발효 시간을 10-20% 줄이는 것이 좋습니다.';

  @override
  String get optimalEnvironmentMessage => '현재 환경 조건이 빵 베이킹에 적합합니다.';

  @override
  String get coldFermentationStrategy => '저온 발효 전략';

  @override
  String get coldFermentationDesc => '현재 온도가 낮아 장시간 발효가 필요합니다.';

  @override
  String get coldFermentationBenefit1 => '풍미 향상';

  @override
  String get coldFermentationBenefit2 => '산패 억제';

  @override
  String get coldFermentationBenefit3 => '글루텐 구조 강화';

  @override
  String get warmFermentationStrategy => '고온 발효 전략';

  @override
  String get warmFermentationDesc => '현재 온도가 높아 빠른 발효가 진행됩니다.';

  @override
  String get warmFermentationBenefit1 => '시간 절약';

  @override
  String get warmFermentationBenefit2 => '효율적인 생산';

  @override
  String get warmFermentationBenefit3 => '빠른 결과 확인';

  @override
  String get standardFermentationStrategy => '표준 발효 전략';

  @override
  String get standardFermentationDesc => '현재 환경이 표준 발효에 최적입니다.';

  @override
  String get standardFermentationBenefit1 => '안정적인 결과';

  @override
  String get standardFermentationBenefit2 => '예측 가능한 품질';

  @override
  String get standardFermentationBenefit3 => '쉬운 관리';

  @override
  String get largeCacheSuggestion => '캐시 크기가 큽니다. 불필요한 캐시를 정리해보세요.';

  @override
  String get increaseCacheSuggestion => '캐시 활용을 늘리면 성능이 향상될 수 있습니다.';

  @override
  String get longAnalysisTimeSuggestion => '분석 시간이 길어집니다. 캐시 활용을 늘려보세요.';

  @override
  String get fastAnalysisSuggestion => '매우 빠른 분석 속도! 최적화가 잘 되고 있습니다.';

  @override
  String get optimizedPerformanceMessage => '현재 성능이 최적화되어 있습니다.';

  @override
  String unitHours(Object count) {
    return '$count시간';
  }

  @override
  String unitMinutes(Object count) {
    return '$count분';
  }

  @override
  String stepCount(Object count) {
    return '$count단계';
  }

  @override
  String get mixinAnalysisTitle => '믹싱 단계별 분석';

  @override
  String get fermentationAnalysisTitle => '발효 단계';

  @override
  String get bakingAnalysisTitle => '오븐 베이킹 단계별 분석';

  @override
  String get analyzingScientificCalculations => '빵 제조 과학적 계산 진행 중...';

  @override
  String stepLabelWithNumber(Object number) {
    return '단계 $number';
  }

  @override
  String get preparingAnalysisData => '...데이터 준비 중';

  @override
  String mixingStepDefaultTitle(Object number) {
    return '믹싱 단계 $number';
  }

  @override
  String speedAndDuration(Object duration, Object speed) {
    return '$speed · $duration분';
  }

  @override
  String get glutenFormationLabel => '글루텐 형성';

  @override
  String get calculatingLabel => '계산 중...';

  @override
  String get detailedMetricsLabel => '상세 메트릭';

  @override
  String get moistureAbsorptionLabel => '수분 흡수율';

  @override
  String optimalRangeLabel(Object max, Object min) {
    return '적정 범위: $min-$max';
  }

  @override
  String optimalRangeLabelPercent(Object max, Object min) {
    return '적정 범위: $min-$max%';
  }

  @override
  String optimalRangeLabelTemp(Object max, Object min) {
    return '적정 범위: $min-$max°C';
  }

  @override
  String get viscosityLabel => '점도';

  @override
  String get rpmLabel => 'RPM';

  @override
  String get rotationSpeedLabel => '회전 속도';

  @override
  String get observedPhenomenaLabel => '관측 현상';

  @override
  String get unknownValue => '알 수 없음';

  @override
  String get errorValue => '오류';

  @override
  String fermentationStepPrefix(Object number) {
    return '$number차 발효';
  }

  @override
  String get mainMetricsTitle => '주요 메트릭';

  @override
  String get co2GenerationLabel => 'CO₂ 생성량';

  @override
  String get volumeExpansionLabel => '부피 팽창';

  @override
  String get fermentationProgressLabel => '발효 진행';

  @override
  String get acidityLabel => '산도';

  @override
  String get scoreGradeExcellent => '최상급';

  @override
  String get scoreGradeGood => '우수';

  @override
  String get scoreGradeFair => '양호';

  @override
  String get scoreGradeAverage => '보통';

  @override
  String get scoreGradePoor => '개선 필요';

  @override
  String stepLabelText(Object number) {
    return '단계 $number';
  }

  @override
  String get measuringTemperature => '측정 중...';

  @override
  String mixingStepTitleLabel(Object number) {
    return '믹싱 단계 $number';
  }

  @override
  String get keyMetricsTitle => '주요 메트릭';

  @override
  String get doughDevelopmentLabel => '🌾 반죽 발달';

  @override
  String get moistureAbsorptionRateLabel => '💧 수분 흡수율';

  @override
  String get doughTemperatureLabel => '🌡️ 반죽 온도';

  @override
  String get doughTextureLabel => '⚡ 반죽 질감';

  @override
  String get calculationError => '계산 오류';

  @override
  String get calculating => '계산 중...';

  @override
  String get measuring => '측정 중...';

  @override
  String get ingredientsMixing => '재료 혼합중';
}
