// lib/utils/image_utils.dart
// 이미지 처리 유틸리티

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 이미지 유틸리티 클래스
class ImageUtils {
  /// 이미지 파일 복사
  static Future<String?> copyImageFile(String originalPath) async {
    try {
      final file = File(originalPath);
      if (!await file.exists()) {
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(originalPath);
      final newPath = path.join(directory.path, 'recipe_images', fileName);

      // 디렉토리 생성
      final imageDir = Directory(path.dirname(newPath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // 파일 복사
      await file.copy(newPath);
      return newPath;
    } catch (e) {
      print('이미지 파일 복사 중 오류: $e');
      return null;
    }
  }

  /// 이미지 압축 (용량 기반 지능적 압축)
  static Future<File?> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final originalSize = await file.length();

      // 용량 기반 최적 압축 설정 계산
      final config = _calculateOptimalCompression(originalSize);

      final lastIndex = filePath.lastIndexOf('.');
      final extension = filePath.substring(lastIndex + 1);
      final targetPath =
          filePath.replaceAll('.$extension', '_compressed.$extension');

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: config.quality,
        minWidth: config.maxWidth,
        minHeight: config.maxHeight,
        keepExif: false, // 용량 절약을 위해 EXIF 제거
        format: CompressFormat.jpeg, // 통일된 포맷
      );

      // 압축 결과 로깅
      if (result != null) {
        final compressedSize = await result.length();
        final savings =
            ((originalSize - compressedSize) / originalSize * 100).round();
        print(
            '🗜️ 이미지 압축 완료: ${originalSize ~/ 1024}KB → ${compressedSize ~/ 1024}KB (${savings}% 절약)');
      }

      // 압축 실패 시 원본 파일 반환 (안전장치)
      return result != null ? File(result.path) : file;
    } catch (e) {
      print('🛑 이미지 압축 중 오류: $e');
      return file; // 오류 시 원본 파일 반환
    }
  }

  /// 용량 기반 최적 압축 설정 계산
  static _CompressionConfig _calculateOptimalCompression(int fileSize) {
    // 5MB 이상: 최대 압축
    if (fileSize > 5 * 1024 * 1024) {
      return _CompressionConfig(quality: 50, maxWidth: 800, maxHeight: 800);
    }
    // 2MB 이상: 강력 압축
    if (fileSize > 2 * 1024 * 1024) {
      return _CompressionConfig(quality: 60, maxWidth: 900, maxHeight: 900);
    }
    // 1MB 이상: 표준 압축
    if (fileSize > 1024 * 1024) {
      return _CompressionConfig(quality: 70, maxWidth: 1000, maxHeight: 1000);
    }
    // 1MB 이하: 가벼운 압축 (품질 유지)
    return _CompressionConfig(quality: 80, maxWidth: 1200, maxHeight: 1200);
  }

  /// 이미지 크기 조정
  static Future<Uint8List?> resizeImage(
    Uint8List imageBytes, {
    int? width,
    int? height,
    int quality = 80,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: width ?? 1024,
        minHeight: height ?? 1024,
        quality: quality,
      );
    } catch (e) {
      print('이미지 크기 조정 중 오류: $e');
      return null;
    }
  }

  /// 이미지 파일 존재 확인
  static Future<bool> imageFileExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 이미지 파일 크기 가져오기
  static Future<int?> getImageFileSize(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 임시 이미지 파일 생성
  static Future<String?> createTempImagePath(String extension) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'temp_image_$timestamp.$extension';
      return path.join(tempDir.path, fileName);
    } catch (e) {
      print('임시 이미지 경로 생성 중 오류: $e');
      return null;
    }
  }

  /// 이미지 파일 삭제
  static Future<bool> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('이미지 파일 삭제 중 오류: $e');
      return false;
    }
  }

  /// 지원되는 이미지 확장자 확인
  static bool isSupportedImageFormat(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    const supportedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];
    return supportedExtensions.contains(extension);
  }

  /// 이미지 파일 이름 생성
  static String generateImageFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }

  /// 저장소 통계 조회
  static Future<StorageStats> getStorageStats() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(directory.path, 'recipe_images'));

    int totalFiles = 0;
    int totalSize = 0;
    int largeFiles = 0;

    if (await imageDir.exists()) {
      await for (final entity in imageDir.list()) {
        if (entity is File && _isImageFile(entity.path)) {
          totalFiles++;
          final size = await entity.length();
          totalSize += size;
          if (size > 1024 * 1024) largeFiles++; // 1MB 이상
        }
      }
    }

    return StorageStats(
      totalFiles: totalFiles,
      totalSizeBytes: totalSize,
      largeFilesCount: largeFiles,
    );
  }

  /// 이미지 파일 여부 확인
  static bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
  }
}

/// 압축 설정 데이터 클래스
class _CompressionConfig {
  final int quality;
  final int maxWidth;
  final int maxHeight;

  _CompressionConfig({
    required this.quality,
    required this.maxWidth,
    required this.maxHeight,
  });
}

/// 저장소 통계 데이터 클래스
class StorageStats {
  final int totalFiles;
  final int totalSizeBytes;
  final int largeFilesCount;

  StorageStats({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.largeFilesCount,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);
  double get averageSizeKB =>
      totalFiles > 0 ? totalSizeBytes / totalFiles / 1024 : 0;
}
