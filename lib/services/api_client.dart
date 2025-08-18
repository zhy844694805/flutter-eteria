import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // iOS模拟器使用127.0.0.1而不是localhost
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
  
  // 单例模式
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  
  String? token;
  
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
  
  Future<Map<String, dynamic>> request(String method, String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('🌐 [ApiClient] $method $uri');
    print('🔐 [ApiClient] Token: ${token != null ? "有token(${token!.substring(0, 20)}...)" : "无token"}');
    if (body != null) print('📦 [ApiClient] Body: $body');
    
    late http.Response response;
    switch (method.toLowerCase()) {
      case 'get':
        response = await http.get(uri, headers: _headers);
        break;
      case 'post':
        response = await http.post(uri, headers: _headers, body: body != null ? json.encode(body) : null);
        break;
      case 'put':
        response = await http.put(uri, headers: _headers, body: body != null ? json.encode(body) : null);
        break;
      case 'delete':
        response = await http.delete(uri, headers: _headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
    
    print('📨 [ApiClient] Status: ${response.statusCode}');
    print('📨 [ApiClient] Response: ${response.body}');
    
    final data = json.decode(response.body);
    if (response.statusCode >= 400) {
      print('❌ [ApiClient] Error: ${data['error']?['message']}');
      
      // 如果用户不存在或token无效，清除token
      final errorCode = data['error']?['code'];
      if (errorCode == 'USER_NOT_FOUND' || errorCode == 'INVALID_TOKEN') {
        print('🔄 [ApiClient] 清除无效token');
        token = null;
        // 同时清除本地存储的token和用户数据
        _clearLocalData();
      }
      
      throw Exception(data['error']?['message'] ?? 'Request failed');
    }
    return data;
  }
  
  Future<Map<String, dynamic>> get(String endpoint) => request('GET', endpoint);
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) => request('POST', endpoint, body: body);
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) => request('PUT', endpoint, body: body);
  Future<Map<String, dynamic>> delete(String endpoint) => request('DELETE', endpoint);

  // 清除本地存储的认证数据
  void _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('auth_token');
      print('🧹 [ApiClient] 已清除本地认证数据');
    } catch (e) {
      print('❌ [ApiClient] 清除本地数据失败: $e');
    }
  }
}