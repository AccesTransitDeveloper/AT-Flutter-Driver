import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/date_utils.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/redeem_withdraw_request.dart';
import '../models/responses/redeem/redeem_point_response.dart';

/// Redeem screen state
class RedeemState {
  final double totalRedeemPoints;
  final List<RedeemTransaction> transactions;
  final Map<String, List<RedeemTransaction>> groupedTransactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isWithdrawing;
  final bool endReached;
  final String? error;
  final String? successMessage;
  final String withdrawAmount;
  final String convertedPrice;
  final String currencySign;
  final bool showWithdrawSheet;
  final String? withdrawError;

  const RedeemState({
    this.totalRedeemPoints = 0.0,
    this.transactions = const [],
    this.groupedTransactions = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isWithdrawing = false,
    this.endReached = false,
    this.error,
    this.successMessage,
    this.withdrawAmount = '',
    this.convertedPrice = '',
    this.currencySign = '',
    this.showWithdrawSheet = false,
    this.withdrawError,
  });

  RedeemState copyWith({
    double? totalRedeemPoints,
    List<RedeemTransaction>? transactions,
    Map<String, List<RedeemTransaction>>? groupedTransactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isWithdrawing,
    bool? endReached,
    String? error,
    String? successMessage,
    String? withdrawAmount,
    String? convertedPrice,
    String? currencySign,
    bool? showWithdrawSheet,
    String? withdrawError,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearWithdrawError = false,
  }) {
    return RedeemState(
      totalRedeemPoints: totalRedeemPoints ?? this.totalRedeemPoints,
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      endReached: endReached ?? this.endReached,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      convertedPrice: convertedPrice ?? this.convertedPrice,
      currencySign: currencySign ?? this.currencySign,
      showWithdrawSheet: showWithdrawSheet ?? this.showWithdrawSheet,
      withdrawError: clearWithdrawError ? null : (withdrawError ?? this.withdrawError),
    );
  }
}

/// Redeem screen ViewModel
class RedeemViewModel extends StateNotifier<RedeemState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  int _currentPage = 1;
  final int _limit = 10;
  bool _isFirstLoad = true;

  RedeemViewModel(this._appRepository, this._sharedPref)
      : super(const RedeemState()) {
    _initState();
  }

  void _initState() {
    final entity = _sharedPref.getEntity();
    final setting = _sharedPref.getSetting();
    final currencySign = setting?.currencySign ?? '';
    state = state.copyWith(
      totalRedeemPoints: entity?.reward ?? 0.0,
      currencySign: currencySign,
    );
    loadRewardPoints();
  }

  Future<void> loadRewardPoints() async {
    if (_isFirstLoad) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final response = await _appRepository.getRewardPoints(
      page: _currentPage,
      limit: _limit,
    );

    switch (response) {
      case Success<RedeemPointResponse>():
        final newTransactions = response.data?.transactions ?? [];
        final totalPages = response.data?.pages ?? 0;

        final List<RedeemTransaction> allTransactions;
        if (_currentPage == 1) {
          allTransactions = newTransactions;
        } else {
          allTransactions = [...state.transactions, ...newTransactions];
        }

        // Update balance from most recent transaction if available
        double updatedPoints = state.totalRedeemPoints;
        if (_currentPage == 1 && newTransactions.isNotEmpty) {
          updatedPoints = newTransactions.first.totalRewardPoint ?? state.totalRedeemPoints;
        }

        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          transactions: allTransactions,
          groupedTransactions: _groupByMonth(allTransactions),
          endReached: totalPages <= 0 || allTransactions.length >= totalPages * _limit,
          totalRedeemPoints: updatedPoints,
        );
        _currentPage++;
        _isFirstLoad = false;

      case Error():
        debugPrint('💰 RedeemViewModel - Error: ${response.error?.message}');
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.error?.message ?? '',
        );
        _isFirstLoad = false;

      case Loading():
        break;
    }
  }

  void loadMore() {
    if (!state.isLoading && !state.isLoadingMore && !state.endReached) {
      loadRewardPoints();
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _isFirstLoad = true;
    state = state.copyWith(
      transactions: [],
      groupedTransactions: {},
      endReached: false,
      withdrawAmount: '',
      convertedPrice: '',
    );
    await loadRewardPoints();
  }

  void updateWithdrawAmount(String amount) {
    final setting = _sharedPref.getSetting();
    final valuePerPoint = setting?.rewardPointConfig?.valueOfOneRewardPoint ?? 0.0;
    final currencySign = state.currencySign;

    final points = double.tryParse(amount) ?? 0.0;
    final converted = points * valuePerPoint;
    final convertedStr = converted > 0
        ? '$currencySign${converted.toStringAsFixed(2)}'
        : '';

    final hasExceeded = amount.isNotEmpty && points > state.totalRedeemPoints;

    state = state.copyWith(
      withdrawAmount: amount,
      convertedPrice: convertedStr,
      withdrawError: hasExceeded ? 'Please enter valid redeem points' : null,
      clearWithdrawError: !hasExceeded,
    );
  }

  Future<void> withdrawPoints() async {
    final setting = _sharedPref.getSetting();
    final minPoints = setting?.rewardPointConfig?.minPointForWithdrawal ?? 0;
    final points = double.tryParse(state.withdrawAmount) ?? 0.0;

    if (state.withdrawAmount.isEmpty || points <= 0) {
      state = state.copyWith(error: 'Please enter redeem point');
      return;
    }
    if (points > state.totalRedeemPoints) {
      state = state.copyWith(error: 'Please enter valid redeem point');
      return;
    }
    if (minPoints > 0 && points < minPoints) {
      state = state.copyWith(
        error: 'Minimum redeem point value should be $minPoints points',
      );
      return;
    }

    state = state.copyWith(isWithdrawing: true, clearError: true);

    final request = RedeemWithdrawRequest(rewardPoint: points);
    final response = await _appRepository.withdrawRewardPoints(request);

    switch (response) {
      case Success():
        // Reload from page 1 after withdrawal
        _currentPage = 1;
        _isFirstLoad = true;
        state = state.copyWith(
          isWithdrawing: false,
          showWithdrawSheet: false,
          withdrawAmount: '',
          convertedPrice: '',
          transactions: [],
          groupedTransactions: {},
          endReached: false,
          successMessage: response.message ?? '',
        );
        await loadRewardPoints();

      case Error():
        state = state.copyWith(
          isWithdrawing: false,
          error: response.error?.message ?? '',
        );

      case Loading():
        break;
    }
  }

  void showWithdrawSheet() {
    state = state.copyWith(showWithdrawSheet: true);
  }

  void hideWithdrawSheet() {
    state = state.copyWith(showWithdrawSheet: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Group transactions by "Month Year" (e.g., "January 2025")
  Map<String, List<RedeemTransaction>> _groupByMonth(
      List<RedeemTransaction> transactions) {
    final Map<String, List<RedeemTransaction>> grouped = {};
    for (final txn in transactions) {
      final monthKey = _getMonthYear(txn.createdAt);
      if (monthKey.isNotEmpty) {
        grouped.putIfAbsent(monthKey, () => []);
        grouped[monthKey]!.add(txn);
      }
    }
    return grouped;
  }

  String _getMonthYear(String? dateString) {
    final date = AppDateUtils.parse(dateString);
    if (date == null) return '';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Provider for RedeemViewModel
final redeemViewModelProvider =
    StateNotifierProvider.autoDispose<RedeemViewModel, RedeemState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return RedeemViewModel(appRepository, sharedPref);
});
