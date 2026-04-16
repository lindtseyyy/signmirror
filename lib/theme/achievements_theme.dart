import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Achievements-specific theme tokens.
///
/// Add this as a [ThemeData.extensions] entry to style Achievements UI
/// independently from the global color scheme.
@immutable
class AchievementsTheme extends ThemeExtension<AchievementsTheme> {
  const AchievementsTheme({
    required this.cardBackgroundColor,
    required this.cardBorderColor,
    required this.cardBorderWidth,
    required this.showCardBorder,
    required this.mutedTextColor,
    required this.lockedTextColor,
    required this.progressTrackColor,
    required this.progressValueColor,
    required this.headerAccentTextColor,
    required this.useCardShadows,
  });

  /// Background color for achievement cards.
  final Color cardBackgroundColor;

  /// Border color for achievement cards.
  final Color cardBorderColor;

  /// Border thickness for achievement cards.
  ///
  /// If [showCardBorder] is false, this value can be ignored by the UI.
  final double cardBorderWidth;

  /// Whether the Achievements UI should draw borders around cards.
  final bool showCardBorder;

  /// Muted/secondary text color (e.g. descriptions, subtitles).
  final Color mutedTextColor;

  /// Text color for locked/inactive achievements.
  final Color lockedTextColor;

  /// Progress bar track/background color.
  final Color progressTrackColor;

  /// Progress bar filled/value color.
  final Color progressValueColor;

  /// Accent color used for header text (e.g. section titles, highlights).
  final Color headerAccentTextColor;

  /// Whether cards should use shadows (as opposed to flat surfaces).
  final bool useCardShadows;

  /// Default light theme values.
  factory AchievementsTheme.light() => const AchievementsTheme(
    cardBackgroundColor: Color(0xFFFFFFFF),
    cardBorderColor: Color(0xFFE6E6E6),
    cardBorderWidth: 1.0,
    showCardBorder: true,
    mutedTextColor: Color(0xFF6B7280),
    lockedTextColor: Color(0xFF9CA3AF),
    progressTrackColor: Color(0xFFE5E7EB),
    progressValueColor: Color(0xFF2563EB),
    headerAccentTextColor: Color(0xFF111827),
    useCardShadows: true,
  );

  /// Default dark theme values.
  factory AchievementsTheme.dark() => const AchievementsTheme(
    cardBackgroundColor: Color(0xFF111827),
    cardBorderColor: Color(0xFF374151),
    cardBorderWidth: 1.0,
    showCardBorder: true,
    mutedTextColor: Color(0xFF9CA3AF),
    lockedTextColor: Color(0xFF6B7280),
    progressTrackColor: Color(0xFF1F2937),
    progressValueColor: Color(0xFF60A5FA),
    headerAccentTextColor: Color(0xFFF9FAFB),
    useCardShadows: false,
  );

  /// High-contrast light theme values.
  factory AchievementsTheme.highContrastLight() => const AchievementsTheme(
    cardBackgroundColor: Color(0xFFFFFFFF),
    cardBorderColor: Color(0xFF111827),
    cardBorderWidth: 2.0,
    showCardBorder: true,
    mutedTextColor: Color(0xFF111827),
    lockedTextColor: Color(0xFF374151),
    progressTrackColor: Color(0xFF111827),
    progressValueColor: Color(0xFF00A3FF),
    headerAccentTextColor: Color(0xFF000000),
    useCardShadows: false,
  );

  /// High-contrast dark theme values.
  factory AchievementsTheme.highContrastDark() => const AchievementsTheme(
    cardBackgroundColor: Color(0xFF000000),
    cardBorderColor: Color(0xFFFFFFFF),
    cardBorderWidth: 2.0,
    showCardBorder: true,
    mutedTextColor: Color(0xFFFFFFFF),
    lockedTextColor: Color(0xFFE5E7EB),
    progressTrackColor: Color(0xFFFFFFFF),
    progressValueColor: Color(0xFF00E5FF),
    headerAccentTextColor: Color(0xFFFFFFFF),
    useCardShadows: false,
  );

  @override
  AchievementsTheme copyWith({
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    double? cardBorderWidth,
    bool? showCardBorder,
    Color? mutedTextColor,
    Color? lockedTextColor,
    Color? progressTrackColor,
    Color? progressValueColor,
    Color? headerAccentTextColor,
    bool? useCardShadows,
  }) {
    return AchievementsTheme(
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      showCardBorder: showCardBorder ?? this.showCardBorder,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      lockedTextColor: lockedTextColor ?? this.lockedTextColor,
      progressTrackColor: progressTrackColor ?? this.progressTrackColor,
      progressValueColor: progressValueColor ?? this.progressValueColor,
      headerAccentTextColor:
          headerAccentTextColor ?? this.headerAccentTextColor,
      useCardShadows: useCardShadows ?? this.useCardShadows,
    );
  }

  @override
  AchievementsTheme lerp(ThemeExtension<AchievementsTheme>? other, double t) {
    if (other is! AchievementsTheme) return this;

    return AchievementsTheme(
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t) ??
          cardBackgroundColor,
      cardBorderColor:
          Color.lerp(cardBorderColor, other.cardBorderColor, t) ??
          cardBorderColor,
      cardBorderWidth:
          lerpDouble(cardBorderWidth, other.cardBorderWidth, t) ??
          cardBorderWidth,
      showCardBorder: t < 0.5 ? showCardBorder : other.showCardBorder,
      mutedTextColor:
          Color.lerp(mutedTextColor, other.mutedTextColor, t) ?? mutedTextColor,
      lockedTextColor:
          Color.lerp(lockedTextColor, other.lockedTextColor, t) ??
          lockedTextColor,
      progressTrackColor:
          Color.lerp(progressTrackColor, other.progressTrackColor, t) ??
          progressTrackColor,
      progressValueColor:
          Color.lerp(progressValueColor, other.progressValueColor, t) ??
          progressValueColor,
      headerAccentTextColor:
          Color.lerp(headerAccentTextColor, other.headerAccentTextColor, t) ??
          headerAccentTextColor,
      useCardShadows: t < 0.5 ? useCardShadows : other.useCardShadows,
    );
  }

  @override
  String toString() {
    return 'AchievementsTheme('
        'cardBackgroundColor: $cardBackgroundColor, '
        'cardBorderColor: $cardBorderColor, '
        'cardBorderWidth: $cardBorderWidth, '
        'showCardBorder: $showCardBorder, '
        'mutedTextColor: $mutedTextColor, '
        'lockedTextColor: $lockedTextColor, '
        'progressTrackColor: $progressTrackColor, '
        'progressValueColor: $progressValueColor, '
        'headerAccentTextColor: $headerAccentTextColor, '
        'useCardShadows: $useCardShadows'
        ')';
  }
}
