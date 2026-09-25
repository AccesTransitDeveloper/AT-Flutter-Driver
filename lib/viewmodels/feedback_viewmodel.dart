import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/api/response_state.dart';
import '../data/api/server_config.dart';
import '../data/repository/app_repository.dart';
import '../data/repository/history_repository.dart';
import '../models/requests/submit_rating_request.dart';
import '../models/responses/booking/booking_detail_response.dart';

/// Params for FeedbackViewModel
class FeedbackParams {
  final String bookingId;
  final bool isFromHistory;

  const FeedbackParams({
    required this.bookingId,
    this.isFromHistory = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackParams && other.bookingId == bookingId;
  }

  @override
  int get hashCode => bookingId.hashCode;
}

/// Feedback screen state
class FeedbackState {
  final bool isLoading;
  final String? error;
  final Booking? booking;
  final String customerName;
  final String? customerImageUrl;
  final double? distance;
  final int? time;
  final int? distanceUnit;
  final int selectedRating; // 1-5
  final String comment;
  final bool isNavigateBack;
  final bool isNavigateToHome;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.booking,
    this.customerName = '',
    this.customerImageUrl,
    this.distance,
    this.time,
    this.distanceUnit,
    this.selectedRating = 5,
    this.comment = '',
    this.isNavigateBack = false,
    this.isNavigateToHome = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    Booking? booking,
    String? customerName,
    String? customerImageUrl,
    double? distance,
    int? time,
    int? distanceUnit,
    int? selectedRating,
    String? comment,
    bool? isNavigateBack,
    bool? isNavigateToHome,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      booking: booking ?? this.booking,
      customerName: customerName ?? this.customerName,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      distance: distance ?? this.distance,
      time: time ?? this.time,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      selectedRating: selectedRating ?? this.selectedRating,
      comment: comment ?? this.comment,
      isNavigateBack: isNavigateBack ?? this.isNavigateBack,
      isNavigateToHome: isNavigateToHome ?? this.isNavigateToHome,
    );
  }
}

/// Feedback ViewModel — driver rates the customer (taxi only)
class FeedbackViewModel extends StateNotifier<FeedbackState> {
  final AppRepository _appRepository;
  final HistoryRepository _historyRepository;
  final FeedbackParams _params;

  FeedbackViewModel(
    this._appRepository,
    this._historyRepository,
    this._params,
  ) : super(const FeedbackState()) {
    _getBookingDetails();
  }

  // ── Fetch Booking Details ──

  Future<void> _getBookingDetails() async {
    state = state.copyWith(isLoading: true);

    if (_params.isFromHistory) {
      final response = await _historyRepository
          .getBookingHistoryDetail(_params.bookingId);

      switch (response) {
        case Success<BookingDetailResponse>():
          final booking = response.data?.booking;
          if (booking == null) {
            state = state.copyWith(isLoading: false, error: '');
            return;
          }
          _processBookingDetails(booking);

        case Error<BookingDetailResponse>():
          state = state.copyWith(
            isLoading: false,
            error: response.error?.message,
          );

        case Loading<BookingDetailResponse>():
          break;
      }
    } else {
      final response =
          await _appRepository.getBookingDetail(_params.bookingId);

      switch (response) {
        case Success<BookingDetailResponse>():
          final booking = response.data?.booking;
          if (booking == null) {
            state = state.copyWith(isLoading: false, error: '');
            return;
          }
          _processBookingDetails(booking);

        case Error<BookingDetailResponse>():
          state = state.copyWith(
            isLoading: false,
            error: response.error?.message,
          );

        case Loading<BookingDetailResponse>():
          break;
      }
    }
  }

  void _processBookingDetails(Booking booking) {
    final customer = booking.customerDetail;
    final invoice = booking.bookingInvoice;
    final actual = invoice?.actual;

    // Customer image
    String? customerImageUrl;
    if (customer?.imageUrl != null && customer!.imageUrl!.isNotEmpty) {
      customerImageUrl = ServerConfig.getFullImageUrl(customer.imageUrl!);
    }

    state = state.copyWith(
      isLoading: false,
      booking: booking,
      customerName: customer?.name ?? '',
      customerImageUrl: customerImageUrl,
      distance: actual?.distance,
      time: actual?.time?.round(),
      distanceUnit: invoice?.distanceUnit,
    );
  }

  // ── Rating ──

  void selectRating(int rating) {
    state = state.copyWith(selectedRating: rating);
  }

  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  // ── Submit ──

  Future<void> submitRating() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final request = SubmitRatingRequest(
      bookingId: _params.bookingId,
      rate: state.selectedRating.toDouble(),
      review: state.comment.isNotEmpty ? state.comment : null,
      rateTo: EntityType.customer,
    );

    final response =
        await _appRepository.submitRating(_params.bookingId, request);

    switch (response) {
      case Success<dynamic>():
        if (_params.isFromHistory) {
          state = state.copyWith(isLoading: false, isNavigateBack: true);
        } else {
          state = state.copyWith(isLoading: false, isNavigateToHome: true);
        }

      case Error<dynamic>():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message,
        );

      case Loading<dynamic>():
        break;
    }
  }

  /// Maybe Later — skip rating, go home
  void skipRating() {
    if (_params.isFromHistory) {
      state = state.copyWith(isNavigateBack: true);
    } else {
      state = state.copyWith(isNavigateToHome: true);
    }
  }
}

/// Provider for FeedbackViewModel
final feedbackViewModelProvider = StateNotifierProvider.autoDispose
    .family<FeedbackViewModel, FeedbackState, FeedbackParams>((ref, params) {
  final appRepository = ref.watch(appRepositoryProvider);
  final historyRepository = ref.watch(historyRepositoryProvider);
  return FeedbackViewModel(appRepository, historyRepository, params);
});
