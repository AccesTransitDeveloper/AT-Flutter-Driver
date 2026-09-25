// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_credit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionCreditResponse _$TransactionCreditResponseFromJson(
  Map<String, dynamic> json,
) => TransactionCreditResponse(
  pages: (json['pages'] as num?)?.toInt(),
  transactions: (json['transactions'] as List<dynamic>?)
      ?.map((e) => TransactionCredit.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TransactionCreditResponseToJson(
  TransactionCreditResponse instance,
) => <String, dynamic>{
  'pages': instance.pages,
  'transactions': instance.transactions,
};

TransactionCredit _$TransactionCreditFromJson(Map<String, dynamic> json) =>
    TransactionCredit(
      amount: (json['amount'] as num?)?.toDouble(),
      bookingId: json['bookingId'],
      bookingUniqueId: json['bookingUniqueId'] as String?,
      createdAt: json['createdAt'] as String?,
      currencyCode: json['currencyCode'] as String?,
      description: json['description'] as String?,
      id: json['_id'] as String?,
      status: (json['status'] as num?)?.toInt(),
      totalWalletAmount: (json['totalWalletAmount'] as num?)?.toDouble(),
      transactionType: (json['transactionType'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      typeId: json['typeId'] as String?,
      uniqueId: (json['uniqueId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransactionCreditToJson(TransactionCredit instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'bookingId': instance.bookingId,
      'bookingUniqueId': instance.bookingUniqueId,
      'createdAt': instance.createdAt,
      'currencyCode': instance.currencyCode,
      'description': instance.description,
      '_id': instance.id,
      'status': instance.status,
      'totalWalletAmount': instance.totalWalletAmount,
      'transactionType': instance.transactionType,
      'type': instance.type,
      'typeId': instance.typeId,
      'uniqueId': instance.uniqueId,
    };
