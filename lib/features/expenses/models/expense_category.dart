import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  entertainment,
  bills,
  health,
  travel,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';

      case ExpenseCategory.transport:
        return 'Transport';

      case ExpenseCategory.shopping:
        return 'Shopping';

      case ExpenseCategory.entertainment:
        return 'Entertainment';

      case ExpenseCategory.bills:
        return 'Bills';

      case ExpenseCategory.health:
        return 'Health';

      case ExpenseCategory.travel:
        return 'Travel';

      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;

      case ExpenseCategory.transport:
        return Icons.directions_car;

      case ExpenseCategory.shopping:
        return Icons.shopping_bag;

      case ExpenseCategory.entertainment:
        return Icons.movie;

      case ExpenseCategory.bills:
        return Icons.receipt_long;

      case ExpenseCategory.health:
        return Icons.favorite;

      case ExpenseCategory.travel:
        return Icons.flight;

      case ExpenseCategory.other:
        return Icons.category;
    }
  }
}
