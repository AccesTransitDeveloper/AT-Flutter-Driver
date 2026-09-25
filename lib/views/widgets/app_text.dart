import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  /// Heading style - large bold text
  const AppText.heading(
    this.text, {
    super.key,
    this.color,
    this.fontSize = AppTypos.heading,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  /// Title style - medium bold text
  const AppText.title(
    this.text, {
    super.key,
    this.color,
    this.fontSize = AppTypos.textXL,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  /// Body style - regular text
  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.fontSize = AppTypos.text,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  /// Caption style - small text
  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.fontSize = AppTypos.textS,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Text(
      text,
      style: TextStyle(
        color: color ?? colors.colorText,
        fontSize: fontSize ?? AppTypos.text,
        fontWeight: fontWeight,
        decoration: decoration,
        height: height,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
