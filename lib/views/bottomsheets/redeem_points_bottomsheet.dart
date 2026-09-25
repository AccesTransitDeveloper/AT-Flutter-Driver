import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/localization/string_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/redeem_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';

class RedeemPointsBottomSheet extends ConsumerStatefulWidget {
  const RedeemPointsBottomSheet({super.key});

  @override
  ConsumerState<RedeemPointsBottomSheet> createState() =>
      _RedeemPointsBottomSheetState();
}

class _RedeemPointsBottomSheetState
    extends ConsumerState<RedeemPointsBottomSheet> {
  final TextEditingController _pointsController = TextEditingController();

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(redeemViewModelProvider);
    final viewModel = ref.read(redeemViewModelProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(
                getString(appStr.headingRedeemPoints, 'heading_redeem_points'),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.paddingXL),

              AppTextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  viewModel.updateWithdrawAmount(value);
                },
                hintText: getString(appStr.hintEnterPoints, 'hint_enter_points'),
              ),
              // Error text
              if (state.withdrawError != null) ...[
                const SizedBox(height: AppDimens.paddingS),
                AppText.caption(
                  state.withdrawError!,
                  color: colors.colorWarning,
                ),
              ],
              const SizedBox(height: AppDimens.paddingS),

              AppText.caption(
                getString(appStr.descriptionEquivalent, 'description_equivalent').replacePlaceholders({
                  StringConstant.value: state.convertedPrice,
                }),
                color: colors.colorText,
              ),
              const SizedBox(height: AppDimens.paddingS),

              AppText.caption(
                getString(appStr.descriptionAvailablePointsValue, 'description_available_points_value').replacePlaceholders({
                  StringConstant.value: state.totalRedeemPoints.toInt().toString(),
                }),
                color: colors.colorText,
              ),
              const SizedBox(height: AppDimens.paddingXL),

              AppFilledButton(
                text: getString(appStr.buttonRedeem, 'button_redeem'),
                isLoading: state.isWithdrawing,
                onPressed: state.withdrawError != null
                    ? null
                    : viewModel.withdrawPoints,
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }
}
