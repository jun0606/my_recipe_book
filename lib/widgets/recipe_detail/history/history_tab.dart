import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/history.dart';
import '../../../providers/recipe_provider.dart';
import '../../../services/history_service.dart';
import '../../../di/service_locator.dart';
import 'history_entry_card.dart';

/// 히스토리 탭 위젯
class HistoryTab extends StatefulWidget {
  /// 레시피 ID
  final int recipeId;
  
  /// 생성자
  const HistoryTab({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<History> _history = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // 서비스 로케이터가 초기화되지 않은 경우 RecipeProvider에서 히스토리 로드
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      await provider.loadHistory(widget.recipeId);
      
      setState(() {
        _history = provider.history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '히스토리를 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }
  
  Future<void> _restoreRecipe(int historyId) async {
    try {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      
      // 향후 HistoryService를 사용하도록 변경
      // final historyService = ServiceLocator().get<HistoryService>();
      // final restoredRecipe = await historyService.restoreRecipeFromHistory(historyId);
      
      // 현재는 미구현 상태이므로 알림만 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이 기능은 아직 구현되지 않았습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('레시피 복원 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage, style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHistory,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('히스토리가 없습니다.', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final history = _history[index];
        return HistoryEntryCard(
          history: history,
          onRestore: () => _restoreRecipe(history.id!),
        );
      },
    );
  }
}