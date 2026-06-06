class SettingsState {
  const SettingsState({
    required this.darkMode,
    required this.useSystemTheme,
    required this.notificationsEnabled,
  });

  final bool darkMode;
  final bool useSystemTheme;
  final bool notificationsEnabled;

  SettingsState copyWith({
    bool? darkMode,
    bool? useSystemTheme,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
