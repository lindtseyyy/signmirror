import 'package:flutter/material.dart';
import 'package:signmirror_flutter/theme/achievements_theme.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';
import 'package:signmirror_flutter/constants/app_colors.dart';

class AppTheme {
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF304166),
    onPrimary: Colors.white,
    surface: Color(0xFFFFFFFF),
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF304166),
    onPrimary: Colors.white,
    // Dashboard cards/sections use `surface` and `surfaceVariant`.
    // These are intentionally not near-black so borders remain visible.
    surface: Color(0xFF181A1F),
    surfaceVariant: Color(0xFF222634),
    onSurface: Color(0xFFE7EAF2),
    onSurfaceVariant: Color(0xFFC3CADB),
    outline: Color(0xFF3A4152),
  );

  static final ColorScheme _highContrastLightColorScheme = _lightColorScheme
      .copyWith(
        primary: const Color(0xFF304166),
        surface: const Color(0xFFFFFFFF),
        onPrimary: Colors.white,
      );

  static final ColorScheme _highContrastDarkColorScheme = _darkColorScheme
      .copyWith(
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
      );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xfff2f3f4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff304166),
      foregroundColor: Colors.white,
    ),
    colorScheme: _lightColorScheme,
    extensions: const <ThemeExtension<dynamic>>[
      // Must match Achievements UI's current hard-coded light styling.
      AchievementsTheme(
        cardBackgroundColor: Color(0xFFFFFFFF),
        // Current UI uses shadows instead of borders.
        cardBorderColor: Color(0x00000000),
        cardBorderWidth: 0.0,
        showCardBorder: false,
        // Colors.black.withOpacity(0.6)
        mutedTextColor: Color(0x99000000),
        // Colors.black.withOpacity(0.4)
        lockedTextColor: Color(0x66000000),
        // Colors.grey.shade200
        progressTrackColor: Color(0xFFEEEEEE),
        // const Color(0xff69B85E)
        progressValueColor: Color(0xFF69B85E),
        // const Color(0xff304166)
        headerAccentTextColor: Color(0xFF304166),
        useCardShadows: true,
      ),
    ],
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
    colorScheme: _darkColorScheme,
    extensions: <ThemeExtension<dynamic>>[
      AchievementsTheme(
        // Avoid white cards on dark backgrounds.
        cardBackgroundColor: _darkColorScheme.surfaceVariant,
        cardBorderColor: _darkColorScheme.outline,
        cardBorderWidth: 1.0,
        showCardBorder: true,
        mutedTextColor: _darkColorScheme.onSurfaceVariant,
        lockedTextColor: _darkColorScheme.onSurfaceVariant.withOpacity(0.6),
        progressTrackColor: _darkColorScheme.outline.withOpacity(0.35),
        // Keep the existing light-mode progress green for recognizability.
        progressValueColor: const Color(0xFF69B85E),
        headerAccentTextColor: _darkColorScheme.onSurface,
        useCardShadows: false,
      ),
    ],
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
    colorScheme: _highContrastLightColorScheme,
    extensions: [
      // Preserve any existing extensions from `lightTheme`, but override
      // Achievements tokens for high-contrast.
      ...lightTheme.extensions.values.where((e) => e is! AchievementsTheme),
      AchievementsTheme(
        cardBackgroundColor: _highContrastLightColorScheme.surface,
        cardBorderColor: _highContrastLightColorScheme.primary,
        cardBorderWidth: 2.0,
        showCardBorder: true,
        mutedTextColor: Colors.black,
        lockedTextColor: Colors.black.withOpacity(0.6),
        progressTrackColor: Colors.black.withOpacity(0.2),
        progressValueColor: _highContrastLightColorScheme.primary,
        headerAccentTextColor: _highContrastLightColorScheme.primary,
        useCardShadows: false,
      ),
    ],
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
    colorScheme: _highContrastDarkColorScheme,
    extensions: [
      // Preserve any existing extensions from `darkTheme`, but override
      // Achievements tokens for high-contrast.
      ...darkTheme.extensions.values.where((e) => e is! AchievementsTheme),
      AchievementsTheme(
        cardBackgroundColor: _highContrastDarkColorScheme.surfaceVariant,
        cardBorderColor: _highContrastDarkColorScheme.outline,
        cardBorderWidth: 2.0,
        showCardBorder: true,
        mutedTextColor: _highContrastDarkColorScheme.onSurfaceVariant,
        lockedTextColor: _highContrastDarkColorScheme.onSurfaceVariant
            .withOpacity(0.7),
        progressTrackColor: _highContrastDarkColorScheme.outline.withOpacity(
          0.55,
        ),
        progressValueColor: _highContrastDarkColorScheme.primary,
        headerAccentTextColor: _highContrastDarkColorScheme.onSurface,
        useCardShadows: false,
      ),
    ],
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
