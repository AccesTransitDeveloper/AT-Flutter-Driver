import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

/// Prominent disclosure shown BEFORE requesting location permission.
///
/// Required by Google Play's Prominent Disclosure & Consent policy because the
/// app uses ACCESS_BACKGROUND_LOCATION. It must clearly explain that location is
/// collected in the background (even when the app is closed or not in use) and
/// requires an affirmative user action before any permission prompt is shown.
class LocationDisclosureBottomSheet extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onDecline;

  const LocationDisclosureBottomSheet({
    super.key,
    required this.onAgree,
    required this.onDecline,
  });

  /// Shows the disclosure (non-dismissible). Resolves to `true` if the driver
  /// agreed, `false` if they declined.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => PopScope(
        canPop: false,
        child: LocationDisclosureBottomSheet(
          onAgree: () => Navigator.of(sheetContext).pop(true),
          onDecline: () => Navigator.of(sheetContext).pop(false),
        ),
      ),
    );
    return result ?? false;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.colorPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  size: 40,
                  color: colors.colorPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.padding),

            // Title
            const AppText.title(
              'Location Access',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingS),

            // Prominent disclosure body
            AppText.body(
              'AT Driver collects location data to share your live location '
              'with riders and our dispatch system, match you with nearby ride '
              'requests, and provide navigation and trip tracking.\n\n'
              'This location data is collected even when the app is closed or '
              'not in use, so that trips and live tracking keep working while '
              'you are online and on a ride.',
              color: colors.colorText.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppDimens.paddingXL),

            // Buttons
            AppFilledButton(
              text: 'Agree & Continue',
              onPressed: onAgree,
            ),
            const SizedBox(height: AppDimens.paddingM),
            AppOutlinedButton(
              text: 'No Thanks',
              onPressed: onDecline,
            ),
          ],
        ),
      ),
    );
  }
}
