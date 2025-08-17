import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/memorial.dart';
import '../theme/app_theme.dart';
import '../providers/memorial_provider.dart';
import '../services/file_service.dart';
import '../utils/image_helper.dart';
import '../utils/form_validators.dart';
import '../utils/error_handler.dart';
import '../widgets/platform_image.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  MemorialType _selectedType = MemorialType.person;
  String _selectedRelationship = '父亲'; // 新增：关系选择
  DateTime? _birthDate;
  DateTime? _deathDate;
  final List<File> _selectedImages = [];
  bool _isPublic = true;
  final ImagePicker _picker = ImagePicker();
  final FileService _fileService = FileService();
  bool _isCompressing = false;
  bool _isUploading = false;

  // 关系选项列表
  final List<String> _relationships = [
    '父亲', '母亲', '祖父', '祖母', '外祖父', '外祖母',
    '丈夫', '妻子', '儿子', '女儿', '兄弟', '姐妹',
    '朋友', '同事', '老师', '同学', '其他亲属', '其他'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建纪念'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 页面标题
            Text(
              '创建纪念',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 不再需要类型选择，默认为逝者纪念

            // 逝者姓名
            _buildNameField(),
            const SizedBox(height: 24),

            // 与逝者关系
            _buildRelationshipField(),
            const SizedBox(height: 24),

            // 出生日期
            _buildDateField(
              label: '出生日期',
              value: _birthDate,
              onTap: () => _selectDate(context, isBirth: true),
            ),
            const SizedBox(height: 24),

            // 离世日期
            _buildDateField(
              label: '离世日期',
              value: _deathDate,
              onTap: () => _selectDate(context, isBirth: false),
            ),
            const SizedBox(height: 24),

            // 照片上传
            _buildPhotoUpload(),
            const SizedBox(height: 24),

            // 纪念文字
            _buildDescriptionField(),
            const SizedBox(height: 24),

            // 隐私设置
            _buildPrivacySettings(),
            const SizedBox(height: 32),

            // 创建按钮
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '逝者姓名',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: '请输入逝者姓名'),
          validator: (value) => FormValidators.validateName(value, fieldName: '逝者姓名'),
        ),
      ],
    );
  }

  Widget _buildRelationshipField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '与逝者关系',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showRelationshipPicker,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedRelationship,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                      : '请选择日期',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '照片',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            if (_selectedImages.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedImages.length}/9',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // 添加照片按钮
        InkWell(
          onTap: _selectedImages.length < 9 ? _pickImages : null,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: _selectedImages.length < 9
                  ? AppColors.surfaceVariant.withValues(alpha: 0.4)
                  : AppColors.surfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _selectedImages.length < 9
                    ? AppColors.cardBorder
                    : AppColors.cardBorder.withValues(alpha: 0.5),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedImages.length < 9
                      ? Icons.add_photo_alternate
                      : Icons.block,
                  size: 32,
                  color: _selectedImages.length < 9
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImages.length < 9 ? '点击添加照片' : '最多可添加9张照片',
                  style: TextStyle(
                    color: _selectedImages.length < 9
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_selectedImages.isNotEmpty && _selectedImages.length < 9)
                  Text(
                    '还可添加${9 - _selectedImages.length}张',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 显示已选择的照片
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
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

        // 压缩提示
        if (_isCompressing)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '正在压缩照片...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '纪念文字',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(hintText: '写下您想说的话...'),
          maxLines: 4,
          validator: (value) => FormValidators.validateDescription(value, fieldName: '纪念文字'),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '隐私设置',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('公开'),
                value: true,
                groupValue: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('仅自己可见'),
                value: false,
                groupValue: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _createMemorial,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedImages.isNotEmpty ? '上传图片中...' : '创建中...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            : const Text(
                '创建纪念',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isBirth,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirth ? DateTime(1980) : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
      helpText: isBirth ? '选择出生日期' : '选择离世日期',
      cancelText: '取消',
      confirmText: '确定',
      fieldLabelText: isBirth ? '出生日期' : '离世日期',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '日期格式错误',
      errorInvalidText: '日期无效',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBirth) {
          _birthDate = picked;
        } else {
          _deathDate = picked;
        }
      });
    }
  }

  Widget _buildSelectedImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: PlatformImage(
            imagePath: image.path,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(11),
            placeholder: Container(
              color: AppColors.surfaceVariant,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: Container(
              color: AppColors.surfaceVariant,
              child: const Center(
                child: Icon(
                  Icons.error,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // 检查总数量限制
        final remainingSlots = 9 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        if (imagesToAdd.length < images.length) {
          if (mounted) {
            ErrorHandler.showWarning(context, '最多只能选择9张照片，已选择前${imagesToAdd.length}张');
          }
        }

        setState(() {
          _isCompressing = true;
        });

        // 转换为File对象并验证
        final newImages = <File>[];
        for (final xfile in imagesToAdd) {
          final file = File(xfile.path);
          // 验证文件确实存在
          if (await file.exists()) {
            newImages.add(file);
          } else {
            debugPrint('Selected image file does not exist: ${xfile.path}');
          }
        }

        if (newImages.isEmpty) {
          setState(() {
            _isCompressing = false;
          });
          if (mounted) {
            ErrorHandler.showError(context, '所选图片无效，请重新选择');
          }
          return;
        }

        // 压缩图片
        final compressedImages = await ImageHelper.compressImages(newImages);

        // 只添加压缩成功的图片
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
          ErrorHandler.showInfo(context, '成功添加${validImages.length}张图片');
        }
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });

      debugPrint('Error picking images: $e');
      if (mounted) {
        ErrorHandler.showError(context, '选择图片失败: $e');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showRelationshipPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部指示器
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '选择与逝者的关系',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 关系选项列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _relationships.length,
                itemBuilder: (context, index) {
                  final relationship = _relationships[index];
                  final isSelected = relationship == _selectedRelationship;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      relationship,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected 
                        ? Icon(
                            Icons.check,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedRelationship = relationship;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }


  void _createMemorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证日期
    final birthDateError = FormValidators.validateBirthDate(_birthDate);
    if (birthDateError != null) {
      ErrorHandler.showError(context, birthDateError);
      return;
    }

    final deathDateError = FormValidators.validateDeathDate(_deathDate, _birthDate);
    if (deathDateError != null) {
      ErrorHandler.showError(context, deathDateError);
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
          print('🔄 [CreatePage] Starting file upload...');
          final uploadedFiles = await _fileService.uploadFiles(_selectedImages);
          imageUrls = uploadedFiles.map((file) => file['url'] as String).toList();
          print('✅ [CreatePage] Files uploaded successfully: $imageUrls');
        } catch (e) {
          print('❌ [CreatePage] File upload failed: $e');
          // 暂时跳过文件上传错误，继续创建纪念
          if (mounted) {
            ErrorHandler.showWarning(context, '图片上传失败，但纪念已创建。您可以稍后编辑添加图片。');
          }
        }
      }

      // 创建纪念对象
      final memorial = Memorial(
        id: 0, // 后端会生成真实ID
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
          ErrorHandler.showSuccess(context, '纪念创建成功！');

          // 清空表单
          _resetForm();

          // 返回首页
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ErrorHandler.showError(context, provider.error ?? '创建失败');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, '图片上传失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedType = MemorialType.person;
      _selectedRelationship = '父亲';
      _birthDate = null;
      _deathDate = null;
      _selectedImages.clear();
      _isPublic = true;
      _isCompressing = false;
      _isUploading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
