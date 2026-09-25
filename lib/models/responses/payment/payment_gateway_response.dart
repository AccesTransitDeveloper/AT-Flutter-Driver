import 'package:json_annotation/json_annotation.dart';

part 'payment_gateway_response.g.dart';

@JsonSerializable()
class PaymentGatewayResponse {
  final List<PaymentGateway>? paymentGateways;
  final BankTransferSetting? bankTransferSetting;
  final CreditWithdrawSetting? creditWithdrawSetting;

  PaymentGatewayResponse({
    this.paymentGateways,
    this.bankTransferSetting,
    this.creditWithdrawSetting,
  });

  factory PaymentGatewayResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentGatewayResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentGatewayResponseToJson(this);

  /// Whether to show bank option (matches Kotlin getShowBank())
  bool get showBank =>
      creditWithdrawSetting?.isActive == true ||
      bankTransferSetting != null;
}

@JsonSerializable()
class PaymentGateway {
  final Credential? credential;
  final bool? isAllowCaptureLater;
  final bool? isAllowSaveBank;
  final bool? isAllowSaveCard;
  final int? type;
  final String? name;

  PaymentGateway({
    this.credential,
    this.isAllowCaptureLater,
    this.isAllowSaveBank,
    this.isAllowSaveCard,
    this.type,
    this.name,
  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) =>
      _$PaymentGatewayFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentGatewayToJson(this);

  PaymentGateway copyWith({
    Credential? credential,
    bool? isAllowCaptureLater,
    bool? isAllowSaveBank,
    bool? isAllowSaveCard,
    int? type,
    String? name,
  }) {
    return PaymentGateway(
      credential: credential ?? this.credential,
      isAllowCaptureLater: isAllowCaptureLater ?? this.isAllowCaptureLater,
      isAllowSaveBank: isAllowSaveBank ?? this.isAllowSaveBank,
      isAllowSaveCard: isAllowSaveCard ?? this.isAllowSaveCard,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}

@JsonSerializable()
class Credential {
  final String? publicKey;

  Credential({this.publicKey});

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialToJson(this);
}

@JsonSerializable()
class BankTransferSetting {
  final int? paymentGateway;

  BankTransferSetting({this.paymentGateway});

  factory BankTransferSetting.fromJson(Map<String, dynamic> json) =>
      _$BankTransferSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BankTransferSettingToJson(this);
}

@JsonSerializable()
class CreditWithdrawSetting {
  final bool? isActive;
  final bool? isAdminApproval;
  final double? minCreditAmount;
  final List<String>? taxIds;
  final int? taxType;
  final WithdrawLimit? withdrawLimit;

  CreditWithdrawSetting({
    this.isActive,
    this.isAdminApproval,
    this.minCreditAmount,
    this.taxIds,
    this.taxType,
    this.withdrawLimit,
  });

  factory CreditWithdrawSetting.fromJson(Map<String, dynamic> json) =>
      _$CreditWithdrawSettingFromJson(json);

  Map<String, dynamic> toJson() => _$CreditWithdrawSettingToJson(this);
}

@JsonSerializable()
class WithdrawLimit {
  final bool? isActive;
  final double? limit;
  final int? limitType;

  WithdrawLimit({this.isActive, this.limit, this.limitType});

  factory WithdrawLimit.fromJson(Map<String, dynamic> json) =>
      _$WithdrawLimitFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawLimitToJson(this);
}
