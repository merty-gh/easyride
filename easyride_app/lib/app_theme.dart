import 'package:flutter/material.dart';

class AppColors {
  // Основные акценты
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Фоны
  static const Color bg = Color(0xFFF1F5F9);
  static const Color bgSoft = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Текст
  static const Color text = Color(0xFF0F172A);
  static const Color text2 = Color(0xFF475569);
  static const Color text3 = Color(0xFF94A3B8);
  
  // Границы и тени
  static const Color border = Color(0x14000000);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.primary,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.text2),
        bodySmall: TextStyle(color: AppColors.text3),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleTextStyle: TextStyle(
          color: AppColors.text, 
          fontSize: 20, 
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}