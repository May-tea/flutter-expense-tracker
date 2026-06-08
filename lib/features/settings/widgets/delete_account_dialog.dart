import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.ref});

  final WidgetRef ref;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

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
      title: Text('Delete Account', style: .new(color: colorScheme.error)),
      content: Column(
        mainAxisSize: .min,
        spacing: screenWidth * 0.03,
        children: [
          const Text(
            'This action is permanent and cannot be undone. Enter your password to confirm.',
          ),
          TextField(
            controller: _controller,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
          onPressed: _isLoading ? null : _delete,
          child: _isLoading
              ? AppLoadingIndicator(
                  size: screenWidth * 0.05,
                  strokeWidth: 2,
                  color: colorScheme.onError,
                )
              : Text('Delete', style: .new(color: colorScheme.surface)),
        ),
      ],
    );
  }

  Future<void> _delete() async {
    final password = _controller.text.trim();

    if (password.isEmpty) {
      setState(() => _error = 'Enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = widget.ref.read(authServiceProvider);
      await authService.reauthenticate(password: password);
      await authService.deleteAccount();

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;

        _error = switch (e.code) {
          'wrong-password' => 'Incorrect password',
          'too-many-requests' => 'Too many attempts, try later',
          _ => 'Something went wrong',
        };
      });
    }
  }
}
