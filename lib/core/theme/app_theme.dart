import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFC83A2D);
  static const Color darkBlue = Color(0xFF1F4277);
  static const Color green = Color(0xFF1F9D57);
  static const Color yellow = Color(0xFFF2C94C);
  static const Color background = Color(0xFFF7F7F8); // Softer off-white
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF7B8190);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'SF Pro',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.yellow,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textDark),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textDark),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textDark),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textDark),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textDark),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 18, // Reduced from 20
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600, // Changed from w700 to Medium bold
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
