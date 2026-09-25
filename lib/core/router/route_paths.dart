/// Centralized route path constants for the driver app.
class RoutePaths {
  RoutePaths._();

  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String verification = '/verification';
  static const String register = '/register';
  static const String atAiDriver = '/at-ai-driver';
  static const String forgotPassword = '/forgot-password';
  static const String createPassword = '/create-password';

  // Main (bottom nav)
  static const String home = '/home';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String documents = '/documents';

  // Account
  static const String account = '/account';

  // Referral
  static const String referral = '/referral';
  static const String referralList = '/referral-list';

  // Settings
  static const String settings = '/settings';
  static const String selectLocation = '/select-location';

  // Booking
  static const String currentRide = '/current-ride/:bookingId';

  // Activity / History
  static const String activity = '/activity';
  static const String tripDetail = '/trip-detail/:bookingId';
  static const String upcomingTripDetail = '/upcoming-trip-detail/:bookingId';

  // Opportunities
  static const String opportunities = '/opportunities';

  // Bidding
  static const String biddingRequests = '/bidding-requests';

  // Marketplace
  static const String marketplace = '/marketplace';

  // Subscription
  static const String subscription = '/subscription';

  // Earnings
  static const String earnings = '/earnings';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletHistory = '/wallet-history';

  // Redeem
  static const String redeem = '/redeem';

  // Support
  static const String contactUs = '/contact-us';
  static const String ticketDetail = '/ticket-detail';
  static const String inbox = '/inbox';
  static const String chat = '/chat';

  // Hub
  static const String hub = '/hub';

  // Vehicle
  static const String vehicles = '/vehicles';
  static const String addEditVehicle = '/add-edit-vehicle';

  // Country/City
  static const String selectCountryCity = '/select-country-city';
  static const String citySelection = '/city-selection';

  // Receipt
  static const String receipt = '/receipt';

  // Feedback
  static const String feedback = '/feedback/:bookingId';

  // Additional Terms
  static const String additionalTerms = '/additional-terms';

  // Create Request (driver-initiated taxi trip)
  static const String createRequest = '/create-request';

  // Other
  static const String imageViewer = '/image-viewer';
  static const String webview = '/webview';
}
