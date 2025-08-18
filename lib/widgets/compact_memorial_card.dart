import 'package:flutter/material.dart';
import '../models/memorial.dart';
import '../theme/app_theme.dart';
import 'platform_image.dart';

class CompactMemorialCard extends StatelessWidget {
  final Memorial memorial;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const CompactMemorialCard({
    super.key,
    required this.memorial,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    // 根据描述长度动态计算卡片高度
    final hasLongDescription = memorial.description.length > 80;
    final hasImage = memorial.primaryImage != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域
              if (hasImage) _buildImageSection(),
              
              // 内容区域
              _buildContentSection(hasLongDescription),
              
              // 操作区域
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Hero(
          tag: 'memorial_image_${memorial.id}',
          child: _buildPrimaryImage(),
        ),
      ),
    );
  }

  Widget _buildPrimaryImage() {
    final primaryImage = memorial.primaryImage;
    if (primaryImage == null) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Icon(
          Icons.person,
          size: 40,
          color: AppColors.textSecondary,
        ),
      );
    }

    return PlatformImage(
      imagePath: primaryImage,
      fit: BoxFit.cover,
    );
  }

  Widget _buildContentSection(bool hasLongDescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息栏
          Row(
            children: [
              // 头像（如果没有大图的话）
              if (memorial.primaryImage == null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // 名字和类型
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'memorial_name_${memorial.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Builder(
                                builder: (context) => Text(
                                  memorial.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Builder(
                            builder: (context) => Text(
                              memorial.typeText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (context) => Text(
                        memorial.formattedDates,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 描述文字
          Builder(
            builder: (context) => Text(
              memorial.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              maxLines: hasLongDescription ? 4 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 年龄标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) => Text(
                '享年 ${memorial.ageAtDeath} 岁',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    // 使用真实数据
    final likeCount = memorial.likeCount ?? 0;
    final viewCount = memorial.viewCount ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0x0D8B7D6B), // 非常淡的背景色
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.local_florist_outlined,
            count: likeCount,
            onPressed: onLike,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.visibility_outlined,
            count: viewCount,
            onPressed: null, // 浏览数不需要点击交互
          ),
          const Spacer(),
          Builder(
            builder: (context) => Text(
              _formatCreateTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreateTime() {
    final now = DateTime.now();
    final difference = now.difference(memorial.createdAt);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return '${difference.inDays ~/ 30}个月前';
    }
  }
}