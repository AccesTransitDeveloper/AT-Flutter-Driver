// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_bank_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddBankResponse _$AddBankResponseFromJson(Map<String, dynamic> json) =>
    AddBankResponse(
      bankAccount: json['bankAccount'] == null
          ? null
          : BankAccount.fromJson(json['bankAccount'] as Map<String, dynamic>),
      paymentGatewayType: (json['paymentGatewayType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AddBankResponseToJson(AddBankResponse instance) =>
    <String, dynamic>{
      'bankAccount': instance.bankAccount,
      'paymentGatewayType': instance.paymentGatewayType,
    };

BankAccount _$BankAccountFromJson(Map<String, dynamic> json) =>
    BankAccount(accountLink: json['accountLink'] as String?);

Map<String, dynamic> _$BankAccountToJson(BankAccount instance) =>
    <String, dynamic>{'accountLink': instance.accountLink};
