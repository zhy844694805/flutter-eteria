import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/glass_icons.dart';

/// 纪念空间操作面板
class MemorialActionSheet extends StatelessWidget {
  final Memorial memorial;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onToggleVisibility;

  const MemorialActionSheet({
    super.key,
    required this.memorial,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onToggleVisibility,
  });

  static Future<void> show(
    BuildContext context, {
    required Memorial memorial,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onShare,
    VoidCallback? onToggleVisibility,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MemorialActionSheet(
        memorial: memorial,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
        onToggleVisibility: onToggleVisibility,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GlassmorphismColors.backgroundGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
                GlassmorphismColors.glassSurface.withValues(alpha: 0.7),
              ],
            ),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题区域
                Container(
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
                          GlassIcons.memorial,
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
                              memorial.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: GlassmorphismColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (memorial.relationship?.isNotEmpty == true)
                              Text(
                                memorial.relationship!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: GlassmorphismColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 操作按钮
                _buildActionButton(
                  context,
                  icon: GlassIcons.edit,
                  title: '编辑纪念',
                  description: '修改纪念信息和照片',
                  color: GlassmorphismColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    onEdit?.call();
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildActionButton(
                  context,
                  icon: memorial.isPublic ? Icons.visibility_off : Icons.visibility,
                  title: memorial.isPublic ? '设为私密' : '设为公开',
                  description: memorial.isPublic ? '仅自己可见' : '所有人可见',
                  color: GlassmorphismColors.warning,
                  onTap: () {
                    Navigator.pop(context);
                    onToggleVisibility?.call();
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildActionButton(
                  context,
                  icon: Icons.share,
                  title: '分享纪念',
                  description: '与家人朋友分享美好回忆',
                  color: GlassmorphismColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    onShare?.call();
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildActionButton(
                  context,
                  icon: Icons.delete_outline,
                  title: '删除纪念',
                  description: '永久删除此纪念空间',
                  color: GlassmorphismColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 取消按钮
                GlassInteractiveButton(
                  text: '取消',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: GlassmorphismColors.glassSurface,
                  height: 44,
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
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

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog<bool>(
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
                    '确定要删除吗？',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '删除后将无法恢复，所有相关的回忆都将永久消失。',
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
                          onPressed: () => Navigator.pop(context, false),
                          height: 44,
                          backgroundColor: GlassmorphismColors.glassSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassInteractiveButton(
                          text: '删除',
                          onPressed: () {
                            Navigator.pop(context, true);
                            onDelete?.call();
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
}
