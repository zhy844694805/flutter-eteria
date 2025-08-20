import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 字体辅助工具 - 提供网络失败时的回退方案
class FontHelper {
  /// 安全地获取 Inter 字体，提供回退方案
  static TextStyle safeInter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (e) {
      // 网络失败时使用系统字体
      return TextStyle(
        fontFamily: _getSystemFontFamily(),
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  /// 安全地获取 NotoSans 字体，提供回退方案
  static TextStyle safeNotoSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.notoSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (e) {
      // 网络失败时使用系统字体
      return TextStyle(
        fontFamily: _getSystemFontFamily(),
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  /// 安全地获取 Inter TextTheme，提供回退方案
  static TextTheme safeInterTextTheme([TextTheme? textTheme]) {
    try {
      return GoogleFonts.interTextTheme(textTheme);
    } catch (e) {
      // 网络失败时使用系统字体的 TextTheme
      return _getSystemTextTheme(textTheme);
    }
  }

  /// 安全地获取 NotoSans TextTheme，提供回退方案
  static TextTheme safeNotoSansTextTheme([TextTheme? textTheme]) {
    try {
      return GoogleFonts.notoSansTextTheme(textTheme);
    } catch (e) {
      // 网络失败时使用系统字体的 TextTheme
      return _getSystemTextTheme(textTheme);
    }
  }

  /// 获取系统字体族名
  static String _getSystemFontFamily() {
    // 根据平台返回合适的系统字体
    return 'system'; // Flutter 会自动选择合适的系统字体
  }

  /// 获取系统字体的 TextTheme
  static TextTheme _getSystemTextTheme([TextTheme? textTheme]) {
    const systemFontFamily = 'system';
    final baseTheme = textTheme ?? ThemeData.light().textTheme;
    
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontFamily: systemFontFamily),
      displayMedium: baseTheme.displayMedium?.copyWith(fontFamily: systemFontFamily),
      displaySmall: baseTheme.displaySmall?.copyWith(fontFamily: systemFontFamily),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontFamily: systemFontFamily),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontFamily: systemFontFamily),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontFamily: systemFontFamily),
      titleLarge: baseTheme.titleLarge?.copyWith(fontFamily: systemFontFamily),
      titleMedium: baseTheme.titleMedium?.copyWith(fontFamily: systemFontFamily),
      titleSmall: baseTheme.titleSmall?.copyWith(fontFamily: systemFontFamily),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontFamily: systemFontFamily),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontFamily: systemFontFamily),
      bodySmall: baseTheme.bodySmall?.copyWith(fontFamily: systemFontFamily),
      labelLarge: baseTheme.labelLarge?.copyWith(fontFamily: systemFontFamily),
      labelMedium: baseTheme.labelMedium?.copyWith(fontFamily: systemFontFamily),
      labelSmall: baseTheme.labelSmall?.copyWith(fontFamily: systemFontFamily),
    );
  }
}