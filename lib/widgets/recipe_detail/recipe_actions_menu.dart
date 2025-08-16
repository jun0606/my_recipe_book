import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../screens/add_recipe_screen.dart';
import '../../screens/recipe_history_screen.dart';
import '../../screens/recipe_tree_screen.dart';
import '../../utils/navigation.dart';
import '../../utils/error_handler.dart';

/// 레시피 상세 화면에서 사용할 액션 메뉴 위젯
class RecipeActionsMenu extends StatelessWidget {
  final Recipe recipe;
  final Function(Recipe?) onRecipeUpdated;
  final Function() onRecipeDeleted;
  
  const RecipeActionsMenu({
    Key? key,
    required this.recipe,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        await _handleMenuAction(context, value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('레시피 수정'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('레시피 복사'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'derive',
          child: ListTile(
            leading: Icon(Icons.call_split),
            title: Text('파생 레시피 생성'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'history',
          child: ListTile(
            leading: Icon(Icons.history),
            title: Text('변경 이력 보기'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'tree',
          child: ListTile(
            leading: Icon(Icons.account_tree),
            title: Text('레시피 계보 보기'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'export_excel',
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Excel로 내보내기'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('레시피 공유'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('레시피 삭제', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleMenuAction(BuildContext context, String value) async {
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    
    switch (value) {
      case 'edit':
        final updatedRecipe = await Navigator.push<Recipe?>(
          context,
          buildPageRoute<Recipe?>(AddRecipeScreen(recipe: recipe, isDerivedCopy: false)),
        );
        if (updatedRecipe != null) {
          onRecipeUpdated(updatedRecipe);
        }
        break;
        
      case 'copy':
        final copiedRecipe = await Navigator.push<Recipe?>(
          context,
          buildPageRoute<Recipe?>(AddRecipeScreen(recipe: recipe, isCopy: true)),
        );
        if (copiedRecipe != null) {
          ErrorHandler.showSuccessSnackBar(context, '레시피가 복사되었습니다.');
        }
        break;
        
      case 'derive':
        final derivedRecipe = await Navigator.push<Recipe?>(
          context,
          buildPageRoute<Recipe?>(AddRecipeScreen(recipe: recipe, isDerivedCopy: true)),
        );
        if (derivedRecipe != null) {
          ErrorHandler.showSuccessSnackBar(context, '파생 레시피가 생성되었습니다.');
        }
        break;
        
      case 'history':
        await Navigator.push(
          context,
          buildPageRoute(const RecipeHistoryScreen()),
        );
        break;
        
      case 'tree':
        await Navigator.push(
          context,
          buildPageRoute(RecipeTreeScreen(initialRecipe: recipe)),
        );
        break;
        
      case 'export_excel':
        try {
          final path = await provider.exportToExcel(recipe);
          ErrorHandler.showSuccessSnackBar(context, 'Excel 파일로 내보내기 완료: $path');
        } catch (e) {
          ErrorHandler.showErrorSnackBar(context, '내보내기 실패: $e');
        }
        break;
        
      case 'share':
        try {
          final path = await provider.exportToExcel(recipe);
          await Share.shareXFiles([XFile(path)], text: '${recipe.title} 레시피');
        } catch (e) {
          ErrorHandler.showErrorSnackBar(context, '공유 실패: $e');
        }
        break;
        
      case 'delete':
        final confirm = await ErrorHandler.showConfirmationDialog(
          context,
          '레시피 삭제',
          '정말로 이 레시피를 삭제하시겠습니까?',
        );
        if (confirm && recipe.id != null) {
          await provider.deleteRecipe(recipe.id!);
          onRecipeDeleted();
        }
        break;
    }
  }
}