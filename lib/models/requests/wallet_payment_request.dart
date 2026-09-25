import 'package:json_annotation/json_annotation.dart';

part 'wallet_payment_request.g.dart';

@JsonSerializable(includeIfNull: false)
class WalletPaymentRequest {
  final double? amount;
  final String? countryId;
  final String? currency;
  final int? paymentPurpose;

  WalletPaymentRequest({
    this.amount,
    this.countryId,
    this.currency,
    this.paymentPurpose,
  });

  factory WalletPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$WalletPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WalletPaymentRequestToJson(this);
}
