import 'dart:io';

class ImageUrlHelper {
  /// 根据平台重写图片URL，确保与API client使用相同的base URL
  static String rewriteImageUrl(String originalUrl) {
    // 如果不是网络URL，直接返回
    if (!originalUrl.startsWith('http')) {
      return originalUrl;
    }
    
    // 提取路径部分（/uploads/...）
    final uri = Uri.parse(originalUrl);
    final path = uri.path;
    
    // 根据平台构建正确的base URL
    final String baseUrl;
    if (Platform.isAndroid) {
      // Android模拟器使用10.0.2.2映射到主机的127.0.0.1
      baseUrl = 'http://10.0.2.2:3000';
    } else {
      // iOS模拟器和其他平台使用127.0.0.1
      baseUrl = 'http://127.0.0.1:3000';
    }
    
    final rewrittenUrl = '$baseUrl$path';
    print('🔄 [ImageUrlHelper] 重写图片URL: $originalUrl -> $rewrittenUrl');
    
    return rewrittenUrl;
  }
}