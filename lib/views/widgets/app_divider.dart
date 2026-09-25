import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

/// Divider with centered text (like "or" separator)
class AppDivider extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? thickness;
  final double? textPadding;
  final TextStyle? textStyle;

  const AppDivider({
    super.key,
    this.text,
    this.color,
    this.thickness,
    this.textPadding,
    this.textStyle,
  });

  /// Creates a divider with "or" text
  const AppDivider.or({
    super.key,
    this.color,
    this.thickness,
    this.textPadding,
    this.textStyle,
  }) : text = 'or';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dividerColor = color ?? colors.colorBackgroundGray;
    final dividerThickness = thickness ?? AppDimens.borderWidth;

    if (text == null || text!.isEmpty) {
      return Divider(
        color: dividerColor,
        thickness: dividerThickness,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: dividerThickness,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: textPadding ?? AppDimens.padding,
          ),
          child: Text(
            text!,
            style: textStyle ??
                TextStyle(
                  fontSize: AppTypos.text,
                  color: colors.colorText.withValues(alpha: 0.6),
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: dividerThickness,
          ),
        ),
      ],
    );
  }
}
