import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/form_validators.dart';
import '../services/feedback_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();
  
  FeedbackType _selectedType = FeedbackType.suggestion;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserContact();
  }

  void _loadUserContact() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _contactController.text = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('意见反馈'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroCard(),
                const SizedBox(height: 24),
                _buildFeedbackForm(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.feedback,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '您的意见对我们很重要',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '感谢您使用永念应用。我们非常重视每一位用户的意见和建议，您的反馈将帮助我们不断改进产品，为您提供更好的服务。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '我们将在1-3个工作日内回复您',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '反馈信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 反馈类型选择
          _buildFormField(
            label: '反馈类型',
            child: DropdownButtonFormField<FeedbackType>(
              initialValue: _selectedType,
              decoration: _getInputDecoration('请选择反馈类型'),
              items: FeedbackType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getFeedbackTypeIcon(type),
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(_getFeedbackTypeText(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // 反馈标题
          _buildFormField(
            label: '反馈标题',
            child: TextFormField(
              controller: _titleController,
              decoration: _getInputDecoration('请简述您的问题或建议'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入反馈标题';
                }
                if (value.trim().length < 5) {
                  return '标题至少需要5个字符';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // 详细描述
          _buildFormField(
            label: '详细描述',
            child: TextFormField(
              controller: _contentController,
              maxLines: 6,
              decoration: _getInputDecoration(
                '请详细描述您遇到的问题或改进建议...\n\n如果是Bug反馈，请包含：\n• 操作步骤\n• 预期结果\n• 实际结果\n• 设备信息',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入详细描述';
                }
                if (value.trim().length < 10) {
                  return '描述至少需要10个字符';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // 联系方式
          _buildFormField(
            label: '联系方式',
            child: TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
              decoration: _getInputDecoration('邮箱地址，用于接收回复'),
              validator: FormValidators.validateEmail,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '提交反馈',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedbackService = FeedbackService();
      await feedbackService.submitFeedback(
        type: _selectedType,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        contact: _contactController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('反馈提交成功，感谢您的宝贵意见！'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败：$e'),
            backgroundColor: AppColors.error,
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

  IconData _getFeedbackTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.suggestion:
        return Icons.lightbulb;
      case FeedbackType.complaint:
        return Icons.warning;
      case FeedbackType.praise:
        return Icons.thumb_up;
      case FeedbackType.other:
        return Icons.help;
    }
  }

  String _getFeedbackTypeText(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug反馈';
      case FeedbackType.suggestion:
        return '功能建议';
      case FeedbackType.complaint:
        return '问题投诉';
      case FeedbackType.praise:
        return '表扬赞美';
      case FeedbackType.other:
        return '其他';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}

