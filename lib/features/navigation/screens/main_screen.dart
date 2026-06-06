import 'package:flutter/material.dart';

import '../../settings/screens/settings_screen.dart';
import '../../transactions/screens/add_transaction/add_transaction_screen.dart';
import '../../transactions/screens/all_transactions/all_transactions_screen.dart';
import '../../transactions/screens/home/home_screen.dart';
import '../widgets/bottom_navigation_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    Placeholder(),
    Placeholder(),
    AllTransactionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        onAddPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
    );
  }
}
