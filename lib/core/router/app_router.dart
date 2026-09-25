import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import 'app_route_observer.dart';

import '../../views/screens/splash/splash_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/verification_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/auth/city_screen.dart';
import '../../views/screens/auth/forgot_password_screen.dart';
import '../../views/screens/home/home_screen.dart';
import '../../views/screens/account/account_screen.dart';
import '../../views/screens/profile/profile_screen.dart';
import '../../views/screens/profile/edit_profile_screen.dart';
import '../../views/screens/documents/document_screen.dart';
import '../../views/screens/referral/referral_screen.dart';
import '../../views/screens/referral/referral_list_screen.dart';
import '../../views/screens/inbox/inbox_screen.dart';
import '../../views/screens/earnings/earnings_screen.dart';
import '../../views/screens/subscription/subscription_screen.dart';
import '../../views/screens/opportunity/opportunities_screen.dart';
import '../../views/screens/bidding/bidding_request_screen.dart';
import '../../views/screens/marketplace/marketplace_screen.dart';
import '../../views/screens/redeem/redeem_screen.dart';
import '../../views/screens/settings/settings_screen.dart';
import '../../views/screens/settings/select_location_screen.dart';
import '../../models/destination_address.dart';
import '../../views/screens/support/contact_us_screen.dart';
import '../../views/screens/support/ticket_detail_screen.dart';
import '../../views/screens/legal/webview_screen.dart';
import '../../views/screens/wallet/wallet_screen.dart';
import '../../views/screens/wallet/wallet_history_screen.dart';
import '../../models/webview_data_model.dart';
import '../../viewmodels/contact_us_viewmodel.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../models/responses/auth/country_response.dart';
import '../../models/responses/vehicle/vehicle_list_response.dart';
import '../../views/screens/hub/hub_screen.dart';
import '../../views/screens/vehicle/vehicle_screen.dart';
import '../../views/screens/vehicle/add_edit_vehicle_screen.dart';
import '../../views/screens/home/select_country_city_screen.dart';
import '../../views/screens/home/additional_terms_screen.dart';
import '../../models/responses/home/additional_terms_item.dart';
import '../../views/screens/trip/trip_screen.dart';
import '../../views/screens/chat/chat_screen.dart';
import '../../views/screens/chat/image_viewer_screen.dart';
import '../../models/chat/chat_config.dart';
import '../../views/screens/activity/activity_screen.dart';
import '../../views/screens/trip/trip_detail_screen.dart';
import '../../views/screens/trip/upcoming_trip_detail_screen.dart';
import '../../views/screens/receipt/receipt_screen.dart';
import '../../viewmodels/receipt_viewmodel.dart';
import '../../views/screens/feedback/feedback_screen.dart';
import '../../views/screens/create_request/create_request_screen.dart';
import '../../features/at_ai_driver/presentation/at_ai_driver_screen.dart';
import '../../viewmodels/auth/register_viewmodel.dart';

/// Temporary placeholder widget used until actual screens are built.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('TODO: Implement $title')),
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    observers: [routeObserver],
    routes: [
      // ── Auth ──────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.verification,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          final loginType = params['loginType'] as String;
          final otpLength = params['otpLength'] as int? ?? 6;
          final supportsOtp = params['supportsOtp'] as bool? ?? true;
          final supportsPassword = params['supportsPassword'] as bool? ?? false;

          if (loginType == 'phone') {
            return VerificationScreen.phone(
              phoneNumber: params['phoneNumber'] as String?,
              countryPhoneCode: params['countryPhoneCode'] as String?,
              countries: (params['countries'] as List<Country>?) ?? const [],
              selectedCountry: params['selectedCountry'] as Country?,
              otpLength: otpLength,
              supportsOtp: supportsOtp,
              supportsPassword: supportsPassword,
            );
          } else {
            return VerificationScreen.email(
              initialEmail: params['email'] as String?,
              otpLength: otpLength,
              supportsOtp: supportsOtp,
              supportsPassword: supportsPassword,
            );
          }
        },
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          final origin = params['origin'] as String;
          final countries = params['countries'] as List<Country>? ?? [];
          final selectedCountry = params['selectedCountry'] as Country?;

          if (origin == 'phone') {
            return RegisterScreen.phone(
              phoneNumber: params['phoneNumber'] as String,
              countryPhoneCode: params['countryPhoneCode'] as String,
              countries: countries,
              selectedCountry: selectedCountry,
              confirmedPrefill:
                  params['confirmedPrefill'] as ConfirmedRegistrationPrefill?,
            );
          } else {
            return RegisterScreen.email(
              email: params['email'] as String,
              countries: countries,
              selectedCountry: selectedCountry,
              confirmedPrefill:
                  params['confirmedPrefill'] as ConfirmedRegistrationPrefill?,
            );
          }
        },
      ),
      GoRoute(
        path: RoutePaths.atAiDriver,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return AtAiDriverScreen(
            startFresh: params?['startFresh'] as bool? ?? false,
            origin: params?['origin'] == 'email'
                ? RegisterOrigin.email
                : RegisterOrigin.phone,
            phoneNumber: params?['phoneNumber'] as String?,
            countryPhoneCode: params?['countryPhoneCode'] as String?,
            email: params?['email'] as String?,
            countries: (params?['countries'] as List<Country>?) ?? const [],
            selectedCountry: params?['selectedCountry'] as Country?,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          final loginType = params['loginType'] as String;
          final otpLength = params['otpLength'] as int? ?? 6;

          if (loginType == 'phone') {
            return ForgotPasswordScreen.phone(
              phoneNumber: params['phoneNumber'] as String,
              countryPhoneCode: params['countryPhoneCode'] as String,
              otpLength: otpLength,
            );
          } else {
            return ForgotPasswordScreen.email(
              email: params['email'] as String,
              otpLength: otpLength,
            );
          }
        },
      ),
      GoRoute(
        path: RoutePaths.createPassword,
        builder: (context, state) {
          // TODO: Extract params from state.extra as Map<String, dynamic>
          return const _PlaceholderScreen(title: 'Create Password');
        },
      ),

      // ── Main (bottom nav) ─────────────────────────────
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Account ────────────────────────────────────────
      GoRoute(
        path: RoutePaths.account,
        builder: (context, state) => const AccountScreen(),
      ),

      // ── Profile ───────────────────────────────────────
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        builder: (context, state) {
          final field = state.extra as EditProfileField;
          return EditProfileScreen(field: field);
        },
      ),
      GoRoute(
        path: RoutePaths.documents,
        builder: (context, state) => const DocumentScreen(),
      ),
      GoRoute(
        path: RoutePaths.referral,
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: RoutePaths.referralList,
        builder: (context, state) => const ReferralListScreen(),
      ),

      // ── Settings ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.selectLocation,
        builder: (context, state) {
          final initialAddress = state.extra as DestinationAddress?;
          return SelectLocationScreen(initialAddress: initialAddress);
        },
      ),

      // ── Booking ───────────────────────────────────────
      GoRoute(
        path: RoutePaths.currentRide,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return TripScreen(bookingId: bookingId);
        },
      ),

      // ── Activity / History ────────────────────────────
      GoRoute(
        path: RoutePaths.activity,
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: RoutePaths.tripDetail,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return TripDetailScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RoutePaths.upcomingTripDetail,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final isMarketPlace = state.extra as bool? ?? false;
          return UpcomingTripDetailScreen(
            bookingId: bookingId,
            isMarketPlace: isMarketPlace,
          );
        },
      ),

      // ── Opportunities ────────────────────────────────
      GoRoute(
        path: RoutePaths.opportunities,
        builder: (context, state) => const OpportunitiesScreen(),
      ),

      // ── Bidding ────────────────────────────────────────
      GoRoute(
        path: RoutePaths.biddingRequests,
        builder: (context, state) => const BiddingRequestScreen(),
      ),

      // ── Marketplace ────────────────────────────────────
      GoRoute(
        path: RoutePaths.marketplace,
        builder: (context, state) => const MarketplaceScreen(),
      ),

      // ── Create Request (driver-initiated taxi trip) ──
      GoRoute(
        path: RoutePaths.createRequest,
        builder: (context, state) => const CreateRequestScreen(),
      ),

      // ── Subscription ─────────────────────────────────
      GoRoute(
        path: RoutePaths.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),

      // ── Earnings ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.earnings,
        builder: (context, state) => const EarningsScreen(),
      ),

      // ── Redeem ────────────────────────────────────────
      GoRoute(
        path: RoutePaths.redeem,
        builder: (context, state) => const RedeemScreen(),
      ),

      // ── Hub ────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.hub,
        builder: (context, state) => const HubScreen(),
      ),

      // ── Vehicle ───────────────────────────────────────
      GoRoute(
        path: RoutePaths.vehicles,
        builder: (context, state) => const VehicleScreen(),
      ),
      GoRoute(
        path: RoutePaths.addEditVehicle,
        builder: (context, state) {
          final vehicle = state.extra as Vehicle?;
          return AddEditVehicleScreen(vehicle: vehicle);
        },
      ),

      // ── Wallet ────────────────────────────────────────
      GoRoute(
        path: RoutePaths.wallet,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isFromSubscription =
              extra?['isFromSubscription'] as bool? ?? false;
          return WalletScreen(isFromSubscription: isFromSubscription);
        },
      ),
      GoRoute(
        path: RoutePaths.walletHistory,
        builder: (context, state) => const WalletHistoryScreen(),
      ),

      // ── Support ───────────────────────────────────────
      GoRoute(
        path: RoutePaths.contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: RoutePaths.ticketDetail,
        builder: (context, state) {
          final ticket = state.extra as SupportTicketItem;
          return TicketDetailScreen(ticket: ticket);
        },
      ),
      GoRoute(
        path: RoutePaths.inbox,
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: RoutePaths.chat,
        builder: (context, state) {
          final chatConfig = state.extra as ChatConfig;
          return ChatScreen(chatConfig: chatConfig);
        },
      ),

      // ── City Selection ───────────────────────────────
      GoRoute(
        path: RoutePaths.citySelection,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return CityScreen(countryId: params['countryId'] as String);
        },
      ),

      // ── Country/City ─────────────────────────────────
      GoRoute(
        path: RoutePaths.selectCountryCity,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return SelectCountryCityScreen(
            needsCountry: params?['needsCountry'] as bool? ?? true,
            existingCountryId: params?['existingCountryId'] as String?,
          );
        },
      ),

      // ── Receipt ───────────────────────────────────────
      GoRoute(
        path: RoutePaths.receipt,
        builder: (context, state) {
          final params = state.extra as ReceiptParams;
          return ReceiptScreen(params: params);
        },
      ),

      // ── Feedback ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.feedback,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final isFromHistory = extra?['isFromHistory'] as bool? ?? true;
          return FeedbackScreen(
            bookingId: bookingId,
            isFromHistory: isFromHistory,
          );
        },
      ),

      // ── Additional Terms ─────────────────────────────
      GoRoute(
        path: RoutePaths.additionalTerms,
        builder: (context, state) {
          final termsItem = state.extra as AdditionalTermsItem;
          return AdditionalTermsScreen(termsItem: termsItem);
        },
      ),

      // ── Other ─────────────────────────────────────────
      GoRoute(
        path: RoutePaths.imageViewer,
        builder: (context, state) {
          final imageUrl = state.extra as String;
          return ImageViewerScreen(imageUrl: imageUrl);
        },
      ),
      GoRoute(
        path: RoutePaths.webview,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          final webViewData = params?['webViewData'] as WebViewDataModel?;
          final onPaymentData =
              params?['onPaymentData'] as void Function(String?)?;
          return WebViewScreen(
            webViewData: webViewData,
            onNavigateWithPaymentData: onPaymentData,
          );
        },
      ),
    ],
  );
});
