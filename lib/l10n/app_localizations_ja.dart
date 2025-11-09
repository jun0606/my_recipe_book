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
  String get noCategories => 'カテゴリがありません。';

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
  String recipeDeleted(Object title) {
    return '$title レシピが削除されました。';
  }

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
}
