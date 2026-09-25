import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class LogoutBottomSheet extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogout;

  const LogoutBottomSheet({
    super.key,
    required this.isLoading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.title(getString(appStr.headingLogout, 'heading_logout')),
            const SizedBox(height: AppDimens.paddingS),
            AppText.body(
              getString(appStr.descriptionLogout, 'description_logout'),
              color: colors.colorText,
            ),
            const SizedBox(height: AppDimens.paddingXL),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: getString(appStr.buttonCancel, 'button_cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: AppFilledButton(
                    text: getString(appStr.buttonLogout, 'button_logout'),
                    isLoading: isLoading,
                    onPressed: () {
                      onLogout();
                      Navigator.pop(context);
                    },
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
