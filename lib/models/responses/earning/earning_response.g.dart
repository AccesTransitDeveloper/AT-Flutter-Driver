// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earning_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningResponse _$EarningResponseFromJson(Map<String, dynamic> json) =>
    EarningResponse(
      earningDetail: json['earningDetail'] == null
          ? null
          : EarningDetail.fromJson(
              json['earningDetail'] as Map<String, dynamic>,
            ),
      dailyEarningDetail: (json['dailyEarningDetail'] as List<dynamic>?)
          ?.map((e) => EarningDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookings: (json['bookings'] as List<dynamic>?)
          ?.map((e) => EarningBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      driverAnalytics: json['driverAnalytics'] == null
          ? null
          : DriverAnalytics.fromJson(
              json['driverAnalytics'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EarningResponseToJson(EarningResponse instance) =>
    <String, dynamic>{
      'earningDetail': instance.earningDetail,
      'dailyEarningDetail': instance.dailyEarningDetail,
      'bookings': instance.bookings,
      'driverAnalytics': instance.driverAnalytics,
    };

EarningDetail _$EarningDetailFromJson(Map<String, dynamic> json) =>
    EarningDetail(
      id: json['_id'] as String?,
      totalBookings: (json['totalBookings'] as num?)?.toInt(),
      completedBookings: (json['completedBookings'] as num?)?.toInt(),
      cancelledBookings: (json['cancelledBookings'] as num?)?.toInt(),
      driverProfit: (json['driverProfit'] as num?)?.toDouble(),
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble(),
      netEarning: (json['netEarning'] as num?)?.toDouble(),
      penalty: (json['penalty'] as num?)?.toDouble(),
      incentive: (json['incentive'] as num?)?.toDouble(),
      cashEarning: (json['cashEarning'] as num?)?.toDouble(),
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EarningDetailToJson(EarningDetail instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'totalBookings': instance.totalBookings,
      'completedBookings': instance.completedBookings,
      'cancelledBookings': instance.cancelledBookings,
      'driverProfit': instance.driverProfit,
      'cashOnHand': instance.cashOnHand,
      'netEarning': instance.netEarning,
      'penalty': instance.penalty,
      'incentive': instance.incentive,
      'cashEarning': instance.cashEarning,
      'timestamp': instance.timestamp,
    };

DriverAnalytics _$DriverAnalyticsFromJson(Map<String, dynamic> json) =>
    DriverAnalytics(
      totalOnlineTimeSec: (json['totalOnlineTimeSec'] as num?)?.toDouble(),
      accepted: (json['accepted'] as num?)?.toInt(),
      cancelled: (json['cancelled'] as num?)?.toInt(),
      cancelledByOther: (json['cancelledByOther'] as num?)?.toInt(),
      completed: (json['completed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DriverAnalyticsToJson(DriverAnalytics instance) =>
    <String, dynamic>{
      'totalOnlineTimeSec': instance.totalOnlineTimeSec,
      'accepted': instance.accepted,
      'cancelled': instance.cancelled,
      'cancelledByOther': instance.cancelledByOther,
      'completed': instance.completed,
    };

EarningBooking _$EarningBookingFromJson(Map<String, dynamic> json) =>
    EarningBooking(
      id: json['_id'] as String?,
      bookingUniqueId: json['bookingUniqueId'] as String?,
      driverProfit: (json['driverProfit'] as num?)?.toDouble(),
      paymentMode: (json['paymentMode'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      charges: (json['charges'] as List<dynamic>?)
          ?.map((e) => EarningCharge.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalPrices: (json['additionalPrices'] as List<dynamic>?)
          ?.map((e) => EarningCharge.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerDetail: json['customerDetail'] == null
          ? null
          : EarningCustomerDetail.fromJson(
              json['customerDetail'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EarningBookingToJson(EarningBooking instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'bookingUniqueId': instance.bookingUniqueId,
      'driverProfit': instance.driverProfit,
      'paymentMode': instance.paymentMode,
      'status': instance.status,
      'charges': instance.charges,
      'additionalPrices': instance.additionalPrices,
      'customerDetail': instance.customerDetail,
    };

EarningCharge _$EarningChargeFromJson(Map<String, dynamic> json) =>
    EarningCharge(
      title: json['title'] as String?,
      driverProfit: (json['driverProfit'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EarningChargeToJson(EarningCharge instance) =>
    <String, dynamic>{
      'title': instance.title,
      'driverProfit': instance.driverProfit,
    };

EarningCustomerDetail _$EarningCustomerDetailFromJson(
  Map<String, dynamic> json,
) => EarningCustomerDetail(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
);

Map<String, dynamic> _$EarningCustomerDetailToJson(
  EarningCustomerDetail instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};
