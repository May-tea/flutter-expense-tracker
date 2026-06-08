import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/services/transaction_service.dart';

class DeleteTransactionsDialog extends ConsumerStatefulWidget {
  const DeleteTransactionsDialog({super.key, required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<DeleteTransactionsDialog> createState() =>
      _DeleteTransactionsDialogState();
}

class _DeleteTransactionsDialogState
    extends ConsumerState<DeleteTransactionsDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final transactionService = ref.read(transactionServiceProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'Delete All Transactions',
        style: TextStyle(color: colorScheme.error),
      ),
      content: const Text(
        'This will permanently delete all your transactions. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
          onPressed: _isLoading ? null : () => _delete(transactionService),
          child: _isLoading
              ? AppLoadingIndicator(
                  size: screenWidth * 0.05,
                  strokeWidth: 2,
                  color: colorScheme.onError,
                )
              : Text('Delete All', style: .new(color: colorScheme.surface)),
        ),
      ],
    );
  }

  Future<void> _delete(TransactionService service) async {
    setState(() => _isLoading = true);


    try {
      await service.deleteAllTransactions();
    } catch (_) {
      setState(() => _isLoading = false);
      return;
    }

    if (mounted) Navigator.pop(context);

    AppSnackBar.show(
      context,
      isError: false,
      message: 'All Transactions deleted successfully.',
    );
  }
}
