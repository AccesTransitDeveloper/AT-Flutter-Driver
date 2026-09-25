import '../constants/app_constants.dart';
import '../../models/invoice.dart';
import '../../models/responses/booking/booking_detail_response.dart';
import 'price_utils.dart';

/// Max value used by backend for "unlimited" slot ranges
const double _backendMax = 9007199254740991;

/// Charge type enum for categorizing price data
enum ChargeType {
  charges,
  additionalPrices,
  accessibilityPrices,
  taxPrices,
}

/// Price type constants matching backend values
class PriceType {
  static const String bookingFee = 'bookingFee';
  static const String distancePrice = 'distancePrice';
  static const String timePrice = 'timePrice';
  static const String minimumFee = 'minimumFee';
  static const String waitingTimePrice = 'waitingTimePrice';
  static const String airportWaitingTimePrice = 'airportWaitingTimePrice';
  static const String stopWaitingTimePrice = 'stopWaitingTimePrice';
  static const String trafficTimePrice = 'trafficTimePrice';
  static const String surgePrice = 'surgePrice';
  static const String cancellationPrice = 'cancellationPrice';
  static const String promoBonus = 'promoBonus';
  static const String roundOff = 'roundOff';
  static const String airportPrice = 'airportPrice';
  static const String zoneToZonePrice = 'zoneToZonePrice';
  static const String cityToCityPrice = 'cityToCityPrice';
  static const String bidPrice = 'bidPrice';
  static const String tipPrice = 'tipPrice';
  static const String cartPrice = 'cartPrice';
  static const String offerBonus = 'offerBonus';
  static const String deliveryPrice = 'deliveryPrice';
  static const String platformProfit = 'platformProfit';
  static const String extraCharge = 'extraCharge';
  static const String nowBookingCharge = 'nowBookingCharge';

  /// Get display title for price type key
  static String getTitle(String value) {
    return switch (value) {
      bookingFee => 'Booking Fee',
      distancePrice => 'Distance Price',
      timePrice => 'Time Price',
      minimumFee => 'Minimum Fee',
      waitingTimePrice => 'Waiting Time Price',
      airportWaitingTimePrice => 'Airport Waiting Time Price',
      stopWaitingTimePrice => 'Stop Waiting Time Price',
      trafficTimePrice => 'Traffic Time Price',
      surgePrice => 'Surge Price',
      cancellationPrice => 'Cancellation Price',
      promoBonus => 'Promo Bonus',
      roundOff => 'Round Off',
      airportPrice => 'Airport Price',
      zoneToZonePrice => 'Zone to Zone Price',
      cityToCityPrice => 'City to City Price',
      bidPrice => 'Bid Price',
      tipPrice => 'Tip Price',
      cartPrice => 'Item Total',
      offerBonus => 'Discounts and Offers',
      deliveryPrice => 'Delivery Charge',
      platformProfit => 'Platform Profit',
      extraCharge => 'Extra Charge',
      nowBookingCharge => 'Now Booking Charge',
      _ => value,
    };
  }
}

/// Driver-specific InvoiceUtil with isShowEarning support.
/// Ported from Kotlin InvoiceUtil.kt — switches between customer price
/// and driver profit based on the isShowEarning flag.
class InvoiceUtil {
  final int currencyDirection;
  final String currencySign;
  final int decimalPointValue;
  final int? distanceUnit;

  InvoiceUtil({
    required this.currencyDirection,
    required this.currencySign,
    required this.decimalPointValue,
    this.distanceUnit,
  });

  /// Build invoice list from InvoiceData.
  /// [isShowEarning] switches price vs driverProfit fields.
  List<Invoice> getInvoiceElements({
    required InvoiceData? invoiceData,
    required bool isShowEarning,
    bool isFareEstimate = false,
    List<MapEntry<String, String>> accessibilityList = const [],
  }) {
    if (invoiceData == null) return [];

    final invoiceList = <Invoice>[];

    // Process charges
    invoiceData.charges?.forEach((charge) {
      final invoice = _getElementFromPriceType(
        priceData: charge,
        chargeType: ChargeType.charges,
        isShowEarning: isShowEarning,
      );
      if (invoice != null) {
        final appliedOnStr = _getAppliedOnStr(
          applyOn: charge.applyOn,
          dataToFilter: invoiceData.charges ?? [],
          accessibilityList: accessibilityList,
        );
        invoiceList.add(invoice.copyWith(
          subTitle: _combineSubtitle(invoice.subTitle, appliedOnStr),
        ));
      }
    });

    // Process additional prices
    invoiceData.additionalPrices?.forEach((additionalPrice) {
      final invoice = _getElementFromPriceType(
        priceData: additionalPrice,
        chargeType: ChargeType.additionalPrices,
        isShowEarning: isShowEarning,
      );
      if (invoice != null) {
        invoiceList.add(invoice);
      }
    });

    // Process accessibility prices (skip for fare estimate)
    if (!isFareEstimate) {
      invoiceData.accessibilityPrices?.forEach((accessibilityPrice) {
        final invoice = _getElementFromPriceType(
          priceData: accessibilityPrice,
          chargeType: ChargeType.accessibilityPrices,
          isShowEarning: isShowEarning,
        );
        if (invoice != null) {
          invoiceList.add(invoice);
        }
      });
    }

    // Process modifier prices
    invoiceData.modifierPrice?.forEach((modifier) {
      final priceData = _modifierToPriceData(modifier);
      final invoice = _getElementFromPriceType(
        priceData: priceData,
        chargeType: ChargeType.additionalPrices,
        isShowEarning: isShowEarning,
      );
      if (invoice != null) {
        invoiceList.add(invoice);
      }
    });

    // Process tax prices
    invoiceData.taxPrices?.forEach((taxPrice) {
      final invoice = _getElementFromPriceType(
        priceData: taxPrice,
        chargeType: ChargeType.taxPrices,
        isShowEarning: isShowEarning,
      );
      if (invoice != null) {
        final appliedOnStr = _getAppliedOnStr(
          applyOn: taxPrice.applyOn,
          dataToFilter: invoiceData.charges ?? [],
          accessibilityList: accessibilityList,
        );
        invoiceList.add(invoice.copyWith(
          subTitle: _combineSubtitle(invoice.subTitle, appliedOnStr),
        ));
      }
    });

    return invoiceList;
  }

  /// Core logic: build Invoice from PriceData, switching price/driverProfit
  Invoice? _getElementFromPriceType({
    required PriceData priceData,
    required ChargeType chargeType,
    required bool isShowEarning,
  }) {
    final amount = isShowEarning ? priceData.driverProfit : priceData.price;
    if ((amount ?? 0) <= 0) return null;

    final title = priceData.title ?? '';
    final titleValue = PriceType.getTitle(title);

    // Discount value
    final discountSource =
        isShowEarning ? priceData.driverProfit : priceData.discountedPrice;
    final priceSource =
        isShowEarning ? priceData.driverProfit : priceData.price;
    final discountValue = (discountSource != null &&
            discountSource > 0 &&
            discountSource < (priceSource ?? 0))
        ? discountSource.applyPriceSetting(
            currencyDirection: currencyDirection,
            currencySign: currencySign,
            decimalPointValue: decimalPointValue,
          )
        : null;

    // Price formatted
    final priceValue = (isShowEarning ? priceData.driverProfit : priceData.price)
        .applyPriceSetting(
      currencyDirection: currencyDirection,
      currencySign: currencySign,
      decimalPointValue: decimalPointValue,
    );

    // Is free
    final discountedSource =
        isShowEarning ? priceData.driverProfit : priceData.discountedPrice;
    final isFree = chargeType == ChargeType.charges &&
        discountedSource != null &&
        (discountedSource) <= 0.0;

    return switch (title) {
      PriceType.bookingFee ||
      PriceType.minimumFee ||
      PriceType.cancellationPrice ||
      PriceType.promoBonus =>
        Invoice(
          title: titleValue,
          subTitle: '',
          isFree: isFree,
          discount: discountValue,
          amount: priceValue,
          invoiceChild: _getChildren(priceData.childs, isShowEarning),
        ),
      PriceType.distancePrice => _getTimeDistancePriceElement(
          title: titleValue,
          amount: priceValue,
          priceData: priceData,
          isDistance: true,
          isShowEarning: isShowEarning,
        ),
      PriceType.timePrice ||
      PriceType.waitingTimePrice ||
      PriceType.airportWaitingTimePrice ||
      PriceType.stopWaitingTimePrice ||
      PriceType.trafficTimePrice =>
        _getTimeDistancePriceElement(
          title: titleValue,
          amount: priceValue,
          priceData: priceData,
          isDistance: false,
          isShowEarning: isShowEarning,
        ),
      PriceType.surgePrice => () {
          var subTitle = '';
          if ((priceData.unit ?? 0) > 0) {
            subTitle = '${priceData.unit} X';
          }
          return Invoice(
            title: titleValue,
            subTitle: subTitle,
            isFree: isFree,
            discount: discountValue,
            amount: priceValue,
            invoiceChild: _getChildren(priceData.childs, isShowEarning),
          );
        }(),
      _ => () {
          var subTitle = '';
          if (chargeType == ChargeType.taxPrices &&
              (priceData.unit ?? 0) > 0) {
            subTitle =
                '${priceData.unit?.format(decimalPointValue)} %';
          }
          if (title.isNotEmpty) {
            return Invoice(
              title: titleValue,
              subTitle: subTitle,
              isFree: isFree,
              discount: discountValue,
              amount: priceValue,
              invoiceChild: _getChildren(priceData.childs, isShowEarning),
            );
          }
          return null;
        }(),
    };
  }

  /// Build invoice element for distance/time-based pricing
  Invoice _getTimeDistancePriceElement({
    required String title,
    required String amount,
    required PriceData priceData,
    required bool isDistance,
    required bool isShowEarning,
  }) {
    final unit =
        isDistance ? DistanceUnit.getUnit(distanceUnit) : 'min';

    // Slot pricing
    if (priceData.isApplySlotPrice == true) {
      final subTitle = _getSubStringSlots(
        priceData: priceData,
        isApplied: true,
        isDistance: isDistance,
        isShowEarning: isShowEarning,
      );
      return Invoice(title: title, subTitle: subTitle, amount: amount);
    }

    // Standard base + unit pricing
    final subTitleList = <String>[];

    final basePrice = isShowEarning
        ? priceData.basePriceDriverProfit
        : priceData.basePrice;
    if ((basePrice ?? 0) > 0) {
      final basePriceStr = basePrice.applyPriceSetting(
        currencyDirection: currencyDirection,
        currencySign: currencySign,
        decimalPointValue: decimalPointValue,
      );
      var sub = 'Base: $basePriceStr';
      if ((priceData.basePriceUnit ?? 0) > 0) {
        final baseUnit =
            '${priceData.basePriceUnit?.format(decimalPointValue)} $unit';
        sub += ' ($baseUnit)';
      }
      subTitleList.add(sub);
    }

    final unitPrice = isShowEarning
        ? priceData.unitPriceDriverProfit
        : priceData.unitPrice;
    if (unitPrice != null) {
      final unitValue = unitPrice.applyPriceSetting(
        currencyDirection: currencyDirection,
        currencySign: currencySign,
        decimalPointValue: decimalPointValue,
      );
      subTitleList.add('$unitValue/$unit');
    }

    return Invoice(
      title: title,
      subTitle: subTitleList.join('\n'),
      amount: amount,
    );
  }

  /// Build slot pricing subtitle string
  String _getSubStringSlots({
    required PriceData priceData,
    required bool isApplied,
    required bool isDistance,
    required bool isShowEarning,
  }) {
    final unit =
        isDistance ? DistanceUnit.getUnit(distanceUnit) : 'min';
    final slotsList =
        (isApplied ? priceData.appliedSlots : priceData.slots) ?? [];

    final buffer = StringBuffer();
    for (var i = 0; i < slotsList.length; i++) {
      final slot = slotsList[i];
      final min = slot.min ?? 0;
      final max = slot.max ?? 0;
      final isLast = i == slotsList.length - 1;

      final price = isApplied
          ? (isShowEarning ? slot.driverProfit : slot.unitPrice)
          : (isShowEarning ? slot.driverProfit : slot.price);
      final unitValue = price.applyPriceSetting(
        currencyDirection: currencyDirection,
        currencySign: currencySign,
        decimalPointValue: decimalPointValue,
      );

      final maxStr = max == _backendMax ? '∞' : '$max';
      final slotRange = '$min $unit - $maxStr $unit';

      var strSub = '$unitValue/$unit';
      if (priceData.isSlotInPriceWithUnitCalculation != true) {
        strSub = unitValue;
      }

      if (priceData.isSlotInPriceWithSum == true || !isApplied) {
        buffer.write('$slotRange: $strSub');
        if (!isLast) buffer.write('\n');
      } else {
        if ((priceData.unit ?? 0) >= min &&
            (priceData.unit ?? 0) <= max &&
            !isLast) {
          buffer.write('$slotRange: $strSub\n');
          break;
        } else if (isLast) {
          buffer.write('$slotRange: $strSub');
        }
      }
    }
    return buffer.toString();
  }

  /// Map PriceData children to InvoiceChild list
  List<InvoiceChild> _getChildren(
      List<PriceData>? childs, bool isShowEarning) {
    if (childs == null || childs.isEmpty) return [];
    return childs.map((child) {
      final priceValue =
          (isShowEarning ? child.driverProfit : child.price).applyPriceSetting(
        currencyDirection: currencyDirection,
        currencySign: currencySign,
        decimalPointValue: decimalPointValue,
      );
      return InvoiceChild(
        title: child.title,
        amount: priceValue,
      );
    }).toList();
  }

  /// Convert ModifierPrice to PriceData for unified processing
  PriceData _modifierToPriceData(ModifierPrice modifier) {
    return PriceData(
      title: modifier.name,
      price: modifier.price,
      driverProfit: modifier.driverProfit,
      discountedPrice: modifier.discountedPrice,
      driverProfitPercentage: modifier.driverProfitPercentage,
      driverProfitType: modifier.driverProfitType,
      childs: modifier.options
          ?.map((opt) => PriceData(
                title: opt.name,
                price: opt.price,
                driverProfitType: opt.driverProfitType,
                driverProfit: opt.driverProfit,
                discountedPrice: opt.discountedPrice,
                driverProfitPercentage: opt.driverProfitPercentage,
              ))
          .toList(),
    );
  }

  /// Build "Applied On: ..." string for charges/taxes
  String _getAppliedOnStr({
    List<String>? applyOn,
    required List<PriceData> dataToFilter,
    List<MapEntry<String, String>> accessibilityList = const [],
  }) {
    if (applyOn == null || applyOn.isEmpty) return '';

    final applicableCharges = applyOn
        .where((charge) =>
            dataToFilter.any((d) =>
                d.title == charge ||
                (d.childs?.any((c) => c.title == charge) ?? false)) ||
            accessibilityList.any((a) => a.key == charge))
        .map((charge) {
      final accessibilityItem =
          accessibilityList.where((a) => a.key == charge).firstOrNull;
      return accessibilityItem?.value ?? PriceType.getTitle(charge);
    }).join(', ');

    if (applicableCharges.isEmpty) return '';
    return 'Applied On: $applicableCharges';
  }

  /// Combine existing subtitle with applied-on string
  String _combineSubtitle(String? subTitle, String appliedOnStr) {
    if (appliedOnStr.isEmpty) return (subTitle ?? '') + appliedOnStr;
    if (subTitle != null && subTitle.isNotEmpty) {
      return '$subTitle\n$appliedOnStr';
    }
    return appliedOnStr;
  }
}
