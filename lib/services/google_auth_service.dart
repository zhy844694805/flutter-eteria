import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

/// Google OAuth认证服务
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  late GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  /// 初始化Google登录
  void initialize() {
    if (_isInitialized) return;

    _googleSignIn = GoogleSignIn(
      // 这些配置需要在部署后设置
      scopes: [
        'email',
        'profile',
      ],
      // 服务器客户端ID（部署后配置）
      // serverClientId: 'YOUR_SERVER_CLIENT_ID',
    );

    _isInitialized = true;
    
    if (ApiConfig.isDevelopment) {
      print('🔧 [GoogleAuthService] 已初始化 (开发模式)');
      print('⚠️ [GoogleAuthService] 生产环境需要配置 Google OAuth 客户端ID');
    }
  }

  /// Google登录
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        initialize();
      }

      if (ApiConfig.isDevelopment) {
        print('🔐 [GoogleAuthService] 开始Google登录流程...');
      }

      // 先尝试静默登录
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      
      if (account == null) {
        // 如果静默登录失败，显示登录界面
        account = await _googleSignIn.signIn();
      }

      if (account != null) {
        if (ApiConfig.isDevelopment) {
          print('✅ [GoogleAuthService] Google登录成功');
          print('👤 [GoogleAuthService] 用户: ${account.displayName}');
          print('📧 [GoogleAuthService] 邮箱: ${account.email}');
        }
      } else {
        if (ApiConfig.isDevelopment) {
          print('❌ [GoogleAuthService] Google登录被用户取消');
        }
      }

      return account;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthService] Google登录失败: $error');
      }
      
      // 在开发环境下，模拟登录失败但不抛出异常
      if (ApiConfig.isDevelopment) {
        _showDevelopmentModeInfo();
        return null;
      }
      
      rethrow;
    }
  }

  /// 获取Google访问令牌
  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthService] 获取访问令牌失败: $error');
      }
      return null;
    }
  }

  /// 获取ID令牌（用于后端验证）
  Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthService] 获取ID令牌失败: $error');
      }
      return null;
    }
  }

  /// 登出Google账号
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (ApiConfig.isDevelopment) {
        print('👋 [GoogleAuthService] Google账号已登出');
      }
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthService] Google登出失败: $error');
      }
    }
  }

  /// 断开Google账号连接
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      if (ApiConfig.isDevelopment) {
        print('🔌 [GoogleAuthService] Google账号连接已断开');
      }
    } catch (error) {
      if (ApiConfig.isDevelopment) {
        print('💥 [GoogleAuthService] Google断开连接失败: $error');
      }
    }
  }

  /// 检查是否已登录Google
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// 获取当前Google用户
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// 显示开发模式信息
  void _showDevelopmentModeInfo() {
    if (ApiConfig.isDevelopment) {
      print('''
📋 [GoogleAuthService] 开发模式提示：
   
   Google登录功能需要以下配置才能正常工作：
   
   1. Android配置：
      • 在 Google Cloud Console 创建 OAuth 2.0 客户端ID
      • 配置 android/app/google-services.json
      • 获取 SHA-1 签名证书指纹
   
   2. iOS配置：
      • 配置 ios/Runner/GoogleService-Info.plist
      • 在 ios/Runner/Info.plist 添加 URL scheme
   
   3. 后端配置：
      • 设置服务器客户端ID用于令牌验证
      • 创建 Google OAuth 验证接口
   
   部署到生产环境后请按照 DEPLOYMENT.md 中的指导完成配置。
''');
    }
  }

  /// 获取用户信息用于注册
  Map<String, dynamic>? getUserDataForRegistration() {
    final account = currentUser;
    if (account == null) return null;

    return {
      'email': account.email,
      'name': account.displayName ?? '',
      'avatar_url': account.photoUrl,
      'google_id': account.id,
      'provider': 'google',
    };
  }
}

/// Google用户数据模型
class GoogleUserData {
  final String email;
  final String name;
  final String? avatarUrl;
  final String googleId;

  GoogleUserData({
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.googleId,
  });

  factory GoogleUserData.fromGoogleAccount(GoogleSignInAccount account) {
    return GoogleUserData(
      email: account.email,
      name: account.displayName ?? '',
      avatarUrl: account.photoUrl,
      googleId: account.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'google_id': googleId,
      'provider': 'google',
    };
  }
}