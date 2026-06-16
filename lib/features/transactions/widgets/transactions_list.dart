import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'transaction_tile.dart';

class TransactionsList extends ConsumerWidget {
  const TransactionsList({
    super.key,
    required this.isAllTransactions,
    this.ignoreFilter = false,
  });

  final bool isAllTransactions;
  final bool ignoreFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionsProvider);
    final filter = ref.watch(transactionFilterProvider);

    final transactionService = ref.watch(transactionServiceProvider);

    final filteredTransactions = ignoreFilter
        ? transactionAsync.maybeWhen(
            data: (list) => list,
            orElse: () => <TransactionModel>[],
          )
        : ref.watch(filteredTransactionsProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return transactionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (_) {
        if (filteredTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(
                  filter.hasActiveFilter
                      ? Icons.search_off
                      : Icons.receipt_long_outlined,
                  size: screenWidth * 0.16,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: screenWidth * 0.029),
                Text(
                  filter.hasActiveFilter
                      ? 'No matching transactions'
                      : 'No transactions yet',
                  style: .new(
                    fontSize: screenWidth * 0.044,
                    fontWeight: .w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  filter.hasActiveFilter
                      ? 'Try adjusting your filters'
                      : 'Tap + to add your first transaction',
                  style: .new(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        final itemCount = isAllTransactions
            ? filteredTransactions.length
            : filteredTransactions.length.clamp(0, 3);

        return ListView.separated(
          padding: .only(
            top: screenWidth * 0.019,
            bottom: screenWidth * 0.058,
            left: isAllTransactions ? screenWidth * 0.04 : 0,
            right: isAllTransactions ? screenWidth * 0.04 : 0,
          ),
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(height: screenWidth * 0.03),
          itemBuilder: (ctx, index) {
            final transaction = filteredTransactions[index];

            return Dismissible(
              key: ValueKey(transaction.id),
              direction: .endToStart,
              onDismissed: (_) async {
                await transactionService
                    .deleteTransaction(transaction.id)
                    .timeout(const Duration(seconds: 2));

                if (!context.mounted) return;
                AppSnackBar.show(
                  context,
                  isError: true,
                  message: 'Transaction deleted!',
                  actionLabel: 'UNDO',
                  onAction: () async {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    transactionService
                        .restoreTransaction(transaction)
                        .timeout(const .new(seconds: 2), onTimeout: () {});
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
