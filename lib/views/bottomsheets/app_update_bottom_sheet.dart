import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

/// App update bottom sheet shown on splash when a newer version is available.
class AppUpdateBottomSheet extends StatelessWidget {
  final bool isForceUpdate;
  final VoidCallback onUpdateNow;
  final VoidCallback? onSkipForNow;

  const AppUpdateBottomSheet({
    super.key,
    required this.isForceUpdate,
    required this.onUpdateNow,
    this.onSkipForNow,
  });

  /// Shows the app update bottom sheet (non-dismissible).
  static Future<void> show({
    required BuildContext context,
    required bool isForceUpdate,
    required VoidCallback onUpdateNow,
    VoidCallback? onSkipForNow,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PopScope(
        canPop: false,
        child: AppUpdateBottomSheet(
          isForceUpdate: isForceUpdate,
          onUpdateNow: onUpdateNow,
          onSkipForNow: onSkipForNow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimens.padding),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.colorText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            const AppText.title(
              "We're getting better!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingS),

            // Description
            AppText.body(
              'A new version of the app is available. Please update to continue.',
              textAlign: TextAlign.center,
              color: colors.colorText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppDimens.paddingXL),

            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.colorPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update,
                size: 48,
                color: colors.colorPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.paddingXL),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppFilledButton(
                    text: 'Update Now',
                    onPressed: onUpdateNow,
                  ),
                ),
                if (!isForceUpdate) ...[
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Skip for now',
                      onPressed: onSkipForNow,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
