import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/photo_carousel.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_floating_action_button.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart' hide GlassFloatingActionButton;
import '../widgets/platform_image.dart';
import '../widgets/share_dialog.dart';
import '../providers/memorial_provider.dart';
import '../providers/auth_provider.dart';
import 'glass_login_page.dart';

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
  List<dynamic> _comments = [];
  bool _isLoadingComments = false;

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
    
    // 加载留言数据
    _loadComments();
    
    // 检查当前用户的献花状态
    _checkLikeStatus();
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

  Future<void> _loadComments() async {
    if (_isLoadingComments) return;
    
    setState(() {
      _isLoadingComments = true;
    });
    
    try {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      final comments = await provider.getComments(widget.memorial.id);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      print('💬 [DetailPage] 加载留言失败: $e');
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _sendComment(String content) async {
    try {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      await provider.addComment(widget.memorial.id, content);
      
      // 重新加载留言列表
      await _loadComments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('留言发送成功'),
            backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('💬 [DetailPage] 发送留言失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('留言发送失败，请稍后重试'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _checkLikeStatus() async {
    try {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      final stats = await provider.getMemorialStats(widget.memorial.id);
      
      setState(() {
        _isLiked = stats['user_liked'] ?? false;
      });
      
      print('✅ [DetailPage] 用户献花状态: $_isLiked');
    } catch (e) {
      print('❌ [DetailPage] 获取献花状态失败: $e');
      // 默认为未献花
      setState(() {
        _isLiked = false;
      });
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
                      GlassmorphismColors.glassSurface.withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: GlassmorphismColors.glassBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
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
    final hasImages = widget.memorial.imageUrls.isNotEmpty;
    
    print('🖼️ [DetailPage] 构建Hero图片，hasImages: $hasImages, 图片数量: ${widget.memorial.imageUrls.length}');
    print('🖼️ [DetailPage] 图片URL列表: ${widget.memorial.imageUrls}');
    
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
                // 多图轮播或占位图
                if (hasImages)
                  PhotoCarousel(
                    imageUrls: widget.memorial.imageUrls,
                    height: 300,
                    showDots: widget.memorial.imageUrls.length > 1,
                    showCounter: widget.memorial.imageUrls.length > 1,
                    autoPlay: widget.memorial.imageUrls.length > 1, // 有多张图片时才自动播放
                    fullWidth: true, // 完全填满容器
                    glassStyle: true, // 启用玻璃拟态样式
                  )
                else
                  _buildImagePlaceholder(),
                
                // 渐变遮罩（仅在有图片时显示，并且使用IgnorePointer避免阻挡事件）
                if (hasImages)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                
                // 纪念标识（使用IgnorePointer避免阻挡轮播控件）
                Positioned(
                  top: 20,
                  left: 20,
                  child: IgnorePointer(
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
                            widget.memorial.relationship?.isNotEmpty == true 
                                ? widget.memorial.relationship! 
                                : widget.memorial.typeText,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: GlassmorphismColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                    flex: 3, // 给名字和关系分配更多空间
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memorial.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: GlassmorphismColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2, // 允许名字换行
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.memorial.relationship?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            '我的${widget.memorial.relationship}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: GlassmorphismColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12), // 增加间距
                  
                  // 隐私状态
                  Flexible( // 使用Flexible让隐私状态可以收缩
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 减小内边距
                      decoration: BoxDecoration(
                        color: (widget.memorial.isPublic == true 
                            ? GlassmorphismColors.success 
                            : GlassmorphismColors.warning)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10), // 减小圆角
                        border: Border.all(
                          color: (widget.memorial.isPublic == true 
                              ? GlassmorphismColors.success 
                              : GlassmorphismColors.warning)
                              .withValues(alpha: 0.3),
                          width: 0.8, // 减小边框宽度
                        ),
                    ),
                      child: Text(
                        widget.memorial.isPublic == true ? '公开' : '私密',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.memorial.isPublic == true 
                              ? GlassmorphismColors.success 
                              : GlassmorphismColors.warning,
                          fontWeight: FontWeight.w500,
                          fontSize: 11, // 减小字体大小
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
    
    int? age;
    age = deathYear - birthYear;
    
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
    return Consumer<MemorialProvider>(
      builder: (context, provider, child) {
        // 获取最新的纪念数据
        final memorial = provider.memorials.firstWhere(
          (m) => m.id == widget.memorial.id,
          orElse: () => widget.memorial,
        );
        
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                GlassIcons.flower,
                '${memorial.likeCount ?? 0}',
                '献花',
                GlassmorphismColors.primary,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                GlassIcons.view,
                '${memorial.viewCount ?? 0}',
                '瞻仰',
                GlassmorphismColors.info,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                GlassIcons.comment,
                '${_comments.length}',
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
      },
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
        child: Consumer<MemorialProvider>(
          builder: (context, provider, child) {
            // 获取最新的纪念数据
            final memorial = provider.memorials.firstWhere(
              (m) => m.id == widget.memorial.id,
              orElse: () => widget.memorial,
            );
            
            return Row(
              children: [
                Expanded(
                  child: GlassInteractiveButton(
                    text: _isLiked ? '已献花' : '献花',
                    icon: GlassIcons.flower,
                    onPressed: _toggleLike,
                    backgroundColor: _isLiked 
                        ? GlassmorphismColors.error.withValues(alpha: 0.1)
                        : null,
                    foregroundColor: _isLiked 
                        ? GlassmorphismColors.error 
                        : GlassmorphismColors.textPrimary,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassInteractiveButton(
                    text: '留言',
                    icon: GlassIcons.comment,
                    onPressed: _showCommentDialog,
                    height: 56,
                  ),
                ),
              ],
            );
          },
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
              
              // 留言列表或暂无留言状态
              if (_isLoadingComments)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_comments.isEmpty)
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
                )
              else
                // 留言列表
                Column(
                  children: _comments.map((comment) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: GlassmorphismColors.glassGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlassmorphismColors.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 留言内容
                          Text(
                            comment['content'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: GlassmorphismColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 留言信息
                          Row(
                            children: [
                              Text(
                                comment['user']?['name'] ?? '匿名用户',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: GlassmorphismColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatCommentDate(comment['created_at']),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: GlassmorphismColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // 检查是否为游客模式
    if (!authProvider.isLoggedIn) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                GlassIcons.lock,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('请登录后再献花'),
            ],
          ),
          backgroundColor: GlassmorphismColors.warning.withValues(alpha: 0.9),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: '登录',
            textColor: Colors.white,
            onPressed: () {
              // 直接推送到登录页面
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GlassLoginPage(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    
    try {
      print('🔄 [DetailPage] 切换献花状态，当前状态: $_isLiked');
      
      // 调用API并获取结果
      final result = await provider.toggleMemorialLikeWithResult(widget.memorial.id);
      
      if (result != null) {
        // 直接使用API返回的状态
        final newLikedStatus = result['liked'] ?? false;
        final newLikeCount = result['like_count'] ?? 0;
        
        // 更新本地状态
        setState(() {
          _isLiked = newLikedStatus;
        });
        
        // 播放动画（只有献花时播放）
        if (_isLiked) {
          _heartController.forward().then((_) {
            _heartController.reverse();
          });
        }
        
        HapticFeedback.lightImpact();
        print('✅ [DetailPage] 献花状态更新成功，API状态: $_isLiked, 点赞数: $newLikeCount');
        
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
                        GlassIcons.flower,
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
        print('❌ [DetailPage] 献花操作失败');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('献花失败，请稍后重试'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('❌ [DetailPage] 献花操作异常: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('献花失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.7),
                  ],
                ),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder,
                  width: 1,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                      onPressed: () async {
                        final content = _commentController.text.trim();
                        if (content.isNotEmpty) {
                          Navigator.pop(context);
                          _commentController.clear();
                          await _sendComment(content);
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
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ShareDialog(memorial: widget.memorial),
    );
  }

  void _showPhotoViewer(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenImageViewer(
              images: images,
              initialIndex: initialIndex,
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

  String _formatCommentDate(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${date.month}月${date.day}日';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}