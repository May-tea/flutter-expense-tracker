import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

class InputCard extends StatelessWidget {
  const InputCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: .symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: .circular(screenWidth * 0.04),
        boxShadow: [
          .new(
            color: colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const .new(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
