import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../theme/app_theme.dart';

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
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
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
    return path.startsWith('http') || path.startsWith('https');
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