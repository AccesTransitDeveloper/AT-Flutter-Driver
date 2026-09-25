// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_booking_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketBookingResponse _$SocketBookingResponseFromJson(
  Map<String, dynamic> json,
) => SocketBookingResponse(
  bookingId: json['bookingId'] as String?,
  driverId: json['driverId'] as String?,
  status: (json['status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  businessType: (json['businessType'] as num?)?.toInt(),
  bookingType: (json['bookingType'] as num?)?.toInt(),
  cancellationReason: json['cancellationReason'] as String?,
  cancelledBy: (json['cancelledBy'] as num?)?.toInt(),
);

Map<String, dynamic> _$SocketBookingResponseToJson(
  SocketBookingResponse instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'driverId': instance.driverId,
  'status': instance.status,
  'type': instance.type,
  'businessType': instance.businessType,
  'bookingType': instance.bookingType,
  'cancellationReason': instance.cancellationReason,
  'cancelledBy': instance.cancelledBy,
};
