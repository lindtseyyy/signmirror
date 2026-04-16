import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  bool _nameDirty = false;

  String? _selectedPersonalization;
  bool _personalizationDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> _personalizationOptions() {
    return const <String>['', 'Self-Learning', 'Teaching', 'Parent Support'];
  }

  void _save(String currentPersonalization) {
    final nameToSave = _nameController.text.trim();
    final personalizationToSave =
        (_selectedPersonalization ?? currentPersonalization).trim();

    ref.read(userNameProvider.notifier).setUserName(nameToSave);
    ref
        .read(personalizationProvider.notifier)
        .setPersonalization(personalizationToSave);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentName = ref.watch(userNameProvider);
    final currentPersonalization = ref.watch(personalizationProvider);

    final options = _personalizationOptions();

    if (!_nameDirty && _nameController.text != currentName) {
      _nameController.text = currentName;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
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
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'User name'),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    _nameDirty = true;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: effectivePersonalization,
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
                  decoration:
                      const InputDecoration(labelText: 'Personalization'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _save(currentPersonalization),
                    child: const Text('Save'),
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
