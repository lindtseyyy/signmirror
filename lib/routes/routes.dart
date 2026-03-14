import 'package:flutter/material.dart';
// Import your screens here
import '../screens/screens.dart';
import "../constants/route_names.dart";

class AppRoutes {
  // Define route name constants
  static const String login = '/login';
  static const String signup = '/signup';

  // Create the route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.signup: (context) => const SignupScreen(),
    };
  }
}
