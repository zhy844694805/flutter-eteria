import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../theme/glassmorphism_theme.dart';

class EditHeavenlyVoicePage extends StatefulWidget {
  final Map<String, dynamic> voice;

  const EditHeavenlyVoicePage({
    super.key,
    required this.voice,
  });

  @override
  State<EditHeavenlyVoicePage> createState() => _EditHeavenlyVoicePageState();
}

class _EditHeavenlyVoicePageState extends State<EditHeavenlyVoicePage> with TickerProviderStateMixin {
  List<File> _audioFiles = [];
  List<String> _textEntries = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    
    // 添加文本监听器以实时更新按钮状态
    _textController.addListener(() {
      setState(() {}); // 触发重新构建以更新按钮状态
    });
    
    _loadVoiceData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _loadVoiceData() {
    // 加载现有的音频文件路径
    if (widget.voice['audioFiles'] != null) {
      _audioFiles = (widget.voice['audioFiles'] as List<dynamic>)
          .map((filePath) => File(filePath.toString()))
          .where((file) => file.existsSync()) // 只保留存在的文件
          .toList();
    }
    
    // 加载现有的文字记录
    if (widget.voice['textEntries'] != null) {
      _textEntries = List<String>.from(widget.voice['textEntries']);
    }
    
    setState(() {
      _isLoading = false;
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
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isLoading 
                          ? _buildLoadingView()
                          : _buildEditContent(),
                    );
                  },
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              onPressed: () => Navigator.of(context).pop(),
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
                  '编辑天堂回音',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: GlassmorphismColors.textOnGlass,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.voice['memorialName'] ?? '',
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

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: GlassmorphismColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '加载回音数据...',
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 回音信息卡片
          _buildVoiceInfoCard(),
          
          const SizedBox(height: 32),
          
          // 音频文件管理
          _buildAudioSection(),
          
          const SizedBox(height: 32),
          
          // 文字记录管理
          _buildTextSection(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVoiceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.primary.withValues(alpha: 0.08),
            GlassmorphismColors.warmAccent.withValues(alpha: 0.04),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary,
                  GlassmorphismColors.warmAccent,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.spatial_audio_off_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.voice['memorialName'] ?? '',
                  style: TextStyle(
                    color: GlassmorphismColors.textOnGlass,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.voice['relationship'] ?? '',
                  style: TextStyle(
                    color: GlassmorphismColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '创建于 ${_formatDate(widget.voice['createdAt'])}',
                  style: TextStyle(
                    color: GlassmorphismColors.textSecondary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.mic_none_outlined,
              color: GlassmorphismColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '音频文件',
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 18,
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
        
        // 添加音频按钮
        _buildAddAudioButton(),
        
        if (_audioFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._audioFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildAudioFileCard(file, index);
          }),
        ],
      ],
    );
  }

  Widget _buildAddAudioButton() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassmorphismColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickAudioFiles,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: GlassmorphismColors.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                '添加音频文件',
                style: TextStyle(
                  color: GlassmorphismColors.primary,
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
    );
  }

  Widget _buildAudioFileCard(File file, int index) {
    final fileName = path.basename(file.path);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GlassmorphismColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.audiotrack,
              color: GlassmorphismColors.primary,
              size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData ? _formatFileSize(snapshot.data!) : '计算中...',
                      style: TextStyle(
                        color: GlassmorphismColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () => _removeAudioFile(index),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: GlassmorphismColors.warmAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '文字记录',
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _textEntries.isNotEmpty
                    ? GlassmorphismColors.warmAccent.withValues(alpha: 0.2)
                    : GlassmorphismColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_textEntries.length}条',
                style: TextStyle(
                  color: _textEntries.isNotEmpty
                      ? GlassmorphismColors.warmAccent
                      : GlassmorphismColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 添加文字输入框
        _buildTextInputArea(),
        
        if (_textEntries.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._textEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return _buildTextEntryCard(text, index);
          }),
        ],
      ],
    );
  }

  Widget _buildTextInputArea() {
    return Column(
      children: [
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
            maxLines: 3,
            style: TextStyle(
              color: GlassmorphismColors.textOnGlass,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '添加TA说过的话...\n例如："要好好照顾自己"\n"永远爱你"',
              hintStyle: TextStyle(
                color: GlassmorphismColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 添加文字记录按钮
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: _textController.text.trim().isNotEmpty
                ? LinearGradient(
                    colors: [
                      GlassmorphismColors.warmAccent.withValues(alpha: 0.9),
                      GlassmorphismColors.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: _textController.text.trim().isEmpty 
                ? GlassmorphismColors.textSecondary.withValues(alpha: 0.2)
                : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: _textController.text.trim().isNotEmpty ? [
              BoxShadow(
                color: GlassmorphismColors.warmAccent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _textController.text.trim().isEmpty ? null : _addTextEntry,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '添加文字记录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextEntryCard(String text, int index) {
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: GlassmorphismColors.warmAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: GlassmorphismColors.warmAccent,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: GlassmorphismColors.textOnGlass,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeTextEntry(index),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GlassmorphismColors.backgroundPrimary.withValues(alpha: 0.9),
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
          // 取消按钮
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: GlassmorphismColors.textSecondary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: GlassmorphismColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          
          // 保存按钮
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassmorphismColors.warmAccent,
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                elevation: 8,
                shadowColor: GlassmorphismColors.warmAccent.withValues(alpha: 0.4),
              ),
              child: _isSaving
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
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '保存更改',
                          style: TextStyle(
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

  // 选择音频文件
  Future<void> _pickAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> validFiles = [];
        
        for (var file in result.files) {
          if (file.path != null) {
            File audioFile = File(file.path!);
            
            // 检查文件大小（限制为50MB）
            int fileSize = await audioFile.length();
            if (fileSize > 50 * 1024 * 1024) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('文件 ${file.name} 大小超过50MB，已跳过'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              continue;
            }

            // 检查文件扩展名
            String extension = path.extension(audioFile.path).toLowerCase();
            List<String> allowedExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg'];
            
            if (!allowedExtensions.contains(extension)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('文件 ${file.name} 格式不支持，已跳过'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              continue;
            }
            
            validFiles.add(audioFile);
          }
        }

        if (validFiles.isNotEmpty) {
          setState(() {
            _audioFiles.addAll(validFiles);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('成功添加 ${validFiles.length} 个音频文件'),
                backgroundColor: GlassmorphismColors.success,
              ),
            );
          }
        }
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

  // 移除音频文件
  void _removeAudioFile(int index) {
    setState(() {
      _audioFiles.removeAt(index);
    });
  }

  // 添加文字记录
  void _addTextEntry() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textEntries.add(_textController.text.trim());
        _textController.clear();
      });
    }
  }

  // 移除文字记录
  void _removeTextEntry(int index) {
    setState(() {
      _textEntries.removeAt(index);
    });
  }

  // 保存更改
  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final voicesJson = prefs.getStringList('heavenly_voices') ?? [];
      
      // 找到要更新的回音数据
      for (int i = 0; i < voicesJson.length; i++) {
        final voiceData = Map<String, dynamic>.from(jsonDecode(voicesJson[i]));
        if (voiceData['id'] == widget.voice['id']) {
          // 更新数据
          voiceData['audioCount'] = _audioFiles.length;
          voiceData['textCount'] = _textEntries.length;
          voiceData['audioFiles'] = _audioFiles.map((f) => f.path).toList();
          voiceData['textEntries'] = _textEntries;
          
          // 替换原数据
          voicesJson[i] = jsonEncode(voiceData);
          break;
        }
      }
      
      // 保存更新后的数据
      await prefs.setStringList('heavenly_voices', voicesJson);
      
      if (mounted) {
        Navigator.of(context).pop(true); // 返回true表示已保存
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.voice['memorialName']}的天堂回音已更新'),
            backgroundColor: GlassmorphismColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
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