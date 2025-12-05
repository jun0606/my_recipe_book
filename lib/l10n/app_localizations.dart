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

  /// No description provided for @textScaleSettings.
  ///
  /// In en, this message translates to:
  /// **'Text Size Settings'**
  String get textScaleSettings;

  /// No description provided for @useSystemTextScale.
  ///
  /// In en, this message translates to:
  /// **'Use System Text Size Setting'**
  String get useSystemTextScale;

  /// No description provided for @followDeviceAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Follow device accessibility settings'**
  String get followDeviceAccessibility;

  /// No description provided for @textScaleAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Text Size Adjustment'**
  String get textScaleAdjustment;

  /// No description provided for @currentSize.
  ///
  /// In en, this message translates to:
  /// **'Current size: {size}%'**
  String currentSize(Object size);

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewBodyText.
  ///
  /// In en, this message translates to:
  /// **'This is an example of body text. Recipe content and descriptions will be displayed at this size.'**
  String get previewBodyText;

  /// No description provided for @previewSmallText.
  ///
  /// In en, this message translates to:
  /// **'This is an example of small text.'**
  String get previewSmallText;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get sizeNormal;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @sizeVeryLarge.
  ///
  /// In en, this message translates to:
  /// **'Very Large'**
  String get sizeVeryLarge;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @textScaleHelp.
  ///
  /// In en, this message translates to:
  /// **'• Use system setting to apply device accessibility settings.\n• Use custom setting to adjust text size only within the app.\n• You can also use both settings together.'**
  String get textScaleHelp;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'{feature} Permission Required'**
  String permissionRequired(Object feature);

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'{feature} permission is required. Would you like to allow it?'**
  String permissionRequiredMessage(Object feature);

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'{feature} permission is required. Please allow it in Settings > Privacy > {feature}.'**
  String permissionPermanentlyDenied(Object feature);

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request Permission'**
  String get requestPermission;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @cameraFeature.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraFeature;

  /// No description provided for @galleryAccessFeature.
  ///
  /// In en, this message translates to:
  /// **'Gallery Access'**
  String get galleryAccessFeature;

  /// No description provided for @photosFeature.
  ///
  /// In en, this message translates to:
  /// **'Photos Library'**
  String get photosFeature;

  /// No description provided for @derivedRecipeSave.
  ///
  /// In en, this message translates to:
  /// **'Save Derived Recipe'**
  String get derivedRecipeSave;

  /// No description provided for @recipeCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Recipe'**
  String get recipeCopy;

  /// No description provided for @recipeModify.
  ///
  /// In en, this message translates to:
  /// **'Modify Recipe'**
  String get recipeModify;

  /// No description provided for @recipeImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get recipeImageUpload;

  /// No description provided for @recipeImageCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get recipeImageCamera;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @takeWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Take with Camera'**
  String get takeWithCamera;

  /// No description provided for @bakingModeActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate Baking Mode'**
  String get bakingModeActivate;

  /// No description provided for @servingsInput.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsInput;

  /// No description provided for @servingsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter servings'**
  String get servingsRequired;

  /// No description provided for @validServingsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of servings'**
  String get validServingsRequired;

  /// No description provided for @splitWeight.
  ///
  /// In en, this message translates to:
  /// **'Split Weight'**
  String get splitWeight;

  /// No description provided for @splitCount.
  ///
  /// In en, this message translates to:
  /// **'Split Count'**
  String get splitCount;

  /// No description provided for @splitWeightOrCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter split weight or split count'**
  String get splitWeightOrCountRequired;

  /// No description provided for @validSplitWeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid split weight'**
  String get validSplitWeightRequired;

  /// No description provided for @validSplitCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid split count'**
  String get validSplitCountRequired;

  /// No description provided for @splitWeightExceedsTotal.
  ///
  /// In en, this message translates to:
  /// **'Split weight cannot exceed total ingredient weight. (Total: {total}g)'**
  String splitWeightExceedsTotal(Object total);

  /// No description provided for @eachWeight.
  ///
  /// In en, this message translates to:
  /// **'{weight}{unit} each'**
  String eachWeight(Object unit, Object weight);

  /// No description provided for @totalSplits.
  ///
  /// In en, this message translates to:
  /// **'Can split into {count} pieces (Remaining: {remaining}{unit})'**
  String totalSplits(Object count, Object remaining, Object unit);

  /// No description provided for @resetInput.
  ///
  /// In en, this message translates to:
  /// **'Reset Input'**
  String get resetInput;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientName;

  /// No description provided for @ingredientEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get ingredientEdit;

  /// No description provided for @ingredientAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ingredientAmount;

  /// No description provided for @validIngredientRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid ingredient name and amount.'**
  String get validIngredientRequired;

  /// No description provided for @validAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid ingredient amount.'**
  String get validAmountRequired;

  /// No description provided for @ingredientNameAndAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter both ingredient name and amount.'**
  String get ingredientNameAndAmountRequired;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **' (Copy)'**
  String get copyLabel;

  /// No description provided for @derivedLabel.
  ///
  /// In en, this message translates to:
  /// **' (Derived)'**
  String get derivedLabel;

  /// No description provided for @recipeGenealogy.
  ///
  /// In en, this message translates to:
  /// **'Recipe Genealogy'**
  String get recipeGenealogy;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @goBackAction.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackAction;

  /// No description provided for @favoritePresets.
  ///
  /// In en, this message translates to:
  /// **'Favorite Presets'**
  String get favoritePresets;

  /// No description provided for @addCustomPreset.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Preset'**
  String get addCustomPreset;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @cleanupAction.
  ///
  /// In en, this message translates to:
  /// **'Cleanup'**
  String get cleanupAction;

  /// No description provided for @useAction.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @duplicateAction.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateAction;

  /// No description provided for @noPresetsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No saved presets.'**
  String get noPresetsAvailable;

  /// No description provided for @addFirstPreset.
  ///
  /// In en, this message translates to:
  /// **'Add your first preset!'**
  String get addFirstPreset;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @titleSelection.
  ///
  /// In en, this message translates to:
  /// **'Title Selection'**
  String get titleSelection;

  /// No description provided for @unitSelection.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitSelection;

  /// No description provided for @editIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredientTitle;

  /// No description provided for @recipeTitleInput.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title'**
  String get recipeTitleInput;

  /// No description provided for @categoryInput.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryInput;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @splitWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Split Weight'**
  String get splitWeightLabel;

  /// No description provided for @splitCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Split Count'**
  String get splitCountLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureLabel;

  /// No description provided for @timeMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Time (minutes)'**
  String get timeMinutesLabel;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity (%)'**
  String get humidityLabel;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedLabel;

  /// No description provided for @stepNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepNumberLabel(Object number);

  /// No description provided for @enterValidIngredientAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid ingredient amount.'**
  String get enterValidIngredientAmount;

  /// No description provided for @enterIngredientNameAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter both ingredient name and amount.'**
  String get enterIngredientNameAndAmount;

  /// No description provided for @writeAllInstructionSteps.
  ///
  /// In en, this message translates to:
  /// **'Please write all instruction steps.'**
  String get writeAllInstructionSteps;

  /// No description provided for @addAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one ingredient.'**
  String get addAtLeastOneIngredient;

  /// No description provided for @recipeModified.
  ///
  /// In en, this message translates to:
  /// **'Recipe has been modified.'**
  String get recipeModified;

  /// No description provided for @recipeModifyError.
  ///
  /// In en, this message translates to:
  /// **'Error modifying recipe: {error}'**
  String recipeModifyError(Object error);

  /// No description provided for @recipeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving recipe: {error}'**
  String recipeSaveError(Object error);

  /// No description provided for @backupFileShare.
  ///
  /// In en, this message translates to:
  /// **'Share Backup File'**
  String get backupFileShare;

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// No description provided for @favoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTab;

  /// No description provided for @statisticsTab.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTab;

  /// No description provided for @recommendationsTab.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendationsTab;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @deleteFavorite.
  ///
  /// In en, this message translates to:
  /// **'Delete Favorite'**
  String get deleteFavorite;

  /// No description provided for @confirmText.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmText;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoTitle;

  /// No description provided for @successCases.
  ///
  /// In en, this message translates to:
  /// **'Success cases: {count} times'**
  String successCases(Object count);

  /// No description provided for @averageImprovement.
  ///
  /// In en, this message translates to:
  /// **'Average improvement: {percent}%'**
  String averageImprovement(Object percent);

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No performance data yet.'**
  String get noPerformanceData;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate: {percent}%'**
  String successRate(Object percent);

  /// No description provided for @noUsageData.
  ///
  /// In en, this message translates to:
  /// **'No usage data yet.'**
  String get noUsageData;

  /// No description provided for @recipeHistory.
  ///
  /// In en, this message translates to:
  /// **'Recipe History'**
  String get recipeHistory;

  /// No description provided for @deleteAllAction.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllAction;

  /// No description provided for @improvementLabel.
  ///
  /// In en, this message translates to:
  /// **'Improvement: '**
  String get improvementLabel;

  /// No description provided for @improvementPrefix.
  ///
  /// In en, this message translates to:
  /// **'Improved: '**
  String get improvementPrefix;

  /// No description provided for @notEnoughImprovementData.
  ///
  /// In en, this message translates to:
  /// **'Not enough improvement data yet.'**
  String get notEnoughImprovementData;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllTitle;

  /// No description provided for @confirmDeleteAllHistory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history?\nThis action cannot be undone.'**
  String get confirmDeleteAllHistory;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @initializingGuideSystem.
  ///
  /// In en, this message translates to:
  /// **'Initializing guide system...'**
  String get initializingGuideSystem;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get completeAction;

  /// No description provided for @guideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Guide completed!'**
  String get guideCompleted;

  /// No description provided for @fermenterSettingGuide.
  ///
  /// In en, this message translates to:
  /// **'Fermenter Setting Guide'**
  String get fermenterSettingGuide;

  /// No description provided for @fermenterSettingGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide for new fermenter settings'**
  String get fermenterSettingGuideDesc;

  /// No description provided for @troubleshootingGuide.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting Guide'**
  String get troubleshootingGuide;

  /// No description provided for @guideShareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Guide sharing feature coming soon'**
  String get guideShareFeatureComingSoon;

  /// No description provided for @guideExportFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Guide export feature coming soon'**
  String get guideExportFeatureComingSoon;

  /// No description provided for @fermenterGuideComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Fermenter guide creation feature coming soon'**
  String get fermenterGuideComingSoon;

  /// No description provided for @troubleshootingGuideComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting guide creation feature coming soon'**
  String get troubleshootingGuideComingSoon;

  /// No description provided for @overallStatistics.
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStatistics;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// No description provided for @mostUsedPresets.
  ///
  /// In en, this message translates to:
  /// **'Most Used Presets'**
  String get mostUsedPresets;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @totalFavorites.
  ///
  /// In en, this message translates to:
  /// **'Total Favorites'**
  String get totalFavorites;

  /// No description provided for @customPresets.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customPresets;

  /// No description provided for @averageSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Average Success Rate'**
  String get averageSuccessRate;

  /// No description provided for @averageImprovementScore.
  ///
  /// In en, this message translates to:
  /// **'Average Improvement'**
  String get averageImprovementScore;

  /// No description provided for @recommendedEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Recommended Environment'**
  String get recommendedEnvironment;

  /// No description provided for @temperatureShort.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get temperatureShort;

  /// No description provided for @humidityShort.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidityShort;

  /// No description provided for @altitudeShort.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitudeShort;

  /// No description provided for @recentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Recently Used'**
  String get recentlyUsed;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @addPresetInSousChef.
  ///
  /// In en, this message translates to:
  /// **'Add presets to favorites in Sous Chef mode'**
  String get addPresetInSousChef;

  /// No description provided for @noRecommendationsYet.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet'**
  String get noRecommendationsYet;

  /// No description provided for @useMoreForRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Use Sous Chef mode more to get personalized recommendations'**
  String get useMoreForRecommendations;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent}%'**
  String confidenceLabel(Object percent);
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
