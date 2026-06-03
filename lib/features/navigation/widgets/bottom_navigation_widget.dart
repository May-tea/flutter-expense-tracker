import 'package:flutter/material.dart';

import '../../../core/utils/screen_utils.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  });

  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Stack(
        clipBehavior: .none,
        children: [
          Container(
            height: screenWidth * 0.2,
            padding: .symmetric(
              vertical: screenWidth * 0.025,
              horizontal: screenWidth * 0.05,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const .new(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: .spaceAround,
              children: [
                _buildTabItem(Icons.home_outlined, 0, screenWidth, colorScheme),
                _buildTabItem(
                  Icons.bar_chart_outlined,
                  1,
                  screenWidth,
                  colorScheme,
                ),
                SizedBox(width: screenWidth * 0.16),
                _buildTabItem(
                  Icons.receipt_long_rounded,
                  3,
                  screenWidth,
                  colorScheme,
                ),
                _buildTabItem(
                  Icons.settings_outlined,
                  4,
                  screenWidth,
                  colorScheme,
                ),
              ],
            ),
          ),
          Positioned(
            top: -screenWidth * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: _buildMiddleAddButton(screenWidth, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    IconData icon,
    int index,
    double screenWidth,
    ColorScheme colorScheme,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: screenWidth * 0.085,
      ),
    );
  }

  Widget _buildMiddleAddButton(double screenWidth, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: screenWidth * 0.17,
        height: screenWidth * 0.17,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: .circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const .new(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: colorScheme.onPrimary,
          size: screenWidth * 0.08,
        ),
      ),
    );
  }
}
