// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get recipeBookTitle => 'My Recipe Book';

  @override
  String get noRecipes => 'No recipes available.';

  @override
  String get categoryList => 'Category List';

  @override
  String get noCategories => 'No categories';

  @override
  String cannotDeleteCategoryWithRecipes(Object category) {
    return 'Cannot delete category \'$category\' as it contains recipes.';
  }

  @override
  String categoryDeleted(Object category) {
    return 'Category \'$category\' deleted.';
  }

  @override
  String categoryDeletionFailed(Object error) {
    return 'Failed to delete category: $error';
  }

  @override
  String get welcomeMessage => 'Welcome to My Recipe Book!';

  @override
  String get startCookingJourney => 'Let\'s start a delicious cooking journey!';

  @override
  String get recipeBookSettings => 'Recipe Book Settings';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get titleLabel => 'Title';

  @override
  String get chef => 'Chef';

  @override
  String get cook => 'Cook';

  @override
  String get baker => 'Baker';

  @override
  String get kitchenMaster => 'Kitchen Master';

  @override
  String get startCooking => 'Start Cooking';

  @override
  String get user => 'User';

  @override
  String addRecipePrompt(Object category) {
    return 'Please add a recipe for $category!';
  }

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get searchRecipe => 'Search Recipe';

  @override
  String get settings => 'Settings';

  @override
  String get addRecipeTitle => 'Add Recipe';

  @override
  String get editRecipeTitle => 'Edit Recipe';

  @override
  String get recipeTitleLabel => 'Recipe Title';

  @override
  String get recipeTitleRequired => 'Please enter a recipe title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get ingredientNameLabel => 'Ingredient Name';

  @override
  String get ingredientAmountLabel => 'Ingredient Amount';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than 0.';

  @override
  String get invalidAmount =>
      'Please enter a valid number for ingredient amount.';

  @override
  String get unitSystemLabel => 'Unit System';

  @override
  String get unitLabel => 'Unit';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get instructionsLabel => 'Instructions';

  @override
  String get instructionsRequired => 'Please enter instructions';

  @override
  String servings(Object servings) {
    return '$servings servings';
  }

  @override
  String get noPhoto => 'No Photo';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get ingredientUnitInstructionEdit =>
      'Ingredients, units, instructions edited';

  @override
  String get saveRecipe => 'Save Recipe';

  @override
  String get editRecipe => 'Edit Recipe';

  @override
  String saveRecipeFailed(Object error) {
    return 'Failed to save recipe: $error';
  }

  @override
  String recipeTitle(Object title) {
    return 'Recipe: $title';
  }

  @override
  String category(Object category) {
    return 'Category: $category';
  }

  @override
  String get ingredientsLabel => 'Ingredients:';

  @override
  String get editHistory => 'Edit History:';

  @override
  String get noHistory => 'No history available.';

  @override
  String get updateHistory => 'Update History';

  @override
  String loadHistoryFailed(Object error) {
    return 'Failed to load history: $error';
  }

  @override
  String get shareExcel => 'Share as Excel';

  @override
  String exportExcelFailed(Object error) {
    return 'Failed to create Excel: $error';
  }

  @override
  String get sharePdf => 'Share as PDF';

  @override
  String exportPdfFailed(Object error) {
    return 'Failed to create PDF: $error';
  }

  @override
  String get userInfo => 'User Info';

  @override
  String get updateUserInfo => 'Update User Info';

  @override
  String loadUserInfoFailed(Object error) {
    return 'Failed to load user info: $error';
  }

  @override
  String get userInfoUpdated => 'User info updated.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Failed to save user info: $error';
  }

  @override
  String get defaultUnitSystem => 'Default Unit System';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get categoryAdded => 'Category added!';

  @override
  String addCategoryFailed(Object error) {
    return 'Failed to add category: $error';
  }

  @override
  String get enterValidCategoryName => 'Please enter a valid category name.';

  @override
  String get recipeManagement => 'Recipe Management';

  @override
  String get deleteRecipe => 'Delete Recipe';

  @override
  String confirmDeleteRecipe(Object title) {
    return 'Delete $title recipe?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get recipeDeleted => 'Recipe deleted';

  @override
  String deleteRecipeFailed(Object error) {
    return 'Failed to delete recipe: $error';
  }

  @override
  String get save => 'Save';

  @override
  String greeting(Object name, Object title) {
    return 'Hello, $title $name!';
  }

  @override
  String get languageSelectionLabel => 'Select Language';

  @override
  String get setupScreenTitle => 'My Recipe Book Setup';

  @override
  String get titleSelectionLabel => 'Select Title';

  @override
  String get pastryChef => 'Pastry Chef';

  @override
  String get gourmet => 'Gourmet';

  @override
  String get foodie => 'Foodie';

  @override
  String get culinaryResearcher => 'Culinary Researcher';

  @override
  String get honorificNim => 'Nim';

  @override
  String get honorificSsi => 'Ssi';

  @override
  String get resetUserNameAndTitle => 'Reset Name and Title';

  @override
  String get unitSystemSelectionLabel => 'Select Unit System';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get newCategoryNameLabel => 'New Category Name';

  @override
  String get add => 'Add';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String confirmDeleteCategory(Object category) {
    return 'Delete \"$category\" category? It must not contain any recipes.';
  }

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backupAllRecipes => 'Backup All Recipes';

  @override
  String get restoreRecipes => 'Restore Recipes';

  @override
  String get deleteAllRecipes => 'Delete All Recipes';

  @override
  String get deleteAllRecipesTitle => 'Delete All Recipes';

  @override
  String get confirmDeleteAllRecipes =>
      'Are you sure you want to delete all recipes? This action cannot be undone.';

  @override
  String get resetUserNameAndTitleTitle => 'Reset Name and Title';

  @override
  String get confirmResetUserNameAndTitle =>
      'Are you sure you want to reset your name and title? The app will restart after reset.';

  @override
  String get reset => 'Reset';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String recipesBackedUp(Object filePath) {
    return 'All recipes backed up to: $filePath';
  }

  @override
  String get shareBackupFile => 'Share My Recipe Book backup file.';

  @override
  String recipeBackupFailed(Object error) {
    return 'Recipe backup failed: $error';
  }

  @override
  String get recipesRestored => 'Recipes successfully restored.';

  @override
  String get fileSelectionCancelled => 'File selection cancelled.';

  @override
  String recipeRestoreFailed(Object error) {
    return 'Recipe restore failed: $error';
  }

  @override
  String get allRecipesDeleted => 'All recipes deleted.';

  @override
  String get userNameAndTitleReset => 'Name and title reset. Restarting app.';

  @override
  String get textScaleSettings => 'Text Size Settings';

  @override
  String get useSystemTextScale => 'Use System Text Size Setting';

  @override
  String get followDeviceAccessibility =>
      'Follow device accessibility settings';

  @override
  String get textScaleAdjustment => 'Text Size Adjustment';

  @override
  String currentSize(Object size) {
    return 'Current size: $size%';
  }

  @override
  String get preview => 'Preview';

  @override
  String get previewBodyText =>
      'This is an example of body text. Recipe content and descriptions will be displayed at this size.';

  @override
  String get previewSmallText => 'This is an example of small text.';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeNormal => 'Normal';

  @override
  String get sizeLarge => 'Large';

  @override
  String get sizeVeryLarge => 'Very Large';

  @override
  String get helpTitle => 'Help';

  @override
  String get textScaleHelp =>
      '• Use system setting to apply device accessibility settings.\n• Use custom setting to adjust text size only within the app.\n• You can also use both settings together.';

  @override
  String permissionRequired(Object feature) {
    return '$feature Permission Required';
  }

  @override
  String permissionRequiredMessage(Object feature) {
    return '$feature permission is required. Would you like to allow it?';
  }

  @override
  String permissionPermanentlyDenied(Object feature) {
    return '$feature permission is required. Please allow it in Settings > Privacy > $feature.';
  }

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get cameraFeature => 'Camera';

  @override
  String get galleryAccessFeature => 'Gallery Access';

  @override
  String get photosFeature => 'Photos Library';

  @override
  String get derivedRecipeSave => 'Save Derived Recipe';

  @override
  String get recipeCopy => 'Copy Recipe';

  @override
  String get recipeModify => 'Modify Recipe';

  @override
  String get recipeImageUpload => 'Upload Photo';

  @override
  String get recipeImageCamera => 'Take Photo with Camera';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takeWithCamera => 'Take with Camera';

  @override
  String get bakingModeActivate => 'Activate Baking Mode';

  @override
  String get servingsInput => 'Servings';

  @override
  String get servingsRequired => 'Please enter servings';

  @override
  String get validServingsRequired => 'Please enter a valid number of servings';

  @override
  String get splitWeight => 'Split Weight';

  @override
  String get splitCount => 'Split Count';

  @override
  String get splitWeightOrCountRequired =>
      'Please enter split weight or split count';

  @override
  String get validSplitWeightRequired => 'Please enter a valid split weight';

  @override
  String get validSplitCountRequired => 'Please enter a valid split count';

  @override
  String splitWeightExceedsTotal(Object total) {
    return 'Split weight cannot exceed total ingredient weight. (Total: ${total}g)';
  }

  @override
  String eachWeight(Object unit, Object weight) {
    return '$weight$unit each';
  }

  @override
  String totalSplits(Object count, Object remaining, Object unit) {
    return 'Can split into $count pieces (Remaining: $remaining$unit)';
  }

  @override
  String get resetInput => 'Reset Input';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get ingredientName => 'Ingredient';

  @override
  String get ingredientEdit => 'Edit Ingredient';

  @override
  String get ingredientAmount => 'Amount';

  @override
  String get validIngredientRequired =>
      'Please enter valid ingredient name and amount.';

  @override
  String get validAmountRequired => 'Please enter a valid ingredient amount.';

  @override
  String get ingredientNameAndAmountRequired =>
      'Please enter both ingredient name and amount.';

  @override
  String get copyLabel => ' (Copy)';

  @override
  String get derivedLabel => ' (Derived)';

  @override
  String get recipeGenealogy => 'Recipe Genealogy';

  @override
  String get retryAction => 'Retry';

  @override
  String get goBackAction => 'Go Back';

  @override
  String get favoritePresets => 'Favorite Presets';

  @override
  String get addCustomPreset => 'Add Custom Preset';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get cleanupAction => 'Cleanup';

  @override
  String get useAction => 'Use';

  @override
  String get editAction => 'Edit';

  @override
  String get duplicateAction => 'Duplicate';

  @override
  String get noPresetsAvailable => 'No saved presets.';

  @override
  String get addFirstPreset => 'Add your first preset!';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get titleSelection => 'Title Selection';

  @override
  String get unitSelection => 'Unit';

  @override
  String get editIngredientTitle => 'Edit Ingredient';

  @override
  String get recipeTitleInput => 'Recipe Title';

  @override
  String get categoryInput => 'Category';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get splitWeightLabel => 'Split Weight';

  @override
  String get splitCountLabel => 'Split Count';

  @override
  String get temperatureLabel => 'Temperature (°C)';

  @override
  String get timeMinutesLabel => 'Time (minutes)';

  @override
  String get humidityLabel => 'Humidity (%)';

  @override
  String get speedLabel => 'Speed';

  @override
  String stepNumberLabel(Object number) {
    return 'Step $number';
  }

  @override
  String get enterValidIngredientAmount =>
      'Please enter a valid ingredient amount.';

  @override
  String get enterIngredientNameAndAmount =>
      'Please enter both ingredient name and amount.';

  @override
  String get writeAllInstructionSteps => 'Please write all instruction steps.';

  @override
  String get addAtLeastOneIngredient => 'Please add at least one ingredient.';

  @override
  String get recipeModified => 'Recipe has been modified.';

  @override
  String recipeModifyError(Object error) {
    return 'Error modifying recipe: $error';
  }

  @override
  String recipeSaveError(Object error) {
    return 'Error saving recipe: $error';
  }

  @override
  String get backupFileShare => 'Share Backup File';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get recommendationsTab => 'Recommendations';

  @override
  String get sortBy => 'Sort By';

  @override
  String get deleteFavorite => 'Delete Favorite';

  @override
  String get confirmText => 'Confirm';

  @override
  String get errorTitle => 'Error';

  @override
  String get infoTitle => 'Information';

  @override
  String successCases(Object count) {
    return 'Success cases: $count times';
  }

  @override
  String averageImprovement(Object percent) {
    return 'Average improvement: $percent%';
  }

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get noPerformanceData => 'No performance data yet.';

  @override
  String successRate(Object percent) {
    return 'Success rate: $percent%';
  }

  @override
  String get noUsageData => 'No usage data yet.';

  @override
  String get recipeHistory => 'Recipe History';

  @override
  String get deleteAllAction => 'Delete All';

  @override
  String get improvementLabel => 'Improvement: ';

  @override
  String get improvementPrefix => 'Improved: ';

  @override
  String get notEnoughImprovementData => 'Not enough improvement data yet.';

  @override
  String get closeAction => 'Close';

  @override
  String get deleteAllTitle => 'Delete All';

  @override
  String get confirmDeleteAllHistory =>
      'Are you sure you want to delete all history?\nThis action cannot be undone.';

  @override
  String get userGuide => 'User Guide';

  @override
  String get initializingGuideSystem => 'Initializing guide system...';

  @override
  String get shareAction => 'Share';

  @override
  String get completeAction => 'Mark Complete';

  @override
  String get guideCompleted => 'Guide completed!';

  @override
  String get fermenterSettingGuide => 'Fermenter Setting Guide';

  @override
  String get fermenterSettingGuideDesc =>
      'Step-by-step guide for new fermenter settings';

  @override
  String get troubleshootingGuide => 'Troubleshooting Guide';

  @override
  String get guideShareFeatureComingSoon => 'Guide sharing feature coming soon';

  @override
  String get guideExportFeatureComingSoon => 'Guide export feature coming soon';

  @override
  String get fermenterGuideComingSoon =>
      'Fermenter guide creation feature coming soon';

  @override
  String get troubleshootingGuideComingSoon =>
      'Troubleshooting guide creation feature coming soon';

  @override
  String get overallStatistics => 'Overall Statistics';

  @override
  String get topPerformers => 'Top Performers';

  @override
  String get mostUsedPresets => 'Most Used Presets';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String get totalFavorites => 'Total Favorites';

  @override
  String get customPresets => 'Custom';

  @override
  String get averageSuccessRate => 'Average Success Rate';

  @override
  String get averageImprovementScore => 'Average Improvement';

  @override
  String get recommendedEnvironment => 'Recommended Environment';

  @override
  String get temperatureShort => 'Temp';

  @override
  String get humidityShort => 'Humidity';

  @override
  String get altitudeShort => 'Altitude';

  @override
  String get recentlyUsed => 'Recently Used';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get addPresetInSousChef =>
      'Add presets to favorites in Sous Chef mode';

  @override
  String get noRecommendationsYet => 'No recommendations yet';

  @override
  String get useMoreForRecommendations =>
      'Use Sous Chef mode more to get personalized recommendations';

  @override
  String confidenceLabel(Object percent) {
    return 'Confidence $percent%';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get complete => 'Complete';

  @override
  String get addStep => 'Add Step';

  @override
  String get simpleCopy => 'Simple Copy';

  @override
  String get derivedRecipe => 'Derived Recipe';

  @override
  String get recipeEdit => 'Edit Recipe';

  @override
  String get sousChefMode => 'Sous Chef Mode';

  @override
  String get historyTooltip => 'History';

  @override
  String get korean => 'Korean';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get textSizeSettingsTooltip => 'Text Size Settings';

  @override
  String get enterTitle => 'Please enter a title';

  @override
  String get hintOvenCondition => 'e.g., Until the top is golden brown';

  @override
  String get hintFermentCondition => 'e.g., Until the dough doubles in size';

  @override
  String get hintMixCondition => 'e.g., Until the dough is smooth';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get quickGuideTooltip => 'Quick Guide';

  @override
  String get cannotLoadComparisonData => 'Cannot load recipe comparison data';

  @override
  String get copyRecipeTitle => 'Copy Recipe';

  @override
  String get saveDerivedRecipeTitle => 'Save Derived Recipe';

  @override
  String get ingredientsSectionTitle => 'Ingredients';

  @override
  String get instructionsSectionTitle => 'Instructions';

  @override
  String get enterInstruction => 'Enter instructions';

  @override
  String stepLabel(Object number) {
    return 'Step $number';
  }

  @override
  String stepCommentLabel(Object number) {
    return 'Step $number Comment (Optional)';
  }

  @override
  String get addOvenStepMessage => 'Please add an oven step';

  @override
  String get addFermentationStepMessage => 'Please add a fermentation step';

  @override
  String get addMixingStepMessage => 'Please add a mixing step';

  @override
  String get addOvenStepExample => 'e.g., 180°C 40min → 200°C 20min';

  @override
  String get addFermentationStepExample =>
      'e.g., 1st ferment 80% 240min → 2nd ferment 85% 120min';

  @override
  String get addMixingStepExample => 'e.g., Medium 15min → Low 10min';

  @override
  String sousChefModeError(Object error) {
    return 'Cannot start Sous Chef mode: $error';
  }

  @override
  String get copyRecipeMethodTitle => 'Select Copy Method';

  @override
  String get copyRecipeMethodContent =>
      'How would you like to copy this recipe?';

  @override
  String get deleteRecipeTitle => 'Delete Recipe';

  @override
  String deleteRecipeContent(Object title) {
    return 'Are you sure you want to delete $title?';
  }

  @override
  String deleteFailed(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get recipeSaveNotReady => 'Recipe save feature is coming soon';

  @override
  String get baseServings => 'Base Servings: ';

  @override
  String get multiplier => 'Multiplier: ';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get derivedGraph => 'Derived Graph';

  @override
  String get saveHistory => 'Save History';

  @override
  String get guideDeactivated => 'Ingredient guide deactivated';

  @override
  String get view => 'View';

  @override
  String get allIngredientsAdded => '🎉 All ingredients added!';

  @override
  String get guideOn => 'Start Guide';

  @override
  String get guideOff => 'Stop Guide';

  @override
  String get mixingStep => 'Mixing';

  @override
  String get fermentationStep => 'Fermentation';

  @override
  String get ovenStep => 'Oven';

  @override
  String stepInfoNotEntered(Object stepType) {
    return '$stepType info not entered';
  }

  @override
  String canAddStepInEdit(Object stepType) {
    return 'You can add $stepType steps in Edit Recipe';
  }

  @override
  String get noInstructions => 'No instructions available.';

  @override
  String get originalAmount => 'Original';

  @override
  String get calculatedAmount => 'Calculated';

  @override
  String get changeAmount => 'Change';
}
