import 'package:json_annotation/json_annotation.dart';

part 'create_booking_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateBookingRequest {
  final int? bookingTime;
  final int? bookingType;
  final bool? isBookForOther;
  final CreateBookingCustomerDetail? customerDetail;
  final List<CreateBookingAddress>? destinationAddresses;
  final CreateBookingAddress? pickupAddress;
  final int? paymentMode;
  final String? vehiclePriceId;
  final bool isFixFare;
  final bool isBidding;
  final double bidPrice;
  final List<String> accessibilityIds;
  final String promoCodeId;

  CreateBookingRequest({
    this.bookingTime,
    this.bookingType,
    this.isBookForOther,
    this.customerDetail,
    this.destinationAddresses,
    this.pickupAddress,
    this.paymentMode,
    this.vehiclePriceId,
    this.isFixFare = false,
    this.isBidding = false,
    this.bidPrice = 0,
    this.accessibilityIds = const [],
    this.promoCodeId = '',
  });

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class CreateBookingCustomerDetail {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? countryPhoneCode;

  CreateBookingCustomerDetail({
    this.firstName,
    this.lastName,
    this.phone,
    this.countryPhoneCode,
  });

  factory CreateBookingCustomerDetail.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingCustomerDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingCustomerDetailToJson(this);
}

@JsonSerializable(includeIfNull: false)
class CreateBookingAddress {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? placeId;

  CreateBookingAddress({
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.countryCode,
    this.placeId,
  });

  factory CreateBookingAddress.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingAddressFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingAddressToJson(this);
}
