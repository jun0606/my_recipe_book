import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../screens/recipe_detail_screen.dart';
import '../../utils/navigation.dart';
import '../../widgets/tree_line_painter.dart';

/// 레시피 트리에서 각 레시피 항목을 표시하는 위젯
class RecipeTreeItem extends StatelessWidget {
  final Recipe recipe;
  final Recipe initialRecipe;
  final int depth;
  final int normalizedDepth;
  final bool hasChild;
  
  const RecipeTreeItem({
    Key? key,
    required this.recipe,
    required this.initialRecipe,
    required this.depth,
    required this.normalizedDepth,
    required this.hasChild,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isCurrentRecipe = recipe.id == initialRecipe.id;
    final bool isRootRecipe = recipe.parentId == null;
    
    return CustomPaint(
      painter: TreeLinePainter(depth: normalizedDepth, hasChild: hasChild),
      child: Padding(
        padding: EdgeInsets.only(left: normalizedDepth * 20.0, top: 4.0, bottom: 4.0),
        child: Card(
          elevation: isCurrentRecipe ? 8.0 : 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          color: isCurrentRecipe ? Colors.pink[50] : null,
          child: ListTile(
            leading: Icon(
              isCurrentRecipe
                  ? Icons.star_rounded
                  : (isRootRecipe ? Icons.menu_book_rounded : Icons.call_split_rounded),
              color: isCurrentRecipe ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
            title: Text(
              recipe.title,
              style: TextStyle(
                fontWeight: isCurrentRecipe ? FontWeight.bold : FontWeight.w500,
                fontSize: 16.0,
                color: Colors.brown[700],
              ),
            ),
            subtitle: Text(
              recipe.category,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[600],
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, buildPageRoute(RecipeDetailScreen(recipe: recipe)));
            },
          ),
        ),
      ),
    );
  }
}