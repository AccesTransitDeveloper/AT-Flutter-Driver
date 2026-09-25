import 'package:json_annotation/json_annotation.dart';

part 'add_card_intent_response.g.dart';

@JsonSerializable()
class AddCardIntentResponse {
  final Intent? intent;
  final int? paymentGatewayType;
  final int? paymentTransactionStatus;
  final String? paymentTransactionId;

  AddCardIntentResponse({
    this.intent,
    this.paymentGatewayType,
    this.paymentTransactionStatus,
    this.paymentTransactionId,
  });

  factory AddCardIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCardIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddCardIntentResponseToJson(this);
}

@JsonSerializable()
class Intent {
  @JsonKey(name: 'access_code')
  final String? accessCode;
  final String? id;
  final String? paymentMethod;
  @JsonKey(name: 'authorization_url')
  final String? authorizationUrl;
  final String? url;
  final String? html;
  final String? reference;
  @JsonKey(name: 'client_secret')
  final String? clientSecret;
  final String? publicKey;

  Intent({
    this.accessCode,
    this.id,
    this.paymentMethod,
    this.authorizationUrl,
    this.url,
    this.html,
    this.reference,
    this.clientSecret,
    this.publicKey,
  });

  factory Intent.fromJson(Map<String, dynamic> json) => _$IntentFromJson(json);

  Map<String, dynamic> toJson() => _$IntentToJson(this);
}
