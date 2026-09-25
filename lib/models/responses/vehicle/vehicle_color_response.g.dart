// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_color_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleColorResponse _$VehicleColorResponseFromJson(
  Map<String, dynamic> json,
) => VehicleColorResponse(
  colors: (json['colors'] as List<dynamic>?)
      ?.map((e) => VehicleColor.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VehicleColorResponseToJson(
  VehicleColorResponse instance,
) => <String, dynamic>{'colors': instance.colors};

VehicleColor _$VehicleColorFromJson(Map<String, dynamic> json) => VehicleColor(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  isActive: json['isActive'] as bool?,
  uniqueId: (json['uniqueId'] as num?)?.toInt(),
);

Map<String, dynamic> _$VehicleColorToJson(VehicleColor instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
      'uniqueId': instance.uniqueId,
    };
