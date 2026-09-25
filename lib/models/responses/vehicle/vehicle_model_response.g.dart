// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModelListResponse _$VehicleModelListResponseFromJson(
  Map<String, dynamic> json,
) => VehicleModelListResponse(
  models: (json['models'] as List<dynamic>?)
      ?.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VehicleModelListResponseToJson(
  VehicleModelListResponse instance,
) => <String, dynamic>{'models': instance.models};
