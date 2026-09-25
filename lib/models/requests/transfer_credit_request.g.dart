// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_credit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferCreditRequest _$TransferCreditRequestFromJson(
  Map<String, dynamic> json,
) => TransferCreditRequest(
  amount: (json['amount'] as num?)?.toDouble(),
  type: (json['type'] as num?)?.toInt(),
  typeId: json['typeId'] as String?,
);

Map<String, dynamic> _$TransferCreditRequestToJson(
  TransferCreditRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'type': instance.type,
  'typeId': instance.typeId,
};
