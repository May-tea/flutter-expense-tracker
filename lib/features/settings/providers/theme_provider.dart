import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  SettingsService get _service => ref.read(settingsServiceProvider);

  @override
  ThemeMode build() {
    _loadThemeMode();

    return .system;
  }

  Future<void> _loadThemeMode() async {
    state = await _service.loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    await _service.saveThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);
