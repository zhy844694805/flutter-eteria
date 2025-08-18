import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import 'login_page.dart';
import 'user_agreement_page.dart';
import 'privacy_policy_page.dart';
import 'profile_page.dart';
import 'privacy_settings_page.dart';
import 'notification_settings_page.dart';
import 'feedback_page.dart';
import 'my_memorials_page.dart';
import 'my_comments_page.dart';
import 'my_favorites_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: Consumer2<AuthProvider, MemorialProvider>(
          builder: (context, authProvider, memorialProvider, child) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, authProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        
                        // 我的纪念部分
                        _buildMemorialSection(context, authProvider),
                        const SizedBox(height: 24),
                        
                        // 互动记录部分
                        _buildInteractionSection(context, authProvider),
                        const SizedBox(height: 24),
                        
                        // 应用设置部分
                        _buildSettingsSection(context, authProvider),
                        const SizedBox(height: 24),
                        
                        // 关于部分
                        _buildAboutSection(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final isLoggedIn = authProvider.isLoggedIn;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // 头像
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Icon(
                        isLoggedIn ? Icons.person : Icons.person_outline,
                        size: 35,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 用户信息
                    Text(
                      isLoggedIn ? user!.name : '未登录',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn 
                          ? user!.email 
                          : '点击登录您的账户',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        '我的',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        if (!isLoggedIn)
          TextButton(
            onPressed: () => _navigateToLogin(context),
            child: const Text(
              '登录',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context, authProvider);
              } else if (value == 'edit_profile') {
                _showComingSoon(context, '编辑资料');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_profile',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('编辑资料'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('退出登录'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }


  Widget _buildMemorialSection(BuildContext context, AuthProvider authProvider) {
    return _buildMenuSection(
      context,
      title: '我的纪念',
      icon: Icons.favorite,
      items: [
        MenuItem(
          icon: Icons.create,
          title: '我创建的纪念',
          subtitle: '查看和管理您创建的纪念',
          onTap: () => _navigateToMyMemorials(context),
        ),
        MenuItem(
          icon: Icons.bookmark,
          title: '我收藏的纪念',
          subtitle: '查看收藏的纪念内容',
          onTap: () => _navigateToMyFavorites(context),
        ),
        MenuItem(
          icon: Icons.chat_bubble,
          title: '我的留言',
          subtitle: '查看我发表的所有留言',
          onTap: () => _navigateToMyComments(context),
        ),
      ],
    );
  }

  Widget _buildInteractionSection(BuildContext context, AuthProvider authProvider) {
    return _buildMenuSection(
      context,
      title: '互动记录',
      icon: Icons.people,
      items: [
        MenuItem(
          icon: Icons.notifications,
          title: '消息通知',
          subtitle: '查看系统消息和互动提醒',
          onTap: () => _showComingSoon(context, '消息通知'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    return _buildMenuSection(
      context,
      title: '应用设置',
      icon: Icons.settings,
      items: [
        MenuItem(
          icon: Icons.person,
          title: '个人信息',
          subtitle: '修改头像、昵称等个人资料',
          onTap: () => _navigateToProfile(context),
        ),
        MenuItem(
          icon: Icons.lock,
          title: '隐私设置',
          subtitle: '管理隐私和数据安全设置',
          onTap: () => _navigateToPrivacySettings(context),
        ),
        MenuItem(
          icon: Icons.notifications_outlined,
          title: '通知设置',
          subtitle: '管理推送通知偏好',
          onTap: () => _navigateToNotificationSettings(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildMenuSection(
      context,
      title: '关于',
      icon: Icons.info,
      items: [
        MenuItem(
          icon: Icons.feedback,
          title: '意见反馈',
          subtitle: '向我们提供宝贵建议',
          onTap: () => _navigateToFeedback(context),
        ),
        MenuItem(
          icon: Icons.policy,
          title: '隐私政策',
          subtitle: '了解我们的隐私保护政策',
          onTap: () => _navigateToPrivacyPolicy(context),
        ),
        MenuItem(
          icon: Icons.gavel,
          title: '用户协议',
          subtitle: '查看服务条款和用户协议',
          onTap: () => _navigateToUserAgreement(context),
        ),
        MenuItem(
          icon: Icons.info,
          title: '关于永念',
          subtitle: '版本信息和开发团队',
          onTap: () => _showAboutApp(context),
        ),
      ],
    );
  }


  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                item.trailing ?? const Icon(
                  Icons.keyboard_arrow_right,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('功能开发中，敬请期待...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _navigateToUserAgreement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserAgreementPage(),
      ),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void _navigateToPrivacySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacySettingsPage(),
      ),
    );
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }

  void _navigateToFeedback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FeedbackPage(),
      ),
    );
  }

  void _navigateToMyMemorials(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyMemorialsPage(),
      ),
    );
  }

  void _navigateToMyFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyFavoritesPage(),
      ),
    );
  }

  void _navigateToMyComments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyCommentsPage(),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已成功退出登录'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(
              '确定',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('关于永念'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '永念 - 让爱永恒传承',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(context, '版本', '1.0.0'),
            const SizedBox(height: 8),
            _buildInfoRow(context, '开发者', '永念团队'),
            const SizedBox(height: 8),
            _buildInfoRow(context, '发布时间', '2024年1月'),
            
            const SizedBox(height: 16),
            Text(
              '应用介绍',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '永念是一个温暖的纪念应用，致力于帮助人们创建和分享对逝者的纪念。我们相信爱是永恒的，记忆是珍贵的，通过数字化的方式让美好的回忆得以永久保存和传承。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            Text(
              '核心功能',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 创建个性化的纪念页面\n'
              '• 上传照片和视频回忆\n'
              '• 撰写纪念文字和生平\n'
              '• 亲友留言和献花互动\n'
              '• 安全的云端存储',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.copyright, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '© 2024 永念团队 版权所有',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });
}