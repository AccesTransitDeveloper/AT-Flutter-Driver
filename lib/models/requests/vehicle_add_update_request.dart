import 'package:json_annotation/json_annotation.dart';

part 'vehicle_add_update_request.g.dart';

@JsonSerializable(includeIfNull: false)
class VehicleAddUpdateRequest {
  final String? color;
  final String? name;
  final String? plateNo;
  final String? year;
  final String? countryId;
  final String? brandId;
  final String? modelId;
  final int? vehicleType;
  final List<String>? accessibilityIds;
  final List<String>? fallbackTypeIds;
  final String? vehicleLicense;

  VehicleAddUpdateRequest({
    this.color,
    this.name,
    this.plateNo,
    this.year,
    this.countryId,
    this.brandId,
    this.modelId,
    this.vehicleType,
    this.accessibilityIds,
    this.fallbackTypeIds,
    this.vehicleLicense,
  });

  factory VehicleAddUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$VehicleAddUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleAddUpdateRequestToJson(this);
}
