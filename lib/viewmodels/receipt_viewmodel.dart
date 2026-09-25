import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/time_util.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/invoice_util.dart';
import '../core/utils/price_utils.dart';
import '../models/invoice.dart';
import '../models/responses/booking/booking_detail_response.dart';

/// State for the Receipt screen
class ReceiptState {
  final String bookingPrice;
  final String? earningStr;
  final String customerName;
  final String rideDate;
  final String paymentDate;
  final int paymentMode;
  final List<Invoice> invoiceList;
  final bool isMinFareApplied;
  final String distance;
  final String time;
  final String payment;
  final String waitingTime;
  final String stopWaitingTime;
  final String trafficTime;
  final Set<String> activeSetting;
  final bool showEarning;
  final bool hideTotal;
  final int businessType;

  const ReceiptState({
    this.bookingPrice = '',
    this.earningStr,
    this.customerName = '',
    this.rideDate = '',
    this.paymentDate = '',
    this.paymentMode = 0,
    this.invoiceList = const [],
    this.isMinFareApplied = false,
    this.distance = '',
    this.time = '',
    this.payment = '',
    this.waitingTime = '',
    this.stopWaitingTime = '',
    this.trafficTime = '',
    this.activeSetting = const {},
    this.showEarning = false,
    this.hideTotal = false,
    this.businessType = 1,
  });
}

/// Receipt params passed via navigation
class ReceiptParams {
  final Booking booking;
  final Set<String> activeSetting;
  final bool isPartnerDriver;

  const ReceiptParams({
    required this.booking,
    required this.activeSetting,
    this.isPartnerDriver = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptParams &&
          runtimeType == other.runtimeType &&
          booking.id == other.booking.id;

  @override
  int get hashCode => booking.id.hashCode;
}

/// ViewModel for the Receipt screen
class ReceiptViewModel extends StateNotifier<ReceiptState> {
  ReceiptViewModel(ReceiptParams params) : super(const ReceiptState()) {
    _loadInvoice(params.booking, params.activeSetting, params.isPartnerDriver);
  }

  void _loadInvoice(Booking booking, Set<String> activeSetting, bool isPartnerDriver) {
    final bookingInvoice = booking.bookingInvoice;
    final actual = bookingInvoice?.actual ?? bookingInvoice?.estimated;
    if (actual == null) return;

    final setCurrencySign = bookingInvoice?.setCurrencySign ?? 1;
    final currSign = bookingInvoice?.currencySign ?? '';
    final decimalPointValue = bookingInvoice?.decimalPointValue ?? 2;

    final isShowEarning =
        activeSetting.contains(DriverBookingSetting.showEarning) &&
        !isPartnerDriver;
    final hideTotal = activeSetting.contains(DriverBookingSetting.hideTotal);
    final isCash = bookingInvoice?.paymentMode == PaymentGatewayType.cash.value;

    final invoiceUtil = InvoiceUtil(
      currencyDirection: setCurrencySign,
      currencySign: currSign,
      decimalPointValue: decimalPointValue,
      distanceUnit: bookingInvoice?.distanceUnit,
    );

    // Total price
    final total = isShowEarning ? actual.driverProfit : actual.total;
    final bookingPrice = total.applyPriceSetting(
      currencyDirection: setCurrencySign,
      currencySign: currSign,
      decimalPointValue: decimalPointValue,
    );

    // Earning (separate from total)
    String? earningStr;
    if (isShowEarning && actual.driverProfit != null) {
      earningStr = actual.driverProfit.applyPriceSetting(
        currencyDirection: setCurrencySign,
        currencySign: currSign,
        decimalPointValue: decimalPointValue,
      );
    }

    // Customer name
    final customer = booking.customerDetail;
    final customerName = customer?.name ??
        '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'.trim();

    // Ride date
    final rideDate =
        _formatRideDate(booking.completedAt ?? booking.bookingTime);

    // Payment date
    final paymentDate =
        _formatPaymentDate(booking.completedAt ?? booking.bookingTime);

    // Distance
    final distanceUnit = DistanceUnit.getUnit(bookingInvoice?.distanceUnit);
    final distance = actual.distance != null
        ? '${actual.distance!.toStringAsFixed(1)} $distanceUnit'
        : '';

    // Time — the API reports these in seconds, not minutes.
    final time = TimeUtil.formatSeconds(actual.time);

    // Payment mode
    final paymentModeValue = bookingInvoice?.paymentMode ?? 0;
    final payment =
        PaymentGatewayType.fromValue(paymentModeValue)?.getName() ?? '';

    // Waiting times
    final waitingTime = TimeUtil.formatSeconds(actual.waitingTime);
    final stopWaitingTime = TimeUtil.formatSeconds(actual.stopWaitingTime);
    final trafficTime = TimeUtil.formatSeconds(actual.trafficTime);

    // Invoice line items
    final invoiceList = invoiceUtil.getInvoiceElements(
      invoiceData: actual,
      isShowEarning: isShowEarning,
    );

    state = ReceiptState(
      bookingPrice: bookingPrice,
      earningStr: earningStr,
      customerName: customerName,
      rideDate: rideDate,
      paymentDate: paymentDate,
      paymentMode: paymentModeValue,
      distance: distance,
      time: time,
      payment: payment,
      waitingTime: waitingTime,
      stopWaitingTime: stopWaitingTime,
      trafficTime: trafficTime,
      invoiceList: invoiceList,
      isMinFareApplied: actual.isMinFareApplied ?? false,
      activeSetting: activeSetting,
      showEarning: isShowEarning,
      hideTotal: hideTotal && !isCash,
      businessType: booking.businessType ?? BusinessType.taxi,
    );
  }

  static const List<String> _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static String _formatRideDate(int? millis) {
    if (millis == null || millis == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${_monthsFull[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  static String _formatPaymentDate(int? millis) {
    if (millis == null || millis == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.month}/${date.day.toString().padLeft(2, '0')}/${date.year.toString().substring(2)} ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }


}

/// Provider for ReceiptViewModel
final receiptViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReceiptViewModel, ReceiptState, ReceiptParams>(
        (ref, params) {
  return ReceiptViewModel(params);
});
