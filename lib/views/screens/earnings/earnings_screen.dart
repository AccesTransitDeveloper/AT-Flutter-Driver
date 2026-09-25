import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/responses/earning/earning_response.dart';
import '../../../viewmodels/earning_viewmodel.dart';
import '../../bottomsheets/week_picker_bottomsheet.dart';
import '../../item/earning_booking_item.dart';
import '../../item/earning_grid_item.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final earningState = ref.watch(earningViewModelProvider);
    final viewModel = ref.read(earningViewModelProvider.notifier);

    // Show error snackbar
    ref.listen<EarningState>(earningViewModelProvider, (prev, next) {
      if (next.error != null &&
          next.error!.isNotEmpty &&
          next.error != prev?.error) {
        context.showErrorSnackBar(next.error!);
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingEarnings, 'heading_earnings'),
            ),
            Expanded(
              child: earningState.isLoading
                  ? _buildShimmer(context, colors)
                  : RefreshIndicator(
                      onRefresh: () => viewModel.loadEarning(),
                      color: colors.colorPrimary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(
                                context, colors, earningState, viewModel),
                            const SizedBox(height: AppDimens.paddingM),
                            _buildMetricsGrid(context, colors, earningState),
                            const SizedBox(height: AppDimens.paddingM),
                            _buildEarningStatisticsSection(
                                context, colors, earningState, viewModel),
                            const SizedBox(height: AppDimens.paddingXXL),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppColorPalette colors,
    EarningState state,
    EarningViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: colors.colorPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total earning
          AppText(
            state.totalEarning.isNotEmpty ? state.totalEarning : '--',
            fontSize: AppTypos.headingLarge,
            fontWeight: FontWeight.w800,
            color: colors.colorButtonText,
          ),
          const SizedBox(height: AppDimens.paddingXS),

          // Period label
          AppText.caption(
            state.periodLabel,
            color: colors.colorButtonText.withValues(alpha: 0.8),
          ),
          const SizedBox(height: AppDimens.paddingM),

          // Date range picker button
          GestureDetector(
            onTap: () => _showDateRangePicker(context, viewModel),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingM,
                vertical: AppDimens.paddingS,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                    color: colors.colorButtonText.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colors.colorButtonText,
                  ),
                  const SizedBox(width: AppDimens.paddingXS),
                  AppText.caption(
                    getString(
                        appStr.buttonSelectDateRange, 'button_select_date_range'),
                    color: colors.colorButtonText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the weekly picker bottom sheet — mirrors Kotlin's
  /// DateRangePickerBottomSheet with LaunchedEffect week auto-snap.
  void _showDateRangePicker(
      BuildContext context, EarningViewModel viewModel) {
    WeekPickerBottomSheet.show(context, (monday, sunday) {
      viewModel.loadEarning(start: monday, end: sunday);
    });
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    AppColorPalette colors,
    EarningState state,
  ) {
    final metrics = [
      _MetricItem(
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF2196F3),
        title: getString(appStr.descriptionNetEarning, 'description_net_earning'),
        value: state.netEarning,
      ),
      _MetricItem(
        icon: Icons.payments_outlined,
        color: const Color(0xFF4CAF50),
        title: getString(appStr.descriptionCashOnHand, 'description_cash_on_hand'),
        value: state.cashOnHand,
      ),
      _MetricItem(
        icon: Icons.check_circle_outline,
        color: const Color(0xFF9C27B0),
        title: getString(
            appStr.descriptionCompletedRides, 'description_completed_rides'),
        value: state.completedRides,
      ),
      _MetricItem(
        icon: Icons.card_giftcard_outlined,
        color: const Color(0xFFFF9800),
        title:
            getString(appStr.descriptionIncentive, 'description_incentive'),
        value: state.incentive,
      ),
      _MetricItem(
        icon: Icons.cancel_outlined,
        color: const Color(0xFFF44336),
        title: getString(
            appStr.descriptionCancelledRides, 'description_cancelled_rides'),
        value: state.cancelledRides,
      ),
      _MetricItem(
        icon: Icons.warning_amber_outlined,
        color: const Color(0xFFFFC107),
        title: getString(appStr.descriptionPenalty, 'description_penalty'),
        value: state.penalty,
      ),
      _MetricItem(
        icon: Icons.person_off_outlined,
        color: const Color(0xFFE53935),
        title: getString(
            appStr.descriptionCancelledByOther, 'description_cancelled_by_other'),
        value: state.cancelledByOther,
      ),
      _MetricItem(
        icon: Icons.access_time_outlined,
        color: const Color(0xFF795548),
        title:
            getString(appStr.descriptionOnlineTime, 'description_online_time'),
        value: state.onlineTime,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.paddingS,
        mainAxisSpacing: AppDimens.paddingS,
        childAspectRatio: 1.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: metrics
            .map(
              (m) => EarningGridItem(
                icon: m.icon,
                iconColor: m.color,
                title: m.title,
                value: m.value,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Combined "Booking Statistics" section — mirrors Kotlin EarningStatistics composable.
  /// Shows individual bookings + daily date-grouped stats cards.
  Widget _buildEarningStatisticsSection(
    BuildContext context,
    AppColorPalette colors,
    EarningState state,
    EarningViewModel viewModel,
  ) {
    final hasBookings = state.bookings.isNotEmpty;
    final hasDailyStats = state.dailyEarningMap.isNotEmpty;

    if (!hasBookings && !hasDailyStats) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXXL),
          child: AppText.body(
            getString(
                appStr.descriptionNoEarningsFound,
                'description_no_earnings_found'),
            color: colors.colorTextHint,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding,
            vertical: AppDimens.paddingS,
          ),
          child: AppText(
            getString(
                appStr.subHeadingEarningStatistics,
                'sub_heading_earning_statistics'),
            fontSize: AppTypos.textL,
            fontWeight: FontWeight.w700,
          ),
        ),

        // Individual booking items
        if (hasBookings)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.bookings.length,
            itemBuilder: (context, index) => EarningBookingItem(
              booking: state.bookings[index],
              formatCurrency: viewModel.formatBookingCurrency,
            ),
          ),

        // Daily stats grouped by date
        ...state.dailyEarningMap.entries.map(
          (entry) => _buildDailyEarningCard(
              context, colors, entry.key, entry.value, viewModel),
        ),
      ],
    );
  }

  Widget _buildDailyEarningCard(
    BuildContext context,
    AppColorPalette colors,
    String date,
    EarningDetail detail,
    EarningViewModel viewModel,
  ) {
    final rows = [
      (
        title: getString(appStr.descriptionEarningTotalEarning,
            'description_earning_total_earning'),
        value: viewModel.formatBookingCurrency(detail.driverProfit),
      ),
      (
        title: getString(appStr.descriptionEarningCompletedRides,
            'description_earning_completed_rides'),
        value: (detail.completedBookings ?? 0).toString(),
      ),
      (
        title: getString(appStr.descriptionTotalCancelledBooking,
            'description_total_cancelled_booking'),
        value: (detail.cancelledBookings ?? 0).toString(),
      ),
      (
        title: getString(appStr.descriptionIncentive, 'description_incentive'),
        value: viewModel.formatBookingCurrency(detail.incentive),
      ),
      (
        title: getString(appStr.descriptionDeduction, 'description_deduction'),
        value: viewModel.formatBookingCurrency(detail.penalty),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingXS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorBackground,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          border: Border.all(color: colors.colorBackgroundGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header — matches inbox StickyDateHeaderDelegate style
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingM,
                vertical: AppDimens.paddingS,
              ),
              decoration: BoxDecoration(
                color: colors.colorPrimary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.buttonRadius),
                  topRight: Radius.circular(AppDimens.buttonRadius),
                  bottomLeft: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                ),
              ),
              child: AppText.caption(
                date,
                color: colors.colorButtonText,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Sub-detail rows
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingM,
                  vertical: AppDimens.paddingXS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.caption(row.title, color: colors.colorTextHint),
                    AppText.caption(
                      row.value,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),

            // "View Details" button
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimens.paddingM,
                top: AppDimens.paddingXS,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (detail.timestamp != null) {
                      final day = DateTime.fromMillisecondsSinceEpoch(
                          detail.timestamp!);
                      viewModel.loadEarning(start: day, end: day);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingXL,
                      vertical: AppDimens.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AppText.caption(
                      getString(
                          appStr.buttonViewDetails, 'button_view_details'),
                      color: colors.colorButtonText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context, AppColorPalette colors) {
    return Shimmer.fromColors(
      baseColor: colors.colorBackgroundGray,
      highlightColor: colors.colorBackground,
      child: Column(
        children: [
          // Header shimmer
          Container(
            width: double.infinity,
            height: 120,
            color: colors.colorBackgroundGray,
          ),
          const SizedBox(height: AppDimens.paddingM),

          // Grid shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.paddingS,
              mainAxisSpacing: AppDimens.paddingS,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                8,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: colors.colorBackgroundGray,
                    borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });
}
