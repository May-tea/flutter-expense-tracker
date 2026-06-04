import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../widgets/transactions_list.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: .new(fontSize: screenWidth * 0.05, fontWeight: .bold),
        ),
      ),
      body: const TransactionsList(isAllTransactions: true),
    );
  }
}
