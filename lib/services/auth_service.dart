import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson == null) return null;
    
    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _saveUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
    await prefs.setString('auth_token', token);
    _api.token = token;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('auth_token');
    _api.token = null;
  }
  
  Future<void> sendVerificationCode(String email) async {
    print('🌐 [AuthService] 发送验证码请求到: ${ApiClient.baseUrl}/auth/send-verification-code');
    print('📦 [AuthService] 请求数据: {email: $email}');
    
    await _api.post('/auth/send-verification-code', body: {
      'email': email,
    });
    
    print('✅ [AuthService] 验证码已发送');
  }

  Future<User> register(String email, String name, String password, String verificationCode) async {
    print('🌐 [AuthService] 发送注册请求到: ${ApiClient.baseUrl}/auth/register');
    print('📦 [AuthService] 请求数据: {email: $email, name: $name, verificationCode: $verificationCode}');
    
    final response = await _api.post('/auth/register', body: {
      'email': email,
      'name': name,
      'password': password,
      'verificationCode': verificationCode,
    });
    
    print('📨 [AuthService] 服务器响应: $response');
    final user = User.fromJson(response['data']['user']);
    final token = response['data']['tokens']['accessToken'];
    
    await _saveUser(user, token);
    return user;
  }
  
  Future<User> verifyEmail(String email, String code) async {
    final response = await _api.post('/auth/verify-email', body: {
      'email': email,
      'verificationCode': code,
    });
    
    return User.fromJson(response['data']['user']);
  }
  
  Future<void> resendVerificationCode(String email) async {
    await _api.post('/auth/resend-verification', body: {'email': email});
  }
  
  Future<User> login(String email, String password) async {
    final response = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    
    final user = User.fromJson(response['data']['user']);
    final token = response['data']['tokens']['accessToken'];
    
    await _saveUser(user, token);
    return user;
  }
  
  Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _api.token = token;
    }
  }
}