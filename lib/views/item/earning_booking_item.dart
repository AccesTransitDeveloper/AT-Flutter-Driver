import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../models/responses/earning/earning_response.dart';
import '../widgets/app_divider.dart';
import '../widgets/app_text.dart';

class EarningBookingItem extends StatefulWidget {
  final EarningBooking booking;
  final String Function(double?) formatCurrency;

  const EarningBookingItem({
    super.key,
    required this.booking,
    required this.formatCurrency,
  });

  @override
  State<EarningBookingItem> createState() => _EarningBookingItemState();
}

class _EarningBookingItemState extends State<EarningBookingItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  List<EarningCharge> get _allCharges {
    final charges = <EarningCharge>[];
    if (widget.booking.charges != null) charges.addAll(widget.booking.charges!);
    if (widget.booking.additionalPrices != null) {
      charges.addAll(widget.booking.additionalPrices!);
    }
    return charges;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final booking = widget.booking;
    final customerName =
        booking.customerDetail?.fullName.isNotEmpty == true
            ? booking.customerDetail!.fullName
            : '--';
    final bookingId = booking.bookingUniqueId ?? '--';
    final profit = widget.formatCurrency(booking.driverProfit);
    final charges = _allCharges;

    return GestureDetector(
      onTap: charges.isNotEmpty ? _toggle : null,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingXS,
        ),
        decoration: BoxDecoration(
          color: colors.colorBackground,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          border: Border.all(color: colors.colorBackgroundGray),
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              child: Row(
                children: [
                  // Booking icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.colorBackgroundGray,
                    ),
                    child: Icon(
                      Icons.directions_car_outlined,
                      size: 18,
                      color: colors.colorText,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingS),

                  // ID + customer name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.caption(
                          bookingId,
                          color: colors.colorTextHint,
                        ),
                        AppText.body(
                          customerName,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),

                  // Profit + expand chevron
                  AppText(
                    profit,
                    fontSize: AppTypos.textM,
                    fontWeight: FontWeight.w700,
                    color: colors.colorText,
                  ),
                  if (charges.isNotEmpty) ...[
                    const SizedBox(width: AppDimens.paddingXS),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.colorTextHint,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Expanded charges
            if (_expanded && charges.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingM),
                child: AppDivider(
                  color: colors.colorBackgroundGray,
                ),
              ),
              ...charges.map(
                (charge) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingM,
                    vertical: AppDimens.paddingXS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.caption(
                        charge.title ?? '--',
                        color: colors.colorTextHint,
                      ),
                      AppText.caption(
                        widget.formatCurrency(charge.driverProfit),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingXS),
            ],
          ],
        ),
      ),
    );
  }
}
