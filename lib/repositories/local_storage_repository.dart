import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// 로컬 스토리지 작업을 추상화하는 인터페이스
abstract class LocalStorageRepository {
  /// 키-값 쌍으로 데이터 저장 (SharedPreferences용)
  Future<void> savePreference<T>(String key, T value);

  /// 키로 데이터 로드 (SharedPreferences용)
  Future<T?> loadPreference<T>(String key);

  /// 키로 데이터 삭제 (SharedPreferences용)
  Future<void> removePreference(String key);

  /// 모델 객체를 JSON 파일로 저장
  Future<void> saveModel<T>(
      String fileName, T model, Map<String, dynamic> Function(T) toJson);

  /// JSON 파일에서 모델 객체 로드
  Future<T?> loadModel<T>(
      String fileName, T Function(Map<String, dynamic>) fromJson);

  /// 모델 리스트를 JSON 파일로 저장
  Future<void> saveModelList<T>(
      String fileName, List<T> models, Map<String, dynamic> Function(T) toJson);

  /// JSON 파일에서 모델 리스트 로드
  Future<List<T>> loadModelList<T>(
      String fileName, T Function(Map<String, dynamic>) fromJson);

  /// 파일 삭제
  Future<void> deleteFile(String fileName);

  /// 파일 존재 여부 확인
  Future<bool> fileExists(String fileName);
}

/// LocalStorageRepository의 구체적인 구현
class LocalStorageRepositoryImpl implements LocalStorageRepository {
  SharedPreferences? _prefs;
  String? _documentsPath;

  /// SharedPreferences 인스턴스 초기화
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 문서 디렉토리 경로 초기화
  Future<String> get _documentsDirectory async {
    if (_documentsPath == null) {
      final directory = await getApplicationDocumentsDirectory();
      _documentsPath = directory.path;
    }
    return _documentsPath!;
  }

  @override
  Future<void> savePreference<T>(String key, T value) async {
    final prefs = await _preferences;

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // 복잡한 객체는 JSON으로 직렬화
      await prefs.setString(key, jsonEncode(value));
    }
  }

  @override
  Future<T?> loadPreference<T>(String key) async {
    final prefs = await _preferences;

    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    } else {
      // 복잡한 객체는 JSON에서 역직렬화
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as T;
      }
      return null;
    }
  }

  @override
  Future<void> removePreference(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  @override
  Future<void> saveModel<T>(
      String fileName, T model, Map<String, dynamic> Function(T) toJson) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');

      final jsonData = toJson(model);
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      throw LocalStorageException('Failed to save model to $fileName: $e');
    }
  }

  @override
  Future<T?> loadModel<T>(
      String fileName, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');

      if (!file.existsSync()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      throw LocalStorageException('Failed to load model from $fileName: $e');
    }
  }

  @override
  Future<void> saveModelList<T>(String fileName, List<T> models,
      Map<String, dynamic> Function(T) toJson) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');

      final jsonData = models.map((model) => toJson(model)).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      throw LocalStorageException('Failed to save model list to $fileName: $e');
    }
  }

  @override
  Future<List<T>> loadModelList<T>(
      String fileName, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');

      if (!file.existsSync()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw LocalStorageException(
          'Failed to load model list from $fileName: $e');
    }
  }

  @override
  Future<void> deleteFile(String fileName) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');

      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      throw LocalStorageException('Failed to delete file $fileName: $e');
    }
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final documentsPath = await _documentsDirectory;
      final file = File('$documentsPath/$fileName');
      return file.existsSync();
    } on FileSystemException {
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// 로컬 스토리지 관련 예외
class LocalStorageException implements Exception {
  final String message;

  const LocalStorageException(this.message);

  @override
  String toString() => 'LocalStorageException: $message';
}
