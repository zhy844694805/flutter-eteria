import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../utils/image_url_helper.dart';

class PlatformImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const PlatformImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isNetworkImage(imagePath)) {
      final rewrittenUrl = ImageUrlHelper.rewriteImageUrl(imagePath);
      debugPrint('🔄 [PlatformImage] 准备加载图片: $rewrittenUrl');
      imageWidget = CachedNetworkImage(
        imageUrl: rewrittenUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (context, url, error) {
          debugPrint('🚫 [PlatformImage] 网络图片加载失败');
          debugPrint('🔗 [PlatformImage] URL: $url');
          debugPrint('❌ [PlatformImage] 错误: $error');
          debugPrint('📱 [PlatformImage] 平台: ${Platform.operatingSystem}');
          return errorWidget ?? _buildNetworkError(url, error);
        },
        httpHeaders: const {
          'Connection': 'keep-alive',
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    } else {
      imageWidget = FutureBuilder<bool>(
        future: _checkFileExists(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ?? _buildDefaultPlaceholder();
          }
          
          if (snapshot.data == true) {
            return Image.file(
              File(imagePath),
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image $imagePath: $error');
                return errorWidget ?? _buildDefaultError();
              },
            );
          } else {
            return errorWidget ?? _buildFileNotFoundError();
          }
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  bool _isNetworkImage(String path) {
    final isNetwork = path.startsWith('http') || path.startsWith('https');
    if (isNetwork) {
      debugPrint('🖼️ [PlatformImage] 加载网络图片: $path');
    }
    return isNetwork;
  }

  Future<bool> _checkFileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.person,
          color: AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNetworkError(String? url, dynamic error) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant.withOpacity(0.3),
            AppColors.surfaceVariant.withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: AppColors.textSecondary,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              '加载失败',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileNotFoundError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: AppColors.error,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              '图片不存在',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}