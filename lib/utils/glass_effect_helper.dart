import 'package:flutter/material.dart';
import '../theme/glassmorphism_theme.dart';

/// 毛玻璃效果辅助工具 - 避免BackdropFilter在iOS上的黑色阴影问题
class GlassEffectHelper {
  /// 创建稳定的毛玻璃容器（不使用BackdropFilter）
  static Widget createGlassContainer({
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double opacity = 0.8,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.9),
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.6),
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.4),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: GlassmorphismColors.shadowMedium,
            blurRadius: 40,
            offset: const Offset(0, 4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: padding != null 
        ? Padding(padding: padding, child: child)
        : child,
    );
  }

  /// 创建交互式毛玻璃容器（悬浮效果）
  static Widget createInteractiveGlassContainer({
    required Widget child,
    VoidCallback? onTap,
    double borderRadius = 16,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double opacity = 0.8,
    bool isPressed = false,
    bool isHovered = false,
  }) {
    final hoverOpacity = isHovered ? opacity * 1.2 : opacity;
    final pressedScale = isPressed ? 0.98 : 1.0;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: pressedScale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GlassmorphismColors.glassSurface.withValues(alpha: hoverOpacity * 0.9),
                GlassmorphismColors.glassSurface.withValues(alpha: hoverOpacity * 0.6),
                GlassmorphismColors.glassSurface.withValues(alpha: hoverOpacity * 0.4),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: GlassmorphismColors.glassBorder.withValues(
                alpha: isHovered ? 0.8 : 0.6
              ),
              width: isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: GlassmorphismColors.shadowLight,
                blurRadius: isHovered ? 25 : 20,
                offset: Offset(0, isHovered ? 12 : 8),
                spreadRadius: isHovered ? -2 : -4,
              ),
              BoxShadow(
                color: GlassmorphismColors.shadowMedium,
                blurRadius: isHovered ? 50 : 40,
                offset: Offset(0, isHovered ? 8 : 4),
                spreadRadius: isHovered ? -4 : -8,
              ),
            ],
          ),
          child: padding != null 
            ? Padding(padding: padding, child: child)
            : child,
        ),
      ),
    );
  }

  /// 创建圆形毛玻璃容器（用于头像等）
  static Widget createCircularGlassContainer({
    required Widget child,
    required double size,
    EdgeInsetsGeometry? margin,
    double opacity = 0.8,
  }) {
    return Container(
      margin: margin,
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.9),
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.6),
            GlassmorphismColors.glassSurface.withValues(alpha: opacity * 0.4),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }
}