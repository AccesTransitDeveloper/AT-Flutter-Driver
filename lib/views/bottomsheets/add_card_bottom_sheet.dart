import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/payments/payment_interface.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/responses/payment/payment_gateway_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_radio_button.dart';
import '../../views/widgets/app_text.dart';
import '../../views/widgets/app_text_field.dart';

/// Bottom sheet for adding a new card
class AddCardBottomSheet extends StatefulWidget {
  final List<PaymentGateway> gatewayList;
  final PaymentGateway? selectedGateway;
  final bool isLoading;
  final ValueChanged<PaymentGateway> onGatewaySelected;
  final ValueChanged<CardDetails> onCardDetailsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const AddCardBottomSheet({
    super.key,
    required this.gatewayList,
    this.selectedGateway,
    required this.isLoading,
    required this.onGatewaySelected,
    required this.onCardDetailsChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  /// Show the add card bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<PaymentGateway> gatewayList,
    PaymentGateway? selectedGateway,
    required bool isLoading,
    required ValueChanged<PaymentGateway> onGatewaySelected,
    required ValueChanged<CardDetails> onCardDetailsChanged,
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
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
      builder: (_) => AddCardBottomSheet(
        gatewayList: gatewayList,
        selectedGateway: selectedGateway,
        isLoading: isLoading,
        onGatewaySelected: onGatewaySelected,
        onCardDetailsChanged: onCardDetailsChanged,
        onSubmit: onSubmit,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  PaymentGateway? _selectedGateway;

  @override
  void initState() {
    super.initState();
    _selectedGateway = widget.selectedGateway ?? widget.gatewayList.firstOrNull;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _notifyCardDetailsChanged() {
    widget.onCardDetailsChanged(CardDetails(
      name: _nameController.text,
      cardNumber: _cardNumberController.text.replaceAll('-', ''),
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
    ));
  }

  /// Check if selected gateway is Stripe (shows card input fields)
  bool get _isStripeSelected =>
      _selectedGateway?.type == PaymentGatewayType.stripe.value;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                AppText.title(
                  getString(
                      appStr.headingAddCardDetails, 'heading_add_card_details'),
                  fontWeight: FontWeight.w600,
                ),

                // Gateway selection with radio buttons
                if (widget.gatewayList.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.paddingM),
                  Row(
                    children: widget.gatewayList.map((gateway) {
                      final isSelected =
                          _selectedGateway?.type == gateway.type;
                      return Expanded(
                        child: AppRadioButton(
                          text: gateway.name ?? '',
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedGateway = gateway);
                            widget.onGatewaySelected(gateway);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Card input fields (only show for Stripe)
                if (_isStripeSelected) ...[
                  const SizedBox(height: AppDimens.paddingM),

                  // Card holder name
                  AppTextField(
                    controller: _nameController,
                    hintText: getString(
                        appStr.hintCardHolderName, 'hint_card_holder_name'),
                    onChanged: (_) => _notifyCardDetailsChanged(),
                  ),
                  const SizedBox(height: AppDimens.padding),

                  // Card number
                  AppTextField(
                    controller: _cardNumberController,
                    hintText:
                        getString(appStr.hintCardNumber, 'hint_card_number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      _CardNumberFormatter(),
                    ],
                    onChanged: (_) => _notifyCardDetailsChanged(),
                  ),
                  const SizedBox(height: AppDimens.padding),

                  // Expiry and CVV row
                  Row(
                    children: [
                      // Expiry date
                      Expanded(
                        child: AppTextField(
                          controller: _expiryController,
                          hintText: getString(
                              appStr.hintExpiryDate, 'hint_expiry_date'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryDateFormatter(),
                          ],
                          onChanged: (_) => _notifyCardDetailsChanged(),
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingM),
                      // CVV
                      Expanded(
                        child: AppTextField(
                          controller: _cvvController,
                          hintText: getString(appStr.hintCvv, 'hint_cvv'),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => _notifyCardDetailsChanged(),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppDimens.padding),

                // Add and Cancel buttons row
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: AppDimens.paddingXS),
                        child: AppFilledButton(
                          text: getString(appStr.buttonAdd, 'button_add'),
                          isLoading: widget.isLoading,
                          onPressed: widget.onSubmit,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: AppDimens.paddingXS),
                        child: AppOutlinedButton(
                          text:
                              getString(appStr.buttonCancel, 'button_cancel'),
                          onPressed: widget.onCancel,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingS),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card number formatter (XXXX-XXXX-XXXX-XXXX)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Expiry date formatter (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
