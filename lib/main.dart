import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignMirror',
      theme: AppTheme.lightTheme,
      home: SafeArea(child: LoginScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
