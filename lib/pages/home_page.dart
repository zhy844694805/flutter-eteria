import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memorial.dart';
import '../widgets/compact_memorial_card.dart';
import '../widgets/staggered_grid_view.dart';
import '../widgets/filter_tabs.dart';
import '../providers/memorial_provider.dart';
import 'memorial_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<MemorialProvider>(context, listen: false);
              provider.loadMemorials();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 实现通知功能
            },
          ),
        ],
      ),
      body: Consumer<MemorialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 页面标题和搜索框
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '网上纪念',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: '追想',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => provider.setSearchQuery(value),
                    ),
                  ],
                ),
              ),
              
              // 过滤标签
              FilterTabs(
                currentFilter: provider.currentFilter,
                onFilterChanged: (filter) => provider.setFilter(filter),
              ),
              
              // 纪念卡片列表 - 双瀑布流
              Expanded(
                child: provider.filteredMemorials.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_neutral,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无纪念',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 12), // 减少水平内边距
                          child: StaggeredGridView(
                            crossAxisCount: 2,
                            mainAxisSpacing: 6, // 减少垂直间距
                            crossAxisSpacing: 8,  // 减少水平间距
                            children: provider.filteredMemorials.map((memorial) {
                              return CompactMemorialCard(
                                memorial: memorial,
                                onTap: () => _showMemorialDetail(context, memorial),
                                onLike: () => _likeMemorial(context, memorial),
                                onComment: () => _commentMemorial(context, memorial),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMemorialDetail(BuildContext context, Memorial memorial) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            MemorialDetailPage(memorial: memorial),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _likeMemorial(BuildContext context, Memorial memorial) async {
    final provider = Provider.of<MemorialProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await provider.toggleMemorialLike(memorial.id);
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('向${memorial.name}献花'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('献花失败，请重试'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _commentMemorial(BuildContext context, Memorial memorial) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: Text('给${memorial.name}留言'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: '写下您想说的话...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('留言成功: ${commentController.text}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('发送'),
            ),
          ],
        );
      },
    );
  }
}