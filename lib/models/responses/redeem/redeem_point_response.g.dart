// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeem_point_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedeemPointResponse _$RedeemPointResponseFromJson(Map<String, dynamic> json) =>
    RedeemPointResponse(
      pages: (json['pages'] as num?)?.toInt(),
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => RedeemTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RedeemPointResponseToJson(
  RedeemPointResponse instance,
) => <String, dynamic>{
  'pages': instance.pages,
  'transactions': instance.transactions,
};

RedeemTransaction _$RedeemTransactionFromJson(Map<String, dynamic> json) =>
    RedeemTransaction(
      createdAt: json['createdAt'] as String?,
      description: json['description'] as String?,
      id: json['_id'] as String?,
      rewardPoint: (json['rewardPoint'] as num?)?.toDouble(),
      status: (json['status'] as num?)?.toInt(),
      totalRewardPoint: (json['totalRewardPoint'] as num?)?.toDouble(),
      transactionType: (json['transactionType'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      typeId: json['typeId'] as String?,
      uniqueId: _uniqueIdFromJson(json['uniqueId']),
      bookingUniqueId: _uniqueIdFromJson(json['bookingUniqueId']),
    );

Map<String, dynamic> _$RedeemTransactionToJson(RedeemTransaction instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'description': instance.description,
      '_id': instance.id,
      'rewardPoint': instance.rewardPoint,
      'status': instance.status,
      'totalRewardPoint': instance.totalRewardPoint,
      'transactionType': instance.transactionType,
      'type': instance.type,
      'typeId': instance.typeId,
      'uniqueId': instance.uniqueId,
      'bookingUniqueId': instance.bookingUniqueId,
    };
