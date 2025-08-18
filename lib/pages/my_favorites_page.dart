import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/memorial_service.dart';
import '../models/memorial.dart';
import '../widgets/platform_image.dart';
import 'memorial_detail_page.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  final ScrollController _scrollController = ScrollController();
  final MemorialService _memorialService = MemorialService();
  
  List<Memorial> _favorites = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading && _hasMoreData) {
      _loadMoreFavorites();
    }
  }

  Future<void> _loadFavorites({bool isRefresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      if (isRefresh) {
        _favorites.clear();
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    try {
      final result = await _memorialService.getUserFavorites(
        page: _currentPage,
        limit: 10,
      );

      final List<Memorial> newFavorites = (result['memorials'] as List)
          .map((json) => Memorial.fromJson(json))
          .toList();

      setState(() {
        if (isRefresh) {
          _favorites = newFavorites;
        } else {
          _favorites.addAll(newFavorites);
        }
        
        _hasMoreData = newFavorites.length >= 10;
        if (!isRefresh) _currentPage++;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFavorites() async {
    await _loadFavorites();
  }

  Future<void> _refreshFavorites() async {
    await _loadFavorites(isRefresh: true);
  }

  List<Memorial> _getFilteredFavorites() {
    if (_searchQuery.isEmpty) return _favorites;
    
    return _favorites.where((memorial) {
      return memorial.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (memorial.relationship?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
             memorial.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _unfavoriteMemorial(Memorial memorial) async {
    try {
      await _memorialService.toggleFavorite(memorial.id);
      setState(() {
        _favorites.removeWhere((m) => m.id == memorial.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已取消收藏'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('取消收藏失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我收藏的纪念'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (!authProvider.isLoggedIn) {
                    return const Center(
                      child: Text('请先登录查看您的收藏'),
                    );
                  }

                  if (_hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '加载失败',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadFavorites(isRefresh: true),
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredFavorites = _getFilteredFavorites();
                  
                  if (filteredFavorites.isEmpty && !_isLoading) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshFavorites,
                    child: _buildFavoritesList(filteredFavorites),
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
          hintText: '搜索收藏的纪念...',
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
            Icons.bookmark_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '没有找到匹配的收藏' : '还没有收藏任何纪念',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? '尝试调整搜索关键词' 
                : '浏览纪念页面并收藏您感兴趣的内容',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Memorial> favorites) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: favorites.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= favorites.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final memorial = favorites[index];
        return _buildFavoriteCard(memorial);
      },
    );
  }

  Widget _buildFavoriteCard(Memorial memorial) {
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
              _buildFavoriteHeader(memorial),
              _buildFavoriteContent(memorial),
              _buildFavoriteActions(memorial),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteHeader(Memorial memorial) {
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

  Widget _buildFavoriteContent(Memorial memorial) {
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

  Widget _buildFavoriteActions(Memorial memorial) {
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
            icon: const Icon(Icons.bookmark_remove, size: 20),
            onPressed: () => _showUnfavoriteDialog(memorial),
            tooltip: '取消收藏',
            color: AppColors.error,
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

  void _showUnfavoriteDialog(Memorial memorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消收藏'),
        content: Text('确定要取消收藏"${memorial.name}"的纪念吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _unfavoriteMemorial(memorial);
            },
            child: Text(
              '确定',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Memorial memorial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemorialDetailPage(memorial: memorial),
      ),
    );
  }
}