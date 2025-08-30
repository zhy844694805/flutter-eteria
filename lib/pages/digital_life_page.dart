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

  // 1. 天堂之音介绍部分 - 干净大气的设计
  Widget _buildHeavenlyVoiceIntroduction() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          // 极简标题区域
          Column(
            children: [
              // 大气的图标设计
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary.withValues(alpha: 0.8),
                      GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Icon(
                  Icons.spatial_audio_off_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 简洁的标题
              Text(
                '天堂之音',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: GlassmorphismColors.textOnGlass,
                  letterSpacing: 2.0,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 精炼的副标题
              Text(
                'AI 重现挚爱声音，让思念有声相伴',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // 极简功能展示
          _buildMinimalFeatures(),
        ],
      ),
    );
  }

  // 极简功能展示
  Widget _buildMinimalFeatures() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMinimalFeature(
              Icons.mic_none_outlined,
              '录音训练',
              '上传语音',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: _buildMinimalFeature(
              Icons.psychology_outlined,
              'AI学习',
              '声音重现',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: _buildMinimalFeature(
              Icons.favorite_outline,
              '温暖陪伴',
              '永恒对话',
            ),
          ),
        ],
      ),
    );
  }

  // 极简功能项
  Widget _buildMinimalFeature(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: GlassmorphismColors.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: GlassmorphismColors.textOnGlass,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: GlassmorphismColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 2. 空状态显示 - 极简设计
  Widget _buildEmptyVoicesState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 极简图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: GlassmorphismColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(
              Icons.spatial_audio_off_outlined,
              size: 36,
              color: GlassmorphismColors.primary.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 简洁文字
          Text(
            '暂无天堂回音',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: GlassmorphismColors.textOnGlass.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '创建您的第一个声音记忆',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GlassmorphismColors.textSecondary,
            ),
          ),
        ],
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

  // 3. 创建回音按钮 - 大气简洁设计
  Widget _buildCreateVoiceButton() {
    return Consumer<MemorialProvider>(
      builder: (context, memorialProvider, child) {
        final userMemorials = memorialProvider.memorials
            .where((m) => m.isOwnedBy(Provider.of<AuthProvider>(context, listen: false).currentUser?.id))
            .toList();
            
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: userMemorials.isNotEmpty
              ? _buildCreateButton()
              : _buildRequirementHint(),
        );
      },
    );
  }

  // 大气的创建按钮
  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.primary,
            GlassmorphismColors.warmAccent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startCreateHeavenlyVoice,
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _heavenlyVoices.isEmpty ? '创建天堂回音' : '创建新回音',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 前置条件提示
  Widget _buildRequirementHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: GlassmorphismColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: GlassmorphismColors.warning.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: GlassmorphismColors.warning,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '请先创建纪念页面，才能开始制作天堂回音',
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final voice = _heavenlyVoices[index];
            return _buildModernVoiceCard(voice, index);
          },
          childCount: _heavenlyVoices.length,
        ),
      ),
    );
  }
  
  Widget _buildModernVoiceCard(Map<String, dynamic> voice, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index == _heavenlyVoices.length - 1 ? 0 : 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息行
          Row(
            children: [
              // 简洁的头像
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary.withValues(alpha: 0.8),
                      GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.spatial_audio_off_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 名称和时间
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
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(voice['createdAt']),
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 状态指示器
              _buildModernStatusIndicator(voice['status'] ?? 'created'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 内容统计 - 现代极简风格
          Row(
            children: [
              if ((voice['audioCount'] ?? 0) > 0) ...[
                _buildContentStat(
                  Icons.mic_none_outlined,
                  '${voice['audioCount']}',
                  '音频',
                ),
                const SizedBox(width: 24),
              ],
              if ((voice['textCount'] ?? 0) > 0) ...[
                _buildContentStat(
                  Icons.text_snippet_outlined,
                  '${voice['textCount']}',
                  '文本',
                ),
              ],
              if ((voice['audioCount'] ?? 0) == 0 && (voice['textCount'] ?? 0) == 0)
                Text(
                  '准备中...',
                  style: TextStyle(
                    color: GlassmorphismColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 现代状态指示器
  Widget _buildModernStatusIndicator(String status) {
    Color statusColor;
    
    switch (status) {
      case 'ready':
        statusColor = GlassmorphismColors.success;
        break;
      case 'training':
        statusColor = GlassmorphismColors.primary;
        break;
      default:
        statusColor = GlassmorphismColors.warmAccent;
    }
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // 内容统计项
  Widget _buildContentStat(IconData icon, String count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: GlassmorphismColors.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            color: GlassmorphismColors.textOnGlass,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
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