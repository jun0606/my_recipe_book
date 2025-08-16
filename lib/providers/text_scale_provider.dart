import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_settings_service.dart';
import '../models/user_configuration.dart';

/// 텍스트 스케일 관리 Provider
class TextScaleProvider extends ChangeNotifier {
  final UserSettingsService _settingsService = UserSettingsService();
  
  double _textScaleFactor = 1.0;
  bool _useSystemTextScale = true;
  String? _currentUserId;

  double get textScaleFactor => _textScaleFactor;
  bool get useSystemTextScale => _useSystemTextScale;

  /// 초기화
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    if (_currentUserId == null) return;
    
    try {
      final config = await _settingsService.loadUserConfiguration(_currentUserId!);
      _textScaleFactor = config.preferences['textScaleFactor']?.toDouble() ?? 1.0;
      _useSystemTextScale = config.preferences['useSystemTextScale'] ?? true;
      notifyListeners();
    } catch (e) {
      print('텍스트 스케일 설정 로드 실패: $e');
    }
  }

  /// 텍스트 스케일 팩터 업데이트
  Future<void> updateTextScaleFactor(double scaleFactor) async {
    if (_currentUserId == null) return;
    
    _textScaleFactor = scaleFactor;
    notifyListeners();
    
    try {
      await _settingsService.updateTextScaleFactor(_currentUserId!, scaleFactor);
    } catch (e) {
      print('텍스트 스케일 팩터 저장 실패: $e');
    }
  }

  /// 시스템 텍스트 스케일 사용 설정 업데이트
  Future<void> updateUseSystemTextScale(bool useSystem) async {
    if (_currentUserId == null) return;
    
    _useSystemTextScale = useSystem;
    notifyListeners();
    
    try {
      await _settingsService.updateUseSystemTextScale(_currentUserId!, useSystem);
    } catch (e) {
      print('시스템 텍스트 스케일 설정 저장 실패: $e');
    }
  }

  /// 효과적인 텍스트 스케일 팩터 계산
  double getEffectiveTextScaleFactor(BuildContext context) {
    if (_useSystemTextScale) {
      return MediaQuery.textScaleFactorOf(context) * _textScaleFactor;
    }
    return _textScaleFactor;
  }
}