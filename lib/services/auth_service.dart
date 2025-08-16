import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'email_service.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static AuthService? _instance;
  SharedPreferences? _prefs;

  AuthService._();

  static Future<AuthService> getInstance() async {
    _instance ??= AuthService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 生成用户ID
  String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(10000);
    return 'user_${timestamp}_$randomNum';
  }

  // 生成密码哈希
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 获取所有用户
  Future<List<User>> _getUsers() async {
    final String? usersJson = _prefs?.getString(_usersKey);
    if (usersJson == null) return [];
    
    try {
      final List<dynamic> usersList = json.decode(usersJson);
      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 保存用户列表
  Future<void> _saveUsers(List<User> users) async {
    final String usersJson = json.encode(
      users.map((user) => user.toJson()).toList(),
    );
    await _prefs?.setString(_usersKey, usersJson);
  }

  // 根据邮箱查找用户
  Future<User?> _findUserByEmail(String email) async {
    final users = await _getUsers();
    try {
      return users.firstWhere((user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // 注册新用户
  Future<AuthResult> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      // 检查邮箱是否已注册
      final existingUser = await _findUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.failure('该邮箱已被注册');
      }

      // 生成验证码
      final verificationCode = EmailService.generateVerificationCode();
      final verificationExpiry = DateTime.now().add(const Duration(minutes: 10));

      // 创建新用户
      final user = User(
        id: _generateUserId(),
        email: email.toLowerCase(),
        name: name,
        status: UserStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        verificationCode: verificationCode,
        verificationCodeExpiry: verificationExpiry,
      );

      // 发送验证邮件
      final emailSent = await EmailService.sendVerificationEmail(
        toEmail: email,
        userName: name,
        verificationCode: verificationCode,
      );

      if (!emailSent) {
        return AuthResult.failure('验证邮件发送失败，请稍后重试');
      }

      // 保存用户（密码存储在本地，这里简化处理）
      final users = await _getUsers();
      users.add(user);
      await _saveUsers(users);

      // 保存密码哈希到本地（实际应用中应该存储在安全的地方）
      await _prefs?.setString('password_${user.id}', _hashPassword(password));

      return AuthResult.success(
        user: user,
        message: '注册成功！验证邮件已发送，请查收邮箱',
      );
    } catch (e) {
      return AuthResult.failure('注册失败：$e');
    }
  }

  // 验证邮箱
  Future<AuthResult> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final user = await _findUserByEmail(email);
      if (user == null) {
        return AuthResult.failure('用户不存在');
      }

      if (user.verificationCode != verificationCode) {
        return AuthResult.failure('验证码错误');
      }

      if (!user.isVerificationCodeValid) {
        return AuthResult.failure('验证码已过期');
      }

      // 更新用户状态
      final updatedUser = user.copyWith(
        status: UserStatus.verified,
        updatedAt: DateTime.now(),
        verificationCode: null,
        verificationCodeExpiry: null,
      );

      final users = await _getUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
        await _saveUsers(users);
      }

      // 发送欢迎邮件
      await EmailService.sendWelcomeEmail(
        toEmail: email,
        userName: user.name,
      );

      return AuthResult.success(
        user: updatedUser,
        message: '邮箱验证成功！',
      );
    } catch (e) {
      return AuthResult.failure('验证失败：$e');
    }
  }

  // 重新发送验证码
  Future<AuthResult> resendVerificationCode(String email) async {
    try {
      final user = await _findUserByEmail(email);
      if (user == null) {
        return AuthResult.failure('用户不存在');
      }

      if (user.isVerified) {
        return AuthResult.failure('邮箱已验证');
      }

      // 生成新验证码
      final verificationCode = EmailService.generateVerificationCode();
      final verificationExpiry = DateTime.now().add(const Duration(minutes: 10));

      // 更新用户
      final updatedUser = user.copyWith(
        verificationCode: verificationCode,
        verificationCodeExpiry: verificationExpiry,
        updatedAt: DateTime.now(),
      );

      final users = await _getUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
        await _saveUsers(users);
      }

      // 发送验证邮件
      final emailSent = await EmailService.sendVerificationEmail(
        toEmail: email,
        userName: user.name,
        verificationCode: verificationCode,
      );

      if (!emailSent) {
        return AuthResult.failure('验证邮件发送失败，请稍后重试');
      }

      return AuthResult.success(
        user: updatedUser,
        message: '验证码已重新发送，请查收邮箱',
      );
    } catch (e) {
      return AuthResult.failure('发送失败：$e');
    }
  }

  // 登录
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _findUserByEmail(email);
      if (user == null) {
        return AuthResult.failure('用户不存在');
      }

      // 检查密码
      final storedPasswordHash = _prefs?.getString('password_${user.id}');
      if (storedPasswordHash != _hashPassword(password)) {
        return AuthResult.failure('密码错误');
      }

      if (!user.isVerified) {
        return AuthResult.failure('请先验证邮箱');
      }

      if (user.isSuspended) {
        return AuthResult.failure('账户已被暂停');
      }

      // 保存当前用户
      await _prefs?.setString(_currentUserKey, json.encode(user.toJson()));

      return AuthResult.success(
        user: user,
        message: '登录成功',
      );
    } catch (e) {
      return AuthResult.failure('登录失败：$e');
    }
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    final String? userJson = _prefs?.getString(_currentUserKey);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }

  // 登出
  Future<void> logout() async {
    await _prefs?.remove(_currentUserKey);
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null && user.isVerified;
  }

  // 清空所有数据
  Future<void> clearAll() async {
    await _prefs?.remove(_usersKey);
    await _prefs?.remove(_currentUserKey);
  }
}

// 认证结果类
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult._({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResult.success({required User user, required String message}) {
    return AuthResult._(
      success: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
}