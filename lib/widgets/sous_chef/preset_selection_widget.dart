/// 프리셋 선택 위젯
/// 다양한 베이킹 프리셋을 선택할 수 있는 UI를 제공합니다.

import 'package:flutter/material.dart';
import '../../services/recipe_preset_manager.dart';
import '../../services/favorite_preset_service.dart';
import '../../models/favorite_preset.dart';
import '../../models/recipe_target.dart';
import '../../screens/favorite_presets_screen.dart';

class PresetSelectionWidget extends StatefulWidget {
  final Function(RecipePreset) onPresetSelected;
  final RecipePreset? selectedPreset;

  const PresetSelectionWidget({
    super.key,
    required this.onPresetSelected,
    this.selectedPreset,
  });

  @override
  State<PresetSelectionWidget> createState() => _PresetSelectionWidgetState();
}

class _PresetSelectionWidgetState extends State<PresetSelectionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '전체';
  List<RecipePreset> _allPresets = [];
  List<RecipePreset> _filteredPresets = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Show favorites screen
  void _showFavoritesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritePresetsScreen(),
      ),
    );
  }

  /// Use favorite preset
  void _useFavoritePreset(FavoritePreset favorite) async {
    try {
      // Update usage record
      await FavoritePresetService.instance.updateFavoriteUsage(favorite.id);
      
      // Convert to standard preset and use
      if (favorite.originalPresetId != null) {
        final standardPreset = RecipePresetManager.getPresetById(favorite.originalPresetId!);
        if (standardPreset != null) {
          widget.onPresetSelected(standardPreset);
        }
      } else {
        // For custom presets, create temporary preset based on data
        final tempPreset = _createTempPresetFromFavorite(favorite);
        widget.onPresetSelected(tempPreset);
      }
    } catch (e) {
      _showErrorDialog('Error using favorite preset: $e');
    }
  }

  /// Create temporary preset from favorite
  RecipePreset _createTempPresetFromFavorite(FavoritePreset favorite) {
    // Create temporary object compatible with RecipePreset
    return RecipePreset(
      id: favorite.id,
      name: favorite.name,
      description: favorite.description,
      category: favorite.category,
      target: const RecipeTarget(), // default target
      tags: favorite.tags,
      estimatedTime: 120, // default value
      difficulty: PresetDifficulty.intermediate, // default value
      keyFeatures: ['Favorite Preset'],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _loadPresets() {
    _allPresets = RecipePresetManager.getAllPresets();
    _categories = ['전체', ...RecipePresetManager.getAllCategories()];
    _filterPresets();
  }

  void _filterPresets() {
    if (_selectedCategory == '전체') {
      _filteredPresets = _allPresets;
    } else {
      _filteredPresets = RecipePresetManager.getPresetsByCategory(_selectedCategory);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.bookmark, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  '프리셋 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 탭 바
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange.shade600,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.orange.shade600,
            isScrollable: true,
            tabs: const [
              Tab(text: '즐겨찾기'),
              Tab(text: '인기'),
              Tab(text: '카테고리'),
              Tab(text: '난이도'),
            ],
          ),
          
          // 탭 뷰 - 동적 높이 계산으로 오버플로우 방지
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesTab(),
                _buildPopularTab(),
                _buildCategoryTab(),
                _buildDifficultyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 즐겨찾기 탭
  Widget _buildFavoritesTab() {
    return FutureBuilder<List<FavoritePreset>>(
      future: FavoritePresetService.instance.getPopularFavorites(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text('즐겨찾기를 불러올 수 없습니다'),
              ],
            ),
          );
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  '아직 즐겨찾기가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '프리셋을 사용한 후 즐겨찾기에 추가해보세요',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showFavoritesScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('즐겨찾기 관리'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '내 즐겨찾기 프리셋',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _showFavoritesScreen,
                    child: const Text('전체 보기'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return _buildFavoritePresetCard(favorite);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 즐겨찾기 프리셋 카드
  Widget _buildFavoritePresetCard(FavoritePreset favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _useFavoritePreset(favorite),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: favorite.quality.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          favorite.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(favorite.successRate * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: favorite.quality.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${favorite.usageCount}회',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    favorite.environmentSummary,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (favorite.isRecentlyUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '최근',
                        style: TextStyle(
                          fontSize: 8,
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

  /// 인기 프리셋 탭
  Widget _buildPopularTab() {
    final popularPresets = RecipePresetManager.getPopularPresets();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '초보자에게 추천하는 인기 프리셋',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: popularPresets.length,
              itemBuilder: (context, index) {
                final preset = popularPresets[index];
                return _buildPresetCard(preset, isPopular: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 탭
  Widget _buildCategoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 카테고리 선택
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterPresets();
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                    checkmarkColor: Colors.orange.shade600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // 프리셋 목록
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPresets.length,
              itemBuilder: (context, index) {
                final preset = _filteredPresets[index];
                return _buildPresetCard(preset);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 난이도별 탭
  Widget _buildDifficultyTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 난이도별 섹션
          Expanded(
            child: ListView(
              children: [
                _buildDifficultySection('초급', PresetDifficulty.beginner),
                const SizedBox(height: 16),
                _buildDifficultySection('중급', PresetDifficulty.intermediate),
                const SizedBox(height: 16),
                _buildDifficultySection('고급', PresetDifficulty.advanced),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 난이도별 섹션
  Widget _buildDifficultySection(String title, PresetDifficulty difficulty) {
    final presets = RecipePresetManager.getPresetsByDifficulty(difficulty);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...presets.map((preset) => _buildPresetCard(preset, isCompact: true)),
      ],
    );
  }

  /// 프리셋 카드
  Widget _buildPresetCard(RecipePreset preset, {bool isPopular = false, bool isCompact = false}) {
    final isSelected = widget.selectedPreset?.id == preset.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: isSelected ? Colors.orange.shade50 : null,
      child: InkWell(
        onTap: () => widget.onPresetSelected(preset),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  // 프리셋 아이콘
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(preset.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(preset.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 프리셋 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                preset.name,
                                style: TextStyle(
                                  fontSize: isCompact ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.orange.shade700 : null,
                                ),
                              ),
                            ),
                            if (isPopular) ...[
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.orange.shade600,
                              ),
                          ],
                        ),
                        Text(
                          preset.description,
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // 태그
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: preset.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 8),
                
                // 메타 정보
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${preset.estimatedTime}분',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.bar_chart,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      preset.difficulty.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 주요 특징
                Text(
                  '특징: ${preset.keyFeatures.take(2).join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 카테고리 색상
  Color _getCategoryColor(String category) {
    switch (category) {
      case '식빵': return Colors.brown.shade400;
      case '케이크': return Colors.pink.shade400;
      case '쿠키': return Colors.amber.shade600;
      case '브리오슈': return Colors.orange.shade400;
      case '단빵': return Colors.purple.shade400;
      case '하드브레드': return Colors.grey.shade600;
      case '건강빵': return Colors.green.shade400;
      default: return Colors.blue.shade400;
    }
  }

  /// 카테고리 아이콘
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식빵': return Icons.bakery_dining;
      case '케이크': return Icons.cake;
      case '쿠키': return Icons.cookie;
      case '브리오슈': return Icons.breakfast_dining;
      case '단빵': return Icons.local_dining;
      case '하드브레드': return Icons.grain;
      case '건강빵': return Icons.eco;
      default: return Icons.restaurant;
    }
  }
}

/// 프리셋 상세 정보 다이얼로그
class PresetDetailDialog extends StatelessWidget {
  final RecipePreset preset;

  const PresetDetailDialog({
    super.key,
    required this.preset,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(preset.category),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(preset.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              preset.name,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              preset.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 기본 정보
            _buildInfoRow('카테고리', preset.category),
            _buildInfoRow('난이도', preset.difficulty.displayName),
            _buildInfoRow('예상 시간', '${preset.estimatedTime}분'),
            
            const SizedBox(height: 16),
            
            // 태그
            const Text(
              '태그',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: preset.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 주요 특징
            const Text(
              '주요 특징',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...preset.keyFeatures.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(feature)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(preset);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('선택'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '식빵': return Colors.brown.shade400;
      case '케이크': return Colors.pink.shade400;
      case '쿠키': return Colors.amber.shade600;
      case '브리오슈': return Colors.orange.shade400;
      case '단빵': return Colors.purple.shade400;
      case '하드브레드': return Colors.grey.shade600;
      case '건강빵': return Colors.green.shade400;
      default: return Colors.blue.shade400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식빵': return Icons.bakery_dining;
      case '케이크': return Icons.cake;
      case '쿠키': return Icons.cookie;
      case '브리오슈': return Icons.breakfast_dining;
      case '단빵': return Icons.local_dining;
      case '하드브레드': return Icons.grain;
      case '건강빵': return Icons.eco;
      default: return Icons.restaurant;
    }
  }
}

/// 프리셋 선택 헬퍼 함수
class PresetSelectionHelper {
  /// 프리셋 선택 다이얼로그 표시
  static Future<RecipePreset?> showPresetSelectionDialog(BuildContext context) {
    return showDialog<RecipePreset>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: PresetSelectionWidget(
            onPresetSelected: (preset) {
              Navigator.of(context).pop(preset);
            },
          ),
        ),
      ),
    );
  }

  /// 프리셋 상세 정보 다이얼로그 표시
  static Future<RecipePreset?> showPresetDetailDialog(
    BuildContext context, 
    RecipePreset preset
  ) {
    return showDialog<RecipePreset>(
      context: context,
      builder: (context) => PresetDetailDialog(preset: preset),
    );
  }
}