import 'package:json_annotation/json_annotation.dart';

part 'business_type_request.g.dart';

@JsonSerializable()
class BusinessTypeRequest {
  final BusinessTypeAddress? address;

  BusinessTypeRequest({this.address});

  factory BusinessTypeRequest.fromJson(Map<String, dynamic> json) =>
      _$BusinessTypeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessTypeRequestToJson(this);
}

@JsonSerializable()
class BusinessTypeAddress {
  final double? latitude;
  final double? longitude;
  final String? countryCode;

  BusinessTypeAddress({
    this.latitude,
    this.longitude,
    this.countryCode,
  });

  factory BusinessTypeAddress.fromJson(Map<String, dynamic> json) =>
      _$BusinessTypeAddressFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessTypeAddressToJson(this);
}
