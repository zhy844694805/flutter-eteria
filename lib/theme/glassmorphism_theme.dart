import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// 玻璃拟态主题系统 - 专为纪念应用设计
/// 采用低饱和度配色和柔和的玻璃效果
class GlassmorphismColors {
  // 主色调 - 雾霾蓝系（突出核心元素）
  static const Color primary = Color(0xFF5C9EAD);       // 雾霾蓝
  static const Color primaryLight = Color(0xFF8BBCC9);  // 淡雾霾蓝
  static const Color primaryDark = Color(0xFF4A7F8A);   // 深雾霾蓝
  
  // 次要色调 - 莫兰迪绿系（点缀营造氛围）
  static const Color secondary = Color(0xFFA3B18A);     // 莫兰迪绿
  static const Color secondaryLight = Color(0xFFC3D0A4); // 淡莫兰迪绿
  static const Color secondaryDark = Color(0xFF8A9B71);  // 深莫兰迪绿
  
  // 背景色系 - 清新自然
  static const Color backgroundPrimary = Color(0xFFF8F9FA);   // 主背景（接近白的浅灰）
  static const Color backgroundSecondary = Color(0xFFF2F2F2); // 导航栏背景（比主背景稍深）
  static const Color backgroundTertiary = Color(0xFFFFFFFF);  // 卡片底色（保持干净）
  
  // 玻璃拟态表面色
  static const Color glassSurface = Color(0x40FFFFFF);    // 40% 白色透明
  static const Color glassSecondary = Color(0x25F8F9FA);  // 25% 背景透明
  static const Color glassBorder = Color(0x50FFFFFF);     // 50% 白色边框
  
  // 文字颜色 - 清晰层级
  static const Color textPrimary = Color(0xFF333333);     // 标题文字
  static const Color textSecondary = Color(0xFF666666);   // 副标题/主要内容
  static const Color textTertiary = Color(0xFF999999);    // 次要信息/说明文字
  static const Color textDisabled = Color(0xFFCCCCCC);    // 禁用/不活跃
  static const Color textOnGlass = Color(0xFF333333);     // 玻璃上文字
  
  // 状态色 - 低饱和度版本
  static const Color success = Color(0xFF7FB069);         // 柔和绿
  static const Color warning = Color(0xFFE6A84F);         // 柔和橙
  static const Color error = Color(0xFFD97C7C);           // 柔和红
  static const Color info = Color(0xFF7BAAD9);            // 柔和蓝
  
  // 分割线和边框
  static const Color divider = Color(0xFFE5E5E5);        // 分割线/边框
  
  // 阴影和边框
  static const Color shadowLight = Color(0x08000000);     // 极淡阴影
  static const Color shadowMedium = Color(0x12000000);    // 中等阴影
  static const Color shadowHeavy = Color(0x20000000);     // 重阴影
  
  // 渐变色组合
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundPrimary,
      backgroundSecondary,
      backgroundTertiary,
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

/// 玻璃拟态装饰样式集合
class GlassmorphismDecorations {
  /// 标准玻璃拟态卡片
  static BoxDecoration get glassCard => BoxDecoration(
    gradient: GlassmorphismColors.glassGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: GlassmorphismColors.glassBorder,
      width: 1.5,
    ),
    boxShadow: const [
      BoxShadow(
        color: GlassmorphismColors.shadowLight,
        blurRadius: 20,
        offset: Offset(0, 8),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: GlassmorphismColors.shadowMedium,
        blurRadius: 40,
        offset: Offset(0, 4),
        spreadRadius: -8,
      ),
    ],
  );
  
  /// 悬浮状态玻璃卡片
  static BoxDecoration get glassCardHover => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x50FFFFFF),
        Color(0x30FFFFFF),
        Color(0x20FFFFFF),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: GlassmorphismColors.glassBorder,
      width: 2.0,
    ),
    boxShadow: const [
      BoxShadow(
        color: GlassmorphismColors.shadowMedium,
        blurRadius: 30,
        offset: Offset(0, 12),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: GlassmorphismColors.shadowHeavy,
        blurRadius: 60,
        offset: Offset(0, 8),
        spreadRadius: -12,
      ),
    ],
  );
  
  /// 毛玻璃背景模糊
  static Widget glassBlur({
    required Widget child,
    double sigmaX = 10.0,
    double sigmaY = 10.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
  
  /// 输入框玻璃拟态样式
  static InputDecoration glassInput({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: GlassmorphismColors.glassSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: GlassmorphismColors.glassBorder,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: GlassmorphismColors.glassBorder,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: GlassmorphismColors.primary,  // 雾霾蓝边框
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: GlassmorphismColors.textTertiary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// 玻璃拟态主题配置
class GlassmorphismTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      
      // 颜色方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassmorphismColors.primary,
        brightness: Brightness.light,
        primary: GlassmorphismColors.primary,
        onPrimary: Colors.white,
        primaryContainer: GlassmorphismColors.primaryLight,
        onPrimaryContainer: GlassmorphismColors.textPrimary,
        secondary: GlassmorphismColors.secondary,
        onSecondary: Colors.white,
        surface: GlassmorphismColors.backgroundPrimary,
        onSurface: GlassmorphismColors.textPrimary,
        surfaceContainerHighest: GlassmorphismColors.backgroundSecondary,
        onSurfaceVariant: GlassmorphismColors.textSecondary,
      ),
      
      // 极简字体排版 - Inter字体系统
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // 标题字体 - 更轻量化
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w300,  // 极细
          color: GlassmorphismColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0,
          height: 1.3,
        ),
        
        // 标题字体
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        
        // 正文字体
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0.15,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: GlassmorphismColors.textSecondary,
          letterSpacing: 0.4,
          height: 1.5,
        ),
        
        // 标签字体
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textSecondary,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: GlassmorphismColors.textTertiary,
          letterSpacing: 0.5,
          height: 1.3,
        ),
      ),
      
      // 应用栏主题 - 透明玻璃效果
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: GlassmorphismColors.textPrimary,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(
          color: GlassmorphismColors.textSecondary,
          size: 24,
        ),
      ),
      
      // 卡片主题 - 清新自然
      cardTheme: CardThemeData(
        color: GlassmorphismColors.backgroundTertiary,  // 纯白色卡片
        surfaceTintColor: Colors.transparent,
        elevation: 2,  // 轻微投影
        shadowColor: GlassmorphismColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),  // 稍微减小圆角
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 按钮主题 - 玻璃质感
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassmorphismColors.glassSurface,
          foregroundColor: GlassmorphismColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: GlassmorphismColors.glassBorder,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GlassmorphismColors.backgroundSecondary,
        selectedItemColor: GlassmorphismColors.primary,     // 雾霾蓝
        unselectedItemColor: GlassmorphismColors.textTertiary,  // #999999
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // 背景色
      scaffoldBackgroundColor: GlassmorphismColors.backgroundPrimary,
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: GlassmorphismColors.divider,  // #E5E5E5
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}