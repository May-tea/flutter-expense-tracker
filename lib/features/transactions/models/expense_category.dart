import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  leisure,
  bills,
  health,
  travel,
  other,
  income,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case .food:
        return 'Food';

      case .transport:
        return 'Transport';

      case .shopping:
        return 'Shopping';

      case .leisure:
        return 'Leisure';

      case .bills:
        return 'Bills';

      case .health:
        return 'Health';

      case .travel:
        return 'Travel';

      case .other:
        return 'Other';

      case .income:
        return 'Income';
    }
  }

  IconData get icon {
    switch (this) {
      case .food:
        return Icons.restaurant;

      case .transport:
        return Icons.directions_car;

      case .shopping:
        return Icons.shopping_bag;

      case .leisure:
        return Icons.movie;

      case .bills:
        return Icons.receipt_long;

      case .health:
        return Icons.favorite;

      case .travel:
        return Icons.flight;

      case .other:
        return Icons.category;

      case .income:
        return Icons.payment_rounded;
    }
  }
}
