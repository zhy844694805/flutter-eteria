import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/photo_carousel.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_floating_action_button.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart' hide GlassFloatingActionButton;
import '../widgets/platform_image.dart';
import '../providers/memorial_provider.dart';

/// 玻璃拟态纪念详情页面
class GlassMemorialDetailPage extends StatefulWidget {
  final Memorial memorial;

  const GlassMemorialDetailPage({
    super.key,
    required this.memorial,
  });

  @override
  State<GlassMemorialDetailPage> createState() => _GlassMemorialDetailPageState();
}

class _GlassMemorialDetailPageState extends State<GlassMemorialDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _heartController;
  late AnimationController _fabController;
  
  late Animation<double> _pageAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _fabAnimation;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  
  bool _isLiked = false;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    
    _heartAnimation = CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeOutCubic,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    
    _scrollController.addListener(_onScroll);
    _pageController.forward();
    
    // 增加瞻仰次数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      provider.incrementMemorialViews(widget.memorial.id);
    });
    
    // 检查是否已献花
    _isLiked = (widget.memorial.likeCount ?? 0) > 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _showFab = offset > 200;
    });
    
    if (_showFab) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(),
                    _buildHeroImage(),
                    _buildMemorialInfo(),
                    _buildActionButtons(),
                    _buildDescription(),
                    _buildPhotoGallery(),
                    _buildTimelineSection(),
                    _buildCommentsSection(),
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
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
            boxShadow: [
              BoxShadow(
                color: GlassmorphismColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Icon(
                Icons.arrow_back_ios,
                color: GlassmorphismColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _showShareSheet,
          child: Container(
            margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    GlassIcons.share,
                    color: GlassmorphismColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final hasImage = widget.memorial.primaryImage != null;
    
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(20),
        child: GlassHoverCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景图片
                if (hasImage)
                  PlatformImage(
                    imagePath: widget.memorial.primaryImage!,
                    fit: BoxFit.cover,
                    placeholder: _buildImagePlaceholder(),
                    errorWidget: _buildImagePlaceholder(),
                  )
                else
                  _buildImagePlaceholder(),
                
                // 渐变遮罩
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
                
                // 纪念标识
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: GlassmorphismColors.glassGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GlassmorphismColors.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          GlassIcons.candle,
                          size: 14,
                          color: GlassmorphismColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '纪念',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: GlassmorphismColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassmorphismColors.backgroundSecondary,
            GlassmorphismColors.backgroundTertiary,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              GlassIcons.photo,
              size: 48,
              color: GlassmorphismColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '珍贵的回忆',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemorialInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名字和关系
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memorial.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: GlassmorphismColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.memorial.relationship?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            '我的${widget.memorial.relationship}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: GlassmorphismColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 隐私状态
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (widget.memorial.isPublic == true 
                          ? GlassmorphismColors.success 
                          : GlassmorphismColors.warning)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (widget.memorial.isPublic == true 
                            ? GlassmorphismColors.success 
                            : GlassmorphismColors.warning)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.memorial.isPublic == true ? '公开' : '私密',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.memorial.isPublic == true 
                            ? GlassmorphismColors.success 
                            : GlassmorphismColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 生命时间轴
              _buildLifeTimeline(),
              
              const SizedBox(height: 20),
              
              // 统计信息
              _buildStatistics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifeTimeline() {
    final birthYear = widget.memorial.birthDate.year;
    final deathYear = widget.memorial.deathDate.year;
    
    if (birthYear == null && deathYear == null) {
      return const SizedBox.shrink();
    }
    
    int? age;
    if (birthYear != null && deathYear != null) {
      age = deathYear - birthYear;
    }
    
    return Container(
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
          color: GlassmorphismColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // 出生
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: GlassmorphismColors.success,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '出生',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: GlassmorphismColors.textTertiary,
                  ),
                ),
                Text(
                  birthYear?.toString() ?? '未知',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // 连接线
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.success,
                  GlassmorphismColors.primary,
                ],
              ),
            ),
          ),
          
          // 享年
          if (age != null) ...[
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '享年',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GlassmorphismColors.textTertiary,
                    ),
                  ),
                  Text(
                    '$age岁',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 连接线
            Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.primary,
                    GlassmorphismColors.secondary,
                  ],
                ),
              ),
            ),
          ],
          
          // 离世
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: GlassmorphismColors.secondary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '离世',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: GlassmorphismColors.textTertiary,
                  ),
                ),
                Text(
                  deathYear?.toString() ?? '未知',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            GlassIcons.heart,
            '${widget.memorial.likeCount ?? 0}',
            '献花',
            GlassmorphismColors.error,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            GlassIcons.view,
            '${widget.memorial.viewCount ?? 0}',
            '瞻仰',
            GlassmorphismColors.info,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            GlassIcons.comment,
            '0', // TODO: 添加评论数统计
            '留言',
            GlassmorphismColors.success,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            Icons.calendar_today,
            _formatDaysAgo(widget.memorial.createdAt),
            '创建',
            GlassmorphismColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: GlassInteractiveButton(
                text: _isLiked ? '已献花' : '献花',
                icon: _isLiked ? GlassIcons.heartFilled : GlassIcons.heart,
                onPressed: _toggleLike,
                backgroundColor: _isLiked 
                    ? GlassmorphismColors.error.withValues(alpha: 0.1)
                    : null,
                foregroundColor: _isLiked 
                    ? GlassmorphismColors.error 
                    : GlassmorphismColors.textPrimary,
                height: 48,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassInteractiveButton(
                text: '留言',
                icon: GlassIcons.comment,
                onPressed: _showCommentDialog,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.memorial.description.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '纪念文字',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.memorial.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final images = widget.memorial.imageUrls;
    if (images.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    GlassIcons.photo,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '照片回忆',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GlassmorphismColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${images.length}张',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GlassmorphismColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showPhotoViewer(images, index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: PlatformImage(
                          imagePath: images[index],
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: GlassmorphismColors.backgroundSecondary,
                            child: Icon(
                              GlassIcons.photo,
                              color: GlassmorphismColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '纪念时间线',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimelineItem(
                Icons.add_circle,
                '建立纪念',
                _formatDateTime(widget.memorial.createdAt),
                GlassmorphismColors.success,
              ),
              if (widget.memorial.updatedAt != widget.memorial.createdAt)
                _buildTimelineItem(
                  Icons.edit,
                  '更新信息',
                  _formatDateTime(widget.memorial.updatedAt),
                  GlassmorphismColors.info,
                ),
              // TODO: 添加更多时间线事件
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
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

  Widget _buildCommentsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    GlassIcons.comment,
                    color: GlassmorphismColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '留言区',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showCommentDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: GlassmorphismColors.glassGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '写留言',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: GlassmorphismColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 暂无留言状态
              Center(
                child: Column(
                  children: [
                    Icon(
                      GlassIcons.comment,
                      size: 32,
                      color: GlassmorphismColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '还没有留言',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GlassmorphismColors.textTertiary,
                      ),
                    ),
                    Text(
                      '成为第一个留言的人',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GlassmorphismColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: _showFab
              ? GlassFloatingActionButton(
                  icon: Icons.keyboard_arrow_up,
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  tooltip: '返回顶部',
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  // 交互方法
  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _heartController.forward().then((_) {
        _heartController.reverse();
      });
      
      HapticFeedback.lightImpact();
    }
    
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await provider.toggleMemorialLike(widget.memorial.id);
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_heartAnimation.value * 0.5),
                    child: Icon(
                      GlassIcons.heartFilled,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(_isLiked ? '献花成功' : '取消献花'),
            ],
          ),
          backgroundColor: _isLiked 
              ? GlassmorphismColors.error.withValues(alpha: 0.9)
              : GlassmorphismColors.textSecondary.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // 恢复状态
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  void _showCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.backgroundGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Row(
                      children: [
                        Text(
                          '写下您的留言',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 输入框
                    GlassFormField(
                      controller: _commentController,
                      hintText: '轻声诉说您的思念...',
                      maxLines: 4,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 发送按钮
                    GlassInteractiveButton(
                      text: '发送留言',
                      icon: Icons.send,
                      onPressed: () {
                        if (_commentController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('留言发送成功'),
                              backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          _commentController.clear();
                        }
                      },
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '分享纪念',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption(Icons.link, '复制链接'),
                      _buildShareOption(Icons.image, '生成图片'),
                      _buildShareOption(Icons.qr_code, '二维码'),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return GlassHoverCard(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label功能开发中'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: GlassmorphismColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoViewer(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            PhotoCarousel(
              imageUrls: images,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // 辅助方法
  String _formatDaysAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '1天前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).round()}月前';
    } else {
      return '${(difference.inDays / 365).round()}年前';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}