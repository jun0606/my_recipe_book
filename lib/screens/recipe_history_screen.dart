/// 레시피 히스토리 화면
/// 수쉐프 모드 사용 기록을 조회하고 분석할 수 있는 화면입니다.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recipe_history.dart';
import '../services/recipe_history_service.dart';

class RecipeHistoryScreen extends StatefulWidget {
  const RecipeHistoryScreen({super.key});

  @override
  State<RecipeHistoryScreen> createState() => _RecipeHistoryScreenState();
}

class _RecipeHistoryScreenState extends State<RecipeHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<RecipeHistory> _histories = [];
  RecipeHistoryStats? _stats;
  bool _isLoading = true;
  
  RecipeHistoryFilter _currentFilter = const RecipeHistoryFilter();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final histories = await RecipeHistoryService.instance.getFilteredHistories(_currentFilter);
      final stats = await RecipeHistoryService.instance.getStats();
      
      setState(() {
        _histories = histories;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('데이터 로드 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 히스토리'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: '기록'),
            Tab(icon: Icon(Icons.analytics), text: '통계'),
            Tab(icon: Icon(Icons.insights), text: '인사이트'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Text('내보내기')),
              const PopupMenuItem(value: 'import', child: Text('가져오기')),
              const PopupMenuItem(value: 'clear', child: Text('전체 삭제')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildStatsTab(),
                _buildInsightsTab(),
              ],
            ),
    );
  }

  /// 히스토리 탭
  Widget _buildHistoryTab() {
    if (_histories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 히스토리가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '수쉐프 모드를 사용하면 기록이 저장됩니다',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          final history = _histories[index];
          return _buildHistoryCard(history);
        },
      ),
    );
  }

  /// 히스토리 카드
  Widget _buildHistoryCard(RecipeHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showHistoryDetail(history),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(history.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      history.type.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      history.recipeTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (history.isSuccessfulOptimization)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 정보
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    history.recipeCategory,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM/dd HH:mm').format(history.timestamp),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 개선 점수
              Row(
                children: [
                  const Text('개선도: '),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getScoreColor(history.improvementScore),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(history.improvementScore * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (history.mainImprovements.isNotEmpty) ...[
                    const Text('개선: '),
                    Text(
                      history.mainImprovements.join(', '),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              
              // 환경 조건
              const SizedBox(height: 8),
              Text(
                '환경: ${history.environmentSummary}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 통계 탭
  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatsCard(),
          const SizedBox(height: 16),
          _buildCategoryStatsCard(),
          const SizedBox(height: 16),
          _buildTypeStatsCard(),
          const SizedBox(height: 16),
          _buildEnvironmentStatsCard(),
        ],
      ),
    );
  }

  /// 전체 통계 카드
  Widget _buildOverallStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  '전체 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '총 최적화',
                    '${_stats!.totalOptimizations}회',
                    Icons.tune,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '성공률',
                    '${(_stats!.successRate * 100).toInt()}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '평균 개선도',
                    '${(_stats!.averageImprovementScore * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '성공 횟수',
                    '${_stats!.successfulOptimizations}회',
                    Icons.star,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 통계 카드
  Widget _buildCategoryStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  '카테고리별 사용량',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._stats!.categoryDistribution.entries.map((entry) {
              final percentage = (entry.value / _stats!.totalOptimizations * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / _stats!.totalOptimizations,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}회 ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 타입 통계 카드
  Widget _buildTypeStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  '기능별 사용량',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._stats!.typeDistribution.entries.map((entry) {
              final percentage = (entry.value / _stats!.totalOptimizations * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getTypeColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.key.displayName),
                    ),
                    Text('${entry.value}회 ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 환경 통계 카드
  Widget _buildEnvironmentStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  '선호 환경 조건',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEnvironmentItem(
                    '온도',
                    '${_stats!.environmentalPreferences['temperature']?.toInt() ?? 26}°C',
                    Icons.thermostat,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildEnvironmentItem(
                    '습도',
                    '${_stats!.environmentalPreferences['humidity']?.toInt() ?? 60}%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildEnvironmentItem(
                    '고도',
                    '${_stats!.environmentalPreferences['altitude']?.toInt() ?? 0}m',
                    Icons.landscape,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 인사이트 탭
  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopImprovementsCard(),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
          const SizedBox(height: 16),
          _buildTrendsCard(),
        ],
      ),
    );
  }

  /// 주요 개선 영역 카드
  Widget _buildTopImprovementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  '주요 개선 영역',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stats!.topImprovements.isEmpty)
              const Text('아직 개선 데이터가 충분하지 않습니다.')
            else
              ...List.generate(_stats!.topImprovements.length, (index) {
                final improvement = _stats!.topImprovements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        improvement,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 추천 사항 카드
  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const Text(
                  '개선 추천',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              '성공률 향상',
              _stats!.successRate < 0.7
                  ? '환경 조건을 더 정확히 입력해보세요'
                  : '훌륭한 성공률을 유지하고 있습니다!',
              _stats!.successRate < 0.7 ? Icons.warning : Icons.check_circle,
              _stats!.successRate < 0.7 ? Colors.orange : Colors.green,
            ),
            _buildRecommendationItem(
              '다양성 확대',
              _stats!.categoryDistribution.length < 3
                  ? '다양한 카테고리의 레시피를 시도해보세요'
                  : '다양한 레시피를 활용하고 있습니다!',
              _stats!.categoryDistribution.length < 3 ? Icons.explore : Icons.check_circle,
              _stats!.categoryDistribution.length < 3 ? Colors.blue : Colors.green,
            ),
            _buildRecommendationItem(
              '기능 활용',
              _stats!.typeDistribution.length < 2
                  ? '다른 수쉐프 기능들도 활용해보세요'
                  : '수쉐프의 다양한 기능을 잘 활용하고 있습니다!',
              _stats!.typeDistribution.length < 2 ? Icons.functions : Icons.check_circle,
              _stats!.typeDistribution.length < 2 ? Colors.purple : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 트렌드 카드
  Widget _buildTrendsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                const Text(
                  '사용 트렌드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '최근 활동이 증가하고 있습니다!\n'
              '꾸준한 사용으로 베이킹 실력이 향상되고 있어요.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// 히스토리 상세 보기
  void _showHistoryDetail(RecipeHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(history.recipeTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('타입', history.type.displayName),
              _buildDetailRow('카테고리', history.recipeCategory),
              _buildDetailRow('날짜', DateFormat('yyyy-MM-dd HH:mm').format(history.timestamp)),
              _buildDetailRow('개선도', '${(history.improvementScore * 100).toInt()}%'),
              _buildDetailRow('환경', history.environmentSummary),
              if (history.mainImprovements.isNotEmpty)
                _buildDetailRow('개선 영역', history.mainImprovements.join(', ')),
              const SizedBox(height: 16),
              const Text(
                '최적화 노트:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...history.optimizationNotes.map((note) => Text('• $note')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteHistory(history);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// 필터 다이얼로그
  void _showFilterDialog() {
    // TODO: 필터 다이얼로그 구현
    _showInfoDialog('필터 기능은 곧 추가될 예정입니다.');
  }

  /// 메뉴 액션 처리
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportHistories();
        break;
      case 'import':
        _importHistories();
        break;
      case 'clear':
        _clearAllHistories();
        break;
    }
  }

  /// 히스토리 내보내기
  void _exportHistories() async {
    try {
      final jsonString = await RecipeHistoryService.instance.exportHistories();
      // TODO: 파일 저장 또는 공유 기능 구현
      _showInfoDialog('히스토리가 내보내기되었습니다.');
    } catch (e) {
      _showErrorDialog('내보내기 중 오류가 발생했습니다: $e');
    }
  }

  /// 히스토리 가져오기
  void _importHistories() {
    // TODO: 파일 선택 및 가져오기 기능 구현
    _showInfoDialog('가져오기 기능은 곧 추가될 예정입니다.');
  }

  /// 전체 히스토리 삭제
  void _clearAllHistories() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 히스토리를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await RecipeHistoryService.instance.clearAllHistories();
              _loadData();
              _showInfoDialog('모든 히스토리가 삭제되었습니다.');
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 개별 히스토리 삭제
  void _deleteHistory(RecipeHistory history) async {
    try {
      await RecipeHistoryService.instance.deleteHistory(history.id);
      _loadData();
      _showInfoDialog('히스토리가 삭제되었습니다.');
    } catch (e) {
      _showErrorDialog('삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 타입별 색상
  Color _getTypeColor(RecipeHistoryType type) {
    switch (type) {
      case RecipeHistoryType.optimization:
        return Colors.blue.shade600;
      case RecipeHistoryType.reverseRecipe:
        return Colors.green.shade600;
      case RecipeHistoryType.presetGeneration:
        return Colors.orange.shade600;
      case RecipeHistoryType.targetBased:
        return Colors.purple.shade600;
    }
  }

  /// 점수별 색상
  Color _getScoreColor(double score) {
    if (score >= 0.7) return Colors.green.shade600;
    if (score >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 오류 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 정보 다이얼로그
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}