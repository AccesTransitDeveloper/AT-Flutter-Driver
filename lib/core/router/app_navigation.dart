import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import '../../models/responses/auth/country_response.dart';
import '../../models/responses/auth/city_response.dart';
import '../../models/destination_address.dart';
import '../../models/responses/home/additional_terms_item.dart';
import '../../models/webview_data_model.dart';
import '../../viewmodels/contact_us_viewmodel.dart';
import '../../models/responses/vehicle/vehicle_list_response.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../models/chat/chat_config.dart';
import '../../models/responses/booking/booking_detail_response.dart';
import '../../viewmodels/receipt_viewmodel.dart';
import '../../viewmodels/auth/register_viewmodel.dart';

/// Typed navigation extension on BuildContext.
/// Each method corresponds to a route in app_router.dart.
extension AppNavigation on BuildContext {
  // ── Common ──────────────────────────────────────────
  void goBack<T>([T? result]) => pop(result);

  // ── Auth (use go() to replace stack) ────────────────
  void navigateToLogin() => go(RoutePaths.login);
  void navigateToHome() => go(RoutePaths.home);
  void navigateToAtAiDriver({
    bool startFresh = false,
    RegisterOrigin? origin,
    String? phoneNumber,
    String? countryPhoneCode,
    String? email,
    List<Country> countries = const [],
    Country? selectedCountry,
  }) => go(
    RoutePaths.atAiDriver,
    extra: {
      'startFresh': startFresh,
      'origin': origin == RegisterOrigin.email ? 'email' : 'phone',
      'phoneNumber': phoneNumber,
      'countryPhoneCode': countryPhoneCode,
      'email': email,
      'countries': countries,
      'selectedCountry': selectedCountry,
    },
  );

  // ── Auth Flow ───────────────────────────────────────
  void navigateToVerificationPhone({
    String? phoneNumber,
    String? countryPhoneCode,
    List<Country> countries = const [],
    Country? selectedCountry,
    int otpLength = 6,
    bool supportsOtp = true,
    bool supportsPassword = false,
  }) {
    push(
      RoutePaths.verification,
      extra: {
        'loginType': 'phone',
        'phoneNumber': phoneNumber,
        'countryPhoneCode': countryPhoneCode,
        'countries': countries,
        'selectedCountry': selectedCountry,
        'otpLength': otpLength,
        'supportsOtp': supportsOtp,
        'supportsPassword': supportsPassword,
      },
    );
  }

  void navigateToVerificationEmail({
    String? email,
    int otpLength = 6,
    bool supportsOtp = true,
    bool supportsPassword = false,
  }) {
    push(
      RoutePaths.verification,
      extra: {
        'loginType': 'email',
        'email': email,
        'otpLength': otpLength,
        'supportsOtp': supportsOtp,
        'supportsPassword': supportsPassword,
      },
    );
  }

  void navigateToRegisterPhone({
    required String phoneNumber,
    required String countryPhoneCode,
    required List<Country> countries,
    Country? selectedCountry,
  }) {
    push(
      RoutePaths.register,
      extra: {
        'origin': 'phone',
        'phoneNumber': phoneNumber,
        'countryPhoneCode': countryPhoneCode,
        'countries': countries,
        'selectedCountry': selectedCountry,
      },
    );
  }

  void navigateToRegisterEmail({
    required String email,
    required List<Country> countries,
    Country? selectedCountry,
  }) {
    push(
      RoutePaths.register,
      extra: {
        'origin': 'email',
        'email': email,
        'countries': countries,
        'selectedCountry': selectedCountry,
      },
    );
  }

  void navigateToRegisterFromAi({
    required RegisterOrigin origin,
    required List<Country> countries,
    Country? selectedCountry,
    String? phoneNumber,
    String? countryPhoneCode,
    String? email,
    ConfirmedRegistrationPrefill? confirmedPrefill,
  }) => push(
    RoutePaths.register,
    extra: {
      'origin': origin == RegisterOrigin.email ? 'email' : 'phone',
      'phoneNumber': phoneNumber,
      'countryPhoneCode': countryPhoneCode,
      'email': email,
      'countries': countries,
      'selectedCountry': selectedCountry,
      'confirmedPrefill': confirmedPrefill,
    },
  );

  void navigateToForgotPasswordPhone({
    required String phoneNumber,
    required String countryPhoneCode,
    int otpLength = 6,
  }) {
    push(
      RoutePaths.forgotPassword,
      extra: {
        'loginType': 'phone',
        'phoneNumber': phoneNumber,
        'countryPhoneCode': countryPhoneCode,
        'otpLength': otpLength,
      },
    );
  }

  void navigateToForgotPasswordEmail({
    required String email,
    int otpLength = 6,
  }) {
    push(
      RoutePaths.forgotPassword,
      extra: {'loginType': 'email', 'email': email, 'otpLength': otpLength},
    );
  }

  void navigateToCreatePassword() {
    push(RoutePaths.createPassword);
    // TODO: Add extra params as needed
  }

  // ── Account ────────────────────────────────────────
  void navigateToAccount() => push(RoutePaths.account);

  // ── Profile ─────────────────────────────────────────
  Future<T?> navigateToProfile<T>() => push<T>(RoutePaths.profile);

  Future<T?> navigateToEditProfile<T>(EditProfileField field) =>
      push<T>(RoutePaths.editProfile, extra: field);

  Future<void> navigateToDocuments() => push(RoutePaths.documents);

  void navigateToReferral() => push(RoutePaths.referral);
  void navigateToReferralList() => push(RoutePaths.referralList);

  // ── Settings ────────────────────────────────────────
  void navigateToSettings() => push(RoutePaths.settings);

  Future<DestinationAddress?> navigateToSelectLocation({
    DestinationAddress? initialAddress,
  }) => push<DestinationAddress>(
    RoutePaths.selectLocation,
    extra: initialAddress,
  );

  // ── Booking ─────────────────────────────────────────
  void navigateToCurrentRide({required String bookingId}) {
    push('/current-ride/$bookingId');
  }

  // ── Activity / History ──────────────────────────────
  void navigateToActivity() => push(RoutePaths.activity);

  void navigateToTripDetail({required String bookingId}) {
    push('/trip-detail/$bookingId');
  }

  /// Resolves with `true` when the booking was cancelled on the detail screen.
  Future<Object?> navigateToUpcomingTripDetail({required String bookingId}) {
    return push<Object?>('/upcoming-trip-detail/$bookingId');
  }

  void navigateToUpcomingTripDetailFromMarketplace({
    required String bookingId,
  }) {
    push('/upcoming-trip-detail/$bookingId', extra: true);
  }

  // ── Bidding ────────────────────────────────────────
  void navigateToBiddingRequests() => push(RoutePaths.biddingRequests);

  // ── Opportunities ───────────────────────────────────
  void navigateToOpportunities() => push(RoutePaths.opportunities);

  // ── Marketplace ───────────────────────────────────
  void navigateToMarketplace() => push(RoutePaths.marketplace);

  // ── Create Request ──────────────────────────────────
  void navigateToCreateRequest() => push(RoutePaths.createRequest);

  // ── Subscription ────────────────────────────────────
  void navigateToSubscription() => push(RoutePaths.subscription);

  // ── Earnings ────────────────────────────────────────
  void navigateToEarnings() => push(RoutePaths.earnings);

  // ── Redeem ──────────────────────────────────────────
  void navigateToRedeem() => push(RoutePaths.redeem);

  // ── Wallet ──────────────────────────────────────────
  void navigateToWallet() => push(RoutePaths.wallet);
  void navigateToWalletHistory() => push(RoutePaths.walletHistory);

  Future<bool?> navigateToWalletForSubscription() =>
      push<bool>(RoutePaths.wallet, extra: {'isFromSubscription': true});

  // ── Support ─────────────────────────────────────────
  void navigateToContactUs() => push(RoutePaths.contactUs);

  Future<bool?> navigateToTicketDetail(SupportTicketItem ticket) {
    return push<bool>(RoutePaths.ticketDetail, extra: ticket);
  }

  void navigateToInbox() => push(RoutePaths.inbox);

  void navigateToChat({required ChatConfig chatConfig}) {
    push(RoutePaths.chat, extra: chatConfig);
  }

  // ── Hub ────────────────────────────────────────────
  void navigateToHub() => push(RoutePaths.hub);

  // ── Country/City ────────────────────────────────────
  Future<bool?> navigateToSelectCountryCity({
    bool needsCountry = true,
    String? existingCountryId,
  }) => push<bool>(
    RoutePaths.selectCountryCity,
    extra: {
      'needsCountry': needsCountry,
      'existingCountryId': existingCountryId,
    },
  );

  // ── Vehicle ────────────────────────────────────────
  void navigateToVehicles() => push(RoutePaths.vehicles);

  Future<T?> navigateToAddEditVehicle<T>({Vehicle? vehicle}) =>
      push<T>(RoutePaths.addEditVehicle, extra: vehicle);

  // ── Feedback ──────────────────────────────────────
  void navigateToFeedback({
    required String bookingId,
    bool isFromHistory = true,
  }) {
    push('/feedback/$bookingId', extra: {'isFromHistory': isFromHistory});
  }

  // ── Receipt ────────────────────────────────────────
  void navigateToReceipt({
    required Booking booking,
    required Set<String> activeSetting,
    bool isPartnerDriver = false,
  }) {
    push(
      RoutePaths.receipt,
      extra: ReceiptParams(
        booking: booking,
        activeSetting: activeSetting,
        isPartnerDriver: isPartnerDriver,
      ),
    );
  }

  // ── Other ───────────────────────────────────────────
  void navigateToImageViewer({required String imageUrl}) {
    push(RoutePaths.imageViewer, extra: imageUrl);
  }

  Future<bool?> pushToAdditionalTerms(AdditionalTermsItem termsItem) =>
      push<bool>(RoutePaths.additionalTerms, extra: termsItem);

  /// Returns once the WebView is popped, so callers can refresh state that the
  /// in-WebView flow may have changed (e.g. Checkr background verification).
  Future<void> navigateToWebView({
    WebViewDataModel? webViewData,
    void Function(String?)? onPaymentData,
  }) {
    return push(
      RoutePaths.webview,
      extra: {'webViewData': webViewData, 'onPaymentData': onPaymentData},
    );
  }

  Future<City?> navigateToCitySelection(String countryId) async {
    final result = await push<City>(
      RoutePaths.citySelection,
      extra: {'countryId': countryId},
    );
    return result;
  }
}
