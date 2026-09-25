import 'package:flutter/material.dart';
import '../../models/theme_colors.dart';

/// Color palette with parsed Color objects
class AppColorPalette {
  final Color colorBackground;
  final Color colorPrimary;
  final Color colorSecondary;
  final Color colorTertiary;
  final Color colorWarning;
  final Color colorText;
  final Color colorSelectedText;
  final Color colorButtonText;
  final Color colorButtonBackground;
  final Color colorBackgroundGray;

  const AppColorPalette({
    required this.colorBackground,
    required this.colorPrimary,
    required this.colorSecondary,
    required this.colorTertiary,
    required this.colorWarning,
    required this.colorText,
    required this.colorSelectedText,
    required this.colorButtonText,
    required this.colorButtonBackground,
    required this.colorBackgroundGray,
  });

  /// Hint text color derived from colorText with 50% opacity
  Color get colorTextHint => colorText.withValues(alpha: 0.5);
}

/// Default palettes
class AppPalettes {
  static const light = AppColorPalette(
    colorBackground: Color(0xFFFFFFFF),
    colorPrimary: Color(0xFF6200EE),
    colorSecondary: Color(0xFF03DAC5),
    colorTertiary: Color(0xFF018786),
    colorWarning: Color(0xFFFF9800),
    colorText: Color(0xFF000000),
    colorSelectedText: Color(0xFFFFFFFF),
    colorButtonText: Color(0xFFFFFFFF),
    colorButtonBackground: Color(0xFF6200EE),
    colorBackgroundGray: Color(0xFFF3F3F3),
  );

  static const dark = AppColorPalette(
    colorBackground: Color(0xFF121212),
    colorPrimary: Color(0xFFBB86FC),
    colorSecondary: Color(0xFF03DAC6),
    colorTertiary: Color(0xFFCF6679),
    colorWarning: Color(0xFFFF9800),
    colorText: Color(0xFFFFFFFF),
    colorSelectedText: Color(0xFFFFFFFF),
    colorButtonText: Color(0xFFFFFFFF),
    colorButtonBackground: Color(0xFFBB86FC),
    colorBackgroundGray: Color(0xFF292929),
  );
}

/// ThemeExtension to hold AppColorPalette
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final AppColorPalette palette;

  const AppThemeColors({required this.palette});

  @override
  AppThemeColors copyWith({AppColorPalette? palette}) {
    return AppThemeColors(palette: palette ?? this.palette);
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return this;
  }
}

/// Extension for easy access: context.colors.colorButtonBackground
extension AppColorsX on BuildContext {
  AppColorPalette get colors =>
      Theme.of(this).extension<AppThemeColors>()!.palette;
}

/// Main theme class
class AppTheme {
  static Color _parseColor(String? colorString, Color defaultColor) {
    if (colorString == null || colorString.isEmpty) {
      return defaultColor;
    }

    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  /// Parse ThemeColors (strings) to AppColorPalette (Colors)
  static AppColorPalette _createPalette(ThemeColors themeColors, bool isDark) {
    final defaults = isDark ? AppPalettes.dark : AppPalettes.light;

    return AppColorPalette(
      colorBackground: _parseColor(themeColors.colorBackground, defaults.colorBackground),
      colorPrimary: _parseColor(themeColors.colorPrimary, defaults.colorPrimary),
      colorSecondary: _parseColor(themeColors.colorSecondary, defaults.colorSecondary),
      colorTertiary: _parseColor(themeColors.colorTertiary, defaults.colorTertiary),
      colorWarning: _parseColor(themeColors.colorWarning, defaults.colorWarning),
      colorText: _parseColor(themeColors.colorText, defaults.colorText),
      colorSelectedText: _parseColor(themeColors.colorSelectedText, defaults.colorSelectedText),
      colorButtonText: _parseColor(themeColors.colorButtonText, defaults.colorButtonText),
      colorButtonBackground: _parseColor(themeColors.colorButtonBackground, defaults.colorButtonBackground),
      colorBackgroundGray: defaults.colorBackgroundGray,
    );
  }

  static ThemeData generateTheme(ThemeColors themeColors, bool isDark) {
    final palette = _createPalette(themeColors, isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: palette.colorBackground,
      extensions: [
        AppThemeColors(palette: palette),
      ],
    );
  }

  static ThemeData get defaultLightTheme {
    return generateTheme(ThemeColors(), false);
  }

  static ThemeData get defaultDarkTheme {
    return generateTheme(ThemeColors(), true);
  }
}
