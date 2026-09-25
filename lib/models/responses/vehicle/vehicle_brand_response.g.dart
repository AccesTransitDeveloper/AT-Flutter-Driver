// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_brand_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleBrandResponse _$VehicleBrandResponseFromJson(
  Map<String, dynamic> json,
) => VehicleBrandResponse(
  brands: (json['brands'] as List<dynamic>?)
      ?.map((e) => Brand.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VehicleBrandResponseToJson(
  VehicleBrandResponse instance,
) => <String, dynamic>{'brands': instance.brands};
