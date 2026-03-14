import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../constants/route_names.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. Declare the recognizer here
  late TapGestureRecognizer _signUpRecognizer;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it
    _signUpRecognizer = TapGestureRecognizer()..onTap = _handleSignIn;
  }

  @override
  void dispose() {
    // 3. Clean it up to prevent memory leaks
    _signUpRecognizer.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    // Navigate to sign in or perform logic
    Navigator.pushNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    SizedBox(height: 250, width: double.infinity),
                    Positioned(
                      left: -150,
                      right: -90,
                      top: -200,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(400, 175),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(start: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              Text(
                                "Start your Journey",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'Enter name',
                          hintStyle: TextStyle(color: Color(0xffB3B3B3)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'Enter email address',
                          hintStyle: TextStyle(color: Color(0xffB3B3B3)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'Enter password',
                          hintStyle: TextStyle(color: Color(0xffB3B3B3)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FilledButton(
                        onPressed: () {},

                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.all(
                              Radius.circular(10),
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const Text(
                            "or sign up with",
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                          Container(
                            width: 100,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                              minimumSize: const Size(130, 50),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset(
                                    "assets/images/google.png",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text("Google"),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                              minimumSize: const Size(130, 50),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset(
                                    "assets/images/facebook.png",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text("Facebook"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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
                              recognizer: _signUpRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
