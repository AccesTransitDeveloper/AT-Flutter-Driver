import 'package:json_annotation/json_annotation.dart';

part 'redeem_point_response.g.dart';

String? _uniqueIdFromJson(dynamic value) => value?.toString();

@JsonSerializable()
class RedeemPointResponse {
  final int? pages;
  final List<RedeemTransaction>? transactions;

  RedeemPointResponse({this.pages, this.transactions});

  factory RedeemPointResponse.fromJson(Map<String, dynamic> json) =>
      _$RedeemPointResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RedeemPointResponseToJson(this);
}

@JsonSerializable()
class RedeemTransaction {
  final String? createdAt;
  final String? description;
  @JsonKey(name: '_id')
  final String? id;
  final double? rewardPoint;
  final int? status;
  final double? totalRewardPoint;
  final int? transactionType;
  final int? type;
  final String? typeId;
  @JsonKey(fromJson: _uniqueIdFromJson)
  final String? uniqueId;
  @JsonKey(fromJson: _uniqueIdFromJson)
  final String? bookingUniqueId;

  RedeemTransaction({
    this.createdAt,
    this.description,
    this.id,
    this.rewardPoint,
    this.status,
    this.totalRewardPoint,
    this.transactionType,
    this.type,
    this.typeId,
    this.uniqueId,
    this.bookingUniqueId,
  });

  factory RedeemTransaction.fromJson(Map<String, dynamic> json) =>
      _$RedeemTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$RedeemTransactionToJson(this);
}
