import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';
import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';

class PracticeMirrorScreen extends ConsumerStatefulWidget {
  final String referenceVideoUrl;
  final String targetGestureName;

  const PracticeMirrorScreen({
    super.key,
    required this.referenceVideoUrl,
    required this.targetGestureName,
  });

  static const double lowLightThreshold = 0.28;
  static const Duration lowLightPauseAfter = Duration(seconds: 10);

  @override
  ConsumerState<PracticeMirrorScreen> createState() =>
      _PracticeMirrorScreenState();
}

class _PracticeMirrorScreenState extends ConsumerState<PracticeMirrorScreen>
    with SingleTickerProviderStateMixin {
  static const _frameInterval = Duration(milliseconds: 66); // ~15 FPS

  late final Random _random;
  Timer? _timer;
  int _frame = 0;

  // Simulated sensor/processing values.
  double _luminance = 0.6; // 0..1
  DateTime? _lowLightSince;
  bool _scoringPaused = false;

  // Gesture predictions (mocked).
  late List<_GesturePrediction> _predictions;

  // Haptic indicator state.
  bool _lowConfidencePulse = false;
  DateTime _lastHapticAt = DateTime.fromMillisecondsSinceEpoch(0);

  // Simple animation for the haptic icon.
  late final AnimationController _pulseController;

  CameraController? _cameraController;
  Future<void>? _cameraInit;
  bool _cameraPermissionDenied = false;
  String? _cameraError;

  late final PracticeStatsNotifier _practiceStatsNotifier;

  @override
  void initState() {
    super.initState();
    _random = Random(DateTime.now().millisecondsSinceEpoch);
    _predictions = _initialPredictions(target: widget.targetGestureName);
    _practiceStatsNotifier = ref.read(practiceStatsProvider.notifier);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _initFrontCamera();
    _startSimulation();
  }

  @override
  void dispose() {
    final accuracyRate = _predictions.isNotEmpty
        ? _predictions.first.confidence
        : 0.0;

    // Avoid modifying providers during widget lifecycle teardown.
    // Schedule the write for the next event-loop turn.
    Future(() {
      _practiceStatsNotifier.recordAttempt(
        signTitle: widget.targetGestureName,
        accuracyRate: accuracyRate,
      );
    });

    _timer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initFrontCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!mounted) return;

      if (!status.isGranted) {
        setState(() {
          _cameraPermissionDenied = true;
        });
        return;
      }

      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No cameras available on this device.';
        });
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController?.dispose();
      _cameraController = controller;

      final init = controller.initialize();
      _cameraInit = init;
      await init;
      if (!mounted) return;

      setState(() {
        _cameraPermissionDenied = false;
        _cameraError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.toString();
      });
    }
  }

  void _startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(_frameInterval, (_) {
      if (!mounted) return;

      setState(() {
        _frame++;
        _luminance = _nextLuminance(_luminance, _frame);
        _updateLowLightState();

        if (!_scoringPaused) {
          _predictions = _nextPredictions(_predictions);
        }

        _updateLowConfidenceIndicator();
      });
    });
  }

  double _nextLuminance(double current, int frame) {
    // Smooth-ish changing luminance with occasional dips.
    final wave = 0.08 * sin(frame / 18.0);
    final jitter = (_random.nextDouble() - 0.5) * 0.06;
    final dip = (_random.nextDouble() < 0.012) ? -0.35 : 0.0;
    final next = (current * 0.90) + (0.10 * (current + wave + jitter + dip));
    return next.clamp(0.0, 1.0);
  }

  void _updateLowLightState() {
    final now = DateTime.now();
    final isLowLight = _luminance < PracticeMirrorScreen.lowLightThreshold;

    if (isLowLight) {
      _lowLightSince ??= now;

      final elapsed = now.difference(_lowLightSince!);
      _scoringPaused = elapsed >= PracticeMirrorScreen.lowLightPauseAfter;
    } else {
      _lowLightSince = null;
      _scoringPaused = false;
    }
  }

  void _updateLowConfidenceIndicator() {
    final detected = _predictions.first;
    final isLow = detected.confidence < 60;
    if (isLow && !_scoringPaused) {
      final now = DateTime.now();
      if (now.difference(_lastHapticAt) >= const Duration(seconds: 2)) {
        _lastHapticAt = now;
        HapticFeedback.lightImpact();
      }

      if (!_lowConfidencePulse) {
        _lowConfidencePulse = true;
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_lowConfidencePulse) {
        _lowConfidencePulse = false;
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  List<_GesturePrediction> _initialPredictions({required String target}) {
    final others = <String>['Hello', 'Thank you', 'Yes', 'No', 'Good'];
    others.removeWhere((g) => g.toLowerCase() == target.toLowerCase());

    final selectedOthers = others.take(2).toList();

    return [
      _GesturePrediction(name: target, confidence: 72),
      _GesturePrediction(name: selectedOthers[0], confidence: 18),
      _GesturePrediction(name: selectedOthers[1], confidence: 10),
    ];
  }

  List<_GesturePrediction> _nextPredictions(List<_GesturePrediction> current) {
    final updated = <_GesturePrediction>[];

    for (final prediction in current) {
      final baseJitter = (prediction.name == widget.targetGestureName) ? 8 : 6;
      final drift = (_random.nextDouble() - 0.5) * baseJitter;

      // Occasional instability (to show the UI reacting).
      final shock = (_random.nextDouble() < 0.04)
          ? ((_random.nextDouble() - 0.5) * 28)
          : 0.0;

      final next = (prediction.confidence + drift + shock).clamp(0.0, 100.0);
      updated.add(prediction.copyWith(confidence: next));
    }

    // Normalize roughly so they feel like "probabilities".
    final sum = updated.fold<double>(0.0, (acc, p) => acc + p.confidence);
    if (sum > 0) {
      for (var i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(
          confidence: (updated[i].confidence / sum * 100.0).clamp(0.0, 100.0),
        );
      }
    }

    updated.sort((a, b) => b.confidence.compareTo(a.confidence));
    return updated;
  }

  String _performanceLabel(double confidence) {
    if (confidence >= 80) return 'Correct';
    if (confidence >= 60) return 'Almost';
    return 'Incorrect';
  }

  Color _performanceColor(BuildContext context, double confidence) {
    // Reuse existing palette already present in the app.
    if (confidence >= 80) return const Color(0xff69B85E);
    if (confidence >= 60) return const Color(0xffF9A825);
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final isDark = themeSettings.mode == AppThemeMode.dark;
    final isHighContrast = themeSettings.highContrast;
    final useLegacyLightColors = !isDark && !isHighContrast;

    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: isHighContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: _PracticeModeTheme(
        useLegacyLightColors: useLegacyLightColors,
        isHighContrast: isHighContrast,
        child: Builder(
          builder: (context) {
            final detected = _predictions.first;
            final detectedConfidence = detected.confidence;
            final performanceLabel = _performanceLabel(detectedConfidence);
            final performanceColor = _performanceColor(
              context,
              detectedConfidence,
            );

            final isLowLight =
                _luminance < PracticeMirrorScreen.lowLightThreshold;

            final scheme = Theme.of(context).colorScheme;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Practice & Feedback'),
                backgroundColor: useLegacyLightColors
                    ? const Color(0xff304166)
                    : scheme.primary,
                foregroundColor: useLegacyLightColors
                    ? Colors.white
                    : scheme.onPrimary,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: _ReferencePanel(
                        videoUrl: widget.referenceVideoUrl,
                        targetGestureName: widget.targetGestureName,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _MirrorPanel(
                        isLowLight: isLowLight,
                        scoringPaused: _scoringPaused,
                        detectedGestureLabel: detected.name,
                        detectedConfidence: detectedConfidence,
                        performanceLabel: performanceLabel,
                        performanceColor: performanceColor,
                        pulse: _lowConfidencePulse,
                        pulseAnimation: _pulseController,
                        cameraController: _cameraController,
                        cameraInit: _cameraInit,
                        cameraPermissionDenied: _cameraPermissionDenied,
                        cameraError: _cameraError,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PracticeModeTheme extends InheritedWidget {
  final bool useLegacyLightColors;
  final bool isHighContrast;

  const _PracticeModeTheme({
    required this.useLegacyLightColors,
    required this.isHighContrast,
    required super.child,
  });

  static _PracticeModeTheme of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_PracticeModeTheme>();
    assert(result != null, 'No _PracticeModeTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_PracticeModeTheme oldWidget) {
    return useLegacyLightColors != oldWidget.useLegacyLightColors ||
        isHighContrast != oldWidget.isHighContrast;
  }
}

class _ReferencePanel extends StatelessWidget {
  final String videoUrl;
  final String targetGestureName;

  const _ReferencePanel({
    required this.videoUrl,
    required this.targetGestureName,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final panelBg = cfg.useLegacyLightColors
        ? Colors.black12
        : scheme.surfaceVariant;
    final panelBorder = (!cfg.useLegacyLightColors && cfg.isHighContrast)
        ? Border.all(color: scheme.outline, width: 1.5)
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(16),
                border: panelBorder,
              ),
            ),
            AdaptiveVideoPlayer(videoUrl: videoUrl),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _PanelHeader(
                title: 'Reference Tutorial',
                subtitle: 'Target: $targetGestureName',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MirrorPanel extends StatelessWidget {
  final bool isLowLight;
  final bool scoringPaused;
  final String detectedGestureLabel;
  final double detectedConfidence;
  final String performanceLabel;
  final Color performanceColor;
  final bool pulse;
  final Animation<double> pulseAnimation;

  final CameraController? cameraController;
  final Future<void>? cameraInit;
  final bool cameraPermissionDenied;
  final String? cameraError;

  const _MirrorPanel({
    required this.isLowLight,
    required this.scoringPaused,
    required this.detectedGestureLabel,
    required this.detectedConfidence,
    required this.performanceLabel,
    required this.performanceColor,
    required this.pulse,
    required this.pulseAnimation,
    required this.cameraController,
    required this.cameraInit,
    required this.cameraPermissionDenied,
    required this.cameraError,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);

    final lowLightOverlayOpacity = cfg.isHighContrast ? 0.46 : 0.35;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _LiveCameraLayer(
              controller: cameraController,
              init: cameraInit,
              permissionDenied: cameraPermissionDenied,
              error: cameraError,
            ),

            // Darken when low light.
            if (isLowLight)
              Container(
                color: Colors.black.withOpacity(lowLightOverlayOpacity),
              ),

            Positioned(
              left: 12,
              top: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProcessingPill(scoringPaused: scoringPaused),
                  const SizedBox(width: 8),
                  const _FpsBadge(),
                ],
              ),
            ),

            // Haptic indicator icon (visual only).
            Positioned(
              right: 12,
              top: 12,
              child: _HapticIndicator(
                enabled: pulse,
                animation: pulseAnimation,
              ),
            ),

            // Bottom HUD stack: low-light warning (if any) + compact scoring UI.
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLowLight) ...[
                    _LowLightBanner(scoringPaused: scoringPaused),
                    const SizedBox(height: 8),
                  ],
                  _ScoreHud(
                    performanceLabel: performanceLabel,
                    performanceColor: performanceColor,
                    confidence: detectedConfidence,
                    detectedGestureLabel: detectedGestureLabel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCameraLayer extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? init;
  final bool permissionDenied;
  final String? error;

  const _LiveCameraLayer({
    required this.controller,
    required this.init,
    required this.permissionDenied,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (permissionDenied) {
      return const _CameraMessage(
        icon: Icons.no_photography,
        title: 'Camera permission needed',
        subtitle: 'Enable camera access to show live practice feed.',
      );
    }

    if (error != null) {
      return _CameraMessage(
        icon: Icons.error_outline,
        title: 'Camera unavailable',
        subtitle: error!,
      );
    }

    if (controller == null || init == null) {
      return const _CameraMessage(
        icon: Icons.camera_alt,
        title: 'Starting camera…',
        subtitle: 'Preparing live preview.',
        showSpinner: true,
      );
    }

    return FutureBuilder<void>(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !controller!.value.isInitialized) {
          return const _CameraMessage(
            icon: Icons.camera_alt,
            title: 'Starting camera…',
            subtitle: 'Preparing live preview.',
            showSpinner: true,
          );
        }

        return _CameraPreviewCover(controller: controller!);
      },
    );
  }
}

class _CameraPreviewCover extends StatelessWidget {
  final CameraController controller;

  const _CameraPreviewCover({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final aspect = controller.value.aspectRatio;

    final bg = cfg.useLegacyLightColors
        ? Colors.black12
        : scheme.surfaceVariant;
    final border = (!cfg.useLegacyLightColors && cfg.isHighContrast)
        ? Border.all(color: scheme.outline, width: 1.5)
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(color: bg, border: border),
      child: Center(
        child: AspectRatio(
          aspectRatio: aspect > 0 ? aspect : 3 / 4,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showSpinner;

  const _CameraMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final bg = cfg.useLegacyLightColors
        ? Colors.black12
        : scheme.surfaceVariant;
    final border = (!cfg.useLegacyLightColors && cfg.isHighContrast)
        ? Border.all(color: scheme.outline, width: 1.5)
        : null;

    final iconColor = cfg.useLegacyLightColors
        ? Colors.black54
        : scheme.onSurfaceVariant;
    final subtitleColor = cfg.useLegacyLightColors
        ? Colors.black.withOpacity(0.65)
        : scheme.onSurfaceVariant.withOpacity(cfg.isHighContrast ? 1.0 : 0.85);

    return DecoratedBox(
      decoration: BoxDecoration(color: bg, border: border),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSpinner) ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Icon(icon, size: 30, color: iconColor),
                  const SizedBox(height: 10),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cfg.useLegacyLightColors ? null : scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: subtitleColor),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FpsBadge extends StatelessWidget {
  const _FpsBadge();

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final bgOpacity = cfg.useLegacyLightColors
        ? 0.12
        : (cfg.isHighContrast ? 0.22 : 0.16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(999),
        border: (!cfg.useLegacyLightColors && cfg.isHighContrast)
            ? Border.all(color: scheme.primary.withOpacity(0.9), width: 1.5)
            : null,
      ),
      child: Text(
        '15 FPS',
        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PanelHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);

    final scrimOpacity = cfg.isHighContrast ? 0.42 : 0.30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(scrimOpacity),
        borderRadius: BorderRadius.circular(12),
        border: cfg.isHighContrast
            ? Border.all(color: Colors.white.withOpacity(0.65), width: 1.0)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(cfg.isHighContrast ? 0.95 : 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ScoreHud extends StatelessWidget {
  final String performanceLabel;
  final Color performanceColor;
  final double confidence;
  final String detectedGestureLabel;

  const _ScoreHud({
    required this.performanceLabel,
    required this.performanceColor,
    required this.confidence,
    required this.detectedGestureLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        final percentSize = isNarrow ? 20.0 : 24.0;
        final chipFontSize = isNarrow ? 11.0 : 12.0;

        final cfg = _PracticeModeTheme.of(context);
        final scheme = Theme.of(context).colorScheme;

        final hudBg = cfg.useLegacyLightColors
            ? Colors.white.withOpacity(0.92)
            : scheme.surface.withOpacity(cfg.isHighContrast ? 0.96 : 0.90);

        final hudBorderColor = cfg.useLegacyLightColors
            ? Colors.black.withOpacity(0.06)
            : scheme.outline.withOpacity(cfg.isHighContrast ? 0.90 : 0.45);

        final hudBorderWidth = (!cfg.useLegacyLightColors && cfg.isHighContrast)
            ? 1.5
            : 1.0;

        final chipBgOpacity = cfg.useLegacyLightColors
            ? 0.16
            : (cfg.isHighContrast ? 0.32 : 0.22);

        final chipBorder = (!cfg.useLegacyLightColors && cfg.isHighContrast)
            ? Border.all(color: performanceColor.withOpacity(0.85), width: 1.0)
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: hudBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hudBorderColor, width: hudBorderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Detected: $detectedGestureLabel',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: performanceColor.withOpacity(chipBgOpacity),
                        borderRadius: BorderRadius.circular(999),
                        border: chipBorder,
                      ),
                      child: Text(
                        performanceLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: performanceColor,
                          fontSize: chipFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${confidence.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: percentSize,
                  fontWeight: FontWeight.w900,
                  color: performanceColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProcessingPill extends StatelessWidget {
  final bool scoringPaused;

  const _ProcessingPill({required this.scoringPaused});

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final Color bg;
    final Color fg;
    BoxBorder? border;

    if (cfg.useLegacyLightColors) {
      bg = scoringPaused
          ? const Color(0xffF9A825).withOpacity(0.20)
          : Colors.black.withOpacity(0.24);
      fg = scoringPaused ? const Color(0xffF9A825) : Colors.white;
    } else {
      bg = scheme.surface.withOpacity(cfg.isHighContrast ? 0.96 : 0.82);
      fg = scoringPaused ? const Color(0xffF9A825) : scheme.onSurface;

      if (cfg.isHighContrast) {
        border = Border.all(
          color: scoringPaused ? const Color(0xffF9A825) : scheme.outline,
          width: 1.5,
        );
      } else if (scoringPaused) {
        border = Border.all(color: const Color(0xffF9A825));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scoringPaused ? Icons.pause_circle_filled : Icons.bolt,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            scoringPaused ? 'Paused' : 'Processing',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowLightBanner extends StatelessWidget {
  final bool scoringPaused;

  const _LowLightBanner({required this.scoringPaused});

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);

    final bgOpacity = cfg.useLegacyLightColors
        ? 0.16
        : (cfg.isHighContrast ? 0.28 : 0.20);

    final borderWidth = (!cfg.useLegacyLightColors && cfg.isHighContrast)
        ? 2.0
        : 1.0;

    final textColor = cfg.useLegacyLightColors ? null : Colors.black;
    final iconColor = cfg.useLegacyLightColors
        ? const Color(0xffF9A825)
        : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF9A825).withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffF9A825), width: borderWidth),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              scoringPaused
                  ? 'Low light detected. Scoring paused.'
                  : 'Low light detected. Improve lighting for better scoring.',
              style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _HapticIndicator extends StatelessWidget {
  final bool enabled;
  final Animation<double> animation;

  const _HapticIndicator({required this.enabled, required this.animation});

  @override
  Widget build(BuildContext context) {
    final cfg = _PracticeModeTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (!enabled) {
      final bg = cfg.useLegacyLightColors
          ? Colors.black.withOpacity(0.18)
          : scheme.surface.withOpacity(cfg.isHighContrast ? 0.92 : 0.75);
      final fg = cfg.useLegacyLightColors ? Colors.white : scheme.onSurface;
      final border = (!cfg.useLegacyLightColors && cfg.isHighContrast)
          ? Border.all(color: scheme.outline, width: 1.5)
          : null;

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Icon(Icons.vibration, color: fg, size: 20),
      );
    }

    final bg = cfg.useLegacyLightColors
        ? const Color(0xffF9A825).withOpacity(0.25)
        : scheme.surface.withOpacity(cfg.isHighContrast ? 0.94 : 0.82);

    final borderWidth = (!cfg.useLegacyLightColors && cfg.isHighContrast)
        ? 2.0
        : 1.0;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + (animation.value * 0.10);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffF9A825),
            width: borderWidth,
          ),
        ),
        child: Icon(Icons.vibration, color: const Color(0xffF9A825), size: 20),
      ),
    );
  }
}

class _GesturePrediction {
  final String name;
  final double confidence;

  const _GesturePrediction({required this.name, required this.confidence});

  _GesturePrediction copyWith({String? name, double? confidence}) {
    return _GesturePrediction(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
    );
  }
}
