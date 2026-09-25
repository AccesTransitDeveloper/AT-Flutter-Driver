import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/socket_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/managers/socket_manager.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/subscription_request.dart';
import '../models/responses/home/subscription_detail_response.dart';
import '../models/responses/payment/payment_intent_response.dart';
import '../models/responses/subscription/subscription_response.dart';
import '../models/webview_data_model.dart';

/// UI-ready subscription item (pre-formatted for display)
class SubscriptionDetail {
  final String? id;
  final int? status;
  final String? vehicleSubscriptionId;
  final String? typeId;
  final String? vehicleTypeId;
  final String title;
  final String subTitle;
  final String price;
  final String? upgradePrice;
  final String description;
  final String? tag;
  final String? strButtonAction;
  final bool isFreeTrialActive;
  final bool isShowCancel;
  final bool isShowUpgrade;
  final bool isShowRenew;
  final bool isSelected;

  const SubscriptionDetail({
    this.id,
    this.status,
    this.vehicleSubscriptionId,
    this.typeId,
    this.vehicleTypeId,
    this.title = '',
    this.subTitle = '',
    this.price = '',
    this.upgradePrice,
    this.description = '',
    this.tag,
    this.strButtonAction,
    this.isFreeTrialActive = false,
    this.isShowCancel = false,
    this.isShowUpgrade = false,
    this.isShowRenew = false,
    this.isSelected = false,
  });

  SubscriptionDetail copyWith({bool? isSelected, String? upgradePrice, String? strButtonAction}) {
    return SubscriptionDetail(
      id: id,
      status: status,
      vehicleSubscriptionId: vehicleSubscriptionId,
      typeId: typeId,
      vehicleTypeId: vehicleTypeId,
      title: title,
      subTitle: subTitle,
      price: price,
      upgradePrice: upgradePrice ?? this.upgradePrice,
      description: description,
      tag: tag,
      strButtonAction: strButtonAction ?? this.strButtonAction,
      isFreeTrialActive: isFreeTrialActive,
      isShowCancel: isShowCancel,
      isShowUpgrade: isShowUpgrade,
      isShowRenew: isShowRenew,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SubscriptionState {
  final bool isMainLoading;
  final bool isListLoading;
  final List<SubscriptionDetail> activeSubscriptionList;
  final List<SubscriptionDetail> subscriptionList;
  final SubscriptionDetail? selectedSubscription;
  final bool showActionBottomSheet;
  final bool isNavigateToWebView;
  final bool isNavigateToPayment;
  final WebViewDataModel? navigateWebViewData;
  final String? snackBarMessage;
  final String? error;

  const SubscriptionState({
    this.isMainLoading = false,
    this.isListLoading = false,
    this.activeSubscriptionList = const [],
    this.subscriptionList = const [],
    this.selectedSubscription,
    this.showActionBottomSheet = false,
    this.isNavigateToWebView = false,
    this.isNavigateToPayment = false,
    this.navigateWebViewData,
    this.snackBarMessage,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isMainLoading,
    bool? isListLoading,
    List<SubscriptionDetail>? activeSubscriptionList,
    List<SubscriptionDetail>? subscriptionList,
    SubscriptionDetail? selectedSubscription,
    bool? showActionBottomSheet,
    bool? isNavigateToWebView,
    bool? isNavigateToPayment,
    WebViewDataModel? navigateWebViewData,
    String? snackBarMessage,
    String? error,
  }) {
    return SubscriptionState(
      isMainLoading: isMainLoading ?? this.isMainLoading,
      isListLoading: isListLoading ?? this.isListLoading,
      activeSubscriptionList:
          activeSubscriptionList ?? this.activeSubscriptionList,
      subscriptionList: subscriptionList ?? this.subscriptionList,
      selectedSubscription: selectedSubscription ?? this.selectedSubscription,
      showActionBottomSheet:
          showActionBottomSheet ?? this.showActionBottomSheet,
      isNavigateToWebView: isNavigateToWebView ?? this.isNavigateToWebView,
      isNavigateToPayment: isNavigateToPayment ?? this.isNavigateToPayment,
      navigateWebViewData: navigateWebViewData,
      snackBarMessage: snackBarMessage,
      error: error,
    );
  }
}

class SubscriptionViewModel extends StateNotifier<SubscriptionState> {
  final AppRepository _repository;
  final SharedPreferenceManager? _sharedPref;

  // Currency settings
  late final String _currencySign;
  late final int _currencyDirection;
  late final int _decimalPoints;
  late final int _paymentGateway;
  late final bool _isAllowUpgrade;

  // Flow tracking (matches Kotlin isCreateSubscription / vehicleSubscriptionId)
  bool _isCreateSubscription = false;
  String? _vehicleSubscriptionId;

  SubscriptionViewModel(this._repository, this._sharedPref)
      : super(const SubscriptionState()) {
    _initSettings();
    loadSubscriptions();
    _listenSubscriptionStatus();
  }

  void _initSettings() {
    final setting = _sharedPref?.getSetting();
    _currencySign = setting?.currencySign ?? '';
    _currencyDirection = setting?.setCurrencySign ?? 1;
    _decimalPoints = setting?.decimalPointValue ?? 2;
    _paymentGateway =
        setting?.subscriptionConfig?.paymentGateway ?? PaymentGatewayType.stripe.value;
    _isAllowUpgrade =
        setting?.subscriptionConfig?.isAllowSubscriptionUpgrade ?? false;
  }

  /// Whether the configured payment gateway proceeds directly (no card selection needed)
  bool get _isDirectPaymentGateway {
    final type = PaymentGatewayType.fromValue(_paymentGateway);
    return type == PaymentGatewayType.razorpay ||
        type == PaymentGatewayType.mercado ||
        type == PaymentGatewayType.payu ||
        type == PaymentGatewayType.pago ||
        type == PaymentGatewayType.pagoC2p ||
        type == PaymentGatewayType.zaincash ||
        type == PaymentGatewayType.hyperpay ||
        type == PaymentGatewayType.nestpay ||
        type == PaymentGatewayType.qicard ||
        type == PaymentGatewayType.mpesa;
  }

  Future<void> loadSubscriptions() async {
    state = state.copyWith(isListLoading: true);

    final response = await _repository.getSubscriptionVehicle();

    switch (response) {
      case Success<SubscriptionResponse>():
        final data = response.data;
        _processSubscriptionList(
          vehicleSubscriptions: data?.vehicleSubscriptions ?? [],
          subscriptions: data?.subscriptions ?? [],
        );
      case Error():
        state = state.copyWith(
          isListLoading: false,
          error: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  void _processSubscriptionList({
    required List<VehicleSubscription> vehicleSubscriptions,
    required List<SubscriptionInfo> subscriptions,
  }) {
    final activeList = <SubscriptionDetail>[];
    final availableList = <SubscriptionDetail>[];

    // Map active vehicle subscriptions
    for (final vs in vehicleSubscriptions) {
      final sub = vs.subscription;
      final pkg = sub?.subscriptionPackage;

      final detail = SubscriptionDetail(
        id: sub?.id,
        status: vs.status,
        vehicleSubscriptionId: vs.id,
        typeId: vs.typeId,
        vehicleTypeId: sub?.vehicleTypeId,
        title: pkg?.name ?? '',
        subTitle: sub?.vehicleTypeName ?? '',
        price: _formatPrice(pkg?.price),
        description: _buildBenefitsDescription(pkg),
        tag: _getStatusTag(vs),
        // iOS: all active subs show cancel button regardless of driver type
        strButtonAction: _getActionButtonText(vs.status),
        isFreeTrialActive: pkg?.freeTrial?.isActive == true,
        isShowCancel: vs.status == VehicleSubscriptionStatus.active,
        isShowUpgrade: false,
        isShowRenew: vs.status == VehicleSubscriptionStatus.inactive ||
            vs.status == VehicleSubscriptionStatus.expired,
        isSelected: true, // Active subs always highlighted
      );
      activeList.add(detail);
    }

    // Map available subscriptions for purchase/upgrade
    for (final sub in subscriptions) {
      final pkg = sub.subscriptionPackage;

      // Check if there's an active sub with matching vehicleTypeId for upgrade
      final matchingActiveSub = activeList.cast<SubscriptionDetail?>().firstWhere(
        (e) =>
            e?.vehicleTypeId == sub.vehicleTypeId &&
            e?.status == VehicleSubscriptionStatus.active,
        orElse: () => null,
      );

      final canUpgrade =
          _isAllowUpgrade && matchingActiveSub != null;

      // Build tag: days + optional free trial (matching Kotlin/iOS)
      final period = sub.subscriptionPeriod;
      String tag = '';
      bool isFreeTrialActive = false;
      if (period != null) {
        if (period == 36500) {
          tag = getString(appStr.descriptionLifeTimePlan, 'description_life_time_plan');
        } else {
          tag = getString(appStr.descriptionValueDays, 'description_value_days')
              .replaceAll('{{_VALUE}}', period.toString());
        }

        final freeTrial = pkg?.freeTrial;
        if (freeTrial?.isActive == true && (freeTrial?.days ?? 0) > 0) {
          isFreeTrialActive = true;
          final freeTrialTag = getString(
                  appStr.descriptionValueFreeTrial, 'description_value_free_trial')
              .replaceAll('{{_VALUE}}', freeTrial!.days!.toInt().toString());
          tag = '$freeTrialTag + $tag';
        }
      }

      final detail = SubscriptionDetail(
        id: sub.id,
        vehicleTypeId: sub.vehicleTypeId,
        title: pkg?.name ?? '',
        subTitle: sub.vehicleTypeName ?? '',
        price: _formatPrice(pkg?.price),
        description: _buildBenefitsDescription(pkg),
        tag: tag.isNotEmpty ? tag : null,
        isFreeTrialActive: isFreeTrialActive,
        isShowUpgrade: canUpgrade,
        strButtonAction: canUpgrade
            ? getString(appStr.buttonUpgrade ?? appStr.buttonUpdate, 'button_upgrade')
            : null,
      );
      availableList.add(detail);

      // Fetch upgrade price for this available sub if applicable
      if (canUpgrade && matchingActiveSub.vehicleSubscriptionId != null) {
        _fetchUpgradePriceForAvailableSub(
          vehicleSubscriptionId: matchingActiveSub.vehicleSubscriptionId ?? '',
          subscriptionId: sub.id ?? '',
          availableSubIndex: availableList.length - 1,
        );
      }
    }

    state = state.copyWith(
      isListLoading: false,
      activeSubscriptionList: activeList,
      subscriptionList: availableList,
    );
  }

  /// Fetches upgrade price for a specific available subscription and updates the list
  Future<void> _fetchUpgradePriceForAvailableSub({
    required String vehicleSubscriptionId,
    required String subscriptionId,
    required int availableSubIndex,
  }) async {
    final response = await _repository.getSubscriptionVehicleUpgrade(
      vehicleSubscriptionId: vehicleSubscriptionId,
      subscriptionId: subscriptionId,
    );

    if (response is Success<SubscriptionVehicleUpgradeResponse>) {
      final upgradePrice = _formatPrice(response.data?.paidAmount);
      if (upgradePrice.isNotEmpty && mounted) {
        final updatedList = List<SubscriptionDetail>.from(state.subscriptionList);
        if (availableSubIndex < updatedList.length) {
          updatedList[availableSubIndex] = updatedList[availableSubIndex].copyWith(
            upgradePrice: upgradePrice,
          );
          state = state.copyWith(subscriptionList: updatedList);
        }
      }
    }
  }

  String _formatPrice(double? value) {
    if (value == null) return '';
    final formatted = value.toStringAsFixed(_decimalPoints);
    if (_currencySign.isEmpty) return formatted;
    if (_currencyDirection == SetCurrencySign.right) {
      return '$formatted$_currencySign';
    }
    return '$_currencySign$formatted';
  }

  String _buildBenefitsDescription(SubscriptionPackage? pkg) {
    if (pkg == null) return '';
    final benefits = <String>[];

    void addBenefit(String label, SubscriptionPackageValue? val) {
      if (val == null || val.isActive != true) return;
      final v = val.value?.toInt().toString() ?? '';
      benefits.add('$label: $v');
    }

    addBenefit(
        getString(appStr.descriptionMaxBookingsPerDay ?? '',
            'description_max_bookings_per_day'),
        pkg.maxBookingsReceivedPerDay);
    addBenefit(
        getString(appStr.descriptionMaxBiddingBookings ?? '',
            'description_max_bidding_bookings'),
        pkg.maxBiddingBookingsAllowed);
    addBenefit(
        getString(appStr.descriptionMaxScheduledRides ?? '',
            'description_max_scheduled_rides'),
        pkg.maxScheduledRidesPerDay);
    addBenefit(
        getString(appStr.descriptionMaxCancelledBookings ?? '',
            'description_max_cancelled_bookings'),
        pkg.maxCanceledBookingsAllowed);
    addBenefit(
        getString(appStr.descriptionMaxExtraBookings ?? '',
            'description_max_extra_bookings'),
        pkg.maxExtraBookingsAllowed);

    if (pkg.maxDailyRevenue?.isActive == true) {
      benefits.add(
          '${getString(appStr.descriptionMaxDailyRevenue ?? '', 'description_max_daily_revenue')}: ${_formatPrice(pkg.maxDailyRevenue?.value)}');
    }
    if (pkg.maxTotalRevenue?.isActive == true) {
      benefits.add(
          '${getString(appStr.descriptionMaxTotalRevenue ?? '', 'description_max_total_revenue')}: ${_formatPrice(pkg.maxTotalRevenue?.value)}');
    }
    if (pkg.minWalletBalance?.isActive == true) {
      benefits.add(
          '${getString(appStr.descriptionMinWalletBalance ?? '', 'description_min_wallet_balance')}: ${_formatPrice(pkg.minWalletBalance?.value)}');
    }
    if (pkg.isMarketplaceAccess == true) {
      benefits.add(getString(appStr.descriptionMarketplaceAccess ?? '',
          'description_marketplace_access'));
    }
    if (pkg.isApplyIncentive == true) {
      benefits.add(getString(
          appStr.descriptionApplyIncentive ?? '', 'description_apply_incentive'));
    }
    if (pkg.isApplyReward == true) {
      benefits.add(getString(
          appStr.descriptionApplyReward ?? '', 'description_apply_reward'));
    }

    return benefits.join('\n');
  }

  String? _getStatusTag(VehicleSubscription vs) {
    if (vs.status == VehicleSubscriptionStatus.pending) {
      return getString(
          appStr.descriptionPaymentPending ?? '', 'description_payment_pending');
    }
    if (vs.status == VehicleSubscriptionStatus.expired) {
      return getString(appStr.descriptionExpired, 'description_expired');
    }

    final remaining = vs.remainingTimeInMillis;
    if (remaining == null || remaining <= 0) return null;

    final days = (remaining / (1000 * 60 * 60 * 24)).floor();
    if (days <= 0) {
      return getString(
          appStr.descriptionExpiresSoon ?? '', 'description_expires_soon');
    }
    final daysStr = getString(
        appStr.descriptionExpiresInDays ?? '', 'description_expires_in_days');
    return daysStr.replaceAll('{{_VALUE}}', days.toString());
  }

  String? _getActionButtonText(int? status) {
    return switch (status) {
      VehicleSubscriptionStatus.active => getString(
          appStr.buttonCancel, 'button_cancel'),
      VehicleSubscriptionStatus.pending => getString(
          appStr.descriptionPayment ?? appStr.buttonSubmit, 'description_payment'),
      VehicleSubscriptionStatus.inactive ||
      VehicleSubscriptionStatus.expired => getString(
          appStr.buttonRenew ?? appStr.buttonUpdate, 'button_renew'),
      _ => null,
    };
  }

  // ── User actions ──────────────────────────────────────

  /// Selection only applies to available subscription list
  void selectSubscription(SubscriptionDetail item) {
    final updatedAvailable = state.subscriptionList
        .map((e) => e.copyWith(isSelected: e.id == item.id))
        .toList();
    state = state.copyWith(
      subscriptionList: updatedAvailable,
      selectedSubscription: item,
    );
  }

  /// All action button clicks show the bottom sheet first (matching Kotlin flow)
  void onActionButtonTap(SubscriptionDetail item) {
    state = state.copyWith(
      selectedSubscription: item,
      showActionBottomSheet: true,
    );
  }

  /// "Yes Sure" on bottom sheet → determine action based on item status/flags
  void confirmAction() {
    state = state.copyWith(showActionBottomSheet: false);
    final selected = state.selectedSubscription;
    if (selected == null) return;
    _proceedSubscriptionAction(selected);
  }

  /// Matches Kotlin proceedSubscriptionAction() — routes based on status and gateway type.
  /// Key: always find the matching ACTIVE subscription to get vehicleSubscriptionId,
  /// since available subs don't have one.
  void _proceedSubscriptionAction(SubscriptionDetail item) {
    // Find matching active subscription by vehicleTypeId (matches Kotlin actionPackageDetail)
    final activeMatch = state.activeSubscriptionList.cast<SubscriptionDetail?>().firstWhere(
      (e) => e?.vehicleTypeId == item.vehicleTypeId,
      orElse: () => null,
    );

    // Use active match's status if available, otherwise use item's own status
    final effectiveStatus = activeMatch?.status ?? item.status;
    final effectiveVsId = activeMatch?.vehicleSubscriptionId ?? item.vehicleSubscriptionId;

    if (effectiveStatus == VehicleSubscriptionStatus.active) {
      // Active subscription: cancel or upgrade
      if (item.isShowCancel && effectiveVsId != null) {
        _cancelSubscription(effectiveVsId);
      } else if (item.isShowUpgrade && effectiveVsId != null) {
        _upgradeSubscription(effectiveVsId, item.id ?? '');
      }
    } else if (effectiveStatus == VehicleSubscriptionStatus.pending ||
        effectiveStatus == VehicleSubscriptionStatus.inactive ||
        effectiveStatus == VehicleSubscriptionStatus.expired) {
      // Pending/Inactive/Expired: pay or renew via gateway routing
      _vehicleSubscriptionId = effectiveVsId;
      _isCreateSubscription = false;
      if (_isDirectPaymentGateway) {
        _proceedSubscription();
      } else {
        state = state.copyWith(isNavigateToPayment: true);
      }
    }
  }

  /// Matches Kotlin PurchaseSubscriptionClick — new subscription purchase
  void onPurchaseTap() {
    final selected = state.selectedSubscription;
    if (selected == null || (selected.id ?? '').isEmpty) {
      state = state.copyWith(
        snackBarMessage: getString(
            appStr.errorPleaseSelectSubscription ?? '',
            'error_please_select_subscription'),
      );
      return;
    }

    _isCreateSubscription = true;
    if (_isDirectPaymentGateway) {
      _proceedSubscription();
    } else {
      state = state.copyWith(isNavigateToPayment: true);
    }
  }

  /// Central routing method (matches Kotlin proceedSubscription)
  void _proceedSubscription() {
    if (_isCreateSubscription) {
      final selected = state.selectedSubscription;
      if (selected != null) _createSubscription(selected);
    } else if (_vehicleSubscriptionId != null) {
      _subscriptionInvoice(_vehicleSubscriptionId!);
    }
  }

  /// Called from screen after returning from wallet/payment screen with card selected
  void proceedAfterCardSelect() {
    _proceedSubscription();
  }

  void dismissActionSheet() {
    state = state.copyWith(showActionBottomSheet: false);
  }

  void clearWebViewNavigation() {
    state = state.copyWith(isNavigateToWebView: false);
  }

  void clearPaymentNavigation() {
    state = state.copyWith(isNavigateToPayment: false);
  }

  // ── API calls ─────────────────────────────────────────

  Future<void> _createSubscription(SubscriptionDetail item) async {
    if (item.id == null) return;
    state = state.copyWith(isMainLoading: true);

    final gatewayType = PaymentGatewayType.fromValue(_paymentGateway);
    final gatewayStr = _paymentGateway.toString();

    final response = await _repository.subscriptionCreate(
      paymentGateway: gatewayStr,
      request: SubscriptionCreateRequest(subscriptionId: item.id),
    );

    switch (response) {
      case Success<PaymentIntentResponse>():
        state = state.copyWith(isMainLoading: false);
        _handlePaymentResponse(response.data, gatewayType);
      case Error():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  void _handlePaymentResponse(
      PaymentIntentResponse? data, PaymentGatewayType? gatewayType) {
    if (data == null) return;

    final intent = data.intent;
    final url = intent?.url ?? intent?.authorizationUrl ?? '';
    final html = intent?.html ?? '';

    if (url.isNotEmpty || html.isNotEmpty) {
      state = state.copyWith(
        isNavigateToWebView: true,
        navigateWebViewData: WebViewDataModel(
          webURL: url.isNotEmpty ? url : null,
          webContent: html.isNotEmpty ? html : null,
        ),
      );
    }
  }

  /// Matches Kotlin subscriptionInvoice() — for renewals/pending payments
  Future<void> _subscriptionInvoice(String vehicleSubscriptionId) async {
    state = state.copyWith(isMainLoading: true);

    final response = await _repository.getSubscriptionInvoice(
      vehicleSubscriptionId: vehicleSubscriptionId,
    );

    switch (response) {
      case Success<SubscriptionInvoiceResponse>():
        state = state.copyWith(isMainLoading: false);
        final url = response.data?.transactionReference?.url;
        if (url != null && url.isNotEmpty) {
          _openUrlInBrowser(url);
        }
        loadSubscriptions();
      case Error():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  Future<void> _openUrlInBrowser(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _cancelSubscription(String vehicleSubscriptionId) async {
    state = state.copyWith(isMainLoading: true);

    final response = await _repository.subscriptionCancel(
      vehicleSubscriptionId: vehicleSubscriptionId,
    );

    switch (response) {
      case Success():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.message,
        );
        loadSubscriptions();
      case Error():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  Future<void> _upgradeSubscription(String vehicleSubscriptionId, String subscriptionId) async {
    state = state.copyWith(isMainLoading: true, showActionBottomSheet: false);

    final response = await _repository.subscriptionUpgrade(
      vehicleSubscriptionId: vehicleSubscriptionId,
      request: SubscriptionUpgradeRequest(subscriptionId: subscriptionId),
    );

    switch (response) {
      case Success():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.message,
        );
        loadSubscriptions();
      case Error():
        state = state.copyWith(
          isMainLoading: false,
          snackBarMessage: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  // ── Socket listener ─────────────────────────────────────

  void _listenSubscriptionStatus() {
    SocketManager.instance.listenEvent(
      SocketConstants.eventSubscriptionStatus,
      (data) {
        if (data is Map<String, dynamic>) {
          final status = data['status'];
          final url = data['transactionReference']?['url'] as String?;
          if (status == VehicleSubscriptionStatus.pending &&
              url != null &&
              url.isNotEmpty) {
            _openUrlInBrowser(url);
          }
          loadSubscriptions();
        }
      },
    );
  }

  @override
  void dispose() {
    SocketManager.instance.offEvent(SocketConstants.eventSubscriptionStatus);
    super.dispose();
  }
}

final subscriptionViewModelProvider = StateNotifierProvider.autoDispose<
    SubscriptionViewModel, SubscriptionState>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).valueOrNull;
  return SubscriptionViewModel(repo, sharedPref);
});
