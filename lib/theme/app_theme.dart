import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_settings.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xfff2f3f4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff304166),
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF304166),
      onPrimary: Colors.white,
      surface: Color(0xFFFFFFFF),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xff304166),
      indicatorColor: const Color(0xff2D68FF),

      // --- ICON COLORS ---
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return IconThemeData(color: Colors.white.withOpacity(0.5));
      }),

      // --- LABEL COLORS ---
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12);
      }),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff304166),
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF304166),
      onPrimary: Colors.white,
      // Dashboard cards/sections use `surface` and `surfaceVariant`.
      // These are intentionally not near-black so borders remain visible.
      surface: Color(0xFF181A1F),
      surfaceVariant: Color(0xFF222634),
      onSurface: Color(0xFFE7EAF2),
      onSurfaceVariant: Color(0xFFC3CADB),
      outline: Color(0xFF3A4152),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xff304166),
      indicatorColor: const Color(0xff2D68FF),

      // --- ICON COLORS ---
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return IconThemeData(color: Colors.white.withOpacity(0.5));
      }),

      // --- LABEL COLORS ---
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12);
      }),
    ),
  );

  static final highContrastLightTheme = lightTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xfff2f3f4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff304166),
      foregroundColor: Colors.white,
    ),
    colorScheme: lightTheme.colorScheme.copyWith(
      primary: const Color(0xFF304166),
      surface: const Color(0xFFFFFFFF),
      onPrimary: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xff304166),
      indicatorColor: const Color(0xff2D68FF),

      // --- ICON COLORS ---
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return IconThemeData(color: Colors.white.withOpacity(0.5));
      }),

      // --- LABEL COLORS ---
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12);
      }),
    ),
  );

  static final highContrastDarkTheme = darkTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff304166),
      foregroundColor: Colors.white,
    ),
    colorScheme: darkTheme.colorScheme.copyWith(
      // Daily Challenge uses `primary` for its background; make it pop in
      // high-contrast dark mode.
      primary: const Color(0xFF3B5487),
      onPrimary: Colors.white,
      // Stronger separation for high-contrast mode.
      surface: const Color(0xFF111318),
      surfaceVariant: const Color(0xFF1B1F2A),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFE2E7F4),
      outline: const Color(0xFF7B869E),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xff304166),
      indicatorColor: const Color(0xff2D68FF),

      // --- ICON COLORS ---
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return IconThemeData(color: Colors.white.withOpacity(0.5));
      }),

      // --- LABEL COLORS ---
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          );
        }
        return TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12);
      }),
    ),
  );

  static ThemeData resolve({
    required AppThemeMode mode,
    required bool highContrast,
  }) {
    switch (mode) {
      case AppThemeMode.light:
        return highContrast ? highContrastLightTheme : lightTheme;
      case AppThemeMode.dark:
        return highContrast ? highContrastDarkTheme : darkTheme;
    }
  }
}
