import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';

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
}
