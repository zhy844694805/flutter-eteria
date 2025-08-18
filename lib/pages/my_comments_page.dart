import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/memorial_service.dart';
import '../widgets/platform_image.dart';

class MyCommentsPage extends StatefulWidget {
  const MyCommentsPage({super.key});

  @override
  State<MyCommentsPage> createState() => _MyCommentsPageState();
}

class _MyCommentsPageState extends State<MyCommentsPage> {
  final ScrollController _scrollController = ScrollController();
  final MemorialService _memorialService = MemorialService();
  
  List<UserComment> _comments = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
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
      _loadMoreComments();
    }
  }

  Future<void> _loadComments({bool isRefresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      if (isRefresh) {
        _comments.clear();
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    try {
      final result = await _memorialService.getUserComments(
        page: _currentPage,
        limit: 10,
      );

      final List<UserComment> newComments = (result['comments'] as List)
          .map((json) => UserComment.fromJson(json))
          .toList();

      setState(() {
        if (isRefresh) {
          _comments = newComments;
        } else {
          _comments.addAll(newComments);
        }
        
        _hasMoreData = newComments.length >= 10;
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

  Future<void> _loadMoreComments() async {
    await _loadComments();
  }

  Future<void> _refreshComments() async {
    await _loadComments(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的留言'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isLoggedIn) {
              return const Center(
                child: Text('请先登录查看您的留言'),
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
                      onPressed: () => _loadComments(isRefresh: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (_comments.isEmpty && !_isLoading) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refreshComments,
              child: _buildCommentsList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有留言',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去纪念页面留下您的第一条留言吧',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _comments.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final comment = _comments[index];
        return _buildCommentCard(comment);
      },
    );
  }

  Widget _buildCommentCard(UserComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToMemorial(comment),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommentHeader(comment),
                const SizedBox(height: 12),
                _buildCommentContent(comment),
                const SizedBox(height: 12),
                _buildCommentFooter(comment),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentHeader(UserComment comment) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 48,
            height: 48,
            color: AppColors.surfaceVariant,
            child: comment.memorial.primaryImage != null
                ? PlatformImage(
                    imagePath: comment.memorial.primaryImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.person,
                    size: 24,
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
                comment.memorial.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '创建者：${comment.memorial.creator.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          comment.memorial.isPublic ? Icons.public : Icons.lock,
          size: 16,
          color: comment.memorial.isPublic ? AppColors.success : AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildCommentContent(UserComment comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        comment.content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCommentFooter(UserComment comment) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(comment.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _navigateToMemorial(UserComment comment) {
    // 这里需要先获取完整的memorial信息，因为comment中只有部分信息
    // 暂时显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('点击查看完整纪念页面'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class UserComment {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentMemorial memorial;

  UserComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.memorial,
  });

  factory UserComment.fromJson(Map<String, dynamic> json) {
    return UserComment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      memorial: CommentMemorial.fromJson(json['memorial']),
    );
  }
}

class CommentMemorial {
  final int id;
  final String name;
  final bool isPublic;
  final CommentCreator creator;
  final String? primaryImage;

  CommentMemorial({
    required this.id,
    required this.name,
    required this.isPublic,
    required this.creator,
    this.primaryImage,
  });

  factory CommentMemorial.fromJson(Map<String, dynamic> json) {
    return CommentMemorial(
      id: json['id'],
      name: json['name'],
      isPublic: json['is_public'],
      creator: CommentCreator.fromJson(json['creator']),
      primaryImage: json['primary_image'],
    );
  }
}

class CommentCreator {
  final int id;
  final String name;
  final String? avatarUrl;

  CommentCreator({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory CommentCreator.fromJson(Map<String, dynamic> json) {
    return CommentCreator(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
    );
  }
}