import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/responses/auth/country_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_divider.dart';
import '../../views/widgets/app_text.dart';

/// Bottom sheet for selecting country phone code
class CountryPhoneCodeBottomSheet extends StatelessWidget {
  final List<Country> phoneCodeList;
  final String? selectedPhoneCode;
  final ValueChanged<Country> onPhoneCodeSelected;

  const CountryPhoneCodeBottomSheet({
    super.key,
    required this.phoneCodeList,
    this.selectedPhoneCode,
    required this.onPhoneCodeSelected,
  });

  /// Show the country phone code selection bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<Country> phoneCodeList,
    String? selectedPhoneCode,
    required ValueChanged<Country> onPhoneCodeSelected,
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
      builder: (_) => CountryPhoneCodeBottomSheet(
        phoneCodeList: phoneCodeList,
        selectedPhoneCode: selectedPhoneCode,
        onPhoneCodeSelected: onPhoneCodeSelected,
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
                getString(appStr.headingSelectPhoneCode, 'heading_select_phone_code'),
              ),
            ),
            const AppDivider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: phoneCodeList.length,
                itemBuilder: (context, index) {
                  final country = phoneCodeList[index];
                  final phoneCode = country.displayPhoneCode;
                  final isSelected = phoneCode == selectedPhoneCode;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onPhoneCodeSelected(country);
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
                          Expanded(
                            child: AppText.body(
                              phoneCode,
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
