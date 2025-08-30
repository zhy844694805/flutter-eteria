import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
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

class _CreateHeavenlyVoicePageState extends State<CreateHeavenlyVoicePage> {
  int _currentStep = 0;
  Memorial? _selectedMemorial;
  List<File> _audioFiles = [];
  List<String> _textEntries = [];
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
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
              _buildHeader(),
              Expanded(
                child: _currentStep == 0
                    ? _buildMemorialSelection()
                    : _buildVoiceUpload(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_currentStep == 0) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _currentStep = 0;
                });
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: GlassmorphismColors.textOnGlass,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStep == 0 ? '创建天堂之音' : '收集珍贵回音',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GlassmorphismColors.textOnGlass,
                  ),
                ),
                Text(
                  _currentStep == 0 
                      ? '选择一位挚爱开始创建'
                      : '上传${_selectedMemorial?.name}的声音和话语',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, '选择'),
        _buildStepLine(),
        _buildStepDot(1, '上传'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive || isCompleted 
                ? GlassmorphismColors.warmAccent 
                : Colors.white30,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive || isCompleted 
                ? GlassmorphismColors.warmAccent 
                : Colors.white60,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.white30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
                    '💡 上传TA生前的语音片段，我们将运用AI技术让TA的声音重现，与您进行温暖对话',
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
                    '建议：上传多段5-60秒的语音，包含不同情感表达，效果会更自然真实',
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
            onPressed: _audioFiles.isEmpty || _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _audioFiles.isEmpty 
                  ? Colors.grey 
                  : GlassmorphismColors.warmAccent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: _audioFiles.isEmpty ? 0 : 8,
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
                        _audioFiles.isEmpty ? '完成创建 (至少需要1个音频)' : '创建天堂回音',
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
    if (_audioFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少上传一个音频文件'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: 实现表单提交逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟提交
      
      if (mounted) {
        Navigator.of(context).pop();
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
}