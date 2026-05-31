import 'package:flutter/material.dart';

import '../utils/screen_utils.dart';

abstract final class AppInputDecoration {
  static InputDecoration build(
    BuildContext context, {
    required String label,
    Widget? suffixIcon,
  }) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: .circular(screenWidth * 0.024),
    );

    return InputDecoration(
      label: Text(
        label,
        style: .new(
          fontSize: screenWidth * 0.035,
          color: colorScheme.secondary,
        ),
      ),
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      enabledBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.25),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.25),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
