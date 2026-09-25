import 'package:json_annotation/json_annotation.dart';

part 'transaction_credit_response.g.dart';

@JsonSerializable()
class TransactionCreditResponse {
  final int? pages;
  final List<TransactionCredit>? transactions;

  TransactionCreditResponse({
    this.pages,
    this.transactions,
  });

  factory TransactionCreditResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionCreditResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionCreditResponseToJson(this);
}

@JsonSerializable()
class TransactionCredit {
  final double? amount;
  final dynamic bookingId;
  final String? bookingUniqueId;
  final String? createdAt;
  final String? currencyCode;
  final String? description;
  @JsonKey(name: '_id')
  final String? id;
  final int? status;
  final double? totalWalletAmount;
  final int? transactionType;
  final int? type;
  final String? typeId;
  final int? uniqueId;

  TransactionCredit({
    this.amount,
    this.bookingId,
    this.bookingUniqueId,
    this.createdAt,
    this.currencyCode,
    this.description,
    this.id,
    this.status,
    this.totalWalletAmount,
    this.transactionType,
    this.type,
    this.typeId,
    this.uniqueId,
  });

  factory TransactionCredit.fromJson(Map<String, dynamic> json) =>
      _$TransactionCreditFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionCreditToJson(this);
}
