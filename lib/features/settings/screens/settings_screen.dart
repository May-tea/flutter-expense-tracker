import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/services/export_service.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/delete_transactions_dialog.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_header.dart';
import '../widgets/theme_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  String _version = '';

  @override
  void initState() {
    super.initState();

    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _saveTransactions(BuildContext context, WidgetRef ref) async {
    final asyncTransactions = ref.read(transactionsProvider);

    asyncTransactions.maybeWhen(
      data: (transactions) async {
        if (transactions.isEmpty) {
          AppSnackBar.show(
            context,
            isError: true,
            message: 'You have no transactions to export.',
          );
          return;
        }

        setState(() => _isExporting = true);

        try {
          final success = await ExportService().saveToDevice(transactions);

          if (context.mounted) {
            AppSnackBar.show(
              context,
              isError: !success,
              message: success
                  ? 'Transactions saved successfully'
                  : 'Failed to save transactions.',
            );
          }
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    final notifications = ref.watch(notificationsProvider);
    final notificationsNotifier = ref.read(notificationsProvider.notifier);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ProfileCard(),

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
            value: notifications.enabled,
            onChanged: notificationsNotifier.setEnabled,
          ),
          if (notifications.enabled)
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Reminder Time'),
              subtitle: Text(
                notifications.reminderTime?.format(context) ??
                    const TimeOfDay(hour: 21, minute: 0).format(context),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                      notifications.reminderTime ??
                      const TimeOfDay(hour: 21, minute: 0),
                );

                if (picked != null) {
                  notificationsNotifier.setReminderTime(picked);
                }
              },
            ),

          const SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Transactions'),
            subtitle: const Text('Save as CSV'),
            trailing: _isExporting
                ? AppLoadingIndicator(
                    size: screenWidth * 0.049,
                    strokeWidth: screenWidth * 0.0049,
                    color: colorScheme.onSurfaceVariant,
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isExporting ? null : () => _saveTransactions(context, ref),
          ),

          const SectionHeader(title: 'Danger Zone'),
          ListTile(
            leading: Icon(
              Icons.delete_sweep_outlined,
              color: colorScheme.error,
            ),
            title: Text(
              'Delete All Transactions',
              style: .new(color: colorScheme.error),
            ),
            onTap: () => _showDeleteTransactionsDialog(context, ref),
          ),

          const SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text('Log out', style: .new(color: colorScheme.error)),
            onTap: () async => await _showLogoutDialog(context, ref),
          ),

          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: colorScheme.error,
            ),
            title: Text(
              'Delete Account',
              style: .new(color: colorScheme.error),
            ),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          const SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: Text(_version.isEmpty ? '...' : _version),
          ),
        ],
      ),
    );
  }
}

void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => DeleteAccountDialog(ref: ref),
  );
}

Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final shouldLogout = await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );

  if (shouldLogout != true) return;

  await ref.read(authServiceProvider).signOut();
}

void _showDeleteTransactionsDialog(BuildContext context, WidgetRef ref) {
  final asyncTransactions = ref.read(transactionsProvider);

  asyncTransactions.maybeWhen(
    data: (transactions) {
      if (transactions.isEmpty) {
        AppSnackBar.show(
          context,
          isError: true,
          message: 'You have no transactions yet.',
        );
        return;
      } else {
        showDialog(
          context: context,
          builder: (_) => DeleteTransactionsDialog(ref: ref),
        );
      }
    },
    orElse: () {},
  );
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
