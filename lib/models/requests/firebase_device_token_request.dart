import 'package:json_annotation/json_annotation.dart';

part 'firebase_device_token_request.g.dart';

@JsonSerializable()
class FirebaseDeviceTokenRequest {
  final String? deviceToken;

  FirebaseDeviceTokenRequest({this.deviceToken});

  factory FirebaseDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$FirebaseDeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseDeviceTokenRequestToJson(this);
}
