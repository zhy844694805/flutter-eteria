import 'package:flutter/foundation.dart';
import '../models/memorial.dart';
import '../models/filter_type.dart';
import '../services/memorial_service.dart';

class MemorialProvider extends ChangeNotifier {
  final MemorialService _service = MemorialService();
  List<Memorial> _memorials = [];
  FilterType _currentFilter = FilterType.all;
  String _searchQuery = '';
  bool _isLoading = false;

  List<Memorial> get memorials => _memorials;
  FilterType get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => null; // 简化：不使用error状态

  List<Memorial> get filteredMemorials {
    return _memorials.where((memorial) {
      final matchesFilter = _currentFilter == FilterType.all ||
          FilterTypeExtension.fromRelationship(memorial.relationship) == _currentFilter;
      
      final matchesSearch = _searchQuery.isEmpty ||
          memorial.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          memorial.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void setFilter(FilterType filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadMemorials() async {
    print('🔄 [MemorialProvider] 开始加载纪念数据...');
    _isLoading = true;
    notifyListeners();
    
    try {
      _memorials = await _service.getMemorials();
      print('✅ [MemorialProvider] 加载成功，共 ${_memorials.length} 条纪念数据');
    } catch (e) {
      print('❌ [MemorialProvider] 加载失败: $e');
      // 静默处理错误，保持简单
      _memorials = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMemorial(Memorial memorial) async {
    try {
      final saved = await _service.saveMemorial(memorial);
      _memorials.add(saved);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMemorial(Memorial memorial) async {
    try {
      final updated = await _service.updateMemorial(memorial);
      final index = _memorials.indexWhere((m) => m.id == memorial.id);
      if (index != -1) {
        _memorials[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMemorial(int id) async {
    try {
      await _service.deleteMemorial(id);
      _memorials.removeWhere((memorial) => memorial.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleMemorialLike(int memorialId) async {
    try {
      print('🔄 [MemorialProvider] 正在切换纪念献花: $memorialId');
      final result = await _service.toggleLike(memorialId);
      
      // 更新本地纪念数据
      final index = _memorials.indexWhere((memorial) => memorial.id == memorialId);
      if (index != -1) {
        final memorial = _memorials[index];
        final newLikeCount = result['like_count'] ?? memorial.likeCount ?? 0;
        final isLiked = result['liked'] ?? false;
        
        // 创建新的Memorial实例并更新
        _memorials[index] = Memorial(
          id: memorial.id,
          name: memorial.name,
          description: memorial.description,
          birthDate: memorial.birthDate,
          deathDate: memorial.deathDate,
          relationship: memorial.relationship,
          type: memorial.type,
          imagePaths: memorial.imagePaths,
          imageUrls: memorial.imageUrls,
          isPublic: memorial.isPublic,
          createdAt: memorial.createdAt,
          updatedAt: memorial.updatedAt,
          likeCount: newLikeCount,
          viewCount: memorial.viewCount,
          user: memorial.user,
        );
        
        notifyListeners();
        print('✅ [MemorialProvider] 献花状态已更新: $isLiked, 数量: $newLikeCount');
      }
      
      return true;
    } catch (e) {
      print('❌ [MemorialProvider] 献花失败: $e');
      return false;
    }
  }
  
  Future<void> incrementMemorialViews(int memorialId) async {
    try {
      print('🔄 [MemorialProvider] 正在增加瞻仰次数: $memorialId');
      await _service.incrementViews(memorialId);
      
      // 更新本地浏览数据
      final index = _memorials.indexWhere((memorial) => memorial.id == memorialId);
      if (index != -1) {
        final memorial = _memorials[index];
        final newViewCount = (memorial.viewCount ?? 0) + 1;
        
        // 创建新的Memorial实例并更新
        _memorials[index] = Memorial(
          id: memorial.id,
          name: memorial.name,
          description: memorial.description,
          birthDate: memorial.birthDate,
          deathDate: memorial.deathDate,
          relationship: memorial.relationship,
          type: memorial.type,
          imagePaths: memorial.imagePaths,
          imageUrls: memorial.imageUrls,
          isPublic: memorial.isPublic,
          createdAt: memorial.createdAt,
          updatedAt: memorial.updatedAt,
          likeCount: memorial.likeCount,
          viewCount: newViewCount,
          user: memorial.user,
        );
        
        notifyListeners();
        print('✅ [MemorialProvider] 瞻仰次数已更新: $newViewCount');
      }
    } catch (e) {
      print('❌ [MemorialProvider] 瞻仰次数更新失败: $e');
    }
  }

  // 兼容旧方法名
  Future<bool> createMemorial(Memorial memorial) => addMemorial(memorial);
  Future<void> refresh() => loadMemorials();
}