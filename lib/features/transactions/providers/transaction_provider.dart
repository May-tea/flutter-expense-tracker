import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>(
  (ref) => .instance,
);

final transactionsProvider = StreamProvider<List<TransactionModel>>(
  (ref) => ref.watch(transactionServiceProvider).getTransactions(),
);

final totalIncomeProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      return transactions
          .where((transaction) => transaction.type == .income)
          .fold(0, (sum, transaction) => sum + transaction.amount);
    },
    orElse: () => 0,
  );
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      return transactions
          .where((transaction) => transaction.type == .expense)
          .fold(0, (sum, transaction) => sum + transaction.amount);
    },
    orElse: () => 0,
  );
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);

  final expense = ref.watch(totalExpenseProvider);

  return income - expense;
});
