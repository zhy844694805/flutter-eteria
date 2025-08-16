import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 主色调 - 基于HTML原型的暖色调
  static const Color primary = Color(0xFF8B7D6B); // rgba(139, 125, 107, 1)
  static const Color primaryLight = Color(0xFFEBE6DD); // rgba(235, 230, 221, 1)
  static const Color primaryDark = Color(0xFF6B5B47); // rgba(107, 91, 71, 1)
  
  // 背景色
  static const Color background = Color(0xFFF5F2ED); // rgba(245, 242, 237, 1)
  static const Color surface = Color(0xFFEBE6DD); // rgba(235, 230, 221, 0.7)
  static const Color surfaceVariant = Color(0xFFF0EBE2);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF4A453F); // rgba(74, 69, 63, 1)
  static const Color textSecondary = Color(0xFF8B7D6B); // rgba(139, 125, 107, 1)
  static const Color textTertiary = Color(0xFFB0A494); // rgba(176, 164, 148, 1)
  
  // 卡片颜色
  static const Color cardBackground = Color(0xFFEBE6DD);
  static const Color cardBorder = Color(0x1F8B7D6B); // rgba(139, 125, 107, 0.12)
  
  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 透明色
  static const Color shadowLight = Color(0x0F8B7D6B); // rgba(139, 125, 107, 0.06)
  static const Color shadowMedium = Color(0x1F8B7D6B); // rgba(139, 125, 107, 0.12)
  static const Color overlay = Color(0x4D000000); // rgba(0, 0, 0, 0.3)
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
      ),
      
      // 字体主题
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        headlineSmall: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
        titleSmall: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
          letterSpacing: 0.2,
        ),
      ),
      
      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Scaffold背景色
      scaffoldBackgroundColor: AppColors.background,
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
      
      // 分割线颜色
      dividerColor: AppColors.cardBorder,
    );
  }
}

// 常用的装饰样式
class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.cardBorder,
      width: 1,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get backgroundDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.surfaceVariant,
        AppColors.background,
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );
}