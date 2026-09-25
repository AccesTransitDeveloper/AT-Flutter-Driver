import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../core/constants/app_constants.dart';
import '../core/utils/invoice_util.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/history_repository.dart';
import '../models/responses/booking/booking_detail_response.dart';

class TripDetailState {
  final bool isLoading;
  final String? error;
  final Booking? booking;
  final BookingDetailResponse? response;
  final Set<String> activeSetting;
  final bool isPartnerDriver;

  const TripDetailState({
    this.isLoading = true,
    this.error,
    this.booking,
    this.response,
    this.activeSetting = const {},
    this.isPartnerDriver = false,
  });

  TripDetailState copyWith({
    bool? isLoading,
    String? error,
    Booking? booking,
    BookingDetailResponse? response,
    Set<String>? activeSetting,
    bool? isPartnerDriver,
    bool clearError = false,
  }) {
    return TripDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      booking: booking ?? this.booking,
      response: response ?? this.response,
      activeSetting: activeSetting ?? this.activeSetting,
      isPartnerDriver: isPartnerDriver ?? this.isPartnerDriver,
    );
  }

  // ── Computed Properties ──────────────────────────────────────────

  bool get isCancelled => booking?.status == 90;

  bool get hasPositiveCancellationCharge {
    final invoiceData = booking?.bookingInvoice?.actual ?? booking?.bookingInvoice?.estimated;
    if (invoiceData == null) return false;

    bool hasPositivePrice(List<PriceData>? prices) {
      for (final priceData in prices ?? const <PriceData>[]) {
        if (priceData.title == PriceType.cancellationPrice &&
            ((priceData.discountedPrice ?? priceData.price ?? 0) > 0)) {
          return true;
        }

        if (hasPositivePrice(priceData.childs)) {
          return true;
        }
      }
      return false;
    }

    return hasPositivePrice(invoiceData.charges) ||
        hasPositivePrice(invoiceData.additionalPrices) ||
        hasPositivePrice(invoiceData.accessibilityPrices) ||
        hasPositivePrice(invoiceData.taxPrices);
  }

  String? get completedTimeStr {
    final timestamp = booking?.completedAt ?? booking?.bookingTime;
    if (timestamp == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return intl.DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  String? get priceStr {
    final invoice = booking?.bookingInvoice;
    if (invoice == null) return null;
    final total = invoice.actual?.total ?? invoice.estimated?.total;
    if (total == null) return null;
    return _formatCurrency(total, invoice);
  }

  String? get distanceStr {
    final invoice = booking?.bookingInvoice;
    final distanceMeters =
        invoice?.actual?.distance ?? invoice?.estimated?.distance;
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
    final timeSeconds = invoice?.actual?.time ?? invoice?.estimated?.time;
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

  String? get earningStr {
    final invoice = booking?.bookingInvoice;
    final earning =
        invoice?.actual?.driverProfit ?? invoice?.estimated?.driverProfit;
    if (earning == null) return null;
    return _formatCurrency(earning, invoice!);
  }

  List<BookingAddress> get addressList {
    final pickup = booking?.pickupAddress;
    final destinations = booking?.destinationAddresses ?? [];
    return [pickup, ...destinations].whereType<BookingAddress>().toList();
  }

  /// Driver has already rated the customer (matches Kotlin: rating?.customerRate == null check)
  bool get isUserRated => booking?.rating?.customerRate != null;

  bool get shouldShowCancelledAmount => !isCancelled || hasPositiveCancellationCharge;

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

class TripDetailViewModel extends StateNotifier<TripDetailState> {
  final HistoryRepository _historyRepository;
  final String bookingId;

  TripDetailViewModel(this._historyRepository, this.bookingId,
      {bool isPartnerDriver = false})
      : super(TripDetailState(isPartnerDriver: isPartnerDriver)) {
    _fetchBookingDetail();
  }

  List<String> _getActiveSettings(
      BookingDetailResponse? data, Booking? booking) {
    if (data == null || booking == null) return [];
    final driverSettings = data.citySetting?.driverBookingSetting;
    if (driverSettings == null) return [];
    return switch (booking.status) {
          90 => driverSettings.serviceCompleted,
          _ => driverSettings.serviceCompleted,
        } ??
        [];
  }

  Future<void> _fetchBookingDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response =
        await _historyRepository.getBookingHistoryDetail(bookingId);
    switch (response) {
      case Success<BookingDetailResponse>():
        final booking = response.data?.booking;
        state = state.copyWith(
          isLoading: false,
          booking: booking,
          response: response.data,
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
}

final tripDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<TripDetailViewModel, TripDetailState, String>((ref, bookingId) {
  final historyRepo = ref.watch(historyRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  final isPartnerDriver = sharedPref?.getEntity()?.type == EntityType.partner;
  return TripDetailViewModel(historyRepo, bookingId,
      isPartnerDriver: isPartnerDriver);
});
