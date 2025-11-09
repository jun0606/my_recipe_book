import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko')
  ];

  /// No description provided for @recipeBookTitle.
  ///
  /// In en, this message translates to:
  /// **'My Recipe Book'**
  String get recipeBookTitle;

  /// No description provided for @noRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes available.'**
  String get noRecipes;

  /// No description provided for @categoryList.
  ///
  /// In en, this message translates to:
  /// **'Category List'**
  String get categoryList;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories available.'**
  String get noCategories;

  /// No description provided for @cannotDeleteCategoryWithRecipes.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category \'{category}\' as it contains recipes.'**
  String cannotDeleteCategoryWithRecipes(Object category);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category \'{category}\' deleted.'**
  String categoryDeleted(Object category);

  /// No description provided for @categoryDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category: {error}'**
  String categoryDeletionFailed(Object error);

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to My Recipe Book!'**
  String get welcomeMessage;

  /// No description provided for @startCookingJourney.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start a delicious cooking journey!'**
  String get startCookingJourney;

  /// No description provided for @recipeBookSettings.
  ///
  /// In en, this message translates to:
  /// **'Recipe Book Settings'**
  String get recipeBookSettings;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @chef.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get chef;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @baker.
  ///
  /// In en, this message translates to:
  /// **'Baker'**
  String get baker;

  /// No description provided for @kitchenMaster.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Master'**
  String get kitchenMaster;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @addRecipePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please add a recipe for {category}!'**
  String addRecipePrompt(Object category);

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @searchRecipe.
  ///
  /// In en, this message translates to:
  /// **'Search Recipe'**
  String get searchRecipe;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipeTitle;

  /// No description provided for @editRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipeTitle;

  /// No description provided for @recipeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title'**
  String get recipeTitleLabel;

  /// No description provided for @recipeTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recipe title'**
  String get recipeTitleRequired;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @ingredientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientNameLabel;

  /// No description provided for @ingredientAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Amount'**
  String get ingredientAmountLabel;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0.'**
  String get amountGreaterThanZero;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number for ingredient amount.'**
  String get invalidAmount;

  /// No description provided for @unitSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get unitSystemLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsLabel;

  /// No description provided for @instructionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter instructions'**
  String get instructionsRequired;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'{servings} servings'**
  String servings(Object servings);

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No Photo'**
  String get noPhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @ingredientUnitInstructionEdit.
  ///
  /// In en, this message translates to:
  /// **'Ingredients, units, instructions edited'**
  String get ingredientUnitInstructionEdit;

  /// No description provided for @saveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe'**
  String get saveRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipe;

  /// No description provided for @saveRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save recipe: {error}'**
  String saveRecipeFailed(Object error);

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {title}'**
  String recipeTitle(Object title);

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String category(Object category);

  /// No description provided for @ingredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredients:'**
  String get ingredientsLabel;

  /// No description provided for @editHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit History:'**
  String get editHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history available.'**
  String get noHistory;

  /// No description provided for @updateHistory.
  ///
  /// In en, this message translates to:
  /// **'Update History'**
  String get updateHistory;

  /// No description provided for @loadHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String loadHistoryFailed(Object error);

  /// No description provided for @shareExcel.
  ///
  /// In en, this message translates to:
  /// **'Share as Excel'**
  String get shareExcel;

  /// No description provided for @exportExcelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create Excel: {error}'**
  String exportExcelFailed(Object error);

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF'**
  String get sharePdf;

  /// No description provided for @exportPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create PDF: {error}'**
  String exportPdfFailed(Object error);

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @updateUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Update User Info'**
  String get updateUserInfo;

  /// No description provided for @loadUserInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user info: {error}'**
  String loadUserInfoFailed(Object error);

  /// No description provided for @userInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'User info updated.'**
  String get userInfoUpdated;

  /// No description provided for @saveUserInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save user info: {error}'**
  String saveUserInfoFailed(Object error);

  /// No description provided for @defaultUnitSystem.
  ///
  /// In en, this message translates to:
  /// **'Default Unit System'**
  String get defaultUnitSystem;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added!'**
  String get categoryAdded;

  /// No description provided for @addCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category: {error}'**
  String addCategoryFailed(Object error);

  /// No description provided for @enterValidCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid category name.'**
  String get enterValidCategoryName;

  /// No description provided for @recipeManagement.
  ///
  /// In en, this message translates to:
  /// **'Recipe Management'**
  String get recipeManagement;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipe;

  /// No description provided for @confirmDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete {title} recipe?'**
  String confirmDeleteRecipe(Object title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} recipe deleted.'**
  String recipeDeleted(Object title);

  /// No description provided for @deleteRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recipe: {error}'**
  String deleteRecipeFailed(Object error);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {title} {name}!'**
  String greeting(Object name, Object title);

  /// No description provided for @languageSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelectionLabel;

  /// No description provided for @setupScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Recipe Book Setup'**
  String get setupScreenTitle;

  /// No description provided for @titleSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Title'**
  String get titleSelectionLabel;

  /// No description provided for @pastryChef.
  ///
  /// In en, this message translates to:
  /// **'Pastry Chef'**
  String get pastryChef;

  /// No description provided for @gourmet.
  ///
  /// In en, this message translates to:
  /// **'Gourmet'**
  String get gourmet;

  /// No description provided for @foodie.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get foodie;

  /// No description provided for @culinaryResearcher.
  ///
  /// In en, this message translates to:
  /// **'Culinary Researcher'**
  String get culinaryResearcher;

  /// No description provided for @honorificNim.
  ///
  /// In en, this message translates to:
  /// **'Nim'**
  String get honorificNim;

  /// No description provided for @honorificSsi.
  ///
  /// In en, this message translates to:
  /// **'Ssi'**
  String get honorificSsi;

  /// No description provided for @resetUserNameAndTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Name and Title'**
  String get resetUserNameAndTitle;

  /// No description provided for @unitSystemSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Unit System'**
  String get unitSystemSelectionLabel;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @newCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New Category Name'**
  String get newCategoryNameLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{category}\" category? It must not contain any recipes.'**
  String confirmDeleteCategory(Object category);

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'Backup All Recipes'**
  String get backupAllRecipes;

  /// No description provided for @restoreRecipes.
  ///
  /// In en, this message translates to:
  /// **'Restore Recipes'**
  String get restoreRecipes;

  /// No description provided for @deleteAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'Delete All Recipes'**
  String get deleteAllRecipes;

  /// No description provided for @deleteAllRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Recipes'**
  String get deleteAllRecipesTitle;

  /// No description provided for @confirmDeleteAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all recipes? This action cannot be undone.'**
  String get confirmDeleteAllRecipes;

  /// No description provided for @resetUserNameAndTitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Name and Title'**
  String get resetUserNameAndTitleTitle;

  /// No description provided for @confirmResetUserNameAndTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your name and title? The app will restart after reset.'**
  String get confirmResetUserNameAndTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @recipesBackedUp.
  ///
  /// In en, this message translates to:
  /// **'All recipes backed up to: {filePath}'**
  String recipesBackedUp(Object filePath);

  /// No description provided for @shareBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Share My Recipe Book backup file.'**
  String get shareBackupFile;

  /// No description provided for @recipeBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Recipe backup failed: {error}'**
  String recipeBackupFailed(Object error);

  /// No description provided for @recipesRestored.
  ///
  /// In en, this message translates to:
  /// **'Recipes successfully restored.'**
  String get recipesRestored;

  /// No description provided for @fileSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'File selection cancelled.'**
  String get fileSelectionCancelled;

  /// No description provided for @recipeRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Recipe restore failed: {error}'**
  String recipeRestoreFailed(Object error);

  /// No description provided for @allRecipesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All recipes deleted.'**
  String get allRecipesDeleted;

  /// No description provided for @userNameAndTitleReset.
  ///
  /// In en, this message translates to:
  /// **'Name and title reset. Restarting app.'**
  String get userNameAndTitleReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
