import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';

/// Bottom sheet for cancelling a trip with reason selection
class CancelTripBottomSheet extends StatefulWidget {
  final List<String> reasons;
  final String cancellationCharge;
  final bool isCancelTripLoading;
  final ValueChanged<String> onReasonSelected;
  final VoidCallback onDismiss;

  const CancelTripBottomSheet({
    super.key,
    required this.reasons,
    required this.cancellationCharge,
    required this.isCancelTripLoading,
    required this.onReasonSelected,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> reasons,
    required String cancellationCharge,
    required bool isCancelTripLoading,
    required ValueChanged<String> onReasonSelected,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => CancelTripBottomSheet(
        reasons: reasons,
        cancellationCharge: cancellationCharge,
        isCancelTripLoading: isCancelTripLoading,
        onReasonSelected: (reason) {
          Navigator.pop(context);
          onReasonSelected(reason);
        },
        onDismiss: () {
          Navigator.pop(context);
          onDismiss();
        },
      ),
    );
  }

  @override
  State<CancelTripBottomSheet> createState() => _CancelTripBottomSheetState();
}

class _CancelTripBottomSheetState extends State<CancelTripBottomSheet> {
  int _selectedIndex = -1;
  String? _otherReason;

  bool get _isOthersSelected =>
      _selectedIndex >= 0 && _selectedIndex == widget.reasons.length - 1;

  String get _selectedReason {
    if (_selectedIndex < 0) return '';
    if (_isOthersSelected) return (_otherReason ?? '').trim();
    return widget.reasons[_selectedIndex];
  }

  bool get _canSubmit {
    if (_selectedIndex < 0) return false;
    if (_isOthersSelected) return (_otherReason ?? '').trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Lift the whole sheet above the keyboard, then let the reason list scroll
    // inside whatever height is left. Putting the inset inside the scroll view
    // instead only grows the scroll extent — the content stays hidden.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header row with back arrow and title
            Row(
              children: [
                InkWell(
                  onTap: widget.onDismiss,
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.arrow_back,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: Center(
                    child: AppText.title(
                      getString(
                        appStr.headingCancelTrip,
                        'heading_cancel_trip',
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Spacer to balance the back arrow
                const SizedBox(width: 24 + AppDimens.paddingM),
              ],
            ),

            const SizedBox(height: AppDimens.paddingXL),

            // "Why do you want to cancel?" heading
            AppText.title(
              getString(
                appStr.headingWhyDoYouWantToCancel,
                'heading_why_do_you_want_to_cancel',
              ),
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: AppDimens.paddingM),

            // Cancellation charge notice
            if (widget.cancellationCharge.isNotEmpty) ...[
              AppText(
                getString(
                  appStr.descriptionCancellationChargeWillBeApplied,
                  'description_cancellation_charge_will_be_applied',
                ).replaceAll('{{_AMOUNT}}', widget.cancellationCharge),
                color: colors.colorWarning,
              ),
              const SizedBox(height: AppDimens.paddingM),
            ],

            // Reason list with radio buttons
            ...widget.reasons.asMap().entries.map((entry) {
              return _buildReasonItem(colors, entry.key, entry.value);
            }),

            // Other reason text field
            if (_isOthersSelected) ...[
              const SizedBox(height: AppDimens.paddingM),
              AppTextField(
                onChanged: (value) => setState(() => _otherReason = value),
                maxLines: 2,
                hintText: getString(
                  appStr.hintWriteSpecificReason,
                  'hint_write_specific_reason',
                ),
                borderRadius: 12,
                borderColor: colors.colorText.withValues(alpha: 0.2),
              ),
            ],

            const SizedBox(height: AppDimens.paddingXL),

            // Cancel Trip button
            SizedBox(
              width: double.infinity,
              child: AppFilledButton(
                text: getString(
                  appStr.descriptionCancelTrip,
                  'description_cancel_trip',
                ),
                enabled: _canSubmit,
                isLoading: widget.isCancelTripLoading,
                onPressed: () {
                  if (_canSubmit) {
                    widget.onReasonSelected(_selectedReason);
                  }
                },
              ),
            ),

            const SizedBox(height: AppDimens.paddingM),

            // Keep my trip button
            SizedBox(
              width: double.infinity,
              child: AppOutlinedButton(
                text: getString(
                  appStr.buttonKeepMyTrip,
                  'button_keep_my_trip',
                ),
                onPressed: widget.onDismiss,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonItem(AppColorPalette colors, int index, String reason) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? colors.colorPrimary : colors.colorTextHint,
              size: 20,
            ),
            const SizedBox(width: AppDimens.paddingS),
            Expanded(
              child: AppText(
                reason,
                color: isSelected
                    ? colors.colorText
                    : colors.colorText.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
