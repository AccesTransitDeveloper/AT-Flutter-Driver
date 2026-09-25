import 'package:json_annotation/json_annotation.dart';

part 'transfer_credit_request.g.dart';

@JsonSerializable()
class TransferCreditRequest {
  final double? amount;
  final int? type;
  final String? typeId;

  TransferCreditRequest({
    this.amount,
    this.type,
    this.typeId,
  });

  factory TransferCreditRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferCreditRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferCreditRequestToJson(this);
}
