import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../models/expense_category.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ExpenseCategory selectedCategory;
  final Function(ExpenseCategory) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: screenWidth * 0.03,
      crossAxisSpacing: screenWidth * 0.03,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: ExpenseCategory.values
          .where((category) => category != .income)
          .map((category) {
            final isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainer,
                  borderRadius: .circular(screenWidth * 0.03),
                  boxShadow: [
                    .new(
                      color: colorScheme.onSurface.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const .new(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: screenWidth * 0.01,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    Text(
                      category.label,
                      style: .new(
                        fontSize: screenWidth * 0.03,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: .bold,
                      ),
                      textAlign: .center,
                    ),
                  ],
                ),
              ),
            );
          })
          .toList(),
    );
  }
}
