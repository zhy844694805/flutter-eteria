import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkTester {
  /// 测试网络连接到本地服务器
  static Future<bool> testLocalConnection() async {
    try {
      final String testUrl;
      if (Platform.isAndroid) {
        testUrl = 'http://10.0.2.2:3000/health';
      } else {
        testUrl = 'http://127.0.0.1:3000/health';
      }
      
      print('🧪 [NetworkTester] 测试连接: $testUrl');
      
      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      print('✅ [NetworkTester] 连接成功，状态码: ${response.statusCode}');
      print('📝 [NetworkTester] 响应: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [NetworkTester] 连接失败: $e');
      return false;
    }
  }
  
  /// 测试图片URL是否可访问
  static Future<bool> testImageUrl(String imageUrl) async {
    try {
      print('🖼️ [NetworkTester] 测试图片URL: $imageUrl');
      
      final response = await http.head(
        Uri.parse(imageUrl),
      ).timeout(const Duration(seconds: 10));
      
      print('📊 [NetworkTester] 图片响应状态: ${response.statusCode}');
      print('📂 [NetworkTester] 内容类型: ${response.headers['content-type']}');
      print('📏 [NetworkTester] 内容长度: ${response.headers['content-length']}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [NetworkTester] 图片测试失败: $e');
      return false;
    }
  }
}