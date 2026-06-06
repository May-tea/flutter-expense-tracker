import 'package:flutter/material.dart';

import '../../../core/utils/screen_utils.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: .fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.049,
        screenWidth * 0.04,
        screenWidth * 0.01,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}
