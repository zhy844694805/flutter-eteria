import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';
import '../config/api_config.dart';

/// Google登录按钮组件
class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool enabled;
  final double height;
  final EdgeInsets? padding;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.text = '使用Google登录',
    this.isLoading = false,
    this.enabled = true,
    this.height = 56,
    this.padding,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _hoverController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _hoverController.reverse();
  }

  void _handleTapCancel() {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: widget.enabled ? _handleTapDown : null,
        onTapUp: widget.enabled ? _handleTapUp : null,
        onTapCancel: widget.enabled ? _handleTapCancel : null,
        onTap: widget.enabled && !widget.isLoading ? () {
          HapticFeedback.lightImpact();
          widget.onPressed?.call();
        } : null,
        child: MouseRegion(
          onEnter: (_) {
            if (widget.enabled) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            }
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: AnimatedBuilder(
            animation: _hoverAnimation,
            builder: (context, child) {
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: _buildGradient(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _buildBorderColor(),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8 + (_hoverAnimation.value * 4),
                      offset: Offset(0, 2 + (_hoverAnimation.value * 2)),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
                            Colors.white.withValues(alpha: 0.05 + (_hoverAnimation.value * 0.03)),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTextColor(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ] else ...[
                            _buildGoogleIcon(),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.isLoading ? '登录中...' : widget.text,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getTextColor(),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          // 开发模式提示标识
                          if (ApiConfig.isDevelopment) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'DEV',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient() {
    if (!widget.enabled) {
      return LinearGradient(
        colors: [
          GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
          GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.15 + (_hoverAnimation.value * 0.05)),
        const Color(0xFF4285F4).withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
        const Color(0xFF34A853).withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
        Colors.white.withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  Color _buildBorderColor() {
    if (!widget.enabled) {
      return GlassmorphismColors.glassBorder.withValues(alpha: 0.3);
    }

    return Color.lerp(
      const Color(0xFF4285F4).withValues(alpha: 0.3),
      const Color(0xFF4285F4).withValues(alpha: 0.6),
      _hoverAnimation.value,
    )!;
  }

  Color _getTextColor() {
    if (!widget.enabled) {
      return GlassmorphismColors.textTertiary;
    }

    return Color.lerp(
      GlassmorphismColors.textPrimary,
      const Color(0xFF4285F4),
      _hoverAnimation.value * 0.3,
    )!;
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: GoogleLogoPainter(
          isEnabled: widget.enabled,
          hoverValue: _hoverAnimation.value,
        ),
      ),
    );
  }
}

/// Google Logo绘制器
class GoogleLogoPainter extends CustomPainter {
  final bool isEnabled;
  final double hoverValue;

  GoogleLogoPainter({
    required this.isEnabled,
    required this.hoverValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isEnabled) {
      _drawDisabledLogo(canvas, size);
      return;
    }

    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Google "G" 的简化版本
    // 蓝色部分
    paint.color = Color.lerp(
      const Color(0xFF4285F4),
      const Color(0xFF4285F4),
      1.0 - (hoverValue * 0.2),
    )!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.14159 / 180), // -90度转弧度
      180 * (3.14159 / 180), // 180度转弧度
      true,
      paint,
    );

    // 红色部分
    paint.color = Color.lerp(
      const Color(0xFFEA4335),
      const Color(0xFFEA4335),
      1.0 - (hoverValue * 0.2),
    )!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      90 * (3.14159 / 180), // 90度转弧度
      90 * (3.14159 / 180), // 90度转弧度
      true,
      paint,
    );

    // 绿色部分
    paint.color = Color.lerp(
      const Color(0xFF34A853),
      const Color(0xFF34A853),
      1.0 - (hoverValue * 0.2),
    )!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      180 * (3.14159 / 180), // 180度转弧度
      90 * (3.14159 / 180), // 90度转弧度
      true,
      paint,
    );

    // 黄色部分
    paint.color = Color.lerp(
      const Color(0xFFFBBC05),
      const Color(0xFFFBBC05),
      1.0 - (hoverValue * 0.2),
    )!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      270 * (3.14159 / 180), // 270度转弧度
      90 * (3.14159 / 180), // 90度转弧度
      true,
      paint,
    );

    // 白色内圆
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);

    // 蓝色"G"
    paint.color = const Color(0xFF4285F4);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'G',
        style: TextStyle(
          color: paint.color,
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawDisabledLogo(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = GlassmorphismColors.textTertiary.withValues(alpha: 0.4);
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}