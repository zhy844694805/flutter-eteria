import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart';

/// 关于页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  PackageInfo? _packageInfo;

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
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = packageInfo;
        });
      }
    } catch (e) {
      // 如果获取失败，使用默认值
      if (mounted) {
        setState(() {
          _packageInfo = PackageInfo(
            appName: 'Eteria',
            packageName: 'com.eteria.app',
            version: '1.0.0',
            buildNumber: '1',
          );
        });
      }
    }
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
                    _buildAppInfo(),
                    _buildFeatures(),
                    _buildSupport(),
                    _buildLegal(),
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                    ),
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
        '关于应用',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // 应用图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary,
                      GlassmorphismColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  GlassIcons.memorial,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 应用名称
              Text(
                _packageInfo?.appName ?? 'Eteria',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 版本信息
              Text(
                '版本 ${_packageInfo?.version ?? '1.0.0'} (${_packageInfo?.buildNumber ?? '1'})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 应用描述
              Text(
                '永念 - 数字纪念空间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '为至亲挚爱创建温馨的数字纪念空间，让美好的回忆永远传承。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '主要功能',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildFeatureItem(
                icon: Icons.memory,
                title: '数字纪念',
                description: '为逝者创建个性化的纪念空间',
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.photo_library_outlined,
                title: '珍贵回忆',
                description: '保存和分享美好的照片与故事',
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.favorite_outline,
                title: '表达敬意',
                description: '献花瞻仰，表达永恒的思念',
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.share_outlined,
                title: '分享传承',
                description: '与家人朋友分享珍贵的记忆',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupport() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.support_outlined,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '帮助与支持',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildSupportItem(
                icon: Icons.help_outline,
                title: '使用帮助',
                onTap: _showHelp,
              ),
              
              const SizedBox(height: 16),
              
              _buildSupportItem(
                icon: Icons.feedback_outlined,
                title: '意见反馈',
                onTap: _showFeedback,
              ),
              
              const SizedBox(height: 16),
              
              _buildSupportItem(
                icon: Icons.email_outlined,
                title: '联系我们',
                onTap: _contactUs,
              ),
              
              const SizedBox(height: 16),
              
              _buildSupportItem(
                icon: Icons.update,
                title: '检查更新',
                onTap: _checkUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegal() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '法律条款',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildSupportItem(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: _showUserAgreement,
              ),
              
              const SizedBox(height: 16),
              
              _buildSupportItem(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: _showPrivacyPolicy,
              ),
              
              const SizedBox(height: 16),
              
              _buildSupportItem(
                icon: Icons.info_outline,
                title: '第三方许可',
                onTap: _showThirdPartyLicenses,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassmorphismColors.primary.withValues(alpha: 0.2),
                GlassmorphismColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: GlassmorphismColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              icon,
              color: GlassmorphismColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
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

  void _showHelp() {
    HapticFeedback.lightImpact();
    _showHelpDialog();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '使用帮助',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: GlassmorphismColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 帮助内容
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHelpSection(
                          '如何创建纪念空间？',
                          '1. 点击主页的"+"按钮\n2. 填写逝者的基本信息\n3. 上传照片和回忆\n4. 选择公开或私密\n5. 点击创建完成',
                        ),
                        _buildHelpSection(
                          '如何管理照片？',
                          '• 在纪念空间详情页点击照片\n• 可以添加、删除或重新排序\n• 支持多种格式：JPG、PNG等\n• 照片会自动压缩优化',
                        ),
                        _buildHelpSection(
                          '如何分享纪念空间？',
                          '• 点击纪念空间的分享按钮\n• 可以通过微信、QQ等分享\n• 也可以复制链接发送给他人\n• 私密空间仅创建者可见',
                        ),
                        _buildHelpSection(
                          '如何保护隐私？',
                          '• 设置纪念空间为私密\n• 定期修改账号密码\n• 谨慎分享个人信息\n• 及时更新隐私设置',
                        ),
                        _buildHelpSection(
                          '遇到问题怎么办？',
                          '• 查看常见问题解答\n• 通过"意见反馈"联系我们\n• 发送邮件到support@eteria.com\n• 关注我们的官方公众号',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '我知道了',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    HapticFeedback.lightImpact();
    _showFeedbackDialog();
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    final contactController = TextEditingController();
    String feedbackType = '功能建议';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: GlassmorphismColors.backgroundGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GlassmorphismColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          color: GlassmorphismColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '意见反馈',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: GlassmorphismColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: GlassmorphismColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 反馈类型
                    Text(
                      '反馈类型',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: feedbackType,
                          isExpanded: true,
                          dropdownColor: GlassmorphismColors.backgroundPrimary,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlassmorphismColors.textPrimary,
                          ),
                          items: ['功能建议', '问题反馈', '界面优化', '其他']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                feedbackType = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 反馈内容
                    Text(
                      '反馈内容',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '请详细描述您的意见或建议...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlassmorphismColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 联系方式
                    Text(
                      '联系方式（可选）',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: contactController,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '邮箱或手机号',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlassmorphismColors.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.contact_mail_outlined,
                            color: GlassmorphismColors.primary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 按钮
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: GlassmorphismColors.glassGradient,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: GlassmorphismColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '取消',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: GlassmorphismColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: isSubmitting ? null : () async {
                              await _submitFeedback(
                                context,
                                feedbackType,
                                feedbackController.text,
                                contactController.text,
                                (bool value) {
                                  setState(() {
                                    isSubmitting = value;
                                  });
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    GlassmorphismColors.primary,
                                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '提交反馈',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitFeedback(
    BuildContext context,
    String type,
    String content,
    String contact,
    Function(bool) setLoadingState,
  ) async {
    if (content.trim().isEmpty) {
      _showMessage('请输入反馈内容', isError: true);
      return;
    }

    setLoadingState(true);

    try {
      // TODO: 调用API提交反馈
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用

      if (context.mounted) {
        Navigator.pop(context);
        _showMessage('反馈提交成功，感谢您的建议！');
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage('提交失败，请稍后重试', isError: true);
      }
    } finally {
      setLoadingState(false);
    }
  }

  void _contactUs() {
    HapticFeedback.lightImpact();
    _showContactDialog();
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '联系我们',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: GlassmorphismColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 联系方式
                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: '客服邮箱',
                  content: 'support@eteria.com',
                  onTap: () => _copyToClipboard('support@eteria.com', '邮箱'),
                ),
                
                const SizedBox(height: 16),
                
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  title: '客服电话',
                  content: '400-123-4567',
                  onTap: () => _copyToClipboard('400-123-4567', '电话'),
                ),
                
                const SizedBox(height: 16),
                
                _buildContactItem(
                  icon: Icons.wechat,
                  title: '微信客服',
                  content: 'Eteria_Support',
                  onTap: () => _copyToClipboard('Eteria_Support', '微信号'),
                ),
                
                const SizedBox(height: 16),
                
                _buildContactItem(
                  icon: Icons.access_time,
                  title: '工作时间',
                  content: '周一至周五 9:00-18:00',
                ),
                
                const SizedBox(height: 24),
                
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '我知道了',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
              GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: GlassmorphismColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                color: GlassmorphismColors.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    _showMessage('${type}已复制到剪贴板');
  }

  void _checkUpdate() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已是最新版本'),
        backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showUserAgreement() {
    HapticFeedback.lightImpact();
    _showUserAgreementDialog();
  }

  void _showUserAgreementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '用户协议',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: GlassmorphismColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 协议内容
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAgreementSection(
                          '1. 服务条款',
                          '欢迎使用永念（Eteria）数字纪念应用。使用本应用即表示您同意遵守以下条款和条件。本协议对您和永念之间具有法律约束力。',
                        ),
                        _buildAgreementSection(
                          '2. 服务内容',
                          '永念为用户提供数字纪念空间创建、管理和分享服务。用户可以：\n• 创建个性化的纪念空间\n• 上传和管理纪念照片、文字\n• 与亲友分享珍贵回忆\n• 表达思念和敬意',
                        ),
                        _buildAgreementSection(
                          '3. 用户责任',
                          '用户承诺：\n• 提供真实、准确的信息\n• 不上传违法、违规内容\n• 尊重他人隐私和权利\n• 妥善保管账号信息\n• 遵守相关法律法规',
                        ),
                        _buildAgreementSection(
                          '4. 隐私保护',
                          '我们承诺保护用户隐私：\n• 严格保护个人信息安全\n• 不会未经授权分享用户数据\n• 采用加密技术保护数据传输\n• 定期更新安全防护措施',
                        ),
                        _buildAgreementSection(
                          '5. 知识产权',
                          '用户上传的内容所有权归用户所有。永念对应用程序、设计、商标等拥有知识产权。未经许可不得复制、传播或用于商业目的。',
                        ),
                        _buildAgreementSection(
                          '6. 免责声明',
                          '永念努力提供稳定、安全的服务，但不保证服务不中断或无错误。对于因不可抗力、网络故障等原因造成的损失，永念不承担责任。',
                        ),
                        _buildAgreementSection(
                          '7. 协议修改',
                          '永念有权根据法律法规变化和业务发展需要修改本协议。修改后的协议将在应用内公布，继续使用即视为同意修改内容。',
                        ),
                        _buildAgreementSection(
                          '8. 联系方式',
                          '如对本协议有疑问，请联系我们：\n邮箱：legal@eteria.com\n地址：中国北京市朝阳区\n\n本协议最后更新时间：2024年1月1日',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '我已阅读并同意',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgreementSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    HapticFeedback.lightImpact();
    _showPrivacyPolicyDialog();
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '隐私政策',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: GlassmorphismColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 隐私政策内容
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAgreementSection(
                          '1. 信息收集',
                          '我们收集的信息类型：\n• 注册信息：邮箱、姓名、手机号\n• 纪念内容：照片、文字、语音等用户上传的内容\n• 使用数据：应用使用情况、错误日志\n• 设备信息：设备型号、操作系统版本、网络信息',
                        ),
                        _buildAgreementSection(
                          '2. 信息使用',
                          '我们使用收集的信息用于：\n• 提供和改进服务\n• 用户身份验证和账号安全\n• 技术支持和客户服务\n• 发送重要通知和更新\n• 分析服务使用情况以优化体验',
                        ),
                        _buildAgreementSection(
                          '3. 信息分享',
                          '我们承诺：\n• 不会出售您的个人信息\n• 不会向第三方分享个人信息，除非：\n  - 获得您的明确同意\n  - 法律法规要求\n  - 保护我们的合法权益\n• 匿名统计数据可能用于分析',
                        ),
                        _buildAgreementSection(
                          '4. 信息安全',
                          '我们采取的安全措施：\n• 数据传输加密（HTTPS/TLS）\n• 服务器安全防护和监控\n• 访问权限控制和审计\n• 定期安全评估和更新\n• 员工隐私培训和保密协议',
                        ),
                        _buildAgreementSection(
                          '5. 用户权利',
                          '您享有以下权利：\n• 查看和更新个人信息\n• 删除账号和相关数据\n• 撤回同意和拒绝处理\n• 数据可携带权\n• 投诉和救济权利',
                        ),
                        _buildAgreementSection(
                          '6. Cookie使用',
                          '我们使用Cookie和类似技术：\n• 记住您的登录状态\n• 保存应用设置和偏好\n• 分析应用使用情况\n• 提供个性化体验\n您可以在设备设置中管理Cookie。',
                        ),
                        _buildAgreementSection(
                          '7. 第三方服务',
                          '应用可能集成第三方服务：\n• 云存储服务（数据备份）\n• 分析服务（使用统计）\n• 推送通知服务\n这些服务有独立的隐私政策，请注意查看。',
                        ),
                        _buildAgreementSection(
                          '8. 政策更新',
                          '我们可能会更新本隐私政策。重大变更将通过应用内通知告知您。继续使用应用即表示接受更新后的政策。\n\n如有疑问，请联系：privacy@eteria.com\n\n最后更新：2024年1月1日',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '我已阅读并理解',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThirdPartyLicenses() {
    HapticFeedback.lightImpact();
    _showLicensesDialog();
  }

  void _showLicensesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '第三方许可',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: GlassmorphismColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 许可列表
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLicenseItem(
                          'Flutter',
                          'Google Inc.',
                          'BSD-3-Clause',
                          '开源UI工具包，用于构建跨平台应用',
                        ),
                        _buildLicenseItem(
                          'Provider',
                          'Remi Rousselet',
                          'MIT',
                          '状态管理库，用于应用状态管理',
                        ),
                        _buildLicenseItem(
                          'HTTP',
                          'Dart Team',
                          'BSD-3-Clause',
                          'HTTP客户端库，用于网络请求',
                        ),
                        _buildLicenseItem(
                          'Image Picker',
                          'Flutter Community',
                          'Apache-2.0',
                          '图片选择库，用于选择相册和相机图片',
                        ),
                        _buildLicenseItem(
                          'Cached Network Image',
                          'Baseflow',
                          'MIT',
                          '网络图片缓存库，用于显示网络图片',
                        ),
                        _buildLicenseItem(
                          'Package Info Plus',
                          'Flutter Community',
                          'BSD-3-Clause',
                          '应用信息获取库，用于获取应用版本信息',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '我知道了',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLicenseItem(
    String name,
    String author,
    String license,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: GlassmorphismColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  license,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: GlassmorphismColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            author,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textTertiary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: (isError 
            ? GlassmorphismColors.error 
            : GlassmorphismColors.success).withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}