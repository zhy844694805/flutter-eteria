import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // 模拟数据
    setState(() {
      _heavenlyVoices = [];
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
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ),
        
        // Content
        _heavenlyVoices.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyVoicesGuide(),
              )
            : _buildVoicesList(),
      ],
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
                      voice['name'] ?? '天堂回音',
                      style: TextStyle(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建于 ${voice['createdAt'] ?? '今天'}',
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
              _buildStatusChip('已训练', GlassmorphismColors.success),
              const SizedBox(width: 12),
              _buildStatusChip('${voice['voiceCount'] ?? 0}段回音', GlassmorphismColors.primary),
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
  
  void _startCreateHeavenlyVoice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHeavenlyVoicePage(),
      ),
    );
  }
}