import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
              onPressed: () {},

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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  const TextSpan(text: "Already have an account? "),
                  TextSpan(
                    text: "Sign In",
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("Sign in button clicked.");
                        // Trigger your action here (e.g., navigation or opening a URL)
                      },
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
