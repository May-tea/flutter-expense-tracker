import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/stats_provider.dart';

class CategoryBreakdown extends ConsumerWidget {
  const CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(categoryBreakdownProvider);

    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (breakdown.isEmpty) {
      return Text(
        'No expense data',
        style: .new(color: colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: .start,
      children: breakdown.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;

        return Padding(
          padding: .symmetric(vertical: screenWidth * 0.01),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(category.name, style: const .new(fontWeight: .w500)),
              Text('\$${amount.toStringAsFixed(2)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
