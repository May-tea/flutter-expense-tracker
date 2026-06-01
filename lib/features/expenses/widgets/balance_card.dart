import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/expense_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalExpense = ref.watch(totalExpenseProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: .all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: .circular(screenWidth * 0.06),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Total Expenses',
            style: .new(color: colorScheme.onPrimary.withValues(alpha: 0.8)),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            '\$${totalExpense.toStringAsFixed(2)}',
            style: .new(
              color: colorScheme.onPrimary,
              fontSize: screenWidth * 0.08,
              fontWeight: .bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: 'Income',
                  amount: '\$6,250',
                  color: colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: _BalanceItem(
                  label: 'Expense',
                  amount: '\$2,430',
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: .new(color: color.withValues(alpha: 0.8))),
        Text(
          amount,
          style: .new(color: color, fontWeight: .bold),
        ),
      ],
    );
  }
}
