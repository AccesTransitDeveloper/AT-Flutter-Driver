import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/booking/booking_detail_response.dart';
import '../models/responses/marketplace/marketplace_response.dart';

class MarketplaceState {
  final bool isLoading;
  final List<Booking> bookings;
  final String? snackBarMessage;

  const MarketplaceState({
    this.isLoading = false,
    this.bookings = const [],
    this.snackBarMessage,
  });

  MarketplaceState copyWith({
    bool? isLoading,
    List<Booking>? bookings,
    String? snackBarMessage,
    bool clearSnackBar = false,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }
}

class MarketplaceViewModel extends StateNotifier<MarketplaceState> {
  final AppRepository _repository;

  MarketplaceViewModel(this._repository) : super(const MarketplaceState()) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true);

    final response = await _repository.getMarketplaceBookings();

    if (response is Success<MarketplaceResponse>) {
      final bookings = response.data?.bookings ?? [];
      // Sort by bookingTime descending (newest first)
      bookings.sort((a, b) =>
          (b.bookingTime ?? 0).compareTo(a.bookingTime ?? 0));
      state = state.copyWith(isLoading: false, bookings: bookings);
    } else {
      state = state.copyWith(
        isLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }
}

final marketplaceViewModelProvider =
    StateNotifierProvider.autoDispose<MarketplaceViewModel, MarketplaceState>(
        (ref) {
  final repo = ref.watch(appRepositoryProvider);
  return MarketplaceViewModel(repo);
});
