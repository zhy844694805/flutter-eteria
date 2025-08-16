import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isVerified;

  // 初始化
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final authService = await AuthService.getInstance();
      _currentUser = await authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 设置当前用户
  void setCurrentUser(User user) {
    _currentUser = user;
    _setError(null);
    notifyListeners();
  }

  // 登录
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final authService = await AuthService.getInstance();
      final result = await authService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
      } else {
        _setError(result.message);
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = '登录失败: $e';
      _setError(error);
      return AuthResult.failure(error);
    } finally {
      _setLoading(false);
    }
  }

  // 注册
  Future<AuthResult> register({
    required String email,
    required String name,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final authService = await AuthService.getInstance();
      final result = await authService.register(
        email: email,
        name: name,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
      } else {
        _setError(result.message);
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = '注册失败: $e';
      _setError(error);
      return AuthResult.failure(error);
    } finally {
      _setLoading(false);
    }
  }

  // 验证邮箱
  Future<AuthResult> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final authService = await AuthService.getInstance();
      final result = await authService.verifyEmail(
        email: email,
        verificationCode: verificationCode,
      );

      if (result.success) {
        _currentUser = result.user;
      } else {
        _setError(result.message);
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = '验证失败: $e';
      _setError(error);
      return AuthResult.failure(error);
    } finally {
      _setLoading(false);
    }
  }

  // 重新发送验证码
  Future<AuthResult> resendVerificationCode(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final authService = await AuthService.getInstance();
      final result = await authService.resendVerificationCode(email);

      if (result.success) {
        _currentUser = result.user;
      } else {
        _setError(result.message);
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = '发送失败: $e';
      _setError(error);
      return AuthResult.failure(error);
    } finally {
      _setLoading(false);
    }
  }

  // 登出
  Future<void> logout() async {
    _setLoading(true);
    try {
      final authService = await AuthService.getInstance();
      await authService.logout();
      _currentUser = null;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('登出失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 清除错误
  void clearError() {
    _setError(null);
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }
}