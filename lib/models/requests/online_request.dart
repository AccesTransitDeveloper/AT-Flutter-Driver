import 'package:json_annotation/json_annotation.dart';

part 'online_request.g.dart';

@JsonSerializable()
class OnlineRequest {
  final List<int>? businessTypes;
  final List<int>? priceModes;
  final String? businessAddress;
  final double? latitude;
  final double? longitude;
  final bool? isAllowPickupFromHome;
  final bool? isAllowDropAtHome;
  final OnlineLocationRequest? businessLocation;

  OnlineRequest({
    this.businessTypes,
    this.priceModes,
    this.businessAddress,
    this.latitude,
    this.longitude,
    this.isAllowPickupFromHome,
    this.isAllowDropAtHome,
    this.businessLocation,
  });

  factory OnlineRequest.fromJson(Map<String, dynamic> json) =>
      _$OnlineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineRequestToJson(this);
}

@JsonSerializable()
class OnlineLocationRequest {
  final String? type;
  final List<double> coordinates;

  OnlineLocationRequest({
    this.type,
    this.coordinates = const [],
  });

  factory OnlineLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$OnlineLocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineLocationRequestToJson(this);
}
