import 'package:json_annotation/json_annotation.dart';

part 'add_address_request.g.dart';

@JsonSerializable()
class AddAddressRequest {
  final int? addressType;
  final String? title;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? countryCode;
  final String? country;
  final String? postalCode;
  final String? placeId;

  AddAddressRequest({
    this.addressType,
    this.title,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.countryCode,
    this.country,
    this.postalCode,
    this.placeId,
  });

  factory AddAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddAddressRequestToJson(this);
}
