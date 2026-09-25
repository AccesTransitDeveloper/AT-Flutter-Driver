import 'package:json_annotation/json_annotation.dart';

part 'pick_vehicle_request.g.dart';

@JsonSerializable()
class PickVehicleRequest {
  final String? scannedDriverId;

  PickVehicleRequest({
    this.scannedDriverId,
  });

  factory PickVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$PickVehicleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PickVehicleRequestToJson(this);
}
