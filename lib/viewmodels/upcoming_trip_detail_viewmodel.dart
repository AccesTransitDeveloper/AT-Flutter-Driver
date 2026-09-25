import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/cancel_booking_request.dart';
import '../models/responses/booking/booking_detail_response.dart';
import '../models/responses/booking/cancellation_reason_response.dart';

class UpcomingTripDetailState {
  final bool isLoading;
  final String? error;
  final Booking? booking;
  final BookingDetailResponse? response;
  final bool isAllowCancelBooking;
  final Set<String> activeSetting;
  final List<CancellationReason> cancellationReasons;
  final bool isCancelLoading;
  final bool isCancelled;
  final String? cancelError;
  final bool isMarketPlace;
  final bool isAcceptLoading;
  final bool isNavigateToHome;
  final String? snackBarMessage;

  const UpcomingTripDetailState({
    this.isLoading = true,
    this.error,
    this.booking,
    this.response,
    this.isAllowCancelBooking = false,
    this.activeSetting = const {},
    this.cancellationReasons = const [],
    this.isCancelLoading = false,
    this.isCancelled = false,
    this.cancelError,
    this.isMarketPlace = false,
    this.isAcceptLoading = false,
    this.isNavigateToHome = false,
    this.snackBarMessage,
  });

  UpcomingTripDetailState copyWith({
    bool? isLoading,
    String? error,
    Booking? booking,
    BookingDetailResponse? response,
    bool? isAllowCancelBooking,
    Set<String>? activeSetting,
    List<CancellationReason>? cancellationReasons,
    bool? isCancelLoading,
    bool? isCancelled,
    String? cancelError,
    bool clearError = false,
    bool clearCancelError = false,
    bool? isMarketPlace,
    bool? isAcceptLoading,
    bool? isNavigateToHome,
    String? snackBarMessage,
    bool clearSnackBar = false,
  }) {
    return UpcomingTripDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      booking: booking ?? this.booking,
      response: response ?? this.response,
      isAllowCancelBooking:
          isAllowCancelBooking ?? this.isAllowCancelBooking,
      activeSetting: activeSetting ?? this.activeSetting,
      cancellationReasons: cancellationReasons ?? this.cancellationReasons,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelError:
          clearCancelError ? null : (cancelError ?? this.cancelError),
      isMarketPlace: isMarketPlace ?? this.isMarketPlace,
      isAcceptLoading: isAcceptLoading ?? this.isAcceptLoading,
      isNavigateToHome: isNavigateToHome ?? this.isNavigateToHome,
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }

  // ── Computed Properties ──────────────────────────────────────────

  String get statusLabel {
    final status = booking?.status;
    if (status == null) return '';
    return switch (status) {
      BookingStatus.requested =>
        getString(appStr.bookingStatusRequested, 'booking_status_requested'),
      BookingStatus.accepted || BookingStatus.assigned =>
        getString(appStr.descriptionAccepted, 'description_accepted'),
      BookingStatus.inRoute =>
        getString(appStr.bookingStatusInRoute, 'booking_status_in_route'),
      BookingStatus.arrivedAtPickup => getString(
          appStr.bookingStatusArrivedAtPickup,
          'booking_status_arrived_at_pickup'),
      BookingStatus.started =>
        getString(appStr.bookingStatusStarted, 'booking_status_started'),
      _ => '',
    };
  }

  String? get dateTimeStr {
    if (booking?.bookingTime == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(booking!.bookingTime!);
    return intl.DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  String? get priceStr {
    final invoice = booking?.bookingInvoice;
    if (invoice == null) return null;
    final total = invoice.estimated?.total;
    if (total == null) return null;
    return _formatCurrency(total, invoice);
  }

  String? get distanceStr {
    final invoice = booking?.bookingInvoice;
    final distanceMeters = invoice?.estimated?.distance;
    if (distanceMeters == null) return null;
    final decimals = invoice?.decimalPointValue ?? 2;
    final distanceUnit = invoice?.distanceUnit;
    if (distanceUnit == 2) {
      // Miles
      final miles = distanceMeters / 1609.344;
      return '${miles.toStringAsFixed(decimals)} mi';
    } else {
      // Kilometers (default)
      final km = distanceMeters / 1000.0;
      return '${km.toStringAsFixed(decimals)} km';
    }
  }

  String? get durationStr {
    final invoice = booking?.bookingInvoice;
    final timeSeconds = invoice?.estimated?.time;
    if (timeSeconds == null) return null;
    final totalSeconds = timeSeconds.round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '$hours hr $mins min' : '$hours hr';
    }
    return seconds > 0 ? '$minutes min $seconds sec' : '$minutes min';
  }

  List<BookingAddress> get addressList {
    final pickup = booking?.pickupAddress;
    final destinations = booking?.destinationAddresses ?? [];
    return [
      if (pickup != null) pickup,
      ...destinations,
    ];
  }

  String? get customerName {
    final customer = booking?.customerDetail;
    if (customer == null) return null;
    final name = customer.name;
    if (name != null && name.isNotEmpty) return name;
    final first = customer.firstName ?? '';
    final last = customer.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : null;
  }

  String _formatCurrency(double value, BookingInvoice invoice) {
    final sign = invoice.currencySign ?? '';
    final dir = invoice.setCurrencySign ?? 1;
    final decimals = invoice.decimalPointValue ?? 2;
    final formatted = value.toStringAsFixed(decimals);
    if (sign.isEmpty) return formatted;
    if (dir == 2) return '$formatted$sign';
    return '$sign$formatted';
  }
}

class UpcomingTripDetailViewModel
    extends StateNotifier<UpcomingTripDetailState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager? _sharedPref;
  final String bookingId;
  final bool isMarketPlace;

  UpcomingTripDetailViewModel(
      this._appRepository, this._sharedPref, this.bookingId,
      {this.isMarketPlace = false})
      : super(const UpcomingTripDetailState()) {
    state = state.copyWith(isMarketPlace: isMarketPlace);
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getBookingDetail(bookingId);
    switch (response) {
      case Success<BookingDetailResponse>():
        final booking = response.data?.booking;
        state = state.copyWith(
          isLoading: false,
          booking: booking,
          response: response.data,
          isAllowCancelBooking:
              response.data?.isAllowCancelBooking ?? false,
          activeSetting:
              _getActiveSettings(response.data, booking).toSet(),
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? '',
        );
      case Loading():
        break;
    }
  }

  Future<void> getCancellationReasons() async {
    final response = await _appRepository.getCancellationReasons(
      queryParams: {
        'businessType':
            (state.booking?.businessType ?? BusinessType.taxi).toString(),
      },
    );
    switch (response) {
      case Success<CancellationReasonResponse>():
        // Always offer "Others" with a free-text box, same as the running
        // trip's cancel sheet. The server returns an empty list here, which
        // left the sheet with no options at all and the booking uncancellable.
        final othersReason = CancellationReason(
          reasons: getString(appStr.descriptionOthers, 'description_others'),
        );
        state = state.copyWith(
          cancellationReasons: [
            ...?response.data?.cancellationReasons,
            othersReason,
          ],
        );
      case Error():
        break;
      case Loading():
        break;
    }
  }

  Future<bool> cancelBooking(String reason) async {
    state = state.copyWith(isCancelLoading: true, clearCancelError: true);

    final request = CancelBookingRequest(
      bookingId: bookingId,
      cancellationReason: reason,
    );
    final response = await _appRepository.cancelBooking(bookingId, request);
    switch (response) {
      case Success():
        state = state.copyWith(
          isCancelLoading: false,
          isCancelled: true,
        );
        return true;
      case Error():
        state = state.copyWith(
          isCancelLoading: false,
          cancelError: response.error?.message ?? '',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<void> acceptMarketplaceBooking() async {
    state = state.copyWith(isAcceptLoading: true);
    final response = await _appRepository.acceptMarketplaceBooking(bookingId);
    switch (response) {
      case Success():
        state = state.copyWith(
          isAcceptLoading: false,
          snackBarMessage: response.message,
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) state = state.copyWith(isNavigateToHome: true);
      case Error():
        state = state.copyWith(
          isAcceptLoading: false,
          snackBarMessage: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  String? getCustomerPhone() => state.booking?.customerDetail?.phone;

  String? getSupportPhone() =>
      _sharedPref?.getSetting()?.contactDetail?.phone;

  List<String> _getActiveSettings(
      BookingDetailResponse? data, Booking? booking) {
    if (data == null || booking == null) return [];
    final driverSettings = data.citySetting?.driverBookingSetting;
    if (driverSettings == null) return [];
    return switch (booking.status) {
      BookingStatus.requested => driverSettings.requested,
      BookingStatus.assigned => driverSettings.assigned,
      BookingStatus.accepted => driverSettings.accepted,
      BookingStatus.inRoute => driverSettings.inRoute,
      BookingStatus.arrivedAtPickup => driverSettings.arrivedAtPickup,
      BookingStatus.started => driverSettings.started,
      BookingStatus.picked => driverSettings.picked,
      _ => null,
    } ??
        [];
  }
}

final upcomingTripDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<UpcomingTripDetailViewModel, UpcomingTripDetailState, String>(
        (ref, bookingId) {
  final appRepo = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  return UpcomingTripDetailViewModel(appRepo, sharedPref, bookingId);
});

final upcomingTripDetailMarketplaceViewModelProvider = StateNotifierProvider
    .autoDispose
    .family<UpcomingTripDetailViewModel, UpcomingTripDetailState, String>(
        (ref, bookingId) {
  final appRepo = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  return UpcomingTripDetailViewModel(appRepo, sharedPref, bookingId,
      isMarketPlace: true);
});
