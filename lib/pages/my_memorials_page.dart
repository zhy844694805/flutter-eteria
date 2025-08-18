import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import '../models/memorial.dart';
import '../widgets/platform_image.dart';
import 'memorial_detail_page.dart';
import 'create_page.dart';

class MyMemorialsPage extends StatefulWidget {
  const MyMemorialsPage({super.key});

  @override
  State<MyMemorialsPage> createState() => _MyMemorialsPageState();
}

class _MyMemorialsPageState extends State<MyMemorialsPage> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _sortBy = 'created_at';
  bool _sortAscending = false;

  List<Memorial> _filterAndSortMemorials(List<Memorial> allMemorials, int? currentUserId) {
    if (currentUserId == null) return [];
    
    // 筛选当前用户创建的纪念
    var userMemorials = allMemorials
        .where((memorial) => memorial.isOwnedBy(currentUserId))
        .toList();
    
    // 应用搜索过滤
    if (_searchQuery.isNotEmpty) {
      userMemorials = userMemorials.where((memorial) {
        return memorial.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (memorial.relationship?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               memorial.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // 应用排序
    userMemorials.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'updated_at':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case 'created_at':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return userMemorials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我创建的纪念'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreate,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'created_at',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'created_at'
                          ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.schedule,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('按创建时间'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'updated_at',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'updated_at'
                          ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.update,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('按更新时间'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name'
                          ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.sort_by_alpha,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('按姓名'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final currentUserId = authProvider.currentUser?.id;
                  
                  if (currentUserId == null) {
                    return const Center(
                      child: Text('请先登录查看您的纪念'),
                    );
                  }

                  return Consumer<MemorialProvider>(
                    builder: (context, memorialProvider, child) {
                      if (memorialProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final userMemorials = _filterAndSortMemorials(
                        memorialProvider.memorials, 
                        currentUserId
                      );

                      if (userMemorials.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () => _refreshMemorials(memorialProvider),
                        child: _buildMemorialsList(userMemorials),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索纪念人姓名、关系或描述...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.create_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '没有找到匹配的纪念' : '您还没有创建任何纪念',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? '尝试调整搜索关键词' 
                : '点击右上角的 + 号创建第一个纪念',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add),
              label: const Text('创建纪念'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemorialsList(List<Memorial> memorials) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: memorials.length,
      itemBuilder: (context, index) {
        final memorial = memorials[index];
        return _buildMemorialCard(memorial);
      },
    );
  }

  Widget _buildMemorialCard(Memorial memorial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToDetail(memorial),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemorialHeader(memorial),
              _buildMemorialContent(memorial),
              _buildMemorialActions(memorial),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorialHeader(Memorial memorial) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.surfaceVariant,
              child: memorial.primaryImage != null
                  ? PlatformImage(
                      imagePath: memorial.primaryImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.textSecondary,
                    ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (memorial.relationship != null) ...[
                  Text(
                    memorial.relationship!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  memorial.formattedDates,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              Icon(
                memorial.isPublic ? Icons.public : Icons.lock,
                size: 16,
                color: memorial.isPublic ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                memorial.isPublic ? '公开' : '私密',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: memorial.isPublic ? AppColors.success : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemorialContent(Memorial memorial) {
    if (memorial.description.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        memorial.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMemorialActions(Memorial memorial) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatChip(
            icon: Icons.favorite,
            count: memorial.likeCount ?? 0,
            label: '点赞',
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.visibility,
            count: memorial.viewCount ?? 0,
            label: '浏览',
          ),
          const Spacer(),
          
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editMemorial(memorial),
            tooltip: '编辑',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteMemorial(memorial),
            tooltip: '删除',
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshMemorials(MemorialProvider memorialProvider) async {
    await memorialProvider.loadMemorials();
  }

  void _navigateToCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePage(),
      ),
    ).then((_) {
      // 创建完成后刷新列表
      if (mounted) {
        final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
        _refreshMemorials(memorialProvider);
      }
    });
  }

  void _navigateToDetail(Memorial memorial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemorialDetailPage(memorial: memorial),
      ),
    );
  }

  void _editMemorial(Memorial memorial) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('编辑功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteMemorial(Memorial memorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除纪念'),
        content: Text('确定要删除"${memorial.name}"的纪念吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDelete(memorial);
            },
            child: Text(
              '删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Memorial memorial) async {
    try {
      final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
      final success = await memorialProvider.deleteMemorial(memorial.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('纪念删除成功'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除失败，请重试'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}