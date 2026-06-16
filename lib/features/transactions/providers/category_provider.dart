import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_category.dart';

final categoriesProvider = Provider<List<ExpenseCategory>>(
  (ref) => ExpenseCategory.values,
);
