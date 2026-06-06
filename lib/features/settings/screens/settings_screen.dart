import 'package:app/features/settings/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/theme_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/theme_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    final notificationsEnabled = ref.watch(notificationsProvider);
    final notificationsNotifier = ref.read(notificationsProvider.notifier);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeModeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(
              context,
              screenWidth,
              themeMode,
              themeModeNotifier,
            ),
          ),

          const SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Enable Notifications'),
            value: notificationsEnabled,
            onChanged: notificationsNotifier.setEnabled,
          ),

          const SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text('Logout', style: .new(color: colorScheme.error)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  .system => 'System',
  .light => 'Light',
  .dark => 'Dark',
};

void _showThemePicker(
  BuildContext context,
  double width,
  ThemeMode current,
  ThemeModeNotifier notifier,
) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(width * 0.04)),
    ),
    builder: (_) => ThemePickerSheet(current: current, notifier: notifier),
  );
}
