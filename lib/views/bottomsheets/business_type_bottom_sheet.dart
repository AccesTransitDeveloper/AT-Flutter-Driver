import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

/// Shows a bottom sheet for selecting a business type from [businessTypes].
/// Returns the selected [int] type, or null if dismissed.
Future<int?> showBusinessTypeBottomSheet(
  BuildContext context,
  List<int> businessTypes,
) async {
  return showModalBottomSheet<int>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.paddingXL),
      ),
    ),
    builder: (context) =>
        _BusinessTypeBottomSheet(businessTypes: businessTypes),
  );
}

class _BusinessTypeBottomSheet extends StatefulWidget {
  final List<int> businessTypes;

  const _BusinessTypeBottomSheet({required this.businessTypes});

  @override
  State<_BusinessTypeBottomSheet> createState() =>
      _BusinessTypeBottomSheetState();
}

class _BusinessTypeBottomSheetState extends State<_BusinessTypeBottomSheet> {
  int? _selected;

  String _nameForType(int type) {
    switch (type) {
      case BusinessType.taxi:
        return getString(appStr.descriptionTaxi, 'description_taxi');
      case BusinessType.delivery:
        return getString(appStr.descriptionDelivery, 'description_delivery');
      case BusinessType.courier:
        return getString(appStr.descriptionCourier, 'description_courier');
      default:
        return type.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimens.paddingM),
            AppText.heading(
              getString(
                appStr.headingSelectBusiness,
                'heading_select_business',
              ),
            ),
            const SizedBox(height: AppDimens.paddingXL),
            ...widget.businessTypes.map(
              (type) => RadioListTile<int>(
                value: type,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                title: AppText.body(_nameForType(type)),
                activeColor: colors.colorPrimary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppDimens.paddingXL),
            AppFilledButton(
              text: getString(appStr.buttonConfirm, 'button_confirm'),
              onPressed: _selected != null
                  ? () => Navigator.of(context).pop(_selected)
                  : null,
            ),
            const SizedBox(height: AppDimens.paddingM),
          ],
        ),
      ),
    );
  }
}
