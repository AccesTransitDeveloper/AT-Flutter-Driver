import 'package:json_annotation/json_annotation.dart';

part 'add_bank_response.g.dart';

@JsonSerializable()
class AddBankResponse {
  final BankAccount? bankAccount;
  final int? paymentGatewayType;

  AddBankResponse({this.bankAccount, this.paymentGatewayType});

  factory AddBankResponse.fromJson(Map<String, dynamic> json) =>
      _$AddBankResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddBankResponseToJson(this);
}

@JsonSerializable()
class BankAccount {
  final String? accountLink;

  BankAccount({this.accountLink});

  factory BankAccount.fromJson(Map<String, dynamic> json) =>
      _$BankAccountFromJson(json);

  Map<String, dynamic> toJson() => _$BankAccountToJson(this);
}
