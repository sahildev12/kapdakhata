import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        brightness: brightness,
        primary: AppColors.primaryPurple,
        surface: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121216) : AppColors.white,
      dividerColor: AppColors.border,
    );

    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
      bodyColor: isDark ? AppColors.white : AppColors.primaryText,
      displayColor: isDark ? AppColors.white : AppColors.primaryText,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? const Color(0xFF121216) : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.primaryText,
        leadingWidth: 40,
        titleSpacing: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: AppLayout.titleSize,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: AppLayout.bodySize,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPurple,
          side: const BorderSide(color: AppColors.darkPurple),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: AppLayout.bodySize,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A2A30) : AppColors.border,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A2A30) : AppColors.border,
          ),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: AppLayout.titleSize,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.white : AppColors.neutralText,
          height: 1.45,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1F) : AppColors.white,
        headerBackgroundColor: AppColors.primaryPurple,
        headerForegroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        ),
        dayStyle: textTheme.bodyMedium,
        yearStyle: textTheme.bodyMedium,
      ),
    );
  }
}
