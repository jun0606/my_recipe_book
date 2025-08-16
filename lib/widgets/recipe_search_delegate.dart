import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';
import '../utils/navigation.dart';

class RecipeSearchDelegate extends SearchDelegate {
  final List<Recipe> recipes;
  
  RecipeSearchDelegate(this.recipes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = recipes.where((recipe) => 
      recipe.title.toLowerCase().contains(query.toLowerCase()) || 
      recipe.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: ListTile(
            leading: recipe.imagePath != null
                ? Image.file(
                    File(recipe.imagePath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.dinner_dining, size: 50),
                  )
                : Icon(Icons.dinner_dining, size: 50),
            title: Text(recipe.title),
            subtitle: Text(recipe.category),
            onTap: () {
              close(context, null);
              Navigator.push(context, buildPageRoute(RecipeDetailScreen(recipe: recipe)));
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = recipes.where((recipe) => 
      recipe.title.toLowerCase().contains(query.toLowerCase()) || 
      recipe.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
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
}