import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/form_validators.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/google_sign_in_button.dart';
import '../services/google_api_service.dart';
import '../config/api_config.dart';
import 'user_agreement_page.dart';
import 'privacy_policy_page.dart';

/// 玻璃拟态注册页面
class GlassRegisterPage extends StatefulWidget {
  const GlassRegisterPage({super.key});

  @override
  State<GlassRegisterPage> createState() => _GlassRegisterPageState();
}

class _GlassRegisterPageState extends State<GlassRegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _isCodeSent = false;
  bool _isSendingCode = false;
  bool _isGoogleLoading = false;

  late AnimationController _headerController;
  late AnimationController _formController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));

    // 启动动画
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // 背景装饰
            _buildBackgroundDecoration(),
            
            // 主要内容
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // 为返回按钮留空间
                      
                      // 头部动画
                      AnimatedBuilder(
                        animation: _headerAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _headerAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                              child: _buildGlassHeader(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 表单动画
                      AnimatedBuilder(
                        animation: _formController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _formSlideAnimation,
                            child: Opacity(
                              opacity: _formOpacityAnimation.value,
                              child: Column(
                                children: [
                                  _buildGlassForm(),
                                  const SizedBox(height: 24),
                                  _buildTermsSection(),
                                  const SizedBox(height: 24),
                                  _buildGlassRegisterButton(),
                                  const SizedBox(height: 24),
                                  _buildOrDivider(),
                                  const SizedBox(height: 24),
                                  _buildGoogleSignInButton(),
                                  const SizedBox(height: 24),
                                  _buildBottomLinks(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 返回按钮
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: RegisterBackgroundPainter(),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: GlassButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(
          Icons.arrow_back_ios,
          color: GlassmorphismColors.textOnGlass,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主标题
        Text(
          '创建账户',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GlassmorphismColors.textOnGlass,
            shadows: [
              Shadow(
                color: GlassmorphismColors.shadowLight,
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 副标题
        Text(
          '加入永念，开始您的纪念之旅',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontWeight: FontWeight.w300,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: GlassmorphismDecorations.glassCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // 姓名输入框
                GlassFormField(
                  controller: _nameController,
                  label: '姓名',
                  hintText: '请输入您的姓名',
                  prefixIcon: Icon(GlassIcons.person, color: GlassmorphismColors.textSecondary),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入姓名';
                    }
                    if (value.trim().length < 2) {
                      return '姓名至少需要2个字符';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 邮箱输入框
                GlassFormField(
                  controller: _emailController,
                  label: '邮箱地址',
                  hintText: '请输入邮箱地址',
                  prefixIcon: Icon(GlassIcons.email, color: GlassmorphismColors.textSecondary),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidators.validateEmail,
                ),
                
                const SizedBox(height: 20),
                
                // 验证码输入框
                _buildVerificationCodeField(),
                
                const SizedBox(height: 20),
                
                // 密码输入框
                GlassFormField(
                  controller: _passwordController,
                  label: '密码',
                  hintText: '请输入密码（至少6位）',
                  prefixIcon: Icon(GlassIcons.lock, color: GlassmorphismColors.textSecondary),
                  obscureText: !_isPasswordVisible,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isPasswordVisible ? GlassIcons.eyeOff : GlassIcons.eye,
                      color: GlassmorphismColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: FormValidators.validatePassword,
                ),
                
                const SizedBox(height: 20),
                
                // 确认密码输入框
                GlassFormField(
                  controller: _confirmPasswordController,
                  label: '确认密码',
                  hintText: '请再次输入密码',
                  prefixIcon: Icon(GlassIcons.lock, color: GlassmorphismColors.textSecondary),
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isConfirmPasswordVisible ? GlassIcons.eyeOff : GlassIcons.eye,
                      color: GlassmorphismColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请确认密码';
                    }
                    if (value != _passwordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '邮箱验证码',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GlassFormField(
                controller: _verificationCodeController,
                hintText: '请输入6位验证码',
                prefixIcon: Icon(GlassIcons.security, color: GlassmorphismColors.textSecondary),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入验证码';
                  }
                  if (value.trim().length != 6) {
                    return '验证码必须是6位数字';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: GlassButton(
                onPressed: _isSendingCode ? null : _handleSendVerificationCode,
                isLoading: _isSendingCode,
                backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.8),
                child: Text(
                  _isCodeSent ? '重新发送' : '发送验证码',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _agreedToTerms = !_agreedToTerms;
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _agreedToTerms 
                      ? GlassmorphismColors.primary 
                      : GlassmorphismColors.glassBorder,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: _agreedToTerms 
                    ? GlassmorphismColors.primary 
                    : Colors.transparent,
              ),
              child: _agreedToTerms
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: GlassmorphismColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: '我已阅读并同意'),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: _navigateToUserAgreement,
                      child: Text(
                        '《用户协议》',
                        style: TextStyle(
                          color: GlassmorphismColors.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '和'),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: _navigateToPrivacyPolicy,
                      child: Text(
                        '《隐私政策》',
                        style: TextStyle(
                          color: GlassmorphismColors.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: (_isLoading || !_agreedToTerms) ? null : _handleRegister,
        isLoading: _isLoading,
        backgroundColor: _agreedToTerms 
            ? GlassmorphismColors.primary
            : GlassmorphismColors.glassBorder,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLoading) ...[
              const Icon(
                GlassIcons.userPlus,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _isLoading ? '注册中...' : '创建账户',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Text(
            '立即登录',
            style: TextStyle(
              color: GlassmorphismColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendVerificationCode() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先输入邮箱地址'),
          backgroundColor: GlassmorphismColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendVerificationCode(_emailController.text.trim());

      if (mounted) {
        if (success) {
          setState(() {
            _isCodeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('验证码已发送到您的邮箱'),
              backgroundColor: GlassmorphismColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          final errorMessage = authProvider.lastError ?? '验证码发送失败，请重试';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: GlassmorphismColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('验证码发送失败: $e'),
            backgroundColor: GlassmorphismColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先同意用户协议和隐私政策'),
          backgroundColor: GlassmorphismColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      if (ApiConfig.isDevelopment) {
        // 开发环境显示提示信息
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Google注册功能（开发模式）'),
                const SizedBox(height: 4),
                Text(
                  '生产环境需要配置Google OAuth密钥',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // 执行Google注册流程
      final result = await GoogleAuthHelper.performGoogleSignIn();
      
      if (result != null && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // 使用Google注册结果更新认证状态
        final userData = result['data']?['user'];
        final token = result['data']?['token'];
        
        if (userData != null && token != null) {
          // 更新认证状态
          await authProvider.setGoogleUser(userData, token);
          
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Google注册成功'),
              backgroundColor: GlassmorphismColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // 返回登录页面或跳转到主页
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Google注册失败: ${error.toString()}'),
            backgroundColor: GlassmorphismColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先同意用户协议和隐私政策'),
          backgroundColor: GlassmorphismColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _nameController.text.trim(),
        _passwordController.text,
        _verificationCodeController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('注册成功！欢迎加入永念'),
              backgroundColor: GlassmorphismColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // 注册成功后返回到主界面
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          final errorMessage = authProvider.lastError ?? '注册失败';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: GlassmorphismColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册失败: $e'),
            backgroundColor: GlassmorphismColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToUserAgreement() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const UserAgreementPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PrivacyPolicyPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlassmorphismColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return GoogleSignInButton(
      onPressed: _isLoading || _isGoogleLoading || !_agreedToTerms ? null : _handleGoogleRegister,
      isLoading: _isGoogleLoading,
      enabled: !_isLoading && !_isGoogleLoading && _agreedToTerms,
      text: 'Google 注册',
      height: 56,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}

/// 注册页面背景装饰绘制器
class RegisterBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // 绘制背景几何图形
    for (int i = 0; i < 15; i++) {
      final x = (i * 61) % size.width;
      final y = (i * 97) % size.height;
      final radius = (i % 4) + 2.0;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // 绘制一些线条
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final startX = (i * 83) % size.width;
      final startY = (i * 121) % size.height;
      final endX = ((i + 1) * 83) % size.width;
      final endY = ((i + 1) * 121) % size.height;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}