import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/managers/location_manager.dart';
import '../../../core/map/map.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/api/server_config.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/driver_location_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/booking/booking_detail_response.dart';
import '../../../viewmodels/trip_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_draggable_scrollable_sheet.dart';
import '../../widgets/app_multiple_action_button.dart';
import '../../widgets/app_text.dart';
import '../../bottomsheets/bid_amount_bottom_sheet.dart';
import '../../bottomsheets/call_options_bottom_sheet.dart';
import '../../bottomsheets/cancel_trip_bottom_sheet.dart';
import '../../bottomsheets/confirmation_bottom_sheet.dart';
import '../../bottomsheets/confirmation_code_bottom_sheet.dart';
import '../home/home_drawer.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_route_observer.dart';
import '../../../models/chat/chat_config.dart';
import '../../../core/navigation/in_app_navigation_view.dart';

class TripScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TripScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen>
    with WidgetsBindingObserver, RouteAware {
  late final MapInterface _mapManager;
  final _sheetController = AppSheetController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSheetExpanded = false;

  /// Measured height of the collapsed sheet; the my-location button rides on
  /// top of it. Seeded with the old constant so the first frame is sane.
  double _collapsedSheetHeight = 290;

  /// Current booking markers (pickup, stops, dropoff) — kept to merge with driver marker
  List<MapMarker> _bookingMarkers = [];

  /// Current driver position
  LatLng? _driverPosition;

  /// Location listener callback (matches Kotlin: LocationUpdatesLaunchEffect)
  VoidCallback? _locationListener;
  ValueNotifier<dynamic>? _locationNotifier;

  /// Map pin URL for driver marker (from shared preferences)
  String? _mapPinUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapManager = ref.read(mapManagerProvider)();
    ref
        .read(tripViewModelProvider(widget.bookingId).notifier)
        .setMapInterface(_mapManager);
    _setupLocationListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    ref
        .read(tripViewModelProvider(widget.bookingId).notifier)
        .fetchBookingDetail(widget.bookingId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrent) {
        ref
            .read(tripViewModelProvider(widget.bookingId).notifier)
            .fetchBookingDetail(widget.bookingId);
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (_locationListener != null && _locationNotifier != null) {
      _locationNotifier!.removeListener(_locationListener!);
    }
    WidgetsBinding.instance.removeObserver(this);
    _mapManager.dispose();
    super.dispose();
  }

  void _setupLocationListener() {
    // Load map pin URL from shared preferences
    final sharedPref = ref.read(sharedPreferenceManagerProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    _mapPinUrl = sharedPref?.getEntity()?.vehicleType?.mapPinUrl;

    _mapManager.setCameraFollowDriver(true);

    // Observe locationNotifier — matches Kotlin: LocationUpdatesLaunchEffect
    // ValueNotifier always holds the current value, so we read it immediately
    // and get notified on every change (no race condition like broadcast streams).
    final locationProvider = ref.read(driverLocationProvider);
    final notifier = locationProvider.locationNotifier;
    _locationNotifier = notifier;

    _locationListener = () {
      final location = notifier.value;
      if (location != null) {
        _driverPosition = LatLng(location.latitude, location.longitude);
        _updateDriverMarker();
      }
    };
    notifier.addListener(_locationListener!);

    // Read current value immediately (if location already available)
    final current = notifier.value;
    if (current != null) {
      _driverPosition = LatLng(current.latitude, current.longitude);
      _updateDriverMarker();
    }
  }

  void _updateDriverMarker() {
    if (_driverPosition == null) return;

    final pinUrl = _mapPinUrl != null && _mapPinUrl!.isNotEmpty
        ? ServerConfig.getFullImageUrl(_mapPinUrl)
        : null;

    final allMarkers = <MapMarker>[
      ..._bookingMarkers,
      MapMarker(
        id: 'driver',
        position: _driverPosition!,
        iconUrl: pinUrl,
        iconAsset: 'assets/images/ic_car_pin.png',
        iconWidth: 40,
        iconHeight: 40,
      ),
    ];
    _mapManager.setMarkers(allMarkers);
  }

  Future<void> _centerOnDriver() async {
    if (_driverPosition != null) {
      _mapManager.animateCamera(_driverPosition!, zoom: 16);
      return;
    }

    // Fallback: get fresh location
    final result = await LocationManager.instance.getCurrentLocation();
    if (result is LocationSuccess) {
      _mapManager.animateCamera(
        LatLng(result.location.latitude, result.location.longitude),
        zoom: 16,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripViewModelProvider(widget.bookingId));
    final notifier =
        ref.read(tripViewModelProvider(widget.bookingId).notifier);
    final colors = context.colors;

    // Listen for snackbar messages
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.snackBarMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          context.showErrorSnackBar(next);
          notifier.clearSnackBar();
        }
      },
    );

    // Listen for navigate back — pop to previous screen (Home or another TripScreen)
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.isNavigateBack),
      (prev, next) {
        if (next && mounted) {
          notifier.clearNavigateBack();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.goBack();
          });
        }
      },
    );

    // Listen for navigate to feedback (after invoice submit)
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.isNavigateToFeedback),
      (prev, next) {
        if (next && mounted) {
          notifier.clearNavigateToFeedback();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.navigateToFeedback(
                bookingId: widget.bookingId,
                isFromHistory: false,
              );
            }
          });
        }
      },
    );

    // Listen for switch-booking navigation (select a booking from move bottom sheet)
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.navigateToBookingId),
      (prev, next) {
        if (next != null && next.isNotEmpty && mounted) {
          notifier.clearNavigateToBookingId();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.navigateToCurrentRide(bookingId: next);
          });
        }
      },
    );

    // Show cancel bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showCancelBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false) && !_isCancelSheetShowing) {
          final currentState =
              ref.read(tripViewModelProvider(widget.bookingId));
          final reasons = currentState.cancellationReasons
              .map((r) => r.reasons ?? '')
              .where((r) => r.isNotEmpty)
              .toList();
          if (reasons.isEmpty) return;
          _isCancelSheetShowing = true;
          CancelTripBottomSheet.show(
            context,
            reasons: reasons,
            cancellationCharge: currentState.cancellationCharge ?? '',
            isCancelTripLoading: currentState.isCancelLoading,
            onReasonSelected: (reason) {
              notifier.cancelBooking(reason);
            },
            onDismiss: () {
              notifier.toggleCancelBottomSheet(false);
            },
          ).whenComplete(() {
            _isCancelSheetShowing = false;
            notifier.toggleCancelBottomSheet(false);
          });
        }
      },
    );

    // Show call option bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showCallOptionBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false) && !_isCallOptionSheetShowing) {
          _isCallOptionSheetShowing = true;
          CallOptionsBottomSheet.show(
            context,
            onCallUser: () {
              notifier.callToUser();
              final phone = notifier.getCustomerPhone();
              if (phone != null && phone.isNotEmpty) {
                _launchPhone(phone);
              }
            },
            onCallSupport: () {
              notifier.callToSupport();
              final phone = notifier.getSupportPhone();
              if (phone != null && phone.isNotEmpty) {
                _launchPhone(phone);
              }
            },
          ).whenComplete(() {
            _isCallOptionSheetShowing = false;
            notifier.toggleCallOptionBottomSheet(false);
          });
        }
      },
    );

    // Show confirmation bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showConfirmationBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false) && !_isConfirmationSheetShowing) {
          _isConfirmationSheetShowing = true;
          final currentState =
              ref.read(tripViewModelProvider(widget.bookingId));
          ConfirmationBottomSheet.show(
            context,
            alertMessage: currentState.confirmationAlertMessage,
            onConfirm: () => notifier.onConfirmClick(),
            onDismiss: () => notifier.toggleConfirmationBottomSheet(false),
          ).whenComplete(() {
            _isConfirmationSheetShowing = false;
            notifier.toggleConfirmationBottomSheet(false);
          });
        }
      },
    );

    // Show confirmation code (OTP) bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showConfirmationCodeBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false) && !_isConfirmationCodeSheetShowing) {
          _isConfirmationCodeSheetShowing = true;
          ConfirmationCodeBottomSheet.show(
            context,
            onCodeChanged: (code) => notifier.updateConfirmationCode(code),
            onVerify: () => notifier.onVerifyCodeClick(),
            onDismiss: () =>
                notifier.toggleConfirmationCodeBottomSheet(false),
          ).whenComplete(() {
            _isConfirmationCodeSheetShowing = false;
            notifier.toggleConfirmationCodeBottomSheet(false);
          });
        }
      },
    );

    // Show bid amount bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showBidAmountBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false)) {
          _showBidAmountBottomSheet(notifier);
        }
      },
    );

    // Show move-booking bottom sheet
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.showMoveBookingBottomSheet),
      (prev, next) {
        if (next && !(prev ?? false)) {
          final list = ref
              .read(tripViewModelProvider(widget.bookingId))
              .moveBookingList;
          _showMoveBookingSheet(list, notifier);
        }
      },
    );

    // Show directions on map when booking detail is loaded
    ref.listen(
      tripViewModelProvider(widget.bookingId)
          .select((s) => s.bookingDetailResponse),
      (prev, next) {
        if (next != null && prev != next) {
          _showDirectionsOnMap(next, colors);
        }
      },
    );

    if (state.isLoading && state.bookingDetailResponse == null) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: colors.colorBackground,
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.colorBackground,
      drawer: const HomeDrawer(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          // Map (full screen). Swapped for Google's turn-by-turn view while
          // in-app navigation is active — mirrors native's
          // `if (showInAppNav()) NavigationMapView(...) else mapManager().ShowMap()`.
          if (state.showInAppNav &&
              state.nextAddress?.latitude != null &&
              state.nextAddress?.longitude != null)
            // Inset above the collapsed sheet rather than filling the screen:
            // the navigator draws its own footer (ETA, distance, speed) along
            // its bottom edge, which the sheet would otherwise cover. Both
            // natives do the same — Android passes the scaffold's
            // contentPadding, iOS pads by bottomSheetFrame.height.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: state.isShowBookingDetail ? _collapsedSheetHeight : 0,
              child: InAppNavigationView(
                // No key tied to lat/lng: the widget must persist across a stop
                // change so its didUpdateWidget can retarget the native
                // navigator in place instead of tearing it down.
                latitude: state.nextAddress!.latitude!,
                longitude: state.nextAddress!.longitude!,
              ),
            )
          else
            Positioned.fill(child: MapHost(manager: _mapManager)),

          // Gradient at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Accept/Reject overlay
          if (state.isShowRequest)
            _buildAcceptRejectCard(state, notifier, colors),

          // Booking detail view (top bar + next address + bottom sheet).
          //
          // The sheet and the status button stay up during in-app navigation —
          // native gates them on isShowBookingDetail() alone, so the driver can
          // still see the trip and advance its status while guidance runs. Only
          // the next-address card and the map buttons step aside (native gates
          // exactly those on showInAppNav().not()).
          if (state.isShowBookingDetail) ...[
            // Bottom sheet
            Positioned.fill(
              child: AppDraggableScrollableSheet(
                controller: _sheetController,
                sheetColor: colors.colorBackground,
                maxChildSize: 1.0,
                onStateChanged: (expanded) {
                  setState(() => _isSheetExpanded = expanded);
                },
                onCollapsedHeightChanged: (height) {
                  if (_collapsedSheetHeight != height) {
                    setState(() => _collapsedSheetHeight = height);
                  }
                },
                collapsedContent: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCollapsedContent(state, colors, notifier: notifier),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.paddingL,
                        8,
                        AppDimens.paddingL,
                        8,
                      ),
                      child: _buildActionButtonRow(state, notifier, colors),
                    ),
                  ],
                ),
                expandedContent:
                    _buildExpandedContent(state, notifier, colors),
              ),
            ),

            // Top bar — hidden when sheet is expanded
            if (!_isSheetExpanded) _buildTopBar(colors),

            // Next address card — hidden when the sheet is expanded, and while
            // navigating (Google's header already shows the next manoeuvre).
            if (!_isSheetExpanded &&
                !state.showInAppNav &&
                state.nextAddress != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 56,
                left: AppDimens.paddingL,
                right: AppDimens.paddingL,
                child: _buildNextAddressCard(state, colors),
              ),

            // Center location button — hidden when the sheet is expanded, and
            // while navigating (the navigator owns the camera).
            if (!_isSheetExpanded && !state.showInAppNav)
              Positioned(
                right: AppDimens.paddingL,
                // Sit just above the sheet. The old constant 290 was taller
                // than the sheet actually is, leaving the button floating.
                bottom: _collapsedSheetHeight + AppDimens.paddingM,
                child: _buildCircleButton(
                  icon: Icons.my_location,
                  color: colors.colorPrimary,
                  bgColor: colors.colorBackground,
                  onTap: _centerOnDriver,
                ),
              ),

            // Action button pinned at bottom when expanded
            if (_isSheetExpanded)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: colors.colorBackground,
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.paddingL,
                    8,
                    AppDimens.paddingL,
                    MediaQuery.of(context).padding.bottom + 8,
                  ),
                  child: _buildActionButtonRow(state, notifier, colors),
                ),
              ),
          ],

          // Submit Invoice view. The trip is over here, so the bar keeps the
          // drawer and SOS but drops the navigate button — there is nothing
          // left to navigate to.
          if (state.showSubmitInvoice) ...[
            _buildTopBar(colors, showNavigation: false),
            _buildSubmitInvoiceCard(state, notifier, colors),
          ],
        ],
      ),
    ),
    );
  }

  // ── Accept / Reject Card ────────────────────────────────────────

  Widget _buildAcceptRejectCard(
      TripState state, TripViewModel notifier, AppColorPalette colors) {
    final settings = state.activeSetting;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.colorBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Tags + Timer + Reject X
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                  child: Row(
                    children: [
                      // Tags
                      if (state.bookingTagList.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: state.bookingTagList
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colors.colorPrimary,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: AppText(
                                        tag,
                                        fontSize: AppTypos.textXS,
                                        color: colors.colorButtonText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      else
                        const Spacer(),

                      // Timer
                      if (state.bookingTimeoutTimeInFormat.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppText(
                            state.bookingTimeoutTimeInFormat,
                            color: colors.colorWarning,
                            fontSize: AppTypos.textL,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                      // Reject X button (top-right)
                      if (!settings.contains(
                          DriverBookingSetting.hideRejectButton))
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Material(
                            color: colors.colorBackgroundGray,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: state.isRejectLoading
                                  ? null
                                  : () => notifier.rejectBooking(),
                              child: state.isRejectLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(Icons.close,
                                      color: colors.colorText,
                                      size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Earning (large, prominent)
                if (settings.contains(DriverBookingSetting.showEarning) &&
                    state.estimatedEarning != null &&
                    !state.isPartnerDriver)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: AppText(
                      state.estimatedEarning!,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // Rating
                if (!settings.contains(DriverBookingSetting.hideUserDetails) &&
                    state.customerRate != null &&
                    state.customerRate! > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 3),
                        AppText(
                          state.customerRate!.toStringAsFixed(1),
                          fontSize: AppTypos.textM,
                          color: colors.colorTextHint,
                        ),
                      ],
                    ),
                  ),

                // Booking ID
                if (settings.contains(DriverBookingSetting.showBookingId))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: AppText(
                      getString(appStr.descriptionBookingId, 'description_booking_id')
                          .replacePlaceholders({StringConstant.bookingNo: state.bookingUniqueId ?? ''}),
                      fontSize: AppTypos.textS,
                      color: colors.colorTextHint,
                    ),
                  ),

                // Customer info row
                if (!settings.contains(DriverBookingSetting.hideUserDetails))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                state.customerName ?? '',
                                fontSize: AppTypos.textM,
                                fontWeight: FontWeight.w500,
                              ),
                              if (state.completedBookings != null)
                                AppText(
                                  state.completedBookings! > 0
                                      ? '${state.completedBookings} ${getString(appStr.descriptionCompletedTrips, 'description_completed_trips')}'
                                      : getString(
                                          null, 'description_new_user'),
                                  fontSize: AppTypos.textXS,
                                  color: colors.colorTextHint,
                                ),
                            ],
                          ),
                        ),
                        if (settings.contains(
                                DriverBookingSetting.allowCallToUser) ||
                            settings.contains(
                                DriverBookingSetting.allowCallToSupport))
                          _buildCallButton(state, notifier, colors),
                      ],
                    ),
                  ),

                const SizedBox(height: 4),

                // Divider
                Divider(
                    height: 1,
                    color: colors.colorBackgroundGray,
                    indent: 16,
                    endIndent: 16),

                const SizedBox(height: 8),

                // Address list
                _buildAddressList(state, colors),

                // Platform profit percentage
                if (settings.contains(
                        DriverBookingSetting.showPlatformProfitPercentage) &&
                    state.driverPlatformProfitPercentage != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: AppText(
                      '${state.driverPlatformProfitPercentage}%',
                      fontSize: AppTypos.textS,
                      color: colors.colorTextHint,
                    ),
                  ),

                const SizedBox(height: 4),

                // Stats row (distance, time, payment)
                _buildStatsRow(state, settings, colors),

                // Note
                if (state.note != null && state.note!.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_alt_outlined,
                            color: colors.colorPrimary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colors.colorBackgroundGray,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              state.note!,
                              fontSize: AppTypos.textS,
                              color: colors.colorTextHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Accept button (green/secondary, full width)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppFilledButton(
                      text: state.statusButtonText,
                      backgroundColor: colors.colorSecondary,
                      isLoading: state.isAcceptLoading,
                      onPressed: () => notifier.acceptBooking(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────

  /// While in-app navigation runs, native keeps this bar up but strips it back:
  /// drawer and SOS icons hidden, the map icon swapped for a cancel that ends
  /// guidance (AppTopBar with showNavigationIcon/showOtherAction =
  /// showInAppNav().not(), notificationIconResId = ic_cancel).
  Widget _buildTopBar(AppColorPalette colors, {bool showNavigation = true}) {
    final bookingState = ref.read(tripViewModelProvider(widget.bookingId));
    final isNavigating = bookingState.showInAppNav;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingM, vertical: 8),
          child: Row(
            children: [
              if (!isNavigating)
                _buildCircleButton(
                  icon: Icons.menu,
                  color: colors.colorPrimary,
                  bgColor: colors.colorBackground,
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              const Spacer(),
              if (showNavigation)
                _buildCircleButton(
                  icon: isNavigating ? Icons.close : Icons.navigation_outlined,
                  color: colors.colorPrimary,
                  bgColor: colors.colorBackground,
                  onTap: () {
                    final notifier = ref.read(
                        tripViewModelProvider(widget.bookingId).notifier);
                    // In-app turn-by-turn when the admin allows it on Google
                    // maps; external Maps otherwise — matches native's
                    // BookingUIEvent.MapNavigationClick branching. While
                    // navigating, the same button ends guidance.
                    if (notifier.isInAppNavigationAvailable) {
                      notifier.toggleInAppNav();
                    } else {
                      _openExternalNavigation();
                    }
                  },
                ),
              if (!isNavigating &&
                  bookingState.activeSetting
                      .contains(DriverBookingSetting.allowSos)) ...[
                const SizedBox(width: 8),
                _buildCircleButton(
                  icon: Icons.emergency,
                  color: colors.colorButtonText,
                  bgColor: colors.colorWarning,
                  onTap: () {
                    ConfirmationBottomSheet.show(
                      context,
                      alertMessage: getString(
                          appStr.descriptionSureCallSos,
                          'description_sure_call_sos'),
                      onConfirm: () => ref
                          .read(tripViewModelProvider(widget.bookingId)
                              .notifier)
                          .sosCalling(),
                      onDismiss: () {},
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // ── Next Address Card ───────────────────────────────────────────

  Widget _buildNextAddressCard(TripState state, AppColorPalette colors) {
    final addr = state.nextAddress;
    if (addr == null) return const SizedBox.shrink();

    final isPickup = state.nextAddressType == 0;
    final isStop = state.nextAddressType == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.colorBackgroundGray),
      ),
      child: Row(
        children: [
          Icon(
            isPickup
                ? Icons.trip_origin
                : (isStop ? Icons.more_vert : Icons.location_on),
            color: isPickup ? colors.colorPrimary : colors.colorSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              addr.address ?? '',
              fontSize: AppTypos.textS,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Button Row ───────────────────────────────────────────

  Widget _buildActionButtonRow(
      TripState state, TripViewModel notifier, AppColorPalette colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: AppMultipleActionButton(
              text: state.statusButtonText,
              type: state.actionButtonType,
              isLoading: state.isStatusLoading,
              onActionEnd: () => notifier.onActionButtonClick(),
            ),
          ),
          if (state.showCancelButton) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: FloatingActionButton(
                heroTag: 'cancel',
                onPressed: state.isCancelLoading
                    ? null
                    : () => notifier.onCancelButtonClick(),
                backgroundColor: Colors.red.shade50,
                elevation: 2,
                child: state.isCancelLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Collapsed Content ───────────────────────────────────────────
  // Matches Kotlin CollapsedContent.kt layout:
  // Row 1: [Column(BookingID, time|distance), MoveBookingButton]
  // Row 2: [ChatIcon(badge), CustomerName]

  Widget _buildCollapsedContent(TripState state, AppColorPalette colors, {TripViewModel? notifier}) {
    final settings = state.activeSetting;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Booking ID + time|distance (left) — Move booking (right)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (settings.contains(DriverBookingSetting.showBookingId))
                      AppText(
                        getString(appStr.descriptionBookingId, 'description_booking_id')
                            .replacePlaceholders({StringConstant.bookingNo: state.bookingUniqueId ?? ''}),
                        fontSize: AppTypos.textM,
                        fontWeight: FontWeight.w600,
                      ),
                    if (settings.contains(
                        DriverBookingSetting.showTotalTimeAndDistance))
                      AppText(
                        '${state.totalTime ?? ''}  |  ${state.totalDistance ?? ''}',
                        fontSize: AppTypos.textS,
                        color: colors.colorTextHint,
                      ),
                  ],
                ),
              ),
              if (state.showMoveToBooking)
                GestureDetector(
                  onTap: () => notifier?.moveBooking(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingM,
                      vertical: AppDimens.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorPrimary,
                      borderRadius: BorderRadius.circular(AppDimens.paddingM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        AppText.caption(
                          '${getString(appStr.buttonSwitchBooking, 'button_switch_booking')} (${state.totalBookingCount})',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Row 2: Customer name (left) + Call & Chat icons (right)
          Row(
            children: [
              if (!settings.contains(DriverBookingSetting.hideUserDetails))
                Expanded(
                  child: AppText(
                    state.customerName ?? '',
                    fontSize: AppTypos.textM,
                    color: colors.colorText,
                  ),
                )
              else
                const Spacer(),
              if (settings.contains(DriverBookingSetting.allowCallToUser) ||
                  settings.contains(DriverBookingSetting.allowCallToSupport))
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      final notifier = ref.read(
                          tripViewModelProvider(widget.bookingId).notifier);
                      notifier.onCallClick();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.colorBackgroundGray,
                      ),
                      child: Icon(Icons.phone,
                          color: colors.colorText, size: 20),
                    ),
                  ),
                ),
              if (settings.contains(DriverBookingSetting.allowChatWithUser))
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => _openChat(state),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.colorBackgroundGray,
                      ),
                      child: Icon(Icons.chat_bubble_outline,
                          color: colors.colorText, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Expanded Content ────────────────────────────────────────────
  // Matches Kotlin ExpandedContent.kt layout:
  // Back button → Booking ID + Call → Earning pill →
  // BookingDetails (name+rating, addresses, platform profit,
  // BookingBottomList stats grid, BookingNotesAndChat note+chat)

  Widget _buildExpandedContent(
      TripState state, TripViewModel notifier, AppColorPalette colors) {
    final settings = state.activeSetting;
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button (collapses sheet)
          GestureDetector(
            onTap: () => _sheetController.collapse(),
            child: Icon(Icons.arrow_back,
                color: colors.colorPrimary, size: 25),
          ),
          const SizedBox(height: 16),

          // Booking ID + Call button row
          Row(
            children: [
              if (settings.contains(DriverBookingSetting.showBookingId))
                Expanded(
                  child: AppText(
                    getString(appStr.descriptionBookingId, 'description_booking_id')
                        .replacePlaceholders({StringConstant.bookingNo: state.bookingUniqueId ?? ''}),
                    fontSize: AppTypos.textL,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const Spacer(),
              if (settings.contains(DriverBookingSetting.allowCallToUser) ||
                  settings.contains(DriverBookingSetting.allowCallToSupport))
                _buildCallButton(state, notifier, colors),
            ],
          ),

          // Earning (with colored pill background)
          if (settings.contains(DriverBookingSetting.showEarning) &&
              !state.isPartnerDriver &&
              state.bookingEarning != null) ...[
            const SizedBox(height: 16),
            AppText(
              getString(appStr.descriptionYouWillEarnByAcceptingTheBooking,
                  'description_you_will_earn_by_accepting_the_booking'),
              fontSize: AppTypos.textS,
              color: colors.colorTextHint,
            ),
            const SizedBox(height: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.colorPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText(
                state.bookingEarning!,
                fontSize: AppTypos.textXL,
                color: colors.colorSelectedText,
              ),
            ),
          ],

          // ── BookingDetails section ──

          // Customer name + rating
          if (!settings.contains(DriverBookingSetting.hideUserDetails)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppText(
                        state.customerName ?? '',
                        fontSize: AppTypos.textM,
                        color: colors.colorText,
                      ),
                      if (state.customerRate != null &&
                          state.customerRate! > 0) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.star,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        AppText(
                          state.customerRate!.toStringAsFixed(1),
                          fontSize: AppTypos.textS,
                          color: colors.colorText,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Address list
          const SizedBox(height: 8),
          _buildAddressList(state, colors),

          // Platform profit percentage
          if (settings.contains(
                  DriverBookingSetting.showPlatformProfitPercentage) &&
              state.driverPlatformProfitPercentage != null) ...[
            const SizedBox(height: 10),
            AppText(
              getString(appStr.descriptionPlatformProfitValue, 'description_platform_profit_value')
                  .replacePlaceholders({StringConstant.value: state.driverPlatformProfitPercentage!}) + '%',
              fontSize: AppTypos.textS,
              fontWeight: FontWeight.w600,
            ),
          ],

          // ── BookingBottomList — staggered 3-column stats grid ──
          const SizedBox(height: 8),
          _buildExpandedStatsGrid(state, settings, colors),

          // ── BookingNotesAndChat — note section ──
          if (state.note != null && state.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_alt_outlined,
                    color: colors.colorPrimary, size: 25),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: colors.colorBackgroundGray, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      state.note!,
                      fontSize: AppTypos.textS,
                      color: colors.colorTextHint,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── Chat section (if allowed) ──
          if (settings.contains(DriverBookingSetting.allowChatWithUser)) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _openChat(state),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: colors.colorPrimary, size: 25),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: colors.colorBackgroundGray, width: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText(
                              getString(appStr.hintTypeAnythingHere, 'hint_type_anything_here'),
                              fontSize: AppTypos.textS,
                              color: colors.colorTextHint,
                            ),
                          ),
                          Icon(Icons.send,
                              color: colors.colorPrimary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Expanded Stats Grid (BookingBottomList) ───────────────────
  // 3-column staggered grid matching Kotlin BookingBottomList.kt

  Widget _buildExpandedStatsGrid(
      TripState state, Set<String> settings, AppColorPalette colors) {
    final items = <Widget>[];

    if (settings.contains(DriverBookingSetting.showEstimateDistance) &&
        state.estimatedDistance != null &&
        state.estimatedDistance!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionDistance, 'description_distance'),
          state.estimatedDistance!,
          colors));
    }
    if (settings.contains(DriverBookingSetting.showEstimateTime) &&
        state.estimatedTime != null &&
        state.estimatedTime!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionTime, 'description_time'),
          state.estimatedTime!,
          colors));
    }
    if (settings.contains(DriverBookingSetting.showTotalTimeAndDistance) &&
        state.totalDistance != null &&
        state.totalDistance!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionTotalDistance, 'description_total_distance'),
          state.totalDistance!,
          colors));
    }
    if (settings.contains(DriverBookingSetting.showTotalTimeAndDistance) &&
        state.totalTime != null &&
        state.totalTime!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionTotalTime, 'description_total_time'),
          state.totalTime!,
          colors));
    }
    if (settings.contains(DriverBookingSetting.showWaitingTime) &&
        state.waitingTime != null &&
        state.waitingTime!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionWaitingTime, 'description_waiting_time'),
          state.waitingTime!,
          colors));
    }
    if (settings.contains(DriverBookingSetting.showTrafficTime) &&
        state.totalTrafficTime != null &&
        state.totalTrafficTime!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.descriptionTrafficTime, 'description_traffic_time'),
          state.totalTrafficTime!,
          colors));
    }
    if (state.payment != null && state.payment!.isNotEmpty) {
      items.add(_buildGridStatItem(
          getString(appStr.headingPayments, 'heading_payments'),
          state.payment!,
          colors));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    // Lay out in rows of 3
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 3) {
      final end = (i + 3 > items.length) ? items.length : i + 3;
      final rowItems = items.sublist(i, end);
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            for (int j = 0; j < 3; j++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: j < rowItems.length
                      ? rowItems[j]
                      : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildGridStatItem(
      String title, String value, AppColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: AppTypos.textXS,
          color: colors.colorTextHint,
          maxLines: 1,
        ),
        AppText(
          value,
          fontSize: AppTypos.textM,
          fontWeight: FontWeight.w600,
          maxLines: 1,
        ),
      ],
    );
  }

  // ── Shared Widgets ──────────────────────────────────────────────

  Widget _buildAddressList(TripState state, AppColorPalette colors) {
    final addresses = state.addressList;
    if (addresses.isEmpty) return const SizedBox.shrink();

    const rowHeight = 48.0;
    final totalHeight = addresses.length * rowHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: icons with connecting line
          SizedBox(
            width: 24,
            height: totalHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vertical connecting line
                if (addresses.length > 1)
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

                // Stop & destination icons
                for (int i = 1; i < addresses.length; i++)
                  Positioned(
                    top: (i * rowHeight) + (rowHeight / 2) - 10,
                    child: i == addresses.length - 1
                        // Final destination — drop off icon
                        ? Image.asset(
                            'assets/images/ic_drop_off.png',
                            width: 20,
                            height: 20,
                            color: colors.colorPrimary,
                            colorBlendMode: BlendMode.srcIn,
                          )
                        // Intermediate stop — numbered square
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.colorPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: AppText(
                                '$i',
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
          const SizedBox(width: 12),

          // Right column: address texts
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < addresses.length; i++)
                  SizedBox(
                    height: rowHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        addresses[i].address ?? '',
                        fontSize: AppTypos.textS,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      TripState state, Set<String> settings, AppColorPalette colors) {
    final items = <Widget>[];

    if (settings.contains(DriverBookingSetting.showEstimateDistance) &&
        state.estimatedDistance != null) {
      items.add(_buildStatChip(getString(appStr.descriptionDistance, 'description_distance'),
          state.estimatedDistance!, colors));
    }
    if (settings.contains(DriverBookingSetting.showEstimateTime) &&
        state.estimatedTime != null) {
      items.add(_buildStatChip(getString(appStr.descriptionTime, 'description_time'),
          state.estimatedTime!, colors));
    }
    if (state.payment != null) {
      items.add(_buildStatChip(
          getString(appStr.headingPayment, 'heading_payment'), state.payment!, colors));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            items.map((item) => Expanded(child: item)).toList(),
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, AppColorPalette colors) {
    return Column(
      children: [
        AppText(
          value,
          fontSize: AppTypos.textM,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 2),
        AppText(
          label,
          fontSize: AppTypos.textXS,
          color: colors.colorTextHint,
        ),
      ],
    );
  }



  // ── Submit Invoice Card ────────────────────────────────────────
  // Matches Kotlin SubmitInvoiceBottomSheet.kt layout:
  // Title "Invoice" → Earning (conditional) → Total price (conditional) →
  // Cash message (conditional) → View Receipt button → Submit Invoice button

  Widget _buildSubmitInvoiceCard(
      TripState state, TripViewModel notifier, AppColorPalette colors) {
    final settings = state.activeSetting;
    final isCash = state.paymentMode == PaymentMode.cash;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.colorBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppText(
                getString(appStr.headingInvoice, 'heading_invoice'),
                fontSize: AppTypos.textXL,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 16),

              // Earning + View Receipt row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Earning
                        if (!state.isPartnerDriver &&
                            settings.contains(
                                DriverBookingSetting.showEarning) &&
                            state.bookingEarning != null) ...[
                          AppText(
                            state.bookingEarning!,
                            fontSize: AppTypos.textXL,
                            fontWeight: FontWeight.bold,
                          ),
                          AppText(
                            getString(appStr.descriptionEarning,
                                'description_earning'),
                            fontSize: AppTypos.textS,
                            color: colors.colorTextHint,
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Total price
                        if (isCash ||
                            !settings.contains(
                                DriverBookingSetting.hideTotal)) ...[
                          if (state.bookingPrice != null)
                            AppText(
                              state.bookingPrice!,
                              fontSize: AppTypos.textXL,
                              fontWeight: FontWeight.bold,
                            ),
                        ],

                        // Cash message
                        if (isCash)
                          AppText(
                            getString(appStr.descriptionInvoiceCollectCash,
                                'description_invoice_collect_cash'),
                            fontSize: AppTypos.textS,
                            color: colors.colorTextHint,
                          ),
                      ],
                    ),
                  ),

                  // View Receipt button
                  AppFilledButton(
                    text: getString(
                        appStr.buttonViewReceipt, 'button_view_receipt'),
                    shrinkWrap: true,
                    height: 36,
                    icon: Icons.receipt_long,
                    onPressed: () {
                      final booking =
                          state.bookingDetailResponse?.booking;
                      if (booking != null) {
                        context.navigateToReceipt(
                          booking: booking,
                          activeSetting: settings,
                          isPartnerDriver: state.isPartnerDriver,
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Submit Invoice button (hidden for partner drivers)
              if (!state.isPartnerDriver)
                AppFilledButton(
                  text: getString(
                      appStr.buttonSubmitInvoice, 'button_submit_invoice'),
                  isLoading: state.isSubmitInvoiceLoading,
                  onPressed: () => notifier.submitInvoice(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(TripState state, TripViewModel notifier,
      AppColorPalette colors) {
    return AppFilledButton(
      text: getString(appStr.buttonCall, 'button_call'),
      shrinkWrap: true,
      height: 36,
      icon: Icons.call,
      onPressed: () => notifier.onCallClick(),
    );
  }

  // ── Map Directions ──────────────────────────────────────────────

  void _showDirectionsOnMap(
      BookingDetailResponse data, AppColorPalette colors) {
    final booking = data.booking;
    if (booking == null) return;

    final markers = <MapMarker>[];
    final bounds = <LatLng>[];

    // Pickup marker
    if (booking.pickupAddress != null) {
      final lat = booking.pickupAddress!.latitude ?? 0;
      final lng = booking.pickupAddress!.longitude ?? 0;
      markers.add(MapMarker(
        id: 'pickup',
        position: LatLng(lat, lng),
        title: getString(appStr.descriptionPickup, 'description_pickup'),
        iconAsset: 'assets/images/ic_pickup.png',
        iconWidth: 32,
        iconHeight: 32,
        iconColor: colors.colorPrimary.toARGB32(),
      ));
      bounds.add(LatLng(lat, lng));
    }

    // Stop markers
    final destinations = booking.destinationAddresses ?? [];
    if (destinations.length > 1) {
      for (int i = 0; i < destinations.length - 1; i++) {
        final addr = destinations[i];
        final lat = addr.latitude ?? 0;
        final lng = addr.longitude ?? 0;
        markers.add(MapMarker(
          id: 'stop_$i',
          position: LatLng(lat, lng),
          title: '${i + 1}',
          stopNumber: i + 1,
          iconWidth: 20,
          iconHeight: 20,
          iconColor: colors.colorPrimary.toARGB32(),
        ));
        bounds.add(LatLng(lat, lng));
      }
    }

    // Drop-off marker
    if (destinations.isNotEmpty) {
      final last = destinations.last;
      final lat = last.latitude ?? 0;
      final lng = last.longitude ?? 0;
      markers.add(MapMarker(
        id: 'dropoff',
        position: LatLng(lat, lng),
        title: getString(appStr.descriptionDropOff, 'description_drop_off'),
        iconAsset: 'assets/images/ic_drop_off.png',
        iconWidth: 32,
        iconHeight: 32,
        iconColor: colors.colorPrimary.toARGB32(),
      ));
      bounds.add(LatLng(lat, lng));
    }

    _bookingMarkers = markers;

    // Add driver marker if we have a position
    if (_driverPosition != null) {
      final pinUrl = _mapPinUrl != null && _mapPinUrl!.isNotEmpty
          ? ServerConfig.getFullImageUrl(_mapPinUrl)
          : null;
      markers.add(MapMarker(
        id: 'driver',
        position: _driverPosition!,
        iconUrl: pinUrl,
        iconAsset: 'assets/images/ic_car_pin.png',
        iconWidth: 40,
        iconHeight: 40,
      ));
    }

    _mapManager.setMarkers(markers);

    // Polyline
    final directionPath =
        booking.bookingInvoice?.estimated?.directionPath;
    if (directionPath != null && directionPath.isNotEmpty) {
      _mapManager.setPolyline(MapPolyline.fromEncoded(
        encoded: directionPath,
        color: colors.colorPrimary.toARGB32(),
      ));
    }

    // Fit bounds
    if (bounds.isNotEmpty) {
      _mapManager.fitBounds(bounds, padding: 150);
    }
  }

  // ── Navigation Helpers ──────────────────────────────────────────

  /// Handles system back press: collapse bottom sheet / close drawer / minimize app.
  /// Matches Kotlin BackHandler behavior — never navigates back to Home.
  void _handleBackPress() {
    // 1. Collapse bottom sheet if expanded
    if (_isSheetExpanded) {
      _sheetController.collapse();
      return;
    }
    // 2. Close drawer if open
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }
    // 3. Minimize app (move to background)
    SystemNavigator.pop();
  }

  void _openExternalNavigation() {
    final state =
        ref.read(tripViewModelProvider(widget.bookingId));
    final addr = state.nextAddress;
    if (addr == null) return;
    final lat = addr.latitude;
    final lng = addr.longitude;
    if (lat == null || lng == null) return;

    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _isBidSheetShowing = false;
  bool _isCancelSheetShowing = false;
  bool _isMoveBookingSheetShowing = false;
  bool _isCallOptionSheetShowing = false;
  bool _isConfirmationSheetShowing = false;
  bool _isConfirmationCodeSheetShowing = false;

  void _showMoveBookingSheet(List<MoveBooking> list, TripViewModel notifier) {
    if (list.isEmpty || _isMoveBookingSheetShowing) return;
    _isMoveBookingSheetShowing = true;
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingL, AppDimens.paddingL, AppDimens.paddingL, AppDimens.paddingM),
              child: AppText(
                getString(appStr.headingSwitchBooking, 'heading_switch_booking'),
                fontSize: AppTypos.textL,
                fontWeight: FontWeight.bold,
                color: colors.colorText,
              ),
            ),
            ...list.map(
              (b) => ListTile(
                leading: Icon(Icons.directions_car, color: colors.colorPrimary),
                title: AppText(b.uniqueId, color: colors.colorText),
                subtitle: AppText(b.address,
                    color: colors.colorTextHint, fontSize: AppTypos.textS),
                onTap: () {
                  Navigator.of(context).pop();
                  notifier.selectBooking(b.id);
                },
              ),
            ),
            const SizedBox(height: AppDimens.paddingM),
          ],
        ),
      ),
    ).whenComplete(() {
      _isMoveBookingSheetShowing = false;
      notifier.dismissMoveBookingBottomSheet();
    });
  }

  void _showBidAmountBottomSheet(TripViewModel notifier) {
    if (_isBidSheetShowing) return;
    _isBidSheetShowing = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final tripState =
                ref.watch(tripViewModelProvider(widget.bookingId));
            return BidAmountBottomSheet(
              errorMessage: tripState.bidAmountError,
              canAcceptBid: tripState.canAcceptBid,
              onAmountChanged: (value) => notifier.onBidAmountChange(value),
              onAccept: () {
                _isBidSheetShowing = false;
                Navigator.pop(context);
                notifier.acceptBidding();
              },
              onCancel: () {
                _isBidSheetShowing = false;
                Navigator.pop(context);
                notifier.dismissBidAmountBottomSheet();
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _isBidSheetShowing = false;
      notifier.dismissBidAmountBottomSheet();
    });
  }

  void _launchPhone(String phone) {
    final uri = Uri.parse('tel:$phone');
    launchUrl(uri);
  }

  void _openChat(TripState state) {
    context.navigateToChat(
      chatConfig: ChatConfig(
        chatType: 'CUSTOMER_DRIVER_CHAT',
        referenceId: state.bookingId,
        receiverImage: state.customerImageUrl,
        receiverName: state.customerName,
      ),
    );
  }
}
