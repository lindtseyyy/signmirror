import 'package:flutter/material.dart';

@immutable
class BookmarkTheme extends ThemeExtension<BookmarkTheme> {
  final Color activeColor;
  final Color inactiveColor;

  const BookmarkTheme({required this.activeColor, required this.inactiveColor});

  @override
  BookmarkTheme copyWith({Color? activeColor, Color? inactiveColor}) {
    return BookmarkTheme(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
    );
  }

  @override
  BookmarkTheme lerp(ThemeExtension<BookmarkTheme>? other, double t) {
    if (other is! BookmarkTheme) return this;

    return BookmarkTheme(
      activeColor: Color.lerp(activeColor, other.activeColor, t) ?? activeColor,
      inactiveColor:
          Color.lerp(inactiveColor, other.inactiveColor, t) ?? inactiveColor,
    );
  }
}
