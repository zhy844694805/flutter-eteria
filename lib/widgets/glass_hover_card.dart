import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';

/// 玻璃拟态悬浮卡片组件
class GlassHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool enabled;

  const GlassHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.enabled = true,
  });

  @override
  State<GlassHoverCard> createState() => _GlassHoverCardState();
}

class _GlassHoverCardState extends State<GlassHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enabled) return;
    
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Transform.translate(
              offset: Offset(0, -2 * _animation.value),
              child: Container(
                decoration: _buildDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
                          GlassmorphismColors.glassSurface.withValues(alpha: 0.5),
                          GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
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
    final baseDecoration = GlassmorphismDecorations.glassCard;
    
    if (_isPressed) {
      return baseDecoration.copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x60FFFFFF),
            Color(0x40FFFFFF),
            Color(0x30FFFFFF),
          ],
        ),
      );
    }
    
    if (_isHovered || _animation.value > 0) {
      return GlassmorphismDecorations.glassCardHover.copyWith(
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.shadowMedium,
            blurRadius: 20 + (_animation.value * 15),
            offset: Offset(0, 8 + (_animation.value * 6)),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: GlassmorphismColors.shadowLight,
            blurRadius: 40 + (_animation.value * 15),
            offset: Offset(0, 4 + (_animation.value * 3)),
            spreadRadius: -8,
          ),
        ],
      );
    }
    
    return baseDecoration;
  }
}