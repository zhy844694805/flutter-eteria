import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/form_validators.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/glass_interactive_widgets.dart';
import 'glass_register_page.dart';
import 'glass_forgot_password_page.dart';

/// 玻璃拟态登录页面
class GlassLoginPage extends StatefulWidget {
  const GlassLoginPage({super.key});

  @override
  State<GlassLoginPage> createState() => _GlassLoginPageState();
}

class _GlassLoginPageState extends State<GlassLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    // 启动动画
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
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
            // 背景装饰粒子效果
            _buildBackgroundParticles(),
            
            // 主要内容
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo动画
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: _buildGlassLogo(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // 表单动画
                        AnimatedBuilder(
                          animation: _formAnimation,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _slideAnimation,
                              child: Opacity(
                                opacity: _formAnimation.value,
                                child: Column(
                                  children: [
                                    _buildGlassForm(),
                                    const SizedBox(height: 24),
                                    _buildGlassLoginButton(),
                                    const SizedBox(height: 20),
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
            ),
            
            // 返回按钮
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlesPainter(),
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

  Widget _buildGlassLogo() {
    return Column(
      children: [
        // 玻璃拟态Logo容器
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
                GlassmorphismColors.glassSurface.withValues(alpha: 0.6),
                GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GlassmorphismColors.shadowHeavy,
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: GlassmorphismColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    GlassIcons.memorial,
                    color: GlassmorphismColors.primary,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 标题
        Text(
          '永念',
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
        
        const SizedBox(height: 8),
        
        Text(
          '让爱永恒传承',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontWeight: FontWeight.w300,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 表单标题
                Text(
                  '欢迎回来',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GlassmorphismColors.textOnGlass,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '请登录您的账户',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
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
                
                // 密码输入框
                GlassFormField(
                  controller: _passwordController,
                  label: '密码',
                  hintText: '请输入密码',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: _isLoading ? null : _handleLogin,
        isLoading: _isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLoading) ...[
              const Icon(
                GlassIcons.login,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _isLoading ? '登录中...' : '登录',
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
    return Column(
      children: [
        // 忘记密码
        GlassButton(
          onPressed: _handleForgotPassword,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Text(
            '忘记密码？',
            style: TextStyle(
              color: GlassmorphismColors.primary.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 注册链接
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '还没有账户？',
              style: TextStyle(
                color: GlassmorphismColors.textSecondary,
                fontSize: 14,
              ),
            ),
            GlassButton(
              onPressed: _navigateToRegister,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              child: Text(
                '立即注册',
                style: TextStyle(
                  color: GlassmorphismColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GlassForgotPasswordPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
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
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GlassRegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
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
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // 使用Snackbar显示成功消息
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('登录成功'),
              backgroundColor: GlassmorphismColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          // AuthProvider状态变化会自动更新UI
        } else {
          final errorMessage = authProvider.lastError ?? '登录失败';
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final errorMessage = authProvider.lastError ?? '登录失败';
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// 背景粒子绘制器
class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // 绘制一些随机分布的圆形粒子
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 73) % size.height;
      final radius = (i % 3) + 1.0;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}