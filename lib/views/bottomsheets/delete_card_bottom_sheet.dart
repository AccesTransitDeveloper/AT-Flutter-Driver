import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/localization/string_constants.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_text.dart';

/// Bottom sheet for confirming card deletion
class DeleteCardBottomSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final String? cardName;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DeleteCardBottomSheet({
    super.key,
    this.title,
    this.message,
    this.cardName,
    required this.isLoading,
    required this.onCancel,
    required this.onConfirm,
  });

  /// Show the delete card confirmation bottom sheet
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    String? cardName,
    required bool isLoading,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
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
      builder: (_) => DeleteCardBottomSheet(
        title: title,
        message: message,
        cardName: cardName,
        isLoading: isLoading,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.title(
              title ??
                  getString(appStr.headingDeleteCard, 'heading_delete_card'),
            ),
            const SizedBox(height: AppDimens.paddingM),
            AppText.body(
              message ??
                  getString(appStr.descriptionDeleteCardMessage,
                          'description_delete_card_message')
                      .replacePlaceholders(
                          {StringConstant.cardNumber: cardName ?? ''}),
              fontWeight: FontWeight.normal,
            ),
            const SizedBox(height: AppDimens.paddingXL),
            Row(
              children: [
                Expanded(
                  child: AppFilledButton(
                    text: getString(appStr.buttonConfirm, 'button_confirm'),
                    isLoading: isLoading,
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: AppOutlinedButton(
                    text: getString(appStr.buttonCancel, 'button_cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
