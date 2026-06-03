import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../models/expense_category.dart';
import '../../models/transaction_model.dart';
import '../../screens/add_transaction/add_transaction_screen.dart';
import '../../utils/category_utils.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    final isIncome = transaction.type == .income;

    final colorScheme = Theme.of(context).colorScheme;
    final color = categoryColor(transaction.category, colorScheme);

    final formattedAmount = NumberFormat.simpleCurrency().format(
      transaction.amount,
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(transaction: transaction),
          ),
        );
      },
      child: Container(
        padding: .all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: .circular(screenWidth * 0.04),
          boxShadow: [
            .new(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const .new(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.05,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(transaction.category.icon, color: color),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                spacing: screenWidth * 0.03,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: .new(
                      fontSize: screenWidth * 0.04,
                      fontWeight: .bold,
                    ),
                  ),
                  Text(
                    transaction.category.label,
                    style: .new(color: colorScheme.secondary),
                  ),
                ],
              ),
            ),
            Column(
              spacing: screenWidth * 0.03,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} $formattedAmount',
                  style: .new(
                    color: isIncome ? colorScheme.primary : colorScheme.error,
                    fontWeight: .bold,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(transaction.date),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
