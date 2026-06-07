import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../services/settings_service.dart';
import 'settings_service_provider.dart';

class NotificationsState {
  const NotificationsState({required this.enabled, required this.reminderTime});

  final bool enabled;
  final TimeOfDay? reminderTime;

  NotificationsState copyWith({bool? enabled, TimeOfDay? reminderTime}) {
    return NotificationsState(
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  SettingsService get _settings => ref.read(settingsServiceProvider);

  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  NotificationsState build() {
    _load();

    return const .new(enabled: false, reminderTime: null);
  }

  Future<void> _load() async {
    final enabled = await _settings.loadNotificationsEnabled();
    final reminderTime = await _settings.loadReminderTime();

    state = .new(
      enabled: enabled,
      reminderTime: reminderTime ?? const .new(hour: 21, minute: 0),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _notifications.requestPermission();
      if (!granted) return;
    }

    state = state.copyWith(enabled: enabled);

    await _settings.saveNotificationsEnabled(enabled);

    if (enabled && state.reminderTime != null) {
      await _notifications.scheduleDailyReminder(state.reminderTime!);
    } else {
      await _notifications.cancelReminder();
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    state = state.copyWith(reminderTime: time);

    await _settings.saveReminderTime(time);

    if (state.enabled) {
      await _notifications.scheduleDailyReminder(time);
    }
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
      NotificationsNotifier.new,
    );
