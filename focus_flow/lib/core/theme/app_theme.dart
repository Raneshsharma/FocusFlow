import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ============================================
  // ELEVATION SHADOWS (from design.md)
  // ============================================

  static List<BoxShadow> elevation0 = [];
  static List<BoxShadow> elevation1 = [
    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> elevation2 = [
    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> elevation3 = [
    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> elevation4 = [
    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 8)),
  ];

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.light,
        primary: AppColors.teal,
        secondary: AppColors.amber,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.deepSlate,
        onPrimary: Colors.white,
        onSecondary: AppColors.deepSlate,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.surface,

      // AppBar — left-aligned (not centered)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepSlate,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Per design.md: left-aligned
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // FAB — Amber per design.md
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.deepSlate,
        elevation: 6, // FAB uses elevation 3 per design (6dp shadow)
        shape: CircleBorder(),
      ),

      // Navigation Bar — 56dp height per design
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.amber.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.amber,
            );
          }
          return const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.grey500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.amber, size: 24);
          }
          return const IconThemeData(color: AppColors.grey500, size: 24);
        }),
      ),

      // Text Theme — Montserrat for headings, Inter for body
      textTheme: const TextTheme(
        // Display
        displayLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        // Headings
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        // Titles
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Body
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // Labels
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // Chip Theme — energy chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999), // rounded-full
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Elevated Button — Primary CTA style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.deepSlate,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button — Ghost style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepSlate,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.grey200,
        thickness: 0.5,
        space: 24,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amber,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.amber;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.amber.withOpacity(0.5);
          }
          return AppColors.grey200;
        }),
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.dark,
        primary: AppColors.teal,
        secondary: AppColors.amber,
        surface: AppColors.deepSlate,
      ),
      scaffoldBackgroundColor: AppColors.deepSlate,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepSlate,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.charcoal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.deepSlate,
        elevation: 6,
        shape: CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        backgroundColor: AppColors.charcoal,
        indicatorColor: AppColors.amber.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // TIMER FONT (JetBrains Mono for timers)
  // ============================================

  static TextStyle timerStyle({double fontSize = 24, Color? color}) {
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textPrimary,
    );
  }
}