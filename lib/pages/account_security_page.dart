import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;

/// 账号安全页面
class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

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
                    _buildSecurityOptions(),
                    _buildDangerZone(),
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
        '账号安全',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSecurityOptions() {
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
                    Icons.security,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '账号安全设置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 修改密码
              _buildSecurityItem(
                icon: Icons.lock_outline,
                title: '修改密码',
                description: '定期更新密码，保护账号安全',
                onTap: _changePassword,
              ),
              
              const SizedBox(width: 16),
              
              // 邮箱验证
              _buildSecurityItem(
                icon: Icons.email_outlined,
                title: '邮箱验证',
                description: '验证绑定的邮箱地址',
                trailing: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ((user?.isVerified ?? false)
                            ? GlassmorphismColors.success 
                            : GlassmorphismColors.warning)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ((user?.isVerified ?? false)
                              ? GlassmorphismColors.success 
                              : GlassmorphismColors.warning)
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (user?.isVerified ?? false) ? '已验证' : '未验证',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: (user?.isVerified ?? false)
                              ? GlassmorphismColors.success 
                              : GlassmorphismColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
                onTap: _verifyEmail,
              ),
              
              const SizedBox(height: 16),
              
              // 登录历史
              _buildSecurityItem(
                icon: Icons.history,
                title: '登录历史',
                description: '查看最近的登录记录',
                onTap: _viewLoginHistory,
              ),
              
              const SizedBox(height: 16),
              
              // 设备管理
              _buildSecurityItem(
                icon: Icons.devices,
                title: '设备管理',
                description: '管理已登录的设备',
                onTap: _manageDevices,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
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
                    Icons.warning_outlined,
                    color: GlassmorphismColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '危险操作区',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 注销账号
              _buildDangerItem(
                icon: Icons.delete_forever_outlined,
                title: '注销账号',
                description: '永久删除账号及所有数据，此操作不可恢复',
                onTap: _deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String description,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.glassGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
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
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ] else
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

  Widget _buildDangerItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.error.withValues(alpha: 0.05),
              GlassmorphismColors.error.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.error.withValues(alpha: 0.2),
                    GlassmorphismColors.error.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: GlassmorphismColors.error,
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
                      color: GlassmorphismColors.error,
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
            Icon(
              Icons.chevron_right,
              color: GlassmorphismColors.error,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() {
    HapticFeedback.lightImpact();
    _showChangePasswordDialog();
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isChanging = false;
        return StatefulBuilder(
          builder: (context, setState) {
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
                          Icons.lock_outline,
                          color: GlassmorphismColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '修改密码',
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
                    
                    // 当前密码
                    Text(
                      '当前密码',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: currentPasswordController,
                      hintText: '请输入当前密码',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 新密码
                    Text(
                      '新密码',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: newPasswordController,
                      hintText: '请输入新密码（至少6位）',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 确认密码
                    Text(
                      '确认新密码',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      hintText: '请再次输入新密码',
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                            onTap: isChanging ? null : () async {
                              await _handlePasswordChange(
                                context,
                                currentPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text,
                                (bool value) {
                                  setState(() {
                                    isChanging = value;
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
                              child: isChanging
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
                                      '确认修改',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
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
        controller: controller,
        obscureText: true,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: GlassmorphismColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: GlassmorphismColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: GlassmorphismColors.primary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handlePasswordChange(
    BuildContext context,
    String currentPassword,
    String newPassword,
    String confirmPassword,
    Function(bool) setLoadingState,
  ) async {
    // 验证输入
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('请填写所有密码字段', isError: true);
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('新密码至少需要6位字符', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('两次输入的新密码不一致', isError: true);
      return;
    }

    setLoadingState(true);

    try {
      // TODO: 调用API修改密码
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用

      if (context.mounted) {
        Navigator.pop(context);
        _showMessage('密码修改成功');
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage('密码修改失败，请稍后重试', isError: true);
      }
    } finally {
      setLoadingState(false);
    }
  }

  void _verifyEmail() {
    HapticFeedback.lightImpact();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user?.isVerified ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('邮箱已经验证过了'),
          backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('邮箱验证功能开发中'),
          backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _viewLoginHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('登录历史功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _manageDevices() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设备管理功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteAccount() {
    HapticFeedback.mediumImpact();
    showDialog(
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: GlassmorphismColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '确定要注销账号吗？',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '注销后所有个人数据和纪念空间都将被永久删除，此操作无法撤销。',
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
                          onPressed: () => Navigator.pop(context),
                          height: 44,
                          backgroundColor: GlassmorphismColors.glassSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassInteractiveButton(
                          text: '确认注销',
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('账号注销功能开发中'),
                                backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
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