import '../models/memorial.dart';
import 'api_client.dart';

class MemorialService {
  final ApiClient _api = ApiClient();
  
  Future<List<Memorial>> getMemorials() async {
    print('🌐 [MemorialService] 正在调用 GET /memorials');
    final response = await _api.get('/memorials');
    print('📦 [MemorialService] 服务器响应: $response');
    final List<dynamic> data = response['data']['memorials'];
    print('📊 [MemorialService] 解析到 ${data.length} 条纪念数据');
    return data.map((json) => Memorial.fromJson(json)).toList();
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
    print('🌐 [MemorialService] 正在切换点赞状态: memorial_id=$memorialId');
    final response = await _api.post('/memorials/$memorialId/like');
    print('📦 [MemorialService] 点赞响应: $response');
    return response['data'];
  }
  
  Future<void> incrementViews(int memorialId) async {
    print('🌐 [MemorialService] 正在增加浏览次数: memorial_id=$memorialId');
    await _api.post('/memorials/$memorialId/view');
    print('✅ [MemorialService] 浏览次数已增加');
  }
  
  Future<Map<String, dynamic>> getMemorialStats(int memorialId) async {
    print('🌐 [MemorialService] 正在获取统计数据: memorial_id=$memorialId');
    final response = await _api.get('/memorials/$memorialId/stats');
    print('📦 [MemorialService] 统计响应: $response');
    return response['data'];
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
}