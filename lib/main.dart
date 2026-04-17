import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/features/location_suggestions/providers/location_suggestion_controller.dart';
import 'package:signmirror_flutter/notifications/notification_service.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/routes/routes.dart';
import 'package:signmirror_flutter/screens/personalization_screen.dart';
import 'package:signmirror_flutter/services/settings_service.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/theme/theme_settings.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

OverlayEntry? _foregroundBannerEntry;
Timer? _foregroundBannerDismissTimer;

StreamSubscription<DailyPracticeReminderEvent>? _foregroundReminderSubscription;

void _hideForegroundReminderBanner() {
  _foregroundBannerDismissTimer?.cancel();
  _foregroundBannerDismissTimer = null;

  _foregroundBannerEntry?.remove();
  _foregroundBannerEntry = null;
}

void _showForegroundReminderBanner(DailyPracticeReminderEvent event) {
  // Intentionally no in-app banner/overlay: show a system notification instead.
  _hideForegroundReminderBanner();

  unawaited(() async {
    try {
      await NotificationService.instance.showDailyPracticeReminderNow(
        title: event.title,
        body: event.body,
      );
    } catch (e, st) {
      debugPrint(
        'main: failed to show daily practice reminder notification: $e',
      );
      debugPrint('$st');
    }
  }());
}

void _startForegroundReminderListener() {
  // Hot reload resilience: if we already have a listener, restart it.
  final existingSubscription = _foregroundReminderSubscription;
  if (existingSubscription != null) {
    _foregroundReminderSubscription = null;
    try {
      unawaited(
        existingSubscription.cancel().catchError((e, st) {
          debugPrint('main: failed to cancel foreground reminder listener: $e');
          debugPrint('$st');
        }),
      );
    } catch (e, st) {
      debugPrint('main: failed to cancel foreground reminder listener: $e');
      debugPrint('$st');
    }
  }

  final Stream<DailyPracticeReminderEvent> stream =
      NotificationService.instance.foregroundReminderStream;

  _foregroundReminderSubscription = stream.listen(
    (event) {
      _showForegroundReminderBanner(event);
    },
    onError: (e, st) {
      debugPrint('main: foreground reminder stream error: $e');
      debugPrint('$st');
    },
  );
}

class _TopReminderBanner extends StatelessWidget {
  const _TopReminderBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, offset, child) {
              return FractionalTranslation(translation: offset, child: child);
            },
            child: Material(
              color: colorScheme.inverseSurface,
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                        color: colorScheme.onInverseSurface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DefaultTextStyle(
                        style: (textTheme.bodyMedium ?? const TextStyle())
                            .copyWith(color: colorScheme.onInverseSurface),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Practice Reminder',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (textTheme.labelSmall ?? const TextStyle())
                                  .copyWith(
                                    color: colorScheme.onInverseSurface,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (textTheme.titleSmall ?? const TextStyle())
                                  .copyWith(
                                    color: colorScheme.onInverseSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      onPressed: _hideForegroundReminderBanner,
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: colorScheme.onInverseSurface,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _scheduleDailyPracticeReminderFromSettings(
  SettingsService settingsService,
) async {
  final practiceTime = settingsService.practiceTime;

  try {
    // Ensure any previously scheduled reminder is aligned to the persisted time.
    await NotificationService.instance.rescheduleDailyPracticeReminderAt(
      practiceTime,
    );
  } catch (e, st) {
    // Scheduling can fail (e.g., permission denied). Don't crash startup.
    debugPrint(
      'main: failed to schedule daily practice reminder at $practiceTime: $e',
    );
    debugPrint('$st');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ui.DartPluginRegistrant.ensureInitialized();

  // Initialize notifications and settings before runApp.
  await NotificationService.instance.init();

  // Listen early so foreground reminders can surface immediately.
  _startForegroundReminderListener();

  // 1. Initialize the service manually once
  final settingsService = SettingsService();
  await settingsService.init();

  // Schedule the daily practice reminder using the currently saved practice time.
  unawaited(_scheduleDailyPracticeReminderFromSettings(settingsService));

  runApp(
    ProviderScope(
      overrides: [
        // 2. "Inject" the already initialized service into the provider
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(locationSuggestionControllerProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    final themeMode = switch (themeSettings.mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp(
      title: 'SignMirror',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      initialRoute: RouteNames.login,
      routes: AppRoutes.getRoutes(),
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const PersonalizationScreen(),
      ),

      // Base themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      highContrastTheme: AppTheme.highContrastLightTheme,
      highContrastDarkTheme: AppTheme.highContrastDarkTheme,

      // App-controlled light/dark mode (no system mode)
      themeMode: themeMode,

      // Make the in-app high-contrast toggle effective even when the OS
      // high-contrast setting is off.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final effectiveHighContrast =
            mediaQuery.highContrast || themeSettings.highContrast;

        return MediaQuery(
          data: mediaQuery.copyWith(highContrast: effectiveHighContrast),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
