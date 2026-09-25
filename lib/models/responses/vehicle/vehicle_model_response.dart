import 'package:json_annotation/json_annotation.dart';

import 'vehicle_list_response.dart';

part 'vehicle_model_response.g.dart';

@JsonSerializable()
class VehicleModelListResponse {
  final List<VehicleModel>? models;

  VehicleModelListResponse({
    this.models,
  });

  factory VehicleModelListResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelListResponseToJson(this);
}
