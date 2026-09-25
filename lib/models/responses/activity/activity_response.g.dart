// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyBookingListResponse _$MyBookingListResponseFromJson(
  Map<String, dynamic> json,
) => MyBookingListResponse(
  dataCount: (json['dataCount'] as num?)?.toInt(),
  bookings: (json['bookings'] as List<dynamic>?)
      ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MyBookingListResponseToJson(
  MyBookingListResponse instance,
) => <String, dynamic>{
  'dataCount': instance.dataCount,
  'bookings': instance.bookings,
};

TripBookingHistoryResponse _$TripBookingHistoryResponseFromJson(
  Map<String, dynamic> json,
) => TripBookingHistoryResponse(
  dataCount: (json['dataCount'] as num?)?.toInt(),
  bookings: (json['bookings'] as List<dynamic>?)
      ?.map((e) => HistoryBooking.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripBookingHistoryResponseToJson(
  TripBookingHistoryResponse instance,
) => <String, dynamic>{
  'dataCount': instance.dataCount,
  'bookings': instance.bookings,
};

HistoryBooking _$HistoryBookingFromJson(Map<String, dynamic> json) =>
    HistoryBooking(
      id: json['_id'] as String?,
      uniqueId: json['uniqueId'] as String?,
      status: (json['status'] as num?)?.toInt(),
      countryId: json['countryId'] as String?,
      vehicleTypeId: json['vehicleTypeId'] as String?,
      bookingTime: (json['bookingTime'] as num?)?.toInt(),
      completedAt: (json['completedAt'] as num?)?.toInt(),
      timezone: json['timezone'] as String?,
      currencySign: json['currencySign'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      setCurrencySign: (json['setCurrencySign'] as num?)?.toInt(),
      decimalPointValue: (json['decimalPointValue'] as num?)?.toInt(),
      vehicleType: json['vehicleType'] == null
          ? null
          : VehicleType.fromJson(json['vehicleType'] as Map<String, dynamic>),
      bookingPrice: json['bookingPrice'] as String?,
      completedTimeValue: json['completedTimeValue'] as String?,
      deliverIn: json['deliverIn'] as String?,
      businessType: (json['businessType'] as num?)?.toInt(),
      bookingType: (json['bookingType'] as num?)?.toInt(),
      isBookForOther: json['isBookForOther'] as bool?,
    );

Map<String, dynamic> _$HistoryBookingToJson(HistoryBooking instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'uniqueId': instance.uniqueId,
      'status': instance.status,
      'countryId': instance.countryId,
      'vehicleTypeId': instance.vehicleTypeId,
      'bookingTime': instance.bookingTime,
      'completedAt': instance.completedAt,
      'timezone': instance.timezone,
      'currencySign': instance.currencySign,
      'total': instance.total,
      'setCurrencySign': instance.setCurrencySign,
      'decimalPointValue': instance.decimalPointValue,
      'vehicleType': instance.vehicleType,
      'bookingPrice': instance.bookingPrice,
      'completedTimeValue': instance.completedTimeValue,
      'deliverIn': instance.deliverIn,
      'businessType': instance.businessType,
      'bookingType': instance.bookingType,
      'isBookForOther': instance.isBookForOther,
    };
