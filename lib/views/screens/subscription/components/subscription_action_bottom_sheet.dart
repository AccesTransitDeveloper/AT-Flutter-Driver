import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

class SubscriptionActionBottomSheet extends StatelessWidget {
  final VoidCallback onYesClick;
  final VoidCallback onCloseClick;

  const SubscriptionActionBottomSheet({
    super.key,
    required this.onYesClick,
    required this.onCloseClick,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onYesClick,
    required VoidCallback onCloseClick,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => SubscriptionActionBottomSheet(
        onYesClick: onYesClick,
        onCloseClick: onCloseClick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AppText.title(
              getString(appStr.headingConfirmation, 'heading_confirmation'),
            ),
            const SizedBox(height: 10),

            // Description (static text like Kotlin)
            AppText.body(
              getString(appStr.descriptionActionSubscription ?? '',
                  'description_action_subscription'),
              color: context.colors.colorTextHint,
            ),
            const SizedBox(height: AppDimens.padding),

            // Buttons in horizontal row (matching Kotlin layout)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: AppFilledButton(
                      text: getString(
                          appStr.buttonYesSure ?? '', 'button_yes_sure'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onYesClick();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: AppOutlinedButton(
                      text: getString(appStr.buttonClose, 'button_close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCloseClick();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
