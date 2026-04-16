import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/utils/snackbar_utils.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/constants/app_colors.dart';
import 'package:signmirror_flutter/widgets/loading_screen.dart';
import 'package:signmirror_flutter/widgets/signmirror_input_decoration.dart';
import '../constants/route_names.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // 1. Declare the recognizer here
  late TapGestureRecognizer _signUpRecognizer;

  // Controllers to get text from fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for password visibility
  bool _isObscured = true;
  bool _isLoading = false;

  // Tracks the error message for each specific field
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it
    _signUpRecognizer = TapGestureRecognizer()..onTap = _handleSignIn;
  }

  @override
  void dispose() {
    // Always dispose controllers to save memory!
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
    super.dispose();
  }

  // 3. The Validation Logic
  bool _validateAndSubmit() {
    bool isValid = true;

    setState(() {
      // Reset errors first
      _nameError = null;
      _emailError = null;
      _passwordError = null;

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (name.isEmpty) {
        _nameError = "Name is required";
        isValid = false;
      }

      // Basic Email Regex check
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty) {
        _emailError = "Email is required";
        isValid = false;
      } else if (!emailRegex.hasMatch(email)) {
        _emailError = "Enter a valid email address";
        isValid = false;
      }

      // This Regex checks: 1 uppercase, 1 lowercase, 1 digit, and length 6+
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');

      if (password.isEmpty) {
        _passwordError = "Password is required";
        isValid = false;
      } else if (!passwordRegex.hasMatch(password)) {
        _passwordError = "Password does not meet requirements";
        isValid = false;
      }
    });

    return isValid;
  }

  void _handleCreateAccount() async {
    if (_validateAndSubmit()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      // Simulate a network delay (e.g., 2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
        });

        // Show success message
        SnackBarUtils.show(
          context,
          message: "Account created successfully!",
          isError: false,
          position: SnackBarPosition.top,
        );

        // Persist the entered name for later use
        ref
            .read(userNameProvider.notifier)
            .setUserName(_nameController.text.trim());

        // Wait a tiny bit so they can read the success message
        await Future.delayed(const Duration(milliseconds: 1500));

        // Redirect to Login (SignIn)
        if (mounted) {
          Navigator.pushReplacementNamed(context, RouteNames.signin);
        }
      }
    }
  }

  void _handleSignIn() {
    // Navigate to sign in or perform logic
    Navigator.pushNamed(context, RouteNames.signin);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                                padding: EdgeInsetsGeometry.directional(
                                  start: 30,
                                ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
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
                            // NAME FIELD
                            TextField(
                              controller: _nameController,
                              onChanged: (value) {
                                if (_nameError != null) {
                                  setState(() {
                                    _nameError =
                                        null; // Clear red color when user types
                                  });
                                }
                              },
                              decoration: signMirrorInputDecoration(
                                label: 'Name',
                                hint: 'Enter name',
                                colors: colors,
                                errorText: _nameError,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // EMAIL FIELD
                            TextField(
                              controller: _emailController,
                              onChanged: (value) {
                                if (_emailError != null) {
                                  setState(() {
                                    _emailError =
                                        null; // Clear red color when user types
                                  });
                                }
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: signMirrorInputDecoration(
                                label: 'Email Address',
                                hint: 'Enter email',
                                colors: colors,
                                errorText: _emailError,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // PASSWORD FIELD
                            TextField(
                              controller: _passwordController,
                              obscureText: _isObscured,
                              onChanged: (value) {
                                if (_passwordError != null) {
                                  setState(() {
                                    _passwordError =
                                        null; // Clear red color when user types
                                  });
                                }
                              },
                              decoration: signMirrorInputDecoration(
                                label: 'Password',
                                hint: 'Enter password',
                                colors: colors,
                                errorText: _passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _isObscured = !_isObscured,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 2),
                              child: Column(
                                children: [
                                  // First Bullet
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Must be at least 6 characters",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ), // Small gap between bullets
                                  // Second Bullet
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Include uppercase, lowercase, and number",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // CREATE ACCOUNT BUTTON
                            FilledButton(
                              onPressed: _handleCreateAccount,

                              style: FilledButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                minimumSize: const Size(double.infinity, 50),
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
                                    foregroundColor: colors.onSurface,
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
                                    foregroundColor: colors.onSurface,
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
                                style:
                                    (textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                          color: colors.onSurface,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w300,
                                        ),
                                children: [
                                  const TextSpan(
                                    text: "Already have an account? ",
                                  ),
                                  TextSpan(
                                    text: "Sign in",
                                    style: const TextStyle(
                                      color: AppColors.lightButtonBackground,
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
          ), // 2. The Loading Overlay
          if (_isLoading) LoadingScreenWidget(label: "Creating account..."),
        ],
      ),
    );
  }
}
