import 'package:json_annotation/json_annotation.dart';

import 'vehicle_list_response.dart';

part 'vehicle_details_response.g.dart';

@JsonSerializable()
class VehicleDetailsResponse {
  final Vehicle? vehicle;

  VehicleDetailsResponse({
    this.vehicle,
  });

  factory VehicleDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleDetailsResponseToJson(this);
}
