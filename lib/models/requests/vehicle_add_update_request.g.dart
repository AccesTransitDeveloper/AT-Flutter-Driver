// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_add_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleAddUpdateRequest _$VehicleAddUpdateRequestFromJson(
  Map<String, dynamic> json,
) => VehicleAddUpdateRequest(
  color: json['color'] as String?,
  name: json['name'] as String?,
  plateNo: json['plateNo'] as String?,
  year: json['year'] as String?,
  countryId: json['countryId'] as String?,
  brandId: json['brandId'] as String?,
  modelId: json['modelId'] as String?,
  vehicleType: (json['vehicleType'] as num?)?.toInt(),
  accessibilityIds: (json['accessibilityIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  fallbackTypeIds: (json['fallbackTypeIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  vehicleLicense: json['vehicleLicense'] as String?,
);

Map<String, dynamic> _$VehicleAddUpdateRequestToJson(
  VehicleAddUpdateRequest instance,
) => <String, dynamic>{
  'color': ?instance.color,
  'name': ?instance.name,
  'plateNo': ?instance.plateNo,
  'year': ?instance.year,
  'countryId': ?instance.countryId,
  'brandId': ?instance.brandId,
  'modelId': ?instance.modelId,
  'vehicleType': ?instance.vehicleType,
  'accessibilityIds': ?instance.accessibilityIds,
  'fallbackTypeIds': ?instance.fallbackTypeIds,
  'vehicleLicense': ?instance.vehicleLicense,
};
