import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/wallet_utils.dart';
import '../../../models/responses/payment/transaction_credit_response.dart';
import '../../../viewmodels/wallet_history_viewmodel.dart';
import '../../item/sticky_date_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(walletHistoryViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(walletHistoryViewModelProvider);

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingWalletHistory, 'heading_wallet_history'),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.groupedTransactions.isEmpty
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppDimens.padding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 64,
                                  color: colors.colorText
                                      .withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: AppDimens.padding),
                                AppText.body(
                                  getString(
                                      appStr.errorNoWalletHistoryFound,
                                      'error_no_wallet_history_found'),
                                  color: colors.colorText
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _TransactionsList(
                          scrollController: _scrollController,
                          groupedTransactions: state.groupedTransactions,
                          isLoadingMore: state.isLoadingMore,
                          currencyDirection: state.currencyDirection,
                          currencySign: state.currencySign,
                          decimalPointValue: state.decimalPointValue,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, List<TransactionCredit>> groupedTransactions;
  final bool isLoadingMore;
  final int currencyDirection;
  final String currencySign;
  final int decimalPointValue;

  const _TransactionsList({
    required this.scrollController,
    required this.groupedTransactions,
    required this.isLoadingMore,
    required this.currencyDirection,
    required this.currencySign,
    required this.decimalPointValue,
  });

  @override
  Widget build(BuildContext context) {
    final entries = groupedTransactions.entries.toList();

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        for (final entry in entries)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyDateHeaderDelegate(
                  date: entry.key,
                  colors: context.colors,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _TransactionItem(
                      transaction: entry.value[index],
                      showDivider: index < entry.value.length - 1,
                      currencyDirection: currencyDirection,
                      currencySign: currencySign,
                      decimalPointValue: decimalPointValue,
                    );
                  },
                  childCount: entry.value.length,
                ),
              ),
            ],
          ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.padding),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimens.paddingXL),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionCredit transaction;
  final bool showDivider;
  final int currencyDirection;
  final String currencySign;
  final int decimalPointValue;

  const _TransactionItem({
    required this.transaction,
    required this.showDivider,
    required this.currencyDirection,
    required this.currencySign,
    required this.decimalPointValue,
  });

  String _formatAmount(double? value) {
    if (value == null) return '';
    final formatted = value.toStringAsFixed(decimalPointValue);
    if (currencySign.isEmpty) return formatted;
    if (currencyDirection == 2) return '$formatted$currencySign';
    return '$currencySign$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final description = getWalletDescription(transaction);
    final localDate =
        AppDateUtils.convertUtcToLocal(transaction.createdAt ?? '');
    final dateTime = localDate != null
        ? AppDateUtils.format(localDate, DateFormat.dayMonthTimeYearFormat)
        : '';
    final formattedAmount = _formatAmount(transaction.amount);
    final isAdded = transaction.status == CreditStatus.added;
    final transactionId =
        '${getString(appStr.descriptionTransactionId, 'description_transaction_id')} ${transaction.uniqueId ?? ''}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingM,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.colorText.withValues(alpha: 0.1),
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Plus/Minus icon
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingS),
            decoration: BoxDecoration(
              color: isAdded
                  ? Colors.green.withValues(alpha: 0.1)
                  : colors.colorWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.paddingS),
            ),
            child: Icon(
              isAdded ? Icons.add : Icons.remove,
              color: isAdded ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.paddingM),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  transactionId,
                  color: colors.colorTextHint,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                AppText.body(
                  description,
                  fontWeight: FontWeight.w600,
                ),
                if (dateTime.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.paddingXS),
                  AppText.caption(
                    dateTime,
                    color: colors.colorTextHint,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: AppDimens.paddingM),

          // Amount
          AppText.body(
            '${isAdded ? '+' : '-'}$formattedAmount',
            fontWeight: FontWeight.w600,
            color: isAdded ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
