import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required bool isError,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: .floating,
        margin: .symmetric(
          horizontal: screenWidth * 0.049,
          vertical: screenWidth * 0.07,
        ),
        padding: .symmetric(
          horizontal: screenWidth * 0.039,
          vertical: screenWidth * 0.044,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(screenWidth * 0.034),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        duration: const .new(seconds: 3),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? colorScheme.onError : colorScheme.onPrimary,
            ),
            SizedBox(width: screenWidth * 0.029),
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
            if (actionLabel != null)
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: .symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isError ? colorScheme.onError : colorScheme.onPrimary)
                            .withValues(alpha: 0.15),
                    borderRadius: .circular(screenWidth * 0.03),
                  ),
                  child: Text(
                    actionLabel,
                    style: .new(
                      color: isError
                          ? colorScheme.onError
                          : colorScheme.onPrimary,
                      fontWeight: .w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      snackBarAnimationStyle: const .new(
        duration: .new(milliseconds: 800),
        reverseDuration: .new(milliseconds: 1000),
      ),
    );
  }
}
