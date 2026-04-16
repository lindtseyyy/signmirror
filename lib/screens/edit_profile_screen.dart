import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/edit_profile_section_card.dart';
import 'package:signmirror_flutter/widgets/signmirror_input_decoration.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;

  bool _nameDirty = false;
  bool _emailDirty = false;

  String? _selectedPersonalization;
  bool _personalizationDirty = false;

  String? _emailErrorText;
  String? _newPasswordErrorText;
  String? _confirmNewPasswordErrorText;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  List<String> _personalizationOptions() {
    return const <String>['', 'Self-Learning', 'Teaching', 'Parent Support'];
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveNameAndPersonalization(String currentPersonalization) {
    final nameToSave = _nameController.text.trim();
    final personalizationToSave =
        (_selectedPersonalization ?? currentPersonalization).trim();

    ref.read(userNameProvider.notifier).setUserName(nameToSave);
    ref
        .read(personalizationProvider.notifier)
        .setPersonalization(personalizationToSave);

    _showSnack('Profile updated.');
  }

  String? _validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email cannot be empty.';

    // Basic validation; intentionally not exhaustive.
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address.';

    return null;
  }

  void _saveEmail() {
    final newEmail = _emailController.text;
    final error = _validateEmail(newEmail);

    setState(() {
      _emailErrorText = error;
    });

    if (error != null) return;

    ref.read(userEmailProvider.notifier).setUserEmail(newEmail.trim());
    _showSnack('Email updated.');
  }

  void _attemptPasswordChange() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmNewPasswordController.text;

    String? newError;
    String? confirmError;

    if (newPassword.trim().isEmpty) {
      newError = 'New password cannot be empty.';
    }

    if (confirmPassword.trim().isEmpty) {
      confirmError = 'Please confirm the new password.';
    } else if (newPassword != confirmPassword) {
      confirmError = 'Passwords do not match.';
    }

    setState(() {
      _newPasswordErrorText = newError;
      _confirmNewPasswordErrorText = confirmError;
    });

    if (newError != null || confirmError != null) return;

    // Intentionally not persisted: password flows must be handled by backend.
    _showSnack('Password change is not connected to the backend yet.');

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentName = ref.watch(userNameProvider);
    final currentEmail = ref.watch(userEmailProvider);
    final currentPersonalization = ref.watch(personalizationProvider);

    final options = _personalizationOptions();

    if (!_nameDirty && _nameController.text != currentName) {
      _nameController.text = currentName;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }

    if (!_emailDirty && _emailController.text != currentEmail) {
      _emailController.text = currentEmail;
      _emailController.selection = TextSelection.collapsed(
        offset: _emailController.text.length,
      );
    }

    if (!_personalizationDirty) {
      _selectedPersonalization = options.contains(currentPersonalization)
          ? currentPersonalization
          : '';
    }

    final effectivePersonalization = options.contains(_selectedPersonalization)
        ? _selectedPersonalization
        : '';

    final themeSettings = ref.watch(themeSettingsProvider);
    final platformHighContrast = MediaQuery.of(context).highContrast;
    final effectiveHighContrast =
        themeSettings.highContrast || platformHighContrast;

    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: effectiveHighContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final colors = Theme.of(context).colorScheme;
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profile')),
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                children: [
                  EditProfileSectionCard(
                    title: 'Profile',
                    description:
                        'Update your name and personalization settings.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: signMirrorInputDecoration(
                            label: 'User name',
                            hint: 'Enter your name',
                            colors: colors,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            _nameDirty = true;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: effectivePersonalization,
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          items: options
                              .map(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value.isEmpty ? 'None' : value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPersonalization = value ?? '';
                              _personalizationDirty = true;
                            });
                          },
                          decoration: signMirrorInputDecoration(
                            label: 'Personalization',
                            hint: 'Select an option',
                            colors: colors,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveNameAndPersonalization(
                              currentPersonalization,
                            ),
                            child: const Text('Save profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  EditProfileSectionCard(
                    title: 'Email',

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current: ${currentEmail.trim().isEmpty ? 'Not set' : currentEmail}",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: signMirrorInputDecoration(
                            label: 'New email',
                            hint: 'Enter new email address',
                            colors: colors,
                            errorText: _emailErrorText,
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            _emailDirty = true;
                            if (_emailErrorText != null) {
                              setState(() {
                                _emailErrorText = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveEmail,
                            child: const Text('Update email'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  EditProfileSectionCard(
                    title: 'Password',

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          decoration: signMirrorInputDecoration(
                            label: 'Current password',
                            hint: 'Enter current password',
                            colors: colors,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: colors.onSurfaceVariant,
                              ),
                              tooltip: _obscureCurrentPassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: signMirrorInputDecoration(
                            label: 'New password',
                            hint: 'Enter a new password',
                            colors: colors,
                            errorText: _newPasswordErrorText,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: colors.onSurfaceVariant,
                              ),
                              tooltip: _obscureNewPassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_newPasswordErrorText != null) {
                              setState(() {
                                _newPasswordErrorText = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmNewPasswordController,
                          obscureText: _obscureConfirmNewPassword,
                          decoration: signMirrorInputDecoration(
                            label: 'Confirm new password',
                            hint: 'Re-enter the new password',
                            colors: colors,
                            errorText: _confirmNewPasswordErrorText,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmNewPassword =
                                      !_obscureConfirmNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: colors.onSurfaceVariant,
                              ),
                              tooltip: _obscureConfirmNewPassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_confirmNewPasswordErrorText != null) {
                              setState(() {
                                _confirmNewPasswordErrorText = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _attemptPasswordChange,
                            child: const Text('Change password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
