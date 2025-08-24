import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart' show GlassInteractiveButton;

/// 玻璃拟态隐私设置页面
class GlassPrivacySettingsPage extends StatefulWidget {
  const GlassPrivacySettingsPage({super.key});

  @override
  State<GlassPrivacySettingsPage> createState() => _GlassPrivacySettingsPageState();
}

class _GlassPrivacySettingsPageState extends State<GlassPrivacySettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  // 隐私设置状态
  bool _profilePublic = true;
  bool _memorialsPublic = true;
  bool _allowComments = true;
  bool _allowFlowers = true;
  bool _showOnlineStatus = false;
  bool _dataAnalytics = true;
  bool _locationTracking = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    
    _pageController.forward();
    _loadSettings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // TODO: 从后端加载用户隐私设置
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
                  slivers: [
                    _buildAppBar(),
                    _buildProfilePrivacySection(),
                    _buildMemorialPrivacySection(),
                    _buildInteractionPrivacySection(),
                    _buildDataPrivacySection(),
                    _buildActionSection(),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.glassGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: GlassmorphismColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        '隐私设置',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfilePrivacySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '个人资料隐私',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: '公开个人资料',
                subtitle: '允许其他用户查看您的基本信息',
                value: _profilePublic,
                onChanged: (value) {
                  setState(() {
                    _profilePublic = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: '显示在线状态',
                subtitle: '让其他用户看到您的在线状态',
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() {
                    _showOnlineStatus = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorialPrivacySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    GlassIcons.memorial,
                    color: GlassmorphismColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '纪念内容隐私',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: '公开纪念内容',
                subtitle: '允许其他用户浏览您创建的纪念',
                value: _memorialsPublic,
                onChanged: (value) {
                  setState(() {
                    _memorialsPublic = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.info.withValues(alpha: 0.1),
                      GlassmorphismColors.info.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GlassmorphismColors.info.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: GlassmorphismColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '关闭后，只有您邀请的用户才能查看纪念内容',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: GlassmorphismColors.textSecondary,
                        ),
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

  Widget _buildInteractionPrivacySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: GlassmorphismColors.warmAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '互动权限',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: '允许留言',
                subtitle: '其他用户可以在您的纪念页面留言',
                value: _allowComments,
                onChanged: (value) {
                  setState(() {
                    _allowComments = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: '允许献花',
                subtitle: '其他用户可以为您的纪念献花',
                value: _allowFlowers,
                onChanged: (value) {
                  setState(() {
                    _allowFlowers = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataPrivacySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: GlassmorphismColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '数据隐私',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: '使用数据分析',
                subtitle: '帮助我们改善应用体验（匿名数据）',
                value: _dataAnalytics,
                onChanged: (value) {
                  setState(() {
                    _dataAnalytics = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: '位置追踪',
                subtitle: '用于推荐附近的纪念场所',
                value: _locationTracking,
                onChanged: (value) {
                  setState(() {
                    _locationTracking = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                title: '数据导出',
                subtitle: '下载您的所有数据',
                icon: Icons.download,
                onTap: () => _exportData(),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                title: '删除账户',
                subtitle: '永久删除您的账户和所有数据',
                icon: Icons.delete_forever,
                textColor: GlassmorphismColors.error,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeThumbColor: GlassmorphismColors.primary,
            activeTrackColor: GlassmorphismColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: GlassmorphismColors.textTertiary,
            inactiveTrackColor: GlassmorphismColors.glassSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? GlassmorphismColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor ?? GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: GlassmorphismColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassInteractiveButton(
          text: '保存设置',
          icon: Icons.save,
          onPressed: _saveSettings,
          width: double.infinity,
          height: 50,
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      // TODO: 实现保存隐私设置到后端的逻辑
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('隐私设置保存成功'),
              ],
            ),
            backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('保存失败，请稍后重试'),
              ],
            ),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassmorphismColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '数据导出',
          style: TextStyle(color: GlassmorphismColors.textPrimary),
        ),
        content: Text(
          '我们将为您准备所有数据的导出文件，包括：\n\n'
          '• 个人资料信息\n'
          '• 创建的纪念内容\n'
          '• 上传的照片和文件\n'
          '• 互动记录\n\n'
          '准备完成后，我们会通过邮箱发送下载链接。',
          style: TextStyle(color: GlassmorphismColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: GlassmorphismColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('数据导出');
            },
            child: Text(
              '确认导出',
              style: TextStyle(color: GlassmorphismColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassmorphismColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: GlassmorphismColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '删除账户',
              style: TextStyle(color: GlassmorphismColors.error),
            ),
          ],
        ),
        content: Text(
          '⚠️ 此操作不可恢复！\n\n'
          '删除账户后，您的所有数据将被永久删除，包括：\n\n'
          '• 个人资料和设置\n'
          '• 创建的所有纪念\n'
          '• 上传的照片和视频\n'
          '• 留言和互动记录\n\n'
          '您确定要继续吗？',
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: GlassmorphismColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('删除账户');
            },
            child: Text(
              '确定删除',
              style: TextStyle(
                color: GlassmorphismColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.construction,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('$feature功能开发中'),
          ],
        ),
        backgroundColor: GlassmorphismColors.warning.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}