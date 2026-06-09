import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/stats_provider.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/stats_container.dart';
import '../widgets/stats_filter_chips.dart';
import '../widgets/stats_summary_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    final filter = ref.watch(statsFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: .symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.029,
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: screenWidth * 0.024,
              children: [
                const StatsFilterChips(),

                Text(
                  'Showing: ${filter.name}',
                  style: .new(
                    fontSize: screenWidth * 0.029,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const StatsContainer(child: StatsSummaryCard()),

                Text(
                  'Financial Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: .w600,
                    letterSpacing: 0.2,
                  ),
                ),

                const StatsContainer(child: IncomeExpenseChart()),

                Text(
                  'Expenses by Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const StatsContainer(child: CategoryBreakdown()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
