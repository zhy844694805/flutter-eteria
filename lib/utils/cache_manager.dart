import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存项
class CacheItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration maxAge;

  CacheItem(this.data, this.timestamp, this.maxAge);

  bool get isExpired => DateTime.now().difference(timestamp) > maxAge;

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'maxAge': maxAge.inMilliseconds,
  };

  factory CacheItem.fromJson(Map<String, dynamic> json, T Function(dynamic) fromData) {
    return CacheItem<T>(
      fromData(json['data']),
      DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      Duration(milliseconds: json['maxAge']),
    );
  }
}

/// 内存缓存管理器
class MemoryCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, Timer> _expirationTimers = {};

  static T? get<T>(String key) {
    final item = _cache[key] as CacheItem<T>?;
    if (item == null || item.isExpired) {
      remove(key);
      return null;
    }
    return item.data;
  }

  static void set<T>(String key, T data, Duration maxAge) {
    // 清除旧的定时器
    _expirationTimers[key]?.cancel();
    
    // 存储数据
    _cache[key] = CacheItem<T>(data, DateTime.now(), maxAge);
    
    // 设置过期定时器
    _expirationTimers[key] = Timer(maxAge, () => remove(key));
  }

  static void remove(String key) {
    _cache.remove(key);
    _expirationTimers[key]?.cancel();
    _expirationTimers.remove(key);
  }

  static void clear() {
    _cache.clear();
    _expirationTimers.values.forEach((timer) => timer.cancel());
    _expirationTimers.clear();
  }

  static int get size => _cache.length;
}

/// 持久化缓存管理器
class PersistentCache {
  static SharedPreferences? _prefs;
  static const String _prefix = 'eteria_cache_';

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<T?> get<T>(
    String key, 
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await initialize();
    
    final jsonString = _prefs?.getString('${_prefix}$key');
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final item = CacheItem.fromJson(json, (data) => fromJson(data as Map<String, dynamic>));
      
      if (item.isExpired) {
        await remove(key);
        return null;
      }
      
      return item.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PersistentCache] Failed to decode cached item: $e');
      }
      await remove(key);
      return null;
    }
  }

  static Future<void> set<T>(
    String key, 
    T data, 
    Duration maxAge,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await initialize();
    
    try {
      final item = CacheItem(data, DateTime.now(), maxAge);
      final json = {
        'data': toJson(data),
        'timestamp': item.timestamp.millisecondsSinceEpoch,
        'maxAge': item.maxAge.inMilliseconds,
      };
      
      await _prefs?.setString('${_prefix}$key', jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PersistentCache] Failed to cache item: $e');
      }
    }
  }

  static Future<void> remove(String key) async {
    await initialize();
    await _prefs?.remove('${_prefix}$key');
  }

  static Future<void> clear() async {
    await initialize();
    final keys = _prefs?.getKeys().where((key) => key.startsWith(_prefix)) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  static Future<List<String>> getAllKeys() async {
    await initialize();
    return _prefs?.getKeys()
        .where((key) => key.startsWith(_prefix))
        .map((key) => key.substring(_prefix.length))
        .toList() ?? [];
  }
}

/// 组合缓存管理器（内存+持久化）
class CacheManager {
  // 缓存配置
  static const Duration defaultMemoryDuration = Duration(minutes: 5);
  static const Duration defaultPersistentDuration = Duration(hours: 1);
  
  /// 获取缓存数据（优先内存，其次持久化）
  static Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // 先尝试内存缓存
    final memoryData = MemoryCache.get<T>(key);
    if (memoryData != null) {
      if (kDebugMode) {
        print('💾 [CacheManager] Memory cache hit: $key');
      }
      return memoryData;
    }

    // 再尝试持久化缓存
    final persistentData = await PersistentCache.get<T>(key, fromJson);
    if (persistentData != null) {
      // 将持久化数据放入内存缓存
      MemoryCache.set(key, persistentData, defaultMemoryDuration);
      if (kDebugMode) {
        print('💽 [CacheManager] Persistent cache hit: $key');
      }
      return persistentData;
    }

    if (kDebugMode) {
      print('❌ [CacheManager] Cache miss: $key');
    }
    return null;
  }

  /// 设置缓存数据
  static Future<void> set<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson, {
    Duration? memoryDuration,
    Duration? persistentDuration,
    bool memoryOnly = false,
  }) async {
    final memDuration = memoryDuration ?? defaultMemoryDuration;
    final perDuration = persistentDuration ?? defaultPersistentDuration;

    // 存入内存缓存
    MemoryCache.set(key, data, memDuration);

    // 存入持久化缓存（除非指定仅内存）
    if (!memoryOnly) {
      await PersistentCache.set(key, data, perDuration, toJson);
    }

    if (kDebugMode) {
      print('💾 [CacheManager] Cached: $key (memory: ${memDuration.inMinutes}m, persistent: ${perDuration.inHours}h)');
    }
  }

  /// 移除缓存
  static Future<void> remove(String key) async {
    MemoryCache.remove(key);
    await PersistentCache.remove(key);
    
    if (kDebugMode) {
      print('🗑️ [CacheManager] Removed cache: $key');
    }
  }

  /// 清除所有缓存
  static Future<void> clear() async {
    MemoryCache.clear();
    await PersistentCache.clear();
    
    if (kDebugMode) {
      print('🧹 [CacheManager] Cleared all cache');
    }
  }

  /// 获取缓存统计信息
  static Future<Map<String, dynamic>> getStats() async {
    final persistentKeys = await PersistentCache.getAllKeys();
    
    return {
      'memorySize': MemoryCache.size,
      'persistentSize': persistentKeys.length,
      'memoryKeys': MemoryCache._cache.keys.toList(),
      'persistentKeys': persistentKeys,
    };
  }

  /// 清理过期缓存
  static Future<void> cleanupExpired() async {
    final persistentKeys = await PersistentCache.getAllKeys();
    int cleanedCount = 0;
    
    for (final key in persistentKeys) {
      try {
        final jsonString = (await SharedPreferences.getInstance()).getString('${PersistentCache._prefix}$key');
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
          final maxAge = Duration(milliseconds: json['maxAge']);
          
          if (DateTime.now().difference(timestamp) > maxAge) {
            await PersistentCache.remove(key);
            cleanedCount++;
          }
        }
      } catch (e) {
        // 删除损坏的缓存项
        await PersistentCache.remove(key);
        cleanedCount++;
      }
    }
    
    if (kDebugMode && cleanedCount > 0) {
      print('🧹 [CacheManager] Cleaned $cleanedCount expired cache items');
    }
  }
}

/// 缓存策略枚举
enum CacheStrategy {
  /// 仅使用缓存，不发起网络请求
  cacheOnly,
  /// 优先使用缓存，缓存无效时发起网络请求
  cacheFirst,
  /// 优先发起网络请求，失败时使用缓存
  networkFirst,
  /// 仅发起网络请求，不使用缓存
  networkOnly,
}

/// 网络缓存辅助类
class NetworkCacheHelper {
  /// 执行带缓存的网络请求
  static Future<T?> executeWithCache<T>(
    String cacheKey,
    Future<T> Function() networkCall,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson, {
    CacheStrategy strategy = CacheStrategy.cacheFirst,
    Duration? cacheDuration,
  }) async {
    switch (strategy) {
      case CacheStrategy.cacheOnly:
        return await CacheManager.get<T>(cacheKey, fromJson);

      case CacheStrategy.cacheFirst:
        final cached = await CacheManager.get<T>(cacheKey, fromJson);
        if (cached != null) return cached;
        
        try {
          final networkData = await networkCall();
          await CacheManager.set(cacheKey, networkData, toJson, 
            persistentDuration: cacheDuration);
          return networkData;
        } catch (e) {
          return null;
        }

      case CacheStrategy.networkFirst:
        try {
          final networkData = await networkCall();
          await CacheManager.set(cacheKey, networkData, toJson,
            persistentDuration: cacheDuration);
          return networkData;
        } catch (e) {
          return await CacheManager.get<T>(cacheKey, fromJson);
        }

      case CacheStrategy.networkOnly:
        final networkData = await networkCall();
        await CacheManager.set(cacheKey, networkData, toJson,
          persistentDuration: cacheDuration);
        return networkData;
    }
  }
}