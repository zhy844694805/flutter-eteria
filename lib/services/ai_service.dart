import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

/// AI聊天消息模型
class ChatMessage {
  final String id;
  final String content;
  final String role; // 'user' 或 'assistant'
  final DateTime timestamp;
  final String? speaker; // 对于天堂之音，记录说话人
  final String? relationship; // 关系
  final bool canPlayVoice; // 是否可以播放语音
  final bool hasAudio; // 是否有音频文件
  final String? audioUrl; // 音频URL

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.speaker,
    this.relationship,
    this.canPlayVoice = false,
    this.hasAudio = false,
    this.audioUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['message'] ?? json['content'] ?? '',
      role: json['role'] ?? 'assistant',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      speaker: json['speaker'],
      relationship: json['relationship'],
      canPlayVoice: json['canPlayVoice'] ?? false,
      hasAudio: json['hasAudio'] ?? false,
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'speaker': speaker,
      'relationship': relationship,
      'canPlayVoice': canPlayVoice,
      'hasAudio': hasAudio,
      'audioUrl': audioUrl,
    };
  }

  /// 创建用户消息
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'user',
      timestamp: DateTime.now(),
    );
  }

  /// 创建AI助手消息
  factory ChatMessage.assistant(
    String content, {
    String? speaker, 
    String? relationship, 
    bool canPlayVoice = false,
    bool hasAudio = false,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'assistant',
      timestamp: DateTime.now(),
      speaker: speaker,
      relationship: relationship,
      canPlayVoice: canPlayVoice,
      hasAudio: hasAudio,
      audioUrl: audioUrl,
    );
  }
}

/// AI服务状态
class AIServiceStatus {
  final bool configured;
  final bool healthy;
  final String model;
  final String? baseURL;
  final DateTime timestamp;
  final bool ttsConfigured; // TTS服务是否配置
  final bool ttsHealthy; // TTS服务是否健康
  final String? ttsServiceUrl; // TTS服务URL

  AIServiceStatus({
    required this.configured,
    required this.healthy,
    required this.model,
    this.baseURL,
    required this.timestamp,
    this.ttsConfigured = false,
    this.ttsHealthy = false,
    this.ttsServiceUrl,
  });

  factory AIServiceStatus.fromJson(Map<String, dynamic> json) {
    return AIServiceStatus(
      configured: json['configured'] ?? false,
      healthy: json['healthy'] ?? false,
      model: json['model'] ?? 'unknown',
      baseURL: json['baseURL'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      ttsConfigured: json['ttsConfigured'] ?? false,
      ttsHealthy: json['ttsHealthy'] ?? false,
      ttsServiceUrl: json['ttsServiceUrl'],
    );
  }
}

/// AI服务类
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final ApiClient _apiClient = ApiClient();
  bool _isServiceAvailable = false;
  AIServiceStatus? _status;

  /// 获取AI服务状态
  Future<AIServiceStatus?> getServiceStatus() async {
    try {
      print('🤖 [AIService] Checking service status...');
      
      final response = await _apiClient.get('/ai/status');
      
      if (response['success'] == true && response['data'] != null) {
        _status = AIServiceStatus.fromJson(response['data']);
        _isServiceAvailable = _status!.configured && _status!.healthy;
        
        print('✅ [AIService] Status: configured=${_status!.configured}, healthy=${_status!.healthy}');
        return _status;
      }
    } catch (e) {
      print('❌ [AIService] Failed to get service status: $e');
      _isServiceAvailable = false;
    }
    return null;
  }

  /// 检查AI服务是否可用
  bool get isServiceAvailable => _isServiceAvailable;

  /// 检查TTS服务是否可用
  bool get isTTSServiceAvailable => _status?.ttsConfigured == true && _status?.ttsHealthy == true;

  /// 获取当前状态
  AIServiceStatus? get currentStatus => _status;

  /// 通用AI对话
  Future<ChatMessage?> chat({
    required String message,
    List<ChatMessage>? context,
    Map<String, dynamic>? options,
  }) async {
    try {
      print('🤖 [AIService] Sending chat message: "${message.substring(0, 50)}..."');
      
      // 构建请求体
      final requestBody = {
        'message': message,
        'context': context?.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }).toList() ?? [],
        'options': options ?? {},
      };

      final response = await _apiClient.post('/ai/chat', body: requestBody);
      
      if (response['success'] == true && response['data'] != null) {
        final aiMessage = ChatMessage.fromJson(response['data']);
        print('✅ [AIService] Received AI response: "${aiMessage.content.substring(0, 50)}..."');
        return aiMessage;
      } else {
        print('❌ [AIService] Chat request failed: ${response['error']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ [AIService] Chat error: $e');
      return ChatMessage.assistant(
        '抱歉，AI服务暂时不可用。请稍后再试。',
      );
    }
  }

  /// 生成纪念内容
  Future<String?> generateMemorialContent({
    required Map<String, dynamic> memorial,
    String type = 'eulogy', // 'eulogy', 'poem', 'memory'
  }) async {
    try {
      print('📝 [AIService] Generating memorial content: $type for ${memorial['name']}');
      
      final response = await _apiClient.post('/ai/memorial-content', body: {
        'memorial': memorial,
        'type': type,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final content = response['data']['content'];
        print('✅ [AIService] Memorial content generated successfully');
        return content;
      } else {
        print('❌ [AIService] Memorial content generation failed: ${response['error']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ [AIService] Memorial content generation error: $e');
      return null;
    }
  }

  /// 天堂之音对话
  Future<ChatMessage?> heavenlyVoiceChat({
    required String message,
    required Map<String, dynamic> voiceProfile,
    List<ChatMessage>? conversationHistory,
  }) async {
    try {
      print('👻 [AIService] Heavenly voice chat with ${voiceProfile['memorialName']}');
      
      final response = await _apiClient.post('/ai/heavenly-voice', body: {
        'message': message,
        'voiceProfile': voiceProfile,
        'conversationHistory': conversationHistory?.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }).toList() ?? [],
      });
      
      if (response['success'] == true && response['data'] != null) {
        final aiMessage = ChatMessage.fromJson(response['data']);
        print('✅ [AIService] Heavenly voice response received');
        return aiMessage;
      } else {
        print('❌ [AIService] Heavenly voice chat failed: ${response['error']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ [AIService] Heavenly voice chat error: $e');
      return ChatMessage.assistant(
        '抱歉，我现在无法回应。请稍后再试。',
        speaker: voiceProfile['memorialName'],
        relationship: voiceProfile['relationship'],
      );
    }
  }

  /// 天堂之音对话（带语音合成）
  Future<ChatMessage?> heavenlyVoiceChatWithAudio({
    required String message,
    required Map<String, dynamic> voiceProfile,
    List<ChatMessage>? conversationHistory,
    bool generateVoice = true,
  }) async {
    try {
      print('👻🎵 [AIService] Heavenly voice chat with audio for ${voiceProfile['memorialName']}');
      
      final response = await _apiClient.post('/ai/heavenly-voice-with-audio', body: {
        'message': message,
        'voiceProfile': voiceProfile,
        'conversationHistory': conversationHistory?.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }).toList() ?? [],
        'generateVoice': generateVoice,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final aiMessage = ChatMessage.fromJson(response['data']);
        print('✅ [AIService] Heavenly voice with audio response received');
        if (aiMessage.hasAudio) {
          print('🎵 [AIService] Audio available at: ${aiMessage.audioUrl}');
        }
        return aiMessage;
      } else {
        print('❌ [AIService] Heavenly voice with audio chat failed: ${response['error']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ [AIService] Heavenly voice with audio chat error: $e');
      return ChatMessage.assistant(
        '抱歉，我现在无法回应。请稍后再试。',
        speaker: voiceProfile['memorialName'],
        relationship: voiceProfile['relationship'],
      );
    }
  }

  /// 语音合成
  Future<String?> synthesizeVoice({
    required String text,
    List<String>? audioPaths,
    String? voiceId,
  }) async {
    try {
      print('🎵 [AIService] Synthesizing voice for text: "${text.substring(0, 50)}..."');
      
      final response = await _apiClient.post('/ai/synthesize-voice', 
        body: {
          'text': text,
          'audioPaths': audioPaths ?? [],
          'voiceId': voiceId,
        },
      );
      
      // 语音合成返回的是JSON响应，不是直接的字节数据
      // 实际的音频URL会在heavenly-voice-with-audio端点中处理
      print('✅ [AIService] Voice synthesis request sent');
      return null; // 这个方法当前不用于直接语音合成
    } catch (e) {
      print('❌ [AIService] Voice synthesis error: $e');
      return null;
    }
  }

  /// 生成对话建议
  Future<List<String>?> generateSuggestions({
    required String context,
    String type = 'questions', // 'questions', 'topics', 'responses'
  }) async {
    try {
      print('💡 [AIService] Generating suggestions: $type');
      
      final response = await _apiClient.post('/ai/generate-suggestions', body: {
        'context': context,
        'type': type,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final suggestions = List<String>.from(response['data']['suggestions'] ?? []);
        print('✅ [AIService] Generated ${suggestions.length} suggestions');
        return suggestions;
      } else {
        print('❌ [AIService] Suggestion generation failed: ${response['error']?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ [AIService] Suggestion generation error: $e');
      return null;
    }
  }

  /// 初始化AI服务
  Future<void> initialize() async {
    print('🚀 [AIService] Initializing AI service...');
    await getServiceStatus();
    
    if (_isServiceAvailable) {
      print('✅ [AIService] AI service is ready');
    } else {
      print('⚠️  [AIService] AI service not available');
    }
  }

  /// 获取错误回退消息
  String getErrorFallbackMessage(String context) {
    switch (context) {
      case 'heavenly_voice':
        return '我现在有些疲倦，请稍后再和我聊天吧。';
      case 'memorial_content':
        return '抱歉，我现在无法帮您创作内容，请稍后再试。';
      case 'chat':
      default:
        return '我现在有些困难理解您的问题，请换个方式表达或稍后再试。';
    }
  }
}