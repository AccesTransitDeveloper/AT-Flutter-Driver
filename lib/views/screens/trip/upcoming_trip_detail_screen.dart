import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/map/interface/map_interface.dart';
import '../../../core/map/models/map_types.dart';
import '../../../core/map/providers/map_provider.dart';
import '../../../core/map/widgets/map_host.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api/server_config.dart';
import '../../../models/chat/chat_config.dart';
import '../../../models/responses/booking/booking_detail_response.dart';
import '../../../models/responses/booking/cancellation_reason_response.dart';
import '../../../viewmodels/upcoming_trip_detail_viewmodel.dart';
import '../../bottomsheets/call_options_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toolbar.dart';

class UpcomingTripDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final bool isMarketPlace;

  const UpcomingTripDetailScreen({
    super.key,
    required this.bookingId,
    this.isMarketPlace = false,
  });

  @override
  ConsumerState<UpcomingTripDetailScreen> createState() =>
      _UpcomingTripDetailScreenState();
}

class _UpcomingTripDetailScreenState
    extends ConsumerState<UpcomingTripDetailScreen> {
  late final MapInterface _mapManager;
  bool _mapRouteShown = false;

  AutoDisposeStateNotifierProviderFamily<UpcomingTripDetailViewModel,
      UpcomingTripDetailState, String> get _provider =>
      widget.isMarketPlace
          ? upcomingTripDetailMarketplaceViewModelProvider
          : upcomingTripDetailViewModelProvider;

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
    final directionPath =
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
    final state = ref.watch(_provider(widget.bookingId));

    ref.listen(_provider(widget.bookingId), (prev, next) {
      // Popping here would close the cancel sheet (it sits on top), and the
      // screen would then pop without a result. _showCancelBottomSheet closes
      // the sheet first, then pops the screen with `true`.
      if (next.cancelError != null && next.cancelError != prev?.cancelError) {
        if (context.mounted) context.showErrorSnackBar(next.cancelError!);
      }
      // Marketplace: navigate to home after accept
      if (next.isNavigateToHome && !(prev?.isNavigateToHome ?? false)) {
        if (context.mounted) context.navigateToHome();
      }
      // Marketplace: show snackbar message
      if (next.snackBarMessage != null &&
          next.snackBarMessage != prev?.snackBarMessage) {
        if (context.mounted) {
          context.showSnackBar(next.snackBarMessage!);
        }
      }
    });

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
                  child: _buildContent(colors, state),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      AppColorPalette colors, UpcomingTripDetailState state) {
    final booking = state.booking!;
    final settings = state.activeSetting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map
        _buildMap(colors),

        const SizedBox(height: AppDimens.paddingL),

        // Status badge
        if (state.statusLabel.isNotEmpty) ...[
          _buildStatusBadge(colors, state.statusLabel, booking.status),
          const SizedBox(height: AppDimens.paddingS),
        ],

        // Ride header
        _buildRideHeader(colors, booking, state),

        // Rental package info
        if (booking.packageDetail != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          _buildRentalPackageInfo(colors, booking),
        ],

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

        // Date/time
        if (state.dateTimeStr != null)
          AppText.body(
            state.dateTimeStr!,
            color: colors.colorText.withValues(alpha: 0.5),
          ),

        const SizedBox(height: AppDimens.paddingXS),

        // Estimated price
        if (state.priceStr != null)
          AppText.body(
            state.priceStr!,
            color: colors.colorText.withValues(alpha: 0.5),
          ),

        const SizedBox(height: AppDimens.paddingXL),

        // Addresses
        if (state.addressList.isNotEmpty)
          _buildAddressSection(colors, state.addressList),

        Divider(
          color: colors.colorBackgroundGray,
          height: AppDimens.paddingXXL,
        ),

        // Trip details
        _buildTripDetails(colors, state),

        // Action buttons (Call & Chat)
        if (settings.contains(DriverBookingSetting.allowCallToUser) ||
            settings.contains(DriverBookingSetting.allowCallToSupport) ||
            settings.contains(DriverBookingSetting.allowChatWithUser)) ...[
          const SizedBox(height: AppDimens.paddingL),
          _buildActionButtons(colors, state, settings),
        ],

        Divider(
          color: colors.colorBackgroundGray,
          height: AppDimens.paddingXXL,
        ),

        // Help & Safety
        _buildHelpAndSafety(colors),

        const SizedBox(height: AppDimens.paddingXL),

        // Accept button (marketplace)
        if (state.isMarketPlace) ...[
          SizedBox(
            width: double.infinity,
            child: AppFilledButton(
              text: getString(appStr.buttonAccept, 'button_accept'),
              isLoading: state.isAcceptLoading,
              onPressed: () => ref
                  .read(_provider(widget.bookingId).notifier)
                  .acceptMarketplaceBooking(),
            ),
          ),
          const SizedBox(height: AppDimens.paddingXL),
        ],

        // Cancel booking button
        if (!state.isMarketPlace && state.isAllowCancelBooking) ...[
          SizedBox(
            width: double.infinity,
            child: AppOutlinedButton(
              text: getString(
                  appStr.buttonCancelBooking, 'button_cancel_booking'),
              textColor: colors.colorWarning,
              borderColor: colors.colorWarning,
              onPressed: () => _showCancelBottomSheet(context),
            ),
          ),
          const SizedBox(height: AppDimens.paddingXL),
        ],

        const SizedBox(height: AppDimens.padding),
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

  Widget _buildStatusBadge(
      AppColorPalette colors, String label, int? statusValue) {
    final badgeColor = switch (statusValue) {
      BookingStatus.accepted || BookingStatus.assigned => Colors.green,
      BookingStatus.inRoute || BookingStatus.arrivedAtPickup => Colors.blue,
      BookingStatus.started => Colors.teal,
      _ => colors.colorPrimary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.paddingS),
      ),
      child: AppText.caption(
        label.toUpperCase(),
        color: badgeColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRideHeader(
      AppColorPalette colors, Booking booking, UpcomingTripDetailState state) {
    final vehicleName = booking.vehicleType?.name ?? '';
    final customerName = state.customerName;
    final customer = booking.customerDetail;
    final imageUrl = customer?.imageUrl != null
        ? ServerConfig.getFullImageUrl(customer!.imageUrl!)
        : null;

    // Build title: "Minivan ride with John" or just "Minivan"
    final title = customerName != null && customerName.isNotEmpty
        ? getString(appStr.descriptionRideWithCustomer,
                'description_ride_with_customer')
            .replacePlaceholders({
            StringConstant.leftParam: vehicleName,
            StringConstant.rightParam: customerName,
          })
        : vehicleName;

    return Row(
      children: [
        Expanded(
          child: AppText.title(
            title,
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

  Widget _buildRentalPackageInfo(AppColorPalette colors, Booking booking) {
    final packageDetail = booking.packageDetail!;
    final invoice = booking.bookingInvoice;
    final currencySign = invoice?.currencySign ?? '';
    final decimals = invoice?.decimalPointValue ?? 2;
    final currencyDir = invoice?.setCurrencySign ?? 1;

    String formatPrice(double? value) {
      if (value == null) return '';
      final formatted = value.toStringAsFixed(decimals);
      if (currencySign.isEmpty) return formatted;
      if (currencyDir == 2) return '$formatted$currencySign';
      return '$currencySign$formatted';
    }

    final distanceUnit = (invoice?.distanceUnit == 2) ? 'mi' : 'km';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(
          packageDetail.packageName ?? '',
          fontWeight: FontWeight.w600,
          color: colors.colorText,
        ),
        if (packageDetail.distancePrice != null) ...[
          const SizedBox(height: AppDimens.paddingXS),
          AppText.caption(
            '${packageDetail.distancePrice!.basePrice?.toStringAsFixed(0) ?? ''} $distanceUnit - ${formatPrice(packageDetail.distancePrice!.price)}',
            color: colors.colorText.withValues(alpha: 0.6),
          ),
        ],
        if (packageDetail.timePrice != null) ...[
          const SizedBox(height: 4),
          AppText.caption(
            '${packageDetail.timePrice!.basePrice?.toStringAsFixed(0) ?? ''} min - ${formatPrice(packageDetail.timePrice!.price)}',
            color: colors.colorText.withValues(alpha: 0.5),
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

  Widget _buildTripDetails(
      AppColorPalette colors, UpcomingTripDetailState state) {
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
        if (state.priceStr != null)
          _buildDetailRow(
            colors,
            getString(appStr.descriptionEstimatedPrice,
                'description_estimated_price'),
            state.priceStr!,
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

  Widget _buildHelpAndSafety(AppColorPalette colors) {
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
          onTap: () => context.navigateToContactUs(),
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

  Widget _buildActionButtons(AppColorPalette colors,
      UpcomingTripDetailState state, Set<String> settings) {
    final allowChat =
        settings.contains(DriverBookingSetting.allowChatWithUser);
    final allowCallUser =
        settings.contains(DriverBookingSetting.allowCallToUser);
    final allowCallSupport =
        settings.contains(DriverBookingSetting.allowCallToSupport);
    final allowCall = allowCallUser || allowCallSupport;

    return Row(
      children: [
        if (allowChat)
          _buildActionChip(
            colors,
            Icons.chat_bubble_outline,
            getString(appStr.hintMessage, 'hint_message'),
            () => _openChat(state),
          ),
        if (allowChat && allowCall)
          const SizedBox(width: AppDimens.paddingM),
        if (allowCall)
          _buildActionChip(
            colors,
            Icons.call,
            getString(appStr.buttonCall, 'button_call'),
            () => _onCallClick(allowCallUser, allowCallSupport),
          ),
      ],
    );
  }

  Widget _buildActionChip(
      AppColorPalette colors, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingM,
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
            AppText.body(label, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }

  void _onCallClick(bool allowCallUser, bool allowCallSupport) {
    final notifier = ref.read(
        _provider(widget.bookingId).notifier);

    if (allowCallUser && allowCallSupport) {
      CallOptionsBottomSheet.show(
        context,
        onCallUser: () {
          final phone = notifier.getCustomerPhone();
          if (phone != null && phone.isNotEmpty) {
            launchUrl(Uri.parse('tel:$phone'));
          }
        },
        onCallSupport: () {
          final phone = notifier.getSupportPhone();
          if (phone != null && phone.isNotEmpty) {
            launchUrl(Uri.parse('tel:$phone'));
          }
        },
      );
    } else if (allowCallUser) {
      final phone = notifier.getCustomerPhone();
      if (phone != null && phone.isNotEmpty) {
        launchUrl(Uri.parse('tel:$phone'));
      }
    } else if (allowCallSupport) {
      final phone = notifier.getSupportPhone();
      if (phone != null && phone.isNotEmpty) {
        launchUrl(Uri.parse('tel:$phone'));
      }
    }
  }

  void _openChat(UpcomingTripDetailState state) {
    final customer = state.booking?.customerDetail;
    context.navigateToChat(
      chatConfig: ChatConfig(
        chatType: 'CUSTOMER_DRIVER_CHAT',
        referenceId: state.booking?.id,
        receiverImage: customer?.imageUrl,
        receiverName: state.customerName,
      ),
    );
  }

  // ── Cancel Bottom Sheet ──────────────────────────────────────────

  Future<void> _showCancelBottomSheet(BuildContext context) async {
    final colors = context.colors;
    final vm = ref.read(
        _provider(widget.bookingId).notifier);
    vm.getCancellationReasons();

    final cancelled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(
              _provider(widget.bookingId));
          return _CancelBottomSheet(
            colors: colors,
            reasons: state.cancellationReasons,
            isLoading: state.isCancelLoading,
            onCancel: (reason) async {
              final success = await ref
                  .read(_provider(widget.bookingId)
                      .notifier)
                  .cancelBooking(reason);
              if (success && sheetContext.mounted) {
                Navigator.pop(sheetContext, true);
              }
            },
            onClose: () => Navigator.pop(sheetContext),
          );
        },
      ),
    );

    // `true` tells the activity screen to reload — its lists are fetched once.
    if (cancelled == true && context.mounted) context.pop(true);
  }
}

class _CancelBottomSheet extends StatefulWidget {
  final AppColorPalette colors;
  final List<CancellationReason> reasons;
  final bool isLoading;
  final Future<void> Function(String reason) onCancel;
  final VoidCallback onClose;

  const _CancelBottomSheet({
    required this.colors,
    required this.reasons,
    required this.isLoading,
    required this.onCancel,
    required this.onClose,
  });

  @override
  State<_CancelBottomSheet> createState() => _CancelBottomSheetState();
}

class _CancelBottomSheetState extends State<_CancelBottomSheet> {
  int _selectedIndex = -1;
  String? _otherReason;

  /// Check if the last item ("Other") is selected
  bool get _isOthersSelected =>
      _selectedIndex >= 0 &&
      _selectedIndex == widget.reasons.length - 1;

  /// Get the selected reason text
  String get _selectedReason {
    if (_selectedIndex < 0) return '';
    if (_isOthersSelected) return (_otherReason ?? '').trim();
    return widget.reasons[_selectedIndex].reasons ?? '';
  }

  bool get _canSubmit {
    if (_selectedIndex < 0) return false;
    if (_isOthersSelected) return (_otherReason ?? '').trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimens.padding,
          right: AppDimens.padding,
          top: AppDimens.padding,
          bottom:
              AppDimens.padding + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back arrow and title
            Row(
              children: [
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.arrow_back,
                    color: widget.colors.colorText,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: Center(
                    child: AppText.title(
                      getString(appStr.headingCancelBooking,
                          'heading_cancel_booking'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Spacer to balance the back arrow
                const SizedBox(width: 24 + AppDimens.paddingM),
              ],
            ),

            const SizedBox(height: AppDimens.paddingXL),

            if (widget.isLoading && widget.reasons.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: AppDimens.paddingXL),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              AppText.body(
                getString(
                    appStr.descriptionSelectReasonForCancellation,
                    'description_select_reason_for_cancellation'),
                color: widget.colors.colorText.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Reasons list
              ...widget.reasons.asMap().entries.map((entry) {
                final index = entry.key;
                final reason = entry.value;
                return _buildReasonItem(index, reason.reasons ?? '');
              }),

              // Other reason text field
              if (_isOthersSelected) ...[
                const SizedBox(height: AppDimens.paddingM),
                AppTextField(
                  onChanged: (value) =>
                      setState(() => _otherReason = value),
                  maxLines: 2,
                  hintText: getString(appStr.hintWriteSpecificReason,
                      'hint_write_specific_reason'),
                  borderRadius: 12,
                  borderColor:
                      widget.colors.colorText.withValues(alpha: 0.2),
                ),
              ],

              const SizedBox(height: AppDimens.paddingXL),

              // Cancel Booking button
              SizedBox(
                width: double.infinity,
                child: AppFilledButton(
                  text: getString(appStr.buttonCancelBooking,
                      'button_cancel_booking'),
                  backgroundColor: widget.colors.colorWarning,
                  isLoading: widget.isLoading,
                  onPressed: _canSubmit
                      ? () => widget.onCancel(_selectedReason)
                      : null,
                ),
              ),

              const SizedBox(height: AppDimens.paddingM),

              // Go Back button
              SizedBox(
                width: double.infinity,
                child: AppOutlinedButton(
                  text: getString(
                      appStr.buttonGoBack, 'button_go_back'),
                  onPressed: widget.onClose,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(int index, String reason) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingS,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 20,
              color: isSelected
                  ? widget.colors.colorPrimary
                  : widget.colors.colorTextHint,
            ),
            const SizedBox(width: AppDimens.paddingS),
            Expanded(
              child: AppText.body(
                reason,
                color: isSelected
                    ? widget.colors.colorText
                    : widget.colors.colorText.withValues(alpha: 0.7),
                fontWeight:
                    isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
