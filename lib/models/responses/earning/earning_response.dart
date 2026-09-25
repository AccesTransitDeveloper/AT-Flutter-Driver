import 'package:json_annotation/json_annotation.dart';

part 'earning_response.g.dart';

@JsonSerializable()
class EarningResponse {
  final EarningDetail? earningDetail;
  final List<EarningDetail>? dailyEarningDetail;
  final List<EarningBooking>? bookings;
  final DriverAnalytics? driverAnalytics;

  EarningResponse({
    this.earningDetail,
    this.dailyEarningDetail,
    this.bookings,
    this.driverAnalytics,
  });

  factory EarningResponse.fromJson(Map<String, dynamic> json) =>
      _$EarningResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EarningResponseToJson(this);
}

@JsonSerializable()
class EarningDetail {
  @JsonKey(name: '_id')
  final String? id;
  final int? totalBookings;
  final int? completedBookings;
  final int? cancelledBookings;
  final double? driverProfit;
  final double? cashOnHand;
  final double? netEarning;
  final double? penalty;
  final double? incentive;
  final double? cashEarning;
  final int? timestamp;

  EarningDetail({
    this.id,
    this.totalBookings,
    this.completedBookings,
    this.cancelledBookings,
    this.driverProfit,
    this.cashOnHand,
    this.netEarning,
    this.penalty,
    this.incentive,
    this.cashEarning,
    this.timestamp,
  });

  factory EarningDetail.fromJson(Map<String, dynamic> json) =>
      _$EarningDetailFromJson(json);

  Map<String, dynamic> toJson() => _$EarningDetailToJson(this);
}

@JsonSerializable()
class DriverAnalytics {
  final double? totalOnlineTimeSec;
  final int? accepted;
  final int? cancelled;
  final int? cancelledByOther;
  final int? completed;

  DriverAnalytics({
    this.totalOnlineTimeSec,
    this.accepted,
    this.cancelled,
    this.cancelledByOther,
    this.completed,
  });

  factory DriverAnalytics.fromJson(Map<String, dynamic> json) =>
      _$DriverAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$DriverAnalyticsToJson(this);
}

@JsonSerializable()
class EarningBooking {
  @JsonKey(name: '_id')
  final String? id;
  final String? bookingUniqueId;
  final double? driverProfit;
  final int? paymentMode;
  final int? status;
  final List<EarningCharge>? charges;
  final List<EarningCharge>? additionalPrices;
  final EarningCustomerDetail? customerDetail;

  EarningBooking({
    this.id,
    this.bookingUniqueId,
    this.driverProfit,
    this.paymentMode,
    this.status,
    this.charges,
    this.additionalPrices,
    this.customerDetail,
  });

  factory EarningBooking.fromJson(Map<String, dynamic> json) =>
      _$EarningBookingFromJson(json);

  Map<String, dynamic> toJson() => _$EarningBookingToJson(this);
}

@JsonSerializable()
class EarningCharge {
  final String? title;
  final double? driverProfit;

  EarningCharge({this.title, this.driverProfit});

  factory EarningCharge.fromJson(Map<String, dynamic> json) =>
      _$EarningChargeFromJson(json);

  Map<String, dynamic> toJson() => _$EarningChargeToJson(this);
}

@JsonSerializable()
class EarningCustomerDetail {
  final String? firstName;
  final String? lastName;

  EarningCustomerDetail({this.firstName, this.lastName});

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory EarningCustomerDetail.fromJson(Map<String, dynamic> json) =>
      _$EarningCustomerDetailFromJson(json);

  Map<String, dynamic> toJson() => _$EarningCustomerDetailToJson(this);
}
