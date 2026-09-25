// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_bidding_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptBiddingRequest _$AcceptBiddingRequestFromJson(
  Map<String, dynamic> json,
) => AcceptBiddingRequest(
  bookingId: json['bookingId'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  driverId: json['driverId'] as String?,
);

Map<String, dynamic> _$AcceptBiddingRequestToJson(
  AcceptBiddingRequest instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'price': instance.price,
  'driverId': instance.driverId,
};
