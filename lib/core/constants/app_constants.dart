import '../localization/app_strings.dart';

class AppConstants {
  // Stripe publishable key (set at runtime from payment gateway response)
  static String stripePublishableKey = '';

  // Production URLs
  static const String apiBaseUrl = 'https://api.accessibletransit.com/api/';
  static const String imageBaseUrl =
      'https://accessibletransit.s3.us-east-1.amazonaws.com/';
  static const String historyBaseUrl =
      'https://history.accessibletransit.com/api/';
  static const String socketBaseUrl = 'https://socket.accessibletransit.com/';

  // Demo URLs
  static const String demoApiBaseUrl = 'https://api.accessibletransit.com/api/';
  static const String demoImageBaseUrl = 'https://api.accessibletransit.com/';
  static const String demoHistoryBaseUrl =
      'https://history.accessibletransit.com/api/';
  static const String demoSocketBaseUrl =
      'https://socket.accessibletransit.com/';

  // Local development ports
  static const int apiPort = 4000;
  static const int historyPort = 4001;
  static const int socketPort = 4002;
}

/// Business type constants
class BusinessType {
  static const int taxi = 1;
  static const int quickDelivery = 2;
  static const int delivery = 3;
  static const int service = 4;
  static const int courier = 5;
}

/// Price mode constants
class PriceMode {
  static const int normal = 1;
  static const int sharing = 2;
  static const int rental = 3;
  static const int quickCommerce = 4;
  static const int delivery = 5;
  static const int pickup = 6;
  static const int intraCityCourier = 7;
  static const int interCityCourier = 8;
  static const int mover = 9;
}

/// Entity type constants
class EntityType {
  static const int admin = 1;
  static const int customer = 2;
  static const int driver = 3;
  static const int partner = 4;
  static const int dispatcher = 5;
  static const int corporate = 6;
  static const int merchant = 7;
  static const int hub = 8;
}

/// Vehicle subscription status constants
class VehicleSubscriptionStatus {
  static const int active = 1;
  static const int pending = 2;
  static const int inactive = 3;
  static const int cancelled = 4;
  static const int expired = 5;
}

/// Currency sign position
class SetCurrencySign {
  static const int left = 1;
  static const int right = 2;
}

/// Assessment status constants
class AssessmentStatus {
  static const int pending = 10;
  static const int failed = 40;
  static const int passed = 30;
}

/// Support ticket status constants
class SupportTicketStatus {
  static const String open = 'OPEN';
  static const String closed = 'CLOSED';
  static const String reopen = 'REOPEN';
  static const String cancelled = 'CANCELLED';
}

/// Device type constants
class DeviceType {
  static const String android = 'ANDROID';
  static const String ios = 'IOS';
}

/// User type constants (driver)
class UserType {
  static const int driver = 3;
}

/// Notification type constants
class NotificationType {
  static const int push = 3;
}

class LoginBy {
  static const int email = 1;
  static const int phone = 2;
  static const int otp = 4;
  static const int password = 5;
  static const int google = 6;
  static const int apple = 7;
}

class OtpSendMode {
  static const int sms = 1;
  static const int email = 2;
  static const int smsEmail = 3;
}

/// Transfer using constants
class TransferUsing {
  static const int qr = 1;
  static const int phone = 2;
}

/// Payment purpose type constants
class PaymentPurposeType {
  static const int addWallet = 1;
  static const int bookingPayment = 2;
  static const int tipPayment = 3;
  static const int splitPayment = 4;
  static const int cancelBookingPayment = 5;
  static const int addCard = 6;
  static const int preBookingPayment = 8;
  static const int fixedGroupRidePayment = 11;
}

/// Payment transaction status constants
class PaymentTransactionStatus {
  static const int pending = 1;
  static const int initiated = 2;
  static const int paid = 3;
  static const int failed = 4;
  static const int cancelled = 5;
  static const int refunded = 6;
  static const int captureRequired = 7;
}

/// Payment gateway type constants
enum PaymentGatewayType {
  cash(1, 'description_cash'),
  wallet(2, 'description_wallet'),
  stripe(3, 'description_stripe'),
  paystack(4, 'description_paystack'),
  razorpay(5, 'description_razorpay'),
  mercado(7, 'description_mercado_pago'),
  payu(8, 'description_payu'),
  pago(9, 'description_pago'),
  pagoC2p(10, 'description_pago'),
  zaincash(11, 'description_zaincash'),
  hyperpay(12, 'description_hyperpay'),
  nestpay(13, 'description_nestpay'),
  qicard(14, 'description_qicard'),
  mpesa(15, 'description_mpesa');

  final int value;
  final String stringKey;

  const PaymentGatewayType(this.value, this.stringKey);

  String getName() {
    final appStrValue = switch (this) {
      PaymentGatewayType.cash => appStr.descriptionCash,
      PaymentGatewayType.wallet => appStr.descriptionWallet,
      PaymentGatewayType.stripe => appStr.descriptionStripe,
      PaymentGatewayType.paystack => appStr.descriptionPaystack,
      PaymentGatewayType.razorpay => appStr.descriptionRazorpay,
      PaymentGatewayType.mercado => appStr.descriptionMercadoPago,
      PaymentGatewayType.payu => appStr.descriptionPayu,
      PaymentGatewayType.pago => appStr.descriptionPago,
      PaymentGatewayType.pagoC2p => appStr.descriptionPago,
      PaymentGatewayType.zaincash => appStr.descriptionZaincash,
      PaymentGatewayType.hyperpay => appStr.descriptionHyperpay,
      PaymentGatewayType.nestpay => appStr.descriptionNestpay,
      PaymentGatewayType.qicard => appStr.descriptionQicard,
      PaymentGatewayType.mpesa => appStr.descriptionMpesa,
    };
    return getString(appStrValue, stringKey);
  }

  static PaymentGatewayType? fromValue(int? value) {
    if (value == null) return null;
    return PaymentGatewayType.values.cast<PaymentGatewayType?>().firstWhere(
          (type) => type?.value == value,
          orElse: () => null,
        );
  }
}

/// Credit status constants (wallet transactions)
class CreditStatus {
  static const int added = 1;
  static const int deducted = 2;
}

/// Credit transaction type constants (wallet transactions)
class CreditTransactionType {
  static const int referralBonus = 1;
  static const int referrerBonus = 2;
  static const int digitalPayment = 3;
  static const int fromAdmin = 4;
  static const int tipPayment = 5;
  static const int toFriend = 6;
  static const int fromFriend = 7;
  static const int rewardPointWithdraw = 8;
  static const int penalty = 9;
  static const int bookingPayment = 10;
  static const int cancelBookingPayment = 11;
  static const int bookingProfit = 12;
  static const int incentive = 13;
  static const int bankTransfer = 14;
  static const int refund = 15;
  static const int subscription = 16;
  static const int fixGroupBooking = 18;
}

/// Penalty type constants
class PenaltyType {
  static const String rideCancellation = 'RIDE_CANCELLATION';
  static const String lowRating = 'LOW_RATING';
  static const String missedRides = 'MISSED_RIDES';
}

/// Bank account status constants
class BankAccountStatus {
  static const int pending = 1;
  static const int processing = 2;
  static const int verified = 3;

  static String getStatusText(int? status) {
    return switch (status) {
      1 => getString(appStr.descriptionBankPending, 'description_bank_pending'),
      2 => getString(appStr.descriptionBankProcessing, 'description_bank_processing'),
      3 => getString(appStr.descriptionBankVerified, 'description_bank_verified'),
      _ => '',
    };
  }
}

/// Payment method type constants (card vs bank)
class PaymentMethods {
  static const int card = 1;
  static const int bank = 2;
}

/// Date format enum for AppDateUtils
enum DateFormat {
  dateOnlyFormat,            // dd-MM-yyyy
  dateFormatWithSpace,       // dd MMM yyyy
  dateMonthWithSpace,        // dd MMM
  dateTimeFormat,            // dd-MM-yyyy hh:mm a
  dayMonthTimeYearFormat,    // d MMM yyyy, hh:mm a
  hourMinuteFormat,          // hh:mm a
  dateMonthHourMinuteFormat, // dd MMMM, hh:mm a
  weekdayAndTime,            // EEE hh:mm a
  apiFormat,                 // ISO 8601
  apiDateFormat,             // ISO 8601 date
}

/// Vehicle status constants
class VehicleStatus {
  static const int pending = 10;
  static const int approved = 20;
  static const int rejected = 30;
}

/// Vehicle type constants (Normal/EV)
class VehicleTypeConst {
  static const int normal = 1;
  static const int ev = 2;
}

/// Vehicle document status constants
class VehicleDocumentStatus {
  static const int pending = 10;
  static const int uploaded = 20;
  static const int accepted = 30;
  static const int rejected = 40;
  static const int expired = 50;
  static const int pendingVehicle = 11;
  static const int expiredVehicle = 51;
}

/// Driver type constants
class DriverType {
  static const String admin = 'ADMIN';
  static const String partner = 'PARTNER';
  static const String merchant = 'MERCHANT';
}

/// Document type constants
class DocumentType {
  static const int vehicle = 9;
  static const int driver = 3;
}

/// Absolute/Percentage type for pricing
class AbsolutePercentage {
  static const int absolute = 1;
  static const int percentage = 2;
}

/// Distance unit constants
class DistanceUnit {
  static const int km = 1;
  static const int miles = 2;

  static String getUnit(int? distanceUnit) {
    return switch (distanceUnit) {
      miles => 'miles',
      _ => 'km',
    };
  }
}

/// Payment mode constants
class PaymentMode {
  static const int cash = 1;
  static const int wallet = 2;
  static const int stripe = 3;
  static const int paystack = 4;
  static const int razorpay = 5;
  static const int mercado = 7;
  static const int payu = 8;
  static const int pago = 9;
  static const int pagoC2p = 10;
  static const int zaincash = 11;
  static const int hyperpay = 12;
  static const int nestpay = 13;
  static const int qicard = 14;
  static const int mpesa = 15;
}

enum Gender {
  none(''),
  male('MALE'),
  female('FEMALE');

  final String value;
  const Gender(this.value);

  static Gender fromValue(String? value) {
    if (value == null || value.isEmpty) return Gender.none;
    return Gender.values.firstWhere(
      (g) => g.value.toUpperCase() == value.toUpperCase(),
      orElse: () => Gender.none,
    );
  }
}

/// Booking status constants
class BookingStatus {
  static const int requested = 1;
  static const int assigned = 10;
  static const int noDriverFound = 11;
  static const int notAnswered = 12;
  static const int rejected = 13;
  static const int merchantAccepted = 14;
  static const int accepted = 20;
  static const int bidAccepted = 21;
  static const int bidRejected = 22;
  static const int inRoute = 30;
  static const int arrivedAtPickup = 40;
  static const int picked = 41;
  static const int dropped = 42;
  static const int started = 50;
  static const int serviceStarted = 51;
  static const int servicePause = 52;
  static const int serviceCompleted = 55;
  static const int arrivedAtStop = 60;
  static const int arrivedNearDestination = 65;
  static const int arrivedAtDestination = 70;
  static const int completed = 80;
  static const int cancelled = 90;
  static const int merchantPreparing = 141;
}

/// Driver booking setting constants (controls UI visibility)
class DriverBookingSetting {
  static const String showEstimatePrice = 'ShowEstimatePrice';
  static const String showEstimateDistance = 'ShowEstimateDistance';
  static const String showEstimateTime = 'ShowEstimateTime';
  static const String showBookingType = 'ShowBookingType';
  static const String showPickupEstimateDistance = 'ShowPickupEstimateDistance';
  static const String showPickupEstimateTime = 'ShowPickupEstimateTime';
  static const String showEarning = 'ShowEarning';
  static const String showPlatformProfitPercentage = 'ShowPlatformProfitPercentage';
  static const String showBiddingAmount = 'ShowBiddingAmount';
  static const String showBookingId = 'ShowBookingId';
  static const String hideRejectButton = 'HideRejectButton';
  static const String allowCallToUser = 'AllowCallToUser';
  static const String allowCallToSupport = 'AllowCallToSupport';
  static const String showDropoffLocation = 'ShowDropoffLocation';
  static const String showStops = 'ShowStops';
  static const String allowChatWithUser = 'AllowChatWithUser';
  static const String showTotalTimeAndDistance = 'ShowTotalTimeAndDistance';
  static const String showWaitingTime = 'ShowWaitingTime';
  static const String allowPauseResume = 'AllowPauseResume';
  static const String openConfirmationDialogue = 'OpenConfirmationDialogue';
  static const String otpVerification = 'OtpVerification';
  static const String showStopWaitingTime = 'ShowStopWaitingTime';
  static const String showTrafficTime = 'ShowTrafficTime';
  static const String showLivePath = 'ShowLivePath';
  static const String allowSos = 'AllowSos';
  static const String editCart = 'EditCart';
  static const String hideUserDetails = 'HideUserDetails';
  static const String hideTotal = 'HideTotal';
  static const String singleTap = 'SingleTap';
  static const String doubleTap = 'DoubleTap';
  static const String swipe = 'Swipe';
  static const String requiredParcelImage = 'RequiredParcelImage';
}

/// Cancelled by constants
class CancelledBy {
  static const int admin = 1;
  static const int customer = 2;
  static const int driver = 3;
  static const int partner = 4;
  static const int dispatcher = 5;
  static const int corporate = 6;
  static const int merchant = 7;
}

/// Checkr background-check status values (native `CheckrStatus`).
class CheckrStatus {
  static const int pending = 10;
  static const int uploaded = 20;
  static const int verified = 30;
  static const int reviewRequired = 40;
}

/// `status` values carried by push notifications (native `NotificationStatus`).
class NotificationStatus {
  static const String entityStatus = 'ENTITY_STATUS';
  static const String chat = 'CHAT';
}
