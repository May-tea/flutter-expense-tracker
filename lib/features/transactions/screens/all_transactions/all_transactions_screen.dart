import 'package:flutter/material.dart';

import '../../widgets/transaction_filter_bar.dart';
import '../../widgets/transactions_list.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: const Column(
        children: [
          TransactionFilterBar(),
          Expanded(child: TransactionsList(isAllTransactions: true)),
        ],
      ),
    );
  }
}
