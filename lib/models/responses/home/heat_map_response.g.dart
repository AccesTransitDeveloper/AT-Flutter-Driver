// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat_map_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeatMapResponse _$HeatMapResponseFromJson(Map<String, dynamic> json) =>
    HeatMapResponse(
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => HeatMapLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      mapZoomLevel: (json['mapZoomLevel'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HeatMapResponseToJson(HeatMapResponse instance) =>
    <String, dynamic>{
      'locations': instance.locations,
      'mapZoomLevel': instance.mapZoomLevel,
    };

HeatMapLocation _$HeatMapLocationFromJson(Map<String, dynamic> json) =>
    HeatMapLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$HeatMapLocationToJson(HeatMapLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'weight': instance.weight,
    };
