import 'package:flutter/material.dart';

import '../models/expense_category.dart';

Color categoryColor(ExpenseCategory category, ColorScheme colorScheme) {
  switch (category) {
    case .food:
      return Colors.orange;

    case .transport:
      return Colors.blue;

    case .shopping:
      return Colors.purple;

    case .leisure:
      return Colors.pink;

    case .bills:
      return Colors.red;

    case .health:
      return Colors.green;

    case .travel:
      return Colors.cyan;

    case .other || .income:
      return colorScheme.primary;
  }
}
