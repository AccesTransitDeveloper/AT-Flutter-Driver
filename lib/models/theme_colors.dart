import 'package:json_annotation/json_annotation.dart';

part 'theme_colors.g.dart';

@JsonSerializable()
class ThemeColors {
  final String? colorBackground;
  final String? colorPrimary;
  final String? colorSecondary;
  final String? colorTertiary;
  final String? colorWarning;
  final String? colorText;
  final String? colorTextGray;
  final String? colorSelectedText;
  final String? colorButtonText;
  final String? colorButtonBackground;

  ThemeColors({
    this.colorBackground,
    this.colorPrimary,
    this.colorSecondary,
    this.colorTertiary,
    this.colorWarning,
    this.colorText,
    this.colorTextGray,
    this.colorSelectedText,
    this.colorButtonText,
    this.colorButtonBackground,
  });

  factory ThemeColors.fromJson(Map<String, dynamic> json) =>
      _$ThemeColorsFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeColorsToJson(this);

  ThemeColors copyWith({
    String? colorBackground,
    String? colorPrimary,
    String? colorSecondary,
    String? colorTertiary,
    String? colorWarning,
    String? colorText,
    String? colorTextGray,
    String? colorSelectedText,
    String? colorButtonText,
    String? colorButtonBackground,
  }) {
    return ThemeColors(
      colorBackground: colorBackground ?? this.colorBackground,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorSecondary: colorSecondary ?? this.colorSecondary,
      colorTertiary: colorTertiary ?? this.colorTertiary,
      colorWarning: colorWarning ?? this.colorWarning,
      colorText: colorText ?? this.colorText,
      colorTextGray: colorTextGray ?? this.colorTextGray,
      colorSelectedText: colorSelectedText ?? this.colorSelectedText,
      colorButtonText: colorButtonText ?? this.colorButtonText,
      colorButtonBackground:
          colorButtonBackground ?? this.colorButtonBackground,
    );
  }
}
