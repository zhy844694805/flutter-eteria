import '../models/memorial.dart';
import 'api_client.dart';

class MemorialService {
  final ApiClient _api = ApiClient();
  
  Future<List<Memorial>> getMemorials() async {
    final response = await _api.get('/memorials');
    final List<dynamic> data = response['data']['memorials'];
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
}