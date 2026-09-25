import 'package:json_annotation/json_annotation.dart';

part 'accept_bidding_request.g.dart';

@JsonSerializable()
class AcceptBiddingRequest {
  final String? bookingId;
  final double? price;
  final String? driverId;

  AcceptBiddingRequest({this.bookingId, this.price, this.driverId});

  factory AcceptBiddingRequest.fromJson(Map<String, dynamic> json) =>
      _$AcceptBiddingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptBiddingRequestToJson(this);
}
