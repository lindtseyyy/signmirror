import 'dart:async' show unawaited;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    final themeSettings = ref.watch(themeSettingsProvider);
    final isDarkMode = themeSettings.mode == AppThemeMode.dark;
    final isOfflineDownloading = ref.watch(offlineDownloadProvider);
    final isHighContrastSetting = themeSettings.highContrast;

    final platformHighContrast = MediaQuery.of(context).highContrast;
    final effectiveHighContrast = isHighContrastSetting || platformHighContrast;

    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: effectiveHighContrast,
    );

    // Watch for changes so the UI updates when the saved time changes.
    ref.watch(practiceTimeProvider);

    // Get the pretty version from your Notifier.
    final displayTime = ref
        .read(practiceTimeProvider.notifier)
        .getDisplayTime();
    final language = ref.watch(languageProvider);
    final userName = ref.watch(userNameProvider);
    final personalization = ref.watch(personalizationProvider);

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final isHighContrastMode = effectiveHighContrast;
          final isDark = theme.brightness == Brightness.dark;
          final useLegacyLightColors = !isDark && !isHighContrastMode;

          final cardBackground = useLegacyLightColors
              ? const Color(0xffffffff)
              : colorScheme.surface;
          final cardBorder = useLegacyLightColors
              ? null
              : Border.all(
                  color: isHighContrastMode
                      ? colorScheme.onSurface.withOpacity(0.9)
                      : colorScheme.outline,
                  width: isHighContrastMode ? 1.2 : 0.8,
                );

          final dividerColor = useLegacyLightColors
              ? Colors.grey
              : (isHighContrastMode
                    ? colorScheme.onSurface.withOpacity(0.9)
                    : colorScheme.outline);

          final mutedIconColor = useLegacyLightColors
              ? Colors.black.withOpacity(0.6)
              : (isHighContrastMode
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant);

          final trailingIconColor = useLegacyLightColors
              ? Colors.grey
              : (isHighContrastMode
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant);

          final inactiveSwitchOutlineColor = useLegacyLightColors
              ? Colors.black
              : (isHighContrastMode
                    ? colorScheme.onSurface
                    : colorScheme.outline);

          final avatarBorderColor = useLegacyLightColors
              ? Colors.black
              : colorScheme.onSurface.withOpacity(
                  isHighContrastMode ? 1.0 : 0.7,
                );

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.editProfile);
                    },
                  ),
                ],
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.profileTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBackground,
                                borderRadius: BorderRadius.circular(15),
                                border: cardBorder,
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 51,
                                    backgroundColor: avatarBorderColor,
                                    child: const CircleAvatar(
                                      radius: 50,
                                      backgroundImage: AssetImage(
                                        'assets/images/profile_picture.jpeg',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    userName.trim().isNotEmpty
                                        ? userName
                                        : strings.profileDefaultUserLabel,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    personalization.trim().isNotEmpty
                                        ? personalization
                                        : strings.profileNotSetLabel,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(
                                    color: dividerColor,
                                    thickness: isHighContrastMode ? 1.2 : 1,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Text(
                                        strings.profileAchievementsHeader,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap, //
                                        ),
                                        icon: Icon(
                                          Icons.double_arrow,
                                          color: mutedIconColor,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            RouteNames.achievements,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Achievement(
                                        imagePath:
                                            "assets/images/achievements/trophy_icon.png",
                                        title:
                                            strings.profileAchievementStudious,
                                        useLegacyLightColors:
                                            useLegacyLightColors,
                                        isHighContrast: isHighContrastMode,
                                      ),
                                      Achievement(
                                        imagePath:
                                            "assets/images/achievements/time_icon.png",
                                        title:
                                            strings.profileAchievementQuickie,
                                        useLegacyLightColors:
                                            useLegacyLightColors,
                                        isHighContrast: isHighContrastMode,
                                      ),
                                      Achievement(
                                        imagePath:
                                            "assets/images/achievements/star_icon.png",
                                        title:
                                            strings.profileAchievementAmbitious,
                                        useLegacyLightColors:
                                            useLegacyLightColors,
                                        isHighContrast: isHighContrastMode,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsetsGeometry.all(20),
                              decoration: BoxDecoration(
                                color: cardBackground,
                                borderRadius: BorderRadius.circular(15),
                                border: cardBorder,
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets
                                        .zero, // 1. Removes the outer 16px gap
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ), // 2. Squeezes the internal space
                                    title: Text(strings.profileDarkModeLabel),
                                    secondary: Icon(
                                      isDarkMode
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                    ),
                                    value: isDarkMode,

                                    // 1. Change the shape/size of the track
                                    trackOutlineColor:
                                        MaterialStateProperty.all(
                                          isDarkMode
                                              ? Colors.transparent
                                              : inactiveSwitchOutlineColor,
                                        ),

                                    // 2. Put an icon INSIDE the moving circle
                                    thumbIcon:
                                        MaterialStateProperty.resolveWith<
                                          Icon?
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return const Icon(
                                              Icons.check,
                                              color: Color(0xff2D68FF),
                                            );
                                          }
                                          return const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          );
                                        }),

                                    onChanged: (value) {
                                      unawaited(
                                        ref
                                            .read(
                                              themeSettingsProvider.notifier,
                                            )
                                            .setMode(
                                              value
                                                  ? AppThemeMode.dark
                                                  : AppThemeMode.light,
                                            ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets
                                        .zero, // 1. Removes the outer 16px gap
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ), // 2. Squeezes the internal space
                                    title: Text(
                                      strings.profileOfflineDownloadingLabel,
                                    ),
                                    secondary: Icon(
                                      isOfflineDownloading
                                          ? Icons.download_for_offline
                                          : Icons.download_for_offline_outlined,
                                    ),
                                    value: isOfflineDownloading,

                                    // 1. Change the shape/size of the track
                                    trackOutlineColor:
                                        MaterialStateProperty.all(
                                          isOfflineDownloading
                                              ? Colors.transparent
                                              : inactiveSwitchOutlineColor,
                                        ),

                                    // 2. Put an icon INSIDE the moving circle
                                    thumbIcon:
                                        MaterialStateProperty.resolveWith<
                                          Icon?
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return const Icon(
                                              Icons.download,
                                              color: Color(0xff2D68FF),
                                            );
                                          }
                                          return const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          );
                                        }),

                                    onChanged: (value) => ref
                                        .read(offlineDownloadProvider.notifier)
                                        .toggle(),
                                  ),
                                  const SizedBox(height: 10),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets
                                        .zero, // 1. Removes the outer 16px gap
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ), // 2. Squeezes the internal space
                                    title: Text(
                                      strings.profileHighContrastLabel,
                                    ),
                                    secondary: Icon(
                                      isHighContrastSetting
                                          ? Icons.contrast
                                          : Icons.contrast_outlined,
                                    ),
                                    value: isHighContrastSetting,

                                    // 1. Change the shape/size of the track
                                    trackOutlineColor:
                                        MaterialStateProperty.all(
                                          isHighContrastSetting
                                              ? Colors.transparent
                                              : inactiveSwitchOutlineColor,
                                        ),

                                    // 2. Put an icon INSIDE the moving circle
                                    thumbIcon:
                                        MaterialStateProperty.resolveWith<
                                          Icon?
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return const Icon(
                                              Icons.contrast,
                                              color: Color(0xff2D68FF),
                                            );
                                          }
                                          return const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          );
                                        }),

                                    onChanged: (value) {
                                      unawaited(
                                        ref
                                            .read(
                                              themeSettingsProvider.notifier,
                                            )
                                            .setHighContrast(value),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    horizontalTitleGap:
                                        8, // Removes the gap between icon and text
                                    visualDensity: const VisualDensity(
                                      vertical: -4,
                                    ),
                                    minLeadingWidth: 0,
                                    leading: const Icon(Icons.language),
                                    title: Text(strings.profileLanguageLabel),
                                    subtitle: Text(
                                      language == 'en'
                                          ? strings.languageEnglishLabel
                                          : strings.languageFilipinoLabel,
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: trailingIconColor,
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => SimpleDialog(
                                          title: Text(
                                            strings.profileSelectLanguageTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          children: [
                                            SimpleDialogOption(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      languageProvider.notifier,
                                                    )
                                                    .setLanguage('en');
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                strings.languageEnglishLabel,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      languageProvider.notifier,
                                                    )
                                                    .setLanguage('fil');
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                strings.languageFilipinoLabel,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity: const VisualDensity(
                                      vertical: -4,
                                    ),

                                    horizontalTitleGap:
                                        8, // Removes the gap between icon and text
                                    minLeadingWidth: 0,
                                    leading: const Icon(Icons.alarm),
                                    title: Text(
                                      strings.profileDailyPracticeReminderLabel,
                                    ),
                                    subtitle: Text(
                                      displayTime,
                                    ), // e.g., "08:30 PM"
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: trailingIconColor,
                                      size: 15,
                                    ),
                                    onTap: () =>
                                        _showTimePicker(context, ref, strings),
                                  ),
                                  const SizedBox(height: 10),
                                  FilledButton(
                                    onPressed: () async {
                                      await ref
                                          .read(settingsServiceProvider)
                                          .clearAuthenticatedUserSession();

                                      // Clear/refresh in-memory state so stale values don't linger.
                                      ref.invalidate(userNameProvider);
                                      ref.invalidate(userEmailProvider);
                                      ref.invalidate(personalizationProvider);

                                      if (!mounted) return;
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RouteNames.signin,
                                        (route) => false,
                                      );
                                    },

                                    style: FilledButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadiusGeometry.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      backgroundColor: const Color(0xffFF4646),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: Text(
                                      strings.profileLogoutLabel,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

class Achievement extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool useLegacyLightColors;
  final bool isHighContrast;

  const Achievement({
    super.key,
    required this.imagePath,
    required this.title,
    this.useLegacyLightColors = true,
    this.isHighContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = useLegacyLightColors
        ? const Color(0xffE2E8F0)
        : colorScheme.surfaceVariant;

    final border = useLegacyLightColors
        ? null
        : Border.all(
            color: isHighContrast
                ? colorScheme.onSurface.withOpacity(0.9)
                : colorScheme.outline,
            width: isHighContrast ? 1.2 : 0.8,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

void _showTimePicker(BuildContext context, WidgetRef ref, AppStrings strings) {
  // Get current saved time and convert to DateTime for the wheel.
  final savedTime = ref.read(practiceTimeProvider); // e.g. "20:00"
  final parts = savedTime.split(':');
  final now = DateTime.now();
  DateTime tempDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildPickerHeader(
              strings: strings,
              onDone: () {
                final pickedTime = TimeOfDay.fromDateTime(tempDateTime);
                ref.read(practiceTimeProvider.notifier).setTime(pickedTime);
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: tempDateTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  tempDateTime = newDateTime;
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPickerHeader({
  required AppStrings strings,
  required VoidCallback onDone,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.profileSelectTimeTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onDone,
          child: Text(
            strings.commonDoneLabel,
            style: const TextStyle(
              color: Color(0xff2D68FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
