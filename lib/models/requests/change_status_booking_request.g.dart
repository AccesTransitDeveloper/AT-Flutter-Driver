// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_status_booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeStatusBookingRequest _$ChangeStatusBookingRequestFromJson(
  Map<String, dynamic> json,
) => ChangeStatusBookingRequest(
  bookingId: json['bookingId'] as String?,
  driverId: json['driverId'] as String?,
  status: (json['status'] as num?)?.toInt(),
  otp: json['otp'] as String?,
  stopAddress: json['stopAddress'] == null
      ? null
      : BookingAddress.fromJson(json['stopAddress'] as Map<String, dynamic>),
  businessType: (json['businessType'] as num?)?.toInt(),
  nextBookingId: json['nextBookingId'] as String?,
);

Map<String, dynamic> _$ChangeStatusBookingRequestToJson(
  ChangeStatusBookingRequest instance,
) => <String, dynamic>{
  'bookingId': ?instance.bookingId,
  'driverId': ?instance.driverId,
  'status': ?instance.status,
  'otp': ?instance.otp,
  'stopAddress': ?instance.stopAddress,
  'businessType': ?instance.businessType,
  'nextBookingId': ?instance.nextBookingId,
};
