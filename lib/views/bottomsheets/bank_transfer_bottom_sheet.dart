import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../models/common/tax_data.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_text.dart';
import '../../views/widgets/app_text_field.dart';

/// Bottom sheet for bank transfer with amount input and tax breakdown
class BankTransferBottomSheet extends ConsumerWidget {
  const BankTransferBottomSheet({super.key});

  /// Show the bank transfer bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const BankTransferBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    final isLoading = state.isLoading;
    final showBreakDownDetail = state.showBreakDownDetail;
    final taxList = state.taxList;
    final formattedWalletAmount = state.formattedWalletAmount ?? '0.00';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.title(
              getString(
                  appStr.headingBankTransfer, 'heading_bank_transfer'),
            ),
            const SizedBox(height: AppDimens.paddingS),
            AppText.caption(
              '${getString(appStr.descriptionWallet, 'description_wallet')}: $formattedWalletAmount',
            ),
            const SizedBox(height: AppDimens.paddingM),
            AppTextField(
              hintText: getString(
                  appStr.hintEnterBankTransferAmount, 'hint_enter_bank_transfer_amount'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: viewModel.onBankAmountChange,
            ),
            const SizedBox(height: AppDimens.paddingM),
            if (!showBreakDownDetail)
              SizedBox(
                width: double.infinity,
                child: AppFilledButton(
                  text: getString(
                      appStr.buttonSendToBank, 'button_send_to_bank'),
                  isLoading: isLoading,
                  onPressed: viewModel.onSendMoneyToBank,
                ),
              ),
            if (showBreakDownDetail) ...[
              const Divider(),
              const SizedBox(height: AppDimens.paddingS),
              AppText.body(
                getString(appStr.descriptionTaxBreakdown, 'description_tax_breakdown'),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.paddingS),
              ...taxList.map((tax) => _buildTaxItem(context, tax)),
              const SizedBox(height: AppDimens.paddingM),
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(
                          appStr.buttonConfirm, 'button_confirm'),
                      isLoading: isLoading,
                      onPressed: () {
                        context.goBack();
                        viewModel.onConfirmBankTransfer();
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                          appStr.buttonCancel, 'button_cancel'),
                      onPressed: () {
                        context.goBack();
                        viewModel.dismissBankTransferSheet();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxItem(BuildContext context, TaxData tax) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.body(
                tax.taxName ?? '',
                fontWeight: FontWeight.normal,
              ),
              AppText.body(
                tax.taxAmount ?? '',
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        if (tax.subTaxList != null && tax.subTaxList!.isNotEmpty)
          ...tax.subTaxList!.map((subTax) => Padding(
                padding: const EdgeInsets.only(
                  left: AppDimens.paddingM,
                  top: AppDimens.paddingXS,
                  bottom: AppDimens.paddingXS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.caption(subTax.$1),
                    AppText.caption(subTax.$2),
                  ],
                ),
              )),
        if (tax.showDivider) const Divider(),
      ],
    );
  }
}
