import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/practice_mirror_screen.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/adaptive_image.dart';

class LessonSignsScreen extends ConsumerStatefulWidget {
  final Lesson? lesson;

  const LessonSignsScreen({super.key, this.lesson});

  @override
  ConsumerState<LessonSignsScreen> createState() => _LessonSignsScreenState();
}

class _LessonSignsScreenState extends ConsumerState<LessonSignsScreen> {
  int currentIndex = 0;
  List<Sign> signs = [];
  bool isLoading = true;

  bool _looksLikeYoutubeId(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    if (v.startsWith('assets/')) return false;
    if (v.contains('http://') || v.contains('https://')) return false;
    if (v.contains('/')) return false;
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(v);
  }

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    if (widget.lesson != null) {
      final isarService = ref.read(isarServiceProvider);
      final loadedSigns = await isarService.getSignsByCategory(
        widget.lesson!.title,
      );
      setState(() {
        signs = loadedSigns;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _nextSign() {
    if (currentIndex < signs.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _prevSign() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _practiceSign(Sign sign) {
    final videoUrl = sign.videoUrl?.trim();
    final videoId = sign.videoId?.trim();
    final referenceVideoUrl = (videoUrl != null && videoUrl.isNotEmpty)
        ? (_looksLikeYoutubeId(videoUrl)
              ? 'https://www.youtube.com/watch?v=$videoUrl'
              : videoUrl)
        : (videoId != null && videoId.isNotEmpty)
        ? 'https://www.youtube.com/watch?v=$videoId'
        : 'assets/videos/sample_portrait_video.mp4';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeMirrorScreen(
          referenceVideoUrl: referenceVideoUrl,
          targetGestureName: sign.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: themeSettings.highContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final isHighContrast = themeSettings.highContrast;
          final isDark = theme.brightness == Brightness.dark;
          final useLegacyLightColors = !isDark && !isHighContrast;

          final appBarBackground = useLegacyLightColors
              ? const Color(0xff304166)
              : colorScheme.primary;
          final appBarForeground = useLegacyLightColors
              ? Colors.white
              : colorScheme.onPrimary;

          final videoBackground = useLegacyLightColors
              ? Colors.black12
              : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);
          final videoBorder = isHighContrast
              ? Border.all(color: colorScheme.outline, width: 1.2)
              : null;

          final instructionsColor = useLegacyLightColors
              ? Colors.black87
              : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurface);

          final progressTextColor = useLegacyLightColors
              ? Colors.grey
              : (isHighContrast
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant);

          final prevBackground = useLegacyLightColors
              ? Colors.grey.shade300
              : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);
          final prevForeground = useLegacyLightColors
              ? Colors.black
              : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurface);

          final nextBackground = useLegacyLightColors
              ? const Color(0xff304166)
              : colorScheme.primary;
          final nextForeground = useLegacyLightColors
              ? Colors.white
              : colorScheme.onPrimary;

          final BorderSide? navButtonSide =
              (!useLegacyLightColors && isHighContrast)
              ? BorderSide(color: colorScheme.outline, width: 1.2)
              : null;
          final BorderSide? practiceButtonSide =
              (!useLegacyLightColors && isHighContrast)
              ? BorderSide(color: colorScheme.onSurface, width: 1.2)
              : null;

          if (isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (signs.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.lesson?.title ?? "Lesson"),
                backgroundColor: appBarBackground,
                foregroundColor: appBarForeground,
              ),
              body: Center(
                child: Text(
                  "No signs available for this lesson.",
                  style: useLegacyLightColors
                      ? null
                      : TextStyle(
                          color: isHighContrast
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final currentSign = signs[currentIndex];
          final hasNext = currentIndex < signs.length - 1;
          final hasPrev = currentIndex > 0;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.lesson?.title ?? "Lesson"),
              backgroundColor: appBarBackground,
              foregroundColor: appBarForeground,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. "Video" Section
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: videoBackground,
                        borderRadius: BorderRadius.circular(15),
                        border: videoBorder,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child:
                          currentSign.videoUrl != null &&
                              currentSign.videoUrl!.isNotEmpty
                          ? AdaptiveVideoPlayer(videoUrl: currentSign.videoUrl!)
                          : AdaptiveImage(
                              currentSign.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Sign Title & Instructions
                    Text(
                      currentSign.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          currentSign.instructions ??
                              "Follow the hand gesture shown in the visual above. Make sure your hand gestures are clear and recognizable.",
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: instructionsColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // 3. Navigation Controls
                    Row(
                      children: [
                        // Previous Button
                        Expanded(
                          child: Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: hasPrev,
                            child: ElevatedButton.icon(
                              onPressed: _prevSign,
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text(
                                "Prev",
                                style: TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 12,
                                ),
                                backgroundColor: prevBackground,
                                foregroundColor: prevForeground,
                                side: navButtonSide,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Practice Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _practiceSign(currentSign),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text(
                              "Practice",
                              style: TextStyle(
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff69B85E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 12,
                              ),
                              side: practiceButtonSide,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Next Button
                        Expanded(
                          child: Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: hasNext,
                            child: ElevatedButton(
                              onPressed: _nextSign,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 12,
                                ),
                                backgroundColor: nextBackground,
                                foregroundColor: nextForeground,
                                side: navButtonSide,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Flexible(
                                    child: Text(
                                      "Next",
                                      style: TextStyle(
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Progress Indicator
                    Center(
                      child: Text(
                        "Sign ${currentIndex + 1} of ${signs.length}",
                        style: TextStyle(
                          color: progressTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
