import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

abstract final class AppTheme {
  static final _lightColorScheme = ColorScheme.fromSeed(
    seedColor: const .fromRGBO(0, 61, 55, 1),
  );

  static final _darkColorScheme = ColorScheme.fromSeed(
    seedColor: const .fromRGBO(0, 61, 55, 1),
    brightness: .dark,
  );

  static ThemeData get lightTheme =>
      .new(fontFamily: AppConstants.fontFamily, colorScheme: _lightColorScheme);

  static ThemeData get darkTheme =>
      .new(fontFamily: AppConstants.fontFamily, colorScheme: _darkColorScheme);
}
