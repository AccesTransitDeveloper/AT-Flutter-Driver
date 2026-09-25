import 'package:json_annotation/json_annotation.dart';

import '../responses/booking/booking_detail_response.dart';

part 'change_status_booking_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ChangeStatusBookingRequest {
  final String? bookingId;
  final String? driverId;
  final int? status;
  final String? otp;
  final BookingAddress? stopAddress;
  final int? businessType;
  final String? nextBookingId;

  ChangeStatusBookingRequest({
    this.bookingId,
    this.driverId,
    this.status,
    this.otp,
    this.stopAddress,
    this.businessType,
    this.nextBookingId,
  });

  factory ChangeStatusBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangeStatusBookingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeStatusBookingRequestToJson(this);
}
