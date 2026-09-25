// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_card_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCardIntentResponse _$AddCardIntentResponseFromJson(
  Map<String, dynamic> json,
) => AddCardIntentResponse(
  intent: json['intent'] == null
      ? null
      : Intent.fromJson(json['intent'] as Map<String, dynamic>),
  paymentGatewayType: (json['paymentGatewayType'] as num?)?.toInt(),
  paymentTransactionStatus: (json['paymentTransactionStatus'] as num?)?.toInt(),
  paymentTransactionId: json['paymentTransactionId'] as String?,
);

Map<String, dynamic> _$AddCardIntentResponseToJson(
  AddCardIntentResponse instance,
) => <String, dynamic>{
  'intent': instance.intent,
  'paymentGatewayType': instance.paymentGatewayType,
  'paymentTransactionStatus': instance.paymentTransactionStatus,
  'paymentTransactionId': instance.paymentTransactionId,
};

Intent _$IntentFromJson(Map<String, dynamic> json) => Intent(
  accessCode: json['access_code'] as String?,
  id: json['id'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  authorizationUrl: json['authorization_url'] as String?,
  url: json['url'] as String?,
  html: json['html'] as String?,
  reference: json['reference'] as String?,
  clientSecret: json['client_secret'] as String?,
  publicKey: json['publicKey'] as String?,
);

Map<String, dynamic> _$IntentToJson(Intent instance) => <String, dynamic>{
  'access_code': instance.accessCode,
  'id': instance.id,
  'paymentMethod': instance.paymentMethod,
  'authorization_url': instance.authorizationUrl,
  'url': instance.url,
  'html': instance.html,
  'reference': instance.reference,
  'client_secret': instance.clientSecret,
  'publicKey': instance.publicKey,
};
