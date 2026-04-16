import 'package:flutter/material.dart';
import 'package:signmirror_flutter/theme/achievements_theme.dart';
import 'package:signmirror_flutter/theme/community_theme.dart';
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
      // Must match Community UI's current hard-coded light styling.
      CommunityTheme(
        pageBackgroundColor: Color(0xFFF2F3F4),
        cardBackgroundColor: Color(0xFFFFFFFF),
        cardSubsurfaceColor: Color(0xFFEEEEEE),
        sheetBackgroundColor: Color(0xFFFFFFFF),
        // Colors.white.withOpacity(0.5)
        dialogBackgroundColor: Color(0x80FFFFFF),
        searchFieldFillColor: Color(0xFFFFFFFF),
        // Colors.grey.shade200
        commentFieldFillColor: Color(0xFFEEEEEE),
        // Approx. ThemeData default divider color in light mode.
        outlineColor: Color(0x1F000000),
        dividerColor: Color(0x1F000000),
        // Colors.grey.shade400
        sheetHandleColor: Color(0xFFBDBDBD),
        // Colors.grey.shade200
        badgeNeutralBackgroundColor: Color(0xFFEEEEEE),
        // Colors.green.shade50
        badgeApprovedBackgroundColor: Color(0xFFE8F5E9),
        // Colors.green
        badgeApprovedBorderColor: Color(0xFF4CAF50),
        // Colors.green.shade800
        badgeApprovedContentColor: Color(0xFF2E7D32),
        // Colors.orange
        badgePendingBorderColor: Color(0xFFFF9800),
        // Colors.blue
        primaryActionColor: Color(0xFF2196F3),
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
      CommunityTheme(
        pageBackgroundColor: Color(0xFF121212),
        cardBackgroundColor: _darkColorScheme.surfaceVariant,
        cardSubsurfaceColor: _darkColorScheme.surface,
        sheetBackgroundColor: _darkColorScheme.surfaceVariant,
        dialogBackgroundColor: _darkColorScheme.surfaceVariant.withOpacity(
          0.92,
        ),
        searchFieldFillColor: _darkColorScheme.surfaceVariant,
        commentFieldFillColor: _darkColorScheme.surfaceVariant,
        outlineColor: _darkColorScheme.outline,
        dividerColor: _darkColorScheme.outline.withOpacity(0.7),
        sheetHandleColor: _darkColorScheme.outline.withOpacity(0.85),
        badgeNeutralBackgroundColor: _darkColorScheme.surface,
        badgeApprovedBackgroundColor: Color(0xFF163624),
        badgeApprovedBorderColor: Color(0xFF66BB6A),
        badgeApprovedContentColor: Color(0xFFA5D6A7),
        badgePendingBorderColor: Color(0xFFFFB74D),
        primaryActionColor: Color(0xFF64B5F6),
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
      // Achievements + Community tokens for high-contrast.
      ...lightTheme.extensions.values.where(
        (e) => e is! AchievementsTheme && e is! CommunityTheme,
      ),
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
      CommunityTheme(
        pageBackgroundColor: const Color(0xFFF2F3F4),
        cardBackgroundColor: _highContrastLightColorScheme.surface,
        cardSubsurfaceColor: const Color(0xFFFFFFFF),
        sheetBackgroundColor: _highContrastLightColorScheme.surface,
        dialogBackgroundColor: const Color(0xCCFFFFFF),
        searchFieldFillColor: const Color(0xFFFFFFFF),
        commentFieldFillColor: const Color(0xFFFFFFFF),
        outlineColor: _highContrastLightColorScheme.primary,
        dividerColor: Colors.black,
        sheetHandleColor: Colors.black54,
        badgeNeutralBackgroundColor: const Color(0xFFFFFFFF),
        badgeApprovedBackgroundColor: const Color(0xFFE8F5E9),
        badgeApprovedBorderColor: const Color(0xFF1B5E20),
        badgeApprovedContentColor: const Color(0xFF1B5E20),
        badgePendingBorderColor: const Color(0xFFE65100),
        primaryActionColor: _highContrastLightColorScheme.primary,
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
      // Achievements + Community tokens for high-contrast.
      ...darkTheme.extensions.values.where(
        (e) => e is! AchievementsTheme && e is! CommunityTheme,
      ),
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
      CommunityTheme(
        pageBackgroundColor: const Color(0xFF121212),
        cardBackgroundColor: _highContrastDarkColorScheme.surfaceVariant,
        cardSubsurfaceColor: _highContrastDarkColorScheme.surface,
        sheetBackgroundColor: _highContrastDarkColorScheme.surfaceVariant,
        dialogBackgroundColor: _highContrastDarkColorScheme.surfaceVariant
            .withOpacity(0.96),
        searchFieldFillColor: _highContrastDarkColorScheme.surfaceVariant,
        commentFieldFillColor: _highContrastDarkColorScheme.surfaceVariant,
        outlineColor: _highContrastDarkColorScheme.outline,
        dividerColor: _highContrastDarkColorScheme.outline,
        sheetHandleColor: _highContrastDarkColorScheme.outline,
        badgeNeutralBackgroundColor: _highContrastDarkColorScheme.surface,
        badgeApprovedBackgroundColor: const Color(0xFF0E3B24),
        badgeApprovedBorderColor: const Color(0xFF00E676),
        badgeApprovedContentColor: const Color(0xFF00E676),
        badgePendingBorderColor: const Color(0xFFFFD54F),
        primaryActionColor: _highContrastDarkColorScheme.primary,
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
