import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/routes/routes.dart';
import 'screens/personalization_screen.dart';
import './theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
