import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class SubscriptionInfoBottomSheet extends StatefulWidget {
  final String? title;
  final String? price;
  final String? description;
  final bool isOptional;
  final VoidCallback onGoToSubscription;

  const SubscriptionInfoBottomSheet({
    super.key,
    this.title,
    this.price,
    this.description,
    required this.isOptional,
    required this.onGoToSubscription,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? price,
    String? description,
    required bool isOptional,
    required VoidCallback onGoToSubscription,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isOptional,
      enableDrag: isOptional,
      builder: (context) => PopScope(
        canPop: isOptional,
        child: SubscriptionInfoBottomSheet(
          title: title,
          price: price,
          description: description,
          isOptional: isOptional,
          onGoToSubscription: () {
            Navigator.pop(context);
            onGoToSubscription();
          },
        ),
      ),
    );
  }

  @override
  State<SubscriptionInfoBottomSheet> createState() =>
      _SubscriptionInfoBottomSheetState();
}

class _SubscriptionInfoBottomSheetState
    extends State<SubscriptionInfoBottomSheet> {
  bool _isExpanded = false;

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
              // Title
              AppText.title(
                getString(
                    appStr.headingSubscription, 'heading_subscription'),
                fontWeight: FontWeight.w600,
              ),

              const SizedBox(height: AppDimens.paddingS),

              // Description
              AppText.body(
                getString(appStr.descriptionSubscriptionInfo,
                    'description_subscription_info'),
                color: colors.colorTextHint,
              ),

              // Subscription plan name + price
              if (widget.title?.isNotEmpty == true) ...[
                const SizedBox(height: AppDimens.padding),
                Row(
                  children: [
                    Expanded(
                      child: AppText.body(
                        widget.title!,
                        color: colors.colorTextHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.price != null)
                      AppText.body(
                        widget.price!,
                        color: colors.colorTextHint,
                        fontWeight: FontWeight.w600,
                      ),
                  ],
                ),
              ],

              // View Benefits (expandable)
              if (widget.description?.isNotEmpty == true) ...[
                const SizedBox(height: AppDimens.paddingXS),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.body(
                        getString(appStr.buttonViewBenefits,
                            'button_view_benefits'),
                        color: colors.colorSecondary,
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: colors.colorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: AppDimens.paddingS),
                  AppText.caption(
                    widget.description!,
                    color: colors.colorTextHint,
                  ),
                ],
              ],

              const SizedBox(height: AppDimens.padding),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(appStr.buttonGoToSubscription,
                          'button_go_to_subscription'),
                      onPressed: widget.onGoToSubscription,
                    ),
                  ),
                  if (widget.isOptional) ...[
                    const SizedBox(width: AppDimens.paddingS),
                    Expanded(
                      child: AppOutlinedButton(
                        text: getString(
                            appStr.buttonClose, 'button_close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
