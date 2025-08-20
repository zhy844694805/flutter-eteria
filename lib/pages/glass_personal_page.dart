import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/user.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_floating_action_button.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart' hide GlassFloatingActionButton;
import '../widgets/platform_image.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import '../utils/glass_effect_helper.dart';

/// 玻璃拟态个人页面
class GlassPersonalPage extends StatefulWidget {
  const GlassPersonalPage({super.key});

  @override
  State<GlassPersonalPage> createState() => _GlassPersonalPageState();
}

class _GlassPersonalPageState extends State<GlassPersonalPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _cardController;
  
  late Animation<double> _pageAnimation;
  late Animation<double> _cardAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    _scrollController.addListener(_onScroll);
    
    // 启动动画
    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cardController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _showFab = offset > 200;
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
        child: AnimatedBuilder(
          animation: _pageAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * _pageAnimation.value),
              child: Opacity(
                opacity: _pageAnimation.value.clamp(0.0, 1.0),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(),
                    _buildUserProfile(),
                    _buildStatisticsCard(),
                    _buildMenuGrid(),
                    _buildRecentActivity(),
                    _buildSettings(),
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        '个人中心',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GlassEffectHelper.createInteractiveGlassContainer(
          onTap: _showSettingsMenu,
          borderRadius: 12,
          margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.more_vert,
            color: GlassmorphismColors.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return SliverToBoxAdapter(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const SizedBox.shrink();
          }
          
          return Container(
            margin: const EdgeInsets.all(20),
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                  child: Opacity(
                    opacity: _cardAnimation.value.clamp(0.0, 1.0),
                    child: GlassHoverCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // 头像部分
                          Stack(
                            children: [
                              GlassEffectHelper.createCircularGlassContainer(
                                size: 100,
                                opacity: 0.8,
                                child: user.avatar?.isNotEmpty == true
                                    ? PlatformImage(
                                        imagePath: user.avatar!,
                                        fit: BoxFit.cover,
                                        placeholder: _buildDefaultAvatar(user),
                                        errorWidget: _buildDefaultAvatar(user),
                                      )
                                  : _buildDefaultAvatar(user),
                              ),
                              
                              // 编辑按钮
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _editAvatar(),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: GlassmorphismColors.glassGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: GlassmorphismColors.glassBorder,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: GlassmorphismColors.shadowMedium,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: GlassmorphismColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 用户信息
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: GlassmorphismColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: GlassmorphismColors.textSecondary,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 认证状态
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (user.isVerified 
                                  ? GlassmorphismColors.success 
                                  : GlassmorphismColors.warning)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (user.isVerified 
                                    ? GlassmorphismColors.success 
                                    : GlassmorphismColors.warning)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isVerified ? Icons.verified : Icons.warning,
                                  size: 14,
                                  color: user.isVerified 
                                      ? GlassmorphismColors.success 
                                      : GlassmorphismColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.isVerified ? '已认证' : '未认证',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: user.isVerified 
                                        ? GlassmorphismColors.success 
                                        : GlassmorphismColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            GlassmorphismColors.primary.withValues(alpha: 0.2),
            GlassmorphismColors.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '用',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: GlassmorphismColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return SliverToBoxAdapter(
      child: Consumer<MemorialProvider>(
        builder: (context, memorialProvider, child) {
          final memorials = memorialProvider.memorials;
          final totalLikes = memorials.fold(0, (sum, memorial) => sum + (memorial.likeCount ?? 0));
          final totalViews = memorials.fold(0, (sum, memorial) => sum + (memorial.viewCount ?? 0));
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassHoverCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: GlassmorphismColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '我的数据',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          GlassIcons.memorial,
                          '${memorials.length}',
                          '纪念',
                          GlassmorphismColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          GlassIcons.heart,
                          totalLikes.toString(),
                          '获赞',
                          GlassmorphismColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          GlassIcons.view,
                          totalViews.toString(),
                          '浏览',
                          GlassmorphismColors.info,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      MenuItemData(
        icon: GlassIcons.memorial,
        title: '我的纪念',
        description: '管理纪念空间',
        color: GlassmorphismColors.primary,
        onTap: () => _navigateToMyMemorials(),
      ),
      MenuItemData(
        icon: GlassIcons.heart,
        title: '我的点赞',
        description: '查看点赞历史',
        color: GlassmorphismColors.error,
        onTap: () => _navigateToMyLikes(),
      ),
      MenuItemData(
        icon: GlassIcons.photo,
        title: '相册管理',
        description: '整理珍贵照片',
        color: GlassmorphismColors.info,
        onTap: () => _navigateToPhotoManager(),
      ),
      MenuItemData(
        icon: Icons.backup,
        title: '数据备份',
        description: '安全存储数据',
        color: GlassmorphismColors.success,
        onTap: () => _navigateToBackup(),
      ),
      MenuItemData(
        icon: Icons.privacy_tip,
        title: '隐私设置',
        description: '保护个人信息',
        color: GlassmorphismColors.warning,
        onTap: () => _navigateToPrivacy(),
      ),
      MenuItemData(
        icon: Icons.help,
        title: '帮助中心',
        description: '获取使用帮助',
        color: GlassmorphismColors.secondary,
        onTap: () => _navigateToHelp(),
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.apps,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '功能中心',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(menuItems[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item) {
    return GlassHoverCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.color.withValues(alpha: 0.15),
                  item.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            item.description,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '最近活动',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 暂无活动状态
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 48,
                      color: GlassmorphismColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无最近活动',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GlassmorphismColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '开始创建纪念或互动来记录活动',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GlassmorphismColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '设置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildSettingItem(
                Icons.person,
                '个人信息',
                '修改个人资料和头像',
                () => _editProfile(),
              ),
              
              _buildSettingItem(
                Icons.notifications,
                '通知设置',
                '管理推送和提醒',
                () => _navigateToNotifications(),
              ),
              
              _buildSettingItem(
                Icons.security,
                '账户安全',
                '密码和安全设置',
                () => _navigateToSecurity(),
              ),
              
              _buildSettingItem(
                Icons.info,
                '关于应用',
                '版本信息和法律条款',
                () => _navigateToAbout(),
              ),
              
              const SizedBox(height: 12),
              
              // 退出登录按钮
              GlassInteractiveButton(
                text: '退出登录',
                icon: Icons.logout,
                onPressed: _logout,
                backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.1),
                foregroundColor: GlassmorphismColors.error,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: GlassmorphismColors.glassGradient,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: GlassmorphismColors.primary,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GlassmorphismColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: GlassmorphismColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedScale(
      scale: _showFab ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: GlassFloatingActionButton(
        icon: Icons.keyboard_arrow_up,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        },
        tooltip: '返回顶部',
      ),
    );
  }

  // 交互方法
  void _editAvatar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('头像编辑功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editProfile() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('个人信息编辑功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSettingsMenu() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: GlassEffectHelper.createGlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            opacity: 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '更多选项',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuOption(Icons.share, '分享应用'),
                _buildMenuOption(Icons.feedback, '意见反馈'),
                _buildMenuOption(Icons.star_rate, '评价应用'),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title) {
    return GlassHoverCard(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title功能开发中'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: GlassmorphismColors.primary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlassmorphismColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: GlassmorphismColors.textTertiary,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _logout() async {
    HapticFeedback.mediumImpact();
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.backgroundGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GlassEffectHelper.createGlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              opacity: 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout,
                    size: 48,
                    color: GlassmorphismColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '确定要退出登录吗？',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '退出后需要重新登录才能访问',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassInteractiveButton(
                          text: '取消',
                          onPressed: () => Navigator.pop(context, false),
                          height: 44,
                          backgroundColor: GlassmorphismColors.glassSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassInteractiveButton(
                          text: '退出',
                          onPressed: () => Navigator.pop(context, true),
                          height: 44,
                          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.1),
                          foregroundColor: GlassmorphismColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldLogout == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
    }
  }

  // 导航方法
  void _navigateToMyMemorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('我的纪念功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToMyLikes() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('我的点赞功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToPhotoManager() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('相册管理功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('数据备份功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToPrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('隐私设置功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('帮助中心功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('通知设置功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToSecurity() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('账户安全功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToAbout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('关于应用功能开发中'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// 菜单项数据类
class MenuItemData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const MenuItemData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}