import '../models/memorial.dart';
import 'api_client.dart';

class MemorialService {
  final ApiClient _api = ApiClient();
  
  Future<List<Memorial>> getMemorials({int page = 1, int limit = 50}) async {
    print('🌐 [MemorialService] 正在调用 GET /memorials (page=$page, limit=$limit)');
    final response = await _api.get('/memorials?page=$page&limit=$limit');
    print('📦 [MemorialService] 服务器响应: $response');
    final List<dynamic> data = response['data']['memorials'];
    final pagination = response['data']['pagination'];
    print('📊 [MemorialService] 解析到 ${data.length} 条纪念数据，总计 ${pagination['total']} 条');
    return data.map((json) => Memorial.fromJson(json)).toList();
  }
  
  /// 获取公开的纪念内容（游客模式）
  Future<List<Memorial>> getPublicMemorials({int page = 1, int limit = 50}) async {
    print('🌐 [MemorialService] 正在调用 GET /memorials/public (page=$page, limit=$limit)');
    try {
      final response = await _api.get('/memorials/public?page=$page&limit=$limit');
      print('📦 [MemorialService] 公开数据服务器响应: $response');
      final List<dynamic> data = response['data']['memorials'];
      final pagination = response['data']['pagination'];
      print('📊 [MemorialService] 解析到 ${data.length} 条公开纪念数据，总计 ${pagination['total']} 条');
      return data.map((json) => Memorial.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ [MemorialService] 公开纪念数据接口不存在，使用普通接口: $e');
      // 如果后端没有专门的公开接口，使用普通接口获取所有数据
      // 这里可以在前端过滤出公开的纪念内容
      final response = await _api.get('/memorials?page=$page&limit=$limit');
      final List<dynamic> data = response['data']['memorials'];
      final allMemorials = data.map((json) => Memorial.fromJson(json)).toList();
      // 过滤出公开的纪念内容
      final publicMemorials = allMemorials.where((memorial) => memorial.isPublic).toList();
      print('📊 [MemorialService] 过滤后的公开纪念数据: ${publicMemorials.length} 条');
      return publicMemorials;
    }
  }
  
  Future<Memorial> saveMemorial(Memorial memorial) async {
    final response = await _api.post('/memorials', body: memorial.toCreateJson());
    return Memorial.fromJson(response['data']['memorial']);
  }
  
  Future<Memorial> updateMemorial(Memorial memorial) async {
    final response = await _api.put('/memorials/${memorial.id}', body: memorial.toJson());
    return Memorial.fromJson(response['data']['memorial']);
  }
  
  Future<void> deleteMemorial(int id) async {
    await _api.delete('/memorials/$id');
  }
  
  Future<Memorial> getMemorialById(int id) async {
    final response = await _api.get('/memorials/$id');
    return Memorial.fromJson(response['data']['memorial']);
  }
  
  Future<Map<String, dynamic>> toggleLike(int memorialId) async {
    print('🌐 [MemorialService] 正在切换献花状态: memorial_id=$memorialId');
    final response = await _api.post('/memorials/$memorialId/like');
    print('📦 [MemorialService] 献花响应: $response');
    return response['data'];
  }
  
  Future<void> incrementViews(int memorialId) async {
    print('🌐 [MemorialService] 正在增加瞻仰次数: memorial_id=$memorialId');
    await _api.post('/memorials/$memorialId/view');
    print('✅ [MemorialService] 瞻仰次数已增加');
  }
  
  Future<Map<String, dynamic>> getMemorialStats(int memorialId) async {
    print('🌐 [MemorialService] 正在获取统计数据: memorial_id=$memorialId');
    final response = await _api.get('/memorials/$memorialId/stats');
    print('📦 [MemorialService] 统计响应: $response');
    return response['data']['stats']; // 修复：返回实际的stats数据
  }
  
  Future<List<dynamic>> getComments(int memorialId, {int page = 1, int limit = 20}) async {
    final response = await _api.get('/memorials/$memorialId/comments?page=$page&limit=$limit');
    return response['data']['comments'];
  }
  
  Future<Map<String, dynamic>> addComment(int memorialId, String content) async {
    final response = await _api.post('/memorials/$memorialId/comments', body: {
      'content': content,
    });
    return response['data']['comment'];
  }
  
  Future<Map<String, dynamic>> toggleFavorite(int memorialId) async {
    print('🌐 [MemorialService] 正在切换收藏状态: memorial_id=$memorialId');
    final response = await _api.post('/memorials/$memorialId/favorite');
    print('📦 [MemorialService] 收藏响应: $response');
    return response['data'];
  }
  
  Future<Map<String, dynamic>> getUserFavorites({int page = 1, int limit = 10}) async {
    print('🌐 [MemorialService] 正在获取用户收藏: page=$page, limit=$limit');
    final response = await _api.get('/memorials/user/favorites?page=$page&limit=$limit');
    print('📦 [MemorialService] 收藏列表响应: $response');
    return response['data'];
  }
  
  Future<Map<String, dynamic>> getUserComments({int page = 1, int limit = 10}) async {
    print('🌐 [MemorialService] 正在获取用户评论: page=$page, limit=$limit');
    final response = await _api.get('/memorials/user/comments?page=$page&limit=$limit');
    print('📦 [MemorialService] 评论列表响应: $response');
    return response['data'];
  }
}