import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_memorial_card.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../widgets/unsplash_image.dart';
import '../providers/memorial_provider.dart';
import '../utils/network_tester.dart';
import 'glass_memorial_detail_page.dart';

/// 玻璃拟态主页
class GlassHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;
  
  const GlassHomePage({
    super.key,
    this.onNavigateToCreate,
  });

  @override
  State<GlassHomePage> createState() => _GlassHomePageState();
}

class _GlassHomePageState extends State<GlassHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 测试网络连接
    _testNetworkConnection();
  }
  
  /// 测试网络连接
  void _testNetworkConnection() async {
    final isConnected = await NetworkTester.testLocalConnection();
    print('🌐 [GlassHomePage] 网络连接状态: ${isConnected ? '正常' : '异常'}');
    
    // 延迟一段时间等待纪念数据加载完成
    await Future.delayed(const Duration(seconds: 2));
    
    // 如果有纪念数据，测试第一张图片
    if (mounted) {
      final memorialProvider = context.read<MemorialProvider>();
      if (memorialProvider.memorials.isNotEmpty) {
        final firstMemorial = memorialProvider.memorials.first;
        if (firstMemorial.primaryImage != null) {
          print('🧪 [GlassHomePage] 准备测试图片: ${firstMemorial.primaryImage!}');
          final canLoadImage = await NetworkTester.testImageUrl(firstMemorial.primaryImage!);
          print('🖼️ [GlassHomePage] 图片加载测试: ${canLoadImage ? '成功' : '失败'}');
        } else {
          print('⚠️ [GlassHomePage] 第一个纪念没有图片');
        }
      } else {
        print('⚠️ [GlassHomePage] 没有纪念数据可测试');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMemorialsList(),
                    _buildRecentActivity(),
                    _buildTrendingMemorials(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '永念',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '珍藏每一份思念',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GlassIconButton(
                icon: GlassIcons.search,
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                isActive: _showSearch,
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                icon: GlassIcons.settings,
                onPressed: () {
                  // TODO: 跳转设置页面
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSearch ? 80 : 0,
      curve: Curves.easeInOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showSearch ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassSearchField(
            controller: _searchController,
            hintText: '寻找心中的那个人...',
            onChanged: (value) {
              // TODO: 实现搜索功能
              final provider = Provider.of<MemorialProvider>(context, listen: false);
              provider.setSearchQuery(value);
            },
            onClear: () {
              final provider = Provider.of<MemorialProvider>(context, listen: false);
              provider.setSearchQuery('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: GlassmorphismDecorations.glassCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.2),
                  GlassmorphismColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            labelColor: GlassmorphismColors.primary,
            unselectedLabelColor: GlassmorphismColors.textSecondary,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '动态'),
              Tab(text: '热门'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorialsList() {
    return Consumer<MemorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!, provider);
        }

        if (provider.filteredMemorials.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          backgroundColor: GlassmorphismColors.glassSurface,
          color: GlassmorphismColors.primary,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final memorial = provider.filteredMemorials[index];
                      return GlassMemorialCard(
                        memorial: memorial,
                        isCompact: true,
                        onTap: () => _showMemorialDetail(memorial),
                        onLike: () => _likeMemorial(memorial),
                        onComment: () => _commentMemorial(memorial),
                      );
                    },
                    childCount: provider.filteredMemorials.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<MemorialProvider>(
      builder: (context, provider, child) {
        final recentMemorials = provider.memorials.take(10).toList();
        
        if (recentMemorials.isEmpty) {
          return _buildEmptyActivityState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: recentMemorials.length,
          itemBuilder: (context, index) {
            final memorial = recentMemorials[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassHoverCard(
                onTap: () => _showMemorialDetail(memorial),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 头像或图片
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: memorial.primaryImage != null
                          ? Image.network(
                              memorial.primaryImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : UnsplashImage.memorial(
                              width: 50,
                              height: 50,
                              borderRadius: BorderRadius.circular(8),
                              seed: memorial.id,
                            ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memorial.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: GlassmorphismColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (memorial.relationship?.isNotEmpty == true)
                            Text(
                              memorial.relationship!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: GlassmorphismColors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(memorial.createdAt),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: GlassmorphismColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 统计
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              GlassIcons.flower,
                              size: 14,
                              color: GlassmorphismColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${memorial.likeCount ?? 0}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: GlassmorphismColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              GlassIcons.view,
                              size: 14,
                              color: GlassmorphismColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${memorial.viewCount ?? 0}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: GlassmorphismColors.textTertiary,
                              ),
                            ),
                          ],
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

  Widget _buildTrendingMemorials() {
    return Consumer<MemorialProvider>(
      builder: (context, provider, child) {
        // 按鲜花数排序
        final trending = provider.memorials.toList()
          ..sort((a, b) => (b.likeCount ?? 0).compareTo(a.likeCount ?? 0));
        
        if (trending.isEmpty) {
          return _buildEmptyTrendingState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: trending.length,
          itemBuilder: (context, index) {
            final memorial = trending[index];
            return Stack(
              children: [
                GlassMemorialCard(
                  memorial: memorial,
                  isCompact: true,
                  onTap: () => _showMemorialDetail(memorial),
                  onLike: () => _likeMemorial(memorial),
                  onComment: () => _commentMemorial(memorial),
                ),
                // 排名标识
                if (index < 3)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getRankingColor(index).withValues(alpha: 0.9),
                            _getRankingColor(index).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getRankingColor(index).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getRankingColor(int rank) {
    switch (rank) {
      case 0: return const Color(0xFFFFD700); // 金色
      case 1: return const Color(0xFFC0C0C0); // 银色
      case 2: return const Color(0xFFCD7F32); // 铜色
      default: return GlassmorphismColors.primary;
    }
  }

  Widget _buildFloatingActionButton() {
    return GlassFloatingActionButton(
      icon: GlassIcons.create,
      onPressed: () {
        widget.onNavigateToCreate?.call();
      },
      tooltip: '缅怀至亲',
    );
  }

  // 状态页面构建方法
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: GlassmorphismColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, MemorialProvider provider) {
    return Center(
      child: GlassHoverCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: GlassmorphismColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GlassmorphismColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GlassInteractiveButton(
              text: '重试',
              icon: Icons.refresh,
              onPressed: () => provider.refresh(),
              width: 120,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassHoverCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UnsplashImage.memorial(
              width: 120,
              height: 120,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 16),
            Text(
              '这里还很安静',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '创建第一份纪念，让回忆永远绽放',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GlassmorphismColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GlassInteractiveButton(
              text: '缅怀至亲',
              icon: GlassIcons.create,
              onPressed: () => widget.onNavigateToCreate?.call(),
              width: 140,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyActivityState() {
    return Center(
      child: GlassHoverCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: GlassmorphismColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无活动记录',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTrendingState() {
    return Center(
      child: GlassHoverCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: GlassmorphismColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无热门纪念',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助方法
  void _showMemorialDetail(Memorial memorial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GlassMemorialDetailPage(memorial: memorial),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _likeMemorial(Memorial memorial) async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await provider.toggleMemorialLike(memorial.id);

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                GlassIcons.flower,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('为${memorial.name}献上一朵花'),
            ],
          ),
          backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.9),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _commentMemorial(Memorial memorial) {
    // TODO: 实现评论功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassmorphismColors.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('对${memorial.name}说些话'),
        content: const GlassFormField(
          hintText: '轻声诉说您的思念...',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          GlassInteractiveButton(
            text: '发送',
            onPressed: () => Navigator.pop(context),
            width: 80,
            height: 36,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}