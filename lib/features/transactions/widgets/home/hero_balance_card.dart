import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../providers/transaction_provider.dart';

class HeroBalanceCard extends ConsumerWidget {
  const HeroBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: .infinity,
      padding: .all(screenWidth * 0.06),
      decoration: BoxDecoration(
        borderRadius: .circular(screenWidth * 0.06),
        gradient: LinearGradient(
          begin: .topLeft,
          end: .bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          .new(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const .new(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Total Balance',
            style: .new(color: colorScheme.onPrimary.withValues(alpha: 0.8)),
          ),
          SizedBox(height: screenWidth * 0.03),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: .new(
              color: colorScheme.onPrimary,
              fontSize: screenWidth * 0.11,
              fontWeight: .w700,
            ),
          ),
          SizedBox(height: screenWidth * 0.06),
          Row(
            children: [
              Expanded(
                child: _AmountInfo(
                  title: 'Income',
                  amount: income,
                  icon: Icons.south_west,
                ),
              ),
              Expanded(
                child: _AmountInfo(
                  title: 'Expense',
                  amount: expense,
                  icon: Icons.north_east,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountInfo extends StatelessWidget {
  const _AmountInfo({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          spacing: screenWidth * 0.019,
          children: [
            CircleAvatar(
              radius: screenWidth * 0.039,
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.15),
              child: Icon(
                icon,
                size: screenWidth * 0.039,
                color: colorScheme.onPrimary,
              ),
            ),
            Text(
              title,
              style: .new(color: colorScheme.onPrimary.withValues(alpha: 0.8)),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.019),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: .new(color: colorScheme.onPrimary, fontWeight: .bold),
        ),
      ],
    );
  }
}
