import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class CallOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onCallUser;
  final VoidCallback onCallSupport;

  const CallOptionsBottomSheet({
    super.key,
    required this.onCallUser,
    required this.onCallSupport,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCallUser,
    required VoidCallback onCallSupport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CallOptionsBottomSheet(
        onCallUser: () {
          Navigator.pop(context);
          onCallUser();
        },
        onCallSupport: () {
          Navigator.pop(context);
          onCallSupport();
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
                  appStr.headingCallUserSupport,
                  'heading_call_user_support',
                ),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.padding),
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(
                        appStr.buttonCallUser,
                        'button_call_user',
                      ),
                      onPressed: onCallUser,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                        appStr.buttonCallSupport,
                        'button_call_support',
                      ),
                      onPressed: onCallSupport,
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
