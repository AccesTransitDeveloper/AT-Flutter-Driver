import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String alertMessage;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const ConfirmationBottomSheet({
    super.key,
    required this.alertMessage,
    required this.onConfirm,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String alertMessage,
    required VoidCallback onConfirm,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmationBottomSheet(
        alertMessage: alertMessage,
        onConfirm: () {
          Navigator.pop(context);
          onConfirm();
        },
        onDismiss: () {
          Navigator.pop(context);
          onDismiss();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.paddingL),
          topRight: Radius.circular(AppDimens.paddingL),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(
                getString(
                  appStr.headingConfirmation,
                  'heading_confirmation',
                ),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.padding),
              AppText.body(
                alertMessage,
                color: colors.colorTextHint,
              ),
              const SizedBox(height: AppDimens.padding),
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(
                        appStr.buttonConfirm,
                        'button_confirm',
                      ),
                      onPressed: onConfirm,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                        appStr.buttonCancel,
                        'button_cancel',
                      ),
                      onPressed: onDismiss,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
