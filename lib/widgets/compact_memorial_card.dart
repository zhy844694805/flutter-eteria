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
      margin: const EdgeInsets.only(bottom: 8), // 减少卡片间距
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8), // 减少水平和底部内边距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息栏
          Row(
            children: [
              // 头像（如果没有大图的话）
              if (memorial.primaryImage == null) ...[
                Container(
                  width: 36, // 减小头像尺寸
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10), // 减少间距
              ],
              
              // 名字和类型
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Hero(
                            tag: 'memorial_name_${memorial.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Builder(
                                builder: (context) => Text(
                                  memorial.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2, // 减少字符间距
                                    fontSize: 15, // 稍微减小字体
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4), // 减少间距
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // 进一步减小内边距
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6), // 减小圆角
                            ),
                            child: Builder(
                              builder: (context) => Text(
                                memorial.typeText,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 8, // 进一步减小字体
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1), // 减少间距
                    Builder(
                      builder: (context) => Text(
                        memorial.formattedDates,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10, // 减小字体
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8), // 减少间距
          
          // 描述文字
          Builder(
            builder: (context) => Text(
              memorial.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.3, // 减少行高
                color: AppColors.textPrimary,
                fontSize: 12, // 减小字体
              ),
              maxLines: hasLongDescription ? 3 : 2, // 减少最大行数
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 6), // 减少间距
          
          // 年龄标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // 减少内边距
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6), // 更淡的背景
              borderRadius: BorderRadius.circular(10), // 减小圆角
            ),
            child: Builder(
              builder: (context) => Text(
                '享年 ${memorial.ageAtDeath} 岁',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10, // 减小字体
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
      margin: const EdgeInsets.only(top: 4), // 大幅减少顶部间距
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 减少垂直内边距
      decoration: const BoxDecoration(
        color: Color(0x08000000), // 更淡的背景色
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.local_florist_outlined,
            count: likeCount,
            onPressed: onLike,
          ),
          const SizedBox(width: 12), // 减少间距
          _buildActionButton(
            icon: Icons.visibility_outlined,
            count: viewCount,
            onPressed: null,
          ),
          const Spacer(),
          Builder(
            builder: (context) => Text(
              _formatCreateTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9, // 进一步减小字体
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1), // 减少内边距
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12, // 减小图标尺寸
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 2), // 减少间距
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 10, // 减小字体
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