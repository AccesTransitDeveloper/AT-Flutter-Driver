import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/map/interface/map_interface.dart';
import '../../../core/map/models/map_types.dart';
import '../../../core/map/providers/map_provider.dart';
import '../../../core/map/widgets/map_host.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/api/server_config.dart';
import '../../../models/responses/activity/activity_response.dart';
import '../../../models/responses/booking/booking_detail_response.dart';
import '../../../viewmodels/activity_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final ScrollController _scrollController = ScrollController();
  late final MapInterface _featuredMapManager;
  bool _isMapConfigured = false;
  String? _featuredMapBookingId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _featuredMapManager = ref.read(mapManagerProvider)();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _featuredMapManager.dispose();
    super.dispose();
  }

  void _configureFeaturedMap(Booking booking) {
    if (_isMapConfigured) return;
    _isMapConfigured = true;

    final primaryColor = context.colors.colorPrimary.toARGB32();
    final markers = <MapMarker>[];
    final boundsPoints = <LatLng>[];

    final pickup = booking.pickupAddress;
    if (pickup != null && pickup.latitude != null && pickup.longitude != null) {
      final pos = LatLng(pickup.latitude!, pickup.longitude!);
      markers.add(MapMarker(
        id: 'pickup',
        position: pos,
        iconAsset: 'assets/images/ic_pickup.png',
        iconWidth: 32,
        iconHeight: 32,
        iconColor: primaryColor,
      ));
      boundsPoints.add(pos);
    }

    final destinations = booking.destinationAddresses ?? [];
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      if (dest.latitude != null && dest.longitude != null) {
        final pos = LatLng(dest.latitude!, dest.longitude!);
        final isLast = i == destinations.length - 1;
        markers.add(MapMarker(
          id: 'destination_$i',
          position: pos,
          iconAsset: isLast ? 'assets/images/ic_drop_off.png' : null,
          iconWidth: isLast ? 32 : 20,
          iconHeight: isLast ? 32 : 20,
          iconColor: primaryColor,
          stopNumber: isLast ? null : i + 1,
        ));
        boundsPoints.add(pos);
      }
    }

    _featuredMapManager.setMarkers(markers);

    final directionPath = booking.bookingInvoice?.actual?.directionPath ??
        booking.bookingInvoice?.estimated?.directionPath;
    if (directionPath != null && directionPath.isNotEmpty) {
      _featuredMapManager.setPolyline(MapPolyline.fromEncoded(
        encoded: directionPath,
        color: primaryColor,
      ));
    }

    if (boundsPoints.isNotEmpty) {
      _featuredMapManager.fitBounds(boundsPoints, padding: 80);
    }
  }

  void _resetFeaturedMap() {
    _isMapConfigured = false;
    _featuredMapManager.setMarkers(const []);
    _featuredMapManager.setPolyline(null);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref.read(activityViewModelProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityViewModelProvider);
    final colors = context.colors;

    ref.listen<ActivityState>(activityViewModelProvider, (prev, next) {
      if (next.snackBarMessage != null &&
          next.snackBarMessage != prev?.snackBarMessage) {
        context.showSnackBar(next.snackBarMessage!);
        ref.read(activityViewModelProvider.notifier).clearSnackBar();
      }
    });

    // Calculate list item count:
    // [0] = Upcoming section, [1] = Past header, [2+] = past items or states
    final pastBookingCount = state.pastBookings.length;
    final hasHistoryData =
        !state.isHistoryLoading && !state.isDataNotFound && pastBookingCount > 0;
    final extraCount = state.isHistoryLoading ||
            (!hasHistoryData && !state.isHistoryLoading) ||
            state.isPaginationLoading
        ? 1
        : 0;
    final itemCount = 2 + (hasHistoryData ? pastBookingCount : 0) + extraCount;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppToolbar(
              title: getString(appStr.headingActivity, 'heading_activity'),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // [0] Upcoming section
                  if (index == 0) {
                    return _buildUpcomingSection(state, colors);
                  }

                  // [1] Past section header + filter
                  if (index == 1) {
                    return _buildPastHeader(state, colors);
                  }

                  // [2+] Past booking items or states
                  final bookingIndex = index - 2;

                  // Loading shimmer
                  if (state.isHistoryLoading && bookingIndex == 0) {
                    return _buildLoadingShimmer(colors);
                  }

                  // Empty state
                  if (!hasHistoryData &&
                      !state.isHistoryLoading &&
                      bookingIndex == 0) {
                    return _buildEmptyState(
                      colors,
                      Icons.history,
                      getString(appStr.descriptionNoPastBookingsFound, 'description_no_past_bookings_found'),
                    );
                  }

                  // Past booking items
                  if (bookingIndex < pastBookingCount) {
                    final booking = state.pastBookings[bookingIndex];

                    // First item as featured card with map
                    if (bookingIndex == 0) {
                      if (_featuredMapBookingId != booking.id) {
                        _featuredMapBookingId = booking.id;
                        _resetFeaturedMap();
                      }

                      final featuredBooking = state.featuredBookingDetail;
                      if (!_isMapConfigured &&
                          featuredBooking != null &&
                          featuredBooking.id == booking.id) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _configureFeaturedMap(featuredBooking);
                        });
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: AppDimens.paddingM),
                        child: _PastBookingFeaturedCard(
                          booking: booking,
                          colors: colors,
                          mapWidget: IgnorePointer(
                            child: MapHost(manager: _featuredMapManager),
                          ),
                          onTap: () {
                            final id = booking.id ?? '';
                            context.navigateToTripDetail(bookingId: id);
                          },
                        ),
                      );
                    }

                    return Column(
                      children: [
                        _PastBookingItem(
                          booking: booking,
                          colors: colors,
                          onTap: () {
                            final id = booking.id ?? '';
                            context.navigateToTripDetail(bookingId: id);
                          },
                        ),
                        if (bookingIndex < pastBookingCount - 1)
                          Divider(
                            color: colors.colorBackgroundGray,
                            height: 1,
                          ),
                      ],
                    );
                  }

                  // Pagination loader
                  if (state.isPaginationLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(AppDimens.padding),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upcoming Section ────────────────────────────────────────────────

  Widget _buildUpcomingSection(ActivityState state, AppColorPalette colors) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.title(
            getString(appStr.headingUpcoming, 'heading_upcoming'),
            color: colors.colorText,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: AppDimens.paddingM),
          if (state.isUpcomingLoading)
            _buildUpcomingShimmer(colors)
          else if (state.upcomingBookings.isEmpty)
            _buildUpcomingEmptyState(colors)
          else
            ...state.upcomingBookings.map((booking) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                  child: _UpcomingBookingItem(
                    booking: booking,
                    colors: colors,
                    onTap: () async {
                      final id = booking.id ?? '';
                      await context.navigateToUpcomingTripDetail(bookingId: id);
                      // Always re-pull on return rather than trusting a pop
                      // result: native re-fetches every time the screen is
                      // shown (LaunchedEffect in MyBookingScreen), and the
                      // booking can change from a cancel, an accept, or a
                      // socket update while the detail screen was open.
                      if (context.mounted) {
                        ref.read(activityViewModelProvider.notifier).refresh();
                      }
                    },
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildUpcomingEmptyState(AppColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.padding),
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.paddingM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  getString(appStr.descriptionNoUpcomingBookings, 'description_no_upcoming_bookings'),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                AppText.caption(
                  getString(appStr.descriptionNoUpcomingBookingsSub, 'description_no_upcoming_bookings_sub'),
                  color: colors.colorText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_today,
            size: 32,
            color: colors.colorText.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingShimmer(AppColorPalette colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding),
        decoration: BoxDecoration(
          color: colors.colorBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(colors, width: 80, height: 12),
                  const SizedBox(height: AppDimens.paddingS),
                  _buildShimmerBox(colors, width: 140, height: 20),
                  const SizedBox(height: AppDimens.paddingS),
                  _buildShimmerBox(colors, width: 120, height: 12),
                  const SizedBox(height: AppDimens.paddingXS),
                  _buildShimmerBox(colors, width: 100, height: 12),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),
            _buildShimmerBox(colors, width: 64, height: 64, radius: AppDimens.paddingS),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
    AppColorPalette colors, {
    double? width,
    required double height,
    double radius = AppDimens.paddingXS,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Past Section Header ─────────────────────────────────────────────

  Widget _buildPastHeader(ActivityState state, AppColorPalette colors) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.title(
            getString(appStr.headingPast, 'heading_past'),
            color: colors.colorText,
            fontWeight: FontWeight.w600,
          ),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
              ),
              child: Icon(
                Icons.filter_list,
                size: 20,
                color: colors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Bottom Sheet ─────────────────────────────────────────────

  void _showFilterBottomSheet(BuildContext context) {
    final colors = context.colors;
    final vm = ref.read(activityViewModelProvider.notifier);
    final currentState = ref.read(activityViewModelProvider);

    // Temporarily track selection in bottom sheet
    int tempFilter = currentState.selectedFilter;
    DateTime? tempFrom = currentState.fromDate;
    DateTime? tempTo = currentState.toDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filterLabels = [
              getString(appStr.descriptionLast7Days, 'description_last_7_days'),
              getString(appStr.descriptionCurrentMonth, 'description_current_month'),
              getString(appStr.descriptionPreviousMonth, 'description_previous_month'),
              getString(appStr.descriptionPrevious6Months, 'description_previous_6_months'),
              getString(appStr.descriptionSpecificDates, 'description_specific_dates'),
            ];

            return Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.colorBackgroundGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.padding),

                  // Filter options
                  for (int i = 0; i < filterLabels.length; i++)
                    RadioListTile<int>(
                      value: i,
                      groupValue: tempFilter,
                      title: AppText.body(filterLabels[i]),
                      activeColor: colors.colorPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setSheetState(() => tempFilter = val!);
                      },
                    ),

                  // Date pickers for specific dates
                  if (tempFilter == HistoryFilter.specificDates) ...[
                    const SizedBox(height: AppDimens.paddingS),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePickerField(
                            context,
                            colors,
                            label: getString(appStr.descriptionFrom, 'description_from'),
                            date: tempFrom,
                            onPicked: (date) {
                              setSheetState(() => tempFrom = date);
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingM),
                        Expanded(
                          child: _buildDatePickerField(
                            context,
                            colors,
                            label: getString(appStr.descriptionTo, 'description_to'),
                            date: tempTo,
                            onPicked: (date) {
                              setSheetState(() => tempTo = date);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppDimens.padding),

                  // Apply button
                  AppFilledButton(
                    text: getString(appStr.buttonApplyFilter, 'button_apply_filter'),
                    borderRadius: AppDimens.buttonRadiusSmall,
                    onPressed: () {
                      vm.selectFilter(tempFilter);
                      if (tempFilter == HistoryFilter.specificDates) {
                        if (tempFrom != null) {
                          vm.selectDate(tempFrom!, isFromDate: true);
                        }
                        if (tempTo != null) {
                          vm.selectDate(tempTo!, isFromDate: false);
                        }
                      }
                      vm.applyFilter();
                      context.pop();
                    },
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom +
                          AppDimens.paddingS),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    AppColorPalette colors, {
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    final displayText = date != null
        ? intl.DateFormat('dd MMM yyyy').format(date)
        : label;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingM,
          vertical: AppDimens.paddingM,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.colorBackgroundGray),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
        ),
        child: AppText.body(
          displayText,
          color: date != null ? colors.colorText : colors.colorTextHint,
        ),
      ),
    );
  }

  // ── Shared Widgets ──────────────────────────────────────────────────

  Widget _buildLoadingShimmer(AppColorPalette colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          // Featured card shimmer
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.paddingM),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.paddingM),
                color: colors.colorBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: colors.colorBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimens.paddingM),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(colors, width: 120, height: 16),
                        const SizedBox(height: AppDimens.paddingS),
                        _buildShimmerBox(colors, width: 160, height: 12),
                        const SizedBox(height: AppDimens.paddingXS),
                        _buildShimmerBox(colors, width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List item shimmers
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
              child: Row(
                children: [
                  _buildShimmerBox(colors,
                      width: 60,
                      height: 60,
                      radius: AppDimens.paddingS),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(colors, width: 100, height: 14),
                        const SizedBox(height: AppDimens.paddingXS),
                        _buildShimmerBox(colors, width: 140, height: 12),
                        const SizedBox(height: AppDimens.paddingXS),
                        _buildShimmerBox(colors, width: 80, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppColorPalette colors,
    IconData icon,
    String message,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXL),
      child: Column(
        children: [
          Icon(icon, size: 64, color: colors.colorText.withValues(alpha: 0.2)),
          const SizedBox(height: AppDimens.padding),
          AppText.body(
            message,
            color: colors.colorText.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

bool _hasPositiveFormattedAmount(String amount) {
  if (amount.isEmpty) return false;
  final normalized = amount.replaceAll(RegExp(r'[^0-9.\-]'), '');
  final parsed = double.tryParse(normalized);
  return (parsed ?? 0) > 0;
}

// ── Upcoming Booking Item ───────────────────────────────────────────────

class _UpcomingBookingItem extends StatelessWidget {
  final Booking booking;
  final AppColorPalette colors;
  final VoidCallback onTap;

  const _UpcomingBookingItem({
    required this.booking,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleName = booking.vehicleType?.name ?? '';
    final bookingId = booking.uniqueId ?? '';
    final scheduleLabel = _getScheduleLabel();
    final dateTimeStr = _formatDateTime();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.colorText.withValues(alpha: 0.18),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicleName.isNotEmpty)
                      AppText.caption(
                        vehicleName,
                        color: colors.colorTextHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText(
                      scheduleLabel,
                      fontSize: AppTypos.textXXL,
                      fontWeight: FontWeight.w700,
                    ),
                    if (bookingId.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.paddingXS),
                      AppText.caption(
                        getString(appStr.descriptionBookingId,
                                'description_booking_id')
                            .replacePlaceholders(
                                {StringConstant.bookingNo: bookingId}),
                        color: colors.colorTextHint,
                      ),
                    ],
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(
                      dateTimeStr,
                      color: colors.colorTextHint,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingM),
              _buildVehicleImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage() {
    final imageUrl = booking.vehicleType?.imageUrl;
    final fullUrl =
        imageUrl != null ? ServerConfig.getFullImageUrl(imageUrl) : null;

    return SizedBox(
      width: 64,
      height: 64,
      child: fullUrl != null
          ? CachedNetworkImage(
              imageUrl: fullUrl,
              fit: BoxFit.contain,
              placeholder: (_, _) => Icon(
                Icons.directions_car,
                color: colors.colorTextHint,
                size: 32,
              ),
              errorWidget: (_, _, _) => Icon(
                Icons.directions_car,
                color: colors.colorTextHint,
                size: 32,
              ),
            )
          : Icon(
              Icons.directions_car,
              color: colors.colorTextHint,
              size: 32,
            ),
    );
  }

  String _getScheduleLabel() {
    if (booking.bookingTime == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(booking.bookingTime!);
    final now = DateTime.now();
    final isToday = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day;

    if (isToday) return getString(appStr.descriptionToday, 'description_today');
    if (isTomorrow) return getString(appStr.descriptionTomorrow, 'description_tomorrow');
    return intl.DateFormat('dd MMM').format(dt);
  }

  String _formatDateTime() {
    if (booking.bookingTime == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(booking.bookingTime!);
    return intl.DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }
}

// ── Past Booking Item ───────────────────────────────────────────────────

class _PastBookingItem extends StatelessWidget {
  final HistoryBooking booking;
  final AppColorPalette colors;
  final VoidCallback onTap;

  const _PastBookingItem({
    required this.booking,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.status == BookingStatus.cancelled;
    final vehicleName = booking.vehicleType?.name ?? '';
    final bookingId = booking.uniqueId ?? '';
    final completedTimeStr = _formatCompletedTime();
    final priceStr = _formatPrice();
    final shouldShowCancelledAmount =
        !isCancelled || _hasPositiveFormattedAmount(priceStr);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
        child: Row(
          children: [
            // Vehicle thumbnail
            _buildVehicleImage(),

            const SizedBox(width: AppDimens.paddingS),

            // Booking details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(
                    vehicleName,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (bookingId.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(
                      getString(appStr.descriptionBookingId,
                              'description_booking_id')
                          .replacePlaceholders(
                              {StringConstant.bookingNo: bookingId}),
                      color: colors.colorTextHint,
                    ),
                  ],
                  if (completedTimeStr.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(
                      completedTimeStr,
                      color: colors.colorTextHint,
                    ),
                  ],
                  if ((priceStr.isNotEmpty && shouldShowCancelledAmount) ||
                      isCancelled) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(
                      isCancelled
                          ? shouldShowCancelledAmount && priceStr.isNotEmpty
                              ? '$priceStr · ${getString(appStr.descriptionCancelled, 'description_cancelled')}'
                              : getString(appStr.descriptionCancelled, 'description_cancelled')
                          : priceStr,
                      color: isCancelled
                          ? colors.colorWarning
                          : colors.colorTextHint,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleImage() {
    final imageUrl = booking.vehicleType?.imageUrl;
    final fullUrl =
        imageUrl != null ? ServerConfig.getFullImageUrl(imageUrl) : null;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.paddingS),
      ),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.paddingS),
              child: CachedNetworkImage(
                imageUrl: fullUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => Icon(
                  Icons.directions_car,
                  color: colors.colorTextHint,
                  size: 28,
                ),
                errorWidget: (_, _, _) => Icon(
                  Icons.directions_car,
                  color: colors.colorTextHint,
                  size: 28,
                ),
              ),
            )
          : Icon(
              Icons.directions_car,
              color: colors.colorTextHint,
              size: 28,
            ),
    );
  }

  String _formatCompletedTime() {
    return booking.completedTimeValue ?? '';
  }

  String _formatPrice() {
    if (booking.bookingPrice != null && booking.bookingPrice!.isNotEmpty) {
      return booking.bookingPrice!;
    }
    return booking.total.applyPriceSetting(
      currencyDirection: booking.setCurrencySign ?? 1,
      currencySign: booking.currencySign ?? '',
      decimalPointValue: booking.decimalPointValue ?? 2,
    );
  }
}

// ── Past Booking Featured Card (first item with map) ────────────────────

class _PastBookingFeaturedCard extends StatelessWidget {
  final HistoryBooking booking;
  final AppColorPalette colors;
  final Widget? mapWidget;
  final VoidCallback onTap;

  const _PastBookingFeaturedCard({
    required this.booking,
    required this.colors,
    this.mapWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.status == BookingStatus.cancelled;
    final vehicleName = booking.vehicleType?.name ?? '';
    final bookingId = booking.uniqueId ?? '';
    final completedTimeStr = _formatCompletedTime();
    final priceStr = _formatPrice();
    final shouldShowCancelledAmount =
        !isCancelled || _hasPositiveFormattedAmount(priceStr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.colorText.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(AppDimens.paddingM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map
            Container(
              height: 180,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.paddingM),
                ),
              ),
              child: mapWidget ??
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: colors.colorText.withValues(alpha: 0.2),
                  ),
            ),

            // Booking info
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.title(
                    vehicleName,
                    fontWeight: FontWeight.w600,
                  ),
                  if (bookingId.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.body(
                      getString(appStr.descriptionBookingId,
                              'description_booking_id')
                          .replacePlaceholders(
                              {StringConstant.bookingNo: bookingId}),
                      color: colors.colorTextHint,
                    ),
                  ],
                  if (completedTimeStr.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.body(
                      completedTimeStr,
                      color: colors.colorTextHint,
                    ),
                  ],
                  if ((priceStr.isNotEmpty && shouldShowCancelledAmount) ||
                      isCancelled) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.body(
                      isCancelled
                          ? shouldShowCancelledAmount && priceStr.isNotEmpty
                              ? '$priceStr · ${getString(appStr.descriptionCancelled, 'description_cancelled')}'
                              : getString(appStr.descriptionCancelled, 'description_cancelled')
                          : priceStr,
                      color: isCancelled
                          ? colors.colorWarning
                          : colors.colorTextHint,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompletedTime() {
    return booking.completedTimeValue ?? '';
  }

  String _formatPrice() {
    if (booking.bookingPrice != null && booking.bookingPrice!.isNotEmpty) {
      return booking.bookingPrice!;
    }
    return booking.total.applyPriceSetting(
      currencyDirection: booking.setCurrencySign ?? 1,
      currencySign: booking.currencySign ?? '',
      decimalPointValue: booking.decimalPointValue ?? 2,
    );
  }
}
