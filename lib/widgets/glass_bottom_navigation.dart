import 'package:flutter/material.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_icons.dart';

/// 玻璃拟态底部导航栏
class GlassBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GlassBottomNavigation> createState() => _GlassBottomNavigationState();
}

class _GlassBottomNavigationState extends State<GlassBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<NavItem> _navItems = [
    NavItem(
      icon: GlassIcons.home,
      activeIcon: GlassIcons.homeFilled,
      label: '首页',
    ),
    NavItem(
      icon: GlassIcons.create,
      activeIcon: GlassIcons.create,
      label: '创建',
    ),
    NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: '数字生命',
    ),
    NavItem(
      icon: GlassIcons.profile,
      activeIcon: GlassIcons.profileFilled,
      label: '我的',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) =>
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    ).toList();
    
    // 初始化当前选中项的动画
    _controllers[widget.currentIndex].forward();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(GlassBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // 重置所有动画
      for (int i = 0; i < _controllers.length; i++) {
        if (i == widget.currentIndex) {
          _controllers[i].forward();
        } else {
          _controllers[i].reverse();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: GlassmorphismColors.glassBorder,
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassmorphismColors.glassSurface.withValues(alpha: 0.95),
                GlassmorphismColors.glassSurface.withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              top: 8,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isActive 
                  ? LinearGradient(
                      colors: [
                        GlassmorphismColors.primary.withValues(alpha: 0.1),
                        GlassmorphismColors.primary.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isActive
                  ? Border.all(
                      color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Transform.scale(
                  scale: 1.0 + (_animations[index].value * 0.1),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 24,
                    color: isActive 
                        ? GlassmorphismColors.primary
                        : GlassmorphismColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 标签
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? GlassmorphismColors.primary
                        : GlassmorphismColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 导航项数据类
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}