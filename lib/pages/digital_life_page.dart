import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memorial.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import '../theme/glassmorphism_theme.dart';
import 'create_heavenly_voice_page.dart';
import 'edit_heavenly_voice_page.dart';
import 'heavenly_conversation_page.dart';

class DigitalLifePage extends StatefulWidget {
  const DigitalLifePage({super.key});

  @override
  State<DigitalLifePage> createState() => _DigitalLifePageState();
}

class _DigitalLifePageState extends State<DigitalLifePage> {
  // 总览页面状态
  List<Map<String, dynamic>> _emailRecipients = [];

  @override
  void initState() {
    super.initState();
    // 加载已创建的邮件收信人数据
    _loadEmailRecipients();
  }

  void _loadEmailRecipients() {
    // TODO: 从后端加载用户创建的邮件收信人
    // 模拟数据 - 从SharedPreferences加载
    _loadEmailRecipientsFromLocal();
  }

  void _loadEmailRecipientsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final recipientsJson = prefs.getStringList('email_recipients') ?? [];
    
    setState(() {
      _emailRecipients = recipientsJson.map((jsonStr) {
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
                      Icons.email,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    '天堂邮箱',
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
                          '接收来自天堂的温暖邮件，感受永恒的爱与陪伴',
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
        _emailRecipients.isEmpty
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
                  Icons.inbox,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 简洁的标题
              Text(
                '天堂邮箱',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: GlassmorphismColors.textOnGlass,
                  letterSpacing: 2.0,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 精炼的副标题
              Text(
                'AI 重现挚爱话语，让思念有邮相伴',
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
              Icons.record_voice_over_outlined,
              '语音邮件',
              '收集声音',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: _buildMinimalFeature(
              Icons.smart_toy_outlined,
              'AI回复',
              '智能邮件',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Expanded(
            child: _buildMinimalFeature(
              Icons.mail_outline,
              '温暖邮件',
              '永恒通信',
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
              Icons.inbox_outlined,
              size: 36,
              color: GlassmorphismColors.primary.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 简洁文字
          Text(
            '暂无对话对象',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: GlassmorphismColors.textOnGlass.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '添加您的第一个对话对象',
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
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _emailRecipients.isEmpty ? '添加对话对象' : '添加另一个对象',
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
              '请先创建纪念页面，才能添加对话对象',
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
    // 如果只有一个回音，使用特殊的单个回音展示
    if (_emailRecipients.length == 1) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child: _buildFeaturedVoiceCard(_emailRecipients[0]),
        ),
      );
    }
    
    // 多个回音时使用原来的列表展示
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final voice = _emailRecipients[index];
            return _buildModernVoiceCard(voice, index);
          },
          childCount: _emailRecipients.length,
        ),
      ),
    );
  }

  // 特色单个回音卡片 - 突出显示主要回音
  Widget _buildFeaturedVoiceCard(Map<String, dynamic> voice) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.primary.withValues(alpha: 0.08),
            GlassmorphismColors.warmAccent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: GlassmorphismColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GlassmorphismColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部区域 - 更大的头像和信息
          Row(
            children: [
              // 大型头像
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary,
                      GlassmorphismColors.warmAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.email,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // 主要信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voice['memorialName'] ?? '对话对象',
                      style: TextStyle(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voice['relationship'] ?? '',
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '创建于 ${_formatDate(voice['createdAt'])}',
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // 内容统计区域 - 更加突出
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                if ((voice['audioCount'] ?? 0) > 0) ...[
                  Expanded(
                    child: _buildFeaturedContentStat(
                      Icons.mic_none_outlined,
                      '${voice['audioCount']}',
                      '音频文件',
                      GlassmorphismColors.primary,
                    ),
                  ),
                ],
                if ((voice['audioCount'] ?? 0) > 0 && (voice['textCount'] ?? 0) > 0)
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                if ((voice['textCount'] ?? 0) > 0) ...[
                  Expanded(
                    child: _buildFeaturedContentStat(
                      Icons.format_quote_rounded,
                      '${voice['textCount']}',
                      '文字记录',
                      GlassmorphismColors.warmAccent,
                    ),
                  ),
                ],
                if ((voice['audioCount'] ?? 0) == 0 && (voice['textCount'] ?? 0) == 0)
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            color: GlassmorphismColors.textSecondary.withValues(alpha: 0.6),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '准备中...',
                            style: TextStyle(
                              color: GlassmorphismColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 操作按钮区域
          _buildFeaturedActionButtons(voice),
        ],
      ),
    );
  }

  // 特色状态指示器
  Widget _buildFeaturedStatusIndicator(String status) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'ready':
        statusColor = GlassmorphismColors.success;
        statusText = '已就绪';
        break;
      case 'training':
        statusColor = GlassmorphismColors.primary;
        statusText = '训练中';
        break;
      default:
        statusColor = GlassmorphismColors.warmAccent;
        statusText = '已创建';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 特色内容统计项
  Widget _buildFeaturedContentStat(IconData icon, String count, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          count,
          style: TextStyle(
            color: GlassmorphismColors.textOnGlass,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 特色操作按钮
  Widget _buildFeaturedActionButtons(Map<String, dynamic> voice) {
    return Row(
      children: [
        // 开始对话按钮
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary,
                  GlassmorphismColors.warmAccent,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _startConversation(voice),
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '发送邮件',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 编辑按钮
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('编辑按钮点击测试'); // 调试信息
                _editVoice(voice);
              },
              borderRadius: BorderRadius.circular(28),
              child: Icon(
                Icons.edit_outlined,
                color: GlassmorphismColors.textOnGlass,
                size: 24,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 删除按钮
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _deleteVoice(voice),
              borderRadius: BorderRadius.circular(28),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernVoiceCard(Map<String, dynamic> voice, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index == _emailRecipients.length - 1 ? 0 : 24),
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
                  Icons.email_outlined,
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
                      voice['memorialName'] ?? '对话对象',
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
              
              // 删除按钮
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _deleteVoice(voice),
                    borderRadius: BorderRadius.circular(16),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ),
                ),
              ),
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
      _loadEmailRecipients();
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

  // 开始对话功能（占位符）
  void _startConversation(Map<String, dynamic> voice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HeavenlyConversationPage(emailRecipient: voice),
      ),
    );
  }

  // 编辑回音功能
  void _editVoice(Map<String, dynamic> voice) async {
    print('编辑按钮被点击了: ${voice['memorialName']}'); // 调试信息
    
    // 暂时显示一个简单的对话框来测试
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GlassmorphismColors.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '编辑功能测试',
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '编辑按钮成功点击！\n回音名称：${voice['memorialName']}',
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '关闭',
                style: TextStyle(
                  color: GlassmorphismColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 尝试导航到编辑页面
                try {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditHeavenlyVoicePage(voice: voice),
                    ),
                  );
                  
                  print('编辑页面返回结果: $result'); // 调试信息
                  
                  // 如果编辑成功，刷新列表
                  if (result == true) {
                    _loadEmailRecipients();
                  }
                } catch (e) {
                  print('编辑页面导航错误: $e'); // 调试信息
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('打开编辑页面失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                '打开编辑页面',
                style: TextStyle(
                  color: GlassmorphismColors.warmAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 删除回音功能
  void _deleteVoice(Map<String, dynamic> voice) async {
    // 显示确认对话框
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GlassmorphismColors.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '删除对话对象',
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '确定要删除对话对象「${voice['memorialName']}」吗？此操作无法撤销。',
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '取消',
                style: TextStyle(
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '删除',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _performDeleteVoice(voice);
    }
  }

  // 执行删除操作
  Future<void> _performDeleteVoice(Map<String, dynamic> voice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipientsJson = prefs.getStringList('email_recipients') ?? [];
      
      // 找到要删除的收信人并移除
      recipientsJson.removeWhere((jsonStr) {
        final recipientData = Map<String, dynamic>.from(jsonDecode(jsonStr));
        return recipientData['id'] == voice['id'];
      });
      
      // 保存更新后的列表
      await prefs.setStringList('email_recipients', recipientsJson);
      
      // 更新UI
      setState(() {
        _emailRecipients.removeWhere((v) => v['id'] == voice['id']);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除对话对象「${voice['memorialName']}」'),
            backgroundColor: GlassmorphismColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}