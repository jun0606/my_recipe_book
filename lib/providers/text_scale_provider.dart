import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 텍스트 스케일 관리 Provider
class TextScaleProvider extends ChangeNotifier {
  static const String _textScaleFactorKey = 'text_scale_factor';
  static const String _useSystemTextScaleKey = 'use_system_text_scale';

  double _textScaleFactor = 1.0;
  bool _useSystemTextScale = true;

  double get textScaleFactor => _textScaleFactor;
  bool get useSystemTextScale => _useSystemTextScale;

  /// 초기화 - 설정 로드
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _textScaleFactor = prefs.getDouble(_textScaleFactorKey) ?? 1.0;
      _useSystemTextScale = prefs.getBool(_useSystemTextScaleKey) ?? true;
      notifyListeners();
    } catch (e) {
      print('텍스트 스케일 설정 로드 실패: $e');
    }
  }

  /// 텍스트 스케일 팩터 업데이트
  Future<void> updateTextScaleFactor(double scaleFactor) async {
    _textScaleFactor = scaleFactor;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_textScaleFactorKey, scaleFactor);
    } catch (e) {
      print('텍스트 스케일 팩터 저장 실패: $e');
    }
  }

  /// 시스템 텍스트 스케일 사용 설정 업데이트
  Future<void> updateUseSystemTextScale(bool useSystem) async {
    _useSystemTextScale = useSystem;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemTextScaleKey, useSystem);
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
