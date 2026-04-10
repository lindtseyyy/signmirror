import 'dart:async';
import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';

class PracticeMirrorScreen extends StatefulWidget {
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
  State<PracticeMirrorScreen> createState() => _PracticeMirrorScreenState();
}

class _PracticeMirrorScreenState extends State<PracticeMirrorScreen>
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

  @override
  void initState() {
    super.initState();
    _random = Random(DateTime.now().millisecondsSinceEpoch);
    _predictions = _initialPredictions(target: widget.targetGestureName);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _startSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
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
    final detected = _predictions.first;
    final detectedConfidence = detected.confidence;
    final performanceLabel = _performanceLabel(detectedConfidence);
    final performanceColor = _performanceColor(context, detectedConfidence);

    final isLowLight = _luminance < PracticeMirrorScreen.lowLightThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice & Feedback'),
        backgroundColor: const Color(0xff304166),
        foregroundColor: Colors.white,
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
                frame: _frame,
                luminance: _luminance,
                isLowLight: isLowLight,
                scoringPaused: _scoringPaused,
                detectedGestureLabel: detected.name,
                detectedConfidence: detectedConfidence,
                performanceLabel: performanceLabel,
                performanceColor: performanceColor,
                pulse: _lowConfidencePulse,
                pulseAnimation: _pulseController,
              ),
            ),
          ],
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black12),
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
  final int frame;
  final double luminance;
  final bool isLowLight;
  final bool scoringPaused;
  final String detectedGestureLabel;
  final double detectedConfidence;
  final String performanceLabel;
  final Color performanceColor;
  final bool pulse;
  final Animation<double> pulseAnimation;

  const _MirrorPanel({
    required this.frame,
    required this.luminance,
    required this.isLowLight,
    required this.scoringPaused,
    required this.detectedGestureLabel,
    required this.detectedConfidence,
    required this.performanceLabel,
    required this.performanceColor,
    required this.pulse,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _SimulatedCameraFeed(frame: frame, luminance: luminance),

            // Darken when low light.
            if (isLowLight)
              Container(color: Colors.black.withValues(alpha: 0.35)),

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

class _FpsBadge extends StatelessWidget {
  const _FpsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '15 FPS',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(12),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
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

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                        color: performanceColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
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
    final bg = scoringPaused
        ? const Color(0xffF9A825).withValues(alpha: 0.20)
        : Colors.black.withValues(alpha: 0.24);

    final fg = scoringPaused ? const Color(0xffF9A825) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF9A825).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffF9A825)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xffF9A825)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              scoringPaused
                  ? 'Low light detected. Scoring paused.'
                  : 'Low light detected. Improve lighting for better scoring.',
              style: const TextStyle(fontWeight: FontWeight.w700),
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
    if (!enabled) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.vibration, color: Colors.white, size: 20),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + (animation.value * 0.10);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xffF9A825).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffF9A825)),
        ),
        child: const Icon(Icons.vibration, color: Color(0xffF9A825), size: 20),
      ),
    );
  }
}

class _SimulatedCameraFeed extends StatelessWidget {
  final int frame;
  final double luminance;

  const _SimulatedCameraFeed({required this.frame, required this.luminance});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SimulatedCameraPainter(frame: frame, luminance: luminance),
      child: const SizedBox.expand(),
    );
  }
}

class _SimulatedCameraPainter extends CustomPainter {
  final int frame;
  final double luminance;

  _SimulatedCameraPainter({required this.frame, required this.luminance});

  @override
  void paint(Canvas canvas, Size size) {
    final base = lerpDouble(0.10, 0.55, luminance) ?? 0.3;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xff304166), Colors.black, 1 - base)!,
          Color.lerp(const Color(0xff2A2C41), Colors.black, 1 - base)!,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bgPaint);

    // Noise overlay.
    final seed = frame;
    final rand = Random(seed);

    final noisePaint = Paint()..color = Colors.white.withValues(alpha: 0.03);
    for (var i = 0; i < 140; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 4 + 1;
      final h = rand.nextDouble() * 4 + 1;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), noisePaint);
    }

    // Simple "person" silhouette.
    final center = Offset(size.width * 0.52, size.height * 0.55);
    final bodyPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, size.height * 0.30),
      size.width * 0.08,
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, size.height * 0.58),
          width: size.width * 0.30,
          height: size.height * 0.46,
        ),
        const Radius.circular(28),
      ),
      bodyPaint,
    );

    // "Hand box" region to simulate detection.
    final handBox = Rect.fromCenter(
      center: Offset(
        size.width * (0.25 + 0.10 * sin(frame / 10.0)),
        size.height * (0.52 + 0.10 * cos(frame / 12.0)),
      ),
      width: size.width * 0.22,
      height: size.height * 0.22,
    );

    final boxPaint = Paint()
      ..color = const Color(0xff2D68FF).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(handBox, const Radius.circular(14)),
      boxPaint,
    );

    // Corner markers.
    final cornerPaint = Paint()
      ..color = const Color(0xff2D68FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const corner = 14.0;
    void cornerLine(Offset p, Offset a, Offset b) {
      canvas.drawLine(p + a, p + b, cornerPaint);
    }

    cornerLine(handBox.topLeft, Offset.zero, const Offset(corner, 0));
    cornerLine(handBox.topLeft, Offset.zero, const Offset(0, corner));

    cornerLine(handBox.topRight, Offset.zero, const Offset(-corner, 0));
    cornerLine(handBox.topRight, Offset.zero, const Offset(0, corner));

    cornerLine(handBox.bottomLeft, Offset.zero, const Offset(corner, 0));
    cornerLine(handBox.bottomLeft, Offset.zero, const Offset(0, -corner));

    cornerLine(handBox.bottomRight, Offset.zero, const Offset(-corner, 0));
    cornerLine(handBox.bottomRight, Offset.zero, const Offset(0, -corner));
  }

  @override
  bool shouldRepaint(covariant _SimulatedCameraPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.luminance != luminance;
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
