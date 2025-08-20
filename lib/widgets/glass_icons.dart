import 'package:flutter/material.dart';
import '../theme/glassmorphism_theme.dart';

/// 矢量图标系统 - 为纪念应用定制的玻璃风格图标
class GlassIcons {
  // 纪念相关图标
  static const IconData memorial = Icons.account_circle_outlined;
  static const IconData flower = Icons.local_florist_outlined;
  static const IconData heart = Icons.favorite_border;
  static const IconData heartFilled = Icons.favorite;
  static const IconData candle = Icons.wb_sunny_outlined;
  static const IconData photo = Icons.photo_camera_outlined;
  static const IconData album = Icons.photo_library_outlined;
  
  // 导航图标
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData create = Icons.add_circle_outline;
  static const IconData profile = Icons.person_outline;
  static const IconData profileFilled = Icons.person;
  
  // 交互图标
  static const IconData like = Icons.thumb_up_outlined;
  static const IconData likeFilled = Icons.thumb_up;
  static const IconData comment = Icons.chat_bubble_outline;
  static const IconData share = Icons.share_outlined;
  static const IconData view = Icons.visibility_outlined;
  
  // 功能图标
  static const IconData search = Icons.search;
  static const IconData filter = Icons.tune;
  static const IconData sort = Icons.sort;
  static const IconData more = Icons.more_horiz;
  static const IconData settings = Icons.settings_outlined;
  
  // 状态图标
  static const IconData success = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData info = Icons.info_outline;
}

/// 玻璃风格图标组件
class GlassIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final bool isActive;
  final VoidCallback? onTap;
  final String? tooltip;

  const GlassIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.isActive = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? 
        (isActive 
            ? GlassmorphismColors.primary 
            : GlassmorphismColors.textSecondary);
    
    Widget iconWidget = Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive ? BoxDecoration(
        gradient: GlassmorphismColors.glassGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder,
          width: 1,
        ),
      ) : null,
      child: Icon(
        icon,
        size: size,
        color: iconColor,
      ),
    );
    
    if (onTap != null) {
      iconWidget = GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }
    
    if (tooltip != null) {
      iconWidget = Tooltip(
        message: tooltip!,
        child: iconWidget,
      );
    }
    
    return iconWidget;
  }
}

/// 玻璃风格悬浮按钮
class GlassFloatingActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GlassFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<GlassFloatingActionButton> createState() => _GlassFloatingActionButtonState();
}

class _GlassFloatingActionButtonState extends State<GlassFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: _isPressed 
                  ? GlassmorphismDecorations.glassCardHover
                  : GlassmorphismDecorations.glassCard,
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 24,
                  color: widget.foregroundColor ?? GlassmorphismColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 玻璃风格图标按钮
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;
  final bool isActive;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.tooltip,
    this.isActive = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: widget.isActive || _isPressed
                  ? GlassmorphismDecorations.glassCardHover
                  : GlassmorphismDecorations.glassCard,
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.45,
                  color: widget.isActive 
                      ? GlassmorphismColors.primary 
                      : GlassmorphismColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 统计图标组件
class StatisticIcon extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatisticIcon({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIcon(
          icon: icon,
          size: 20,
          color: color ?? GlassmorphismColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: GlassmorphismColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: GlassmorphismColors.textTertiary,
          ),
        ),
      ],
    );
  }
}