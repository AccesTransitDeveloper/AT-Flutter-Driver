import 'dart:async';
import '../core/utils/time_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/localization/string_constants.dart';
import '../core/managers/location_manager.dart';
import '../core/map/interface/map_interface.dart';
import '../core/map/models/map_types.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../core/managers/socket_manager.dart';
import '../core/constants/socket_constants.dart';
import '../core/utils/driver_location_provider.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/accept_bidding_request.dart';
import '../models/requests/accept_reject_booking_request.dart';
import '../models/requests/cancel_booking_request.dart';
import '../models/requests/change_status_booking_request.dart';
import '../models/requests/submit_invoice_request.dart';
import '../models/responses/booking/booking_detail_response.dart';
import '../models/responses/booking/cancellation_reason_response.dart';
import '../models/responses/activity/activity_response.dart';
import '../views/widgets/app_multiple_action_button.dart';

// ── MoveBooking (switch-booking list item) ────────────────────────
class MoveBooking {
  final String id;
  final String uniqueId;
  final String address;
  const MoveBooking({required this.id, required this.uniqueId, required this.address});
}

// ── TripState ──────────────────────────────────────────────────────

class TripState {
  // Loading
  final bool isLoading;
  final bool isAcceptLoading;
  final bool isRejectLoading;
  final bool isStatusLoading;
  final bool isCancelLoading;
  final bool isSubmitInvoiceLoading;

  // View mode
  final bool isShowRequest;
  final bool isShowBookingDetail;
  final bool showSubmitInvoice;

  // Settings
  final Set<String> activeSetting;

  // Booking info
  final String bookingId;
  final String? bookingUniqueId;
  final int bookingStatus;
  final int nextBookingStatus;
  final int? bookingType;
  final int? businessType;

  // Accept screen
  final String? estimatedEarning;
  final List<String> bookingTagList;
  final String? bookingTime;
  final String bookingTimeoutTimeInFormat;
  final int bookingTimeoutTimer;
  final String? customerName;
  final double? customerRate;
  final int? completedBookings;
  final String? estimatedDistance;
  final String? estimatedTime;
  final String? payment;
  final String? note;
  final String statusButtonText;
  final String? customerImageUrl;
  final String? customerPhone;
  final String? customerCountryPhoneCode;

  // Addresses
  final List<BookingAddress> addressList;
  final BookingAddress? nextAddress;
  final int? nextAddressType; // 0=pickup, 1=stop, 2=dropoff

  /// True while Google's in-app turn-by-turn is showing in place of the
  /// regular map. See TripViewModel.isInAppNavigationAvailable for the gate
  /// (mapType == google && admin's mapKey.isAllowInAppNavigation), and
  /// toggleInAppNav for what flips this. Mirrors native's `showInAppNav`.
  final bool showInAppNav;

  // Bottom sheet
  final String? totalDistance;
  final String? totalTime;
  final String? waitingTime;
  final String? totalTrafficTime;

  // Cancel
  final bool showCancelButton;
  final int? cancelUpToStatus;
  final bool isAllowCancelBooking;
  final List<CancellationReason> cancellationReasons;
  final String? cancellationCharge;

  // Bottom sheets / dialogs
  final bool showCancelBottomSheet;
  final bool showConfirmationBottomSheet;
  final bool showConfirmationCodeBottomSheet;
  final bool showCallOptionBottomSheet;

  // Confirmation / OTP
  final String confirmationCode;
  final String confirmationAlertMessage;

  // Navigation
  final bool isNavigateBack;
  final bool isNavigateToFeedback;
  final String? navigateToBookingId; // switch to another booking

  // Switch bookings
  final bool showMoveToBooking;
  final bool showMoveBookingBottomSheet;
  final List<MoveBooking> moveBookingList;
  final int totalBookingCount;

  // Snackbar
  final String? snackBarMessage;

  // Map
  final String? directionPath;
  final bool isPartnerDriver;
  final double? currentLatitude;
  final double? currentLongitude;
  final MultipleActionButtonType actionButtonType;

  // Invoice
  final String? bookingEarning;
  final String? bookingPrice;
  final int? paymentMode;
  final String? driverPlatformProfitPercentage;

  // Bidding
  final bool isBidding;
  final double? driverMaxBid;
  final String bidAmount;
  final String? bidAmountError;
  final bool canAcceptBid;
  final bool showBidAmountBottomSheet;

  // Raw response (for map directions etc)
  final BookingDetailResponse? bookingDetailResponse;

  const TripState({
    this.isLoading = false,
    this.isAcceptLoading = false,
    this.isRejectLoading = false,
    this.isStatusLoading = false,
    this.isCancelLoading = false,
    this.isSubmitInvoiceLoading = false,
    this.isShowRequest = false,
    this.isShowBookingDetail = false,
    this.showSubmitInvoice = false,
    this.activeSetting = const {},
    this.bookingId = '',
    this.bookingUniqueId,
    this.bookingStatus = 0,
    this.nextBookingStatus = 0,
    this.bookingType,
    this.businessType,
    this.estimatedEarning,
    this.bookingTagList = const [],
    this.bookingTime,
    this.bookingTimeoutTimeInFormat = '',
    this.bookingTimeoutTimer = 0,
    this.customerName,
    this.customerRate,
    this.completedBookings,
    this.estimatedDistance,
    this.estimatedTime,
    this.payment,
    this.note,
    this.statusButtonText = '',
    this.customerImageUrl,
    this.customerPhone,
    this.customerCountryPhoneCode,
    this.addressList = const [],
    this.nextAddress,
    this.nextAddressType,
    this.showInAppNav = false,
    this.totalDistance,
    this.totalTime,
    this.waitingTime,
    this.totalTrafficTime,
    this.showCancelButton = false,
    this.cancelUpToStatus,
    this.isAllowCancelBooking = false,
    this.cancellationReasons = const [],
    this.cancellationCharge,
    this.showCancelBottomSheet = false,
    this.showConfirmationBottomSheet = false,
    this.showConfirmationCodeBottomSheet = false,
    this.showCallOptionBottomSheet = false,
    this.confirmationCode = '',
    this.confirmationAlertMessage = '',
    this.isNavigateBack = false,
    this.isNavigateToFeedback = false,
    this.navigateToBookingId,
    this.showMoveToBooking = false,
    this.showMoveBookingBottomSheet = false,
    this.moveBookingList = const [],
    this.totalBookingCount = 0,
    this.snackBarMessage,
    this.directionPath,
    this.isPartnerDriver = false,
    this.actionButtonType = MultipleActionButtonType.click,
    this.bookingEarning,
    this.bookingPrice,
    this.paymentMode,
    this.driverPlatformProfitPercentage,
    this.isBidding = false,
    this.driverMaxBid,
    this.bidAmount = '',
    this.bidAmountError,
    this.canAcceptBid = false,
    this.showBidAmountBottomSheet = false,
    this.bookingDetailResponse,
    this.currentLatitude,
    this.currentLongitude,
  });

  TripState copyWith({
    bool? isLoading,
    bool? isAcceptLoading,
    bool? isRejectLoading,
    bool? isStatusLoading,
    bool? isCancelLoading,
    bool? isSubmitInvoiceLoading,
    bool? isShowRequest,
    bool? isShowBookingDetail,
    bool? showSubmitInvoice,
    Set<String>? activeSetting,
    String? bookingId,
    String? bookingUniqueId,
    int? bookingStatus,
    int? nextBookingStatus,
    int? bookingType,
    int? businessType,
    String? estimatedEarning,
    List<String>? bookingTagList,
    String? bookingTime,
    String? bookingTimeoutTimeInFormat,
    int? bookingTimeoutTimer,
    String? customerName,
    double? customerRate,
    int? completedBookings,
    String? estimatedDistance,
    String? estimatedTime,
    String? payment,
    String? note,
    String? statusButtonText,
    String? customerImageUrl,
    String? customerPhone,
    String? customerCountryPhoneCode,
    List<BookingAddress>? addressList,
    BookingAddress? nextAddress,
    int? nextAddressType,
    bool? showInAppNav,
    String? totalDistance,
    String? totalTime,
    String? waitingTime,
    String? totalTrafficTime,
    bool? showCancelButton,
    int? cancelUpToStatus,
    bool? isAllowCancelBooking,
    List<CancellationReason>? cancellationReasons,
    String? cancellationCharge,
    bool? showCancelBottomSheet,
    bool? showConfirmationBottomSheet,
    bool? showConfirmationCodeBottomSheet,
    bool? showCallOptionBottomSheet,
    String? confirmationCode,
    String? confirmationAlertMessage,
    bool? isNavigateBack,
    bool? isNavigateToFeedback,
    String? navigateToBookingId,
    bool clearNavigateToBookingId = false,
    bool? showMoveToBooking,
    bool? showMoveBookingBottomSheet,
    List<MoveBooking>? moveBookingList,
    int? totalBookingCount,
    String? snackBarMessage,
    bool clearSnackBar = false,
    String? directionPath,
    bool? isPartnerDriver,
    MultipleActionButtonType? actionButtonType,
    String? bookingEarning,
    String? bookingPrice,
    int? paymentMode,
    String? driverPlatformProfitPercentage,
    bool? isBidding,
    double? driverMaxBid,
    String? bidAmount,
    String? bidAmountError,
    bool clearBidAmountError = false,
    bool? canAcceptBid,
    bool? showBidAmountBottomSheet,
    BookingDetailResponse? bookingDetailResponse,
    bool clearNextAddress = false,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      isAcceptLoading: isAcceptLoading ?? this.isAcceptLoading,
      isRejectLoading: isRejectLoading ?? this.isRejectLoading,
      isStatusLoading: isStatusLoading ?? this.isStatusLoading,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      isSubmitInvoiceLoading:
          isSubmitInvoiceLoading ?? this.isSubmitInvoiceLoading,
      isShowRequest: isShowRequest ?? this.isShowRequest,
      isShowBookingDetail: isShowBookingDetail ?? this.isShowBookingDetail,
      showSubmitInvoice: showSubmitInvoice ?? this.showSubmitInvoice,
      activeSetting: activeSetting ?? this.activeSetting,
      bookingId: bookingId ?? this.bookingId,
      bookingUniqueId: bookingUniqueId ?? this.bookingUniqueId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      nextBookingStatus: nextBookingStatus ?? this.nextBookingStatus,
      bookingType: bookingType ?? this.bookingType,
      businessType: businessType ?? this.businessType,
      estimatedEarning: estimatedEarning ?? this.estimatedEarning,
      bookingTagList: bookingTagList ?? this.bookingTagList,
      bookingTime: bookingTime ?? this.bookingTime,
      bookingTimeoutTimeInFormat:
          bookingTimeoutTimeInFormat ?? this.bookingTimeoutTimeInFormat,
      bookingTimeoutTimer: bookingTimeoutTimer ?? this.bookingTimeoutTimer,
      customerName: customerName ?? this.customerName,
      customerRate: customerRate ?? this.customerRate,
      completedBookings: completedBookings ?? this.completedBookings,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      payment: payment ?? this.payment,
      note: note ?? this.note,
      statusButtonText: statusButtonText ?? this.statusButtonText,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      customerPhone: customerPhone ?? this.customerPhone,
      customerCountryPhoneCode:
          customerCountryPhoneCode ?? this.customerCountryPhoneCode,
      addressList: addressList ?? this.addressList,
      nextAddress: clearNextAddress ? null : (nextAddress ?? this.nextAddress),
      nextAddressType: nextAddressType ?? this.nextAddressType,
      showInAppNav: showInAppNav ?? this.showInAppNav,
      totalDistance: totalDistance ?? this.totalDistance,
      totalTime: totalTime ?? this.totalTime,
      waitingTime: waitingTime ?? this.waitingTime,
      totalTrafficTime: totalTrafficTime ?? this.totalTrafficTime,
      showCancelButton: showCancelButton ?? this.showCancelButton,
      cancelUpToStatus: cancelUpToStatus ?? this.cancelUpToStatus,
      isAllowCancelBooking:
          isAllowCancelBooking ?? this.isAllowCancelBooking,
      cancellationReasons: cancellationReasons ?? this.cancellationReasons,
      cancellationCharge: cancellationCharge ?? this.cancellationCharge,
      showCancelBottomSheet:
          showCancelBottomSheet ?? this.showCancelBottomSheet,
      showConfirmationBottomSheet:
          showConfirmationBottomSheet ?? this.showConfirmationBottomSheet,
      showConfirmationCodeBottomSheet: showConfirmationCodeBottomSheet ??
          this.showConfirmationCodeBottomSheet,
      showCallOptionBottomSheet:
          showCallOptionBottomSheet ?? this.showCallOptionBottomSheet,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      confirmationAlertMessage:
          confirmationAlertMessage ?? this.confirmationAlertMessage,
      isNavigateBack: isNavigateBack ?? this.isNavigateBack,
      isNavigateToFeedback: isNavigateToFeedback ?? this.isNavigateToFeedback,
      navigateToBookingId: clearNavigateToBookingId
          ? null
          : (navigateToBookingId ?? this.navigateToBookingId),
      showMoveToBooking: showMoveToBooking ?? this.showMoveToBooking,
      showMoveBookingBottomSheet:
          showMoveBookingBottomSheet ?? this.showMoveBookingBottomSheet,
      moveBookingList: moveBookingList ?? this.moveBookingList,
      totalBookingCount: totalBookingCount ?? this.totalBookingCount,
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
      directionPath: directionPath ?? this.directionPath,
      isPartnerDriver: isPartnerDriver ?? this.isPartnerDriver,
      actionButtonType: actionButtonType ?? this.actionButtonType,
      bookingEarning: bookingEarning ?? this.bookingEarning,
      bookingPrice: bookingPrice ?? this.bookingPrice,
      paymentMode: paymentMode ?? this.paymentMode,
      driverPlatformProfitPercentage: driverPlatformProfitPercentage ??
          this.driverPlatformProfitPercentage,
      isBidding: isBidding ?? this.isBidding,
      driverMaxBid: driverMaxBid ?? this.driverMaxBid,
      bidAmount: bidAmount ?? this.bidAmount,
      bidAmountError:
          clearBidAmountError ? null : (bidAmountError ?? this.bidAmountError),
      canAcceptBid: canAcceptBid ?? this.canAcceptBid,
      showBidAmountBottomSheet:
          showBidAmountBottomSheet ?? this.showBidAmountBottomSheet,
      bookingDetailResponse:
          bookingDetailResponse ?? this.bookingDetailResponse,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}

// ── TripViewModel ──────────────────────────────────────────────────

class TripViewModel extends StateNotifier<TripState> {
  final AppRepository _repository;
  final SharedPreferenceManager? _sharedPref;
  final SocketManager _socketManager;
  final DriverLocationProvider _driverLocationProvider;
  MapInterface? _mapInterface;
  Timer? _acceptRejectTimer;
  StreamSubscription<DriverLocation>? _locationSubscription;

  TripViewModel(
    this._repository,
    this._sharedPref,
    this._socketManager,
    this._driverLocationProvider,
  ) : super(const TripState()) {
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    if (_sharedPref != null) {
      _driverLocationProvider.startGps(_sharedPref);
    }
    _locationSubscription?.cancel();
    _locationSubscription =
        _driverLocationProvider.locationStream.listen((location) {
      state = state.copyWith(
        currentLatitude: location.latitude,
        currentLongitude: location.longitude,
      );
    });
  }

  void setMapInterface(MapInterface mapInterface) {
    _mapInterface = mapInterface;
  }

  /// Subscribe to BOOKING_STATUS socket events for this specific booking.
  /// Re-fetches booking detail whenever server pushes a status change.
  void subscribeBookingStatus(String bookingId) {
    _socketManager.listenEvent(SocketConstants.bookingStatus, (data) {
      final map = data is Map ? data : {};
      final socketBookingId = map['bookingId']?.toString();
      if (socketBookingId == bookingId && mounted) {
        fetchBookingDetail(bookingId);
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _acceptRejectTimer?.cancel();
    _socketManager.offEvent(SocketConstants.bookingStatus);
    super.dispose();
  }

  // ── Currency Formatting ─────────────────────────────────────────

  String _formatPrice(double value) {
    final setting = _sharedPref?.getSetting();
    final decimals = setting?.decimalPointValue ?? 2;
    final formatted = value.toStringAsFixed(decimals);
    final currency = setting?.currencySign ?? '\$';
    final position = setting?.setCurrencySign ?? SetCurrencySign.left;

    if (position == SetCurrencySign.right) {
      return '$formatted$currency';
    }
    return '$currency$formatted';
  }

  // ── Fetch Booking Detail ────────────────────────────────────────

  Future<void> fetchBookingDetail(String bookingId) async {
    state = state.copyWith(isLoading: true, bookingId: bookingId);

    final response = await _repository.getBookingDetail(bookingId);

    if (response is Success<BookingDetailResponse>) {
      final data = response.data;
      if (data == null) {
        state = state.copyWith(isLoading: false, isNavigateBack: true);
        return;
      }

      final booking = data.booking;
      if (booking == null) {
        state = state.copyWith(isLoading: false, isNavigateBack: true);
        return;
      }

      final status = booking.status ?? 0;
      // The server usually sends the next status; when it's missing/0 (seen on
      // delivery orders) derive it from the current status so the action button
      // shows the right label instead of falling back to "Accept".
      final serverNext = booking.nextStatus ?? 0;
      final nextStatus = serverNext > 0
          ? serverNext
          : _deriveNextStatus(status, booking.businessType);

      // If cancelled, navigate back
      if (status == BookingStatus.cancelled) {
        state = state.copyWith(isLoading: false, isNavigateBack: true);
        return;
      }

      final isBidding =
          booking.biddingDetail?.isBidding ?? false;
      final driverMaxBid =
          data.citySetting?.bidSetting?.driverMaxBid;

      // showMoveToBooking: true when driver has more than one active booking
      final allBookingIds = [
        ...(_sharedPref?.getEntity()?.bookingIds ?? []),
        ...(_sharedPref?.getEntity()?.scheduleBookingIds ?? []),
      ];
      final showMoveToBooking = allBookingIds.length > 1;

      state = state.copyWith(
        isLoading: false,
        bookingStatus: status,
        nextBookingStatus: nextStatus,
        bookingType: booking.bookingType,
        businessType: booking.businessType,
        bookingDetailResponse: data,
        cancelUpToStatus: data.cancelUpToStatus,
        isAllowCancelBooking: data.isAllowCancelBooking ?? false,
        isBidding: isBidding,
        driverMaxBid: driverMaxBid,
        showMoveToBooking: showMoveToBooking,
        totalBookingCount: allBookingIds.length,
      );

      _setBookingStatusView(status);
      _setDriverBookingSetting(data, status);
      _setBookingDetails(data);
      _setStatusButtonText(nextStatus);
      _setNextAddress(booking, status);
      _setCancelButton(data, status);
      _startAcceptRejectTimer(data.remainingTime);
    } else if (response is Error) {
      state = state.copyWith(
        isLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  // ── Accept Booking ──────────────────────────────────────────────

  Future<void> acceptBooking() async {
    if (state.isBidding) {
      state = state.copyWith(showBidAmountBottomSheet: true);
      return;
    }

    final bookingId = state.bookingId;
    final entity = _sharedPref?.getEntity();
    if (bookingId.isEmpty) return;

    state = state.copyWith(isAcceptLoading: true);
    _acceptRejectTimer?.cancel();

    final request = AcceptRejectBookingRequest(
      bookingId: bookingId,
      driverId: entity?.id,
    );

    final response = await _repository.acceptBooking(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(isAcceptLoading: false);

      if (_isScheduleRide()) {
        state = state.copyWith(isNavigateBack: true);
        return;
      }

      await fetchBookingDetail(bookingId);
    } else {
      state = state.copyWith(
        isAcceptLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  bool _isScheduleRide() {
    final bookingTags = state.bookingDetailResponse?.booking?.bookingTags;
    return bookingTags?.contains('SCHEDULE') == true;
  }

  // ── Switch / Move Booking ──────────────────────────────────────────

  /// Fetch all active bookings and show the switch-booking bottom sheet.
  /// Mirrors Kotlin's `bookingList()` with `isNowBooking=true`.
  Future<void> moveBooking() async {
    state = state.copyWith(isLoading: true);
    final response = await _repository.getActiveBookings();
    if (!mounted) return;

    if (response is Success<MyBookingListResponse>) {
      final bookings = response.data?.bookings ?? [];
      final currentId = state.bookingId;

      final moveList = bookings
          .where((b) => b.id != null && b.id != currentId)
          .map((b) {
            final addr = b.pickupAddress?.address ?? '';
            return MoveBooking(
              id: b.id!,
              uniqueId: b.uniqueId ?? '',
              address: addr,
            );
          })
          .toList();

      state = state.copyWith(
        isLoading: false,
        moveBookingList: moveList,
        showMoveBookingBottomSheet: moveList.isNotEmpty,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Select a booking from the switch-booking bottom sheet.
  void selectBooking(String bookingId) {
    state = state.copyWith(
      showMoveBookingBottomSheet: false,
      navigateToBookingId: bookingId,
    );
  }

  void dismissMoveBookingBottomSheet() {
    state = state.copyWith(showMoveBookingBottomSheet: false);
  }

  void clearNavigateToBookingId() {
    state = state.copyWith(clearNavigateToBookingId: true);
  }

  // ── Bidding ────────────────────────────────────────────────────────

  double _getMaxDriverBid() {
    final customerBidPrice = state.bookingDetailResponse?.booking
            ?.biddingDetail?.customerBidPrice ??
        0;
    final maxBidPercent = state.driverMaxBid ?? 0;
    try {
      return customerBidPrice + (customerBidPrice * maxBidPercent / 100);
    } catch (_) {
      return customerBidPrice;
    }
  }

  void onBidAmountChange(String value) {
    final amount = double.tryParse(value);
    final maxBid = _getMaxDriverBid();

    String? error;
    bool canAccept = false;

    if (amount != null && amount > 0) {
      if (maxBid > 0 && amount > maxBid) {
        final formattedMax = _formatPrice(maxBid);
        error = getString(appStr.errorDriverMaxBid, 'error_driver_max_bid')
            .replacePlaceholders({StringConstant.amount: formattedMax});
      } else {
        canAccept = true;
      }
    }

    state = state.copyWith(
      bidAmount: value,
      bidAmountError: error,
      clearBidAmountError: error == null,
      canAcceptBid: canAccept,
    );
  }

  Future<void> acceptBidding() async {
    final bookingId = state.bookingId;
    final entity = _sharedPref?.getEntity();
    final price = double.tryParse(state.bidAmount);
    if (bookingId.isEmpty || price == null) return;

    state = state.copyWith(
      isAcceptLoading: true,
      showBidAmountBottomSheet: false,
    );
    _acceptRejectTimer?.cancel();

    final request = AcceptBiddingRequest(
      bookingId: bookingId,
      price: price,
      driverId: entity?.id,
    );

    final response = await _repository.acceptBidding(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(
        isAcceptLoading: false,
        isNavigateBack: true,
      );
    } else {
      state = state.copyWith(
        isAcceptLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  void dismissBidAmountBottomSheet() {
    state = state.copyWith(
      showBidAmountBottomSheet: false,
      bidAmount: '',
      canAcceptBid: false,
      clearBidAmountError: true,
    );
  }

  // ── Reject Booking ──────────────────────────────────────────────

  Future<void> rejectBooking() async {
    final bookingId = state.bookingId;
    final entity = _sharedPref?.getEntity();
    if (bookingId.isEmpty) return;

    state = state.copyWith(isRejectLoading: true);
    _acceptRejectTimer?.cancel();

    final request = AcceptRejectBookingRequest(
      bookingId: bookingId,
      driverId: entity?.id,
    );

    final response = await _repository.rejectBooking(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(isRejectLoading: false, isNavigateBack: true);
    } else {
      state = state.copyWith(
        isRejectLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  // ── Change Status ───────────────────────────────────────────────

  Future<void> changeStatus({String? otp}) async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;

    state = state.copyWith(isStatusLoading: true);

    // Get current location and reverse geocode for stopAddress
    final stopAddress = await _getCurrentLocationAddress();

    if (stopAddress == null) {
      // Location/geocode failed — tell the driver instead of silently aborting
      // (otherwise a correct OTP looks like it did nothing).
      state = state.copyWith(
        isStatusLoading: false,
        snackBarMessage: getString(
          appStr.errorLocationNotAvailable,
          'error_location_not_available',
        ),
      );
      return;
    }

    final request = ChangeStatusBookingRequest(
      bookingId: bookingId,
      status: state.nextBookingStatus,
      otp: otp,
      stopAddress: stopAddress,
      businessType: state.businessType,
    );

    final response =
        await _repository.changeBookingStatus(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(isStatusLoading: false);
      await fetchBookingDetail(bookingId);
    } else {
      // Error message lives on `error`, not `message` (Error doesn't set
      // `message`) — without this an invalid OTP showed no error at all.
      state = state.copyWith(
        isStatusLoading: false,
        snackBarMessage: response.error?.message,
      );
    }
  }

  /// Get current location and reverse geocode via MapInterface.
  /// Matches Kotlin getCurrentLocationAddress → getGeocodedAddress flow.
  Future<BookingAddress?> _getCurrentLocationAddress() async {
    if (_mapInterface == null) return null;

    final result = await LocationManager.instance.getCurrentLocation();
    if (result is! LocationSuccess) return null;

    final lat = result.location.latitude;
    final lng = result.location.longitude;

    final destination =
        await _mapInterface!.getPlaceDetailWithCoordinates(lat, lng);

    return BookingAddress(
      address: destination.address,
      latitude: destination.latitude ?? lat,
      longitude: destination.longitude ?? lng,
      city: destination.city,
      country: destination.country,
      countryCode: destination.countryCode,
      postalCode: destination.postalCode,
      placeId: destination.placeId,
    );
  }

  // ── Cancel Booking ──────────────────────────────────────────────

  Future<void> cancelBooking(String reason) async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;

    state = state.copyWith(isCancelLoading: true);

    final request = CancelBookingRequest(
      bookingId: bookingId,
      cancellationReason: reason,
    );

    final response = await _repository.cancelBooking(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(isCancelLoading: false, isNavigateBack: true);
    } else {
      state = state.copyWith(
        isCancelLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  // ── SOS ────────────────────────────────────────────────────────

  Future<void> sosCalling() async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final response = await _repository.sosCall(bookingId);

    if (response is Success) {
      state = state.copyWith(
        isLoading: false,
        snackBarMessage: response.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  // ── Submit Invoice ─────────────────────────────────────────────

  Future<void> submitInvoice() async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;

    state = state.copyWith(isSubmitInvoiceLoading: true);

    final request = SubmitInvoiceRequest(bookingId: bookingId);
    final response = await _repository.submitInvoice(bookingId, request);
    if (!mounted) return;

    if (response is Success) {
      state = state.copyWith(
        isSubmitInvoiceLoading: false,
        showSubmitInvoice: false,
        isNavigateToFeedback: true,
      );
    } else {
      state = state.copyWith(
        isSubmitInvoiceLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  // ── Fetch Cancellation Reasons & Charge ─────────────────────────

  Future<void> fetchCancellationReasons() async {
    final response = await _repository.getCancellationReasons(
      queryParams: {
        'businessType': (state.businessType ?? BusinessType.taxi).toString(),
      },
    );
    if (response is Success<CancellationReasonResponse>) {
      final reasons = response.data?.cancellationReasons ?? [];
      // Add "Others" option at the end
      final othersReason = CancellationReason(
        reasons: getString(appStr.descriptionOthers, 'description_others'),
      );
      state = state.copyWith(
        cancellationReasons: [...reasons, othersReason],
        showCancelBottomSheet: true,
      );
    }
  }

  Future<void> fetchCancellationCharge() async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;

    final response = await _repository.getCancellationCharge(bookingId);
    if (response is Success) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final total = (data['total'] as num?)?.toDouble() ?? 0;
        if (total > 0) {
          state = state.copyWith(
            cancellationCharge: total.toStringAsFixed(2),
          );
        }
      }
    }
  }

  void onCancelButtonClick() {
    fetchCancellationReasons();
    fetchCancellationCharge();
  }

  // ── Calling ─────────────────────────────────────────────────────

  /// Smart call routing: show bottom sheet if both options available,
  /// otherwise call directly.
  void onCallClick() {
    final settings = state.activeSetting;
    final allowUser =
        settings.contains(DriverBookingSetting.allowCallToUser);
    final allowSupport =
        settings.contains(DriverBookingSetting.allowCallToSupport);

    if (allowUser && allowSupport) {
      state = state.copyWith(showCallOptionBottomSheet: true);
    } else if (allowUser) {
      callToUser();
    } else if (allowSupport) {
      callToSupport();
    }
  }

  Future<void> callToUser() async {
    state = state.copyWith(showCallOptionBottomSheet: false);
    final isAllowCall =
        state.bookingDetailResponse?.isAllowCall ?? false;
    if (!isAllowCall) {
      // Direct dial — screen will handle launching the phone
      return;
    }
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;
    final response = await _repository.calling(bookingId);
    if (response is Success) {
      state = state.copyWith(snackBarMessage: response.message);
    } else {
      state = state.copyWith(snackBarMessage: response.message);
    }
  }

  Future<void> callToSupport() async {
    state = state.copyWith(showCallOptionBottomSheet: false);
    final isAllowCall =
        state.bookingDetailResponse?.isAllowCall ?? false;
    if (!isAllowCall) {
      // Direct dial support — screen will handle launching the phone
      return;
    }
    final response = await _repository.supportCalling();
    if (response is Success) {
      state = state.copyWith(snackBarMessage: response.message);
    } else {
      state = state.copyWith(snackBarMessage: response.message);
    }
  }

  /// Get customer phone for direct dial
  String? getCustomerPhone() => state.customerPhone;

  /// Get support phone for direct dial
  String? getSupportPhone() =>
      _sharedPref?.getSetting()?.contactDetail?.phone;

  Future<void> calling() async {
    final bookingId = state.bookingId;
    if (bookingId.isEmpty) return;
    await _repository.calling(bookingId);
  }

  // ── Private Methods ─────────────────────────────────────────────

  void _setBookingStatusView(int status) {
    switch (status) {
      case BookingStatus.assigned:
        state = state.copyWith(
          isShowRequest: true,
          isShowBookingDetail: false,
          showSubmitInvoice: false,
          // Nothing to navigate to outside the running trip. Clearing it here
          // as well as in _setNextAddress covers the states that end the trip
          // (arrival at the destination, and a new request replacing it) —
          // otherwise the flag stayed set and the top bar kept offering to
          // stop guidance over the invoice and rating screens.
          showInAppNav: false,
        );
        break;
      case BookingStatus.arrivedAtDestination:
        state = state.copyWith(
          isShowRequest: false,
          isShowBookingDetail: false,
          showSubmitInvoice: true,
          showInAppNav: false,
        );
        break;
      default:
        state = state.copyWith(
          isShowRequest: false,
          isShowBookingDetail: true,
          showSubmitInvoice: false,
        );
    }
  }

  void _setDriverBookingSetting(BookingDetailResponse data, int status) {
    final driverSettings = data.citySetting?.driverBookingSetting;
    if (driverSettings == null) return;

    List<String>? settingList;
    switch (status) {
      case BookingStatus.requested:
        settingList = driverSettings.requested;
        break;
      case BookingStatus.assigned:
        settingList = driverSettings.assigned;
        break;
      case BookingStatus.accepted:
        settingList = driverSettings.accepted;
        break;
      case BookingStatus.inRoute:
        settingList = driverSettings.inRoute;
        break;
      case BookingStatus.arrivedAtPickup:
        settingList = driverSettings.arrivedAtPickup;
        break;
      case BookingStatus.started:
      case BookingStatus.arrivedAtStop:
        settingList = driverSettings.started;
        break;
      case BookingStatus.picked:
        settingList = driverSettings.picked;
        break;
      case BookingStatus.dropped:
        settingList = driverSettings.dropped;
        break;
      case BookingStatus.arrivedNearDestination:
        settingList = driverSettings.arrivedNearDestination;
        break;
      case BookingStatus.arrivedAtDestination:
        settingList = driverSettings.arrivedAtDestination;
        break;
    }

    if (settingList != null) {
      state = state.copyWith(activeSetting: settingList.toSet());
    }
  }

  void _setBookingDetails(BookingDetailResponse data) {
    final booking = data.booking;
    if (booking == null) return;

    final invoice = booking.bookingInvoice;
    final estimated = invoice?.estimated;
    final customer = booking.customerDetail;
    final setting = _sharedPref?.getSetting();
    final distanceUnit = invoice?.distanceUnit ?? setting?.distanceUnit;
    final unitLabel =
        distanceUnit == DistanceUnit.miles ? 'mi' : 'km';

    // Build address list
    final addresses = <BookingAddress>[];
    if (booking.pickupAddress != null) {
      addresses.add(booking.pickupAddress!);
    }
    if (booking.destinationAddresses != null) {
      addresses.addAll(booking.destinationAddresses!);
    }

    // Format distance (API returns meters → convert to km or miles)
    final decimalPoints = invoice?.decimalPointValue ?? 1;
    String? distanceStr;
    if (estimated?.distance != null) {
      final divisor = distanceUnit == DistanceUnit.miles ? 1609.34 : 1000.0;
      final converted = estimated!.distance! / divisor;
      distanceStr = '${converted.toStringAsFixed(decimalPoints)} $unitLabel';
    }

    // Format time (API returns seconds → convert to minutes)
    String? timeStr;
    if (estimated?.time != null) {
      final totalSeconds = estimated!.time!.toInt();
      final mins = totalSeconds ~/ 60;
      if (mins >= 60) {
        final hours = mins ~/ 60;
        final remainingMins = mins % 60;
        timeStr = remainingMins > 0 ? '${hours}h ${remainingMins}min' : '${hours}h';
      } else {
        timeStr = '${mins}min';
      }
    }

    // Format payment
    String? paymentStr;
    if (estimated?.total != null) {
      paymentStr = _formatPrice(estimated!.total!);
    }

    // Format earning
    String? earningStr;
    if (estimated?.driverProfit != null) {
      earningStr = _formatPrice(estimated!.driverProfit!);
    }

    // Total distance/time (actual)
    final actual = invoice?.actual;
    String? totalDistStr;
    if (actual?.distance != null) {
      totalDistStr =
          '${actual!.distance!.toStringAsFixed(1)} $unitLabel';
    }
    // Seconds, not minutes — see TimeUtil.
    final totalTimeStr = TimeUtil.formatSecondsCompact(actual?.time);
    final waitingTimeStr = TimeUtil.formatSecondsCompact(actual?.waitingTime);
    final trafficTimeStr = TimeUtil.formatSecondsCompact(actual?.trafficTime);

    // Determine action button type
    final settings = state.activeSetting;
    MultipleActionButtonType actionType;
    if (settings.contains(DriverBookingSetting.swipe)) {
      actionType = MultipleActionButtonType.swipe;
    } else if (settings.contains(DriverBookingSetting.doubleTap)) {
      actionType = MultipleActionButtonType.doubleTap;
    } else {
      actionType = MultipleActionButtonType.click;
    }

    // Driver platform profit percentage
    String? profitPercentage;
    if (invoice?.driverPlatformProfitPercentage != null) {
      final decimals = invoice?.decimalPointValue ?? 2;
      profitPercentage = invoice!.driverPlatformProfitPercentage!
          .toStringAsFixed(decimals);
    }

    state = state.copyWith(
      bookingUniqueId: booking.uniqueId,
      estimatedEarning: earningStr,
      bookingTagList: booking.bookingTags ?? [],
      customerName: customer?.name,
      customerRate: customer?.rate,
      completedBookings: customer?.completedBookings,
      customerImageUrl: customer?.imageUrl,
      customerPhone: customer?.phone,
      estimatedDistance: distanceStr,
      estimatedTime: timeStr,
      payment: paymentStr,
      note: booking.customerNote,
      addressList: addresses,
      directionPath: estimated?.directionPath,
      paymentMode: invoice?.paymentMode,
      actionButtonType: actionType,
      totalDistance: totalDistStr ?? distanceStr,
      totalTime: totalTimeStr ?? timeStr,
      waitingTime: waitingTimeStr,
      totalTrafficTime: trafficTimeStr,
      bookingEarning: earningStr,
      bookingPrice: paymentStr,
      driverPlatformProfitPercentage: profitPercentage,
    );
  }

  /// Next status in the flow, from the current status. Delivery/quick-commerce
  /// add the `picked` step after arriving at the store.
  int _deriveNextStatus(int status, int? businessType) {
    // delivery=3, quick-commerce=2 both use the picked step.
    final isDelivery =
        businessType == BusinessType.delivery || businessType == 2;
    switch (status) {
      case BookingStatus.assigned:
        return BookingStatus.accepted;
      case BookingStatus.accepted:
        return BookingStatus.inRoute;
      case BookingStatus.inRoute:
        return BookingStatus.arrivedAtPickup;
      case BookingStatus.arrivedAtPickup:
        return isDelivery ? BookingStatus.picked : BookingStatus.started;
      case BookingStatus.picked:
        return BookingStatus.started;
      case BookingStatus.started:
      case BookingStatus.arrivedAtStop:
        return BookingStatus.arrivedAtDestination;
      case BookingStatus.arrivedNearDestination:
        return BookingStatus.arrivedAtDestination;
      case BookingStatus.arrivedAtDestination:
        return BookingStatus.completed;
      default:
        return BookingStatus.accepted;
    }
  }

  void _setStatusButtonText(int nextStatus) {
    String buttonText;
    switch (nextStatus) {
      case BookingStatus.inRoute:
        buttonText = getString(appStr.buttonComing, 'button_coming');
        break;
      case BookingStatus.arrivedAtPickup:
        buttonText = getString(appStr.buttonArrivedAtPickUp, 'button_arrived_at_pick_up');
        break;
      case BookingStatus.started:
        buttonText = getString(appStr.buttonTapWhenYouStart, 'button_tap_when_you_start');
        break;
      case BookingStatus.arrivedAtStop:
        buttonText = getString(appStr.buttonTapWhenYouArrivedAtStop, 'button_tap_when_you_arrived_at_stop');
        break;
      case BookingStatus.picked:
        buttonText = getString(appStr.buttonSwipeToPickOrder, 'button_swipe_to_pick_order');
        break;
      case BookingStatus.dropped:
        buttonText = getString(appStr.buttonDropOrder, 'button_drop_order');
        break;
      case BookingStatus.arrivedNearDestination:
        // Delivery: driver marks reaching the drop-off area.
        buttonText = getString(null, 'delivery_tap_at_drop_off');
        break;
      case BookingStatus.arrivedAtDestination:
        buttonText = getString(appStr.buttonTapTwiceEndBooking, 'button_tap_twice_end_booking');
        break;
      case BookingStatus.completed:
        // Delivery completion (70 → 80).
        buttonText = state.businessType == BusinessType.delivery
            ? getString(null, 'delivery_order_delivered')
            : getString(appStr.buttonTapTwiceEndBooking, 'button_tap_twice_end_booking');
        break;
      default:
        if (state.isBidding) {
          final customerBidPrice = state.bookingDetailResponse?.booking
              ?.biddingDetail?.customerBidPrice;
          final formattedPrice = _formatPrice(customerBidPrice ?? 0);
          buttonText = getString(
                  appStr.buttonAcceptBid, 'button_accept_bid')
              .replacePlaceholders(
                  {StringConstant.amount: formattedPrice});
        } else {
          buttonText = getString(appStr.buttonAccept, 'button_accept');
        }
    }
    state = state.copyWith(statusButtonText: buttonText);
  }

  /// Google's in-app turn-by-turn is only offered when the city is on the
  /// Google map provider (the SDK renders its own map, but the rest of the
  /// app's Google-specific pieces — API key, ToS — assume that provider) and
  /// the admin has explicitly allowed it. Matches native's
  /// `isMapTypeGoogle = mapType == GOOGLE && mapKey.isAllowInAppNavigation`.
  bool get isInAppNavigationAvailable {
    final setting = _sharedPref?.getSetting();
    final isGoogle =
        MapProviderType.fromValue(setting?.mapType) == MapProviderType.google;
    return isGoogle && (setting?.mapKey?.isAllowInAppNavigation ?? false);
  }

  /// Toggles in-app guidance on/off. The trip screen swaps its map widget
  /// for [InAppNavigationView] while this is true and feeds it
  /// `state.nextAddress`; there is nothing else to drive here.
  void toggleInAppNav() {
    state = state.copyWith(showInAppNav: !state.showInAppNav);
  }

  void _setNextAddress(Booking booking, int status) {
    final destinations = booking.destinationAddresses ?? [];
    final actualDestinations = booking.actualDestinationAddresses ?? [];

    BookingAddress? nextAddr;
    int addressType = 0; // 0=pickup, 1=stop, 2=dropoff

    switch (status) {
      case BookingStatus.assigned:
      case BookingStatus.accepted:
      case BookingStatus.inRoute:
      case BookingStatus.arrivedAtPickup:
        nextAddr = booking.pickupAddress;
        addressType = 0;
        break;
      default:
        final isMultipleStop = destinations.length > 1;
        final nextSt = booking.nextStatus ?? 0;
        final isPickedOrDropped = nextSt == BookingStatus.picked ||
            nextSt == BookingStatus.dropped;

        if (isMultipleStop &&
            (destinations.length - 1 > actualDestinations.length ||
                isPickedOrDropped)) {
          var index = actualDestinations.length;
          if (isPickedOrDropped && index > 0) {
            index -= 1;
          }
          if (index < destinations.length) {
            nextAddr = destinations[index];
            addressType = 1;
          }
        }

        nextAddr ??= destinations.isNotEmpty ? destinations.last : null;
        if (addressType != 1) addressType = 2;
    }

    // Once the driver has arrived/started this leg there's nothing left to
    // navigate to — matches native, which clears `showInAppNav` on the same
    // statuses (BookingViewModel: ARRIVED_AT_PICKUP, STARTED, ARRIVED_AT_STOP).
    final justArrivedOrStarted = status == BookingStatus.arrivedAtPickup ||
        status == BookingStatus.started ||
        status == BookingStatus.arrivedAtStop;

    state = state.copyWith(
      nextAddress: nextAddr,
      nextAddressType: addressType,
      showInAppNav: justArrivedOrStarted ? false : state.showInAppNav,
    );
  }

  void _setCancelButton(BookingDetailResponse data, int status) {
    final cancelUpTo = data.cancelUpToStatus;
    final isAllowCancel = data.isAllowCancelBooking ?? false;

    bool showCancel = false;
    if (isAllowCancel && cancelUpTo != null && status <= cancelUpTo) {
      showCancel = true;
    }

    state = state.copyWith(
      showCancelButton: showCancel,
      cancelUpToStatus: cancelUpTo,
      isAllowCancelBooking: isAllowCancel,
    );
  }

  void _startAcceptRejectTimer(int? remainingTimeSeconds) {
    _acceptRejectTimer?.cancel();

    if (state.bookingStatus != BookingStatus.assigned) return;
    if (remainingTimeSeconds == null || remainingTimeSeconds <= 0) return;

    state = state.copyWith(
      bookingTimeoutTimer: remainingTimeSeconds,
      bookingTimeoutTimeInFormat: _formatTime(remainingTimeSeconds),
    );

    _acceptRejectTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final remaining = state.bookingTimeoutTimer - 1;
        if (remaining <= 0) {
          timer.cancel();
          state = state.copyWith(
            bookingTimeoutTimer: 0,
            bookingTimeoutTimeInFormat: '',
            isNavigateBack: true,
          );
        } else {
          state = state.copyWith(
            bookingTimeoutTimer: remaining,
            bookingTimeoutTimeInFormat: _formatTime(remaining),
          );
        }
      },
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ── UI Actions ──────────────────────────────────────────────────

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }

  void clearNavigateBack() {
    state = state.copyWith(isNavigateBack: false);
  }

  void clearNavigateToFeedback() {
    state = state.copyWith(isNavigateToFeedback: false);
  }

  void toggleCancelBottomSheet(bool show) {
    state = state.copyWith(showCancelBottomSheet: show);
  }

  void toggleCallOptionBottomSheet(bool show) {
    state = state.copyWith(showCallOptionBottomSheet: show);
  }

  void toggleConfirmationBottomSheet(bool show) {
    state = state.copyWith(showConfirmationBottomSheet: show);
  }

  void toggleConfirmationCodeBottomSheet(bool show) {
    state = state.copyWith(
      showConfirmationCodeBottomSheet: show,
      confirmationCode: show ? '' : state.confirmationCode,
    );
  }

  // ── Action Button Flow (Kotlin changeBookingStatus) ────────────

  /// Called when driver taps/swipes the action button.
  /// Follows Kotlin flow: check confirmation → check OTP → call API.
  void onActionButtonClick() {
    _changeBookingStatus(isFromConfirm: false);
  }

  void _changeBookingStatus({bool isFromConfirm = false}) {
    // Check 1: Confirmation dialog
    if (!isFromConfirm &&
        state.activeSetting
            .contains(DriverBookingSetting.openConfirmationDialogue)) {
      _getConfirmationAlertMessage();
      state = state.copyWith(showConfirmationBottomSheet: true);
      return;
    }

    // Check 2: OTP verification (from booking response, not settings)
    final isShowOtp =
        state.bookingDetailResponse?.booking?.isShowOtp ?? false;
    if (!isFromConfirm && isShowOtp) {
      state = state.copyWith(
        showConfirmationCodeBottomSheet: true,
        confirmationCode: '',
      );
      return;
    }

    // No dialogs needed → call API directly
    final otp = state.confirmationCode.isNotEmpty
        ? state.confirmationCode
        : null;
    changeStatus(otp: otp);
  }

  void _getConfirmationAlertMessage() {
    String alertMessage;
    switch (state.nextBookingStatus) {
      case BookingStatus.inRoute:
        alertMessage = getString(
            appStr.descriptionStatusAlertComing,
            'description_status_alert_coming');
        break;
      case BookingStatus.arrivedAtPickup:
        alertMessage = getString(
            appStr.descriptionStatusAlertArrived,
            'description_status_alert_arrived');
        break;
      case BookingStatus.started:
        alertMessage = getString(
            appStr.descriptionStatusAlertStart,
            'description_status_alert_start');
        break;
      case BookingStatus.arrivedAtStop:
        alertMessage = getString(
            appStr.descriptionStatusAlertStopHere,
            'description_status_alert_stop_here');
        break;
      case BookingStatus.arrivedAtDestination:
        alertMessage = getString(
            appStr.descriptionStatusAlertEnd,
            'description_status_alert_end');
        break;
      case BookingStatus.picked:
        alertMessage = getString(
            appStr.descriptionStatusAlertPickedCourier,
            'description_status_alert_picked_courier');
        break;
      case BookingStatus.dropped:
        alertMessage = getString(
            appStr.descriptionStatusAlertDroppedCourier,
            'description_status_alert_dropped_courier');
        break;
      default:
        alertMessage = '-';
    }
    state = state.copyWith(confirmationAlertMessage: alertMessage);
  }

  /// Called when user taps "Confirm" on the confirmation dialog.
  void onConfirmClick() {
    state = state.copyWith(showConfirmationBottomSheet: false);

    // After confirmation, check if OTP is also required (matches Kotlin flow)
    final isShowOtp =
        state.bookingDetailResponse?.booking?.isShowOtp ?? false;
    if (isShowOtp) {
      state = state.copyWith(
        showConfirmationCodeBottomSheet: true,
        confirmationCode: '',
      );
      return;
    }

    _changeBookingStatus(isFromConfirm: true);
  }

  /// Called when user taps "Verify Code" on the OTP dialog.
  void onVerifyCodeClick() {
    if (state.confirmationCode.isEmpty) {
      state = state.copyWith(
        snackBarMessage: getString(
            appStr.errorPleaseEnterConfirmationCode,
            'error_please_enter_confirmation_code'),
      );
      return;
    }
    state = state.copyWith(showConfirmationCodeBottomSheet: false);
    changeStatus(otp: state.confirmationCode);
  }

  /// Updates the confirmation code as user types in OTP dialog.
  void updateConfirmationCode(String code) {
    state = state.copyWith(confirmationCode: code);
  }
}

// ── Provider ──────────────────────────────────────────────────────────

final tripViewModelProvider = StateNotifierProvider.autoDispose
    .family<TripViewModel, TripState, String>((ref, bookingId) {
  final repository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  final socketManager = ref.watch(socketManagerProvider);
  final driverLocProvider = ref.watch(driverLocationProvider);
  final viewModel = TripViewModel(repository, sharedPref, socketManager, driverLocProvider);
  viewModel.fetchBookingDetail(bookingId);
  viewModel.subscribeBookingStatus(bookingId);
  return viewModel;
});
