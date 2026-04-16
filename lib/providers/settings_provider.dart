import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; //
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';

import '../services/settings_service.dart';

// This provider gives you access to the service anywhere
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// --- THEME (Phase 2.2) ---
// Single source of truth for all theme-related settings.
final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsController, ThemeSettings>((ref) {
      final service = ref.watch(settingsServiceProvider);
      return ThemeSettingsController(service);
    });

class ThemeSettingsController extends StateNotifier<ThemeSettings> {
  ThemeSettingsController(this._service)
    : super(
        ThemeSettings(
          mode: _service.themeMode,
          highContrast: _service.highContrastEnabled,
        ),
      );

  final SettingsService _service;

  Future<void> setMode(AppThemeMode mode) async {
    if (state.mode == mode) return;
    state = ThemeSettings(mode: mode, highContrast: state.highContrast);
    await _service.setThemeMode(mode);
  }

  Future<void> toggleMode() async {
    final nextMode = state.mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setMode(nextMode);
  }

  Future<void> setHighContrast(bool enabled) async {
    if (state.highContrast == enabled) return;
    state = ThemeSettings(mode: state.mode, highContrast: enabled);
    await _service.setHighContrastEnabled(enabled);
  }

  Future<void> toggleHighContrast() async {
    await setHighContrast(!state.highContrast);
  }
}

// Legacy provider kept for backwards compatibility (dark mode as bool).
// Derives its state from themeSettingsProvider.
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final controller = ref.read(themeSettingsProvider.notifier);
  final notifier = ThemeNotifier(
    controller,
    ref.read(themeSettingsProvider).mode == AppThemeMode.dark,
  );

  ref.listen<ThemeSettings>(themeSettingsProvider, (previous, next) {
    notifier._syncFromSettings(next);
  });

  return notifier;
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier(this._controller, bool initialIsDark) : super(initialIsDark);

  final ThemeSettingsController _controller;

  void _syncFromSettings(ThemeSettings settings) {
    state = settings.mode == AppThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    await _controller.toggleMode();
  }
}

// 1. High Contrast Provider
final highContrastProvider = StateNotifierProvider<HighContrastNotifier, bool>((
  ref,
) {
  final controller = ref.read(themeSettingsProvider.notifier);
  final notifier = HighContrastNotifier(
    controller,
    ref.read(themeSettingsProvider).highContrast,
  );

  ref.listen<ThemeSettings>(themeSettingsProvider, (previous, next) {
    notifier._syncFromSettings(next);
  });

  return notifier;
});

class HighContrastNotifier extends StateNotifier<bool> {
  HighContrastNotifier(this._controller, bool initial) : super(initial);

  final ThemeSettingsController _controller;

  void _syncFromSettings(ThemeSettings settings) {
    state = settings.highContrast;
  }

  Future<void> toggle() async {
    await _controller.toggleHighContrast();
  }
}

// 2. Offline Download Provider
final offlineDownloadProvider = StateNotifierProvider<OfflineNotifier, bool>((
  ref,
) {
  return OfflineNotifier(ref.watch(settingsServiceProvider));
});

class OfflineNotifier extends StateNotifier<bool> {
  final SettingsService _service;
  OfflineNotifier(this._service) : super(_service.offlineDownloading);

  void toggle() async {
    state = !state;
    await _service.setOfflineDownloading(state);
  }
}

// 3. Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.watch(settingsServiceProvider));
});

class LanguageNotifier extends StateNotifier<String> {
  final SettingsService _service;

  LanguageNotifier(this._service)
    : super(AppStrings.normalizeLangCode(_service.language));

  Future<void> setLanguage(String? language) async {
    final normalized = AppStrings.normalizeLangCode(language);
    if (state == normalized) return;
    state = normalized;
    await _service.setLanguage(normalized);
  }
}

// 4. User Name Provider
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier(ref.watch(settingsServiceProvider));
});

class UserNameNotifier extends StateNotifier<String> {
  final SettingsService _service;
  UserNameNotifier(this._service) : super(_service.userName);

  void setUserName(String value) async {
    state = value;
    await _service.setUserName(value);
  }
}

// 5. User Email Provider
final userEmailProvider = StateNotifierProvider<UserEmailNotifier, String>((
  ref,
) {
  return UserEmailNotifier(ref.watch(settingsServiceProvider));
});

class UserEmailNotifier extends StateNotifier<String> {
  final SettingsService _service;
  UserEmailNotifier(this._service) : super(_service.userEmail);

  void setUserEmail(String value) async {
    state = value;
    await _service.setUserEmail(value);
  }
}

// 6. Personalization Provider
final personalizationProvider =
    StateNotifierProvider<PersonalizationNotifier, String>((ref) {
      return PersonalizationNotifier(ref.watch(settingsServiceProvider));
    });

class PersonalizationNotifier extends StateNotifier<String> {
  final SettingsService _service;
  PersonalizationNotifier(this._service) : super(_service.userPersonalization);

  void setPersonalization(String value) async {
    state = value;
    await _service.setUserPersonalization(value);
  }
}

// 7. Practice Time Provider
final practiceTimeProvider =
    StateNotifierProvider<PracticeTimeNotifier, String>((ref) {
      return PracticeTimeNotifier(ref.watch(settingsServiceProvider));
    });

class PracticeTimeNotifier extends StateNotifier<String> {
  final SettingsService _service;
  PracticeTimeNotifier(this._service) : super(_service.practiceTime);
  // PRETTY FORMATTER for the UI (Subtitle)
  String getDisplayTime() {
    final parts = state.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Create a dummy DateTime to format
    final tempDate = DateTime(2026, 1, 1, hour, minute);

    // 'hh:mm a' results in "03:56 PM"
    // 'h:mm a' results in "3:56 PM"
    return DateFormat('h:mm a').format(tempDate);
  }

  // UPDATER called by the "Done" button
  void setTime(TimeOfDay picked) async {
    final new24hTime =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    state = new24hTime;
    await _service.setPracticeTime(new24hTime);
  }
}
