import 'package:app/features/transactions/models/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>(
  (ref) => .instance,
);

final transactionsProvider = StreamProvider<List<TransactionModel>>(
  (ref) => ref.watch(transactionServiceProvider).getTransactions(),
);

final transactionsByTypeProvider =
    Provider.family<List<TransactionModel>, TransactionType>((ref, type) {
      return ref
          .watch(transactionsProvider)
          .maybeWhen(
            data: (transactions) =>
                transactions.where((t) => t.type == type).toList(),
            orElse: () => [],
          );
    });

final totalIncomeProvider = Provider<double>((ref) {
  return _sumAmounts(ref.watch(transactionsByTypeProvider(.income)));
});

final totalExpenseProvider = Provider<double>((ref) {
  return _sumAmounts(ref.watch(transactionsByTypeProvider(.expense)));
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

double _sumAmounts(List<TransactionModel> transactions) {
  return transactions.fold(0, (sum, t) => sum + t.amount);
}

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => const .new(),
);

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) => _applyFilter(transactions, filter),
    orElse: () => [],
  );
});

List<TransactionModel> _applyFilter(
  List<TransactionModel> transactions,
  TransactionFilter filter,
) {
  return transactions.where((t) {
    if (filter.types != null && !filter.types!.contains(t.type)) {
      return false;
    }

    if (filter.dateRange != null) {
      final date = t.date;
      final start = filter.dateRange!.start;
      final end = DateTime(
        filter.dateRange!.end.year,
        filter.dateRange!.end.month,
        filter.dateRange!.end.day,
        23,
        59,
        59,
      );
      if (date.isBefore(start) || date.isAfter(end)) {
        return false;
      }
    }

    if (filter.category != null && t.category.name != filter.category) {
      return false;
    }

    if (filter.minAmount != null && t.amount < filter.minAmount!) {
      return false;
    }

    if (filter.maxAmount != null && t.amount > filter.maxAmount!) {
      return false;
    }

    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      final query = filter.searchText!.toLowerCase();
      final title = t.title.toLowerCase();

      if (!title.contains(query)) {
        return false;
      }
    }

    return true;
  }).toList();
}
