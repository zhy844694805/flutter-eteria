import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isVerified;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _service.initializeToken();
    _currentUser = await _service.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  String? _lastError;
  String? get lastError => _lastError;

  Future<bool> sendVerificationCode(String email) async {
    try {
      _lastError = null;
      print('📝 [AuthProvider] 开始发送验证码: $email');
      await _service.sendVerificationCode(email);
      print('✅ [AuthProvider] 验证码发送成功');
      return true;
    } catch (e) {
      print('❌ [AuthProvider] 验证码发送失败: $e');
      _lastError = _parseErrorMessage(e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String name, String password, String verificationCode) async {
    try {
      _lastError = null;
      print('📝 [AuthProvider] 开始注册: $email');
      final user = await _service.register(email, name, password, verificationCode);
      _currentUser = user;
      notifyListeners();
      print('✅ [AuthProvider] 注册成功: ${user.name}');
      return true;
    } catch (e) {
      print('❌ [AuthProvider] 注册失败: $e');
      _lastError = _parseErrorMessage(e.toString());
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    try {
      _currentUser = await _service.verifyEmail(email, code);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email) async {
    try {
      await _service.resendVerificationCode(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _lastError = null;
      _currentUser = await _service.login(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AuthProvider] 登录失败: $e');
      _lastError = _parseErrorMessage(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    notifyListeners();
  }

  // 兼容旧方法
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // 解析错误信息，提供更友好的提示
  String _parseErrorMessage(String error) {
    print('🔍 [AuthProvider] 解析错误信息: $error');
    
    // 移除Exception前缀
    final cleanError = error.replaceAll('Exception: ', '').trim();
    
    // 检查常见错误类型
    if (cleanError.contains('Email already registered') || 
        cleanError.contains('User already exists') ||
        cleanError.contains('邮箱已被注册') ||
        cleanError.contains('already registered')) {
      return '邮箱已被注册';
    }
    
    if (cleanError.contains('Invalid verification code') ||
        cleanError.contains('验证码') && cleanError.contains('错误')) {
      return '验证码错误或已过期';
    }
    
    if (cleanError.contains('Invalid email') ||
        cleanError.contains('邮箱格式')) {
      return '邮箱格式不正确';
    }
    
    if (cleanError.contains('Password') && cleanError.contains('too short')) {
      return '密码长度不能少于6位';
    }
    
    if (cleanError.contains('Invalid password') ||
        cleanError.contains('密码错误')) {
      return '密码错误';
    }
    
    if (cleanError.contains('User not found') ||
        cleanError.contains('用户不存在')) {
      return '用户不存在';
    }
    
    if (cleanError.contains('Network') ||
        cleanError.contains('Connection') ||
        cleanError.contains('timeout')) {
      return '网络连接失败，请检查网络设置';
    }
    
    // 返回原始错误信息（如果没有匹配到特定类型）
    return cleanError.isNotEmpty ? cleanError : '操作失败，请重试';
  }
}