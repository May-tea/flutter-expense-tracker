import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            spacing: screenWidth * 0.01,
            children: [
              Text(
                'Welcome',
                style: .new(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              Text(
                'Mariya',
                style: .new(fontSize: screenWidth * 0.06, fontWeight: .w700),
              ),
            ],
          ),
        ),
        Row(
          spacing: screenWidth * 0.04,
          children: [
            const _HeaderIconButton(icon: Icons.notifications_outlined),
            CircleAvatar(
              radius: screenWidth * 0.06,
              child: Icon(Icons.person, size: screenWidth * 0.06),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: .all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: .circle,
      ),
      child: Icon(icon),
    );
  }
}
