import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  static Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 0,
    );

    return result != null ? File(result.path) : null;
  }

  static Future<String?> copyImageFile(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) return null;

      final directory = await getApplicationDocumentsDirectory();
      final newPath = p.join(directory.path, '${DateTime.now().millisecondsSinceEpoch}_copied.png');
      final newFile = await originalFile.copy(newPath);
      return newFile.path;
    } catch (e) {
      print('Error copying image file: $e');
      return null;
    }
  }
  
  static Future<bool> deleteImageFile(String? path) async {
    if (path == null) return false;
    
    try {
      final imageFile = File(path);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image file: $e');
      return false;
    }
  }
}