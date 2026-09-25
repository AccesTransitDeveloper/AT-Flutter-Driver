import 'package:json_annotation/json_annotation.dart';

part 'socket_driver_live_location_request.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SocketDriverLiveLocationRequest {
  final List<SocketLocation>? locations;

  SocketDriverLiveLocationRequest({this.locations});

  factory SocketDriverLiveLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$SocketDriverLiveLocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocketDriverLiveLocationRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class SocketLocation {
  final double? latitude;
  final double? longitude;
  final int? time;
  final double? speed;
  final double? bearing;

  SocketLocation({
    this.latitude,
    this.longitude,
    this.time,
    this.speed,
    this.bearing,
  });

  factory SocketLocation.fromJson(Map<String, dynamic> json) =>
      _$SocketLocationFromJson(json);

  Map<String, dynamic> toJson() => _$SocketLocationToJson(this);
}
