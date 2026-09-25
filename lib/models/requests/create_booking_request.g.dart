// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingRequest _$CreateBookingRequestFromJson(
  Map<String, dynamic> json,
) => CreateBookingRequest(
  bookingTime: (json['bookingTime'] as num?)?.toInt(),
  bookingType: (json['bookingType'] as num?)?.toInt(),
  isBookForOther: json['isBookForOther'] as bool?,
  customerDetail: json['customerDetail'] == null
      ? null
      : CreateBookingCustomerDetail.fromJson(
          json['customerDetail'] as Map<String, dynamic>,
        ),
  destinationAddresses: (json['destinationAddresses'] as List<dynamic>?)
      ?.map((e) => CreateBookingAddress.fromJson(e as Map<String, dynamic>))
      .toList(),
  pickupAddress: json['pickupAddress'] == null
      ? null
      : CreateBookingAddress.fromJson(
          json['pickupAddress'] as Map<String, dynamic>,
        ),
  paymentMode: (json['paymentMode'] as num?)?.toInt(),
  vehiclePriceId: json['vehiclePriceId'] as String?,
  isFixFare: json['isFixFare'] as bool? ?? false,
  isBidding: json['isBidding'] as bool? ?? false,
  bidPrice: (json['bidPrice'] as num?)?.toDouble() ?? 0,
  accessibilityIds:
      (json['accessibilityIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  promoCodeId: json['promoCodeId'] as String? ?? '',
);

Map<String, dynamic> _$CreateBookingRequestToJson(
  CreateBookingRequest instance,
) => <String, dynamic>{
  'bookingTime': ?instance.bookingTime,
  'bookingType': ?instance.bookingType,
  'isBookForOther': ?instance.isBookForOther,
  'customerDetail': ?instance.customerDetail,
  'destinationAddresses': ?instance.destinationAddresses,
  'pickupAddress': ?instance.pickupAddress,
  'paymentMode': ?instance.paymentMode,
  'vehiclePriceId': ?instance.vehiclePriceId,
  'isFixFare': instance.isFixFare,
  'isBidding': instance.isBidding,
  'bidPrice': instance.bidPrice,
  'accessibilityIds': instance.accessibilityIds,
  'promoCodeId': instance.promoCodeId,
};

CreateBookingCustomerDetail _$CreateBookingCustomerDetailFromJson(
  Map<String, dynamic> json,
) => CreateBookingCustomerDetail(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String?,
  countryPhoneCode: json['countryPhoneCode'] as String?,
);

Map<String, dynamic> _$CreateBookingCustomerDetailToJson(
  CreateBookingCustomerDetail instance,
) => <String, dynamic>{
  'firstName': ?instance.firstName,
  'lastName': ?instance.lastName,
  'phone': ?instance.phone,
  'countryPhoneCode': ?instance.countryPhoneCode,
};

CreateBookingAddress _$CreateBookingAddressFromJson(
  Map<String, dynamic> json,
) => CreateBookingAddress(
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  city: json['city'] as String?,
  country: json['country'] as String?,
  countryCode: json['countryCode'] as String?,
  placeId: json['placeId'] as String?,
);

Map<String, dynamic> _$CreateBookingAddressToJson(
  CreateBookingAddress instance,
) => <String, dynamic>{
  'address': ?instance.address,
  'latitude': ?instance.latitude,
  'longitude': ?instance.longitude,
  'city': ?instance.city,
  'country': ?instance.country,
  'countryCode': ?instance.countryCode,
  'placeId': ?instance.placeId,
};
