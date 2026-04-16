import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/edit_profile_section_card.dart';
import 'package:signmirror_flutter/widgets/signmirror_input_decoration.dart';

enum _EmailValidationError { empty, invalid }

enum _NewPasswordValidationError { empty }

enum _ConfirmPasswordValidationError { empty, mismatch }

enum _PersonalizationKey { none, selfLearning, teaching, parentSupport }

_PersonalizationKey _personalizationFromPersistedValue(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return _PersonalizationKey.none;

  switch (normalized) {
    case 'self-learning':
      return _PersonalizationKey.selfLearning;
    case 'teaching':
      return _PersonalizationKey.teaching;
    case 'parent support':
      return _PersonalizationKey.parentSupport;
    default:
      return _PersonalizationKey.none;
  }
}

extension _PersonalizationKeyX on _PersonalizationKey {
  /// Persisted values must remain stable and language-agnostic.
  String get persistedValue {
    switch (this) {
      case _PersonalizationKey.none:
        return '';
      case _PersonalizationKey.selfLearning:
        return 'Self-Learning';
      case _PersonalizationKey.teaching:
        return 'Teaching';
      case _PersonalizationKey.parentSupport:
        return 'Parent Support';
    }
  }

  String label(AppStrings strings) {
    return strings.personalizationLabelForKey(persistedValue);
  }
}

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

  _PersonalizationKey _selectedPersonalization = _PersonalizationKey.none;
  bool _personalizationDirty = false;

  _EmailValidationError? _emailError;
  _NewPasswordValidationError? _newPasswordError;
  _ConfirmPasswordValidationError? _confirmNewPasswordError;

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

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveNameAndPersonalization() {
    final nameToSave = _nameController.text.trim();
    final personalizationToSave = _selectedPersonalization.persistedValue
        .trim();

    ref.read(userNameProvider.notifier).setUserName(nameToSave);
    ref
        .read(personalizationProvider.notifier)
        .setPersonalization(personalizationToSave);

    final strings = ref.read(appStringsProvider);
    _showSnack(strings.editProfileSnackbarProfileUpdated);
  }

  _EmailValidationError? _validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return _EmailValidationError.empty;

    // Basic validation; intentionally not exhaustive.
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return _EmailValidationError.invalid;

    return null;
  }

  void _saveEmail() {
    final newEmail = _emailController.text;
    final error = _validateEmail(newEmail);

    setState(() {
      _emailError = error;
    });

    if (error != null) return;

    ref.read(userEmailProvider.notifier).setUserEmail(newEmail.trim());
    final strings = ref.read(appStringsProvider);
    _showSnack(strings.editProfileSnackbarEmailUpdated);
  }

  void _attemptPasswordChange() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmNewPasswordController.text;

    _NewPasswordValidationError? newError;
    _ConfirmPasswordValidationError? confirmError;

    if (newPassword.trim().isEmpty) {
      newError = _NewPasswordValidationError.empty;
    }

    if (confirmPassword.trim().isEmpty) {
      confirmError = _ConfirmPasswordValidationError.empty;
    } else if (newPassword != confirmPassword) {
      confirmError = _ConfirmPasswordValidationError.mismatch;
    }

    setState(() {
      _newPasswordError = newError;
      _confirmNewPasswordError = confirmError;
    });

    if (newError != null || confirmError != null) return;

    // Intentionally not persisted: password flows must be handled by backend.
    final strings = ref.read(appStringsProvider);
    _showSnack(strings.editProfileSnackbarPasswordNotConnected);

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    final currentName = ref.watch(userNameProvider);
    final currentEmail = ref.watch(userEmailProvider);
    final currentPersonalization = ref.watch(personalizationProvider);

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
      _selectedPersonalization = _personalizationFromPersistedValue(
        currentPersonalization,
      );
    }

    final emailErrorText = _emailError == null
        ? null
        : <_EmailValidationError, String>{
            _EmailValidationError.empty: strings.editProfileErrorEmailEmpty,
            _EmailValidationError.invalid: strings.editProfileErrorEmailInvalid,
          }[_emailError!];

    final newPasswordErrorText = _newPasswordError == null
        ? null
        : <_NewPasswordValidationError, String>{
            _NewPasswordValidationError.empty:
                strings.editProfileErrorNewPasswordEmpty,
          }[_newPasswordError!];

    final confirmNewPasswordErrorText = _confirmNewPasswordError == null
        ? null
        : <_ConfirmPasswordValidationError, String>{
            _ConfirmPasswordValidationError.empty:
                strings.editProfileErrorConfirmPasswordEmpty,
            _ConfirmPasswordValidationError.mismatch:
                strings.editProfileErrorPasswordsDoNotMatch,
          }[_confirmNewPasswordError!];

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
            appBar: AppBar(title: Text(strings.editProfileTitle)),
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                children: [
                  EditProfileSectionCard(
                    title: strings.editProfileSectionProfileTitle,
                    description: strings.editProfileSectionProfileDescription,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfileUserNameLabel,
                            hint: strings.editProfileUserNameHint,
                            colors: colors,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            _nameDirty = true;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<_PersonalizationKey>(
                          value: _selectedPersonalization,
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          items: _PersonalizationKey.values
                              .map(
                                (value) =>
                                    DropdownMenuItem<_PersonalizationKey>(
                                      value: value,
                                      child: Text(value.label(strings)),
                                    ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPersonalization =
                                  value ?? _PersonalizationKey.none;
                              _personalizationDirty = true;
                            });
                          },
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfilePersonalizationLabel,
                            hint: strings.editProfilePersonalizationHint,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveNameAndPersonalization,
                            child: Text(strings.editProfileSaveProfileButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  EditProfileSectionCard(
                    title: strings.editProfileSectionEmailTitle,
                    description: strings.editProfileSectionEmailDescription,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${strings.editProfileCurrentEmailPrefix}${currentEmail.trim().isEmpty ? strings.profileNotSetLabel : currentEmail}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfileNewEmailLabel,
                            hint: strings.editProfileNewEmailHint,
                            colors: colors,
                            errorText: emailErrorText,
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            _emailDirty = true;
                            if (_emailError != null) {
                              setState(() {
                                _emailError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveEmail,
                            child: Text(strings.editProfileUpdateEmailButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  EditProfileSectionCard(
                    title: strings.editProfileSectionPasswordTitle,
                    description: strings.editProfileSectionPasswordDescription,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfileCurrentPasswordLabel,
                            hint: strings.editProfileCurrentPasswordHint,
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
                                  ? strings.editProfileShowPasswordTooltip
                                  : strings.editProfileHidePasswordTooltip,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfileNewPasswordLabel,
                            hint: strings.editProfileNewPasswordHint,
                            colors: colors,
                            errorText: newPasswordErrorText,
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
                                  ? strings.editProfileShowPasswordTooltip
                                  : strings.editProfileHidePasswordTooltip,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_newPasswordError != null) {
                              setState(() {
                                _newPasswordError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmNewPasswordController,
                          obscureText: _obscureConfirmNewPassword,
                          decoration: signMirrorInputDecoration(
                            label: strings.editProfileConfirmNewPasswordLabel,
                            hint: strings.editProfileConfirmNewPasswordHint,
                            colors: colors,
                            errorText: confirmNewPasswordErrorText,
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
                                  ? strings.editProfileShowPasswordTooltip
                                  : strings.editProfileHidePasswordTooltip,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_confirmNewPasswordError != null) {
                              setState(() {
                                _confirmNewPasswordError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _attemptPasswordChange,
                            child: Text(
                              strings.editProfileChangePasswordButton,
                            ),
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
