import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF304166),
      surface: Color(0xFFFFFFFF),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),
    ),
  );
}
