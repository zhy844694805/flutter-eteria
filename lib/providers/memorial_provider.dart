import 'package:flutter/foundation.dart';
import '../models/memorial.dart';
import '../models/filter_type.dart';
import '../services/memorial_service.dart';

class MemorialProvider extends ChangeNotifier {
  List<Memorial> _memorials = [];
  FilterType _currentFilter = FilterType.all;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<Memorial> get memorials => _memorials;
  FilterType get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取过滤后的纪念列表
  List<Memorial> get filteredMemorials {
    var filtered = _memorials.where((memorial) {
      final matchesFilter = _currentFilter == FilterType.all ||
          (_currentFilter == FilterType.person && memorial.type == MemorialType.person);
      
      final matchesSearch = _searchQuery.isEmpty ||
          memorial.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          memorial.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesFilter && matchesSearch;
    }).toList();
    
    // 按创建时间排序
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  // 初始化数据
  Future<void> initialize() async {
    await loadMemorials();
  }

  // 加载纪念数据
  Future<void> loadMemorials() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final service = await MemorialService.getInstance();
      await service.initializeMockData(); // 初始化模拟数据
      _memorials = await service.getMemorials();
      notifyListeners();
    } catch (e) {
      _setError('加载数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 添加纪念
  Future<bool> addMemorial(Memorial memorial) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final service = await MemorialService.getInstance();
      final success = await service.saveMemorial(memorial);
      
      if (success) {
        _memorials.add(memorial);
        notifyListeners();
        return true;
      } else {
        _setError('保存失败');
        return false;
      }
    } catch (e) {
      _setError('保存失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新纪念
  Future<bool> updateMemorial(Memorial memorial) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final service = await MemorialService.getInstance();
      final success = await service.updateMemorial(memorial);
      
      if (success) {
        final index = _memorials.indexWhere((m) => m.id == memorial.id);
        if (index != -1) {
          _memorials[index] = memorial;
          notifyListeners();
        }
        return true;
      } else {
        _setError('更新失败');
        return false;
      }
    } catch (e) {
      _setError('更新失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除纪念
  Future<bool> deleteMemorial(int id) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final service = await MemorialService.getInstance();
      final success = await service.deleteMemorial(id);
      
      if (success) {
        _memorials.removeWhere((memorial) => memorial.id == id);
        notifyListeners();
        return true;
      } else {
        _setError('删除失败');
        return false;
      }
    } catch (e) {
      _setError('删除失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 设置过滤器
  void setFilter(FilterType filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // 设置搜索查询
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 清除搜索
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadMemorials();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  // 生成新的ID
  int _generateNewId() {
    if (_memorials.isEmpty) return 1;
    return _memorials.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // 创建新纪念的便捷方法
  Memorial createMemorial({
    required MemorialType type,
    required String name,
    required DateTime birthDate,
    required DateTime deathDate,
    required String description,
    List<String>? imagePaths,
    List<String>? imageUrls,
    String? imagePath, // 向后兼容
    String? imageUrl,  // 向后兼容
    required bool isPublic,
  }) {
    // 处理向后兼容
    final finalImagePaths = <String>[];
    final finalImageUrls = <String>[];
    
    if (imagePaths != null) finalImagePaths.addAll(imagePaths);
    if (imageUrls != null) finalImageUrls.addAll(imageUrls);
    
    // 向后兼容单个图片
    if (imagePath != null && !finalImagePaths.contains(imagePath)) {
      finalImagePaths.add(imagePath);
    }
    if (imageUrl != null && !finalImageUrls.contains(imageUrl)) {
      finalImageUrls.add(imageUrl);
    }
    
    return Memorial(
      id: _generateNewId(),
      type: type,
      name: name,
      birthDate: birthDate,
      deathDate: deathDate,
      description: description,
      imagePaths: finalImagePaths,
      imageUrls: finalImageUrls,
      isPublic: isPublic,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}