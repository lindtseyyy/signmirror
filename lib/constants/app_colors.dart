import 'package:flutter/material.dart';

class AppColors {
  static const lightButtonBackground = Color(0xFF2D68FF);
  static const lightButtonForeground = Color(0xFFFFFFFF);

  // Bookmark icon colors.
  //
  // Light mode currently uses a single bookmark color in the UI. Keep these
  // values aligned with the existing appearance.
  static const bookmarkActiveLight = Color(0xFF304166);
  static const bookmarkInactiveLight = Color(0xFF304166);

  // Dark mode: use a visibly bright active color on dark surfaces.
  // Reuse the app's existing accent blue.
  static const bookmarkActiveDark = Color(0xFF2D68FF);
  // Light, readable inactive color on dark surfaces.
  static const bookmarkInactiveDark = Color(0xFFC3CADB);

  // High-contrast dark mode: push contrast further.
  static const bookmarkActiveHighContrastDark = Color(0xFF00E5FF);
  static const bookmarkInactiveHighContrastDark = Color(0xFFFFFFFF);
}
