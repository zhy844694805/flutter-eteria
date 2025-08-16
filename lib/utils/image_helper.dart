import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  // 压缩图片
  static Future<File?> compressImage(File file) async {
    try {
      // 检查原文件是否存在
      if (!await file.exists()) {
        debugPrint('Source file does not exist: ${file.path}');
        return null;
      }

      // 获取应用文档目录 - iOS使用Documents目录更安全
      final directory = await getApplicationDocumentsDirectory();
      final targetPath = path.join(
        directory.path,
        'images', // 创建专门的图片子目录
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 确保目录存在
      final imageDir = Directory(path.dirname(targetPath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // 压缩图片 - iOS上使用更保守的设置
      final Uint8List? result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: defaultTargetPlatform == TargetPlatform.iOS ? 800 : 1024,
        minHeight: defaultTargetPlatform == TargetPlatform.iOS ? 800 : 1024,
        quality: defaultTargetPlatform == TargetPlatform.iOS ? 90 : 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(targetPath);
        await compressedFile.writeAsBytes(result);
        
        // 验证文件确实被创建
        if (await compressedFile.exists()) {
          debugPrint('Image compressed successfully: $targetPath');
          return compressedFile;
        }
      }
    } catch (e) {
      debugPrint('Error compressing image: $e');
    }
    return null;
  }

  // 压缩多张图片
  static Future<List<File>> compressImages(List<File> files) async {
    final compressedFiles = <File>[];
    
    for (final file in files) {
      final compressedFile = await compressImage(file);
      if (compressedFile != null) {
        compressedFiles.add(compressedFile);
      } else {
        // 如果压缩失败，使用原文件
        compressedFiles.add(file);
      }
    }
    
    return compressedFiles;
  }

  // 检查文件大小
  static Future<String> getFileSize(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  // 获取图片尺寸信息
  static String getImageInfo(File file) {
    // 这里可以添加获取图片尺寸的逻辑
    // 为了简化，暂时返回文件名
    return path.basename(file.path);
  }

  // 验证图片文件是否有效
  static Future<bool> isValidImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return false;
      }
      
      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        return false;
      }
      
      // 检查文件扩展名
      final extension = path.extension(imagePath).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
      
      return validExtensions.contains(extension);
    } catch (e) {
      debugPrint('Error validating image file: $e');
      return false;
    }
  }

  // 清理无效的图片路径
  static Future<List<String>> cleanImagePaths(List<String> imagePaths) async {
    final validPaths = <String>[];
    
    for (final imagePath in imagePaths) {
      if (await isValidImageFile(imagePath)) {
        validPaths.add(imagePath);
      } else {
        debugPrint('Invalid image path removed: $imagePath');
      }
    }
    
    return validPaths;
  }
}