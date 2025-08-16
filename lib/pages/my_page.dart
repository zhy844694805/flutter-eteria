import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 用户资料
              _buildUserProfile(context, authProvider),
          
          const SizedBox(height: 24),
          
          // 我的纪念部分
          _buildMenuSection(
            context,
            title: '我的纪念',
            items: [
              MenuItem(
                icon: Icons.create,
                title: '我的纪念',
                onTap: () => _showComingSoon(context, '我的纪念'),
              ),
              MenuItem(
                icon: Icons.favorite,
                title: '收藏',
                onTap: () => _showComingSoon(context, '收藏'),
              ),
              MenuItem(
                icon: Icons.chat_bubble,
                title: '留言',
                onTap: () => _showComingSoon(context, '留言'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 设置部分
          _buildMenuSection(
            context,
            title: '设置',
            items: [
              MenuItem(
                icon: Icons.person,
                title: '个人信息',
                onTap: () => _showComingSoon(context, '个人信息'),
              ),
              MenuItem(
                icon: Icons.lock,
                title: '隐私设置',
                onTap: () => _showComingSoon(context, '隐私设置'),
              ),
              MenuItem(
                icon: Icons.notifications,
                title: '通知设置',
                onTap: () => _showComingSoon(context, '通知设置'),
              ),
              MenuItem(
                icon: Icons.help,
                title: '帮助',
                onTap: () => _showComingSoon(context, '帮助'),
              ),
            ],
          ),
        ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final isLoggedIn = authProvider.isLoggedIn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          // 头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLoggedIn ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              isLoggedIn ? Icons.person : Icons.person_outline,
              size: 32,
              color: isLoggedIn ? Colors.white : AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? user!.name : '未登录',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn 
                      ? user!.email 
                      : '点击登录您的账户',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // 登录/登出按钮
          if (!isLoggedIn)
            TextButton(
              onPressed: () => _navigateToLogin(context),
              child: Text(
                '登录',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout(context, authProvider);
                }
              },
              itemBuilder: (context) => [
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
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
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
              letterSpacing: 0.3,
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
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(15),
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
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Icon(
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
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}