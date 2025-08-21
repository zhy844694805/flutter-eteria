import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_hover_card.dart';
import '../widgets/glass_interactive_widgets.dart' hide GlassHoverCard;
import '../widgets/glass_icons.dart';

/// 通知设置页面
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _commentNotifications = true;
  bool _flowerNotifications = true;
  bool _anniversaryReminders = true;
  bool _systemUpdates = false;
  bool _marketingEmails = false;
  
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';
  bool _quietHoursEnabled = true;
  String _reminderDays = '提前1天';
  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildGeneralNotificationSection(),
                            const SizedBox(height: 16),
                            _buildInteractionNotificationSection(),
                            const SizedBox(height: 16),
                            _buildReminderSection(),
                            const SizedBox(height: 16),
                            _buildQuietHoursSection(),
                            const SizedBox(height: 16),
                            _buildOtherNotificationSection(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                          ],
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
        '通知设置',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: GlassmorphismColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGeneralNotificationSection() {
    return GlassHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '通知方式',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSwitchTile(
            icon: Icons.push_pin_outlined,
            title: '推送通知',
            subtitle: '接收应用推送的消息通知',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: '邮件通知',
            subtitle: '接收发送到邮箱的通知消息',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionNotificationSection() {
    return GlassHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '互动通知',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSwitchTile(
            icon: Icons.chat_bubble_outline,
            title: '新留言通知',
            subtitle: '有人在您的纪念页面留言时通知',
            value: _commentNotifications,
            onChanged: (value) {
              setState(() {
                _commentNotifications = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.local_florist_outlined,
            title: '献花通知',
            subtitle: '有人为您的纪念献花时通知',
            value: _flowerNotifications,
            onChanged: (value) {
              setState(() {
                _flowerNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return GlassHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '纪念提醒',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSwitchTile(
            icon: Icons.schedule_outlined,
            title: '纪念日提醒',
            subtitle: '在重要纪念日前提醒您',
            value: _anniversaryReminders,
            onChanged: (value) {
              setState(() {
                _anniversaryReminders = value;
              });
            },
          ),
          
          if (_anniversaryReminders) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '提醒时间',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildReminderOption('提前1天', _reminderDays == '提前1天'),
                      _buildReminderOption('提前3天', _reminderDays == '提前3天'),
                      _buildReminderOption('提前7天', _reminderDays == '提前7天'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return GlassHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bedtime_outlined,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '免打扰时间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSwitchTile(
            icon: Icons.do_not_disturb_outlined,
            title: '启用免打扰',
            subtitle: '在指定时间段内不接收推送通知',
            value: _quietHoursEnabled,
            onChanged: (value) {
              setState(() {
                _quietHoursEnabled = value;
              });
            },
          ),
          
          if (_quietHoursEnabled) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: '开始时间',
                    time: _quietHoursStart,
                    onTap: () => _selectTime(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    label: '结束时间',
                    time: _quietHoursEnd,
                    onTap: () => _selectTime(false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherNotificationSection() {
    return GlassHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.more_horiz_outlined,
                color: GlassmorphismColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '其他通知',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSwitchTile(
            icon: Icons.system_update_outlined,
            title: '系统更新',
            subtitle: '应用更新和维护通知',
            value: _systemUpdates,
            onChanged: (value) {
              setState(() {
                _systemUpdates = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.campaign_outlined,
            title: '推广邮件',
            subtitle: '产品功能介绍和活动信息',
            value: _marketingEmails,
            onChanged: (value) {
              setState(() {
                _marketingEmails = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassmorphismColors.glassSurface.withValues(alpha: 0.2),
            GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlassmorphismColors.primary.withValues(alpha: 0.2),
                  GlassmorphismColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlassmorphismColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GlassmorphismColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildGlassSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildGlassSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          gradient: value
              ? LinearGradient(
                  colors: [
                    GlassmorphismColors.primary,
                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? GlassmorphismColors.primary.withValues(alpha: 0.5)
                : GlassmorphismColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            if (value)
              BoxShadow(
                color: GlassmorphismColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: GlassmorphismColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _reminderDays = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    GlassmorphismColors.primary,
                    GlassmorphismColors.primary.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  colors: [
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.2),
                    GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? GlassmorphismColors.primary.withValues(alpha: 0.5)
                : GlassmorphismColors.glassBorder.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: GlassmorphismColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Colors.white
                : GlassmorphismColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlassmorphismColors.glassSurface.withValues(alpha: 0.3),
              GlassmorphismColors.glassSurface.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassmorphismColors.glassBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GlassmorphismColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: GlassmorphismColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GlassmorphismColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: GlassmorphismColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return GlassInteractiveButton(
      text: _isSaving ? '保存中...' : '保存设置',
      icon: _isSaving ? null : Icons.save_outlined,
      onPressed: _isSaving ? null : _saveSettings,
      height: 56,
      backgroundColor: GlassmorphismColors.primary.withValues(alpha: 0.1),
      foregroundColor: GlassmorphismColors.primary,
      isLoading: _isSaving,
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final currentTime = isStartTime ? _quietHoursStart : _quietHoursEnd;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: GlassmorphismColors.primary,
              onPrimary: Colors.white,
              surface: GlassmorphismColors.backgroundPrimary,
              onSurface: GlassmorphismColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _quietHoursStart = formattedTime;
        } else {
          _quietHoursEnd = formattedTime;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: 实现保存通知设置的逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟API调用
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('通知设置保存成功'),
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('保存失败，请稍后重试'),
            backgroundColor: GlassmorphismColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}