/// 가이드 목록 위젯
/// 활성 가이드와 히스토리를 관리하는 UI 컴포넌트

import 'package:flutter/material.dart';
import '../../services/user_guide_system.dart';
import '../../models/fermentation_scenario_v2.dart' as fermentation_scenario_v2;
import 'user_guide_widget.dart';

class GuideListWidget extends StatefulWidget {
  final UserGuideSystem guideSystem;
  final Function(UserGuide)? onGuideSelected;
  final bool showHistory;
  final bool allowCreate;

  const GuideListWidget({
    Key? key,
    required this.guideSystem,
    this.onGuideSelected,
    this.showHistory = true,
    this.allowCreate = true,
  }) : super(key: key);

  @override
  State<GuideListWidget> createState() => _GuideListWidgetState();
}

class _GuideListWidgetState extends State<GuideListWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.showHistory ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showHistory) _buildTabBar(),
        Expanded(
          child: widget.showHistory
              ? _buildTabBarView()
              : _buildActiveGuides(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(
            icon: const Icon(Icons.play_circle_outline),
            text: '진행 중 (${widget.guideSystem.activeGuides.length})',
          ),
          Tab(
            icon: const Icon(Icons.history),
            text: '완료됨 (${widget.guideSystem.guideHistory.length})',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildActiveGuides(),
        _buildGuideHistory(),
      ],
    );
  }

  Widget _buildActiveGuides() {
    final activeGuides = widget.guideSystem.activeGuides;

    if (activeGuides.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: '진행 중인 가이드가 없습니다',
        subtitle: widget.allowCreate 
            ? '새로운 가이드를 생성하여 시작하세요'
            : '가이드가 생성되면 여기에 표시됩니다',
        showCreateButton: widget.allowCreate,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGuides.length,
      itemBuilder: (context, index) {
        final guide = activeGuides[index];
        return _buildGuideCard(guide, isActive: true);
      },
    );
  }

  Widget _buildGuideHistory() {
    final guideHistory = widget.guideSystem.guideHistory;

    if (guideHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: '완료된 가이드가 없습니다',
        subtitle: '가이드를 완료하면 여기에 기록됩니다',
        showCreateButton: false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guideHistory.length,
      itemBuilder: (context, index) {
        final guide = guideHistory[guideHistory.length - 1 - index]; // 최신순
        return _buildGuideCard(guide, isActive: false);
      },
    );
  }

  Widget _buildGuideCard(UserGuide guide, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => widget.onGuideSelected?.call(guide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getGuideTypeColor(guide.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getGuideTypeIcon(guide.type),
                      color: _getGuideTypeColor(guide.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          guide.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, guide),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('보기'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('삭제', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (isActive) ...[
                // 진행률 표시
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: guide.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getGuideTypeColor(guide.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(guide.progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${guide.completedStepsCount}/${guide.steps.length} 단계 완료',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDuration(guide.estimatedRemainingTime)} 남음',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // 완료 정보 표시
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '완료됨',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(guide.updatedAt ?? guide.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              // 가이드 타입 및 컨텍스트 정보
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    _getGuideTypeText(guide.type),
                    _getGuideTypeColor(guide.type),
                  ),
                  if (guide.context.containsKey('recipeId'))
                    _buildInfoChip(
                      guide.context['recipeId'],
                      Colors.blue,
                    ),
                  if (guide.context.containsKey('fermenterType'))
                    _buildInfoChip(
                      guide.context['fermenterType'] == 'smart' ? '스마트 발효기' : '일반 발효기',
                      Colors.purple,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showCreateButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (showCreateButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateGuideDialog,
                icon: const Icon(Icons.add),
                label: const Text('가이드 생성'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, UserGuide guide) {
    switch (action) {
      case 'view':
        widget.onGuideSelected?.call(guide);
        break;
      case 'delete':
        _showDeleteConfirmDialog(guide);
        break;
    }
  }

  void _showDeleteConfirmDialog(UserGuide guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가이드 삭제'),
        content: Text('${guide.title} 가이드를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGuide(guide);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _deleteGuide(UserGuide guide) async {
    try {
      await widget.guideSystem.removeGuide(guide.id);
      setState(() {}); // 목록 새로고침
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${guide.title} 가이드가 삭제되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('가이드 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 가이드 생성'),
        content: const Text('어떤 종류의 가이드를 생성하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createSetupGuide();
            },
            child: const Text('발효기 설정'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createMaintenanceGuide();
            },
            child: const Text('유지 관리'),
          ),
        ],
      ),
    );
  }

  void _createSetupGuide() {
    // TODO: 발효기 설정 가이드 생성 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('발효기 설정 가이드 생성 기능은 준비 중입니다'),
      ),
    );
  }

  void _createMaintenanceGuide() async {
    try {
      await widget.guideSystem.createMaintenanceGuide(
        fermenterType: fermentation_scenario_v2.FermenterType.smart, // 기본값
      );
      setState(() {}); // 목록 새로고침
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유지 관리 가이드가 생성되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('가이드 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getGuideTypeColor(GuideType type) {
    switch (type) {
      case GuideType.setup:
        return Colors.blue;
      case GuideType.fermentation:
        return Colors.green;
      case GuideType.troubleshooting:
        return Colors.orange;
      case GuideType.maintenance:
        return Colors.purple;
      case GuideType.safety:
        return Colors.red;
    }
  }

  IconData _getGuideTypeIcon(GuideType type) {
    switch (type) {
      case GuideType.setup:
        return Icons.settings;
      case GuideType.fermentation:
        return Icons.timeline;
      case GuideType.troubleshooting:
        return Icons.build;
      case GuideType.maintenance:
        return Icons.cleaning_services;
      case GuideType.safety:
        return Icons.security;
    }
  }

  String _getGuideTypeText(GuideType type) {
    switch (type) {
      case GuideType.setup:
        return '설정';
      case GuideType.fermentation:
        return '발효';
      case GuideType.troubleshooting:
        return '문제해결';
      case GuideType.maintenance:
        return '유지관리';
      case GuideType.safety:
        return '안전';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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