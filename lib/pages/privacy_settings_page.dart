import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profilePublic = true;
  bool _memorialsPublic = true;
  bool _allowComments = true;
  bool _allowFlowers = true;
  bool _showOnlineStatus = false;
  bool _dataAnalytics = true;
  bool _locationTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私设置'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfilePrivacySection(),
              const SizedBox(height: 20),
              _buildMemorialPrivacySection(),
              const SizedBox(height: 20),
              _buildInteractionPrivacySection(),
              const SizedBox(height: 20),
              _buildDataPrivacySection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '个人资料隐私',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
    );
  }

  Widget _buildMemorialPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '纪念内容隐私',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '关闭后，只有您邀请的用户才能查看纪念内容',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '互动权限',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
    );
  }

  Widget _buildDataPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数据隐私',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
            onTap: () => _showComingSoon('数据导出'),
          ),
          
          const SizedBox(height: 8),
          _buildActionTile(
            title: '删除账户',
            subtitle: '永久删除您的账户和所有数据',
            icon: Icons.delete_forever,
            textColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? AppColors.textSecondary,
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
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          '保存设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: 实现保存隐私设置的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('隐私设置保存成功'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: const Text(
          '此操作不可恢复！删除账户后，您的所有数据将被永久删除，包括：\n\n'
          '• 个人资料和设置\n'
          '• 创建的所有纪念\n'
          '• 上传的照片和视频\n'
          '• 留言和互动记录\n\n'
          '确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon('删除账户');
            },
            child: Text(
              '确定删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能开发中'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}