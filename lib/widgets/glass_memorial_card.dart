import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_icons.dart';
import 'platform_image.dart';

/// 玻璃拟态纪念卡片 - 带悬浮效果
class GlassMemorialCard extends StatefulWidget {
  final Memorial memorial;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final bool isCompact;
  final bool showMoreButton;

  const GlassMemorialCard({
    super.key,
    required this.memorial,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onMore,
    this.isCompact = true,
    this.showMoreButton = false,
  });

  @override
  State<GlassMemorialCard> createState() => _GlassMemorialCardState();
}

class _GlassMemorialCardState extends State<GlassMemorialCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -4),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _handleHover(true),
              onExit: (_) => _handleHover(false),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: _buildDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.5),
                            GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration() {
    final baseDecoration = GlassmorphismDecorations.glassCard;
    
    if (_isPressed) {
      return baseDecoration.copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x60FFFFFF),
            Color(0x40FFFFFF),
            Color(0x30FFFFFF),
          ],
        ),
      );
    }
    
    if (_isHovered || _elevationAnimation.value > 0) {
      return GlassmorphismDecorations.glassCardHover.copyWith(
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.shadowMedium,
            blurRadius: 20 + (_elevationAnimation.value * 20),
            offset: Offset(0, 8 + (_elevationAnimation.value * 8)),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: GlassmorphismColors.shadowLight,
            blurRadius: 40 + (_elevationAnimation.value * 20),
            offset: Offset(0, 4 + (_elevationAnimation.value * 4)),
            spreadRadius: -8,
          ),
        ],
      );
    }
    
    return baseDecoration;
  }

  Widget _buildContent() {
    if (widget.isCompact) {
      return _buildCompactContent();
    } else {
      return _buildFullContent();
    }
  }

  Widget _buildCompactContent() {
    final hasImage = widget.memorial.primaryImage != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片区域
        if (hasImage) _buildImageSection(),
        
        // 内容区域
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10), // 进一步减小内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            children: [
              // 标题行
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.memorial.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4), // 减小间距
                  if (widget.showMoreButton) ...[
                    _buildMoreButton(),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: _buildMemorialBadge(),
                  ),
                ],
              ),
              
              const SizedBox(height: 4), // 减少间距
              
              // 描述
              if (widget.memorial.description?.isNotEmpty == true)
                Text(
                  widget.memorial.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 4), // 进一步减少间距
              
              // 互动区域
              _buildInteractionRow(),
            ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              // 头像或图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: GlassmorphismColors.glassGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlassmorphismColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  GlassIcons.memorial,
                  color: GlassmorphismColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3, // 给名字和关系分配更多空间
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.memorial.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.memorial.relationship?.isNotEmpty == true)
                      Text(
                        widget.memorial.relationship!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlassmorphismColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // 增加间距
              if (widget.showMoreButton) ...[
                _buildMoreButton(),
                const SizedBox(width: 4),
              ],
              _buildMemorialBadge(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 图片区域
          if (widget.memorial.primaryImage != null) ...[
            _buildImageSection(),
            const SizedBox(height: 16),
          ],
          
          // 描述
          if (widget.memorial.description?.isNotEmpty == true) ...[
            Text(
              widget.memorial.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          
          // 日期信息
          _buildDateInfo(),
          
          const SizedBox(height: 16),
          
          // 互动区域
          _buildInteractionRow(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: widget.isCompact ? 16 / 9 : 4 / 3,
      child: ClipRRect(
        borderRadius: widget.isCompact 
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(12),
        child: PlatformImage(
          imagePath: widget.memorial.primaryImage ?? '',
          fit: BoxFit.cover,
          placeholder: Container(
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                GlassIcons.photo,
                size: 32,
                color: GlassmorphismColors.textTertiary,
              ),
            ),
          ),
          errorWidget: Container(
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                GlassIcons.photo,
                size: 32,
                color: GlassmorphismColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemorialBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // 进一步减小内边距
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.primary.withValues(alpha: 0.1),
            GlassmorphismColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(4), // 进一步减小圆角
        border: Border.all(
          color: GlassmorphismColors.primary.withValues(alpha: 0.3),
          width: 0.8, // 减小边框宽度
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            GlassIcons.candle,
            size: 8, // 进一步减小图标尺寸
            color: GlassmorphismColors.primary,
          ),
          const SizedBox(width: 2), // 进一步减小间距
          Text(
            widget.memorial.relationship?.isNotEmpty == true 
                ? widget.memorial.relationship! 
                : widget.memorial.typeText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 9, // 进一步减小字体大小
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    final birthYear = widget.memorial.birthDate?.year;
    final deathYear = widget.memorial.deathDate?.year;
    
    if (birthYear == null && deathYear == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(
            Icons.calendar_today,
            size: 16,
            color: GlassmorphismColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${birthYear ?? '?'} - ${deathYear ?? '?'}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      children: [
        // 献花
        Flexible(
          child: _buildInteractionButton(
            icon: GlassIcons.flower,
            count: widget.memorial.likeCount ?? 0,
            isActive: (widget.memorial.likeCount ?? 0) > 0,
            onTap: widget.onLike,
            color: GlassmorphismColors.primary,
          ),
        ),
        const SizedBox(width: 8), // 进一步减小间距
        
        // 评论
        Flexible(
          child: _buildInteractionButton(
            icon: GlassIcons.comment,
            count: 0, // TODO: 添加评论计数
            onTap: widget.onComment,
            color: GlassmorphismColors.info,
          ),
        ),
        
        const Spacer(),
        
        // 瞻仰次数
        Flexible(
          child: _buildInteractionButton(
            icon: GlassIcons.view,
            count: widget.memorial.viewCount ?? 0,
            onTap: null, // 瞻仰次数不可点击
            color: GlassmorphismColors.textTertiary,
            isActive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback? onTap,
    required Color color,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 减小内边距
        decoration: isActive ? BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14, // 减小图标尺寸
              color: isActive ? color : GlassmorphismColors.textSecondary,
            ),
            const SizedBox(width: 1), // 进一步减小间距
            Flexible(
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? color : GlassmorphismColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10, // 减小字体大小
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建更多操作按钮
  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: widget.onMore,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
              GlassmorphismColors.glassSurface.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: GlassmorphismColors.glassBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.more_vert,
          size: 16,
          color: GlassmorphismColors.textSecondary,
        ),
      ),
    );
  }
}