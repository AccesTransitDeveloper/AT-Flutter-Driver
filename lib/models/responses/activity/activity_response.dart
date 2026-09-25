import 'package:json_annotation/json_annotation.dart';
import '../booking/booking_detail_response.dart';

part 'activity_response.g.dart';

/// Response for upcoming/active bookings (main API: GET booking)
@JsonSerializable()
class MyBookingListResponse {
  final int? dataCount;
  final List<Booking>? bookings;

  MyBookingListResponse({this.dataCount, this.bookings});

  factory MyBookingListResponse.fromJson(Map<String, dynamic> json) =>
      _$MyBookingListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyBookingListResponseToJson(this);
}

/// Response for past booking history (history API: GET booking_history)
@JsonSerializable()
class TripBookingHistoryResponse {
  final int? dataCount;
  final List<HistoryBooking>? bookings;

  TripBookingHistoryResponse({this.dataCount, this.bookings});

  factory TripBookingHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$TripBookingHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TripBookingHistoryResponseToJson(this);
}

@JsonSerializable()
class HistoryBooking {
  @JsonKey(name: '_id')
  final String? id;
  final String? uniqueId;
  final int? status;
  final String? countryId;
  final String? vehicleTypeId;
  final int? bookingTime;
  final int? completedAt;
  final String? timezone;
  final String? currencySign;
  final double? total;
  final int? setCurrencySign;
  final int? decimalPointValue;
  final VehicleType? vehicleType;
  final String? bookingPrice;
  final String? completedTimeValue;
  final String? deliverIn;
  final int? businessType;
  final int? bookingType;
  final bool? isBookForOther;

  HistoryBooking({
    this.id,
    this.uniqueId,
    this.status,
    this.countryId,
    this.vehicleTypeId,
    this.bookingTime,
    this.completedAt,
    this.timezone,
    this.currencySign,
    this.total,
    this.setCurrencySign,
    this.decimalPointValue,
    this.vehicleType,
    this.bookingPrice,
    this.completedTimeValue,
    this.deliverIn,
    this.businessType,
    this.bookingType,
    this.isBookForOther,
  });

  factory HistoryBooking.fromJson(Map<String, dynamic> json) =>
      _$HistoryBookingFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryBookingToJson(this);
}
