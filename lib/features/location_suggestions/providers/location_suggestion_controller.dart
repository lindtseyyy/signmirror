import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/features/location_suggestions/services/location_suggestion_service.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';

final locationSuggestionControllerProvider =
    Provider<LocationSuggestionController>((ref) {
      final controller = LocationSuggestionController(ref);
      controller._init();
      ref.onDispose(controller.dispose);
      return controller;
    });

class LocationSuggestionController {
  LocationSuggestionController(this._ref)
    : _service = LocationSuggestionService();

  final Ref _ref;
  final LocationSuggestionService _service;

  ProviderSubscription<bool>? _enabledSubscription;

  void _init() {
    _enabledSubscription = _ref.listen<bool>(
      locationSuggestionsEnabledProvider,
      (previous, next) {
        if (next) {
          unawaited(_service.start());
        } else {
          unawaited(_service.stop());
        }
      },
      fireImmediately: true,
    );
  }

  void dispose() {
    _enabledSubscription?.close();
    _enabledSubscription = null;
    unawaited(_service.stop());
  }
}
