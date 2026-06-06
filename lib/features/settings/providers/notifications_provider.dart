import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';
import 'theme_provider.dart';

class NotificationsProvider extends Notifier<bool> {
  SettingsService get _service => ref.read(settingsServiceProvider);

  @override
  bool build() {
    _load();

    return true;
  }

  Future<void> _load() async {
    state = await _service.loadNotificationsEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;

    await _service.saveNotificationsEnabled(enabled);
  }
}

final notificationsProvider = NotifierProvider<NotificationsProvider, bool>(
  NotificationsProvider.new,
);
