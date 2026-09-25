import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

/// A common toolbar widget used across screens.
///
/// Provides a consistent app bar with:
/// - Back button on left (optional)
/// - Centered or left-aligned title
/// - Optional right action button
class AppToolbar extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final bool showBackButton;
  final IconData backIcon;
  final VoidCallback? onBack;
  final IconData? rightIcon;
  final VoidCallback? onRightIconPressed;
  final Widget? rightWidget;

  const AppToolbar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.showBackButton = true,
    this.backIcon = Icons.arrow_back,
    this.onBack,
    this.rightIcon,
    this.onRightIconPressed,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row - Back button and right action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Back button or empty space
              if (showBackButton)
                IconButton(
                  onPressed: onBack ?? () => context.pop(),
                  icon: Icon(
                    backIcon,
                    color: colors.colorText,
                  ),
                )
              else
                const SizedBox(width: 48),

              // Right side - Icon, custom widget, or empty space for balance
              if (rightWidget != null)
                rightWidget!
              else if (rightIcon != null)
                IconButton(
                  onPressed: onRightIconPressed,
                  icon: Icon(
                    rightIcon,
                    color: colors.colorText,
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),

          // Title below back button
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimens.paddingM,
              top: AppDimens.paddingS,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppTypos.heading,
                fontWeight: FontWeight.bold,
                color: colors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
