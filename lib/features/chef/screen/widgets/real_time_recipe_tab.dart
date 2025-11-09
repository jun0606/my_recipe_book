// 실시간 레시피 탭 위젯
// 실시간 레시피 표시 및 관리 UI 컴포넌트

import 'package:flutter/material.dart';

class RealTimeRecipeTab extends StatefulWidget {
  const RealTimeRecipeTab({super.key});

  @override
  State<RealTimeRecipeTab> createState() => _RealTimeRecipeTabState();
}

class _RealTimeRecipeTabState extends State<RealTimeRecipeTab> {
  final List<Map<String, dynamic>> _realTimeRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRealTimeRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Text(
                '🍞 실시간 레시피',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _refreshRecipes,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: '새로고침',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 실시간 레시피 목록
          if (_realTimeRecipes.isEmpty && !_isLoading) ...[
            _buildEmptyState(),
          ] else if (_isLoading) ...[
            _buildLoadingState(),
          ] else ...[
            _buildRecipeList(),
          ],

          const SizedBox(height: 16),

          // 실시간 피드백 섹션
          _buildRealTimeFeedback(),

          const SizedBox(height: 16),

          // 추천 레시피 섹션
          _buildRecommendedRecipes(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '실시간 레시피가 준비 중입니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 다양한 실시간 레시피를 만나보실 수 있습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshRecipes,
            icon: const Icon(Icons.refresh),
            label: const Text('새로고침'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[100],
              foregroundColor: Colors.pink[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '실시간 레시피를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 추천 (${_realTimeRecipes.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ..._realTimeRecipes.map((recipe) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecipeCard(recipe),
            )),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe['title']?.toString() ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe['confidence']?.toString() ?? '85%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recipe['description']?.toString() ?? '설명 없음',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  recipe['estimatedTime']?.toString() ?? '30분',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  recipe['difficulty']?.toString() ?? '중급',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startRecipe(recipe),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('시작하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[100],
                      foregroundColor: Colors.pink[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _saveRecipe(recipe),
                  icon: const Icon(Icons.bookmark_border),
                  tooltip: '저장하기',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeFeedback() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💬 실시간 피드백',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: const Text(
                '실시간 피드백 시스템이 준비 중입니다.\n'
                '레시피 진행 중 유용한 팁과 조언을 제공해드립니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedRecipes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ 추천 레시피',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecommendedRecipeItem(
              '클래식 바게트',
              '전통적인 프랑스식 바게트 만들기',
              '고급',
            ),
            const SizedBox(height: 8),
            _buildRecommendedRecipeItem(
              '사워도우',
              '천연 효모로 만드는 건강한 빵',
              '중급',
            ),
            const SizedBox(height: 8),
            _buildRecommendedRecipeItem(
              '크루아상',
              '버터 풍미가 가득한 크루아상',
              '고급',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedRecipeItem(
      String title, String description, String difficulty) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              difficulty,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadRealTimeRecipes() async {
    setState(() => _isLoading = true);

    // 실제로는 서버나 로컬 데이터베이스에서 로드
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _realTimeRecipes.addAll([
          {
            'id': '1',
            'title': '완벽한 크루아상',
            'description': '바삭한 껍질과 부드러운 내부가 특징인 프랑스 전통 빵',
            'confidence': '92%',
            'estimatedTime': '3시간',
            'difficulty': '고급',
            'tags': ['프랑스', '바삭함', '버터'],
          },
          {
            'id': '2',
            'title': '홈메이드 사워도우',
            'description': '천연 효모로 만드는 건강하고 풍미 있는 빵',
            'confidence': '88%',
            'estimatedTime': '24시간',
            'difficulty': '중급',
            'tags': ['건강', '천연', '효모'],
          },
          {
            'id': '3',
            'title': '빠른 바게트',
            'description': '1시간 만에 완성하는 간단한 바게트 레시피',
            'confidence': '85%',
            'estimatedTime': '1시간',
            'difficulty': '초급',
            'tags': ['빠른', '간단', '프랑스'],
          },
        ]);
        _isLoading = false;
      });
    }
  }

  void _refreshRecipes() {
    setState(() {
      _realTimeRecipes.clear();
      _isLoading = true;
    });
    _loadRealTimeRecipes();
  }

  void _startRecipe(Map<String, dynamic> recipe) {
    // 레시피 시작 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe['title']} 레시피를 시작합니다!'),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _saveRecipe(Map<String, dynamic> recipe) {
    // 레시피 저장 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe['title']} 레시피가 저장되었습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
