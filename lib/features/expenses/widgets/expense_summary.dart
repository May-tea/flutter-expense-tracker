import '../../../core/utils/screen_utils.dart';
import 'package:flutter/material.dart';

class ExpenseSummary extends StatelessWidget {
  const ExpenseSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    return Row(
      children: [
        const Expanded(
          child: _SummaryCard(
            title: 'Income',
            amount: '\$6,250',
            icon: Icons.arrow_downward,
          ),
        ),
        SizedBox(width: screenWidth * 0.029),
        const Expanded(
          child: _SummaryCard(
            title: 'Expense',
            amount: '\$2,430',
            icon: Icons.arrow_upward,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: .all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: .circular(screenWidth * 0.05),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Icon(icon),
          SizedBox(height: screenWidth * 0.02),
          Text(title),
          SizedBox(height: screenWidth * 0.01),
          Text(
            amount,
            style: .new(
              fontWeight: .bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}
