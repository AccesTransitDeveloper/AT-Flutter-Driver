// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionResponse _$SubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionResponse(
  vehicleSubscriptions: (json['vehicleSubscriptions'] as List<dynamic>?)
      ?.map((e) => VehicleSubscription.fromJson(e as Map<String, dynamic>))
      .toList(),
  subscriptions: (json['subscriptions'] as List<dynamic>?)
      ?.map((e) => SubscriptionInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SubscriptionResponseToJson(
  SubscriptionResponse instance,
) => <String, dynamic>{
  'vehicleSubscriptions': instance.vehicleSubscriptions,
  'subscriptions': instance.subscriptions,
};

SubscriptionVehicleUpgradeResponse _$SubscriptionVehicleUpgradeResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionVehicleUpgradeResponse(
  paidAmount: (json['paidAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SubscriptionVehicleUpgradeResponseToJson(
  SubscriptionVehicleUpgradeResponse instance,
) => <String, dynamic>{'paidAmount': instance.paidAmount};

SubscriptionInvoiceResponse _$SubscriptionInvoiceResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionInvoiceResponse(
  transactionReference: json['transactionReference'] == null
      ? null
      : TransactionReference.fromJson(
          json['transactionReference'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SubscriptionInvoiceResponseToJson(
  SubscriptionInvoiceResponse instance,
) => <String, dynamic>{'transactionReference': instance.transactionReference};

TransactionReference _$TransactionReferenceFromJson(
  Map<String, dynamic> json,
) => TransactionReference(
  status: json['status'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$TransactionReferenceToJson(
  TransactionReference instance,
) => <String, dynamic>{'status': instance.status, 'url': instance.url};
