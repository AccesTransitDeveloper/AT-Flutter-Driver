import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_utils.dart' hide SetCurrencySign;
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/booking/booking_detail_response.dart';
import '../../../viewmodels/marketplace_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceViewModelProvider);
    final colors = context.colors;

    ref.listen<MarketplaceState>(marketplaceViewModelProvider, (prev, next) {
      if (next.snackBarMessage != null &&
          next.snackBarMessage != prev?.snackBarMessage) {
        context.showErrorSnackBar(next.snackBarMessage!);
        ref.read(marketplaceViewModelProvider.notifier).clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingMarketplaceRide, 'heading_marketplace_ride'),
            ),
            Expanded(child: _buildBody(state, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(MarketplaceState state, AppColorPalette colors) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.bookings.isEmpty) {
      return Center(
        child: AppText(
          getString(appStr.errorNoBookingsFound, 'error_no_bookings_found'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
      itemCount: state.bookings.length,
      separatorBuilder: (_, _) => Divider(
        color: colors.colorBackgroundGray,
        height: 1,
        indent: AppDimens.padding,
        endIndent: AppDimens.padding,
      ),
      itemBuilder: (context, index) {
        return _MarketplaceBookingItem(
          booking: state.bookings[index],
          onTap: () {
            context.navigateToUpcomingTripDetailFromMarketplace(
              bookingId: state.bookings[index].id ?? '',
            );
          },
        );
      },
    );
  }
}

class _MarketplaceBookingItem extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _MarketplaceBookingItem({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invoice = booking.bookingInvoice;
    final estimated = invoice?.estimated;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Booking ID + Date/Time
            _buildHeaderRow(colors),
            const SizedBox(height: AppDimens.paddingS),

            // Address list
            _buildAddressList(colors),
            const SizedBox(height: AppDimens.paddingS),

            // Row 2: Vehicle | Distance | Time | Price
            _buildInfoRow(colors, estimated, invoice),
            const SizedBox(height: AppDimens.paddingS),

            // Row 3: Driver Earning + Booking type tag
            _buildFooterRow(colors, estimated, invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppColorPalette colors) {
    final dateTimeStr = _formatBookingDateTime();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          '#${booking.uniqueId ?? ''}',
          fontSize: AppTypos.textS,
          color: colors.colorTextHint,
        ),
        AppText(
          dateTimeStr,
          fontSize: AppTypos.textS,
          color: colors.colorTextHint,
        ),
      ],
    );
  }

  Widget _buildAddressList(AppColorPalette colors) {
    final addresses = <BookingAddress>[];
    if (booking.pickupAddress != null) {
      addresses.add(booking.pickupAddress!);
    }
    if (booking.destinationAddresses != null) {
      addresses.addAll(booking.destinationAddresses!);
    }

    if (addresses.isEmpty) return const SizedBox.shrink();

    const rowHeight = 48.0;
    final destinations = addresses.length > 1 ? addresses.sublist(1) : <BookingAddress>[];
    final totalHeight = addresses.length * rowHeight;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.colorBackgroundGray),
        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS,
      ),
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
                // Destination/stop icons
                for (int i = 0; i < destinations.length; i++)
                  Positioned(
                    top: rowHeight +
                        (i * rowHeight) +
                        (rowHeight / 2) -
                        10,
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
                                color: colors.colorSelectedText,
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

  Widget _buildInfoRow(
      AppColorPalette colors, InvoiceData? estimated, BookingInvoice? invoice) {
    final items = <Widget>[];
    final vehicleName = booking.vehicleType?.name;
    final distanceUnit = invoice?.distanceUnit ?? DistanceUnit.km;
    final currencySign = invoice?.currencySign ?? '';

    if (vehicleName != null && vehicleName.isNotEmpty) {
      items.add(_infoChip(vehicleName, colors));
    }

    if (estimated?.distance != null) {
      final unitLabel = distanceUnit == DistanceUnit.miles
          ? getString(appStr.descriptionDistanceUnitMi, 'description_distance_unit_mi')
          : getString(appStr.descriptionDistanceUnitKm, 'description_distance_unit_km');
      final divisor = distanceUnit == DistanceUnit.miles ? 1609.34 : 1000.0;
      final distanceValue = estimated!.distance! / divisor;
      items.add(_infoChip(
          '${distanceValue.toStringAsFixed(1)} $unitLabel', colors));
    }

    if (estimated?.time != null) {
      final timeInMinutes = (estimated!.time! / 60).ceil();
      items.add(_infoChip(
          '$timeInMinutes ${getString(appStr.descriptionMinutesUnit, 'description_minutes_unit')}', colors));
    }

    if (estimated?.total != null) {
      final decimal = invoice?.decimalPointValue ?? 2;
      final priceStr = estimated!.total!.applyPriceSetting(
        currencyDirection: invoice?.setCurrencySign ?? SetCurrencySign.left,
        currencySign: currencySign,
        decimalPointValue: decimal,
      );
      items.add(_infoChip(priceStr, colors));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppDimens.paddingS,
      runSpacing: AppDimens.paddingXS,
      children: items,
    );
  }

  Widget _infoChip(String text, AppColorPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
      ),
      child: AppText(
        text,
        fontSize: AppTypos.textS,
        color: colors.colorText,
      ),
    );
  }

  Widget _buildFooterRow(
      AppColorPalette colors, InvoiceData? estimated, BookingInvoice? invoice) {
    final currencySign = invoice?.currencySign ?? '';
    final decimal = invoice?.decimalPointValue ?? 2;
    final driverProfit = estimated?.driverProfit;
    final bookingType = booking.bookingType;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Driver earning
        if (driverProfit != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: colors.colorPrimary,
              ),
              const SizedBox(width: 4),
              AppText(
                getString(appStr.descriptionEarning, 'description_earning'),
                fontSize: AppTypos.textS,
                color: colors.colorTextHint,
              ),
              const SizedBox(width: 4),
              AppText(
                driverProfit.applyPriceSetting(
                  currencyDirection: invoice?.setCurrencySign ?? SetCurrencySign.left,
                  currencySign: currencySign,
                  decimalPointValue: decimal,
                ),
                fontSize: AppTypos.textS,
                fontWeight: FontWeight.w600,
                color: colors.colorText,
              ),
            ],
          )
        else
          const SizedBox.shrink(),

        // Booking type tag
        if (bookingType != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingS,
              vertical: AppDimens.paddingXS,
            ),
            decoration: BoxDecoration(
              color: colors.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
            ),
            child: AppText(
              _getBookingTypeName(bookingType),
              fontSize: AppTypos.textXS,
              fontWeight: FontWeight.w600,
              color: colors.colorPrimary,
            ),
          ),
      ],
    );
  }

  String _formatBookingDateTime() {
    final bookingTime = booking.bookingTime;
    if (bookingTime == null || bookingTime == 0) return '';

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(bookingTime * 1000);
    return intl.DateFormat('dd MMM, hh:mm a').format(dateTime);
  }

  String _getBookingTypeName(int type) {
    return switch (type) {
      PriceMode.normal =>
        getString(appStr.descriptionNormal, 'description_normal'),
      PriceMode.sharing =>
        getString(appStr.descriptionShare, 'description_share'),
      PriceMode.rental =>
        getString(appStr.descriptionRental, 'description_rental'),
      _ => getString(appStr.descriptionNormal, 'description_normal'),
    };
  }
}
