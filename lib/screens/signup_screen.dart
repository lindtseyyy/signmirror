import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/app_colors.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/services/isar_service.dart';
import 'package:signmirror_flutter/utils/snackbar_utils.dart';
import 'package:signmirror_flutter/widgets/loading_screen.dart';
import 'package:signmirror_flutter/widgets/signmirror_input_decoration.dart';

import '../constants/route_names.dart';

extension SignupStrings on AppStrings {
  String get signupCreateAccountTitle =>
      isFilipino ? 'Gumawa ng Account' : 'Create Account';

  String get signupCreateAccountSubtitle =>
      isFilipino ? 'Simulan ang iyong paglalakbay' : 'Start your Journey';

  String get signupNameLabel => isFilipino ? 'Pangalan' : 'Name';
  String get signupNameHint =>
      isFilipino ? 'Ilagay ang pangalan' : 'Enter name';

  String get signupCreateAccountButtonLabel =>
      isFilipino ? 'Gumawa ng Account' : 'Create Account';

  String get signupPasswordHelperMinChars => isFilipino
      ? 'Dapat hindi bababa sa 6 na karakter'
      : 'Must be at least 6 characters';

  String get signupPasswordHelperComposition => isFilipino
      ? 'Dapat may malaking titik, maliit na titik, at numero'
      : 'Include uppercase, lowercase, and number';

  String get signupFooterHaveAccountLabel =>
      isFilipino ? 'Mayroon ka nang account? ' : 'Already have an account? ';

  String get signupFooterSignInLabel => isFilipino ? 'Mag-sign in' : 'Sign in';

  String get signupLoadingCreatingAccountLabel =>
      isFilipino ? 'Ginagawa ang account...' : 'Creating account...';

  // Validation errors
  String get signupErrorNameRequired =>
      isFilipino ? 'Kailangan ang pangalan' : 'Name is required';

  String get signupErrorPasswordRequirements => isFilipino
      ? 'Hindi pumapasa ang password sa mga kinakailangan'
      : 'Password does not meet requirements';

  // Snackbars
  String get signupSnackbarAccountCreated => isFilipino
      ? 'Matagumpay na nagawa ang account!'
      : 'Account created successfully!';

  String get signupSnackbarEmailAlreadyExists => isFilipino
      ? 'Mayroon nang account gamit ang email na iyon.'
      : 'An account with that email already exists.';

  String get signupSnackbarCreateFailed => isFilipino
      ? 'Hindi makagawa ng account. Pakisubukan muli.'
      : 'Could not create account. Please try again.';

  // Social providers
  String get signupSocialGoogleLabel => 'Google';
  String get signupSocialFacebookLabel => 'Facebook';
}

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
    final strings = ref.read(appStringsProvider);
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
        _nameError = strings.signupErrorNameRequired;
        isValid = false;
      }

      // Basic Email Regex check
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty) {
        _emailError = strings.signinErrorEmailRequired;
        isValid = false;
      } else if (!emailRegex.hasMatch(email)) {
        _emailError = strings.signinErrorEmailInvalid;
        isValid = false;
      }

      // This Regex checks: 1 uppercase, 1 lowercase, 1 digit, and length 6+
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');

      if (password.isEmpty) {
        _passwordError = strings.signinErrorPasswordRequired;
        isValid = false;
      } else if (!passwordRegex.hasMatch(password)) {
        _passwordError = strings.signupErrorPasswordRequirements;
        isValid = false;
      }
    });

    return isValid;
  }

  void _handleCreateAccount() async {
    if (!_validateAndSubmit()) return;

    final strings = ref.read(appStringsProvider);
    final isarService = ref.read(isarServiceProvider);

    setState(() {
      _isLoading = true; // Start loading
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Ensure email is unique before attempting registration.
      // IsarService normalizes for case/trim; we pass trimmed email.
      final existingUser = await isarService.getUserByEmail(email);
      if (existingUser != null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _emailError = strings.signupSnackbarEmailAlreadyExists;
        });
        return;
      }

      final createdUser = await isarService.registerUser(name, email, password);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Show success message
      SnackBarUtils.show(
        context,
        message: strings.signupSnackbarAccountCreated,
        isError: false,
        position: SnackBarPosition.top,
      );

      // Persist to SharedPreferences-backed settings providers
      // (use normalized values from the saved user)
      ref.read(userNameProvider.notifier).setUserName(createdUser.name);
      ref.read(userEmailProvider.notifier).setUserEmail(createdUser.email);

      // Wait a tiny bit so they can read the success message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Redirect to Login (SignIn)
      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.signin);
      }
    } on EmailAlreadyExistsException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = strings.signupSnackbarEmailAlreadyExists;
      });

      SnackBarUtils.show(
        context,
        message: strings.signupSnackbarEmailAlreadyExists,
        isError: true,
        position: SnackBarPosition.top,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      SnackBarUtils.show(
        context,
        message: strings.signupSnackbarCreateFailed,
        isError: true,
        position: SnackBarPosition.top,
      );
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
    final strings = ref.watch(appStringsProvider);
    final langCode = ref.watch(languageProvider);
    final langBadge = langCode == 'fil' ? 'FIL' : 'EN';

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
                          Positioned(
                            top: 12,
                            right: 12,
                            child: PopupMenuButton<String>(
                              initialValue: langCode,
                              onSelected: (value) {
                                ref
                                    .read(languageProvider.notifier)
                                    .setLanguage(value);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'en',
                                  child: Text(strings.languageEnglishLabel),
                                ),
                                PopupMenuItem(
                                  value: 'fil',
                                  child: Text(strings.languageFilipinoLabel),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  langBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
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
                                      strings.signupCreateAccountTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                    Text(
                                      strings.signupCreateAccountSubtitle,
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
                                label: strings.signupNameLabel,
                                hint: strings.signupNameHint,
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
                                label: strings.signinEmailLabel,
                                hint: strings.signinEmailHint,
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
                                label: strings.signinPasswordLabel,
                                hint: strings.signinPasswordHint,
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
                                        strings.signupPasswordHelperMinChars,
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
                                        strings.signupPasswordHelperComposition,
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
                              child: Text(
                                strings.signupCreateAccountButtonLabel,
                                style: const TextStyle(
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
                                Text(
                                  strings.signinDividerLabel,
                                  style: const TextStyle(fontFamily: 'Inter'),
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
                                      Text(strings.signupSocialGoogleLabel),
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
                                      Text(strings.signupSocialFacebookLabel),
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
                                  TextSpan(
                                    text: strings.signupFooterHaveAccountLabel,
                                  ),
                                  TextSpan(
                                    text: strings.signupFooterSignInLabel,
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
          if (_isLoading)
            LoadingScreenWidget(
              label: strings.signupLoadingCreatingAccountLabel,
            ),
        ],
      ),
    );
  }
}
