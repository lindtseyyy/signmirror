import 'package:flutter/foundation.dart';

enum AppThemeMode { light, dark }

@immutable
class ThemeSettings {
  const ThemeSettings({required this.mode, required this.highContrast});

  final AppThemeMode mode;
  final bool highContrast;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.mode == mode &&
        other.highContrast == highContrast;
  }

  @override
  int get hashCode => Object.hash(mode, highContrast);
}
