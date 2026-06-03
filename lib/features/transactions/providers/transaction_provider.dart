import 'package:flutter_riverpod/flutter_riverpod.dart';

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
