import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/socket_constants.dart';
import '../core/managers/socket_manager.dart';
import '../core/localization/app_strings.dart';
import '../core/payments/payment_interface.dart';
import '../core/payments/paystack_manager.dart';
import '../core/payments/stripe_payment_manager.dart';
import '../core/payments/webview_payment_manager.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/add_card_request.dart';
import '../models/requests/transfer_credit_request.dart';
import '../models/requests/wallet_payment_request.dart';
import '../models/responses/auth/country_response.dart';
import '../models/requests/entity_detail_request.dart';
import '../models/responses/payment/add_bank_response.dart';
import '../models/responses/payment/add_card_intent_response.dart';
import '../models/responses/payment/card_response.dart';
import '../models/responses/payment/payment_gateway_response.dart';
import '../models/responses/payment/payment_intent_response.dart';
import '../models/responses/payment/search_user_response.dart';
import '../models/common/tax_data.dart';
import '../models/requests/withdraw_credit_request.dart';
import '../models/responses/payment/credit_withdraw_response.dart';
import '../models/webview_data_model.dart';
import '../views/bottomsheets/transfer_money_bottom_sheet.dart';

/// Payment screen state (driver app — no booking-specific flows)
class PaymentState {
  final List<PaymentGateway> allPaymentGatewayList;
  final List<PaymentGateway> paymentGatewayList;
  final PaymentGateway? paymentGatewayToAddCard;
  final List<CardResponse> cards;
  final List<CardResponse> cardsList;
  final List<CardResponse> walletCardsList;
  final CardResponse? selectedCardsForAddPayment;
  final CardResponse? selectedPaymentMethod;
  final bool isLoading;
  final bool isDataLoading;
  final String? error;
  final String? snackBarMessage;
  final bool isSnackBarError;
  final double? totalWalletAmount;
  final String? formattedWalletAmount;
  final double? totalRedeemPoints;
  final bool isShowTransferMoneyButton;
  final bool isDisableTransferMoneyButton;
  final bool isCardAndBankVisible;
  final bool isWalletVisible;
  final bool isShowDeleteCard;
  final double walletAmount;
  final int? selectedPaymentType;
  final WebViewDataModel? navigateURL;
  final bool isNavigateToWebView;
  final bool isShowSendMoneyButton;
  final SearchUser? selectedUser;
  final bool isShowNoDataFound;
  final bool isShowRedeemPoints;
  final bool showTransferMoneyBottomSheet;
  final bool showAddCardBottomSheet;
  final bool showGatewayBottomSheet;
  final bool showAddWalletAmountBottomSheet;
  final bool showDeleteCardBottomSheet;
  final bool showCountryPhoneCodeBottomSheet;
  final bool isAddCard;
  final bool isAddCardLoading;
  final CardDetails? selectedCardDetails;
  final PaymentInterface? paymentManager;
  final List<Country> countryList;
  final List<DropDownModel> userMenuList;
  final DropDownModel? selectedUserMenu;
  final String phoneNumber;
  final String amount;
  final String countryPhoneCode;
  final CardResponse? selectedCardForDelete;
  final List<Country> multiplePhoneCodeCountryList;

  // Bank account state
  final List<CardResponse> bankList;
  final CardResponse? defaultBank;
  final int paymentGatewayForBank;
  final bool isShowBankOption;
  final bool showDeleteBankBottomSheet;
  final CardResponse? selectedBankForDelete;

  // Bank withdrawal / transfer options state
  final bool isBankWithdrawActive;
  final bool showTransferOptionBottomSheet;
  final int selectedTransferOption;
  final List<String> transferMoneyOptions;
  final bool showBankTransferBottomSheet;
  final String bankTransferAmount;
  final bool showBreakDownDetail;
  final List<TaxData> taxList;
  final bool isTransferLimitActive;
  final double transferLimit;
  final bool isPaymentTypeRazorpay;
  final CardResponse? selectedCardPaymentMethod;
  final CardResponse? selectedBankPaymentMethod;
  final int? paymentTypeSelection;
  final bool showAddWalletAmount;
  final bool isFromSubscription;
  final bool isNavigateBack;

  const PaymentState({
    this.allPaymentGatewayList = const [],
    this.paymentGatewayList = const [],
    this.paymentGatewayToAddCard,
    this.cards = const [],
    this.cardsList = const [],
    this.walletCardsList = const [],
    this.selectedCardsForAddPayment,
    this.selectedPaymentMethod,
    this.isLoading = false,
    this.isDataLoading = false,
    this.error,
    this.snackBarMessage,
    this.isSnackBarError = false,
    this.totalWalletAmount,
    this.formattedWalletAmount,
    this.totalRedeemPoints,
    this.isShowTransferMoneyButton = false,
    this.isDisableTransferMoneyButton = false,
    this.isCardAndBankVisible = false,
    this.isWalletVisible = true,
    this.isShowDeleteCard = true,
    this.walletAmount = 0,
    this.selectedPaymentType,
    this.navigateURL,
    this.isNavigateToWebView = false,
    this.isShowSendMoneyButton = false,
    this.selectedUser,
    this.isShowNoDataFound = false,
    this.isShowRedeemPoints = false,
    this.showTransferMoneyBottomSheet = false,
    this.showAddCardBottomSheet = false,
    this.showGatewayBottomSheet = false,
    this.showAddWalletAmountBottomSheet = false,
    this.showDeleteCardBottomSheet = false,
    this.showCountryPhoneCodeBottomSheet = false,
    this.isAddCard = false,
    this.isAddCardLoading = false,
    this.selectedCardDetails,
    this.paymentManager,
    this.countryList = const [],
    this.userMenuList = const [],
    this.selectedUserMenu,
    this.phoneNumber = '',
    this.amount = '',
    this.countryPhoneCode = '',
    this.selectedCardForDelete,
    this.multiplePhoneCodeCountryList = const [],
    this.bankList = const [],
    this.defaultBank,
    this.paymentGatewayForBank = 0,
    this.isShowBankOption = false,
    this.showDeleteBankBottomSheet = false,
    this.selectedBankForDelete,
    this.isBankWithdrawActive = false,
    this.showTransferOptionBottomSheet = false,
    this.selectedTransferOption = -1,
    this.transferMoneyOptions = const [],
    this.showBankTransferBottomSheet = false,
    this.bankTransferAmount = '',
    this.showBreakDownDetail = false,
    this.taxList = const [],
    this.isTransferLimitActive = false,
    this.transferLimit = 0.0,
    this.isPaymentTypeRazorpay = false,
    this.selectedCardPaymentMethod,
    this.selectedBankPaymentMethod,
    this.paymentTypeSelection,
    this.showAddWalletAmount = false,
    this.isFromSubscription = false,
    this.isNavigateBack = false,
  });

  PaymentState copyWith({
    List<PaymentGateway>? allPaymentGatewayList,
    List<PaymentGateway>? paymentGatewayList,
    PaymentGateway? paymentGatewayToAddCard,
    List<CardResponse>? cards,
    List<CardResponse>? cardsList,
    List<CardResponse>? walletCardsList,
    CardResponse? selectedCardsForAddPayment,
    CardResponse? selectedPaymentMethod,
    bool? isLoading,
    bool? isDataLoading,
    String? error,
    bool clearError = false,
    String? snackBarMessage,
    bool? isSnackBarError,
    bool clearSnackBar = false,
    bool clearNavigateURL = false,
    double? totalWalletAmount,
    String? formattedWalletAmount,
    double? totalRedeemPoints,
    bool? isShowTransferMoneyButton,
    bool? isDisableTransferMoneyButton,
    bool? isCardAndBankVisible,
    bool? isWalletVisible,
    bool? isShowDeleteCard,
    double? walletAmount,
    int? selectedPaymentType,
    WebViewDataModel? navigateURL,
    bool? isNavigateToWebView,
    bool? isShowSendMoneyButton,
    SearchUser? selectedUser,
    bool clearSelectedUser = false,
    bool? isShowNoDataFound,
    bool? isShowRedeemPoints,
    bool? showTransferMoneyBottomSheet,
    bool? showAddCardBottomSheet,
    bool? showGatewayBottomSheet,
    bool? showAddWalletAmountBottomSheet,
    bool? showDeleteCardBottomSheet,
    bool? showCountryPhoneCodeBottomSheet,
    bool? isAddCard,
    bool? isAddCardLoading,
    CardDetails? selectedCardDetails,
    PaymentInterface? paymentManager,
    List<Country>? countryList,
    List<DropDownModel>? userMenuList,
    DropDownModel? selectedUserMenu,
    bool clearSelectedUserMenu = false,
    String? phoneNumber,
    String? amount,
    String? countryPhoneCode,
    CardResponse? selectedCardForDelete,
    bool clearSelectedCardForDelete = false,
    List<Country>? multiplePhoneCodeCountryList,
    List<CardResponse>? bankList,
    CardResponse? defaultBank,
    bool clearDefaultBank = false,
    int? paymentGatewayForBank,
    bool? isShowBankOption,
    bool? showDeleteBankBottomSheet,
    CardResponse? selectedBankForDelete,
    bool clearSelectedBankForDelete = false,
    bool? isBankWithdrawActive,
    bool? showTransferOptionBottomSheet,
    int? selectedTransferOption,
    List<String>? transferMoneyOptions,
    bool? showBankTransferBottomSheet,
    String? bankTransferAmount,
    bool? showBreakDownDetail,
    List<TaxData>? taxList,
    bool? isTransferLimitActive,
    double? transferLimit,
    bool? isPaymentTypeRazorpay,
    CardResponse? selectedCardPaymentMethod,
    bool clearSelectedCardPaymentMethod = false,
    CardResponse? selectedBankPaymentMethod,
    bool clearSelectedBankPaymentMethod = false,
    int? paymentTypeSelection,
    bool? showAddWalletAmount,
    bool? isFromSubscription,
    bool? isNavigateBack,
  }) {
    return PaymentState(
      allPaymentGatewayList:
          allPaymentGatewayList ?? this.allPaymentGatewayList,
      paymentGatewayList: paymentGatewayList ?? this.paymentGatewayList,
      paymentGatewayToAddCard:
          paymentGatewayToAddCard ?? this.paymentGatewayToAddCard,
      cards: cards ?? this.cards,
      cardsList: cardsList ?? this.cardsList,
      walletCardsList: walletCardsList ?? this.walletCardsList,
      selectedCardsForAddPayment:
          selectedCardsForAddPayment ?? this.selectedCardsForAddPayment,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isLoading: isLoading ?? this.isLoading,
      isDataLoading: isDataLoading ?? this.isDataLoading,
      error: clearError ? null : (error ?? this.error),
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
      isSnackBarError:
          clearSnackBar ? false : (isSnackBarError ?? this.isSnackBarError),
      totalWalletAmount: totalWalletAmount ?? this.totalWalletAmount,
      formattedWalletAmount:
          formattedWalletAmount ?? this.formattedWalletAmount,
      totalRedeemPoints: totalRedeemPoints ?? this.totalRedeemPoints,
      isShowTransferMoneyButton:
          isShowTransferMoneyButton ?? this.isShowTransferMoneyButton,
      isDisableTransferMoneyButton:
          isDisableTransferMoneyButton ?? this.isDisableTransferMoneyButton,
      isCardAndBankVisible:
          isCardAndBankVisible ?? this.isCardAndBankVisible,
      isWalletVisible: isWalletVisible ?? this.isWalletVisible,
      isShowDeleteCard: isShowDeleteCard ?? this.isShowDeleteCard,
      walletAmount: walletAmount ?? this.walletAmount,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      navigateURL:
          clearNavigateURL ? null : (navigateURL ?? this.navigateURL),
      isNavigateToWebView: isNavigateToWebView ?? this.isNavigateToWebView,
      isShowSendMoneyButton:
          isShowSendMoneyButton ?? this.isShowSendMoneyButton,
      selectedUser:
          clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
      isShowNoDataFound: isShowNoDataFound ?? this.isShowNoDataFound,
      isShowRedeemPoints: isShowRedeemPoints ?? this.isShowRedeemPoints,
      showTransferMoneyBottomSheet:
          showTransferMoneyBottomSheet ?? this.showTransferMoneyBottomSheet,
      showAddCardBottomSheet:
          showAddCardBottomSheet ?? this.showAddCardBottomSheet,
      showGatewayBottomSheet:
          showGatewayBottomSheet ?? this.showGatewayBottomSheet,
      showAddWalletAmountBottomSheet:
          showAddWalletAmountBottomSheet ??
              this.showAddWalletAmountBottomSheet,
      showDeleteCardBottomSheet:
          showDeleteCardBottomSheet ?? this.showDeleteCardBottomSheet,
      showCountryPhoneCodeBottomSheet:
          showCountryPhoneCodeBottomSheet ??
              this.showCountryPhoneCodeBottomSheet,
      isAddCard: isAddCard ?? this.isAddCard,
      isAddCardLoading: isAddCardLoading ?? this.isAddCardLoading,
      selectedCardDetails: selectedCardDetails ?? this.selectedCardDetails,
      paymentManager: paymentManager ?? this.paymentManager,
      countryList: countryList ?? this.countryList,
      userMenuList: userMenuList ?? this.userMenuList,
      selectedUserMenu: clearSelectedUserMenu
          ? null
          : (selectedUserMenu ?? this.selectedUserMenu),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      countryPhoneCode: countryPhoneCode ?? this.countryPhoneCode,
      selectedCardForDelete: clearSelectedCardForDelete
          ? null
          : (selectedCardForDelete ?? this.selectedCardForDelete),
      multiplePhoneCodeCountryList:
          multiplePhoneCodeCountryList ?? this.multiplePhoneCodeCountryList,
      bankList: bankList ?? this.bankList,
      defaultBank:
          clearDefaultBank ? null : (defaultBank ?? this.defaultBank),
      paymentGatewayForBank:
          paymentGatewayForBank ?? this.paymentGatewayForBank,
      isShowBankOption: isShowBankOption ?? this.isShowBankOption,
      showDeleteBankBottomSheet:
          showDeleteBankBottomSheet ?? this.showDeleteBankBottomSheet,
      selectedBankForDelete: clearSelectedBankForDelete
          ? null
          : (selectedBankForDelete ?? this.selectedBankForDelete),
      isBankWithdrawActive:
          isBankWithdrawActive ?? this.isBankWithdrawActive,
      showTransferOptionBottomSheet:
          showTransferOptionBottomSheet ?? this.showTransferOptionBottomSheet,
      selectedTransferOption:
          selectedTransferOption ?? this.selectedTransferOption,
      transferMoneyOptions:
          transferMoneyOptions ?? this.transferMoneyOptions,
      showBankTransferBottomSheet:
          showBankTransferBottomSheet ?? this.showBankTransferBottomSheet,
      bankTransferAmount:
          bankTransferAmount ?? this.bankTransferAmount,
      showBreakDownDetail:
          showBreakDownDetail ?? this.showBreakDownDetail,
      taxList: taxList ?? this.taxList,
      isTransferLimitActive:
          isTransferLimitActive ?? this.isTransferLimitActive,
      transferLimit: transferLimit ?? this.transferLimit,
      isPaymentTypeRazorpay:
          isPaymentTypeRazorpay ?? this.isPaymentTypeRazorpay,
      selectedCardPaymentMethod: clearSelectedCardPaymentMethod
          ? null
          : (selectedCardPaymentMethod ?? this.selectedCardPaymentMethod),
      selectedBankPaymentMethod: clearSelectedBankPaymentMethod
          ? null
          : (selectedBankPaymentMethod ?? this.selectedBankPaymentMethod),
      paymentTypeSelection:
          paymentTypeSelection ?? this.paymentTypeSelection,
      showAddWalletAmount:
          showAddWalletAmount ?? this.showAddWalletAmount,
      isFromSubscription:
          isFromSubscription ?? this.isFromSubscription,
      isNavigateBack: isNavigateBack ?? this.isNavigateBack,
    );
  }
}

/// Payment screen ViewModel (driver app)
class PaymentViewModel extends StateNotifier<PaymentState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager? _sharedPref;
  final SocketManager _socketManager;

  PaymentViewModel(
      this._appRepository, this._sharedPref, this._socketManager)
      : super(const PaymentState()) {
    _initialize();
  }

  // Currency settings
  int _currencyDirection = 1;
  String _currencySign = '';
  int _decimalPoints = 2;

  void _initialize() {
    final setting = _sharedPref?.getSetting();
    _currencyDirection = setting?.setCurrencySign ?? 1;
    _currencySign = setting?.currencySign ?? '';
    _decimalPoints = setting?.decimalPointValue ?? 2;

    getPaymentGateways();
    _setupUserMenuList();

    final entity = _sharedPref?.getEntity();

    state = state.copyWith(
      countryPhoneCode: entity?.countryPhoneCode ?? '',
      isShowRedeemPoints: setting?.rewardPointConfig?.isActive ?? false,
    );

    getWalletDetails();
    getCountries();
    getEntityDetail();
  }

  /// Set isFromSubscription flag (called from WalletScreen when opened from subscription)
  void setFromSubscription(bool value) {
    state = state.copyWith(isFromSubscription: value);
  }

  /// Format currency value
  String formatCurrency(double? value) {
    if (value == null) return '';
    final formatted = value.toStringAsFixed(_decimalPoints);
    if (_currencySign.isEmpty) return formatted;
    if (_currencyDirection == 2) return '$formatted$_currencySign';
    return '$_currencySign$formatted';
  }

  /// Setup user menu list and transfer money options for credit transfer (driver-specific)
  void _setupUserMenuList() {
    final setting = _sharedPref?.getSetting();
    final userMenuList = <DropDownModel>[];
    final transferMoneyOptions = <String>[];

    if (setting?.creditTransferConfig?.isDriverToCustomer == true) {
      final name =
          getString(appStr.descriptionCustomer, 'description_customer');
      userMenuList.add(DropDownModel(
        type: EntityType.customer,
        name: name,
      ));
      transferMoneyOptions.add(name);
    }

    if (setting?.creditTransferConfig?.isDriverToDriver == true) {
      final name = getString(appStr.descriptionDriver, 'description_driver');
      userMenuList.add(DropDownModel(
        type: EntityType.driver,
        name: name,
      ));
      transferMoneyOptions.add(name);
    }

    if (userMenuList.isNotEmpty) {
      final checkTransfer =
          setting?.creditTransferConfig?.isDriverToDriver == true ||
              setting?.creditTransferConfig?.isDriverToCustomer == true;
      final entity = _sharedPref?.getEntity();
      final isShowMoneyTransfer =
          (entity?.credit ?? 0) > 0.0 && checkTransfer;

      state = state.copyWith(
        isShowTransferMoneyButton: checkTransfer,
        isDisableTransferMoneyButton: !isShowMoneyTransfer,
        userMenuList: userMenuList,
        selectedUserMenu: userMenuList.first,
        transferMoneyOptions: transferMoneyOptions,
      );
    } else {
      state = state.copyWith(
        transferMoneyOptions: transferMoneyOptions,
      );
    }
  }

  /// Get payment gateways
  Future<void> getPaymentGateways() async {
    final countryId = _sharedPref?.getEntity()?.countryId;

    state = state.copyWith(
        isLoading: true, isDataLoading: true, clearError: true);

    final response = await _appRepository.getPaymentGateways(
      countryId: countryId ?? '',
    );

    switch (response) {
      case Success<PaymentGatewayResponse>():
        final gateways = response.data?.paymentGateways ?? [];
        if (gateways.isNotEmpty) {
          debugPrint('PaymentViewModel - ${gateways.length} gateways');

          final stripeGateway = gateways
              .where((g) => g.type == PaymentGatewayType.stripe.value)
              .firstOrNull;
          AppConstants.stripePublishableKey =
              stripeGateway?.credential?.publicKey ?? '';

          final filteredList = _createPaymentGatewayList(gateways);

          // Handle bank settings
          final gatewayResponse = response.data;
          final showBank = gatewayResponse?.showBank ?? false;
          final bankGateway =
              gatewayResponse?.bankTransferSetting?.paymentGateway ?? 0;

          state = state.copyWith(
            isLoading: false,
            isDataLoading: false,
            showAddWalletAmount: true,
            allPaymentGatewayList: gateways,
            paymentGatewayList: filteredList,
            isCardAndBankVisible: _checkCardAndBankVisibility(gateways),
            isShowBankOption: showBank,
            paymentGatewayForBank: bankGateway,
          );

          // Add "Bank" to transfer money options if bank is shown
          if (showBank) {
            final options = [
              ...state.transferMoneyOptions,
              getString(appStr.descriptionBank, 'description_bank'),
            ];
            state = state.copyWith(transferMoneyOptions: options);
          }

          await getCards();

          if (_isGetBanks(gatewayResponse)) {
            await getBank();
          }
        } else {
          state = state.copyWith(
            isDataLoading: false,
            showAddWalletAmount: false,
          );
        }

        // Extract credit withdraw settings
        final isBankWithdrawActive =
            response.data?.creditWithdrawSetting?.isActive ?? false;
        final isTransferLimitActive =
            response.data?.creditWithdrawSetting?.withdrawLimit?.isActive ??
                false;
        final transferLimit =
            response.data?.creditWithdrawSetting?.withdrawLimit?.limit ?? 0.0;
        final bankGatewayType =
            response.data?.bankTransferSetting?.paymentGateway ?? 0;
        final isPaymentTypeRazorpay =
            bankGatewayType == PaymentGatewayType.razorpay.value;

        // If no bank withdraw and no user menu → hide transfer button
        if (!isBankWithdrawActive && state.userMenuList.isEmpty) {
          state = state.copyWith(isShowTransferMoneyButton: false);
        }

        state = state.copyWith(
          isBankWithdrawActive: isBankWithdrawActive,
          isTransferLimitActive: isTransferLimitActive,
          transferLimit: transferLimit,
          isPaymentTypeRazorpay: isPaymentTypeRazorpay,
        );

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false, isDataLoading: false);

      case Loading():
        break;
    }
  }

  List<PaymentGateway> _createPaymentGatewayList(List<PaymentGateway> list) {
    final paymentGateways =
        list.where((g) => g.isAllowSaveCard == true).toList();

    if (paymentGateways.isNotEmpty) {
      final updatedList = paymentGateways.map((gateway) {
        final gatewayType = PaymentGatewayType.fromValue(gateway.type);
        return gateway.copyWith(
          name: gatewayType?.getName() ?? gateway.name ?? '',
        );
      }).toList();

      state = state.copyWith(paymentGatewayToAddCard: updatedList.first);
      return updatedList;
    }

    return paymentGateways;
  }

  bool _checkCardAndBankVisibility(List<PaymentGateway>? gateways) {
    if (gateways == null) return false;
    return gateways.any((g) =>
        g.type == PaymentGatewayType.stripe.value ||
        g.type == PaymentGatewayType.paystack.value);
  }

  /// Get saved cards
  Future<void> getCards() async {
    if (state.allPaymentGatewayList.isEmpty) return;

    final countryId = _sharedPref?.getEntity()?.countryId ?? '';
    final gatewayTypeList = state.paymentGatewayList
        .map((g) => g.type.toString())
        .join(',');
    if (gatewayTypeList.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.getCards(
      countryId: countryId,
      paymentGatewayTypes: gatewayTypeList,
    );

    switch (response) {
      case Success<GetCardsResponse>():
        final allCardsResponse = response.data?.cards ?? [];
        final cardList = <CardResponse>[];

        if (allCardsResponse.isNotEmpty) {
          final walletCards = <CardResponse>[];
          CardResponse? defaultCard;

          for (final card in allCardsResponse) {
            if (card.isDefault == true) {
              defaultCard = card;
              walletCards.add(card);
            }
          }

          for (final card in allCardsResponse) {
            final updatedCard = card.copyWith(
              cardName: '${card.cardType ?? ''}**** ${card.lastFour}',
            );
            cardList.add(updatedCard);
          }

          walletCards.addAll(_webViewGatewayCardList());

          state = state.copyWith(
            isLoading: false,
            cards: allCardsResponse,
            cardsList: cardList,
            walletCardsList: walletCards,
            showAddCardBottomSheet: false,
            selectedCardsForAddPayment:
                walletCards.isNotEmpty ? walletCards.first : null,
            selectedPaymentMethod: defaultCard,
          );
        } else {
          final walletCards = _webViewGatewayCardList();
          state = state.copyWith(
            isLoading: false,
            cards: allCardsResponse,
            cardsList: cardList,
            walletCardsList: walletCards,
            showAddCardBottomSheet: false,
            selectedCardsForAddPayment:
                walletCards.isNotEmpty ? walletCards.first : null,
          );
        }

      case Error():
        final walletCards = _webViewGatewayCardList();
        state = state.copyWith(
          isLoading: false,
          cardsList: [],
          walletCardsList: walletCards,
          selectedCardsForAddPayment:
              walletCards.isNotEmpty ? walletCards.first : null,
        );

      case Loading():
        break;
    }
  }

  /// Create list of webview-based payment gateways
  List<CardResponse> _webViewGatewayCardList() {
    final paymentGatewayList = <CardResponse>[];
    final allGateways = state.allPaymentGatewayList;

    final webViewTypes = [
      PaymentGatewayType.razorpay,
      PaymentGatewayType.mercado,
      PaymentGatewayType.payu,
      PaymentGatewayType.pago,
      PaymentGatewayType.pagoC2p,
      PaymentGatewayType.zaincash,
      PaymentGatewayType.hyperpay,
      PaymentGatewayType.nestpay,
      PaymentGatewayType.qicard,
      PaymentGatewayType.mpesa,
    ];

    for (final type in webViewTypes) {
      if (allGateways.any((g) => g.type == type.value)) {
        paymentGatewayList.add(CardResponse(
          id: type.name,
          paymentGatewayType: type.value,
          cardName: type.getName(),
        ));
      }
    }

    return paymentGatewayList;
  }

  /// Get wallet details from local storage
  void getWalletDetails() {
    final entity = _sharedPref?.getEntity();
    final formattedAmount = formatCurrency(entity?.credit);
    debugPrint(
        'PaymentViewModel - getWalletDetails: credit=${entity?.credit}, formatted=$formattedAmount');

    state = state.copyWith(
      totalWalletAmount: entity?.credit,
      formattedWalletAmount: formattedAmount,
      totalRedeemPoints: entity?.reward,
    );

    _setTransferButton();
  }

  void _setTransferButton() {
    final setting = _sharedPref?.getSetting();
    final entity = _sharedPref?.getEntity();

    final checkTransfer =
        setting?.creditTransferConfig?.isDriverToCustomer == true ||
            setting?.creditTransferConfig?.isDriverToDriver == true;

    final isShowMoneyTransfer = (entity?.credit ?? 0) >= 1 && checkTransfer;

    state = state.copyWith(
      isShowTransferMoneyButton: checkTransfer,
      isDisableTransferMoneyButton: !isShowMoneyTransfer,
    );
  }

  /// Delete a card
  Future<void> deleteCard(String id) async {
    state = state.copyWith(isLoading: true);

    final response = await _appRepository.deleteCard(cardId: id);

    switch (response) {
      case Success():
        _showSnackBar(response.message ?? '');
        await getCards();

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  bool _isCardSelectedForPayment() {
    if (state.walletAmount <= 0) {
      _showSnackBar(
        getString(appStr.errorPleaseEnterWalletAmount, 'error_please_enter_wallet_amount'),
        isError: true,
      );
      return false;
    }

    if (state.selectedCardsForAddPayment == null) {
      _showSnackBar(
        getString(appStr.errorPleaseSelectCard, 'error_please_select_card'),
        isError: true,
      );
      return false;
    }

    return true;
  }

  bool _checkCardData(CardDetails cardDetails) {
    if (cardDetails.name == null || cardDetails.name!.isEmpty) {
      _showSnackBar(
          getString(appStr.errorPleaseEnterCardName, 'error_please_enter_card_name'), isError: true);
      return false;
    }
    if (cardDetails.cardNumber == null ||
        cardDetails.cardNumber!.length < 13) {
      _showSnackBar(
          getString(appStr.errorPleaseEnterValidCardNumber, 'error_please_enter_valid_card_number'),
          isError: true);
      return false;
    }
    if (cardDetails.expiryDate == null ||
        !cardDetails.expiryDate!.contains('/')) {
      _showSnackBar(
          getString(appStr.errorPleaseEnterValidExpiryDate, 'error_please_enter_valid_expiry_date'),
          isError: true);
      return false;
    }
    if (cardDetails.cvv == null || cardDetails.cvv!.length < 3) {
      _showSnackBar(
          getString(appStr.errorPleaseEnterValidCvv, 'error_please_enter_valid_cvv'), isError: true);
      return false;
    }
    return true;
  }

  PaymentInterface _getPaymentManager(int? paymentGateway) {
    return switch (paymentGateway) {
      int g when g == PaymentGatewayType.stripe.value =>
        StripePaymentManager(),
      int g when g == PaymentGatewayType.paystack.value =>
        PaystackManager(),
      _ => WebViewPaymentManager(),
    };
  }

  /// Create payment intent for wallet top-up
  Future<void> paymentIntentCreate() async {
    if (!_isCardSelectedForPayment()) return;

    final paymentGateway =
        state.selectedCardsForAddPayment?.paymentGatewayType;
    final paymentManager = _getPaymentManager(paymentGateway);

    state = state.copyWith(
      selectedPaymentType: paymentGateway,
      isLoading: true,
    );

    final paymentIntentRequest = WalletPaymentRequest(
      amount: state.walletAmount,
      countryId: _sharedPref?.getEntity()?.countryId,
      currency: _sharedPref?.getEntity()?.creditCurrencyCode,
      paymentPurpose: PaymentPurposeType.addWallet,
    );

    final response = await _appRepository.paymentIntentCreate(
      paymentGateway: paymentGateway.toString(),
      request: paymentIntentRequest,
    );

    switch (response) {
      case Success<PaymentIntentResponse>():
        debugPrint(
            'PaymentViewModel - paymentIntentCreate success: status=${response.data?.paymentTransactionStatus}');
        if (response.data?.paymentTransactionStatus ==
            PaymentTransactionStatus.initiated) {
          paymentManager
              .initPaymentSdk(response.data?.intent?.publicKey ?? '');

          paymentManager.createPaymentIntent(
            intent: response.data?.intent,
            callback: PaymentCallbackImpl(
              onSuccess: (paymentMethodId, intentResponse) {
                debugPrint(
                    'PaymentViewModel - onSuccess: paymentMethodId=$paymentMethodId');
                if (paymentMethodId != null) {
                  state = state.copyWith(
                    isLoading: false,
                    showAddWalletAmountBottomSheet: false,
                    walletAmount: 0,
                  );
                  _delayedGetEntityDetail();
                  getCards();
                } else {
                  WebViewDataModel? webViewDataModel;
                  if (intentResponse?.url != null &&
                      intentResponse!.url!.isNotEmpty) {
                    webViewDataModel = WebViewDataModel(
                      webURL: Uri.encodeFull(intentResponse.url!),
                    );
                  } else if (intentResponse?.html != null &&
                      intentResponse!.html!.isNotEmpty) {
                    webViewDataModel = WebViewDataModel(
                      webContent: intentResponse.html,
                    );
                  }
                  if (webViewDataModel != null) {
                    state = state.copyWith(
                      isLoading: false,
                      isNavigateToWebView: !state.isNavigateToWebView,
                      navigateURL: webViewDataModel,
                      showAddWalletAmountBottomSheet: false,
                      walletAmount: 0,
                    );
                  }
                }
              },
              onCapture: () {
                debugPrint(
                    'PaymentViewModel - onCapture: RequiresCapture received');
                // RequiresCapture - server will capture, wallet updates via socket
                state = state.copyWith(
                  isLoading: false,
                  showAddWalletAmountBottomSheet: false,
                  walletAmount: 0,
                );
              },
              onCardCreated: (paymentMethodId, intent) {},
              onError: (error) {
                debugPrint(
                    'PaymentViewModel - onError: ${error.toString()}');
                _showSnackBar(error.toString(), isError: true);
                state = state.copyWith(isLoading: false);
              },
            ),
          );
        } else {
          debugPrint(
              'PaymentViewModel - paymentIntentCreate: status=${response.data?.paymentTransactionStatus}, not initiated - calling getEntityDetail');
          state = state.copyWith(
            isLoading: false,
            showAddWalletAmountBottomSheet: false,
            walletAmount: 0,
          );
          if (response.message?.isNotEmpty == true) {
            _showSnackBar(response.message!);
          }
          _delayedGetEntityDetail();
          getCards();
        }

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  void resetNavigationState() {
    state = state.copyWith(
      isNavigateToWebView: false,
      clearNavigateURL: true,
    );
  }

  /// Delayed entity detail fetch - gives server time to process credit update
  void _delayedGetEntityDetail() {
    Future.delayed(const Duration(seconds: 2), () {
      getEntityDetail();
    });
  }

  /// Get entity detail (refresh user data)
  Future<void> getEntityDetail() async {
    final request = EntityDetailRequest();
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success():
        debugPrint(
            'PaymentViewModel - getEntityDetail success, credit: ${response.data?.entity?.credit}');
        if (response.data?.entity != null) {
          await _sharedPref?.setEntity(response.data!.entity!);
        }
        getWalletDetails();
        state = state.copyWith(isLoading: false);

      case Error():
        debugPrint(
            'PaymentViewModel - getEntityDetail error: ${response.error?.message}');
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  void updateWalletAmount(double amount) {
    state = state.copyWith(walletAmount: amount);
  }

  /// Search user for money transfer
  Future<void> getSearchUser({
    required String countryPhoneCode,
    required String phoneNo,
    required int type,
    required String id,
  }) async {
    state = state.copyWith(isLoading: true);

    final response = await _appRepository.searchUser(
      countryPhoneCode: countryPhoneCode,
      phone: phoneNo,
      type: type,
      id: id,
    );

    switch (response) {
      case Success<SearchUserResponse>():
        if (response.data?.user != null) {
          state = state.copyWith(
            isLoading: false,
            isShowSendMoneyButton: true,
            selectedUser: response.data!.user,
            isShowNoDataFound: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isShowSendMoneyButton: false,
            isShowNoDataFound: true,
          );
        }

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(
          isLoading: false,
          isShowSendMoneyButton: false,
          isShowNoDataFound: true,
        );

      case Loading():
        break;
    }
  }

  /// Transfer credit to another user
  Future<void> transferCredit(TransferCreditRequest request) async {
    state = state.copyWith(isLoading: true);

    final response = await _appRepository.transferCredit(request: request);

    switch (response) {
      case Success():
        _showSnackBar(response.message ?? '');
        state = state.copyWith(
          isLoading: false,
          showTransferMoneyBottomSheet: false,
        );
        getEntityDetail();

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(
          isLoading: false,
          showTransferMoneyBottomSheet: false,
        );

      case Loading():
        break;
    }
  }

  /// Add a new card
  Future<void> addCard(String? paymentMethodId) async {
    final addCardRequest = AddCardRequest(
      countryId: _sharedPref?.getEntity()?.countryId,
      paymentMethod: paymentMethodId,
    );

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.addCard(
      gateway: state.selectedPaymentType.toString(),
      request: addCardRequest,
    );

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          showAddCardBottomSheet: false,
          showGatewayBottomSheet: false,
          isAddCard: false,
        );
        await getCards();

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(
          isLoading: false,
          showAddCardBottomSheet: false,
          showGatewayBottomSheet: false,
          isAddCard: false,
        );

      case Loading():
        break;
    }
  }

  /// Add card intent for payment gateway
  Future<void> addCardIntent() async {
    final gatewayType = state.paymentGatewayToAddCard?.type;

    if (gatewayType == PaymentGatewayType.stripe.value) {
      final cardDetails = state.selectedCardDetails;
      if (cardDetails == null || !_checkCardData(cardDetails)) {
        return;
      }
      state = state.copyWith(isAddCard: true);
    }

    state = state.copyWith(
      isAddCardLoading: true,
      selectedPaymentType: gatewayType,
      paymentManager: _getPaymentManager(gatewayType),
    );

    final response = await _appRepository.addCardIntent(
      gateway: gatewayType.toString(),
      countryId: _sharedPref?.getEntity()?.countryId ?? '',
    );

    switch (response) {
      case Success<AddCardIntentResponse>():
        state = state.copyWith(
          showAddCardBottomSheet: false,
          showGatewayBottomSheet: false,
          isAddCardLoading: false,
        );

        final data = response.data;
        state.paymentManager
            ?.initPaymentSdk(data?.intent?.publicKey ?? '');
        state.paymentManager?.createCardIntent(
          card: state.selectedCardDetails,
          addCardIntentResponse: data?.intent,
          callback: PaymentCallbackImpl(
            onSuccess: (paymentMethodId, intentResponse) {},
            onCapture: () {},
            onCardCreated: (paymentMethodId, addCardIntentResponse) {
              if (paymentMethodId != null) {
                if (state.isAddCard) {
                  state = state.copyWith(isAddCard: false);
                  addCard(paymentMethodId);
                }
              } else if (addCardIntentResponse != null) {
                final webViewDataModel = WebViewDataModel(
                  webURL: Uri.encodeFull(
                      data?.intent?.authorizationUrl ?? ''),
                );
                state = state.copyWith(
                  isNavigateToWebView: !state.isNavigateToWebView,
                  navigateURL: webViewDataModel,
                );
              }
            },
            onError: (error) {
              _showSnackBar(error.toString(), isError: true);
              state = state.copyWith(
                isAddCardLoading: false,
                showAddCardBottomSheet: false,
                showGatewayBottomSheet: false,
                isAddCard: false,
              );
            },
          ),
        );

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(
          isAddCardLoading: false,
          isAddCard: false,
        );

      case Loading():
        break;
    }
  }

  /// Get countries list
  Future<void> getCountries() async {
    final response = await _appRepository.getCountries();

    switch (response) {
      case Success<CountryResponse>():
        state = state.copyWith(
          countryList: response.data?.countries ?? [],
        );

      case Error():
        break;

      case Loading():
        break;
    }
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void updateSelectedUserMenu(DropDownModel? userMenu) {
    state = state.copyWith(
      selectedUserMenu: userMenu,
      clearSelectedUser: true,
      isShowSendMoneyButton: false,
      phoneNumber: '',
    );
  }

  // ==================== Bank Account Methods ====================

  /// Get saved bank accounts
  Future<void> getBank() async {
    final paymentGateway = state.paymentGatewayForBank;
    if (paymentGateway == 0) return;

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.getBank(
      paymentGateway: paymentGateway,
    );

    switch (response) {
      case Success<GetCardsResponse>():
        final bankAccounts = response.data?.bankAccounts ?? [];
        if (bankAccounts.isNotEmpty) {
          final defaultBank =
              bankAccounts.where((b) => b.isDefault == true).firstOrNull;
          state = state.copyWith(
            isLoading: false,
            bankList: bankAccounts,
            defaultBank: defaultBank,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            bankList: [],
            clearDefaultBank: true,
          );
        }

      case Error():
        state = state.copyWith(
          isLoading: false,
          bankList: [],
          clearDefaultBank: true,
        );

      case Loading():
        break;
    }
  }

  /// Add a new bank account
  Future<void> addBank() async {
    state = state.copyWith(paymentTypeSelection: PaymentMethods.bank);

    final addCardRequest = AddCardRequest(
      countryId: _sharedPref?.getEntity()?.countryId,
    );

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.addBank(
      gateway: state.paymentGatewayForBank.toString(),
      request: addCardRequest,
    );

    switch (response) {
      case Success<AddBankResponse>():
        state = state.copyWith(isLoading: false);

        final accountLink = response.data?.bankAccount?.accountLink;
        if (accountLink != null && accountLink.isNotEmpty) {
          state = state.copyWith(
            isNavigateToWebView: !state.isNavigateToWebView,
            navigateURL: WebViewDataModel(
              webURL: Uri.encodeFull(accountLink),
            ),
          );
        }

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  /// Delete a bank account
  Future<void> deleteBank(String id) async {
    state = state.copyWith(isLoading: true);

    final response = await _appRepository.deleteBank(bankId: id);

    switch (response) {
      case Success():
        _showSnackBar(response.message ?? '');
        await getBank();

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  void showDeleteBankDialog(CardResponse bank) {
    state = state.copyWith(
      showDeleteBankBottomSheet: true,
      selectedBankForDelete: bank,
    );
  }

  void cancelDeleteBankDialog() {
    state = state.copyWith(
      showDeleteBankBottomSheet: false,
      clearSelectedBankForDelete: true,
    );
  }

  Future<void> confirmDeleteBank() async {
    final bankId = state.selectedBankForDelete?.id;
    state = state.copyWith(
      showDeleteBankBottomSheet: false,
      clearSelectedBankForDelete: true,
    );
    if (bankId != null) {
      await deleteBank(bankId);
    }
  }

  // ==================== Bottom Sheet Toggles ====================

  void showDeleteCardDialog(CardResponse card) {
    state = state.copyWith(
      showDeleteCardBottomSheet: true,
      selectedCardForDelete: card,
    );
  }

  void cancelDeleteCardDialog() {
    state = state.copyWith(
      showDeleteCardBottomSheet: false,
      clearSelectedCardForDelete: true,
    );
  }

  Future<void> confirmDeleteCard() async {
    final cardId = state.selectedCardForDelete?.id;
    state = state.copyWith(
      showDeleteCardBottomSheet: false,
      clearSelectedCardForDelete: true,
    );
    if (cardId != null) {
      await deleteCard(cardId);
    }
  }

  void toggleAddWalletAmountBottomSheet() {
    state = state.copyWith(
      showAddWalletAmountBottomSheet:
          !state.showAddWalletAmountBottomSheet,
      walletAmount: 0,
    );
  }

  void dismissAddWalletAmountBottomSheet() {
    state = state.copyWith(
      showAddWalletAmountBottomSheet: false,
      walletAmount: 0,
    );
  }

  void updateSelectedCardForPayment(CardResponse card) {
    state = state.copyWith(selectedCardsForAddPayment: card);
  }

  void toggleTransferMoneyBottomSheet() {
    if (state.isShowTransferMoneyButton) {
      state = state.copyWith(
        showTransferMoneyBottomSheet:
            !state.showTransferMoneyBottomSheet,
        clearSelectedUser: true,
        amount: '',
        phoneNumber: '',
        isShowSendMoneyButton: false,
      );
    }
  }

  void dismissTransferMoneyBottomSheet() {
    state = state.copyWith(
      showTransferMoneyBottomSheet: false,
      clearSelectedUser: true,
      amount: '',
      phoneNumber: '',
      isShowSendMoneyButton: false,
    );
  }

  void onTransferMoneyClick() {
    final amount = state.amount;
    final totalWalletAmount = state.totalWalletAmount ?? 0.0;

    try {
      final amountDouble = double.tryParse(amount) ?? 0.0;

      if (amount.isEmpty ||
          amountDouble == 0.0 ||
          totalWalletAmount < amountDouble) {
        _showSnackBar(
          getString(appStr.errorPleaseEnterValidAmount, 'error_please_enter_valid_amount'),
          isError: true,
        );
        return;
      }

      final transferCreditRequest = TransferCreditRequest(
        amount: amountDouble,
        typeId: state.selectedUser?.id,
        type: state.selectedUserMenu?.type,
      );

      transferCredit(transferCreditRequest);
    } catch (_) {
      _showSnackBar(
        getString(appStr.errorPleaseEnterValidAmount, 'error_please_enter_valid_amount'),
        isError: true,
      );
    }
  }

  void onSearchPhoneNumber() {
    if (state.phoneNumber.isNotEmpty) {
      if (state.selectedUserMenu != null) {
        getSearchUser(
          countryPhoneCode: state.countryPhoneCode,
          phoneNo: state.phoneNumber,
          type: state.selectedUserMenu!.type,
          id: '',
        );
      }
    } else {
      _showSnackBar(
        getString(appStr.errorPleaseEnterPhoneNumber, 'error_please_enter_phone_number'),
        isError: true,
      );
    }
  }

  void toggleCountryPhoneCodeBottomSheet() {
    final entity = _sharedPref?.getEntity();
    final country = state.countryList
        .where((c) => c.id == entity?.countryId)
        .firstOrNull;

    if (country?.phoneCodes != null && country!.phoneCodes!.isNotEmpty) {
      final multiplePhoneCodeCountryList = country.phoneCodes!
          .map((code) => Country(
                id: country.id,
                name: country.name,
                phoneCodes: [code],
                currencyCode: country.currencyCode,
                currencySign: country.currencySign,
                alpha2: country.alpha2,
                code: country.code,
                code2: country.code2,
                timezones: country.timezones,
                isBusiness: country.isBusiness,
                phoneCode: code,
              ))
          .toList();

      state = state.copyWith(
        multiplePhoneCodeCountryList: multiplePhoneCodeCountryList,
        showCountryPhoneCodeBottomSheet: true,
      );
    }
  }

  void dismissCountryPhoneCodeBottomSheet() {
    state = state.copyWith(showCountryPhoneCodeBottomSheet: false);
  }

  void updateCountryPhoneCode(Country country) {
    state = state.copyWith(
      countryPhoneCode: country.phoneCodes?.firstOrNull ?? '',
    );
  }

  void onAddCardClick() {
    if (state.paymentGatewayList.isEmpty) return;

    final firstGateway = state.paymentGatewayList.first;

    state = state.copyWith(
      showAddCardBottomSheet: !state.showAddCardBottomSheet,
      paymentTypeSelection: PaymentMethods.card,
      paymentManager: _getPaymentManager(firstGateway.type),
    );
  }

  void dismissAddCardBottomSheet() {
    state = state.copyWith(showAddCardBottomSheet: false);
  }

  void updateSelectedGatewayForAddCard(PaymentGateway gateway) {
    state = state.copyWith(
      paymentGatewayToAddCard: gateway,
      selectedPaymentType: gateway.type,
      paymentManager: _getPaymentManager(gateway.type),
    );
  }

  void updateCardDetails(CardDetails cardDetails) {
    state = state.copyWith(selectedCardDetails: cardDetails);
  }

  void onPaymentMethodChange(CardResponse? selectedPaymentMethod) {
    if (state.selectedCardPaymentMethod?.id == selectedPaymentMethod?.id) {
      return;
    }
    state = state.copyWith(
      selectedCardPaymentMethod: selectedPaymentMethod,
      selectedPaymentMethod: selectedPaymentMethod,
    );
    _selectCard();
  }

  void onBankPaymentMethodChange(CardResponse? selectedBankPaymentMethod) {
    if (state.selectedBankPaymentMethod?.id == selectedBankPaymentMethod?.id) {
      return;
    }
    state =
        state.copyWith(selectedBankPaymentMethod: selectedBankPaymentMethod);
    _selectCard();
  }

  /// Listen for socket event to update wallet credit
  void socketForPaymentWallet() {
    _socketManager.listenEvent(
      SocketConstants.eventUpdateCredit,
      (data) {
        debugPrint('PaymentViewModel - Socket UPDATE_CREDIT received');
        getEntityDetail();
      },
    );
  }

  void disposeSocket() {
    _socketManager.offEvent(SocketConstants.eventUpdateCredit);
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    state = state.copyWith(
      snackBarMessage: message,
      isSnackBarError: isError,
    );
  }

  // ==================== Select Card API ====================

  /// PATCH API to set default card, then refresh cards
  Future<void> _selectCard() async {
    final cardId = state.selectedCardPaymentMethod?.id ?? '';
    if (cardId.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.selectCard(cardId: cardId);

    switch (response) {
      case Success():
        await getCards();
        if (state.isFromSubscription) {
          state = state.copyWith(isNavigateBack: true);
        }

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  // ==================== Bank Withdrawal ====================

  /// POST to withdraw credit to bank account
  Future<void> withdrawCredit() async {
    final request = WithdrawCreditRequest(
      amount: double.tryParse(state.bankTransferAmount),
    );

    state = state.copyWith(isLoading: true);

    final response = await _appRepository.withdrawCredit(request: request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          bankTransferAmount: '',
          taxList: [],
          showBreakDownDetail: false,
          showBankTransferBottomSheet: false,
        );
        getEntityDetail();

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  /// GET credit withdraw tax detail before confirming bank transfer
  Future<void> getCreditWithDrawDetail(double amount) async {
    state = state.copyWith(isLoading: true);

    final response =
        await _appRepository.getCreditWithdrawTaxDetail(amount: amount);

    switch (response) {
      case Success<CreditWithdrawResponse>():
        state = state.copyWith(
          isLoading: false,
          showBreakDownDetail: true,
          taxList: _createTaxItemList(response.data),
        );

      case Error():
        _showSnackBar(response.error?.message ?? '', isError: true);
        state = state.copyWith(isLoading: false);

      case Loading():
        break;
    }
  }

  /// Build TaxData list from CreditWithdrawResponse
  List<TaxData> _createTaxItemList(CreditWithdrawResponse? data) {
    final taxItemList = <TaxData>[];

    taxItemList.add(TaxData(
      taxName: getString(
          appStr.descriptionDebitAmount, 'description_debit_amount'),
      taxAmount: formatCurrency(data?.debitAmount),
    ));

    taxItemList.add(TaxData(
      taxName:
          getString(appStr.descriptionTaxAmount, 'description_tax_amount'),
      taxAmount: formatCurrency(data?.taxAmount),
      subTaxList: _createSubTaxList(data?.taxDetail),
      showDivider: true,
    ));

    taxItemList.add(TaxData(
      taxName: getString(
          appStr.descriptionBankAmount, 'description_bank_amount'),
      taxAmount: formatCurrency(data?.bankAmount),
    ));

    return taxItemList;
  }

  /// Build sub-tax pairs from TaxDetail
  List<(String, String)> _createSubTaxList(TaxDetail? taxDetail) {
    final taxList = <(String, String)>[];
    taxDetail?.taxes?.forEach((tax) {
      final entry = tax.name?.entries.where((e) => e.value.isNotEmpty).firstOrNull;
      if (entry != null) {
        taxList.add((entry.value, '${tax.value} %'));
      }
    });
    return taxList;
  }

  /// Check if bank gateway matches and allows save bank
  bool _isGetBanks(PaymentGatewayResponse? data) {
    final paymentGatewayList = data?.paymentGateways ?? [];
    final paymentGatewayForBank =
        data?.bankTransferSetting?.paymentGateway ?? 0;

    for (final gateway in paymentGatewayList) {
      if (gateway.type == paymentGatewayForBank &&
          gateway.isAllowSaveBank == true) {
        state = state.copyWith(paymentGatewayForBank: paymentGatewayForBank);
        return true;
      }
    }
    return false;
  }

  /// Validate amount input (digits + dot only)
  bool _validateAmount(String value) {
    if (value.isEmpty) return true;
    final allowedChars = {...'0123456789.'.split('')};
    return value.split('').every((c) => allowedChars.contains(c));
  }

  // ==================== Transfer Options Flow ====================

  /// Show transfer option selection or bank transfer directly
  void onShowTransferOption() {
    if (state.transferMoneyOptions.length != 1) {
      state = state.copyWith(
        showTransferOptionBottomSheet: true,
        selectedTransferOption: -1,
      );
    } else {
      state = state.copyWith(
        showBankTransferBottomSheet: true,
        selectedTransferOption: -1,
      );
    }
  }

  /// Update selected transfer option index
  void onTransferOptionSelection(int option) {
    state = state.copyWith(selectedTransferOption: option);
  }

  /// Navigate based on selected transfer option
  void onNextClick() {
    final option = state.selectedTransferOption;
    if (option == -1) return;

    if (option != state.transferMoneyOptions.length - 1) {
      // Not the last option → show transfer money to user
      state = state.copyWith(
        selectedUserMenu: state.userMenuList.length > option
            ? state.userMenuList[option]
            : null,
        showTransferMoneyBottomSheet: true,
        showTransferOptionBottomSheet: false,
      );
    } else {
      // Last option → bank transfer
      state = state.copyWith(
        showTransferOptionBottomSheet: false,
        showBankTransferBottomSheet: true,
      );
    }
  }

  /// Dismiss transfer option sheet
  void dismissTransferOptionSheet() {
    state = state.copyWith(
      showTransferOptionBottomSheet: false,
      selectedTransferOption: -1,
    );
  }

  // ==================== Bank Transfer Flow ====================

  /// Update bank transfer amount
  void onBankAmountChange(String amount) {
    if (_validateAmount(amount)) {
      state = state.copyWith(
        bankTransferAmount: amount,
        showBreakDownDetail: false,
        taxList: [],
      );
    }
  }

  /// Validate and send money to bank (get tax detail first)
  void onSendMoneyToBank() {
    try {
      final bankTransferAmount = state.bankTransferAmount;
      final totalWalletAmount = state.totalWalletAmount ?? 0.0;
      final amount = double.tryParse(bankTransferAmount) ?? 0.0;

      if (bankTransferAmount.isEmpty ||
          amount == 0.0 ||
          amount >= totalWalletAmount) {
        _showSnackBar(
          getString(appStr.errorPleaseEnterValidAmount, 'error_please_enter_valid_amount'),
          isError: true,
        );
        return;
      }

      if (state.isTransferLimitActive && amount > state.transferLimit) {
        _showSnackBar(
          getString(appStr.errorAmountIsMoreThanWithdrawLimit, 'error_amount_is_more_than_withdraw_limit'),
          isError: true,
        );
        return;
      }

      getCreditWithDrawDetail(amount);
    } catch (_) {
      _showSnackBar(
        getString(appStr.errorPleaseEnterValidAmount, 'error_please_enter_valid_amount'),
        isError: true,
      );
    }
  }

  /// Confirm bank transfer (call withdrawCredit)
  void onConfirmBankTransfer() {
    if (state.bankTransferAmount.isNotEmpty) {
      withdrawCredit();
    } else {
      _showSnackBar(
        getString(appStr.errorPleaseEnterValidAmount, 'error_please_enter_valid_amount'),
        isError: true,
      );
    }
  }

  /// Dismiss bank transfer bottom sheet and reset state
  void dismissBankTransferSheet() {
    state = state.copyWith(
      showBankTransferBottomSheet: false,
      bankTransferAmount: '',
      taxList: [],
      showBreakDownDetail: false,
    );
  }

  /// Handle WebView payment response — refresh cards or banks based on payment type
  void onPaymentResponseShow({String? message, bool success = false}) {
    if (message != null && message.isNotEmpty) {
      _showSnackBar(message, isError: !success);
    }
    if (state.paymentTypeSelection == PaymentMethods.card) {
      getCards();
    } else if (state.paymentTypeSelection == PaymentMethods.bank) {
      getBank();
    }
  }

  /// Set payment type selection to card
  void setPaymentTypeCard() {
    state = state.copyWith(paymentTypeSelection: PaymentMethods.card);
  }

  /// Set payment type selection to bank
  void setPaymentTypeBank() {
    state = state.copyWith(paymentTypeSelection: PaymentMethods.bank);
  }

  @override
  void dispose() {
    disposeSocket();
    super.dispose();
  }
}

/// Provider for PaymentViewModel
final paymentViewModelProvider =
    StateNotifierProvider.autoDispose<PaymentViewModel, PaymentState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).valueOrNull;
  final socketManager = ref.watch(socketManagerProvider);
  return PaymentViewModel(appRepository, sharedPref, socketManager);
});
