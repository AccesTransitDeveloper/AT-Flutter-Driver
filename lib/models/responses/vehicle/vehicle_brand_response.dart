import 'package:json_annotation/json_annotation.dart';

import 'vehicle_list_response.dart';

part 'vehicle_brand_response.g.dart';

@JsonSerializable()
class VehicleBrandResponse {
  final List<Brand>? brands;

  VehicleBrandResponse({
    this.brands,
  });

  factory VehicleBrandResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleBrandResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleBrandResponseToJson(this);
}
