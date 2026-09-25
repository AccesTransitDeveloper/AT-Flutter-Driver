// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_reject_booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptRejectBookingRequest _$AcceptRejectBookingRequestFromJson(
  Map<String, dynamic> json,
) => AcceptRejectBookingRequest(
  bookingId: json['bookingId'] as String?,
  driverId: json['driverId'] as String?,
);

Map<String, dynamic> _$AcceptRejectBookingRequestToJson(
  AcceptRejectBookingRequest instance,
) => <String, dynamic>{
  'bookingId': ?instance.bookingId,
  'driverId': ?instance.driverId,
};
