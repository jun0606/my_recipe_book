/// 가이드 설정 위젯
/// 사용자 가이드 시스템의 설정을 관리하는 UI 컴포넌트

import 'package:flutter/material.dart';
import '../../services/user_guide_system.dart';
import '../../services/fermentation_notification_service.dart';

class GuideSettingsWidget extends StatefulWidget {
  final UserGuideSystem guideSystem;
  final FermentationNotificationService notificationService;

  const GuideSettingsWidget({
    Key? key,
    required this.guideSystem,
    required this.notificationService,
  }) : super(key: key);

  @override
  State<GuideSettingsWidget> createState() => _GuideSettingsWidgetState();
}

class _GuideSettingsWidgetState extends State<GuideSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('가이드 설정'),
          _buildGuideSettings(),
          const SizedBox(height: 24),
          _buildSectionHeader('알림 설정'),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildSectionHeader('고급 설정'),
          _buildAdvancedSettings(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGuideSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingTile(
              icon: Icons.auto_mode,
              title: '자동 진행',
              subtitle: '단계 완료 시 자동으로 다음 단계로 이동',
              value: widget.guideSystem.autoProgressEnabled,
              onChanged: (value) async {
                await widget.guideSystem.setAutoProgressEnabled(value);
                setState(() {});
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.lightbulb_outline,
              title: '상황별 팁',
              subtitle: '현재 상황에 맞는 유용한 팁 표시',
              value: widget.guideSystem.contextualTipsEnabled,
              onChanged: (value) async {
                await widget.guideSystem.setContextualTipsEnabled(value);
                setState(() {});
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.record_voice_over,
              title: '음성 가이드',
              subtitle: '음성으로 가이드 내용 읽어주기 (실험적 기능)',
              value: widget.guideSystem.voiceGuidanceEnabled,
              onChanged: (value) async {
                await widget.guideSystem.setVoiceGuidanceEnabled(value);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingTile(
              icon: Icons.smart_toy,
              title: '스마트 알림',
              subtitle: '상황에 맞는 지능적인 알림 발송',
              value: widget.guideSystem.smartNotificationsEnabled,
              onChanged: (value) async {
                await widget.guideSystem.setSmartNotificationsEnabled(value);
                setState(() {});
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.notifications,
              title: '푸시 알림',
              subtitle: '앱이 백그라운드에 있을 때도 알림 받기',
              value: widget.notificationService.notificationEnabled,
              onChanged: (value) async {
                await widget.notificationService.setNotificationEnabled(value);
                setState(() {});
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.volume_up,
              title: '알림 소리',
              subtitle: '알림 시 소리 재생',
              value: widget.notificationService.soundEnabled,
              onChanged: (value) async {
                await widget.notificationService.setSoundEnabled(value);
                setState(() {});
              },
            ),
            const Divider(),
            _buildSettingTile(
              icon: Icons.vibration,
              title: '진동',
              subtitle: '알림 시 진동 사용',
              value: widget.notificationService.vibrationEnabled,
              onChanged: (value) async {
                await widget.notificationService.setVibrationEnabled(value);
                setState(() {});
              },
            ),
            if (widget.notificationService.soundEnabled) ...[
              const Divider(),
              _buildVolumeSlider(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return ListTile(
      leading: const Icon(Icons.volume_down),
      title: const Text('알림 볼륨'),
      subtitle: Slider(
        value: widget.notificationService.soundVolume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: '${(widget.notificationService.soundVolume * 100).round()}%',
        onChanged: (value) async {
          await widget.notificationService.setSoundVolume(value);
          setState(() {});
        },
      ),
      trailing: const Icon(Icons.volume_up),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('알림 테스트'),
              subtitle: const Text('다양한 알림 소리와 진동을 테스트해보세요'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showNotificationTestDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('가이드 백업'),
              subtitle: const Text('완료된 가이드 히스토리를 백업합니다'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _exportGuideHistory,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('가이드 복원'),
              subtitle: const Text('백업된 가이드 히스토리를 복원합니다'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _importGuideHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _resetAllSettings,
          icon: const Icon(Icons.refresh),
          label: const Text('설정 초기화'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _showAboutDialog,
          icon: const Icon(Icons.info_outline),
          label: const Text('가이드 시스템 정보'),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showNotificationTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 테스트'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('어떤 알림을 테스트하시겠습니까?'),
            const SizedBox(height: 16),
            _buildTestButton(
              '단계 시작',
              Icons.play_circle,
              () => widget.notificationService.notifyStageStart(
                stageName: '테스트 단계',
                duration: const Duration(minutes: 30),
              ),
            ),
            _buildTestButton(
              '단계 완료',
              Icons.check_circle,
              () => widget.notificationService.notifyStageComplete(
                stageName: '테스트 단계',
                nextStageName: '다음 테스트 단계',
              ),
            ),
            _buildTestButton(
              '발효 완료',
              Icons.celebration,
              () => widget.notificationService.notifyFermentationComplete(),
            ),
            _buildTestButton(
              '경고 알림',
              Icons.warning,
              () => widget.notificationService.notifyWarning(
                message: '테스트 경고 메시지입니다',
              ),
            ),
            _buildTestButton(
              '체크포인트',
              Icons.flag,
              () => widget.notificationService.notifyCheckpoint(
                message: '테스트 체크포인트입니다',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed();
          },
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }

  void _exportGuideHistory() {
    // TODO: 가이드 히스토리 내보내기 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('가이드 백업 기능은 준비 중입니다'),
      ),
    );
  }

  void _importGuideHistory() {
    // TODO: 가이드 히스토리 가져오기 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('가이드 복원 기능은 준비 중입니다'),
      ),
    );
  }

  void _resetAllSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text(
          '모든 가이드 설정을 초기값으로 되돌리시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performReset();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset() async {
    try {
      // 가이드 시스템 설정 초기화
      await widget.guideSystem.setAutoProgressEnabled(true);
      await widget.guideSystem.setSmartNotificationsEnabled(true);
      await widget.guideSystem.setContextualTipsEnabled(true);
      await widget.guideSystem.setVoiceGuidanceEnabled(false);

      // 알림 서비스 설정 초기화
      await widget.notificationService.setNotificationEnabled(true);
      await widget.notificationService.setSoundEnabled(true);
      await widget.notificationService.setVibrationEnabled(true);
      await widget.notificationService.setSoundVolume(0.7);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 설정이 초기화되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 초기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가이드 시스템 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('버전', '1.0.0'),
            _buildInfoRow('활성 가이드', '${widget.guideSystem.activeGuides.length}개'),
            _buildInfoRow('완료된 가이드', '${widget.guideSystem.guideHistory.length}개'),
            const SizedBox(height: 16),
            const Text(
              '통합 사용자 가이드 시스템은 발효기 설정부터 문제 해결까지 '
              '모든 과정을 단계별로 안내합니다.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}