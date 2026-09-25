import 'package:json_annotation/json_annotation.dart';

import 'booking_detail_response.dart';

part 'bids_response.g.dart';

@JsonSerializable()
class BidsResponse {
  final List<BiddingRequestItem>? bookings;

  BidsResponse({this.bookings});

  factory BidsResponse.fromJson(Map<String, dynamic> json) =>
      _$BidsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BidsResponseToJson(this);
}

@JsonSerializable()
class BiddingRequestItem {
  @JsonKey(name: '_id')
  final String? id;
  final int? bookingType;
  final int? bookingTime;
  final String? timezone;
  final BiddingDetail? biddingDetail;
  final String? uniqueId;
  final CustomerDetail? customerDetail;

  BiddingRequestItem({
    this.id,
    this.bookingType,
    this.bookingTime,
    this.timezone,
    this.biddingDetail,
    this.uniqueId,
    this.customerDetail,
  });

  factory BiddingRequestItem.fromJson(Map<String, dynamic> json) =>
      _$BiddingRequestItemFromJson(json);

  Map<String, dynamic> toJson() => _$BiddingRequestItemToJson(this);
}
