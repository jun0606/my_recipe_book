import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../widgets/recipe_search_delegate.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'settings_screen.dart';
// import 'drag_drop_test_screen.dart'; // Temporarily disabled
import '../utils/navigation.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    provider.loadRecipes();
    provider.loadCategories().then((_) {
      if (mounted) {
        setState(() {
          _tabController = TabController(length: provider.categories.length, vsync: this);
          _isLoading = false;
          print('RecipeListScreen: Categories loaded. Count: ${provider.categories.length}');
          print('RecipeListScreen: TabController initialized with length: ${_tabController?.length}');
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<RecipeProvider>(context);
    if (_tabController != null && _tabController!.length != provider.categories.length) {
      _tabController?.dispose();
      _tabController = TabController(length: provider.categories.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final categories = provider.categories;
    if (_isLoading || _tabController == null) {
      print('RecipeListScreen: Loading state - _isLoading: $_isLoading, _tabController == null: ${_tabController == null}');
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipe Book'),
        actions: [
          IconButton(
            icon: Icon(Icons.search), 
            onPressed: () => showSearch(context: context, delegate: RecipeSearchDelegate(provider.recipes))
          ),
          IconButton(
            icon: Icon(Icons.widgets), 
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Drag Drop Test is temporarily disabled')),
              );
            }
          ),
          IconButton(
            icon: Icon(Icons.settings), 
            onPressed: () => Navigator.push(context, buildPageRoute(SettingsScreen()))
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final filteredRecipes = provider.recipes.where((recipe) => recipe.category == category).toList();
          print("RecipeListScreen: Category '$category'. Filtered recipes count: ${filteredRecipes.length}");
          return filteredRecipes.isEmpty
              ? Center(child: Text('$category 레시피를 추가하세요!', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () => Navigator.push(context, buildPageRoute(RecipeDetailScreen(recipe: recipe))),
                        child: Column(
                          children: [
                            recipe.imagePath != null
                                ? Image.file(
                                    File(recipe.imagePath!),
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 200,
                                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    ),
                                  )
                                : Container(height: 200, child: Icon(Icons.dinner_dining, size: 50)),
                            ListTile(
                              title: Text(recipe.title),
                              subtitle: FutureBuilder<int>(
                                future: provider.getDerivedCount(recipe.id!),
                                builder: (context, snapshot) {
                                  String derivedInfo = '';
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    if (snapshot.data! > 0) {
                                      derivedInfo = ' (파생 ${snapshot.data}개)';
                                    }
                                  }
                                  return Text('${recipe.category}${derivedInfo}${recipe.parentId != null ? ' (파생됨)' : ''}');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final initialCategory = provider.categories[_tabController!.index];
          final newRecipe = await Navigator.push<Recipe?>(
            context, 
            buildPageRoute<Recipe?>(AddRecipeScreen(initialCategory: initialCategory))
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}