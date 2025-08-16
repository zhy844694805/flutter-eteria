import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UIHelpers {
  // 创建标准的输入字段
  static Widget buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText ?? '请输入$label',
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  // 创建标准的按钮
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }

  // 创建标准的卡片容器
  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // 创建分割线
  static Widget buildDivider({String? text}) {
    if (text != null) {
      return Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      );
    }
    return const Divider();
  }

  // 创建空状态显示
  static Widget buildEmptyState({
    required IconData icon,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }

  // 创建标准的AppBar
  static PreferredSizeWidget buildAppBar({
    required String title,
    List<Widget>? actions,
    bool hasBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.background,
      leading: hasBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: onBackPressed,
            )
          : null,
      actions: actions,
    );
  }

  // 创建标准的页面布局
  static Widget buildPageLayout({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    bool hasBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    return Scaffold(
      appBar: buildAppBar(
        title: title,
        actions: actions,
        hasBackButton: hasBackButton,
        onBackPressed: onBackPressed,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  // 创建标准的列表项
  static Widget buildListTile({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  // 创建标准的状态小部件
  static Widget buildStatusChip({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}