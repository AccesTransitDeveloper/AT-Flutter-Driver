import 'package:json_annotation/json_annotation.dart';

part 'payment_intent_response.g.dart';

@JsonSerializable()
class PaymentIntentResponse {
  final int? paymentGatewayType;
  final String? paymentTransactionId;
  final int? paymentTransactionStatus;
  final IntentPayment? intent;

  PaymentIntentResponse({
    this.paymentGatewayType,
    this.paymentTransactionId,
    this.paymentTransactionStatus,
    this.intent,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentIntentResponseToJson(this);
}

@JsonSerializable()
class IntentPayment {
  final String? id;
  final String? paymentMethod;
  final String? clientSecret;
  final String? publicKey;
  final String? url;
  final String? html;
  @JsonKey(name: 'authorization_url')
  final String? authorizationUrl;
  @JsonKey(name: 'access_code')
  final String? accessCode;
  final String? reference;

  IntentPayment({
    this.id,
    this.paymentMethod,
    this.clientSecret,
    this.publicKey,
    this.url,
    this.html,
    this.authorizationUrl,
    this.accessCode,
    this.reference,
  });

  factory IntentPayment.fromJson(Map<String, dynamic> json) =>
      _$IntentPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$IntentPaymentToJson(this);
}
