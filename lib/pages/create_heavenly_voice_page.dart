import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/memorial.dart';
import '../providers/auth_provider.dart';
import '../providers/memorial_provider.dart';
import '../theme/glassmorphism_theme.dart';

class CreateHeavenlyVoicePage extends StatefulWidget {
  const CreateHeavenlyVoicePage({super.key});

  @override
  State<CreateHeavenlyVoicePage> createState() => _CreateHeavenlyVoicePageState();
}

class _CreateHeavenlyVoicePageState extends State<CreateHeavenlyVoicePage> with TickerProviderStateMixin {
  int _currentStep = 0;
  Memorial? _selectedMemorial;
  List<File> _audioFiles = [];
  List<String> _textEntries = [];
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
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
              _buildModernHeader(),
              _buildModernStepIndicator(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _currentStep == 0
                            ? _buildStepOneMemorialSelection()
                            : _buildStepTwoContentCollection(),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildMemorialSelection() {
    return Consumer<MemorialProvider>(
      builder: (context, memorialProvider, child) {
        final userMemorials = memorialProvider.memorials
            .where((m) => m.isOwnedBy(
                Provider.of<AuthProvider>(context, listen: false).currentUser?.id))
            .toList();

        if (memorialProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: GlassmorphismColors.primary,
            ),
          );
        }

        if (userMemorials.isEmpty) {
          return _buildEmptyMemorials();
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: GlassmorphismDecorations.glassCard.copyWith(
                        borderRadius: BorderRadius.circular(12),
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
                              '为哪位挚爱创建天堂之音？选择后我们将收集他们的声音片段',
                              style: TextStyle(
                                color: GlassmorphismColors.info,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '选择纪念 (${userMemorials.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: userMemorials.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final memorial = userMemorials[index];
                          return _buildMemorialCard(memorial);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedMemorial != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlassmorphismColors.warmAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                      shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '为${_selectedMemorial?.name}收集回音',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyMemorials() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.6),
                  GlassmorphismColors.secondary.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '还没有创建纪念',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: GlassmorphismColors.textOnGlass,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: GlassmorphismDecorations.glassCard.copyWith(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '要创建天堂之音，您需要先为挚爱创建一个纪念。纪念是保存回忆的地方，也是天堂之音的基础。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GlassmorphismColors.textOnGlass,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: 导航到创建纪念页面
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassmorphismColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '创建第一个纪念',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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

  Widget _buildMemorialCard(Memorial memorial) {
    final isSelected = _selectedMemorial?.id == memorial.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMemorial = memorial;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    GlassmorphismColors.warmAccent.withValues(alpha: 0.3),
                    GlassmorphismColors.primary.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : GlassmorphismColors.glassSurface,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: GlassmorphismColors.warmAccent, width: 2)
              : Border.all(color: GlassmorphismColors.glassBorder),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: GlassmorphismColors.warmAccent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: GlassmorphismColors.glassSurface,
              ),
              child: memorial.primaryImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        memorial.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: GlassmorphismColors.textSecondary,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: GlassmorphismColors.textSecondary,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memorial.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlassmorphismColors.textOnGlass,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memorial.relationship ?? '亲人',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memorial.formattedDates,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: GlassmorphismColors.warmAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 温馨提示卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: GlassmorphismDecorations.glassCard.copyWith(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                            GlassmorphismColors.warmAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '收集珍贵回音',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: GlassmorphismColors.textOnGlass,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '让TA的声音永远陪伴您',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlassmorphismColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GlassmorphismColors.warmAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GlassmorphismColors.warmAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '💡 上传TA生前的语音片段或记录TA说过的话，我们将运用AI技术让TA的声音和话语重现，与您进行温暖对话',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GlassmorphismColors.textOnGlass,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 音频收集区域
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'TA的声音片段',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textOnGlass,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _audioFiles.isNotEmpty
                      ? GlassmorphismColors.success.withValues(alpha: 0.2)
                      : GlassmorphismColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_audioFiles.length}个',
                  style: TextStyle(
                    color: _audioFiles.isNotEmpty
                        ? GlassmorphismColors.success
                        : GlassmorphismColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildAudioUploadArea(),
          
          if (_audioFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._audioFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildAudioFileCard(file, index);
            }).toList(),
          ],
          
          const SizedBox(height: 24),
          
          // 贴心提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlassmorphismColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GlassmorphismColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: GlassmorphismColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '建议：上传多段5-60秒的语音和丰富的文字记录，内容越全面，AI效果会更自然真实',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.info,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 文字记忆区域  
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: GlassmorphismColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'TA说过的话',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textOnGlass,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _textEntries.isNotEmpty
                      ? GlassmorphismColors.secondary.withValues(alpha: 0.2)
                      : GlassmorphismColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_textEntries.length}条',
                  style: TextStyle(
                    color: _textEntries.isNotEmpty
                        ? GlassmorphismColors.secondary
                        : GlassmorphismColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextInputArea(),
          
          if (_textEntries.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._textEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              return _buildTextEntryCard(text, index);
            }).toList(),
          ],
          
          const SizedBox(height: 40),
          
          // 完成按钮
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassmorphismColors.warmAccent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 8,
              shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '创建天堂回音',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: GlassmorphismColors.info,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: GlassmorphismColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioUploadArea() {
    return GestureDetector(
      onTap: _pickAudioFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.primary.withValues(alpha: 0.08),
              GlassmorphismColors.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GlassmorphismColors.primary.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
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
                boxShadow: [
                  BoxShadow(
                    color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '点击上传音频',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: GlassmorphismColors.textOnGlass,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '支持 MP3、WAV、M4A、AAC、OGG\n建议 5-60秒，最大50MB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildAudioFileCard(File file, int index) {
    final fileName = path.basename(file.path);
    
    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) {
        final fileSize = snapshot.data;
        final fileSizeText = fileSize != null 
            ? _formatFileSize(fileSize)
            : '计算中...';
            
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassmorphismColors.primary.withValues(alpha: 0.1),
                GlassmorphismColors.glassSurface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlassmorphismColors.primary,
                      GlassmorphismColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.audiotrack,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        color: GlassmorphismColors.textOnGlass,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: GlassmorphismColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '音频 ${index + 1}',
                            style: TextStyle(
                              color: GlassmorphismColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fileSizeText,
                          style: TextStyle(
                            color: GlassmorphismColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _audioFiles.removeAt(index);
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Widget _buildTextInputArea() {
    return Container(
      decoration: GlassmorphismDecorations.glassCard.copyWith(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '记录TA常说的话...\n例如："要好好照顾自己"\n"爸爸/妈妈永远爱你"',
              hintStyle: TextStyle(
                color: GlassmorphismColors.textTertiary,
                fontSize: 14,
                height: 1.4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            ),
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: GlassmorphismColors.glassBorder,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '用文字记录TA的温暖话语',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GlassmorphismColors.textTertiary,
                  ),
                ),
                TextButton(
                  onPressed: _addTextEntry,
                  style: TextButton.styleFrom(
                    backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.1),
                    foregroundColor: GlassmorphismColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '添加',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEntryCard(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.secondary.withValues(alpha: 0.08),
            GlassmorphismColors.secondary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: GlassmorphismColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: GlassmorphismColors.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"$text"',
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 15,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeTextEntry(index),
            icon: Icon(
              Icons.close_rounded,
              color: GlassmorphismColors.error.withValues(alpha: 0.8),
              size: 18,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: GlassmorphismColors.error.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
        // 检查文件大小（限制为50MB）
        int fileSize = await file.length();
        if (fileSize > 50 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('音频文件大小不能超过50MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // 检查文件扩展名
        String extension = path.extension(file.path).toLowerCase();
        List<String> allowedExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg'];
        
        if (!allowedExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('不支持的音频格式，请选择 MP3, WAV, M4A, AAC 或 OGG 格式'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _audioFiles.add(file);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已添加音频文件：${path.basename(file.path)}'),
              backgroundColor: GlassmorphismColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件时出错：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addTextEntry() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textEntries.add(_textController.text.trim());
        _textController.clear();
      });
    }
  }

  void _removeTextEntry(int index) {
    setState(() {
      _textEntries.removeAt(index);
    });
  }

  void _submitForm() async {

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 保存天堂之音数据到本地
      await _saveHeavenlyVoiceToLocal();
      
      if (mounted) {
        Navigator.of(context).pop(true); // 返回true表示创建成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedMemorial?.name}的天堂之音创建成功！'),
            backgroundColor: GlassmorphismColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _saveHeavenlyVoiceToLocal() async {
    if (_selectedMemorial == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final voicesJson = prefs.getStringList('heavenly_voices') ?? [];
    
    // 创建天堂之音数据
    final heavenlyVoice = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'memorialId': _selectedMemorial!.id,
      'memorialName': _selectedMemorial!.name,
      'relationship': _selectedMemorial!.relationship,
      'audioCount': _audioFiles.length,
      'textCount': _textEntries.length,
      'audioFiles': _audioFiles.map((f) => f.path).toList(),
      'textEntries': _textEntries,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'created', // created, training, ready
    };
    
    // 添加到列表并保存
    voicesJson.add(jsonEncode(heavenlyVoice));
    await prefs.setStringList('heavenly_voices', voicesJson);
  }

  // 现代化头部设计
  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
              onPressed: () {
                if (_currentStep == 0) {
                  Navigator.of(context).pop();
                } else {
                  _goToPreviousStep();
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: GlassmorphismColors.textOnGlass,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // 标题区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '创建天堂之音',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: GlassmorphismColors.textOnGlass,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepDescription(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 现代化步骤指示器
  Widget _buildModernStepIndicator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Row(
        children: [
          _buildModernStepDot(0, '选择纪念'),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _currentStep >= 1 
                    ? GlassmorphismColors.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildModernStepDot(1, '收集内容'),
        ],
      ),
    );
  }

  // 现代化步骤圆点
  Widget _buildModernStepDot(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      GlassmorphismColors.primary,
                      GlassmorphismColors.warmAccent,
                    ],
                  )
                : null,
            color: !isActive ? Colors.white.withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(16),
            border: isCurrent ? Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ) : null,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    step == 0 ? Icons.person_outline : Icons.mic_none_outlined,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: GlassmorphismColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive 
                ? GlassmorphismColors.textOnGlass
                : GlassmorphismColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return '选择一位挚爱开始创建';
      case 1:
        return '为${_selectedMemorial?.name ?? ''}收集珍贵声音记忆';
      default:
        return '';
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  // 第一步：现代化纪念选择
  Widget _buildStepOneMemorialSelection() {
    return Consumer<MemorialProvider>(
      builder: (context, memorialProvider, child) {
        final userMemorials = memorialProvider.memorials
            .where((m) => m.isOwnedBy(Provider.of<AuthProvider>(context, listen: false).currentUser?.id))
            .toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文本
              Container(
                padding: const EdgeInsets.all(24),
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismColors.primary.withValues(alpha: 0.8),
                            GlassmorphismColors.warmAccent.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '选择纪念对象',
                            style: TextStyle(
                              color: GlassmorphismColors.textOnGlass,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '为哪一位挚爱创建专属的天堂之音',
                            style: TextStyle(
                              color: GlassmorphismColors.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 纪念列表
              Expanded(
                child: userMemorials.isEmpty
                    ? _buildEmptyMemorialState()
                    : ListView.builder(
                        itemCount: userMemorials.length,
                        itemBuilder: (context, index) {
                          final memorial = userMemorials[index];
                          return _buildModernMemorialCard(memorial);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 现代化纪念卡片
  Widget _buildModernMemorialCard(Memorial memorial) {
    bool isSelected = _selectedMemorial?.id == memorial.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected 
            ? GlassmorphismColors.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? GlassmorphismColors.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedMemorial = memorial;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlassmorphismColors.primary.withValues(alpha: 0.8),
                        GlassmorphismColors.secondary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
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
                        memorial.name,
                        style: TextStyle(
                          color: GlassmorphismColors.textOnGlass,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        memorial.relationship ?? '',
                        style: TextStyle(
                          color: GlassmorphismColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 选中指示器
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? GlassmorphismColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? GlassmorphismColors.primary
                          : GlassmorphismColors.textSecondary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 第二步：现代化内容收集
  Widget _buildStepTwoContentCollection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前选择的纪念信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.1),
                  GlassmorphismColors.warmAccent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GlassmorphismColors.primary.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GlassmorphismColors.primary,
                        GlassmorphismColors.warmAccent,
                      ],
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '为 ${_selectedMemorial?.name} 收集内容',
                        style: TextStyle(
                          color: GlassmorphismColors.textOnGlass,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '上传音频文件或添加文字记录，内容越丰富效果越好',
                        style: TextStyle(
                          color: GlassmorphismColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 内容收集区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAudioUploadSection(),
                  const SizedBox(height: 24),
                  _buildTextInputSection(),
                  const SizedBox(height: 120), // 增加底部空间，避免被底部操作栏遮挡
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 音频上传区域
  Widget _buildAudioUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '语音片段 (可选)',
          style: TextStyle(
            color: GlassmorphismColors.textOnGlass,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '上传5-60秒的音频文件，AI会学习声音特征',
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // 上传按钮
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickAudioFiles,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: GlassmorphismColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _audioFiles.isEmpty ? '点击上传音频文件' : '已上传 ${_audioFiles.length} 个文件',
                    style: TextStyle(
                      color: GlassmorphismColors.textOnGlass,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '支持 MP3、WAV、M4A 格式',
                    style: TextStyle(
                      color: GlassmorphismColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 文件列表
        if (_audioFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._audioFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildAudioFileItem(file, index);
          }),
        ],
      ],
    );
  }

  // 音频文件项
  Widget _buildAudioFileItem(File file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GlassmorphismColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            color: GlassmorphismColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path.basename(file.path),
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _removeAudioFile(index),
            icon: Icon(
              Icons.close,
              color: GlassmorphismColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // 文本输入区域
  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '文字记录',
          style: TextStyle(
            color: GlassmorphismColors.textOnGlass,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '记录TA说过的话、口头禅、表达习惯等',
          style: TextStyle(
            color: GlassmorphismColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // 输入框
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 4,
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '例如："早安，今天天气真好" 或 "记得多喝水，注意身体"',
              hintStyle: TextStyle(
                color: GlassmorphismColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 添加按钮
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _textController.text.trim().isEmpty ? null : _addTextEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              '添加文字记录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        // 文字列表
        if (_textEntries.isNotEmpty) ...[
          const SizedBox(height: 20),
          ..._textEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return _buildTextEntryItem(text, index);
          }),
        ],
      ],
    );
  }

  // 文字记录项
  Widget _buildTextEntryItem(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GlassmorphismColors.warmAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.warmAccent.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: GlassmorphismColors.warmAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeTextEntry(index),
            icon: Icon(
              Icons.close,
              color: GlassmorphismColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMemorialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: GlassmorphismColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 40,
              color: GlassmorphismColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无可用纪念',
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先创建一个纪念页面',
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  void _removeAudioFile(int index) {
    setState(() {
      _audioFiles.removeAt(index);
    });
  }

  Future<void> _pickAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _audioFiles.addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 现代化底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GlassmorphismColors.backgroundPrimary.withValues(alpha: 0.8),
            GlassmorphismColors.backgroundPrimary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 上一步按钮 (仅在第二步显示)
          if (_currentStep > 0)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    minimumSize: const Size(0, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: GlassmorphismColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '上一步',
                        style: TextStyle(
                          color: GlassmorphismColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // 下一步/完成按钮
          Expanded(
            flex: _currentStep > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _getNextButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getNextButtonAction() != null 
                    ? GlassmorphismColors.warmAccent
                    : GlassmorphismColors.textSecondary.withValues(alpha: 0.3),
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                elevation: _getNextButtonAction() != null ? 8 : 0,
                shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
              ),
              child: _isSubmitting && _currentStep == 1
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentStep == 0 ? Icons.arrow_forward_rounded : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentStep == 0 ? '下一步' : '创建天堂回音',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取下一步按钮的操作
  VoidCallback? _getNextButtonAction() {
    if (_currentStep == 0) {
      // 第一步：需要选择纪念
      return _selectedMemorial != null ? _goToNextStep : null;
    } else if (_currentStep == 1) {
      // 第二步：需要至少一个音频文件或文字记录
      return (_audioFiles.isNotEmpty || _textEntries.isNotEmpty) && !_isSubmitting 
          ? _submitForm 
          : null;
    }
    return null;
  }

  void _goToNextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }
}