import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/responses/payment/payment_gateway_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_text.dart';

/// Bottom sheet for selecting payment gateway
class GatewaySelectionBottomSheet extends StatelessWidget {
  final List<PaymentGateway> gatewayList;
  final PaymentGateway? selectedGateway;
  final ValueChanged<PaymentGateway> onGatewaySelected;

  const GatewaySelectionBottomSheet({
    super.key,
    required this.gatewayList,
    this.selectedGateway,
    required this.onGatewaySelected,
  });

  /// Show the gateway selection bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<PaymentGateway> gatewayList,
    PaymentGateway? selectedGateway,
    required ValueChanged<PaymentGateway> onGatewaySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => GatewaySelectionBottomSheet(
        gatewayList: gatewayList,
        selectedGateway: selectedGateway,
        onGatewaySelected: onGatewaySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: AppText.title(
                getString(appStr.headingSelectPaymentGateway,
                    'heading_select_payment_gateway'),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: gatewayList.length,
                itemBuilder: (context, index) {
                  final gateway = gatewayList[index];
                  final isSelected = gateway.type == selectedGateway?.type;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onGatewaySelected(gateway);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding,
                        vertical: AppDimens.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.colorPrimary.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: isSelected
                                ? colors.colorPrimary
                                : colors.colorText,
                            size: AppDimens.iconSize,
                          ),
                          const SizedBox(width: AppDimens.paddingM),
                          Expanded(
                            child: AppText.body(
                              gateway.name ?? '',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? colors.colorPrimary
                                  : colors.colorText,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: colors.colorPrimary,
                              size: AppDimens.iconSizeSmall,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
