import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/practice_mirror_screen.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';

class DictionarySignScreen extends ConsumerWidget {
  final Sign sign;

  const DictionarySignScreen({super.key, required this.sign});

  bool _looksLikeYoutubeId(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    if (v.startsWith('assets/')) return false;
    if (v.contains('http://') || v.contains('https://')) return false;
    if (v.contains('/')) return false;
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(v);
  }

  void _practiceSign(BuildContext context, String targetGestureName) {
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
          targetGestureName: targetGestureName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final effectiveHighContrast =
        settings.highContrast || MediaQuery.of(context).highContrast;

    final language = ref.watch(languageProvider).trim();
    final lowerLanguage = language.toLowerCase();
    final normalizedLanguage =
        (lowerLanguage == 'filipino' || lowerLanguage == 'tagalog')
        ? 'fil'
        : (lowerLanguage == 'english' ? 'en' : language);

    final strings = AppStrings(normalizedLanguage);
    final titleFil = sign.titleFil?.trim();
    final displayTitle =
        strings.isFilipino && titleFil != null && titleFil.isNotEmpty
        ? titleFil
        : sign.title;

    final resolvedTheme = AppTheme.resolve(
      mode: settings.mode,
      highContrast: effectiveHighContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final isHighContrast = effectiveHighContrast;
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
              ? Border.all(
                  color: colorScheme.onSurface.withOpacity(0.85),
                  width: 1.6,
                )
              : null;

          final instructionsColor = useLegacyLightColors
              ? Colors.black87
              : colorScheme.onSurface;

          final missingImageIconColor = useLegacyLightColors
              ? Colors.grey
              : colorScheme.onSurfaceVariant;

          final practiceBackground = useLegacyLightColors
              ? const Color(0xff69B85E)
              : colorScheme.primary;
          final practiceForeground = useLegacyLightColors
              ? Colors.white
              : colorScheme.onPrimary;

          return Scaffold(
            appBar: AppBar(
              title: Text(displayTitle),
              backgroundColor: appBarBackground,
              foregroundColor: appBarForeground,
            ),
            backgroundColor: useLegacyLightColors
                ? null
                : theme.scaffoldBackgroundColor,
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
                      child: sign.videoUrl != null && sign.videoUrl!.isNotEmpty
                          ? AdaptiveVideoPlayer(videoUrl: sign.videoUrl!)
                          : AdaptiveImage(
                              sign.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: missingImageIconColor,
                                  ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Sign Title & Instructions
                    Text(
                      displayTitle,
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
                          sign.instructions ??
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

                    // 3. Navigation Controls (Only Practice)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _practiceSign(context, displayTitle),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text(
                              "Practice",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: practiceBackground,
                              foregroundColor: practiceForeground,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 14,
                              ),
                              side: isHighContrast
                                  ? BorderSide(
                                      color: practiceForeground.withOpacity(
                                        0.9,
                                      ),
                                      width: 1.2,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
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
