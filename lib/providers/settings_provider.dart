import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import 'package:intl/intl.dart'; // 

// This provider gives you access to the service anywhere
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// This notifier handles the actual "Theme Logic" and UI updates
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final service = ref.read(settingsServiceProvider);
  return ThemeNotifier(service);
});

class ThemeNotifier extends StateNotifier<bool> {
  final SettingsService _service;

  ThemeNotifier(this._service) : super(_service.isDarkMode);

  void toggleTheme() async {
    state = !state; // Update the UI instantly
    await _service.setDarkMode(state); // Save to local storage
  }
}

// 1. High Contrast Provider
final highContrastProvider = StateNotifierProvider<HighContrastNotifier, bool>((
  ref,
) {
  return HighContrastNotifier(ref.watch(settingsServiceProvider));
});

class HighContrastNotifier extends StateNotifier<bool> {
  final SettingsService _service;
  HighContrastNotifier(this._service) : super(_service.isHighContrast);

  void toggle() async {
    state = !state;
    await _service.setHighContrast(state);
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
  LanguageNotifier(this._service) : super(_service.language);

  void setLanguage(String language) async {
    await _service.setLanguage(language);
  }
}

// 3. Practice Time Provider
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
