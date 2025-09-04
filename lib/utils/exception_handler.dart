import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'error_handler.dart';

/// 全局异常处理器
class ExceptionHandler {
  static bool _initialized = false;

  /// 初始化全局异常处理
  static void initialize() {
    if (_initialized) return;
    
    // 捕获Flutter框架异常
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError('Flutter Framework Error', details.exception, details.stack);
      
      // 在Debug模式下显示错误详情
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // 捕获异步异常
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Async Error', error, stack);
      return true;
    };

    _initialized = true;
  }

  /// 记录错误日志
  static void _logError(String category, Object error, StackTrace? stack) {
    debugPrint('🚨 [$category] ${DateTime.now().toIso8601String()}');
    debugPrint('Error: $error');
    if (stack != null) {
      debugPrint('Stack trace:');
      debugPrint(stack.toString());
    }
    debugPrint('─' * 80);
  }

  /// 处理网络错误
  static String handleNetworkError(Object error) {
    if (error is SocketException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is TimeoutException) {
      return '请求超时，请重试';
    } else if (error is HttpException) {
      return '服务器响应错误: ${error.message}';
    } else if (error.toString().contains('Connection refused')) {
      return '无法连接到服务器，请稍后重试';
    } else if (error.toString().contains('Network is unreachable')) {
      return '网络不可达，请检查网络连接';
    }
    
    return '网络错误: ${error.toString()}';
  }

  /// 处理API错误
  static String handleApiError(Object error) {
    final errorString = error.toString().replaceAll('Exception: ', '');
    
    // 常见API错误映射
    const errorMappings = {
      'User not found': '用户不存在',
      'Invalid credentials': '用户名或密码错误',
      'Token expired': '登录已过期，请重新登录',
      'Access denied': '访问被拒绝',
      'Resource not found': '资源不存在',
      'Validation failed': '数据验证失败',
      'File too large': '文件太大',
      'Unsupported file type': '不支持的文件类型',
      'Email already registered': '邮箱已被注册',
      'Invalid verification code': '验证码错误或已过期',
    };

    for (final entry in errorMappings.entries) {
      if (errorString.contains(entry.key)) {
        return entry.value;
      }
    }

    return errorString.isEmpty ? '未知错误' : errorString;
  }

  /// 安全执行异步操作
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      _logError('Safe Execute', e, stack);
      
      final friendlyMessage = errorMessage ?? 
        (e is SocketException || e is TimeoutException || e is HttpException 
          ? handleNetworkError(e) 
          : handleApiError(e));

      if (showError && context != null && context.mounted) {
        ErrorHandler.showError(context, friendlyMessage);
      }
      
      return null;
    }
  }

  /// 安全执行同步操作
  static T? safeExecuteSync<T>(
    T Function() operation, {
    BuildContext? context,
    String? errorMessage,
    bool showError = true,
  }) {
    try {
      return operation();
    } catch (e, stack) {
      _logError('Safe Execute Sync', e, stack);
      
      final friendlyMessage = errorMessage ?? '操作失败: ${e.toString()}';

      if (showError && context != null && context.mounted) {
        ErrorHandler.showError(context, friendlyMessage);
      }
      
      return null;
    }
  }

  /// 处理异步操作结果
  static Future<bool> handleAsyncResult<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? successMessage,
    String? errorMessage,
    bool showSuccess = false,
    bool showError = true,
  }) async {
    try {
      await operation();
      
      if (showSuccess && successMessage != null && context != null && context.mounted) {
        ErrorHandler.showSuccess(context, successMessage);
      }
      
      return true;
    } catch (e, stack) {
      _logError('Handle Async Result', e, stack);
      
      final friendlyMessage = errorMessage ?? 
        (e is SocketException || e is TimeoutException || e is HttpException 
          ? handleNetworkError(e) 
          : handleApiError(e));

      if (showError && context != null && context.mounted) {
        ErrorHandler.showError(context, friendlyMessage);
      }
      
      return false;
    }
  }

  /// 断路器模式 - 防止频繁失败的操作
  static final Map<String, _CircuitBreaker> _circuitBreakers = {};

  static Future<T?> withCircuitBreaker<T>(
    String key,
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    int failureThreshold = 3,
    Duration recoveryTime = const Duration(minutes: 1),
  }) async {
    final breaker = _circuitBreakers.putIfAbsent(
      key,
      () => _CircuitBreaker(failureThreshold, recoveryTime),
    );

    if (breaker.isOpen) {
      throw Exception('Circuit breaker is open for $key');
    }

    try {
      final result = await operation().timeout(timeout);
      breaker.recordSuccess();
      return result;
    } catch (e) {
      breaker.recordFailure();
      rethrow;
    }
  }
}

/// 断路器实现
class _CircuitBreaker {
  final int failureThreshold;
  final Duration recoveryTime;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  _CircuitBreaker(this.failureThreshold, this.recoveryTime);

  bool get isOpen {
    if (_failureCount < failureThreshold) return false;
    
    if (_lastFailureTime == null) return false;
    
    return DateTime.now().difference(_lastFailureTime!) < recoveryTime;
  }

  void recordSuccess() {
    _failureCount = 0;
    _lastFailureTime = null;
  }

  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
  }
}

/// 错误状态枚举
enum ErrorType {
  network,
  api,
  validation,
  storage,
  permission,
  unknown
}

/// 错误信息类
class AppError {
  final ErrorType type;
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code)';
  }
}