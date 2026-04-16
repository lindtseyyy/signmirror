import 'package:flutter/material.dart';

class BookmarkIconButton extends StatelessWidget {
  const BookmarkIconButton({
    super.key,
    required this.isBookmarked,
    required this.onPressed,
    this.tooltip,
  });

  final bool isBookmarked;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bookmarkTheme = _findBookmarkThemeExtension(theme);

    final activeColor =
        _tryReadActiveColor(bookmarkTheme) ?? colorScheme.primary;

    final inactiveColor =
        _tryReadInactiveColor(bookmarkTheme) ?? colorScheme.onSurfaceVariant;

    final color = isBookmarked ? activeColor : inactiveColor;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: 20,
        color: color,
      ),
    );
  }
}

ThemeExtension<dynamic>? _findBookmarkThemeExtension(ThemeData theme) {
  for (final entry in theme.extensions.entries) {
    if (entry.key.toString() == 'BookmarkTheme') {
      return entry.value;
    }
  }
  return null;
}

Color? _tryReadActiveColor(ThemeExtension<dynamic>? extension) {
  if (extension == null) return null;

  final dynamic ext = extension;

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.activeColor;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.active;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.bookmarkedColor;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.selectedColor;
    if (value is Color) return value;
  } catch (_) {}

  return null;
}

Color? _tryReadInactiveColor(ThemeExtension<dynamic>? extension) {
  if (extension == null) return null;

  final dynamic ext = extension;

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.inactiveColor;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.inactive;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.unbookmarkedColor;
    if (value is Color) return value;
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final value = ext.unselectedColor;
    if (value is Color) return value;
  } catch (_) {}

  return null;
}
