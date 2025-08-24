import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart' show GlassInteractiveButton;

/// 帮助中心页面
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
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
                    _buildSearchSection(),
                    _buildQuickActionsSection(),
                    _buildHelpCategoriesSection(),
                    _buildContactSection(),
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
        '帮助中心',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '有什么可以帮助您的？',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '搜索常见问题...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: GlassmorphismColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: GlassmorphismColors.textSecondary,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: GlassmorphismColors.glassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: GlassmorphismColors.glassBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: GlassmorphismColors.glassBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: GlassmorphismColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '快速操作',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: GlassIcons.create,
                      title: '创建纪念',
                      subtitle: '新手指引',
                      color: GlassmorphismColors.primary,
                      onTap: () => _showHelpContent('创建纪念指引'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.share,
                      title: '分享纪念',
                      subtitle: '分享教程',
                      color: GlassmorphismColors.secondary,
                      onTap: () => _showHelpContent('分享纪念教程'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '隐私保护',
                      subtitle: '设置说明',
                      color: GlassmorphismColors.warmAccent,
                      onTap: () => _showHelpContent('隐私保护设置'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.support_agent,
                      title: '联系客服',
                      subtitle: '在线咨询',
                      color: GlassmorphismColors.info,
                      onTap: () => _contactSupport(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: GlassmorphismColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCategoriesSection() {
    final categories = _getFilteredCategories();
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '常见问题',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map((category) => _buildHelpCategoryItem(category)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCategoryItem(HelpCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showHelpContent(category.title);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.glassGradient,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                category.icon,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      category.subtitle,
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
      ),
    );
  }

  Widget _buildContactSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.contact_support,
                    color: GlassmorphismColors.warmAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '联系我们',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildContactItem(
                icon: Icons.email_outlined,
                title: '邮箱支持',
                subtitle: 'support@eteria.com',
                onTap: () => _contactSupport(),
              ),
              const SizedBox(height: 8),
              _buildContactItem(
                icon: Icons.phone_outlined,
                title: '电话咨询',
                subtitle: '400-888-0000',
                onTap: () => _contactSupport(),
              ),
              const SizedBox(height: 8),
              _buildContactItem(
                icon: Icons.schedule,
                title: '工作时间',
                subtitle: '周一至周五 9:00-18:00',
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap != null ? GlassmorphismColors.glassSurface.withValues(alpha: 0.5) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: GlassmorphismColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
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
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
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

  List<HelpCategory> _getFilteredCategories() {
    final allCategories = [
      HelpCategory(
        icon: GlassIcons.create,
        title: '如何创建纪念？',
        subtitle: '创建纪念的详细步骤',
        keywords: ['创建', '纪念', '新建'],
      ),
      HelpCategory(
        icon: Icons.photo_library_outlined,
        title: '如何上传照片？',
        subtitle: '添加照片和管理相册',
        keywords: ['照片', '上传', '相册'],
      ),
      HelpCategory(
        icon: Icons.share,
        title: '如何分享纪念？',
        subtitle: '与家人朋友分享纪念内容',
        keywords: ['分享', '邀请', '链接'],
      ),
      HelpCategory(
        icon: Icons.privacy_tip_outlined,
        title: '隐私设置说明',
        subtitle: '保护您的隐私和数据安全',
        keywords: ['隐私', '安全', '设置'],
      ),
      HelpCategory(
        icon: GlassIcons.flower,
        title: '献花和留言功能',
        subtitle: '如何进行互动和表达思念',
        keywords: ['献花', '留言', '互动'],
      ),
      HelpCategory(
        icon: Icons.account_circle_outlined,
        title: '账户管理',
        subtitle: '修改个人信息和账户设置',
        keywords: ['账户', '个人信息', '设置'],
      ),
    ];

    if (_searchQuery.isEmpty) {
      return allCategories;
    }

    return allCategories.where((category) {
      final query = _searchQuery.toLowerCase();
      return category.title.toLowerCase().contains(query) ||
             category.subtitle.toLowerCase().contains(query) ||
             category.keywords.any((keyword) => keyword.toLowerCase().contains(query));
    }).toList();
  }

  void _showHelpContent(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: GlassmorphismColors.glassGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: GlassmorphismColors.glassSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: GlassmorphismColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: GlassHoverCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHelpContentForTitle(title),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '还有其他问题？',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassInteractiveButton(
                        text: '联系客服',
                        icon: Icons.support_agent,
                        onPressed: () {
                          Navigator.pop(context);
                          _contactSupport();
                        },
                        width: double.infinity,
                        height: 44,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHelpContentForTitle(String title) {
    switch (title) {
      case '如何创建纪念？':
      case '创建纪念指引':
        return '''创建纪念的步骤：

1. 点击首页右下角的"+"按钮
2. 填写逝者的基本信息：
   • 姓名（必填）
   • 与您的关系
   • 生卒日期
   • 简短介绍
3. 上传纪念照片（可选）
4. 选择纪念类型和隐私设置
5. 点击"创建纪念"完成

提示：
• 所有信息都可以后续修改
• 建议上传清晰的照片以获得更好的纪念效果
• 可以设置为私密纪念，仅自己可见''';

      case '分享纪念教程':
        return '''分享纪念的方法：

1. 进入纪念详情页面
2. 点击右上角的分享按钮
3. 选择分享方式：
   • 生成分享链接
   • 生成纪念二维码
   • 直接分享到社交平台

隐私提醒：
• 只有公开的纪念才能被分享
• 可以在隐私设置中控制谁能查看
• 分享的纪念支持留言和献花功能''';

      case '隐私保护设置':
        return '''隐私设置说明：

个人资料隐私：
• 控制其他用户是否能查看您的基本信息
• 设置在线状态显示

纪念内容隐私：
• 设置纪念为公开或私密
• 私密纪念只有您能查看和管理

互动权限：
• 控制是否允许他人留言
• 控制是否允许他人献花

数据隐私：
• 控制数据收集和使用
• 可以随时导出或删除您的数据''';

      default:
        return '''感谢您使用永念应用。

我们致力于为用户提供温馨、安全的纪念空间。如果您在使用过程中遇到任何问题，请随时联系我们的客服团队。

我们会持续改进应用功能，为您提供更好的服务体验。''';
    }
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassmorphismColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '联系客服',
          style: TextStyle(color: GlassmorphismColors.textPrimary),
        ),
        content: Text(
          '您可以通过以下方式联系我们：\n\n'
          '📧 邮箱：support@eteria.com\n'
          '📞 电话：400-888-0000\n'
          '🕒 工作时间：周一至周五 9:00-18:00\n\n'
          '我们会尽快回复您的咨询。',
          style: TextStyle(color: GlassmorphismColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '知道了',
              style: TextStyle(color: GlassmorphismColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCategory {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> keywords;

  HelpCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.keywords,
  });
}