// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingDetailResponse _$BookingDetailResponseFromJson(
  Map<String, dynamic> json,
) => BookingDetailResponse(
  booking: json['booking'] == null
      ? null
      : Booking.fromJson(json['booking'] as Map<String, dynamic>),
  citySetting: json['citySetting'] == null
      ? null
      : CitySetting.fromJson(json['citySetting'] as Map<String, dynamic>),
  cancelUpToStatus: (json['cancelUptoStatus'] as num?)?.toInt(),
  isAllowCancelBooking: json['isAllowCancelBooking'] as bool?,
  remainingTime: (json['remainingTime'] as num?)?.toInt(),
  isAllowCall: json['isAllowCall'] as bool?,
  videoCallUrl: json['videoCallUrl'] as String?,
  advancePaymentTimer: (json['advancePaymentTimer'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookingDetailResponseToJson(
  BookingDetailResponse instance,
) => <String, dynamic>{
  'booking': instance.booking,
  'citySetting': instance.citySetting,
  'cancelUptoStatus': instance.cancelUpToStatus,
  'isAllowCancelBooking': instance.isAllowCancelBooking,
  'remainingTime': instance.remainingTime,
  'isAllowCall': instance.isAllowCall,
  'videoCallUrl': instance.videoCallUrl,
  'advancePaymentTimer': instance.advancePaymentTimer,
};

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['_id'] as String?,
  isShowOtp: json['isShowOtp'] as bool?,
  businessType: (json['businessType'] as num?)?.toInt(),
  bookingType: (json['bookingType'] as num?)?.toInt(),
  bookingTags: (json['bookingTags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  status: (json['status'] as num?)?.toInt(),
  nextStatus: (json['nextStatus'] as num?)?.toInt(),
  cityId: json['cityId'] as String?,
  vehicleTypeId: json['vehicleTypeId'] as String?,
  vehiclePriceId: json['vehiclePriceId'] as String?,
  cancellationReason: json['cancellationReason'] as String?,
  speakingLanguage: json['speakingLanguage'] as String?,
  pickupAddress: json['pickupAddress'] == null
      ? null
      : BookingAddress.fromJson(json['pickupAddress'] as Map<String, dynamic>),
  destinationAddresses: (json['destinationAddresses'] as List<dynamic>?)
      ?.map((e) => BookingAddress.fromJson(e as Map<String, dynamic>))
      .toList(),
  customerNote: json['customerNote'] as String?,
  verificationDetail: (json['verificationDetail'] as List<dynamic>?)
      ?.map((e) => VerificationDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  bookingTime: (json['bookingTime'] as num?)?.toInt(),
  timezone: json['timezone'] as String?,
  biddingDetail: json['biddingDetail'] == null
      ? null
      : BiddingDetail.fromJson(json['biddingDetail'] as Map<String, dynamic>),
  customerDetail: json['customerDetail'] == null
      ? null
      : CustomerDetail.fromJson(json['customerDetail'] as Map<String, dynamic>),
  statusTimeline: (json['statusTimeline'] as List<dynamic>?)
      ?.map((e) => StatusTimeline.fromJson(e as Map<String, dynamic>))
      .toList(),
  actualDestinationAddresses:
      (json['actualDestinationAddresses'] as List<dynamic>?)
          ?.map((e) => BookingAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
  uniqueId: _uniqueIdFromJson(json['uniqueId']),
  bookingInvoice: json['bookingInvoice'] == null
      ? null
      : BookingInvoice.fromJson(json['bookingInvoice'] as Map<String, dynamic>),
  vehicleType: json['vehicleType'] == null
      ? null
      : VehicleType.fromJson(json['vehicleType'] as Map<String, dynamic>),
  packageDetail: json['packageDetail'] == null
      ? null
      : PackageDetail.fromJson(json['packageDetail'] as Map<String, dynamic>),
  completedAt: (json['completedAt'] as num?)?.toInt(),
  countryId: json['countryId'] as String?,
  createdType: (json['createdType'] as num?)?.toInt(),
  citySetting: json['citySetting'] == null
      ? null
      : CitySetting.fromJson(json['citySetting'] as Map<String, dynamic>),
  confirmedDriver: json['confirmedDriver'] == null
      ? null
      : ConfirmedDriver.fromJson(
          json['confirmedDriver'] as Map<String, dynamic>,
        ),
  isAllowCall: json['isAllowCall'] as bool?,
  isBookForOther: json['isBookForOther'] as bool?,
  isManualAssigned: json['isManualAssigned'] as bool?,
  requiredParcelImage: json['requiredParcelImage'] as bool?,
  requiredParcelScan: json['requiredParcelScan'] as bool?,
  rating: json['rating'] == null
      ? null
      : BookingRating.fromJson(json['rating'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  '_id': instance.id,
  'isShowOtp': instance.isShowOtp,
  'businessType': instance.businessType,
  'bookingType': instance.bookingType,
  'bookingTags': instance.bookingTags,
  'status': instance.status,
  'nextStatus': instance.nextStatus,
  'cityId': instance.cityId,
  'vehicleTypeId': instance.vehicleTypeId,
  'vehiclePriceId': instance.vehiclePriceId,
  'cancellationReason': instance.cancellationReason,
  'speakingLanguage': instance.speakingLanguage,
  'pickupAddress': instance.pickupAddress,
  'destinationAddresses': instance.destinationAddresses,
  'customerNote': instance.customerNote,
  'verificationDetail': instance.verificationDetail,
  'bookingTime': instance.bookingTime,
  'timezone': instance.timezone,
  'biddingDetail': instance.biddingDetail,
  'customerDetail': instance.customerDetail,
  'statusTimeline': instance.statusTimeline,
  'actualDestinationAddresses': instance.actualDestinationAddresses,
  'uniqueId': instance.uniqueId,
  'bookingInvoice': instance.bookingInvoice,
  'vehicleType': instance.vehicleType,
  'packageDetail': instance.packageDetail,
  'completedAt': instance.completedAt,
  'countryId': instance.countryId,
  'createdType': instance.createdType,
  'citySetting': instance.citySetting,
  'confirmedDriver': instance.confirmedDriver,
  'isAllowCall': instance.isAllowCall,
  'isBookForOther': instance.isBookForOther,
  'isManualAssigned': instance.isManualAssigned,
  'requiredParcelImage': instance.requiredParcelImage,
  'requiredParcelScan': instance.requiredParcelScan,
  'rating': instance.rating,
};

BookingAddress _$BookingAddressFromJson(Map<String, dynamic> json) =>
    BookingAddress(
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      countryCode: json['countryCode'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      note: json['note'] as String?,
      placeId: json['placeId'] as String?,
      id: json['_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookingAddressToJson(BookingAddress instance) =>
    <String, dynamic>{
      'address': ?instance.address,
      'latitude': ?instance.latitude,
      'longitude': ?instance.longitude,
      'city': ?instance.city,
      'countryCode': ?instance.countryCode,
      'country': ?instance.country,
      'postalCode': ?instance.postalCode,
      'note': ?instance.note,
      'placeId': ?instance.placeId,
      '_id': ?instance.id,
      'createdAt': ?instance.createdAt,
      'updatedAt': ?instance.updatedAt,
      'name': ?instance.name,
      'phone': ?instance.phone,
      'type': ?instance.type,
    };

VerificationDetail _$VerificationDetailFromJson(Map<String, dynamic> json) =>
    VerificationDetail(
      status: (json['status'] as num?)?.toInt(),
      otp: json['otp'] as String?,
    );

Map<String, dynamic> _$VerificationDetailToJson(VerificationDetail instance) =>
    <String, dynamic>{'status': instance.status, 'otp': instance.otp};

BiddingDetail _$BiddingDetailFromJson(Map<String, dynamic> json) =>
    BiddingDetail(
      isBidding: json['isBidding'] as bool?,
      customerBidPrice: (json['customerBidPrice'] as num?)?.toDouble(),
      customerBidRejectTime: (json['customerBidRejectTime'] as num?)
          ?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      bid: json['bid'] == null
          ? null
          : Bid.fromJson(json['bid'] as Map<String, dynamic>),
      remainingTime: (json['remainingTime'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$BiddingDetailToJson(BiddingDetail instance) =>
    <String, dynamic>{
      'isBidding': instance.isBidding,
      'customerBidPrice': instance.customerBidPrice,
      'customerBidRejectTime': instance.customerBidRejectTime,
      'price': instance.price,
      'bid': instance.bid,
      'remainingTime': instance.remainingTime,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

Bid _$BidFromJson(Map<String, dynamic> json) => Bid(
  id: json['id'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  status: (json['status'] as num?)?.toInt(),
);

Map<String, dynamic> _$BidToJson(Bid instance) => <String, dynamic>{
  'id': instance.id,
  'price': instance.price,
  'status': instance.status,
};

CustomerDetail _$CustomerDetailFromJson(Map<String, dynamic> json) =>
    CustomerDetail(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      isFavourite: json['isFavourite'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      completedBookings: (json['completedBookings'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CustomerDetailToJson(CustomerDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'name': instance.name,
      'phone': instance.phone,
      'imageUrl': instance.imageUrl,
      'rate': instance.rate,
      'isFavourite': instance.isFavourite,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'completedBookings': instance.completedBookings,
    };

StatusTimeline _$StatusTimelineFromJson(Map<String, dynamic> json) =>
    StatusTimeline(
      status: (json['status'] as num?)?.toInt(),
      time: (json['time'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      typeId: json['typeId'] as String?,
      name: json['name'] as String?,
      waitingTime: (json['waitingTime'] as num?)?.toInt(),
      id: json['_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$StatusTimelineToJson(StatusTimeline instance) =>
    <String, dynamic>{
      'status': instance.status,
      'time': instance.time,
      'type': instance.type,
      'typeId': instance.typeId,
      'name': instance.name,
      'waitingTime': instance.waitingTime,
      '_id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

BookingInvoice _$BookingInvoiceFromJson(Map<String, dynamic> json) =>
    BookingInvoice(
      id: json['_id'] as String?,
      distanceUnit: (json['distanceUnit'] as num?)?.toInt(),
      currencySign: json['currencySign'] as String?,
      setCurrencySign: (json['setCurrencySign'] as num?)?.toInt(),
      decimalPointValue: (json['decimalPointValue'] as num?)?.toInt(),
      estimated: json['estimated'] == null
          ? null
          : InvoiceData.fromJson(json['estimated'] as Map<String, dynamic>),
      actual: json['actual'] == null
          ? null
          : InvoiceData.fromJson(json['actual'] as Map<String, dynamic>),
      paymentMode: (json['paymentMode'] as num?)?.toInt(),
      driverPlatformProfitPercentage:
          (json['driverPlatformProfitPercentage'] as num?)?.toDouble(),
      isAdvancePaymentLimit: json['isAdvancePaymentLimit'] as bool?,
      paymentStatus: (json['paymentStatus'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookingInvoiceToJson(BookingInvoice instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'distanceUnit': instance.distanceUnit,
      'currencySign': instance.currencySign,
      'setCurrencySign': instance.setCurrencySign,
      'decimalPointValue': instance.decimalPointValue,
      'estimated': instance.estimated,
      'actual': instance.actual,
      'paymentMode': instance.paymentMode,
      'driverPlatformProfitPercentage': instance.driverPlatformProfitPercentage,
      'isAdvancePaymentLimit': instance.isAdvancePaymentLimit,
      'paymentStatus': instance.paymentStatus,
    };

InvoiceData _$InvoiceDataFromJson(Map<String, dynamic> json) => InvoiceData(
  distance: (json['distance'] as num?)?.toDouble(),
  time: (json['time'] as num?)?.toDouble(),
  pickTime: (json['pickTime'] as num?)?.toDouble(),
  waitingTime: (json['waitingTime'] as num?)?.toDouble(),
  stopWaitingTime: (json['stopWaitingTime'] as num?)?.toDouble(),
  trafficTime: (json['trafficTime'] as num?)?.toDouble(),
  directionPath: json['directionPath'] as String?,
  isMinFareApplied: json['isMinFareApplied'] as bool?,
  charges: (json['charges'] as List<dynamic>?)
      ?.map((e) => PriceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  additionalPrices: (json['additionalPrices'] as List<dynamic>?)
      ?.map((e) => PriceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  accessibilityPrices: (json['accessibilityPrices'] as List<dynamic>?)
      ?.map((e) => PriceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  taxPrices: (json['taxPrices'] as List<dynamic>?)
      ?.map((e) => PriceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  isOutsideBoundary: json['isOutsideBoundary'] as bool?,
  priceType: (json['priceType'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toDouble(),
  driverProfit: (json['driverProfit'] as num?)?.toDouble(),
  modifierPrice: (json['modifierPrices'] as List<dynamic>?)
      ?.map((e) => ModifierPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
  pickDate: json['pickDate'] as String?,
);

Map<String, dynamic> _$InvoiceDataToJson(InvoiceData instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'time': instance.time,
      'pickTime': instance.pickTime,
      'waitingTime': instance.waitingTime,
      'stopWaitingTime': instance.stopWaitingTime,
      'trafficTime': instance.trafficTime,
      'directionPath': instance.directionPath,
      'isMinFareApplied': instance.isMinFareApplied,
      'charges': instance.charges,
      'additionalPrices': instance.additionalPrices,
      'accessibilityPrices': instance.accessibilityPrices,
      'taxPrices': instance.taxPrices,
      'isOutsideBoundary': instance.isOutsideBoundary,
      'priceType': instance.priceType,
      'total': instance.total,
      'driverProfit': instance.driverProfit,
      'modifierPrices': instance.modifierPrice,
      'pickDate': instance.pickDate,
    };

PriceData _$PriceDataFromJson(Map<String, dynamic> json) => PriceData(
  isActive: json['isActive'] as bool?,
  title: json['title'] as String?,
  chargeId: json['chargeId'] as String?,
  type: (json['type'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
  discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
  priceType: (json['priceType'] as num?)?.toInt(),
  driverProfit: (json['driverProfit'] as num?)?.toDouble(),
  driverProfitType: (json['driverProfitType'] as num?)?.toInt(),
  applyOn: (json['applyOn'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  appliedSlots: (json['appliedSlots'] as List<dynamic>?)
      ?.map((e) => AppliedSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  slots: (json['slots'] as List<dynamic>?)
      ?.map((e) => AppliedSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  basePrice: (json['basePrice'] as num?)?.toDouble(),
  basePriceUnit: (json['basePriceUnit'] as num?)?.toDouble(),
  unitPrice: (json['unitPrice'] as num?)?.toDouble(),
  driverProfitPercentage: (json['driverProfitPercentage'] as num?)?.toDouble(),
  unit: (json['unit'] as num?)?.toDouble(),
  isApplySlotPrice: json['isApplySlotPrice'] as bool?,
  isMinFareApplied: json['isMinFareApplied'] as bool?,
  isApplyTax: json['isApplyTax'] as bool?,
  basePriceDriverProfit: (json['basePriceDriverProfit'] as num?)?.toDouble(),
  unitPriceDriverProfit: (json['unitPriceDriverProfit'] as num?)?.toDouble(),
  childs: (json['childs'] as List<dynamic>?)
      ?.map((e) => PriceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  isSlotInPriceWithUnitCalculation:
      json['isSlotInPriceWithUnitCalculation'] as bool?,
  isSlotInPriceWithSum: json['isSlotInPriceWithSum'] as bool?,
);

Map<String, dynamic> _$PriceDataToJson(PriceData instance) => <String, dynamic>{
  'isActive': instance.isActive,
  'title': instance.title,
  'chargeId': instance.chargeId,
  'type': instance.type,
  'price': instance.price,
  'discountedPrice': instance.discountedPrice,
  'priceType': instance.priceType,
  'driverProfit': instance.driverProfit,
  'driverProfitType': instance.driverProfitType,
  'applyOn': instance.applyOn,
  'appliedSlots': instance.appliedSlots,
  'slots': instance.slots,
  'basePrice': instance.basePrice,
  'basePriceUnit': instance.basePriceUnit,
  'unitPrice': instance.unitPrice,
  'driverProfitPercentage': instance.driverProfitPercentage,
  'unit': instance.unit,
  'isApplySlotPrice': instance.isApplySlotPrice,
  'isMinFareApplied': instance.isMinFareApplied,
  'isApplyTax': instance.isApplyTax,
  'basePriceDriverProfit': instance.basePriceDriverProfit,
  'unitPriceDriverProfit': instance.unitPriceDriverProfit,
  'childs': instance.childs,
  'isSlotInPriceWithUnitCalculation': instance.isSlotInPriceWithUnitCalculation,
  'isSlotInPriceWithSum': instance.isSlotInPriceWithSum,
};

AppliedSlot _$AppliedSlotFromJson(Map<String, dynamic> json) => AppliedSlot(
  min: (json['min'] as num?)?.toDouble(),
  max: (json['max'] as num?)?.toDouble(),
  price: (json['price'] as num?)?.toDouble(),
  unitPrice: (json['unitPrice'] as num?)?.toDouble(),
  unit: (json['unit'] as num?)?.toDouble(),
  driverProfit: (json['driverProfit'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AppliedSlotToJson(AppliedSlot instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'price': instance.price,
      'unitPrice': instance.unitPrice,
      'unit': instance.unit,
      'driverProfit': instance.driverProfit,
    };

VehicleType _$VehicleTypeFromJson(Map<String, dynamic> json) => VehicleType(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$VehicleTypeToJson(VehicleType instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

PackageDetail _$PackageDetailFromJson(Map<String, dynamic> json) =>
    PackageDetail(
      id: json['_id'] as String?,
      packageName: json['packageName'] as String?,
      distancePrice: json['distancePrice'] == null
          ? null
          : PriceData.fromJson(json['distancePrice'] as Map<String, dynamic>),
      timePrice: json['timePrice'] == null
          ? null
          : PriceData.fromJson(json['timePrice'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PackageDetailToJson(PackageDetail instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'packageName': instance.packageName,
      'distancePrice': instance.distancePrice,
      'timePrice': instance.timePrice,
    };

CitySetting _$CitySettingFromJson(Map<String, dynamic> json) => CitySetting(
  id: json['_id'] as String?,
  businessSetting: (json['businessSetting'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  bookingSetting: (json['bookingSetting'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  driverBookingSetting: json['driverBookingSetting'] == null
      ? null
      : BookingSetting.fromJson(
          json['driverBookingSetting'] as Map<String, dynamic>,
        ),
  customerBookingSetting: json['customerBookingSetting'] == null
      ? null
      : BookingSetting.fromJson(
          json['customerBookingSetting'] as Map<String, dynamic>,
        ),
  bidSetting: json['bidSetting'] == null
      ? null
      : BidSetting.fromJson(json['bidSetting'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CitySettingToJson(CitySetting instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'businessSetting': instance.businessSetting,
      'bookingSetting': instance.bookingSetting,
      'driverBookingSetting': instance.driverBookingSetting,
      'customerBookingSetting': instance.customerBookingSetting,
      'bidSetting': instance.bidSetting,
    };

BookingSetting _$BookingSettingFromJson(
  Map<String, dynamic> json,
) => BookingSetting(
  requested: (json['REQUESTED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  assigned: (json['ASSIGNED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  accepted: (json['ACCEPTED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  inRoute: (json['IN_ROUTE'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  arrivedAtPickup: (json['ARRIVED_AT_PICKUP'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  picked: (json['PICKED'] as List<dynamic>?)?.map((e) => e as String).toList(),
  started: (json['STARTED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  dropped: (json['DROPPED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  arrivedAtStop: (json['ARRIVED_AT_STOP'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  arrivedNearDestination: (json['ARRIVED_NEAR_DESTINATION'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  arrivedAtDestination: (json['ARRIVED_AT_DESTINATION'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  serviceCompleted: (json['SERVICE_COMPLETED'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  verificationCodeLength: (json['verificationCodeLength'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookingSettingToJson(BookingSetting instance) =>
    <String, dynamic>{
      'REQUESTED': instance.requested,
      'ASSIGNED': instance.assigned,
      'ACCEPTED': instance.accepted,
      'IN_ROUTE': instance.inRoute,
      'ARRIVED_AT_PICKUP': instance.arrivedAtPickup,
      'PICKED': instance.picked,
      'STARTED': instance.started,
      'DROPPED': instance.dropped,
      'ARRIVED_AT_STOP': instance.arrivedAtStop,
      'ARRIVED_NEAR_DESTINATION': instance.arrivedNearDestination,
      'ARRIVED_AT_DESTINATION': instance.arrivedAtDestination,
      'SERVICE_COMPLETED': instance.serviceCompleted,
      'verificationCodeLength': instance.verificationCodeLength,
    };

ConfirmedDriver _$ConfirmedDriverFromJson(Map<String, dynamic> json) =>
    ConfirmedDriver(
      id: json['id'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isFavourite: json['isFavourite'] as bool?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ConfirmedDriverToJson(ConfirmedDriver instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'isFavourite': instance.isFavourite,
      'name': instance.name,
      'phone': instance.phone,
      'rate': instance.rate,
    };

BidSetting _$BidSettingFromJson(Map<String, dynamic> json) => BidSetting(
  isCustomerCanBid: json['isCustomerCanBid'] as bool?,
  customerBiddingTimeout: (json['customerBiddingTimeout'] as num?)?.toInt(),
  driverBiddingTimeout: (json['driverBiddingTimeout'] as num?)?.toInt(),
  maxDriverBidLimit: (json['maxDriverBidLimit'] as num?)?.toDouble(),
  customerMinBid: (json['customerMinBid'] as num?)?.toDouble(),
  driverMaxBid: (json['driverMaxBid'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BidSettingToJson(BidSetting instance) =>
    <String, dynamic>{
      'isCustomerCanBid': instance.isCustomerCanBid,
      'customerBiddingTimeout': instance.customerBiddingTimeout,
      'driverBiddingTimeout': instance.driverBiddingTimeout,
      'maxDriverBidLimit': instance.maxDriverBidLimit,
      'customerMinBid': instance.customerMinBid,
      'driverMaxBid': instance.driverMaxBid,
    };

ModifierPrice _$ModifierPriceFromJson(Map<String, dynamic> json) =>
    ModifierPrice(
      id: json['id'] as String?,
      name: json['name'] as String?,
      isAllowAddQuantity: json['isAllowAddQuantity'] as bool?,
      maxQtyAddInCart: (json['maxQtyAddInCart'] as num?)?.toDouble(),
      driverProfit: (json['driverProfit'] as num?)?.toDouble(),
      driverProfitType: (json['driverProfitType'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ModifierOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: (json['price'] as num?)?.toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      driverProfitPercentage: (json['driverProfitPercentage'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$ModifierPriceToJson(ModifierPrice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isAllowAddQuantity': instance.isAllowAddQuantity,
      'maxQtyAddInCart': instance.maxQtyAddInCart,
      'driverProfit': instance.driverProfit,
      'driverProfitType': instance.driverProfitType,
      'options': instance.options,
      'price': instance.price,
      'discountedPrice': instance.discountedPrice,
      'driverProfitPercentage': instance.driverProfitPercentage,
    };

ModifierOption _$ModifierOptionFromJson(Map<String, dynamic> json) =>
    ModifierOption(
      id: json['id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      qty: (json['qty'] as num?)?.toInt(),
      driverProfit: (json['driverProfit'] as num?)?.toDouble(),
      driverProfitType: (json['driverProfitType'] as num?)?.toInt(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      driverProfitPercentage: (json['driverProfitPercentage'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$ModifierOptionToJson(ModifierOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'price': instance.price,
      'qty': instance.qty,
      'driverProfit': instance.driverProfit,
      'driverProfitType': instance.driverProfitType,
      'discountedPrice': instance.discountedPrice,
      'driverProfitPercentage': instance.driverProfitPercentage,
    };

BookingRating _$BookingRatingFromJson(Map<String, dynamic> json) =>
    BookingRating(
      customerRate: (json['customerRate'] as num?)?.toDouble(),
      customerReview: json['customerReview'] as String?,
      driverRate: (json['driverRate'] as num?)?.toDouble(),
      driverReview: json['driverReview'] as String?,
      customerMerchantRate: (json['customerMerchantRate'] as num?)?.toDouble(),
      customerMerchantReview: json['customerMerchantReview'] as String?,
      driverMerchantRate: (json['driverMerchantRate'] as num?)?.toDouble(),
      driverMerchantReview: json['driverMerchantReview'] as String?,
      merchantCustomerRate: (json['merchantCustomerRate'] as num?)?.toDouble(),
      merchantCustomerReview: json['merchantCustomerReview'] as String?,
      merchantDriverRate: (json['merchantDriverRate'] as num?)?.toDouble(),
      merchantDriverReview: json['merchantDriverReview'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$BookingRatingToJson(BookingRating instance) =>
    <String, dynamic>{
      'customerRate': instance.customerRate,
      'customerReview': instance.customerReview,
      'driverRate': instance.driverRate,
      'driverReview': instance.driverReview,
      'customerMerchantRate': instance.customerMerchantRate,
      'customerMerchantReview': instance.customerMerchantReview,
      'driverMerchantRate': instance.driverMerchantRate,
      'driverMerchantReview': instance.driverMerchantReview,
      'merchantCustomerRate': instance.merchantCustomerRate,
      'merchantCustomerReview': instance.merchantCustomerReview,
      'merchantDriverRate': instance.merchantDriverRate,
      'merchantDriverReview': instance.merchantDriverReview,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
