import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart';

/// 欢迎页面 - 让用户选择登录或游客模式
class WelcomePage extends StatefulWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGuestMode;

  const WelcomePage({
    super.key,
    required this.onLoginPressed,
    required this.onGuestMode,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentOpacityAnimation;

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
    
    _contentController = AnimationController(
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

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    ));

    // 启动动画
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
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
            // 背景装饰粒子效果
            _buildBackgroundParticles(),
            
            // 主要内容
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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
                      
                      const SizedBox(height: 60),
                      
                      // 内容动画
                      AnimatedBuilder(
                        animation: _contentController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _contentSlideAnimation,
                            child: Opacity(
                              opacity: _contentOpacityAnimation.value,
                              child: Column(
                                children: [
                                  _buildWelcomeMessage(),
                                  const SizedBox(height: 40),
                                  _buildActionButtons(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WelcomeBackgroundPainter(),
      ),
    );
  }

  Widget _buildGlassLogo() {
    return Column(
      children: [
        // 玻璃拟态Logo容器
        Container(
          width: 140,
          height: 140,
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
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: GlassmorphismColors.shadowHeavy,
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    GlassIcons.memorial,
                    color: GlassmorphismColors.primary,
                    size: 70,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // 标题
        Text(
          '永念',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 48,
            color: GlassmorphismColors.textOnGlass,
            shadows: [
              Shadow(
                color: GlassmorphismColors.shadowLight,
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          '让爱永恒传承',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontWeight: FontWeight.w300,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
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
                Text(
                  '欢迎使用永念',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: GlassmorphismColors.textOnGlass,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '一个用于纪念逝者、保存美好回忆的应用。\n您可以选择登录获得完整功能，\n或以游客模式浏览公开内容。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 登录按钮
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: widget.onLoginPressed,
            backgroundColor: GlassmorphismColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  GlassIcons.login,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  '登录 / 注册',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 游客模式按钮
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: widget.onGuestMode,
            backgroundColor: Colors.transparent,
            borderColor: GlassmorphismColors.glassBorder,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  GlassIcons.eyeOff,
                  color: GlassmorphismColors.textOnGlass,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  '游客模式浏览',
                  style: TextStyle(
                    color: GlassmorphismColors.textOnGlass,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 功能说明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '功能对比',
                    style: TextStyle(
                      color: GlassmorphismColors.textOnGlass,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureComparison(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureComparison() {
    return Column(
      children: [
        _buildFeatureRow('浏览公开纪念', true, true),
        _buildFeatureRow('创建纪念内容', false, true),
        _buildFeatureRow('上传照片视频', false, true),
        _buildFeatureRow('个人中心', false, true),
        _buildFeatureRow('收藏点赞', false, true),
      ],
    );
  }

  Widget _buildFeatureRow(String feature, bool guestMode, bool loginMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: TextStyle(
                color: GlassmorphismColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              guestMode ? Icons.check : Icons.close,
              color: guestMode ? GlassmorphismColors.success : GlassmorphismColors.error,
              size: 16,
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              loginMode ? Icons.check : Icons.close,
              color: loginMode ? GlassmorphismColors.success : GlassmorphismColors.error,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

/// 欢迎页面背景装饰绘制器
class WelcomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // 绘制随机分布的圆形粒子
    for (int i = 0; i < 25; i++) {
      final x = (i * 41) % size.width;
      final y = (i * 71) % size.height;
      final radius = (i % 4) + 1.5;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // 绘制一些连接线
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final startX = (i * 89) % size.width;
      final startY = (i * 113) % size.height;
      final endX = ((i + 2) * 89) % size.width;
      final endY = ((i + 2) * 113) % size.height;
      
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