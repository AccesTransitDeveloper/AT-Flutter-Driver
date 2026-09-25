import 'package:json_annotation/json_annotation.dart';
import '../booking/booking_detail_response.dart';

part 'marketplace_response.g.dart';

@JsonSerializable()
class MarketplaceResponse {
  final int? dataCount;
  final List<Booking>? bookings;

  MarketplaceResponse({this.dataCount, this.bookings});

  factory MarketplaceResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceResponseToJson(this);
}
