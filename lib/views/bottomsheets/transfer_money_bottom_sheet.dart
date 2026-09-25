import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/api/server_config.dart';
import '../../models/responses/payment/search_user_response.dart';
import '../../core/theme/app_theme.dart';
import '../../views/widgets/app_button.dart';
import '../../views/widgets/app_radio_button.dart';
import '../../views/widgets/app_text.dart';
import '../../views/widgets/app_text_field.dart';

/// Simple model for user type dropdown selection
class DropDownModel {
  final String name;
  final int type;

  const DropDownModel({required this.name, required this.type});
}

/// Bottom sheet for transferring money to another user
class TransferMoneyBottomSheet extends StatefulWidget {
  final List<DropDownModel> userMenuList;
  final DropDownModel? selectedUserMenu;
  final String countryPhoneCode;
  final SearchUser? selectedUser;
  final bool isLoading;
  final bool isShowSendMoneyButton;
  final bool isShowNoDataFound;
  final String? formattedWalletAmount;
  final ValueChanged<DropDownModel> onUserMenuSelected;
  final VoidCallback onCountryCodeTap;
  final ValueChanged<String> onPhoneNumberChanged;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSearchUser;
  final VoidCallback onSendMoney;

  const TransferMoneyBottomSheet({
    super.key,
    required this.userMenuList,
    this.selectedUserMenu,
    required this.countryPhoneCode,
    this.selectedUser,
    required this.isLoading,
    required this.isShowSendMoneyButton,
    required this.isShowNoDataFound,
    this.formattedWalletAmount,
    required this.onUserMenuSelected,
    required this.onCountryCodeTap,
    required this.onPhoneNumberChanged,
    required this.onAmountChanged,
    required this.onSearchUser,
    required this.onSendMoney,
  });

  /// Show the transfer money bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<DropDownModel> userMenuList,
    DropDownModel? selectedUserMenu,
    required String countryPhoneCode,
    SearchUser? selectedUser,
    required bool isLoading,
    required bool isShowSendMoneyButton,
    required bool isShowNoDataFound,
    String? formattedWalletAmount,
    required ValueChanged<DropDownModel> onUserMenuSelected,
    required VoidCallback onCountryCodeTap,
    required ValueChanged<String> onPhoneNumberChanged,
    required ValueChanged<String> onAmountChanged,
    required VoidCallback onSearchUser,
    required VoidCallback onSendMoney,
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
      builder: (_) => TransferMoneyBottomSheet(
        userMenuList: userMenuList,
        selectedUserMenu: selectedUserMenu,
        countryPhoneCode: countryPhoneCode,
        selectedUser: selectedUser,
        isLoading: isLoading,
        isShowSendMoneyButton: isShowSendMoneyButton,
        isShowNoDataFound: isShowNoDataFound,
        formattedWalletAmount: formattedWalletAmount,
        onUserMenuSelected: onUserMenuSelected,
        onCountryCodeTap: onCountryCodeTap,
        onPhoneNumberChanged: onPhoneNumberChanged,
        onAmountChanged: onAmountChanged,
        onSearchUser: onSearchUser,
        onSendMoney: onSendMoney,
      ),
    );
  }

  @override
  State<TransferMoneyBottomSheet> createState() =>
      _TransferMoneyBottomSheetState();
}

class _TransferMoneyBottomSheetState extends State<TransferMoneyBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DropDownModel? _selectedUserMenu;

  @override
  void initState() {
    super.initState();
    _selectedUserMenu =
        widget.selectedUserMenu ?? widget.userMenuList.firstOrNull;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                  getString(appStr.headingSendMoney, 'heading_send_money'),
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppDimens.paddingXL),

                // User type selection - Radio buttons
                if (widget.userMenuList.isNotEmpty) ...[
                  Row(
                    children: widget.userMenuList.map((menu) {
                      final isSelected = _selectedUserMenu?.type == menu.type;
                      return Expanded(
                        child: AppRadioButton(
                          text: menu.name,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedUserMenu = menu);
                            widget.onUserMenuSelected(menu);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                ],

                // Phone number with country code
                Row(
                  children: [
                    Expanded(
                      child: AppPhoneTextField(
                        controller: _phoneController,
                        hintText: getString(
                            appStr.hintNumberExample, 'hint_number_example'),
                        onChanged: widget.onPhoneNumberChanged,
                        countryCodeWidget: InkWell(
                          onTap: widget.onCountryCodeTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding,
                              vertical: AppDimens.paddingM,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText.body(
                                  widget.countryPhoneCode,
                                  color: colors.colorText,
                                ),
                                const SizedBox(width: AppDimens.paddingXS),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: colors.colorText,
                                  size: AppDimens.iconSizeSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingS),
                    // Search button
                    IconButton(
                      onPressed:
                          widget.isLoading ? null : widget.onSearchUser,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.colorPrimary,
                        foregroundColor: colors.colorButtonText,
                      ),
                      icon: widget.isLoading
                          ? SizedBox(
                              width: AppDimens.iconSizeSmall,
                              height: AppDimens.iconSizeSmall,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.colorButtonText,
                              ),
                            )
                          : const Icon(
                              Icons.search,
                              size: AppDimens.iconSizeSmall,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingM),

                // User info (when found)
                if (widget.selectedUser != null) ...[
                  _buildUserInfo(context, widget.selectedUser!),
                  const SizedBox(height: AppDimens.paddingM),
                ],

                // No data found message
                if (widget.isShowNoDataFound && widget.selectedUser == null)
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    decoration: BoxDecoration(
                      color: colors.colorWarning.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimens.textFieldRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.colorWarning,
                          size: AppDimens.iconSizeSmall,
                        ),
                        const SizedBox(width: AppDimens.paddingS),
                        Expanded(
                          child: AppText.body(
                            getString(appStr.errorUserNotFound,
                                'error_user_not_found'),
                            color: colors.colorWarning,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Amount input (show when user is found)
                if (widget.isShowSendMoneyButton) ...[
                  const SizedBox(height: AppDimens.paddingM),
                  AppTextField(
                    controller: _amountController,
                    hintText: getString(appStr.hintEnterTransferAmount,
                        'hint_enter_transfer_amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: widget.onAmountChanged,
                  ),
                  const SizedBox(height: AppDimens.paddingXL),

                  // Send and Cancel buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          text: getString(appStr.buttonSend, 'button_send'),
                          isLoading: widget.isLoading,
                          onPressed: widget.onSendMoney,
                        ),
                      ),
                      const SizedBox(width: AppDimens.padding),
                      Expanded(
                        child: AppOutlinedButton(
                          text: getString(
                              appStr.buttonCancel, 'button_cancel'),
                          onPressed: () => context.goBack(),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppDimens.paddingS),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, SearchUser user) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding),
      decoration: BoxDecoration(
        color: colors.colorPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.textFieldRadius),
        border: Border.all(
          color: colors.colorPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.colorPrimary,
            backgroundImage:
                user.imageUrl != null && user.imageUrl!.isNotEmpty
                    ? NetworkImage(
                        ServerConfig.getFullImageUrl(user.imageUrl))
                    : null,
            child: user.imageUrl == null || user.imageUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    color: colors.colorButtonText,
                    size: AppDimens.iconSize,
                  )
                : null,
          ),
          const SizedBox(width: AppDimens.paddingM),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  user.fullName ??
                      '${user.firstName ?? ''} ${user.lastName ?? ''}'
                          .trim(),
                  fontWeight: FontWeight.w600,
                ),
                if (user.fullPhone != null && user.fullPhone!.isNotEmpty)
                  AppText.caption(
                    user.fullPhone!,
                    color: colors.colorText,
                  ),
              ],
            ),
          ),
          // Check icon
          Icon(
            Icons.check_circle,
            color: colors.colorPrimary,
            size: AppDimens.iconSize,
          ),
        ],
      ),
    );
  }
}
