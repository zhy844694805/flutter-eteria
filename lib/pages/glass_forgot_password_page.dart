import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/form_validators.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/glass_interactive_widgets.dart';

/// 玻璃拟态忘记密码页面
class GlassForgotPasswordPage extends StatefulWidget {
  const GlassForgotPasswordPage({super.key});

  @override
  State<GlassForgotPasswordPage> createState() => _GlassForgotPasswordPageState();
}

class _GlassForgotPasswordPageState extends State<GlassForgotPasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _isSendingCode = false;
  bool _isResettingPassword = false;
  
  // 当前步骤：0=输入邮箱，1=验证码和新密码
  int _currentStep = 0;

  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _stepController;
  
  late Animation<double> _headerAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<Offset> _stepSlideAnimation;

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _stepSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeOutCubic,
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // 底部背景填充
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: GlassmorphismColors.backgroundGradient,
                ),
              ),
            ),
            // 背景装饰
            _buildBackgroundDecoration(),
            
            // 主要内容
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
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
                                  _buildStepIndicator(),
                                  const SizedBox(height: 24),
                                  _buildGlassForm(),
                                  const SizedBox(height: 24),
                                  _buildActionButton(),
                                  const SizedBox(height: 24),
                                  _buildBackToLogin(),
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

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ForgotPasswordBackgroundPainter(),
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
          '找回密码',
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
          _currentStep == 0 ? '输入您的邮箱地址，我们将发送验证码' : '输入验证码并设置新密码',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontWeight: FontWeight.w300,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
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
        children: [
          // 步骤1
          _buildStepItem(0, '邮箱验证', GlassIcons.email),
          
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _currentStep > 0
                      ? [GlassmorphismColors.primary, GlassmorphismColors.primary.withValues(alpha: 0.5)]
                      : [GlassmorphismColors.glassBorder, GlassmorphismColors.glassBorder.withValues(alpha: 0.3)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          
          // 步骤2
          _buildStepItem(1, '重设密码', GlassIcons.lock),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [GlassmorphismColors.primary, GlassmorphismColors.primary.withValues(alpha: 0.7)]
                  )
                : null,
            color: isActive ? null : GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? GlassmorphismColors.primary : GlassmorphismColors.glassBorder,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : GlassmorphismColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isActive ? GlassmorphismColors.primary : GlassmorphismColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
            child: _currentStep == 0 ? _buildStep1Form() : _buildStep2Form(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Form() {
    return Column(
      children: [
        // 邮箱输入框
        GlassFormField(
          controller: _emailController,
          label: '邮箱地址',
          hintText: '请输入注册时使用的邮箱',
          prefixIcon: Icon(GlassIcons.email, color: GlassmorphismColors.textSecondary),
          keyboardType: TextInputType.emailAddress,
          validator: FormValidators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildStep2Form() {
    return Column(
      children: [
        // 验证码输入框
        GlassFormField(
          controller: _verificationCodeController,
          label: '验证码',
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
        
        const SizedBox(height: 20),
        
        // 新密码输入框
        GlassFormField(
          controller: _newPasswordController,
          label: '新密码',
          hintText: '请输入新密码（至少6位）',
          prefixIcon: Icon(GlassIcons.lock, color: GlassmorphismColors.textSecondary),
          obscureText: !_isNewPasswordVisible,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
            child: Icon(
              _isNewPasswordVisible ? GlassIcons.eyeOff : GlassIcons.eye,
              color: GlassmorphismColors.textSecondary,
              size: 20,
            ),
          ),
          validator: FormValidators.validatePassword,
        ),
        
        const SizedBox(height: 20),
        
        // 确认新密码输入框
        GlassFormField(
          controller: _confirmPasswordController,
          label: '确认新密码',
          hintText: '请再次输入新密码',
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
              return '请确认新密码';
            }
            if (value != _newPasswordController.text) {
              return '两次输入的密码不一致';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: _isLoading ? null : _handleAction,
        isLoading: _isLoading,
        backgroundColor: GlassmorphismColors.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLoading) ...[
              Icon(
                _currentStep == 0 ? GlassIcons.email : Icons.lock_reset,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _isLoading
                  ? (_currentStep == 0 ? '发送中...' : '重置中...')
                  : (_currentStep == 0 ? '发送验证码' : '重置密码'),
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

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '想起密码了？',
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
            '返回登录',
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

  Future<void> _handleAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep == 0) {
      await _handleSendVerificationCode();
    } else {
      await _handleResetPassword();
    }
  }

  Future<void> _handleSendVerificationCode() async {
    setState(() {
      _isSendingCode = true;
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendVerificationCode(_emailController.text.trim());

      if (mounted) {
        if (success) {
          setState(() {
            _isCodeSent = true;
            _currentStep = 1;
          });
          
          // 启动步骤切换动画
          _stepController.forward();
          
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() {
      _isResettingPassword = true;
      _isLoading = true;
    });

    try {
      // TODO: 实现重置密码的API调用
      // 这里需要后端提供重置密码的接口
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('密码重置成功！请使用新密码登录'),
            backgroundColor: GlassmorphismColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // 返回登录页面
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('密码重置失败: $e'),
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
          _isResettingPassword = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    _stepController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

/// 忘记密码页面背景装饰绘制器
class ForgotPasswordBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // 绘制锁形图案
    for (int i = 0; i < 8; i++) {
      final x = (i * 97) % size.width;
      final y = (i * 131) % size.height;
      final radius = (i % 3) + 3.0;
      
      // 绘制锁的圆形部分
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
      
      // 绘制锁的方形部分
      canvas.drawRRect(
        RRect.fromLTRBR(
          x - radius * 0.8,
          y + radius * 0.3,
          x + radius * 0.8,
          y + radius * 1.5,
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // 绘制连接线
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final startX = (i * 107) % size.width;
      final startY = (i * 139) % size.height;
      final endX = ((i + 2) * 107) % size.width;
      final endY = ((i + 2) * 139) % size.height;
      
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