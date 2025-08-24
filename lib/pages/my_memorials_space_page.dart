import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/memorial.dart';
import '../providers/memorial_provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_memorial_card.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_icons.dart';
import '../widgets/memorial_action_sheet.dart';
import 'glass_create_page.dart';
import 'glass_memorial_detail_page.dart';

/// 我的纪念空间页面
class MyMemorialsSpacePage extends StatefulWidget {
  const MyMemorialsSpacePage({super.key});

  @override
  State<MyMemorialsSpacePage> createState() => _MyMemorialsSpacePageState();
}

class _MyMemorialsSpacePageState extends State<MyMemorialsSpacePage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  bool _isGridView = true;

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
    
    // 确保加载用户的纪念数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMemorials();
      _showInitialTipIfNeeded();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshMemorials() async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    await provider.loadMemorials();
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
                    _buildStatsSection(),
                    _buildMemorialsList(),
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
        '我的纪念空间',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggleViewMode,
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: GlassmorphismColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Consumer<MemorialProvider>(
        builder: (context, provider, child) {
          final memorials = provider.memorials;
          final totalMemorials = memorials.length;
          final totalFlowers = memorials.fold(0, (sum, memorial) => sum + (memorial.likeCount ?? 0));
          final totalViews = memorials.fold(0, (sum, memorial) => sum + (memorial.viewCount ?? 0));
          
          return Container(
            margin: const EdgeInsets.all(16),
            child: GlassHoverCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        GlassIcons.memorial,
                        color: GlassmorphismColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '空间统计',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: GlassmorphismColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          GlassIcons.memorial,
                          totalMemorials.toString(),
                          '纪念',
                          GlassmorphismColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          GlassIcons.flower,
                          totalFlowers.toString(),
                          '鲜花',
                          GlassmorphismColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          GlassIcons.view,
                          totalViews.toString(),
                          '瞻仰',
                          GlassmorphismColors.info,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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


  Widget _buildMemorialsList() {
    return Consumer<MemorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(GlassmorphismColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载纪念空间...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final memorials = provider.memorials;

        if (memorials.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        if (_isGridView) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final memorial = memorials[index];
                  return GestureDetector(
                    onLongPress: () => _showMemorialActions(memorial),
                    child: GlassMemorialCard(
                      memorial: memorial,
                      isCompact: true,
                      showMoreButton: true,
                      onTap: () => _navigateToMemorialDetail(memorial),
                      onLike: () => _toggleMemorialLike(memorial.id),
                      onMore: () => _showMemorialActions(memorial),
                    ),
                  );
                },
                childCount: memorials.length,
              ),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final memorial = memorials[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GestureDetector(
                    onLongPress: () => _showMemorialActions(memorial),
                    child: GlassMemorialCard(
                      memorial: memorial,
                      isCompact: false,
                      showMoreButton: true,
                      onTap: () => _navigateToMemorialDetail(memorial),
                      onLike: () => _toggleMemorialLike(memorial.id),
                      onMore: () => _showMemorialActions(memorial),
                    ),
                  ),
                );
              },
              childCount: memorials.length,
            ),
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            GlassIcons.memorial,
            size: 64,
            color: GlassmorphismColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有纪念空间',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始为至亲创建温馨的纪念空间',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '创建后点击“⋮”按钮即可管理纪念空间',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textTertiary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlassInteractiveButton(
            text: '缅怀至亲',
            icon: GlassIcons.create,
            onPressed: _navigateToCreate,
            width: 150,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.primary,
            GlassmorphismColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          GlassIcons.create,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }


  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _toggleMemorialLike(int memorialId) async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    final success = await provider.toggleMemorialLike(memorialId);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('献花操作失败，请稍后重试'),
          backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _navigateToMemorialDetail(Memorial memorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlassMemorialDetailPage(memorial: memorial),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GlassCreatePage()),
    ).then((_) => _refreshMemorials());
  }

  void _showMemorialActions(Memorial memorial) {
    HapticFeedback.mediumImpact();
    MemorialActionSheet.show(
      context,
      memorial: memorial,
      onEdit: () => _editMemorial(memorial),
      onDelete: () => _deleteMemorial(memorial),
      onShare: () => _shareMemorial(memorial),
      onToggleVisibility: () => _toggleMemorialVisibility(memorial),
    );
  }

  void _editMemorial(Memorial memorial) {
    // TODO: 导航到编辑页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('编辑功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _deleteMemorial(Memorial memorial) async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    final success = await provider.deleteMemorial(memorial.id);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('纪念空间已删除'),
            backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _refreshMemorials();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('删除失败，请稍后重试'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _shareMemorial(Memorial memorial) {
    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('分享功能开发中'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _toggleMemorialVisibility(Memorial memorial) async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    
    // 创建更新后的纪念对象
    final updatedMemorial = Memorial(
      id: memorial.id,
      name: memorial.name,
      description: memorial.description,
      birthDate: memorial.birthDate,
      deathDate: memorial.deathDate,
      relationship: memorial.relationship,
      type: memorial.type,
      imagePaths: memorial.imagePaths,
      imageUrls: memorial.imageUrls,
      isPublic: !memorial.isPublic, // 切换可见性
      createdAt: memorial.createdAt,
      updatedAt: memorial.updatedAt,
      likeCount: memorial.likeCount,
      viewCount: memorial.viewCount,
      user: memorial.user,
    );
    
    final success = await provider.updateMemorial(updatedMemorial);
    
    if (mounted) {
      if (success) {
        final statusText = updatedMemorial.isPublic ? '已设为公开' : '已设为私密';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusText),
            backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('设置失败，请稍后重试'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  /// 显示初次使用提示
  void _showInitialTipIfNeeded() {
    // 可以使用 SharedPreferences 来检查是否已显示过提示
    // 这里为了简化，暂时不存储状态
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final provider = Provider.of<MemorialProvider>(context, listen: false);
        if (provider.memorials.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '点击纪念卡片右上角“⋮”按钮即可管理纪念空间',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }
}