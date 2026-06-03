import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_tile.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionService = ref.watch(transactionServiceProvider);
    final transactionAsync = ref.watch(transactionsProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return transactionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: screenWidth * 0.16,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: screenWidth * 0.029),
                Text(
                  'No transactions yet',
                  style: .new(
                    fontSize: screenWidth * 0.044,
                    fontWeight: .w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  'Tap + to add your first transaction',
                  style: .new(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: .only(top: screenWidth * 0.019, bottom: screenWidth * 0.058),
          itemCount: transactions.length,
          separatorBuilder: (_, _) => SizedBox(height: screenWidth * 0.03),
          itemBuilder: (ctx, index) {
            final transaction = transactions[index];

            return Dismissible(
              key: ValueKey(transaction.id),
              direction: .endToStart,
              onDismissed: (_) async {
                await transactionService.deleteTransaction(transaction.id);

                if (!context.mounted) return;

                AppSnackBar.show(
                  context,
                  isError: true,
                  message: 'Transaction deleted!',
                  actionLabel: 'UNDO',
                  onAction: () async {
                    ScaffoldMessenger.of(context).clearSnackBars();

                    await transactionService.restoreTransaction(transaction);
                  },
                );
              },
              background: Container(
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: .circular(screenWidth * 0.048),
                ),
                alignment: .centerRight,
                padding: .symmetric(horizontal: screenWidth * 0.048),
                child: Icon(
                  Icons.delete_outline,
                  size: screenWidth * 0.068,
                  color: colorScheme.error,
                ),
              ),
              child: TransactionTile(transaction: transaction),
            );
          },
        );
      },
    );
  }
}
