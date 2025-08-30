import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memorial.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import '../theme/glassmorphism_theme.dart';
import 'create_heavenly_voice_page.dart';

class DigitalLifePage extends StatefulWidget {
  const DigitalLifePage({super.key});

  @override
  State<DigitalLifePage> createState() => _DigitalLifePageState();
}

class _DigitalLifePageState extends State<DigitalLifePage> {
  // 总览页面状态
  List<Map<String, dynamic>> _heavenlyVoices = [];

  @override
  void initState() {
    super.initState();
    // 加载已创建的天堂回音数据
    _loadHeavenlyVoices();
  }

  void _loadHeavenlyVoices() {
    // TODO: 从后端加载用户创建的天堂回音
    // 模拟数据 - 从SharedPreferences加载
    _loadHeavenlyVoicesFromLocal();
  }

  void _loadHeavenlyVoicesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final voicesJson = prefs.getStringList('heavenly_voices') ?? [];
    
    setState(() {
      _heavenlyVoices = voicesJson.map((jsonStr) {
        return Map<String, dynamic>.from(jsonDecode(jsonStr));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return _buildGuestView();
        }
        return _buildMainView();
      },
    );
  }
  
  Widget _buildGuestView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [GlassmorphismColors.primary.withValues(alpha: 0.6), GlassmorphismColors.secondary.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    '天堂之音',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: GlassmorphismDecorations.glassCard.copyWith(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '聆听来自天堂的温暖声音，感受永恒的爱与陪伴',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: GlassmorphismColors.textOnGlass,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '请先登录以使用此功能',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlassmorphismColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlassmorphismColors.warmAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            '去登录',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: SafeArea(
          child: _buildOverviewContent(),
        ),
      ),
    );
  }
  
  Widget _buildOverviewContent() {
    return CustomScrollView(
      slivers: [
        // 1. 天堂之音介绍 (始终显示)
        SliverToBoxAdapter(
          child: _buildHeavenlyVoiceIntroduction(),
        ),
        
        // 2. 已创建的回音列表
        _heavenlyVoices.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyVoicesState(),
              )
            : _buildVoicesList(),
            
        // 3. 创建回音按钮 (始终显示)
        SliverToBoxAdapter(
          child: _buildCreateVoiceButton(),
        ),
      ],
    );
  }

  // 1. 天堂之音介绍部分
  Widget _buildHeavenlyVoiceIntroduction() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和副标题
          Text(
            '天堂之音',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: GlassmorphismColors.textOnGlass,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '让逝去的挚爱用温暖的声音陪伴您',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          
          // 详细功能介绍卡片
          Container(
            padding: const EdgeInsets.all(24),
            decoration: GlassmorphismDecorations.glassCard.copyWith(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // 主要图标和标题
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlassmorphismColors.primary,
                        GlassmorphismColors.warmAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'AI重现挚爱声音',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GlassmorphismColors.textOnGlass,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 详细描述
                Text(
                  '天堂之音是一项革命性的AI技术，通过深度学习算法分析和重现逝者的声音特征。我们将他们的语音片段和文字记录转化为永恒的数字回音，让您能够重新听到那些熟悉而温暖的声音。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GlassmorphismColors.textOnGlass,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // 功能特点列表
                Column(
                  children: [
                    _buildFeatureHighlight(
                      Icons.mic,
                      '语音克隆技术',
                      '上传5-60秒的语音片段，AI学习声音特征',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureHighlight(
                      Icons.chat_bubble_outline,
                      '智能对话生成',
                      '基于文字记录生成个性化的温暖话语',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureHighlight(
                      Icons.favorite,
                      '情感陪伴',
                      '在思念时刻，聆听来自天堂的温暖声音',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 温馨提示
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GlassmorphismColors.warmAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GlassmorphismColors.warmAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: GlassmorphismColors.warmAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '建议上传多段不同情感的语音和丰富的文字记录，这样AI重现的声音会更加自然真实',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlassmorphismColors.textOnGlass,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. 空状态显示
  Widget _buildEmptyVoicesState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: GlassmorphismDecorations.glassCard.copyWith(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.record_voice_over_outlined,
              size: 64,
              color: GlassmorphismColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '还没有天堂回音',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: GlassmorphismColors.textOnGlass,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '创建您的第一个天堂回音，让AI重现挚爱的声音',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 功能特点高亮组件
  Widget _buildFeatureHighlight(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: GlassmorphismColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            icon,
            color: GlassmorphismColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: GlassmorphismColors.textOnGlass,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. 创建回音按钮
  Widget _buildCreateVoiceButton() {
    return Consumer<MemorialProvider>(
      builder: (context, memorialProvider, child) {
        final userMemorials = memorialProvider.memorials
            .where((m) => m.isOwnedBy(Provider.of<AuthProvider>(context, listen: false).currentUser?.id))
            .toList();
            
        return Padding(
          padding: const EdgeInsets.all(20),
          child: userMemorials.isNotEmpty
              ? ElevatedButton(
                  onPressed: _startCreateHeavenlyVoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassmorphismColors.warmAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _heavenlyVoices.isEmpty ? '创建第一个天堂回音' : '创建新的天堂回音',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: GlassmorphismDecorations.glassCard.copyWith(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: GlassmorphismColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '请先创建一个纪念页面，才能创建天堂回音',
                          style: TextStyle(
                            color: GlassmorphismColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyVoicesGuide() {
    return Consumer<MemorialProvider>(
      builder: (context, memorialProvider, child) {
        final userMemorials = memorialProvider.memorials
            .where((m) => m.isOwnedBy(Provider.of<AuthProvider>(context, listen: false).currentUser?.id))
            .toList();
            
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // 主要图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary.withValues(alpha: 0.6),
                      GlassmorphismColors.secondary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.record_voice_over,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                '创建您的第一个天堂回音',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GlassmorphismColors.textOnGlass,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: GlassmorphismDecorations.glassCard.copyWith(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '让逝去的挚爱用他们的声音与您对话，感受永恒的爱与陪伴。通过AI技术复现他们的温暖言语，让爱永远传递。',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: GlassmorphismColors.textOnGlass,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // 功能介绍
                    _buildFeatureItem(
                      Icons.person_outline,
                      '选择挚爱',
                      '从您的纪念中选择一位特别的人',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildFeatureItem(
                      Icons.graphic_eq,
                      '收集回音',
                      '上传他们的珍贵语音片段',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildFeatureItem(
                      Icons.chat_bubble_outline,
                      '温暖对话',
                      '与AI复现的声音进行对话',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    if (userMemorials.isNotEmpty)
                      ElevatedButton(
                        onPressed: _startCreateHeavenlyVoice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlassmorphismColors.warmAccent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                          shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '开始创建天堂回音',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: GlassmorphismColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GlassmorphismColors.info.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: GlassmorphismColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '请先创建一个纪念，再来制作天堂回音',
                                    style: TextStyle(
                                      color: GlassmorphismColors.info,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // 跳转到创建页面
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlassmorphismColors.primary,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              '去创建纪念',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: GlassmorphismColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: GlassmorphismColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: GlassmorphismColors.textOnGlass,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: GlassmorphismColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoicesList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final voice = _heavenlyVoices[index];
            return _buildVoiceCard(voice);
          },
          childCount: _heavenlyVoices.length,
        ),
      ),
    );
  }
  
  Widget _buildVoiceCard(Map<String, dynamic> voice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphismDecorations.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary,
                      GlassmorphismColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voice['memorialName'] ?? '天堂回音',
                      style: TextStyle(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建于 ${_formatDate(voice['createdAt'])}',
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: GlassmorphismColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChip(
                voice['status'] == 'created' ? '已创建' : '已训练', 
                voice['status'] == 'created' ? GlassmorphismColors.warmAccent : GlassmorphismColors.success
              ),
              const SizedBox(width: 12),
              if ((voice['audioCount'] ?? 0) > 0)
                _buildStatusChip('${voice['audioCount']}段音频', GlassmorphismColors.primary),
              if ((voice['audioCount'] ?? 0) > 0 && (voice['textCount'] ?? 0) > 0)
                const SizedBox(width: 12),
              if ((voice['textCount'] ?? 0) > 0)
                _buildStatusChip('${voice['textCount']}段文字', GlassmorphismColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  void _startCreateHeavenlyVoice() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHeavenlyVoicePage(),
      ),
    );
    
    // 如果创建成功，刷新列表
    if (result == true) {
      _loadHeavenlyVoices();
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '今天';
    
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return '今天';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${date.month}月${date.day}日';
      }
    } catch (e) {
      return '今天';
    }
  }
}