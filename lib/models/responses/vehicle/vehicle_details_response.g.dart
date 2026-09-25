// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleDetailsResponse _$VehicleDetailsResponseFromJson(
  Map<String, dynamic> json,
) => VehicleDetailsResponse(
  vehicle: json['vehicle'] == null
      ? null
      : Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VehicleDetailsResponseToJson(
  VehicleDetailsResponse instance,
) => <String, dynamic>{'vehicle': instance.vehicle};
