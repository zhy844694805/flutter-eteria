import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DigitalLifePage extends StatelessWidget {
  const DigitalLifePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数字生命'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 即将上线图标
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 标题
              Text(
                '即将上线',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 描述
              Text(
                '数字生命功能正在开发中，敬请期待...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 功能预告
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '功能预告',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      icon: Icons.smart_toy,
                      title: 'AI对话',
                      description: '与逝者的AI形象进行对话',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      icon: Icons.memory,
                      title: '记忆重现',
                      description: '基于生前数据重现珍贵回忆',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      icon: Icons.video_library,
                      title: '虚拟影像',
                      description: '生成逝者的虚拟影像',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}