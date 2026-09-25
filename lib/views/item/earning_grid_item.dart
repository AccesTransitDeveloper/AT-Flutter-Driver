import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_text.dart';

class EarningGridItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const EarningGridItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        border: Border.all(color: colors.colorBackgroundGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: AppDimens.paddingS),

          // Value
          AppText(
            value,
            fontSize: AppTypos.textM,
            fontWeight: FontWeight.w700,
            color: colors.colorText,
          ),
          const SizedBox(height: 2),

          // Title
          AppText.caption(
            title,
            color: colors.colorTextHint,
          ),
        ],
      ),
    );
  }
}
