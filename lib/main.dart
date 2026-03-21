import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/routes/routes.dart';
import 'package:signmirror_flutter/services/settings_service.dart';
import 'screens/personalization_screen.dart';
import './theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignMirror',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.main,
      routes: AppRoutes.getRoutes(),
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const PersonalizationScreen(),
      ),
    );
  }
}
