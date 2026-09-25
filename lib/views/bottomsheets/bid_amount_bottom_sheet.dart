import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';

class BidAmountBottomSheet extends StatelessWidget {
  final String? errorMessage;
  final bool canAcceptBid;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const BidAmountBottomSheet({
    super.key,
    this.errorMessage,
    required this.canAcceptBid,
    required this.onAmountChanged,
    required this.onAccept,
    required this.onCancel,
  });

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
                  appStr.headingBiddingAmount,
                  'heading_bidding_amount',
                ),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.paddingS),
              AppTextField(
                hintText: getString(
                  appStr.hintEnterBidAmount,
                  'hint_enter_bid_amount',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: onAmountChanged,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppDimens.paddingXS),
                AppText.caption(
                  errorMessage!,
                  color: Colors.red,
                ),
              ],
              const SizedBox(height: AppDimens.padding),
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(
                        appStr.buttonAccept,
                        'button_accept',
                      ),
                      onPressed: canAcceptBid ? onAccept : null,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                        appStr.buttonCancel,
                        'button_cancel',
                      ),
                      onPressed: onCancel,
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
