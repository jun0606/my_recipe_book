import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/fermentation_notification_service.dart';

/// 발효 타이머 알림 설정 위젯
class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  final FermentationNotificationService _notificationService = 
      FermentationNotificationService();
  
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationEnabled = true;
  double _soundVolume = 0.7;
  PermissionStatus _notificationPermission = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    // 권한 상태 확인
    final permission = await Permission.notification.status;
    
    setState(() {
      _soundEnabled = _notificationService.soundEnabled;
      _vibrationEnabled = _notificationService.vibrationEnabled;
      _notificationEnabled = _notificationService.notificationEnabled;
      _soundVolume = _notificationService.soundVolume;
      _notificationPermission = permission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '알림 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showTestNotifications,
                  icon: const Icon(Icons.play_arrow),
                  tooltip: '알림 테스트',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 로컬 알림 설정
            _buildSwitchTile(
              title: '푸시 알림',
              subtitle: '앱이 백그라운드에 있을 때도 알림 받기',
              icon: Icons.notifications_active,
              value: _notificationEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationEnabled = value;
                });
                await _notificationService.setNotificationEnabled(value);
              },
            ),
            
            const Divider(),
            
            // 소리 설정
            _buildSwitchTile(
              title: '소리 알림',
              subtitle: '알림 시 소리 재생',
              icon: Icons.volume_up,
              value: _soundEnabled,
              onChanged: (value) async {
                setState(() {
                  _soundEnabled = value;
                });
                await _notificationService.setSoundEnabled(value);
              },
            ),
            
            // 시스템 사운드 안내
            if (_soundEnabled) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                           size: 16, 
                           color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '시스템 기본 사운드를 사용합니다.\n볼륨은 기기의 시스템 볼륨을 따릅니다.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const Divider(),
            
            // 진동 설정
            _buildSwitchTile(
              title: '진동 알림',
              subtitle: '알림 시 진동 패턴 재생',
              icon: Icons.vibration,
              value: _vibrationEnabled,
              onChanged: (value) async {
                setState(() {
                  _vibrationEnabled = value;
                });
                await _notificationService.setVibrationEnabled(value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // 권한 상태 표시
            _buildPermissionStatus(),
            
            const SizedBox(height: 16),
            
            // 알림 종류 설명
            _buildNotificationTypesInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: value ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: value ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNotificationTypesInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 4),
              Text(
                '알림 종류',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNotificationTypeItem('🫧', '단계 시작', '각 발효 단계가 시작될 때'),
          _buildNotificationTypeItem('✅', '단계 완료', '발효 단계가 완료될 때'),
          _buildNotificationTypeItem('🎉', '전체 완료', '모든 발효가 완료될 때'),
          _buildNotificationTypeItem('⚠️', '주의 알림', '과발효 위험 등 문제 상황'),
          _buildNotificationTypeItem('📋', '체크포인트', '폴딩 시간 등 중간 확인'),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '- $description',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 권한 상태 표시
  Widget _buildPermissionStatus() {
    final isPermissionGranted = _notificationPermission.isGranted;
    final color = isPermissionGranted ? Colors.green : Colors.orange;
    final icon = isPermissionGranted ? Icons.check_circle : Icons.warning;
    final statusText = isPermissionGranted ? '권한 허용됨' : '권한 필요';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.shade700),
              const SizedBox(width: 8),
              Text(
                '알림 권한 상태: $statusText',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                ),
              ),
            ],
          ),
          if (!isPermissionGranted) ...[
            const SizedBox(height: 8),
            Text(
              '알림이 제대로 작동하려면 권한이 필요합니다.',
              style: TextStyle(
                fontSize: 12,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openAppSettings,
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('설정으로 이동'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.shade100,
                foregroundColor: color.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 앱 설정으로 이동
  Future<void> _openAppSettings() async {
    await openAppSettings();
    // 설정에서 돌아온 후 권한 상태 다시 확인
    await Future.delayed(const Duration(milliseconds: 500));
    _loadSettings();
  }

  /// 알림 테스트
  void _showTestNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 테스트'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('어떤 알림을 테스트하시겠습니까?'),
            const SizedBox(height: 16),
            // 개별 테스트 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testStartNotification();
                  },
                  icon: const Text('🫧'),
                  label: const Text('시작'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testCompleteNotification();
                  },
                  icon: const Text('✅'),
                  label: const Text('완료'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testWarningNotification();
                  },
                  icon: const Text('⚠️'),
                  label: const Text('경고'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testCheckpointNotification();
                  },
                  icon: const Text('📋'),
                  label: const Text('체크포인트'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testCelebrationNotification();
                  },
                  icon: const Text('🎉'),
                  label: const Text('축하'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _testStartNotification() async {
    await _notificationService.notifyStageStart(
      stageName: '1차 발효',
      duration: const Duration(minutes: 90),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시작 알림 테스트 완료'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testCompleteNotification() async {
    await _notificationService.notifyStageComplete(
      stageName: '1차 발효',
      nextStageName: '최종 발효',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('완료 알림 테스트 완료'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testWarningNotification() async {
    await _notificationService.notifyWarning(
      message: '과발효 위험! 즉시 다음 단계로 진행하세요',
      urgent: true,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ 경고 알림 테스트 완료'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testCheckpointNotification() async {
    await _notificationService.notifyCheckpoint(
      message: '30% 지점 - 첫 번째 폴딩을 실시하세요',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 체크포인트 알림 테스트 완료'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testCelebrationNotification() async {
    await _notificationService.notifyFermentationComplete();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 축하 알림 테스트 완료'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}