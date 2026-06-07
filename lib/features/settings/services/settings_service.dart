import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _reminderTimeKey = 'reminder_time';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_themeModeKey);

    return switch (value) {
      'light' => .light,
      'dark' => .dark,
      _ => .system,
    };
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_reminderTimeKey, time.hour * 60 + time.minute);
  }

  Future<TimeOfDay?> loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(_reminderTimeKey);

    if (minutes == null) return null;

    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
