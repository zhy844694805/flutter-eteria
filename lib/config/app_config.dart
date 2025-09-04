import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;
  
  // Environment detection
  static Environment get environment => _environment;
  
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
  
  // Initialize environment
  static void initialize(Environment env) {
    _environment = env;
    if (kDebugMode) {
      print('🚀 App initialized in ${env.name} mode');
    }
  }
  
  // App Information
  static const String appName = 'Eteria';
  static const String appTitle = '永念';
  static const String appSubtitle = '网上纪念';
  static const String appDescription = '一个用于缅怀逝者和宠物的纪念应用';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  
  // API Configuration
  static String get baseApiUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://127.0.0.1:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.eteria.com/api/v1';
      case Environment.production:
        return 'https://api.eteria.com/api/v1';
    }
  }
  
  static String get webSocketUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://127.0.0.1:3000/ws';
      case Environment.staging:
        return 'wss://staging-api.eteria.com/ws';
      case Environment.production:
        return 'wss://api.eteria.com/ws';
    }
  }
  
  // Feature Flags
  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static bool get enableCrashlytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static bool get enableDebugLogging {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return kDebugMode;
      case Environment.production:
        return false;
    }
  }
  
  static bool get enablePerformanceMonitoring {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  // Cache Configuration
  static Duration get defaultCacheDuration {
    switch (_environment) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 30);
      case Environment.production:
        return const Duration(hours: 2);
    }
  }
  
  static int get maxCacheSize {
    switch (_environment) {
      case Environment.development:
        return 50; // 50MB
      case Environment.staging:
        return 100; // 100MB
      case Environment.production:
        return 200; // 200MB
    }
  }
  
  // Network Configuration
  static Duration get networkTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
  
  static int get maxRetryAttempts {
    switch (_environment) {
      case Environment.development:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 3;
    }
  }
  
  // Storage Configuration
  static String get storagePrefix {
    switch (_environment) {
      case Environment.development:
        return 'eteria_dev_';
      case Environment.staging:
        return 'eteria_staging_';
      case Environment.production:
        return 'eteria_';
    }
  }
  
  // Security Configuration
  static bool get enableCertificatePinning {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static bool get enableBiometricAuth {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  // Google OAuth Configuration
  static String get googleClientId {
    switch (_environment) {
      case Environment.development:
        return 'dev-google-client-id';
      case Environment.staging:
        return 'staging-google-client-id';
      case Environment.production:
        return 'prod-google-client-id';
    }
  }
  
  // Analytics Configuration
  static String get analyticsTrackingId {
    switch (_environment) {
      case Environment.development:
        return '';
      case Environment.staging:
        return 'GA-STAGING-ID';
      case Environment.production:
        return 'GA-PRODUCTION-ID';
    }
  }
  
  // Image Configuration
  static int get maxImageSize {
    return 10 * 1024 * 1024; // 10MB
  }
  
  static int get imageQuality {
    switch (_environment) {
      case Environment.development:
        return 85;
      case Environment.staging:
        return 80;
      case Environment.production:
        return 75;
    }
  }
  
  // Pagination Configuration
  static int get defaultPageSize {
    return 10;
  }
  
  static int get maxPageSize {
    return 50;
  }
  
  // Database Configuration
  static String get databaseName {
    switch (_environment) {
      case Environment.development:
        return 'eteria_dev.db';
      case Environment.staging:
        return 'eteria_staging.db';
      case Environment.production:
        return 'eteria.db';
    }
  }
  
  static int get databaseVersion {
    return 1;
  }
  
  // Localization Configuration
  static const List<String> supportedLanguages = ['zh', 'en'];
  static const String defaultLanguage = 'zh';
  static const String defaultCountry = 'CN';
  
  // Theme Configuration
  static bool get enableDynamicColor {
    return true;
  }
  
  static bool get enableGlassmorphism {
    return true;
  }
  
  // Testing Configuration
  static bool get isTestMode => kDebugMode && _environment == Environment.development;
  
  static bool get enableMockData => isTestMode;
  
  static bool get skipAnimations => isTestMode;
  
  // Debugging utilities
  static void printConfiguration() {
    if (!kDebugMode) return;
    
    print('=== APP CONFIGURATION ===');
    print('Environment: ${_environment.name}');
    print('API URL: $baseApiUrl');
    print('WebSocket URL: $webSocketUrl');
    print('Analytics Enabled: $enableAnalytics');
    print('Debug Logging: $enableDebugLogging');
    print('Cache Duration: ${defaultCacheDuration.inMinutes}min');
    print('Network Timeout: ${networkTimeout.inSeconds}s');
    print('Max Retry Attempts: $maxRetryAttempts');
    print('Storage Prefix: $storagePrefix');
    print('Database Name: $databaseName');
    print('=========================');
  }
  
  // Validation
  static bool validate() {
    if (baseApiUrl.isEmpty) {
      if (kDebugMode) print('❌ Base API URL is empty');
      return false;
    }
    
    if (isProduction && !baseApiUrl.startsWith('https://')) {
      if (kDebugMode) print('❌ Production API URL must use HTTPS');
      return false;
    }
    
    if (supportedLanguages.isEmpty) {
      if (kDebugMode) print('❌ No supported languages configured');
      return false;
    }
    
    if (!supportedLanguages.contains(defaultLanguage)) {
      if (kDebugMode) print('❌ Default language not in supported languages');
      return false;
    }
    
    return true;
  }
  
  // Reset configuration (for testing)
  static void reset() {
    _environment = Environment.development;
  }
}

// Environment-specific configurations
class DevelopmentConfig {
  static const bool showDebugBanner = true;
  static const bool enableSlowAnimations = false;
  static const bool enableInspector = true;
  static const bool enableServiceExtensions = true;
}

class StagingConfig {
  static const bool showDebugBanner = false;
  static const bool enableSlowAnimations = false;
  static const bool enableInspector = false;
  static const bool enableServiceExtensions = true;
}

class ProductionConfig {
  static const bool showDebugBanner = false;
  static const bool enableSlowAnimations = false;
  static const bool enableInspector = false;
  static const bool enableServiceExtensions = false;
}