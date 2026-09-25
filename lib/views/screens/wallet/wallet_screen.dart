import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/router/app_navigation.dart';
import '../../../models/responses/payment/card_response.dart';
import '../../../models/responses/payment/payment_webview_response.dart';
import '../../../viewmodels/payment_viewmodel.dart';
import '../../bottomsheets/add_card_bottom_sheet.dart';
import '../../bottomsheets/add_wallet_amount_bottom_sheet.dart';
import '../../bottomsheets/country_phone_code_bottom_sheet.dart';
import '../../bottomsheets/bank_transfer_bottom_sheet.dart';
import '../../bottomsheets/delete_card_bottom_sheet.dart';
import '../../bottomsheets/transfer_money_bottom_sheet.dart';
import '../../bottomsheets/transfer_options_bottom_sheet.dart';
import '../../item/card_item.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final bool isFromSubscription;

  const WalletScreen({super.key, this.isFromSubscription = false});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with WidgetsBindingObserver {
  bool _isDeleteCardSheetShowing = false;
  bool _isDeleteBankSheetShowing = false;
  bool _isAddWalletAmountSheetShowing = false;
  bool _isTransferMoneySheetShowing = false;
  bool _isCountryPhoneCodeSheetShowing = false;
  bool _isAddCardSheetShowing = false;
  bool _isTransferOptionsSheetShowing = false;
  bool _isBankTransferSheetShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(paymentViewModelProvider.notifier);
      viewModel.socketForPaymentWallet();
      if (widget.isFromSubscription) {
        viewModel.setFromSubscription(true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(paymentViewModelProvider.notifier).socketForPaymentWallet();
      ref.read(paymentViewModelProvider.notifier).getWalletDetails();
    }
  }

  void _showDeleteCardBottomSheet() {
    if (_isDeleteCardSheetShowing) return;
    _isDeleteCardSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    DeleteCardBottomSheet.show(
      context,
      cardName: state.selectedCardForDelete?.cardName ??
          state.selectedCardForDelete?.lastFour,
      isLoading: state.isLoading,
      onCancel: () {
        viewModel.cancelDeleteCardDialog();
      },
      onConfirm: () {
        viewModel.confirmDeleteCard();
      },
    ).then((_) {
      _isDeleteCardSheetShowing = false;
      viewModel.cancelDeleteCardDialog();
    });
  }

  void _showDeleteBankBottomSheet() {
    if (_isDeleteBankSheetShowing) return;
    _isDeleteBankSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    DeleteCardBottomSheet.show(
      context,
      title: getString(appStr.headingDeleteBank, 'heading_delete_bank'),
      message:
          getString(appStr.descriptionDeleteBank, 'description_delete_bank'),
      cardName: state.selectedBankForDelete?.lastFour,
      isLoading: state.isLoading,
      onCancel: () {
        viewModel.cancelDeleteBankDialog();
      },
      onConfirm: () {
        viewModel.confirmDeleteBank();
      },
    ).then((_) {
      _isDeleteBankSheetShowing = false;
      viewModel.cancelDeleteBankDialog();
    });
  }

  void _showAddWalletAmountBottomSheet() {
    if (_isAddWalletAmountSheetShowing) return;
    _isAddWalletAmountSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    AddWalletAmountBottomSheet.show(
      context,
      cardsList: state.walletCardsList,
      selectedCard: state.selectedCardsForAddPayment,
      isLoading: state.isLoading,
      onAmountChanged: (amount) {
        final parsedAmount = double.tryParse(amount) ?? 0;
        viewModel.updateWalletAmount(parsedAmount);
      },
      onCardSelected: (card) {
        viewModel.updateSelectedCardForPayment(card);
      },
      onSubmit: () {
        viewModel.paymentIntentCreate();
      },
      onCancel: () {
        context.goBack();
      },
    ).then((_) {
      _isAddWalletAmountSheetShowing = false;
      viewModel.dismissAddWalletAmountBottomSheet();
    });
  }

  void _showTransferMoneyBottomSheet() {
    if (_isTransferMoneySheetShowing) return;
    _isTransferMoneySheetShowing = true;

    final viewModel = ref.read(paymentViewModelProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(paymentViewModelProvider);
          return TransferMoneyBottomSheet(
            userMenuList: state.userMenuList,
            selectedUserMenu: state.selectedUserMenu,
            countryPhoneCode: state.countryPhoneCode,
            selectedUser: state.selectedUser,
            isLoading: state.isLoading,
            isShowSendMoneyButton: state.isShowSendMoneyButton,
            isShowNoDataFound: state.isShowNoDataFound,
            formattedWalletAmount: state.formattedWalletAmount,
            onUserMenuSelected: (menu) {
              viewModel.updateSelectedUserMenu(menu);
            },
            onCountryCodeTap: () {
              viewModel.toggleCountryPhoneCodeBottomSheet();
            },
            onPhoneNumberChanged: (phone) {
              viewModel.updatePhoneNumber(phone);
            },
            onAmountChanged: (amount) {
              viewModel.updateAmount(amount);
            },
            onSearchUser: () {
              viewModel.onSearchPhoneNumber();
            },
            onSendMoney: () {
              viewModel.onTransferMoneyClick();
            },
          );
        },
      ),
    ).then((_) {
      _isTransferMoneySheetShowing = false;
      viewModel.dismissTransferMoneyBottomSheet();
    });
  }

  void _showCountryPhoneCodeBottomSheet() {
    if (_isCountryPhoneCodeSheetShowing) return;
    _isCountryPhoneCodeSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    CountryPhoneCodeBottomSheet.show(
      context,
      phoneCodeList: state.multiplePhoneCodeCountryList,
      selectedPhoneCode: state.countryPhoneCode,
      onPhoneCodeSelected: (country) {
        viewModel.updateCountryPhoneCode(country);
      },
    ).then((_) {
      _isCountryPhoneCodeSheetShowing = false;
      viewModel.dismissCountryPhoneCodeBottomSheet();
    });
  }

  void _showAddCardBottomSheet() {
    if (_isAddCardSheetShowing) return;
    _isAddCardSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    AddCardBottomSheet.show(
      context,
      gatewayList: state.paymentGatewayList,
      selectedGateway: state.paymentGatewayToAddCard,
      isLoading: state.isAddCardLoading,
      onGatewaySelected: (gateway) {
        viewModel.updateSelectedGatewayForAddCard(gateway);
      },
      onCardDetailsChanged: (cardDetails) {
        viewModel.updateCardDetails(cardDetails);
      },
      onSubmit: () {
        viewModel.addCardIntent();
      },
      onCancel: () {
        context.goBack();
      },
    ).then((_) {
      _isAddCardSheetShowing = false;
      viewModel.dismissAddCardBottomSheet();
    });
  }

  void _showTransferOptionsBottomSheet() {
    if (_isTransferOptionsSheetShowing) return;
    _isTransferOptionsSheetShowing = true;

    final state = ref.read(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    TransferOptionsBottomSheet.show(
      context,
      options: state.transferMoneyOptions,
      selectedOption: state.selectedTransferOption,
      onOptionSelected: (option) {
        viewModel.onTransferOptionSelection(option);
      },
      onCancel: () {
        viewModel.dismissTransferOptionSheet();
      },
      onNext: () {
        viewModel.onNextClick();
      },
    ).then((_) {
      _isTransferOptionsSheetShowing = false;
      viewModel.dismissTransferOptionSheet();
    });
  }

  void _showBankTransferBottomSheet() {
    if (_isBankTransferSheetShowing) return;
    _isBankTransferSheetShowing = true;

    final viewModel = ref.read(paymentViewModelProvider.notifier);

    BankTransferBottomSheet.show(context).then((_) {
      _isBankTransferSheetShowing = false;
      viewModel.dismissBankTransferSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);
    final viewModel = ref.read(paymentViewModelProvider.notifier);

    // Listen for bottom sheet state changes
    ref.listen<PaymentState>(paymentViewModelProvider, (previous, next) {
      // Auto-navigate back after card selection when from subscription
      if (next.isNavigateBack && !(previous?.isNavigateBack ?? false)) {
        context.goBack(true);
        return;
      }

      // Delete card bottom sheet
      if (next.showDeleteCardBottomSheet &&
          !(previous?.showDeleteCardBottomSheet ?? false)) {
        _showDeleteCardBottomSheet();
      }

      // Delete bank bottom sheet
      if (next.showDeleteBankBottomSheet &&
          !(previous?.showDeleteBankBottomSheet ?? false)) {
        _showDeleteBankBottomSheet();
      }

      // Add wallet amount bottom sheet
      if (next.showAddWalletAmountBottomSheet &&
          !(previous?.showAddWalletAmountBottomSheet ?? false)) {
        _showAddWalletAmountBottomSheet();
      }

      // Transfer money bottom sheet
      if (next.showTransferMoneyBottomSheet &&
          !(previous?.showTransferMoneyBottomSheet ?? false)) {
        _showTransferMoneyBottomSheet();
      }

      // Country phone code bottom sheet
      if (next.showCountryPhoneCodeBottomSheet &&
          !(previous?.showCountryPhoneCodeBottomSheet ?? false)) {
        _showCountryPhoneCodeBottomSheet();
      }

      // Add card bottom sheet
      if (next.showAddCardBottomSheet &&
          !(previous?.showAddCardBottomSheet ?? false)) {
        _showAddCardBottomSheet();
      }

      // Transfer options bottom sheet
      if (next.showTransferOptionBottomSheet &&
          !(previous?.showTransferOptionBottomSheet ?? false)) {
        _showTransferOptionsBottomSheet();
      }

      // Bank transfer bottom sheet
      if (next.showBankTransferBottomSheet &&
          !(previous?.showBankTransferBottomSheet ?? false)) {
        _showBankTransferBottomSheet();
      }

      // Close add card bottom sheet when state changes to false
      if (!next.showAddCardBottomSheet &&
          (previous?.showAddCardBottomSheet ?? false) &&
          _isAddCardSheetShowing) {
        context.goBack();
        _isAddCardSheetShowing = false;
      }

      // Close add wallet amount bottom sheet when state changes to false
      if (!next.showAddWalletAmountBottomSheet &&
          (previous?.showAddWalletAmountBottomSheet ?? false) &&
          _isAddWalletAmountSheetShowing) {
        context.goBack();
        _isAddWalletAmountSheetShowing = false;
      }

      // Close transfer money bottom sheet when state changes to false
      if (!next.showTransferMoneyBottomSheet &&
          (previous?.showTransferMoneyBottomSheet ?? false) &&
          _isTransferMoneySheetShowing) {
        context.goBack();
        _isTransferMoneySheetShowing = false;
      }

      // Navigate to WebView screen
      if (next.isNavigateToWebView !=
              (previous?.isNavigateToWebView ?? false) &&
          next.navigateURL != null) {
        viewModel.resetNavigationState();
        context.navigateToWebView(
          webViewData: next.navigateURL,
          onPaymentData: (message) {
            context.goBack();
            // Parse JSON response like customer app
            final paymentResponse =
                PaymentWebViewResponse.fromJsonString(message);
            final success = paymentResponse?.success ?? false;
            final responseMessage = paymentResponse?.message;
            viewModel.onPaymentResponseShow(
              message: responseMessage,
              success: success,
            );
            viewModel.getEntityDetail();
          },
        );
      }

      // Show snackbar
      if (next.snackBarMessage != null &&
          next.snackBarMessage!.isNotEmpty &&
          next.snackBarMessage != previous?.snackBarMessage) {
        if (next.isSnackBarError) {
          context.showErrorSnackBar(next.snackBarMessage!);
        } else {
          context.showSnackBar(next.snackBarMessage!);
        }
        viewModel.clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
          child: Column(
            children: [
              AppToolbar(
                title: getString(appStr.headingPayments, 'heading_payments'),
                showBackButton: true,
                onBack: widget.isFromSubscription
                    ? () => context.goBack(true)
                    : null,
              ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Wallet Details Section (hidden when from subscription)
                    if (state.isWalletVisible &&
                        !widget.isFromSubscription)
                      _WalletDetailsSection(
                        formattedAmount:
                            state.formattedWalletAmount ?? '0.00',
                        isShowTransferButton: state.isShowTransferMoneyButton,
                        isDisableTransferButton:
                            state.isDisableTransferMoneyButton,
                        showAddWalletAmount: state.showAddWalletAmount,
                        onTap: () {
                          context.navigateToWalletHistory();
                        },
                        onTransferTap: () {
                          viewModel.onShowTransferOption();
                        },
                        onAddTap: () {
                          viewModel.toggleAddWalletAmountBottomSheet();
                        },
                      ),

                    // Redeem Points Section (hidden when from subscription)
                    if (state.isShowRedeemPoints &&
                        (state.totalRedeemPoints ?? 0) > 0 &&
                        !widget.isFromSubscription)
                      _RedeemPointsSection(
                        totalPoints: state.totalRedeemPoints ?? 0,
                        onRedeemTap: () {
                          context.navigateToRedeem();
                        },
                      ),

                    // Payment Methods Section
                    if (state.isCardAndBankVisible)
                      _PaymentMethodsSection(
                        cardsList: state.cardsList,
                        selectedCard: state.selectedPaymentMethod,
                        isShowDeleteCard: state.isShowDeleteCard,
                        onCardSelected: (card) {
                          viewModel.onPaymentMethodChange(card);
                        },
                        onCardDelete: (card) {
                          viewModel.showDeleteCardDialog(card);
                        },
                        onAddCardTap: () {
                          viewModel.onAddCardClick();
                        },
                      ),

                    // Bank Accounts Section (hidden when from subscription)
                    if (state.isShowBankOption &&
                        !widget.isFromSubscription)
                      _BankAccountsSection(
                        bankList: state.bankList,
                        defaultBank: state.defaultBank,
                        onBankDelete: (bank) {
                          viewModel.showDeleteBankDialog(bank);
                        },
                        onAddBankTap: () {
                          viewModel.addBank();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet details section widget
class _WalletDetailsSection extends StatelessWidget {
  final String formattedAmount;
  final bool isShowTransferButton;
  final bool isDisableTransferButton;
  final bool showAddWalletAmount;
  final VoidCallback? onTap;
  final VoidCallback? onTransferTap;
  final VoidCallback? onAddTap;

  const _WalletDetailsSection({
    required this.formattedAmount,
    this.isShowTransferButton = false,
    this.isDisableTransferButton = false,
    this.showAddWalletAmount = false,
    this.onTap,
    this.onTransferTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppDimens.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: colors.colorText.withValues(alpha: 0.08),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          color: colors.colorBackground,
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              colors.colorText.withValues(alpha: 0.10),
              colors.colorText.withValues(alpha: 0.040),
              colors.colorText.withValues(alpha: 0.001),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet info row
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.body(
                          getString(
                              appStr.descriptionWallet, 'description_wallet'),
                          color: colors.colorText,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: AppDimens.paddingXS),
                        AppText.heading(
                          formattedAmount,
                          color: colors.colorText,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.colorText,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.padding),

            // Action buttons
            Row(
              children: [
                if (isShowTransferButton)
                  Expanded(
                    flex: 2,
                    child: AppFilledButton(
                      text: getString(
                          appStr.buttonTransferMoney, 'button_transfer_money'),
                      icon: Icons.swap_horiz,
                      enabled: !isDisableTransferButton,
                      onPressed: onTransferTap,
                      borderRadius: 50,
                      height: 40,
                    ),
                  ),
                if (isShowTransferButton)
                  const SizedBox(width: AppDimens.paddingM),
                if (showAddWalletAmount)
                  Expanded(
                    child: AppFilledButton(
                      text: getString(appStr.buttonAdd, 'button_add'),
                      icon: Icons.add,
                      onPressed: onAddTap,
                      borderRadius: 50,
                      height: 40,
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

/// Redeem points section widget
class _RedeemPointsSection extends StatelessWidget {
  final double totalPoints;
  final VoidCallback? onRedeemTap;

  const _RedeemPointsSection({
    required this.totalPoints,
    this.onRedeemTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: colors.colorText.withValues(alpha: 0.08),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          color: colors.colorBackground,
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              colors.colorText.withValues(alpha: 0.10),
              colors.colorText.withValues(alpha: 0.040),
              colors.colorText.withValues(alpha: 0.001),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: InkWell(
          onTap: onRedeemTap,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          child: Row(
            children: [
              Icon(
                Icons.stars,
                color: colors.colorPrimary,
                size: AppDimens.iconSize,
              ),
              const SizedBox(width: AppDimens.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      getString(appStr.headingRedeemPoints,
                          'heading_redeem_points'),
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(
                      getString(appStr.descriptionRewardPointsValue,
                              'description_reward_points_value')
                          .replacePlaceholders({
                        StringConstant.redeemPoints: totalPoints.toInt()
                      }),
                      color: colors.colorText,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.colorText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payment methods section widget
class _PaymentMethodsSection extends StatelessWidget {
  final List<CardResponse> cardsList;
  final CardResponse? selectedCard;
  final bool isShowDeleteCard;
  final ValueChanged<CardResponse>? onCardSelected;
  final ValueChanged<CardResponse>? onCardDelete;
  final VoidCallback? onAddCardTap;

  const _PaymentMethodsSection({
    required this.cardsList,
    this.selectedCard,
    this.isShowDeleteCard = true,
    this.onCardSelected,
    this.onCardDelete,
    this.onAddCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppDimens.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body(
            getString(appStr.subHeadingPaymentMethods,
                'sub_heading_payment_methods'),
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: AppDimens.paddingM),

          // Card list
          ...cardsList.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    index < cardsList.length - 1 ? AppDimens.paddingS : 0,
              ),
              child: CardItem(
                card: card,
                isSelected: selectedCard?.id == card.id,
                showDeleteButton: isShowDeleteCard &&
                    card.paymentGatewayType != null &&
                    card.paymentGatewayType != 0 &&
                    card.paymentGatewayType != 1,
                onTap: () => onCardSelected?.call(card),
                onDelete: () => onCardDelete?.call(card),
              ),
            );
          }),

          // Add card button
          Padding(
            padding: EdgeInsets.only(
              top: cardsList.isNotEmpty ? AppDimens.paddingS : 0,
            ),
              child: InkWell(
                onTap: onAddCardTap,
                borderRadius:
                    BorderRadius.circular(AppDimens.buttonRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingM,
                    vertical: AppDimens.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: colors.colorBackgroundGray,
                    borderRadius:
                        BorderRadius.circular(AppDimens.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: colors.colorPrimary,
                        size: AppDimens.iconSize,
                      ),
                      const SizedBox(width: AppDimens.padding),
                      AppText.body(
                        getString(appStr.buttonAddNewCard,
                            'button_add_new_card'),
                        color: colors.colorText,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bank accounts section widget
class _BankAccountsSection extends StatelessWidget {
  final List<CardResponse> bankList;
  final CardResponse? defaultBank;
  final ValueChanged<CardResponse>? onBankDelete;
  final VoidCallback? onAddBankTap;

  const _BankAccountsSection({
    required this.bankList,
    this.defaultBank,
    this.onBankDelete,
    this.onAddBankTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppDimens.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body(
            getString(
                appStr.subHeadingBankAccounts, 'sub_heading_bank_accounts'),
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: AppDimens.paddingM),

          // Bank list
          ...bankList.asMap().entries.map((entry) {
            final index = entry.key;
            final bank = entry.value;
            final isDefault = bank.isDefault == true;
            final statusText =
                BankAccountStatus.getStatusText(bank.status);

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    index < bankList.length - 1 ? AppDimens.paddingS : 0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingM,
                  vertical: AppDimens.paddingM,
                ),
                decoration: BoxDecoration(
                  color: isDefault
                      ? colors.colorPrimary.withValues(alpha: 0.08)
                      : colors.colorBackgroundGray,
                  borderRadius:
                      BorderRadius.circular(AppDimens.buttonRadius),
                  border: isDefault
                      ? Border.all(
                          color:
                              colors.colorPrimary.withValues(alpha: 0.3),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: colors.colorPrimary,
                      size: AppDimens.iconSize,
                    ),
                    const SizedBox(width: AppDimens.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.body(
                            bank.lastFour != null
                                ? '****${bank.lastFour}'
                                : bank.accountNumber ?? '',
                            fontWeight: FontWeight.w500,
                          ),
                          if (statusText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppDimens.paddingXS),
                              child: AppText.caption(
                                statusText,
                                color: bank.status ==
                                        BankAccountStatus.verified
                                    ? Colors.green
                                    : colors.colorText.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colors.colorWarning,
                        size: AppDimens.iconSize,
                      ),
                      onPressed: () => onBankDelete?.call(bank),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Add bank button
          Padding(
            padding: EdgeInsets.only(
              top: bankList.isNotEmpty ? AppDimens.paddingS : 0,
            ),
            child: InkWell(
              onTap: onAddBankTap,
              borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingM,
                  vertical: AppDimens.paddingM,
                ),
                decoration: BoxDecoration(
                  color: colors.colorBackgroundGray,
                  borderRadius:
                      BorderRadius.circular(AppDimens.buttonRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: colors.colorPrimary,
                      size: AppDimens.iconSize,
                    ),
                    const SizedBox(width: AppDimens.padding),
                    AppText.body(
                      getString(
                          appStr.buttonAddNewBank, 'button_add_new_bank'),
                      color: colors.colorText,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
