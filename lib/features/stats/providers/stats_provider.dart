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
    int month = date.month - months;
    int year = date.year;

    while (month <= 0) {
      month += 12;
      year -= 1;
    }

    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;

    return DateTime(year, month, day);
  }

  final now = DateTime.now();

  return switch (filter) {
    .thisMonth =>
      transactions
          .where((t) => t.date.year == now.year && t.date.month == now.month)
          .toList(),
    .threeMonths => transactions.where((t) {
      final start = subtractMonths(DateTime(now.year, now.month, 1), 3);
      return !t.date.isBefore(start);
    }).toList(),
    .sixMonths => transactions.where((t) {
      final start = subtractMonths(DateTime(now.year, now.month, 1), 6);
      return !t.date.isBefore(start);
    }).toList(),
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
