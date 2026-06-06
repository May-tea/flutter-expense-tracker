import 'package:flutter/material.dart';

import '../../../core/utils/screen_utils.dart';
import '../providers/theme_provider.dart';

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({
    super.key,
    required this.current,
    required this.notifier,
  });

  final ThemeMode current;
  final ThemeModeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    const options = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

    return SafeArea(
      child: Column(
        mainAxisSize: .min,
        spacing: screenWidth * 0.029,
        children: [
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.01,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: .circular(screenWidth * 0.005),
            ),
          ),
          Text(
            'Theme',
            style: .new(fontSize: screenWidth * 0.039, fontWeight: .w600),
          ),
          const Divider(),
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (selected) {
              if (selected != null) {
                notifier.setThemeMode(selected);
                Navigator.pop(context);
              }
            },
            child: Column(
              children: options
                  .map(
                    (mode) => RadioListTile<ThemeMode>(
                      title: Text(_label(mode)),
                      secondary: Icon(_icon(mode)),
                      value: mode,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String _label(ThemeMode mode) => switch (mode) {
  .system => 'System',
  .light => 'Light',
  .dark => 'Dark',
};

IconData _icon(ThemeMode mode) => switch (mode) {
  .system => Icons.brightness_auto,
  .light => Icons.light_mode_outlined,
  .dark => Icons.dark_mode_outlined,
};
