import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/socket_constants.dart';
import '../core/managers/socket_manager.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/price_utils.dart' hide SetCurrencySign;
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/accept_reject_booking_request.dart';
import '../models/responses/booking/bids_response.dart';

class BiddingRequestState {
  final bool isLoading;
  final List<BiddingRequestItem> biddingRequests;
  final String? snackBarMessage;

  const BiddingRequestState({
    this.isLoading = true,
    this.biddingRequests = const [],
    this.snackBarMessage,
  });

  BiddingRequestState copyWith({
    bool? isLoading,
    List<BiddingRequestItem>? biddingRequests,
    String? snackBarMessage,
    bool clearSnackBar = false,
  }) {
    return BiddingRequestState(
      isLoading: isLoading ?? this.isLoading,
      biddingRequests: biddingRequests ?? this.biddingRequests,
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }
}

class BiddingRequestViewModel extends StateNotifier<BiddingRequestState> {
  final AppRepository _appRepository;
  final SocketManager _socketManager;
  final SharedPreferenceManager? _sharedPref;

  // Currency settings for price formatting
  late final int _currencyDirection;
  late final String _currencySign;
  late final int _decimalPointValue;
  late final String? _entityId;

  BiddingRequestViewModel(
    this._appRepository,
    this._socketManager,
    this._sharedPref,
  ) : super(const BiddingRequestState()) {
    final setting = _sharedPref?.getSetting();
    final entity = _sharedPref?.getEntity();
    _currencyDirection = setting?.setCurrencySign ?? SetCurrencySign.left;
    _currencySign = setting?.currencySign ?? '';
    _decimalPointValue = setting?.decimalPointValue ?? 2;
    _entityId = entity?.id;

    _fetchBids();
    _listenBookingStatus();
  }

  @override
  void dispose() {
    _socketManager.offEvent(SocketConstants.bookingStatus);
    super.dispose();
  }

  Future<void> _fetchBids() async {
    state = state.copyWith(isLoading: true);

    final response = await _appRepository.getBids();
    switch (response) {
      case Success<BidsResponse>():
        final bids = response.data?.bookings ?? [];
        state = state.copyWith(
          isLoading: false,
          biddingRequests: bids,
        );
      case Error():
        state = state.copyWith(isLoading: false);
      case Loading():
        break;
    }
  }

  void rejectBid(String bookingId) async {
    final request = AcceptRejectBookingRequest(
      bookingId: bookingId,
      driverId: _entityId,
    );
    final response =
        await _appRepository.rejectBooking(bookingId, request);
    switch (response) {
      case Success():
        removeBid(bookingId);
      case Error():
        _showSnackBar(response.error?.message ?? '');
      case Loading():
        break;
    }
  }

  void removeBid(String bookingId) {
    final items =
        state.biddingRequests.where((b) => b.id != bookingId).toList();
    state = state.copyWith(biddingRequests: items);
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }

  String formatBidPrice(double? price) {
    return price.applyPriceSetting(
      currencyDirection: _currencyDirection,
      currencySign: _currencySign,
      decimalPointValue: _decimalPointValue,
    );
  }

  void _listenBookingStatus() {
    _socketManager.listenEvent(
      SocketConstants.bookingStatus,
      (data) {
        if (data is! Map) return;
        final bookingId = data['bookingId']?.toString() ?? '';
        final driverId = data['driverId']?.toString() ?? '';
        final status = data['status'];
        final statusInt = status is int ? status : int.tryParse(status?.toString() ?? '');

        if (bookingId.isEmpty || statusInt == null) return;

        switch (statusInt) {
          case BookingStatus.accepted:
            // Another driver accepted → remove bid
            if (driverId != _entityId) {
              removeBid(bookingId);
            }
          case BookingStatus.bidRejected:
            // Current driver's bid was rejected
            if (driverId == _entityId) {
              removeBid(bookingId);
            }
          case BookingStatus.cancelled:
          case BookingStatus.rejected:
            removeBid(bookingId);
          default:
            break;
        }
      },
    );
  }

  void _showSnackBar(String message) {
    state = state.copyWith(snackBarMessage: message);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        state = state.copyWith(clearSnackBar: true);
      }
    });
  }
}

final biddingRequestViewModelProvider = StateNotifierProvider.autoDispose<
    BiddingRequestViewModel, BiddingRequestState>((ref) {
  final appRepo = ref.watch(appRepositoryProvider);
  final socketManager = ref.watch(socketManagerProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  return BiddingRequestViewModel(appRepo, socketManager, sharedPref);
});
