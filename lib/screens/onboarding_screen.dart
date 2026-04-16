import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../constants/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 1. Declare the recognizer here
  late TapGestureRecognizer _signInRecognizer;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it
    _signInRecognizer = TapGestureRecognizer()..onTap = _handleSignIn;
  }

  @override
  void dispose() {
    // 3. Clean it up to prevent memory leaks
    _signInRecognizer.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    // Navigate to sign in or perform logic
    Navigator.pushNamed(context, RouteNames.signin);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final signInColor = isDarkMode
        ? Color.lerp(colors.primaryContainer, colors.onSurface, 0.35)!
        : colors.primary;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(height: 400, width: double.infinity),
                Positioned(
                  left: -100,
                  right: -100,
                  top: -250,
                  child: Center(
                    child: Container(
                      width: 650,
                      height: 650,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Image.asset('assets/images/test_sign.png'),
              ],
            ),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 0.0,
                horizontal: 30.0,
              ),
              child: Text(
                "Learn Filipino Sign Language through AI-powered real-time feedback.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19.0,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.signup);
              },
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                ),
                fixedSize: const Size(300, 60),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                  color: colors.onSurface,
                ),
                children: [
                  const TextSpan(text: "Already have an account? "),
                  TextSpan(
                    text: "Sign In",
                    style: TextStyle(
                      color: signInColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: _signInRecognizer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
