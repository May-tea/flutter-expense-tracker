import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expense_provider.dart';
import 'expense_tile.dart';

class RecentExpenses extends ConsumerWidget {
  const RecentExpenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final expenseService = ref.watch(expenseServiceProvider);

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses yet.'));
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (ctx, index) {
            final expense = expenses[index];

            return Dismissible(
              key: ValueKey(expense.id),
              direction: .endToStart,
              onDismissed: (_) async {
                await expenseService.deleteExpense(expense.id);
              },
              background: Container(
                alignment: .centerRight,
                padding: const .symmetric(horizontal: 20),
                child: const Icon(Icons.delete),
              ),
              child: ExpenseTile(expense: expense),
            );
          },
        );
      },
    );
  }
}
