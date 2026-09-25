import 'package:json_annotation/json_annotation.dart';

part 'booking_detail_response.g.dart';

String? _uniqueIdFromJson(dynamic value) => value?.toString();

@JsonSerializable()
class BookingDetailResponse {
  final Booking? booking;
  final CitySetting? citySetting;
  @JsonKey(name: 'cancelUptoStatus')
  final int? cancelUpToStatus;
  final bool? isAllowCancelBooking;
  final int? remainingTime;
  final bool? isAllowCall;
  final String? videoCallUrl;
  final int? advancePaymentTimer;

  BookingDetailResponse({
    this.booking,
    this.citySetting,
    this.cancelUpToStatus,
    this.isAllowCancelBooking,
    this.remainingTime,
    this.isAllowCall,
    this.videoCallUrl,
    this.advancePaymentTimer,
  });

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookingDetailResponseToJson(this);
}

@JsonSerializable()
class Booking {
  @JsonKey(name: '_id')
  final String? id;
  final bool? isShowOtp;
  final int? businessType;
  final int? bookingType;
  final List<String>? bookingTags;
  final int? status;
  final int? nextStatus;
  final String? cityId;
  final String? vehicleTypeId;
  final String? vehiclePriceId;
  final String? cancellationReason;
  final String? speakingLanguage;
  final BookingAddress? pickupAddress;
  final List<BookingAddress>? destinationAddresses;
  final String? customerNote;
  final List<VerificationDetail>? verificationDetail;
  final int? bookingTime;
  final String? timezone;
  final BiddingDetail? biddingDetail;
  final CustomerDetail? customerDetail;
  final List<StatusTimeline>? statusTimeline;
  final List<BookingAddress>? actualDestinationAddresses;
  @JsonKey(fromJson: _uniqueIdFromJson)
  final String? uniqueId;
  final BookingInvoice? bookingInvoice;
  final VehicleType? vehicleType;
  final PackageDetail? packageDetail;
  final int? completedAt;
  final String? countryId;
  final int? createdType;
  final CitySetting? citySetting;
  final ConfirmedDriver? confirmedDriver;
  final bool? isAllowCall;
  final bool? isBookForOther;
  final bool? isManualAssigned;
  final bool? requiredParcelImage;
  final bool? requiredParcelScan;
  final BookingRating? rating;

  Booking({
    this.id,
    this.isShowOtp,
    this.businessType,
    this.bookingType,
    this.bookingTags,
    this.status,
    this.nextStatus,
    this.cityId,
    this.vehicleTypeId,
    this.vehiclePriceId,
    this.cancellationReason,
    this.speakingLanguage,
    this.pickupAddress,
    this.destinationAddresses,
    this.customerNote,
    this.verificationDetail,
    this.bookingTime,
    this.timezone,
    this.biddingDetail,
    this.customerDetail,
    this.statusTimeline,
    this.actualDestinationAddresses,
    this.uniqueId,
    this.bookingInvoice,
    this.vehicleType,
    this.packageDetail,
    this.completedAt,
    this.countryId,
    this.createdType,
    this.citySetting,
    this.confirmedDriver,
    this.isAllowCall,
    this.isBookForOther,
    this.isManualAssigned,
    this.requiredParcelImage,
    this.requiredParcelScan,
    this.rating,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);
}

@JsonSerializable(includeIfNull: false)
class BookingAddress {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? countryCode;
  final String? country;
  final String? postalCode;
  final String? note;
  final String? placeId;
  @JsonKey(name: '_id')
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? name;
  final String? phone;
  final int? type;

  BookingAddress({
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.countryCode,
    this.country,
    this.postalCode,
    this.note,
    this.placeId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.phone,
    this.type,
  });

  factory BookingAddress.fromJson(Map<String, dynamic> json) =>
      _$BookingAddressFromJson(json);

  Map<String, dynamic> toJson() => _$BookingAddressToJson(this);
}

@JsonSerializable()
class VerificationDetail {
  final int? status;
  final String? otp;

  VerificationDetail({this.status, this.otp});

  factory VerificationDetail.fromJson(Map<String, dynamic> json) =>
      _$VerificationDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDetailToJson(this);
}

@JsonSerializable()
class BiddingDetail {
  final bool? isBidding;
  final double? customerBidPrice;
  final double? customerBidRejectTime;
  final double? price;
  final Bid? bid;
  final int? remainingTime;
  final String? createdAt;
  final String? updatedAt;

  BiddingDetail({
    this.isBidding,
    this.customerBidPrice,
    this.customerBidRejectTime,
    this.price,
    this.bid,
    this.remainingTime,
    this.createdAt,
    this.updatedAt,
  });

  factory BiddingDetail.fromJson(Map<String, dynamic> json) =>
      _$BiddingDetailFromJson(json);

  Map<String, dynamic> toJson() => _$BiddingDetailToJson(this);
}

@JsonSerializable()
class Bid {
  final String? id;
  final double? price;
  final int? status;

  Bid({this.id, this.price, this.status});

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  Map<String, dynamic> toJson() => _$BidToJson(this);
}

@JsonSerializable()
class CustomerDetail {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? phone;
  final String? imageUrl;
  final double? rate;
  final bool? isFavourite;
  final String? createdAt;
  final String? updatedAt;
  final int? completedBookings;

  CustomerDetail({
    this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.phone,
    this.imageUrl,
    this.rate,
    this.isFavourite,
    this.createdAt,
    this.updatedAt,
    this.completedBookings,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerDetailToJson(this);
}

@JsonSerializable()
class StatusTimeline {
  final int? status;
  final int? time;
  final int? type;
  final String? typeId;
  final String? name;
  final int? waitingTime;
  @JsonKey(name: '_id')
  final String? id;
  final String? createdAt;
  final String? updatedAt;

  StatusTimeline({
    this.status,
    this.time,
    this.type,
    this.typeId,
    this.name,
    this.waitingTime,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory StatusTimeline.fromJson(Map<String, dynamic> json) =>
      _$StatusTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$StatusTimelineToJson(this);
}

@JsonSerializable()
class BookingInvoice {
  @JsonKey(name: '_id')
  final String? id;
  final int? distanceUnit;
  final String? currencySign;
  final int? setCurrencySign;
  final int? decimalPointValue;
  final InvoiceData? estimated;
  final InvoiceData? actual;
  final int? paymentMode;
  final double? driverPlatformProfitPercentage;
  final bool? isAdvancePaymentLimit;
  final int? paymentStatus;

  BookingInvoice({
    this.id,
    this.distanceUnit,
    this.currencySign,
    this.setCurrencySign,
    this.decimalPointValue,
    this.estimated,
    this.actual,
    this.paymentMode,
    this.driverPlatformProfitPercentage,
    this.isAdvancePaymentLimit,
    this.paymentStatus,
  });

  factory BookingInvoice.fromJson(Map<String, dynamic> json) =>
      _$BookingInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$BookingInvoiceToJson(this);
}

@JsonSerializable()
class InvoiceData {
  final double? distance;
  final double? time;
  final double? pickTime;
  final double? waitingTime;
  final double? stopWaitingTime;
  final double? trafficTime;
  final String? directionPath;
  final bool? isMinFareApplied;
  final List<PriceData>? charges;
  final List<PriceData>? additionalPrices;
  final List<PriceData>? accessibilityPrices;
  final List<PriceData>? taxPrices;
  final bool? isOutsideBoundary;
  final int? priceType;
  final double? total;
  final double? driverProfit;
  @JsonKey(name: 'modifierPrices')
  final List<ModifierPrice>? modifierPrice;
  final String? pickDate;

  InvoiceData({
    this.distance,
    this.time,
    this.pickTime,
    this.waitingTime,
    this.stopWaitingTime,
    this.trafficTime,
    this.directionPath,
    this.isMinFareApplied,
    this.charges,
    this.additionalPrices,
    this.accessibilityPrices,
    this.taxPrices,
    this.isOutsideBoundary,
    this.priceType,
    this.total,
    this.driverProfit,
    this.modifierPrice,
    this.pickDate,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceDataToJson(this);
}

@JsonSerializable()
class PriceData {
  final bool? isActive;
  final String? title;
  final String? chargeId;
  final int? type;
  final double? price;
  final double? discountedPrice;
  final int? priceType;
  final double? driverProfit;
  final int? driverProfitType;
  final List<String>? applyOn;
  final List<AppliedSlot>? appliedSlots;
  final List<AppliedSlot>? slots;
  final double? basePrice;
  final double? basePriceUnit;
  final double? unitPrice;
  final double? driverProfitPercentage;
  final double? unit;
  final bool? isApplySlotPrice;
  final bool? isMinFareApplied;
  final bool? isApplyTax;
  final double? basePriceDriverProfit;
  final double? unitPriceDriverProfit;
  final List<PriceData>? childs;
  final bool? isSlotInPriceWithUnitCalculation;
  final bool? isSlotInPriceWithSum;

  PriceData({
    this.isActive,
    this.title,
    this.chargeId,
    this.type,
    this.price,
    this.discountedPrice,
    this.priceType,
    this.driverProfit,
    this.driverProfitType,
    this.applyOn,
    this.appliedSlots,
    this.slots,
    this.basePrice,
    this.basePriceUnit,
    this.unitPrice,
    this.driverProfitPercentage,
    this.unit,
    this.isApplySlotPrice,
    this.isMinFareApplied,
    this.isApplyTax,
    this.basePriceDriverProfit,
    this.unitPriceDriverProfit,
    this.childs,
    this.isSlotInPriceWithUnitCalculation,
    this.isSlotInPriceWithSum,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) =>
      _$PriceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PriceDataToJson(this);
}

@JsonSerializable()
class AppliedSlot {
  final double? min;
  final double? max;
  final double? price;
  final double? unitPrice;
  final double? unit;
  final double? driverProfit;

  AppliedSlot({
    this.min,
    this.max,
    this.price,
    this.unitPrice,
    this.unit,
    this.driverProfit,
  });

  factory AppliedSlot.fromJson(Map<String, dynamic> json) =>
      _$AppliedSlotFromJson(json);

  Map<String, dynamic> toJson() => _$AppliedSlotToJson(this);
}

@JsonSerializable()
class VehicleType {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? imageUrl;

  VehicleType({this.id, this.name, this.imageUrl});

  factory VehicleType.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeToJson(this);
}

@JsonSerializable()
class PackageDetail {
  @JsonKey(name: '_id')
  final String? id;
  final String? packageName;
  final PriceData? distancePrice;
  final PriceData? timePrice;

  PackageDetail({this.id, this.packageName, this.distancePrice, this.timePrice});

  factory PackageDetail.fromJson(Map<String, dynamic> json) =>
      _$PackageDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PackageDetailToJson(this);
}

@JsonSerializable()
class CitySetting {
  @JsonKey(name: '_id')
  final String? id;
  final List<String>? businessSetting;
  final List<String>? bookingSetting;
  final BookingSetting? driverBookingSetting;
  final BookingSetting? customerBookingSetting;
  final BidSetting? bidSetting;

  CitySetting({
    this.id,
    this.businessSetting,
    this.bookingSetting,
    this.driverBookingSetting,
    this.customerBookingSetting,
    this.bidSetting,
  });

  factory CitySetting.fromJson(Map<String, dynamic> json) =>
      _$CitySettingFromJson(json);

  Map<String, dynamic> toJson() => _$CitySettingToJson(this);
}

@JsonSerializable()
class BookingSetting {
  @JsonKey(name: 'REQUESTED')
  final List<String>? requested;
  @JsonKey(name: 'ASSIGNED')
  final List<String>? assigned;
  @JsonKey(name: 'ACCEPTED')
  final List<String>? accepted;
  @JsonKey(name: 'IN_ROUTE')
  final List<String>? inRoute;
  @JsonKey(name: 'ARRIVED_AT_PICKUP')
  final List<String>? arrivedAtPickup;
  @JsonKey(name: 'PICKED')
  final List<String>? picked;
  @JsonKey(name: 'STARTED')
  final List<String>? started;
  @JsonKey(name: 'DROPPED')
  final List<String>? dropped;
  @JsonKey(name: 'ARRIVED_AT_STOP')
  final List<String>? arrivedAtStop;
  @JsonKey(name: 'ARRIVED_NEAR_DESTINATION')
  final List<String>? arrivedNearDestination;
  @JsonKey(name: 'ARRIVED_AT_DESTINATION')
  final List<String>? arrivedAtDestination;
  @JsonKey(name: 'SERVICE_COMPLETED')
  final List<String>? serviceCompleted;
  final int? verificationCodeLength;

  BookingSetting({
    this.requested,
    this.assigned,
    this.accepted,
    this.inRoute,
    this.arrivedAtPickup,
    this.picked,
    this.started,
    this.dropped,
    this.arrivedAtStop,
    this.arrivedNearDestination,
    this.arrivedAtDestination,
    this.serviceCompleted,
    this.verificationCodeLength,
  });

  factory BookingSetting.fromJson(Map<String, dynamic> json) =>
      _$BookingSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingSettingToJson(this);
}

@JsonSerializable()
class ConfirmedDriver {
  final String? id;
  final String? imageUrl;
  final bool? isFavourite;
  final String? name;
  final String? phone;
  final double? rate;

  ConfirmedDriver({
    this.id,
    this.imageUrl,
    this.isFavourite,
    this.name,
    this.phone,
    this.rate,
  });

  factory ConfirmedDriver.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedDriverFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedDriverToJson(this);
}

@JsonSerializable()
class BidSetting {
  final bool? isCustomerCanBid;
  final int? customerBiddingTimeout;
  final int? driverBiddingTimeout;
  final double? maxDriverBidLimit;
  final double? customerMinBid;
  final double? driverMaxBid;

  BidSetting({
    this.isCustomerCanBid,
    this.customerBiddingTimeout,
    this.driverBiddingTimeout,
    this.maxDriverBidLimit,
    this.customerMinBid,
    this.driverMaxBid,
  });

  factory BidSetting.fromJson(Map<String, dynamic> json) =>
      _$BidSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BidSettingToJson(this);
}

@JsonSerializable()
class ModifierPrice {
  final String? id;
  final String? name;
  final bool? isAllowAddQuantity;
  final double? maxQtyAddInCart;
  final double? driverProfit;
  final int? driverProfitType;
  final List<ModifierOption>? options;
  final double? price;
  final double? discountedPrice;
  final double? driverProfitPercentage;

  ModifierPrice({
    this.id,
    this.name,
    this.isAllowAddQuantity,
    this.maxQtyAddInCart,
    this.driverProfit,
    this.driverProfitType,
    this.options,
    this.price,
    this.discountedPrice,
    this.driverProfitPercentage,
  });

  factory ModifierPrice.fromJson(Map<String, dynamic> json) =>
      _$ModifierPriceFromJson(json);

  Map<String, dynamic> toJson() => _$ModifierPriceToJson(this);
}

@JsonSerializable()
class ModifierOption {
  final String? id;
  final String? name;
  final String? image;
  final double? price;
  final int? qty;
  final double? driverProfit;
  final int? driverProfitType;
  final double? discountedPrice;
  final double? driverProfitPercentage;

  ModifierOption({
    this.id,
    this.name,
    this.image,
    this.price,
    this.qty,
    this.driverProfit,
    this.driverProfitType,
    this.discountedPrice,
    this.driverProfitPercentage,
  });

  factory ModifierOption.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionFromJson(json);

  Map<String, dynamic> toJson() => _$ModifierOptionToJson(this);
}

@JsonSerializable()
class BookingRating {
  final double? customerRate;
  final String? customerReview;
  final double? driverRate;
  final String? driverReview;
  final double? customerMerchantRate;
  final String? customerMerchantReview;
  final double? driverMerchantRate;
  final String? driverMerchantReview;
  final double? merchantCustomerRate;
  final String? merchantCustomerReview;
  final double? merchantDriverRate;
  final String? merchantDriverReview;
  final String? createdAt;
  final String? updatedAt;

  BookingRating({
    this.customerRate,
    this.customerReview,
    this.driverRate,
    this.driverReview,
    this.customerMerchantRate,
    this.customerMerchantReview,
    this.driverMerchantRate,
    this.driverMerchantReview,
    this.merchantCustomerRate,
    this.merchantCustomerReview,
    this.merchantDriverRate,
    this.merchantDriverReview,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingRating.fromJson(Map<String, dynamic> json) =>
      _$BookingRatingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingRatingToJson(this);
}
