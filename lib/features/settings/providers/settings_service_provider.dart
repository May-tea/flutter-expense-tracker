import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) => .new());

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => .new(),
);
