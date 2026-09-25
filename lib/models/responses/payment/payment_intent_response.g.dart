// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentResponse _$PaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => PaymentIntentResponse(
  paymentGatewayType: (json['paymentGatewayType'] as num?)?.toInt(),
  paymentTransactionId: json['paymentTransactionId'] as String?,
  paymentTransactionStatus: (json['paymentTransactionStatus'] as num?)?.toInt(),
  intent: json['intent'] == null
      ? null
      : IntentPayment.fromJson(json['intent'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentIntentResponseToJson(
  PaymentIntentResponse instance,
) => <String, dynamic>{
  'paymentGatewayType': instance.paymentGatewayType,
  'paymentTransactionId': instance.paymentTransactionId,
  'paymentTransactionStatus': instance.paymentTransactionStatus,
  'intent': instance.intent,
};

IntentPayment _$IntentPaymentFromJson(Map<String, dynamic> json) =>
    IntentPayment(
      id: json['id'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      clientSecret: json['clientSecret'] as String?,
      publicKey: json['publicKey'] as String?,
      url: json['url'] as String?,
      html: json['html'] as String?,
      authorizationUrl: json['authorization_url'] as String?,
      accessCode: json['access_code'] as String?,
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$IntentPaymentToJson(IntentPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentMethod': instance.paymentMethod,
      'clientSecret': instance.clientSecret,
      'publicKey': instance.publicKey,
      'url': instance.url,
      'html': instance.html,
      'authorization_url': instance.authorizationUrl,
      'access_code': instance.accessCode,
      'reference': instance.reference,
    };
