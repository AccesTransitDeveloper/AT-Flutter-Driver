import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../core/localization/app_strings.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/history_repository.dart';
import '../models/responses/earning/earning_response.dart';

class EarningState {
  final bool isLoading;
  final String totalEarning;
  final String periodLabel;
  final String netEarning;
  final String cashOnHand;
  final String completedRides;
  final String incentive;
  final String cancelledRides;
  final String penalty;
  final String cancelledByOther;
  final String onlineTime;
  final List<EarningBooking> bookings;
  final Map<String, EarningDetail> dailyEarningMap;
  final String? error;

  const EarningState({
    this.isLoading = false,
    this.totalEarning = '',
    this.periodLabel = '',
    this.netEarning = '--',
    this.cashOnHand = '--',
    this.completedRides = '--',
    this.incentive = '--',
    this.cancelledRides = '--',
    this.penalty = '--',
    this.cancelledByOther = '--',
    this.onlineTime = '--',
    this.bookings = const [],
    this.dailyEarningMap = const {},
    this.error,
  });

  EarningState copyWith({
    bool? isLoading,
    String? totalEarning,
    String? periodLabel,
    String? netEarning,
    String? cashOnHand,
    String? completedRides,
    String? incentive,
    String? cancelledRides,
    String? penalty,
    String? cancelledByOther,
    String? onlineTime,
    List<EarningBooking>? bookings,
    Map<String, EarningDetail>? dailyEarningMap,
    String? error,
  }) {
    return EarningState(
      isLoading: isLoading ?? this.isLoading,
      totalEarning: totalEarning ?? this.totalEarning,
      periodLabel: periodLabel ?? this.periodLabel,
      netEarning: netEarning ?? this.netEarning,
      cashOnHand: cashOnHand ?? this.cashOnHand,
      completedRides: completedRides ?? this.completedRides,
      incentive: incentive ?? this.incentive,
      cancelledRides: cancelledRides ?? this.cancelledRides,
      penalty: penalty ?? this.penalty,
      cancelledByOther: cancelledByOther ?? this.cancelledByOther,
      onlineTime: onlineTime ?? this.onlineTime,
      bookings: bookings ?? this.bookings,
      dailyEarningMap: dailyEarningMap ?? this.dailyEarningMap,
      error: error,
    );
  }
}

class EarningViewModel extends StateNotifier<EarningState> {
  final HistoryRepository _historyRepository;
  final SharedPreferenceManager? _sharedPref;

  // Currency settings
  late final String _currencySign;
  late final int _currencyDirection; // 1 = prefix, 2 = suffix
  late final int _decimalPoints;

  EarningViewModel(this._historyRepository, this._sharedPref)
      : super(const EarningState()) {
    _initCurrencySettings();
    loadEarning();
  }

  void _initCurrencySettings() {
    final setting = _sharedPref?.getSetting();
    _currencySign = setting?.currencySign ?? '';
    _currencyDirection = setting?.setCurrencySign ?? 1;
    _decimalPoints = setting?.decimalPointValue ?? 2;
  }

  Future<void> loadEarning({DateTime? start, DateTime? end}) async {
    final now = DateTime.now();
    final startDate = start ?? now;
    final endDate = end ?? startDate;
    final isRange = end != null && start != null &&
        (end.year != start.year ||
            end.month != start.month ||
            end.day != start.day);

    final startStr = _toApiDateString(startDate);
    final endStr = _toApiDateString(endDate);
    final periodLabel = _formatPeriodLabel(startDate, isRange ? endDate : null);

    state = state.copyWith(isLoading: true, periodLabel: periodLabel);

    final response = await _historyRepository.getEarning(
      startDate: startStr,
      endDate: endStr,
      isGroupByDate: isRange,
    );

    switch (response) {
      case Success<EarningResponse>():
        final data = response.data;
        final detail = data?.earningDetail;
        final analytics = data?.driverAnalytics;

        // Build daily earning map grouped by formatted date from timestamp
        final dailyList = data?.dailyEarningDetail ?? [];
        final dailyMap = <String, EarningDetail>{};
        for (final d in dailyList) {
          if (d.timestamp == null) continue;
          final dateKey = intl.DateFormat('dd MMM yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(d.timestamp!),
          );
          dailyMap[dateKey] = d;
        }

        state = state.copyWith(
          isLoading: false,
          totalEarning: _formatCurrency(detail?.driverProfit),
          netEarning: _formatCurrency(detail?.netEarning),
          cashOnHand: _formatCurrency(detail?.cashOnHand),
          completedRides: (analytics?.completed ?? 0).toString(),
          incentive: _formatCurrency(detail?.incentive),
          cancelledRides: (analytics?.cancelled ?? 0).toString(),
          penalty: _formatCurrency(detail?.penalty),
          cancelledByOther: (analytics?.cancelledByOther ?? 0).toString(),
          onlineTime: _formatOnlineTime(analytics?.totalOnlineTimeSec),
          bookings: data?.bookings ?? [],
          dailyEarningMap: dailyMap,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message,
        );
      case Loading():
        break;
    }
  }

  String _formatCurrency(double? value) {
    if (value == null) return '--';
    final formatted = value.toStringAsFixed(_decimalPoints);
    if (_currencySign.isEmpty) return formatted;
    if (_currencyDirection == 2) return '$formatted$_currencySign';
    return '$_currencySign$formatted';
  }

  String _formatOnlineTime(double? seconds) {
    final minUnit = getString(appStr.descriptionMinutesUnit, 'description_minutes_unit');
    final hrUnit = getString(appStr.descriptionHoursUnit, 'description_hours_unit');
    if (seconds == null || seconds <= 0) return '0 $minUnit';
    final totalMinutes = (seconds / 60).floor();
    if (totalMinutes < 60) return '$totalMinutes $minUnit';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '$hours $hrUnit';
    return '$hours $hrUnit $minutes $minUnit';
  }

  String _formatPeriodLabel(DateTime start, DateTime? end) {
    if (end == null) {
      final now = DateTime.now();
      if (start.year == now.year &&
          start.month == now.month &&
          start.day == now.day) {
        return getString(appStr.descriptionTodaysEarning, 'description_todays_earning');
      }
      return intl.DateFormat('dd MMM yyyy').format(start);
    }
    // Date range
    final startFmt = intl.DateFormat('dd MMM').format(start);
    final endFmt = intl.DateFormat('dd MMM yyyy').format(end);
    if (start.month == end.month && start.year == end.year) {
      return '${intl.DateFormat('dd').format(start)}-${intl.DateFormat('dd MMM yyyy').format(end)}';
    }
    return '$startFmt - $endFmt';
  }

  String _toApiDateString(DateTime date) {
    return intl.DateFormat('yyyy-MM-dd').format(date);
  }

  String formatBookingCurrency(double? value) => _formatCurrency(value);
}

final earningViewModelProvider =
    StateNotifierProvider.autoDispose<EarningViewModel, EarningState>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).valueOrNull;
  return EarningViewModel(repo, sharedPref);
});
