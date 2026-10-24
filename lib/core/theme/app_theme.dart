import 'package:flutter/material.dart';

class AppColors {
  static const Color navyBlue = Color(0xFF0A192F);
  static const Color gold = Color(0xFFD4AF37);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F7);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyBlue,
        primary: AppColors.navyBlue,
        secondary: AppColors.gold,
        surface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.navyBlue,
      ),
    );
  }
}
