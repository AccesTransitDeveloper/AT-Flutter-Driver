// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceResponse _$MarketplaceResponseFromJson(Map<String, dynamic> json) =>
    MarketplaceResponse(
      dataCount: (json['dataCount'] as num?)?.toInt(),
      bookings: (json['bookings'] as List<dynamic>?)
          ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarketplaceResponseToJson(
  MarketplaceResponse instance,
) => <String, dynamic>{
  'dataCount': instance.dataCount,
  'bookings': instance.bookings,
};
