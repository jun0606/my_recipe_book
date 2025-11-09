/// 사용자 가이드 메인 화면
/// 통합 가이드 시스템의 중앙 허브

import 'package:flutter/material.dart';
import '../services/user_guide_system.dart';
import '../services/fermentation_notification_service.dart';
import '../widgets/user_guide/user_guide_widget.dart';
import '../widgets/user_guide/guide_list_widget.dart';
import '../widgets/user_guide/guide_settings_widget.dart';

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({Key? key}) : super(key: key);

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late UserGuideSystem _guideSystem;
  late FermentationNotificationService _notificationService;

  UserGuide? _selectedGuide;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _guideSystem = UserGuideSystem();
    _notificationService = FermentationNotificationService();
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _guideSystem.initialize();
      await _notificationService.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('사용자 가이드'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('가이드 시스템을 초기화하는 중...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('사용자 가이드'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '가이드 시스템 초기화 실패',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeServices,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedGuide != null) {
      return _buildGuideDetailScreen();
    }

    return _buildMainScreen();
  }

  Widget _buildMainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 가이드'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: '가이드 목록'),
            Tab(icon: Icon(Icons.dashboard), text: '대시보드'),
            Tab(icon: Icon(Icons.settings), text: '설정'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQuickActions,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '빠른 가이드 생성',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGuideListTab(),
          _buildDashboardTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildGuideDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGuide!.title),
        leading: IconButton(
          onPressed: () {
            setState(() {
              _selectedGuide = null;
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleGuideAction(value, _selectedGuide!),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('공유'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('내보내기'),
                  ],
                ),
              ),
              if (_guideSystem.activeGuides.contains(_selectedGuide))
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text('완료 처리'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: UserGuideWidget(
        guide: _selectedGuide!,
        onGuideComplete: () {
          _guideSystem.completeGuide(_selectedGuide!.id);
          setState(() {
            _selectedGuide = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('가이드가 완료되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onStepComplete: (stepId) {
          _guideSystem.completeStep(_selectedGuide!.id, stepId);
          setState(() {}); // 진행률 업데이트
        },
        showProgress: true,
        allowSkip: true,
      ),
    );
  }

  Widget _buildGuideListTab() {
    return GuideListWidget(
      guideSystem: _guideSystem,
      onGuideSelected: (guide) {
        setState(() {
          _selectedGuide = guide;
        });
      },
      showHistory: true,
      allowCreate: true,
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return GuideSettingsWidget(
      guideSystem: _guideSystem,
      notificationService: _notificationService,
    );
  }

  Widget _buildStatsCards() {
    final activeGuides = _guideSystem.activeGuides;
    final completedGuides = _guideSystem.guideHistory;
    final totalSteps = activeGuides.fold<int>(
      0,
      (sum, guide) => sum + guide.steps.length,
    );
    final completedSteps = activeGuides.fold<int>(
      0,
      (sum, guide) => sum + guide.completedStepsCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가이드 현황',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '진행 중',
                value: '${activeGuides.length}',
                subtitle: '개 가이드',
                color: Colors.blue,
                icon: Icons.play_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '완료됨',
                value: '${completedGuides.length}',
                subtitle: '개 가이드',
                color: Colors.green,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '전체 단계',
                value: '$totalSteps',
                subtitle: '개 단계',
                color: Colors.orange,
                icon: Icons.list_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '완료 단계',
                value: '$completedSteps',
                subtitle: '개 단계',
                color: Colors.purple,
                icon: Icons.done_all,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentGuides = [
      ..._guideSystem.activeGuides,
      ..._guideSystem.guideHistory.take(3),
    ].take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 활동',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (recentGuides.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '최근 활동이 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...recentGuides
              .map((guide) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _getGuideTypeColor(guide.type).withOpacity(0.1),
                        child: Icon(
                          _getGuideTypeIcon(guide.type),
                          color: _getGuideTypeColor(guide.type),
                        ),
                      ),
                      title: Text(guide.title),
                      subtitle: Text(
                        '${guide.completedStepsCount}/${guide.steps.length} 단계 완료',
                      ),
                      trailing: guide.progress == 1.0
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : CircularProgressIndicator(
                              value: guide.progress,
                              strokeWidth: 2,
                            ),
                      onTap: () {
                        setState(() {
                          _selectedGuide = guide;
                        });
                      },
                    ),
                  ))
              .toList(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              title: '발효기 설정',
              subtitle: '새 발효기 설정 가이드',
              icon: Icons.settings,
              color: Colors.blue,
              onTap: () => _createSetupGuide(),
            ),
            _buildQuickActionCard(
              title: '문제 해결',
              subtitle: '발효기 문제 해결',
              icon: Icons.build,
              color: Colors.orange,
              onTap: () => _createTroubleshootingGuide(),
            ),
            _buildQuickActionCard(
              title: '유지 관리',
              subtitle: '정기 유지 관리',
              icon: Icons.cleaning_services,
              color: Colors.purple,
              onTap: () => _createMaintenanceGuide(),
            ),
            _buildQuickActionCard(
              title: '알림 테스트',
              subtitle: '알림 기능 테스트',
              icon: Icons.notifications_active,
              color: Colors.green,
              onTap: () => _testNotifications(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '새 가이드 생성',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('발효기 설정 가이드'),
              subtitle: const Text('새로운 발효기 설정을 위한 단계별 가이드'),
              onTap: () {
                Navigator.pop(context);
                _createSetupGuide();
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.orange),
              title: const Text('문제 해결 가이드'),
              subtitle: const Text('발효기 문제 해결을 위한 가이드'),
              onTap: () {
                Navigator.pop(context);
                _createTroubleshootingGuide();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.cleaning_services, color: Colors.purple),
              title: const Text('유지 관리 가이드'),
              subtitle: const Text('발효기 정기 유지 관리 가이드'),
              onTap: () {
                Navigator.pop(context);
                _createMaintenanceGuide();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleGuideAction(String action, UserGuide guide) {
    switch (action) {
      case 'share':
        _shareGuide(guide);
        break;
      case 'export':
        _exportGuide(guide);
        break;
      case 'complete':
        _completeGuide(guide);
        break;
    }
  }

  void _shareGuide(UserGuide guide) {
    // TODO: 가이드 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('가이드 공유 기능은 준비 중입니다')),
    );
  }

  void _exportGuide(UserGuide guide) {
    // TODO: 가이드 내보내기 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('가이드 내보내기 기능은 준비 중입니다')),
    );
  }

  void _completeGuide(UserGuide guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가이드 완료'),
        content: Text('${guide.title} 가이드를 완료 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _guideSystem.completeGuide(guide.id);
              setState(() {
                _selectedGuide = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('가이드가 완료되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  void _createSetupGuide() {
    // TODO: 발효기 설정 가이드 생성 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('발효기 설정 가이드 생성 기능은 준비 중입니다')),
    );
  }

  void _createTroubleshootingGuide() {
    // TODO: 문제 해결 가이드 생성 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('문제 해결 가이드 생성 기능은 준비 중입니다')),
    );
  }

  void _createMaintenanceGuide() async {
    try {
      await _guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('유지 관리 가이드가 생성되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가이드 생성 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testNotifications() async {
    await _notificationService.notifyCheckpoint(
      message: '알림 테스트가 성공적으로 실행되었습니다!',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('테스트 알림이 발송되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
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
}
