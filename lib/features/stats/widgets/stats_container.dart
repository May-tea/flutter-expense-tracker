import 'package:flutter/material.dart';

import '../../../core/utils/screen_utils.dart';

class StatsContainer extends StatelessWidget {
  const StatsContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: .all(screenWidth * 0.029),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: .circular(screenWidth * 0.039),
        boxShadow: [
          .new(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const .new(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
