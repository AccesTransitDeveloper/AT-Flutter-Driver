// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_withdraw_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditWithdrawResponse _$CreditWithdrawResponseFromJson(
  Map<String, dynamic> json,
) => CreditWithdrawResponse(
  amount: (json['amount'] as num?)?.toDouble(),
  bankAmount: (json['bankAmount'] as num?)?.toDouble(),
  debitAmount: (json['debitAmount'] as num?)?.toDouble(),
  taxAmount: (json['taxAmount'] as num?)?.toDouble(),
  taxDetail: json['taxDetail'] == null
      ? null
      : TaxDetail.fromJson(json['taxDetail'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreditWithdrawResponseToJson(
  CreditWithdrawResponse instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'bankAmount': instance.bankAmount,
  'debitAmount': instance.debitAmount,
  'taxAmount': instance.taxAmount,
  'taxDetail': instance.taxDetail,
};

TaxDetail _$TaxDetailFromJson(Map<String, dynamic> json) => TaxDetail(
  taxes: (json['taxes'] as List<dynamic>?)
      ?.map((e) => Tax.fromJson(e as Map<String, dynamic>))
      .toList(),
  taxType: (json['taxType'] as num?)?.toInt(),
);

Map<String, dynamic> _$TaxDetailToJson(TaxDetail instance) => <String, dynamic>{
  'taxes': instance.taxes,
  'taxType': instance.taxType,
};

Tax _$TaxFromJson(Map<String, dynamic> json) => Tax(
  name: (json['name'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  value: (json['value'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TaxToJson(Tax instance) => <String, dynamic>{
  'name': instance.name,
  'value': instance.value,
};
