import 'package:intl/intl.dart';

enum StatsFilter { thisMonth, threeMonths, sixMonths, all }

class MonthlyStats {
  MonthlyStats({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;

  String get monthLabel => DateFormat('MMM yyyy').format(month);
}
