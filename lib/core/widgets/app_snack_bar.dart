import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required bool isError,
    required String message,
  }) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: .floating,
        margin: .symmetric(
          horizontal: screenWidth * 0.049,
          vertical: screenWidth * 0.029,
        ),
        padding: .symmetric(
          horizontal: screenWidth * 0.039,
          vertical: screenWidth * 0.034,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(screenWidth * 0.034),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        duration: const .new(milliseconds: 3000),
        content: Row(
          spacing: screenWidth * 0.029,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? colorScheme.onError : colorScheme.onPrimary,
            ),
            Expanded(
              child: Text(
                message,
                style: .new(
                  color: isError ? colorScheme.onError : colorScheme.onPrimary,
                  fontWeight: .bold,
                  fontSize: screenWidth * 0.034,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
