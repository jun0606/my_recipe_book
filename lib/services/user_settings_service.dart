import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_recipe_book/models/user_configuration.dart';

/// 사용자 설정 관리 서비스
class UserSettingsService {
  static const String _userConfigKey = 'user_configuration';
  static const String _moduleLayoutKey = 'module_layout';
  static const String _activeModulesKey = 'active_modules';

  /// 사용자 설정 로드
  Future<UserConfiguration> loadUserConfiguration(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('${_userConfigKey}_$userId');
      
      if (configJson != null) {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        return UserConfiguration.fromJson(configMap);
      }
    } catch (e) {
      print('사용자 설정 로드 실패: $e');
    }
    
    // 기본 설정 반환
    return UserConfiguration.defaultConfig(userId);
  }

  /// 사용자 설정 저장
  Future<void> saveUserConfiguration(UserConfiguration config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(config.toJson());
      await prefs.setString('${_userConfigKey}_${config.userId}', configJson);
    } catch (e) {
      print('사용자 설정 저장 실패: $e');
      rethrow;
    }
  }

  /// 모듈 레이아웃 저장
  Future<void> saveModuleLayout(Map<String, Offset> layout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutMap = layout.map(
        (key, value) => MapEntry(key, {'x': value.dx, 'y': value.dy}),
      );
      final layoutJson = jsonEncode(layoutMap);
      await prefs.setString(_moduleLayoutKey, layoutJson);
    } catch (e) {
      print('모듈 레이아웃 저장 실패: $e');
      rethrow;
    }
  }

  /// 모듈 레이아웃 로드
  Future<Map<String, Offset>> loadModuleLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = prefs.getString(_moduleLayoutKey);
      
      if (layoutJson != null) {
        final layoutMap = jsonDecode(layoutJson) as Map<String, dynamic>;
        return layoutMap.map(
          (key, value) => MapEntry(
            key,
            Offset(
              value['x']?.toDouble() ?? 0.0,
              value['y']?.toDouble() ?? 0.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('모듈 레이아웃 로드 실패: $e');
    }
    
    return {};
  }

  /// 활성 모듈 목록 업데이트
  Future<void> updateActiveModules(List<String> modules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_activeModulesKey, modules);
    } catch (e) {
      print('활성 모듈 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 활성 모듈 목록 로드
  Future<List<String>> loadActiveModules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_activeModulesKey) ?? 
             ['basic_calculator', 'scaling'];
    } catch (e) {
      print('활성 모듈 로드 실패: $e');
      return ['basic_calculator', 'scaling'];
    }
  }

  /// 설정 초기화
  Future<void> resetSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_userConfigKey}_$userId');
      await prefs.remove(_moduleLayoutKey);
      await prefs.remove(_activeModulesKey);
    } catch (e) {
      print('설정 초기화 실패: $e');
      rethrow;
    }
  }

  /// 텍스트 스케일 팩터 업데이트
  Future<void> updateTextScaleFactor(String userId, double scaleFactor) async {
    try {
      final config = await loadUserConfiguration(userId);
      final updatedConfig = config.updatePreferences({
        'textScaleFactor': scaleFactor,
      });
      await saveUserConfiguration(updatedConfig);
    } catch (e) {
      print('텍스트 스케일 팩터 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 시스템 텍스트 스케일 사용 설정 업데이트
  Future<void> updateUseSystemTextScale(String userId, bool useSystem) async {
    try {
      final config = await loadUserConfiguration(userId);
      final updatedConfig = config.updatePreferences({
        'useSystemTextScale': useSystem,
      });
      await saveUserConfiguration(updatedConfig);
    } catch (e) {
      print('시스템 텍스트 스케일 설정 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 모든 사용자 설정 삭제
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_userConfigKey) || 
            key == _moduleLayoutKey || 
            key == _activeModulesKey) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('모든 설정 삭제 실패: $e');
      rethrow;
    }
  }
}