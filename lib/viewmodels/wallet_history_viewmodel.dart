import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../core/constants/app_constants.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/date_utils.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/payment/transaction_credit_response.dart';

/// Wallet history screen state
class WalletHistoryState {
  final List<TransactionCredit> transactions;
  final Map<String, List<TransactionCredit>> groupedTransactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool endReached;
  final String? error;

  // Currency settings
  final int currencyDirection;
  final String currencySign;
  final int decimalPointValue;

  const WalletHistoryState({
    this.transactions = const [],
    this.groupedTransactions = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.endReached = false,
    this.error,
    this.currencyDirection = 1,
    this.currencySign = '',
    this.decimalPointValue = 2,
  });

  WalletHistoryState copyWith({
    List<TransactionCredit>? transactions,
    Map<String, List<TransactionCredit>>? groupedTransactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? endReached,
    String? error,
    bool clearError = false,
    int? currencyDirection,
    String? currencySign,
    int? decimalPointValue,
  }) {
    return WalletHistoryState(
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      endReached: endReached ?? this.endReached,
      error: clearError ? null : (error ?? this.error),
      currencyDirection: currencyDirection ?? this.currencyDirection,
      currencySign: currencySign ?? this.currencySign,
      decimalPointValue: decimalPointValue ?? this.decimalPointValue,
    );
  }
}

/// Wallet history screen ViewModel
class WalletHistoryViewModel extends StateNotifier<WalletHistoryState> {
  final AppRepository _appRepository;

  int _currentPage = 1;
  bool _isFirstLoad = true;

  WalletHistoryViewModel(
    this._appRepository,
    SharedPreferenceManager sharedPref,
  ) : super(const WalletHistoryState()) {
    final setting = sharedPref.getSetting();
    state = state.copyWith(
      currencyDirection: setting?.setCurrencySign ?? 1,
      currencySign: setting?.currencySign ?? '',
      decimalPointValue: setting?.decimalPointValue ?? 2,
    );
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_isFirstLoad) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final response =
        await _appRepository.getTransactionCredit(page: _currentPage);

    switch (response) {
      case Success<TransactionCreditResponse>():
        final newTransactions = response.data?.transactions ?? [];

        if (newTransactions.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            endReached: true,
          );
        } else {
          List<TransactionCredit> allTransactions;
          if (_currentPage == 1) {
            allTransactions = newTransactions;
          } else {
            allTransactions = [...state.transactions, ...newTransactions];
          }

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            transactions: allTransactions,
            groupedTransactions: _groupByMonth(allTransactions),
            endReached: false,
          );
          _currentPage++;
        }
        _isFirstLoad = false;

      case Error():
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.error?.message,
        );
        _isFirstLoad = false;

      case Loading():
        break;
    }
  }

  /// Load more transactions (pagination)
  void loadMore() {
    if (!state.isLoading && !state.isLoadingMore && !state.endReached) {
      _loadTransactions();
    }
  }

  /// Format currency value
  String formatCurrency(double? value) {
    if (value == null) return '';
    final formatted = value.toStringAsFixed(state.decimalPointValue);
    if (state.currencySign.isEmpty) return formatted;
    if (state.currencyDirection == 2) return '$formatted${state.currencySign}';
    return '${state.currencySign}$formatted';
  }

  /// Group transactions by month (MMMM yyyy)
  Map<String, List<TransactionCredit>> _groupByMonth(
      List<TransactionCredit> transactions) {
    final Map<String, List<TransactionCredit>> grouped = {};

    for (final transaction in transactions) {
      if (transaction.createdAt != null) {
        final date = AppDateUtils.convertUtcToLocal(transaction.createdAt!);
        if (date != null) {
          final monthKey = AppDateUtils.format(
              date, DateFormat.dateFormatWithSpace);
          if (monthKey.isNotEmpty) {
            // Use month-year as key (e.g., "February 2026")
            final monthYear = intl.DateFormat('MMMM yyyy').format(date);
            grouped.putIfAbsent(monthYear, () => []);
            grouped[monthYear]!.add(transaction);
          }
        }
      }
    }

    return grouped;
  }

}

/// Provider for WalletHistoryViewModel
final walletHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<WalletHistoryViewModel, WalletHistoryState>(
        (ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return WalletHistoryViewModel(appRepository, sharedPref);
});
