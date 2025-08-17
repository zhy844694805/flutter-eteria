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
    _isLoading = true;
    notifyListeners();
    
    try {
      _memorials = await _service.getMemorials();
    } catch (e) {
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

  // 兼容旧方法名
  Future<bool> createMemorial(Memorial memorial) => addMemorial(memorial);
  Future<void> refresh() => loadMemorials();
}