// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelBookingRequest _$CancelBookingRequestFromJson(
  Map<String, dynamic> json,
) => CancelBookingRequest(
  bookingId: json['bookingId'] as String?,
  cancellationReason: json['cancellationReason'] as String?,
);

Map<String, dynamic> _$CancelBookingRequestToJson(
  CancelBookingRequest instance,
) => <String, dynamic>{
  'bookingId': ?instance.bookingId,
  'cancellationReason': ?instance.cancellationReason,
};
