import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/glass_icons.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
        child: Stack(
          children: [
            // 主要内容
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: GlassmorphismDecorations.glassCard,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        GlassIcons.security,
                                        color: GlassmorphismColors.primary,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '永念隐私政策',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: GlassmorphismColors.textOnGlass,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  _buildSection(
                                    context,
                                    '引言',
                                    '永念团队深知个人信息的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '1. 我们收集的信息',
                                    '为了向您提供更好的服务，我们可能会收集以下信息：\\n\\n'
                                    '• 账户信息：邮箱地址、用户名\\n'
                                    '• 纪念内容：您上传的照片、文字、视频等\\n'
                                    '• 设备信息：设备型号、操作系统版本\\n'
                                    '• 使用信息：应用使用情况、错误日志',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '2. 信息使用目的',
                                    '我们收集的信息将用于：\\n\\n'
                                    '• 提供纪念服务，包括内容存储和展示\\n'
                                    '• 改善用户体验和服务质量\\n'
                                    '• 保障系统安全，防止恶意使用\\n'
                                    '• 遵守法律法规要求',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '3. 信息共享',
                                    '我们承诺不会向第三方出售、出租或交易您的个人信息。但在以下情况下，我们可能需要共享您的信息：\\n\\n'
                                    '• 获得您的明确同意\\n'
                                    '• 法律法规要求或政府部门要求\\n'
                                    '• 为保护永念或其他用户的权利、财产或安全\\n'
                                    '• 与可信的合作伙伴共享，但仅限于提供服务所必需',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '4. 信息安全',
                                    '我们采取以下措施保护您的信息安全：\\n\\n'
                                    '• 使用加密技术保护数据传输\\n'
                                    '• 定期更新安全措施和系统\\n'
                                    '• 限制员工对个人信息的访问\\n'
                                    '• 建立安全事件应急预案',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '5. 您的权利',
                                    '您对自己的个人信息享有以下权利：\\n\\n'
                                    '• 查询权：了解我们处理您个人信息的情况\\n'
                                    '• 更正权：要求我们更正错误的个人信息\\n'
                                    '• 删除权：要求我们删除您的个人信息\\n'
                                    '• 账户注销：可以注销您的账户',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '6. 未成年人保护',
                                    '我们非常重视对未成年人的保护。如果您是未成年人，建议您请父母或法定监护人仔细阅读本隐私政策，并在征得同意后使用我们的服务。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '7. 政策更新',
                                    '我们可能适时更新本隐私政策。当政策发生变更时，我们会在应用内通知您，并征求您的同意。',
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  Container(
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
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              GlassIcons.email,
                                              color: GlassmorphismColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '联系我们',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: GlassmorphismColors.textOnGlass,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '如果您对本隐私政策有任何疑问、意见或建议，请通过应用内意见反馈功能联系我们。',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: GlassmorphismColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '最后更新：2024年1月',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: GlassmorphismColors.textSecondary.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 返回按钮
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
              GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.glassBorder,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: GlassmorphismColors.textOnGlass,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: GlassmorphismColors.textOnGlass,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: GlassmorphismColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}