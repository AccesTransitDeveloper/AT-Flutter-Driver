import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import 'app_text.dart';

/// Custom radio button widget with app styling
class AppRadioButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const AppRadioButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimens.radioButtonSize,
              height: AppDimens.radioButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? colors.colorPrimary : colors.colorText,
                  width: AppDimens.borderWidthThick,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: AppDimens.radioButtonInnerSize,
                        height: AppDimens.radioButtonInnerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.colorPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppDimens.paddingS),
            Flexible(
              child: AppText.body(
                text,
                color: isSelected ? colors.colorPrimary : colors.colorText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
