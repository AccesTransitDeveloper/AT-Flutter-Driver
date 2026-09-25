import 'package:json_annotation/json_annotation.dart';

part 'socket_booking_response.g.dart';

@JsonSerializable()
class SocketBookingResponse {
  final String? bookingId;
  final String? driverId;
  final int? status;
  final int? type;
  final int? businessType;
  final int? bookingType;
  final String? cancellationReason;
  final int? cancelledBy;

  SocketBookingResponse({
    this.bookingId,
    this.driverId,
    this.status,
    this.type,
    this.businessType,
    this.bookingType,
    this.cancellationReason,
    this.cancelledBy,
  });

  factory SocketBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$SocketBookingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SocketBookingResponseToJson(this);
}
