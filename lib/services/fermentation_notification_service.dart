import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

/// 발효 타이머 알림 서비스
/// 진동, 소리, 로컬 알림을 통한 종합적인 알림 시스템
class FermentationNotificationService {
  static final FermentationNotificationService _instance = 
      FermentationNotificationService._internal();
  factory FermentationNotificationService() => _instance;
  FermentationNotificationService._internal();

  // 알림 관련 인스턴스
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // 설정 키
  static const String _soundEnabledKey = 'fermentation_sound_enabled';
  static const String _vibrationEnabledKey = 'fermentation_vibration_enabled';
  static const String _soundVolumeKey = 'fermentation_sound_volume';
  static const String _notificationEnabledKey = 'fermentation_notification_enabled';
  
  // 기본 설정값
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationEnabled = true;
  double _soundVolume = 0.7;
  
  // 초기화 상태
  bool _initialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // 설정 로드
      await _loadSettings();
      
      // 권한 요청
      await _requestPermissions();
      
      // 로컬 알림 초기화
      await _initializeLocalNotifications();
      
      _initialized = true;
      print('✅ FermentationNotificationService 초기화 완료');
    } catch (e) {
      print('❌ FermentationNotificationService 초기화 오류: $e');
    }
  }

  /// 필요한 권한들 요청
  Future<void> _requestPermissions() async {
    print('🔐 권한 요청 시작...');
    
    // Android 13+ 알림 권한 요청
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      print('📱 알림 권한: ${notificationStatus.name}');
      
      // 시스템 설정으로 이동이 필요한 경우
      if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
        print('⚠️ 알림 권한이 거부되었습니다. 시스템 설정에서 수동으로 허용해주세요.');
      }
    }
    
    // iOS 알림 권한은 flutter_local_notifications에서 자동 처리
    print('✅ 권한 요청 완료');
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'fermentation_timer',
        '발효 타이머',
        description: '발효 단계 완료 및 중요 알림',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭됨: ${response.payload}');
    // 필요시 특정 화면으로 이동 로직 추가
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
    _notificationEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
    _soundVolume = prefs.getDouble(_soundVolumeKey) ?? 0.7;
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
    await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
    await prefs.setBool(_notificationEnabledKey, _notificationEnabled);
    await prefs.setDouble(_soundVolumeKey, _soundVolume);
  }

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationEnabled => _notificationEnabled;
  double get soundVolume => _soundVolume;

  /// 소리 설정
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
  }

  /// 진동 설정
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
  }

  /// 알림 설정
  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    await _saveSettings();
  }

  /// 소리 볼륨 설정 (0.0 ~ 1.0)
  /// 참고: 시스템 사운드는 시스템 볼륨을 따르므로 이 설정은 UI 표시용입니다
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
  }

  /// 발효 단계 시작 알림
  Future<void> notifyStageStart({
    required String stageName,
    required Duration duration,
  }) async {
    await _ensureInitialized();
    
    // 진동
    if (_vibrationEnabled) {
      await _playStartVibration();
    }
    
    // 소리
    if (_soundEnabled) {
      await _playStartSound();
    }
    
    // 로컬 알림
    if (_notificationEnabled) {
      await _showStartNotification(stageName, duration);
    }
  }

  /// 발효 단계 완료 알림
  Future<void> notifyStageComplete({
    required String stageName,
    String? nextStageName,
  }) async {
    await _ensureInitialized();
    
    // 진동 (더 강하게)
    if (_vibrationEnabled) {
      await _playCompleteVibration();
    }
    
    // 소리 (완료 사운드)
    if (_soundEnabled) {
      await _playCompleteSound();
    }
    
    // 로컬 알림
    if (_notificationEnabled) {
      await _showCompleteNotification(stageName, nextStageName);
    }
  }

  /// 전체 발효 완료 알림
  Future<void> notifyFermentationComplete() async {
    await _ensureInitialized();
    
    // 진동 (축하 패턴)
    if (_vibrationEnabled) {
      await _playCelebrationVibration();
    }
    
    // 소리 (축하 사운드)
    if (_soundEnabled) {
      await _playCelebrationSound();
    }
    
    // 로컬 알림
    if (_notificationEnabled) {
      await _showFermentationCompleteNotification();
    }
  }

  /// 경고 알림 (과발효 위험 등)
  Future<void> notifyWarning({
    required String message,
    bool urgent = false,
  }) async {
    await _ensureInitialized();
    
    // 진동 (경고 패턴)
    if (_vibrationEnabled) {
      await _playWarningVibration(urgent);
    }
    
    // 소리 (경고 사운드)
    if (_soundEnabled) {
      await _playWarningSound();
    }
    
    // 로컬 알림
    if (_notificationEnabled) {
      await _showWarningNotification(message, urgent);
    }
  }

  /// 체크포인트 알림 (폴딩 시간 등)
  Future<void> notifyCheckpoint({
    required String message,
  }) async {
    await _ensureInitialized();
    
    // 진동 (부드러운 알림)
    if (_vibrationEnabled) {
      await _playCheckpointVibration();
    }
    
    // 소리 (부드러운 알림음)
    if (_soundEnabled) {
      await _playCheckpointSound();
    }
    
    // 로컬 알림
    if (_notificationEnabled) {
      await _showCheckpointNotification(message);
    }
  }

  // 진동 패턴들
  
  /// 시작 진동 (부드러운 단일 진동)
  Future<void> _playStartVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 200);
    }
  }

  /// 완료 진동 (더블 진동)
  Future<void> _playCompleteVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 300, 100, 300]);
    }
  }

  /// 축하 진동 (리듬감 있는 패턴)
  Future<void> _playCelebrationVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]);
    }
  }

  /// 경고 진동 (긴급도에 따라)
  Future<void> _playWarningVibration(bool urgent) async {
    if (await Vibration.hasVibrator() ?? false) {
      if (urgent) {
        // 긴급: 연속 진동
        await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100, 50, 100]);
      } else {
        // 일반 경고: 트리플 진동
        await Vibration.vibrate(pattern: [0, 150, 100, 150, 100, 150]);
      }
    }
  }

  /// 체크포인트 진동 (부드러운 알림)
  Future<void> _playCheckpointVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
    }
  }

  // 소리 재생들

  /// 시작 소리 (다중 방법 시도)
  Future<void> _playStartSound() async {
    print('🔊 시작 알림 재생 시도...');
    await _playMultiMethodSound('시작', SystemSoundType.click, HapticFeedback.lightImpact);
  }

  /// 완료 소리 (다중 방법 시도)
  Future<void> _playCompleteSound() async {
    print('🔊 완료 알림 재생 시도...');
    await _playMultiMethodSound('완료', SystemSoundType.alert, HapticFeedback.mediumImpact);
  }

  /// 축하 소리 (다중 방법 시도)
  Future<void> _playCelebrationSound() async {
    print('🔊 축하 알림 재생 시도...');
    
    bool soundPlayed = false;
    
    // 방법 1: 시스템 사운드 2회
    try {
      await SystemSound.play(SystemSoundType.alert);
      await Future.delayed(const Duration(milliseconds: 200));
      await SystemSound.play(SystemSoundType.alert);
      soundPlayed = true;
      print('✅ 축하 시스템 사운드 재생 완료');
    } catch (e) {
      print('❌ 축하 시스템 사운드 실패: $e');
    }
    
    // 방법 2: 햅틱 피드백 (시스템 사운드 실패 시)
    if (!soundPlayed) {
      try {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
        print('🔄 축하 햅틱 피드백 완료');
      } catch (e) {
        print('❌ 축하 햅틱 피드백도 실패: $e');
      }
    }
  }

  /// 경고 소리 (다중 방법 시도)
  Future<void> _playWarningSound() async {
    print('🔊 경고 알림 재생 시도...');
    
    bool soundPlayed = false;
    
    // 방법 1: 시스템 사운드 3회
    try {
      for (int i = 0; i < 3; i++) {
        await SystemSound.play(SystemSoundType.alert);
        if (i < 2) await Future.delayed(const Duration(milliseconds: 150));
      }
      soundPlayed = true;
      print('✅ 경고 시스템 사운드 재생 완료');
    } catch (e) {
      print('❌ 경고 시스템 사운드 실패: $e');
    }
    
    // 방법 2: 햅틱 피드백 (시스템 사운드 실패 시)
    if (!soundPlayed) {
      try {
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.heavyImpact();
          if (i < 2) await Future.delayed(const Duration(milliseconds: 150));
        }
        print('🔄 경고 햅틱 피드백 완료');
      } catch (e) {
        print('❌ 경고 햅틱 피드백도 실패: $e');
      }
    }
  }

  /// 체크포인트 소리 (다중 방법 시도)
  Future<void> _playCheckpointSound() async {
    print('🔊 체크포인트 알림 재생 시도...');
    await _playMultiMethodSound('체크포인트', SystemSoundType.click, HapticFeedback.selectionClick);
  }

  /// 다중 방법으로 소리 재생 시도
  Future<void> _playMultiMethodSound(
    String soundName, 
    SystemSoundType systemSound, 
    Future<void> Function() hapticFallback
  ) async {
    bool soundPlayed = false;
    
    // 방법 1: 시스템 사운드
    try {
      await SystemSound.play(systemSound);
      soundPlayed = true;
      print('✅ $soundName 시스템 사운드 재생 완료');
    } catch (e) {
      print('❌ $soundName 시스템 사운드 실패: $e');
    }
    
    // 방법 2: 햅틱 피드백 (시스템 사운드 실패 시)
    if (!soundPlayed) {
      try {
        await hapticFallback();
        print('🔄 $soundName 햅틱 피드백 완료');
      } catch (e) {
        print('❌ $soundName 햅틱 피드백도 실패: $e');
      }
    }
    
    // 방법 3: 강제 진동 (모든 방법 실패 시)
    if (!soundPlayed) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(duration: 100);
          print('🔄 $soundName 강제 진동 완료');
        }
      } catch (e) {
        print('❌ $soundName 강제 진동도 실패: $e');
      }
    }
  }

  // 로컬 알림들

  /// 시작 알림
  Future<void> _showStartNotification(String stageName, Duration duration) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fermentation_timer',
        '발효 타이머',
        channelDescription: '발효 단계 시작 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      1,
      '🫧 $stageName 시작',
      '예상 시간: ${_formatDuration(duration)}',
      notificationDetails,
      payload: 'stage_start:$stageName',
    );
  }

  /// 완료 알림
  Future<void> _showCompleteNotification(String stageName, String? nextStageName) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fermentation_timer',
        '발효 타이머',
        channelDescription: '발효 단계 완료 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    final body = nextStageName != null 
        ? '다음 단계: $nextStageName'
        : '발효 단계가 완료되었습니다';

    await _localNotifications.show(
      2,
      '✅ $stageName 완료',
      body,
      notificationDetails,
      payload: 'stage_complete:$stageName',
    );
  }

  /// 전체 완료 알림
  Future<void> _showFermentationCompleteNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fermentation_timer',
        '발효 타이머',
        channelDescription: '발효 완료 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      3,
      '🎉 발효 완료!',
      '모든 발효 단계가 완료되었습니다. 이제 굽기를 시작하세요!',
      notificationDetails,
      payload: 'fermentation_complete',
    );
  }

  /// 경고 알림
  Future<void> _showWarningNotification(String message, bool urgent) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fermentation_timer',
        '발효 타이머',
        channelDescription: '발효 경고 알림',
        importance: urgent ? Importance.max : Importance.high,
        priority: urgent ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      4,
      urgent ? '🚨 긴급 알림' : '⚠️ 주의 필요',
      message,
      notificationDetails,
      payload: 'warning:$message',
    );
  }

  /// 체크포인트 알림
  Future<void> _showCheckpointNotification(String message) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fermentation_timer',
        '발효 타이머',
        channelDescription: '발효 체크포인트 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      5,
      '📋 체크포인트',
      message,
      notificationDetails,
      payload: 'checkpoint:$message',
    );
  }

  /// 초기화 확인
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// 시간 포맷팅
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    // 시스템 사운드만 사용하므로 별도 정리 불필요
    print('FermentationNotificationService 정리 완료');
  }
}