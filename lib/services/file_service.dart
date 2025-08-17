import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_client.dart';

class FileService {
  final ApiClient _api = ApiClient();
  
  /// 上传单个文件
  Future<Map<String, dynamic>> uploadSingleFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/files/upload-single'),
    );
    
    // 添加认证头
    if (_api.token != null) {
      request.headers['Authorization'] = 'Bearer ${_api.token}';
    }
    
    // 添加文件
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
    ));
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(responseBody);
      return data['data']['file'];
    } else {
      final error = json.decode(responseBody);
      throw Exception(error['error']['message'] ?? 'Upload failed');
    }
  }
  
  /// 上传多个文件
  Future<List<Map<String, dynamic>>> uploadFiles(List<File> files, {int? memorialId}) async {
    print('🌐 [FileService] Uploading ${files.length} files');
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/files/upload'),
    );
    
    // 添加认证头
    if (_api.token != null) {
      request.headers['Authorization'] = 'Bearer ${_api.token}';
      print('🔐 [FileService] Token added');
    } else {
      print('❌ [FileService] No token available');
    }
    
    // 添加纪念ID（如果提供）
    if (memorialId != null) {
      request.fields['memorial_id'] = memorialId.toString();
      print('📝 [FileService] Memorial ID: $memorialId');
    }
    
    // 添加文件
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      print('📎 [FileService] Adding file ${i + 1}: ${file.path}');
      
      // 根据文件扩展名确定MIME类型
      String? mimeType;
      final extension = file.path.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg'; // 默认为JPEG
      }
      
      print('🎯 [FileService] Detected MIME type: $mimeType for file: ${file.path}');
      
      // 简化：直接使用fromPath，让后端处理MIME类型验证
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: '${DateTime.now().millisecondsSinceEpoch}_${i + 1}.$extension',
      ));
    }
    
    print('🚀 [FileService] Sending upload request to ${request.url}');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    print('📨 [FileService] Status: ${response.statusCode}');
    print('📨 [FileService] Response: $responseBody');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = json.decode(responseBody);
        final files = data['data']['files'] as List;
        return List<Map<String, dynamic>>.from(files);
      } catch (e) {
        print('❌ [FileService] Failed to parse response: $e');
        print('Response body: $responseBody');
        throw Exception('Failed to parse upload response: $e');
      }
    } else {
      try {
        final error = json.decode(responseBody);
        final errorMessage = error['error']['message'] ?? 'Upload failed';
        print('❌ [FileService] Upload failed: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        print('❌ [FileService] Failed to parse error response: $e');
        print('Raw response: $responseBody');
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    }
  }
  
  /// 删除文件
  Future<void> deleteFile(int fileId) async {
    await _api.delete('/files/$fileId');
  }
}