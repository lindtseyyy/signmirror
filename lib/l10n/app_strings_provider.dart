import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';

/// Exposes [AppStrings] based on the persisted app language.
///
/// [languageProvider] stores language codes like 'en', 'fil' (or 'tl').
final appStringsProvider = Provider<AppStrings>((ref) {
  final code = ref.watch(languageProvider);
  return AppStrings(code);
});
