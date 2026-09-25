import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/booking/bids_response.dart';
import '../../../viewmodels/bidding_request_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class BiddingRequestScreen extends ConsumerWidget {
  const BiddingRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biddingRequestViewModelProvider);
    final colors = context.colors;

    ref.listen<BiddingRequestState>(biddingRequestViewModelProvider,
        (prev, next) {
      if (next.snackBarMessage != null &&
          next.snackBarMessage != prev?.snackBarMessage) {
        context.showErrorSnackBar(next.snackBarMessage!);
        ref.read(biddingRequestViewModelProvider.notifier).clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingBiddingRequest, 'heading_bidding_request'),
            ),
            Expanded(child: _buildBody(state, colors, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BiddingRequestState state, AppColorPalette colors, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.biddingRequests.isEmpty) {
      return Center(
        child: AppText(
          getString(appStr.errorNoRecordFound, 'error_no_record_found'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      itemCount: state.biddingRequests.length,
      itemBuilder: (context, index) {
        final item = state.biddingRequests[index];
        return _BiddingRequestItemWidget(
          item: item,
          viewModel: ref.read(biddingRequestViewModelProvider.notifier),
        );
      },
    );
  }
}

class _BiddingRequestItemWidget extends StatefulWidget {
  final BiddingRequestItem item;
  final BiddingRequestViewModel viewModel;

  const _BiddingRequestItemWidget({
    required this.item,
    required this.viewModel,
  });

  @override
  State<_BiddingRequestItemWidget> createState() =>
      _BiddingRequestItemWidgetState();
}

class _BiddingRequestItemWidgetState extends State<_BiddingRequestItemWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.item.biddingDetail?.remainingTime ?? 0;
    if (_remainingSeconds > 0) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        widget.viewModel.removeBid(widget.item.id ?? '');
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = widget.item;
    final bidPriceFormatted =
        widget.viewModel.formatBidPrice(item.biddingDetail?.bid?.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.paddingM),

        // Booking ID
        AppText.caption(
          getString(appStr.descriptionBookingId, 'description_booking_id')
              .replacePlaceholders(
                  {StringConstant.bookingNo: item.uniqueId ?? ''}),
          color: colors.colorTextHint,
        ),
        const SizedBox(height: AppDimens.paddingXS),

        // Customer name + rating
        Row(
          children: [
            Expanded(
              child: AppText.body(
                item.customerDetail?.name ?? '',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.customerDetail?.rate != null) ...[
              const SizedBox(width: AppDimens.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: colors.colorPrimary),
                    const SizedBox(width: 2),
                    AppText.caption(
                      item.customerDetail!.rate!.toStringAsFixed(1),
                      fontWeight: FontWeight.w600,
                      color: colors.colorPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimens.paddingXS),

        // Bid price
        AppText.caption(
          getString(appStr.descriptionBiddingPrice, 'description_bidding_price')
              .replacePlaceholders({StringConstant.amount: bidPriceFormatted}),
          color: colors.colorTextHint,
        ),
        const SizedBox(height: AppDimens.paddingM),

        // Reject button + Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Reject button
            AppFilledButton(
              text: getString(appStr.buttonReject, 'button_reject'),
              onPressed: () =>
                  widget.viewModel.rejectBid(item.id ?? ''),
              backgroundColor: colors.colorWarning.withValues(alpha: 0.1),
              textColor: colors.colorWarning,
              height: 32,
              borderRadius: 5,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingM,
              ),
            ),

            // Timer
            AppText.body(
              _formatTime(_remainingSeconds),
              color: colors.colorWarning,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
          child: Divider(color: colors.colorBackgroundGray, height: 1),
        ),
      ],
    );
  }
}
