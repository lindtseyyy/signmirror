import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signmirror_flutter/features/location_suggestions/data/contextual_zones.dart';
import 'package:signmirror_flutter/features/location_suggestions/data/fsl_vocab_map.dart';
import 'package:signmirror_flutter/features/location_suggestions/domain/contextual_zone.dart';
import 'package:signmirror_flutter/notifications/notification_service.dart';

class LocationSuggestionService with WidgetsBindingObserver {
  LocationSuggestionService({
    List<ContextualZone> zones = predefinedContextualZones,
    Map<ZoneCategory, List<String>> vocabByZoneCategory =
        fslVocabByZoneCategory,
    NotificationService? notificationService,
    DateTime Function()? now,
  }) : _zones = zones,
       _vocabByZoneCategory = vocabByZoneCategory,
       _notificationService =
           notificationService ?? NotificationService.instance,
       _now = now ?? DateTime.now;

  static const double defaultEnterRadiusMeters = 100.0;
  static const double _exitHysteresisMeters = 10.0;

  // FR-LC-06: show within 5 seconds of entering.
  // Use an immediate (next-tick) timer to preserve cancellation semantics.
  static const Duration _enterNotificationDelay = Duration.zero;
  static const Duration _perZoneCooldown = Duration(minutes: 10);

  final List<ContextualZone> _zones;
  final Map<ZoneCategory, List<String>> _vocabByZoneCategory;
  final NotificationService _notificationService;
  final DateTime Function() _now;

  StreamSubscription<Position>? _positionSubscription;
  bool _started = false;
  bool _lifecycleObserverRegistered = false;

  final Map<String, _ZoneMonitorState> _zoneStates =
      <String, _ZoneMonitorState>{};

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _registerLifecycleObserverIfNeeded();

    final canMonitor = await _canMonitorLocationBestEffort();
    if (!canMonitor) {
      await stop();
      return;
    }

    await _startPositionStream();
  }

  Future<void> stop() async {
    _started = false;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    for (final state in _zoneStates.values) {
      state._inside = false;
      state._pendingEnterNotification?.cancel();
      state._pendingEnterNotification = null;
    }

    _unregisterLifecycleObserverIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Foreground-only: cancel stream when not resumed.
    if (!_started) return;

    if (state == AppLifecycleState.resumed) {
      unawaited(_startPositionStream());
      return;
    }

    unawaited(_positionSubscription?.cancel());
    _positionSubscription = null;

    // Don't allow delayed notifications while backgrounded.
    for (final zoneState in _zoneStates.values) {
      zoneState._inside = false;
      zoneState._pendingEnterNotification?.cancel();
      zoneState._pendingEnterNotification = null;
    }
  }

  void _registerLifecycleObserverIfNeeded() {
    if (_lifecycleObserverRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverRegistered = true;
  }

  void _unregisterLifecycleObserverIfNeeded() {
    if (!_lifecycleObserverRegistered) return;
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleObserverRegistered = false;
  }

  Future<bool> _canMonitorLocationBestEffort() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e, st) {
      debugPrint(
        'LocationSuggestionService: permission/service check failed: $e',
      );
      debugPrint('$st');
      return false;
    }
  }

  Future<void> _startPositionStream() async {
    if (!_started) return;
    if (_positionSubscription != null) return;

    final canMonitor = await _canMonitorLocationBestEffort();
    if (!canMonitor) {
      await stop();
      return;
    }

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
            _handlePosition,
            onError: (Object e, StackTrace st) {
              debugPrint(
                'LocationSuggestionService: position stream error: $e',
              );
              debugPrint('$st');
              // Permission errors or disabled services can surface here.
              unawaited(stop());
            },
            cancelOnError: false,
          );
    } catch (e, st) {
      debugPrint(
        'LocationSuggestionService: failed to start position stream: $e',
      );
      debugPrint('$st');
      await stop();
    }
  }

  void _handlePosition(Position position) {
    if (!_started) return;
    if (_zones.isEmpty) return;

    for (final zone in _zones) {
      final zoneState = _zoneStates.putIfAbsent(
        zone.id,
        () => _ZoneMonitorState(),
      );

      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        zone.latitude,
        zone.longitude,
      );

      final enterRadius = zone.radiusMeters.toDouble();
      final exitRadius = enterRadius + _exitHysteresisMeters;

      if (zoneState._inside) {
        if (distanceMeters > exitRadius) {
          zoneState._inside = false;
          zoneState._pendingEnterNotification?.cancel();
          zoneState._pendingEnterNotification = null;
        }
        continue;
      }

      // Currently outside.
      if (distanceMeters <= enterRadius) {
        zoneState._inside = true;
        _scheduleEnterNotification(zone, zoneState);
      }
    }
  }

  void _scheduleEnterNotification(
    ContextualZone zone,
    _ZoneMonitorState state,
  ) {
    state._pendingEnterNotification?.cancel();
    state._pendingEnterNotification = Timer(_enterNotificationDelay, () {
      unawaited(_maybeNotifyForZone(zone));
    });
  }

  Future<void> _maybeNotifyForZone(ContextualZone zone) async {
    if (!_started) return;

    final state = _zoneStates[zone.id];
    if (state == null || !state._inside) return;

    final lastNotifiedAt = state._lastNotifiedAt;
    if (lastNotifiedAt != null &&
        _now().difference(lastNotifiedAt) < _perZoneCooldown) {
      return;
    }

    final body = _formatNotificationBody(zone.category);

    try {
      await _notificationService.showLocationSuggestion(body: body);
      state._lastNotifiedAt = _now();
    } catch (e, st) {
      debugPrint('LocationSuggestionService: failed to show notification: $e');
      debugPrint('$st');
      // Best-effort: do not crash; do not mark cooldown on failure.
    }
  }

  String _formatNotificationBody(ZoneCategory category) {
    final categoryHuman = _humanizeCategory(category);
    final vocab = _vocabByZoneCategory[category] ?? const <String>[];

    if (vocab.isEmpty) {
      return "You're near a $categoryHuman.";
    }

    return "You're near a $categoryHuman. These FSL signs may be helpful: ${vocab.join(', ')}.";
  }

  String _humanizeCategory(ZoneCategory category) {
    final trimmed = _zoneCategoryKey(category).trim();
    if (trimmed.isEmpty) return 'Location';

    final withUnderscores = trimmed.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]}_${m[2]}',
    );
    final normalized = withUnderscores.replaceAll('-', '_');
    final parts = normalized
        .split('_')
        .where((p) => p.trim().isNotEmpty)
        .map((p) => p.trim().toLowerCase());

    final words = parts.map((p) {
      if (p.length == 1) return p.toUpperCase();
      return '${p[0].toUpperCase()}${p.substring(1)}';
    }).toList();

    return words.isEmpty ? 'Location' : words.join(' ');
  }

  String _zoneCategoryKey(ZoneCategory category) {
    final raw = category.toString();
    final dotIndex = raw.indexOf('.');
    return dotIndex == -1 ? raw : raw.substring(dotIndex + 1);
  }
}

class _ZoneMonitorState {
  bool _inside = false;
  Timer? _pendingEnterNotification;
  DateTime? _lastNotifiedAt;
}
