import 'package:flutter/material.dart';
import 'package:signmirror_flutter/screens/achievements_screen.dart';
import 'package:signmirror_flutter/screens/bookmarked_signs_screen.dart';
import 'package:signmirror_flutter/screens/community_screen.dart';
import 'package:signmirror_flutter/screens/dashboard_screen.dart';
import 'package:signmirror_flutter/screens/edit_profile_screen.dart';
import 'package:signmirror_flutter/screens/main_screen.dart';
import 'package:signmirror_flutter/screens/personalization_screen.dart';
import 'package:signmirror_flutter/screens/profile_screen.dart';
// Import your screens here
import '../screens/screens.dart';
import "../constants/route_names.dart";

class AppRoutes {
  // Define route name constants
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String personalization = '/personalization';
  static const String dashboard = '/dashboard';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String achievements = "/achievements";
  static const String community = "/community";

  // Create the route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      RouteNames.login: (context) => const OnboardingScreen(),
      RouteNames.signup: (context) => const SignupScreen(),
      RouteNames.signin: (context) => const SigninScreen(),
      RouteNames.personalization: (context) => const PersonalizationScreen(),
      RouteNames.main: (context) => const MainScreen(),
      RouteNames.dashboard: (context) => const DashboardScreen(),
      RouteNames.profile: (context) => const ProfileScreen(),
      RouteNames.editProfile: (context) => const EditProfileScreen(),
      RouteNames.achievements: (context) => const AchievementsScreen(),
      RouteNames.community: (context) => const CommunityScreen(),
      RouteNames.bookmarkedSigns: (context) => const BookmarkedSignsScreen(),
    };
  }
}
