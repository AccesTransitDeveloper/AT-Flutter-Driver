import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/responses/payment/card_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_text.dart';
import '../../views/widgets/app_text_field.dart';
import '../item/card_item.dart';

/// Bottom sheet for adding wallet amount
class AddWalletAmountBottomSheet extends StatefulWidget {
  final List<CardResponse> cardsList;
  final CardResponse? selectedCard;
  final bool isLoading;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<CardResponse> onCardSelected;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const AddWalletAmountBottomSheet({
    super.key,
    required this.cardsList,
    this.selectedCard,
    required this.isLoading,
    required this.onAmountChanged,
    required this.onCardSelected,
    required this.onSubmit,
    required this.onCancel,
  });

  /// Show the add wallet amount bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<CardResponse> cardsList,
    CardResponse? selectedCard,
    required bool isLoading,
    required ValueChanged<String> onAmountChanged,
    required ValueChanged<CardResponse> onCardSelected,
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
      builder: (_) => AddWalletAmountBottomSheet(
        cardsList: cardsList,
        selectedCard: selectedCard,
        isLoading: isLoading,
        onAmountChanged: onAmountChanged,
        onCardSelected: onCardSelected,
        onSubmit: onSubmit,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<AddWalletAmountBottomSheet> createState() =>
      _AddWalletAmountBottomSheetState();
}

class _AddWalletAmountBottomSheetState
    extends State<AddWalletAmountBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  CardResponse? _selectedCard;

  @override
  void initState() {
    super.initState();
    _selectedCard = widget.selectedCard ?? widget.cardsList.firstOrNull;
    if (_selectedCard != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCardSelected(_selectedCard!);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Title
              AppText.title(
                getString(
                    appStr.headingAddWalletAmount, 'heading_add_wallet_amount'),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppDimens.paddingXL),

              AppTextField(
                controller: _amountController,
                hintText:
                    getString(appStr.hintEnterAmount, 'hint_enter_amount'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: widget.onAmountChanged,
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Card selection list
              if (widget.cardsList.isNotEmpty) ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.cardsList.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.paddingS),
                  itemBuilder: (context, index) {
                    final card = widget.cardsList[index];
                    final isSelected = _selectedCard?.id == card.id;
                    return CardItem(
                      card: card,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedCard = card);
                        widget.onCardSelected(card);
                      },
                    );
                  },
                ),
                const SizedBox(height: AppDimens.paddingXL),
              ],

              // Add and Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(appStr.buttonAdd, 'button_add'),
                      isLoading: widget.isLoading,
                      onPressed: widget.onSubmit,
                    ),
                  ),
                  const SizedBox(width: AppDimens.padding),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(appStr.buttonCancel, 'button_cancel'),
                      onPressed: widget.onCancel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }
}
