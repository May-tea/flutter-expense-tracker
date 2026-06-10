import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../auth/providers/auth_provider.dart';

class EditUsernameDialog extends StatefulWidget {
  const EditUsernameDialog({super.key, required this.ref, required this.currentName});

  final WidgetRef ref;
  final String currentName;

  @override
  State<EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<EditUsernameDialog> {
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
