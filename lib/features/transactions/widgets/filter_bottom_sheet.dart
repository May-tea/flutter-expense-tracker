import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_utils.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_type.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _searchController;

  late TransactionFilter _localFilter;

  @override
  void initState() {
    super.initState();

    final currentFilter = ref.read(transactionFilterProvider);

    _localFilter = currentFilter;

    _minController = TextEditingController(
      text: currentFilter.minAmount?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: currentFilter.maxAmount?.toString() ?? '',
    );
    _searchController = TextEditingController(
      text: currentFilter.searchText ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  void _applyFilters() {
    if (!_formKey.currentState!.validate()) return;

    final min = _minController.text.isNotEmpty
        ? double.tryParse(_minController.text)
        : null;
    final max = _maxController.text.isNotEmpty
        ? double.tryParse(_maxController.text)
        : null;

    ref.read(transactionFilterProvider.notifier).state = _localFilter.copyWith(
      minAmount: min,
      maxAmount: max,
      searchText: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
    );

    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _localFilter = const .new();

      _minController.clear();
      _maxController.clear();
      _searchController.clear();
    });

    ref.read(transactionFilterProvider.notifier).state = const .new();

    Navigator.pop(context);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const .new(days: 365)),
      initialDateRange: _localFilter.dateRange,
    );

    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(dateRange: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    Widget verticalGap = SizedBox(height: screenWidth * 0.039);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.039,
          screenWidth * 0.02,
          screenWidth * 0.039,
          screenWidth * 0.04,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Center(
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.01,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: .circular(screenWidth * 0.005),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Center(
                  child: Text(
                    'Filter Transactions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: .w600,
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.058),

                Text('Type', style: theme.textTheme.labelLarge),

                SizedBox(height: screenWidth * 0.019),

                Wrap(
                  spacing: screenWidth * 0.019,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _localFilter.types == null,
                      onSelected: (_) => setState(() {
                        _localFilter = _localFilter.copyWith(types: null);
                      }),
                    ),

                    FilterChip(
                      label: const Text('Income'),
                      selected:
                          _localFilter.types?.contains(
                            TransactionType.income,
                          ) ==
                          true,
                      onSelected: (_) => setState(() {
                        _localFilter = _localFilter.copyWith(
                          types: {TransactionType.income},
                        );
                      }),
                    ),

                    FilterChip(
                      label: const Text('Expense'),
                      selected:
                          _localFilter.types?.contains(
                            TransactionType.expense,
                          ) ==
                          true,
                      onSelected: (_) => setState(() {
                        _localFilter = _localFilter.copyWith(
                          types: {TransactionType.expense},
                        );
                      }),
                    ),
                  ],
                ),

                verticalGap,

                Text('Date Range', style: theme.textTheme.labelLarge),

                SizedBox(height: screenWidth * 0.019),

                InkWell(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: .symmetric(
                      horizontal: screenWidth * 0.029,
                      vertical: screenWidth * 0.029,
                    ),
                    decoration: BoxDecoration(
                      border: .all(color: theme.colorScheme.outline),
                      borderRadius: .circular(screenWidth * 0.019),
                    ),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          _localFilter.dateRange != null
                              ? '${_localFilter.dateRange!.start.toLocal().toString().split(' ')[0]} → ${_localFilter.dateRange!.end.toLocal().toString().split(' ')[0]}'
                              : 'Select a date range',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Icon(Icons.date_range),
                      ],
                    ),
                  ),
                ),

                if (_localFilter.dateRange != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _localFilter = _localFilter.copyWith(dateRange: null);
                    }),
                    child: const Text('Clear'),
                  ),

                verticalGap,

                Text('Category', style: theme.textTheme.labelLarge),

                SizedBox(height: screenWidth * 0.019),

                DropdownButtonFormField<String>(
                  initialValue: _localFilter.category,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'All categories',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.name,
                        child: Text(cat.name),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() {
                    _localFilter = _localFilter.copyWith(categoryName: val);
                  }),
                ),

                verticalGap,

                Text('Amount Range', style: theme.textTheme.labelLarge),

                SizedBox(height: screenWidth * 0.019),

                Row(
                  spacing: screenWidth * 0.029,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minController,
                        keyboardType: const .numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (val) {
                          if (val != null &&
                              val.isNotEmpty &&
                              double.tryParse(val) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _maxController,
                        keyboardType: const .numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (val) {
                          if (val != null &&
                              val.isNotEmpty &&
                              double.tryParse(val) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                verticalGap,

                Text('Search', style: theme.textTheme.labelLarge),

                SizedBox(height: screenWidth * 0.019),

                TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by title...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                SizedBox(height: screenWidth * 0.058),

                Row(
                  spacing: screenWidth * 0.039,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.019),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
