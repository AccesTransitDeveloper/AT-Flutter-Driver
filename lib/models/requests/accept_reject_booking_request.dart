import 'package:json_annotation/json_annotation.dart';

part 'accept_reject_booking_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AcceptRejectBookingRequest {
  final String? bookingId;
  final String? driverId;

  AcceptRejectBookingRequest({this.bookingId, this.driverId});

  factory AcceptRejectBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$AcceptRejectBookingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptRejectBookingRequestToJson(this);
}
