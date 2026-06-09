import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../extensions/stats_filter_extension.dart';
import '../models/stats_filter.dart';
import '../providers/stats_provider.dart';

class StatsFilterChips extends ConsumerWidget {
  const StatsFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(statsFilterProvider);

    final screenWidth = ScreenUtils.width(context);

    return Wrap(
      spacing: screenWidth * 0.019,
      children: StatsFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(filter.label),
          selected: selectedFilter == filter,
          onSelected: (_) {
            ref.read(statsFilterProvider.notifier).state = filter;
          },
        );
      }).toList(),
    );
  }
}
