import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/map/interface/map_interface.dart';
import '../../../core/map/models/map_types.dart';
import '../../../core/map/providers/map_provider.dart';
import '../../../core/map/widgets/map_host.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api/server_config.dart';
import '../../../models/responses/booking/booking_detail_response.dart';
import '../../../viewmodels/trip_detail_viewmodel.dart';
import '../../bottomsheets/new_ticket_bottomsheet.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TripDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  late final MapInterface _mapManager;
  bool _mapRouteShown = false;

  @override
  void initState() {
    super.initState();
    _mapManager = ref.read(mapManagerProvider)();
  }

  @override
  void dispose() {
    _mapManager.dispose();
    super.dispose();
  }

  void _showRouteOnMap(Booking booking) {
    if (_mapRouteShown) return;
    _mapRouteShown = true;

    final primaryColor = context.colors.colorPrimary.toARGB32();
    final markers = <MapMarker>[];
    final boundsPoints = <LatLng>[];

    // Pickup marker
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

    // Destination markers
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

    _mapManager.setMarkers(markers);

    // Polyline from direction path
    final directionPath = booking.bookingInvoice?.actual?.directionPath ??
        booking.bookingInvoice?.estimated?.directionPath;
    if (directionPath != null && directionPath.isNotEmpty) {
      _mapManager.setPolyline(MapPolyline.fromEncoded(
        encoded: directionPath,
        color: primaryColor,
      ));
    }

    // Fit camera to show all points
    if (boundsPoints.isNotEmpty) {
      _mapManager.fitBounds(boundsPoints, padding: 80);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(tripDetailViewModelProvider(widget.bookingId));

    // Show route on map when booking data is available
    if (state.booking != null && !_mapRouteShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRouteOnMap(state.booking!);
      });
    }

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingTripDetails, 'heading_trip_details'),
            ),
            if (state.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: AppText.body(
                      state.error!,
                      color: colors.colorText.withValues(alpha: 0.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else if (state.booking != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding,
                  ),
                  child: _buildContent(context, colors, state),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppColorPalette colors, TripDetailState state) {
    final booking = state.booking!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map
        _buildMap(colors),

        const SizedBox(height: AppDimens.paddingL),

        // Ride header (vehicle name + customer avatar)
        _buildRideHeader(colors, booking),

        const SizedBox(height: AppDimens.paddingS),

        // Booking ID
        if (booking.uniqueId != null && booking.uniqueId!.isNotEmpty) ...[
          AppText.body(
            getString(appStr.descriptionBookingId, 'description_booking_id')
                .replacePlaceholders(
                    {StringConstant.bookingNo: booking.uniqueId!}),
            color: colors.colorText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimens.paddingXS),
        ],

        // Completed date/time
        if (state.completedTimeStr != null)
          AppText.body(
            state.completedTimeStr!,
            color: colors.colorText.withValues(alpha: 0.5),
          ),

        const SizedBox(height: AppDimens.paddingXS),

        // Price
        if (state.priceStr != null && state.shouldShowCancelledAmount)
          AppText.body(
            state.isCancelled
                ? '${state.priceStr} · ${getString(appStr.descriptionCancelled, 'description_cancelled')}'
                : state.priceStr!,
            color: state.isCancelled
                ? colors.colorWarning
                : colors.colorText.withValues(alpha: 0.5),
          ),

        // Cancelled (when no price)
        if (state.isCancelled &&
            (state.priceStr == null || !state.shouldShowCancelledAmount))
          AppText.body(
            getString(appStr.descriptionCancelled, 'description_cancelled'),
            color: colors.colorWarning,
          ),

        // Receipt chip (like customer app)
        if (!state.isCancelled &&
            state.booking?.bookingInvoice?.actual != null) ...[
          const SizedBox(height: AppDimens.padding),
          _buildActionChips(colors, state),
        ],

        const SizedBox(height: AppDimens.paddingXL),

        // Rating row (hide for cancelled bookings)
        if (!state.isCancelled) ...[
          _buildRatingRow(colors, state),
          Divider(
            color: colors.colorBackgroundGray,
            height: AppDimens.paddingXXL,
          ),
        ],

        // Addresses
        if (state.addressList.isNotEmpty)
          _buildAddressSection(colors, state.addressList),

        // Cancellation reason
        if (state.isCancelled &&
            booking.cancellationReason != null &&
            booking.cancellationReason!.isNotEmpty) ...[
          Divider(
            color: colors.colorBackgroundGray,
            height: AppDimens.paddingXXL,
          ),
          Row(
            children: [
              Icon(Icons.cancel_outlined,
                  size: 22,
                  color: colors.colorText.withValues(alpha: 0.6)),
              const SizedBox(width: AppDimens.paddingM),
              Expanded(
                child: AppText.body(
                  getString(appStr.descriptionReasonPrefix,
                          'description_reason_prefix')
                      .replacePlaceholders(
                          {StringConstant.value: booking.cancellationReason!}),
                ),
              ),
            ],
          ),
        ],

        Divider(
          color: colors.colorBackgroundGray,
          height: AppDimens.paddingXXL,
        ),

        // Trip details section
        if (!state.isCancelled) ...[
          _buildTripDetails(colors, state),
          Divider(
            color: colors.colorBackgroundGray,
            height: AppDimens.paddingXXL,
          ),
        ],

        // Help & Safety
        _buildHelpAndSafety(context, colors, booking),

        const SizedBox(height: AppDimens.paddingXXL),
      ],
    );
  }

  Widget _buildMap(AppColorPalette colors) {
    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.paddingM),
      ),
      child: IgnorePointer(child: MapHost(manager: _mapManager)),
    );
  }

  Widget _buildRideHeader(AppColorPalette colors, Booking booking) {
    final vehicleName = booking.vehicleType?.name ?? '';
    final customer = booking.customerDetail;
    final imageUrl = customer?.imageUrl != null
        ? ServerConfig.getFullImageUrl(customer!.imageUrl!)
        : null;

    return Row(
      children: [
        Expanded(
          child: AppText.title(
            vehicleName,
            fontWeight: FontWeight.bold,
            fontSize: AppTypos.textXXL,
          ),
        ),
        if (customer != null) ...[
          const SizedBox(width: AppDimens.paddingM),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.colorBackgroundGray,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Icon(
                      Icons.person,
                      color: colors.colorText.withValues(alpha: 0.4),
                      size: 28,
                    ),
                    errorWidget: (_, _, _) => Icon(
                      Icons.person,
                      color: colors.colorText.withValues(alpha: 0.4),
                      size: 28,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: colors.colorText.withValues(alpha: 0.4),
                    size: 28,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressSection(
      AppColorPalette colors, List<BookingAddress> addressList) {
    const double rowHeight = 48;
    final totalRows = addressList.length;
    final totalHeight = totalRows * rowHeight;
    final destinations =
        addressList.length > 1 ? addressList.sublist(1) : <BookingAddress>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icons column with connecting line
        SizedBox(
          width: 24,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (totalRows > 1)
                Positioned(
                  top: rowHeight / 2,
                  bottom: rowHeight / 2,
                  child: Container(
                    width: 1.5,
                    color: colors.colorPrimary.withValues(alpha: 0.3),
                  ),
                ),
              // Pickup icon
              Positioned(
                top: (rowHeight / 2) - 10,
                child: Image.asset(
                  'assets/images/ic_pickup.png',
                  width: 20,
                  height: 20,
                  color: colors.colorPrimary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              // Destination/stop icons
              for (int i = 0; i < destinations.length; i++)
                Positioned(
                  top: rowHeight + (i * rowHeight) + (rowHeight / 2) - 10,
                  child: i == destinations.length - 1
                      ? Image.asset(
                          'assets/images/ic_drop_off.png',
                          width: 20,
                          height: 20,
                          color: colors.colorPrimary,
                          colorBlendMode: BlendMode.srcIn,
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colors.colorPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: AppText(
                              '${i + 1}',
                              color: colors.colorBackground,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),

        const SizedBox(width: AppDimens.paddingM),

        // Address text column
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: addressList.map((address) {
              return SizedBox(
                height: rowHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText.body(
                    address.address ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTripDetails(AppColorPalette colors, TripDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.title(
          getString(appStr.headingTripDetails, 'heading_trip_details'),
          fontWeight: FontWeight.bold,
          fontSize: AppTypos.textXXL,
        ),
        const SizedBox(height: AppDimens.padding),
        if (state.distanceStr != null)
          _buildDetailRow(
            colors,
            getString(appStr.descriptionDistance, 'description_distance'),
            state.distanceStr!,
          ),
        if (state.durationStr != null)
          _buildDetailRow(
            colors,
            getString(appStr.descriptionDuration, 'description_duration'),
            state.durationStr!,
          ),
        if (state.earningStr != null && !state.isPartnerDriver)
          _buildDetailRow(
            colors,
            getString(appStr.descriptionEarning, 'description_earning'),
            state.earningStr!,
          ),
      ],
    );
  }

  Widget _buildDetailRow(
      AppColorPalette colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.body(
            label,
            color: colors.colorText.withValues(alpha: 0.5),
          ),
          AppText.body(value, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  Widget _buildHelpAndSafety(
      BuildContext context, AppColorPalette colors, Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.title(
          getString(
              appStr.headingHelpAndSafety, 'heading_help_and_safety'),
          fontWeight: FontWeight.bold,
          fontSize: AppTypos.textXXL,
        ),
        const SizedBox(height: AppDimens.padding),
        InkWell(
          onTap: () => _showNewTicketBottomSheet(context, booking),
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 28,
                color: colors.colorText.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppDimens.paddingM),
              Expanded(
                child: AppText.body(
                  getString(appStr.buttonGetHelp, 'button_get_help'),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.colorText.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNewTicketBottomSheet(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.colorBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => NewTicketBottomSheet(
        bookingId: booking.id,
        uniqueId: booking.uniqueId,
      ),
    );
  }

  Widget _buildActionChips(AppColorPalette colors, TripDetailState state) {
    return Wrap(
      spacing: AppDimens.paddingS,
      runSpacing: AppDimens.paddingS,
      children: [
        _buildChip(
          colors,
          icon: Icons.receipt_long,
          label: getString(appStr.buttonViewReceipt, 'button_view_receipt'),
          onTap: () {
            final booking = state.booking;
            if (booking != null) {
              context.navigateToReceipt(
                booking: booking,
                activeSetting: state.activeSetting,
                isPartnerDriver: state.isPartnerDriver,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRatingRow(AppColorPalette colors, TripDetailState state) {
    final rating = state.booking?.rating;
    final customerRate = rating?.customerRate?.toInt() ?? 0;

    if (state.isUserRated && customerRate > 0) {
      // Already rated — show read-only display
      return Row(
        children: [
          Icon(Icons.star, size: 22, color: colors.colorText),
          const SizedBox(width: AppDimens.paddingM),
          AppText.body(
            getString(appStr.descriptionRated, 'description_rated')
                .replacePlaceholders({StringConstant.value: customerRate}),
          ),
          const SizedBox(width: AppDimens.paddingXS),
          ...List.generate(
            customerRate,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(Icons.star, size: 16, color: colors.colorText),
            ),
          ),
        ],
      );
    }

    // Not yet rated — tappable to feedback screen
    return InkWell(
      onTap: () {
        context.navigateToFeedback(
          bookingId: state.booking?.id ?? widget.bookingId,
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            size: 22,
            color: colors.colorText.withValues(alpha: 0.6),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: AppText.body(
              getString(
                  appStr.descriptionNotYetRated, 'description_not_yet_rated'),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.colorText.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    AppColorPalette colors, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingS,
        ),
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          borderRadius: BorderRadius.circular(AppDimens.paddingXL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colors.colorText),
            const SizedBox(width: AppDimens.paddingS),
            AppText.body(
              label,
              fontWeight: FontWeight.w500,
              color: colors.colorText,
            ),
          ],
        ),
      ),
    );
  }
}
