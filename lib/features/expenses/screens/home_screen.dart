import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_summary.dart';
import '../widgets/recent_expenses.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenUtils.width(context);
    final expenseAsync = ref.watch(expensesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .all(screenWidth * 0.05),
          child: Column(
            children: [
              const BalanceCard(),
              SizedBox(height: screenWidth * 0.06),
              const ExpenseSummary(),
              SizedBox(height: screenWidth * 0.06),
              const Expanded(child: RecentExpenses()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddExpenseSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
