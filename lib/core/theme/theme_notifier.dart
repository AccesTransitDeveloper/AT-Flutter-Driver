import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/theme_colors.dart';
import 'app_theme.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode mode;
  final ThemeColors? lightColors;
  final ThemeColors? darkColors;

  ThemeState({
    this.mode = AppThemeMode.system,
    this.lightColors,
    this.darkColors,
  });

  ThemeState copyWith({
    AppThemeMode? mode,
    ThemeColors? lightColors,
    ThemeColors? darkColors,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      lightColors: lightColors ?? this.lightColors,
      darkColors: darkColors ?? this.darkColors,
    );
  }

  ThemeData getLightTheme() {
    if (lightColors != null) {
      return AppTheme.generateTheme(lightColors!, false);
    }
    return AppTheme.defaultLightTheme;
  }

  ThemeData getDarkTheme() {
    if (darkColors != null) {
      return AppTheme.generateTheme(darkColors!, true);
    }
    return AppTheme.defaultDarkTheme;
  }

  ThemeMode get materialThemeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setLightColors(ThemeColors colors) {
    state = state.copyWith(lightColors: colors);
  }

  void setDarkColors(ThemeColors colors) {
    state = state.copyWith(darkColors: colors);
  }

  void updateThemeColors({
    ThemeColors? lightColors,
    ThemeColors? darkColors,
  }) {
    state = state.copyWith(
      lightColors: lightColors,
      darkColors: darkColors,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
