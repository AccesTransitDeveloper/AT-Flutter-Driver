import 'package:json_annotation/json_annotation.dart';

part 'card_response.g.dart';

@JsonSerializable()
class GetCardsResponse {
  final List<CardResponse>? cards;
  final List<CardResponse>? bankAccounts;

  GetCardsResponse({this.cards, this.bankAccounts});

  factory GetCardsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCardsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetCardsResponseToJson(this);
}

@JsonSerializable()
class CardResponse {
  final String? cardType;
  final String? fingerprint;
  @JsonKey(name: '_id')
  final String? id;
  final bool? isDefault;
  final String? lastFour;
  final String? paymentCustomerId;
  final int? paymentGatewayType;
  final String? paymentGatewayTypeId;
  final String? token;
  final int? type;
  final int? status;
  final String? typeId;
  final String? cardName;
  final bool? isEnable;
  final String? routingNumber;
  final String? accountNumber;
  final String? accountId;
  final String? bankId;

  CardResponse({
    this.cardType,
    this.fingerprint,
    this.id,
    this.isDefault,
    this.lastFour,
    this.paymentCustomerId,
    this.paymentGatewayType,
    this.paymentGatewayTypeId,
    this.token,
    this.type,
    this.status,
    this.typeId,
    this.cardName,
    this.isEnable,
    this.routingNumber,
    this.accountNumber,
    this.accountId,
    this.bankId,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) =>
      _$CardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CardResponseToJson(this);

  CardResponse copyWith({
    String? cardType,
    String? fingerprint,
    String? id,
    bool? isDefault,
    String? lastFour,
    String? paymentCustomerId,
    int? paymentGatewayType,
    String? paymentGatewayTypeId,
    String? token,
    int? type,
    int? status,
    String? typeId,
    String? cardName,
    bool? isEnable,
    String? routingNumber,
    String? accountNumber,
    String? accountId,
    String? bankId,
  }) {
    return CardResponse(
      cardType: cardType ?? this.cardType,
      fingerprint: fingerprint ?? this.fingerprint,
      id: id ?? this.id,
      isDefault: isDefault ?? this.isDefault,
      lastFour: lastFour ?? this.lastFour,
      paymentCustomerId: paymentCustomerId ?? this.paymentCustomerId,
      paymentGatewayType: paymentGatewayType ?? this.paymentGatewayType,
      paymentGatewayTypeId: paymentGatewayTypeId ?? this.paymentGatewayTypeId,
      token: token ?? this.token,
      type: type ?? this.type,
      status: status ?? this.status,
      typeId: typeId ?? this.typeId,
      cardName: cardName ?? this.cardName,
      isEnable: isEnable ?? this.isEnable,
      routingNumber: routingNumber ?? this.routingNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      accountId: accountId ?? this.accountId,
      bankId: bankId ?? this.bankId,
    );
  }
}
