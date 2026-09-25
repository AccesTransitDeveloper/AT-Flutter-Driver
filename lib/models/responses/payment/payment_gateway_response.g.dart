// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_gateway_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentGatewayResponse _$PaymentGatewayResponseFromJson(
  Map<String, dynamic> json,
) => PaymentGatewayResponse(
  paymentGateways: (json['paymentGateways'] as List<dynamic>?)
      ?.map((e) => PaymentGateway.fromJson(e as Map<String, dynamic>))
      .toList(),
  bankTransferSetting: json['bankTransferSetting'] == null
      ? null
      : BankTransferSetting.fromJson(
          json['bankTransferSetting'] as Map<String, dynamic>,
        ),
  creditWithdrawSetting: json['creditWithdrawSetting'] == null
      ? null
      : CreditWithdrawSetting.fromJson(
          json['creditWithdrawSetting'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PaymentGatewayResponseToJson(
  PaymentGatewayResponse instance,
) => <String, dynamic>{
  'paymentGateways': instance.paymentGateways,
  'bankTransferSetting': instance.bankTransferSetting,
  'creditWithdrawSetting': instance.creditWithdrawSetting,
};

PaymentGateway _$PaymentGatewayFromJson(Map<String, dynamic> json) =>
    PaymentGateway(
      credential: json['credential'] == null
          ? null
          : Credential.fromJson(json['credential'] as Map<String, dynamic>),
      isAllowCaptureLater: json['isAllowCaptureLater'] as bool?,
      isAllowSaveBank: json['isAllowSaveBank'] as bool?,
      isAllowSaveCard: json['isAllowSaveCard'] as bool?,
      type: (json['type'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PaymentGatewayToJson(PaymentGateway instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'isAllowCaptureLater': instance.isAllowCaptureLater,
      'isAllowSaveBank': instance.isAllowSaveBank,
      'isAllowSaveCard': instance.isAllowSaveCard,
      'type': instance.type,
      'name': instance.name,
    };

Credential _$CredentialFromJson(Map<String, dynamic> json) =>
    Credential(publicKey: json['publicKey'] as String?);

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{'publicKey': instance.publicKey};

BankTransferSetting _$BankTransferSettingFromJson(Map<String, dynamic> json) =>
    BankTransferSetting(
      paymentGateway: (json['paymentGateway'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BankTransferSettingToJson(
  BankTransferSetting instance,
) => <String, dynamic>{'paymentGateway': instance.paymentGateway};

CreditWithdrawSetting _$CreditWithdrawSettingFromJson(
  Map<String, dynamic> json,
) => CreditWithdrawSetting(
  isActive: json['isActive'] as bool?,
  isAdminApproval: json['isAdminApproval'] as bool?,
  minCreditAmount: (json['minCreditAmount'] as num?)?.toDouble(),
  taxIds: (json['taxIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  taxType: (json['taxType'] as num?)?.toInt(),
  withdrawLimit: json['withdrawLimit'] == null
      ? null
      : WithdrawLimit.fromJson(json['withdrawLimit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreditWithdrawSettingToJson(
  CreditWithdrawSetting instance,
) => <String, dynamic>{
  'isActive': instance.isActive,
  'isAdminApproval': instance.isAdminApproval,
  'minCreditAmount': instance.minCreditAmount,
  'taxIds': instance.taxIds,
  'taxType': instance.taxType,
  'withdrawLimit': instance.withdrawLimit,
};

WithdrawLimit _$WithdrawLimitFromJson(Map<String, dynamic> json) =>
    WithdrawLimit(
      isActive: json['isActive'] as bool?,
      limit: (json['limit'] as num?)?.toDouble(),
      limitType: (json['limitType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WithdrawLimitToJson(WithdrawLimit instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'limit': instance.limit,
      'limitType': instance.limitType,
    };
