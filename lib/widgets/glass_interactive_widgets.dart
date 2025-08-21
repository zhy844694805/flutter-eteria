import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_icons.dart';

/// 悬浮交互按钮 - 带有动态效果
class GlassInteractiveButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const GlassInteractiveButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
    this.height = 56,
    this.padding,
  });

  @override
  State<GlassInteractiveButton> createState() => _GlassInteractiveButtonState();
}

class _GlassInteractiveButtonState extends State<GlassInteractiveButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _rippleController;
  
  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  bool _showRipple = false;
  Offset _rippleCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    );
    
    _pressAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    );
    
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enabled) return;
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = true;
      _showRipple = true;
      _rippleCenter = details.localPosition;
    });
    
    _pressController.forward();
    _rippleController.forward();
    
    // 触觉反馈
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _pressController.reverse();
    
    // 延迟执行回调，让动画完成
    Future.delayed(const Duration(milliseconds: 50), () {
      widget.onPressed?.call();
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _pressAnimation, _rippleAnimation]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Transform.scale(
              scale: 1.0 - (_pressAnimation.value * 0.05),
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // 优化垂直内边距
                decoration: _buildDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none, // 避免内容被裁剪
                    children: [
                      // 水波纹效果
                      if (_showRipple)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RipplePainter(
                              center: _rippleCenter,
                              progress: _rippleAnimation.value,
                              color: widget.foregroundColor?.withValues(alpha: 0.1) ?? 
                                     GlassmorphismColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      // 按钮内容
                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration() {
    final hoverScale = 1.0 + (_hoverAnimation.value * 0.05);
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (widget.backgroundColor ?? GlassmorphismColors.glassSurface)
              .withValues(alpha: 0.8 + (_hoverAnimation.value * 0.2)),
          (widget.backgroundColor ?? GlassmorphismColors.glassSurface)
              .withValues(alpha: 0.4 + (_hoverAnimation.value * 0.1)),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: GlassmorphismColors.glassBorder.withValues(
          alpha: 0.5 + (_hoverAnimation.value * 0.5),
        ),
        width: 1.0 + (_hoverAnimation.value * 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: GlassmorphismColors.shadowLight,
          blurRadius: 8 + (_hoverAnimation.value * 8),
          offset: Offset(0, 2 + (_hoverAnimation.value * 4)),
        ),
        if (_hoverAnimation.value > 0)
          BoxShadow(
            color: GlassmorphismColors.shadowMedium,
            blurRadius: 16 + (_hoverAnimation.value * 8),
            offset: Offset(0, 4 + (_hoverAnimation.value * 2)),
          ),
      ],
    );
  }

  Widget _buildContent() {
    final foregroundColor = widget.foregroundColor ?? GlassmorphismColors.textPrimary;
    
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中对齐
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
              height: 1.0, // 优化行高确保文字完整显示
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 水波纹绘制器
class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;

  RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: ((1.0 - progress) * color.a).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final radius = progress * (size.width + size.height) * 0.5;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// 悬浮卡片容器
class GlassHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final Duration animationDuration;
  final Curve curve;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 4.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.margin,
    this.padding,
  });

  @override
  State<GlassHoverCard> createState() => _GlassHoverCardState();
}

class _GlassHoverCardState extends State<GlassHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.elevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _handleHover(true),
              onExit: (_) => _handleHover(false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  margin: widget.margin,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    gradient: GlassmorphismColors.glassGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GlassmorphismColors.glassBorder.withValues(
                        alpha: (0.5 + (_elevationAnimation.value / widget.elevation * 0.5)).clamp(0.0, 1.0),
                      ),
                      width: 1.0 + (_elevationAnimation.value / widget.elevation * 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GlassmorphismColors.shadowLight,
                        blurRadius: 8 + (_elevationAnimation.value * 2),
                        offset: Offset(0, 2 + _elevationAnimation.value),
                      ),
                      if (_elevationAnimation.value > 0)
                        BoxShadow(
                          color: GlassmorphismColors.shadowMedium,
                          blurRadius: 16 + (_elevationAnimation.value * 2),
                          offset: Offset(0, 4 + (_elevationAnimation.value * 0.5)),
                        ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 悬浮菜单
class GlassFloatingMenu extends StatefulWidget {
  final List<GlassMenuItem> items;
  final Widget child;
  final bool isOpen;
  final VoidCallback? onToggle;

  const GlassFloatingMenu({
    super.key,
    required this.items,
    required this.child,
    this.isOpen = false,
    this.onToggle,
  });

  @override
  State<GlassFloatingMenu> createState() => _GlassFloatingMenuState();
}

class _GlassFloatingMenuState extends State<GlassFloatingMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 200 + (index * 50)),
        vsync: this,
      ),
    );
    
    _itemAnimations = _itemControllers.map((controller) =>
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    ).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(GlassFloatingMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      _toggleMenu();
    }
  }

  void _toggleMenu() {
    if (widget.isOpen) {
      _controller.forward();
      for (int i = 0; i < _itemControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) _itemControllers[i].forward();
        });
      }
    } else {
      _controller.reverse();
      for (final controller in _itemControllers.reversed) {
        controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 菜单项
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final animation = _itemAnimations[index];
          
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Transform.translate(
                  offset: Offset(0, -60.0 * (index + 1) * animation.value),
                  child: Opacity(
                    opacity: animation.value.clamp(0.0, 1.0),
                    child: GlassHoverCard(
                      onTap: () {
                        item.onTap();
                        widget.onToggle?.call();
                      },
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.label != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: GlassmorphismColors.glassSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.label!,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: GlassmorphismColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            item.icon,
                            color: item.color ?? GlassmorphismColors.primary,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        
        // 主按钮
        GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 0.785398, // 45度
                child: widget.child,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 菜单项数据类
class GlassMenuItem {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? color;

  const GlassMenuItem({
    required this.icon,
    this.label,
    required this.onTap,
    this.color,
  });
}

/// 进度指示器
class GlassProgressIndicator extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final String? label;

  const GlassProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.label,
  });

  @override
  State<GlassProgressIndicator> createState() => _GlassProgressIndicatorState();
}

class _GlassProgressIndicatorState extends State<GlassProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GlassProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? GlassmorphismColors.glassSurface,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: widget.value * _animation.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? GlassmorphismColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}