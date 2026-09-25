import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/destination_address.dart';
import '../../../models/invoice.dart';
import '../../../viewmodels/create_request_viewmodel.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../bottomsheets/date_picker_bottom_sheet.dart';
import '../../bottomsheets/time_picker_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toolbar.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRequestViewModelProvider);
    final vm = ref.read(createRequestViewModelProvider.notifier);
    final colors = context.colors;

    ref.listen<CreateRequestState>(createRequestViewModelProvider,
        (prev, next) {
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
        vm.clearError();
      }
      if (next.successMessage != null &&
          prev?.successMessage != next.successMessage) {
        context.showSnackBar(next.successMessage!);
        vm.clearSuccess();
        // Navigate to home and refresh entity detail
        context.navigateToHome();
        ref.read(homeViewModelProvider.notifier).getEntityDetail();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppToolbar(title: 'Create a Request'),
            if (state.isInitialLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.isBusinessNotAvailable)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_mall_directory_outlined,
                            size: 80, color: colors.colorTextHint),
                        const SizedBox(height: AppDimens.padding),
                        AppText.body(
                          state.businessNotAvailableMessage ??
                              'Business not available in your area',
                          color: colors.colorTextHint,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Now / Schedule Toggle ──
                    _buildScheduleSection(colors, state, vm),
                    const SizedBox(height: AppDimens.padding),

                    // ── Ride Type ──
                    _buildRideTypeSection(colors, state, vm),
                    const SizedBox(height: AppDimens.padding),

                    // ── Pickup Address ──
                    _buildAddressField(
                      colors: colors,
                      label: 'Pickup Address',
                      iconWidget: Image.asset('assets/images/ic_pickup.png',
                          width: 20, height: 20),
                      address: state.pickupAddress,
                      onTap: () async {
                        final result =
                            await context.navigateToSelectLocation();
                        if (result != null) {
                          vm.setPickupAddress(result);
                        }
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingS),

                    // ── Destination Addresses ──
                    ...state.destinationAddresses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dest = entry.value;
                      final isLast = index == state.destinationAddresses.length - 1;
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimens.paddingS),
                        child: _buildAddressField(
                          colors: colors,
                          label: isLast ? 'Drop-off' : 'Stop ${index + 1}',
                          iconWidget: isLast
                              ? Image.asset('assets/images/ic_drop_off.png',
                                  width: 20, height: 20)
                              : _buildStopNumber(colors, index + 1),
                          address: dest,
                          onTap: () async {
                            final result =
                                await context.navigateToSelectLocation(
                                    initialAddress: dest);
                            if (result != null) {
                              vm.updateDestination(index, result);
                            }
                          },
                          onRemove: () => vm.removeDestination(index),
                        ),
                      );
                    }),

                    // Add destination button (hide when maxStop limit reached)
                    _buildAddDestinationButton(colors, state, vm),
                    const SizedBox(height: AppDimens.padding),

                    // ── Customer Details ──
                    AppText.body(
                      'Customer Details',
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingS),

                    // First & Last name row
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _firstNameController,
                            hintText: 'First Name',
                            textInputAction: TextInputAction.next,
                            onChanged: vm.updateFirstName,
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingS),
                        Expanded(
                          child: AppTextField(
                            controller: _lastNameController,
                            hintText: 'Last Name',
                            textInputAction: TextInputAction.next,
                            onChanged: vm.updateLastName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingS),

                    // Phone number row
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: AppTextField(
                            hintText: state.countryPhoneCode.isNotEmpty
                                ? state.countryPhoneCode
                                : '+1',
                            enabled: false,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingS),
                        Expanded(
                          child: AppTextField(
                            controller: _phoneController,
                            hintText: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onChanged: vm.updatePhone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Button with Price ──
            if (!state.isBusinessNotAvailable)
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding),
                child: _buildBookButton(colors, state, vm),
              ),
          ],
        ),
      ),
    );
  }

  // ── Schedule Section ──

  Widget _buildScheduleSection(
    AppColorPalette colors,
    CreateRequestState state,
    CreateRequestViewModel vm,
  ) {
    // If neither Now nor Schedule is available, hide the section entirely
    if (!state.isShowRideNow && !state.isShowScheduleRide) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (state.isShowRideNow) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => vm.toggleScheduled(false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
                decoration: BoxDecoration(
                  color: !state.isScheduled
                      ? colors.colorPrimary
                      : colors.colorBackgroundGray,
                  borderRadius: BorderRadius.circular(AppDimens.paddingS),
                ),
                alignment: Alignment.center,
                child: AppText.body(
                  'Now',
                  color: !state.isScheduled ? colors.colorButtonText : colors.colorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (state.isShowScheduleRide) const SizedBox(width: AppDimens.paddingS),
        ],
        if (state.isShowScheduleRide)
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await DatePickerBottomSheet.show(
                  context: context,
                  initialDate: state.scheduledTime,
                  maxDays: state.maxScheduleSelectableDays,
                );
                if (date != null && mounted) {
                  final time = await TimePickerBottomSheet.show(
                    context: context,
                    selectedDate: date,
                  );
                  if (time != null) {
                    vm.setScheduledTime(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ));
                  }
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
                decoration: BoxDecoration(
                  color: state.isScheduled
                      ? colors.colorPrimary
                      : colors.colorBackgroundGray,
                  borderRadius: BorderRadius.circular(AppDimens.paddingS),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: state.isScheduled ? colors.colorButtonText : colors.colorText,
                    ),
                    const SizedBox(width: AppDimens.paddingXS),
                    AppText.body(
                      state.scheduledTime != null
                          ? _formatDateTime(state.scheduledTime!)
                          : 'Schedule',
                      color: state.isScheduled ? colors.colorButtonText : colors.colorText,
                      fontWeight: FontWeight.w600,
                    ),
                    if (state.isScheduled && state.isShowRideNow) ...[
                      const SizedBox(width: AppDimens.paddingXS),
                      GestureDetector(
                        onTap: () => vm.toggleScheduled(false),
                        child: Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: state.isScheduled ? colors.colorButtonText : colors.colorText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Ride Type Section ──

  Widget _buildRideTypeSection(
    AppColorPalette colors,
    CreateRequestState state,
    CreateRequestViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(
          'Ride Type',
          fontWeight: FontWeight.w600,
          color: colors.colorText,
        ),
        const SizedBox(height: AppDimens.paddingS),
        Wrap(
          spacing: AppDimens.paddingS,
          runSpacing: AppDimens.paddingS,
          children: state.availableRideTypes.map((type) {
            final isSelected = state.selectedRideType == type.type;
            return GestureDetector(
              onTap: () => vm.setRideType(type.type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding,
                  vertical: AppDimens.paddingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.colorPrimary
                      : colors.colorBackgroundGray,
                  borderRadius: BorderRadius.circular(AppDimens.paddingS),
                ),
                child: AppText.body(
                  type.name,
                  color: isSelected
                      ? colors.colorButtonText
                      : colors.colorText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Address Field ──

  Widget _buildStopNumber(AppColorPalette colors, int number) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colors.colorPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: AppText.caption(
          '$number',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required AppColorPalette colors,
    required String label,
    required Widget iconWidget,
    required DestinationAddress? address,
    required VoidCallback onTap,
    VoidCallback? onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          borderRadius: BorderRadius.circular(AppDimens.paddingS),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: AppDimens.paddingS),
            Expanded(
              child: AppText.body(
                address?.address ?? label,
                color: address != null
                    ? colors.colorText
                    : colors.colorTextHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  color: colors.colorTextHint,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Add Destination Button ──

  Widget _buildAddDestinationButton(
    AppColorPalette colors,
    CreateRequestState state,
    CreateRequestViewModel vm,
  ) {
    // Hide when maxStop limit is reached (stops = destinationAddresses.length - 1)
    final stopCount = state.destinationAddresses.isEmpty
        ? 0
        : state.destinationAddresses.length - 1;
    if (state.maxStop > 0 && stopCount >= state.maxStop) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        final result = await context.navigateToSelectLocation();
        if (result != null) {
          vm.addDestination(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: colors.colorPrimary, width: 1),
          borderRadius: BorderRadius.circular(AppDimens.paddingS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.colorPrimary, size: 20),
            const SizedBox(width: AppDimens.paddingXS),
            AppText.body(
              'Add Destination',
              color: colors.colorPrimary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  // ── Book Button with Price ──

  Widget _buildBookButton(
    AppColorPalette colors,
    CreateRequestState state,
    CreateRequestViewModel vm,
  ) {
    final hasPrice = state.fareEstimatePrice.isNotEmpty &&
        state.destinationAddresses.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!state.isLoading && !state.isFetchingPrice) {
          vm.createBooking();
        }
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.colorButtonBackground,
          borderRadius: BorderRadius.circular(AppDimens.paddingS),
        ),
        child: state.isLoading || state.isFetchingPrice
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: colors.colorButtonText,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: hasPrice
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppDimens.padding),
                    child: AppText.body(
                      state.isScheduled ? 'Schedule Ride' : 'Request Ride Now',
                      color: colors.colorButtonText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasPrice)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingS),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.body(
                            state.fareEstimatePrice,
                            color: colors.colorButtonText,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(width: AppDimens.paddingXS),
                          GestureDetector(
                            onTap: () => _showFareDetailSheet(colors, vm),
                            child: Icon(
                              Icons.info_outline,
                              color: colors.colorButtonText,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  // ── Fare Detail Bottom Sheet ──

  void _showFareDetailSheet(AppColorPalette colors, CreateRequestViewModel vm) {
    final detail = vm.getFareDetail();
    if (detail == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.padding,
                  AppDimens.padding,
                  AppDimens.padding,
                  AppDimens.paddingS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      'Fare Estimation',
                      fontWeight: FontWeight.w700,
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                    AppText.caption(
                      'This is just an estimated fare. Actual fare may vary slightly based on traffic or discount',
                      color: colors.colorTextHint,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.paddingS),
              Divider(color: colors.colorBackgroundGray, height: 1),

              // Invoice list
              Flexible(
                child: detail.invoiceList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimens.padding),
                        child: Center(
                          child: AppText.body(
                            'No fare details available',
                            color: colors.colorTextHint,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding,
                          vertical: AppDimens.paddingM,
                        ),
                        itemCount: detail.invoiceList.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppDimens.paddingM),
                        itemBuilder: (_, index) {
                          final invoice = detail.invoiceList[index];
                          return _InvoiceItemWidget(
                            invoice: invoice,
                            colors: colors,
                          );
                        },
                      ),
              ),

              Divider(color: colors.colorBackgroundGray, height: 1),

              if (detail.isMinFareApplied)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.padding, AppDimens.paddingS, AppDimens.padding, 0,
                  ),
                  child: AppText.caption(
                    'Minimum fare applied',
                    color: colors.colorPrimary,
                  ),
                ),

              // Distance | Total | Time summary row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.padding, AppDimens.paddingM,
                  AppDimens.padding, 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption('Distance',
                              color: colors.colorTextHint),
                          AppText.body(detail.distance ?? '-',
                              fontWeight: FontWeight.w600,
                              color: colors.colorText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AppText.caption('Total',
                              color: colors.colorTextHint),
                          AppText.body(detail.totalPrice,
                              fontWeight: FontWeight.w600,
                              color: colors.colorText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText.caption('Time',
                              color: colors.colorTextHint),
                          AppText.body(detail.totalTime ?? '-',
                              fontWeight: FontWeight.w600,
                              color: colors.colorText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding),
                child: AppFilledButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$minute $amPm';
  }
}

/// Invoice item widget matching customer app's _InvoiceItem
class _InvoiceItemWidget extends StatelessWidget {
  final Invoice invoice;
  final AppColorPalette colors;

  const _InvoiceItemWidget({
    required this.invoice,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(
                    invoice.title ?? '',
                    fontWeight: FontWeight.w500,
                  ),
                  if (invoice.subTitle?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    AppText.caption(
                      invoice.subTitle!,
                      color: colors.colorTextHint,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (invoice.isFree == true)
                  AppText.body(
                    'FREE',
                    color: colors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  )
                else
                  AppText.body(
                    invoice.amount ?? '',
                    fontWeight: FontWeight.w600,
                  ),
                if (invoice.discount?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  AppText.caption(
                    invoice.discount!,
                    color: colors.colorTextHint,
                    decoration: TextDecoration.lineThrough,
                  ),
                ],
              ],
            ),
          ],
        ),

        // Child items
        if (invoice.invoiceChild?.isNotEmpty == true) ...[
          const SizedBox(height: AppDimens.paddingS),
          ...invoice.invoiceChild!.map((child) => Padding(
                padding: const EdgeInsets.only(
                  left: AppDimens.padding,
                  top: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.caption(
                      child.title ?? '',
                      color: colors.colorTextHint,
                    ),
                    AppText.caption(
                      child.amount ?? '',
                      color: colors.colorTextHint,
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
