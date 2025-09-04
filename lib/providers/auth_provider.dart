import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/exception_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  bool _disposed = false;
  Timer? _sessionTimer;
  
  // 会话管理
  static const Duration sessionTimeout = Duration(hours: 24);
  DateTime? _lastActivity;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isVerified;

  Future<void> initialize() async {
    if (_disposed) return;
    
    _isLoading = true;
    _safeNotifyListeners();
    
    try {
      await _service.initializeToken();
      _currentUser = await _service.getCurrentUser();
      
      if (_currentUser != null) {
        _updateLastActivity();
        _startSessionTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AuthProvider] 初始化失败，可能token已失效: $e');
      }
      _currentUser = null;
      _lastActivity = null;
    }
    
    _isLoading = false;
    _safeNotifyListeners();
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
    if (_disposed) return false;
    
    try {
      _lastError = null;
      _currentUser = await _service.login(email, password);
      
      if (_currentUser != null) {
        _updateLastActivity();
        _startSessionTimer();
      }
      
      _safeNotifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthProvider] 登录失败: $e');
      }
      _lastError = _parseErrorMessage(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    if (_disposed) return;
    
    await _service.logout();
    _currentUser = null;
    _lastActivity = null;
    _lastError = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    
    _safeNotifyListeners();
  }

  // 兼容旧方法
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Google登录设置用户状态
  Future<void> setGoogleUser(Map<String, dynamic> userData, String token) async {
    if (_disposed) return;
    
    try {
      _lastError = null;
      
      final user = User.fromJson(userData);
      await _service.setToken(token);
      _currentUser = user;
      
      _updateLastActivity();
      _startSessionTimer();
      
      if (kDebugMode) {
        print('✅ [AuthProvider] Google用户设置成功: ${user.name}');
      }
      _safeNotifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthProvider] 设置Google用户失败: $e');
      }
      _lastError = _parseErrorMessage(e.toString());
      rethrow;
    }
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
  
  /// 安全的notifyListeners调用
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
  
  /// 更新最后活动时间
  void _updateLastActivity() {
    _lastActivity = DateTime.now();
  }
  
  /// 启动会话计时器
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      
      final now = DateTime.now();
      if (_lastActivity != null && 
          now.difference(_lastActivity!) > sessionTimeout) {
        if (kDebugMode) {
          print('⏰ [AuthProvider] 会话超时，自动登出');
        }
        logout();
        timer.cancel();
      }
    });
  }
  
  /// 检查会话是否有效
  bool get isSessionValid {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) < sessionTimeout;
  }
  
  /// 刷新会话
  void refreshSession() {
    if (_currentUser != null && isLoggedIn) {
      _updateLastActivity();
    }
  }
  
  /// 获取会话信息
  Map<String, dynamic> getSessionInfo() {
    return {
      'isLoggedIn': isLoggedIn,
      'lastActivity': _lastActivity?.toIso8601String(),
      'sessionValid': isSessionValid,
      'timeUntilExpiry': _lastActivity != null 
          ? sessionTimeout.inMilliseconds - DateTime.now().difference(_lastActivity!).inMilliseconds
          : 0,
    };
  }
  
  @override
  void dispose() {
    _disposed = true;
    _sessionTimer?.cancel();
    super.dispose();
  }
}