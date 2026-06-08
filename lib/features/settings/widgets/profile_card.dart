import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) return const SizedBox();

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: .all(screenWidth * 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(screenWidth * 0.03),
      ),
      child: Padding(
        padding: .all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: .start,
          spacing: screenWidth * 0.025,
          children: [
            Row(
              spacing: screenWidth * 0.04,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: .new(
                      fontSize: screenWidth * 0.06,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: screenWidth * 0.01,
                    children: [
                      Text(
                        user.displayName ?? 'Unknown',
                        style: .new(
                          fontSize: screenWidth * 0.045,
                          fontWeight: .bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: .new(
                          fontSize: screenWidth * 0.035,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditUsernameDialog(
                    context,
                    ref,
                    user.displayName ?? '',
                  ),
                ),
              ],
            ),
            Text(
              user.emailVerified ? '✓ Verified' : '❌ Not Verified',
              style: .new(
                fontSize: screenWidth * 0.035,
                color: user.emailVerified
                    ? colorScheme.tertiary
                    : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showEditUsernameDialog(
  BuildContext context,
  WidgetRef ref,
  String currentName,
) {
  showDialog(
    context: context,
    builder: (ctx) => _EditUsernameDialog(ref: ref, currentName: currentName),
  );
}

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({required this.ref, required this.currentName});

  final WidgetRef ref;
  final String currentName;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Edit Username'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? AppLoadingIndicator(
                  size: screenWidth * 0.05,
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final newName = _controller.text.trim();

    if (newName.isEmpty) return;

    setState(() => _isLoading = true);

    final authService = widget.ref.read(authServiceProvider);
    await authService.updateDisplayName(newName);

    if (mounted) Navigator.pop(context);

    widget.ref.invalidate(authStateProvider);

    AppSnackBar.show(
      context,
      isError: false,
      message: 'Username updated successfully.',
    );
  }
}
