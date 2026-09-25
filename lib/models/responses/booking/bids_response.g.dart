// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bids_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BidsResponse _$BidsResponseFromJson(Map<String, dynamic> json) => BidsResponse(
  bookings: (json['bookings'] as List<dynamic>?)
      ?.map((e) => BiddingRequestItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BidsResponseToJson(BidsResponse instance) =>
    <String, dynamic>{'bookings': instance.bookings};

BiddingRequestItem _$BiddingRequestItemFromJson(
  Map<String, dynamic> json,
) => BiddingRequestItem(
  id: json['_id'] as String?,
  bookingType: (json['bookingType'] as num?)?.toInt(),
  bookingTime: (json['bookingTime'] as num?)?.toInt(),
  timezone: json['timezone'] as String?,
  biddingDetail: json['biddingDetail'] == null
      ? null
      : BiddingDetail.fromJson(json['biddingDetail'] as Map<String, dynamic>),
  uniqueId: json['uniqueId'] as String?,
  customerDetail: json['customerDetail'] == null
      ? null
      : CustomerDetail.fromJson(json['customerDetail'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BiddingRequestItemToJson(BiddingRequestItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'bookingType': instance.bookingType,
      'bookingTime': instance.bookingTime,
      'timezone': instance.timezone,
      'biddingDetail': instance.biddingDetail,
      'uniqueId': instance.uniqueId,
      'customerDetail': instance.customerDetail,
    };
