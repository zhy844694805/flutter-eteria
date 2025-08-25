import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart' show GlassInteractiveButton;

/// 最近活动页面
class RecentActivitiesPage extends StatefulWidget {
  const RecentActivitiesPage({super.key});

  @override
  State<RecentActivitiesPage> createState() => _RecentActivitiesPageState();
}

class _RecentActivitiesPageState extends State<RecentActivitiesPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all'; // all, memorial, interaction, system
  
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
    _loadActivities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    // TODO: 从后端加载用户的最近活动数据
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
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(),
                    _buildFilterSection(),
                    _buildActivitiesList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
        '最近活动',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _clearAllActivities,
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
              Icons.clear_all,
              color: GlassmorphismColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: GlassmorphismColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '活动筛选',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', '全部', Icons.timeline),
                    const SizedBox(width: 8),
                    _buildFilterChip('memorial', '纪念相关', GlassIcons.memorial),
                    const SizedBox(width: 8),
                    _buildFilterChip('interaction', '互动记录', GlassIcons.flower),
                    const SizedBox(width: 8),
                    _buildFilterChip('system', '系统通知', Icons.notifications_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    GlassmorphismColors.primary.withValues(alpha: 0.2),
                    GlassmorphismColors.primary.withValues(alpha: 0.1),
                  ],
                )
              : GlassmorphismColors.glassGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? GlassmorphismColors.primary.withValues(alpha: 0.4)
                : GlassmorphismColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? GlassmorphismColors.primary
                  : GlassmorphismColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? GlassmorphismColors.primary
                    : GlassmorphismColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    final activities = _getFilteredActivities();
    
    if (activities.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final activity = activities[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildActivityItem(activity),
          );
        },
        childCount: activities.length,
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return GlassHoverCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活动图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activity.iconColor.withValues(alpha: 0.15),
                  activity.iconColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: activity.iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              activity.icon,
              color: activity.iconColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 活动内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: GlassmorphismColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.timeAgo,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GlassmorphismColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 操作按钮
          if (activity.actionable)
            GestureDetector(
              onTap: () => _handleActivityAction(activity),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: GlassmorphismColors.glassSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.1),
                  GlassmorphismColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.timeline,
              size: 40,
              color: GlassmorphismColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyStateTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateSubtitle(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlassInteractiveButton(
            text: '开始活动',
            icon: GlassIcons.create,
            onPressed: () => Navigator.pop(context),
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'memorial':
        return '暂无纪念活动';
      case 'interaction':
        return '暂无互动记录';
      case 'system':
        return '暂无系统通知';
      default:
        return '暂无最近活动';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_selectedFilter) {
      case 'memorial':
        return '创建纪念或管理纪念内容时会显示在这里';
      case 'interaction':
        return '献花、留言等互动记录会显示在这里';
      case 'system':
        return '系统消息和通知会显示在这里';
      default:
        return '开始缅怀至亲或互动来记录活动';
    }
  }

  List<ActivityItem> _getFilteredActivities() {
    // 模拟活动数据
    final allActivities = _getMockActivities();
    
    if (_selectedFilter == 'all') {
      return allActivities;
    }
    
    return allActivities.where((activity) => activity.type == _selectedFilter).toList();
  }

  List<ActivityItem> _getMockActivities() {
    // 模拟数据 - 实际应用中应该从Provider或API获取
    return [
      ActivityItem(
        type: 'memorial',
        icon: GlassIcons.create,
        iconColor: GlassmorphismColors.primary,
        title: '创建了纪念"慈祥的奶奶"',
        description: '为奶奶创建了温馨的纪念空间',
        timeAgo: '2小时前',
        actionable: true,
      ),
      ActivityItem(
        type: 'interaction',
        icon: GlassIcons.flower,
        iconColor: GlassmorphismColors.error,
        title: '收到了一朵鲜花',
        description: '张三为您的纪念"亲爱的爸爸"献花',
        timeAgo: '5小时前',
        actionable: true,
      ),
      ActivityItem(
        type: 'interaction',
        icon: Icons.comment_outlined,
        iconColor: GlassmorphismColors.secondary,
        title: '收到了新留言',
        description: '李四在纪念"慈祥的奶奶"留下了思念',
        timeAgo: '1天前',
        actionable: true,
      ),
      ActivityItem(
        type: 'memorial',
        icon: Icons.photo_outlined,
        iconColor: GlassmorphismColors.info,
        title: '上传了3张照片',
        description: '为纪念"亲爱的妈妈"添加了珍贵回忆',
        timeAgo: '2天前',
        actionable: true,
      ),
      ActivityItem(
        type: 'system',
        icon: Icons.backup_outlined,
        iconColor: GlassmorphismColors.success,
        title: '纪念数据已备份',
        description: '您的所有纪念内容已安全备份到云端',
        timeAgo: '3天前',
        actionable: false,
      ),
      ActivityItem(
        type: 'interaction',
        icon: GlassIcons.view,
        iconColor: GlassmorphismColors.warmAccent,
        title: '纪念被瞻仰了',
        description: '您的纪念"亲爱的爸爸"获得了新的瞻仰',
        timeAgo: '1周前',
        actionable: true,
      ),
    ];
  }

  void _handleActivityAction(ActivityItem activity) {
    // TODO: 根据活动类型处理点击操作
    HapticFeedback.lightImpact();
    
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
            Text('跳转到 ${activity.title}'),
          ],
        ),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAllActivities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassmorphismColors.backgroundTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.clear_all,
              color: GlassmorphismColors.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '清空活动记录',
              style: TextStyle(color: GlassmorphismColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          '确定要清空所有活动记录吗？\n\n此操作不可恢复，清空后将无法查看历史活动。',
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: GlassmorphismColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performClearActivities();
            },
            child: Text(
              '确认清空',
              style: TextStyle(
                color: GlassmorphismColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performClearActivities() {
    // TODO: 实现清空活动记录的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('活动记录已清空'),
          ],
        ),
        backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    // 刷新页面状态
    setState(() {});
  }
}

/// 活动项数据模型
class ActivityItem {
  final String type;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String timeAgo;
  final bool actionable;

  ActivityItem({
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.actionable = false,
  });
}