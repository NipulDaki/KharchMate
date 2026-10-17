import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service responsible for managing local notifications, including
/// daily morning (9:00 AM) and evening (7:00 PM) expense reminders.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? notificationsPlugin})
    : _notificationsPlugin =
          notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  static const String channelId = 'kharchmate_daily_reminders';
  static const String channelName = 'KharchMate Daily Reminders';
  static const String channelDescription =
      'Daily reminders to review and log your expenses in KharchMate.';

  // Notification IDs
  static const int morningNotificationId = 900;
  static const int eveningNotificationId = 1900;
  static const int testMorningNotificationId = 901;
  static const int testEveningNotificationId = 1901;

  // Default reminder times: 9:00 AM and 7:00 PM (19:00)
  static const int defaultMorningHour = 9;
  static const int defaultMorningMinute = 0;
  static const int defaultEveningHour = 19;
  static const int defaultEveningMinute = 0;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Callback when a notification is tapped
  void Function(NotificationResponse response)? onNotificationTapped;

  /// Initializes timezone data, notifications plugin, requests permissions,
  /// cancels any prior test reminders, and sets the original daily reminders (9:00 AM & 7:00 PM).
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _configureLocalTimeZone();
      await _initializePlugin();
      await requestPermissions();
      await scheduleDailyReminders();
      _isInitialized = true;
      debugPrint(
        'NotificationService: Initialized with original daily reminders (9:00 AM & 7:00 PM).',
      );
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Failed to initialize ($e)\n$stackTrace');
    }
  }

  /// Sets up local timezone using device's current timezone.
  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb) return;
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      debugPrint(
        'NotificationService: Configured timezone -> ${timezoneInfo.identifier}',
      );
    } catch (e) {
      debugPrint('NotificationService: Fallback to UTC timezone ($e)');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Configures platform-specific initialization settings.
  Future<void> _initializePlugin() async {
    const androidSettings = AndroidInitializationSettings(
      'ic_notification',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint(
          'NotificationService: Notification tapped -> payload: ${response.payload}',
        );
        onNotificationTapped?.call(response);
      },
    );
  }

  /// Requests notification permissions for iOS and Android 13+.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    bool granted = false;
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final notifGranted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
        granted = notifGranted;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        granted =
            await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      debugPrint('NotificationService: Permission request error ($e)');
    }
    return granted;
  }

  /// Notification presentation details for Android and iOS.
  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      color: Color(0xFFFF9800),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  /// Computes next instance of target hour & minute in local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    return scheduledDate;
  }

  /// Schedules daily 9:00 AM and 7:00 PM expense reminders.
  Future<void> scheduleDailyReminders({
    int morningHour = defaultMorningHour,
    int morningMinute = defaultMorningMinute,
    int eveningHour = defaultEveningHour,
    int eveningMinute = defaultEveningMinute,
  }) async {
    await scheduleMorningReminder(hour: morningHour, minute: morningMinute);
    await scheduleEveningReminder(hour: eveningHour, minute: eveningMinute);
  }

  /// Schedules daily morning reminder (default: 9:00 AM).
  Future<void> scheduleMorningReminder({
    int hour = defaultMorningHour,
    int minute = defaultMorningMinute,
    String title = 'Morning Expense Check ☀️',
    String body = 'Plan your day and remember to record your morning expenses in KharchMate.',
  }) async {
    await _scheduleDailyNotification(
      id: morningNotificationId,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      payload: 'morning_expense_reminder',
    );
  }

  /// Schedules daily evening reminder (default: 7:00 PM / 19:00).
  Future<void> scheduleEveningReminder({
    int hour = defaultEveningHour,
    int minute = defaultEveningMinute,
    String title = 'Daily Expense Reminder 🌙',
    String body = 'Time to review today\'s spending! Keep your budget on track by logging your expenses in KharchMate.',
  }) async {
    await _scheduleDailyNotification(
      id: eveningNotificationId,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      payload: 'evening_expense_reminder',
    );
  }

  /// Schedules test notifications for testing/verification:
  /// one representing the 9:00 AM morning reminder (firing in [delayMinutes1] minutes)
  /// and one representing the 7:00 PM evening reminder (firing in [delayMinutes2] minutes).
  Future<void> scheduleTestReminders({
    int delayMinutes1 = 2,
    int delayMinutes2 = 3,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final time1 = now.add(Duration(minutes: delayMinutes1));
    final time2 = now.add(Duration(minutes: delayMinutes2));
    final details = _notificationDetails();

    try {
      await _notificationsPlugin.zonedSchedule(
        id: testMorningNotificationId,
        title: 'Morning Expense Check ☀️',
        body: 'Plan your day and remember to record your morning expenses in KharchMate.',
        scheduledDate: time1,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'test_morning_expense_reminder',
      );
      debugPrint(
        'NotificationService: Scheduled test morning reminder at ${time1.toIso8601String()} (+${delayMinutes1}m)',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Could not schedule test morning reminder: $e',
      );
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id: testEveningNotificationId,
        title: 'Daily Expense Reminder 🌙',
        body: 'Time to review today\'s spending! Keep your budget on track by logging your expenses in KharchMate.',
        scheduledDate: time2,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'test_evening_expense_reminder',
      );
      debugPrint(
        'NotificationService: Scheduled test evening reminder at ${time2.toIso8601String()} (+${delayMinutes2}m)',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Could not schedule test evening reminder: $e',
      );
    }
  }

  /// Helper to schedule a recurring daily notification at a specific time.
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final details = _notificationDetails();

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint(
        'NotificationService: Scheduled daily reminder id $id at ${scheduledDate.toIso8601String()}',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Could not schedule notification id $id: $e',
      );
    }
  }

  /// Triggers an immediate notification for testing or explicit alerts.
  Future<void> showInstantNotification({
    int id = 1,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
      payload: payload,
    );
  }

  /// Cancels a specific reminder by ID.
  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// Cancels both morning and evening reminders.
  Future<void> cancelDailyReminders() async {
    await cancelReminder(morningNotificationId);
    await cancelReminder(eveningNotificationId);
  }

  /// Cancels test reminders (IDs 901 and 1901) if any were scheduled.
  Future<void> cancelTestReminders() async {
    await cancelReminder(testMorningNotificationId);
    await cancelReminder(testEveningNotificationId);
  }

  /// Cancels all notifications.
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Fetches pending notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
