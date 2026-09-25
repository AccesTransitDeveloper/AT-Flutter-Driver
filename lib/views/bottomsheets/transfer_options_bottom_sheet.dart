import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_text.dart';

/// Bottom sheet for selecting transfer option (Customer/Driver/Bank)
class TransferOptionsBottomSheet extends StatefulWidget {
  final List<String> options;
  final int selectedOption;
  final VoidCallback onCancel;
  final ValueChanged<int> onOptionSelected;
  final VoidCallback onNext;

  const TransferOptionsBottomSheet({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onCancel,
    required this.onOptionSelected,
    required this.onNext,
  });

  /// Show the transfer options bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<String> options,
    required int selectedOption,
    required VoidCallback onCancel,
    required ValueChanged<int> onOptionSelected,
    required VoidCallback onNext,
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
      builder: (_) => TransferOptionsBottomSheet(
        options: options,
        selectedOption: selectedOption,
        onCancel: onCancel,
        onOptionSelected: onOptionSelected,
        onNext: onNext,
      ),
    );
  }

  @override
  State<TransferOptionsBottomSheet> createState() =>
      _TransferOptionsBottomSheetState();
}

class _TransferOptionsBottomSheetState
    extends State<TransferOptionsBottomSheet> {
  late int _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
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
              getString(appStr.headingTransferOptions,
                  'heading_transfer_options'),
            ),
            const SizedBox(height: AppDimens.paddingM),
            ...List.generate(widget.options.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() => _selectedOption = value ?? -1);
                  widget.onOptionSelected(value ?? -1);
                },
                title: AppText.body(widget.options[index]),
                activeColor: context.colors.colorPrimary,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: AppDimens.paddingM),
            Row(
              children: [
                Expanded(
                  child: AppFilledButton(
                    text: getString(appStr.buttonNext, 'button_next'),
                    onPressed: () {
                      context.goBack();
                      widget.onNext();
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: AppOutlinedButton(
                    text: getString(appStr.buttonCancel, 'button_cancel'),
                    onPressed: () {
                      context.goBack();
                      widget.onCancel();
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
