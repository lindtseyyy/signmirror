import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/routes/routes.dart';
import 'package:signmirror_flutter/screens/personalization_screen.dart';
import 'package:signmirror_flutter/services/settings_service.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ui.DartPluginRegistrant.ensureInitialized();

  // 1. Initialize the service manually once
  final settingsService = SettingsService();
  await settingsService.init();

  runApp(
    ProviderScope(
      overrides: [
        // 2. "Inject" the already initialized service into the provider
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);

    final themeMode = switch (themeSettings.mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp(
      title: 'SignMirror',
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.login,
      routes: AppRoutes.getRoutes(),
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const PersonalizationScreen(),
      ),

      // Base themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      highContrastTheme: AppTheme.highContrastLightTheme,
      highContrastDarkTheme: AppTheme.highContrastDarkTheme,

      // App-controlled light/dark mode (no system mode)
      themeMode: themeMode,

      // Make the in-app high-contrast toggle effective even when the OS
      // high-contrast setting is off.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final effectiveHighContrast =
            mediaQuery.highContrast || themeSettings.highContrast;

        return MediaQuery(
          data: mediaQuery.copyWith(highContrast: effectiveHighContrast),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
