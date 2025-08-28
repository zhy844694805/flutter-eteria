import '../config/api_config.dart';
import 'api_client.dart';
import 'google_auth_service.dart';

/// Google OAuth相关的API服务
class GoogleApiService {
  static final ApiClient _apiClient = ApiClient();

  /// 使用Google ID令牌登录后端
  static Future<Map<String, dynamic>> signInWithGoogleToken({
    required String idToken,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      if (ApiConfig.isDevelopment) {
        print('🔐 [GoogleApiService] 发送Google登录请求到后端');
      }

      final response = await _apiClient.request(
        'POST',
        '/auth/google/signin',
        body: {
          'id_token': idToken,
          'email': email,
          'name': name,
          'avatar_url': avatarUrl,
        },
      );

      if (ApiConfig.isDevelopment) {
        print('✅ [GoogleApiService] Google登录成功');
        print('📦 [GoogleApiService] 响应: ${response.toString().substring(0, 100)}...');
      }

      return response;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleApiService] Google登录失败: $error');
        
        // 开发环境模拟成功响应
        return _mockSuccessResponse(email, name, avatarUrl);
      }
      
      rethrow;
    }
  }

  /// 使用Google ID令牌注册新账户
  static Future<Map<String, dynamic>> registerWithGoogleToken({
    required String idToken,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      if (ApiConfig.isDevelopment) {
        print('📝 [GoogleApiService] 发送Google注册请求到后端');
      }

      final response = await _apiClient.request(
        'POST',
        '/auth/google/register',
        body: {
          'id_token': idToken,
          'email': email,
          'name': name,
          'avatar_url': avatarUrl,
        },
      );

      if (ApiConfig.isDevelopment) {
        print('✅ [GoogleApiService] Google注册成功');
        print('📦 [GoogleApiService] 响应: ${response.toString().substring(0, 100)}...');
      }

      return response;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleApiService] Google注册失败: $error');
        
        // 开发环境模拟成功响应
        return _mockSuccessResponse(email, name, avatarUrl);
      }
      
      rethrow;
    }
  }

  /// 检查Google账号是否已存在
  static Future<bool> checkGoogleAccountExists(String email) async {
    try {
      if (ApiConfig.isDevelopment) {
        print('🔍 [GoogleApiService] 检查Google账号是否存在: $email');
      }

      final response = await _apiClient.request(
        'POST',
        '/auth/google/check',
        body: {'email': email},
      );

      final exists = response['exists'] ?? false;

      if (ApiConfig.isDevelopment) {
        print('📋 [GoogleApiService] 账号存在状态: $exists');
      }

      return exists;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleApiService] 检查账号失败: $error');
        // 开发环境默认返回false（账号不存在）
        return false;
      }
      
      rethrow;
    }
  }

  /// 绑定Google账号到现有用户
  static Future<Map<String, dynamic>> linkGoogleAccount({
    required String idToken,
    required String email,
  }) async {
    try {
      if (ApiConfig.isDevelopment) {
        print('🔗 [GoogleApiService] 绑定Google账号到现有用户');
      }

      final response = await _apiClient.request(
        'POST',
        '/auth/google/link',
        body: {
          'id_token': idToken,
          'email': email,
        },
      );

      if (ApiConfig.isDevelopment) {
        print('✅ [GoogleApiService] Google账号绑定成功');
      }

      return response;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleApiService] Google账号绑定失败: $error');
        
        // 开发环境模拟成功响应
        return {
          'success': true,
          'message': '账号绑定成功（开发模式模拟）',
        };
      }
      
      rethrow;
    }
  }

  /// 解绑Google账号
  static Future<Map<String, dynamic>> unlinkGoogleAccount() async {
    try {
      if (ApiConfig.isDevelopment) {
        print('🔓 [GoogleApiService] 解绑Google账号');
      }

      final response = await _apiClient.request(
        'POST',
        '/auth/google/unlink',
      );

      if (ApiConfig.isDevelopment) {
        print('✅ [GoogleApiService] Google账号解绑成功');
      }

      return response;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleApiService] Google账号解绑失败: $error');
        
        // 开发环境模拟成功响应
        return {
          'success': true,
          'message': '账号解绑成功（开发模式模拟）',
        };
      }
      
      rethrow;
    }
  }

  /// 开发环境模拟成功响应
  static Map<String, dynamic> _mockSuccessResponse(
    String email,
    String name,
    String? avatarUrl,
  ) {
    if (ApiConfig.isDevelopment) {
      print('🎭 [GoogleApiService] 使用模拟响应（开发模式）');
    }

    return {
      'success': true,
      'message': 'Google认证成功（开发模式模拟）',
      'data': {
        'user': {
          'id': 999, // 模拟用户ID
          'email': email,
          'name': name,
          'avatar_url': avatarUrl,
          'is_verified': true,
          'provider': 'google',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        'token': 'mock_google_jwt_token_for_development',
        'expires_in': 86400,
      },
    };
  }
}

/// Google登录相关错误类
class GoogleAuthException implements Exception {
  final String message;
  final String? code;

  GoogleAuthException(this.message, {this.code});

  @override
  String toString() => 'GoogleAuthException: $message ${code != null ? '($code)' : ''}';
}

/// 常用的Google登录流程处理
class GoogleAuthHelper {
  static final GoogleAuthService _googleAuth = GoogleAuthService();

  /// 完整的Google登录流程
  static Future<Map<String, dynamic>?> performGoogleSignIn() async {
    try {
      // 1. 初始化Google登录服务
      _googleAuth.initialize();

      // 2. 执行Google登录
      final googleAccount = await _googleAuth.signInWithGoogle();
      if (googleAccount == null) {
        throw GoogleAuthException('用户取消了Google登录');
      }

      // 3. 获取ID令牌
      final idToken = await _googleAuth.getIdToken();
      if (idToken == null) {
        throw GoogleAuthException('无法获取Google ID令牌');
      }

      // 4. 检查账号是否已存在
      final accountExists = await GoogleApiService.checkGoogleAccountExists(
        googleAccount.email,
      );

      // 5. 根据账号存在状态选择登录或注册
      if (accountExists) {
        return await GoogleApiService.signInWithGoogleToken(
          idToken: idToken,
          email: googleAccount.email,
          name: googleAccount.displayName ?? '',
          avatarUrl: googleAccount.photoUrl,
        );
      } else {
        return await GoogleApiService.registerWithGoogleToken(
          idToken: idToken,
          email: googleAccount.email,
          name: googleAccount.displayName ?? '',
          avatarUrl: googleAccount.photoUrl,
        );
      }
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthHelper] Google登录流程失败: $error');
      }
      rethrow;
    }
  }

  /// 登出并清理Google状态
  static Future<void> signOut() async {
    await _googleAuth.signOut();
  }

  /// 获取当前Google用户信息
  static GoogleUserData? getCurrentGoogleUser() {
    final account = _googleAuth.currentUser;
    if (account == null) return null;
    return GoogleUserData.fromGoogleAccount(account);
  }
}