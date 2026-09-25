// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnlineRequest _$OnlineRequestFromJson(Map<String, dynamic> json) =>
    OnlineRequest(
      businessTypes: (json['businessTypes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      priceModes: (json['priceModes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      businessAddress: json['businessAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAllowPickupFromHome: json['isAllowPickupFromHome'] as bool?,
      isAllowDropAtHome: json['isAllowDropAtHome'] as bool?,
      businessLocation: json['businessLocation'] == null
          ? null
          : OnlineLocationRequest.fromJson(
              json['businessLocation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OnlineRequestToJson(OnlineRequest instance) =>
    <String, dynamic>{
      'businessTypes': instance.businessTypes,
      'priceModes': instance.priceModes,
      'businessAddress': instance.businessAddress,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isAllowPickupFromHome': instance.isAllowPickupFromHome,
      'isAllowDropAtHome': instance.isAllowDropAtHome,
      'businessLocation': instance.businessLocation,
    };

OnlineLocationRequest _$OnlineLocationRequestFromJson(
  Map<String, dynamic> json,
) => OnlineLocationRequest(
  type: json['type'] as String?,
  coordinates:
      (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [],
);

Map<String, dynamic> _$OnlineLocationRequestToJson(
  OnlineLocationRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'coordinates': instance.coordinates,
};
