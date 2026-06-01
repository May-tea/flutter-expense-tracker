import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) => .instance);

final expensesProvider = StreamProvider<List<ExpenseModel>>(
  (ref) => ref.watch(expenseServiceProvider).getExpenses(),
);

final totalExpenseProvider = Provider<double>((ref) {
  final expensesAsync = ref.watch(expensesProvider);

  return expensesAsync.maybeWhen(
    data: (expenses) {
      return expenses.fold(0, (sum, expense) => sum + expense.amount);
    },
    orElse: () => 0,
  );
});
