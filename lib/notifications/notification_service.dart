import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily practice reminder notifications.
///
/// Requirements / dependencies:
/// - flutter_local_notifications
/// - timezone
/// - flutter_timezone (for reliable local IANA timezone name)
/// - permission_handler (to request notification permission)
///
/// Android notes:
/// - For Android 13+ (API 33+), notification permission is requested when
///   scheduling.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyPracticeReminderId = 10001;

  static const String _androidChannelId = 'daily_practice_reminders';
  static const String _androidChannelName = 'Daily Practice Reminders';
  static const String _androidChannelDescription =
      'Daily reminders to practice in SignMirror.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  final StreamController<DailyPracticeReminderEvent>
  _foregroundReminderController =
      StreamController<DailyPracticeReminderEvent>.broadcast();
  Timer? _foregroundReminderTimer;
  int? _foregroundReminderHour;
  int? _foregroundReminderMinute;
  String? _foregroundReminderTitle;
  String? _foregroundReminderBody;

  /// Fires while the app is in the foreground at the scheduled reminder time.
  ///
  /// This is independent from OS-level notifications.
  Stream<DailyPracticeReminderEvent> get foregroundReminderStream =>
      _foregroundReminderController.stream;

  /// Initializes the notifications plugin and timezone database.
  ///
  /// Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    // Timezone init must happen before scheduling with zonedSchedule.
    await _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings: initSettings);

    // Create / ensure the Android channel exists.
    await _createAndroidChannelIfNeeded();

    _initialized = true;
  }

  /// Best-effort check for whether notifications are enabled for this app on
  /// Android.
  ///
  /// Returns:
  /// - `true` if notifications are enabled.
  /// - `false` if notifications are disabled.
  /// - `null` if not Android or the status can't be determined.
  Future<bool?> areAndroidNotificationsEnabledBestEffort() async {
    if (!_isAndroid) return null;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return null;

    final dynamic androidDynamic = android;

    try {
      final dynamic result = await androidDynamic.areNotificationsEnabled();
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }

    try {
      final dynamic result = await androidDynamic
          .areNotificationsEnabledForApp();
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }

    return null;
  }

  /// Best-effort attempt to open Android notification settings for this app.
  ///
  /// Falls back to opening the app settings screen if a more specific intent is
  /// unavailable.
  Future<void> openAndroidNotificationSettingsBestEffort() async {
    if (!_isAndroid) return;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final dynamic androidDynamic = android;

      try {
        await androidDynamic.openNotificationSettings();
        return;
      } catch (_) {
        // ignore
      }

      try {
        await androidDynamic.openAppNotificationSettings();
        return;
      } catch (_) {
        // ignore
      }
    }

    try {
      await openAppSettings();
    } catch (_) {
      // ignore
    }
  }

  /// Best-effort attempt to open Android notification channel settings for the
  /// daily practice reminders channel.
  ///
  /// Falls back to app notification settings and then app settings.
  Future<void> openAndroidChannelSettingsBestEffort() async {
    if (!_isAndroid) return;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final dynamic androidDynamic = android;

      try {
        await androidDynamic.openNotificationChannelSettings(_androidChannelId);
        return;
      } catch (_) {
        // ignore
      }

      try {
        await Function.apply(
          androidDynamic.openNotificationChannelSettings,
          const <dynamic>[],
          <Symbol, dynamic>{#channelId: _androidChannelId},
        );
        return;
      } catch (_) {
        // ignore
      }

      try {
        await Function.apply(
          androidDynamic.openAndroidNotificationChannelSettings,
          const <dynamic>[],
          <Symbol, dynamic>{#channelId: _androidChannelId},
        );
        return;
      } catch (_) {
        // ignore
      }
    }

    await openAndroidNotificationSettingsBestEffort();
  }

  /// Best-effort debug dump of the daily practice reminder notification state.
  ///
  /// Prints:
  /// - Notification permission status
  /// - Android notifications enabled status (if available)
  /// - Exact alarm capability (if available)
  /// - Whether pendingNotificationRequests contains the daily reminder id
  Future<void> debugDumpDailyPracticeNotificationState() async {
    await init();

    PermissionStatus? permissionStatus;
    if (!kIsWeb) {
      try {
        permissionStatus = await Permission.notification.status;
      } catch (_) {
        // ignore
      }
    }

    final enabled = await areAndroidNotificationsEnabledBestEffort();
    final canExact = await _canScheduleExactAlarmsBestEffort();

    bool? pendingContains;
    int? pendingCount;
    if (!kIsWeb) {
      try {
        final pending = await _plugin.pendingNotificationRequests();
        pendingCount = pending.length;
        pendingContains = pending.any((p) => p.id == _dailyPracticeReminderId);
      } catch (_) {
        // ignore
      }
    }

    debugPrint(
      'NotificationService: debugDumpDailyPracticeNotificationState '
      'permission=$permissionStatus '
      'areNotificationsEnabled=$enabled '
      'canScheduleExactAlarms=$canExact '
      'pendingContainsId=$pendingContains '
      '(pendingCount=$pendingCount)',
    );
  }

  /// Schedules a daily practice reminder at a 24-hour time string "HH:mm".
  ///
  /// Example: "07:30".
  Future<void> scheduleDailyPracticeReminderAt(
    String hhmm, {
    String title = 'Daily practice time',
    String body = 'Take 2 minutes to practice and keep your streak going.',
  }) async {
    final (hour, minute) = _parse24hTime(hhmm);
    await scheduleDailyPracticeReminder(
      hour: hour,
      minute: minute,
      title: title,
      body: body,
    );
  }

  /// Schedules a timezone-aware daily practice reminder at [hour]:[minute].
  ///
  /// This requests notification permission on iOS and Android 13+.
  /// If a reminder already exists, it is replaced.
  Future<void> scheduleDailyPracticeReminder({
    required int hour,
    required int minute,
    String title = 'Daily practice time',
    String body = 'Take 2 minutes to practice and keep your streak going.',
  }) async {
    _validateHourMinute(hour: hour, minute: minute);

    await init();
    await _requestPermissionsIfNeeded();

    if (_isAndroid) {
      // Ensure the channel exists and check for Android-level blocks before
      // attempting to schedule.
      await _createAndroidChannelIfNeeded();

      final areEnabled = await areAndroidNotificationsEnabledBestEffort();
      if (areEnabled == false) {
        throw StateError(
          'Notifications are disabled for this app on Android. '
          'Enable notifications in system settings to schedule reminders.',
        );
      }

      final channelBlocked = await _isAndroidChannelBlockedBestEffort();
      if (channelBlocked == true) {
        throw StateError(
          'The "Daily Practice Reminders" notification channel is blocked on Android. '
          'Enable this channel in system notification settings to schedule reminders.',
        );
      }
    }

    final scheduled = _nextInstanceOfTime(hour: hour, minute: minute);

    final scheduleMode = await _chooseAndroidScheduleMode(scheduled);
    debugPrint(
      'NotificationService: scheduling daily reminder for '
      '${scheduled.toIso8601String()} (local tz=${tz.local.name}) '
      'mode=$scheduleMode',
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    _cancelForegroundReminderTimer();

    try {
      await _plugin.zonedSchedule(
        id: _dailyPracticeReminderId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        debugPrint(
          'NotificationService: exactAllowWhileIdle failed ($e). '
          'Falling back to inexactAllowWhileIdle.',
        );
        await _plugin.zonedSchedule(
          id: _dailyPracticeReminderId,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        rethrow;
      }
    }

    await _debugLogPendingNotificationRegistration(
      id: _dailyPracticeReminderId,
    );

    _foregroundReminderHour = hour;
    _foregroundReminderMinute = minute;
    _foregroundReminderTitle = title;
    _foregroundReminderBody = body;
    _scheduleForegroundReminderTimer(scheduledFor: scheduled);
  }

  /// Best-effort check for whether the daily practice reminder channel is
  /// blocked (importance set to none).
  ///
  /// Returns:
  /// - `true` if the channel is blocked.
  /// - `false` if the channel exists and is not blocked.
  /// - `null` if the status can't be determined.
  Future<bool?> _isAndroidChannelBlockedBestEffort() async {
    if (!_isAndroid) return null;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return null;

    final dynamic androidDynamic = android;

    // Try fetching all channels.
    try {
      final dynamic channels = await androidDynamic.getNotificationChannels();
      if (channels is List) {
        for (final channel in channels) {
          final dynamic c = channel;
          final dynamic id = c.id;
          if (id != _androidChannelId) continue;

          final dynamic importance = c.importance;
          if (importance == Importance.none) return true;
          if (importance is int && importance == 0) return true;
          return false;
        }

        // If we can query channels but ours isn't present, treat as unknown.
        return null;
      }
    } catch (_) {
      // ignore
    }

    // Try fetching a single channel if the API exists.
    try {
      final dynamic channel = await androidDynamic.getNotificationChannel(
        _androidChannelId,
      );
      if (channel != null) {
        final dynamic importance = channel.importance;
        if (importance == Importance.none) return true;
        if (importance is int && importance == 0) return true;
        return false;
      }
    } catch (_) {
      // ignore
    }

    return null;
  }

  /// Cancels the daily practice reminder (if scheduled).
  Future<void> cancelDailyPracticeReminder() async {
    _cancelForegroundReminderTimer();
    await init();
    await _plugin.cancel(id: _dailyPracticeReminderId);
  }

  /// Cancels and schedules again with the provided time.
  Future<void> rescheduleDailyPracticeReminder({
    required int hour,
    required int minute,
    String title = 'Daily practice time',
    String body = 'Take 2 minutes to practice and keep your streak going.',
  }) async {
    await cancelDailyPracticeReminder();
    await scheduleDailyPracticeReminder(
      hour: hour,
      minute: minute,
      title: title,
      body: body,
    );
  }

  /// Cancels and schedules again with a provided 24-hour time string "HH:mm".
  Future<void> rescheduleDailyPracticeReminderAt(
    String hhmm, {
    String title = 'Daily practice time',
    String body = 'Take 2 minutes to practice and keep your streak going.',
  }) async {
    await cancelDailyPracticeReminder();
    await scheduleDailyPracticeReminderAt(hhmm, title: title, body: body);
  }

  Future<void> _createAndroidChannelIfNeeded() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  Future<void> _requestPermissionsIfNeeded() async {
    if (kIsWeb) return;

    // Requests notification permission on iOS and Android 13+.
    // On older Android versions this is a no-op (already granted at install).
    final status = await Permission.notification.status;
    if (status.isGranted) return;

    final requested = await Permission.notification.request();
    if (!requested.isGranted) {
      throw StateError(
        'Notification permission is required to schedule reminders. '
        'Current status: $requested',
      );
    }
  }

  /// Requests the Android exact alarm permission if the host platform and
  /// flutter_local_notifications version support it.
  ///
  /// This is best-effort: if the API is unavailable or the request fails, we
  /// still proceed and rely on the scheduling call + fallback behavior.
  Future<void> _requestExactAlarmsPermissionIfAvailable() async {
    if (kIsWeb) return;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    try {
      // Use a dynamic invocation so compilation doesn't depend on the exact
      // plugin API surface.
      final dynamic androidDynamic = android;
      final dynamic result = await androidDynamic
          .requestExactAlarmsPermission();
      debugPrint(
        'NotificationService: requested exact alarms permission (result=$result)',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: exact alarms permission request not available/failed ($e)',
      );
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();

    if (kIsWeb) {
      // `flutter_timezone` is not available on web.
      return;
    }

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // If we fail to get an IANA timezone name, tz.local may not match the
      // device timezone. We still allow scheduling as a fallback.
      debugPrint('NotificationService: failed to set local timezone: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<AndroidScheduleMode> _chooseAndroidScheduleMode(
    tz.TZDateTime scheduledFor,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final leadTime = scheduledFor.difference(now);

    // Prefer exact alarms for best real-world delivery reliability.
    //
    // Behavior:
    // - If exact alarms are allowed => use exactAllowWhileIdle.
    // - If capability is unknown => try exactAllowWhileIdle and rely on the
    //   scheduling try/catch fallback.
    // - If exact alarms are known disallowed => request permission (best-effort)
    //   and re-check; if still disallowed => use inexactAllowWhileIdle.
    final canScheduleExact = await _canScheduleExactAlarmsBestEffort();

    if (canScheduleExact == true) {
      debugPrint(
        'NotificationService: exact alarms allowed; using exactAllowWhileIdle '
        '(leadTime=${leadTime.inMinutes}m).',
      );
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    if (canScheduleExact == null) {
      debugPrint(
        'NotificationService: exact alarm capability unknown; using exactAllowWhileIdle '
        '(leadTime=${leadTime.inMinutes}m) and relying on scheduling fallback if needed.',
      );
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    debugPrint(
      'NotificationService: exact alarms not allowed; requesting permission and re-checking '
      '(leadTime=${leadTime.inMinutes}m).',
    );
    await _requestExactAlarmsPermissionIfAvailable();

    final canScheduleExactAfterRequest =
        await _canScheduleExactAlarmsBestEffort();

    if (canScheduleExactAfterRequest == true) {
      debugPrint(
        'NotificationService: exact alarms allowed after permission request; '
        'using exactAllowWhileIdle.',
      );
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    if (canScheduleExactAfterRequest == null) {
      debugPrint(
        'NotificationService: exact alarm capability unknown after permission request; '
        'using exactAllowWhileIdle and relying on scheduling fallback if needed.',
      );
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    debugPrint(
      'NotificationService: exact alarms still not allowed; using inexactAllowWhileIdle.',
    );
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Best-effort check for whether this device/app can schedule exact alarms.
  ///
  /// Returns:
  /// - `true` if the platform plugin reports exact alarms are allowed.
  /// - `false` if the platform plugin reports they are not allowed.
  /// - `null` if the API isn't available or can't be determined.
  Future<bool?> _canScheduleExactAlarmsBestEffort() async {
    if (kIsWeb) return null;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return null;

    final dynamic androidDynamic = android;

    // Try newer/alternate API names without taking a compile-time dependency.
    try {
      final dynamic result = await androidDynamic
          .canScheduleExactNotifications();
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }

    try {
      final dynamic result = await androidDynamic.canScheduleExactAlarms();
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }

    return null;
  }

  Future<void> _debugLogPendingNotificationRegistration({
    required int id,
  }) async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      final exists = pending.any((p) => p.id == id);
      debugPrint(
        'NotificationService: pendingNotificationRequests contains id=$id: $exists '
        '(pendingCount=${pending.length})',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: failed to read pendingNotificationRequests ($e)',
      );
    }
  }

  void _scheduleForegroundReminderTimer({required tz.TZDateTime scheduledFor}) {
    _cancelForegroundReminderTimer();

    // If no schedule has been stored, we can't make this recurring.
    final hour = _foregroundReminderHour;
    final minute = _foregroundReminderMinute;
    final title = _foregroundReminderTitle;
    final body = _foregroundReminderBody;
    if (hour == null || minute == null) return;
    if (title == null || body == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var delay = scheduledFor.difference(now);
    if (delay.isNegative) {
      delay = Duration.zero;
    }

    debugPrint(
      'NotificationService: foreground timer set for '
      '${scheduledFor.toIso8601String()} (in ${delay.inSeconds}s)',
    );

    _foregroundReminderTimer = Timer(delay, () {
      final firedAt = tz.TZDateTime.now(tz.local);
      _foregroundReminderController.add(
        DailyPracticeReminderEvent(
          title: title,
          body: body,
          scheduledFor: scheduledFor,
          firedAt: firedAt,
        ),
      );

      // Keep the in-app alert behavior daily while the app stays open.
      final next = _nextInstanceOfTime(hour: hour, minute: minute);
      _scheduleForegroundReminderTimer(scheduledFor: next);
    });
  }

  void _cancelForegroundReminderTimer() {
    _foregroundReminderTimer?.cancel();
    _foregroundReminderTimer = null;
  }

  static (int hour, int minute) _parse24hTime(String hhmm) {
    final value = hhmm.trim();
    final parts = value.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format. Expected HH:mm, got "$hhmm"');
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      throw FormatException(
        'Invalid time numbers. Expected HH:mm, got "$hhmm"',
      );
    }

    _validateHourMinute(hour: hour, minute: minute);
    return (hour, minute);
  }

  static void _validateHourMinute({required int hour, required int minute}) {
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }
  }
}

class DailyPracticeReminderEvent {
  const DailyPracticeReminderEvent({
    required this.title,
    required this.body,
    required this.scheduledFor,
    required this.firedAt,
  });

  final String title;
  final String body;
  final tz.TZDateTime scheduledFor;
  final tz.TZDateTime firedAt;
}
