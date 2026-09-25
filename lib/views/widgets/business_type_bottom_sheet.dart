import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'app_text.dart';
import 'app_button.dart';

Future<int?> showBusinessTypeBottomSheet(
  BuildContext context,
  List<int> businessTypes,
) {
  return showModalBottomSheet<int>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.paddingL),
      ),
    ),
    builder: (_) => _BusinessTypeSheet(businessTypes: businessTypes),
  );
}

class _BusinessTypeSheet extends StatefulWidget {
  final List<int> businessTypes;
  const _BusinessTypeSheet({required this.businessTypes});

  @override
  State<_BusinessTypeSheet> createState() => _BusinessTypeSheetState();
}

class _BusinessTypeSheetState extends State<_BusinessTypeSheet> {
  int? _selected;

  String _nameFor(int type) {
    switch (type) {
      case BusinessType.taxi:
        return getString(appStr.descriptionTaxi, 'description_taxi');
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
              getString(appStr.headingSelectBusiness, 'heading_select_business'),
            ),
            const SizedBox(height: AppDimens.paddingXL),
            ...widget.businessTypes.map(
              (type) => RadioListTile<int>(
                value: type,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                title: AppText.body(_nameFor(type)),
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
