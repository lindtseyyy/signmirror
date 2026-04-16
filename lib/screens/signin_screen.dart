import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:signmirror_flutter/utils/snackbar_utils.dart';
import 'package:signmirror_flutter/widgets/loading_screen.dart';
import 'package:signmirror_flutter/constants/app_colors.dart';
import '../constants/route_names.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // 1. Declare the recognizer here
  late TapGestureRecognizer _signUpRecognizer;

  // Controllers to get text from fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for password visibility
  bool _isObscured = true;
  bool _isLoading = false;
  bool _isLoginValid = false;

  // Tracks the error message for each specific field
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it
    _signUpRecognizer = TapGestureRecognizer()..onTap = _handleSignUp;
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
      _emailError = null;
      _passwordError = null;

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Basic Email Regex check
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty) {
        _emailError = "Email is required";
        isValid = false;
      } else if (!emailRegex.hasMatch(email)) {
        _emailError = "Enter a valid email address";
        isValid = false;
      }

      // Password Check (Length, Uppercase, Lowercase, Number)
      String pass = _passwordController.text;

      if (pass.isEmpty) {
        _passwordError = "Password is required";
        isValid = false;
      }
    });

    return isValid;
  }

  void _handleLogin() async {
    if (_validateAndSubmit()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      // For invalid login later
      // SnackBarUtils.show(
      //   context,
      //   message: "Invalid credentials. Please try again.",
      //   isError: true,
      //   position: SnackBarPosition.top,
      // );

      // Simulate a network delay (e.g., 2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
          _isLoginValid = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isLoginValid = true;
        });

        // Redirect to Personalization instead of Login (Onboarding)
        if (mounted) {
          Navigator.pushReplacementNamed(context, RouteNames.personalization);
        }
      }
    }
  }

  void _handleSignUp() {
    // Navigate to sign in or perform logic
    Navigator.pushNamed(context, RouteNames.signup);
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
                                      'Welcome Back!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                    Text(
                                      "Good to see you again!",
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
                              decoration: _inputStyle(
                                'Email Address',
                                'Enter email',
                                colors,
                                _emailError,
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
                              decoration:
                                  _inputStyle(
                                    'Password',
                                    'Enter password',
                                    colors,
                                    _passwordError,
                                  ).copyWith(
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
                            const SizedBox(height: 20),

                            // CREATE ACCOUNT BUTTON
                            FilledButton(
                              onPressed: _handleLogin,

                              style: FilledButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                "Login",
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
                                style:
                                    (textTheme.bodyMedium ??
                                            const TextStyle())
                                        .copyWith(
                                          color: colors.onSurface,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w300,
                                        ),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    text: "Sign up",
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
          ),
          if (_isLoading) LoadingScreenWidget(label: "Logging in..."),
          if (_isLoginValid)
            LoadingScreenWidget(label: "Preparing your dashboard..."),
        ],
      ),
    );
  }

  // Helper to keep code clean
  InputDecoration _inputStyle(
    String label,
    String hint,
    ColorScheme colors,
    String? errorText,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText, // Add this line here!
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle: const TextStyle(color: Color(0xffB3B3B3)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      // Add these two for the red error borders
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
