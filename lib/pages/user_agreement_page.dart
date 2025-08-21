import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/glass_icons.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({super.key});

  @override
  State<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage>
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
                                          '永念用户服务协议',
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
                                    '1. 服务条款的接受',
                                    '欢迎使用永念应用。当您使用永念服务时，即表示您已阅读、理解并同意接受本协议的所有条款和条件。如果您不同意本协议的任何条款，请不要使用本服务。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '2. 服务描述',
                                    '永念是一款纪念应用，旨在帮助用户创建和分享对逝者的纪念。我们提供照片上传、文字纪念、留言互动等功能，让用户能够永久保存和分享珍贵的回忆。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '3. 用户责任',
                                    '• 您必须年满18周岁或在法定监护人同意下使用本服务\\n'
                                    '• 您承诺提供真实、准确的个人信息\\n'
                                    '• 您不得上传违法、有害、威胁、虐待、诽谤、粗俗或其他不当内容\\n'
                                    '• 您不得侵犯他人的知识产权、隐私权或其他权利\\n'
                                    '• 您不得恶意使用本服务或干扰服务的正常运行',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '4. 内容所有权',
                                    '您上传的所有内容（包括但不限于照片、文字、视频）的知识产权归您所有。通过使用本服务，您授予永念有限的、非独家的、可转让的权利来存储、显示和分发您的内容，仅限于提供服务所必需的范围。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '5. 隐私保护',
                                    '我们重视您的隐私，会采取合理的安全措施保护您的个人信息。具体的隐私处理方式请参阅我们的隐私政策。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '6. 服务变更与终止',
                                    '我们保留随时修改、暂停或终止服务的权利。对于服务的重大变更，我们会提前通知用户。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '7. 免责声明',
                                    '本服务按"现状"提供，我们不保证服务不会中断或无错误。在法律允许的最大范围内，我们不承担因使用本服务而产生的任何直接或间接损失。',
                                  ),
                                  
                                  _buildSection(
                                    context,
                                    '8. 法律适用',
                                    '本协议受中华人民共和国法律管辖。如发生争议，双方应友好协商解决，协商不成的，提交有管辖权的人民法院解决。',
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
                                          '如有任何问题，请通过应用内意见反馈功能联系我们。',
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