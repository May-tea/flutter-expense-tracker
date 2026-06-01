import 'package:app/features/expenses/models/expense_category.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/screen_utils.dart';
import '../models/expense_model.dart';
import 'add_expense_sheet.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final ExpenseModel expense;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _categoryColor(expense.category, colorScheme);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return AddExpenseSheet(expense: expense);
          },
        );
      },
      child: Container(
        margin: .only(bottom: screenWidth * 0.03),
        padding: .all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: .circular(screenWidth * 0.04),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: categoryColor.withValues(alpha: 0.15),
              child: Icon(expense.category.icon, color: categoryColor),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: const .new(fontWeight: .bold),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    expense.category.label,
                    style: .new(color: colorScheme.secondary),
                  ),
                ],
              ),
            ),

            Text(
              '- \$${expense.amount.toStringAsFixed(2)}',
              style: .new(color: colorScheme.error, fontWeight: .bold),
            ),
          ],
        ),
      ),
    );
  }
}

Color _categoryColor(ExpenseCategory category, ColorScheme colorScheme) {
  switch (category) {
    case ExpenseCategory.food:
      return Colors.orange;

    case ExpenseCategory.transport:
      return Colors.blue;

    case ExpenseCategory.shopping:
      return Colors.purple;

    case ExpenseCategory.entertainment:
      return Colors.pink;

    case ExpenseCategory.bills:
      return Colors.red;

    case ExpenseCategory.health:
      return Colors.green;

    case ExpenseCategory.travel:
      return Colors.cyan;

    case ExpenseCategory.other:
      return colorScheme.primary;
  }
}
