import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';

class ConfirmationCodeBottomSheet extends StatelessWidget {
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onVerify;
  final VoidCallback onDismiss;

  const ConfirmationCodeBottomSheet({
    super.key,
    required this.onCodeChanged,
    required this.onVerify,
    required this.onDismiss,
  });

  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onCodeChanged,
    required VoidCallback onVerify,
    required VoidCallback onDismiss,
  }) {
    if (_isShowing) return Future.value();
    _isShowing = true;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ConfirmationCodeBottomSheet(
        onCodeChanged: onCodeChanged,
        onVerify: () {
          _isShowing = false;
          Navigator.pop(context);
          onVerify();
        },
        onDismiss: () {
          _isShowing = false;
          Navigator.pop(context);
          onDismiss();
        },
      ),
    ).whenComplete(() => _isShowing = false);
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
          padding: EdgeInsets.only(
            left: AppDimens.padding,
            right: AppDimens.padding,
            top: AppDimens.padding,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.padding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(
                getString(
                  appStr.headingConfirmationCode,
                  'heading_confirmation_code',
                ),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.paddingM),
              AppTextField(
                hintText: getString(
                  appStr.hintEnterConfirmationCode,
                  'hint_enter_confirmation_code',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: onCodeChanged,
              ),
              const SizedBox(height: AppDimens.padding),
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(
                        appStr.buttonVerifyCode,
                        'button_verify_code',
                      ),
                      onPressed: onVerify,
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
