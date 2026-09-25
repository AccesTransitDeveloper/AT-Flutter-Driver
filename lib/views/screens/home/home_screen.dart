import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/router/app_route_observer.dart';
import '../../../core/managers/location_manager.dart';
import '../../../core/managers/permission_manager.dart';
import '../../../core/map/map.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/api/response_state.dart';
import '../../../data/api/server_config.dart';
import '../../../models/missing_info_item.dart';
import '../../../models/responses/home/additional_terms_item.dart';
import '../../../models/responses/home/assessment_config.dart';
import '../../../models/responses/home/heat_map_response.dart';
import '../../../models/webview_data_model.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text.dart';
import '../../widgets/business_type_bottom_sheet.dart';
import '../../bottomsheets/location_disclosure_bottom_sheet.dart';
import '../../bottomsheets/subscription_info_bottom_sheet.dart';
import 'home_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final MapInterface _mapManager;
  late final AnimationController _pulseController;
  bool _subscriptionSheetShowing = false;
  /// Whether the map has already been centred on the driver for this screen.
  bool _didAutoZoom = false;
  static const double _defaultZoom = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapManager = ref.read(mapManagerProvider)();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).init();
      final state = ref.read(homeViewModelProvider);
      _updateDriverMarker(state);
      // Location may already be known (e.g. coming back from another screen),
      // in which case the listener below won't fire.
      _autoZoomToDriver(state);
      _requestPermissions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _mapManager.dispose();
    super.dispose();
  }

  /// Called when navigating back to HomeScreen from another screen (e.g. TripScreen → Home).
  /// Equivalent to Kotlin's onResume triggered by back navigation.
  @override
  void didPopNext() {
    if (_subscriptionSheetShowing) {
      _subscriptionSheetShowing = false;
      return;
    }
    ref.read(homeViewModelProvider.notifier).getEntityDetail();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only fires when app returns from background, not from in-app navigation.
      // In-app back navigation is handled by didPopNext() above.
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrent) {
        ref.read(homeViewModelProvider.notifier).getEntityDetail();
      }
    }
  }

  Future<void> _requestPermissions() async {
    const permissionManager = PermissionManager.instance;
    final viewModel = ref.read(homeViewModelProvider.notifier);

    final locationStatus = await permissionManager.getLocationStatus();
    if (locationStatus == PermissionResult.granted) return;

    if (locationStatus == PermissionResult.permanentlyDenied) {
      if (mounted) _showLocationPermissionDialog(permanentlyDenied: true);
      return;
    }

    // Google Play Prominent Disclosure: must show an in-app disclosure that
    // explains background location collection BEFORE the system permission
    // prompt. Only request the permission after the driver affirmatively agrees.
    if (!viewModel.hasAcceptedLocationDisclosure) {
      if (!mounted) return;
      final agreed = await LocationDisclosureBottomSheet.show(context);
      if (!agreed) return;
      await viewModel.acceptLocationDisclosure();
    }

    if (!mounted) return;
    final locationResult = await permissionManager.requestLocation();
    if (!mounted) return;
    if (locationResult == PermissionResult.permanentlyDenied) {
      _showLocationPermissionDialog(permanentlyDenied: true);
    } else if (locationResult == PermissionResult.denied) {
      _showLocationPermissionDialog(permanentlyDenied: false);
    }
  }

  void _showLocationPermissionDialog({required bool permanentlyDenied}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: AppText.body(
          getString(appStr.headingPermissionRequired, 'heading_permission_required')
              .replacePlaceholders({StringConstant.param: 'Location'}),
          fontWeight: FontWeight.w600,
        ),
        content: AppText.body(
          getString(appStr.descriptionEnablePermissionInSettings,
                  'description_enable_permission_in_settings')
              .replacePlaceholders({StringConstant.param: 'location'}),
        ),
        actions: [
          if (permanentlyDenied) ...[
            AppTextButton(
              text: getString(appStr.buttonClose, 'button_close'),
              onPressed: () => Navigator.pop(context),
            ),
            AppTextButton(
              text: getString(appStr.buttonOpenSettings, 'button_open_settings'),
              onPressed: () {
                Navigator.pop(context);
                PermissionManager.instance.openSettings();
              },
            ),
          ] else
            AppTextButton(
              text: getString(appStr.buttonOk, 'button_ok'),
              onPressed: () async {
                Navigator.pop(context);
                final result = await PermissionManager.instance.requestLocation();
                if (mounted && result == PermissionResult.permanentlyDenied) {
                  _showLocationPermissionDialog(permanentlyDenied: true);
                }
              },
            ),
        ],
      ),
    );
  }

  /// Centre the map on the driver the first time a location is known. Runs
  /// once per screen so a later update doesn't yank the camera back while the
  /// driver is panning around. Safe to call before the map is created — the
  /// manager replays the pending camera move once the controller exists.
  void _autoZoomToDriver(HomeState state) {
    if (_didAutoZoom) return;
    final lat = state.currentLatitude;
    final lng = state.currentLongitude;
    if (lat == null || lng == null) return;
    _didAutoZoom = true;
    _mapManager.animateCamera(LatLng(lat, lng), zoom: _defaultZoom);
  }

  void _updateDriverMarker(HomeState state) {
    if (state.currentLatitude == null || state.currentLongitude == null) return;

    final pinUrl = state.mapPinUrl != null && state.mapPinUrl!.isNotEmpty
        ? ServerConfig.getFullImageUrl(state.mapPinUrl)
        : null;

    _mapManager.setMarkers([
      MapMarker(
        id: 'driver',
        position: LatLng(state.currentLatitude!, state.currentLongitude!),
        iconUrl: pinUrl,
        iconAsset: 'assets/images/ic_car_pin.png',
        iconWidth: 40,
        iconHeight: 40,
      ),
    ]);
  }

  Future<void> _loadHeatMapData() async {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final response = await viewModel.historyRepository.getHeatMap();
    if (response is Success<HeatMapResponse>) {
      final locations = response.data?.locations;
      if (locations != null && locations.isNotEmpty) {
        _mapManager.setHeatMap(
          locations
              .where((l) => l.latitude != null && l.longitude != null)
              .map((l) => HeatMapPoint(
                    latitude: l.latitude!,
                    longitude: l.longitude!,
                    weight: l.weight,
                  ))
              .toList(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // Update driver marker when location or map pin URL changes
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      if (next.currentLatitude != null &&
          next.currentLongitude != null &&
          (next.currentLatitude != previous?.currentLatitude ||
              next.currentLongitude != previous?.currentLongitude ||
              next.mapPinUrl != previous?.mapPinUrl)) {
        _updateDriverMarker(next);
        _autoZoomToDriver(next);
      }

      // Handle heat map toggle
      if (next.isHeatMapEnabled != previous?.isHeatMapEnabled) {
        if (next.isHeatMapEnabled) {
          _loadHeatMapData();
        } else {
          _mapManager.clearHeatMap();
        }
      }

      // Handle booking navigation
      if (next.navigateToBookingId != null &&
          next.navigateToBookingId != previous?.navigateToBookingId) {
        final bookingId = next.navigateToBookingId!;
        ref.read(homeViewModelProvider.notifier).clearBookingNavigation();
        context.navigateToCurrentRide(bookingId: bookingId);
      }

      // Handle subscription info bottom sheet
      if (next.showSubscriptionInfoBottomSheet &&
          next.showSubscriptionInfoBottomSheet !=
              previous?.showSubscriptionInfoBottomSheet) {
        final vm = ref.read(homeViewModelProvider.notifier);
        vm.dismissSubscriptionInfoBottomSheet();
        _subscriptionSheetShowing = true;
        SubscriptionInfoBottomSheet.show(
          context,
          title: next.subscriptionInfoTitle,
          price: next.subscriptionInfoPrice,
          description: next.subscriptionInfoDescription,
          isOptional: next.isSubscriptionOptional,
          onGoToSubscription: () {
            _subscriptionSheetShowing = false;
            context.navigateToSubscription();
          },
        );
      }

      // Handle snackbar messages
      if (next.snackBarMessage != null &&
          next.snackBarMessage != previous?.snackBarMessage) {
        if (next.isSnackBarError) {
          context.showErrorSnackBar(next.snackBarMessage!);
        } else {
          context.showSnackBar(next.snackBarMessage!);
        }
        ref.read(homeViewModelProvider.notifier).clearSnackBar();
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          // Layer 1: Full-screen Google Map
          Positioned.fill(
            child: MapHost(manager: _mapManager),
          ),

          // Layer 2: Approval pending overlay (below top bar & bottom section)
          if (homeState.showApprovalScreen)
            Positioned.fill(
              child: _buildApprovalOverlay(colors, homeState),
            ),

          // Layer 3: Top bar
          Positioned(
            top: topPadding + AppDimens.paddingS,
            left: AppDimens.padding,
            right: AppDimens.padding,
            child: _buildTopBar(colors, homeState),
          ),

          // Layer 4: Right-side FAB (my location)
          if (!homeState.showApprovalScreen)
            Positioned(
              right: AppDimens.padding,
              // Clear the bottom status bar only (~64 + safe area) and sit
              // beside the GO button rather than above it — the GO button is
              // centred, so the right edge next to it is free space.
              bottom: 80 +
                  bottomPadding +
                  (homeState.isOnline &&
                          homeState.goingToAddressAddress != null &&
                          homeState.goingToAddressAddress!.isNotEmpty
                      ? 60
                      : 0),
              child: _buildRightFabs(colors, homeState),
            ),

          // Layer 5: Bottom control section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSection(colors, homeState, bottomPadding),
          ),

          // Layer 6: Block overlay (full screen)
          if (homeState.isBlockStatus)
            Positioned.fill(
              child: _buildBlockOverlay(colors, homeState, bottomPadding),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(AppColorPalette colors, HomeState homeState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menu button
        _CircularIconButton(
          icon: Icons.menu,
          color: colors.colorText,
          backgroundColor: colors.colorBackground,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),

        const Spacer(),

        // Earnings badge (hidden for partner drivers)
        if (!homeState.isPartnerDriver)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              onTap: () {
                context.navigateToEarnings();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingL,
                  vertical: AppDimens.paddingS,
                ),
                decoration: BoxDecoration(
                  color: colors.colorBackground,
                  borderRadius: BorderRadius.circular(AppDimens.paddingXL),
                ),
                child: AppText.body(
                  homeState.todayEarning,
                  color: colors.colorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const Spacer(),

        // Notification + Create Request buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircularIconButton(
              icon: Icons.notifications_outlined,
              color: colors.colorText,
              backgroundColor: colors.colorBackground,
              onTap: () {
                context.navigateToInbox();
              },
            ),
            if (homeState.showCreateRequest) ...[
              const SizedBox(height: AppDimens.paddingS),
              _CircularIconButton(
                icon: Icons.hail,
                color: colors.colorText,
                backgroundColor: colors.colorBackground,
                onTap: () {
                  context.navigateToCreateRequest();
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRightFabs(AppColorPalette colors, HomeState homeState) {
    return _CircularIconButton(
      icon: Icons.my_location,
      color: colors.colorPrimary,
      backgroundColor: colors.colorBackground,
      size: 48,
      onTap: () => _centerOnCurrentLocation(),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final latLng = viewModel.currentLatLng;

    if (latLng != null) {
      _mapManager.animateCamera(latLng, zoom: 16);
      return;
    }

    // If no stored location, try to get a fresh one
    final result = await LocationManager.instance.getCurrentLocation();
    if (result is LocationSuccess) {
      _mapManager.animateCamera(
        LatLng(result.location.latitude, result.location.longitude),
        zoom: 16,
      );
    }
  }

  Widget _buildGoButton(
    AppColorPalette colors,
    HomeState homeState,
    HomeViewModel viewModel,
  ) {
    final buttonColor =
        homeState.isOnline ? colors.colorWarning : colors.colorSecondary;
    const double buttonSize = 80;

    return GestureDetector(
      onTap: homeState.isOnlineLoading ? null : viewModel.toggleOnlineOffline,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Base color fill
                  Container(
                    width: buttonSize,
                    height: buttonSize,
                    color: buttonColor,
                  ),
                  // Pulse ring
                  _buildPulseRing(
                    progress: _pulseController.value,
                    buttonSize: buttonSize,
                  ),
                  // GO text on top
                  child!,
                ],
              );
            },
            child: Center(
              child: homeState.isOnlineLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : AppText.title(
                      getString(appStr.buttonGo, 'button_go'),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing({
    required double progress,
    required double buttonSize,
  }) {
    final size = buttonSize * progress;
    final opacity = (1.0 - progress).clamp(0.0, 0.3);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 3,
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    AppColorPalette colors,
    HomeState homeState,
    double bottomPadding,
  ) {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final hasMissingInfo = homeState.missingInfoItems.isNotEmpty &&
        !homeState.showApprovalScreen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasMissingInfo) ...[
          // Required actions card (Mode A)
          _buildRequiredActionsCard(colors, homeState),
        ] else if (!homeState.showApprovalScreen) ...[
          // Hub driver vehicle controls
          if (homeState.isHubDriver && !homeState.isOnline) ...[
            if (!homeState.isVehiclePickedUp)
              // Hub driver NOT picked up → show "Pick Vehicle" only
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                child: GestureDetector(
                  onTap: () => context.navigateToVehicles(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingL,
                      vertical: AppDimens.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorPrimary,
                      borderRadius: BorderRadius.circular(AppDimens.paddingXL),
                    ),
                    child: AppText.body(
                      getString(
                          appStr.buttonPickVehicle, 'button_pick_vehicle'),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else ...[
              // Hub driver picked up + offline → show GO button + "Drop Vehicle"
              _buildGoButton(colors, homeState, viewModel),
              const SizedBox(height: AppDimens.paddingS),
              GestureDetector(
                onTap: () {
                  final typeId = viewModel.vehicleTypeId;
                  if (typeId != null) {
                    viewModel.dropVehicle(typeId);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingL,
                    vertical: AppDimens.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: colors.colorWarning,
                    borderRadius: BorderRadius.circular(AppDimens.paddingXL),
                  ),
                  child: AppText.body(
                    getString(
                        appStr.buttonDropVehicle, 'button_drop_vehicle'),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ] else if (!homeState.isHubDriver ||
              (homeState.isHubDriver && homeState.isVehiclePickedUp)) ...[
            // Regular driver or hub driver with vehicle picked up + online
            _buildGoButton(colors, homeState, viewModel),
          ],
        ],

        const SizedBox(height: AppDimens.paddingM),

        // Going-to address bar (when online + address available)
        if (homeState.isOnline &&
            homeState.goingToAddressAddress != null &&
            homeState.goingToAddressAddress!.isNotEmpty)
          _buildGoingToAddressBar(colors, homeState),

        // Bottom status bar
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: AppDimens.padding,
            right: AppDimens.padding,
            top: AppDimens.paddingM,
            bottom: bottomPadding + AppDimens.paddingM,
          ),
          decoration: BoxDecoration(
            color: colors.colorBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.paddingL),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Vehicle button
                  GestureDetector(
                    onTap: () => context.navigateToVehicles(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.colorBackgroundGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: colors.colorText,
                        size: AppDimens.iconSize,
                      ),
                    ),
                  ),

                  // Status text (centered)
                  Expanded(
                    child: Center(
                      child: AppText.body(
                        homeState.isOnline
                            ? (homeState.zoneQueue.isNotEmpty
                                ? homeState.zoneQueue
                                : getString(appStr.textYoureOnline,
                                    'text_youre_online'))
                            : getString(
                                appStr.textYoureOffline, 'text_youre_offline'),
                        fontWeight: FontWeight.w600,
                        color: colors.colorText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Bidding button (online + TAXI) or placeholder
                  if (homeState.showBidding && homeState.isOnline)
                    GestureDetector(
                      onTap: () {
                        context.navigateToBiddingRequests();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.colorBackgroundGray,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.gavel,
                          color: colors.colorText,
                          size: AppDimens.iconSize,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),

              // Cash booking minimum wallet warning
              if (!homeState.isCreditStatusOk && homeState.isOnline)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.paddingS),
                  child: AppText.body(
                    getString(appStr.errorWalletLimitCash,
                            'error_wallet_limit_cash')
                        .replaceAll('{{_AMOUNT}}',
                            homeState.cashBookingMinimumWallet),
                    color: colors.colorWarning,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Going-to Address Bar ──────────────────────────────────────

  Widget _buildGoingToAddressBar(AppColorPalette colors, HomeState homeState) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: AppDimens.padding,
        right: AppDimens.padding,
        bottom: AppDimens.paddingS,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingM,
      ),
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: BorderRadius.circular(AppDimens.paddingM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.home_outlined,
            color: colors.colorPrimary,
            size: AppDimens.iconSize,
          ),
          const SizedBox(width: AppDimens.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (homeState.goingToAddressTitle != null &&
                    homeState.goingToAddressTitle!.isNotEmpty)
                  AppText.body(
                    homeState.goingToAddressTitle!,
                    fontWeight: FontWeight.w600,
                    color: colors.colorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                AppText.caption(
                  homeState.goingToAddressAddress!,
                  color: colors.colorTextHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Required Actions Card ───────────────────────────────────────

  Widget _buildRequiredActionsCard(
    AppColorPalette colors,
    HomeState homeState,
  ) {
    final items = homeState.missingInfoItems;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: BorderRadius.circular(AppDimens.paddingM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning accent bar at top
          Container(
            height: 4,
            color: colors.colorWarning,
          ),

          // Header: warning icon + title + count
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colors.colorWarning,
                  size: 24,
                ),
                const SizedBox(width: AppDimens.paddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.body(
                        '${getString(appStr.textRequiredActions, 'text_required_actions')} (${items.length})',
                        fontWeight: FontWeight.bold,
                        color: colors.colorText,
                      ),
                      const SizedBox(height: 2),
                      AppText.caption(
                        getString(appStr.textGoOnlineWhenResolved,
                            'text_go_online_when_resolved'),
                        color: colors.colorWarning,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: colors.colorBackgroundGray),

          // List of missing info items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMissingInfoTile(colors, item),
                if (index < items.length - 1)
                  Divider(
                    height: 1,
                    color: colors.colorBackgroundGray,
                    indent: AppDimens.padding,
                    endIndent: AppDimens.padding,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMissingInfoTile(AppColorPalette colors, MissingInfoItem item) {
    return GestureDetector(
      onTap: item.isEnabled ? () => _navigateForMissingInfo(item) : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: item.isEnabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding,
            vertical: AppDimens.paddingM,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      item.title,
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText.caption(
                        item.description,
                        color: colors.colorTextHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (item.isEnabled)
                Icon(
                  Icons.chevron_right,
                  color: colors.colorTextHint,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateForMissingInfo(MissingInfoItem item) async {
    switch (item.id) {
      case 1: // Documents
        context.navigateToDocuments();
        break;
      case 2: // Vehicles
      case 3: // Vehicle documents
        context.navigateToVehicles();
        break;
      case 4: // Country
        final result = await context.navigateToSelectCountryCity(
          needsCountry: true,
        );
        if (result == true) _refreshAfterMissingInfo();
        break;
      case 5: // City
        final countryId =
            ref.read(homeViewModelProvider.notifier).entityCountryId;
        final result = await context.navigateToSelectCountryCity(
          needsCountry: false,
          existingCountryId: countryId,
        );
        if (result == true) _refreshAfterMissingInfo();
        break;
      case 6: // Profile
        context.navigateToProfile();
        break;
      case 7: // Availability
        context.navigateToSettings();
        break;
      case 8: // Assessment
        final config = item.data as AssessmentConfig?;
        if (config?.assessmentUrl != null) {
          context.navigateToWebView(
            webViewData: WebViewDataModel(
              webURL: config!.assessmentUrl,
              name: item.title,
            ),
          );
        }
        break;
      case 9: // Application Form
        final config = item.data as AssessmentConfig?;
        if (config?.url != null) {
          context.navigateToWebView(
            webViewData: WebViewDataModel(
              webURL: config!.url,
              name: item.title,
            ),
          );
        }
        break;
      case 10: // ABN
        final config = item.data as AssessmentConfig?;
        if (config?.url != null) {
          context.navigateToWebView(
            webViewData: WebViewDataModel(
              webURL: config!.url,
              name: item.title,
            ),
          );
        }
        break;
      case 11: // Select Business
        final selected = await showBusinessTypeBottomSheet(
          context,
          [BusinessType.taxi],
        );
        if (selected != null && mounted) {
          final success = await ref
              .read(homeViewModelProvider.notifier)
              .selectBusinessType(selected);
          if (success) _refreshAfterMissingInfo();
        }
        break;
      case 12: // Police Check
        final config = item.data as AssessmentConfig?;
        if (config?.url != null) {
          context.navigateToWebView(
            webViewData: WebViewDataModel(
              webURL: config!.url,
              name: item.title,
            ),
          );
        }
        break;
      case 13: // Additional Terms
        final termsItem = item.data as AdditionalTermsItem?;
        if (termsItem != null) {
          final result = await context.pushToAdditionalTerms(termsItem);
          if (result == true) _refreshAfterMissingInfo();
        }
        break;
      case 103: // Checkr background verification
        // The API hands back a one-time URL to finish the check. The WebView
        // closes itself on the DISMISS_WEBVIEW socket event; refreshing once it
        // pops mirrors native's `socketForCheckr()` reload. (Listening for that
        // socket event here would break the WebView's own listener, since
        // SocketManager.offEvent removes every handler for an event.)
        final url =
            await ref.read(homeViewModelProvider.notifier).initiateCheckr();
        if (url != null && mounted) {
          await context.navigateToWebView(
            webViewData: WebViewDataModel(
              webURL: url,
              name: item.title,
            ),
          );
          if (mounted) _refreshAfterMissingInfo();
        }
        break;
    }
  }

  void _refreshAfterMissingInfo() {
    ref.read(homeViewModelProvider.notifier).getInformationStatus();
  }

  // ── Approval Pending Overlay (Mode B) ────────────────────────────

  Widget _buildApprovalOverlay(
    AppColorPalette colors,
    HomeState homeState,
  ) {
    final title = homeState.missingInfoItems.isNotEmpty
        ? homeState.missingInfoItems.first.title
        : '';
    final description = homeState.missingInfoItems.isNotEmpty
        ? homeState.missingInfoItems.first.description
        : '';

    return Container(
      color: colors.colorBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimens.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 100,
                  color: colors.colorWarning,
                ),
                const SizedBox(height: AppDimens.paddingXL),
                AppText.title(
                  title,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.paddingM),
                AppText.body(
                  description,
                  textAlign: TextAlign.center,
                  color: colors.colorText.withValues(alpha: 0.6),
                ),
                if (homeState.isDeclineStatus) ...[
                  const SizedBox(height: AppDimens.paddingXL),
                  AppFilledButton(
                    text: getString(
                        appStr.buttonContactUs, 'button_contact_us'),
                    onPressed: () => context.navigateToContactUs(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Block Overlay ──────────────────────────────────────────────

  Widget _buildBlockOverlay(
    AppColorPalette colors,
    HomeState homeState,
    double bottomPadding,
  ) {
    return Container(
      color: colors.colorBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Block icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    color: Colors.red,
                    size: 40,
                  ),
                ),

                const SizedBox(height: AppDimens.paddingL),

                // Title
                AppText.title(
                  getString(
                    appStr.errorNotApprovedYet,
                    'error_not_approved_yet',
                  ),
                  color: colors.colorText,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimens.paddingM),

                // Message
                AppText.body(
                  homeState.blockedUserMessage.isNotEmpty
                      ? homeState.blockedUserMessage
                      : getString(
                          appStr.descriptionYourAccountIsBlocked,
                          'description_your_account_is_blocked',
                        ),
                  color: colors.colorTextHint,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),

                const SizedBox(height: AppDimens.paddingXL),

                // Contact Us button
                AppFilledButton(
                  text: getString(appStr.buttonContactUs, 'button_contact_us'),
                  onPressed: () => context.navigateToContactUs(),
                ),

                const SizedBox(height: AppDimens.paddingM),

                // Logout button
                AppOutlinedButton(
                  text: getString(appStr.buttonLogout, 'button_logout'),
                  onPressed: () => context.navigateToLogin(),
                  borderColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable circular icon button used on the map overlay
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final VoidCallback onTap;

  const _CircularIconButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 44,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: AppDimens.iconSize),
      ),
    );
  }
}
