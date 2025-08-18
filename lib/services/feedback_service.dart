import 'api_client.dart';

enum FeedbackType {
  bug,
  suggestion,
  complaint,
  praise,
  other,
}

class FeedbackService {
  final ApiClient _api = ApiClient();

  Future<void> submitFeedback({
    required FeedbackType type,
    required String title,
    required String content,
    required String contact,
  }) async {
    print('🌐 [FeedbackService] 提交反馈：$title');
    
    final response = await _api.post('/feedback', body: {
      'type': _feedbackTypeToString(type),
      'title': title,
      'content': content,
      'contact': contact,
    });
    
    print('✅ [FeedbackService] 反馈提交成功');
    return response['data'];
  }

  Future<List<Map<String, dynamic>>> getUserFeedbacks({
    int page = 1,
    int limit = 20,
  }) async {
    print('🌐 [FeedbackService] 获取用户反馈历史');
    
    final response = await _api.get('/feedback/my?page=$page&limit=$limit');
    final List<dynamic> data = response['data']['feedbacks'];
    
    print('📦 [FeedbackService] 获取到 ${data.length} 条反馈记录');
    return data.cast<Map<String, dynamic>>();
  }

  String _feedbackTypeToString(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.suggestion:
        return 'suggestion';
      case FeedbackType.complaint:
        return 'complaint';
      case FeedbackType.praise:
        return 'praise';
      case FeedbackType.other:
        return 'other';
    }
  }

  FeedbackType _stringToFeedbackType(String typeString) {
    switch (typeString) {
      case 'bug':
        return FeedbackType.bug;
      case 'suggestion':
        return FeedbackType.suggestion;
      case 'complaint':
        return FeedbackType.complaint;
      case 'praise':
        return FeedbackType.praise;
      case 'other':
      default:
        return FeedbackType.other;
    }
  }
}