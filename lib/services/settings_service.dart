import 'package:shared_preferences/shared_preferences.dart';

import 'package:signmirror_flutter/theme/theme_settings.dart';

class SettingsService {
  SettingsService._internal();

  static final SettingsService _instance = SettingsService._internal();

  /// Factory constructor so `SettingsService()` always returns the same instance.
  factory SettingsService() => _instance;

  late SharedPreferences _prefs;
  Future<void>? _initFuture;
  bool _initialized = false;

  // Initialize the service (call this in main.dart before runApp).
  // Idempotent: safe to call multiple times, will only initialize once.
  Future<void> init() {
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  SharedPreferences get _prefsSync {
    if (!_initialized) {
      throw StateError(
        'SettingsService used before init() completed. '
        'Ensure main() awaits SettingsService().init() before runApp().',
      );
    }
    return _prefs;
  }

  // --- DARK MODE ---
  bool get isDarkMode => _prefsSync.getBool('isDarkMode') ?? false;

  AppThemeMode get themeMode =>
      isDarkMode ? AppThemeMode.dark : AppThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    await _prefsSync.setBool('isDarkMode', value);
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    await setDarkMode(value == AppThemeMode.dark);
  }

  // --- LANGUAGE ---
  String get language => _prefsSync.getString('language') ?? 'en';

  Future<void> setLanguage(String lang) async {
    await _prefsSync.setString('language', lang);
  }

  // --- OFFLINE DOWNLOADING ---
  bool get offlineDownloading =>
      _prefsSync.getBool('offlineDownloading') ?? false;

  Future<void> setOfflineDownloading(bool value) async {
    await _prefsSync.setBool('offlineDownloading', value);
  }

  // --- HIGH CONTRAST ---
  bool get isHighContrast => _prefsSync.getBool('isHighContrast') ?? false;

  bool get highContrastEnabled => isHighContrast;

  Future<void> setHighContrast(bool value) async {
    await _prefsSync.setBool('isHighContrast', value);
  }

  Future<void> setHighContrastEnabled(bool value) async {
    await setHighContrast(value);
  }

  // --- PRACTICE TIME ---
  String get practiceTime => _prefsSync.getString('practiceTime') ?? "20:00";

  Future<void> setPracticeTime(String time) async {
    await _prefsSync.setString('practiceTime', time);
  }

  // --- USER NAME ---
  String get userName => _prefsSync.getString('userName') ?? '';

  Future<void> setUserName(String value) async {
    await _prefsSync.setString('userName', value);
  }

  // --- USER PERSONALIZATION ---
  String get userPersonalization =>
      _prefsSync.getString('userPersonalization') ?? '';

  Future<void> setUserPersonalization(String value) async {
    await _prefsSync.setString('userPersonalization', value);
  }
}
