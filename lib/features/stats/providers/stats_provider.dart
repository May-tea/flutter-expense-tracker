import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../transactions/models/expense_category.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../models/stats_filter.dart';

final statsFilterProvider = StateProvider<StatsFilter>((ref) => .thisMonth);

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(data: (data) => data, orElse: () => <TransactionModel>[]);

  final filter = ref.watch(statsFilterProvider);

  DateTime subtractMonths(DateTime date, int months) {
    final y = date.year;
    final m = date.month - months;
    final d = date.day;

    final newYear = y + (m <= 0 ? (m - 12) ~/ 12 : 0);
    final newMonth = (m % 12 == 0 ? 12 : m % 12);
    final lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = d > lastDayOfMonth ? lastDayOfMonth : d;

    return DateTime(newYear, newMonth, newDay);
  }

  final now = DateTime.now();

  return switch (filter) {
    .thisMonth =>
      transactions
          .where((t) => t.date.year == now.year && t.date.month == now.month)
          .toList(),
    .threeMonths =>
      transactions
          .where((t) => !t.date.isBefore(subtractMonths(now, 3)))
          .toList(),
    .sixMonths =>
      transactions
          .where((t) => !t.date.isBefore(subtractMonths(now, 6)))
          .toList(),
    .all => transactions,
  };
});

double _sumAmounts(List<TransactionModel> transactions) {
  return transactions.fold(0, (sum, t) => sum + t.amount);
}

final filteredIncomeProvider = Provider<double>((ref) {
  return _sumAmounts(
    ref
        .watch(filteredTransactionsProvider)
        .where((t) => t.type == .income)
        .toList(),
  );
});

final filteredExpenseProvider = Provider<double>((ref) {
  return _sumAmounts(
    ref
        .watch(filteredTransactionsProvider)
        .where((t) => t.type == .expense)
        .toList(),
  );
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(filteredIncomeProvider) - ref.watch(filteredExpenseProvider);
});

final categoryBreakdownProvider = Provider<Map<ExpenseCategory, double>>((ref) {
  final transactions = ref
      .watch(filteredTransactionsProvider)
      .where((t) => t.type == .expense && t.category != .income)
      .toList();

  final Map<ExpenseCategory, double> breakdown = {};

  for (final t in transactions) {
    breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
  }

  return breakdown;
});

final monthlyStatsListProvider = Provider<List<MonthlyStats>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  final Map<DateTime, Map<String, double>> grouped = {};

  for (final t in transactions) {
    final monthKey = DateTime(t.date.year, t.date.month);

    grouped.putIfAbsent(monthKey, () => {'income': 0, 'expense': 0});

    if (t.type == .income) {
      grouped[monthKey]!['income'] = grouped[monthKey]!['income']! + t.amount;
    } else {
      grouped[monthKey]!['expense'] = grouped[monthKey]!['expense']! + t.amount;
    }
  }

  final result = grouped.entries.map((e) {
    return MonthlyStats(
      month: e.key,
      income: e.value['income'] ?? 0,
      expense: e.value['expense'] ?? 0,
    );
  }).toList();

  result.sort((a, b) => a.month.compareTo(b.month));

  return result;
});
