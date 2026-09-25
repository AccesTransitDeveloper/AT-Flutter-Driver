import 'package:json_annotation/json_annotation.dart';

part 'address_response.g.dart';

@JsonSerializable()
class AddressResponse {
  final List<DriverSavedAddress>? addresses;

  AddressResponse({this.addresses});

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);
}

@JsonSerializable()
class DriverSavedAddress {
  @JsonKey(name: '_id')
  final String? id;
  final String? address;
  final String? title;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? placeId;
  final bool? isAddressSelected;

  DriverSavedAddress({
    this.id,
    this.address,
    this.title,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.countryCode,
    this.placeId,
    this.isAddressSelected,
  });

  factory DriverSavedAddress.fromJson(Map<String, dynamic> json) =>
      _$DriverSavedAddressFromJson(json);

  Map<String, dynamic> toJson() => _$DriverSavedAddressToJson(this);
}
