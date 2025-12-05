/// 즐겨찾기 프리셋 화면
/// 사용자의 즐겨찾기 프리셋을 관리하고 사용할 수 있는 화면입니다.

library favorite_presets_screen;

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/favorite_preset.dart';
import '../services/favorite_preset_service.dart';

class FavoritePresetsScreen extends StatefulWidget {
  const FavoritePresetsScreen({super.key});

  @override
  State<FavoritePresetsScreen> createState() => _FavoritePresetsScreenState();
}

class _FavoritePresetsScreenState extends State<FavoritePresetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<FavoritePreset> _favorites = [];
  FavoritePresetStats? _stats;
  bool _isLoading = true;

  FavoritePresetFilter _currentFilter = const FavoritePresetFilter();
  FavoritePresetSortOption _sortOption = FavoritePresetSortOption.popularity;

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
      final favorites =
          await FavoritePresetService.instance.getSortedFavorites(_sortOption);
      final stats = await FavoritePresetService.instance.getStats();

      setState(() {
        _favorites = favorites;
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
        title: Text(AppLocalizations.of(context)!.favoritePresets),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: '즐겨찾기'),
            Tab(icon: Icon(Icons.analytics), text: '통계'),
            Tab(icon: Icon(Icons.auto_awesome), text: '추천'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: '정렬',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) {
              final l10nMenu = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                    value: 'add_custom', child: Text(l10nMenu.addCustomPreset)),
                PopupMenuItem(value: 'export', child: Text(l10nMenu.exportAction)),
                PopupMenuItem(value: 'import', child: Text(l10nMenu.importAction)),
                PopupMenuItem(value: 'cleanup', child: Text(l10nMenu.cleanupAction)),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesTab(),
                _buildStatsTab(),
                _buildRecommendationsTab(),
              ],
            ),
    );
  }

  /// 즐겨찾기 탭
  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 즐겨찾기가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '수쉐프 모드에서 프리셋을 즐겨찾기에 추가해보세요',
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
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildFavoriteCard(favorite);
        },
      ),
    );
  }

  /// 즐겨찾기 카드
  Widget _buildFavoriteCard(FavoritePreset favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showFavoriteDetail(favorite),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(favorite.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      favorite.type.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: favorite.quality.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      favorite.quality.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleFavoriteAction(action, favorite),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'use', child: Text('사용하기')),
                      const PopupMenuItem(value: 'edit', child: Text('수정')),
                      const PopupMenuItem(
                          value: 'duplicate', child: Text('복제')),
                      const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 제목과 설명
              Text(
                favorite.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                favorite.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 통계 정보
              Row(
                children: [
                  _buildStatChip(
                    Icons.trending_up,
                    '성공률: ${(favorite.successRate * 100).toInt()}%',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.star,
                    '개선도: ${(favorite.averageImprovementScore * 100).toInt()}%',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.repeat,
                    '${favorite.usageCount}회',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 환경 조건과 태그
              Row(
                children: [
                  Icon(Icons.thermostat, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    favorite.environmentSummary,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (favorite.isRecentlyUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '최근 사용',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          _buildTopPerformersCard(),
          const SizedBox(height: 16),
          _buildMostUsedCard(),
          const SizedBox(height: 16),
          _buildCategoryDistributionCard(),
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
                    '총 즐겨찾기',
                    '${_stats!.totalPresets}개',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '커스텀',
                    '${_stats!.customPresets}개',
                    Icons.build,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '평균 성공률',
                    '${(_stats!.averageSuccessRate * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '평균 개선도',
                    '${(_stats!.averageImprovementScore * 100).toInt()}%',
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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

  /// 추천 탭
  Widget _buildRecommendationsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FavoritePresetService.instance.getAutoFavoriteRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  '추천을 불러오는 중 오류가 발생했습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final recommendations = snapshot.data ?? [];

        if (recommendations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '아직 추천할 프리셋이 없습니다',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '수쉐프 모드를 더 사용하면 맞춤 추천을 받을 수 있습니다',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            return _buildRecommendationCard(recommendation);
          },
        );
      },
    );
  }

  /// 추천 카드
  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    final confidence = recommendation['confidence'] as double;
    final successCount = recommendation['successCount'] as int;
    final avgImprovement = recommendation['averageImprovement'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation['name'] as String,
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
                    color: _getConfidenceColor(confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '신뢰도 ${(confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // 환경 조건
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추천 환경 조건',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildEnvItem(
                          '온도',
                          '${recommendation['environmentalConditions']['temperature']}°C',
                          Icons.thermostat,
                          Colors.red),
                      const SizedBox(width: 16),
                      _buildEnvItem(
                          '습도',
                          '${recommendation['environmentalConditions']['humidity']}%',
                          Icons.water_drop,
                          Colors.blue),
                      const SizedBox(width: 16),
                      _buildEnvItem(
                          '고도',
                          '${recommendation['environmentalConditions']['altitude']}m',
                          Icons.landscape,
                          Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 통계 정보
            Row(
              children: [
                Text('성공 사례: ${successCount}회'),
                const SizedBox(width: 16),
                Text('평균 개선도: ${(avgImprovement * 100).toInt()}%'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      _createFavoriteFromRecommendation(recommendation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('즐겨찾기 추가'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvItem(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 나머지 메서드들
  Widget _buildTopPerformersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const Text(
                  '최고 성과 프리셋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stats!.topPerformers.isEmpty)
              const Text('아직 성과 데이터가 없습니다.')
            else
              ..._stats!.topPerformers.take(3).map(
                    (preset) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: preset.quality.color,
                        child: Text(
                          '${(_stats!.topPerformers.indexOf(preset) + 1)}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(preset.name),
                      subtitle:
                          Text('성공률: ${(preset.successRate * 100).toInt()}%'),
                      trailing: Text('${preset.usageCount}회'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUsedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.repeat, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  '자주 사용하는 프리셋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stats!.mostUsed.isEmpty)
              const Text('아직 사용 데이터가 없습니다.')
            else
              ..._stats!.mostUsed.take(3).map(
                    (preset) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          '${preset.usageCount}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(preset.name),
                      subtitle: Text(preset.category),
                      trailing: Text('${(preset.successRate * 100).toInt()}%'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionCard() {
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
                  '카테고리별 분포',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._stats!.categoryDistribution.entries.map((entry) {
              final percentage =
                  (entry.value / _stats!.totalPresets * 100).toInt();
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
                        value: entry.value / _stats!.totalPresets,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade400),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}개 ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

// 유틸리티 메서드들
  Color _getTypeColor(FavoritePresetType type) {
    switch (type) {
      case FavoritePresetType.standard:
        return Colors.blue.shade600;
      case FavoritePresetType.custom:
        return Colors.green.shade600;
      case FavoritePresetType.hybrid:
        return Colors.purple.shade600;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green.shade600;
    if (confidence >= 0.6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  // 액션 메서드들
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정렬 기준'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FavoritePresetSortOption.values.map((option) {
            return RadioListTile<FavoritePresetSortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOption = value);
                  Navigator.of(context).pop();
                  _loadData();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    _showInfoDialog('필터 기능은 곧 추가될 예정입니다.');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_custom':
        _showCustomPresetDialog();
        break;
      case 'export':
        _exportFavorites();
        break;
      case 'import':
        _importFavorites();
        break;
      case 'cleanup':
        _cleanupFavorites();
        break;
    }
  }

  void _handleFavoriteAction(String action, FavoritePreset favorite) {
    switch (action) {
      case 'use':
        _useFavorite(favorite);
        break;
      case 'edit':
        _editFavorite(favorite);
        break;
      case 'duplicate':
        _duplicateFavorite(favorite);
        break;
      case 'delete':
        _deleteFavorite(favorite);
        break;
    }
  }

  void _showFavoriteDetail(FavoritePreset favorite) {
    _showInfoDialog('상세 정보 기능은 곧 추가될 예정입니다.');
  }

  void _showCustomPresetDialog() {
    _showInfoDialog('커스텀 프리셋 생성 기능은 곧 추가될 예정입니다.');
  }

  void _useFavorite(FavoritePreset favorite) {
    Navigator.pop(context, favorite);
  }

  void _editFavorite(FavoritePreset favorite) {
    _showInfoDialog('프리셋 수정 기능은 곧 추가될 예정입니다.');
  }

  void _duplicateFavorite(FavoritePreset favorite) async {
    try {
      await FavoritePresetService.instance.duplicateFavorite(favorite.id);
      _loadData();
      _showInfoDialog('프리셋이 복제되었습니다.');
    } catch (e) {
      _showErrorDialog('복제 중 오류가 발생했습니다: $e');
    }
  }

  void _deleteFavorite(FavoritePreset favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기 삭제'),
        content: Text('${favorite.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FavoritePresetService.instance
                    .deleteFavorite(favorite.id);
                _loadData();
                _showInfoDialog('즐겨찾기가 삭제되었습니다.');
              } catch (e) {
                _showErrorDialog('삭제 중 오류가 발생했습니다: $e');
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _createFavoriteFromRecommendation(
      Map<String, dynamic> recommendation) async {
    try {
      await FavoritePresetService.instance.createCustomPreset(
        name: recommendation['name'] as String,
        description: recommendation['description'] as String,
        category: recommendation['category'] as String,
        presetData: {
          'type': 'auto_recommendation',
          'successCount': recommendation['successCount'],
          'confidence': recommendation['confidence'],
        },
        environmentalConditions: Map<String, dynamic>.from(
          recommendation['environmentalConditions'] as Map,
        ),
        tags: ['추천', '자동생성'],
      );

      _loadData();
      _showInfoDialog('추천 프리셋이 즐겨찾기에 추가되었습니다.');
    } catch (e) {
      _showErrorDialog('즐겨찾기 추가 중 오류가 발생했습니다: $e');
    }
  }

  void _exportFavorites() async {
    try {
      final jsonString = await FavoritePresetService.instance.exportFavorites();
      _showInfoDialog('즐겨찾기가 내보내기되었습니다.');
    } catch (e) {
      _showErrorDialog('내보내기 중 오류가 발생했습니다: $e');
    }
  }

  void _importFavorites() {
    _showInfoDialog('가져오기 기능은 곧 추가될 예정입니다.');
  }

  void _cleanupFavorites() async {
    try {
      await FavoritePresetService.instance.cleanupUnusedFavorites();
      _loadData();
      _showInfoDialog('사용하지 않는 즐겨찾기가 정리되었습니다.');
    } catch (e) {
      _showErrorDialog('정리 중 오류가 발생했습니다: $e');
    }
  }

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
