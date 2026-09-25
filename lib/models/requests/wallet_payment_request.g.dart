// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletPaymentRequest _$WalletPaymentRequestFromJson(
  Map<String, dynamic> json,
) => WalletPaymentRequest(
  amount: (json['amount'] as num?)?.toDouble(),
  countryId: json['countryId'] as String?,
  currency: json['currency'] as String?,
  paymentPurpose: (json['paymentPurpose'] as num?)?.toInt(),
);

Map<String, dynamic> _$WalletPaymentRequestToJson(
  WalletPaymentRequest instance,
) => <String, dynamic>{
  'amount': ?instance.amount,
  'countryId': ?instance.countryId,
  'currency': ?instance.currency,
  'paymentPurpose': ?instance.paymentPurpose,
};
