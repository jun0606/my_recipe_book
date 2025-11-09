// lib/widgets/recipe_search_delegate.dart
// 레시피 검색 위젯

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/navigation.dart';

/// 레시피 검색 델리게이트
class RecipeSearchDelegate extends SearchDelegate<String> {
  final List<Recipe> recipes;

  RecipeSearchDelegate(this.recipes);

  @override
  String get searchFieldLabel => '레시피 검색...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterRecipes(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        return ListTile(
          title: Text(recipe.title),
          subtitle: Text(recipe.category),
          onTap: () {
            close(context, recipe.id.toString());
            // 레시피 상세 화면으로 이동
            _navigateToRecipeDetail(context, recipe);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _filterRecipes(query);

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final recipe = suggestions[index];
        return ListTile(
          title: Text(recipe.title),
          subtitle: Text(recipe.category),
          onTap: () {
            query = recipe.title;
            showResults(context);
          },
        );
      },
    );
  }

  /// 레시피 필터링
  List<Recipe> _filterRecipes(String query) {
    if (query.isEmpty) {
      return recipes;
    }

    return recipes.where((recipe) {
      final title = recipe.title.toLowerCase();
      final category = recipe.category.toLowerCase();
      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) || category.contains(searchQuery);
    }).toList();
  }

  /// 레시피 상세 화면으로 이동
  void _navigateToRecipeDetail(BuildContext context, Recipe recipe) {
    // 실제 구현에서는 RecipeDetailScreen으로 이동
    // Navigator.of(context).push(
    //   buildPageRoute(RecipeDetailScreen(recipe: recipe)),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${recipe.title} 선택됨')),
    );
  }
}
