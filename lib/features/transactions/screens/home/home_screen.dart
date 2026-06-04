import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../widgets/home/hero_balance_card.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/recent_transactions_header.dart';
import '../../widgets/transactions_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .all(screenWidth * 0.05),
          child: Column(
            spacing: screenWidth * 0.06,
            children: const [
              HomeHeader(),
              HeroBalanceCard(),
              RecentTransactionsHeader(),
              Expanded(child: TransactionsList(isAllTransactions: false)),
            ],
          ),
        ),
      ),
    );
  }
}
