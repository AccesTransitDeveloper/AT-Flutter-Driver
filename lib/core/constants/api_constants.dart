/// API Parameters used in headers and request bodies
class ApiParams {
  static const String authorization = 'Authorization';
  static const String language = 'language';
  static const String type = 'type';
  static const String page = 'page';
  static const String limit = 'limit';
  static const String sortOrder = 'sortOrder';
  static const String deviceType = 'deviceType';
  static const String userType = 'userType';
  static const String expiryDate = 'expiryDate';
  static const String uniqueCode = 'uniqueCode';
  static const String notificationType = 'notificationType';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String isGroupByDate = 'isGroupByDate';
  static const String countryId = 'countryId';
  static const String paymentGatewayTypes = 'paymentGatewayTypes';
  static const String countryPhoneCode = 'countryPhoneCode';
  static const String phone = 'phone';
  static const String id = 'id';
  static const String brandId = 'brandId';
  static const String vehicleId = 'vehicleId';
  static const String typeId = 'typeId';
}

/// Main API Endpoints
class ApiEndpoint {
  // Auth / Splash
  static const String getToken = 'auth/get_token';
  static const String getEntityDetail = 'auth/get_entity_detail';
  static const String getLanguageStrings = 'language/strings';

  // Auth
  static const String getCountries = 'country';
  static const String checkRegistered = 'auth/check_registered';
  static const String generateOtp = 'auth/generate_otp';
  static const String verifyOtp = 'auth/verify_otp';
  static const String signIn = 'auth/signin';
  static const String signUp = 'auth/driver/signup';
  static const String changePassword = 'auth/change_password';
  static const String deviceToken = 'auth/device_token';

  // Workflow
  static const String setWorkflow = 'auth/workflow';

  // Profile
  static const String updateProfile = 'auth/update_profile';
  static const String profilePicture = 'auth/profile_picture';

  // Documents
  static const String getDocuments = 'uploaded_document';
  static const String uploadDocument = 'uploaded_document/{documentId}';

  // Maps / Geocoding
  static const String googleGeocode = 'gmaps/maps/api/geocode/json';

  // Notifications
  static const String getNotifications = 'notifiations';

  // Referral
  static const String referralHistory = 'referral';

  // Earnings (history API)
  static const String earning = 'earning';

  // Support Tickets
  static const String getSupportTicketCategories = 'support/ticket/categories';
  static const String supportTicket = 'support/ticket';
  static const String addSupportTicketImage = 'support/ticket/image/{ticketId}';
  static const String updateTicketStatus = 'support/ticket/{ticketId}/status';

  // Redeem / Reward Points
  static const String getRewardPoints = 'transaction/reward_point';
  static const String withdrawRewardPoints = 'transaction/reward_point/withdraw';

  // Settings
  static const String signOut = 'auth/signout';
  static const String deleteAccount = 'auth/delete_account';
  static const String getLanguage = 'language';
  static const String setLanguage = 'auth/language';

  // Emergency Contacts
  static const String emergencyContact = 'emergency_contact';
  static const String modifyEmergencyContact = 'emergency_contact/{contactId}';

  // SOS
  static const String sosCall = 'sms_template/sos/{bookingId}';

  // Opportunities
  static const String incentivePolicy = 'city/incentive_policy/{cityId}';
  static const String penaltyPolicy = 'city/penalty_policy/{cityId}';

  // Going Home Address
  static const String address = 'address';
  static const String modifyAddress = 'address/{addressId}';

  // Payment / Wallet
  static const String getTransactionCredit = 'transaction/credit';
  static const String getPaymentGateways = 'payment_gateway/user';
  static const String getCards = 'card';
  static const String addCardIntent = 'card/intent/add/{gateway}';
  static const String addCard = 'card/{gateway}';
  static const String modifyCard = 'card/{cardId}';
  static const String paymentIntentCreate = 'payment/intent/create/{paymentGateway}';
  static const String transferCredits = 'transaction/credit/transfer';
  static const String searchUser = 'transaction/credit/transfer/search_user';

  // Bank Account
  static const String addBank = 'bank_account/{gateway}';
  static const String getBank = 'bank_account/{payment_gateway}';
  static const String selectBank = 'bank_account/{bankId}';

  // Credit Withdrawal
  static const String creditWithdrawTaxDetail = 'transaction/credit_withdraw/tax_detail';
  static const String creditWithdraw = 'transaction/credit_withdraw';

  // Driver Online/Offline
  static const String driverOnline = 'driver/online';
  static const String driverOffline = 'driver/offline';

  // Business Type
  static const String businessType = 'booking/businessType';

  // Information Status
  static const String informationStatus = 'auth/driver/information_status';
  static const String checkr = 'checkr';

  // Country/City
  static const String getCities = 'city';
  static const String setCountryCity = 'auth/set_country_city';

  // Additional Terms
  static const String acceptAdditionalTerms = 'additional_terms/accept';

  // Subscription
  static const String subscriptionVehicleInfo = 'subscription/vehicle/info';
  static const String subscriptionVehicle = 'subscription/vehicle';
  static const String subscriptionCreate = 'subscription/create/{paymentGateway}';
  static const String subscriptionUpgrade = 'subscription/upgrade/{vehicleSubscriptionId}';
  static const String subscriptionVehicleUpgrade = 'subscription/vehicle/upgrade/{vehicleSubscriptionId}/{subscriptionId}';
  static const String subscriptionCancel = 'subscription/cancel/{vehicleSubscriptionId}';
  static const String subscriptionInvoice = 'subscription/invoice/{vehicleSubscriptionId}';

  // Vehicle
  static const String vehicle = 'vehicle';
  static const String vehicleDetail = 'vehicle/{vehicleId}';
  static const String vehicleBrand = 'vehicle/vehicle_brand';
  static const String vehicleColor = 'vehicle/vehicle_color';
  static const String vehicleModel = 'vehicle/vehicle_model';
  static const String selectVehicle = 'vehicle/select_vehicle/{vehicleId}';
  static const String accessibility = 'accessibility';
  static const String nearestHub = 'hub/nearest';
  static const String hubVehicle = 'hub/vehicle';
  static const String pickVehicle = 'vehicle/pick/{vehicleId}';
  static const String dropVehicle = 'vehicle/drop/{vehicleId}';

  // Booking
  static const String bookingDetail = 'booking/{bookingId}';
  static const String acceptBooking = 'booking/taxi/accept/{bookingId}';
  static const String rejectBooking = 'booking/taxi/reject/{bookingId}';
  static const String changeBookingStatus = 'booking/taxi/change_status/{bookingId}';
  static const String cancelBooking = 'booking/cancel/{bookingId}';
  static const String cancellationCharge = 'booking/cancellation_charge/{bookingId}';
  static const String cancellationReason = 'cancellation_reason';
  static const String submitInvoice = 'booking/submit_invoice/{bookingId}';
  static const String submitRating = 'booking/submit_rating/{bookingId}';
  static const String calling = 'calling/{bookingId}';
  static const String supportCalling = 'calling/support_call';

  // Bidding
  static const String bids = 'booking/taxi/bids';
  static const String acceptBidding = 'booking/taxi/accept_bidding';

  // Marketplace
  static const String marketplaceBookingList = 'booking/taxi/market_place';
  static const String acceptMarketplaceBooking = 'booking/taxi/market_place/accept/{bookingId}';

  // My Bookings (upcoming/active)
  static const String myBookings = 'booking';

  // Create Booking (driver-initiated taxi trip)
  static const String createBooking = 'booking/taxi';
  static const String getVehicleTypes = 'booking/taxi/get_vehicle_types';
}

/// History API Endpoints
class HistoryApiEndpoint {
  static const String heatMap = 'booking_history/map/heatmap';
  static const String bookingHistory = 'booking_history';
  static const String bookingHistoryDetail = 'booking_history/{bookingId}';
}

/// Socket API Endpoints
class SocketApiEndpoint {
  static const String chatAttachment = 'api/chat/attachment';
}
