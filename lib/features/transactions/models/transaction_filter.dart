import 'package:flutter/material.dart';

import 'transaction_type.dart';

class TransactionFilter {
  const TransactionFilter({
    this.types,
    this.dateRange,
    this.category,
    this.minAmount,
    this.maxAmount,
    this.searchText,
  });

  final Set<TransactionType>? types;
  final DateTimeRange? dateRange;
  final String? category;
  final double? minAmount;
  final double? maxAmount;
  final String? searchText;

  static const _clear = Object();

  TransactionFilter copyWith({
    Object? types = _clear,
    Object? dateRange = _clear,
    Object? categoryName = _clear,
    Object? minAmount = _clear,
    Object? maxAmount = _clear,
    Object? searchText = _clear,
  }) {
    return .new(
      types: identical(types, _clear)
          ? this.types
          : types as Set<TransactionType>?,
      dateRange: identical(dateRange, _clear)
          ? this.dateRange
          : dateRange as DateTimeRange?,
      category: identical(categoryName, _clear)
          ? category
          : categoryName as String?,
      minAmount: identical(minAmount, _clear)
          ? this.minAmount
          : minAmount as double?,
      maxAmount: identical(minAmount, _clear)
          ? this.maxAmount
          : maxAmount as double?,
      searchText: identical(minAmount, _clear)
          ? this.searchText
          : searchText as String?,
    );
  }

  TransactionFilter clearAmounts() => .new(
    types: types,
    dateRange: dateRange,
    category: category,
    minAmount: null,
    maxAmount: null,
    searchText: searchText,
  );

  bool get hasActiveFilter =>
      types != null ||
      dateRange != null ||
      category != null ||
      minAmount != null ||
      maxAmount != null ||
      (searchText != null && searchText!.isNotEmpty);
}
