import 'package:flutter/material.dart';

import '../utils/screen_utils.dart';
import 'app_loading_indicator.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: () {
        if (isLoading) return;
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        minimumSize: .fromHeight(screenWidth * 0.12),
      ),
      child: isLoading
          ? AppLoadingIndicator(
              size: screenWidth * 0.049,
              strokeWidth: screenWidth * 0.006,
              color: colorScheme.onPrimary,
            )
          : Text(label, style: .new(color: colorScheme.onPrimary)),
    );
  }
}
