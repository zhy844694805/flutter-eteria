import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart';
import '../widgets/glass_form_field.dart';
import '../widgets/platform_image.dart';
import '../utils/image_helper.dart';

/// 个人信息设置页面
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isSaving = false;
  File? _selectedAvatarFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    
    _pageController.forward();
    _initializeUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
        ),
        child: AnimatedBuilder(
          animation: _pageAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * _pageAnimation.value),
              child: Opacity(
                opacity: _pageAnimation.value.clamp(0.0, 1.0),
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    _buildAvatarSection(),
                    _buildPersonalInfoForm(),
                    _buildActionSection(),
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.glassGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: GlassmorphismColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        '个人信息',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return SliverToBoxAdapter(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) return const SizedBox.shrink();
          
          return Container(
            margin: const EdgeInsets.all(16),
            child: GlassHoverCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 头像
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              GlassmorphismColors.primary.withValues(alpha: 0.1),
                              GlassmorphismColors.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GlassmorphismColors.glassBorder,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GlassmorphismColors.shadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedAvatarFile != null
                              ? Image.file(
                                  _selectedAvatarFile!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : user.avatar?.isNotEmpty == true
                                  ? PlatformImage(
                                      imagePath: user.avatar!,
                                      fit: BoxFit.cover,
                                      placeholder: _buildDefaultAvatar(user),
                                      errorWidget: _buildDefaultAvatar(user),
                                    )
                                  : _buildDefaultAvatar(user),
                        ),
                      ),
                      
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _changeAvatar,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    GlassmorphismColors.primary,
                                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 认证状态
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (user.isVerified 
                          ? GlassmorphismColors.success 
                          : GlassmorphismColors.warning)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (user.isVerified 
                            ? GlassmorphismColors.success 
                            : GlassmorphismColors.warning)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isVerified ? Icons.verified : Icons.warning,
                          size: 16,
                          color: user.isVerified 
                              ? GlassmorphismColors.success 
                              : GlassmorphismColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.isVerified ? '已认证用户' : '未认证用户',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: user.isVerified 
                                ? GlassmorphismColors.success 
                                : GlassmorphismColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            GlassmorphismColors.primary.withValues(alpha: 0.3),
            GlassmorphismColors.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '用',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: GlassmorphismColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassHoverCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: GlassmorphismColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '基本信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlassmorphismColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 姓名
                GlassFormField(
                  controller: _nameController,
                  label: '姓名',
                  prefixIcon: Icon(Icons.person_outline, color: GlassmorphismColors.primary),
                  enabled: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '请输入姓名';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 邮箱
                GlassFormField(
                  controller: _emailController,
                  label: '邮箱',
                  prefixIcon: Icon(Icons.email_outlined, color: GlassmorphismColors.primary),
                  enabled: false, // 邮箱不能修改
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 16),
                
                // 手机号
                GlassFormField(
                  controller: _phoneController,
                  label: '手机号',
                  prefixIcon: Icon(Icons.phone_outlined, color: GlassmorphismColors.primary),
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // 移除严格的手机号格式限制，只检查基本格式
                    if (value?.isNotEmpty == true && value!.length < 6) {
                      return '请输入有效的联系号码';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: GlassInteractiveButton(
          text: _isSaving ? '保存中...' : '保存修改',
          icon: _isSaving ? null : Icons.save,
          onPressed: _isSaving ? null : _saveChanges,
          height: 50,
          backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.1),
          foregroundColor: GlassmorphismColors.primary,
          isLoading: _isSaving,
        ),
      ),
    );
  }


  void _changeAvatar() {
    HapticFeedback.lightImpact();
    _showAvatarSelectionDialog();
  }

  void _showAvatarSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: GlassmorphismColors.backgroundGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部指示器
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlassmorphismColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // 标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '更换头像',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 选项
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildAvatarOption(
                        icon: Icons.camera_alt_outlined,
                        title: '拍照',
                        subtitle: '使用相机拍摄新头像',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromCamera();
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildAvatarOption(
                        icon: Icons.photo_library_outlined,
                        title: '从相册选择',
                        subtitle: '选择已有的照片作为头像',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromGallery();
                        },
                      ),
                      
                      if (_selectedAvatarFile != null || (_currentUser?.avatar?.isNotEmpty == true)) ...[
                        const SizedBox(height: 12),
                        _buildAvatarOption(
                          icon: Icons.delete_outline,
                          title: '移除头像',
                          subtitle: '使用默认头像',
                          onTap: () {
                            Navigator.pop(context);
                            _removeAvatar();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.glassGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.glassBorder,
            width: 1,
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
                    GlassmorphismColors.primary.withValues(alpha: 0.2),
                    GlassmorphismColors.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GlassmorphismColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: GlassmorphismColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      _showErrorMessage('拍照失败，请重试');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      _showErrorMessage('选择图片失败，请重试');
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    try {
      // 压缩图片
      final compressedFile = await ImageHelper.compressImage(
        File(image.path),
      );
      
      setState(() {
        _selectedAvatarFile = compressedFile;
      });
      
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('头像已选择，请保存修改'),
            ],
          ),
          backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      _showErrorMessage('图片处理失败，请重试');
    }
  }

  void _removeAvatar() {
    setState(() {
      _selectedAvatarFile = null;
    });
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('头像已移除，请保存修改'),
        backgroundColor: GlassmorphismColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  User? get _currentUser {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // TODO: 实现头像上传功能
      if (_selectedAvatarFile != null) {
        // 这里应该调用文件上传API
        print('📷 需要上传头像: ${_selectedAvatarFile!.path}');
        // 可以使用现有的FileService来上传头像
        // final uploadedFileUrl = await FileService.uploadSingleFile(_selectedAvatarFile!);
      }
      
      // TODO: 调用API更新用户信息
      final updateData = {
        'name': _nameController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        // 如果上传了头像，这里应该包含头像URL
        // 'avatar_url': uploadedFileUrl,
      };
      
      print('📝 需要更新的用户信息: $updateData');
      
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _selectedAvatarFile = null; // 清除选择的头像
        });
        
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('个人信息更新成功'),
              ],
            ),
            backgroundColor: GlassmorphismColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        _showErrorMessage('更新失败，请稍后重试');
      }
    }
  }
}