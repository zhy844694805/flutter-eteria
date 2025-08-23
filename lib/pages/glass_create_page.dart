import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/glass_icons.dart';
import '../widgets/glass_interactive_widgets.dart';
import '../providers/memorial_provider.dart';
import '../providers/auth_provider.dart';
import 'glass_login_page.dart';
import '../services/file_service.dart';
import '../utils/image_helper.dart';
import '../utils/form_validators.dart';
import '../utils/error_handler.dart';

/// 玻璃拟态创建纪念页面
class GlassCreatePage extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  
  const GlassCreatePage({
    super.key,
    this.onNavigateToHome,
  });

  @override
  State<GlassCreatePage> createState() => _GlassCreatePageState();
}

class _GlassCreatePageState extends State<GlassCreatePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  MemorialType _selectedType = MemorialType.person;
  String _selectedRelationship = '父亲';
  DateTime? _birthDate;
  DateTime? _deathDate;
  final List<File> _selectedImages = [];
  bool _isPublic = true;
  bool _isCompressing = false;
  bool _isUploading = false;
  
  late AnimationController _pageAnimationController;
  late AnimationController _progressController;
  late Animation<double> _pageAnimation;
  late Animation<double> _progressAnimation;
  
  final ImagePicker _picker = ImagePicker();
  final FileService _fileService = FileService();
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 4;

  // 关系选项列表
  final List<String> _relationships = [
    '父亲', '母亲', '祖父', '祖母', '外祖父', '外祖母',
    '丈夫', '妻子', '儿子', '女儿', '兄弟', '姐妹',
    '朋友', '同事', '老师', '同学', '其他亲属', '其他'
  ];

  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pageAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    
    _pageController = PageController();
    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pageAnimationController.dispose();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // 验证当前步骤的表单
      if (_currentStep == 0) {
        // 第一步：验证基本信息
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (_nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('请输入逝者姓名'),
              backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return _buildGuestModeView();
        }
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _pageAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * _pageAnimation.value),
                    child: Opacity(
                      opacity: _pageAnimation.value,
                      child: Column(
                        children: [
                          _buildAppBar(),
                          _buildProgressBar(),
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (page) {
                                  setState(() {
                                    _currentStep = page;
                                  });
                                  _updateProgress();
                                },
                                children: [
                                  _buildBasicInfoStep(),
                                  _buildDatesStep(),
                                  _buildPhotosStep(),
                                  _buildDescriptionStep(),
                                ],
                              ),
                            ),
                          ),
                          _buildBottomControls(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '缅怀至亲',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '让我们一起回忆那些温暖的时刻',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return GlassProgressIndicator(
            value: _progressAnimation.value,
            color: GlassmorphismColors.primary,
            height: 6,
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassHoverCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              '基本信息',
              '请填写逝者的基本信息',
              GlassIcons.memorial,
            ),
            const SizedBox(height: 24),
            
            // 逝者姓名
            GlassFormField(
              label: '逝者姓名',
              hintText: '请轻柔地输入ta的姓名',
              controller: _nameController,
              validator: (value) => FormValidators.validateName(value, fieldName: '逝者姓名'),
              prefixIcon: Icon(
                GlassIcons.memorial,
                color: GlassmorphismColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 20),
            
            // 与逝者关系
            GlassDropdownField<String>(
              label: '与逝者关系',
              hintText: '请选择关系',
              value: _selectedRelationship,
              items: _relationships,
              itemBuilder: (item) => item,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // 隐私设置
            _buildPrivacySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassHoverCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              '生命历程',
              '记录ta的生命轨迹',
              Icons.calendar_today,
            ),
            const SizedBox(height: 24),
            
            // 出生日期
            GlassDateField(
              label: '出生日期',
              hintText: '请选择出生日期',
              selectedDate: _birthDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              initialDate: DateTime(1980, 1, 1), // 默认1980年
              onDateSelected: (date) {
                setState(() {
                  _birthDate = date;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // 离世日期
            GlassDateField(
              label: '离世日期',
              hintText: '请选择离世日期',
              selectedDate: _deathDate,
              firstDate: _birthDate ?? DateTime(1900),
              lastDate: DateTime.now(),
              onDateSelected: (date) {
                setState(() {
                  _deathDate = date;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // 日期信息预览
            if (_birthDate != null || _deathDate != null)
              _buildDatePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassHoverCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              '珍贵回忆',
              '添加照片来保存美好回忆',
              GlassIcons.photo,
            ),
            const SizedBox(height: 24),
            
            // 照片选择区域
            _buildPhotoSelector(),
            
            const SizedBox(height: 20),
            
            // 已选择的照片
            if (_selectedImages.isNotEmpty)
              _buildSelectedPhotos(),
              
            // 压缩提示
            if (_isCompressing)
              _buildCompressionIndicator(),
              
            const SizedBox(height: 16),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassHoverCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              '纪念文字',
              '写下您想对ta说的话',
              Icons.edit,
            ),
            const SizedBox(height: 24),
            
            // 纪念文字输入
            GlassFormField(
              label: '纪念文字',
              hintText: '与ta分享您心中的话语...',
              controller: _descriptionController,
              maxLines: 6,
              validator: (value) => FormValidators.validateDescription(value, fieldName: '纪念文字'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.glassGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: GlassmorphismColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '隐私设置',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: GlassmorphismColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlassHoverCard(
                onTap: () {
                  Future.microtask(() {
                    if (mounted) {
                      setState(() => _isPublic = true);
                    }
                  });
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isPublic,
                      onChanged: (value) {
                        Future.microtask(() {
                          if (mounted) {
                            setState(() => _isPublic = value ?? true);
                          }
                        });
                      },
                      activeColor: GlassmorphismColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '公开',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: GlassmorphismColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '其他人可以看到',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: GlassmorphismColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassHoverCard(
                onTap: () {
                  Future.microtask(() {
                    if (mounted) {
                      setState(() => _isPublic = false);
                    }
                  });
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _isPublic,
                      onChanged: (value) {
                        Future.microtask(() {
                          if (mounted) {
                            setState(() => _isPublic = value ?? false);
                          }
                        });
                      },
                      activeColor: GlassmorphismColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '私密',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: GlassmorphismColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '仅自己可见',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: GlassmorphismColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: GlassmorphismColors.glassGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            color: GlassmorphismColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_birthDate?.year ?? '?'} - ${_deathDate?.year ?? '?'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return GestureDetector(
      onTap: _selectedImages.length < 9 ? _pickImages : null,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: _selectedImages.length < 9
              ? GlassmorphismColors.glassGradient
              : LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImages.length < 9
                ? GlassmorphismColors.glassBorder
                : GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedImages.length < 9
                  ? GlassIcons.photo
                  : Icons.block,
              size: 40,
              color: _selectedImages.length < 9
                  ? GlassmorphismColors.primary
                  : GlassmorphismColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedImages.length < 9 
                  ? '添加珍贵的回忆照片' 
                  : '已添加足够的美好回忆',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _selectedImages.length < 9
                    ? GlassmorphismColors.textPrimary
                    : GlassmorphismColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedImages.isNotEmpty && _selectedImages.length < 9
                  ? '还可添加${9 - _selectedImages.length}张'
                  : '点击选择照片 (最多9张)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GlassmorphismColors.textSecondary,
              ),
            ),
            if (_selectedImages.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GlassmorphismColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_selectedImages.length}/9',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: GlassmorphismColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已选择的照片',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: GlassmorphismColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: _buildSelectedImageItem(_selectedImages[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: GlassmorphismDecorations.glassCard,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: GlassmorphismColors.backgroundSecondary,
                  child: Icon(
                    Icons.error,
                    color: GlassmorphismColors.error,
                    size: 32,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GlassmorphismColors.error.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: GlassmorphismColors.shadowMedium,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GlassmorphismColors.glassSurface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 0.5,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: GlassmorphismColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompressionIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.info.withValues(alpha: 0.1),
            GlassmorphismColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                GlassmorphismColors.info,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '正在优化照片质量，请稍候...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlassmorphismColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: GlassInteractiveButton(
                text: '上一步',
                icon: Icons.arrow_back,
                onPressed: _previousStep,
                backgroundColor: GlassmorphismColors.glassSecondary,
                foregroundColor: GlassmorphismColors.textSecondary,
                height: 52,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: GlassInteractiveButton(
              text: _currentStep == _totalSteps - 1 ? '建立纪念' : '下一步',
              icon: _currentStep == _totalSteps - 1 
                  ? (_isUploading ? null : GlassIcons.create)
                  : Icons.arrow_forward,
              onPressed: _isUploading 
                  ? null 
                  : (_currentStep == _totalSteps - 1 ? _createMemorial : _nextStep),
              isLoading: _isUploading,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  // 交互方法
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remainingSlots = 9 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        if (imagesToAdd.length < images.length && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('最多只能选择9张照片，已选择前${imagesToAdd.length}张'),
              backgroundColor: GlassmorphismColors.warning.withValues(alpha: 0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        setState(() {
          _isCompressing = true;
        });

        final newImages = <File>[];
        for (final xfile in imagesToAdd) {
          final file = File(xfile.path);
          if (await file.exists()) {
            newImages.add(file);
          }
        }

        if (newImages.isEmpty) {
          setState(() {
            _isCompressing = false;
          });
          return;
        }

        final compressedImages = await ImageHelper.compressImages(newImages);
        final validImages = <File>[];
        for (final compressedImage in compressedImages) {
          if (await compressedImage.exists()) {
            validImages.add(compressedImage);
          }
        }

        setState(() {
          _selectedImages.addAll(validImages);
          _isCompressing = false;
        });

        if (validImages.length < newImages.length && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功添加${validImages.length}张图片'),
              backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _createMemorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证日期
    final birthDateError = FormValidators.validateBirthDate(_birthDate);
    if (birthDateError != null) {
      _showErrorSnackBar(birthDateError);
      return;
    }

    final deathDateError = FormValidators.validateDeathDate(_deathDate, _birthDate);
    if (deathDateError != null) {
      _showErrorSnackBar(deathDateError);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 上传图片
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          final uploadedFiles = await _fileService.uploadFiles(_selectedImages);
          imageUrls = uploadedFiles.map((file) => file['url'] as String).toList();
        } catch (e) {
          if (mounted) {
            _showWarningSnackBar('图片上传失败，但纪念已创建。您可以稍后编辑添加图片。');
          }
        }
      }

      // 创建纪念对象
      final memorial = Memorial(
        id: 0,
        type: _selectedType,
        name: _nameController.text.trim(),
        relationship: _selectedRelationship,
        birthDate: _birthDate!,
        deathDate: _deathDate!,
        description: _descriptionController.text.trim(),
        imagePaths: [],
        imageUrls: imageUrls,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 使用Provider创建纪念
      if (!mounted) return;
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      final success = await provider.addMemorial(memorial);

      if (mounted) {
        if (success) {
          print('🎉 [GlassCreatePage] 纪念创建成功，准备跳转到首页');
          _showSuccessSnackBar('纪念创建成功！');
          
          // 延迟1.5秒后自动跳转到首页
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              print('🏠 [GlassCreatePage] 开始跳转到首页');
              if (widget.onNavigateToHome != null) {
                widget.onNavigateToHome!();
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } else {
              print('❌ [GlassCreatePage] 组件已销毁，取消跳转');
            }
          });
        } else {
          print('❌ [GlassCreatePage] 纪念创建失败: ${provider.error}');
          _showErrorSnackBar(provider.error ?? '创建失败');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('创建失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: GlassmorphismColors.warning.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 游客模式视图
  Widget _buildGuestModeView() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _pageAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _pageAnimation.value),
                child: Opacity(
                  opacity: _pageAnimation.value,
                  child: Column(
                    children: [
                      // 简化的导航栏
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GlassIconButton(
                              icon: Icons.arrow_back,
                              onPressed: () => Navigator.pop(context),
                              size: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '创建纪念',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: GlassmorphismColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 主要内容区域
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: GlassmorphismDecorations.glassCard,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.05),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 锁定图标
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                GlassmorphismColors.primary.withValues(alpha: 0.3),
                                                GlassmorphismColors.primary.withValues(alpha: 0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(40),
                                            border: Border.all(
                                              color: GlassmorphismColors.primary.withValues(alpha: 0.5),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            GlassIcons.lock,
                                            size: 40,
                                            color: GlassmorphismColors.primary,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 24),
                                        
                                        // 标题
                                        Text(
                                          '需要登录账户',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: GlassmorphismColors.textOnGlass,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        
                                        // 说明文字
                                        Text(
                                          '创建纪念内容需要登录账户。\n登录后您可以：',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: GlassmorphismColors.textSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // 功能列表
                                        Column(
                                          children: [
                                            _buildFeatureTile('创建纪念内容', GlassIcons.create),
                                            _buildFeatureTile('上传照片视频', GlassIcons.photo),
                                            _buildFeatureTile('个人纪念管理', GlassIcons.profile),
                                            _buildFeatureTile('收藏点赞互动', GlassIcons.like),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 32),
                                        
                                        // 操作按钮
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: GlassButton(
                                                onPressed: () {
                                                  // 直接推送到登录页面
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => const GlassLoginPage(),
                                                    ),
                                                  );
                                                },
                                                backgroundColor: GlassmorphismColors.primary,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      GlassIcons.login,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      '登录 / 注册',
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
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String feature, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: GlassmorphismColors.success,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              color: GlassmorphismColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}