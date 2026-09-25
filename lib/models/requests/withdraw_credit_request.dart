import 'package:json_annotation/json_annotation.dart';

part 'withdraw_credit_request.g.dart';

@JsonSerializable()
class WithdrawCreditRequest {
  final double? amount;

  WithdrawCreditRequest({this.amount});

  factory WithdrawCreditRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawCreditRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawCreditRequestToJson(this);
}
