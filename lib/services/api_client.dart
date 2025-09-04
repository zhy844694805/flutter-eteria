import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/exception_handler.dart';
import '../utils/error_handler.dart';

class ApiClient {
  // 使用配置文件管理API地址
  static String get baseUrl => ApiConfig.apiUrl;
  
  // 单例模式
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    // 初始化时验证配置并打印信息（仅开发环境）
    if (ApiConfig.isDevelopment) {
      ApiConfig.printConfig();
      if (!ApiConfig.validateConfig()) {
        print('⚠️ [ApiClient] 配置验证失败，请检查API配置');
      }
    }
  }
  
  String? token;
  
  // 重试配置
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // 请求统计
  int _requestCount = 0;
  int _failureCount = 0;
  
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
  
  Future<Map<String, dynamic>> request(
    String method, 
    String endpoint, {
    Map<String, dynamic>? body,
    bool enableRetry = true,
    Duration? timeout,
  }) async {
    return await _requestWithRetry(
      method, 
      endpoint, 
      body: body, 
      enableRetry: enableRetry,
      timeout: timeout ?? requestTimeout,
    );
  }
  
  Future<Map<String, dynamic>> _requestWithRetry(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool enableRetry = true,
    Duration timeout = requestTimeout,
    int attempt = 1,
  }) async {
    _requestCount++;
    final uri = Uri.parse('$baseUrl$endpoint');
    
    if (ApiConfig.isDevelopment) {
      print('🌐 [ApiClient] $method $uri (Attempt $attempt)');
      print('🔐 [ApiClient] Token: ${token != null ? "有token(${token!.substring(0, 20)}...)" : "无token"}');
      if (body != null) print('📦 [ApiClient] Body: $body');
    }
    
    try {
      final response = await _makeRequest(method, uri, body).timeout(timeout);
      
      if (ApiConfig.isDevelopment) {
        print('📨 [ApiClient] Status: ${response.statusCode}');
        print('📨 [ApiClient] Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
      }
      
      // 尝试解析响应
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON response: ${response.body}');
      }
      
      // 处理HTTP错误状态
      if (response.statusCode >= 400) {
        _failureCount++;
        final errorMessage = data['error']?['message'] ?? 'Request failed';
        final errorCode = data['error']?['code'];
        
        if (ApiConfig.isDevelopment) {
          print('❌ [ApiClient] Error: $errorMessage (Code: $errorCode)');
        }
        
        // 处理认证错误
        if (_shouldClearAuth(errorCode, response.statusCode)) {
          print('🔄 [ApiClient] 清除无效认证信息');
          await _clearAuthData();
        }
        
        // 判断是否应该重试
        if (enableRetry && _shouldRetry(response.statusCode) && attempt < maxRetries) {
          await Future.delayed(retryDelay * attempt);
          return await _requestWithRetry(
            method, 
            endpoint, 
            body: body, 
            enableRetry: enableRetry,
            timeout: timeout,
            attempt: attempt + 1,
          );
        }
        
        throw Exception(errorMessage);
      }
      
      return data;
    } catch (e) {
      _failureCount++;
      
      // 网络错误处理
      if (e is SocketException || e is TimeoutException) {
        if (enableRetry && attempt < maxRetries) {
          if (ApiConfig.isDevelopment) {
            print('🔄 [ApiClient] Network error, retrying... (${e.runtimeType})');
          }
          await Future.delayed(retryDelay * attempt);
          return await _requestWithRetry(
            method, 
            endpoint, 
            body: body, 
            enableRetry: enableRetry,
            timeout: timeout,
            attempt: attempt + 1,
          );
        }
      }
      
      if (ApiConfig.isDevelopment) {
        print('❌ [ApiClient] Request failed: $e');
      }
      rethrow;
    }
  }
  
  Future<http.Response> _makeRequest(
    String method, 
    Uri uri, 
    Map<String, dynamic>? body,
  ) async {
    final headers = _headers;
    final encodedBody = body != null ? json.encode(body) : null;
    
    switch (method.toLowerCase()) {
      case 'get':
        return await http.get(uri, headers: headers);
      case 'post':
        return await http.post(uri, headers: headers, body: encodedBody);
      case 'put':
        return await http.put(uri, headers: headers, body: encodedBody);
      case 'delete':
        return await http.delete(uri, headers: headers);
      case 'patch':
        return await http.patch(uri, headers: headers, body: encodedBody);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
  
  bool _shouldRetry(int statusCode) {
    // 重试5xx服务器错误和429限流错误
    return statusCode >= 500 || statusCode == 429;
  }
  
  bool _shouldClearAuth(String? errorCode, int statusCode) {
    return errorCode == 'USER_NOT_FOUND' ||
           errorCode == 'INVALID_TOKEN' ||
           errorCode == 'TOKEN_EXPIRED' ||
           statusCode == 401;
  }
  
  Future<Map<String, dynamic>> get(String endpoint) => request('GET', endpoint);
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) => request('POST', endpoint, body: body);
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) => request('PUT', endpoint, body: body);
  Future<Map<String, dynamic>> delete(String endpoint) => request('DELETE', endpoint);

  // 清除认证数据（异步版本）
  Future<void> _clearAuthData() async {
    token = null;
    await _clearLocalData();
  }
  
  // 清除本地存储的认证数据
  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('current_user'),
        prefs.remove('auth_token'),
        prefs.remove('email_recipients'), // 清除天堂邮箱数据
      ]);
      if (ApiConfig.isDevelopment) {
        print('🧹 [ApiClient] 已清除本地认证数据');
      }
    } catch (e) {
      print('❌ [ApiClient] 清除本地数据失败: $e');
    }
  }
  
  // 获取请求统计信息
  Map<String, dynamic> getStats() {
    return {
      'requestCount': _requestCount,
      'failureCount': _failureCount,
      'successRate': _requestCount > 0 ? ((_requestCount - _failureCount) / _requestCount) : 0.0,
    };
  }
  
  // 重置统计信息
  void resetStats() {
    _requestCount = 0;
    _failureCount = 0;
  }
}