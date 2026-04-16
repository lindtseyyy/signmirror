import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/achievements_theme.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';

AchievementsTheme _fallbackAchievementsTheme(ThemeData theme) {
  if (theme.brightness == Brightness.dark) {
    return AchievementsTheme.dark();
  }

  return const AchievementsTheme(
    cardBackgroundColor: Color(0xFFFFFFFF),
    cardBorderColor: Color(0x00000000),
    cardBorderWidth: 0.0,
    showCardBorder: false,
    mutedTextColor: Color(0x99000000),
    lockedTextColor: Color(0x66000000),
    progressTrackColor: Color(0xFFEEEEEE),
    progressValueColor: Color(0xFF69B85E),
    headerAccentTextColor: Color(0xFF304166),
    useCardShadows: true,
  );
}

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final strings = ref.watch(appStringsProvider);
    final userName = ref.watch(userNameProvider);

    final displayName = userName.trim().isEmpty
        ? strings.profileDefaultUserLabel
        : userName.trim();

    final headerMessage = strings.achievementsHeaderMessage(displayName);
    final lockedLabel = strings.achievementsLockedLabel;

    final studiousDescription = strings.achievementsCompletedChallenge(
      strings.achievementsChallengeStayConsistent7Days,
    );

    final quickieDescription = strings.achievementsCompletedChallenge(
      strings.achievementsChallengeLearn5SignsOneWeek,
    );

    final ambitiousDescription = strings.achievementsCompletedChallenge(
      strings.achievementsChallengeLearnBasicSigns,
    );

    final perfectionistDescription = strings.achievementsCompletedChallenge(
      strings.achievementsChallengeGet100Accuracy,
    );

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
          final theme = Theme.of(context);
          final achievementsTheme =
              theme.extension<AchievementsTheme>() ??
              _fallbackAchievementsTheme(theme);

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  Navigator.pop(context); // This performs the "Back" action
                },
              ),
              title: Text(
                strings.achievementsTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: achievementsTheme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: achievementsTheme.showCardBorder
                                ? Border.all(
                                    color: achievementsTheme.cardBorderColor,
                                    width: achievementsTheme.cardBorderWidth,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height:
                                    120, // Increase this for a larger circle
                                width: 120, // Keep height and width the same
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 1. The Background Circle (the "track")
                                    SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: CircularProgressIndicator(
                                        value: 1.0, // Full circle
                                        strokeWidth: 12, // Thicker line
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              achievementsTheme
                                                  .progressTrackColor,
                                            ),
                                      ),
                                    ),
                                    // 2. The Actual Progress
                                    SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: CircularProgressIndicator(
                                        value: 0.75, // 75% progress
                                        strokeWidth: 12,
                                        strokeCap: StrokeCap
                                            .round, // ✅ This makes the end rounded
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              achievementsTheme
                                                  .progressValueColor,
                                            ),
                                      ),
                                    ),
                                    // 3. The Percentage Text
                                    Text(
                                      "75%",
                                      style: TextStyle(
                                        fontSize:
                                            20, // Larger font for a larger circle
                                        fontWeight: FontWeight.bold,
                                        color: achievementsTheme
                                            .headerAccentTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: Text(headerMessage)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          spacing: 10,
                          children: [
                            AchievementUnlocked(
                              title: strings.profileAchievementStudious,
                              description: studiousDescription,
                              imagePath:
                                  "assets/images/achievements/trophy_icon.png",
                            ),
                            AchievementUnlocked(
                              title: strings.profileAchievementQuickie,
                              description: quickieDescription,
                              imagePath:
                                  "assets/images/achievements/time_icon.png",
                            ),
                            AchievementUnlocked(
                              title: strings.profileAchievementAmbitious,
                              description: ambitiousDescription,
                              imagePath:
                                  "assets/images/achievements/medal_icon.png",
                            ),
                            AchievementUnlocked(
                              title: strings.profileAchievementPerfectionist,
                              description: perfectionistDescription,
                              imagePath:
                                  "assets/images/achievements/star_icon.png",
                            ),
                            AchievementLocked(
                              imagePath:
                                  "assets/images/achievements/sunglasses_icon.png",
                              label: lockedLabel,
                            ),
                            AchievementLocked(
                              imagePath:
                                  "assets/images/achievements/sunglasses_icon.png",
                              label: lockedLabel,
                            ),
                            AchievementLocked(
                              imagePath:
                                  "assets/images/achievements/sunglasses_icon.png",
                              label: lockedLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

BoxDecoration _achievementCardDecoration(
  BuildContext context, {
  required double borderRadius,
}) {
  final theme = Theme.of(context);
  final achievementsTheme =
      theme.extension<AchievementsTheme>() ?? _fallbackAchievementsTheme(theme);

  return BoxDecoration(
    color: achievementsTheme.cardBackgroundColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: achievementsTheme.showCardBorder
        ? Border.all(
            color: achievementsTheme.cardBorderColor,
            width: achievementsTheme.cardBorderWidth,
          )
        : null,
    boxShadow: achievementsTheme.useCardShadows
        ? [
            BoxShadow(
              blurRadius: 1,
              offset: const Offset(1, 1),
              color: Colors.black.withOpacity(0.1), // Very subtle color
            ),
          ]
        : null,
  );
}

class AchievementUnlocked extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  const AchievementUnlocked({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievementsTheme =
        theme.extension<AchievementsTheme>() ??
        _fallbackAchievementsTheme(theme);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _achievementCardDecoration(context, borderRadius: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievementsTheme.mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementLocked extends StatelessWidget {
  final String imagePath;
  final String label;
  const AchievementLocked({
    super.key,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievementsTheme =
        theme.extension<AchievementsTheme>() ??
        _fallbackAchievementsTheme(theme);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _achievementCardDecoration(context, borderRadius: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: achievementsTheme.lockedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
