import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorHandler {
  // 显示成功消息
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示错误消息
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示警告消息
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示信息消息
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示确认对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDangerous = false,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // 显示loading对话框
  static void showLoadingDialog(BuildContext context, {String message = '处理中...'}) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // 隐藏对话框
  static void hideDialog(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  // 处理异步操作的通用方法
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showLoading = true,
    bool showSuccess = false,
    bool showError = true,
    Duration? timeout,
  }) async {
    if (!context.mounted) return null;

    try {
      if (showLoading && loadingMessage != null) {
        showLoadingDialog(context, message: loadingMessage);
      }

      final Future<T> futureOperation = timeout != null 
          ? operation().timeout(timeout)
          : operation();
      
      final result = await futureOperation;

      if (context.mounted) {
        if (showLoading && loadingMessage != null) {
          hideDialog(context);
        }

        if (showSuccess && successMessage != null) {
          ErrorHandler.showSuccess(context, successMessage);
        }
      }

      return result;
    } catch (e) {
      if (context.mounted) {
        if (showLoading && loadingMessage != null) {
          hideDialog(context);
        }

        if (showError) {
          final message = errorMessage ?? _getErrorMessage(e);
          ErrorHandler.showError(context, message);
        }
      }
      return null;
    }
  }
  
  // 获取友好的错误消息
  static String _getErrorMessage(Object error) {
    final errorString = error.toString();
    
    if (errorString.contains('SocketException') || 
        errorString.contains('Connection refused')) {
      return '网络连接失败，请检查网络设置';
    }
    
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return '请求超时，请重试';
    }
    
    if (errorString.contains('FormatException') ||
        errorString.contains('Invalid JSON')) {
      return '服务器响应格式错误';
    }
    
    // 移除Exception前缀
    final cleanError = errorString.replaceAll('Exception: ', '').trim();
    return cleanError.isEmpty ? '操作失败，请重试' : cleanError;
  }
  
  // 显示网络错误提示
  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('网络连接失败'),
          ],
        ),
        content: const Text('请检查网络连接后重试'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('重试'),
            ),
        ],
      ),
    );
  }
}