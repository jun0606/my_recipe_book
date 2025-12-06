// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get recipeBookTitle => '私のレシピブック';

  @override
  String get noRecipes => 'レシピがありません。';

  @override
  String get categoryList => 'カテゴリ一覧';

  @override
  String get noCategories => 'カテゴリーがありません';

  @override
  String cannotDeleteCategoryWithRecipes(Object category) {
    return '$category カテゴリにレシピがあるため削除できません。';
  }

  @override
  String categoryDeleted(Object category) {
    return '$category カテゴリが削除されました。';
  }

  @override
  String categoryDeletionFailed(Object error) {
    return 'カテゴリ削除失敗: $error';
  }

  @override
  String get welcomeMessage => 'My Recipe Bookへようこそ！';

  @override
  String get startCookingJourney => 'おいしい料理の旅を始めましょう！';

  @override
  String get recipeBookSettings => 'レシピブック設定';

  @override
  String get nameLabel => '名前';

  @override
  String get nameRequired => '名前を入力してください';

  @override
  String get titleLabel => '称号';

  @override
  String get chef => 'シェフ';

  @override
  String get cook => '料理人';

  @override
  String get baker => 'ベーカー';

  @override
  String get kitchenMaster => 'キッチンマスター';

  @override
  String get startCooking => '料理を始める';

  @override
  String get user => 'ユーザー';

  @override
  String addRecipePrompt(Object category) {
    return '$category レシピを追加してください！';
  }

  @override
  String get addRecipe => 'レシピ追加';

  @override
  String get searchRecipe => 'レシピ検索';

  @override
  String get settings => '設定';

  @override
  String get addRecipeTitle => 'レシピ追加';

  @override
  String get editRecipeTitle => 'レシピ編集';

  @override
  String get recipeTitleLabel => 'レシピタイトル';

  @override
  String get recipeTitleRequired => 'レシピタイトルを入力してください';

  @override
  String get categoryLabel => 'カテゴリー';

  @override
  String get ingredientNameLabel => '材料名';

  @override
  String get ingredientAmountLabel => '材料量';

  @override
  String get amountGreaterThanZero => '量は0より大きくしてください。';

  @override
  String get invalidAmount => '材料の量は有効な数値で入力してください。';

  @override
  String get unitSystemLabel => '単位体系';

  @override
  String get unitLabel => '単位';

  @override
  String get addIngredient => '材料追加';

  @override
  String get instructionsLabel => '作り方';

  @override
  String get instructionsRequired => '作り方を入力してください';

  @override
  String servings(Object servings) {
    return '$servings人前';
  }

  @override
  String get noPhoto => '写真なし';

  @override
  String get uploadPhoto => '写真アップロード';

  @override
  String get ingredientUnitInstructionEdit => '材料、単位、作り方編集';

  @override
  String get saveRecipe => 'レシピ保存';

  @override
  String get editRecipe => 'レシピ編集';

  @override
  String saveRecipeFailed(Object error) {
    return 'レシピ保存失敗: $error';
  }

  @override
  String recipeTitle(Object title) {
    return 'レシピ: $title';
  }

  @override
  String category(Object category) {
    return 'カテゴリー: $category';
  }

  @override
  String get ingredientsLabel => '材料:';

  @override
  String get editHistory => '編集履歴:';

  @override
  String get noHistory => '履歴がありません。';

  @override
  String get updateHistory => '履歴更新';

  @override
  String loadHistoryFailed(Object error) {
    return '履歴ロード失敗: $error';
  }

  @override
  String get shareExcel => 'エクセルで共有';

  @override
  String exportExcelFailed(Object error) {
    return 'エクセル作成失敗: $error';
  }

  @override
  String get sharePdf => 'PDFで共有';

  @override
  String exportPdfFailed(Object error) {
    return 'PDF作成失敗: $error';
  }

  @override
  String get userInfo => 'ユーザー情報';

  @override
  String get updateUserInfo => 'ユーザー情報更新';

  @override
  String loadUserInfoFailed(Object error) {
    return 'ユーザー情報ロード失敗: $error';
  }

  @override
  String get userInfoUpdated => 'ユーザー情報が更新されました。';

  @override
  String saveUserInfoFailed(Object error) {
    return 'ユーザー情報保存失敗: $error';
  }

  @override
  String get defaultUnitSystem => '基本単位体系';

  @override
  String get categoryManagement => 'カテゴリー管理';

  @override
  String get addNewCategory => '新カテゴリー追加';

  @override
  String get categoryAdded => 'カテゴリーが追加されました！';

  @override
  String addCategoryFailed(Object error) {
    return 'カテゴリー追加失敗: $error';
  }

  @override
  String get enterValidCategoryName => '有効なカテゴリー名を入力してください。';

  @override
  String get recipeManagement => 'レシピ管理';

  @override
  String get deleteRecipe => 'レシピ削除';

  @override
  String confirmDeleteRecipe(Object title) {
    return '$title レシピを削除しますか？';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get recipeDeleted => 'レシピが削除されました';

  @override
  String deleteRecipeFailed(Object error) {
    return 'レシピ削除失敗: $error';
  }

  @override
  String get save => '保存';

  @override
  String greeting(Object name, Object title) {
    return 'こんにちは、$title $nameさん！';
  }

  @override
  String get languageSelectionLabel => '言語選択';

  @override
  String get setupScreenTitle => '私のレシピブック設定';

  @override
  String get titleSelectionLabel => '称号選択';

  @override
  String get pastryChef => 'パティシエ';

  @override
  String get gourmet => '美食家';

  @override
  String get foodie => '食いしん坊';

  @override
  String get culinaryResearcher => '料理研究家';

  @override
  String get honorificNim => '様';

  @override
  String get honorificSsi => 'さん';

  @override
  String get resetUserNameAndTitle => '名前と称号をリセット';

  @override
  String get unitSystemSelectionLabel => '単位システムを選択';

  @override
  String get saveSettings => '設定を保存';

  @override
  String get newCategoryNameLabel => '新しいカテゴリ名';

  @override
  String get add => '追加';

  @override
  String get deleteCategory => 'カテゴリを削除';

  @override
  String confirmDeleteCategory(Object category) {
    return '\"$category\" カテゴリを削除しますか？このカテゴリにレシピが含まれていない必要があります。';
  }

  @override
  String get dataManagement => 'データ管理';

  @override
  String get backupAllRecipes => 'すべてのレシピをバックアップ';

  @override
  String get restoreRecipes => 'レシピを復元';

  @override
  String get deleteAllRecipes => 'すべてのレシピを削除';

  @override
  String get deleteAllRecipesTitle => 'すべてのレシピを削除';

  @override
  String get confirmDeleteAllRecipes => '本当にすべてのレシピを削除しますか？この操作は元に戻せません。';

  @override
  String get resetUserNameAndTitleTitle => '名前と称号をリセット';

  @override
  String get confirmResetUserNameAndTitle =>
      '本当に名前と称号をリセットしますか？リセット後、アプリを再起動するとユーザー設定画面に移動します。';

  @override
  String get reset => 'リセット';

  @override
  String get settingsSaved => '設定が保存されました。';

  @override
  String recipesBackedUp(Object filePath) {
    return 'すべてのレシピが次のパスにバックアップされました: $filePath';
  }

  @override
  String get shareBackupFile => '私のレシピブックのバックアップファイルを共有します。';

  @override
  String recipeBackupFailed(Object error) {
    return 'レシピのバックアップに失敗しました: $error';
  }

  @override
  String get recipesRestored => 'レシピが正常に復元されました。';

  @override
  String get fileSelectionCancelled => 'ファイル選択がキャンセルされました。';

  @override
  String recipeRestoreFailed(Object error) {
    return 'レシピの復元に失敗しました: $error';
  }

  @override
  String get allRecipesDeleted => 'すべてのレシピが削除されました。';

  @override
  String get userNameAndTitleReset => '名前と称号がリセットされました。アプリを再起動します。';

  @override
  String get textScaleSettings => 'テキストサイズ設定';

  @override
  String get useSystemTextScale => 'システムのテキストサイズ設定を使用';

  @override
  String get followDeviceAccessibility => 'デバイスのアクセシビリティ設定に従います';

  @override
  String get textScaleAdjustment => 'テキストサイズ調整';

  @override
  String currentSize(Object size) {
    return '現在のサイズ: $size%';
  }

  @override
  String get preview => 'プレビュー';

  @override
  String get previewBodyText => 'これは本文テキストの例です。レシピの内容や説明はこのサイズで表示されます。';

  @override
  String get previewSmallText => '小さいテキストの例です。';

  @override
  String get sizeSmall => '小';

  @override
  String get sizeNormal => '標準';

  @override
  String get sizeLarge => '大';

  @override
  String get sizeVeryLarge => '特大';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get textScaleHelp =>
      '• システム設定を使用すると、デバイスのアクセシビリティ設定が適用されます。\n• カスタム設定を使用すると、アプリ内でのみテキストサイズが調整されます。\n• 両方の設定を一緒に使用することもできます。';

  @override
  String permissionRequired(Object feature) {
    return '$feature 権限が必要';
  }

  @override
  String permissionRequiredMessage(Object feature) {
    return '$feature 権限が必要です。許可しますか？';
  }

  @override
  String permissionPermanentlyDenied(Object feature) {
    return '$feature 権限が必要です。設定 > プライバシー > $feature で権限を許可してください。';
  }

  @override
  String get requestPermission => '権限をリクエスト';

  @override
  String get goToSettings => '設定へ移動';

  @override
  String get cameraFeature => 'カメラ';

  @override
  String get galleryAccessFeature => 'ギャラリーアクセス';

  @override
  String get photosFeature => 'フォトライブラリ';

  @override
  String get derivedRecipeSave => '派生レシピを保存';

  @override
  String get recipeCopy => 'レシピをコピー';

  @override
  String get recipeModify => 'レシピを編集';

  @override
  String get recipeImageUpload => '写真をアップロード';

  @override
  String get recipeImageCamera => 'カメラで撮影';

  @override
  String get selectFromGallery => 'ギャラリーから選択';

  @override
  String get takeWithCamera => 'カメラで撮影';

  @override
  String get bakingModeActivate => 'ベーキングモードをアクティブ化';

  @override
  String get servingsInput => '人前';

  @override
  String get servingsRequired => '人前を入力してください';

  @override
  String get validServingsRequired => '有効な人前の数を入力してください';

  @override
  String get splitWeight => '分割重量';

  @override
  String get splitCount => '分割数';

  @override
  String get splitWeightOrCountRequired => '分割重量または分割個数を入力してください';

  @override
  String get validSplitWeightRequired => '有効な分割重量を入力してください';

  @override
  String get validSplitCountRequired => '有効な分割個数を入力してください';

  @override
  String splitWeightExceedsTotal(Object total) {
    return '分割重量は総材料重量を超えることはできません。（合計: ${total}g）';
  }

  @override
  String eachWeight(Object unit, Object weight) {
    return '各 $weight$unit ずつ';
  }

  @override
  String totalSplits(Object count, Object remaining, Object unit) {
    return '合計 $count個に分割可能（残り: $remaining$unit）';
  }

  @override
  String get resetInput => '入力値をリセット';

  @override
  String get ingredients => '材料';

  @override
  String get ingredientName => '材料名';

  @override
  String get ingredientEdit => '材料を編集';

  @override
  String get ingredientAmount => '量';

  @override
  String get validIngredientRequired => '有効な材料名と量を入力してください。';

  @override
  String get validAmountRequired => '有効な材料の量を入力してください。';

  @override
  String get ingredientNameAndAmountRequired => '材料名と量の両方を入力してください。';

  @override
  String get copyLabel => ' (コピー)';

  @override
  String get derivedLabel => ' (派生)';

  @override
  String get recipeGenealogy => 'レシピ系譜';

  @override
  String get retryAction => '再試行';

  @override
  String get goBackAction => '戻る';

  @override
  String get favoritePresets => 'お気に入りプリセット';

  @override
  String get addCustomPreset => 'カスタムプリセットを追加';

  @override
  String get exportAction => 'エクスポート';

  @override
  String get importAction => 'インポート';

  @override
  String get cleanupAction => '整理';

  @override
  String get useAction => '使用';

  @override
  String get editAction => '編集';

  @override
  String get duplicateAction => '複製';

  @override
  String get noPresetsAvailable => '保存されたプリセットがありません。';

  @override
  String get addFirstPreset => '最初のプリセットを追加しましょう！';

  @override
  String get languageSelection => '言語選択';

  @override
  String get titleSelection => '称号選択';

  @override
  String get unitSelection => '単位';

  @override
  String get editIngredientTitle => '材料を編集';

  @override
  String get recipeTitleInput => 'レシピタイトル';

  @override
  String get categoryInput => 'カテゴリー';

  @override
  String get servingsLabel => '人前';

  @override
  String get splitWeightLabel => '分割重量';

  @override
  String get splitCountLabel => '分割個数';

  @override
  String get temperatureLabel => '温度 (°C)';

  @override
  String get timeMinutesLabel => '時間 (分)';

  @override
  String get humidityLabel => '湿度 (%)';

  @override
  String get speedLabel => '速度';

  @override
  String stepNumberLabel(Object number) {
    return 'ステップ $number';
  }

  @override
  String get enterValidIngredientAmount => '有効な材料の量を入力してください。';

  @override
  String get enterIngredientNameAndAmount => '材料名と量の両方を入力してください。';

  @override
  String get writeAllInstructionSteps => 'すべての調理手順を記入してください。';

  @override
  String get addAtLeastOneIngredient => '少なくとも1つの材料を追加してください。';

  @override
  String get recipeModified => 'レシピが変更されました。';

  @override
  String recipeModifyError(Object error) {
    return 'レシピ変更中にエラーが発生しました: $error';
  }

  @override
  String recipeSaveError(Object error) {
    return 'レシピ保存中にエラーが発生しました: $error';
  }

  @override
  String get backupFileShare => 'バックアップファイルを共有';

  @override
  String get backupCancelled => 'バックアップがキャンセルされました';

  @override
  String get favoritesTab => 'お気に入り';

  @override
  String get statisticsTab => '統計';

  @override
  String get recommendationsTab => 'おすすめ';

  @override
  String get sortBy => '並び替え';

  @override
  String get deleteFavorite => 'お気に入りを削除';

  @override
  String get confirmText => '確認';

  @override
  String get errorTitle => 'エラー';

  @override
  String get infoTitle => '情報';

  @override
  String successCases(Object count) {
    return '成功事例: $count回';
  }

  @override
  String averageImprovement(Object percent) {
    return '平均改善度: $percent%';
  }

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get noPerformanceData => 'まだ成果データがありません。';

  @override
  String successRate(Object percent) {
    return '成功率: $percent%';
  }

  @override
  String get noUsageData => 'まだ使用データがありません。';

  @override
  String get recipeHistory => 'レシピ履歴';

  @override
  String get deleteAllAction => '全削除';

  @override
  String get improvementLabel => '改善度: ';

  @override
  String get improvementPrefix => '改善: ';

  @override
  String get notEnoughImprovementData => 'まだ改善データが不足しています。';

  @override
  String get closeAction => '閉じる';

  @override
  String get deleteAllTitle => '全削除';

  @override
  String get confirmDeleteAllHistory => 'すべての履歴を削除しますか?\nこの操作は元に戻せません。';

  @override
  String get userGuide => 'ユーザーガイド';

  @override
  String get initializingGuideSystem => 'ガイドシステムを初期化中...';

  @override
  String get shareAction => '共有';

  @override
  String get completeAction => '完了';

  @override
  String get guideCompleted => 'ガイドが完了しました！';

  @override
  String get fermenterSettingGuide => '発酵機設定ガイド';

  @override
  String get fermenterSettingGuideDesc => '新しい発酵機設定のステップバイステップガイド';

  @override
  String get troubleshootingGuide => 'トラブルシューティングガイド';

  @override
  String get guideShareFeatureComingSoon => 'ガイド共有機能は準備中です';

  @override
  String get guideExportFeatureComingSoon => 'ガイドエクスポート機能は準備中です';

  @override
  String get fermenterGuideComingSoon => '発酵機ガイド作成機能は準備中です';

  @override
  String get troubleshootingGuideComingSoon => 'トラブルシューティングガイド作成機能は準備中です';

  @override
  String get overallStatistics => '全体統計';

  @override
  String get topPerformers => 'トップパフォーマー';

  @override
  String get mostUsedPresets => 'よく使用するプリセット';

  @override
  String get categoryDistribution => 'カテゴリー別分布';

  @override
  String get totalFavorites => '合計お気に入り';

  @override
  String get customPresets => 'カスタム';

  @override
  String get averageSuccessRate => '平均成功率';

  @override
  String get averageImprovementScore => '平均改善度';

  @override
  String get recommendedEnvironment => '推奨環境条件';

  @override
  String get temperatureShort => '温度';

  @override
  String get humidityShort => '湿度';

  @override
  String get altitudeShort => '高度';

  @override
  String get recentlyUsed => '最近使用';

  @override
  String get noFavoritesYet => 'まだお気に入りがありません';

  @override
  String get addPresetInSousChef => 'スーシェフモードでプリセットをお気に入りに追加してください';

  @override
  String get noRecommendationsYet => 'まだおすすめがありません';

  @override
  String get useMoreForRecommendations =>
      'スーシェフモードをもっと使用すると、パーソナライズされたおすすめが表示されます';

  @override
  String confidenceLabel(Object percent) {
    return '信頼度 $percent%';
  }

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get close => '閉じる';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get complete => '完了';

  @override
  String get addStep => 'ステップを追加';

  @override
  String get simpleCopy => '単純コピー';

  @override
  String get derivedRecipe => '派生レシピ';

  @override
  String get recipeEdit => 'レシピを編集';

  @override
  String get sousChefMode => 'スーシェフモード';

  @override
  String get historyTooltip => '履歴';

  @override
  String get korean => '韓国語';

  @override
  String get autoSave => '自動保存';

  @override
  String get textSizeSettingsTooltip => 'テキストサイズ設定';

  @override
  String get enterTitle => 'タイトルを入力してください';

  @override
  String get hintOvenCondition => '例: 表面が黄金色になるまで';

  @override
  String get hintFermentCondition => '例: 生地が2倍に膨らむまで';

  @override
  String get hintMixCondition => '例: 生地が滑らかになるまで';

  @override
  String get sortTooltip => '並び替え';

  @override
  String get filterTooltip => 'フィルター';

  @override
  String get refreshTooltip => '更新';

  @override
  String get quickGuideTooltip => 'クイックガイド';

  @override
  String get cannotLoadComparisonData => 'レシピ比較データを読み込めません';

  @override
  String get copyRecipeTitle => 'レシピコピー';

  @override
  String get saveDerivedRecipeTitle => '派生レシピ保存';

  @override
  String get ingredientsSectionTitle => '材料';

  @override
  String get instructionsSectionTitle => '作り方';

  @override
  String get enterInstruction => '作り方を入力してください';

  @override
  String stepLabel(Object number) {
    return 'ステップ $number';
  }

  @override
  String stepCommentLabel(Object number) {
    return 'ステップ $number コメント (任意)';
  }

  @override
  String get addOvenStepMessage => 'オーブンのステップを追加してください';

  @override
  String get addFermentationStepMessage => '発酵のステップを追加してください';

  @override
  String get addMixingStepMessage => 'ミキシングのステップを追加してください';

  @override
  String get addOvenStepExample => '例: 180°C 40分 → 200°C 20分';

  @override
  String get addFermentationStepExample => '例: 1次発酵 80% 240分 → 2次発酵 85% 120分';

  @override
  String get addMixingStepExample => '例: 中速 15分 → 低速 10分';

  @override
  String sousChefModeError(Object error) {
    return 'スーシェフモードを開始できません: $error';
  }

  @override
  String get copyRecipeMethodTitle => 'レシピコピー方法の選択';

  @override
  String get copyRecipeMethodContent => 'どのようにコピーしますか？';

  @override
  String get deleteRecipeTitle => 'レシピ削除';

  @override
  String deleteRecipeContent(Object title) {
    return '$title レシピを削除しますか？';
  }

  @override
  String deleteFailed(Object error) {
    return '削除失敗: $error';
  }

  @override
  String get recipeSaveNotReady => 'レシピ保存機能は準備中です';

  @override
  String get baseServings => '基本人数: ';

  @override
  String get multiplier => '倍率: ';

  @override
  String get edit => '編集';

  @override
  String get copy => 'コピー';

  @override
  String get derivedGraph => '派生図';

  @override
  String get saveHistory => '履歴保存';

  @override
  String get guideDeactivated => '材料ガイドが無効になりました';

  @override
  String get view => '表示';

  @override
  String get allIngredientsAdded => '🎉 すべての材料が追加されました！';

  @override
  String get guideOn => 'ガイド開始';

  @override
  String get guideOff => 'ガイド終了';

  @override
  String get mixingStep => 'ミキシング';

  @override
  String get fermentationStep => '発酵';

  @override
  String get ovenStep => 'オーブン';

  @override
  String stepInfoNotEntered(Object stepType) {
    return '$stepType 情報が入力されていません';
  }

  @override
  String canAddStepInEdit(Object stepType) {
    return 'レシピ編集で $stepType ステップを追加できます';
  }

  @override
  String get noInstructions => '作り方が登録されていません。';

  @override
  String get originalAmount => '元';

  @override
  String get calculatedAmount => '計算後';

  @override
  String get changeAmount => '変化';

  @override
  String get mixingStepTitle => 'ミキシングステップ';

  @override
  String fermentationStepTitle(Object number) {
    return '発酵段階 $number';
  }

  @override
  String get ovenStepTitle => 'オーブンステップ';

  @override
  String get recipeCalculator => 'レシピ計算機';

  @override
  String get calculationControl => '計算コントロール';

  @override
  String get calculationMode => '計算モード:';

  @override
  String get baseIngredient => '基準材料:';

  @override
  String get runCalculation => '計算実行';

  @override
  String get originalRecipe => 'オリジナルレシピ';

  @override
  String get calculationResult => '計算結果';

  @override
  String get totalWeight => '総量';

  @override
  String get remainingWeight => '残り重量';

  @override
  String get bakersPercentageComparison => 'ベーカーズパーセント比較';

  @override
  String get multiplierLabel => '倍率:';

  @override
  String get calcModePercentage => 'パーセント計算';

  @override
  String get calcModeTargetSplit => '目標分割数';

  @override
  String get timesLabel => '倍';

  @override
  String get targetCountLabel => '目標数:';

  @override
  String get countUnit => '個';

  @override
  String get targetCountError => '目標数は1個以上である必要があります';

  @override
  String get noDescription => '説明なし';

  @override
  String get mixingSpeedLow => '低速';

  @override
  String get mixingSpeedMedium => '中速';

  @override
  String get mixingSpeedHigh => '高速';

  @override
  String get mixingSpeedMax => '最高速';

  @override
  String get mixingSpeedPulse => 'パルス';

  @override
  String get mixingSpeedEgg => '卵/泡';

  @override
  String get sousChefModeTitle => 'スーシェフモード';

  @override
  String get analysisTab => '分析';

  @override
  String get selectAnalysisModule => '分析モジュール選択';

  @override
  String get breadModule => 'パンモジュール';

  @override
  String get unknownModule => '不明なモジュール';

  @override
  String get bakingEnvironmentConditions => 'ベーキング環境条件';

  @override
  String get altitudeLabel => '高度 (m)';

  @override
  String get seasonLabel => '季節';

  @override
  String get ovenTypeLabel => 'オーブンタイプ';

  @override
  String get fermentationMethodLabel => '発酵方法';

  @override
  String get mixerTypeLabel => 'ミキサータイプ';

  @override
  String get applySettings => '設定を適用';

  @override
  String get applyingSettings => '適用中...';

  @override
  String get seasonSpring => '春';

  @override
  String get seasonSummer => '夏';

  @override
  String get seasonAutumn => '秋';

  @override
  String get seasonWinter => '冬';

  @override
  String get ovenConvection => 'コンベクションオーブン';

  @override
  String get ovenProfessionalConvection => 'プロ用コンベクション';

  @override
  String get ovenHome => '家庭用オーブン';

  @override
  String get ovenConventional => '従来型オーブン';

  @override
  String get ovenDeck => 'デッキオーブン';

  @override
  String get ovenSteam => 'スチームオーブン';

  @override
  String get ovenRadiation => '放射オーブン';

  @override
  String get ovenStone => '石窯オーブン';

  @override
  String get ovenProfessional => 'プロ用オーブン';

  @override
  String get fermentationRoomTemp => '室温発酵';

  @override
  String get fermentationFermenter => '発酵機';

  @override
  String get mixerHome => '家庭用ミキサー';

  @override
  String get mixerProfessional => 'プロ用ミキサー';

  @override
  String get mixerCommercial => '業務用ミキサー';

  @override
  String get additionalAnalysisResults => '追加分析結果';

  @override
  String get expectedSuccessRate => '予想成功率';

  @override
  String get glutenOptimization => 'グルテン形成最適化';

  @override
  String get moistureBalance => '水分バランス';

  @override
  String get temperatureStability => '温度安定性';

  @override
  String get statusOptimal => '適正';

  @override
  String get statusGood => '良好';

  @override
  String get statusStable => '安定';

  @override
  String get fermentationStrategyRecommendation => '発酵戦略推奨';

  @override
  String get mixingStepOptimization => 'ミキシング段階最適化';

  @override
  String get memoryUsage => 'メモリ使用量';

  @override
  String get cacheMemory => 'キャッシュメモリ';

  @override
  String get initializingModuleWait => '分析モジュールを初期化中です。しばらくしてからもう一度お試しください。';

  @override
  String get analysisComplete => '分析が完了しました。';

  @override
  String get analysisError => '分析中にエラーが発生しました。';

  @override
  String get validationError => '入力値検証エラー';

  @override
  String get confirm => '確認';

  @override
  String get performanceSuggestions => 'パフォーマンス改善提案';

  @override
  String get optimizationHighTemp => ' (高温最適化)';

  @override
  String get optimizationLowTemp => ' (低温最適化)';

  @override
  String get optimizationHomeMixer => ' (家庭用ミキサー調整)';

  @override
  String get analyzing => '分析中...';

  @override
  String get startAnalysis => '分析開始';

  @override
  String get improvementMethodsAndRecommendations => '改善方法および推奨事項';

  @override
  String get runAnalysis => '分析実行';

  @override
  String get environmentalRecommendations => '環境条件に基づく推奨';

  @override
  String stepCountLabel(Object count) {
    return '$count段階';
  }

  @override
  String get settingsApplied => '環境設定が適用されました。';

  @override
  String get settingsApplyError => '環境設定の適用中にエラーが発生しました。';

  @override
  String get realTimeRecipeTitle => 'リアルタイムレシピ';

  @override
  String get refresh => '更新';

  @override
  String get realTimeRecipeComingSoon => 'リアルタイムレシピは準備中です';

  @override
  String get realTimeRecipeComingSoonDesc => 'まもなく様々なリアルタイムレシピをご覧いただけます';

  @override
  String get loadingRealTimeRecipes => 'リアルタイムレシピを読み込み中...';

  @override
  String get realTimeRecommendation => 'リアルタイム推奨';

  @override
  String get noTitle => 'タイトルなし';

  @override
  String get start => '開始';

  @override
  String get realTimeFeedback => 'リアルタイムフィードバック';

  @override
  String get realTimeFeedbackComingSoon =>
      'リアルタイムフィードバックシステムは準備中です。\nレシピ進行中に役立つヒントやアドバイスを提供します。';

  @override
  String get recommendedRecipes => 'おすすめレシピ';

  @override
  String recipeStarted(Object title) {
    return '$title レシピを開始します！';
  }

  @override
  String recipeSaved(Object title) {
    return '$title レシピが保存されました！';
  }

  @override
  String get initializingAnalysisEngine => '分析エンジンを初期化中...';

  @override
  String get performingScientificCalculations => 'パン製造の科学的段階別計算を実行中...';

  @override
  String get preparingMixingData => 'ミキシング段階データを準備中...';

  @override
  String get mixingAnalysis => 'ミキシング分析';

  @override
  String keyMetricsTotalMixing(Object minutes) {
    return '主要指標: 総ミキシング $minutes分';
  }

  @override
  String get mixingAnalysisComplete => 'ミキシング分析完了';

  @override
  String overallScore(Object grade, Object score) {
    return '総合スコア: $score% ($grade)';
  }

  @override
  String get totalTime => '総時間';

  @override
  String get glutenDevelopment => 'グルテン発達';

  @override
  String get moisture => '水分';

  @override
  String get doughTemperature => '生地温度';

  @override
  String get currentStatus => '現在の状態';

  @override
  String get warning => '警告';

  @override
  String get temperatureWarning => '温度警告';

  @override
  String stepTemperatureWarning(Object number, Object temp) {
    return '段階 $number: 生地温度 $temp (推奨: 20-30°C)';
  }

  @override
  String get mixingStepAnalysis => 'ミキシング段階別分析';

  @override
  String get analyzingMixing => 'ミキシング分析進行中...';

  @override
  String get performingStepCalculations => '段階別計算を実行しています';

  @override
  String get scientificCalculationsInProgress => '科学的計算進行中...';

  @override
  String get processingAnalysisData => '分析データを処理してメトリクス値を計算しています。';

  @override
  String get fermentationAnalysis => '発酵分析';

  @override
  String get totalFermentationTime => '発酵総時間';

  @override
  String get totalCO2Generation => '総CO₂生成量';

  @override
  String get totalFermentationProgress => '総発酵進行率';

  @override
  String get fermentationStepCount => '発酵段階数';

  @override
  String get noData => 'データなし';

  @override
  String get fermentationPerfect => '完璧な発酵';

  @override
  String get fermentationExcellent => '優秀完了';

  @override
  String get fermentationGood => '良好完了';

  @override
  String get fermentationAverage => '普通完了';

  @override
  String get fermentationPoor => '不十分完了';

  @override
  String get analysisIncomplete => '分析未完了';

  @override
  String get actualDataUnavailable => '実際のデータを使用できません';

  @override
  String completedStep(Object number) {
    return '完了段階 $number';
  }

  @override
  String stepNumber(Object number) {
    return '段階 $number';
  }

  @override
  String timeMinutes(Object minutes) {
    return '時間: $minutes分';
  }

  @override
  String get progress => '進行率';

  @override
  String get maillardReaction => 'メイラード';

  @override
  String get crumb => 'クラム';

  @override
  String get internalTemperature => '内部温度';

  @override
  String get bakingComplete => 'ベーキング完了！';

  @override
  String get bakingAnalysis => 'オーブンベーキング分析';

  @override
  String get waitingForFermentationAnalysis => '発酵分析完了後にベーキング分析を行います...';

  @override
  String get totalBakingTime => '総ベーキング時間';

  @override
  String get totalMaillardReaction => '総メイラード反応';

  @override
  String get averageInternalTemperature => '平均内部温度';

  @override
  String get bakingStepCount => 'ベーキング段階数';

  @override
  String get crustColor => 'クラスト色';

  @override
  String get crumbBakingProgress => 'クラム進行率';

  @override
  String get crustColorDarkBrown => '濃い茶色';

  @override
  String get crustColorBrown => '茶色';

  @override
  String get crustColorLightBrown => '薄い茶色';

  @override
  String get crustColorGolden => '金色';

  @override
  String get crustColorLightIvory => '薄いアイボリー';

  @override
  String get preparingBakingStepData => 'オーブンベーキング段階別分析データを準備中...';

  @override
  String get bakingStepAnalysis => 'オーブンベーキング段階別分析';

  @override
  String stepProgress(Object completed, Object total) {
    return '$completed/$total段階';
  }

  @override
  String get scientificBakingCalculationsInProgress => 'パン製造科学的計算進行中...';

  @override
  String get performingScientificBakingCalculations => 'パン製造科学的ベーキング計算を実行中...';

  @override
  String get performanceMonitoring => 'パフォーマンス監視';

  @override
  String get analysisDuration => '分析所要時間';

  @override
  String get cachePerformance => 'キャッシュパフォーマンス';

  @override
  String get totalEntries => '総項目';

  @override
  String get expiredEntries => '期限切れ項目';

  @override
  String get hitRate => 'ヒット率';

  @override
  String get successRateStatistics => '成功率統計';

  @override
  String get lowTempWarning => '温度が低いため、発酵時間が長くなる可能性があります。暖かい場所に移動してください。';

  @override
  String get highTempWarning => '温度が高いため、過発酵のリスクがあります。涼しい場所に移動してください。';

  @override
  String get lowHumidityWarning => '湿度が低いため、パンが乾燥する可能性があります。水を近くに置いてください。';

  @override
  String get highHumidityWarning => '湿度が高いため、パンが重くなる可能性があります。通気の良い場所を確認してください。';

  @override
  String get winterRecommendation => '冬は発酵時間を20-30%増やすことをお勧めします。';

  @override
  String get summerRecommendation => '夏は発酵時間を10-20%減らすことをお勧めします。';

  @override
  String get optimalEnvironmentMessage => '現在の環境条件はパン焼きに適しています。';

  @override
  String get coldFermentationStrategy => '低温発酵戦略';

  @override
  String get coldFermentationDesc => '現在の温度が低いため、長時間の発酵が必要です。';

  @override
  String get coldFermentationBenefit1 => '風味向上';

  @override
  String get coldFermentationBenefit2 => '酸敗抑制';

  @override
  String get coldFermentationBenefit3 => 'グルテン構造強化';

  @override
  String get warmFermentationStrategy => '高温発酵戦略';

  @override
  String get warmFermentationDesc => '現在の温度が高いため、急速な発酵が進行します。';

  @override
  String get warmFermentationBenefit1 => '時間節約';

  @override
  String get warmFermentationBenefit2 => '効率的な生産';

  @override
  String get warmFermentationBenefit3 => '迅速な結果確認';

  @override
  String get standardFermentationStrategy => '標準発酵戦略';

  @override
  String get standardFermentationDesc => '現在の環境は標準発酵に最適です。';

  @override
  String get standardFermentationBenefit1 => '安定した結果';

  @override
  String get standardFermentationBenefit2 => '予測可能な品質';

  @override
  String get standardFermentationBenefit3 => '容易な管理';

  @override
  String get largeCacheSuggestion => 'キャッシュサイズが大きいです。不要なキャッシュを整理してみてください。';

  @override
  String get increaseCacheSuggestion => 'キャッシュ活用を増やすとパフォーマンスが向上する可能性があります。';

  @override
  String get longAnalysisTimeSuggestion => '分析時間が長くなっています。キャッシュ活用を増やしてみてください。';

  @override
  String get fastAnalysisSuggestion => '非常に速い分析速度！最適化がうまくいっています。';

  @override
  String get optimizedPerformanceMessage => '現在、パフォーマンスが最適化されています。';

  @override
  String unitHours(Object count) {
    return '$count時間';
  }

  @override
  String unitMinutes(Object count) {
    return '$count分';
  }

  @override
  String stepCount(Object count) {
    return '$count Steps';
  }

  @override
  String get mixinAnalysisTitle => 'Mixing Step-by-Step Analysis';

  @override
  String get fermentationAnalysisTitle => 'Fermentation Analysis';

  @override
  String get bakingAnalysisTitle => 'Oven Baking Step-by-Step Analysis';

  @override
  String get analyzingScientificCalculations =>
      'Performing scientific bread calculations...';

  @override
  String stepLabelWithNumber(Object number) {
    return 'Step $number';
  }

  @override
  String get preparingAnalysisData => 'Preparing data...';

  @override
  String mixingStepDefaultTitle(Object number) {
    return 'ミキシング段階 $number';
  }

  @override
  String speedAndDuration(Object duration, Object speed) {
    return '$speed · $duration分';
  }

  @override
  String get glutenFormationLabel => 'グルテン形成';

  @override
  String get calculatingLabel => '計算中...';

  @override
  String get detailedMetricsLabel => '詳細メトリクス';

  @override
  String get moistureAbsorptionLabel => '水分吸収率';

  @override
  String optimalRangeLabel(Object max, Object min) {
    return '適正範囲: $min-$max';
  }

  @override
  String optimalRangeLabelPercent(Object max, Object min) {
    return '適正範囲: $min-$max%';
  }

  @override
  String optimalRangeLabelTemp(Object max, Object min) {
    return '適正範囲: $min-$max°C';
  }

  @override
  String get viscosityLabel => '粘度';

  @override
  String get rpmLabel => 'RPM';

  @override
  String get rotationSpeedLabel => '回転速度';

  @override
  String get observedPhenomenaLabel => '観測現象';

  @override
  String get unknownValue => '不明';

  @override
  String get errorValue => 'エラー';

  @override
  String fermentationStepPrefix(Object number) {
    return '${number}th Fermentation';
  }

  @override
  String get mainMetricsTitle => 'Main Metrics';

  @override
  String get co2GenerationLabel => 'CO₂ Generation';

  @override
  String get volumeExpansionLabel => 'Volume Expansion';

  @override
  String get fermentationProgressLabel => 'Fermentation Progress';

  @override
  String get acidityLabel => 'Acidity';

  @override
  String get scoreGradeExcellent => 'Excellent';

  @override
  String get scoreGradeGood => 'Good';

  @override
  String get scoreGradeFair => 'Fair';

  @override
  String get scoreGradeAverage => 'Average';

  @override
  String get scoreGradePoor => 'Poor';

  @override
  String stepLabelText(Object number) {
    return 'Step $number';
  }

  @override
  String get measuringTemperature => 'Measuring...';

  @override
  String mixingStepTitleLabel(Object number) {
    return 'Mixing Step $number';
  }

  @override
  String get keyMetricsTitle => 'Key Metrics';

  @override
  String get doughDevelopmentLabel => '🌾 Dough Development';

  @override
  String get moistureAbsorptionRateLabel => '💧 Moisture Absorption Rate';

  @override
  String get doughTemperatureLabel => '🌡️ Dough Temperature';

  @override
  String get doughTextureLabel => '⚡ Dough Texture';

  @override
  String get calculationError => 'Calculation Error';

  @override
  String get calculating => 'Calculating...';

  @override
  String get measuring => 'Measuring...';

  @override
  String get ingredientsMixing => 'Mixing Ingredients';
}
