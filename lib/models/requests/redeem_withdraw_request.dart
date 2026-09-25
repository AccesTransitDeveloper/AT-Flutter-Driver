import 'package:json_annotation/json_annotation.dart';

part 'redeem_withdraw_request.g.dart';

@JsonSerializable(includeIfNull: false)
class RedeemWithdrawRequest {
  final double? rewardPoint;

  RedeemWithdrawRequest({this.rewardPoint});

  factory RedeemWithdrawRequest.fromJson(Map<String, dynamic> json) =>
      _$RedeemWithdrawRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RedeemWithdrawRequestToJson(this);
}
