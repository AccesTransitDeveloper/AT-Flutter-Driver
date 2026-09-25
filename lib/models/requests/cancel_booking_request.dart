import 'package:json_annotation/json_annotation.dart';

part 'cancel_booking_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CancelBookingRequest {
  final String? bookingId;
  final String? cancellationReason;

  CancelBookingRequest({this.bookingId, this.cancellationReason});

  factory CancelBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelBookingRequestToJson(this);
}
