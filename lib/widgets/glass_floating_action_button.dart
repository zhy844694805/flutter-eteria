import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';

/// 玻璃拟态浮动操作按钮
class GlassFloatingActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GlassFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 56,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<GlassFloatingActionButton> createState() => _GlassFloatingActionButtonState();
}

class _GlassFloatingActionButtonState extends State<GlassFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  
  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

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
    
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    );
    
    _pressAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _pressAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_pressAnimation.value * 0.05),
          child: Transform.translate(
            offset: Offset(0, -4 * _hoverAnimation.value),
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: _buildDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
                              GlassmorphismColors.glassSurface.withValues(alpha: 0.7),
                            ],
                          ),
                          border: Border.all(
                            color: GlassmorphismColors.glassBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(widget.size / 2),
                        ),
                        child: Center(
                          child: Icon(
                            widget.icon,
                            color: widget.foregroundColor ?? GlassmorphismColors.primary,
                            size: widget.size * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: widget.backgroundColor != null
          ? RadialGradient(
              colors: [
                widget.backgroundColor!.withValues(alpha: 0.3),
                widget.backgroundColor!.withValues(alpha: 0.1),
              ],
            )
          : GlassmorphismColors.glassGradient,
      borderRadius: BorderRadius.circular(widget.size / 2),
      border: Border.all(
        color: GlassmorphismColors.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: GlassmorphismColors.shadowMedium,
          blurRadius: 20 + (_hoverAnimation.value * 15),
          offset: Offset(0, 8 + (_hoverAnimation.value * 6)),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: GlassmorphismColors.shadowLight,
          blurRadius: 40 + (_hoverAnimation.value * 15),
          offset: Offset(0, 4 + (_hoverAnimation.value * 3)),
          spreadRadius: -8,
        ),
      ],
    );
  }
}