// 프리셋 관리 다이얼로그

import 'package:flutter/material.dart';
import '../../models/sous_chef_models.dart';
import '../../services/sous_chef_database.dart';

class PresetManagementDialog extends StatefulWidget {
  final BakingType bakingType;
  final Map<String, dynamic>? currentOptions;
  final Function(SousChefPreset) onPresetSelected;

  const PresetManagementDialog({
    Key? key,
    required this.bakingType,
    this.currentOptions,
    required this.onPresetSelected,
  }) : super(key: key);

  @override
  State<PresetManagementDialog> createState() => _PresetManagementDialogState();
}

class _PresetManagementDialogState extends State<PresetManagementDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SousChefPreset> _allPresets = [];
  List<SousChefPreset> _filteredPresets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPresets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    setState(() => _isLoading = true);
    
    try {
      _allPresets = SousChefDatabase.getPresetsByBakingType(widget.bakingType);
      _filteredPresets = _allPresets;
    } catch (e) {
      print('프리셋 로드 실패: $e');
      _allPresets = [];
      _filteredPresets = [];
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetList(),
                  _buildPopularPresets(),
                  _buildSaveNewPreset(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark, color: Colors.purple.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프리셋 관리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                Text(
                  _getBakingTypeName(widget.bakingType),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.purple.shade700,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.purple.shade600,
        tabs: const [
          Tab(text: '내 프리셋'),
          Tab(text: '인기 프리셋'),
          Tab(text: '새로 저장'),
        ],
      ),
    );
  }

  Widget _buildPresetList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredPresets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 프리셋이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 프리셋을 저장해보세요',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPresets.length,
      itemBuilder: (context, index) {
        final preset = _filteredPresets[index];
        return _buildPresetCard(preset);
      },
    );
  }

  Widget _buildPopularPresets() {
    final popularPresets = SousChefDatabase.getPopularPresets();
    
    if (popularPresets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '인기 프리셋이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: popularPresets.length,
      itemBuilder: (context, index) {
        final preset = popularPresets[index];
        return _buildPresetCard(preset, showStats: true);
      },
    );
  }

  Widget _buildSaveNewPreset() {
    if (widget.currentOptions == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '저장할 설정이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '먼저 옵션을 설정해주세요',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return _buildSavePresetForm();
  }

  Widget _buildPresetCard(SousChefPreset preset, {bool showStats = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onPresetSelected(preset);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPresetColor(preset.colorTag),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preset.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (showStats) ...[
                    Icon(Icons.trending_up, size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${preset.usageCount}회',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (value) => _handlePresetAction(value, preset),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('수정')),
                      const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (preset.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: preset.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: const TextStyle(fontSize: 10),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(preset.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (showStats) ...[
                    const Spacer(),
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${(preset.successRate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavePresetForm() {
    final nameController = TextEditingController();
    final tagsController = TextEditingController();
    String selectedColor = 'blue';

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '프리셋 이름',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: '태그 (쉼표로 구분)',
                  hintText: '예: 겨울용, 고온, 습한날씨',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '색상 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['red', 'blue', 'green', 'orange', 'purple', 'teal']
                    .map((color) => GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getPresetColor(color),
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveNewPreset(
                    nameController.text,
                    tagsController.text,
                    selectedColor,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('프리셋 저장'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePresetAction(String action, SousChefPreset preset) {
    switch (action) {
      case 'edit':
        // 편집 기능 (추후 구현)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('편집 기능은 추후 구현됩니다')),
        );
        break;
      case 'delete':
        _deletePreset(preset);
        break;
    }
  }

  Future<void> _deletePreset(SousChefPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: Text('${preset.name} 프리셋을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SousChefDatabase.deletePreset(preset.id);
        await _loadPresets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프리셋이 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveNewPreset(String name, String tagsText, String colorTag) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력해주세요')),
      );
      return;
    }

    final tags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final preset = SousChefPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      colorTag: colorTag,
      tags: tags,
      options: widget.currentOptions!,
      createdAt: DateTime.now(),
    );

    try {
      await SousChefDatabase.savePreset(preset);
      await _loadPresets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프리셋이 저장되었습니다')),
        );
        _tabController.animateTo(0); // 내 프리셋 탭으로 이동
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  String _getBakingTypeName(BakingType type) {
    switch (type) {
      case BakingType.bread:
        return '빵';
      case BakingType.cake:
        return '케이크';
      case BakingType.cookie:
        return '쿠키';
      case BakingType.fried:
        return '튀김';
      case BakingType.dessertHot:
        return '온 디저트';
      case BakingType.dessertCold:
        return '냉 디저트';
      case BakingType.frozenDessert:
        return '냉동 디저트';
      case BakingType.iceCream:
        return '아이스크림';
      case BakingType.gelato:
        return '젤라토';
      case BakingType.candy:
        return '사탕';
      case BakingType.etc:
        return '기타';
    }
  }

  Color _getPresetColor(String colorTag) {
    switch (colorTag.toLowerCase()) {
      case 'red':
        return Colors.red.shade600;
      case 'blue':
        return Colors.blue.shade600;
      case 'green':
        return Colors.green.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'purple':
        return Colors.purple.shade600;
      case 'teal':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}