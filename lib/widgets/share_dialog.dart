import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/memorial.dart';
import '../services/share_service.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/glass_icons.dart';

/// 分享对话框组件
class ShareDialog extends StatefulWidget {
  final Memorial memorial;
  
  const ShareDialog({
    super.key,
    required this.memorial,
  });
  
  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: GlassmorphismColors.backgroundGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              GlassIcons.share,
              color: GlassmorphismColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分享纪念',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '让更多人记住 ${widget.memorial.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GlassmorphismColors.glassSurface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: GlassmorphismColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        children: [
          // 纪念信息预览
          _buildMemorialPreview(),
          const SizedBox(height: 24),
          
          // 分享选项
          _buildShareOptions(),
        ],
      ),
    );
  }
  
  Widget _buildMemorialPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassmorphismColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // 头像或图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: GlassmorphismColors.backgroundSecondary,
              child: widget.memorial.primaryImage != null
                  ? Image.network(
                      widget.memorial.primaryImage!,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      GlassIcons.photo,
                      color: GlassmorphismColors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memorial.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.memorial.relationship?.isNotEmpty == true)
                  Text(
                    '我的${widget.memorial.relationship}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                Text(
                  '${widget.memorial.birthDate.year} - ${widget.memorial.deathDate.year}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: GlassmorphismColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShareOption(
              icon: Icons.link,
              title: '复制链接',
              subtitle: '复制到剪贴板',
              onTap: _copyLink,
              color: GlassmorphismColors.info,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildShareOption(
              icon: Icons.qr_code,
              title: '二维码',
              subtitle: '生成二维码',
              onTap: _showQRCode,
              color: GlassmorphismColors.primary,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShareOption(
              icon: Icons.image,
              title: '海报图',
              subtitle: '生成纪念海报',
              onTap: _generatePoster,
              color: GlassmorphismColors.success,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildShareOption(
              icon: GlassIcons.share,
              title: '分享',
              subtitle: '分享给朋友',
              onTap: _shareLink,
              color: GlassmorphismColors.secondary,
            )),
          ],
        ),
      ],
    );
  }
  
  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: GlassmorphismColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // 分享功能方法
  void _copyLink() async {
    final success = await ShareService.copyLinkToClipboard(widget.memorial);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (success) {
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('链接已复制到剪贴板'),
            ],
          ),
          backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('复制失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  
  void _showQRCode() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QRCodeDialog(memorial: widget.memorial),
    );
  }
  
  void _generatePoster() async {
    Navigator.of(context).pop();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // 显示加载提示
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('正在生成海报...'),
          ],
        ),
        backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    
    final success = await ShareService.shareMemorialPoster(widget.memorial, context);
    
    if (!success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('生成海报失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  
  void _shareLink() async {
    Navigator.of(context).pop();
    final success = await ShareService.shareMemorialLink(widget.memorial);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

/// 二维码对话框
class QRCodeDialog extends StatefulWidget {
  final Memorial memorial;
  
  const QRCodeDialog({
    super.key,
    required this.memorial,
  });
  
  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  gradient: GlassmorphismColors.backgroundGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 头部
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: GlassmorphismColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '扫码查看纪念',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: GlassmorphismColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(
                                  Icons.close,
                                  color: GlassmorphismColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 二维码
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: ShareService.generateQRCode(widget.memorial, size: 200),
                        ),
                        
                        // 底部按钮
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: GlassInteractiveButton(
                                  text: '复制链接',
                                  icon: Icons.copy,
                                  onPressed: _saveQRCode,
                                  height: 44,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassInteractiveButton(
                                  text: '分享',
                                  icon: GlassIcons.share,
                                  onPressed: _shareQRCode,
                                  height: 44,
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
          );
        },
      ),
    );
  }
  
  void _saveQRCode() async {
    // 复制二维码链接到剪贴板
    final success = await ShareService.copyLinkToClipboard(widget.memorial);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (success) {
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('二维码链接已复制到剪贴板'),
            ],
          ),
          backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('复制失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  
  void _shareQRCode() async {
    Navigator.of(context).pop();
    final success = await ShareService.shareQRCode(widget.memorial, context);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}