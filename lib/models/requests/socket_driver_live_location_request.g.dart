// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_driver_live_location_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketDriverLiveLocationRequest _$SocketDriverLiveLocationRequestFromJson(
  Map<String, dynamic> json,
) => SocketDriverLiveLocationRequest(
  locations: (json['locations'] as List<dynamic>?)
      ?.map((e) => SocketLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SocketDriverLiveLocationRequestToJson(
  SocketDriverLiveLocationRequest instance,
) => <String, dynamic>{
  'locations': ?instance.locations?.map((e) => e.toJson()).toList(),
};

SocketLocation _$SocketLocationFromJson(Map<String, dynamic> json) =>
    SocketLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      time: (json['time'] as num?)?.toInt(),
      speed: (json['speed'] as num?)?.toDouble(),
      bearing: (json['bearing'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SocketLocationToJson(SocketLocation instance) =>
    <String, dynamic>{
      'latitude': ?instance.latitude,
      'longitude': ?instance.longitude,
      'time': ?instance.time,
      'speed': ?instance.speed,
      'bearing': ?instance.bearing,
    };
