import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class ReferralPolicyBottomSheet extends StatelessWidget {
  final List<String> policy;

  const ReferralPolicyBottomSheet({
    super.key,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.title(
                    getString(
                        appStr.headingReferralPolicy, 'heading_referral_policy'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => context.goBack(),
                  icon: Icon(Icons.close, color: colors.colorText),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingM),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: policy.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimens.paddingM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.body(
                          '${index + 1}.',
                          color: colors.colorText,
                        ),
                        const SizedBox(width: AppDimens.paddingS),
                        Expanded(
                          child: AppText.body(
                            policy[index],
                            color: colors.colorText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimens.padding),
            AppFilledButton(
              text: getString(appStr.buttonClose, 'button_close'),
              onPressed: () => context.goBack(),
            ),
          ],
        ),
      ),
    );
  }
}
