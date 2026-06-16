import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../models/transaction_type.dart';
import '../providers/transaction_provider.dart';
import 'filter_bottom_sheet.dart';

class TransactionFilterBar extends ConsumerWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    final screenWidth = ScreenUtils.width(context);

    return Padding(
      padding: .symmetric(
        horizontal: screenWidth * 0.039,
        vertical: screenWidth * 0.019,
      ),
      child: Row(
        spacing: screenWidth * 0.019,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.types == null,
            onSelected: (_) =>
                ref.read(transactionFilterProvider.notifier).state = filter
                    .copyWith(types: null),
          ),

          FilterChip(
            label: const Text('Income'),
            selected: filter.types?.contains(TransactionType.income) == true,
            onSelected: (_) =>
                ref.read(transactionFilterProvider.notifier).state = filter
                    .copyWith(types: {TransactionType.income}),
          ),

          FilterChip(
            label: const Text('Expense'),
            selected: filter.types?.contains(TransactionType.expense) == true,
            onSelected: (_) =>
                ref.read(transactionFilterProvider.notifier).state = filter
                    .copyWith(types: {TransactionType.expense}),
          ),

          const Spacer(),

          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: filter.hasActiveFilter
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FilterBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }
}
