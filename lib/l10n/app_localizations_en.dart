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
  String get noCategories => 'No categories available.';

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
  String recipeDeleted(Object title) {
    return '$title recipe deleted.';
  }

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
  String get testAddCategoryButton => 'Test Add Category Button';

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
}
