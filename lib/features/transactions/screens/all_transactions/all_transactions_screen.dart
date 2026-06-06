import 'package:flutter/material.dart';

import '../../widgets/transactions_list.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: const TransactionsList(isAllTransactions: true),
    );
  }
}
