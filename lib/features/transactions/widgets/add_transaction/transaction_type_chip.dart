import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../models/transaction_type.dart';

class TransactionTypeChip extends StatelessWidget {
  const TransactionTypeChip({
    super.key,
    required this.label,
    required this.type,
    required this.selectedType,
    required this.onSelected,
  });

  final String label;
  final TransactionType type;
  final TransactionType selectedType;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: .symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainer,
          borderRadius: .circular(screenWidth * 0.03),
          boxShadow: isSelected
              ? [
                  .new(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const .new(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: .new(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: .bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
      ),
    );
  }
}
