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
  /// **'No categories'**
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
  /// **'Recipe deleted'**
  String get recipeDeleted;

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
  /// **'Ingredient'**
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

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStep;

  /// No description provided for @simpleCopy.
  ///
  /// In en, this message translates to:
  /// **'Simple Copy'**
  String get simpleCopy;

  /// No description provided for @derivedRecipe.
  ///
  /// In en, this message translates to:
  /// **'Derived Recipe'**
  String get derivedRecipe;

  /// No description provided for @recipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get recipeEdit;

  /// No description provided for @sousChefMode.
  ///
  /// In en, this message translates to:
  /// **'Sous Chef Mode'**
  String get sousChefMode;

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTooltip;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// No description provided for @textSizeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text Size Settings'**
  String get textSizeSettingsTooltip;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @hintOvenCondition.
  ///
  /// In en, this message translates to:
  /// **'e.g., Until the top is golden brown'**
  String get hintOvenCondition;

  /// No description provided for @hintFermentCondition.
  ///
  /// In en, this message translates to:
  /// **'e.g., Until the dough doubles in size'**
  String get hintFermentCondition;

  /// No description provided for @hintMixCondition.
  ///
  /// In en, this message translates to:
  /// **'e.g., Until the dough is smooth'**
  String get hintMixCondition;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @quickGuideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick Guide'**
  String get quickGuideTooltip;

  /// No description provided for @cannotLoadComparisonData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load recipe comparison data'**
  String get cannotLoadComparisonData;

  /// No description provided for @copyRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy Recipe'**
  String get copyRecipeTitle;

  /// No description provided for @saveDerivedRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Derived Recipe'**
  String get saveDerivedRecipeTitle;

  /// No description provided for @ingredientsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsSectionTitle;

  /// No description provided for @instructionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsSectionTitle;

  /// No description provided for @enterInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter instructions'**
  String get enterInstruction;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepLabel(Object number);

  /// No description provided for @stepCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number} Comment (Optional)'**
  String stepCommentLabel(Object number);

  /// No description provided for @addOvenStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add an oven step'**
  String get addOvenStepMessage;

  /// No description provided for @addFermentationStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add a fermentation step'**
  String get addFermentationStepMessage;

  /// No description provided for @addMixingStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add a mixing step'**
  String get addMixingStepMessage;

  /// No description provided for @addOvenStepExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 180°C 40min → 200°C 20min'**
  String get addOvenStepExample;

  /// No description provided for @addFermentationStepExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1st ferment 80% 240min → 2nd ferment 85% 120min'**
  String get addFermentationStepExample;

  /// No description provided for @addMixingStepExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Medium 15min → Low 10min'**
  String get addMixingStepExample;

  /// No description provided for @sousChefModeError.
  ///
  /// In en, this message translates to:
  /// **'Cannot start Sous Chef mode: {error}'**
  String sousChefModeError(Object error);

  /// No description provided for @copyRecipeMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Copy Method'**
  String get copyRecipeMethodTitle;

  /// No description provided for @copyRecipeMethodContent.
  ///
  /// In en, this message translates to:
  /// **'How would you like to copy this recipe?'**
  String get copyRecipeMethodContent;

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipeTitle;

  /// No description provided for @deleteRecipeContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {title}?'**
  String deleteRecipeContent(Object title);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailed(Object error);

  /// No description provided for @recipeSaveNotReady.
  ///
  /// In en, this message translates to:
  /// **'Recipe save feature is coming soon'**
  String get recipeSaveNotReady;

  /// No description provided for @baseServings.
  ///
  /// In en, this message translates to:
  /// **'Base Servings: '**
  String get baseServings;

  /// No description provided for @multiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier: '**
  String get multiplier;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @derivedGraph.
  ///
  /// In en, this message translates to:
  /// **'Derived Graph'**
  String get derivedGraph;

  /// No description provided for @saveHistory.
  ///
  /// In en, this message translates to:
  /// **'Save History'**
  String get saveHistory;

  /// No description provided for @guideDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Ingredient guide deactivated'**
  String get guideDeactivated;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @allIngredientsAdded.
  ///
  /// In en, this message translates to:
  /// **'🎉 All ingredients added!'**
  String get allIngredientsAdded;

  /// No description provided for @guideOn.
  ///
  /// In en, this message translates to:
  /// **'Start Guide'**
  String get guideOn;

  /// No description provided for @guideOff.
  ///
  /// In en, this message translates to:
  /// **'Stop Guide'**
  String get guideOff;

  /// No description provided for @mixingStep.
  ///
  /// In en, this message translates to:
  /// **'Mixing'**
  String get mixingStep;

  /// No description provided for @fermentationStep.
  ///
  /// In en, this message translates to:
  /// **'Fermentation'**
  String get fermentationStep;

  /// No description provided for @ovenStep.
  ///
  /// In en, this message translates to:
  /// **'Oven'**
  String get ovenStep;

  /// No description provided for @stepInfoNotEntered.
  ///
  /// In en, this message translates to:
  /// **'{stepType} info not entered'**
  String stepInfoNotEntered(Object stepType);

  /// No description provided for @canAddStepInEdit.
  ///
  /// In en, this message translates to:
  /// **'You can add {stepType} steps in Edit Recipe'**
  String canAddStepInEdit(Object stepType);

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions available.'**
  String get noInstructions;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get originalAmount;

  /// No description provided for @calculatedAmount.
  ///
  /// In en, this message translates to:
  /// **'Calculated'**
  String get calculatedAmount;

  /// No description provided for @changeAmount.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAmount;

  /// No description provided for @mixingStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step'**
  String get mixingStepTitle;

  /// No description provided for @fermentationStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Step {number}'**
  String fermentationStepTitle(Object number);

  /// No description provided for @ovenStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Oven Step'**
  String get ovenStepTitle;

  /// No description provided for @recipeCalculator.
  ///
  /// In en, this message translates to:
  /// **'Recipe Calculator'**
  String get recipeCalculator;

  /// No description provided for @calculationControl.
  ///
  /// In en, this message translates to:
  /// **'Calculation Control'**
  String get calculationControl;

  /// No description provided for @calculationMode.
  ///
  /// In en, this message translates to:
  /// **'Calculation Mode:'**
  String get calculationMode;

  /// No description provided for @baseIngredient.
  ///
  /// In en, this message translates to:
  /// **'Base Ingredient:'**
  String get baseIngredient;

  /// No description provided for @runCalculation.
  ///
  /// In en, this message translates to:
  /// **'Run Calculation'**
  String get runCalculation;

  /// No description provided for @originalRecipe.
  ///
  /// In en, this message translates to:
  /// **'Original Recipe'**
  String get originalRecipe;

  /// No description provided for @calculationResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get calculationResult;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get totalWeight;

  /// No description provided for @remainingWeight.
  ///
  /// In en, this message translates to:
  /// **'Remaining Weight'**
  String get remainingWeight;

  /// No description provided for @bakersPercentageComparison.
  ///
  /// In en, this message translates to:
  /// **'Baker\'s Percentage Comparison'**
  String get bakersPercentageComparison;

  /// No description provided for @multiplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Multiplier:'**
  String get multiplierLabel;

  /// No description provided for @calcModePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get calcModePercentage;

  /// No description provided for @calcModeTargetSplit.
  ///
  /// In en, this message translates to:
  /// **'Target Split Count'**
  String get calcModeTargetSplit;

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get timesLabel;

  /// No description provided for @targetCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Count:'**
  String get targetCountLabel;

  /// No description provided for @countUnit.
  ///
  /// In en, this message translates to:
  /// **'ea'**
  String get countUnit;

  /// No description provided for @targetCountError.
  ///
  /// In en, this message translates to:
  /// **'Target count must be at least 1'**
  String get targetCountError;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @mixingSpeedLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get mixingSpeedLow;

  /// No description provided for @mixingSpeedMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mixingSpeedMedium;

  /// No description provided for @mixingSpeedHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get mixingSpeedHigh;

  /// No description provided for @mixingSpeedMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get mixingSpeedMax;

  /// No description provided for @mixingSpeedPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get mixingSpeedPulse;

  /// No description provided for @mixingSpeedEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg/Foam'**
  String get mixingSpeedEgg;

  /// No description provided for @sousChefModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sous Chef Mode'**
  String get sousChefModeTitle;

  /// No description provided for @analysisTab.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTab;

  /// No description provided for @selectAnalysisModule.
  ///
  /// In en, this message translates to:
  /// **'Select Analysis Module'**
  String get selectAnalysisModule;

  /// No description provided for @breadModule.
  ///
  /// In en, this message translates to:
  /// **'Bread Module'**
  String get breadModule;

  /// No description provided for @unknownModule.
  ///
  /// In en, this message translates to:
  /// **'Unknown Module'**
  String get unknownModule;

  /// No description provided for @bakingEnvironmentConditions.
  ///
  /// In en, this message translates to:
  /// **'Baking Environment Conditions'**
  String get bakingEnvironmentConditions;

  /// No description provided for @altitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Altitude (m)'**
  String get altitudeLabel;

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get seasonLabel;

  /// No description provided for @ovenTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Oven Type'**
  String get ovenTypeLabel;

  /// No description provided for @fermentationMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Method'**
  String get fermentationMethodLabel;

  /// No description provided for @mixerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mixer Type'**
  String get mixerTypeLabel;

  /// No description provided for @applySettings.
  ///
  /// In en, this message translates to:
  /// **'Apply Settings'**
  String get applySettings;

  /// No description provided for @applyingSettings.
  ///
  /// In en, this message translates to:
  /// **'Applying...'**
  String get applyingSettings;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @ovenConvection.
  ///
  /// In en, this message translates to:
  /// **'Convection Oven'**
  String get ovenConvection;

  /// No description provided for @ovenProfessionalConvection.
  ///
  /// In en, this message translates to:
  /// **'Professional Convection Oven'**
  String get ovenProfessionalConvection;

  /// No description provided for @ovenHome.
  ///
  /// In en, this message translates to:
  /// **'Home Oven'**
  String get ovenHome;

  /// No description provided for @ovenConventional.
  ///
  /// In en, this message translates to:
  /// **'Conventional Oven'**
  String get ovenConventional;

  /// No description provided for @ovenDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck Oven'**
  String get ovenDeck;

  /// No description provided for @ovenSteam.
  ///
  /// In en, this message translates to:
  /// **'Steam Oven'**
  String get ovenSteam;

  /// No description provided for @ovenRadiation.
  ///
  /// In en, this message translates to:
  /// **'Radiation Oven'**
  String get ovenRadiation;

  /// No description provided for @ovenStone.
  ///
  /// In en, this message translates to:
  /// **'Stone Oven'**
  String get ovenStone;

  /// No description provided for @ovenProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional Oven'**
  String get ovenProfessional;

  /// No description provided for @fermentationRoomTemp.
  ///
  /// In en, this message translates to:
  /// **'Room Temperature'**
  String get fermentationRoomTemp;

  /// No description provided for @fermentationFermenter.
  ///
  /// In en, this message translates to:
  /// **'Fermenter'**
  String get fermentationFermenter;

  /// No description provided for @mixerHome.
  ///
  /// In en, this message translates to:
  /// **'Home Mixer'**
  String get mixerHome;

  /// No description provided for @mixerProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional Mixer'**
  String get mixerProfessional;

  /// No description provided for @mixerCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial Mixer'**
  String get mixerCommercial;

  /// No description provided for @additionalAnalysisResults.
  ///
  /// In en, this message translates to:
  /// **'Additional Analysis Results'**
  String get additionalAnalysisResults;

  /// No description provided for @expectedSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Expected Success Rate'**
  String get expectedSuccessRate;

  /// No description provided for @glutenOptimization.
  ///
  /// In en, this message translates to:
  /// **'Gluten Optimization'**
  String get glutenOptimization;

  /// No description provided for @moistureBalance.
  ///
  /// In en, this message translates to:
  /// **'Moisture Balance'**
  String get moistureBalance;

  /// No description provided for @temperatureStability.
  ///
  /// In en, this message translates to:
  /// **'Temperature Stability'**
  String get temperatureStability;

  /// No description provided for @statusOptimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get statusOptimal;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get statusStable;

  /// No description provided for @fermentationStrategyRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Strategy Recommendation'**
  String get fermentationStrategyRecommendation;

  /// No description provided for @mixingStepOptimization.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step Optimization'**
  String get mixingStepOptimization;

  /// No description provided for @memoryUsage.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get memoryUsage;

  /// No description provided for @cacheMemory.
  ///
  /// In en, this message translates to:
  /// **'Cache Memory'**
  String get cacheMemory;

  /// No description provided for @initializingModuleWait.
  ///
  /// In en, this message translates to:
  /// **'Initializing analysis module. Please try again in a moment.'**
  String get initializingModuleWait;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete.'**
  String get analysisComplete;

  /// No description provided for @analysisError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during analysis.'**
  String get analysisError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @performanceSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Performance Suggestions'**
  String get performanceSuggestions;

  /// No description provided for @optimizationHighTemp.
  ///
  /// In en, this message translates to:
  /// **' (High Temp Optimization)'**
  String get optimizationHighTemp;

  /// No description provided for @optimizationLowTemp.
  ///
  /// In en, this message translates to:
  /// **' (Low Temp Optimization)'**
  String get optimizationLowTemp;

  /// No description provided for @optimizationHomeMixer.
  ///
  /// In en, this message translates to:
  /// **' (Home Mixer Adjustment)'**
  String get optimizationHomeMixer;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis'**
  String get startAnalysis;

  /// No description provided for @improvementMethodsAndRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Improvement Methods and Recommendations'**
  String get improvementMethodsAndRecommendations;

  /// No description provided for @runAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Run Analysis'**
  String get runAnalysis;

  /// No description provided for @environmentalRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Environmental Recommendations'**
  String get environmentalRecommendations;

  /// No description provided for @stepCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Steps'**
  String stepCountLabel(Object count);

  /// No description provided for @settingsApplied.
  ///
  /// In en, this message translates to:
  /// **'Environmental settings applied.'**
  String get settingsApplied;

  /// No description provided for @settingsApplyError.
  ///
  /// In en, this message translates to:
  /// **'Error applying environmental settings.'**
  String get settingsApplyError;

  /// No description provided for @realTimeRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Real Time Recipe'**
  String get realTimeRecipeTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @realTimeRecipeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Real time recipes are coming soon'**
  String get realTimeRecipeComingSoon;

  /// No description provided for @realTimeRecipeComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'You will soon meet various real time recipes'**
  String get realTimeRecipeComingSoonDesc;

  /// No description provided for @loadingRealTimeRecipes.
  ///
  /// In en, this message translates to:
  /// **'Loading real time recipes...'**
  String get loadingRealTimeRecipes;

  /// No description provided for @realTimeRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Real Time Recommendation'**
  String get realTimeRecommendation;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @realTimeFeedback.
  ///
  /// In en, this message translates to:
  /// **'Real Time Feedback'**
  String get realTimeFeedback;

  /// No description provided for @realTimeFeedbackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Real time feedback system is coming soon.\nWe will provide useful tips and advice during the recipe.'**
  String get realTimeFeedbackComingSoon;

  /// No description provided for @recommendedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recommended Recipes'**
  String get recommendedRecipes;

  /// No description provided for @recipeStarted.
  ///
  /// In en, this message translates to:
  /// **'Starting {title} recipe!'**
  String recipeStarted(Object title);

  /// No description provided for @recipeSaved.
  ///
  /// In en, this message translates to:
  /// **'{title} recipe saved!'**
  String recipeSaved(Object title);

  /// No description provided for @initializingAnalysisEngine.
  ///
  /// In en, this message translates to:
  /// **'Initializing analysis engine...'**
  String get initializingAnalysisEngine;

  /// No description provided for @performingScientificCalculations.
  ///
  /// In en, this message translates to:
  /// **'Performing scientific step-by-step calculations...'**
  String get performingScientificCalculations;

  /// No description provided for @preparingMixingData.
  ///
  /// In en, this message translates to:
  /// **'Preparing mixing step data...'**
  String get preparingMixingData;

  /// No description provided for @mixingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Mixing Analysis'**
  String get mixingAnalysis;

  /// No description provided for @keyMetricsTotalMixing.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics: Total Mixing {minutes} min'**
  String keyMetricsTotalMixing(Object minutes);

  /// No description provided for @mixingAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Mixing Analysis Complete'**
  String get mixingAnalysisComplete;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score: {score}% ({grade})'**
  String overallScore(Object grade, Object score);

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @glutenDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Gluten Development'**
  String get glutenDevelopment;

  /// No description provided for @moisture.
  ///
  /// In en, this message translates to:
  /// **'Moisture'**
  String get moisture;

  /// No description provided for @doughTemperature.
  ///
  /// In en, this message translates to:
  /// **'Dough Temperature'**
  String get doughTemperature;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @temperatureWarning.
  ///
  /// In en, this message translates to:
  /// **'Temperature Warning'**
  String get temperatureWarning;

  /// No description provided for @stepTemperatureWarning.
  ///
  /// In en, this message translates to:
  /// **'Step {number}: Dough Temp {temp} (Recommended: 20-30°C)'**
  String stepTemperatureWarning(Object number, Object temp);

  /// No description provided for @mixingStepAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step Analysis'**
  String get mixingStepAnalysis;

  /// No description provided for @analyzingMixing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Mixing...'**
  String get analyzingMixing;

  /// No description provided for @performingStepCalculations.
  ///
  /// In en, this message translates to:
  /// **'Performing step calculations'**
  String get performingStepCalculations;

  /// No description provided for @scientificCalculationsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scientific calculations in progress...'**
  String get scientificCalculationsInProgress;

  /// No description provided for @processingAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'Processing analysis data to calculate metrics.'**
  String get processingAnalysisData;

  /// No description provided for @fermentationAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Analysis'**
  String get fermentationAnalysis;

  /// No description provided for @totalFermentationTime.
  ///
  /// In en, this message translates to:
  /// **'Total Fermentation Time'**
  String get totalFermentationTime;

  /// No description provided for @totalCO2Generation.
  ///
  /// In en, this message translates to:
  /// **'Total CO₂ Generation'**
  String get totalCO2Generation;

  /// No description provided for @totalFermentationProgress.
  ///
  /// In en, this message translates to:
  /// **'Total Fermentation Progress'**
  String get totalFermentationProgress;

  /// No description provided for @fermentationStepCount.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Steps'**
  String get fermentationStepCount;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @fermentationPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect Fermentation'**
  String get fermentationPerfect;

  /// No description provided for @fermentationExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get fermentationExcellent;

  /// No description provided for @fermentationGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get fermentationGood;

  /// No description provided for @fermentationAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get fermentationAverage;

  /// No description provided for @fermentationPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get fermentationPoor;

  /// No description provided for @analysisIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis Incomplete'**
  String get analysisIncomplete;

  /// No description provided for @actualDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Actual data unavailable'**
  String get actualDataUnavailable;

  /// No description provided for @completedStep.
  ///
  /// In en, this message translates to:
  /// **'Completed Step {number}'**
  String completedStep(Object number);

  /// No description provided for @stepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepNumber(Object number);

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Time: {minutes} min'**
  String timeMinutes(Object minutes);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @maillardReaction.
  ///
  /// In en, this message translates to:
  /// **'Maillard'**
  String get maillardReaction;

  /// No description provided for @crumb.
  ///
  /// In en, this message translates to:
  /// **'Crumb'**
  String get crumb;

  /// No description provided for @internalTemperature.
  ///
  /// In en, this message translates to:
  /// **'Internal Temp'**
  String get internalTemperature;

  /// No description provided for @bakingComplete.
  ///
  /// In en, this message translates to:
  /// **'Baking Complete!'**
  String get bakingComplete;

  /// No description provided for @bakingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Oven Baking Analysis'**
  String get bakingAnalysis;

  /// No description provided for @waitingForFermentationAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Waiting for fermentation analysis to complete...'**
  String get waitingForFermentationAnalysis;

  /// No description provided for @totalBakingTime.
  ///
  /// In en, this message translates to:
  /// **'Total Baking Time'**
  String get totalBakingTime;

  /// No description provided for @totalMaillardReaction.
  ///
  /// In en, this message translates to:
  /// **'Total Maillard Reaction'**
  String get totalMaillardReaction;

  /// No description provided for @averageInternalTemperature.
  ///
  /// In en, this message translates to:
  /// **'Avg Internal Temp'**
  String get averageInternalTemperature;

  /// No description provided for @bakingStepCount.
  ///
  /// In en, this message translates to:
  /// **'Baking Steps'**
  String get bakingStepCount;

  /// No description provided for @crustColor.
  ///
  /// In en, this message translates to:
  /// **'Crust Color'**
  String get crustColor;

  /// No description provided for @crumbBakingProgress.
  ///
  /// In en, this message translates to:
  /// **'Crumb Progress'**
  String get crumbBakingProgress;

  /// No description provided for @crustColorDarkBrown.
  ///
  /// In en, this message translates to:
  /// **'Dark Brown'**
  String get crustColorDarkBrown;

  /// No description provided for @crustColorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get crustColorBrown;

  /// No description provided for @crustColorLightBrown.
  ///
  /// In en, this message translates to:
  /// **'Light Brown'**
  String get crustColorLightBrown;

  /// No description provided for @crustColorGolden.
  ///
  /// In en, this message translates to:
  /// **'Golden'**
  String get crustColorGolden;

  /// No description provided for @crustColorLightIvory.
  ///
  /// In en, this message translates to:
  /// **'Light Ivory'**
  String get crustColorLightIvory;

  /// No description provided for @preparingBakingStepData.
  ///
  /// In en, this message translates to:
  /// **'Preparing baking step analysis data...'**
  String get preparingBakingStepData;

  /// No description provided for @bakingStepAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Baking Step Analysis'**
  String get bakingStepAnalysis;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Steps'**
  String stepProgress(Object completed, Object total);

  /// No description provided for @scientificBakingCalculationsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scientific baking calculations in progress...'**
  String get scientificBakingCalculationsInProgress;

  /// No description provided for @performingScientificBakingCalculations.
  ///
  /// In en, this message translates to:
  /// **'Performing scientific baking calculations...'**
  String get performingScientificBakingCalculations;

  /// No description provided for @performanceMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Performance Monitoring'**
  String get performanceMonitoring;

  /// No description provided for @analysisDuration.
  ///
  /// In en, this message translates to:
  /// **'Analysis Duration'**
  String get analysisDuration;

  /// No description provided for @cachePerformance.
  ///
  /// In en, this message translates to:
  /// **'Cache Performance'**
  String get cachePerformance;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntries;

  /// No description provided for @expiredEntries.
  ///
  /// In en, this message translates to:
  /// **'Expired Entries'**
  String get expiredEntries;

  /// No description provided for @hitRate.
  ///
  /// In en, this message translates to:
  /// **'Hit Rate'**
  String get hitRate;

  /// No description provided for @successRateStatistics.
  ///
  /// In en, this message translates to:
  /// **'Success Rate Statistics'**
  String get successRateStatistics;

  /// No description provided for @lowTempWarning.
  ///
  /// In en, this message translates to:
  /// **'Low temperature may prolong fermentation. Move to a warmer place.'**
  String get lowTempWarning;

  /// No description provided for @highTempWarning.
  ///
  /// In en, this message translates to:
  /// **'High temperature risks over-fermentation. Move to a cooler place.'**
  String get highTempWarning;

  /// No description provided for @lowHumidityWarning.
  ///
  /// In en, this message translates to:
  /// **'Low humidity may dry out the bread. Keep water nearby.'**
  String get lowHumidityWarning;

  /// No description provided for @highHumidityWarning.
  ///
  /// In en, this message translates to:
  /// **'High humidity may make the bread heavy. Ensure good ventilation.'**
  String get highHumidityWarning;

  /// No description provided for @winterRecommendation.
  ///
  /// In en, this message translates to:
  /// **'In winter, increase fermentation time by 20-30%.'**
  String get winterRecommendation;

  /// No description provided for @summerRecommendation.
  ///
  /// In en, this message translates to:
  /// **'In summer, decrease fermentation time by 10-20%.'**
  String get summerRecommendation;

  /// No description provided for @optimalEnvironmentMessage.
  ///
  /// In en, this message translates to:
  /// **'Current environmental conditions are optimal for baking.'**
  String get optimalEnvironmentMessage;

  /// No description provided for @coldFermentationStrategy.
  ///
  /// In en, this message translates to:
  /// **'Cold Fermentation Strategy'**
  String get coldFermentationStrategy;

  /// No description provided for @coldFermentationDesc.
  ///
  /// In en, this message translates to:
  /// **'Low temperature requires long fermentation.'**
  String get coldFermentationDesc;

  /// No description provided for @coldFermentationBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Flavor Enhancement'**
  String get coldFermentationBenefit1;

  /// No description provided for @coldFermentationBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Rancidity Inhibition'**
  String get coldFermentationBenefit2;

  /// No description provided for @coldFermentationBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Gluten Structure Strengthening'**
  String get coldFermentationBenefit3;

  /// No description provided for @warmFermentationStrategy.
  ///
  /// In en, this message translates to:
  /// **'Warm Fermentation Strategy'**
  String get warmFermentationStrategy;

  /// No description provided for @warmFermentationDesc.
  ///
  /// In en, this message translates to:
  /// **'High temperature leads to rapid fermentation.'**
  String get warmFermentationDesc;

  /// No description provided for @warmFermentationBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Time Saving'**
  String get warmFermentationBenefit1;

  /// No description provided for @warmFermentationBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Efficient Production'**
  String get warmFermentationBenefit2;

  /// No description provided for @warmFermentationBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Quick Results'**
  String get warmFermentationBenefit3;

  /// No description provided for @standardFermentationStrategy.
  ///
  /// In en, this message translates to:
  /// **'Standard Fermentation Strategy'**
  String get standardFermentationStrategy;

  /// No description provided for @standardFermentationDesc.
  ///
  /// In en, this message translates to:
  /// **'Current environment is optimal for standard fermentation.'**
  String get standardFermentationDesc;

  /// No description provided for @standardFermentationBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Stable Results'**
  String get standardFermentationBenefit1;

  /// No description provided for @standardFermentationBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Predictable Quality'**
  String get standardFermentationBenefit2;

  /// No description provided for @standardFermentationBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Easy Management'**
  String get standardFermentationBenefit3;

  /// No description provided for @largeCacheSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Cache size is large. Try clearing unnecessary cache.'**
  String get largeCacheSuggestion;

  /// No description provided for @increaseCacheSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Increasing cache usage may improve performance.'**
  String get increaseCacheSuggestion;

  /// No description provided for @longAnalysisTimeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Analysis time is long. Try increasing cache usage.'**
  String get longAnalysisTimeSuggestion;

  /// No description provided for @fastAnalysisSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Very fast analysis speed! Optimization is working well.'**
  String get fastAnalysisSuggestion;

  /// No description provided for @optimizedPerformanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Performance is currently optimized.'**
  String get optimizedPerformanceMessage;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String unitHours(Object count);

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String unitMinutes(Object count);

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Steps'**
  String stepCount(Object count);

  /// No description provided for @mixinAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step-by-Step Analysis'**
  String get mixinAnalysisTitle;

  /// No description provided for @fermentationAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Analysis'**
  String get fermentationAnalysisTitle;

  /// No description provided for @bakingAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Oven Baking Step-by-Step Analysis'**
  String get bakingAnalysisTitle;

  /// No description provided for @analyzingScientificCalculations.
  ///
  /// In en, this message translates to:
  /// **'Performing scientific bread calculations...'**
  String get analyzingScientificCalculations;

  /// No description provided for @stepLabelWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepLabelWithNumber(Object number);

  /// No description provided for @preparingAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'Preparing data...'**
  String get preparingAnalysisData;

  /// No description provided for @mixingStepDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step {number}'**
  String mixingStepDefaultTitle(Object number);

  /// No description provided for @speedAndDuration.
  ///
  /// In en, this message translates to:
  /// **'{speed} · {duration}m'**
  String speedAndDuration(Object duration, Object speed);

  /// No description provided for @glutenFormationLabel.
  ///
  /// In en, this message translates to:
  /// **'Gluten Formation'**
  String get glutenFormationLabel;

  /// No description provided for @calculatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculatingLabel;

  /// No description provided for @detailedMetricsLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed Metrics'**
  String get detailedMetricsLabel;

  /// No description provided for @moistureAbsorptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Moisture Absorption'**
  String get moistureAbsorptionLabel;

  /// No description provided for @optimalRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Optimal: {min}-{max}'**
  String optimalRangeLabel(Object max, Object min);

  /// No description provided for @optimalRangeLabelPercent.
  ///
  /// In en, this message translates to:
  /// **'Optimal: {min}-{max}%'**
  String optimalRangeLabelPercent(Object max, Object min);

  /// No description provided for @optimalRangeLabelTemp.
  ///
  /// In en, this message translates to:
  /// **'Optimal: {min}-{max}°C'**
  String optimalRangeLabelTemp(Object max, Object min);

  /// No description provided for @viscosityLabel.
  ///
  /// In en, this message translates to:
  /// **'Viscosity'**
  String get viscosityLabel;

  /// No description provided for @rpmLabel.
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpmLabel;

  /// No description provided for @rotationSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotation Speed'**
  String get rotationSpeedLabel;

  /// No description provided for @observedPhenomenaLabel.
  ///
  /// In en, this message translates to:
  /// **'Observed Phenomena'**
  String get observedPhenomenaLabel;

  /// No description provided for @unknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownValue;

  /// No description provided for @errorValue.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorValue;

  /// No description provided for @fermentationStepPrefix.
  ///
  /// In en, this message translates to:
  /// **'{number}th Fermentation'**
  String fermentationStepPrefix(Object number);

  /// No description provided for @mainMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Metrics'**
  String get mainMetricsTitle;

  /// No description provided for @co2GenerationLabel.
  ///
  /// In en, this message translates to:
  /// **'CO₂ Generation'**
  String get co2GenerationLabel;

  /// No description provided for @volumeExpansionLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume Expansion'**
  String get volumeExpansionLabel;

  /// No description provided for @fermentationProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Fermentation Progress'**
  String get fermentationProgressLabel;

  /// No description provided for @acidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidityLabel;

  /// No description provided for @scoreGradeExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scoreGradeExcellent;

  /// No description provided for @scoreGradeGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scoreGradeGood;

  /// No description provided for @scoreGradeFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get scoreGradeFair;

  /// No description provided for @scoreGradeAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get scoreGradeAverage;

  /// No description provided for @scoreGradePoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scoreGradePoor;

  /// No description provided for @stepLabelText.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepLabelText(Object number);

  /// No description provided for @measuringTemperature.
  ///
  /// In en, this message translates to:
  /// **'Measuring...'**
  String get measuringTemperature;

  /// No description provided for @mixingStepTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Mixing Step {number}'**
  String mixingStepTitleLabel(Object number);

  /// No description provided for @keyMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetricsTitle;

  /// No description provided for @doughDevelopmentLabel.
  ///
  /// In en, this message translates to:
  /// **'🌾 Dough Development'**
  String get doughDevelopmentLabel;

  /// No description provided for @moistureAbsorptionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'💧 Moisture Absorption Rate'**
  String get moistureAbsorptionRateLabel;

  /// No description provided for @doughTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'🌡️ Dough Temperature'**
  String get doughTemperatureLabel;

  /// No description provided for @doughTextureLabel.
  ///
  /// In en, this message translates to:
  /// **'⚡ Dough Texture'**
  String get doughTextureLabel;

  /// No description provided for @calculationError.
  ///
  /// In en, this message translates to:
  /// **'Calculation Error'**
  String get calculationError;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @measuring.
  ///
  /// In en, this message translates to:
  /// **'Measuring...'**
  String get measuring;

  /// No description provided for @ingredientsMixing.
  ///
  /// In en, this message translates to:
  /// **'Mixing Ingredients'**
  String get ingredientsMixing;
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
