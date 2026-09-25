import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/responses/payment/card_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_text.dart';

/// Reusable card item widget for displaying payment cards
class CardItem extends StatelessWidget {
  final CardResponse card;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const CardItem({
    super.key,
    required this.card,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = false,
  });

  /// Get display name for the card
  String get _displayName {
    if (card.cardName != null && card.cardName!.isNotEmpty) {
      return card.cardName!;
    }

    // Fallback to lastFour if cardName is not set
    final lastFour = card.lastFour;
    if (lastFour != null && lastFour.isNotEmpty) {
      return '**** $lastFour';
    }

    return getString(appStr.descriptionCard, 'description_card');
  }

  IconData get _paymentIcon {
    switch (card.paymentGatewayType) {
      case 0: // Cash
        return Icons.money;
      case 1: // Wallet
        return Icons.account_balance_wallet;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = card.isEnable ?? true;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimens.textFieldRadius),
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding,
            vertical: AppDimens.paddingM,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.colorPrimary
                : colors.colorBackgroundGray,
            borderRadius: BorderRadius.circular(AppDimens.textFieldRadius),
          ),
          child: Row(
            children: [
              // Card name
              Expanded(
                child: AppText.body(
                  _displayName,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? colors.colorSelectedText
                      : colors.colorText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Delete button or card icon
              if (showDeleteButton && onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: isSelected
                        ? colors.colorSelectedText
                        : colors.colorText,
                    size: AppDimens.iconSizeSmall,
                  ),
                )
              else
                Icon(
                  _paymentIcon,
                  color: isSelected
                      ? colors.colorSelectedText
                      : colors.colorText,
                  size: AppDimens.iconSizeSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
