import 'package:json_annotation/json_annotation.dart';

part 'credit_withdraw_response.g.dart';

@JsonSerializable()
class CreditWithdrawResponse {
  final double? amount;
  final double? bankAmount;
  final double? debitAmount;
  final double? taxAmount;
  final TaxDetail? taxDetail;

  CreditWithdrawResponse({
    this.amount,
    this.bankAmount,
    this.debitAmount,
    this.taxAmount,
    this.taxDetail,
  });

  factory CreditWithdrawResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditWithdrawResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreditWithdrawResponseToJson(this);
}

@JsonSerializable()
class TaxDetail {
  final List<Tax>? taxes;
  final int? taxType;

  TaxDetail({this.taxes, this.taxType});

  factory TaxDetail.fromJson(Map<String, dynamic> json) =>
      _$TaxDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TaxDetailToJson(this);
}

@JsonSerializable()
class Tax {
  final Map<String, String>? name;
  final double? value;

  Tax({this.name, this.value});

  factory Tax.fromJson(Map<String, dynamic> json) => _$TaxFromJson(json);

  Map<String, dynamic> toJson() => _$TaxToJson(this);
}
