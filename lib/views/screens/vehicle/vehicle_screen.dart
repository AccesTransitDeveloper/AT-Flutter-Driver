import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/api/server_config.dart';
import '../../../models/responses/vehicle/vehicle_list_response.dart';
import '../../../viewmodels/vehicle_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

// ── Shared helpers ──────────────────────────────────────────────────

String vehicleDisplayName(Vehicle vehicle) {
  final year = vehicle.year ?? '';
  final brand = vehicle.brandDetail?.name ?? '';
  final model = vehicle.modelDetail?.name ?? '';
  final name = vehicle.name ?? '';
  if (brand.isNotEmpty || model.isNotEmpty) {
    return '$year $brand $model'.trim();
  }
  return name;
}

String? vehicleStatusText(int? docStatus) {
  switch (docStatus) {
    case VehicleDocumentStatus.pending:
    case VehicleDocumentStatus.pendingVehicle:
      return getString(
          appStr.descriptionVehiclePending, 'description_vehicle_pending');
    case VehicleDocumentStatus.rejected:
      return getString(
          appStr.descriptionVehicleRejected, 'description_vehicle_rejected');
    case VehicleDocumentStatus.expired:
    case VehicleDocumentStatus.expiredVehicle:
      return getString(appStr.descriptionVehicleInfoExpiresSoon,
          'description_vehicle_info_expires_soon');
    default:
      return null;
  }
}

Widget buildVehicleActionChip(
    BuildContext context, String text, Color bgColor,
    Color textColor, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      ),
      child: AppText.caption(text,
          color: textColor, fontWeight: FontWeight.w600),
    ),
  );
}

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(vehicleViewModelProvider.notifier);
      final state = ref.read(vehicleViewModelProvider);
      if (!state.isHubDriver) {
        vm.getVehicleList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleViewModelProvider);
    final vm = ref.read(vehicleViewModelProvider.notifier);
    final colors = context.colors;

    // Listen for snackbar messages and vehicle change sheet
    ref.listen<VehicleState>(vehicleViewModelProvider, (prev, next) {
      if (next.snackBarMessage.isNotEmpty &&
          prev?.snackBarMessage != next.snackBarMessage) {
        if (next.isSnackBarError) {
          context.showErrorSnackBar(next.snackBarMessage);
        } else {
          context.showSnackBar(next.snackBarMessage);
        }
        vm.clearSnackBar();
      }

      // Show change vehicle confirmation bottom sheet
      if (next.showSelectVehicleSheet &&
          prev?.showSelectVehicleSheet != true) {
        _showChangeVehicleSheet(context, vm, next);
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingVehicles, 'heading_vehicles'),
              rightIcon: !state.isHubDriver ? Icons.add : null,
              onRightIconPressed: !state.isHubDriver
                  ? () => context.navigateToAddEditVehicle().then((_) {
                        vm.getVehicleList();
                      })
                  : null,
            ),
            Expanded(
              child: state.isDataLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.totalVehicleList.isEmpty
                      ? _buildEmptyState(colors, state, vm)
                      : _buildVehicleContent(state, vm, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      AppColorPalette colors, VehicleState state, VehicleViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: colors.colorTextHint,
          ),
          const SizedBox(height: AppDimens.padding),
          AppText.body(
            getString(appStr.descriptionNoVehiclesFound, 'description_no_vehicles_found'),
            color: colors.colorTextHint,
          ),
          if (!state.isHubDriver && !state.isPartnerDriver) ...[
            const SizedBox(height: AppDimens.paddingXL),
            Padding(
              padding: AppDimens.screenPadding,
              child: AppFilledButton(
                text: getString(appStr.buttonAddVehicle, 'button_add_vehicle'),
                onPressed: () =>
                    context.navigateToAddEditVehicle().then((_) {
                      vm.getVehicleList();
                    }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleContent(
      VehicleState state, VehicleViewModel vm, AppColorPalette colors) {
    return RefreshIndicator(
      onRefresh: () async {
        if (state.isHubDriver) {
          await vm.getHubVehicleList();
        } else {
          await vm.getVehicleList();
        }
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppDimens.paddingXXL),
        children: [
          // Selected / Picked vehicle detail card
          if (state.isHubDriver && state.pickedVehicle != null)
            _VehicleDetailCard(
              vehicle: state.pickedVehicle!,
              isHubDriver: true,
              isOnline: state.isOnline,
              invoiceList: state.vehicleInvoiceList,
              onDrop: () => vm.dropVehicle(state.pickedVehicle!.id!),
              onQrCode: () => vm.onQrCodeClick(state.pickedVehicle!.id!),
            )
          else if (!state.isHubDriver && state.selectedVehicle != null)
            _VehicleDetailCard(
              vehicle: state.selectedVehicle!,
              isHubDriver: false,
              isOnline: state.isOnline,
              invoiceList: state.vehicleInvoiceList,
              onEdit: () => context
                  .navigateToAddEditVehicle(vehicle: state.selectedVehicle)
                  .then((_) => vm.getVehicleList()),
            ),

          // Other vehicles section
          if (state.vehicleList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingL,
                AppDimens.paddingXL,
                AppDimens.paddingL,
                AppDimens.paddingS,
              ),
              child: AppText.title(
                state.isHubDriver
                    ? getString(appStr.headingVehicles, 'heading_vehicles')
                    : getString(appStr.headingOtherVehicles, 'heading_other_vehicles'),
                fontSize: AppTypos.textL,
              ),
            ),
            ...state.vehicleList.map((vehicle) => _VehicleListItem(
                  vehicle: vehicle,
                  isHubDriver: state.isHubDriver,
                  onTap: state.isHubDriver
                      ? null
                      : () => vm.showChangeVehicleSheet(vehicle),
                  onEdit: state.isHubDriver
                      ? null
                      : () => context
                          .navigateToAddEditVehicle(vehicle: vehicle)
                          .then((_) => vm.getVehicleList()),
                  onPick: state.isHubDriver
                      ? () => vm.pickVehicle(vehicle.id!)
                      : null,
                )),
          ],

          // Add vehicle button at bottom (non-hub, non-partner, non-merchant)
          if (!state.isHubDriver && !state.isPartnerDriver) ...[
            const SizedBox(height: AppDimens.paddingXL),
            Padding(
              padding: AppDimens.screenPadding,
              child: AppOutlinedButton(
                text: getString(appStr.buttonAddVehicle, 'button_add_vehicle'),
                onPressed: () =>
                    context.navigateToAddEditVehicle().then((_) {
                      vm.getVehicleList();
                    }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChangeVehicleSheet(
      BuildContext context, VehicleViewModel vm, VehicleState state) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(
                getString(appStr.headingConfirmVehicleChange,
                    'heading_confirm_vehicle_change'),
                fontSize: AppTypos.textL,
              ),
              const SizedBox(height: AppDimens.paddingM),
              AppText.body(
                state.selectVehicleMessage,
                color: colors.colorTextHint,
              ),
              const SizedBox(height: AppDimens.paddingXL),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                          appStr.buttonCancel, 'button_cancel'),
                      onPressed: () {
                        context.pop();
                        vm.dismissSelectVehicleSheet();
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: AppFilledButton(
                      text:
                          getString(appStr.buttonYes, 'button_yes'),
                      onPressed: () {
                        context.pop();
                        vm.confirmVehicleChange();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // If dismissed by swiping/tapping outside, reset the state
      if (vm.mounted) vm.dismissSelectVehicleSheet();
    });
  }
}

// ── Vehicle Detail Card (Selected/Picked Vehicle) ──────────────────

class _VehicleDetailCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isHubDriver;
  final bool isOnline;
  final List<VehicleInvoice> invoiceList;
  final VoidCallback? onEdit;
  final VoidCallback? onDrop;
  final VoidCallback? onQrCode;

  const _VehicleDetailCard({
    required this.vehicle,
    required this.isHubDriver,
    required this.isOnline,
    required this.invoiceList,
    this.onEdit,
    this.onDrop,
    this.onQrCode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingS,
      ),
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle image / status icon
          _buildImageSection(colors),

          // Vehicle info
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row with edit/drop button
                Row(
                  children: [
                    Expanded(
                      child: AppText.title(
                        vehicleDisplayName(vehicle),
                        fontSize: AppTypos.textL,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHubDriver && !isOnline && onDrop != null)
                      buildVehicleActionChip(
                        context,
                        getString(appStr.buttonDrop, 'button_drop'),
                        Colors.red.shade50,
                        Colors.red,
                        onDrop!,
                      ),
                    if (!isHubDriver && onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colors.colorTextHint,
                          size: AppDimens.iconSizeSmall,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimens.paddingXS),

                // Licence number + vehicle type badges. The plate number was
                // dropped from add/edit in favour of the vehicle licence, so
                // showing it here left the badge blank on newer vehicles.
                Wrap(
                  spacing: AppDimens.paddingS,
                  runSpacing: AppDimens.paddingXS,
                  children: [
                    if (vehicle.vehicleLicense?.isNotEmpty == true)
                      _buildBadge(
                        vehicle.vehicleLicense!,
                        colors.colorPrimary,
                        colors.colorButtonText,
                      ),
                    if (vehicle.vehicleTypeDetail?.name != null)
                      _buildBadge(
                        vehicle.vehicleTypeDetail!.name!,
                        colors.colorPrimary.withValues(alpha: 0.1),
                        colors.colorPrimary,
                      ),
                    if (isHubDriver && onQrCode != null)
                      InkWell(
                        onTap: onQrCode,
                        child: Icon(
                          Icons.qr_code,
                          color: colors.colorPrimary,
                          size: AppDimens.iconSize,
                        ),
                      ),
                  ],
                ),

                // Status banner
                _buildStatusBanner(context, colors),

                // Invoice list
                if (invoiceList.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.paddingM),
                  ...invoiceList.map((invoice) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimens.paddingXS),
                        child: Row(
                          children: [
                            AppText.caption(
                              invoice.title ?? '',
                              color: colors.colorTextHint,
                            ),
                            if (invoice.subTitle != null) ...[
                              const SizedBox(width: AppDimens.paddingS),
                              AppText.caption(
                                invoice.subTitle!,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(AppColorPalette colors) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: colors.colorPrimary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.buttonRadius),
        ),
      ),
      child: _buildStatusImage(colors),
    );
  }

  Widget _buildStatusImage(AppColorPalette colors) {
    final docStatus = vehicle.documentStatus;
    final imageUrl = vehicle.vehicleTypeDetail?.imageUrl;
    final statusText = vehicleStatusText(docStatus);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Vehicle image
        if (imageUrl != null && imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: ServerConfig.getFullImageUrl(imageUrl),
            height: 120,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/default_vehicle.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          )
        else
          Image.asset(
            'assets/images/default_vehicle.png',
            height: 120,
            fit: BoxFit.contain,
          ),

        // Gray tint overlay + status text
        if (statusText != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.colorBackground.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.buttonRadius),
                ),
              ),
              alignment: Alignment.center,
              child: AppText.body(
                statusText,
                color: colors.colorTextHint,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBanner(BuildContext context, AppColorPalette colors) {
    final docStatus = vehicle.documentStatus;
    String? statusText;
    Color? bgColor;
    Color? textColor;

    statusText = vehicleStatusText(docStatus);

    switch (docStatus) {
      case VehicleDocumentStatus.pending:
      case VehicleDocumentStatus.pendingVehicle:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
      case VehicleDocumentStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
      case VehicleDocumentStatus.expired:
      case VehicleDocumentStatus.expiredVehicle:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
      default:
        break;
    }

    if (statusText == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppDimens.paddingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: textColor),
          const SizedBox(width: AppDimens.paddingS),
          Expanded(
            child: AppText.caption(
              statusText,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      ),
      child: AppText.caption(text, color: textColor, fontWeight: FontWeight.w500),
    );
  }

}

// ── Vehicle List Item (Other Vehicles) ──────────────────────────────

class _VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final bool isHubDriver;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onPick;

  const _VehicleListItem({
    required this.vehicle,
    required this.isHubDriver,
    required this.onTap,
    this.onEdit,
    this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingXS,
        ),
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle image
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: colors.colorPrimary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppDimens.buttonRadius),
                  ),
                ),
                child: _buildItemImage(colors),
              ),

              // Divider
              Container(width: 1, color: colors.colorBackground),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText.body(
                        vehicleDisplayName(vehicle),
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimens.paddingXS),
                      Wrap(
                        spacing: AppDimens.paddingXS,
                        runSpacing: AppDimens.paddingXS,
                        children: [
                          if (vehicle.vehicleLicense?.isNotEmpty == true)
                            _buildSmallBadge(
                              vehicle.vehicleLicense!,
                              colors.colorPrimary,
                              colors.colorButtonText,
                            ),
                          if (vehicle.vehicleTypeDetail?.name != null)
                            _buildSmallBadge(
                              vehicle.vehicleTypeDetail!.name!,
                              colors.colorPrimary.withValues(alpha: 0.1),
                              colors.colorPrimary,
                            ),
                          if (vehicleStatusText(vehicle.documentStatus) != null)
                            _buildSmallBadge(
                              vehicleStatusText(vehicle.documentStatus)!,
                              _getStatusColor(vehicle.documentStatus).withValues(alpha: 0.1),
                              _getStatusColor(vehicle.documentStatus),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action button
              if (isHubDriver && onPick != null)
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppDimens.paddingM),
                    child: buildVehicleActionChip(
                      context,
                      getString(appStr.buttonPick, 'button_pick'),
                      colors.colorSecondary.withValues(alpha: 0.1),
                      colors.colorSecondary,
                      onPick!,
                    ),
                  ),
                )
              else if (!isHubDriver && onEdit != null)
                Center(
                  child: IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.more_vert,
                      color: colors.colorTextHint,
                      size: AppDimens.iconSizeSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(AppColorPalette colors) {
    final imageUrl = vehicle.vehicleTypeDetail?.imageUrl;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingS),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: ServerConfig.getFullImageUrl(imageUrl),
              height: 60,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/default_vehicle.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            )
          : Image.asset(
              'assets/images/default_vehicle.png',
              height: 60,
              fit: BoxFit.contain,
            ),
    );
  }

  Color _getStatusColor(int? docStatus) {
    switch (docStatus) {
      case VehicleDocumentStatus.rejected:
        return Colors.red;
      case VehicleDocumentStatus.expired:
      case VehicleDocumentStatus.expiredVehicle:
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  Widget _buildSmallBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingXS + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: AppText.caption(
        text,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
