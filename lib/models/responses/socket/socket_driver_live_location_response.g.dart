// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_driver_live_location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketDriverLiveLocationResponse _$SocketDriverLiveLocationResponseFromJson(
  Map<String, dynamic> json,
) => SocketDriverLiveLocationResponse(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  time: (json['time'] as num?)?.toInt(),
  speed: (json['speed'] as num?)?.toDouble(),
  bearing: (json['bearing'] as num?)?.toDouble(),
  locations: (json['locations'] as List<dynamic>?)
      ?.map((e) => SocketLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  distanceList: (json['distanceList'] as List<dynamic>?)
      ?.map((e) => DistanceListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  zoneId: json['zoneId'] as String?,
  zoneName: json['zoneName'] as String?,
  zoneQueueNumber: (json['zoneQueueNumber'] as num?)?.toInt(),
);

Map<String, dynamic> _$SocketDriverLiveLocationResponseToJson(
  SocketDriverLiveLocationResponse instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'time': instance.time,
  'speed': instance.speed,
  'bearing': instance.bearing,
  'locations': instance.locations,
  'distanceList': instance.distanceList,
  'zoneId': instance.zoneId,
  'zoneName': instance.zoneName,
  'zoneQueueNumber': instance.zoneQueueNumber,
};

DistanceListItem _$DistanceListItemFromJson(Map<String, dynamic> json) =>
    DistanceListItem(
      bookingId: json['bookingId'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      trafficTime: (json['trafficTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DistanceListItemToJson(DistanceListItem instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'distance': instance.distance,
      'trafficTime': instance.trafficTime,
    };
