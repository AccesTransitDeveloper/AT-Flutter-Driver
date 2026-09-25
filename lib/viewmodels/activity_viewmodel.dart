import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/date_utils.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../data/repository/history_repository.dart';
import '../models/responses/activity/activity_response.dart';
import '../models/responses/booking/booking_detail_response.dart';

/// Filter options for past bookings (matches Kotlin FilterType)
class HistoryFilter {
  static const int last7Days = 0;
  static const int currentMonth = 1;
  static const int previousMonth = 2;
  static const int previous6Months = 3;
  static const int specificDates = 4;
}

class ActivityState {
  final bool isUpcomingLoading;
  final List<Booking> upcomingBookings;
  final bool isHistoryLoading;
  final bool isPaginationLoading;
  final List<HistoryBooking> pastBookings;
  final Booking? featuredBookingDetail;
  final bool isDataNotFound;
  final int selectedFilter;
  final int previousSelectedFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? snackBarMessage;

  const ActivityState({
    this.isUpcomingLoading = true,
    this.upcomingBookings = const [],
    this.isHistoryLoading = true,
    this.isPaginationLoading = false,
    this.pastBookings = const [],
    this.featuredBookingDetail,
    this.isDataNotFound = false,
    this.selectedFilter = HistoryFilter.last7Days,
    this.previousSelectedFilter = HistoryFilter.last7Days,
    this.fromDate,
    this.toDate,
    this.snackBarMessage,
  });

  ActivityState copyWith({
    bool? isUpcomingLoading,
    List<Booking>? upcomingBookings,
    bool? isHistoryLoading,
    bool? isPaginationLoading,
    List<HistoryBooking>? pastBookings,
    Booking? featuredBookingDetail,
    bool clearFeaturedBookingDetail = false,
    bool? isDataNotFound,
    int? selectedFilter,
    int? previousSelectedFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? snackBarMessage,
    bool clearSnackBar = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return ActivityState(
      isUpcomingLoading: isUpcomingLoading ?? this.isUpcomingLoading,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      pastBookings: pastBookings ?? this.pastBookings,
      featuredBookingDetail: clearFeaturedBookingDetail
          ? null
          : (featuredBookingDetail ?? this.featuredBookingDetail),
      isDataNotFound: isDataNotFound ?? this.isDataNotFound,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      previousSelectedFilter:
          previousSelectedFilter ?? this.previousSelectedFilter,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }
}

class ActivityViewModel extends StateNotifier<ActivityState> {
  final AppRepository _appRepository;
  final HistoryRepository _historyRepository;

  int _currentPage = 1;
  int _totalCount = 0;
  static const int _pageLimit = 10;

  ActivityViewModel(this._appRepository, this._historyRepository)
      : super(const ActivityState()) {
    _fetchUpcomingBookings();
    _fetchBookingHistory();
  }

  /// Re-pull both lists. Used when returning from a screen that changed a
  /// booking (e.g. a cancellation) — the lists are fetched once in the
  /// constructor, so without this the cancelled trip stayed on screen.
  Future<void> refresh() async {
    // Back to page 1 — _fetchBookingHistory appends when _currentPage > 1, so
    // refreshing after pagination would duplicate the loaded pages.
    _currentPage = 1;
    await Future.wait([
      _fetchUpcomingBookings(),
      _fetchBookingHistory(),
    ]);
  }

  // ── Upcoming Bookings ─────────────────────────────────────────────

  Future<void> _fetchUpcomingBookings() async {
    state = state.copyWith(isUpcomingLoading: true);

    final response = await _appRepository.getMyBookings();
    switch (response) {
      case Success<MyBookingListResponse>():
        final bookings = response.data?.bookings ?? [];
        // Sort by bookingTime ascending (earliest first)
        bookings.sort((a, b) =>
            (a.bookingTime ?? 0).compareTo(b.bookingTime ?? 0));
        state = state.copyWith(
          isUpcomingLoading: false,
          upcomingBookings: bookings,
        );
      case Error():
        // The API answers 404 "Booking not found" when the driver has none
        // left, so clear the list — holding the old one kept a just-cancelled
        // booking on screen. Other failures keep whatever is already shown.
        state = state.copyWith(
          isUpcomingLoading: false,
          upcomingBookings:
              response.responseCode == 404 ? const [] : state.upcomingBookings,
        );
      case Loading():
        break;
    }
  }

  // ── Past Bookings (History) ───────────────────────────────────────

  Future<void> _fetchBookingHistory() async {
    final isFirstPage = _currentPage == 1;
    state = state.copyWith(
      isHistoryLoading: isFirstPage,
      isPaginationLoading: !isFirstPage,
    );

    final dateRange = _getDateRange();
    final startStr = _toApiDateString(dateRange.$1);
    final endStr = _toApiDateString(dateRange.$2);

    final response = await _historyRepository.getBookingHistory(
      startDate: startStr,
      endDate: endStr,
      page: _currentPage,
      limit: _pageLimit,
    );

    switch (response) {
      case Success<TripBookingHistoryResponse>():
        final newBookings = response.data?.bookings ?? [];
        _totalCount = response.data?.dataCount ?? 0;

        final allBookings = isFirstPage
            ? newBookings
            : [...state.pastBookings, ...newBookings];

        final featuredBookingId = allBookings.firstOrNull?.id;

        state = state.copyWith(
          isHistoryLoading: false,
          isPaginationLoading: false,
          pastBookings: allBookings,
          isDataNotFound: allBookings.isEmpty,
          clearFeaturedBookingDetail: isFirstPage && allBookings.isEmpty,
        );

        if (featuredBookingId != null &&
            featuredBookingId != state.featuredBookingDetail?.id) {
          await _fetchFeaturedBookingDetail(featuredBookingId);
        }
      case Error():
        state = state.copyWith(
          isHistoryLoading: false,
          isPaginationLoading: false,
          isDataNotFound: isFirstPage && state.pastBookings.isEmpty,
        );
      case Loading():
        break;
    }
  }

  void loadNextPage() {
    if (state.isPaginationLoading || state.isHistoryLoading) return;
    if (state.pastBookings.length >= _totalCount) return;
    _currentPage++;
    _fetchBookingHistory();
  }

  // ── Filtering ─────────────────────────────────────────────────────

  void selectFilter(int index) {
    state = state.copyWith(selectedFilter: index);
  }

  void selectDate(DateTime date, {required bool isFromDate}) {
    if (isFromDate) {
      state = state.copyWith(fromDate: date);
    } else {
      state = state.copyWith(toDate: date);
    }
  }

  void applyFilter() {
    _currentPage = 1;
    _totalCount = 0;
    state = state.copyWith(
      previousSelectedFilter: state.selectedFilter,
      pastBookings: const [],
      isDataNotFound: false,
      clearFeaturedBookingDetail: true,
    );
    _fetchBookingHistory();
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }

  // ── Date Range Helpers ────────────────────────────────────────────

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (state.selectedFilter) {
      case HistoryFilter.last7Days:
        return (now.subtract(const Duration(days: 7)), now);
      case HistoryFilter.currentMonth:
        return (DateTime(now.year, now.month, 1), now);
      case HistoryFilter.previousMonth:
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        final lastDay = DateTime(now.year, now.month, 0);
        return (prevMonth, lastDay);
      case HistoryFilter.previous6Months:
        return (DateTime(now.year, now.month - 6, 1), now);
      case HistoryFilter.specificDates:
        final from = state.fromDate ?? now.subtract(const Duration(days: 7));
        final to = state.toDate ?? now;
        return (from, to);
      default:
        return (now.subtract(const Duration(days: 7)), now);
    }
  }

  String _toApiDateString(DateTime date) {
    return AppDateUtils.toApiDateString(date);
  }

  Future<void> _fetchFeaturedBookingDetail(String bookingId) async {
    final response = await _historyRepository.getBookingHistoryDetail(bookingId);
    switch (response) {
      case Success<BookingDetailResponse>():
        final booking = response.data?.booking;
        if (booking != null && booking.id == bookingId) {
          state = state.copyWith(featuredBookingDetail: booking);
        }
      case Error():
        break;
      case Loading():
        break;
    }
  }
}

final activityViewModelProvider =
    StateNotifierProvider.autoDispose<ActivityViewModel, ActivityState>((ref) {
  final appRepo = ref.watch(appRepositoryProvider);
  final historyRepo = ref.watch(historyRepositoryProvider);
  return ActivityViewModel(appRepo, historyRepo);
});
