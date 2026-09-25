import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/redeem_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/redeem/redeem_point_response.dart';
import '../../../viewmodels/redeem_viewmodel.dart';
import '../../bottomsheets/redeem_points_bottomsheet.dart';
import '../../item/sticky_date_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class RedeemScreen extends ConsumerStatefulWidget {
  const RedeemScreen({super.key});

  @override
  ConsumerState<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends ConsumerState<RedeemScreen> {
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
      ref.read(redeemViewModelProvider.notifier).loadMore();
    }
  }

  void _showWithdrawSheet() {
    final viewModel = ref.read(redeemViewModelProvider.notifier);
    viewModel.showWithdrawSheet();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.colorBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const RedeemPointsBottomSheet(),
    ).then((_) {
      viewModel.hideWithdrawSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(redeemViewModelProvider);

    ref.listen<RedeemState>(redeemViewModelProvider, (previous, next) {
      if (next.successMessage != null && previous?.successMessage == null) {
        if (next.showWithdrawSheet == false && previous?.showWithdrawSheet == true) {
          context.goBack();
        }
        context.showSnackBar(next.successMessage!);
        ref.read(redeemViewModelProvider.notifier).clearSuccess();
      }
      if (next.error != null && previous?.error == null) {
        context.showErrorSnackBar(next.error!);
        ref.read(redeemViewModelProvider.notifier).clearError();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppToolbar(
              title: getString(appStr.headingRedeem, 'heading_redeem'),
            ),

            _RedeemCard(
              points: state.totalRedeemPoints,
              onRedeem: _showWithdrawSheet,
            ),

            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(redeemViewModelProvider.notifier).refresh(),
                      child: state.transactions.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  child: Center(
                                    child: AppText.body(
                                      getString(appStr.errorNoRedeemHistoryFound, 'error_no_redeem_history_found'),
                                      color: colors.colorText,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _TransactionsList(
                              scrollController: _scrollController,
                              groupedTransactions: state.groupedTransactions,
                              isLoadingMore: state.isLoadingMore,
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final double points;
  final VoidCallback onRedeem;

  const _RedeemCard({
    required this.points,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppDimens.padding),
      padding: const EdgeInsets.all(AppDimens.padding),
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            decoration: BoxDecoration(
              color: colors.colorBackground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.paddingM),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: colors.colorPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimens.padding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  getString(appStr.descriptionAvailablePoints, 'description_available_points'),
                  color: colors.colorTextHint,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                AppText.heading(
                  '${points.toInt()}',
                  color: colors.colorText,
                ),
              ],
            ),
          ),

          AppFilledButton(
            text: getString(appStr.buttonRedeem, 'button_redeem'),
            onPressed: points > 0 ? onRedeem : null,
            enabled: points > 0,
            backgroundColor: colors.colorSecondary,
            shrinkWrap: true,
            height: 40,
            borderRadius: AppDimens.buttonRadiusSmall,
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, List<RedeemTransaction>> groupedTransactions;
  final bool isLoadingMore;

  const _TransactionsList({
    required this.scrollController,
    required this.groupedTransactions,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  colors: colors,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _TransactionItem(transaction: entry.value[index]);
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
  final RedeemTransaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final totalPoints = transaction.totalRewardPoint?.toInt() ?? 0;
    final points = transaction.rewardPoint?.toInt() ?? 0;
    final description = getRedeemDescription(transaction);
    final dateTime = AppDateUtils.formatString(
      transaction.createdAt,
      DateFormat.dateMonthHourMinuteFormat,
    );
    final isDeducted = transaction.status == RedeemPointStatus.deducted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.colorText.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingS),
            decoration: BoxDecoration(
              color: isDeducted
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.paddingS),
            ),
            child: Icon(
              isDeducted ? Icons.remove : Icons.add,
              color: isDeducted ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.paddingM),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  description,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                AppText.caption(
                  dateTime,
                  color: colors.colorText,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.body(
                '${isDeducted ? '-' : '+'}$points',
                fontWeight: FontWeight.w600,
                color: isDeducted ? Colors.red : Colors.green,
              ),
              const SizedBox(height: AppDimens.paddingXS),
              AppText.caption(
                getString(appStr.descriptionBalance, 'description_balance').replacePlaceholders({
                  StringConstant.value: totalPoints.toString(),
                }),
                color: colors.colorText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
