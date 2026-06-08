import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _channelId = 'transaction_reminder';
  static const _channelName = 'Transaction Reminder';
  static const _reminderId = 0;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    final timeZoneName = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _plugin.initialize(settings: const .new(android: androidSettings));
  }

  Future<bool> isPermissionGranted() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Transaction Reminder',
      body: 'Did you log your transactions today? 💸',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const .new(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: .high,
          priority: .high,
        ),
      ),
      androidScheduleMode: .inexactAllowWhileIdle,
      matchDateTimeComponents: .time,
    );
  }

  Future<void> cancelReminder() async => await _plugin.cancel(id: _reminderId);

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const .new(days: 1));
    }

    return scheduled;
  }
}
