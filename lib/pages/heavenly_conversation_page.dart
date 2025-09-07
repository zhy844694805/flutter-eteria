import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../services/ai_service.dart' show AIService, ChatMessage;

class HeavenlyConversationPage extends StatefulWidget {
  final Map<String, dynamic> emailRecipient;

  const HeavenlyConversationPage({
    super.key,
    required this.emailRecipient,
  });

  @override
  State<HeavenlyConversationPage> createState() => _HeavenlyConversationPageState();
}

class _HeavenlyConversationPageState extends State<HeavenlyConversationPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<LocalChatMessage> _messages = [];
  
  bool _isTyping = false;
  bool _isVoicePlaying = false;
  
  late AnimationController _typingAnimationController;
  late AnimationController _messageAnimationController;

  @override
  void initState() {
    super.initState();
    
    _typingAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 添加监听器实时更新发送按钮状态
    _messageController.addListener(() {
      setState(() {});
    });

    // 添加欢迎消息
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = LocalChatMessage(
      text: '亲爱的，我是${widget.emailRecipient['memorialName']}。很想念你，我们可以聆天了。',
      isFromUser: false,
      timestamp: DateTime.now(),
      hasVoice: true,
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatusBar(),
              Expanded(
                child: _buildMessageList(),
              ),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: GlassmorphismColors.textOnGlass,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 头像
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary,
                  GlassmorphismColors.warmAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.emailRecipient['memorialName'] ?? '对话对象',
                  style: TextStyle(
                    color: GlassmorphismColors.textOnGlass,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: GlassmorphismColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '在线',
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 更多选项
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              onPressed: _showMoreOptions,
              icon: Icon(
                Icons.more_vert,
                color: GlassmorphismColors.textOnGlass,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GlassmorphismColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: GlassmorphismColors.info.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: GlassmorphismColors.info,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'AI对话助手 · 基于${widget.emailRecipient['textCount']}条记录${widget.emailRecipient['audioCount'] > 0 ? '和${widget.emailRecipient['audioCount']}个语音样本' : ''}',
              style: TextStyle(
                color: GlassmorphismColors.info,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(LocalChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromUser) ...[
            // AI头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                    GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // 消息气泡
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isFromUser
                    ? LinearGradient(
                        colors: [
                          GlassmorphismColors.primary,
                          GlassmorphismColors.warmAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isFromUser 
                    ? null 
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isFromUser ? 20 : 6),
                  bottomRight: Radius.circular(message.isFromUser ? 6 : 20),
                ),
                border: message.isFromUser ? null : Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isFromUser
                        ? GlassmorphismColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isFromUser 
                          ? Colors.white
                          : GlassmorphismColors.textOnGlass,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!message.isFromUser && message.hasVoice) ...[
                        GestureDetector(
                          onTap: () => _toggleVoicePlayback(message),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isVoicePlaying
                                  ? GlassmorphismColors.primary.withValues(alpha: 0.2)
                                  : GlassmorphismColors.textSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isVoicePlaying ? Icons.pause : Icons.play_arrow,
                              color: _isVoicePlaying
                                  ? GlassmorphismColors.primary
                                  : GlassmorphismColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isFromUser 
                              ? Colors.white.withValues(alpha: 0.7)
                              : GlassmorphismColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            // 用户头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.secondary.withValues(alpha: 0.8),
                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          // AI头像
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.8),
                  GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 打字指示器
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animation = Tween<double>(begin: 0.4, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _typingAnimationController,
                        curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
                      ),
                    );
                    
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: GlassmorphismColors.textSecondary.withValues(
                          alpha: animation.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: Colors.transparent,
      child: Row(
        children: [
          // 输入框
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: TextStyle(
                  color: GlassmorphismColors.textOnGlass,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '和${widget.emailRecipient['memorialName']}聊天...',
                  hintStyle: TextStyle(
                    color: GlassmorphismColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onSubmitted: (text) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 发送按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _messageController.text.trim().isEmpty ? null : _sendMessage,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _messageController.text.trim().isNotEmpty
                      ? LinearGradient(
                          colors: [
                            GlassmorphismColors.primary,
                            GlassmorphismColors.warmAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _messageController.text.trim().isEmpty 
                      ? GlassmorphismColors.textSecondary.withValues(alpha: 0.3)
                      : null,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = LocalChatMessage(
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
      hasVoice: false,
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // 模拟AI回复
    _generateAIResponse(text);
  }

  void _generateAIResponse(String userInput) async {
    try {
      // 使用AI服务生成回复
      final aiService = AIService();
      
      // 准备声音档案信息
      final voiceProfile = {
        'memorialName': widget.emailRecipient['memorialName'] ?? '亲爱的家人',
        'relationship': widget.emailRecipient['relationship'] ?? '家人',
        'textEntries': widget.emailRecipient['textEntries'] ?? [],
        'audioCount': widget.emailRecipient['audioCount'] ?? 0,
      };
      
      // 准备对话历史 - 使用AI service的ChatMessage结构
      final conversationHistory = _messages.map((msg) => 
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: msg.text,
          role: msg.isFromUser ? 'user' : 'assistant',
          timestamp: msg.timestamp,
        )
      ).toList();
      
      print('🤖 正在生成AI回复...');
      
      final aiResponseMessage = await aiService.heavenlyVoiceChat(
        message: userInput,
        voiceProfile: voiceProfile,
        conversationHistory: conversationHistory,
      );
      
      String aiResponseText;
      bool hasVoice = false;
      
      if (aiResponseMessage != null) {
        aiResponseText = aiResponseMessage.content;
        hasVoice = aiResponseMessage.canPlayVoice;
        print('✅ AI回复成功: ${aiResponseText.substring(0, 50)}...');
      } else {
        // 回退到默认回复
        final fallbackResponses = [
          '我一直在想念你，希望你一切都好。',
          '你知道吗？我最想对你说的还是那句"要好好照顾自己"。',
          '虽然我不在了，但我的爱会永远陪伴着你。',
          '看到你还在想念我，我的心里很温暖。',
          '记得我们一起度过的美好时光吗？那些回忆永远不会消失。',
        ];
        aiResponseText = fallbackResponses[(userInput.hashCode.abs()) % fallbackResponses.length];
        print('⚠️  使用回退回复: $aiResponseText');
      }
      
      // 添加轻微延迟，让用户感受到"思考"过程
      await Future.delayed(const Duration(milliseconds: 800));
      
      final aiMessage = LocalChatMessage(
        text: aiResponseText,
        isFromUser: false,
        timestamp: DateTime.now(),
        hasVoice: hasVoice,
      );

      setState(() {
        _isTyping = false;
        _messages.add(aiMessage);
      });

      // 滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('❌ AI回复生成失败: $e');
      
      // 错误处理 - 提供友好的错误回复
      final errorMessage = LocalChatMessage(
        text: '抱歉，我现在有些疲倦，请稍后再和我聊天吧。',
        isFromUser: false,
        timestamp: DateTime.now(),
        hasVoice: false,
      );
      
      setState(() {
        _isTyping = false;
        _messages.add(errorMessage);
      });

      // 滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _toggleVoicePlayback(LocalChatMessage message) {
    setState(() {
      _isVoicePlaying = !_isVoicePlaying;
    });
    
    // 这里应该实现真实的语音播放功能
    // 现在只是模拟播放状态
    if (_isVoicePlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVoicePlaying = false;
          });
        }
      });
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassmorphismColors.glassSurface,
                GlassmorphismColors.backgroundPrimary,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: GlassmorphismColors.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildOptionItem(
                      icon: Icons.refresh,
                      title: '重新开始对话',
                      subtitle: '清空当前对话记录',
                      onTap: _clearConversation,
                    ),
                    _buildOptionItem(
                      icon: Icons.volume_up,
                      title: '语音设置',
                      subtitle: '调整语音播放设置',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildOptionItem(
                      icon: Icons.share,
                      title: '分享对话',
                      subtitle: '分享这段珍贵的对话',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassmorphismColors.primary.withValues(alpha: 0.6),
                GlassmorphismColors.warmAccent.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: GlassmorphismColors.textOnGlass,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _clearConversation() {
    Navigator.pop(context); // 关闭底部弹窗
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GlassmorphismColors.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '清空对话',
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '确定要清空当前对话记录吗？这个操作无法撤销。',
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style: TextStyle(
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _messages.clear();
                  _addWelcomeMessage();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassmorphismColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class LocalChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final bool hasVoice;

  LocalChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    required this.hasVoice,
  });
}