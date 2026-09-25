import 'package:json_annotation/json_annotation.dart';

import '../../requests/socket_driver_live_location_request.dart';

part 'socket_driver_live_location_response.g.dart';

@JsonSerializable()
class SocketDriverLiveLocationResponse {
  final double? latitude;
  final double? longitude;
  final int? time;
  final double? speed;
  final double? bearing;
  final List<SocketLocation>? locations;
  final List<DistanceListItem>? distanceList;
  final String? zoneId;
  final String? zoneName;
  final int? zoneQueueNumber;

  SocketDriverLiveLocationResponse({
    this.latitude,
    this.longitude,
    this.time,
    this.speed,
    this.bearing,
    this.locations,
    this.distanceList,
    this.zoneId,
    this.zoneName,
    this.zoneQueueNumber,
  });

  factory SocketDriverLiveLocationResponse.fromJson(
          Map<String, dynamic> json) =>
      _$SocketDriverLiveLocationResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SocketDriverLiveLocationResponseToJson(this);
}

@JsonSerializable()
class DistanceListItem {
  final String? bookingId;
  final double? distance;
  final int? trafficTime;

  DistanceListItem({
    this.bookingId,
    this.distance,
    this.trafficTime,
  });

  factory DistanceListItem.fromJson(Map<String, dynamic> json) =>
      _$DistanceListItemFromJson(json);

  Map<String, dynamic> toJson() => _$DistanceListItemToJson(this);
}
