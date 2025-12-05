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
  String get splitCount => '分割個数';

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
}
