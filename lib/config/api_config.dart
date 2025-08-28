import 'dart:io';
import 'package:flutter/foundation.dart';

/// API配置管理类
/// 
/// 负责根据运行环境（开发/生产）和平台（Android/iOS）
/// 自动选择正确的API基础地址
class ApiConfig {
  // 开发环境配置
  static const String _devBaseUrl = 'http://127.0.0.1:3000';
  static const String _devAndroidBaseUrl = 'http://10.0.2.2:3000';
  
  // 生产环境配置 - 部署时需要替换为实际的服务器域名
  static const String _prodBaseUrl = 'https://your-domain.com';
  
  /// 获取基础URL（不包含API版本）
  static String get baseUrl {
    if (kDebugMode) {
      // 开发环境
      if (Platform.isAndroid) {
        // Android模拟器使用10.0.2.2映射到主机的127.0.0.1
        return _devAndroidBaseUrl;
      } else {
        // iOS模拟器和其他平台使用127.0.0.1
        return _devBaseUrl;
      }
    } else {
      // 生产环境
      return _prodBaseUrl;
    }
  }
  
  /// 获取API完整地址
  static String get apiUrl => '$baseUrl/api/v1';
  
  /// 获取文件上传地址
  static String get uploadUrl => '$apiUrl/files';
  
  /// 获取健康检查地址
  static String get healthUrl => '$baseUrl/health';
  
  /// 是否为开发环境
  static bool get isDevelopment => kDebugMode;
  
  /// 是否为生产环境
  static bool get isProduction => !kDebugMode;
  
  /// 获取当前环境名称
  static String get environmentName => isDevelopment ? 'Development' : 'Production';
  
  /// 打印当前配置信息（仅在开发环境）
  static void printConfig() {
    if (isDevelopment) {
      print('🔧 [ApiConfig] Environment: $environmentName');
      print('🔧 [ApiConfig] Platform: ${Platform.operatingSystem}');
      print('🔧 [ApiConfig] Base URL: $baseUrl');
      print('🔧 [ApiConfig] API URL: $apiUrl');
    }
  }
  
  /// 验证配置是否正确
  static bool validateConfig() {
    try {
      final uri = Uri.parse(apiUrl);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      if (isDevelopment) {
        print('❌ [ApiConfig] Invalid configuration: $e');
      }
      return false;
    }
  }
}

/// 部署配置说明：
/// 
/// 1. 开发环境：
///    - 自动检测平台并使用正确的本地地址
///    - Android: http://10.0.2.2:3000
///    - iOS/其他: http://127.0.0.1:3000
/// 
/// 2. 生产环境：
///    - 替换 _prodBaseUrl 为实际的服务器域名
///    - 例如: https://api.yourapp.com
/// 
/// 3. 使用方法：
///    ```dart
///    // 获取API地址
///    final apiUrl = ApiConfig.apiUrl;
///    
///    // 检查环境
///    if (ApiConfig.isDevelopment) {
///      print('运行在开发环境');
///    }
///    
///    // 打印配置信息（仅开发环境）
///    ApiConfig.printConfig();
///    ```