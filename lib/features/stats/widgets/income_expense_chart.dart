import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/stats_filter.dart';
import '../providers/stats_provider.dart';

class IncomeExpenseChart extends ConsumerWidget {
  const IncomeExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatsListProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const .new(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: SfCartesianChart(
        key: ValueKey(stats),
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compactCurrency(symbol: '\$'),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: const Legend(isVisible: true),
        series: <CartesianSeries<MonthlyStats, String>>[
          ColumnSeries<MonthlyStats, String>(
            dataSource: stats,
            xValueMapper: (stat, _) => stat.monthLabel,
            yValueMapper: (stat, _) => stat.income,
            name: 'Income',
            color: colorScheme.primary,
            animationDuration: 600,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
          ColumnSeries<MonthlyStats, String>(
            dataSource: stats,
            xValueMapper: (stat, _) => stat.monthLabel,
            yValueMapper: (stat, _) => stat.expense,
            name: 'Expense',
            color: colorScheme.error,
            animationDuration: 600,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
