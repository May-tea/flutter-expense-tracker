import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/stats_provider.dart';

class StatsSummaryCard extends ConsumerWidget {
  const StatsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(filteredIncomeProvider);
    final expense = ref.watch(filteredExpenseProvider);
    final balance = ref.watch(balanceProvider);

    final screenWidth = ScreenUtils.width(context);

    return Card(
      child: Padding(
        padding: .all(screenWidth * 0.039),
        child: Column(
          children: [
            _row('Income', income),
            SizedBox(height: screenWidth * 0.029),
            _row('Expense', expense),
            const Divider(),
            _row('Balance', balance),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, double value) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [Text(title), Text('\$${value.toStringAsFixed(2)}')],
    );
  }
}
