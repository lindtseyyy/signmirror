import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // We use a static instance so we don't have to keep re-opening it
  late SharedPreferences _prefs;

  // 1. Initialize the service (Call this in your main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- DARK MODE ---
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
  }

  // --- LANGUAGE ---
  String get language => _prefs.getString('language') ?? 'en';

  Future<void> setLanguage(String lang) async {
    await _prefs.setString('language', lang);
  }

  // --- OFFLINE DOWNLOADING ---
  bool get offlineDownloading => _prefs.getBool('offlineDownloading') ?? false;

  Future<void> setOfflineDownloading(bool value) async {
    await _prefs.setBool('offlineDownloading', value);
  }

  // --- HIGH CONTRAST ---
  bool get isHighContrast => _prefs.getBool('isHighContrast') ?? false;

  Future<void> setHighContrast(bool value) async {
    await _prefs.setBool('isHighContrast', value);
  }

  // --- PRACTICE TIME ---
  String get practiceTime => _prefs.getString('practiceTime') ?? "20:00";

  Future<void> setPracticeTime(String time) async {
    await _prefs.setString('practiceTime', time);
  }
}
